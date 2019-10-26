;
;	assembly invaders
;	-----------------
;
;	coded by Axel Lindholm a.k.a. ElMaco
;	email: axel.lindholm@swipnet.se
;
;	this game was originally made as an entry in #asm's
;	4k game compo and to honor the memory of the most
;	wonderful girl who ever lived: Anna Lundquist
;
;	sorry, not much comments here, the idea of writing
;	twice as much don't excite me enough...
;
;	game controls:
;	--------------
;		right arrow	-	move your neat spaceship right
;		left arrow	-	move the same neat spaceship left
;		space		-	blast an alien to smithereens
;

	IDEAL
	MODEL TINY
	ASSUME CS:CODE
	P386

KEY_SPACE	equ	32
KEY_ESC		equ	27
KEY_LEFT	equ	75
KEY_RIGHT	equ	77

SIZE_SHIP	equ	16*10
SIZE_BLOCK	equ	40*10
SIZE_ALIEN	equ	16*9
SIZE_SCREEN	equ	320*200

VSCREEN		equ	6000h
VIDEO_SEG	equ	0a000h

ALIEN_ROW	equ	10


SEGMENT CODE
ORG 100h

MACRO clear_vscreen
	push VSCREEN
	pop es
	xor di,di
	mov cx,SIZE_SCREEN
	mov al,1
	rep stosb
ENDM

MACRO draw_vscreen
	push ds VSCREEN VIDEO_SEG
	pop es ds
	xor di,di
	xor si,si

	mov cx,SIZE_SCREEN
	rep movsb

	pop ds
ENDM

MACRO vsync
	mov dx,3dah
@vsync1:
	in al,dx
	test al,8
	jnz @vsync1
@vsync2:
	in al,dx
	test al,8
	jz @vsync2
ENDM

MACRO init_colors
	mov eax,10101000h
	call setcolor

	xor eax,eax
	inc al
	call setcolor

	mov ax,1510h
	call setcolor

	mov ax,3011h
	call setcolor

	mov ax,1506h
	call setcolor

	mov ax,3007h
	call setcolor

	mov eax,15000002h
	call setcolor

	mov eax,30000003h
	call setcolor

	mov eax,00150004h
	call setcolor

	mov eax,00300005h
	call setcolor

	mov eax,00151508h
	call setcolor

	mov eax,00303009h
	call setcolor

	mov eax,1515000ah
	call setcolor

	mov ax,150eh
	call setcolor

	mov eax,3030000bh
	call setcolor

	mov ax,300fh
	call setcolor

	mov eax,1020250ch
	call setcolor

	mov eax,3f3f3f0dh
	call setcolor

	mov eax,00300015h
	call setcolor
ENDM

MACRO create_alien_gfx
	lea si,[alien_map]
	lea di,[alien_gfx]
	push ds
	pop es

	mov cx,4*9
@alien_creation:
	lodsb
	mov ah,al
	shr al,6
	stosb
	mov al,ah
	shl al,2
	shr al,6
	stosb
	mov al,ah
	shl al,4
	shr al,6
	stosb
	mov al,ah
	shl al,6
	shr al,6
	stosb
	loop @alien_creation
ENDM

MACRO create_ship_gfx
	lea si,[ship_map]
	lea di,[ship_gfx]
	push ds
	pop es

	mov cx,4*10
@ship_creation:
	lodsb

	mov ah,al
	shr al,6
	add al,0dh
	cmp al,0dh
	jne @store_b1

	mov al,1

@store_b1:
	stosb

	mov al,ah
	shl al,2
	shr al,6
	add al,0dh
	cmp al,0dh
	jne @store_b2

	mov al,1

@store_b2:
	stosb
	mov al,ah
	shl al,4
	shr al,6
	add al,0dh
	cmp al,0dh
	jne @store_b3

	mov al,1

@store_b3:
	stosb
	mov al,ah
	shl al,6
	shr al,6
	add al,0dh
	cmp al,0dh
	jne @store_b4

	mov al,1

@store_b4:
	stosb
	loop @ship_creation
ENDM

