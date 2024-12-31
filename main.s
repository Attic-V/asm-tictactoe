%macro printch 1
	mov     rax, 1
	mov     rdi, 1
	mov     rsi, %1
	mov     rdx, 1
	syscall
%endmacro

%macro printst 2
	mov     rax, 1
	mov     rdi, 1
	mov     rsi, %1
	mov     rdx, %2
	syscall
%endmacro

%macro chstate 1
	mov     r10w, %1
	mov     cx, r10w
	and     cx, r11w
	cmp     r10w, cx
	je      .match
%endmacro

section .bss
	input_char resb 1

section .data
	x_board dw 0
	o_board dw 0

	x_char db 'X'
	o_char db 'O'
	e_char db '.'                           ; empty position

	newline db 0xa

	position_prompt db "enter position [1-9]: ", 0
	position_prompt_len equ $ - position_prompt

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
	printst winmsg_x, winmsg_x_len
	jmp     .end

.win_o:
	printst winmsg_o, winmsg_o_len
	jmp     .end

.draw:
	printst drawmsg, drawmsg_len
	jmp     .end

.end:
	mov     rsp, rbp
	pop     rbp
	ret

place_piece:                                    ; (lea r14: board)
	push    rbp
	mov     rbp, rsp

.loop:
	push    r14
	printst position_prompt, position_prompt_len
	call    readchar
	call    print_newline
	pop     r14

	mov     cl, [input_char]
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

check_win:                                      ; (board)
	push    rbp
	mov     rbp, rsp

	mov     r11w, [rbp + 16]

	xor     rax, rax

	chstate 0x1c0                           ; 111 000 000
	chstate 0x38                            ; 000 111 000
	chstate 0x7                             ; 000 000 111
	chstate 0x124                           ; 100 100 100
	chstate 0x92                            ; 010 010 010
	chstate 0x49                            ; 001 001 001
	chstate 0x111                           ; 100 010 001
	chstate 0x54                            ; 001 010 100
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
	mov     rsi, input_char
	mov     rdx, 1
	syscall

	mov     rax, 0
	mov     rdi, 0
	mov     rsi, 0
	mov     rdx, 1
	syscall                                 ; clear return char

	mov     rsp, rbp
	pop     rbp
	ret
