;umi
;128 byte intro
;
;by frag
;http://fsqrt.blogspot.com/
;pzagrebin@gmail.com
;07-12-2011

;Umi is the japanese word for sea.
;Some speedcoding here, only 2 hours for all from scratch.
;Effect is ancient but i can't find it in 128b.
;And again slow in dosbox. In fact the code is fast.
;There is no fpu usage and only two multiplications for each point.
;But damn dosbox is 20 times slower than WinXP even with "CPU Cycles = max". 
;This emulator has left me in despair.


org 100h
	mov al, 13h
	int 10h
	
	push 0a000h
	pop es			;screen area
	push 09000h
	pop gs			;buffer
	push 08000h
	pop ds			;for sin table

SIN:	mov [bx], ch		;sin(x)-like LUT
	add cx, si
	mov ax, 40
	imul cx
	sub si, dx
	inc bx
	jnz SIN

	mov dx, 3c9h		;Blue palette.
PAL:	out dx, al
	out dx, al
	shrd ax, cx, 18
	out dx, al
	shr al, 1
	loop PAL

L0:	mov ch, 2		;512 planes.
LP:	mov bx, 319		;320 columns.
LX:	mov si, bx
	imul bx, cx
	shr bx, 8		;Scale "y" at cx plane
	mov dx, cx
	add dx, bp
	xor dl, bl
	and dl, 31		;Xor texture
	mov al, [bx+si]		;Add si for scaling factor (si+256)/256
	mov bx, cx
	add bx, bp
	add al, [bx+si]		;Height is a sin(x)+sin(y+t)
	cbw
	push ax
	sub ax, cx		;Planes have different screen "y" offset
	sar ax, 2
	add ax, 160
	imul di, ax, 320
	xchg bx, si
	add di, bx
	pop ax
	add al, 128
	add al, dl		;Height + 128 + xor texture is a color
	mov [gs:di], al
	mov [gs:di+320], al	;Plot 2 pixel wide sine curve
	dec bx
	jns LX
	loop LP

COPY:	xor ax, ax
	xchg al,[gs:di]		;Copy and cleaning buffer
	stosb
	loop COPY

	inc bp
	in al, 60h
	dec ax
	jnz L0
	ret
				;Enjoy!


