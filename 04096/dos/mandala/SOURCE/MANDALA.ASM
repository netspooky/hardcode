; mandala source (c) 1996/97 by G bor Papp [rod/mandula]
; contact me at s5001@sun10.vsz.bme.hu or rod@inf.bme.hu
; visit us at www.inf.bme.hu/~mandula
;
; this header must stay at the top of this file.
;
; this material is not freeware. you are allowed to copy it without
; restrictions for non-commercial use. no payment of any kind may be charged
; for this product or any combination of products or services including this
; product without the author's authorization and official written license.
; commercial use is strictly prohibited.
;
; you may only look at the source, you may not use it.
; you must not use this code or derivatives in your productions.
; you may use the algorithms in non commercial productions if you credit me.

.386

;úúúúúúúúúúúúúúúúúúúúú[macro magic by hyp-x/mandula]úúúúúúúúúúúúúúúúúúúúú

open_seg=0

nowarn	res
.close	macro
	ife	open_seg-1
		%intcls
		purge	%intcls
	endif
open_seg=0
	endm

.code	macro	segname
	.close
	ifb	<segname>
		_text	segment para public use16 'code'
			assume	cs:_text
		%intcls	macro
		_text	ends
			endm
		open_seg=1
	else
		segname	segment para public use16 'code'
			assume	cs:&segname
		%intcls	macro
		segname	ends
			endm
		open_seg=1
	endif
	endm

.data	macro
	.close
_data	segment para public use16 'data'
%intcls	macro
_data	ends
	endm
open_seg=1
	endm

.data?	macro
	.close
_bss	segment para public use16 'bss'
%intcls	macro
_bss	ends
	endm
open_seg=1
	endm

.stack	macro size
	.close
	ifdef	mod_tiny
		display "**error** tiny programs shouldn't have a stack."
		err
	else
	nowarn  res

stack	segment para stack use16 'stack'
	warn	res
	ifb <size>
	db	1024 dup(?)
	else
	db	size dup(?)
	endif
stack	ends
	endif
	endm

.fardata? macro	segname
	.close
	ifb	<segname>
		display	"**error** far segment must have a name."
		err
	else
		segname	segment para public use16 'far_bss'
		%intcls	macro
		segname	ends
			endm
		open_seg=1
	endif
	endm

end	macro startlabel
	.close
	purge	end
	end startlabel
	endm

%groupdef macro
	ifdef	mod_nearstack
		.data
		.data?
		.stack	0
		group	dgroup	_data,_bss,stack
		assume	ds:dgroup
		@data	equ	dgroup
		.close
	else
		.data
		.data?
		group	dgroup	_data,_bss
		assume	ds:dgroup
		@data	equ	dgroup
		.close
	endif
	endm
.model	macro model_def,stack_mod
	ifidni	<stack_mod>,<nearstack>
		mod_nearstack	equ	1
	endif

	ifidni	<model_def>,<tiny>
		mod_tiny	equ	1
		.code
		.data
		.data?
		group	com_group	text,data,bss
		.close
	else
	ifidni 	<model_def>,<small>
		mod_small	equ	1
		%groupdef
	else
		display	"**error** the model is not valid or not implemented."
		err
	endif
	endif
	endm

.name	macro	modulname
	ifb	<modulname>
		display "**error** modul definition must have a name."
		err
	else
		_text	equ <modulname>
	endif
	endm

warn	res
;úúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúú

.model small
.stack 256
jumps
locals
dosseg

nowarn res
;úúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúú
load		macro	para1,para2
		push 	para2
		pop  	para1
endm
;úúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúú
movfdd		macro	mem,data
		mov	mem,012345678h
org	$-4
dd	data
endm

;úúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúú
setalc		macro

		db	0d6h

endm

;úúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúú

;ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ
				.fardata? @virtscr
;ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ

		db      64000 dup (?)


;ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ
				.fardata? @mazeseg
;ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ

		db      65535 dup (?)

;ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ
				.fardata? @clouds
;ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ

		db	64000 dup (?)

;ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ
				.fardata? @mandala
;ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ

		db	65535 dup(?)

;ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ
				.fardata? @distabseg
;ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ

distable	db	64000 dup(?)

;ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ
				.fardata? @circtabseg
;ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ

circtable	db	64000 dup(?)

;ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ
				.fardata? @degtabseg
;ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ

degtable	db	64000 dup (?)

;ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ
				.fardata? @multabseg
;ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ

multable	db	65535 dup(?)

;ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ
				.data?
;ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ

sintable        dw      64  dup(?)
costable        dw      256 dup(?)

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

palette         db      768 dup(?)

fadeinval	dw	?
fadeoutval	dw	?
mandinit	dw	?

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

dist            dw      200 dup(?)
angle           dw      ?
xpos            db      ?
ypos            db      ?

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

xc              dw      ?
yc              dw      ?
radius          dw      ?
color           db      ?

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

liney           dw      ?
linexstart      dw      ?
linexend        dw      ?

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
skyxstart       dw      ?

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

timer           dd      ?

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

deg		dw	?

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

x0		dq	?
x		dq	?
y		dq	?
addx		dq	?
addy		dq	?
bailout		dq	?

r		dq	?
phi		dq	?
status		dw	?

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

		dd	?
fire		db      32*16 dup (?)
		dd	?

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

balldata1	dw	32*32 dup (?)
balldata2	dw	32*32 dup (?)
balldata3	dw	32*32 dup (?)
balldata4	dw	32*32 dup (?)
balldata5	dw	32*32 dup (?)
balldata6	dw	32*32 dup (?)
balldata7	dw	32*32 dup (?)

balloffsets	dw	7     dup (?)

sqr		dw	?
ddtemp		dd	?
dwtemp		dw	?

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

alpha		dw	?
beta            dw      ?
gamma           dw      ?

sinalpha	dw	?

r11		dw	?
r12		dw      ?
r13		dw      ?
r21		dw	?
r22		dw      ?
r23		dw      ?
r31		dw	?
r32		dw      ?
r33		dw      ?

