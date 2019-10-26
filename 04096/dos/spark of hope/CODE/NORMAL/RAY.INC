;-------------------------------------------------------------------------------
SingleShadeTun	PROC
	add	ebx,ds:[TabPtr]
	shr	ebx,1			;ebx = texture ( aligned on 20000h )
	xor	esi,esi
	mov	edi,ds:[TabPtr]		;edi = destination
	mov	bx,[esi*2+edi+TunelBuffer]
SSTun:
	mov	ax,[ebx+ebx]
	xor	dh,dh
	mov	dl,[esi+edi+TunelBuffer+320*200*2] 
	mov	cx,ax
	and	ax,111110000011111b
	and	cx,000001111100000b
	sub	al,dl
	jge	NoBlueFade1
	xor	al,al
NoBlueFade1:	
	shl	dl,2
	sub	ah,dl
	jge	NoGreenFade1
	xor	ah,ah
NoGreenFade1:	
	shl	dx,3
	sub	cx,dx
	jge	NoRedFade1
	xor	cx,cx
NoRedFade1:	
	mov	bx,[esi*2+edi+TunelBuffer+2]
	or	ax,cx
	mov	[esi*2+edi],ax
	inc	si
	cmp	si,64000
	jnz	SSTun
	ret
SingleShadeTun	ENDP


ALIGN	4

Du	dw 0
Dv	dw 0
Du2	dw 0
Dv2	dw 0

Temp	dd 	0
Temp2	dd 	0
TR	dw 	10000

T1	dd 1.0
T76f8	dw 77
T8	dw 8

t128pi	dd 40.74366543
t128pi2	dd 10430.37835
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
ALIGN 4
OriginX		dd 0.0		;Camera coordinates
OriginY		dd 0.0
OriginZ		dd 256.0
DirX		dd 0.0
DirY		dd 0.0
DirZ		dd 0.0
T		dd 0.0
HitX		dd 0.0
HitY		dd 0.0
HitZ		dd 0.0
DepthColor	dd 61.3
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@MkTr160	dw -160
@MkTr100	dw -100
@MkTr256	dw 256

MkTraceTab	PROC
	mov	di,offset TraceTabSet
	fild	[@MkTr100]
	mov	cx,26
MkTraceY:
	fild	[@MkTr160]
	mov	dx,41
MkTraceX:
	fld	st
	fmul	st,st
	fld	st(2)
	fmul	st,st
	fild	[@MkTr256]
	fmul	st,st
	faddp	st(1),st
	faddp	st(1),st
	fsqrt
	fld	st(1)
	fdiv	st,st(1)
	fstp	dword ptr [di]
	fld	st(2)
	fdiv	st,st(1)
	fstp	dword ptr [di+4]
	fild	[@MkTr256]
	fdiv	st,st(1)
	fstp	dword ptr [di+8]
	fstp	st
	
	fiadd	[T8]
	add	di,12
	dec	dx
	jnz	MkTraceX
	fstp	st
	fiadd	[T8]
	loop	MkTraceY
	fstp	st
	ret
MkTraceTab	ENDP
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
ALIGN 4
anglex		dd 0.0
angley		dd 0.0
anglez		dd 0.0

sinx		dd 0.0
cosx		dd 0.0
siny		dd 0.0
cosy		dd 0.0
sinz		dd 0.0
cosz		dd 0.0

PreRotates PROC			
	fld	[anglex]
	fsincos
	fstp	[cosx]
	fstp	[sinx]
	fld	[angley]
	fsincos
	fstp	[cosy]
	fstp	[siny]
	fld	[anglez]
	fsincos
	fstp	[cosz]
	fstp	[sinz]
	ret
PreRotates	ENDP
;-------------------------------------------------------------------------------
Rotates PROC			
	fld	dword ptr [si]			;X
	fld	dword ptr [si+4]		;Y
	fld	dword ptr [si+8]		;Z
;OX Rotation :
	fld	st(1)				;y
	fmul	[cosx]				;y*cosx
	fxch	st(2)				;y
	fmul	[sinx]				;y*sinx
	fld	st(1)				;z
	fmul	[sinx]				;z*sinx
	fxch	st(2)				;z
	fmul	[cosx]				;z*cosx
	fxch	st(2)				;
	faddp	st(3),st			;
	fsubp	st(1),st			;
