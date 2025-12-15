; print (%1, %2) - print buffer to stdout
; %1: buffer address
; %2: buffer length
%macro print 2
	mov     rax, 1                          ; write
	mov     rdi, 1                          ; stdout
	mov     rsi, %1                         ; address
	mov     rdx, %2                         ; length
	syscall
%endmacro

; printch (%1) - print character to stdout
; %1: character address
%macro printch 1
	print %1, 1
%endmacro

section .bss
	in_char resb 1                          ; user input buffer

section .data
	x_board dw 0                            ; bitboard for player x
	o_board dw 0                            ; bitboard for player x

section .rodata
	x_char db 'X'                           ; x position
	o_char db 'O'                           ; o position
	e_char db '.'                           ; empty position

	newline db 0xa                          ; newline character
	space   db 0x20                         ; space character

	prompt db "enter position [1-9]: ", 0   ; move prompt string
	prompt_len equ $ - prompt               ; move prompt string length

	winmsg_x db "X wins!", 0xa
	winmsg_x_len equ $ - winmsg_x

	winmsg_o db "O wins!", 0xa
	winmsg_o_len equ $ - winmsg_o

	drawmsg db "The game has ended in a draw.", 0xa
	drawmsg_len equ $ - drawmsg

section .text
	global _start

_start:
	call    main

	mov     rax, 60
	mov     rdi, 0
	syscall

main:
	push    rbp
	mov     rbp, rsp

	mov     cl, 9

.x:
	push    rcx
	lea     r14, [x_board]
	call    place_piece
	call    print_board
	call    print_newline
	push    word [x_board]
	call    check_win
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
	call    print_newline
	push    word [o_board]
	call    check_win
	pop     rcx
	cmp     rax, 1
	je      .win_o

	loop    .x
	jmp     .draw

.win_x:
	print   winmsg_x, winmsg_x_len
	jmp     .end

.win_o:
	print   winmsg_o, winmsg_o_len
	jmp     .end

.draw:
	print   drawmsg, drawmsg_len
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
	print   prompt, prompt_len
	call    readchar
	call    print_newline
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

	mov     rcx, 9                          ; counter
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
	call    print_e
	jmp     .next

.print_x:
	call    print_x
	jmp     .next

.print_o:
	call    print_o
	jmp     .next

.next:
	call    print_space
	pop     rcx
	xor     rdx, rdx
	mov     rax, rcx
	add     rax, 2
	mov     rbx, 3
	div     rbx
	test    rdx, rdx
	jnz     .to_loop                        ; check if remainder is not zero
	push    rcx
	call    print_newline
	pop     rcx
	pop     r9
	pop     r8

.to_loop:
	shl     r8w, 1
	shl     r9w, 1

	loop    .loop

	mov     rsp, rbp
	pop     rbp
	ret

print_x:
	push    rbp
	mov     rbp, rsp

	printch x_char

	mov     rsp, rbp
	pop     rbp
	ret

print_o:
	push    rbp
	mov     rbp, rsp

	printch o_char

	mov     rsp, rbp
	pop     rbp
	ret

print_e:
	push    rbp
	mov     rbp, rsp

	printch e_char

	mov     rsp, rbp
	pop     rbp
	ret

print_newline:
	push    rbp
	mov     rbp, rsp

	printch newline

	mov     rsp, rbp
	pop     rbp
	ret

print_space:
	push    rbp
	mov     rbp, rsp

	printch space

	mov     rsp, rbp
	pop     rbp
	ret

check_win:              ; (board)
	push    rbp
	mov     rbp, rsp

	mov     r11w, [rbp + 16]

	xor     rax, rax

	mov     r10w, 0b111000000
	mov     cx, r10w
	and     cx, r11w
	cmp     r10w, cx
	je      .match

	mov     r10w, 0b000111000
	mov     cx, r10w
	and     cx, r11w
	cmp     r10w, cx
	je      .match

	mov     r10w, 0b000000111
	mov     cx, r10w
	and     cx, r11w
	cmp     r10w, cx
	je      .match

	mov     r10w, 0b100100100
	mov     cx, r10w
	and     cx, r11w
	cmp     r10w, cx
	je      .match

	mov     r10w, 0b010010010
	mov     cx, r10w
	and     cx, r11w
	cmp     r10w, cx
	je      .match

	mov     r10w, 0b001001001
	mov     cx, r10w
	and     cx, r11w
	cmp     r10w, cx
	je      .match

	mov     r10w, 0b100010001
	mov     cx, r10w
	and     cx, r11w
	cmp     r10w, cx
	je      .match

	mov     r10w, 0b001010100
	mov     cx, r10w
	and     cx, r11w
	cmp     r10w, cx
	je      .match

	jmp     .end

.match:
	mov     rax, 1

.end:
	mov     rsp, rbp
	pop     rbp
	ret     2

readchar:
	push    rbp
	mov     rbp, rsp

	mov     rax, 0
	mov     rdi, 0
	mov     rsi, in_char
	mov     rdx, 1
	syscall

	mov     rax, 0
	mov     rdi, 0
	mov     rsi, 0
	mov     rdx, 1
	syscall                                 ; consume LF

	mov     rsp, rbp
	pop     rbp
	ret