add11		dw	?
add12		dw	?

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

np=19
addxball=160
addyball=100
addzball=600

db	?
dw	?

object          dw	np-2 dup(?,?,?)


currentobject	dw	np dup(?,?,?)

		align	4

zlist		dw	np dup(?,?)

ballx		dw	?
bally		dw	?

fireinit	dw	?

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

sz255		dd	?
stripeinit	dw	?
morph		dw	?

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

fpu_cw		dw	?

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

t_fadeleft	=	 128
t_left   	=	 450
t_right		=	 850
t_faderight	=	 978

t_mandalain	=	1106
t_mandala	=       1600
t_mandalaout	=	1728

t_stripein	=	1856
t_stripe	=       2300
t_stripeout	=	2428

t_firein	=	2556
t_fireballs	=	3600
t_fireout	=	3728

;ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ
				.code
				.386
				.387
;ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ

main            proc    near

		pop	ax

		fninit

		mov	cx,2
		loop	$

		fnstcw	fpu_cw
		cmp	byte ptr [fpu_cw+1],3
		jne	@@out


		in	al,21h
		or	al,6
		out	21h,al

		call    genmaze

		load    es,0
		cli
		mov     eax,es:[4*8]
		mov     cs:oldint8,eax
		lea     bx,cs:newint8
		mov     es:[4*8],bx
		mov     es:[4*8+2],cs

		mov     al,36h
		out     43h,al
		mov     ax,428bh
		out     40h,al
		mov     al,ah
		out     40h,al

		sti


		load    ds,@data
		call    gensintable
		call	initwave
		call	mandala


		load	es,ds
		lea	di,fire-4
		mov	cx,32*16/2+4
		xor	ax,ax
		rep	stosw

		mov	radius,14
		mov	cx,7
		lea	di,balldata1
		xor	bx,bx
@@transfcalc:   mov	balloffsets[bx],di
		push	cx bx
		call	balltransform
		pop	bx cx
		add	bx,2
		dec	radius
		loop	@@transfcalc


		push	ds
		load	es,ds
		load	ds,cs
		lea	si,cubes
		lea	di,object
		mov	cx,np*3*2
		rep	movsb
		pop	ds


		mov     ax,13h
		int     10h
		call    genlogo
		call    genclouds

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

		xor	eax,eax

		mov	dword ptr alpha,eax
		mov	gamma,ax

		mov     skyxstart,ax
		mov     angle,ax
		mov     word ptr xpos,ax

		mov	timer,eax
		mov	fadeinval,ax
		mov	mandinit,ax
		mov	stripeinit,ax
		mov	deg,ax
		mov	fireinit,ax

@@timingeffects:mov     eax,timer

		cmp	eax,t_fadeleft
		jb	@@fadeleft

		cmp	eax,t_left
		jb	@@toleft

		cmp	eax,t_right
		jb	@@toright

		cmp	eax,t_faderight
		jb	@@faderight

		cmp	mandinit,0
		je	@@mandinit

		cmp	eax,t_mandalain
		jb	@@mandalain

		cmp	eax,t_mandala
		jb	@@mandala

		cmp	eax,t_mandalaout
		jb	@@mandalaout

		cmp	stripeinit,0
		je	@@stripeinit

		cmp	eax,t_stripein
		jb	@@stripein

		cmp	eax,t_stripe
		jb	@@stripe

		cmp	eax,t_stripeout
		jb	@@stripeout

		cmp	fireinit,0
		je	@@fireinit

		cmp	eax,t_firein
		jb	@@firein

		mov	word ptr cs:fireroot,0bfbfh

		cmp	eax,t_fireballs
		jb	@@fireballs

		mov	word ptr cs:fireroot,0h

		cmp	eax,t_fireout
		jb	@@fireout

		jmp	@@todos


@@fadeleft:
		mov	bp,fadeinval
		call	fade

@@toleft:
		load    es,@virtscr
		call    sky
		call    drawmaze
		call    drawvirt

		inc     skyxstart
		inc     byte ptr angle
		add     xpos,2
		add     ypos,2


		jmp	@@endeffect

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

@@faderight:
		mov	bp,fadeoutval
		call	fade

@@toright:	cmp	timer,t_right
		ja	@@nomax
		mov	fadeoutval,128
@@nomax:
		load    es,@virtscr
		call    sky
		call    drawmaze
		call    drawvirt


		dec     skyxstart
		dec     byte ptr angle
		sub     xpos,2
		add     ypos,4

		mov	fadeinval,0

		jmp	@@endeffect

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

@@stripeinit:   lea	si,cs:stripepal
		call	fillpalette

		push	es
		call	stripes

		load	es,0a000h
		mov	cx,32000
		xor	ax,ax
		xor	di,di
		rep	stosw
		pop	es

		mov	dword ptr cs:shadepatch1,0100878ah
		mov	dword ptr cs:shadepatch2,0100a78ah

		mov	stripeinit,1
		mov	fadeinval,0

@@stripein:
		mov	bp,fadeinval
		call	fade
		jmp	@@stripe

@@stripeout:
		mov	bp,fadeoutval
		call	fade
		jmp	@@stripewave


@@stripe:	mov	fadeoutval,128

@@stripewave:	mov	morph,20
		call	distabgen

		load	fs,@distabseg
		jmp	@@mandalawave

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

@@mandinit:     lea	si,cs:mandalapal
		call	fillpalette

		mov	cx,32000
		xor	ax,ax
		xor	di,di
		rep	stosw
		mov	mandinit,1

@@mandalain:
		mov	bp,fadeinval
		call	fade
		jmp	@@mandala

@@mandalaout:
		mov	bp,fadeoutval
		call	fade

@@mandala:
		load	fs,@circtabseg
		cmp	timer,t_mandala
		ja	@@mandalawave
		mov	fadeoutval,128


