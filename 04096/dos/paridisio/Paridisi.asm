.model tiny
.386

.DATA
;System-stuff
oldtimeroffs		dw	?
oldtimerseg		dw	?

;Global stuff
buffer			dw	?
framecounter		dw	0
framecounter2		dw	-140
tempint			dw	?
tempreal		dd	?
x			dw	?
y			dw	?
fx			dd	?
fy			dd	?
rndseed			dd	1;3713942343
rndseed2		dd	1;81363361
x1			dw	?
y1			dw	?
x2			dw	?
y2			dw	?
midx			dw	?
midy			dw	?
deltax			dw	?
deltay			dw	?
ftextrandom		dd	?
ftextmask		dw	255
c1			db	?
c2			db	?
c3			db	?
c4			db	?
col1			dw	?
col2			dw	?
col3			dw	?
col4			dw	?
palette			dd	0.0,0.0,0.0, 64.0,64.0,64.0, 64.0,0.0,64.0, 0.0,64.0,0.0, 0.0,0.0,64.0
paletter		dd	?
paletteg		dd	?
paletteb		dd	?
paletterk		dd	?
palettegk		dd	?
palettebk		dd	?

;Flare-effect
flaremap		dw	?
flarex			dw	?
flarey			dw	?
color			dw	?
flaremul		dd	1.0
dotmul			dd	0.0

;Planet-effect
planetsize		dd	?
planetx			dd	0
planety			dd	0
nx			dd	?
ny			dd	?
nz			dd	?
lightx			dd	?;0.5
lighty			dd	?;0.0
lightz			dd	?;-0.866
planetshade		dd	?
planetbumpmap		dw	?
planetrandom		dd	14.0
slopex			dw	?
slopey			dw	?
bumpheight		dd	0.01
highlight		dd	50.0
slope1			dw	?
slope2			dw	?
slope3			dw	?
slope4			dw	?
b1			dw	?
b2			dw	?
b3			dw	?
b4			dw	?
b5			dw	?
b6			dw	?
b7			dw	?
b8			dw	?
b9			dw	?
b10			dw	?
b11			dw	?
b12			dw	?
txd1			dw	?
txd2			dw	?
txd3			dw	?
txd4			dw	?
txd			dd	?
tyd1			dw	?
tyd2			dw	?
tyd3			dw	?
tyd4			dw	?
tyd			dd	?
jumpflag		db	0
planetxconst		dd	1.01
planetyconst		dd	1.005

;Recurse-effect
recursemap		dw	?
zoom			dd	0.99;1.1;5;0.95
angle			dd	0.0;5
originx			dd	0.0
originy			dd	0.0
ktx1			dd	?
kty1			dd	?
ktx2			dd	?
kty2			dd	?
tx1b			dd	?
ty1b			dd	?
tx1c			dd	?
ty1c			dd	?
tx			dd	?
ty			dd	?
tx1			dd	?
ty1			dd	?
textx1			dw	?
texty1			dw	?
textx2			dw	?
texty2			dw	?
textfx			dd	?
textfy			dd	?
text1fx			dd	?
text1fy			dd	?
color1			dw	?
color2			dw	?
color3			dw	?
color4			dw	?
colorsub		dw	0

;Constants
FLARECONST		dd	-0.00005
CONST65536		dd	65536.0
CONST255		dd	255.0
CONST64			dd	64.0
CONST63			dd	63.0
CONST9			dd	9.0
CONST5			dd	5.0
CONST3			dd	3.0
CONST1_5		dd	2.0
CONST0_5		dd	0.5
CONST1_O_256		dd	?
ROTSPEED1		dd	0.057
ROTSPEED2		dd	-0.036
ROTSPEED3		dd	0.076
ROTSPEED4		dd	0.0013
PULSARCONST		dd	0.017
PULSARCONST2		dd	1.3
MOVECONST1		dd	0.01
MOVECONST2		dd	0.013
MOVECONST3		dd	100.0
MOVECONST4		dd	60.0
FLAREAPPEARSPEED	dd	0.004
FLAREAPPEARINV		=	250
PLANETSIZESPEED		dd	0.003
NO_DOT			=	586	;Kiva maaginen luku by Hyu
CONSTNAMEFLARE		dd	0.5
CONSTNAMEFLARE2		dd	0.79

PART1LENGHT		=	1150
PART2LENGHT		=	250
PART3LENGHT		=	3000
PART4LENGHT		=	3500
PART5LENGHT		=	1050
PART6LENGHT		=	400

;Name
font			dw	?
namelenght		db	9
introname		db	"Paridisio"
namedot			dw	?
nameflare		dw	?
nameflaresize		dw	25;11
nameflaresize2		dw	13;5

endstring		db	"Paridisio  -  4kB-intro for Assembly'01 by Itchi / Lonely Coders$"

.CODE
org 100h

start:
	mov	cs:[datasegment],ds
	jmp	main
datasegment		dw	?



;********************
; Makepalettevalues *
;********************
makepalettevalues:
	pusha

	lea	bx,palette
	add	bx,12
	mov	cx,24
palettesetloop:
	fild	framecounter
	mov	tempint,cx
	fiadd	tempint
	add	tempint,10
	fimul	tempint
	fmul	ROTSPEED1
	fmul	ROTSPEED3
	fmul	ROTSPEED1
	;fmul	CONST0_5
	;fmul	CONST0_5
	;fmul	CONST0_5
	;fmul	CONST0_5
	fcos
	mov	tempint,31
	fimul	tempint
	mov	tempint,32
	fild	tempint
	fadd
	fstp	tempreal
	mov	eax,tempreal
	mov	[bx],eax
	add	bx,4
	dec	cx
	loop	palettesetloop

	popa
ret



;**************
; Makepalette *
;**************
makepalette:
	pusha


	mov	dx,3C8h
	mov	ax,0
	out	dx,al
	inc	dx
	lea	bx,palette
	mov	ch,4
paletteloop:
	mov	eax,[bx]
	mov	paletter,eax

	mov	eax,[bx+4]
	mov	paletteg,eax

	mov	eax,[bx+8]
	mov	paletteb,eax
	add	bx,12


	mov	eax,[bx]
	mov	tempreal,eax
	fld	tempreal
	fsub	paletter
	fdiv	CONST64
	fstp	paletterk

	mov	eax,[bx+4]
	mov	tempreal,eax
	fld	tempreal
	fsub	paletteg
	fdiv	CONST64
	fstp	palettegk

	mov	eax,[bx+8]
	mov	tempreal,eax
	fld	tempreal
	fsub	paletteb
	fdiv	CONST64
	fstp	palettebk
	;add	bx,12

	mov	cl,64
