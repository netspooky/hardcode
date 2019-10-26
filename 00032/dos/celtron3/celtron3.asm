;
; 	-*- Celtron3 -*-
; 	by robotron <mp@duch.cz> 2012/10
; 	mile Medunce @>=
;
;	32 B DOS .COM demo
;	showing cellular automaton of chosen rule

%ifndef rule
rule	equ	110
;rule	equ	30
%endif

;	* rule is changeable (7 upper bits) -- try e.g. 30
;
; credits: Bebul^1, Rrrola^2, Mr.Prof^3, numerous CA/life scientists
; 	& especially the amazing Nature for miracles of simplicity
;
; ^1 urged my interest into demoscene by admiring ^2
; ^2 has shown me impossible by his 32b demos (dirojed==hypercool)
; ^3 gave me a tedious coding task (bore|leading to this question of being)
;
; more inspiration:
;   http://mathworld.wolfram.com/Rule110.html
;   http://en.wikipedia.org/wiki/Rule_30
;   http://upload.wikimedia.org/wikipedia/en/7/78/Rake_selection.gif
;
; ****************************************************************************
; ** WARNING: works well in DOSbox, in VirtualBox/XP, the "aaa" instruction **
; ** might need to be replaced by "inc ah" (but 32->33B is unacceptable :-) **
; ****************************************************************************
;
; compiled by NASM:
; 0000  b0 11 cd 10 c5 1f 8c de  37 b2 80 88 c1 d1 e8 b3  |........7.......|
; 0010  37 d2 cb 88 74 b2 d1 da  73 f1 8a 24 4e 75 ea c3  |7...t...s..$Nu..|
;
section .text
org 0x100
	; assume: ah=0 bx=0, "CD 20 FF 9F" @ds:0; thx ^2 for inspiration

width	equ	80		; gfx line width

	mov	al,0x11
	int	0x10
	lds	bx,[bx]		; bx=20CDh ds=9FFFh (by Rrrola)
	mov	si,ds		; VRAM size 0x9fff instead of 0x9600

%ifdef cpu_safe
	inc	ah		; aaa seem to fail somewhere
%else
	aaa			; "inc ah" -- initial seed
%endif
mainloop:
	mov	dl,0x80		; one-hot 8-cycle counter
loop8:
	mov	cl,al		; lower 3 bits = cell neigbourhood
	shr	ax,1
	mov	bl,rule/2	; cellular rule, needs to be /2
	ror	bl,cl		; apply rule (LUT)
	;
	mov	byte [si-(width-2)],dh	; store with 1cycle/bit offset in mind
	;
	rcr	dx,1		; 8-stage one-hot counter (dl) & data (dh)
	jnc	loop8

	mov	byte ah,[si]
	dec	si
	jnz	mainloop
	ret