@@mandalawave:	load	gs,@mandala


		push	es
		load	es,@multabseg

		mov	cx,256
		xor	di,di
		mov	si,deg
		add	si,si

@@0:            mov	ax,ds:sintable[si]

		push	ax
		mov	bl,16

		sar	ax,4

		neg	al

		mov	es:[di+256],al
		pop	ax

		sar	ax,5
		add	ax,128
		stosb

		add	si,8
		and	si,511
		loop	@@0

		pop	es

		sub	byte ptr deg,5

		call	wave
		call	waitrtc

		jmp	@@endeffect

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

@@fireinit:     call	wood

		lea	si,cs:firepal
		call	fillpalette

		mov	fadeinval,0
		mov	fireinit,1

@@firein:
		mov	bp,fadeinval
		call	fade
		jmp	@@fireballs

@@fireout:
		mov	bp,fadeoutval
		call	fade

@@fireballs:	cmp	timer,t_fireballs
		ja	@@goballs
		mov	fadeoutval,128

@@goballs:	call	makefire

		push	ds
		load	es,@virtscr
		load	ds,@mazeseg
		xor	di,di
		xor	si,si
		mov	cx,32000
		rep	movsw
		pop	ds


		call	drawobject
		call	drawvirt


		add	byte ptr alpha,1
		add	byte ptr beta,-2
		add	byte ptr gamma,1


		jmp	@@endeffect


@@endeffect:	in	al,60h
		dec	al
		jnz	@@timingeffects


;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

@@todos:        in	al,21h
		and	al,255-6
		out	21h,al

		mov	ah,1
		int	16h
		jz	@@pufferisempty

		xor	ax,ax
		int	16h

@@pufferisempty:

		load    es,0
		cli
		mov     eax,cs:oldint8
		mov     es:[4*8],eax

		mov     al,36h
		out     43h,al
		xor     ax,ax
		out     40h,al
		out     40h,al

		sti

		mov     ax,3
		int     10h

@@out:		load	ds,cs
		lea	dx,cs:endmessage
		mov	ah,9
		int	21h

		mov     ax,4c00h
		int     21h

endmessage	db	"(c) 1996/97 by rod/mandula",13,10,'$'


main            endp

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
wave		proc	near
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

		push	ds
		load	ds,@multabseg

		mov	di,32

		mov	dh,0
@@yloop:	mov	dl,0

@@xloop:
		mov	cx,word ptr fs:distable[di]
		mov	bl,cl
		mov	bh,0

shadepatch1:	mov	al,0
		nop
		nop

		mov	bh,[bx]
		mov	bl,dl
		mov	cl,[bx]
		mov	bl,dh
		mov	bh,[bx]
		mov	bl,cl
		add	al,gs:[bx+7168]

		inc	dl


		mov	bl,ch
		mov	bh,0
shadepatch2:	mov	ah,0
		nop
		nop

		mov	bh,[bx]
		mov	bl,dl
		mov	ch,[bx]
		mov	bl,dh
		mov	bh,[bx]
		mov	bl,ch
		add	ah,gs:[bx+7168]

		mov	es:[di],ax

		inc	dl
		add	di,2


		cmp	dl,0
		jne	@@xloop


		add	di,320-256
		inc	dh
		cmp	dh,200
		jne	@@yloop

		pop	ds
		ret

wave		endp



;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
distabgen	proc	near
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

		mov	ax,deg
		mov	cs:byte ptr @@patch+2,al

		push	es fs gs

		load	fs,@degtabseg
		load	gs,@circtabseg
		load	es,@distabseg

		mov	di,63999

		mov	dx,morph

@@loop:         mov	cl,gs:[di]
		mov	bl,fs:[di]

@@patch:        add	bl,0ffh

		mov	bh,0
		add	bx,bx
		mov	ax,ds:sintable[bx]
		idiv	dl

		add	al,cl
		mov	es:[di],al
		dec	di
		jnz	@@loop

		pop	gs fs es

		ret


distabgen	endp


;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
stripes		proc	near
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

		load	es,@mandala
		xor	di,di
		mov	cx,32768
		xor	ax,ax
		rep	stosw

		xor	si,si

		xor	cx,cx
		xor	di,di
@@1:
		mov	ax,15
		call	random
		inc	ax

		mov	bx,cs:ctable[si-2]
		mov	ah,es:[di+bx]
		mov	bx,cs:ctable[si]
		add	ah,es:[di+bx]
		shr	ah,1
		add	al,ah
		add	al,16
		stosb

		add	si,2
		and	si,15

		dec	cx
		jnz	@@1

		ret

stripes		endp

		dw	-257
ctable		dw	-256,-255,1,257,256,255,-1,-257



;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
drawobject	proc	near
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

		load	es,ds

		call	calcrot

		lea	si,ds:object
		lea	di,ds:currentobject
		mov	cx,np
		call	rotatexyz


		mov	cx,np
		lea	si,ds:currentobject
		lea	di,ds:zlist
@@fillzlist:	mov     ax,ds:[si+4]
		neg	ax
		stosw
		mov	ax,si
		stosw
		add	si,6
		loop	@@fillzlist



		lea	cx,ds:zlist
		lea	dx,ds:zlist+(np-1)*4
		call	qsort

		mov	cx,np
		lea	si,zlist

		load	es,@virtscr

@@perspective:
		mov	di,[si+2]

		mov	bx,ds:[di+4]
		add	bx,addzball
		mov     ax,ds:[di]
		cwd
		mov	dl,ah
		mov	ah,al
		mov	al,0
		idiv	bx
		add	ax,addxball
		mov	ballx,ax

		mov     ax,ds:[di+2]
		cwd
		mov	dl,ah
		mov	ah,al
		mov	al,0
		idiv	bx
		add	ax,addyball
		mov	bally,ax

		pusha

		sub	bx,400
		sar	bx,6
		call	drawfireball

		popa

		add	si,4

		loop	@@perspective


		ret

