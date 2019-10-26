; Unfinished entry, the main idea was to draw another plane and draw a fake shadow of the sphere, but have not time at all.
; It features: wait for the ESC key and it also restores the video mode!! its wonderful!! and with only 219 bytes!! WOW!! :P
; 
; really, this suxxxx. made just for fun. the source code sux too (if you could understand something let me know :D)
;
;
; support spanish demoscene.
;
; compile: nasm16 attrib.asm -o attrib.com
;
; bp / fuzzion
;
; http://www.fuzzion.org

%define		BACKGROUND	0
%define		MOSAIC		32
%define		SPHERE		38

section	.text
	org	0x100

start:
	mov	al,0x13
	int	0x10

	push	word 0x0a000
	pop	es

	mov	bx,data
	mov	si,tempf
	xor	di,di
	fild	word [bx+2]			;y
	mov	dx,200
.yRT	
	fld	dword [bx+12]			;.23	y
	fmul	st0,st1				;.23y	y
	fiadd	word [bx+22]			;.23y+k	y
						;v3	y
	
	fld	dword [bx+16]			;.94	v3	y
	fmul	st0,st2				;.94y	v3	y
	fisub	word [bx+20]			;.94y-c	v3	y
						;v2	v3	y
	
	fild	word [bx+4]			;x	v2	v3	y
	fmul	dword [bx+8]
	mov	cx,320
.xRT						;x	v2	v3	y
	mov	al,BACKGROUND

	fld	st1				;v2	x	v2	v3	y
	fimul	word [bx+6]			;-60v2	x	v2	v3	y	
	fld	st3				;v3	-60v2	x	v2	v3	y	
	fimul	word [bx]			;400v3	-60v2	x	v2	v3	y
	fsubrp	st1,st0				;b	x	v2	v3	y
	fadd	st0,st0
	
	fmul	st0,st0				;b^2	x	v2	v3	y
	fld	st1				;x	b^2	x	v2	v3	y
	fmul	st0,st0				;v1^2	b^2	x	v2	v3	y	
	fld	st3				;v2	v1^2	b^2	x	v2	v3	y
	fmul	st0,st0				;v2^2	v1^2	b^2	x	v2	v3	y
	faddp	st1,st0				;v1+v2	b^2	x	v2	v3	y		;v1+v2 == v1^2+v2^2	
	fld	st4				;v3	v1+v2	b^2	x	v2	v3	y
	fmul	st0,st0				;v3^2	v1+v2	b^2	x	v2	v3	y
	faddp	st1,st0				;a	b^2	x	v2	v3	y	
	fimul	word [bx]			;ac	b^2	x	v2	v3	y
	fimul	word [bx]			;ac	b^2	x	v2	v3	y
	fadd	st0,st0				;2ac	b^2	x	v2	v3	y
	fadd	st0,st0				;4ac	b^2	x	v2	v3	y
	fsubp	st1,st0				;disc	x	v2	v3	y
	fistp	dword [si]			;x	v2	v3	y	
	and	byte [si+3],0x80
	jnz	.nosphere
	
	mov	al,SPHERE
	jmp	.okCol
.nosphere	
	fxch	st1				;v2	x	v3	y
	fist	word [si]		
	fxch	st1				;x	v2	v3	y
	and	byte [si+1],0x80
	jz	.okCol
	mov	al,MOSAIC
	
	fld	st0				;v1	x	v2	v3	y
	fdiv	st0,st2				;v1/v2	x	v2	v3	y		;X*100/100
	frndint					;X	x	v2	v3	y	
	fld	st3				;v3	X	x	v2	v3	y
	fdiv	st0,st3				;v3/v2	X	x	v2	v3	y
	fimul	word [bx]			;Z	X	x	v2	v3	y	
	fidiv	word [bx+2]			;Z/-100	X	x	v2	v3	y
	fchs					;Z/100	X	x	v2	v3	y	
	faddp	st1,st0				;Z+X	x	v2	v3	y
	fistp	word [si]			;x	v2	v3	y
	and	byte [si],1	
	jz	.okCol
	dec	al
.okCol
	stosb	
	
	fadd	dword [bx+8]			;x+0.97	v2	v3	y		
	loop	.xRT
	
	fcompp					;v3	y
	fstp	st0				;y
	
	fld1					;1.0	y
	faddp	st1,st0				;y+1.0
	dec	dx
	jnz	near .yRT
	
	;fstp	st0				;blaeh
	
main:
	mov	cl,28				;ch should be 0 here but who knows with the evil windows :P
pocafeina:
	mov	dx,msg
	mov	ah,9
	int	0x21
	loop	pocafeina

testforKey:
	xor	ax,ax	
	in	al,0x60
	dec	ax
	jnz	testforKey
	
	mov	al,3
	int	0x10
	ret
	
	data:
		dw	400,-100,-160,-60
		dd	0.9701,-0.2352,-0.9412
		dw	54,-215
	
	msg	db	'bp sux $'	
section	.bss
	tempf	resd	1		