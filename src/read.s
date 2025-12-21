section .text
	global readchar                         ; expose to linker
	global read_getDigit

;===============================================
; char readchar ();
;-----------------------------------------------
; read character from stdin
;
; System V ABI compatible
;===============================================
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

	leave
	ret

;===============================================
; int read_getDigit ();
;-----------------------------------------------
; Read a character from stdin and convert it to
; a digit. Returns the digit as an int.
;
; This function is System V ABI compliant.
;===============================================
read_getDigit:
	push    rbp
	mov     rbp, rsp

	call    readchar
	sub     al, '0'

	leave
	ret
