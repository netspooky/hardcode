;*******************************************************************
; Hmm, tiny game?
;
; Go:
;
; tasm ridgrace
; tlink /t ridgrace
; ridgrace
;
;*******************************************************************

b	equ	byte ptr
w	equ	word ptr
s	equ	short

cseg	segment	byte

	assume	cs:cseg,ds:cseg,es:nothing,ss:cseg

	org	100h

;*******************************************************************

start:	mov	es,cs:scrnseg	;ES->screen seg

	sub	bx,bx
	mov	cx,2000
	xor	ax,ax
@@cl:	mov w	es:[bx],ax	;Cls
	inc	bx
	inc	bx
	loop	@@cl

;*******************************************************************

@@mor:	mov	bx,carx
	mov	ax,31*256
	mov w	es:[bx],ax
	mov w	es:[bx+2],ax

;*******************************************************************

	mov	cx,4000-160
	mov	si,cx
	mov	di,4000
  	push	ds
   	push	es
    	pop	ds
	std
      	rep	movsb	;Scroll the screen
       	pop	ds

;*******************************************************************

	mov	bx,roadx
	add	bx,166
	mov	ax,(124*256)+34
	push	ds
	push	es
	pop	ds
	mov w	[bx-6],ax	;Render the road
	mov w	[bx-4],ax
	mov w	[bx-2],ax
	mov	cx,22
@@road:	inc	bx
	mov b	[bx],31
	inc	bx
	loop	@@road
	mov w	[bx],ax
	mov w	[bx+2],ax
	mov w	[bx+4],ax
	pop	ds

;*******************************************************************

	mov	bx,carx
	mov b	al,es:[bx]	;Collision detection algorithm
	mov b	ah,es:[bx+2]
	or	ax,ax
	jz s	@@okman

@@splat:	dec	loops	;!!! SPLAT !!!

@@okman:

;*******************************************************************

	mov	ah,2
	int	16h	;CHECK KBD STATUS
	rcr	ax,1
	jnc	@@nlft
	add	carx,2	;car movement maths
@@nlft:	rcr	ax,1
	jnc	@@nrght
	sub	carx,2
@@nrght:

;*******************************************************************

	mov	cx,roadvel
	mov	dx,roadx
	add	dx,cx	;Move road...

	mov	bl,rand1
	add	random,bl	;Random no. generator!
	mov	al,random

	cmp	al,120
	jl s	@@nono
	inc	bl
	mov	rand1,bl
	sub	carx,160

	cmp	dx,20
	jl s	@@rr
	cmp	dx,60
	jg s	@@rr1	;Fractal terrain generator
     	neg	cx
	jmp s	@@oka

@@nono:	cmp	dx,4
	jle s	@@rr	;bounds checking
@@okb:	cmp	dx,92
	jl s	@@oka
@@rr1:	mov	cx,-2
	jmp s	@@oka
@@rr:	mov	cx,2

@@oka:	mov	roadvel,cx
	mov	roadx,dx

;*******************************************************************

	mov	bx,carx
	mov	ax,66*256+35	;Render the car
	mov w	es:[bx],ax
	mov w	es:[bx+2],ax

;*******************************************************************

	mov	dx,3dah
@@w1:	in	al,dx
	test	al,8
	jnz s	@@w1	;Waitvb
@@w2:	in	al,dx
	test	al,8
	jz s	@@w2

;*******************************************************************

	cmp b	loops,0
	jz s	@@dun	;MAIN LOOP
	jmp	@@mor

;*******************************************************************

@@dun:	ret

;*******************************************************************
;DATA Section (ish)

scrnseg	dw	0b800h
roadx	dw	30*2
roadvel	dw	2
carx	dw	(38*2)+(160*23)
loops	db	1
rand1	db	5
random	db	?

cseg	ends

;*******************************************************************

	end start
