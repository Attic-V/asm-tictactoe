section .text
	global readchar                         ; expose to linker

; readchar () (rax) - read character from stdin
; rax: character read from stdin
; System V ABI compatible
readchar:
	push    rbp
	mov     rbp, rsp
	sub     rsp, 16                         ; reserve 16 bytes

	mov     rax, 0                          ; read
	mov     rdi, 0                          ; from stdin
	mov     rsi, rsp                        ; to local buffer at rsp
	mov     rdx, 1                          ; 1 character
	syscall

	mov     rax, [rsp]                      ; load character into rax

	mov     rsp, rbp
	pop     rbp
	ret