;OY Rotation :
	fld	st(2)				;x
	fmul	[cosy]				;x*cosy
	fxch	st(3)				;x
	fmul	[siny]				;x*siny
	fld	st(1)				;z
	fmul	[siny]				;z*siny
	fxch	st(2)				;z
	fmul	[cosy]				;z*cosy
	fxch	st(2)				;
	fsubp	st(4),st			;
	faddp	st(1),st			;
;OZ Rotation :
	fld	st(1)				;y
	fmul	[cosz]				;y*cosz
	fxch	st(2)				;y
	fmul	[sinz]				;y*sinz
	fld	st(3)				;x
	fmul	[sinz]				;x*sinz
	fxch	st(4)				;x
	fmul	[cosz]				;x*cosz
	fxch	st(4)				;st(0)=x*sinz
	fsubp	st(3),st			;yn=y*cosz-x*sinz
	faddp	st(3),st			;xn=y*sinz+x*cosz
	fstp	[DirZ]
	fstp	[DirY]
	fstp	[DirX]
        ret
Rotates ENDP
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
FdTunel	PROC
	mov	si,offset TraceTabSet
	mov	di,offset TraceTab
	mov	cx,41*26
FdTunelLoop:
	call	Rotates		;Rotate ray vector D = [DirX,DirY,DirZ]

	fld	[DirZ]
	fmul	st,st
	fsubr	[T1]
	fadd	st,st
	fld	[DirX]
	fmul	[OriginX]
	fld	[DirY]
	fmul	[OriginY]
	faddp	st(1),st
	fadd	st,st
	fchs
	fld	[OriginX]
	fmul	st,st
	fld	[OriginY]
	fmul	st,st
	faddp	st(1),st
	fisub	[TR]
	fadd	st,st
	fmul	st,st(2)
	fld	st(1)
	fmul	st,st
	fsubrp	st(1),st
	fsqrt
	faddp	st(1),st
	fdivrp	st(1),st
;--
	fld	[DirY]
	fmul	st,st(1)
	fld	[DirX]
	fmul	st,st(2)
	fld	[DirZ]
	fmul	st,st(3)
	fxch	st(2)
	fadd	[OriginY]
	fxch	st(1)
	fadd	[OriginX]
	fxch	st(2)
	fadd	[OriginZ]	;st=hy  , st1=hx , st2=hz , st3=t
	fxch	st(3)
	fmul	[DepthColor]
	fistp	dword ptr [di+8]

	fpatan
	mov	eax,[di+8]
	cmp	eax,255*256
	jbe	NoFdtOver1
	mov	ax,255*256
NoFdtOver1:
	shr	ax,3
	mov	[di+8],ax
	fmul	[t128pi2]
	fxch	st(1)
	fimul	[T76f8]
	fxch	st(1)
	fistp	dword ptr [di]
	fistp	dword ptr [di+4]
	add	si,12
	add	di,12
	dec	ecx
	jnz	FdTunelLoop
	ret
FdTunel	ENDP
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
Plane1	dd 150.0
Plane2	dd -150.0
TPlanes	dd 126.57142

d05	dd 0.5
d005	dd 0.16
d003	dd 0.18
d07	dd 0.5

FdPlanes	PROC
	mov	di,offset XSine
	mov	cx,41
	fldz
MkXSine:
	fld	st
	fsin
	fmul	[d05]
	fstp	dword ptr [di]
	fadd	[d005]
	add	di,4
	loop	MkXSine
	fstp	st

	mov	di,offset YSine
	mov	cx,26
	fldz
MkYSine:
	fld	st
	fcos
	fmul	[d07]
	fstp	dword ptr [di]
	fadd	[d003]
	add	di,4
	loop	MkYSine
	fstp	st
;-----------------
	mov	si,offset TraceTabSet
	mov	di,offset TraceTab
	mov	cx,26
	mov	bp,offset YSine
FdPlanesLoopY:
	mov	dx,41
	mov	bx,offset XSine
	push	cx
