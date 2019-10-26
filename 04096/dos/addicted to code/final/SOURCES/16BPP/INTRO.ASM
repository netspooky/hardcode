ASSUME cs:CODE
JUMPS

include	macros.inc
include intro.mac
include timer.mac

include	ef7.mac

.386p

o		equ offset
a		equ offset TempWord

seed		equ 456h			;For random number generator
VideoMode	equ 10Eh			;Vesa mode number ( LFB )

NPat		equ 14				;Number of patterns (odd)
NTex		equ 8				;Number of textures
NBkg		equ 0				;Number of backgrounds
NCol		equ 2				;Number of shade buffers

Buffer		equ 0				;Buffer size   = 65536*6
Buffer2		equ Buffer+20000h
Buffer3		equ Buffer2+20000h
Textures	equ Buffer+60000h		;Textures ( 15bit )
Backgrounds	equ Textures+NTex*20000h	;Patterns ( for texture maker )
Patterns	equ Backgrounds+NBkg*20000h	;Patterns ( for texture maker )
ColBuffers	equ Patterns+NPat*10000h	;Shade/Color buffers
TunelBuffer	equ ColBuffers+NCol*10000h	;Tunel buffer
FlowBuffer	equ TunelBuffer+10000h*2	;Flow (r,g,b - 3*10000h)
MemoryEnd	equ FlowBuffer+10000h*3		;End of used memory

MemSize		equ (MemoryEnd-Buffer)/1000+200
MemSizeBytes	equ (MemoryEnd-Buffer)
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
CODE	SEGMENT USE16
	org	100h
Start:
	jmp RealStart
	db (2000h-3) dup (0)
RealStart:
	finit				;Init floating point unit
	call	InitSystem		;Init XMS Driver ( Check if exists )
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
	mov	edi,ds:[TabPtr]		;Clear memory 	
	mov	ecx,MemSizeBytes/4	;- Whole reserved memory
	xor	eax,eax			;- by dwords
	rep	lstosd
;Clear1:	lstosd				;- using lstosd ( edi instead of di )
;	loopd	Clear1			;  instruction using ecx instead of cx


	call	MakeTextures		;Generate all textures

	InitVesa			;Init vesa mode  ( if possible )
	MakeMultab			;Make fading table (32 colors in 64 sh)
	SetTimer			;Set timer at 182 Hz

	in	al,21h			;Disable keyboard
	or	al,2		
	out	21h,al
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
;&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
;&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
;>>>>>>>>>>>>>>>>>>>>>>>> Effect no. 1 - flow <<<<<<<<<<<<<<<<<<<<<<<<
Effect1Loop:
	call	Flow

	mov	ds:[FlareC],-80
	mov	ax,320*3+8
	mov	cx,168/4-2
@@ert1a:
	mov	dx,8
@@ert2a:
	pushad
	and	cl,1
	shl	cl,2
	add	ax,cx
	mov	bx,10
	call	PutFlare
	popad
	add	ax,8
	dec	dx
	jnz	@@ert2a
	add	ax,320*4-8*8
	loop	@@ert1a

	mov	si,offset text1
	mov	cx,182*10
	call	CopyScreen
	jnc	Effect1Loop
EndOfEffect1:
;>>>>>>>>>>>>>>>>>>>>>>>> Effect no. 2 - tunnels <<<<<<<<<<<<<<<<<<<<<<<<
;..............................................................................
Effect2Start:
	mov	ds:[FrameCount],0
Effect2Loop:
	call	MkTunel1
	mov	eax,Textures+Texture5
	call	TextureTunel

	mov	edi,ds:[TabPtr]
	shr	edi,1
NegTunel2:
	mov	ax,[edi+edi]
	xor	ax,7FFFh
	mov	[edi+edi+20000h],ax
	inc	di
	cmp	di,320*(200-32)
	jnz	NegTunel2

	call	AddScreenMkGray

	mov	si,offset text2
	mov	cx,182*10
	call	CopyScreen
	jnc	Effect2Loop
EndOfEffect2:
;>>>>>>>>>>>>>>>>>>>>>>>> Effect no. 4 - blobs <<<<<<<<<<<<<<<<<<<<<<<<
;..............................................................................
Effect4Start:
	mov	ds:[FrameCount],0
