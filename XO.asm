; Tic Tac Toe Game in 3 Game Modes : U-U , U-C & C-C .
; Start Time : 14/12/2012
; Assembly Language : 8086 Architecture
; Author : Ahmad Siavashi, Ali KianiNejad
; Author's e-mail : ahmad.siavashi@gmail.com, af.kianinejad@gmail.com
include io.h

Win Macro a,b,c
	local end1
	mov al,board[a]
	cmp al,player
	jne	end1
	cmp al,board[b]
	jne end1
	cmp board[c],0
	jg 	end1
	mov ax,c
	call quit1
	end1:
endm

Def Macro a,b,c
	local end1,end2,Ifm,elsem
	mov bl,player
	cmp bl,1
	je	ifm
	jg 	elsem
	jmp end2
	ifm:
		inc bl
		jmp end2
	elsem:
		dec bl
	end2:
	mov al,board[a]
	cmp al,bl
	jne end1
	cmp al,board[b]
	jne end1
	cmp board[c],0
	jg 	end1
	mov ax,c
	call quit1
	end1:
endm

CheakGoodChance Macro a,b,c
	local end1
	mov bl,player
	cmp board[a],bl
	jne end1
	mov bl,board[b]
	cmp bl,0
	jge end1
	mov bl,board[c]
	cmp bl,0
	jge end1
	mov ax,c
	call quit1
	end1:
endm

fill_Color	macro
	push ax
	push bx
	push cx
	push dx
	MOV AH,06H ;request scroll ; clears screen
	MOV AL,00H ;full screen
	MOV BH,1FH ; set attribute,
	MOV CX,0000 ;top left corner
	MOV DH,25 ;bottom right corner of box
	MOV	DL,45
	INT 10H ; interrupt call
	hide_text_cursor
	pop dx
	pop cx
	pop	bx
	pop ax
endm

cls macro
	push ax
	mov ax,02h
	int 10h
	pop ax
endm

hide_text_cursor	macro
	push	cx
	push	ax
	; hide text cursor:
	mov     ah, 1
	mov     ch, 2bh
	mov     cl, 0bh
	int     10h  
	pop	ax
	pop	cx
endm

Initialize_Console	macro
	push	ax
	mov ah, 0				; Set Video mode
    mov al, 01h 
    int 10h 
	fill_color
	hide_text_cursor
	pop	ax
endm

gotoxy	macro	x,y
	push	ax
	push	dx
	; set cursor position at (dl,dh):
	mov     dl, x  ; column.
	mov     dh, y   ; row.
	mov     ah, 02h
	int     10h
	pop		dx
	pop		ax
endm

print	macro	msg
	push	ax
	push	dx
	lea	dx, msg
	mov	ah,09h
	int	21h
	pop	dx
	pop	ax
endm

put_player	macro	play
	local	draw_O,draw_X,fin
	cmp		play,1
	jne		draw_O
	draw_X:
		gotoxy	ah,al
		print	x_UP
		inc		al
		gotoxy	ah,al
		print	x_down
		jmp		fin
	draw_O:
		gotoxy	ah,al
		print	O_UP
		inc		al
		gotoxy	ah,al
		print	O_down
	fin:
endm

Delay Macro a
	local loop11,l1,l2
	push ax
	push bx
	push cx
	push dx
	mov cx,65
	mov ax,a
	mov cx,coefficient
	mul cx
	mov cx,ax
	mov dx,3dah
	loop11:
		push cx
	l1:
		in al,dx
		and al,08h
		jnz l1
    l2:
		in al,dx
		and al,08h
		jz l2
   pop cx
   loop loop11
   pop dx
   pop cx
   pop bx
   pop ax
endm

cr				equ	13																	; CarriageReturn
lf				equ	10																	; LineFeed
max_str_in		equ	6
coefficient		equ 65

stacks		segment		stack
				dw	100	dup(?)
stacks		ends

