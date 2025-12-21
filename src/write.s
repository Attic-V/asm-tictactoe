section .text
	global printst                          ; expose to linker
	global write_printChar
	global write_printSpace
	global write_printLf

;===============================================
; void printst (char *buf);
;-----------------------------------------------
; write null-terminated buffer to stdout
;===============================================
printst:
	xor     rcx, rcx                        ; set counter to zero

.loop:
	cmp     byte [rdi + rcx], 0             ; check for null byte
	je      .done                           ; if found then break
	inc     rcx                             ; else increment counter
	jmp     .loop

.done:
	mov     rsi, rcx                        ; pass length to print
	sub     rsp, 8                          ; stack alignment
	call    print
	add     rsp, 8                          ; stack alignment

	ret

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