Effect4Loop:

	call	Effect4

	mov	si,offset text3
	mov	cx,182*15
	call	CopyScreen
	jnc	Effect4Loop
EndOfEffect4:
;>>>>>>>>>>>>>>>>>>>>>> Effect no. 5 - tunnel + plasma <<<<<<<<<<<<<<<<<<<<<<<
;..............................................................................
Effect5Start:
	mov	ds:[FrameCount],0
Effect5Loop:
	call	Effect5

	call	MkTunel1
	mov	eax,Textures+Texture1
	call	TextureTunel

	call	AddScreenMkGray

	mov	si,offset text4
	mov	cx,182*15
	call	CopyScreen
	jnc	Effect5Loop
EndOfEffect5:
;>>>>>>>>>>>>>>>>>>>>>>>> Effect no. 6 - radial blur <<<<<<<<<<<<<<<<<<<<<<<<
;..............................................................................
Effect6Start:
	mov	ds:[FrameCount],0
Effect6Loop:
	mov	edi,ds:[TabPtr]
	lea	esi,[edi+Colbuffers]
	shr	edi,1
	lea	ebx,[edi+(Textures+Texture8)/2]
MkRadialBackY:
	xor	bl,bl
	mov	bp,320
MkRadialBackX:
	mov	cx,[ebx+ebx]
	xor	al,al
	mov	[edi+edi],cx
	inc	di
	test	cx,(24+24*32+24*1024)
	jnz	NopeRadialBack
	mov	ax,cx
	shr	ax,5
	xor	al,-1
NopeRadialBack:
	inc	bl
	mov	[esi],al
	inc	si
	dec	bp
	jnz	MkRadialBackX
	inc	bh
	cmp	di,320*(200-32)
	jnz	MkRadialBackY

	
	call	RadialBlur

	mov	ds:[FlareC],-128
	mov	ax,320*3+8
	mov	cx,168/4-2
@@ert1:
	mov	dx,8
@@ert2:
	pushad
	and	cl,1
	shl	cl,2
	add	ax,cx
	mov	bx,5
	call	PutFlare
	popad
	add	ax,8
	dec	dx
	jnz	@@ert2
	add	ax,320*4-8*8
	loop	@@ert1

	mov	si,offset text5
	mov	cx,182*15
	call	CopyScreen
	jnc	Effect6Loop
EndOfEffect6:
;>>>>>>>>>>>>>>>>>>>>>>>> Effect no. 7 - water <<<<<<<<<<<<<<<<<<<<<<<<
;..............................................................................
Effect7Start:
	Effect7Prepare
	mov	ds:[FrameCount],0
Effect7Loop:
	Effect7

	mov	si,offset text6
	mov	cx,182*15
	call	CopyScreen
	jnc	Effect7Loop
EndOfEffect7:
;>>>>>>>>>>>>>>>>>>>>>>>> Effect no. 8 - flow 2 <<<<<<<<<<<<<<<<<<<<<<<<
;..............................................................................
Effect8Start:
	mov	ds:[FlowFrame],0
	mov	ds:[FrameCount],0
Effect8Loop:
	call	Flow2

	mov	si,offset greetz
	xor	cx,cx
WriteGreetz:
	mov	dx,ds:[FrameCount]
	shr	dx,2
	mov	ax,cx
	imul	ax,35
	sub	ax,dx
	add	ax,200
	cmp	ax,-15
	jle	NoWriteGr
	cmp	ax,200-32
	jge	NoWriteGr
	imul	ax,320
	add	ax,20
	xchg	di,ax
	pusha
	mov	bp,5
	mov	dh,127
	call	OutText
	popa
NoWriteGr:
	lodsb
	or	al,al
	jnz	NoWriteGr

	inc	cx
	cmp	cl,16
	jnz	WriteGreetz


	mov	si,offset text7
	mov	cx,182*20
	call	CopyScreen
	jnc	Effect8Loop
EndOfEffect8:
;..............................................................................
;..............................................................................
;..............................................................................
;-------------------------------------------------------------------------------
EndOfIntro:
	mov	ax,3			;Switch into text mode
	int	10h			;Call bios

	in	al,21h			;Enable keyboard
	and	al,0FDh
	out	21h,al

	ResetTimer			;Set old 8h interrupt at 18.2 Hz
	call	DeInitSystem		;Free memory ( reserved by XMS Driver )
	ret				;Ant that's all folks
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
include timer.inc
include flatram.inc
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
include mkpatern.inc

