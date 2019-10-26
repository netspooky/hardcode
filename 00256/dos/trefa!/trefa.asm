       .586
code   SEGMENT use16
       ASSUME  cs:code,ds:code,es:code
       ORG     100h
start:
	mov   al,13h
   int   10h

	; allocate memory
	mov	ax,cs
	add	ah,10h
   mov	gs,ax

   push	0a000h
	pop	es

;----------------------------------------------------------------
@begin:
	mov	dx,314*2
@1:
	mov	cx,314*2
@2:
   lea	si,data
	fninit
   fld1						;1
	fadd	st,st				;2
	mov	f,cx
	fild	f					;(q+pi)*100 2
	fidiv	f100				;q+pi 2
	mov	f,dx
	fild	f					;(p+pi)*100 q+pi 2
	fidiv	f100				;p+pi q+pi 2
	fsub	st,st[2]			;p q+pi 2
	
	;	x = (sin(p) + 2*sin(2*p))/((2 + cos(q+2))/2);

	fld	st		         ;p p q 2
	fadd	st,st				;2*p p q 2
	fld	st[2]				;q 2*p p q 2
	fadd	st,st[4]       ;q+2 2*p p q 2
	fcos                 ;cos(q+2) 2*p p q 2
	fadd	st,st[4]       ;2+cos(q+2) 2*p p q 2
	fdiv	st,st[4]			;(2+cos(q+2))/2 2*p p q 2
	fld	st[1]				;2*p (2+cos(q+2))/2 2*p p q 2
	fsin                 ;sin(2*p) (2+cos(q+2))/2 2*p p q 2
	fadd	st,st			   ;2*sin(2*p) (2+cos(q+2))/2 2*p p q 2
	fld	st[3]          ;p 2*sin(2*p) (2+cos(q+2))/2 2*p p q 2
	fsin						;sin(p) 2*sin(2*p) (2+cos(q+2))/2 2*p p q 2
	faddp	st[1],st   		;sin(p)+2*sin(2*p) (2+cos(q+2))/2 2*p p q 2
	fdiv	st,st[1]			;(sin(p)+2*sin(2*p))/((2+cos(q+2))/2) (2+cos(q+2))/2 2*p p q 2
								;x (2+cos(q+2))/2 2*p p q 2

	;	y = (cos(p) - 2*cos(2*p))*((2 + cos(q+2))/2)*((2 + cos(q))/2);

	fld	st[4]				;q x (2+cos(q+2))/2 2*p p q 2
	fcos						;cos(q) x (2+cos(q+2))/2 2*p p q 2
	fadd	st,st[6]			;2+cos(q) x (2+cos(q+2))/2 2*p p q 2
	fdiv	st,st[6]			;(2+cos(q))/2 x (2+cos(q+2))/2 2*p p q 2
	fld	st[4]				;p (2+cos(q))/2 x (2+cos(q+2))/2 2*p p q 2
	fcos						;cos(p) (2+cos(q))/2 x (2+cos(q+2))/2 2*p p q 2
	fxch	st[4]				;2*p (2+cos(q))/2 x (2+cos(q+2))/2 cos(p) p q 2
	fcos						;cos(2*p) (2+cos(q))/2 x (2+cos(q+2))/2 cos(p) p q 2
	fadd	st,st				;2*cos(2*p) (2+cos(q))/2 x (2+cos(q+2))/2 cos(p) p q 2
	fsubp	st[4],st			;(2+cos(q))/2 x (2+cos(q+2))/2 cos(p)-2*cos(2*p) p q 2
	fxch	st[3]				;cos(p)-2*cos(2*p) x (2+cos(q+2))/2 (2+cos(q))/2 p q 2
	fmulp	st[2],st 		;x (cos(p)-2*cos(2*p))*((2+cos(q+2))/2) (2+cos(q))/2 p q 2
	fxch	st[1]				;(cos(p)-2*cos(2*p))*((2+cos(q+2))/2) x (2+cos(q))/2 p q 2	
	fmul	st,st[2]			;(cos(p)-2*cos(2*p))*((2+cos(q+2))/2)*((2+cos(q))/2) x (2+cos(q))/2 p q 2
								;y x (2+cos(q))/2 p q 2
	fimul	scale				;y*scale x (2+cos(q))/2 p q 2
	fistp	y					;x (2+cos(q))/2 p q 2
	fxch	st[2]          ;p (2+cos(q))/2 x q 2

	;	z = sin(3*p)/((2 + cos(q))/2);

	fldpi                ;3.14 p (2+cos(q))/2 x q 2
	fmulp	st[1],st			;3*p (2+cos(q))/2 x q 2
	fsin                 ;sin(3*p) (2+cos(q))/2 x q 2
	fxch	st[1]				;(2+cos(q))/2 sin(3*p) x q 2
	fdivp st[1],st    	;sin(3*p)/((2+cos(q))/2) x q 2
						    	;z x q 2
	push	40h
	pop	fs
	fild	word ptr fs:[6ch]	;t z x q 2
	fldpi						;pi t z x q 2
	fdiv	st[1],st       ;pi t/pi z x q 2
	fdiv	st[1],st       ;pi t/pi z x q 2
	fdivp	st[1],st       ;t z x q 2

	fsincos					;sin cos z x q 2
	fld	st[3]				;x sin cos z x q 2
	fmul	st,st[2]			;x*cos sin cos z x q 2
	fld	st[3]				;z x*cos sin cos z x q 2
	fmul	st,st[2]			;z*sin x*cos sin cos z x q 2
	fsubp	st[1],st			;x*cos-z*sin sin cos z x q 2
	fxch	st[1]				;sin x*cos-z*sin cos z x q 2
	fmulp	st[4],st			;x*cos-z*sin cos z x*sin q 2
	fxch	st[1]				;cos x*cos-z*sin z x*sin q 2
	fmulp	st[2],st			;x*cos-z*sin z*cos x*sin q 2
	fxch	st[2]				;x*sin z*cos x*cos-z*sin q 2
	faddp	st[1],st			;x*sin+z*cos x*cos-z*sin q 2

	fimul	scale				;scale*z x q 2
	fistp	z					;x q 2
	fimul	scale				;x*scale q 2
	fistp x					;q 2

	mov	ax,y
	mov	bx,ax
	sal	bx,8
	sal	ax,6
	add	bx,ax
	add	bx,x
	add	bx,160+100*320
	mov	ax,z
	add	al,160
	mov	ah,gs:[bx]
	cmp	ah,al
	jae	skip
	mov	gs:[bx],al
skip:

	sub	cx,4
	jnz	@2

	dec	dx
	jnz	@1

@draw:
	mov	al,gs:[di]
	inc	al
	js		@not
   mov	al,ch
   xor	al,cl
@not:
	shr	al,2
	mov	gs:[di],dl
	stosb
	loop	@draw

	in 	al,60h
  	cbw
  	dec 	ax
	jnz 	@begin

   ret
;-------------------------------------------
f100		equ	word ptr [si+0]
scale		equ 	word ptr [si+2]
y			equ 	word ptr [si+4]
x			equ 	word ptr [si+6]
z			equ 	word ptr [si+8]
f			equ 	word ptr [si+10]
;-------------------------------------------
data:
_f100		dw	100	;+0
_scale	dw	13    ;+2
_y			dw	?     ;+4
_x			dw	?     ;+6
_z			dw	?     ;+8
_f			dw ?     ;+10
;-------------------------------------------
code   ENDS
       END start