MACRO init_invaders
	mov ax,0201h
	call create_alien
	mov ax,0402h
	call create_alien
	mov ax,0603h
	call create_alien
	mov ax,0804h
	call create_alien
	mov ax,0a05h
	call create_alien

	mov cx,4*SIZE_BLOCK
	mov al,0ch
	push ds
	pop es
	lea di,[blocks]
	rep stosb
ENDM

MACRO init_spaceship
	push ds
	pop es

	mov cx,SIZE_SHIP
	lea si,[ship_gfx]
	lea di,[space_ship]
	rep movsb
ENDM

start:
	mov ax,13h
	int 10h

	create_ship_gfx
	create_alien_gfx

	init_colors
	init_invaders
	init_spaceship

	call activate_aliens

@mainloop:
	clear_vscreen

	call draw_blocks

	call move_aliens
	call draw_aliens
	call alien_fire

	call move_ship
	call draw_ship

	call draw_shots

	call check_borders

	call draw_lifemeter

	vsync
	draw_vscreen

	cmp [BYTE ds:gameover],0
	je @quit_prg

	mov ah,1
	int 16h
	jz @mainloop
	xor ah,ah
	int 16h

	cmp al,KEY_SPACE
	jne @not_space

	cmp [WORD ds:player_shot_y],0
	jne @mainloop

	mov [WORD ds:player_shot_y],200-15
	mov ax,[WORD ds:ship_xpos]
	add ax,12
	mov [WORD ds:player_shot_x],ax

	jmp @mainloop
@not_space:
	cmp ah,KEY_LEFT
	jne @not_left

	mov [BYTE ds:ship_right],0
	mov [BYTE ds:ship_left],10
	jmp @mainloop

@not_left:
	cmp ah,KEY_RIGHT
	jne @not_right

	mov [BYTE ds:ship_left],0
	mov [BYTE ds:ship_right],10
	jmp @mainloop

@not_right:
	cmp al,KEY_ESC
	jne @mainloop

@quit_prg:
	mov ax,3
	int 10h
	ret


PROC draw_blocks
	lea si,[blocks]
	mov di,320*170+35
	push di

	xor ax,ax
	mov cx,4
@blocks_loop:
	pop di
	push di cx ax

	mov cx,70
	mul cx
	add di,ax

	mov cx,10
@blkseg_loop:
	push cx

	mov cx,40
	rep movsb
	add di,280

	pop cx
	loop @blkseg_loop

	pop ax cx
	inc ax
	loop @blocks_loop

	pop di
	ret
ENDP

PROC setcolor
	push eax
	mov dx,3c8h
	out dx,al
	inc dx
	mov al,ah
	out dx,al
	shr eax,16
	out dx,al
	mov al,ah
	out dx,al
	pop eax
	ret
ENDP

PROC draw_lifemeter
	mov di,320*195+315
	push VSCREEN
	pop es

	xor ch,ch
	mov cl,[BYTE ds:gameover]
	mov ax,1515h

@draw_life_loop:
	stosw
	stosb
	add di,317
	stosw
	stosb
	add di,317
	stosw
	stosb
	sub di,320*7+3
	loop @draw_life_loop

	ret
ENDP

PROC alien_fire
	cmp [WORD ds:alien_shot_y],0
	jne @dont_fire

	mov ax,[WORD ds:ship_xpos]
	mov cx,[WORD ds:alien_xpos]

	xor bx,bx

	cmp cx,500
	jb @no_addition

	add cx,[WORD ds:alien_min_x]
	mov bl,[BYTE ds:current_xmin]

@no_addition:
	cmp cx,ax
	ja @dont_fire

	sub ax,cx

	mov cx,20
	xor dx,dx
	div cx

	add ax,bx

	cmp ax,9
	ja @dont_fire

	mov bp,ax
	lea si,[invaders]
	add si,4*10
	add si,bp

	mov bx,5
	mov cx,5