FdPlanesLoopX:
	fld	dword ptr [bx]
	fadd	[anglex]
	fsincos
	fstp	[cosx]
	fstp	[sinx]
	fld	dword ptr [bp]
	fadd	[anglez]
	fsincos
	fstp	[cosz]
	fstp	[sinz]

	call	Rotates		;Rotate ray vector D = [DirX,DirY,DirZ]

	fld	[DirY]
	fdivr	[T1]
	fld	[Plane1]
	fsub	[OriginY]
	fmul	st,st(1)
	fld	[Plane2]
	fsub	[OriginY]
	fmulp	st(2),st
	ftst
	fnstsw	ax
	sahf
	jae	Planes1Hit
	fstp	st
;	xor	cx,cx
	jmp	Planes2Hit
Planes1Hit:
	fxch	st(1)
	fstp	st
;	mov	cx,80000000h
Planes2Hit:
	fld	[DirX]
	fmul	st,st(1)
	fadd	[OriginX]
	fmul	[TPlanes]
	fistp	dword ptr [di]
	fld	[DirZ]
	fmul	st,st(1)
	fadd	[OriginZ]
	fmul	[TPlanes]
	fistp	dword ptr [di+4]

	fmul	[DepthColor]
	fistp	dword ptr [di+8]

	mov	eax,[di+8]
	cmp	eax,255*256
	jbe	NoFdpsOver1
	mov	ax,255*256
NoFdpsOver1:
	shr	ax,3
	mov	[di+8],ax
	add	bx,4
	add	di,12
	add	si,12
	dec	dx
	jnz	FdPlanesLoopX
	pop	cx
	add	bp,4
	loop	FdPlanesLoopY
	ret
FdPlanes	ENDP
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
PA	dd 0.02
T356	dw 356

FdPlane	PROC
	mov	si,offset TraceTabSet
	mov	di,offset TraceTab
	mov	cx,41*26
FdPlaneLoop:
	call	Rotates		;Rotate ray vector D = [DirX,DirY,DirZ]

	fld	[DirY]
	fmul	st,st
	fld	[DirX]
	fmul	st,st
	faddp	st(1),st
	fmul	[PA]
	fadd	st,st
	fld	[DirY]
	fmul	[OriginY]
	fld	[DirX]
	fmul	[OriginX]
	faddp	st(1),st
	fmul	[PA]
	fadd	st,st
	fsubr	[DirZ]
	fld	[OriginY]
	fmul	st,st
	fld	[OriginX]
	fmul	st,st
	faddp	st(1),st
	fmul	[PA]
	fsub	[OriginZ]
	fadd	st,st
	fmul	st,st(2)
	fld	st(1)
	fmul	st,st
	fsubrp	st(1),st
	fsqrt
	fsubp	st(1),st
	fdivrp	st(1),st
;-----------------------------
	fld	[DirX]
	fmul	st,st(1)
	fadd	[OriginX]	
	fld	[DirY]
	fmul	st,st(2)
	fadd	[OriginY]	

	
	ftst
	fmul	st,st
	fld	st
	fmul	[PA]
	fmul	st,st
	faddp	st(1),st
	fsqrt
	fimul	[T356]
	fnstsw	ax
	sahf
	jae	NoPlane1
	fchs
NoPlane1:
	fistp	dword ptr [di+4]

	ftst
	fmul	st,st
	fld	st
	fmul	[PA]
	fmul	st,st
	faddp	st(1),st
	fsqrt
	fimul	[T356]
	fnstsw	ax
	sahf
	jae	NoPlane2
	fchs
NoPlane2:
	fistp	dword ptr [di]
;----------- !!!!!!!- --
	fchs
	fmul	[DepthColor]
	fistp	dword ptr [di+8]
	mov	eax,[di+8]
	cmp	eax,255*256
	jbe	NoFdpOver1
	mov	ax,255*256
NoFdpOver1:
	shr	ax,3
	mov	[di+8],ax

	add	di,12
	add	si,12
	loop	FdPlaneLoop
	ret
