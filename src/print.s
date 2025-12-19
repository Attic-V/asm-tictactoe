section .text
global printch                                  ; expose to linker
global printst                                  ; expose to linker

; printch (rdi) () - write character to stdout
; rdi: character
; System V ABI compatible
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

; print (rdi, rsi) () - write buffer to stdout
; rdi: buffer address
; rsi: buffer length
; System V ABI compatible
print:
	push    rbp
	mov     rbp, rsp

	mov     rdx, rsi                        ; length
	mov     rsi, rdi                        ; address
	mov     rax, 1                          ; write
	mov     rdi, 1                          ; stdout
	syscall

	mov     rsp, rbp
	pop     rbp
	ret

; printst (rdi) () - write a null-terminated buffer to stdout
; rdi: buffer address
; System V ABI compatible
printst:
	push    rbp
	mov     rbp, rsp

	xor     rcx, rcx                        ; set counter to zero

.loop:
	cmp     byte [rdi + rcx], 0             ; check for null byte
	je      .done                           ; if found then break
	inc     rcx                             ; else increment counter
	jmp     .loop

.done:
	mov     rsi, rcx                        ; pass length to print
	call    print

	mov     rsp, rbp
	pop     rbp
	ret