include ray.inc
include flow.inc
include	radial.inc
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
include	ef4.asm
include	ef5.asm
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

greetz:	
	db 'banshik',0
	db 'bayger',0
	db 'behemot',0
	db 'daze',0
	db 'fugaz',0
	db 'gardner',0
	db 'guru',0
	db 'ile',0
	db 'impexus',0
	db 'mash',0
	db 'mrock',0
	db 'rastan',0
	db 'tihocan',0
	db 'viggith',0
	db 'weed',0
text1:
	db 1,5
	dw 320*124+160
	db 'finally',0
	db 2,6
	dw 320*144+170
	db 'finished',0
	db 0
text2:
	db 1,5
	dw 320*4+130
	db 'not{at{all',0
	db 2,6
	dw 320*24+250
	db 'but',0
	db 3,7
	dw 320*44+210
	db 'enough',0
	db 0
text3:
	db 1,5
	dw 320*104+10
	db 'another{week',0
	db 2,6
	dw 320*124+10
	db 'just{thrown{out',0
	db 3,7
	dw 320*144+10
	db 'of{my{life',0
	db 0
text4:
	db 1,5
	dw 320*4+310-9*18
	db 'i{thought',0
	db 2,6
	dw 320*24+310-7*18
	db 'it{does',0
	db 3,7
	dw 320*44+310-4*18
	db 'make',0
	db 4,8
	dw 320*64+310-5*18
	db 'sense',0
	db 0
text5:
	db 1,5
	dw 320*64+310-6*18
	db 'not{so',0
	db 2,6
	dw 320*84+310-4*18
	db 'sure',0
	db 3,7
	dw 320*104+310-5*18
	db 'about',0
	db 4,8
	dw 320*124+310-4*18
	db 'that',0
	db 5,9
	dw 320*144+310-6*18
	db 'anyway',0
	db 0
text6:
	db 1,5
	dw 320*4+10
	db 'i{am',0
	db 2,6
	dw 320*24+10
	db 'addicted',0
	db 3,7
	dw 320*44+10
	db 'to',0
	db 4,8
	dw 320*64+10
	db 'code',0
text7:
	db 0
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;%%%%%%% OutText routine
;%%%%%%%  - outputs font text on screen (in TabPtr)
;%%%%%%% => di - text screen position
;%%%%%%% => bp - texts width (flare width - normal width = 5)
;%%%%%%% => dh - text brightness (0-127)

DrawChar:
	mul	cl
	xchg	bx,ax
	mov	ax,di
DrawCharY:
	mov	dl,[bx+offset FontTab]
	inc	bx
	push	ax
DrawCharX:
	shr	dl,1
	jz	EndCharLIne
	jnc	NoCharFlare
	pusha
	mov	bx,bp
	mov	ds:[FlareC],dh
	call	PutFlare
	popa
NoCharFlare:
	inc	ax
	inc	ax
	jmp	DrawCharX
EndCharLine:
	pop	ax
	add	ax,320*2
	loop	DrawCharY
	add	di,18
OutText:
	lodsb
	mov	cx,6
	sub	al,97
	jge	DrawChar
	lodsb
	ret
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;%%%% => si - text buffer

FadeText	PROC
FadeTexts:	
	lodsw
	or	al,al
	jz	EndFadeTexts
	mov	bp,5
	mov	dh,127
	mov	bx,ds:[FrameCount]
	cmp	bh,al
	jb	NoText1
	jz	FadeText1
	not	bl
	cmp	bh,ah
	ja	NoText1
	jnz	NoFade
FadeText1:
	mov	dh,bl
	not	bl
	shr	dh,1
	shr	bl,3
	xor	bh,bh
	add	bp,bx
NoFade:
	pusha
	lodsw
	xchg	di,ax
	call	OutText
	popa
NoText1:
	lodsw
@EETY:
	lodsb
	or	al,al
	jnz	@EETY
afterText:
	jmp	FadeTexts
EndFadeTexts:
	ret
FadeText	ENDP
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
VesaError 	db 'Vesa!$'

;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;%%%%%% => ax - 15bit color pixel to fade
;%%%%%%    bl - fade
;%%%%%% <= ax - faded 15bit color pixel  

