;wash
;64 byte intro
;
;by frag
;http://fsqrt.blogspot.com/
;pzagrebin@gmail.com
;11-11-2011

org 100h
	mov al, 13h
	int 10h
	push 0a000h
	pop ds
	mov di, 320
	mov bp, si		;bp is the radius of rotation ellipse

L:	mov ax, si
	xor dx, dx
	div di			;x -> dx, y -> al, ah = 0
	sub al, bl		;Let's make displacement of origin.		
	sub dx, bp		;Origin coordinates are (bp, bx).
	xor al, dl
	and al, 10010000b	;As main figure i used 128x128 squares 
				;made from 16x16 squares.
				;Is a point (dx, al) in it?
	lodsb
	jnz A			;If no - decrement color.
	mov al, 32		;If yes - set a white (31) dot.
A:	dec al
	cmp al, 16		;If point color is black (<=16) do nothing
	jl I
	mov [si-1], al		;There is too little place for changing palette,
				;but i want a grayscale, therefore i used 
				;colors from standart palette in range 16-31.
I:	loop L
	push bx			;This is simple rotating algorithm,
	sar bx, 5		;it moves point (bp, bx) along the ellipse
				;with center in (0, 0) and size 
				;determined by the initial point (256, 0).
	sub bp, bx		;x_new = x_old - y_old / 32
	pop bx		
	push bp
	sar bp, 5
	add bx, bp		;y_new = y_old + x_new / 32
	pop bp
	in al, 60h
	dec ax			;ah = 0
	jnz L			;Enjoy!
	ret
		

