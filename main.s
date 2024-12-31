%macro printch 1
	mov     rax, 1
	mov     rdi, 1
	mov     rsi, %1
	mov     rdx, 1
	syscall
%endmacro

section .data
	x_board dw 0
	o_board dw 0

	x_char db 'X'
	o_char db 'O'
	e_char db '.'                           ; empty position

	newline db 0xa

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

	mov     rsp, rbp
	pop     rbp
	ret

print_board:
	push    rbp
	mov     rbp, rsp

	mov     cl, 9                           ; counter
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
	printch newline
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
