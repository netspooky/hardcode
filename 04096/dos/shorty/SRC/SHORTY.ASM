		code	segment
		assume	cs:code; ds:code

Color	EQU	107

.386
		org	100h

main:		mov	al, 13h
		int	10h

		mov	ah, 4ah
		mov	bx, 4096
		int	21h
		jc	@end

		call	getmem
		mov	fs, ax			; BackGround Segment
		mov	BkGnd, ax

		call	getmem
		mov	gs, ax			; Tunnel Texture.
		mov	Texture1Seg, ax 	 ; For Later.. Phongmap..

		call	getmem
		mov	ATab, ax		; ArcTangens Tabel

		call	getmem
		mov	Texture2Seg, ax 	; Glas Phong Map
		mov	es, ax			; ClearScreen.
		xor	di, di
		mov	cx, 32766
		xor	ax, ax
		rep	stosw

		sub	bx, 96
		call	getmem
		mov	STab, ax		; Square Root Tabel

		call	getmem
		mov	bp, ax			; Calculated Tunnel Segment.
		mov	ScrSeg, ax

		mov	es, ax			; ClearScreen.
		xor	di, di
		mov	cx, 32000
		xchg	ax, si
		rep	stosw

		push	cs
		pop	es
cos:		lea	di, cos_tab		; Calculate CoSinus Tabel
		mov	cx, 1023
		mov	ebx, 16776900
		mov	eax, ebx
calc:		stosd
		imul	ebx
		shrd	eax, edx, 23
		sub	eax, es:[di-8]
		loop	calc

		mov	di, OFFSET SqrtTab
		call	calctab 			; precalc sqrt_tab

precalc:	xor	si, si
		mov	bx, 3072
		mov	ch, 4				; cx is nul
@L1:		mov	eax, cos_tabel[bx]
		call	Mult
		add	ax, 100
		or	ax, ax
		js	Nopix
		cmp	ax, 199
		ja	Nopix
		imul	ax, 320
		mov	di, ax
		mov	eax, cos_tabel[si]
		call	Mult
		add	ax, 160
		or	ax, ax
		js	Nopix
		cmp	ax, 319
		ja	Nopix
		add	di, ax
		mov	ax, 12288
		cwd
		cmp	word ptr [S1+3], 47
		ja	eindepijp
		xor	ax, ax
eindepijp:	div	word ptr [S1+3]
		mov	es, STab
		stosb
		dec	di
		mov	ax, cx
		shr	ax, 2
		mov	es, ATab
		stosb
Nopix:		add	bx, 4
		and	bh, 0Fh
		add	si, 4
		loop	@L1
		dec	word ptr [S1+3]
		jnz	precalc

		push	cs
		pop	es
		xor	bx, bx
		mov	di, OFFSET PalBuf
pal:		mov	al, bl
		shr	al, 2
		stosb
		stosb
		mov	al, bl
		shr	al, 1
		stosb
		inc	bl
		jns	pal	       ; door tot 128

		xor	bl, bl
pal2:		mov	al, bl		; zwart -> rood/roze palette gedeelte
		shr	al, 1
		stosb
		mov	al, bl
		shr	al, 3
		stosb
		stosb
		add	bl, 2
		jns	pal2		; door tot 128

		xor	bl, bl
pal3:		mov	al, 63		; rood/roze -> wit palette gedeelte
		stosb
		mov	al, bl
		shr	al, 2
		add	al, 16
		stosb
		stosb
		add	bl, 2
		jns	pal3		; door tot 128

		push	fs
		pop	es
		xor	di, di
		mov	cx, 320
		mov	al, Color			; starting value
		rep	stosb

		mov	ch, 0F9h			; dit is (64000-320)/256
		call	background
		add	word ptr [ck3+3], 64		; ck3+3 is hierna -256 !!

		push	gs
		pop	es
		xor	di, di
		xor	al, al
		mov	ch, 128 			; cx = 32768 CX
		rep	stosb

		mov	ch, 1				; cx = 256
		mov	al, 100 			; starting value
		rep	stosb
		mov	ch,127
		call	background

		call	SetTimer

		mov	dh, 255
		mov	max, 255
		mov	ds, STab

		mov	palc, 0

@NoKey: 	cmp	palc, 63
		jns	@nodec3
		inc	palc
		mov	col, 0
		call	setpal
@nodec3:
		mov	di, 63999
