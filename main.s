section .data
	x_board dw 0
	o_board dw 0

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
