;oil
;32 byte intro
;
;by frag
;pzagrebin@gmail.com
;http://fsqrt.blogspot.com/
;30-09-2011

org 100h
	mov al, 13h
	int 10h
	lds bx, [bx]
	std			;flow direction is down
L:	imul bx, byte 177	;pseudorandom number generator
	lodsb
	test al, al		;if no color - do nothing
	jz A
	add bx, ax		;for better randomiszation
	push bx
	and bx, word 3		
	mov [si+bx+319], al	;left_or_right flow direction
	pop bx
A:	loop L
	mov [bx], bh		;put a new rnd point after 2^32 point
	jmp L