@loopje:	mov	al, ds:[di]		; STab
		cmp	al, dh
		jbe	@NP
		cmp	al, Max
		ja	@NP
		mov	bl, al
		sub	bl, dl
		shl	bx, 4
		and	bh, 0Fh
		mov	ebx, cs:[Cos_tabel+bx]
		sar	ebx, 19

		mov	es, ATab
		mov	ah, es:[di]
		add	al, dl			; diepte positie.
		add	ah, bl			; hoek positie.

		xchg	ax, bx
		mov	al, gs:[bx]
		or	al, al
		jz	@NP
		mov	es, bp
		mov	es:[di],al
@NP:		dec	di
		jnz	@loopje

		dec	dl

		call	DoBitMap

		push	0a000h
		pop	es
		push	ds
		mov	ds, bp
		mov	ch, 7Dh
@L2:		mov	ax, ds:[di]		; Tunnel Color
		mov	bx, fs:[di]		; BackGround Color.
		mov	ds:[di], bx
		stosw
		loop	@l2
		pop	ds

		or	dh, dh
		jz	@NoDec
		dec	dh
		jmp	@NoDec2
@NoDec: 	or	max, 0
		jz	@NextEvent
		dec	max
@NoDec2:	in	al, 60h
		cmp	al, 1
		jne	@NoKey	      ; cx is hier nul

@NextEvent:	mov	palc, 0
		push	cs
		pop	ds
		mov	es, Texture1Seg       ; Saves Memory. Was Tunnel Texture
		mov	Temp, es
		xor	ax, ax
		call	MakePhongPiccy	     ; Calculate Environment Map
		call	CalcPlan	     ; Calculate connection table

		mov	di, OFFSET Point1
		call	calcbol
		mov	di, OFFSET Point2
		call	calcbol
		mov	di, OFFSET Point3
		call	calcbol
		mov	di, OFFSET Point4
		call	calcbol

		push	cs
		push	cs
		pop	es
		pop	ds

		mov	pointoffset, OFFSET point1
		mov	NormalOffset, OFFSET norms1
		call	MakeNorms
		mov	pointoffset, OFFSET point2
		mov	NormalOffset, OFFSET norms2
		call	MakeNorms
		mov	pointoffset, OFFSET point3
		mov	NormalOffset, OFFSET norms3
		call	MakeNorms
		mov	pointoffset, OFFSET point4
		mov	NormalOffset, OFFSET norms4
		call	MakeNorms

		mov	glas, 0
		mov	timer, 0

@Nokey2:	cmp	palc, 63
		jns	@nodec4
		add	palc, 4
		mov	col, 63
		call	setpal
@nodec4:
		mov	ax, timer
		shl	ax, 1
		mov	rot,ax
		or	glas, 0
		jnz	@NoGlasMap
		cmp	rot, 3000
		js	@NoGlasMap
		mov	glas, 1
		mov	palc, 0
		call	makeglasmap
		mov	ax, Texture1Seg
		mov	bx, Texture2Seg
		mov	Texture2Seg, ax
		mov	Texture1Seg, bx
		mov	col, 63
		call	setpal
@NoGlasMap:	cmp	rot, 6000
		jns	@nextevent2

		call	DoFrame

		push	0a000h
		pop	es
		xor	di, di
		push	ds
		mov	ds, ScrSeg
		mov	fs, BkGnd
		mov	cx, 32000
@tosc:		mov	ax, ds:[di]
		mov	bx, fs:[di]
		mov	ds:[di], bx
		stosw
		dec	cx
		jnz	@tosc
		pop	ds

		in	al, 60h
		cmp	al, 1
		jne	@NoKey2        ; cx is hier nul
		jmp	@nextevent3

@nextevent2:	mov	glas, 0
		mov	palc, 0

		mov	es, ScrSeg
		xor	di, di
		mov	ax, 33153
		mov	cx, 32000
		rep	stosw

		mov	ax, Texture1Seg
		mov	bx, Texture2Seg
		mov	Texture2Seg, ax
		mov	Texture1Seg, bx

		push	cs
		pop	ds
		mov	ax, Texture2Seg
		mov	es, ax
		xor	di, di
		mov	cx, 16384
		xor	eax, eax
		rep	stosd

		mov	ax, Temp
		mov	Texture1Seg, ax


@Nokey3:	cmp	rot, 9000
		jns	@nodec5
		cmp	palc, 63
		jns	@nodec5
		add	palc, 4
		mov	col, 63
		call	setpal