drawobject	endp

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
qsort		proc	near
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		mov	bx,cx
		add	bx,dx
		rcr	bx,1
		and	bx,0FFFCh

		mov	si,cx
		mov	di,dx

		mov	bx,ds:[bx]
		sub	si,4
		add	di,4
@@repeat:
@@while_i:
		add	si,4
		cmp	ds:[si],bx
		jl	@@while_i
@@while_j:
		sub	di,4
		cmp	ds:[di],bx
		jg	@@while_j
		cmp	si,di
		jae	@@break
		mov	eax,ds:[si]
		mov	ebp,ds:[di]
		mov	ds:[si],ebp
		mov	ds:[di],eax
		jmp	@@repeat
@@break:
		sub	si,4
		add	di,4

		cmp	cx,si
		jae	@@noleft
		push	dx di
		mov	dx,si
		call	qsort
		pop	di dx
@@noleft:
		cmp	di,dx
		jae	@@noright
		mov	cx,di
		call	qsort
@@noright:
		ret

qsort	endp

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
drawfireball	proc     near
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

		sub	ballx,16
		sub	bally,16

		add	bx,bx
		mov	si,balloffsets[bx]

		mov	ax,bally
		shl	ax,6
		mov	di,ax
		shl	ax,2
		add	di,ax
		add	di,ballx

		mov	dx,32
@@yloop:	mov	cx,32
@@xloop:	mov	bx,ds:[si]
		mov	al,fire[bx]
		or	al,al
		jz	@@black
		mov	es:[di],al

		mov	al,es:[di+320*5+10]
		cmp	al,192+12
		jb	@@black

		sub	byte ptr es:[di+320*5+10],12

@@black:	inc	di
		add	si,2
		loop	@@xloop
		add	di,320-32

		dec	dx
		jnz	@@yloop

		ret

drawfireball	endp

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
balltransform   proc     near
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

		load	es,ds
		cld
		finit

		mov	dx,-16
@@yloop:	mov	cx,-16
		mov	bx,dx
		imul	bx,bx
		mov	bally,dx
@@xloop:
		mov	ballx,cx
		or	cx,cx
		jne	@@notzero
		cmp	dx,0
		jge	@@ygr0
		fldpi
		fld1
		fld1
		fadd

		fdiv
		jmp	@@morecalc

@@ygr0:         fldpi
		movfdd	ddtemp,1.5
		fld	ddtemp
		fmul
		jmp	@@morecalc


@@notzero:	fild	bally
		fild	ballx
		fpatan
		fldpi
		fadd

@@morecalc:     mov	dwtemp,32
		fild	dwtemp
		fmul
		fldpi
		fdiv

		fistp	dwtemp

		mov	ax,cx
		imul	ax,ax
		add	ax,bx
		mov	sqr,ax
		fild	sqr
		fsqrt
		fistp	sqr

		mov	ax,sqr
		cmp	ax,radius
		ja	@@black

		sub	ax,radius
		neg	ax
		shl	ax,5
		add	ax,dwtemp
		jmp	@@store

@@black:	xor	ax,ax
@@store:	stosw
		inc     cx
		cmp	cx,16
		jl	@@xloop

		inc	dx
		cmp	dx,16
		jl	@@yloop

		ret

balltransform   endp

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
makefire	proc	near
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

decay = 30
		load	es,ds


		lea	si,fire+32
		lea	di,fire
		mov	cx,32*16

@@actflame:     lodsb
		or	al,al
		jz	@@black

		cmp	al,decay
		jb	@@black


		mov	dl,al
		mov	ax,7
		call	random
		sub	ax,3
		mov	bx,ax
		mov	ax,decay
		call	random
		sub	dl,al
		mov	[di+bx],dl
		inc	di
		loop	@@actflame
		jmp	@@actflameready

@@black:        mov	byte ptr [di],0
		inc	di
		loop	@@actflame

@@actflameready:
		mov	fire[0],0


		lea	di,fire+15*32
		mov	ax,0

fireroot = $ - 2

		mov	cx,16
		rep	stosw

		ret

makefire	endp

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
calcrot		proc	near
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

		mov	bx,alpha
		add	bx,bx
		mov	ax,sintable[bx]
		mov	sinalpha,ax
		mov	di,costable[bx]

		mov	bx,beta
		add	bx,bx
		mov	si,sintable[bx]
		mov	bp,costable[bx]

		mov	bx,gamma
		add	bx,bx
		mov	cx,sintable[bx]
		mov	ax,costable[bx]
		mov	bx,ax

		imul	bp
		shrd	ax,dx,8
		mov	r11,ax

		mov	ax,cx
		imul	bp
		shrd	ax,dx,8
		mov	r12,ax

		mov	ax,si
		mov	r13,ax
		neg	r13

		mov	ax,di
		imul	cx
		shrd	ax,dx,8
		mov	add11,ax

		mov	ax,sinalpha
		imul	bx
		shrd	ax,dx,8
		mov	add12,ax
		imul	si
		shrd	ax,dx,8
		sub	ax,add11

		mov	r21,ax

		mov	ax,add11
		imul	si
		shrd	ax,dx,8
		sub	ax,add12
		mov	r32,ax

		mov	ax,di
		imul	bx
		shrd	ax,dx,8
		mov	add11,ax

		mov	ax,sinalpha
		imul	cx
		shrd	ax,dx,8
		mov	add12,ax
		imul	si
		shrd	ax,dx,8
		add	ax,add11
		mov	r22,ax

		mov	ax,add11
		imul	si
		shrd	ax,dx,8
		add	ax,add12
		mov	r31,ax

		mov	ax,sinalpha
		imul	bp
		shrd	ax,dx,8
		mov	r23,ax

		mov	ax,di
		imul	bp
		shrd	ax,dx,8

		mov	r33,ax

		ret