paletteloopinner:
	fld	paletter
	fistp	tempint
	mov	ax,tempint
	out	dx,al

	fld	paletteg
	fistp	tempint
	mov	ax,tempint
	out	dx,al

	fld	paletteb
	fistp	tempint
	mov	ax,tempint
	out	dx,al


	fld	paletter
	fadd	paletterk
	fstp	paletter

	fld	paletteg
	fadd	palettegk
	fstp	paletteg

	fld	paletteb
	fadd	palettebk
	fstp	paletteb
	
	dec	cl
	jnz	paletteloopinner
	dec	ch
	jnz	paletteloop
	
	popa
ret
makepalette2:
	pusha


	mov	dx,3C8h
	mov	ax,0;
	out	dx,al
	inc	dx
	mov	cx,64
paletteloop1:
	out	dx,al
	out	dx,al
	out	dx,al
	inc	al
	loop	paletteloop1

	mov	cx,64
	mov	bl,63
paletteloop2:
	mov	al,63
	out	dx,al
	mov	al,bl
	out	dx,al
	dec	bl
	out	dx,al
	loop	paletteloop2

	mov	cx,64
	mov	bl,63
	mov	bh,0
paletteloop3:
	mov	al,bl
	out	dx,al
	mov	al,bh
	out	dx,al
	mov	al,0
	out	dx,al
	dec	bl
	inc	bh
	loop	paletteloop3

	mov	cx,64
	mov	bl,63
	mov	bh,0
paletteloop4:
	mov	al,0
	out	dx,al
	mov	al,bl
	out	dx,al
	mov	al,bh
	out	dx,al
	dec	bl
	inc	bh
	loop	paletteloop4


	popa
ret



;*************
; Initialize *
;*************
initialize:
	pusha


	mov	ax, 13h
	int	10h
	finit

	mov	ax,cs
	add	ax,1000h
	mov	buffer,ax
	add	ax,1000h
	mov	flaremap,ax
	add	ax,1000h
	mov	recursemap,ax
	add	ax,1000h
	mov	planetbumpmap,ax
	add	ax,1000h
	mov	font,ax
	add	ax,1024
	mov	namedot,ax
	add	ax,144
	mov	nameflare,ax
	add	ax,6
	;mov	namedoty,ax
	;add	ax,36

	push	buffer
	pop	es
	xor	di,di
	xor	ax,ax
	mov	cx,32768
	rep	stosw

	push	recursemap
	pop	es
	xor	di,di
	xor	ax,ax
	mov	cx,32768
	rep	stosw

	push	planetbumpmap
	pop	es
	xor	di,di
	xor	ax,ax
	mov	cx,32768
	rep	stosw

	call	readfont
	call	initname

	call	inittextures

	popa
ret



;************
;* Readfont *
;************
;char *merkit=(char *)0xFFA6E;
;
;void readfonts(void){
;  short i,x,y,offs1,offs2;
;  char color;
;  char mask;
;  for (i=0;i<256;i++){
;    for (y=0;y<8;y++){
;      mask=128;
;      for (x=0;x<8;x++){
;        offs1=i*8+y;
;        color=((merkit[offs1]&mask)>0?1:0);
;        offs2=y*8+x;
;        font[i][offs2]=color;
;        mask>>=1;
;      }
;    }
;  }
;}
readfont:
        pusha
        push fs
        push es


        mov ax,0FFA6h
        mov fs,ax
        mov si,0000Eh
        mov ax,font
        mov es,ax
        xor di,di

        mov dx,256
        ;xor dl,dl
fontiloop:
        mov ch,8
fontyloop:
        mov cl,8
fontxloop:
        mov al,fs:[si]
        shr al,cl
        and al,1
        stosb
        dec cl
        jnz fontxloop
        inc si
        dec ch
        jnz fontyloop
        dec dx
        ;dec dl
        jnz fontiloop
        

        pop es
        pop fs
        popa
ret



;************
;* Initname *
;************
initname:
	push	es
	push	fs
	push	gs


	push	namedot
	pop	es
        push	font
        pop	fs

	mov	tempint,0
	lea	bx,introname

	xor	di,di
	mov	dl,namelenght
nameloop:
	mov	al,[bx]
	xor	ah,ah
	shl	ax,6
	mov	si,ax

	mov	ch,8
nameyloop:
	mov	cl,8
namexloop:
	mov	ah,fs:[si]

	mov	x,NO_DOT
	mov	y,0
	push	ax
	test	ah,1
	jz	storename

	;mov	x,bx
	mov	ax,tempint
	mov	x,ax
	shl	x,3
	shl	ax,3
	mov	ax,8
	sub	al,cl
	add	x,ax
	sub	x,36
	sal	x,2

	mov	ax,8
	sub	al,ch
	sub	ax,4
	sal	ax,2
	mov	y,ax
	
storename:
	mov	ax,x
	mov	es:[di],ax
	mov	ax,y
	mov	es:[di+2],ax
	pop	ax

	;shl	ah,7
	;mov	es:[di],ah
	;inc	di
	add	di,4
	inc	si
	
	dec	cl
	jnz	namexloop
	;add	di,(256-8)

	dec	ch
	jnz	nameyloop
	;add	di,8
	;sub	di,256*8
	;add	di,10

	inc	bx
	inc	tempint
	dec	dl
	jnz	nameloop



	pop	gs
	pop	fs
	pop	es
ret



;***********
;* Retrace *
;***********
retrace:
	push    dx
	push    ax


;        mov dx,3C8h
;        mov al,0
;        out dx,al
;        inc dx
;        out dx,al
;        out dx,al
;        out dx,al

	mov     dx,3dah
delay_l1:
	in      al,dx
	test    al,8
	jne     delay_l1
delay_l2:
	in      al,dx
	test    al,8
	je      delay_l2

;        mov dx,3C8h
;        mov al,0
;        out dx,al
;        inc dx
;        mov al,63
;        out dx,al
;        mov al,0
;        out dx,al
;        out dx,al


	pop     ax
	pop     dx
ret



;**************
;* rendername *
;**************
rendername:
	pusha
	push	es
	push	fs


	push	buffer
	pop	es
	xor	di,di
	xor	ax,ax
	mov	cx,32768
	rep	stosw

	push	buffer
	pop	es
	push	namedot
	pop	fs

	xor	si,si
	mov	cx,576
namerenderloop:
	mov	ax,fs:[si]
	cmp	ax,NO_DOT
	jz	dontrendername
	mov	x,ax
	mov	bx,fs:[si+2]
	mov	y,bx
	call	rendernameflare

dontrendername:
	add	si,4
	dec	cx
	jnz	namerenderloop

	pop	fs
	pop	es
	popa
ret



;*******************
;* rendernameflare *
;*******************
rendernameflare:
	pusha
	push	di

	cmp	framecounter,985
	js	nameflarepoint1
	mov	framecounter,985