FadePixel	PROC
	push	si
	push	di
	push	bp
	push	cx

	mov	bp,31744		
	mov	si,ax
	mov	di,si
	and	bx,0FCh
	and	bp,si
	shl	bx,3
	and	si,31
	shr	bp,10
	and	di,992
	shr	di,5
	mov	al,[bx+si+offset multab]
	mov	si,bp
	xor	cx,cx
	mov	cl,[di+bx+offset multab]
	shl	cx,5
	mov	ah,[si+bx+offset multab]
	shl	ah,2
	or	ax,cx

	pop	cx
	pop	bp
	pop	di
	pop	si
	ret
FadePixel	ENDP
;-------------------------------------------;
;Fade_tab	PROC
Fade_tab0:
	mov	byte ptr ds:[NegFade+2],0
	xor	edx,edx
	jmp	fade_tab
Fade_tab7F:
	mov	byte ptr ds:[NegFade+2],7Fh
	mov	edx,20000h
Fade_tab:
	mov	eax,ColBuffers
	add	edx,ds:[TabPtr]
	add	eax,ds:[TabPtr]
	shr	edx,1
	sub	eax,edx
	mov	dword ptr [@@cb1+3],eax
@fade_tab:
	mov	si,[edx+edx]		;//edx+edx
	mov	bp,31744		
@@cb1:	mov	bl,[edx+12345678h]
NegFade:
	xor	bl,00h
	mov	di,si
	and	bx,0FCh
	and	bp,si
	shl	bx,3
	and	si,31
	shr	bp,10
	and	di,992
	shr	di,5
	mov	al,[bx+si+offset multab]
	mov	si,bp
	xor	cx,cx
	mov	cl,[di+bx+offset multab]
	inc	dx
	shl	cx,5
	mov	ah,[si+bx+offset multab]

	shl	ah,2

	or	ax,cx
	cmp	dx,320*(200-32)
	mov	[edx+edx-2],ax
	jnz	@fade_tab
	ret
;Fade_tab	ENDP
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
AddScreenMkGray	PROC
	call	Fade_tab7F
	call	Fade_tab0
	call	AddScreens
	mov	edi,ds:[TabPtr]
	shr	edi,1
;	xor	di,di
MkGrayY:
	add	di,220
	xor	dx,dx
MkGrayX:
	mov	ax,[edi+edi]

	mov	cx,ax
	shr	ah,2
	shr	cx,4
	and	al,31
	and	cx,(31 shl 1)
	add	al,ah
	add	al,cl
	shr	al,2
	mov	cl,al
	mov	ah,al
	shl	ah,2
	shl	cx,5
	or	ax,cx

	cmp	dx,32
	jae	NoGray
	mov	bx,dx
	shl	bx,3
	cmp	dx,16
	jb	NoGray2
	sub	bl,(16 shl 3)
	jmp	NoGray3	
NoGray2:
	mov	ax,[edi+edi]
	xor	bl,07Fh
NoGray3:
	call	FadePixel
NoGray:
	inc	dx
	mov	[edi+edi],ax
	inc	di
	cmp	dx,100
	jb	MkGrayX

	cmp	di,320*(200-32)
	jnz	MkGrayY
	ret
AddScreenMkGray	ENDP
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;%%%%%%% => ax - pos

FlareC	db 127

PutFlare	PROC
	mov	edi,ds:[TabPtr]
	lea	ecx,[edi+Patterns+Pattern7]
	shr	edi,1
	mov	di,ax

	xor	ax,ax
	cwd
	inc	dx
	div	bx
	mov	bp,ax
	shr	bx,1
	sub	di,bx

FlareYl:
	push	di
	xor	dx,dx
FlareXl:
	mov	cl,dh
	mov	al,[ecx]
	imul	ds:[FlareC]
	sar	ax,7
	jz	NoAddFlare
	xor	al,80h
	xchg	ax,bx
	mov	ax,[edi+edi]
	call	FadePixel
	mov	[edi+edi],ax
NoAddFlare:
	inc	di
	add	dx,bp
	jnc	FlareXl

	pop	di
	add	di,320
	add	ch,51
	jnc	FlareYl
NoFlare:
	ret
PutFlare	ENDP

;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;%%%%%%% Add two textures (no saturation, just wrap around)
;%%%%%%% [TabPtr] + [TabPtr + ebx]
;%%%%%%% in: ebx

