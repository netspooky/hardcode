%define mem 0
%define ant_dir mem+0
%define var(x) [bx+x]

org 100h

init:

	mov ax,13h
	int 10h
	push 08000h
	pop es
	
	mov bx, 256
	
	
	
	;mov ax,160
	;mov var(x),ax
	;mov ax,100
	;mov var(y),ax
	mov ax,1
	mov var(ant_dir),ax
	mov si, config

	;init pc speaker
	in al,0x61
	or al,3
	out 0x61,al
	
reset:

	;reset frame counter;
	xor bp,bp
	;setup palette
	mov dx,0x03c8
	mov al,1
	out dx,al
	inc dx
	mov ax,si
	mov cx, 15*3;
ploop:
	out dx,al
	inc ax;
	rol ax,1;
	loop ploop;

	xor ax,ax
	xor di,di
	xor cx,cx
	dec cx
	rep stosb
	mov di,320*100+160
	
	
main:
	
ant_move:
	mov bx, var(ant_dir)
	shl bx,1
	add bx, move_v
	add di,[bx]
	
	;restore bx
	mov bx,256
	
	; get state
	mov cl,[es:di]
	
	inc cl
	
	mov ax,[si+2] ; load state config
	rcr ax,cl ; carry contains left or right
	mov ax,var(ant_dir)
	jc rotate_left
rotate_right:
	inc ax
	jmp rotate_finalize
rotate_left:
	dec ax
rotate_finalize:
	and ax,3
	mov var(ant_dir),ax
	
	mov al,[si] ; state count limit
	cmp cl,al
	jl skip
	xor cl,cl
skip:
	; put state
	mov [es:di],cl
	
	
	
	;vsync
	dec dx
	jnz vsync_skip
	mov dx, 03dah
	mov ah, 0x08
vsync_poll:
	in al,dx
	test al,ah
	jz vsync_poll
	
	;update screen
	push ds
	push es
	push si
	push di
	
	push es
	pop ds
	push 0a000h
	pop es
	xor si,si
	xor di,di
	mov cx,160*200
	rep movsw
	
	pop di
	pop si
	pop es
	pop ds
	
	;sound
	mov dx, 0x42
	mov ax, di
	;xor ax, 0x1735
	out dx, ax
	
	;frame
	; counter
	inc bp;
	cmp bp,0x200;
	jl no_reset
	add si,4
	jmp reset
no_reset:
	
	xor dh,dh; 
	mov dl,[si+1]
	shl dx,4;
vsync_skip:


keyboard_test:
	in al,60h
	dec al
	jnz main
	ret
	
move_v:
	dw +1
	dw -320
	dw -1
	dw +320
	
config:
	db 2
	db 1
	dw 01b
	
; same fast	
	db 2
	db 25
	dw 01b
	
;config3:
	db 9
	db 5
	dw 110000010b
	
;config4:
	db 11
	db 25
	dw 00111000010b
	
;config5:
	db 4
	db 1
	dw 0110b
	
;config6:
	db 4
	db 1
	dw 1100b
	
; 2nd time all again
; same fast	
	db 2
	db 80
	dw 01b
	
;config3:
	db 9
	db 80
	dw 110000010b
	
	
;config5:
	db 4
	db 80
	dw 0110b
	
;config6:
	db 4
	db 80
	dw 1100b
	
; final crawl
; same fast	
; same fast	
	db 2
	db 250
	dw 01b
	
;config4:
	db 11
	db 250
	dw 00111000010b
	
;config5:
	db 4
	db 250
	dw 0110b
	
;config6:
	db 4
	db 250
	dw 1100b