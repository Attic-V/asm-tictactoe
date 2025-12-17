; print (%1, %2) - print buffer to stdout
; %1: buffer address
; %2: buffer length
; clobber: rax, rdi, rsi, rdx
%macro print 2
	mov     rax, 1                          ; write
	mov     rdi, 1                          ; stdout
	mov     rsi, %1                         ; address
	mov     rdx, %2                         ; length
	syscall
%endmacro

; printch (%1) - print character to stdout
; %1: character address
; clobber: rax, rdi, rsi, rdx
%macro printch 1
	print   %1, 1
%endmacro

; printst (%1) - print null-terminated string to stdout
; %1: buffer address
; clobber: rax, rdi, rsi, rdx, rcx
%macro printst 1
	mov     rsi, %1                         ; load address of string
	xor     rcx, rcx                        ; set length counter to zero

%%loop:
	cmp     byte [rsi + rcx], 0             ; check for null terminator byte
	je      %%done                          ; if found then jump to end
	inc     rcx                             ; else increment length counter
	jmp     %%loop                          ; repeat loop

%%done:
	print   %1, rcx                         ; print address with length
%endmacro

; printnl () () - print a newline character
; clobber: same as printch
%macro printnl 0
	printch newline
%endmacro

section .bss
	in_char resb 1                          ; user input buffer
	discard resb 1                          ; dummy buffer

section .data
	x_board dw 0                            ; bitboard for player x
	o_board dw 0                            ; bitboard for player o

section .rodata
	x_char db 'X'                           ; x position
	o_char db 'O'                           ; o position
	e_char db '.'                           ; empty position

	newline db 0xa                          ; newline character
	space   db 0x20                         ; space character

	prompt db "enter position [1-9]: ", 0   ; move prompt string

	winmsg_x db "X wins!", 0xa, 0           ; win message for x
	winmsg_o db "O wins!", 0xa, 0           ; win message for o

	drawmsg db "The game has ended ", \
		"in a draw.", 0xa, 0            ; draw message

	win_states dw \
		0b111000000, 0b000111000, \
		0b000000111, 0b100100100, \
		0b010010010, 0b001001001, \
		0b100010001, 0b001010100        ; all possible wincons
	win_state_count equ 8                   ; number of possible wincons

section .text
	global _start                           ; expose _start to the linker

_start:
	call    main

	mov     rax, 60                         ; exit
	mov     rdi, 0                          ; code 0
	syscall

main:
	push    rbp
	mov     rbp, rsp

	mov     cl, 9                           ; 9 board cells to loop through

.x:
	push    rcx
	lea     r14, [x_board]
	call    place_piece
	call    print_board
	printnl                                 ; '\n'
	mov     rdi, [x_board]                  ; pass x_board to check_win
	call    check_win                       ; check_win x_board
	pop     rcx
	cmp     rax, 1
	je      .win_x

	loop    .o
	jmp     .draw

.o:
	push    rcx
	lea     r14, [o_board]
	call    place_piece
	call    print_board
	printnl                                 ; '\n'
	mov     rdi, [o_board]                  ; pass o_board to check_win
	call    check_win                       ; check_win o_board
	pop     rcx
	cmp     rax, 1
	je      .win_o

	dec     cl                              ; decrement counter
	jnz     .x                              ; loop .x if cl > 0

	jmp     .draw

.win_x:
	printst winmsg_x                        ; display x win message
	jmp     .end

.win_o:
	printst winmsg_o                        ; display o win message
	jmp     .end

.draw:
	printst drawmsg                         ; display draw message
	jmp     .end

.end:
	mov     rsp, rbp
	pop     rbp
	ret

place_piece:            ; (lea r14: board)
	push    rbp
	mov     rbp, rsp

.loop:
	push    r14
	printst prompt                          ; display input prompt
	mov     rsi, in_char                    ; pass in_char to readchar
	call    readchar                        ; get move char
	mov     rsi, discard                    ; pass discard to readchar
	call    readchar                        ; consume newline
	printnl                                 ; '\n'
	pop     r14

	mov     cl, [in_char]
	cmp     cl, '1'
	jl      .loop
	cmp     cl, '9'
	jg      .loop
	sub     cl, '0'
	dec     cl

	mov     r12w, 0x100
	shr     r12w, cl

	mov     ax, [x_board]
	or      ax, [o_board]
	test    ax, r12w
	jnz     .loop

	or      [r14], r12w

	mov     rsp, rbp
	pop     rbp
	ret

print_board:
	push    rbp
	mov     rbp, rsp

	mov     cl, 9                           ; 9 board cells to loop through
	mov     r8w, [x_board]
	mov     r9w, [o_board]

.loop:
	push    r8
	push    r9
	push    rcx
	test    r8w, 0x100
	jnz     .print_x
	test    r9w, 0x100
	jnz     .print_o
	printch e_char
	jmp     .next

.print_x:
	printch x_char
	jmp     .next

.print_o:
	printch o_char
	jmp     .next

.next:
	printch space
	pop     rcx
	xor     rdx, rdx
	mov     rax, rcx
	add     rax, 2
	mov     rbx, 3
	div     rbx
	test    rdx, rdx
	jnz     .to_loop                        ; check if remainder is not zero
	push    rcx
	printnl                                 ; '\n'
	pop     rcx
	pop     r9
	pop     r8

.to_loop:
	shl     r8w, 1
	shl     r9w, 1

	dec     cl                              ; decrement counter
	jnz     .loop                           ; loop .loop if cl > 0

	mov     rsp, rbp
	pop     rbp
	ret

; check_win (rdi) (rax) - check if a given boardstate contains a wincon
; rdi: word boardstate value
; rax: if wincon was found then 1 else 0
; clobber: r10w, r13w, rcx, rsi
check_win:
	push    rbp
	mov     rbp, rsp

	xor     rax, rax                        ; default to returning false

	mov     rsi, win_states                 ; pointer to win mask list
	mov     rcx, win_state_count            ; loop counter

.loop:
	mov     r10w, [rsi]                     ; load mask
	mov     r13w, r10w                      ; copy mask into temp register
	and     r13w, di                        ; apply board to temp mask
	cmp     r10w, r13w                      ; check if full mask matches
	je      .match                          ; jump if full mask matches

	add     rsi, 2                          ; advance to next mask
	loop    .loop                           ; jmp .loop if (--rcx != 0)
	jmp     .end                            ; go to end

.match:
	mov     rax, 1                          ; found a wincon

.end:
	mov     rsp, rbp
	pop     rbp
	ret

; readchar (rsi) () - read character to buffer from stdin
; rsi: buffer to read to
; clobber: rax, rdi, rdx
readchar:
	push    rbp
	mov     rbp, rsp

	mov     rax, 0                          ; read
	mov     rdi, 0                          ; from stdin
	mov     rdx, 1                          ; 1 character
	syscall                                 ; to [rsi]

	mov     rsp, rbp
	pop     rbp
	ret

