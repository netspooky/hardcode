;t
;32 byte intro
;
;by frag
;http://fsqrt.blogspot.com/
;pzagrebin@gmail.com
;05-07-2012

;Dynamic T-square fractal in 32b
;For this fractal we coverthe plane
;with squares 2^n x 2^n
;and count for each pixel how many times
;it under the border or middle part of these squares.
;In terms of binary code we need to
;take x and y, find the pairs of sequental equal (or non-equal) bit pairs
;at each position, AND it for x and y and count the number or 1's.
;Enjoy!

org 100h
	mov al, 13h
	int 10h
L:	les ax, [bx]
	mov ah, 0cch	;ax = cccd
	mul di		;y->dh, x->dl
	imul ax, dx, 2	;al = dl << 1
	xor dx, ax	;each '1' is the sequental non-equal bit pair
T:	mov al, 17	;darkest color and code reuse for the timer
	and dh, dl	;each '1' is the s. non-e. bit pair
			;for the both x and y -> middle of square
	add dx, [si+bx]	;[si+bx] - timer
R:	adc al, 0	;simple bit counter
	shr dh, 1
	jnz R
	stosb
	loop L
	jmp T+1		;[cs:T+1] = adc [si+bx], sp	;sp = FFFE, reduce timer by 2.
			;[cs:T+3] = salc