@nodec5:
		mov	ax, timer
		shl	ax, 1
		mov	rot,ax
		cmp	rot, 9000
		js	@nodec6
		call	setpal
		sub	palc, 4
		js	@Nextevent3
@nodec6:

		call	DoFrame
		call	DoBlur

		in	al, 60h
		cmp	al, 1
		jne	@NoKey3

@nextevent3:	push	cs
		pop	es
		mov	di, OFFSET PalBuf
		mov	al, 63
		mov	cx, 768
		rep	stosb
		mov	palc, 63
@again: 	dec	palc
		jz	@end
		mov	col, 0
		call	setpal
		jmp	@again

@end:		mov	ax, 3
		int	10h

		call	resettimer

		push	cs
		pop	ds
		mov	dx, OFFSET author
		mov	ah, 9
		int	21h
		push	cs
		pop	es
		mov	ax, 4C00h
		int	21h
		ret

;********EINDE MAIN PROGRAMMA*****************

;***********PROCEDURES HIERONDER**************
Mult:		sar	eax, 10
S1:		imul	eax, 768			; selfmodifying
		sar	eax, 16
		ret


getmem: 	mov	ah, 48h
		int	21h
		jc	@end
		ret

BackGround:	mov	ax, 130bh
Ck1:		imul	ax, 1111h
		mov	word ptr [Ck1+2], ax		; selfmodifying code
		mov	bl,5
		cwd
		idiv	bx
		mov	al, dl
		xor	dx, dx
Ck3:		mov	dl, es:[di-320]
Ck2:		add	dx, Color
		shr	dx, 1
		add	al, dl
		jns	NoBelowNul
		xor	al, al
NoBelowNul:	mov	byte ptr [Ck2+2], al		 ; selfmodifying code
		mov	byte ptr [Background+2], al	 ; selfmodifying code
		stosb
		Loop	background
		ret

DoBlur: 	push	0a000h
		pop	es
		xor	di, di
		push	ds
		mov	ds, ScrSeg
		mov	cx, 32000
@blur:		mov	ax, ds:[di]
		cmp	al, 131
		jbe	 NoDecAL
		sub	al, 2
NoDecAL:	cmp	ah, 131
		jbe	 NoDecAH
		sub	ah, 2
NoDecAH:	mov	ds:[di], ax
		stosw
		dec	cx
		jnz	@blur
		pop	ds
		ret

setpal: 	pusha
		push	ds
		push	si
		mov	dx,3DAh
@@Wait:
		in	al, dx
		and	al, 08h
		jz	@@Wait
@@Retr:
		in	al,dx
		and	al,08h
		jnz	@@Retr

		push	cs
		pop	ds
		mov	si, OFFSET palbuf
		mov	dl, 0C8h
		xor	al, al
		out	dx, al
		inc	dx
		mov	bx, 768
@PL:		xor	ah, ah
		lodsb
		mul	palc
		mov	cx, 64
		sub	cx, palc
		imul	cx, col
		add	ax, cx
		shr	ax, 6

		mov	dx, 03C9h
		out	dx, al
		dec	bx
		jnz	@PL

		pop	si
		pop	ds
		popa
		ret

makeglasmap:	mov	es, Texture2Seg
		mov	ds, Texture1Seg
		mov	cx, 32766
		xor	di, di
		xor	bx, bx
@DoIt:		mov	ax, ds:[di]
		sub	al, 128
		sub	ah, 128
		mov	bl, al
		mov	al, cs:[remap.bx]
		mov	bl, ah
		mov	ah, cs:[remap.bx]
		stosw			    ; 0..63
		loop	@DoIt

		mov	ds, BkGnd
		mov	es, ATab
		mov	Texture1Seg, es
		xor	di, di
		mov	si, 32
		mov	dx, 200
@Ylo:		mov	cx, 256
@Xlo:		lodsb
		shr	al, 1
		add	al, 128
		stosb
		loop	@Xlo
		add	si, 64
		dec	dx
		jnz	@Ylo
		push	cs
		push	cs
		pop	ds
		pop	es
		ret

DoFrame:	mov	ax, rot
		and	ax, 3ffh
		movzx	esi, al
		cmp	ah, 0
		jne	Not_in_0
		  mov	  interofs1, OFFSET point2
		  mov	  interofs2, OFFSET point1
Not_in_0:	cmp	ah, 1
		jne	Not_in_1
		  mov	  interofs1, OFFSET point3
		  mov	  interofs2, OFFSET point2