nameflarepoint1:

	fild	framecounter
	fmul	ROTSPEED1
	mov	tempint,cx
	fiadd	tempint
	fsin
	mov	tempint,1000
	fild	tempint
	fisub	framecounter
	mov	tempint,10
	fidiv	tempint
	fmul
	fld1
	fadd
	fiadd	x
	fistp	x

	fild	framecounter
	fmul	ROTSPEED2
	mov	tempint,cx
	fild	tempint
	fmul	CONSTNAMEFLARE2
	fadd
	fcos
	mov	tempint,1000
	fild	tempint
	fisub	framecounter
	mov	tempint,10
	fidiv	tempint
	fmul
	fld1
	fadd
	fiadd	y
	fistp	y

	fild	framecounter
	fmul	CONST0_5
	fmul	CONST0_5
	fmul	CONST0_5
	fmul	CONST0_5
	fistp	color
	cmp	color,63
	js	nonameflaretopclip
	mov	color,63
nonameflaretopclip:

	;fild	y
	;mov	tempint,1000
	;fild	tempint
	;fimul	tempint
	;fidiv	framecounter
	;fidiv	framecounter
	;fidiv	framecounter
	;fld1
	;fadd	CONSTNAMEFLARE
	;fmul
	;fistp	y
	
	add	x,160
	add	y,100

	mov	bx,y
	mov	ax,x

	mov	dx,bx
	shl	bx,8
	shl	dx,6
	add	bx,dx
	add	bx,ax
	mov	al,255
	;mov	es:[bx],al
	;mov	ax,x
	;mov	flarex,ax
	;mov	ax,y
	;mov	flarey,ax
	;call	renderdot2
	;mov	ax,y
	;shl	ax,8
	;shl	y,6
	;add	ax,y
	;add	ax,x
	;add	ax,128
	;mov	tempint,bx
	;xor	ax,ax

	mov	tempint,40
	fild	tempint
	fild	framecounter
	fmul	ROTSPEED1
	fmul	CONST0_5
	fchs
	fadd
	;mov	tempint,9
	;fild	tempint
	fist	nameflaresize
	fistp	nameflaresize2
	shr	nameflaresize2,1

	mov	di,bx
	;mov	dx,15
	mov	dx,nameflaresize
nameflareyloop:
	;mov	cx,15
	mov	cx,nameflaresize
nameflarexloop:
	mov	tempint,cx
	;sub	tempint,7
	fild	tempint
	fisub	nameflaresize2
	fld	st(0)
	fmul
	;fimul	tempint
	mov	tempint,dx
	;sub	tempint,7
	fild	tempint
	fisub	nameflaresize2
	fld	st(0)
	fmul
	;fimul	tempint
	fadd
	fsqrt
	fchs
	;mov	tempint,7
	;fiadd	tempint
	fiadd	nameflaresize2
	fidiv	nameflaresize2
	;fmul	;dotmul
	;mov	tempint,63
	fimul	color
	fistp	tempint
	mov	ax,tempint
	cmp	ax,0
	jns	nameflarenozero
	mov	ax,0
nameflarenozero:
	;mov	bl,es:[di]
	;add	al,bl
	add	al,es:[di]
	jnc	nameflarenoclip
	mov	al,255
nameflarenoclip:
	stosb
	;inc	al
	loop	nameflarexloop
	;add	di,320-9
	add	di,320
	sub	di,nameflaresize

	dec	dx
	jnz	nameflareyloop

	pop	di
	popa
ret



;*************
;* renderdot *
;*************
renderdot:
	pusha
	push	es


	push	buffer
	pop	es

	cmp	framecounter,FLAREAPPEARINV
	ja	dotnofadein

	fild	framecounter
	fmul	FLAREAPPEARSPEED
	fstp	dotmul
dotnofadein:


	fild	framecounter
	fmul	MOVECONST1
	fcos
	fmul	MOVECONST3
	fistp	flarex
	fild	framecounter
	fmul	MOVECONST2
	fsin
	fmul	MOVECONST4
	fistp	flarey

	mov	ax,flarey
	mov	y,ax
	mov	ax,flarex
	mov	x,ax
	add	y,68

	call	renderdot2
	jmp	rendereddot
renderdot2:
	mov	ax,y
	shl	ax,8
	shl	y,6
	add	ax,y
	add	ax,x
	add	ax,128
	mov	tempint,ax

	xor	ax,ax

	
	mov	di,tempint
	mov	dx,64
dotyloop:
	mov	cx,64
dotxloop:
	mov	tempint,cx
	sub	tempint,32
	fild	tempint
	fimul	tempint
	mov	tempint,dx
	sub	tempint,32
	fild	tempint
	fimul	tempint
	fadd
	fsqrt
	fchs
	mov	tempint,32
	fiadd	tempint
	fmul	dotmul
	fistp	tempint
	mov	ax,tempint
	cmp	ax,0
	jns	dotnozero
	mov	ax,0
dotnozero:
	;mov	bl,es:[di]
	;add	al,bl
	add	al,es:[di]
	jnc	dotnoclip
	mov	al,255
dotnoclip:
	stosb
	;inc	al
	loop	dotxloop
	add	di,256

	dec	dx
	jnz	dotyloop
	ret

rendereddot:
	pop es
	popa
ret



;***************
;* renderflare *
;***************
renderflare:
	pusha
	push	es


	push	flaremap
	pop	es

	cmp	framecounter,FLAREAPPEARINV
	ja	flarenofadein

	fild	framecounter
	fmul	FLAREAPPEARSPEED
	fstp	flaremul
flarenofadein:

	xor	di,di
	mov	y,-100
	mov	dx,200
flareyloop:
	mov	x,-160
	mov	cx,320
flarexloop:
	fild	y
	fld	st(0)
	fmulp
	fild	x
	fld	st(0)
	fmulp
	faddp
	fmul	FLARECONST

	;st(0) = expmul
	fild	x
	fild	y
	fpatan
	fld	st(0)
	;fld	st(0)
	;st(0),st(1),st(2) = atan     st(3) = expmul

	fmul	CONST5
	fild	framecounter
	fmul	ROTSPEED1
	fadd
	fsin
	fadd	CONST1_5
	fxch;	st(1),st(0)
	;st(1) = atan     st(1) = mul1    st(2) = atan    st(3) = expmul

	;fmul	CONST3
	;fild	framecounter
	;fmul	ROTSPEED3
	;fadd
	;fsin
	;fadd	CONST1_5
	;fadd
	;fxch;	st(1),st(0)
	;st(0) = atan     st(1) = mul2    st(2) = expmul

	fmul	CONST9
	fild	framecounter
	fmul	ROTSPEED2
	fadd
	fsin
	fadd	CONST1_5
	fadd
	;st(0) = expmul2

	fild	framecounter
	fmul	PULSARCONST
	fsin
	fadd	PULSARCONST2
	fmul

	fmul

	call	fexp

	fmul	CONST63
	fmul	flaremul
	fistp	color
	mov	ax,color
	stosb

	inc	x
	dec	cx
	jz	flarenoxloop
	jmp	flarexloop