FdPlane	ENDP
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
TunelInt1	PROC
	mov	edi,ds:[TabPtr]
	add	edi,TunelBuffer
	mov	si,offset TraceTab
	mov	bp,25
FdDraw3:
	push	bp
	mov	bp,40
FdDraw4:
	mov	cx,[si]
	mov	ax,[si+41*12]
	sub	ax,cx
	mov	dx,[si+4]
	sar	ax,3
	mov	bx,[si+41*12+4]
	sub	bx,dx
	mov	[Du],ax		
	sar	bx,3
	push	bp
	mov	bp,[si+12+4]
	push	si
	mov	ax,[si+12+41*12+4]
	mov	[Dv],bx
	sub	ax,bp
	mov	bx,[si+12+41*12]
	sar	ax,3
	mov	si,[si+12]
	sub	bx,si
	mov	[Dv2],ax
	sar	bx,3
	mov	[Du2],bx
	mov	bx,8
FdDraw5:
	push	si
	push	bp
	sub	bp,dx
	sub	si,cx
	sar	si,3
	push	cx
	sar	bp,3	
	push	dx

	mov	al,ch
	add	cx,si
	mov	ah,dh
	add	dx,bp
	mov	[edi],ax
	mov	al,ch
	mov	ah,dh
	add	cx,si
	mov	[edi+2],ax
	add	dx,bp	
	mov	al,ch
	add	cx,si
	mov	ah,dh
	add	dx,bp
	mov	[edi+4],ax
	mov	al,ch
	mov	ah,dh
	add	cx,si
	mov	[edi+6],ax
	add	dx,bp	

	mov	al,ch
	add	cx,si
	mov	ah,dh
	add	dx,bp
	mov	[edi+8],ax
	mov	al,ch
	mov	ah,dh
	add	cx,si
	mov	[edi+10],ax
	add	dx,bp	
	mov	al,ch
	add	cx,si
	mov	ah,dh
	add	dx,bp
	mov	[edi+12],ax
	mov	al,ch
	mov	ah,dh
	add	cx,si
	mov	[edi+14],ax
	add	dx,bp	

	pop	dx
	pop	cx
	pop	bp
	pop	si
	add	cx,[Du]
	add	dx,[Dv]
	add	si,[Du2]
	add	bp,[Dv2]
	add	edi,320*2
	dec	bx
	jnz	FdDraw5
	pop	si
	pop	bp
	add	si,12
	add	edi,(8-8*320)*2
	dec	bp
	jnz	FdDraw4
	pop	bp
	add	si,12
	add	edi,(7*320)*2
	dec	bp
	jnz	FdDraw3
	ret
TunelInt1	ENDP
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
ColorInt1	PROC
	mov	si,offset TraceTab
	mov	edi,[TabPtr]
	add	edi,TunelBuffer+320*200*2
	mov	bp,25
Color4:
	push	bp
	mov	dx,40
Color5:
	mov	bx,[si+8+41*12]
	mov	cx,[si+8]
	sub	bx,cx
	mov	ax,[si+8+12]
	sar	bx,3
	mov	bp,[si+8+12+41*12]
	sub	bp,ax
	add	si,12
	sar	bp,3
	push	si
	push	dx
	mov	si,8
Color6:
	push	ax
	sub	ax,cx
	sar	ax,3
	push	cx
	mov	dl,ch
	add	cx,ax
	mov	dh,ch
	add	cx,ax
	rol	edx,16
	mov	dl,ch
	add	cx,ax
	mov	dh,ch
	add	cx,ax
	ror	edx,16
	mov	[edi],edx

	mov	dl,ch
	add	cx,ax
	mov	dh,ch
	add	cx,ax
	rol	edx,16
	mov	dl,ch
	add	cx,ax
	mov	dh,ch
	pop	cx
	ror	edx,16
	pop	ax
	mov	[edi+4],edx
	add	cx,bx
	add	edi,320
	add	ax,bp
	dec	si
	jnz	Color6

	add	edi,(8-320*8)
	pop	dx
	pop	si	
	dec	dx
	jnz	Color5

	add	si,12
	add	edi,320*7
	pop	bp
	dec	bp
	jnz	Color4
	ret
ColorInt1	ENDP
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