data		segment
	intro		db		' ------------------------------------  ',cr,lf
				db		'|               WELCOME               |',cr,lf
				db		'|                 T O                 |',cr,lf
				db		'|            TIC  TAC  TOE            |',cr,lf
				db      ' ------------------------------------- ',cr,lf,'$'
	prompt_gm	db		'|                                     |',cr,lf
				db		'|      How Do You Like To Play ?      |',cr,lf
				db		'|                                     |',cr,lf
				db		'|                                     |',cr,lf
				db		'|        >> 1) User Vs User           |',cr,lf
				db		'|                                     |',cr,lf
				db		'|           2) User Vs CPU            |',cr,lf
				db		'|                                     |',cr,lf
				db		'|           3) CPU  Vs CPU            |',cr,lf
				db		'|                                     |',cr,lf
				db		' ------------------------------------- ',cr,lf,'$'
	prompt_gd	db		'|                                     |',cr,lf
				db		'|      Tell CPU About Your Skills     |',cr,lf
				db		'|                                     |',cr,lf
				db		'|                                     |',cr,lf
				db		'|        >> 1) Easy                   |',cr,lf
				db		'|                                     |',cr,lf
				db		'|           2) Normal                 |',cr,lf
				db		'|                                     |',cr,lf
				db		'|           3) Impossible             |',cr,lf
				db		'|                                     |',cr,lf
				db		' -------------------------------------   ',cr,lf,'$'
	sel_player	db		lf,CR,'|                                     |',cr,lf
				db		'|      Do You Like To Play First ?    |',cr,lf
				db		'|                                     |',cr,lf
				db		'|        >> 1) NO                     |',cr,lf
				db		'|                                     |',cr,lf
				db		'|           2) Yes                    |',cr,lf
				db		'|                                     |',cr,lf
				db		' ------------------------------------- ',cr,lf,'$'
	gm			db		0
	gd			db		3
	;------------------------------------------
	str_in		db		max_str_in dup(?),'$'												; temporary variables for input issues.
	;------------------------------------------
	board		db		-1,-2,-3,-4,-5,-6,-7,-8,-9												; related to draw_board function.
	new_line	db		cr,lf,'$'
	X_UP		db		'\/','$'
	X_DOWN		db		'/\','$'
	O_UP		db		'/\','$'
	O_DOWN		db		'\/','$'
	game_board	db		' ------------------------------------- ',cr,lf
				db		'|            |            |           |',cr,lf
				db		'|            |            |           |',cr,lf
				db		'|            |            |           |',cr,lf
				db		'|            |            |           |',cr,lf
				db		'|            |            |           |',cr,lf
				db		'|            |            |           |',cr,lf
				db		'| ---------- + ---------- + --------- |',cr,lf
				db		'|            |            |           |',cr,lf
				db		'|            |            |           |',cr,lf
				db		'|            |            |           |',cr,lf
				db		'|            |            |           |',cr,lf
				db		'|            |            |           |',cr,lf
				db		'|            |            |           |',cr,lf
				db		'| ---------- + ---------- + --------- |',cr,lf
				db		'|            |            |           |',cr,lf
				db		'|            |            |           |',cr,lf
				db		'|            |            |           |',cr,lf
				db		'|            |            |           |',cr,lf
				db		'|            |            |           |',cr,lf
				db		'|            |            |           |',cr,lf
				db		' ------------------------------------- ',cr,lf,'$'
	;------------------------------------------
	player		db		1
	prompt_mov	db		'Choose Your Square',cr,lf,'$'
	choices		db		'[1,9]$'
	player1		db		'(Player X)$'
	player2		db		'(Player O)$'
	
	max_status	dw		2
	status		dw		0
	space_blank	db		'  $'
	symbole		db		'>>$'
	temp		db		CR,LF,6 dup(?),'$'
	;------------------------------------------
	winner_msg	db		'<-- Congratulation -->',cr,lf,'$'
	hasWinner	db		0
	draw_msg 	db 		'<< There is No Winner >>',cr,lf,'$'
	blank_line	db		'                                       ','$'

