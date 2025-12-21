LF equ 10

section .data
	x_board dw 0                            ; bitboard for player x
	o_board dw 0                            ; bitboard for player o

section .rodata
	prompt db "enter position [1-9]: ", 0   ; move prompt string

	winmsg_x db "X wins!", LF, 0            ; win message for x
	winmsg_o db "O wins!", LF, 0            ; win message for o

	drawmsg db "The game has ended ", \
		"in a draw.", LF, 0             ; draw message

	win_states dw \
		0b111000000, 0b000111000, \
		0b000000111, 0b100100100, \
		0b010010010, 0b001001001, \
		0b100010001, 0b001010100        ; all possible wincons
	win_state_count equ 8                   ; number of possible wincons

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
	call    check_win                       ; check_win x_board
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
	call    check_win                       ; check_win o_board
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
	call    getCellInput
	mov     ecx, eax                        ; cell index in ecx
	mov     edx, 8
	sub     edx, ecx
	mov     ecx, edx

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
	test    r8d, 0x100                      ; check if X occupies cell
	cmovnz  edi, [markerX]                  ; if so then use X marker
	test    r9d, 0x100                      ; check if O occupies cell
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
	shl     r8d, 1                          ; shift temp board left
	shl     r9d, 1                          ; shift temp board left

	loop    .loop

	ret

;===============================================
; int check_win (int boardstate)
;-----------------------------------------------
; Checks whether the given board state contains
; a win condition.
;
; Returns 1 if the a win condition exists and 0
; otherwise.
;===============================================
check_win:
	mov     rsi, win_states                 ; save win state array to rsi
	mov     rcx, win_state_count            ; save win state count to rcx

.loop:
	mov     r8w, [rsi + 2*rcx - 2]          ; load mask
	mov     r9w, r8w                        ; copy mask
	and     r9w, di                         ; apply board to mask
	cmp     r8w, r9w                        ; check if union matches mask
	je      .match                          ; exit if they do match

	loop    .loop
	mov     rax, 0                          ; wincon not found
	ret

.match:
	mov     rax, 1                          ; wincon found
	ret

;===============================================
; int getCellInput ()
;-----------------------------------------------
; Reads a cell number and line feed from stdin
; and returns the cell number as an int. The
; input taken will be of the range 1-9 and the
; cell number returned will be of 0-8.
;===============================================
getCellInput:
	push    rbp
	mov     rbp, rsp

	mov     rdi, prompt
	call    write_printStr                  ; display prompt

	call    read_getDigit                   ; get cell number
	dec     rax                             ; map 1-9 to 0-8
	push    rax                             ; save cell number
	call    read_getChar                    ; consume LF
	call    write_printLf
	pop     rax                             ; restore cell number

	leave
	ret