calcrot		endp

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
rotatexyz	proc	near
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

@@rotxyz:       mov	ax,r12
		imul	word ptr ds:[si]
		shrd	ax,dx,8
		mov	bx,ax

		mov	ax,r22
		imul	word ptr ds:[si+2]
		shrd	ax,dx,8
		add	bx,ax

		mov	ax,r32
		imul	word ptr ds:[si+4]
		shrd	ax,dx,8
		add	ax,bx
		mov	ds:[di+2],ax

		mov	ax,r11
		imul	word ptr ds:[si]
		shrd	ax,dx,8
		mov	bx,ax

		mov	ax,r21
		imul	word ptr ds:[si+2]
		shrd	ax,dx,8
		add	bx,ax

		mov	ax,r31
		imul	word ptr ds:[si+4]
		shrd	ax,dx,8
		add	ax,bx
		mov	ds:[di],ax

		mov	ax,r13
		imul	word ptr ds:[si]
		shrd	ax,dx,8
		mov	bx,ax

		mov	ax,r23
		imul	word ptr ds:[si+2]
		shrd	ax,dx,8
		add	bx,ax

		mov	ax,r33
		imul	word ptr ds:[si+4]
		shrd	ax,dx,8
		add	ax,bx
		mov	ds:[di+4],ax

		add	di,6
		add	si,6
		dec	cx
		jnz	@@rotxyz

		ret

rotatexyz	endp


;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
wood		proc	near
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

		push	ds
		load	ds,@mazeseg
		load	es,ds

		xor	di,di
		mov	ax,0e1e0h
		mov	cx,32000
		rep	stosw

		xor	cx,cx
		xor	bp,bp
@@woo:		mov	ax,bp
		add	bp,bx
		and	ax,7

		mov	bl,[di-320]
		or	al,al
		jz	@@0
		dec	al
		jz	@@1
		dec	al
		jz	@@2
		dec	al
		jz	@@3

@@4:		mov	[di],bl
		inc	di
		loop	@@woo

		pop	ds

		ret

@@0:		cmp	bl,253
		ja	@@4
		inc	bl
@@01:		inc	bl
		jmp	@@4

@@1:		cmp	bl,194
		jb	@@4
		dec	bl
@@11:		dec	bl
		jmp	@@4

@@2:		cmp	bl,[di-321]
@@21:		je	@@4
		jb	@@01
		jmp	@@11

@@3:		cmp	bl,[di-319]
		jmp	@@21

wood		endp

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
mandala		proc	near
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

		load	es,ds
		load	ds,cs
		lea	si,mandata
		lea	di,x0
		mov	cx,48
		rep	movsw

		load	ds,es

		load	es,@mandala


		fninit

		mov	bx,85
		xor	di,di
@@yloop:
		fld	x0
		fstp	x
		mov	dx,85

@@xloop:
		fld	x
		fmul	x
		fld	y
		fmul	y
		fadd
		fsqrt
		fstp	r
		fld	y
		fld	x
		fpatan
		fstp	phi

		xor	cx,cx

@@iter:		inc	cx

		fld1
		fdiv	r
		fld	st(0)
		fmul
		fst	r

		fld	phi
		fadd	phi
		fchs
		fstp	phi

		fcomp	bailout

		fnstsw	status

		test	byte ptr status+1,01000101b
		jz	@@out

		jmp	@@iter

@@out:		fld	phi
		fsin
		fmul	r
		frndint
		fistp	status
		shl	cx,3
		add	cx,status
		cmp	cx,256
		jb	@@iterout
		mov	cl,0
@@iterout:	mov	ch,cl

		mov	es:[di],cl
		mov	es:[di+85],cl
		mov	es:[di+85*2],cx

		mov	es:[di+256*85],cl
		mov	es:[di+256*85+85],cl
		mov	es:[di+256*85+85*2],cx

		mov	es:[di+256*85*2],cl
		mov	es:[di+256*85*2+85],cl
		mov	es:[di+256*85*2+85*2],cx

		mov	es:[di+256*85*3],cl
		mov	es:[di+256*85*3+85],cl
		mov	es:[di+256*85*3+85*2],cx


		fld	x
		fadd	addx
		fstp	x

		inc	di
		dec	dx
		jnz	@@xloop

		add	di,256-85
		fld	y
		fadd	addy
		fstp	y

		dec	bx
		jnz	@@yloop

		ret

mandala		endp

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

mandata		dq	-1.7473876,-1.7473876,1.72384644,0.0415735
		dq	-0.0410288,8.0

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
initwave	proc	near
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

		load	fs,@circtabseg
		load	es,@degtabseg
		xor	di,di

		movfdd	sz255,1275.0

		mov	dx,-100
@@yloop:	mov	cx,-160
		mov	bx,dx
		imul	bx,bx
@@xloop:	mov	ax,cx
		imul	ax,ax
		add	ax,bx
		mov	status,ax
		fild	status
		fsqrt
		fistp	word ptr fs:[di]

		cmp	cx,0
		jne	@@notzero
		cmp	dx,0
		jge	@@ygr0
		mov	al,64+128
		jmp	@@storedeg

@@ygr0:		mov	al,64
		jmp	@@storedeg
@@notzero:
		mov	status,dx
		fild	status
		mov	status,cx
		fild	status
		fpatan
		fmul	sz255
		fldpi
		fadd	st,st
		fdiv
		fistp	status
		mov	ax,status
@@storedeg:	mov	es:[di],al

		inc	di
		inc	cx
		cmp	cx,160
		jne	@@xloop
		inc	dx
		cmp	dx,100
		jne	@@yloop

		load	es,@multabseg
		xor	di,di

		mov	bx,0