data		ends

code		segment
	assume	cs:code, ds:data, ss:stacks
	main	proc	near
		mov		ax,seg data
		mov		ds,ax
		Initialize_Console
		print	intro
		call	gm_mod
		cls
		fill_color
		print	game_board
	while_1:
		call	draw_board
		call	check_win
		cmp		hasWinner,1
		jge		quit
		call	get_move
		jmp		while_1
	quit:
		call	get_key	; to pause the program.
		mov	al,0																		; return code 0
		mov	ah,4ch																		; termination code
		int	21h																			; dos system call
	main	endp
	
	check_win	proc	near
		one:
			mov	al,board[0]
			cmp	board[1],al
			jne	two
			cmp	board[2],al
			jne	two
			jmp	won
		two:
			mov	al,board[3]
			cmp	board[4],al
			jne	three
			cmp	board[5],al
			jne	three
			jmp	won
		three:
			mov	al,board[6]
			cmp	board[7],al
			jne	four
			cmp	board[8],al
			jne	four
			jmp	won
		four:
			mov	al,board[0]
			cmp	board[3],al
			jne	five
			cmp	board[6],al
			jne	five
			jmp	won
		five:
			mov	al,board[1]
			cmp	board[4],al
			jne	six
			cmp	board[7],al
			jne	six
			jmp	won
		six:
			mov	al,board[2]
			cmp	board[5],al
			jne	seven
			cmp	board[8],al
			jne	seven
			jmp	won
		seven:
			mov	al,board[0]
			cmp	board[4],al
			jne	eight
			cmp	board[8],al
			jne	eight
			jmp	won
		eight:
			mov	al,board[2]
			cmp	board[4],al
			jne	no_winner
			cmp	board[6],al
			jne	no_winner
		won:
			player_one:
				cmp		al,1
				jne		player_two
				gotoxy	15,22
				print	player1
				jmp		win_msg
			player_two:
				gotoxy	15,22
				print	player2
			win_msg:
				gotoxy	9,23
				print	winner_msg
			mov		hasWinner,1
			jmp exit1
		no_winner:
			mov	cx,9
			mov si,0
			for_Draw:
				cmp	board[si],0
				jl	end_for_Draw
				inc	si
				loop for_Draw
			end_for_Draw:
				cmp si,9
				jne exit1
				mov hasWinner,2
				gotoxy	7,22
				print draw_msg
		exit1:
		ret
	check_win	endp
	
	do_move		proc	near
		push	bp
		mov		bp,sp
		mov		si,[bp+4]
		mov		al,player
		mov		byte ptr[board[si]],al
		pop		bp
		ret 2
	do_move		endp
	
	read_mouse	proc	near
		again:
			mov	ax,3
			int 33h
			test bx,1
			jz	again
			; gotoxy	0,23
			; itoa str_in,cx
			; print	str_in
			; gotoxy	0,24
			; itoa str_in,dx
			; print	str_in
		ret
	read_mouse	endp
	
	get_move	proc	near
		select_player:
		gotoxy	15,22
		cmp		player,1
		jne		player_2
		
		player_1:
			print	player1
			jmp		prompt
		player_2:
			print	player2
		prompt:
			gotoxy	10,23
			print	prompt_mov
			gotoxy	17,24
			print	choices
		cmp		gm,2
		jl		User
		jg		AI
		cmp		player,1
		je		User
		AI:
			call AI_proc
			jmp	 move
		User:
			call Get_Sqr_From_Mouse
		move:
		mov		si,ax
		cmp		si,9																	; checking validity of the following equation : 1 <= player move <= 9
		jg		ileg
		cmp		si,1
		jl		ileg
		dec		si
		cmp		byte ptr[board[si]],0													; if the square was already selected by the other.
		jg		ileg
		jmp		valid_move
		ileg:
			jmp		select_player
		valid_move:
			push	si
			call	do_move
		change_turn:
			cmp		player,1
			je		player2_turn
			mov		player,1
			jmp		return
		player2_turn:
			mov		player,2
		return:
		ret
	get_move	endp
	
	draw_board	proc	near
		mov		si,0
		mov		cx,9
		for_board:
			push	cx
			mov		al,byte ptr[board[si]]
			cmp		al,1
			jl		next
			push	si	; board square - 1
			call	get_square_coordinates
			mov		bl,byte ptr[board[si]]
			put_player bl	; coordinates are in ax
		next:
			inc		si
			pop		cx
			loop	for_board
		gotoxy	0,22
		print	blank_line
		gotoxy	0,23
		print	blank_line
		gotoxy	0,24
		print	blank_line
		hide_text_cursor
		ret
	draw_board	endp
	
	get_square_coordinates proc	near
		push	bp
		mov		bp,sp
		square_0:
			cmp		word ptr[bp+4],0
			jne		square_1
			mov		ah,6
			mov		al,3
			jmp		return_func
		square_1:
			cmp		word ptr[bp+4],1
			jne		square_2
			mov		ah,19
			mov		al,3
			jmp		return_func
		square_2:
			cmp		word ptr[bp+4],2
			jne		square_3
			mov		ah,32
			mov		al,3
			jmp		return_func
		square_3:
			cmp		word ptr[bp+4],3
			jne		square_4
			mov		ah,6
			mov		al,10
			jmp		return_func
		square_4:
			cmp		word ptr[bp+4],4
			jne		square_5
			mov		ah,19
			mov		al,10
			jmp		return_func
		square_5:
			cmp		word ptr[bp+4],5
			jne		square_6
			mov		ah,32
			mov		al,10
			jmp		return_func
		square_6:
			cmp		word ptr[bp+4],6
			jne		square_7
			mov		ah,6
			mov		al,17
			jmp		return_func
		square_7:
			cmp		word ptr[bp+4],7
			jne		square_8
			mov		ah,19
			mov		al,17
			jmp		return_func
		square_8:
			cmp		word ptr[bp+4],8
			jne		return_func
			mov		ah,32
			mov		al,17
	return_func:
		pop		bp
		ret	2
	get_square_coordinates	endp
	
	get_key		proc	near
		mov		ax,00h
		int 	16h
		cbw
		sub	al,30h
		ret
	get_key		endp
	
	get_arrow0 proc 
		while_get0:
			call get_arrow_key
		arrow0:
			cmp ax,28
			jne	UP0
			ENT0:
			mov ax,status
			inc ax
			gotoxy 0,16
			ret
		UP0:
			cmp 	ax,72
			jne		DOWN0
			cmp 	status,0
			jle		while_get0
			cmp		status,1
			jg		up02
		up01:
			dec		status
			gotoxy	9,11
			print	space_blank
			gotoxy	9,9
			print	symbole
			jmp while_get0
		up02:
			dec		status
			gotoxy	9,13
			print	space_blank
			gotoxy	9,11
			print	symbole
			jmp while_get0
		DOWN0:
			cmp ax,80
			je Down01
			jmp while_get0
		Down01:
			mov ax,max_status
			cmp ax,status
			jne	down02
			jmp while_get0
		down02:
			cmp status,1
			je down03
			gotoxy	9,9
			print	space_blank
			gotoxy 	9,11
			print	symbole
			inc status
			jmp while_get0
		down03:
			gotoxy	9,11
			print	space_blank
			gotoxy 	9,13
			print	symbole
			inc status
			jmp while_get0
	get_arrow0 endp
	
	get_arrow1 proc 
		while_get1:
			call get_arrow_key
		arrow1:
			cmp ax,28
			jne	UP1
			ENT1:
			mov ax,status
			inc ax
			gotoxy 0,22
			ret
		UP1:
			cmp 	ax,72
			jne		DOWN1
			cmp 	status,0
			jle		while_get1
			cmp		status,1
			jg		up12
		up11:
			dec		status
			gotoxy	9,18
			print	space_blank
			gotoxy	9,16
			print	symbole
			jmp while_get1
		up12:
			dec		status
			gotoxy	9,20
			print	space_blank
			gotoxy	9,18
			print	symbole
			jmp while_get1
		DOWN1:
			cmp ax,80
			je Down11
			jmp while_get1
		Down11:
			mov ax,max_status
			cmp ax,status
			jne	down12
			jmp while_get1
		down12:
			cmp status,1
			je down13
			gotoxy	9,16
			print	space_blank
			gotoxy 	9,18
			print	symbole
			inc status
			jmp while_get1
		down13:
			gotoxy	9,18
			print	space_blank
			gotoxy 	9,20
			print	symbole
			inc status
			jmp while_get1
	get_arrow1 endp
	
	get_arrow2 proc
		while_get2:
			call get_arrow_key
		arrow2:
			cmp ax,28
			jne	UP2
			ENT2:
			mov ax,status

			gotoxy 0,22
			ret
		UP2:
			cmp status,1
			jne	down2
			dec status
			gotoxy 9,21
			print space_blank
			gotoxy 9,19
			print symbole
			jmp while_get2
		down2:
			cmp status,0
			jne while_get2
			inc status
			gotoxy 9,19
			print space_blank
			gotoxy 9,21
			print symbole
			jmp while_get2
	
	get_arrow2 endp
	
	

	get_arrow_key		proc	near
		mov		ax,00h
		int 	16h
		mov     al,ah
		cbw
		ret
	get_arrow_key		endp
	
	gm_mod		proc	near
		input_gm:
			print	prompt_gm
	get_gm:	call	get_arrow0
			mov		gm,al																; checking input's validity.
			cmp		gm,1
			je		set
			cmp		gm,2
			je		input_gd
			cmp		gm,3
			je		set
		illegal_gm:																		; if input was not valid.
			jmp		get_gm
		input_gd:		; if it was valid, simply exit function.
			print	prompt_gd
	get_gd:	
			mov status,0
			call	get_arrow1
			mov		gd,al			; checking input's validity.
			print	temp
			cmp		gd,1
			je		input_fp
			cmp		gd,2
			je		input_fp
			cmp		gd,3
			je		input_fp
		illegal_gd:
			jmp		get_gd
	input_fp:
			print 	sel_player
	get_fp:	
			mov status,0
			mov max_status,1
			call get_arrow2
			mov ax,status
			mov player,al
			cmp ax,1
			je 	set
			cmp ax,2
			jg	illegal_fp
			mov player,2
			jmp set
		illegal_fp:
			jmp get_fp
	set:
		ret
	gm_mod		endp
	
	