flarenoxloop:
	;loop	flarexloop

	inc	y
	dec	dx
	jnz	flareyloop


	pop es
	popa
ret



;********
;* fpow *
;********
;#pragma aux fpow parm [8087] [8087] value [8087] modify [8087] =
;"fyl2x"
;"fld1"
;"fld st(1)"
;"fprem"
;"f2xm1"
;"faddp st(1),st"
;"fscale"
;"fxch st(1)"
;"fstp st(0)"
fpow:
	fyl2x
	fld1
	fld	st(1)
	fprem
	f2xm1
	faddp	st(1),st(0)
	fscale
	fxch	st(1)
	fstp	st(0)
ret



;********
;* fexp *
;********
;#pragma aux fexp parm [8087] value [8087] modify [8087] =
;"fldl2e"
;"fmulp st(1),st"
;"fld1"
;"fld st(1)"
;"fprem"
;"f2xm1"
;"faddp st(1),st"
;"fscale"
;"fxch st(1)"
;"fstp st(0)"
fexp:
	fldl2e
	fmulp st(1),st(0)
	fld1
	fld st(1)
	fprem
	f2xm1
	faddp st(1),st(0)
	fscale
	fxch st(1)
	fstp st(0)
ret



;*****************
;* recursebuffer *
;*****************
;  float size=256/zoom;
;  tx1=65536*(256-size);
;  ty1=65536*(256-size);
;  int ktx1,kty1,ktx2,kty2;
;  ktx1=cos(angle)*65536/zoom;
;  kty1=sin(angle)*65536/zoom;
;  ktx2=-sin(angle)*65536/zoom;
;  kty2=cos(angle)*65536/zoom;
;  tx1=0;
;  ty1=0;
;  float dx=-sin(angle)*128*zoom;
;  float dy=cos(angle)*128*zoom;
;  if (dy!=0){
;    float dy2=128-dy+originy;
;    float dx2=dy2*dx/dy+originx;
;    float px=128+dx+dx2;
;    float ptx=127;
;    float pty=-dy2*128/dy;
;    tx1=ptx*65536-px*ktx1;
;    ty1=pty*65536-px*kty1;
;  } else{
;    if (dx<0){
;      tx1=255;
;      ty1=0;
;    } else{
;      tx1=0;
;      ty1=255;
;    }
;  }
;  int tx,ty;
;  offs1=0;
;  unsigned short color;
;  for (y=0;y<256;y++){
;    tx=tx1;
;    ty=ty1;
;    for (x=0;x<256;x++,offs1++){
;      offs2=(((ty>>16)&255)<<8)+((tx>>16)&255);
;      color=buffer2[offs2];
;      color=subone[(int)(color)];
;      buffer1[offs1]=color;
;      tx+=ktx1;
;      ty+=kty1;
;    }
;    tx1+=ktx2;
;    ty1+=kty2;
;  }
recursebuffer:
	push es
	push fs
	pusha

	push	recursemap
	pop	es
	push	buffer
	pop	fs

	fild	framecounter
	fmul	ROTSPEED4
	fsin
	fmul	CONST63
	;fmul	CONST1_5
	fstp	originx

	fild	framecounter
	fmul	ROTSPEED1
	fild	framecounter
	fmul	ROTSPEED3
	fmul	ROTSPEED2
	fsin
	fadd	CONST1_5
	fadd	CONST1_5
	fmul	CONST0_5
	fmul	CONST0_5
	fmul	CONST0_5
	fmul	CONST0_5
	;fmul	CONST0_5
	;fmul	CONST0_5
	fmul
	fsin
	fmul	ROTSPEED3
	fmul	CONST0_5
	fchs
	fld1
	fadd
	;fstp	tempreal
	fstp	zoom

	fild	framecounter
	fmul	ROTSPEED1
	fmul	ROTSPEED2
	fsin
	fmul	CONST0_5
	;fmul	ROTSPEED3
	fstp	angle

;  ktx1=cos(angle)/zoom;
;  kty1=sin(angle)/zoom;
;  ktx2=-sin(angle)/zoom;
;  kty2=cos(angle)/zoom;
	fld	zoom
	fld1
	fdiv
	fstp	tempreal
	fld	angle
	fsincos
	fmul	tempreal
	fst	ktx1
	fstp	kty2
	fmul	tempreal
	fst	kty1
	fchs
	fstp	ktx2
	
;160=tx1+(100+originy)*ktx2+(160+originx)*ktx1
;tx1=160-((100+originy)*ktx2+(160+originx)*ktx1)
;ty1=100-(100*kty2+160*kty1)
	mov	tempint,100
	fild	tempint
	fadd	originy
	fmul	ktx2
	mov	tempint,160
	fild	tempint
	fadd	originx
	fmul	ktx1
	fadd
	fchs
	fiadd	tempint
	fadd	originx
	fstp	tx1
	
	mov	tempint,160
	fild	tempint
	fadd	originx
	fmul	kty1
	mov	tempint,100
	fild	tempint
	fadd	originy
	fmul	kty2
	fadd
	fchs
	fiadd	tempint
	fstp	ty1
	
;  for (y=0;y<200;y++){
;    tx=tx1;
;    ty=ty1;
;    for (x=0;x<320;x++,offs1++){
;      offs2=((ty%200)*320)+(tx%320);
;      color=buffer2[offs2];
;      color--;//=subone[(int)(color)];
;      buffer1[offs1]=color;
;      tx+=ktx1;
;      ty+=kty1;
;    }
;    tx1+=ktx2;
;    ty1+=kty2;
;  }

	mov	dx,200
	xor	di,di
recurseyloop:
	mov	cx,320
	fld	tx1
	fstp	tx
	fld	ty1
	fstp	ty
recursexloop:
	call	getbilinearpixel

	sub	ax,colorsub
	jns	nozero
	xor	ax,ax
nozero:
	stosb

	fld	tx
	fadd	ktx1
	fstp	tx
	fld	ty
	fadd	kty1
	fstp	ty

	;loop	recursexloop
	dec	cx
	jnz	recursexloop

	fld	tx1
	fadd	ktx2
	fstp	tx1
	fld	ty1
	fadd	kty2
	fstp	ty1

	dec	dx
	jnz	recurseyloop


;	xor	di,di
;	fld	angle
;	fmul	CONST255
;	;fild	framecounter
;	;fmul	CONST0_5
;	mov	tempint,320
;	call	fsmod
;	fistp	x
;	mov	cx,x
;	xor	al,al
;testloop:
;	stosb
;	inc	al
;	loop	testloop

;	xor	di,di
;	mov	cx,64000
;testloop:
;	mov	al,fs:[di]
;	inc	al
;	stosb
;	loop	testloop


	popa
	pop	fs
	pop	es