AddScreens	PROC
	mov	edi,ds:[TabPtr]
	shr	edi,1
AddScreens1:
	mov	eax,[edi+edi+20000h]
	add	[edi+edi],eax
	add	di,2
	cmp	di,320*(200-32)
	jnz	AddScreens1
	ret
AddScreens	ENDP

;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
CopyScreen	PROC
;>>>>>>>>>>>>>>>>>>>>>> check for key pressed <<<<<<<<<<<<<<<<<<<;
	in	al,60h
	cmp	al,1
	jnz	NoEnd
	pop	ax
	jmp	EndOfIntro
NoEnd:
;>>>>>>>>>>>>>>>>>>>>> check for effect end <<<<<<<<<<<<<<<<<<<<<;
	mov	ax,ds:[FrameCount]
	add	ax,10
	sub	ax,cx
	jb	NoEnd2
	stc
	ret
NoEnd2:
;>>>>>>>>>>>>>>>>>>> draw blured texts on screen <<<<<<<<<<<<<<<<;
	pusha
	call	FadeText
	popa
;>>>>>>>>>>>>>>>>>>> shede top and bottom of screen <<<<<<<<<<<<<;
	mov	esi,ds:[TabPtr]
	mov	edi,ds:[VramPtr]
	add	edi,320*16*2

	push	esi
	mov	dx,2
ShadeScreen:
	mov	bp,320
ShadeCopyScreen:
	and	word ptr [esi],30+30*32+30*1024
	shr	word ptr [esi],1
	add	esi,2
	dec	bp
	jnz	ShadeCopyScreen
	add	esi,320*2*(200-32-2)
	dec	dx
	jnz	ShadeScreen
	pop	esi
;------------------------------------;
	mov	dx,3dah
@CopySc1:
	in	al,dx
	and	al,8
	jz	@CopySc1
;------------------------------------;
	mov	ax,ds:[FrameCount]
	sub	cx,ax
	or	ch,ch
	jnz	NoFadeOut
	mov	ax,cx
	jmp	StartFade
NoFadeOut:
	or	ah,ah
	jnz	NormalCopy
StartFade:
	shr	ax,1
	mov	bx,ax
	shr	esi,1
@fade_loop1:
	mov	ax,[esi+esi]
	push	bx
	call	FadePixel
	mov	dx,ax
	and	ax,7FE0h
	add	ax,dx
	mov	[edi],ax
	inc	si
	add	edi,2
	pop	bx
	cmp	si,320*(200-32)
	jnz	@fade_loop1
	clc
	ret
;------------------------------------;
NormalCopy:
;	mov	ecx,320*(200-32)/2
;	rep	lmovsd

	mov	cx,320*(200-32)/2
Convertto16bpp:
	mov	eax,[esi]
	add	esi,4
	mov	edx,eax
	and	eax,7FE07FE0h
	add	eax,edx
	mov	[edi],eax
	add	edi,4
	dec	cx
	jnz	Convertto16bpp

	clc
	ret
CopyScreen	ENDP
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;........8x6 font table (26 chars).........
FontTab:
include font.inc


;.....some useful variables........

tpi128		dd 0.024543693
t128pi		dd 40.743686
t256		dw 256
t128		dw 128
t64		dw 64
t160		dw 160
t84		dw 84

t40		dw 40
t50		dw 50

t3		dw 3
t200		dw 200
t3600		dw 3600
t10		dw 10
t1div3600	dd 0.00027777

t30		dw 30
t5500		dw 5500
;/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\;
;-------------- uni use ---------------
TempWord	dw ?
Temp		dd 400 dup (?)
;--------- for radial bluring ---------
Rad_X		dd 320 dup (?)
Rad_Y		dd 320 dup (?)
Rad_Ypos	dw ?
Rad_V		dw ?
;------ for vesa initialization -------
VesaNfo:	db 40 		dup (?)
VramPtr		dd ?
		db (256-44)	dup (?)
;------- used in whole intro ----------
TabHandle	dw ?
CodeLinear	dd ?

FontOfs		dw ?
FontSeg		dw ?

;--------- for color mixixng ----------
multab		db 32*64	dup (?)
;---------- for raytracing ------------
SineTab		dw 256		dup (?)
TraceTab	dd 3*41*26 	dup (?)
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
CODE	ENDS

END	Start