@@yloop2:	mov	cx,-127
@@xloop2:	mov	ax,cx
		imul	bx
		shrd	ax,dx,7
		add	al,128
		stosb
		inc	cx
		cmp	cx,128
		jle	@@xloop2
		inc	bx
		cmp	bx,256
		jbe	@@yloop2

		ret

initwave	endp

oldint8         dd      ?

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;
newint8         proc    near
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

		push    ds

		load    ds,@data
		inc     ds:timer


		cmp	ds:fadeinval,128
		je	@@1
		inc	ds:fadeinval
@@1:		cmp	ds:fadeoutval,0
		je	@@2
		dec	ds:fadeoutval
@@2:

		pop     ds
		jmp     dword ptr cs:oldint8

newint8         endp

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;
gensintable     proc    near
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

		xor     edi,edi
		mov     ebx,65535
		mov     ebp,2*804

		xor     si,si
		mov     cx,320

@@singen:       mov     eax,edi
		shr     eax,8
		mov     sintable[si],ax

		inc     si
		inc     si

		mov     eax,edi
		imul    ebp
		shrd    eax,edx,16
		sub     ebx,eax
		mov     eax,ebx
		imul    ebp
		shrd    eax,edx,16
		add     edi,eax

		loop    @@singen

		ret


gensintable     endp

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
drawmaze        proc    near
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

		xor     bx,bx
		mov     di,32000+160-2

@@draw:         push    bx

		mov     ax,dist[bx]
		mov     si,angle
		add     si,si
		mov     cx,costable[si]
		push    ax
		imul    cx
		shrd    ax,dx,8
		mov     cx,ax
		mov     bp,ax
		neg     bp


		pop     ax
		mov     bx,sintable[si]
		imul    bx
		shrd    ax,dx,8
		mov     dx,ax
		mov     si,ax

		shl     cx,8
		shl     dx,8
		add     ch,xpos
		add     dh,ypos

		push    ds
		load    ds,@mazeseg

		std
		push    di cx dx
		rept    80

			mov     bl,ch
			mov     bh,dh
			mov     ah,[bx]
			add     cx,si
			add     dx,bp
			mov     bl,ch
			mov     bh,dh
			mov     al,[bx]
			add     cx,si
			add     dx,bp
			stosw

		endm
		pop     dx cx di

		inc     di
		inc     di

		cld
		rept    80

			sub     cx,si
			sub     dx,bp
			mov     bl,ch
			mov     bh,dh
			mov     al,[bx]
			sub     cx,si
			sub     dx,bp
			mov     bl,ch
			mov     bh,dh
			mov     ah,[bx]
			stosw

		endm

		pop     ds

		add     di,160-2

		pop     bx

		inc     bx
		inc     bx
		cmp     bx,200
		jb      @@draw


		mov     di,32000-320
		mov     cx,320
@@3d:           push    di
@@1:            mov     dl,10
		mov     bl,es:[di]
		dec     bl

@@2:            add     di,320
		cmp     di,64000
		ja      @@endrow
		mov     al,es:[di]
		or      al,al
		jnz     @@1

		or      dl,dl
		jz      @@2
		dec     dl

		mov     es:[di],bl
		sub     bl,2


		jmp     @@2

@@endrow:       pop     di
		inc     di
		cmp     di,32320
		jb      @@3d

		ret

drawmaze        endp

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
genmaze         proc    near
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

		load    es,@mazeseg
		load    ds,es

		mov     di,32768
		xor     cx,cx
@@pixloop:
		mov     ax,di
@@randseed:     imul    ax,01234h
		add     ax,di
		mov     word ptr cs:@@randseed+2,ax

		sar     ax,0Ch
		inc     ax

		mov     ah,es:[di-256]
		add     ah,es:[di-257]
		rcr     ah,1
		add     al,ah
		and     al,127
		add     al,128
		stosb
		loop    @@pixloop

		std
		mov     di,65535
		mov     si,32767
		mov     dl,128
@@row2:         mov     cx,256
		rep     movsb
		add     si,256
		mov     cx,256
		rep     movsb
		dec     dl
		jnz     @@row2

		mov     dx,65536-256
		mov     bx,256
		call    alias

		cld
		load    ds,cs
		lea     si,mazedat
		xor     di,di
		mov     dl,16
@@gen:          lodsw
		mov     bx,ax
		xor     ax,ax

		mov     bp,16
@@line:         rcl     bx,1
		jnc     @@notblack
		push    di

		mov     dh,16
@@row:          mov     cx,8
		rep     stosw
		add     di,256-16
		dec     dh
		jnz     @@row

		pop     di

@@notblack:     add     di,16
		dec     bp
		jnz     @@line

		add     di,256*15
		dec     dl
		jnz     @@gen


		load    ds,@data
		xor     bx,bx
		mov     cx,30
@@gendist:      mov     ax,256*50
		cwd
		idiv    cx
		mov     dist[bx],ax
		inc     cx
		inc     bx
		inc     bx
		cmp     bx,200
		jnz     @@gendist


		ret

genmaze         endp

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
genclouds       proc    near
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

		load    ds,@data
		load    fs,@clouds

		lea     di,ds:palette

		load    es,ds
		mov     cx,768
		xor     ax,ax
		rep     stosb

		call    setpalette

		load    es,0a000h

		mov     cx,100
		mov     linexstart,0
		mov     linexend,639
@@backloop:     mov     liney,cx
		mov     ax,cx
		shr     ax,1
		add     al,10
		mov     color,al
		call    horizline
		dec     cx
		jns     @@backloop

		mov     bp,150
@@cloudloop:    mov     ax,640-20
		lea     bx,random
		call    bx
		add     ax,10
		mov     xc,ax
		mov     ax,80
		call    bx
		add     ax,10
		mov     yc,ax
		mov     ax,10
		call    bx
		inc     ax
		mov     radius,ax
		mov     ax,50
		call    bx
		add     al,30
		mov     color,al
		call    filledcircle
		dec     bp
		jnz     @@cloudloop

		call    copy

		load    es,0a000h

		xor     di,di
