section .text
	global printch                          ; expose to linker
	global printst                          ; expose to linker

;===============================================
; void printch (char c);
;-----------------------------------------------
; write character to stdout
;
; System V ABI compatible
;===============================================
printch:
	push    rbp
	mov     rbp, rsp
	sub     rsp, 16                         ; reserve space on stack

	mov     [rsp], dil                      ; move character to buffer

	mov     rdi, rsp                        ; pass buffer to print
	mov     rsi, 1                          ; pass length 1 to print
	call    print

	mov     rsp, rbp
	pop     rbp
	ret

;===============================================
; void print (char *buf, int len);
;-----------------------------------------------
; write buffer to stdout
;
; System V ABI compatible
;===============================================
print:
	mov     rdx, rsi                        ; length
	mov     rsi, rdi                        ; address
	mov     rax, 1                          ; write
	mov     rdi, 1                          ; stdout
	syscall

	ret

;===============================================
; void printst (char *buf);
;-----------------------------------------------
; write null-terminated buffer to stdout
;
; System V ABI compatible
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
	call    print

	ret
