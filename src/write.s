section .text
	extern string_len

	global write_printChar
	global write_printSpace
	global write_printLf
	global write_printStr

;===============================================
; void write_printChar (char c);
;-----------------------------------------------
; Write a character to stdout.
;===============================================
write_printChar:
	sub         rsp, 8

	mov         [rsp], dil

	mov         rdi, rsp
	mov         rsi, 1
	call        print

	add         rsp, 8
	ret

;===============================================
; void write_printSpace ();
;-----------------------------------------------
; Write a space character to stdout.
;===============================================
write_printSpace:
	sub         rsp, 8

	mov         rdi, 32
	call        write_printChar

	add         rsp, 8
	ret

;===============================================
; void write_printLf ();
;-----------------------------------------------
; Write a line feed character to stdout.
;===============================================
write_printLf:
	sub         rsp, 8

	mov         rdi, 10
	call        write_printChar

	add         rsp, 8
	ret

;===============================================
; void write_printStr (char *buf);
;-----------------------------------------------
; Write a null-terminated buffer to stdout.
;===============================================
write_printStr:
	push        rbx

	mov         rbx, rdi
	call        string_len

	mov         rdi, rbx
	mov         rsi, rax
	call        print

	pop         rbx
	ret

;===============================================
; void print (char *buf, int len);
;-----------------------------------------------
; Write a buffer with a given length to stdout.
;===============================================
print:
	mov         rdx, rsi
	mov         rsi, rdi
	mov         rax, 1
	mov         rdi, 1
	syscall

	ret