ret



;*************************
;* getbilinearpixel      *
;*	param:	tx,ty    *
;*	return:	ax=color *
;*************************
getbilinearpixel:
	fld	tx
	fld	st(0)
	fsub	CONST0_5
	frndint
	fist	textx1
	fchs
	fadd
	fst	textfx
	fchs
	fld1
	fadd
	fstp	text1fx

	fld	ty
	fld	st(0)
	fsub	CONST0_5
	frndint
	fist	texty1
	fchs
	fadd
	fst	textfy
	fchs
	fld1
	fadd
	fstp	text1fy

	fild	textx1
	mov	tempint,320
	call	modulo
	fist	textx1
	fld1
	fadd
	call	modulo
	fistp	textx2

	fild	texty1
	mov	tempint,200
	call	modulo
	fist	texty1
	fld1
	fadd
	call	modulo
	fistp	texty2

	mov	ax,texty1
	mov	y,ax
	mov	ax,textx1
	mov	x,ax
	call	getpixel
	mov	color1,ax

	mov	ax,texty1
	mov	y,ax
	mov	ax,textx2
	mov	x,ax
	call	getpixel
	mov	color2,ax

	mov	ax,texty2
	mov	y,ax
	mov	ax,textx1
	mov	x,ax
	call	getpixel
	mov	color3,ax

	mov	ax,texty2
	mov	y,ax
	mov	ax,textx2
	mov	x,ax
	call	getpixel
	mov	color4,ax

	fild	color1
	fmul	text1fx
	fmul	text1fy
	fild	color2
	fmul	textfx
	fmul	text1fy
	fadd
	fild	color3
	fmul	text1fx
	fmul	textfy
	fadd
	fild	color4
	fmul	textfx
	fmul	textfy
	fadd
	fistp	color

	mov	ax,color
ret



;*************************
;* Getpixel              *
;*	param:	x,y      *
;*	return:	ax=color *
;*************************
getpixel:
	mov	ax,y
	shl	ax,8
	shl	y,6
	add	ax,y
	add	ax,x

	mov	si,ax
	xor	ax,ax
	mov	al,fs:[si]
ret



;****************************
;* Fsmod                    *
;*	param:	val=st(0)   *
;*		mod=tempint *
;****************************
;float sfmod(float val, float mod){
;	val-=(int)(val/mod)*mod;
;	if (val<0) val+=mod;
;	return val;
;}
fsmod:
	fld	st(0)
	fidiv	tempint
	fld	CONST0_5
	fchs
	fadd
	frndint
	fimul	tempint
	fchs
	fadd
	fldz
	fcomp
	fstsw	ax
	wait
	sahf
	jns	fsmodcont
	fiadd	tempint
fsmodcont:
ret



;****************************
;* modulo                   *
;*	param:	val=st(0)   *
;*		mod=tempint *
;****************************
;float mod(int val, int mod){
;	val-=(int)(val/mod)*mod;
;	return val;
;}
modulo:
	fld	st(0)
	fidiv	tempint
	fld	CONST0_5
	fchs
	fadd
	frndint
	fimul	tempint
	fchs
	fadd
ret



;****************
;* renderplanet *
;****************
renderplanet:
	pusha
	push	es
	push	fs

	mov	tempint,-8
	fild	tempint
	fld1
	fscale
	fstp	CONST1_O_256
	fstp	tempreal

	push	buffer
	pop	es
	push	planetbumpmap
	pop	fs


;	fild	framecounter
;	fmul	PLANETSIZESPEED
;	fmul	CONST0_5
;	fcos
;	fchs
;	mov	tempint,120
;	fimul	tempint
;	mov	tempint,150
;	fiadd	tempint
;	fstp	planetsize
;
;
;	fild	framecounter
;	fmul	CONST0_5
;	fmul	CONST0_5
;	fmul	CONST0_5
;	fmul	CONST0_5
;	fmul	ROTSPEED2
;	fsin
;	fmul	planetsize
;	fchs
;	fstp	planetx
	
	mov	tempint,1000
	fild	tempint
	fild	framecounter
	fmul	CONST0_5
	fmul	CONST0_5
	fsub
	fild	tempint
	fdivr
	mov	tempint,100
	fimul	tempint
	fisub	tempint
	fstp	planetsize

	fld	planetsize
	fmul	planetsize
	fmul	ROTSPEED1
	fmul	ROTSPEED1
	fmul	CONST0_5
	fld	st(0)
	fmul	planetxconst
	fstp	planetx
	fmul	planetyconst
	fstp	planety

;	fild	framecounter
;	fimul	framecounter
;	fmul	ROTSPEED1
;	fmul	ROTSPEED1
;	fstp	planetsize

	;fldz
	;fstp	planetx
	;fldz
	;fstp	planety
	;mov	tempint,400
	;fild	tempint
	;fstp	planetsize

	fild	framecounter
	fmul	ROTSPEED1
	fmul	CONST0_5
	fmul	CONST0_5
	;fmul	CONST0_5
	;fmul	ROTSPEED2
	fsin
	fstp	lightx

	fild	framecounter
	;fmul	ROTSPEED1
	fmul	ROTSPEED1
	fmul	CONST0_5
	fmul	CONST0_5
	fsin
	fmul	CONST0_5
	fmul	CONST0_5
	fstp	lighty

	fild	framecounter
	fmul	ROTSPEED1
	fmul	CONST0_5
	fmul	CONST0_5
	;fmul	ROTSPEED3
	fcos
	;fld1
	;fld1
	;fadd
	;fchs
	;fadd
	fstp	lightz

	fld	lightx
	fld	st(0)
	fmul
	fld	lighty
	fld	st(0)
	fmul
	fld	lightz
	fld	st(0)
	fmul
	fadd
	fadd
	fsqrt
	fstp	tempreal
	fld	lightx
	fdiv	tempreal
	fstp	lightx
	fld	lighty
	fdiv	tempreal
	fstp	lighty
	fld	lightz
	fdiv	tempreal
	fstp	lightz


	xor	di,di
	mov	y,-100
	fild	y
	fadd	planety
	fstp	fy
	mov	dx,200
planetyloop:
	mov	jumpflag,0
	mov	x,-160
	mov	cx,160
planetjumppoint:
	fild	x
	fadd	planetx
	fstp	fx
planetxloop:
	test	jumpflag,1
	jz	noaverage

	xor	ax,ax
	xor	bx,bx
	mov	al,es:[di-1]
	mov	bl,es:[di+1]
	mov	tempint,ax
	sub	tempint,bx
	fild	tempint
	fabs
	fistp	tempint
	cmp	tempint,10
	ja	noaverage
	add	ax,bx
	shr	ax,1
	;mov	ax,0
	;mov	color,ax
	;mov	color,0
	jmp	averagedone
