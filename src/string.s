section .text
	global string_len

;===============================================
; int string_len (char *buf);
;-----------------------------------------------
; Get the length of a null-terminated buffer
; excluding the null byte.
;===============================================
string_len:
	mov         rsi, rdi
	xor         eax, eax
	mov         rcx, -1

	repne       scasb
	lea         rax, [rdi - 1]
	sub         rax, rsi
	ret
