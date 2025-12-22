section .data
	x_board dw 0
	o_board dw 0

section .text
	extern read_getDigit
	extern read_getChar

	extern write_printChar
	extern write_printSpace
	extern write_printLf
	extern write_printStr

	global _start

_start:
	call        main

	mov         rax, 60
	mov         rdi, 0
	syscall

;===============================================
; void main ();
;-----------------------------------------------
;===============================================
main:
	sub         rsp, 8
	push        rbp
	push        rbx

	mov         ebx, 9
	mov         rbp, x_board
	jmp         .turn

.retryinput:
	mov         rdi, .failmsg
	call        write_printStr

.turn:
	call        getUserInput

	mov         rdi, rbp
	mov         esi, eax
	call        place_piece
	cmp         eax, -1
	je          .retryinput

	call        print_board
	call        write_printLf

	mov         rdi, rbp
	call        checkWin
	test        al, 1
	jnz         .end

	xor         rbp, x_board                    ; swap current board
	xor         rbp, o_board

	dec         ebx
	jnz         .turn

.end:
	mov         rcx, .winmsg_x
	mov         rdx, .winmsg_o

	mov         rdi, .drawmsg
	cmp         rbp, x_board
	cmove       rdi, rcx
	cmp         rbp, o_board
	cmove       rdi, rdx
	call        write_printStr

	pop         rbx
	pop         rbp
	add         rsp, 8
	ret

.winmsg_x db "X wins!", 10, 0
.winmsg_o db "O wins!", 10, 0
.drawmsg db "Match drawn.", 10, 0
.failmsg db "Cell is already occupied. ", \
	"Try again.", 10, 0

;===============================================
; int placePiece (int *board, short cell);
;-----------------------------------------------
; Place a marker in the given cell of the given
; board. Return 0 on success and -1 on failure.
;===============================================
place_piece:
	movzx       ecx, word [x_board]
	or          cx, [o_board]

	bt          cx, si
	jc          .fail

	bts         [rdi], si
	mov         eax, 0
	ret

.fail:
	mov         eax, -1
	ret

;===============================================
; void displayBoard ();
;-----------------------------------------------
; Write ASCII drawing of full board to stdout.
;===============================================
print_board:
	push        rbx

	mov         ebx, 1

.loop:
	mov         di, [.markerNone]
	test        bx, [x_board]
	cmovnz      di, [.markerX]
	test        bx, [o_board]
	cmovnz      di, [.markerO]
	call        write_printChar
	call        write_printSpace

	test        ebx, 0x124
	jz          .skipLf
	call        write_printLf

.skipLf:
	shl         ebx, 1
	test        ebx, 0x200
	jz          .loop

	pop         rbx
	ret

.markerX db 'X'
.markerO db 'O'
.markerNone db '.'

;===============================================
; int checkWin (int *boardstate);
;-----------------------------------------------
; Check whether the given boardstate contains a
; win condition.
;
; Return 1 if a win condition is present and 0
; otherwise.
;===============================================
checkWin:
	mov         di, [rdi]
	mov         ecx, 8

.loop:
	mov         si, [.winStates + ecx*2 - 2]
	mov         dx, si
	and         dx, di
	cmp         dx, si
	je          .match

	loop        .loop
	xor         eax, eax
	ret

.match:
	mov         eax, 1
	ret

.winStates dw \
	0b111000000, 0b000111000, 0b000000111, \
	0b100100100, 0b010010010, 0b001001001, \
	0b100010001, 0b001010100

;===============================================
; int getUserInput ();
;-----------------------------------------------
; Get user input from stdin. Return their
; selected cell number as an int in the range
; 0-8. Consume the line feed following their
; selection.
;===============================================
getUserInput:
	push        rbx

	jmp         .input

.retry:
	mov         rdi, .failmsg
	call        write_printStr

.input:
	mov         rdi, .prompt
	call        write_printStr

	call        read_getDigit
	lea         rbx, [rax - 1]

	call        read_getChar
	call        write_printLf

	cmp         rbx, 0
	jl          .retry
	cmp         rbx, 8
	jg          .retry

	mov         rax, rbx
	pop         rbx
	ret

.prompt db "Enter position [1-9]: ", 0
.failmsg db "Input is not in valid range. ", \
	"Please try again.", 10, 0