noaverage:
	;push	x
	;push	y

	fld	fy
	fld	st(0)
	fmul
	fld	fx
	fld	st(0)
	fmul
	fadd
	fchs
	fld	planetsize
	fld	st(0)
	fmul
	fadd
	fst	tempreal
	mov	color,0
	fldz
	fcompp
	fstsw	ax
	wait
	sahf
	js	noplanet

	fld1
	fdiv	planetsize
	fld	st(0)
	fld	st(0)
	fld	tempreal
	fsqrt
	fmul
	fchs
	fstp	nz
	fld	fx
	fmul
	fstp	nx
	fld	fy
	fmul
	fstp	ny

	fld	nx
	fchs
	fld	nz
	fpatan
	fldpi
	fadd
	fldpi
	fldpi
	fadd
	fdiv
	fstp	tx

	fld	nz
	fld	st(0)
	fmul
	fld	nx
	fld	st(0)
	fmul
	fadd
	fsqrt
	fld	ny
	fchs
	fpatan
	fldpi
	fadd
	fldpi
	fdiv
	fstp	ty

	fild	framecounter
	fmul	ROTSPEED1
	fmul	ROTSPEED3
	;fmul	ROTSPEED3
	fchs
	fmul	CONST0_5
	fmul	CONST0_5
	fadd	tx
	fstp	tx

	mov	tempint,256
	fld	tx
	fimul	tempint
	fstp	tx
	fld	ty
	fimul	tempint
	fstp	ty

	fld	tx
	fsub	CONST0_5
	fistp	x
	fld	ty
	fsub	CONST0_5
	fistp	y

;b1=bumpmap[(((tyi-1)&and)<<shift)+((txi)&and)];
;b2=bumpmap[(((tyi-1)&and)<<shift)+((txi+1)&and)];
;b3=bumpmap[(((tyi)&and)<<shift)+((txi-1)&and)];
;b4=bumpmap[(((tyi)&and)<<shift)+((txi)&and)];
;b5=bumpmap[(((tyi)&and)<<shift)+((txi+1)&and)];
;b6=bumpmap[(((tyi)&and)<<shift)+((txi+2)&and)];
;b7=bumpmap[(((tyi+1)&and)<<shift)+((txi-1)&and)];
;b8=bumpmap[(((tyi+1)&and)<<shift)+((txi)&and)];
;b9=bumpmap[(((tyi+1)&and)<<shift)+((txi+1)&and)];
;b10=bumpmap[(((tyi+1)&and)<<shift)+((txi+2)&and)];
;b11=bumpmap[(((tyi+2)&and)<<shift)+((txi)&and)];
;b12=bumpmap[(((tyi+2)&and)<<shift)+((txi+1)&and)];
	xor	ax,ax
	dec	y
	call	getpixel2
	mov	b1,ax
	inc	x
	call	getpixel2
	mov	b2,ax
	inc	y
	sub	x,2
	call	getpixel2
	mov	b3,ax
	inc	x
	call	getpixel2
	mov	b4,ax
	inc	x
	call	getpixel2
	mov	b5,ax
	inc	x
	call	getpixel2
	mov	b6,ax
	inc	y
	sub	x,3
	call	getpixel2
	mov	b7,ax
	inc	x
	call	getpixel2
	mov	b8,ax
	inc	x
	call	getpixel2
	mov	b9,ax
	inc	x
	call	getpixel2
	mov	b10,ax
	inc	y
	sub	x,2
	call	getpixel2
	mov	b11,ax
	inc	x
	call	getpixel2
	mov	b12,ax

	fld	tx
	fld	st(0)
	fsub	CONST0_5
	frndint
	fchs
	fadd
	fst	textfx
	fchs
	fld1
	fadd
	fstp	text1fx

	fld	ty
	fld	st(0)
	fsub	CONST0_5
	frndint
	fchs
	fadd
	fst	textfy
	fchs
	fld1
	fadd
	fstp	text1fy

;txd1=b5-b3; txd2=b6-b4; txd3=b9-b7; txd4=b10-b8;
;txd=txd1*f1x*f1y + txd2*f2x*f1y + txd3*f1x*f2y + txd4*f2x*f2y;
	mov	ax,b5
	sub	ax,b3
	mov	color1,ax
	mov	ax,b6
	sub	ax,b4
	mov	color2,ax
	mov	ax,b9
	sub	ax,b7
	mov	color3,ax
	mov	ax,b10
	sub	ax,b8
	mov	color4,ax

	call	getbilinearvalue
	mov	slopex,ax
;tyd1=b8-b1; tyd2=b9-b2; tyd3=b11-b4; tyd4=b12-b5;
;tyd=tyd1*f1x*f1y + tyd2*f2x*f1y + tyd3*f1x*f2y + tyd4*f2x*f2y;
	mov	ax,b8
	sub	ax,b1
	mov	color1,ax
	mov	ax,b9
	sub	ax,b2
	mov	color2,ax
	mov	ax,b11
	sub	ax,b4
	mov	color3,ax
	mov	ax,b12
	sub	ax,b5
	mov	color4,ax

	call	getbilinearvalue
	mov	slopey,ax


	fild	slopex
	fmul	bumpheight
	;fld	st(0)
	;fmul	nx
	;fchs
	;fxch
	fmul	nz
	fadd	nx
	fstp	nx
	;fadd	nz
	;fstp	tempreal

	fild	slopey
	fmul	bumpheight
	;fld	st(0)
	;fmul	ny
	;fchs
	;fxch
	fmul	nz
	fadd	ny
	fstp	ny
	;fadd	tempreal
	;fstp	nz

	fld	nx
	fld	st(0)
	fmul
	fld	ny
	fld	st(0)
	fmul
	fld	nz
	fld	st(0)
	fmul
	fadd
	fadd
	fsqrt
	fstp	tempreal
	fld1
	fdiv	tempreal
	fstp	tempreal
	fld	nx
	fmul	tempreal
	fstp	nx
	fld	ny
	fmul	tempreal
	fstp	ny
	fld	nz
	fmul	tempreal
	fstp	nz

	fld	nx
	fmul	lightx
	fld	ny
	fmul	lighty
	fld	nz
	fmul	lightz
	fadd
	fadd
	fld	highlight
	fld	st(1)
	call	fpow
	fadd
	fmul	CONST0_5
	fstp	planetshade

	;mov	tempint,256
	;fld	tx
	;fimul	tempint
	;fistp	textx1
	;fld	ty
	;fimul	tempint
	;fistp	texty1

	;mov	bx,texty1
	;and	bx,255
	;shl	bx,8
	;mov	ax,textx1
	;add	ax,framecounter
	;add	bl,al
	;xor	ax,ax
	;mov	al,fs:[bx]
	;call	getbilinearpixel2

	;mov	tempint,ax
	;fild	slopex
	;fmul	CONST1_O_256
	;fmul	planetshade
	fld	planetshade
	mov	color,0

	fmul	CONST63
	fistp	tempint

	cmp	tempint,0
	js	noplanet

	mov	ax,tempint
	mov	color,ax