Get_Sqr_From_Mouse proc
	call read_mouse
	mov ax,-1
	cmp dx,167
	jg ret_proc
	cmp cx,303
	jg ret_proc
	cmp cx,104
	jg sqr3
	sqr0:
		cmp dx,56
		jg  sqr1
		mov ax,1
		jmp ret_Proc
	sqr1:
		cmp dx,112
		jg sqr2
		mov ax,4
		jmp ret_Proc
	sqr2:
		mov ax,7
		jmp ret_Proc
	sqr3:
		cmp cx,208
		jg sqr6
		cmp dx,56
		jg sqr4
		mov ax,2
		jmp ret_Proc
	sqr4:
		cmp dx,112
		jg  sqr5
		mov ax,5
		jmp ret_Proc
	sqr5:
		mov ax,8
		jmp ret_Proc
	sqr6:
		cmp dx,56
		jg sqr7
		mov ax,3
		jmp ret_Proc 
	sqr7:
		cmp dx,112
		jg sqr8
		mov ax,6
		jmp ret_Proc
	sqr8:
		mov ax,9
	ret_Proc:
	ret
Get_Sqr_From_Mouse endp

	
	AI_random 	proc	near
		mov		si,0
		mov		cx,9
		mov 	ax,-1
		for_ai:
			cmp	board[si],0
			jl	end_for_ai
			inc	si
			loop for_ai
		end_for_ai:
			mov	ax,si
		endproc:
			ret
	AI_random	endp
	
	AI_Easy		proc	near
		call AI_random
		ret
	AI_Easy		endp
	
	AI_medium	proc	near
		call	winp
		cmp		ax,0
		jg		end_medium
		call 	defence
		cmp		ax,0
		jg		end_medium
		call	AI_random
		end_medium:
			ret
	AI_medium	endp
	
	AI_Hard		proc	near
		call 	Winp
		cmp 	ax,0
		jg		end_hard
		call	defence
		cmp 	ax,0
		jge		end_hard
		call	Choice_Good_chance
		cmp 	ax,0
		jge		end_hard
		cmp		board[4],0
		jg		for_ai
		mov 	ax,4
		jmp		end_hard
		call 	AI_random
		end_hard:
			ret
	AI_Hard 	endp
	
	AI_proc		proc	near
		mov 	ax,-1
		cmp		gd,2
		jl		Easy_mode
		jg		Hard_mode
		DELAY 1
		call	AI_medium
		jmp		end_AI
		Easy_mode:
			call	AI_Easy
			jmp		end_AI
		Hard_mode:
			DELAY 2
			call 	AI_hard
		end_AI:
			inc		ax
		ret
	AI_proc		endp
	
	Winp 		proc	near		
		Win 0,1,2
		Win 1,2,0
		Win 0,2,1
		Win 3,4,5
		Win 4,5,3
		Win 3,5,4
		Win 6,7,8
		Win 7,8,6
		Win 6,8,7
		Win 0,3,6
		Win 0,6,3
		Win 3,6,0
		Win 1,4,7
		Win 1,7,4
		Win 4,7,1
		Win 2,8,5
		Win 5,8,2
		Win 2,5,8
		Win 0,4,8
		Win 0,8,4
		Win 4,8,0
		Win 2,4,6
		Win 2,6,3
		Win 4,6,2
			jmp callQuit
		ret
		callQuit:
			call quit1
	Winp 	endp
	
	
	Defence proc	near
		Def 0,1,2
		Def 1,2,0
		Def 0,2,1
		Def 3,4,5
		Def 4,5,3
		Def 3,5,4
		Def 6,7,8
		Def 7,8,6
		Def 6,8,7
		Def 0,3,6
		Def 0,6,3
		Def 3,6,0
		Def 1,4,7
		Def 1,7,4
		Def 4,7,1
		Def 2,8,5
		Def 5,8,2
		Def 2,5,8
		Def 0,4,8
		Def 0,8,4
		Def 4,8,0
		Def 2,4,6
		Def 2,6,3
		Def 4,6,2
			jmp callQuit3
		ret
		callQuit3:
			call quit1
	Defence endp
	
	quit1 	proc	near
		pop dx
		ret
	quit1 	endp

	Choice_Good_chance  proc	near
		CheakGoodChance 0,4,8
		CheakGoodChance 4,8,0
		CheakGoodChance 0,8,4
		CheakGoodChance 3,4,5
		CheakGoodChance 4,5,3
		CheakGoodChance 3,5,4
		CheakGoodChance 6,7,8
		CheakGoodChance 7,8,6
		CheakGoodChance 6,8,7
		CheakGoodChance 0,3,6
		CheakGoodChance 0,6,3
		CheakGoodChance 3,6,0
		CheakGoodChance 1,4,7
		CheakGoodChance 1,7,4
		CheakGoodChance 4,7,1
		CheakGoodChance 2,8,5
		CheakGoodChance 5,8,2
		CheakGoodChance 2,5,8
		CheakGoodChance 0,1,2	
		CheakGoodChance 0,2,1
		CheakGoodChance 1,2,0
		CheakGoodChance 2,4,6
		CheakGoodChance 2,6,4
		CheakGoodChance 4,6,2
			jmp callQuit2
		ret
		callQuit2:
			call quit1
	Choice_Good_chance 	endp
code		ends
end			main
																		; Main is the program's entrance point.