@alfire_loop:
	lodsb
	cmp al,0
	je @alien_cant_fire

	mov ax,bp
	mov dx,20
	mul dx
	add ax,12
	add ax,[WORD ds:alien_xpos]
	mov [WORD ds:alien_shot_x],ax

	mov ax,bx
	mov dx,15
	mul dx
	add ax,[WORD ds:alien_ypos]
	mov [WORD ds:alien_shot_y],ax
	jmp @dont_fire

@alien_cant_fire:
	dec bx
	sub si,11
	loop @alfire_loop

@dont_fire:
	ret
ENDP

PROC move_aliens
	dec [BYTE ds:alien_movep]
	cmp [BYTE ds:alien_movep],0
	ja @et_move_done

	mov al,[BYTE ds:current_level]
	mov [BYTE ds:alien_movep],al

	cmp [BYTE ds:alien_dir],1
	je @right_movement

	mov ax,[WORD ds:alien_xpos]
	add ax,[WORD ds:alien_min_x]
	cmp ax,0
	jne @move_left

	add [WORD ds:alien_ypos],5
	mov [BYTE ds:alien_dir],1

	jmp @move_right

@move_left:
	dec [WORD ds:alien_xpos]
	jmp @et_move_done

@right_movement:
	mov ax,[WORD ds:alien_xpos]

	cmp ax,500
	jb @no_minadd

	add ax,[WORD ds:alien_min_x]

@no_minadd:
	cmp ax,[WORD ds:alien_max_x]
	jb @move_right

	add [WORD ds:alien_ypos],5
	mov [BYTE ds:alien_dir],0
	jmp @move_left

@move_right:
	inc [WORD ds:alien_xpos]

@et_move_done:
	mov ax,[WORD ds:alien_max_y]
	cmp ax,[WORD ds:alien_ypos]
	jne @no_gameover

	mov [BYTE ds:gameover],0

@no_gameover:
	ret
ENDP

PROC draw_shots
	push VSCREEN
	pop es

	cmp [WORD ds:player_shot_y],0
	je @et_shots

	dec [WORD ds:player_shot_y]
	mov ax,[WORD ds:player_shot_y]
	mov cx,320
	mul cx
	add ax,[WORD ds:player_shot_x]
	mov di,ax
	cmp [BYTE es:di],1
	je @pl_nohit1

	call pl_hit_something

	mov [WORD ds:player_shot_x],0
	mov [WORD ds:player_shot_y],0
	jmp @et_shots

@pl_nohit1:
	dec [WORD ds:player_shot_y]
	mov ax,[WORD ds:player_shot_y]
	mov cx,320
	mul cx
	add ax,[WORD ds:player_shot_x]
	mov di,ax
	cmp [BYTE es:di],1
	je @pl_nohit2

	call pl_hit_something

	mov [WORD ds:player_shot_x],0
	mov [WORD ds:player_shot_y],0
	jmp @et_shots

@pl_nohit2:
	mov ax,[WORD ds:player_shot_y]
	mov cx,320
	mul cx
	add ax,[WORD ds:player_shot_x]
	mov di,ax
	mov al,0dh
	stosb

	cmp [WORD ds:player_shot_y],2
	ja @et_shots

	mov [WORD ds:player_shot_x],0
	mov [WORD ds:player_shot_y],0

@et_shots:
	cmp [WORD ds:alien_shot_y],0
	je @done_shooting

	inc [WORD ds:alien_shot_y]
	mov ax,[WORD ds:alien_shot_y]
	mov cx,320
	mul cx
	add ax,[WORD ds:alien_shot_x]
	mov di,ax
	cmp [BYTE es:di],1
	je @et_nohit1

	call et_hit_something

	mov [WORD ds:alien_shot_x],0
	mov [WORD ds:alien_shot_y],0
	jmp @done_shooting

@et_nohit1:
	inc [WORD ds:alien_shot_y]
	mov ax,[WORD ds:alien_shot_y]
	mov cx,320
	mul cx
	add ax,[WORD ds:alien_shot_x]
	mov di,ax
	cmp [BYTE es:di],1
	je @et_nohit2

	call et_hit_something

	mov [WORD ds:alien_shot_x],0
	mov [WORD ds:alien_shot_y],0
	jmp @done_shooting

