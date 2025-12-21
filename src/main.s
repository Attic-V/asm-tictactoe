LF equ 10

section .data
	x_board dw 0                            ; bitboard for player x
	o_board dw 0                            ; bitboard for player o

section .rodata
	winmsg_x db "X wins!", LF, 0            ; win message for x
	winmsg_o db "O wins!", LF, 0            ; win message for o

	drawmsg db "The game has ended ", \
		"in a draw.", LF, 0             ; draw message

section .text
	extern write_printChar
	extern write_printSpace
	extern write_printLf
	extern write_printStr
	extern read_getDigit
	extern read_getChar
	global _start                           ; expose _start to the linker

_start:
	call    main

	mov     rax, 60                         ; exit
	mov     rdi, 0                          ; code 0
	syscall

main:
	push    rbp
	mov     rbp, rsp

	mov     cl, 9                           ; 9 board cells to loop through

.x:
	push    rcx                             ; save rcx
	lea     rdi, [x_board]                  ; pass x board to place_piece
	call    place_piece                     ; place piece in x board
	call    print_board                     ; display board
	call    write_printLf
	mov     rdi, [x_board]                  ; pass x_board to check_win
	call    checkWin                        ; checkWin x_board
	pop     rcx                             ; restore rcx
	cmp     rax, 1                          ; if x won
	je      .win_x                          ; then jump .win_x

	loop    .o                              ; dec cl and jump .o if cl > 0
	jmp     .draw                           ; else go to .draw

.o:
	push    rcx                             ; save rcx
	lea     rdi, [o_board]                  ; pass o board to place_piece
	call    place_piece                     ; place piece in o board
	call    print_board                     ; display board
	call    write_printLf
	mov     rdi, [o_board]                  ; pass o_board to check_win
	call    checkWin                        ; checkWin o_board
	pop     rcx                             ; restore rcx
	cmp     rax, 1                          ; if o won
	je      .win_o                          ; then jump .win_o

	dec     cl                              ; decrement counter
	jnz     .x                              ; loop .x if cl > 0
	jmp     .draw                           ; else go to .draw

.win_x:
	mov     rdi, winmsg_x                   ; pass to printst
	jmp     .end
.win_o:
	mov     rdi, winmsg_o                   ; pass to printst
	jmp     .end
.draw:
	mov     rdi, drawmsg                    ; pass to printst
	jmp     .end

.end:
	call    write_printStr

	leave
	ret

;===============================================
; void placePiece (int *board);
;-----------------------------------------------
; Read input from stdin and place a marker in
; the selected cell of the given board.
;===============================================
place_piece:
	push        rbx

	mov         rbx, rdi

.loop:
	call        getUserInput

	movzx       ecx, word [x_board]
	or          cx, [o_board]

	bt          cx, ax
	jc          .loop

	bts         [rbx], ax

	pop         rbx
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
	mov         di, [markerNone]
	test        bx, [x_board]
	cmovnz      di, [markerX]
	test        bx, [o_board]
	cmovnz      di, [markerO]
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

markerX db 'X'
markerO db 'O'
markerNone db '.'

;===============================================
; int checkWin (int boardstate);
;-----------------------------------------------
; Check whether the given boardstate contains a
; win condition.
;
; Return 1 if a win condition is present and 0
; otherwise.
;===============================================
checkWin:
	mov         ecx, 8

.loop:
	mov         si, [winStates + ecx*2 - 2]
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

winStates dw \
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

	mov         rdi, prompt
	call        write_printStr

	call        read_getDigit
	dec         rax
	mov         rbx, rax

	call        read_getChar
	call        write_printLf

	mov         rax, rbx
	pop         rbx
	ret

prompt: db "Enter position [1-9]: ", 0
