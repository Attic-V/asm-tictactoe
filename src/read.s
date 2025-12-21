section .text
	global read_getChar
	global read_getDigit

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
; Read a character from stdin, convert it to an
; int, and return it.
;===============================================
read_getDigit:
	sub         rsp, 8

	call        read_getChar
	sub         al, '0'

	add         rsp, 8
	ret