@et_nohit2:
	mov ax,[WORD ds:alien_shot_y]
	mov cx,320
	mul cx
	add ax,[WORD ds:alien_shot_x]
	mov di,ax
	mov al,0dh
	stosb

	cmp [WORD ds:alien_shot_y],197
	jb @done_shooting

	mov [WORD ds:alien_shot_y],0
	mov [WORD ds:alien_shot_x],0

@done_shooting:
	ret
ENDP

PROC move_ship
	pusha

	cmp [BYTE ds:ship_left],0
	je @no_lmove
	cmp [WORD ds:ship_xpos],0
	je @no_lmove

	dec [WORD ds:ship_xpos]
	dec [BYTE ds:ship_left]
	jmp @move_done

@no_lmove:
	cmp [BYTE ds:ship_right],0
	je @move_done
	cmp [WORD ds:ship_xpos],294
	je @move_done

	inc [WORD ds:ship_xpos]
	dec [BYTE ds:ship_right]

@move_done:
	popa
	ret
ENDP

PROC draw_ship
	pusha

	cmp [BYTE ds:playersuxx],0
	je @draw_spaceship

	lea si,[ship_gfx]
	lea di,[space_ship]
	mov cx,SIZE_SHIP
@ship_hit_loop:
	mov al,[BYTE ds:si]
	cmp al,1
	je @no_color_there

	cmp [BYTE ds:playersuxx],1
	ja @add_color

	sub al,2

@add_color:
	add al,2

	mov [BYTE ds:di],al

@no_color_there:
	inc di
	inc si

	loop @ship_hit_loop

	dec [BYTE ds:playersuxx]

@draw_spaceship:
	push VSCREEN
	pop es

	mov di,320*185+5
	add di,[WORD ds:ship_xpos]
	lea si,[space_ship]

	mov cx,10
@ship_loop:
	push cx

	mov cx,16
	rep movsb
	add di,304

	pop cx
	loop @ship_loop

	popa
	ret
ENDP

PROC draw_alien
	pusha

	mov dl,al
	shr eax,16
	mov di,ax
	add di,320*5+5

	xor dh,dh
	mov ax,SIZE_ALIEN
	dec dx
	mul dx

	lea si,[aliens]
	add si,ax

	mov cx,9
@drawa_loop:
	push cx

	mov cx,16
	rep movsb
	add di,304

	pop cx
	loop @drawa_loop

	popa
	ret
ENDP

PROC draw_aliens
	pusha

	mov ax,[WORD ds:alien_ypos]
	mov cx,320
	mul cx
	add ax,[WORD ds:alien_xpos]
	mov bp,ax

	xor bx,bx
	mov cx,ALIEN_ROW
@et_loop:
	push cx

	mov ax,20
	mul bx
	add ax,bp
	shl eax,16
	xor dx,dx

	mov cx,5
@et_row_loop:
	push cx

	inc dx
	mov ax,dx

	push ax dx

	mov ax,dx
	dec ax
	mov cx,10
	mul cx
	add ax,bx

	lea di,[invaders]
	add di,ax

	pop dx ax

	cmp [BYTE ds:di],0
	je @alien_dead

	push eax
	call draw_alien
	pop eax

@alien_dead:
	shr eax,16
	add ax,15*320
	shl eax,16

	pop cx
	loop @et_row_loop

	inc bx
	pop cx
	loop @et_loop

	popa
	ret
ENDP

PROC create_alien
	pusha

	mov bx,ax
	mov ax,SIZE_ALIEN
	xor cx,cx
	mov cl,bl
	dec cl
	mul cx

	lea di,[aliens]
	add di,ax
	mov al,bh
	dec al

	lea si,[alien_gfx]

	mov cx,SIZE_ALIEN
@alien_loop:

	cmp [BYTE ds:si],0
	je @no_color

	mov ah,[BYTE ds:si]
	add ah,al
	mov [BYTE ds:di],ah
	jmp @continue_loop

@no_color:
	mov [BYTE ds:di],1