@@smearlooprow: xor     bx,bx
		mov     dh,0
@@smearloopcol: mov     si,di
		add     si,bx
		mov     dl,fs:[si]
		mov     cl,dh
		shr     cl,1
		add     cl,10
		cmp     dl,cl
		je      @@marad
		mov     ax,50
		call    random
		add     dl,al
@@marad:        mov     ax,31
		call    random
		sub     ax,15
		add     si,ax
		mov     es:[si],dl
		add     bx,640
		inc     dh
		cmp     dh,100
		jb      @@smearloopcol

		inc     di
		cmp     di,640
		jb      @@smearlooprow

		call    copy

		push    ds
		load    ds,fs
		load    es,0a000h
		mov     bx,640
		mov     dx,64000-640
		call    alias
		call    alias
		pop     ds

		call    copy

		load    es,0a000h
		xor     di,di
		mov     cx,32000
		xor     ax,ax
		rep     stosw

		lea	si,cs:mazepal
		call	fillpalette

		ret

genclouds       endp

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
genlogo         proc    near
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

		mov	cs:randseed,35212

		lea     di,ds:palette

		load    es,ds
		mov     cx,768
		xor     ax,ax
		rep     stosb

		call    setpalette

		push    ds es

		push    cs
		pop     ds

		push    0a000h
		pop     es

		lea     si,logo
		mov     di,40+85*320

		mov     dh,15
@@col:
		mov     dl,15
@@row:          lodsb
		mov     bh,al
		mov     cx,8
@@byte:         xor     ax,ax
		rcl     bh,1
		jnc     @@black
		mov     ax,0ffffh
		call    random
		and     ax,7f7fh

@@black:        mov     es:[di+320],ax
		stosw
		loop    @@byte

		dec     dl
		jnz     @@row

		add     di,320+320-120*2
		dec     dh
		jnz     @@col

@@alias:        push    es
		pop     ds
		mov     dx,3

@@aliasonce:
		xor     ah,ah
		xor     di,di
		mov     si,di

		mov     bp,160
@@aliaschar:    mov     cx,320

@@aliasrow:     lodsb
		add     al,es:[si]
		adc     ah,0
		add     al,es:[si+319]
		adc     ah,0
		add     al,es:[si+320]
		adc     ah,0
		shr     ax,2
		stosb
		loop    @@aliasrow

		dec     bp
		jnz     @@aliaschar

		dec     dx
		jnz     @@aliasonce

		pop     es ds

		lea	si,cs:logopal
		call	fillpalette

		xor	bp,bp
		mov	bx,64
@@fadein:	call	waitrtc
		call	fade
		inc	bp
		inc	bp
		dec	bx
		jnz	@@fadein

		mov	timer,0
@@wait:		cmp	timer,100
		jb	@@wait

		mov	bx,64
@@fadeout:	call	waitrtc
		call	fade
		dec	bp
		dec	bp
		dec	bx
		jnz	@@fadeout

		ret

genlogo         endp

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
alias           proc    near
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

		mov     di,bx
@@aliasloop:    xor     cx,cx
		mov     cl,[di]
		shl     cx,2
		mov     ax,cx
		mov     cl,[di+1]
		mov     ch,0
		shl     cx,1
		add     ax,cx
		mov     cl,[di-1]
		mov     ch,0
		shl     cx,1
		add     ax,cx
		mov     cl,[di+bx]
		mov     ch,0
		shl     cx,1
		add     ax,cx
		mov     cl,[di-bx]
		mov     ch,0
		shl     cx,1
		add     ax,cx
		mov     cl,[di-bx-1]
		mov     ch,0
		add     ax,cx
		mov     cl,[di-bx+1]
		add     ax,cx
		mov     cl,[di+bx+1]
		add     ax,cx
		mov     cl,[di+bx-1]
		add     ax,cx
		shr     ax,4
		mov     es:[di],al
		inc     di
		cmp     di,dx
		jb      @@aliasloop
		ret

alias           endp

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
copy            proc    near
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

		push    ds
		load    es,fs
		load    ds,0a000h
		xor     si,si
		xor     di,di
		mov     cx,32000
		rep     movsw
		pop     ds

		ret
copy            endp

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
filledcircle    proc    near
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

		xor     bx,bx
		mov     cx,radius
		mov     dx,cx
		shl     dx,1
		neg     dx
		add     dx,3

@@circloop:     cmp     bx,cx
		jge     @@vege

		call    @@circline
		cmp     dx,0
		jge     @@1

		mov     ax,bx
		shl     ax,2
		add     ax,6
		add     dx,ax
		jmp     @@ki
@@1:            mov     ax,bx
		sub     ax,cx
		shl     ax,2
		add     ax,10
		add     dx,ax

		dec     cx
@@ki:           inc     bx
		jmp     @@circloop


@@vege:         cmp     bx,cx
		jne     @@vege2

@@circline:
		mov     ax,yc
		sub     ax,cx
		mov     liney,ax
		mov     ax,xc
		sub     ax,bx
		mov     linexstart,ax
		mov     ax,xc
		add     ax,bx
		mov     linexend,ax
		call    horizline

		mov     ax,yc
		add     ax,cx
		mov     liney,ax
		call    horizline
		mov     ax,yc
		sub     ax,bx
		mov     liney,ax
		mov     ax,xc
		sub     ax,cx
		mov     linexstart,ax
		mov     ax,xc
		add     ax,cx
		mov     linexend,ax
		call    horizline

		mov     ax,yc
		add     ax,bx
		mov     liney,ax
		call    horizline

@@vege2:        ret

