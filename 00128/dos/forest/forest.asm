;forest
;128 byte intro
;
;by frag
;http://fsqrt.blogspot.com/
;pzagrebin@gmail.com
;06-12-2011


org 100h
	mov al, 13h
	int 10h
c1:	push 0a000h
	pop es
	mov dx, 3c9h		;As the rendering part is well below 128b
PAL:	out dx, al		;i decided to spend some space to do a 
	out dx, al		;white-blue-black palete
	shrd ax, cx, 18		;though grayscale is nice too.
	out dx, al
	mul cl
	mov al, ah
	loop PAL

				;Let's do ray casting!
L:	mov cx, 319		;cx - screen "x", dx - screen "y"
LX:	xor ax, ax		;ax is a ray lenght.
LR:	inc al			;We trace ray from ax = 1 to 256
	jz R
	pusha
	mov bx, sp
	fild word [bx+2]	;Load camera angle from si,
	fiadd word [bx+12]	;add column number,
	fidiv word [R+1]	;degrees->radians by dividing by 199.
	fsincos
	fimul word [bx+14]	;Scale the trace ray.
	fistp word [bx+8]
	fimul word [bx+14]
	fistp word [bx]
	popa			
				;Poles are square columns 16x16 set in 64x64 grid.
	add bl, 24		;We need to place camera between pole rows
	add di, si		;si is the camera angle and position
	mov bp, bx
	xor bp, di
	and bx, di
	or bl, 11001111b	;Check if we reach the pole.
	inc bl
	jnz LR			;Trace until finding pole or ax = 256

R:	mov dx, 199		;Plot the cx-th column of screen picture
				;"mov dl, 200" with ... "dec dx", "jnz R" can save 1 byte
				;by the cost of upper row
LY:	push ax
	push dx
	test ax, ax		;If distance is too far - place white
	jz Z
	sub dx, ax		;Trick to slopeing poles from/to the camera:
				;efective distance to the pole depends on
				;the screen "y" coordinate.
	imul dx, ax
	mov dl, dh		;Find pole texture z-coordinate
	xor dx, bp		;"x" xor "y" xor "z" gives the color
	and dl, 15		;Limit color value
	sub dl, al		;and blend it with distance value.
	xchg ax, dx
Z:	pop dx
	imul di, dx, 320	;place the screen point
	add di, cx
	inc ax			;Sthif color forward
				;due to it's first color is wrong (see palette procedure). 
	stosb
	pop ax
	dec dx
	jns LY
	dec cx			;"loop LY" can save 1 byte by the cost of leftmost column. 
	jns LX
	inc si
	in al, 60h
	dec ax
	jnz L
	ret
				;Enjoy!