@continue_loop:
	inc di
	inc si

	loop @alien_loop

	popa
	ret
ENDP

PROC pl_hit_something
	pusha

	mov ax,[WORD ds:player_shot_y]
	mov cx,320
	mul cx
	add ax,[WORD ds:player_shot_x]
	mov di,ax
	mov al,[BYTE es:di]

	cmp al,0bh
	ja @plhit_block

@alien_wasted:
	mov ax,[WORD ds:player_shot_x]
	mov cx,[WORD ds:alien_xpos]

	sub ax,cx
	xor dx,dx
	mov cx,20
	div cx
	push ax

	mov ax,[WORD ds:player_shot_y]
	mov cx,[WORD ds:alien_ypos]

	sub ax,cx
	xor dx,dx
	mov cx,15
	div cx

	mov cx,10
	mul cx
	pop cx
	add ax,cx

	lea di,[invaders]
	add di,ax
	mov [BYTE ds:di],0

	jmp @plhit_done

@plhit_block:
	mov ax,[WORD ds:player_shot_x]
	mov bp,ax
	sub ax,35
	mov cx,70
	xor dx,dx
	div cx
	push ax
	mov cx,SIZE_BLOCK
	mul cx
	lea di,[blocks]
	add di,ax

	sub bp,35
	pop ax
	mov cx,70
	mul cx
	sub bp,ax
	add di,bp

	mov ax,[WORD ds:player_shot_y]
	sub ax,200-30
	mov cx,40
	mul cx
	add di,ax

	mov [BYTE ds:di],1

@plhit_done:
	popa
	ret
ENDP

PROC et_hit_something
	pusha

	mov ax,[WORD ds:alien_shot_y]
	mov cx,320
	mul cx
	add ax,[WORD ds:alien_shot_x]
	mov di,ax
	mov al,[BYTE es:di]

	cmp al,0dh
	je @ethit_done
	cmp al,0ch
	jne @ethit_player

	mov ax,[WORD ds:alien_shot_x]
	mov bp,ax
	sub ax,35
	mov cx,70
	xor dx,dx
	div cx
	push ax
	mov cx,SIZE_BLOCK
	mul cx
	lea di,[blocks]
	add di,ax

	sub bp,35
	pop ax
	mov cx,70
	mul cx
	sub bp,ax
	add di,bp

	mov ax,[WORD ds:alien_shot_y]
	sub ax,200-30
	mov cx,40
	mul cx
	add di,ax

	mov [BYTE ds:di],1
	jmp @ethit_done

@ethit_player:
	dec [BYTE ds:gameover]
	mov [BYTE ds:playersuxx],30

@ethit_done:
	popa
	ret
ENDP

PROC check_borders
	pusha

	xor ah,ah
	mov al,[BYTE ds:current_xmin]
	lea di,[invaders]
	add di,ax

	mov cx,5
	xor ax,ax
@chk_xmin_loop:
	cmp [BYTE ds:di],0
	je @no_xmin_alien

	inc ax

@no_xmin_alien:
	add di,ALIEN_ROW
	loop @chk_xmin_loop

	cmp ax,0
	ja @check_xmax

	add [WORD ds:alien_min_x],20
	inc [BYTE ds:current_xmin]

@check_xmax:
	xor ah,ah
	mov al,[BYTE ds:current_xmax]
	lea di,[invaders]
	add di,ax

	mov cx,5
	xor ax,ax
@chk_xmax_loop:
	cmp [BYTE ds:di],0
	je @no_xmax_alien

	inc ax

@no_xmax_alien:
	add di,ALIEN_ROW
	loop @chk_xmax_loop

	cmp ax,0
	ja @check_rows

	add [WORD ds:alien_max_x],20
	dec [BYTE ds:current_xmax]

@check_rows:
	mov ax,[WORD ds:current_yline]
	dec ax
	mov cx,ALIEN_ROW
	mul cx
	lea di,[invaders]
	add di,ax

	mov cx,10
	xor ax,ax
@border_loop:
	cmp [BYTE ds:di],0
	je @no_one_there

	inc ax

