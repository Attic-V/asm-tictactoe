LF    equ 10
SPACE equ 32

MARKER_X    equ 'X'
MARKER_O    equ 'O'
MARKER_NONE equ '.'

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

section .text
	extern printch                          ; print.s
	extern printst                          ; print.s
	extern readchar                         ; read.s
	extern read_getDigit
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

	mov     rdi, LF
	call    printch

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

	mov     rdi, LF
	call    printch

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
	call    printst

	mov     rsp, rbp
	pop     rbp
	ret

;===============================================
; void place_piece (int *board)
;-----------------------------------------------
; Read input from stdin and place a piece in
; the selected cell of the given board. Cell
; range is 1-9.
;
; This function is System V ABI compliant.
;===============================================
place_piece:
	push    rbp
	mov     rbp, rsp

.loop:
	push    rdi                             ; save board address
	mov     rdi, prompt                     ; pass to printst
	call    printst

	call    read_getDigit                   ; get desired cell number
	push    rax                             ; save input digit
	call    readchar                        ; consume newline

	mov     rdi, LF
	call    printch

	pop     rax                             ; restore input digit
	pop     rdi                             ; restore board address

	mov     cl, al                          ; move input char to cl
	dec     cl                              ; target 1 is cell 0

	mov     r10d, 0x100                     ; place in temp board 0 cell
	shr     r10d, cl                        ; shift to correct cell

	mov     eax, [x_board]                  ; move x board to ax
	or      eax, [o_board]                  ; or o board with x board in ax
	test    eax, r10d                       ; if target cell is occupied
	jnz     .loop                           ; then try again

	or      [rdi], r10d                     ; place piece in cell on board

	mov     rsp, rbp
	pop     rbp
	ret

; print_board () () - display board to stdout
; clobber: rcx, r8w, r9w, rax, rdx, rbx, rdi, rsi, r11
print_board:
	push    rbp
	mov     rbp, rsp

	mov     rcx, 9                          ; 9 board cells to loop through
	mov     r8w, [x_board]                  ; copy x board to r8w
	mov     r9w, [o_board]                  ; copy o board to r9w

.loop:
	push    rcx                             ; save rcx
	test    r8w, 0x100                      ; check if x occupies cell
	jnz     .print_x                        ; jump if true
	test    r9w, 0x100                      ; check if o occupies cell
	jnz     .print_o                        ; jump if true

	mov     rdi, MARKER_NONE                ; pass empty marker to printch
	jmp     .next

.print_x:
	mov     rdi, MARKER_X                   ; pass x marker to printch
	jmp     .next

.print_o:
	mov     rdi, MARKER_O                   ; pass o marker to printch
	jmp     .next

.next:
	call    printch                         ; print char passed in

	mov     rdi, SPACE
	call    printch                         ; print space

	pop     rcx                             ; restore rcx
	xor     rdx, rdx                        ; zero upper half of dividend
	mov     rax, rcx                        ; copy loop count to rax
	add     rax, 2                          ; offset loop count by 2
	mov     rbx, 3                          ; divisor is 3
	div     rbx                             ; divide rdx:rax by rbx
	test    rdx, rdx                        ; check if remainder is zero
	jnz     .to_loop                        ; loop if false
	push    rcx                             ; save rcx

	mov     rdi, LF
	call    printch

	pop     rcx                             ; restore rcx

.to_loop:
	shl     r8w, 1                          ; shift temp board left
	shl     r9w, 1                          ; shift temp board left

	dec     cl                              ; decrement counter
	jnz     .loop                           ; loop .loop if cl > 0

	mov     rsp, rbp
	pop     rbp
	ret

;===============================================
; int check_win (int boardstate)
;-----------------------------------------------
; Checks whether the given board state contains
; a win condition.
;
; Returns 1 if the a win condition exists and 0
; otherwise.
;
; System V ABI compatible
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
