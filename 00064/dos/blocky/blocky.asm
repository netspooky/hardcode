;blocky
;64 byte intro
;
;by frag
;http://fsqrt.blogspot.com/
;pzagrebin@gmail.com
;28-07-2012

;Very simple thing, just wanted to do something tiny.
;Enjoy!

org 100h
	mov al, 13h
	int 10h

L:	les ax, [bx]	;ax = 20cdh, ds = 9fffh
	mov fs, ax	;fs = 20cdh
	mov ah, 0cch	;ax = cccdh - magic constant
	mul di		;dl = x, dh = y
	mov ax, fs
	sub dh, [bx]	;y += 51
	div dh		;y' = 20cdh/y
	xchg ax, dx	;dl = y', al = x
	imul dl		;x' = x * y'
	add dx, si	;x' += time
	mov al, ah
	xor al, dl	;color = height = x' ^ y'
	and al, 00011100b
	cbw
	mov dl, al
	mov cl, 40
R:	inc ax		;ax - column y
	imul bp, ax, 320
	add bp, di	;index of current pixel
	jc E		;check if out of screen
	mov [fs:bp+si+16+160], dl
			;fs - buffer, si to prevent shift with time
			;16 due to ds = 9ffh in dosbox, set it to 0 for real dos
			;160 - centering
E:	loop R
	inc di		;next pixel
	jnz L

C:	fs movsb	;copy to framebuffer
	loop C
	inc si		;inc timer
	in al, 60h
	dec ax
	jnz L
	ret