@no_one_there:
	inc di

	loop @border_loop

	cmp ax,0
	ja @quit_bc

	add [WORD ds:alien_max_y],15
	dec [WORD ds:current_yline]

	cmp [WORD ds:current_yline],0
	jne @quit_bc

	cmp [BYTE ds:current_level],0
	jne @level_change

	mov [BYTE ds:gameover],0
	jmp @quit_bc

@level_change:
	dec [BYTE ds:current_level]
	mov al,[BYTE ds:current_level]
	mov [BYTE ds:alien_movep],al

	call activate_aliens
@quit_bc:
	popa
	ret
ENDP

PROC activate_aliens
	push ds
	pop es

	lea di,[invaders]

	mov cx,5
	xor al,al
@restore_aliens:
	inc al
	push cx

	mov cx,ALIEN_ROW
	rep stosb

	pop cx
	loop @restore_aliens

	mov [WORD ds:alien_max_x],115
	mov [WORD ds:alien_max_y],100
	mov [WORD ds:alien_min_x],0
	mov [WORD ds:current_yline],5
	mov [BYTE ds:current_xmax],9
	mov [BYTE ds:current_xmin],0

	mov [WORD ds:alien_xpos],0
	mov [WORD ds:alien_ypos],0
	mov [BYTE ds:alien_dir],1

	ret
ENDP

gameover:	db 5
playersuxx:	db 0

ship_left:	db 0
ship_right:	db 0
ship_xpos:	dw 0

current_level:	db 5
alien_movep:	db 1

player_shot_y:	dw 0
player_shot_x:	dw 0

alien_shot_y:	dw 0
alien_shot_x:	dw 0

alien_map:	db 00000001b, 01010101b, 01010101b, 01000000b
		db 00000110b, 10101010b, 10101010b, 10010000b
		db 00011010b, 00000010b, 10000000b, 10100100b
		db 01101010b, 10101010b, 10101010b, 10101001b
		db 00011010b, 10101010b, 10101010b, 10100100b
		db 00000001b, 01101001b, 01101001b, 01000000b
		db 00000001b, 10100100b, 00011010b, 01000000b
		db 00000110b, 10010000b, 00000110b, 10010000b
		db 00000101b, 01000000b, 00000001b, 01010000b

ship_map:	db 00000000b, 00000010b, 10000000b, 00000000b
		db 00000000b, 00000110b, 10010000b, 00000000b
		db 00000000b, 00011010b, 10100100b, 00000000b
		db 00000000b, 00011010b, 10100100b, 00000000b
		db 00000000b, 00011010b, 10100100b, 00000000b
		db 00000000b, 00011010b, 10100100b, 00000000b
		db 00000000b, 01101010b, 10101001b, 00000000b
		db 00000001b, 10101010b, 10101010b, 01000000b
		db 00000110b, 10101010b, 10101010b, 10010000b
		db 00000101b, 01010101b, 01010101b, 01010000b

		db 0

alien_max_x:	dw ?
alien_min_x:	dw ?
alien_max_y:	dw ?
current_yline:	dw ?
current_xmin:	db ?
current_xmax:	db ?
alien_xpos:	dw ?
alien_ypos:	dw ?
alien_dir:	db ?

ship_gfx:	db SIZE_SHIP dup(?)
space_ship:	db SIZE_SHIP dup(?)

invaders:	db ALIEN_ROW dup(?)
		db ALIEN_ROW dup(?)
		db ALIEN_ROW dup(?)
		db ALIEN_ROW dup(?)
		db ALIEN_ROW dup(?)

alien_gfx:	db SIZE_ALIEN dup(?)
aliens:		db SIZE_ALIEN dup(?)
		db SIZE_ALIEN dup(?)
		db SIZE_ALIEN dup(?)
		db SIZE_ALIEN dup(?)
		db SIZE_ALIEN dup(?)

blocks:		db SIZE_BLOCK dup(?)
		db SIZE_BLOCK dup(?)
		db SIZE_BLOCK dup(?)
		db SIZE_BLOCK dup(?)
ENDS
END start