noplanet:
	mov	ax,color
averagedone:
	stosb

	inc	di
	fld1
	fld1
	fadd
	fadd	fx
	fstp	fx
	dec	cx
	jz	planetnoxloop
	jmp	planetxloop
planetnoxloop:
	test	jumpflag,1
	jnz	nojump

	mov	x,-159
	mov	cx,159
	sub	di,319
	mov	jumpflag,1
	jmp	planetjumppoint
nojump:
	inc	di

	fld1
	fadd	fy
	fstp	fy
	dec	dx
	jnz	planetyloop


	pop	fs
	pop	es
	popa
ret



;*************************
;* getslope              *
;*	param:	tx,ty    *
;*	return:	ax=color *
;*************************
getslope:
	fld	tx
	fld1
	fadd
	fistp	x
	call	getpixel2
	mov	bx,ax
	fld	tx
	fld1
	fld1
	fadd
	fchs
	fadd
	fistp	x
	call	getpixel2
	sub	ax,bx
ret



;**********************************************
;* getbilinearvalue                           *
;*	param:	color1,color2,color3,color4   *
;*		textfx,text1fx,textfy,text1fy *
;*	return:	ax=color                      *
;**********************************************
getbilinearvalue:
	fild	color1
	fmul	text1fx
	fmul	text1fy
	fild	color2
	fmul	textfx
	fmul	text1fy
	fadd
	fild	color3
	fmul	text1fx
	fmul	textfy
	fadd
	fild	color4
	fmul	textfx
	fmul	textfy
	fadd
	fistp	color
	mov	ax,color
ret



;*************************
;* Getpixel2             *
;*	param:	x,y      *
;*	return:	ax=color *
;*************************
getpixel2:
	mov	si,y
	shl	si,8
	and	x,255
	add	si,x
	mov	al,fs:[si]
ret



;**********
;* Random *
;**********
random:
	pusha

	mov	eax,rndseed
	add	eax,1724721753
	mov	ebx,rndseed2
	add	ebx,239873
	mul	bx
	add	eax,4721753
	mov	rndseed2,eax
	sub	ebx,eax
	add	ebx,19836137
	mul	bx
	mov	rndseed,eax

	popa
ret



;***************
; InitTextures *
;***************
inittextures:
	pusha
	push es


	mov	ax,planetbumpmap
	mov	es,ax
	call	random
	mov	eax,rndseed
	shr	eax,24
	mov	al,127
	mov	es:[0],al

	;fld	REAL31
	;fmul	REAL025
	;fmul REAL01
	fld	planetrandom
	fstp	ftextrandom
	mov	cl,8
	mov	x1,0
	mov	y1,0
	mov	x2,256
	mov	y2,256
	call	fractalrecurse

	pop es
	popa
ret

fractalrecurse:
	mov	ax,x2
	sub	ax,x1
	mov	deltax,ax
	cmp	ax,1
	ja	fraccontinue
	mov	deltay,ax
	cmp	ax,1
	ja	fraccontinue
	jmp	outoffractalrecurse
fraccontinue:

	mov	ax,y2
	sub	ax,y1
	mov	deltay,ax


	mov	ax,x1
	add	ax,x2
	shr	ax,1
	mov	midx,ax
	mov	bx,y1
	add	bx,y2
	shr	bx,1
	mov	midy,bx

	mov	bx,y1
	;and bx,ftextmask
	shl	bx,cl
	mov	dx,x1
	;and dx,ftextmask
	add	bx,dx
	mov	dl,es:[bx]
	mov	c1,dl

	mov	bx,y1
	;and bx,ftextmask
	shl	bx,cl
	mov	dx,x2
	and	dx,ftextmask
	add	bx,dx
	mov	dl,es:[bx]
	mov	c2,dl

	mov	bx,y2
	and	bx,ftextmask
	shl	bx,cl
	mov	dx,x1
	;and dx,ftextmask
	add	bx,dx
	mov	dl,es:[bx]
	mov	c3,dl

	mov	bx,y2
	and	bx,ftextmask
	shl	bx,cl
	mov	dx,x2
	and	dx,ftextmask
	add	bx,dx
	mov	dl,es:[bx]
	mov	c4,dl

	xor	dh,dh

	mov	dl,c1
	mov	ax,dx
	mov	dl,c2
	add	ax,dx
	shr	ax,1
	fild	deltax
	call	randomfractal
	mov	bx,y1
	shl	bx,cl
	add	bx,midx
	mov	ah,es:[bx]
	cmp	ah,0
	jnz	rf1
	mov	es:[bx],al
rf1:

	mov	dl,c3
	mov	ax,dx
	mov	dl,c4
	add	ax,dx
	shr	ax,1
	fild	deltax
	call	randomfractal
	mov	bx,y2
	and	bx,ftextmask
	shl	bx,cl
	add	bx,midx
	mov	ah,es:[bx]
	cmp	ah,0
	jnz	rf2
	mov	es:[bx],al
rf2:

	mov	dl,c1
	mov	ax,dx
	mov	dl,c3
	add	ax,dx
	shr	ax,1
	fild	deltay
	call	randomfractal
	mov	bx,midy
	shl	bx,cl
	add	bx,x1
	mov	ah,es:[bx]
	cmp	ah,0
	jnz	rf3
	mov	es:[bx],al
rf3:
	mov	dl,c2
	mov	ax,dx
	mov	dl,c4
	add	ax,dx
	shr	ax,1
	fild	deltay
	call	randomfractal
	mov	bx,midy
	shl	bx,cl
	mov	dx,x2
	and	dx,ftextmask
	add	bx,dx
	mov	ah,es:[bx]
	cmp	ah,0
	jnz	rf4
	mov	es:[bx],al
