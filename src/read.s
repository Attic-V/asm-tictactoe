section .text
	global read_getDigit
	global read_getChar

;===============================================
; char read_getChar ();
;-----------------------------------------------
; Read a character from stdin and return it.
;===============================================
read_getChar:
	sub         rsp, 8

	mov         rax, 0
	mov         rdi, 0
	mov         rsi, rsp
	mov         rdx, 1
	syscall

	movzx       eax, byte [rsp]

	add         rsp, 8
	ret

;===============================================
; int read_getDigit ();
;-----------------------------------------------
; Read a character from stdin and convert it to
; a digit. Returns the digit as an int.
;===============================================
read_getDigit:
	push    rbp
	mov     rbp, rsp

	call    read_getChar
	sub     al, '0'

	leave
	ret
