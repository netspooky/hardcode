;Textours2
;MZ1453/GFB(tm)
;20/11-03

;you might disassemble it....
;..but why not save time...
;the source is here


	.386p
code	segment use16
	org 0100h
	assume  cs:code, ds:code;, es:code, ss:code
d	equ	dword ptr
w	equ	word ptr
b	equ	byte ptr
hx=320
hy=200
n=256


start:	mov	ax,13h
	int	10h

	push	0a000h
	pop	es
	push	09000h
	pop	fs
	push	08000h
	pop	gs



     
igen:
;	mov     dx,3dah
;r1:     in      al,dx          
;        test    al,8
;        jz      r1


;cls	2bytes....
;slower than 32bit, but smaller...!
	xor	di,di
	mov	dx,08c8ch;	mov	cx,hx*hy/2+hx/2
	mov	cx,dx
cls:	mov	ax,fs:[di]
	mov	fs:[di],dx
	mov	gs:[di],dx
	stosw	;mov	es:[di],ax
	loop	cls




	mov	di,offset dc
	mov	si,offset temp

;	finit


	fldz
	fstp	d [si+16]
	mov	bp,n
l2:
	fldz
	fst	d [si]
	fild	w [di+8]
	fadd	st(0),st(0)
	call	cirkel_og_roter
	fstp	d [si+32]		;cz
	fstp	d [si+24]		;cx
	fstp	d [si+28]		;cy
fup:	mov	cx,n
l1:
	fld	d [si]
	fadd	d [di]
	fst	d [si]
	fsincos		;x y z
	fimul	w [di+8]
	fxch	st(1)
	fimul	w [di+8]
	call	cirkel_og_roter

	fist	w [si+36]	;z lokal
	fadd	d [si+32]
	fistp	w [si+37]	;z+cz	fræk adressering!!

	fadd	d [si+24]
	fistp	w [si+4]		;x+cx
	fadd	d [si+28]
	fistp	w [si+8]		;y+cy

	mov	bx,w [si+8]
	imul	bx,hx
	add	bx,w [si+4]
	add	bx,hx/2+hy/2*hx
	mov	ax,w [si+36]	;uhh.. den sved!!
				;ah og al på een gang
	mov	dx,bp
	or	dl,cl
	and	al,dl
	sar	al,1
	add	al,128




	mov	dh,2
pl2:	mov	dl,2
pl1:	cmp	ah,gs:[bx]
	jle	zb0
	mov	gs:[bx],ah
	mov	fs:[bx],al
zb0:	inc	bx
	dec	dl
	jnz	pl1
	add	bx,hx-2
	dec	dh
	jnz	pl2
	
	loop	l1

	fld	d [si+16]
	fadd	d [di]
	fstp	d [si+16]

	dec	bp
	jnz	l2

	fld	d [si+20]
	fadd	d [di+4]
	fstp	d [si+20]




        mov     ah,01H                              ;get keyboard buffer status
        int     16H
	jz      igen
;	ret

cirkel_og_roter:
	fldz
	fld	d [si+16]

	mov	al,2
lll:	call	roter
	fxch	st(2)		;y x z
	fld	d [si+20]
	dec	al
	jnz	lll

;	call	roter
roter:
	fsincos			;c s x y z
	fld	st(2)		;x c s x y z
	fmul	st(0),st(1)	;xc c s x y z
	fld	st(4)		;y xc c s x y z
	fmul	st(0),st(3)	;ys xc.. 
	fsubp	st(1)		;ys-xc c s..
	fxch	st(4)		;y c s x ys-xc z
	fmulp	st(1)		;yc s x ys..
	fxch	st(2)		;x s yc ys..
	fmulp	st(1)		;xs yc ys..
	faddp	st(1)		;xs+ys ys-xc z
	ret


dc	dd	0.025	;intern
vy0d	dd	0.05	;global
m	dw	24
;c	dd	?
;vy0	dd	?
temp	equ	640

code	ends      
       	end start


