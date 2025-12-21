LF equ 10

section .data
	x_board dw 0                            ; bitboard for player x
	o_board dw 0                            ; bitboard for player o

section .rodata
	winmsg_x db "X wins!", LF, 0            ; win message for x
	winmsg_o db "O wins!", LF, 0            ; win message for o

	drawmsg db "The game has ended ", \
		"in a draw.", LF, 0             ; draw message

	markerX db 'X'                          ; X marker
	markerO db 'O'                          ; O marker
	markerNone db '.'                       ; empty marker

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
; void place_piece (int *board)
;-----------------------------------------------
; Read input from stdin and place a piece in
; the selected cell of the given board. Cell
; range is 1-9.
;===============================================
place_piece:
	push    rdi                             ; save board address

.loop:
	call    getUserInput
	mov     ecx, eax                        ; cell index in ecx

	mov     eax, [x_board]                  ; track x occupancy
	or      eax, [o_board]                  ; track o occupancy

	bt      eax, ecx                        ; check if cell is occupied
	jc      .loop                           ; if so then retry

	pop     rdi                             ; restore board address
	bts     [rdi], ecx                      ; occupy cell in board

	ret

;===============================================
; void print_board ()
;-----------------------------------------------
; Write ASCII drawing of board to stdout.
;===============================================
print_board:
	mov     ecx, 9                          ; 9 board cells to loop through
	mov     r8d, [x_board]                  ; copy x board to r8d
	mov     r9d, [o_board]                  ; copy o board to r9d

.loop:
	mov     edi, [markerNone]               ; default to empty marker
	test    r8d, 1                          ; check if X occupies cell
	cmovnz  edi, [markerX]                  ; if so then use X marker
	test    r9d, 1                          ; check if O occupies cell
	cmovnz  edi, [markerO]                  ; if so then use O marker
	push    rcx
	call    write_printChar                 ; display marker
	call    write_printSpace
	pop     rcx

	xor     rdx, rdx                        ; zero upper half of dividend
	mov     rax, rcx                        ; dividend
	add     rax, 2                          ; offset dividend by 2
	mov     r10, 3                          ; divisor is 3
	div     r10                             ; divide rdx:rax by r10
	test    rdx, rdx                        ; check if remainder is zero
	jnz     .to_loop                        ; loop if false
	push    rcx
	call    write_printLf
	pop     rcx

.to_loop:
	shr     r8d, 1                          ; shift temp board right
	shr     r9d, 1                          ; shift temp board right

	loop    .loop

	ret

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