Not_in_1:	cmp	ah, 2
		jne	Not_in_2
		  mov	  interofs1, OFFSET point4
		  mov	  interofs2, OFFSET point3
Not_in_2:	cmp	ah, 3
		jne	Not_in_3
		  mov	  interofs1, OFFSET point1
		  mov	  interofs2, OFFSET point4
Not_in_3:
		call	interpolate
		call	InitializeRotMatrix
		mov	si, OFFSET Points
		mov	bp, OFFSET RPoints
		mov	cx, 384*2
		call	Rotatem
		mov	si, OFFSET Rpoints
		mov	cx, 384
		call	Add_Perspectief
		call	Rsort
		call	DoManyTexture
		call	DoBitMap
		ret


DoBitMap:	pusha
		push	ds
		push	cs
		pop	ds
		mov	si, OFFSET Bitmap
		mov	es, ScrSeg
		mov	di, 61721
		mov	dl, 5
	@Ylb:	mov	dh, 35
	@Xlb:	lodsb
		or	al, al
		jz	@Nopixel
		mov	byte ptr es:[di], 255
      @nopixel: inc	di
		dec	dh
		jnz	@Xlb
		add	di, 285
		dec	dl
		jnz	@Ylb
		pop	ds
		popa
		ret

settimer:	mov	timer, 0
		cli
		mov	ax, 351Ch
		int	21h
		mov	word ptr cs:[Old1C.0], es
		mov	word ptr cs:[Old1C.2], bx
		push	cs
		pop	ds
		mov	dx, OFFSET Int1C
		mov	ax, 251Ch
		int	21h
		mov	al, 36h
		out	043h, al
		mov	ax, 16384
		out	040h, al
		mov	al, ah
		out	040h, al
		sti
		ret

resettimer:	mov	timer, 0
		cli
		mov	ds, word ptr cs:[old1C.0]
		mov	dx, word ptr cs:[old1c.2]
		mov	ax, 251Ch
		int	21h
		mov	al, 36h
		out	043h, al
		xor	ax, ax
		out	040h, al
		out	040h, al
		sti
		ret

Int1C:		push	ax
		inc	timer
		mov	al, 20h
		out	20h, al
		pop	ax
		IRET


include dtext.inc		; texturemap routine.
include radix.inc		; radix sorteer routine.
include sqrt.inc		; Square Root Table creator.
include phong.inc		; Calculate PhongMap. 127..256...  to es:ax
include rotate.inc		; Rotate Routine
include bol.inc 		; Sphere Calculate + Connection map
include normals.inc		; Normal routines.


author	  db '(C)1996 The Russian/ThE ClaN',0Dh,0Ah,'$'
bitmap	  db 0,0,1,0,0,0,0,1,1,0,1,0,1,0,0,1,0,0,1,1,0,0,1,1,1,0,1,0,1,0,0,0,1,0,0
	  db 0,1,1,1,0,0,1,0,0,0,1,0,1,0,1,0,1,0,1,0,1,0,0,1,0,0,1,0,1,0,0,1,1,1,0
	  db 1,1,1,1,1,0,0,1,0,0,1,1,1,0,1,0,1,0,1,1,0,0,0,1,0,0,0,1,0,0,1,1,1,1,1
	  db 0,1,1,1,0,0,0,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,0,1,0,0,0,1,0,0,0,1,1,1,0
	  db 0,0,1,0,0,0,1,1,0,0,1,0,1,0,0,1,0,0,1,0,1,0,0,1,0,0,0,1,0,0,0,0,1,0,0
include   remap.db

cos_tabel dd 16777216			; cos(0*PI/512)
cos_tab   dd 1023 dup(?)		; cos(2..1024)
SqrtTab   dw 257 dup(?) 		; sqrt(0..4gig)
palbuf	  db 768 dup(?) 		; palette.
Old1C	  dd ?
palc	  dw ?
col	  dw ?

point1	  dw 384*3 dup (?)		; object 1 points
norms1	  dw 384*3 dup (?)		; object 1 vertex normals
point2	  dw 384*3 dup (?)		; object 2 points
norms2	  dw 384*3 dup (?)		; object 2 vertex normals
point3	  dw 384*3 dup (?)		; object 3 points
norms3	  dw 384*3 dup (?)		; object 3 vertex normals
point4	  dw 384*3 dup (?)		; object 4 points
norms4	  dw 384*3 dup (?)		; object 4 vertex normals