rf4:

	mov	dl,c1
	mov	ax,dx
	mov	dl,c2
	add	ax,dx
	mov	dl,c3
	add	ax,dx
	mov	dl,c4
	add	ax,dx
	shr	ax,2
	fild	deltax
	;fld	st(0)
	fmul	st(0),st(0)
	fild	deltay
	;fld	st(0)
	fmul	st(0),st(0) 
	fadd
	fsqrt
	call	randomfractal
	;add ax,tempint
	mov	bx,midy
	shl	bx,cl
	add	bx,midx
	mov	es:[bx],al


	push	x1
	push	y1
	push	x2
	push	y2
	push	midx
	push	midy
	;push ftextmask
	mov	ax,midx
	mov	x2,ax
	mov	ax,midy
	mov	y2,ax
	;shr ftextmask,1
	call	fractalrecurse
	;pop ftextmask
	pop	midy
	pop	midx
	pop	y2
	pop	x2
	pop	y1
	pop	x1
	push	x1
	push	y1
	push	x2
	push	y2
	push	midx
	push	midy
	;push ftextmask
	mov	ax,midx
	mov	x1,ax
	mov	ax,midy
	mov	y2,ax
	;shr ftextmask,1
	call	fractalrecurse
	;pop ftextmask
	pop	midy
	pop	midx
	pop	y2
	pop	x2
	pop	y1
	pop	x1
	push	x1
	push	y1
	push	x2
	push	y2
	push	midx
	push	midy
	;push ftextmask
	mov	ax,midx
	mov	x2,ax
	mov	ax,midy
	mov	y1,ax
	;shr ftextmask,1
	call	fractalrecurse
	;pop ftextmask
	pop	midy
	pop	midx
	pop	y2
	pop	x2
	pop	y1
	pop	x1
	push	x1
	push	y1
	push	x2
	push	y2
	push	midx
	push	midy
	;push ftextmask
	mov	ax,midx
	mov	x1,ax
	mov	ax,midy
	mov	y1,ax
	;shr ftextmask,1
	call	fractalrecurse
	;pop ftextmask
	pop	midy
	pop	midx
	pop	y2
	pop	x2
	pop	y1
	pop	x1
outoffractalrecurse:
ret

randomfractal:
	call	random
	and	rndseed,65535
	fild	rndseed
	fdiv	CONST65536
	;fdiv REAL65536
	;fistp tempint
	;fild tempint
	;fdiv REAL65536
	fsub	CONST0_5
	fmul
	fmul	ftextrandom
	fistp	tempint
	add	ax,tempint
	cmp	ax,1
	jb	randomzero
	cmp	ax,255
	ja	random255
	jmp	randomok
	;ret
randomzero:
	mov	ax,1
	jmp	randomok
	;ret
random255:
	mov	ax,255
randomok:
ret



;**************
;* Copybuffer *
;**************
copybuffer:
	push	es
	push	ds
	pusha

	
;	push	fs
;	push	buffer
;	pop	es
;	push	planetbumpmap
;	pop	fs
;	xor	di,di
;	xor	si,si
;	mov	dx,200
;testyloop:
;	mov	cx,256
;testxloop:
;	mov	al,fs:[si]
;	stosb
;	inc	si
;	loop	testxloop
;	add	di,64
;	dec	dx
;	jnz	testyloop
;	pop	fs

	push	0A000h
	pop	es
	push	buffer
	pop	ds

	xor	di,di
	xor	si,si
	mov	cx,16000
	rep	movsd

	;push	ds
	;pop	es
	;mov	cx,16000
	;xor	eax,eax
	;rep	stosd


	popa
	pop	ds
	pop	es
ret



;*********************
;* Copyflaretobuffer *
;*********************
copyflaretobuffer:
	push	es
	push	ds
	pusha


	push	buffer
	pop	es
	push	flaremap
	pop	ds

	xor	di,di
	xor	si,si
;	mov	cx,64000
;flarebufferloop:
;	lodsb
;	xor	ah,ah
;	xor	bh,bh
;	mov	bl,es:[di]
;	add	ax,bx
;	;dec	ax
;	sub	ax,2
;	ja	nozeroing
;	xor	ax,ax
;nozeroing:
;	test	ah,255
;	jz	noclipping
;	mov	ax,255
;noclipping:
;	stosb
;	loop	flarebufferloop

	mov	cx,16000
	rep	movsd

	popa
	pop	ds
	pop	es
ret



;***********************
;* Copyrecursetobuffer *
;***********************
copyrecursetobuffer:
	push es
	push ds
	pusha


	push buffer
	pop es
	push recursemap
	pop ds

	xor di,di
	xor si,si
	mov cx,16000
	rep movsd

	popa
	pop ds
	pop es
ret



;************
;* Settimer *
;************
settimer:
	cli
	mov ax,351Ch
	int 21h
	mov oldtimeroffs,bx
	mov oldtimerseg,es
	
	push ds
	lea dx,newinterrupt
        mov ax,cs
        mov ds,ax
	mov ax,251Ch
	int 21h
	pop ds
	
	;New rate
	mov al,3Ch
	out 43h,al
	nop
	nop
	;mov ax,4DAEh ;1234DDh/60
	mov al,0AEh
	out 40h,al
	nop
	nop
	mov al,4Dh
	out 40h,al
	nop
	nop
	sti
ret



;**************
;* Unsettimer *
;**************
unsettimer:
	push ds
	mov dx,oldtimeroffs
	mov ds,oldtimerseg
	mov ax,251Ch
	int 21h
	pop ds
ret



;***************
; Newinterrupt *
;***************
newinterrupt:
	push ds
	mov ds,cs:[datasegment]
	inc framecounter2
	pop ds
iret



;********
;* Main *
;********
main:
	call initialize
	;call makepalette
	call settimer


mainloop:
	cmp	framecounter2,0
	js	mainloop

	call	makepalette

	mov	ax,framecounter2
	mov	framecounter,ax

	;jmp	part4

	cmp	framecounter,PART1LENGHT
	jns	part2
	call	renderflare
	call	copyflaretobuffer
	jmp	continue1
part2:
	sub	framecounter,PART1LENGHT

	cmp	framecounter,PART3LENGHT
	jns	part3

	call	makepalettevalues

	call	recursebuffer
	call	copyrecursetobuffer

	cmp	framecounter,PART2LENGHT
	js	continue1
	cmp	framecounter,PART3LENGHT-PART2LENGHT
	jns	continue1
	sub	framecounter,PART2LENGHT
	mov	colorsub,1

	call	renderdot
	jmp	continue1
part3:
	sub	framecounter,PART3LENGHT
	
	cmp	framecounter,PART4LENGHT
	jns	part4

	call	renderplanet
	jmp	continue1
part4:
	sub	framecounter,PART4LENGHT
	
	cmp	framecounter,PART5LENGHT
	jns	part5

	call	makepalettevalues

	call	rendername
	jmp	continue1
part5:
	sub	framecounter,PART5LENGHT

	cmp	framecounter,PART6LENGHT
	jns	nomainloop

	;add	framecounter,6000
	;neg	framecounter
	mov	colorsub,1
	call	recursebuffer
	call	copyrecursetobuffer
continue1:
	call	retrace
	call	copybuffer

	;inc framecounter

	;Keyboard handling
	mov	ax,256
	int	16h
	jz	yesmainloop          ;No keys pressed

	mov	ah,0
	int	16h
	dec	ah
	jz	nomainloop           ;ESC pressed

	;cmp al,32
	;jnz yesmainloop         ;Space not pressed
	;
	;add i,3

yesmainloop:
	jmp mainloop
nomainloop:
	call	unsettimer
	mov	ax,3h
	int	10h
	mov	ah,9
	lea	dx,endstring
	int	21h
	ret
end start
