;tuk-tuk
;32 byte intro
;
;by frag
;http://fsqrt.blogspot.com/
;pzagrebin@gmail.com
;08-06-2012

;Watched farmed 32b tonight and...
;made this for reinstatement of 32b intros.

org 100h
	mov al, 13h
	int 10h
	les bp, [bx]
	
L:	mov ax, 0ccbfh	;rrrola's "mul instead of div" trick,
					;constant tuned to avoid overlap
					;as [bx+2] is not exactly 0a000h
	mul di			;y->dh, x->dl
	mov al, bl
S:	neg al			;al(bx) = /\/\/\/
	jl S
	mul dl
	mul dx
	mov al, dh
	and al, bh
	stosb
	loop L
	dec bx
	jmp L
	