plan	    dw 750*3 dup (?)		  ; connection tabel.
points	    dw 384*3 dup (?)		  ; original 3D Points X,Y,Z
vertnorm    dw 384*3 dup (?)		  ; original vertex normals.
rpoints     dw 384*3 dup (?)		  ; rotated 3D Points X,Y,Z
rnormals    dw 384*3 dup (?)		  ; rotated Vertex Normals.
polynormals dw 750*3 dup (?)		  ; Polynormals.

max	  db ?
glas	  db ?
timer	  dw ?
interofs1 dw ?
interofs2 dw ?
ATab	  dw ?				; Arctangens Tabel
STab	  dw ?				; Square Root Tabel
BkGnd	  dw ?				; BackGround Picture Seg.
Temp	  dw ?				; To Store for Blur..
Temp2	  dw ?				; Dump Segment.


;****** POLYGOON ROUTINES VARIABLEN **********************

 Links	    db ?			; [si-62]

 X1r	    dd ?			; [si-58]
 X2r	    dd ?			; [si-54]
 X3r	    dd ?			; [si-50]
 X4r	    dd ?			; [si-46]

 Tx2r	    dd ?			; [si-42]
 Ty2r	    dd ?			; [si-38]
 Dx2r	    dd ?			; [si-34]
 Dy2r	    dd ?			; [si-30]
 Txt1	    dd ?			; [si-26]
 Tyt1	    dd ?			; [si-22]
 Dxt1	    dd ?			; [si-18]
 Dyt1	    dd ?			; [si-14]
 Xt1	    dd ?			; [si-10]
 Xt2	    dd ?			; [si-6]

 X4	    dw ?			; [si-4]
 X1	    dw ?			; [si-2]
 X2	    dw ?			; si
 X3	    dw ?			; di

 Y1	    dw ?			; [si+4]
 Y2	    dw ?			; [si+6]
 Y3	    dw ?			; [si+8]

 Tx1	    dw ?			; [si+10]
 Tx2	    dw ?			; [si+12]
 Tx3	    dw ?			; [si+14]

 Ty1	    dw ?			; [si+16]
 Ty2	    dw ?			; [si+18]
 Ty3	    dw ?			; [si+20]

 Dx1	    dw ?			; [si+22]
 Dx2	    dw ?			; [si+24]
 Dx3	    dw ?			; [si+26]

 Dy1	    dw ?			; [si+28]
 Dy2	    dw ?			; [si+30]
 Dy3	    dw ?			; [si+32]

 Tx4	    dw ?			; [si+34]
 Ty4	    dw ?			; [si+36]
 Dx4	    dw ?			; [si+38]
 Dy4	    dw ?			; [si+40]

 scrseg     dw ?			; [si+42]
 texture1seg dw ?			; [si+44]
 texture2seg dw ?			; [si+46]
 flag3	    db ?			; [si+48]

; ******* RADIX SORTEER VARIABLEN *************

AantalH dw 256 dup(?);
AantalL dw 256 dup(?);
Lijst	dw 750 dup(?);
Lijst2	dw 750 dup(?);
PntsH	dw 256 dup(?);
PntsL	dw 256 dup(?);
Sorted	dw 750 dup(?);
SortedL dw 750 dup(?);
SortedN dw 750 dup(?)

; ********** ROTATE ROUTINE VARIABLEN ***********
rot		dw ?

SinX		DD ?
SinY		DD ?
SinZ		DD ?
CosX		DD ?
CosY		DD ?
CosZ		DD ?

M11   DD ?
M12   DD ?
M13   DD ?
M21   DD ?
M22   DD ?
M23   DD ?
M31   DD ?
M32   DD ?
M33   DD ?		     ; Rotation Matrix

;*************** BOL.INC VARS *****************
a	dw ?
b	dw ?
r	dd ?
ctc	dd ?
sts	dd ?
cpc	dd ?
sps	dd ?

;************ NORMALS.INC **************

vert1		dw ?
vert2		dw ?
vert3		dw ?
dest		dw ?
V1		dd 3 dup (?)
V2		dd 3 dup (?)
V3		dd 3 dup (?)
D		dd 3 dup (?)
normalshifter	db ?
makenormscounter dw ?

normaloffset	dw ?
pointoffset	dw ?
normalbuffer	dd 1800 dup (?)


code	ENDS
END	main
