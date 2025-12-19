; printst (%1) - print null-terminated string to stdout
; %1: buffer address
; clobber: rax, rdi, rsi, rdx, rcx, r11
%macro printst 1
	mov     rsi, %1                         ; load address of string
	xor     rcx, rcx                        ; set length counter to zero

%%loop:
	cmp     byte [rsi + rcx], 0             ; check for null terminator byte
	je      %%done                          ; if found then jump to end
	inc     rcx                             ; else increment length counter
	jmp     %%loop                          ; repeat loop

%%done:
	mov     rdi, rsi                        ; pass address to print
	mov     rsi, rcx                        ; pass length to print
	call    print
%endmacro

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
	push    rcx                             ; save rcx
	lea     r14, [x_board]                  ; pass x board to place_piece
	call    place_piece                     ; place piece in x board
	call    print_board                     ; display board

	mov     dil, [newline]
	call    printch                         ; '\n'

	mov     rdi, [x_board]                  ; pass x_board to check_win
	call    check_win                       ; check_win x_board
	pop     rcx                             ; restore rcx
	cmp     rax, 1                          ; if x won
	je      .win_x                          ; then jump .win_x

	loop    .o                              ; dec cl and jump .o if cl > 0
	jmp     .draw                           ; else go to .draw

.o:
	push    rcx                             ; save rcx
	lea     r14, [o_board]                  ; pass o board to place_piece
	call    place_piece                     ; place piece in o board
	call    print_board                     ; display board

	mov     dil, [newline]
	call    printch                         ; '\n'

	mov     rdi, [o_board]                  ; pass o_board to check_win
	call    check_win                       ; check_win o_board
	pop     rcx                             ; restore rcx
	cmp     rax, 1                          ; if o won
	je      .win_o                          ; then jump .win_o

	dec     cl                              ; decrement counter
	jnz     .x                              ; loop .x if cl > 0
	jmp     .draw                           ; else go to .draw

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

; place_piece (r14) () - place piece on board
; r14: board address
place_piece:
	push    rbp
	mov     rbp, rsp

.loop:
	printst prompt                          ; display input prompt
	call    readchar                        ; get desired cell number
	push    rax                             ; save input char
	call    readchar                        ; consume newline

	mov     dil, [newline]
	call    printch                         ; '\n'

	pop     rax                             ; restore input char

	mov     cl, al                          ; move input char to cl
	cmp     cl, '1'                         ; if target cell < 1
	jl      .loop                           ; then try again
	cmp     cl, '9'                         ; if target cell > 9
	jg      .loop                           ; then try again
	sub     cl, '0'                         ; convert digit char to int
	dec     cl                              ; target 1 is cell 0

	mov     r12w, 0x100                     ; place in temp board 0 cell
	shr     r12w, cl                        ; shift to correct cell

	mov     ax, [x_board]                   ; move x board to ax
	or      ax, [o_board]                   ; or o board with x board in ax
	test    ax, r12w                        ; if target cell is occupied
	jnz     .loop                           ; then try again

	or      [r14], r12w                     ; place piece in cell on board

	mov     rsp, rbp
	pop     rbp
	ret

; print_board () () - display board to stdout
; clobber: rcx, r8w, r9w, rax, rdx, rbx, rdi, rsi, r11
print_board:
	push    rbp
	mov     rbp, rsp

	mov     rcx, 9                          ; 9 board cells to loop through
	mov     r8w, [x_board]                  ; copy x board to r8w
	mov     r9w, [o_board]                  ; copy o board to r9w

.loop:
	push    rcx                             ; save rcx
	test    r8w, 0x100                      ; check if x occupies cell
	jnz     .print_x                        ; jump if true
	test    r9w, 0x100                      ; check if o occupies cell
	jnz     .print_o                        ; jump if true

	mov     dil, [e_char]                   ; pass empty char to printch
	jmp     .next

.print_x:
	mov     dil, [x_char]                   ; pass x char to printch
	jmp     .next

.print_o:
	mov     dil, [o_char]                   ; pass o char to printch
	jmp     .next

.next:
	call    printch                         ; print char passed in

	mov     dil, [space]
	call    printch                         ; print space

	pop     rcx                             ; restore rcx
	xor     rdx, rdx                        ; zero upper half of dividend
	mov     rax, rcx                        ; copy loop count to rax
	add     rax, 2                          ; offset loop count by 2
	mov     rbx, 3                          ; divisor is 3
	div     rbx                             ; divide rdx:rax by rbx
	test    rdx, rdx                        ; check if remainder is zero
	jnz     .to_loop                        ; loop if false
	push    rcx                             ; save rcx

	mov     dil, [newline]
	call    printch                         ; '\n'

	pop     rcx                             ; restore rcx

.to_loop:
	shl     r8w, 1                          ; shift temp board left
	shl     r9w, 1                          ; shift temp board left

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

; readchar () (al) - read character from stdin
; al: character fread from stdin
; clobber: rdi, rsi, rdx, rcx, r11
readchar:
	push    rbp
	mov     rbp, rsp
	sub     rsp, 16                         ; reserve 16 bytes

	mov     rax, 0                          ; read
	mov     rdi, 0                          ; from stdin
	mov     rsi, rsp                        ; to local buffer at rsp
	mov     rdx, 1                          ; 1 character
	syscall

	mov     al, [rsp]                       ; load byte into al

	mov     rsp, rbp
	pop     rbp
	ret

; printch (dil) () - write character to stdout
; dil: character
; System V ABI compatible
printch:
	push    rbp
	mov     rbp, rsp

	sub     rsp, 16                         ; reserve space on stack

	mov     [rsp], dil                      ; move character to buffer

	mov     rax, 1                          ; write
	mov     rdi, 1                          ; stdout
	lea     rsi, [rsp]                      ; &char
	mov     rdx, 1                          ; 1
	syscall

	mov     rsp, rbp
	pop     rbp
	ret

; print (rdi, rsi) () - write buffer to stdout
; rdi: buffer address
; rsi: buffer length
; System V ABI compatible
print:
	push    rbp
	mov     rbp, rsp

	mov     rdx, rsi                        ; length
	mov     rsi, rdi                        ; address
	mov     rax, 1                          ; write
	mov     rdi, 1                          ; stdout
	syscall

	mov     rsp, rbp
	pop     rbp
	ret