filledcircle    endp

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
horizline       proc    near
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

		pusha
		mov     bx,linexstart

		mov     di,liney
		mov     ax,di
		shl     di,9
		shl     ax,7
		add     di,ax
		add     di,bx

		mov     cx,linexend
		sub     cx,bx
		inc     cx
		mov     al,color
		rep     stosb
		popa

		ret

horizline       endp

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
sky             proc    near
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

		mov     bx,skyxstart
		push    ds
		load    ds,@clouds
		mov     bp,100
		xor     di,di
@@skyloop:      mov     si,bx
		mov	cx,320
		rep	movsb

		add     bx,640
		dec     bp
		jnz     @@skyloop

		pop     ds
		ret

sky             endp

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
fillpalette     proc    near
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		cld
		push	ds es
		load	es,ds
		load	ds,cs
		lea	di,palette

		xor	ax,ax
		stosw
		stosb
@@set:		lodsw
		xchg	cx,ax
		jcxz	@@end
		lodsw
		xchg	bx,ax
		lodsw
		xchg	dx,ax
		lodsw
@@col:		mov	es:[di],bh
		mov	es:[di+1],dh
		mov	es:[di+2],ah

		add	bx,[si]
		add	dx,[si+2]
		add	ax,[si+4]

		add	di,3
		loop	@@col

		add	si,6
		jmp	@@set


@@end:		pop	es ds
		ret

fillpalette     endp

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
setpalette      proc    near
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

		lea	si,palette
		mov     dx,03c8h
		xor     al,al
		out     dx,al
		inc     dl
		mov     cx,768
		rep     outsb

		ret

setpalette      endp

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
fade		 proc    near
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

		cld
		lea     si,ds:palette
		mov     dx,03c8h
		xor     ax,ax
		out     dx,al
		inc     dl
		mov     cx,768
@@3:            lodsb
		imul    ax,bp
		shr     ax,7
		out     dx,al
		loop	@@3

		ret

fade		endp

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
drawvirt        proc     near
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

		call	waitrtc

		push    ds
		load    es,0a000h
		load    ds,@virtscr
		xor     si,si
		xor     di,di
		mov     cx,32000
		rep     movsw
		pop     ds

		ret

drawvirt        endp

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
waitrtc		proc	near
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

		cli
		mov 	dx,3dah
@@wait1:
		in 	al,dx
		test 	al,08h
		jz 	@@wait1
@@wait2:
		in 	al,dx
		test	al,08h
		jnz  	@@wait2
		sti
		ret

waitrtc		endp

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
random          proc     near
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

		push    bx cx dx
		mov     cx,ax
		mov     ax,75
		mov     bx,cs:randseed
		mul     bx
		add     ax,74
		sbb     ax,dx
		mov     cs:randseed,ax
		xor     dx,dx
		div     cx
		mov     ax,dx
		pop     dx cx bx
		ret

random          endp

randseed        dw      0

;ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ


;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

mazedat         dw      1000100100000100b
		dw      1110101111010111b
		dw      0000101001010000b
		dw      1011101101011011b
		dw      1000100100000010b
		dw      1011110101111010b
		dw      1000010001000010b
		dw      1101010111101110b
		dw      0001010100000000b
		dw      0111011110111111b
		dw      0000000000100000b
		dw      1111011011101111b
		dw      0100000000001000b
		dw      0101111011111101b
		dw      0000001010000001b
		dw      1111101111101101b

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
logo    label byte

 db 2,2,0,2,0,152,17,252,0,8,4,128,0,16,0,2,135,0,7,0
 db 80,28,127,128,28,3,0,0,56,0,7,134,0,7,32,120,8,56,192,28
 db 131,0,0,57,0,7,142,0,47,64,124,24,48,32,189,7,0,1,122,0
 db 7,207,0,27,128,50,24,48,48,110,7,64,0,220,0,15,203,64,9,128
 db 51,24,48,80,38,3,128,0,76,0,13,217,128,17,200,49,184,48,16,71
 db 33,128,0,142,64,44,209,0,16,240,113,176,32,16,67,193,128,0,135,128
 db 24,240,160,255,224,48,176,32,51,255,133,128,7,255,0,24,240,192,54,224
 db 52,244,40,80,219,131,160,1,183,0,60,224,192,32,224,56,120,112,16,131
 db 129,192,1,7,0,56,112,192,64,112,120,112,96,49,1,193,192,2,3,128
 db 48,112,96,64,112,112,48,96,225,1,193,132,66,3,128,116,120,104,208,120
 db 240,49,127,195,65,227,248,198,131,192,248,236,241,240,204,152,120,255
 db 7,195,51,255,143,134,96

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

cubes		dw	 100, 100, 100
		dw	-100,-100,-100
		dw	-100, 100, 100
		dw	 100,-100, 100
		dw	 100, 100,-100
		dw	-100,-100, 100
		dw	 100,-100,-100
		dw	-100, 100,-100

		dw	 50, 50, 50
		dw	-50, 50, 50
		dw	 50,-50, 50
		dw	 50, 50,-50
		dw	-50,-50, 50
		dw	 50,-50,-50
		dw	-50, 50,-50
		dw	-50,-50,-50
		dw	0,0,0

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

logopal		dw      48,103,114,163,103,114,163
		dw	55,4944,5472,7824,204,195,153
		dw	0

mazepal		dw	127,17*256,14*256,34*256,46*2,49*2,29*2
		dw	128,24*256,4*256,0,78,118,126
		dw	0

mandalapal	dw      127,13*256,10*256,26*256,100,102,74
		dw	128,63*256,63*256,63*256,-100,-102,-74
		dw	0

firepal         dw	63,256,57,0,256,57,0
		dw	64,63*256,14*256,0,-8,142,85
		dw	64,61*256,49*256,21*256,8,57,171
		dw	64,0,14*256,26*256,252,199,150
		dw	0

stripepal       dw	143,5376,512,512,68,81,18
		dw	0


end            	main
