;--------------------------------------------------------------------
;                  StarPort Intro II V1.0
;--------------------------------------------------------------------
;              Copyright (C) 1993 Future Crew
;--------------------------------------------------------------------
;                        code: Psi
;                       music: Skaven
;--------------------------------------------------------------------
;    This code is released to the public domain. You can do
;    whatever you like with this code, but remember, that if
;    you are just planning on making another small intro by
;    changing a few lines of code, be prepared to enter the
;    worldwide lamers' club. However, if you are looking at
;    this code in hope of learning something new, go right 
;    ahead. That's exactly why this source was released. 
;    (BTW: I don't claim there's anything new to find here,
;    but it's always worth looking, right?) 
;--------------------------------------------------------------------
;    The code is optimized mainly for size but also a little
;    for speed. The goal was to get this little bbs intro to
;    under 2K, and 1993 bytes sounded like a good size. Well,
;    it wasn't easy, and there are surely places left one could 
;    squeeze a few extra bytes off...
;      Making a small intro is not hard. Making a small intro
;    with a nice feel is very hard, and you have to sacrifice
;    ideas to fit the intro to the limits you have set. I had
;    a lot of plans (a background piccy for example), but well,
;    the size limit came first.
;      I hope you enjoy my choice of size/feature ratio in this
;    intro! In case you are interested, this was a three evening
;    project (the last one spent testing).
;--------------------------------------------------------------------
;    You can compile this with TASM, but the resulting COM-file
;    will be a lot larger than the released version. This is
;    because all the zero data is included to the result. The
;    released version was first compiled to a COM file, and then
;    a separate postprocessing program was ran which removed all
;    the zero data from the end of the file. If you are just 
;    experimenting, recompiling is as easy as MAKE.BAT. If you
;    want to make this small again, you have to do some work as
;    well, and make your own postprocessor.
;--------------------------------------------------------------------

BORDERS=0	;set to 1 for visible border-timings

code 	SEGMENT para public 'CODE'
	ASSUME cs:code
	LOCALS
	.386

ORG	100h
start:	cld	;filler to make the filesize exactly 1993 bytes
	cld	;filler to make the filesize exactly 1993 bytes
	jmp	main

;±±±±±±±±±±±±±±±± setborder ±±±±±±±±±±±±±±±±
;descr: debug/change border color
setborder MACRO col
	IF BORDERS
	push	ax
	push	dx
	mov	dx,3dah
	in	al,dx
	mov	dx,3c0h
	mov	al,11h+32
	out	dx,al
	mov	al,col
	out	dx,al
	pop	dx
	pop	ax
	ENDIF
	ENDM

;€€€€€€€€€€€€€€€€ Simplex Adlib Player €€€€€€€€€€€€€€€€
;this doesn't just read raw data to output to adlib like the one
;used in the last starport intro. This player really does have 
;note & instrument data it reads and processes!

;±±±±±±±±±±±±±±±± output data to adlib ±±±±±±±±±±±±±±
a_lodsboutaw03: ;size optimization related entry (instrument loading)
	call	a_lodsboutaw
	add	ah,3
a_lodsboutaw: ;size optimization related entry (instrument loading)
	lodsb
a_outaw	PROC NEAR ;ah=reg,al=data
	push	ax
	push	cx
	xchg	al,ah
	mov	dx,388h
	out	dx,al
	mov	cx,7
	call	a_wait
	mov	dx,389h
	mov	al,ah
	out	dx,al
	mov	cx,30
	call	a_wait
	pop	cx
	pop	ax
	ret
a_wait:	in	al,dx
	loop	a_wait
	ret
a_outaw	ENDP

;±±±±±±±±±±±±±±±± load instrument to adlib ±±±±±±±±±±±±±±
a_loadinstrument PROC NEAR
	;bx=channel, ds:si=offset to instrument data
	mov	ah,ds:a_inst_table[bx]
	mov	cx,4
@@1:	call	a_lodsboutaw03
	add	ah,20h-3
	loop	@@1
	add	ah,40h
	call	a_lodsboutaw03
	mov	ah,bl
	add	ah,0c0h
	jmp	a_lodsboutaw
a_loadinstrument ENDP

;±±±±±±±±±±±±±±±± set note on/off ±±±±±±±±±±±±±±
a_playnote PROC NEAR
	;bx=channel, ax=data
	push	bx
	xchg	ah,bl
	add	ah,0a0h
	call	a_outaw
	mov	al,bl
	add	ah,010h
	pop	bx
	jmp	a_outaw
a_playnote ENDP

;±±±±±±±±±±±±±±±± initialize/clear/shutup adlib ±±±±±±±±±±±±±±
a_init PROC NEAR
	mov	ax,00120h
	call	a_outaw
	mov	ax,00800h
	call	a_outaw
	mov	ah,0bdh
	call	a_outaw
	mov	bp,9
	xor	bx,bx
	mov	di,OFFSET music_instruments
@@1:	mov	si,ds:[di]
	add	di,2
	call	a_loadinstrument
	xor	ax,ax
	call	a_playnote
	inc	bx
	dec	bp
	jnz	@@1	
	ret
a_init ENDP

;±±±±±±±±±±±±±±±± advance music one row ±±±±±±±±±±±±±±
a_dorow PROC NEAR
	sub	ds:a_musiccnt,1
	jnc	@@0
	mov	ds:a_musiccnt,music_speed
	mov	cx,music_channels
	mov	di,OFFSET music_patterns
	xor	bx,bx
@@1:	sub	ds:a_chdelaycnt[bx],1
	jns	@@2
	mov	si,ds:[di]	
	xor	ax,ax
	call	a_playnote
@@4:	lodsb	
	or	al,al
	jz	@@7
	jns	@@6
	sub	al,81h
	mov	ds:a_chdelay[bx],al
	lodsb
@@6:	mov	dl,al
	and	ax,15
	mov	bp,ax
	add	bp,bp
	mov	ax,ds:a_note_table[bp]
	shr	dl,2
	and	dl,not 3
	add	ah,dl
	call	a_playnote
	mov	al,ds:a_chdelay[bx]
	mov	ds:a_chdelaycnt[bx],al
	mov	ds:[di],si
@@2:	add	di,4
	inc	bx
	loop	@@1
@@0:	ret
@@7:	mov	si,ds:[di+2]
	jmp	@@4
a_dorow ENDP

;€€€€€€€€€€€€€€€ Intro Routines €€€€€€€€€€€€€€€€€€€€

;±±±±±±±±±±±±±±±± sin/cos ±±±±±±±±±±±±±±±±
;entry: ax=angle (0..65535)
; exit: ax=muller (-127..127)
addwcos:add	ax,ds:[bx] ;optimized entry for wavesets
	mov	ds:[bx],ax
cos:	add	ax,16384
sin:	mov	bx,ax
	mov	cx,bx
	and	cx,1023
	neg	cx
	add	cx,1023
	shr	bx,10
	mov	ah,ds:sintable[bx]
	xor	al,al
	imul	cx
	push	ax
	push	dx
	mov	ah,ds:sintable[bx+1]
	xor	al,al
	neg	cx
	add	cx,1023
	imul	cx
	pop	bx
	pop	cx
	add	ax,cx
	adc	dx,bx
	shrd	ax,dx,11
	ret

;±±±±±±±±±±±±±±±± rand ±±±±±±±±±±±±±±±±
;returns a random value in range -4096..4095
rand	PROC NEAR
	mov	eax,1107030247
	mul	ds:seed
	add	eax,97177
	mov	ds:seed,eax
	shr	eax,15
	and	ax,8191
	sub	ax,4096
;size optimizatin, some code moved from after all rand calls
	add	bx,2
	mov	ds:[bx],ax
	ret
rand	ENDP

;±±±±±±±±±±±±±±±± timer ±±±±±±±±±±±±±±±±
inittimer PROC NEAR
	mov	eax,fs:[8*4]
	mov	ds:oldint8,eax
	mov	ax,cs
	shl	eax,16
	mov	ax,OFFSET intti8
	mov	dx,17000 ;70hz
	jmp	@@1
deinittimer:
	mov	eax,ds:oldint8
	xor	dx,dx
@@1:	cli
	mov	fs:[8*4],eax
	mov	al,036h
	out	43h,al
	mov	al,dl
	out	40h,al
	mov	al,dh
	out	40h,al
	sti
	ret
inittimer ENDP

intti8	PROC FAR ;timer interrupt
	push	ax
	mov	al,20h
	out	20h,al
	inc	cs:framecounter
	pop	ax
	iret
intti8	ENDP

;±±±±±±±±±±±±±±±± load indexed palette ±±±±±±±±±±±±±±
setpal	PROC NEAR
	;ds:si=pointer to colorindices
	mov	dx,3c8h
	xor	al,al
	out	dx,al
	inc	dx
	mov	cx,8
@@1:	xor	bh,bh
	mov	bl,ds:[si]
	shr	bl,2
	call	setpl2
	mov	bl,ds:[si]
	shl	bx,2
	call	setpl2
	inc	si
	loop	@@1
	ret
setpl2:	and	bx,15*2
	mov	ax,word ptr ds:col0[bx]
	out	dx,al
	mov	al,ah
	out	dx,al
	mov	al,ds:col0[bx+2]
	out	dx,al
	ret
setpal	ENDP

;±±±±±±±±±±±±±± clear & copy videobuffer to screen ±±±±±±±±±±±±±±
clearcopy PROC NEAR
;---copy/clear buf
	xor	edx,edx
	mov	si,OFFSET vbuf
	mov	bx,4
	mov	cx,200
	mov	di,-4
@@1:	mov	bp,5
@@2:	REPT	2
	mov	eax,ds:[si]
	add	di,bx
	mov	ds:[si],edx
	add	si,bx
	mov	es:[di],eax
	ENDM
	dec	bp
	jnz	@@2
	add	si,bx
	dec	cx
	jnz	@@1
	ret
clearcopy ENDP

;±±±±±±±±±±±±±± draw a small pixel ±±±±±±±±±±±±±±
pset1	PROC NEAR ;ds:di=destination center, si=xmask offset
	mov	al,ds:colb[si]
	or	ds:[di],al
@@1:	ret
pset1 	ENDP

;±±±±±±±±±±±±±± draw a big pixel (depending on Z) ±±±±±±±±±±±±±
pset2	PROC NEAR ;ds:di=destination center, si=xmask offset
	mov	ax,ds:colbww[si]
	or	ds:[di+0],ax
	or	ds:[di+44],ax
	cmp	bp,8300 ;zcompare for size
	jl	pset3
	;smaller one
	mov	ax,ds:colbw[si]
	or	ds:[di-44],ax
	or	ds:[di+88],ax
	mov	ax,ds:colbv[si]
	or	ds:[di-88],ax
	or	ds:[di+132],ax
	ret
pset3:	;larger one
	or	ds:[di-44],ax
	or	ds:[di+88],ax
	mov	ax,ds:colbw[si]
	or	ds:[di-88],ax
	or	ds:[di+132],ax
	ret
pset2 	ENDP

;±±±±±±±±±±±±±± add a letter composed of big dots to dotlist ±±±±±±±±±±±±±
letter3d PROC NEAR
	;bx=letter
	;si=basex
	;bp=basey
	sub	bx,'A'
	jc	@@0
	shl	bx,3
	mov	di,ds:nextdot
	mov	cx,8
@@1:	push	cx
	push	si
	mov	cx,8
@@2:	cmp	ds:font[bx],0
	je	@@3
	mov	ds:dots[di],si
	mov	ds:dots[di+2],bp
	;zsinus
	push	si
	add	si,ds:sinus1
	sar	si,6
	and	si,63
	mov	al,ds:sintable[si]
	cbw
	pop	si
	shl	ax,2
	mov	ds:dots[di+4],ax
	;
	mov	word ptr ds:dots[di+6],OFFSET pset2
	add	di,8
	and	di,DOTNUM1*8-1
@@3:	inc	bx
	add	si,LETTERDOTSPACING
	loop	@@2
	pop	si
	add	bx,320-8
	add	bp,LETTERDOTSPACING
	pop	cx
	loop	@@1
	mov	ds:nextdot,di
@@0:	ret
letter3d ENDP

;±±±±±±±±±±±±±± calc 2x2 rotation matrix ±±±±±±±±±±±±±
set3drot PROC NEAR
	;ax=angle,ds:di=pointer to matrix
	push	ax
	call	sin
	mov	ds:[di+r01-r00],ax
	neg	ax
	mov	ds:[di+r10-r00],ax
	pop	ax
	call	cos
	mov	ds:[di+r00-r00],ax
	mov	ds:[di+r11-r00],ax
	ret
set3drot ENDP

;±±±±±±±±±±±± rotate point with 2x2 rotation matrix (innerpart) ±±±±±±±±±±±±±
rotate2x2i PROC NEAR
	;(di,bp)->(cx) with matrix half at ds:si
	;this is the inner part, called twice
	push	bx
	mov	ax,di
	imul	word ptr ds:[si]
	mov	cx,ax
	mov	bx,dx
	mov	ax,bp
	imul	word ptr ds:[si+2]
	add	cx,ax
	adc	bx,dx
	shrd	cx,bx,14
	pop	bx
	add	si,4
	ret
rotate2x2i ENDP

;±±±±±±±±±±±±±± advance demo one frame (raw work) ±±±±±±±±±±±±±
doit	PROC NEAR
;======wait for border
	setborder 0
	mov	dx,3dah
@@w1:	in	al,dx
	test	al,8
	jnz	@@w1
@@w2:	in	al,dx
	test	al,8
	jz	@@w2
	setborder 30
;======done
	mov	si,ds:index
	push	si
	call	setpal
	pop	si
	add	si,9
	cmp	si,OFFSET index4
	jbe	@@i2
	mov	si,OFFSET index1
@@i2:	mov	ds:index,si
	mov	al,2
	mov	ah,ds:[si+8]
	mov	dx,3c4h
	out	dx,ax
	call	clearcopy
;======do timer simulation stuff
	setborder 28
	xor	cx,cx
	mov	ds:scrollsubber,0
	xchg	cx,ds:framecounter
	jcxz	@@78
@@77:	push	cx
	add	ds:scrollsubber,SCROLLSPEED
	call	doit70
	pop	cx
	loop	@@77
	setborder 26
@@78:;======
;---redraw dots
	mov	cx,DOTNUM
	mov	bx,OFFSET dots
@@1:	push	cx
	push	bx
	mov	bp,ds:[bx+2]
	mov	di,ds:[bx+4]
	cmp	word ptr ds:[bx+6],OFFSET pset2
	jne	@@5
	;ysinus
	mov	cx,ds:[bx]
	mov	si,ds:sinus2
	add	si,cx
	sar	si,7
	and	si,63
	mov	al,ds:sintable[si]
	cbw
	shl	ax,2
	add	bp,ax
	;scroll
	sub	cx,ds:scrollsubber
	mov	ds:[bx],cx
	cmp	cx,-3900
	jl	@@7
	cmp	cx,3900
	jg	@@7
@@5:	;--rotate coordinates
	mov	si,OFFSET r00
	call	rotate2x2i
	push	cx
	call	rotate2x2i
	pop	di
	mov	bp,ds:[bx]
	mov	si,OFFSET p00
	push	cx
	call	rotate2x2i
	push	cx
	call	rotate2x2i
	pop	bp
	pop	di
	;bp=Z, cx=X, di=Y
	add	bp,ds:zadder
	cmp	bp,1024
	jl	@@7
	;--project
	mov	ax,256
	imul	di
	idiv	bp
	add	ax,100
	mov	di,ax
	mov	ax,307
	imul	cx
	idiv	bp
	add	ax,160
	mov	si,ax
	;si=SX, di=SY
	mov	ax,ds:[bx+6]
	cmp	si,319
	ja	@@7
	cmp	di,199
	ja	@@7
	;calc dest address & xmask offset
	add	di,di
	mov	di,ds:rows[di]
	add	si,si
	add	di,ds:cols[si]
	;
	call	ax
@@7:	pop	bx
	pop	cx
	add	bx,8
	dec	cx
	jnz	@@1
	ret
doit	ENDP

;±±±±±±±±±±±±±± advance demo counters 1/70 sec ±±±±±±±±±±±±±
;a separate routine is used to get frame syncronization for
;slower machines (and slow vga cards)
doit70	PROC NEAR
;---add sinuses & udforce
	add	ds:sinus1,70
	add	ds:sinus2,177
	add	ds:udforced,3000
;---set wave1
	mov	bx,OFFSET wwave
	mov	ax,77
	call	addwcos
	sar	ax,5
	mov	ds:wave1,ax
;---set zadder
	mov	bx,OFFSET zwave
	mov	ax,370
	call	addwcos
	sar	ax,3
	add	ax,8888
	mov	ds:zadder,ax
;---set 3d rotate YZ
	mov	bx,OFFSET udwave
	mov	ax,ds:wave1
	call	addwcos
	imul	ds:udforce
	shrd	ax,dx,8
	mov	di,OFFSET r00
	call	set3drot
;---set 3d rotate XZ
	mov	bx,OFFSET lrwave
	mov	ax,200
	call	addwcos
	sar	ax,1
	mov	di,OFFSET p00
	call	set3drot
;---add more text to 3d scroller
	sub	ds:textcnt,SCROLLSPEED
	jnc	@@t1
	mov	ds:textcnt,LETTERDOTSPACING*8-1
	mov	si,ds:text
	mov	bl,ds:[si]
	IFDEF XORTEXTS
	xor	bl,17h
	ENDIF
	and	bx,255
	jz	@@t3
	inc	si
	mov	ds:text,si
	cmp	bl,32
	jge	@@t4
	shl	bx,SCROLLDELAYSHL
	mov	ds:textcnt,bx
	jmp	@@t1
@@t4:	mov	bp,0
	mov	si,4100
	call	letter3d
	jmp	@@t1
@@t3:	mov	si,OFFSET text0
	mov	ds:text,si
@@t1:	;;;
;======adlib music
	jmp	a_dorow
doit70	ENDP

;€€€€€€€€€€€€€€€€ Main routine €€€€€€€€€€€€€€€€
;stack @ cs:0fffeh

main	PROC NEAR
;ÕÕÕÕÕÕÕÕÕ Zero Zerodata & Init Segs ÕÕÕÕÕÕÕ
.8086	;;;
	push	cs
	push	cs
	pop	ds
	pop	es
	mov	cx,(zeroend-zerobeg)/2
	mov	di,OFFSET zerobeg
	xor	ax,ax ;zero used later
	rep	stosw
	mov	dx,0a000h
	mov	es,dx
;segments now set: DS=code/data ES=vram
;ÕÕÕÕÕÕÕÕÕ Check for 386 ÕÕÕÕÕÕÕÕÕ
	push	sp
	pop	dx
	cmp	dx,sp
	jz	@@o1
@@o2:	jmp	endansi ;80(1)86
.286p	;;;
@@o1:	mov	bx,OFFSET rows
	sgdt	ds:[bx]
	cmp	byte ptr ds:[bx+5],0
	js	@@o2
;ÕÕÕÕÕÕÕÕÕ Check for VGA ÕÕÕÕÕÕÕÕÕ
.386p	;;;
	mov	fs,ax ;ax was zero
;segments now set: DS=code/data ES=vram FS=zeropage
	mov	ax,1a00h
	int	10h
	cmp	al,01ah
	jne	endansi ;no vga
	cmp	bl,7
	jb	endansi ;no vga
;ÕÕÕÕÕÕÕÕÕ Initialize - doinit 0 ÕÕÕÕÕÕÕÕÕ
	;copy vga font to font buffer
	mov	ax,13h
	int	10h
	mov	cx,'Z'-'A'+1
	mov	bx,16
	mov	ax,'A'+0eh*256
@@a1:	int	10h
	inc	al
	loop	@@a1
	mov	cx,8*320/2
	mov	bx,OFFSET font
	xor	di,di
@@a2:	mov	ax,es:[di]
	mov	ds:[di+bx],ax
	add	di,2
	loop	@@a2
;ÕÕÕÕÕÕÕÕÕ Initialize - vga ÕÕÕÕÕÕÕÕÕ
	;init videomode 320x200x16
	mov	ax,0dh
	int	10h
	;set up rows/cols/etc
	mov	si,-2
	mov	di,OFFSET vbuf-44
	mov	bl,128
	xor	bp,bp
	jmp	@@b5
@@b1:	mov	ds:rows[si],di
	mov	ds:colb[si],bl
	mov	ds:colbww[si],cx
	shr	cl,1
	rcr	ch,1
	mov	ds:colbw[si],dx
	shr	dl,1
	rcr	dh,1
	mov	ds:colbv[si],ax
	shr	al,1
	rcr	ah,1
	mov	ds:cols[si],bp
	ror	bl,1
	jnc	@@b4
	inc	bp
@@b5:	mov	cx,0000000011111110b
	mov	dx,0000000001111100b
	mov	ax,0000000000111000b
@@b4:	add	di,44
	add	si,2
	cmp	si,(320)*2
	jle	@@b1
	;set simplex palette order (16 color mode)
	mov	dx,3dah
	in	al,dx
	mov	dl,0c0h
	xor	ax,ax
	mov	cx,16
@@b2:	out	dx,al
	out	dx,al
	inc	al
	loop	@@b2
	mov	al,20h
	out	dx,al
;ÕÕÕÕÕÕÕÕÕ Initialize - doinit ÕÕÕÕÕÕÕÕÕ
	mov	cx,DOTNUM
	mov	bx,OFFSET dots-2
@@c1:	push	cx
	call	rand
	call	rand
	call	rand
	sar	ax,2
	mov	ds:[bx],ax
	add	bx,2
	mov	word ptr ds:[bx],OFFSET pset1
	pop	cx
	loop	@@c1
;ÕÕÕÕÕÕÕÕÕ Initialize - others ÕÕÕÕÕÕÕÕÕ
	call	a_init
	call	inittimer
;ÕÕÕÕÕÕÕÕÕ Do the intro stuff ÕÕÕÕÕÕÕÕÕ
again:	call	doit
	mov	ah,1
	int	16h
	jz	again
	mov	ah,0
	int	16h
;ÕÕÕÕÕÕÕÕÕ DeInitialize ÕÕÕÕÕÕÕÕÕ
	call	deinittimer
	call	a_init ;reinitializing adlib shuts it up
;ÕÕÕÕÕÕÕÕÕ Display end ansi (only thing done if no 386 or vga) ÕÕÕÕÕÕÕÕÕ
endansi:mov	ax,3h
	int	10h
	mov	si,OFFSET endtext
	push	0b800h	;if the user has an MGA or HGC
	pop	es	;it's not my problem :-)
	xor	di,di
	mov	ah,0eh
@@1:	lodsb
	IFDEF XORTEXTS
	xor	al,17h
	ENDIF
	cmp	al,31
	jae	@@2
	mov	ah,al
	jmp	@@1
@@2:	jz	@@3
	stosw
	jmp	@@1
@@3:	mov	ax,4c00h
	int	21h
main	ENDP
	
;€€€€€€€€€€€€€€€€ Initialized (nonzero) data €€€€€€€€€€€€€€€€

;pointer & delay counter for scrolltext
text	dw	OFFSET text0
textcnt	dw	1

;3d rotation values (more in zerodata)
udforced LABEL DWORD
	dw	0
udforce	dw	64
lrwave	dw	-20000
zwave	dw	16000

sintable LABEL BYTE ;sine table (circle is 64 units)
db 0,12,24,36,48,59,70,80,89,98,105,112,117,121,124,126,127,126
db 124,121,117,112,105,98,89,80,70,59,48,36,24,12,0,-12,-24,-36
db -48,-59,-70,-80,-89,-98,-105,-112,-117,-121,-124,-126,-127
db -126,-124,-121,-117,-112,-105,-98,-89,-80,-70,-59,-48,-36
db -24,-12,0,3,6,9,12,15,18,21,24,27,30,33,36,39,42,45,48,51,54
db 57,59,62,65,67,70

;adlib player data
a_inst_table LABEL BYTE
	db 20h+0,20h+1,20h+2,20h+8,20h+9,20h+10,20h+16,20h+17,20h+18
NTB equ 8192 ;+1024*1
a_note_table LABEL WORD
	dw NTB+363,NTB+385,NTB+408,NTB+432,NTB+458,NTB+485
	dw NTB+514,NTB+544,NTB+577,NTB+611,NTB+647,NTB+868
	;note: a zero word is expected after this table (found in col0)
	
col0	db	 0, 0, 0 ,0	;background color
col1	db	 0,15,35 ,0	;delay color 3
col2	db	16,30,48 ,0	;delay color 2
col3	db	32,45,55 ,0	;delay color 1
col4	db	60,61,62 	;brightest color
	;1	. x . x . x . x . x . x . x . x
	;2	. . x x . . x x . . x x . . x x
	;4	. . . . x x x x . . . . x x x x
	;8	. . . . . . . . x x x x x x x x
;palette indices for 4 palettes. Last number is bitplane to write
;during the frame having this palette
index1	db	04h,34h,24h,34h,14h,34h,24h,34h	,1 ;1248
index2	db	03h,23h,13h,23h,44h,44h,44h,44h	,8 ;8124
index3	db	02h,12h,44h,44h,33h,33h,44h,44h	,4 ;4812
index4	db	01h,44h,33h,44h,22h,44h,33h,44h	,2 ;2481
index	dw	OFFSET index1 ;offset to current index

;################## Music - (tune by skaven/fc) ###################
;generated with ST3->SIMPLEXADLIB, handoptimized by psi (283 bytes)
music_channels equ 8
music_speed equ 8
music_instruments LABEL BYTE
dw OFFSET ains6
dw OFFSET ains2
dw OFFSET ains4
dw OFFSET ains3
dw OFFSET ains3
dw OFFSET ains1
dw OFFSET ains1
dw OFFSET ains4
ains1 LABEL BYTE
db 65,194,6,0,35,242,240,240,1,0,4
ains2 LABEL BYTE
db 145,64,135,128,243,111,35,3,1,1,2
ains3 LABEL BYTE
db 225,33,17,128,17,19,34,34,0,0,12
ains4 LABEL BYTE
db 97,33,27,0,98,132,86,85,0,0,14
ains6 LABEL BYTE
db 145,64,135,136,243,111,35,3,1,1,2
music_patterns LABEL BYTE
ach0 dw OFFSET ach0d,OFFSET ach0dr
ach1 dw OFFSET ach1d,OFFSET ach1dr
ach2 dw OFFSET ach2d,OFFSET ach2dr
ach3 dw OFFSET ach3d,OFFSET ach3d
ach4 dw OFFSET ach4d,OFFSET ach4d
ach5 dw OFFSET ach5d,OFFSET ach5d
ach6 dw OFFSET ach6d,OFFSET ach6d
ach7 dw OFFSET ach7d,OFFSET ach7d
ach0d LABEL BYTE
db 081h
ach0dr LABEL BYTE
db 057h,050h,050h,055h,057h,050h,055h,057h
db 050h,055h,057h,050h,055h,057h,050h,055h
db 0
ach1d LABEL BYTE
db 081h
ach1dr LABEL BYTE
db 050h,055h,057h,050h,055h,057h,050h,055h
db 057h,050h,055h,057h,050h,055h,057h,050h
db 0
ach2d LABEL BYTE
db 0C0h,050h,084h
db 030h,020h,030h,020h,02Ah,01Ah,02Ah,01Ah
db 030h,020h,030h,020h,02Ah,01Ah,02Ah,01Ah
ach2dr LABEL BYTE
db 030h,020h,030h,020h,02Ah,01Ah,02Ah,01Ah
db 025h,015h,025h,015h,028h,018h,02Ah,01Ah
db 0
ach3d LABEL BYTE
db 0A0h,050h,040h,0C0h,040h,088h,040h,040h
db 03Ah,042h,090h,045h,088h,040h,042h,040h
db 047h,090h,04Ah,088h,045h,098h,040h
db 0
ach4d LABEL BYTE
db 0A0h,050h,030h,0C0h,047h,088h,047h,043h
db 042h,045h,047h,045h,048h,047h,047h,050h
db 052h,084h,050h,04Ah,088h,050h,098h,045h
db 0
ach5d LABEL BYTE
db 0C0h,020h,0A0h,010h,010h,090h,010h,02Ah
db 025h,088h,028h,02Ah,090h,010h,02Ah,025h
db 088h,028h,02Ah
db 0
ach6d LABEL BYTE
db 0C0h,020h,0A0h,020h,020h,090h,020h,01Ah
db 015h,088h,018h,01Ah,090h,020h,01Ah,015h
db 088h,018h,01Ah
db 0
ach7d LABEL BYTE
db 0C0h,00Ch,0FEh,050h,090h,00Ch,081h,04Ah
db 050h,084h,052h,055h,086h,04Ah,081h,050h
db 04Ah,086h,050h,082h,055h,098h,045h
db 0
;#########################################################

SCROLLSPEED equ	90
SCROLLDELAYSHL equ 9
LETTERDOTSPACING equ 128

db 0fch

text0	LABEL BYTE ;scrolltext (numbers are delays)
	db	31,25,'CALL STARPORT',9,'FUTURE CREW WORLD HQ',9,'CDN',9,'GRAVIS EURO',9,'AND MORE',0

endtext	LABEL BYTE ;endansi... well... endansiline (numbers are colors)
	db	15
	db	'StarPort'
	db	3,' ƒƒ ',11
	db	'V32bis +358-0-8044626'
	db	' +358-0-8041133'
	db	3,' ƒƒ ',15
	db	'FC-WHQ'
	db	31
endtext1 LABEL BYTE

db 0fch

;€€€€€€€€€€€€€€€€ Uninitialized (zero) data €€€€€€€€€€€€€€€€

zerobeg	LABEL WORD ;start zero clear from here

rows	dw	320 dup(0)	;offsets to screen rows
cols	dw	320 dup(0)	;offsets to screen cols
colb	db	320 dup(0,0)	;bitmasks for screen cols
colbv	dw	320 dup(0)	;wide -"-
colbw	dw	320 dup(0)	;wider -"-
colbww	dw	320 dup(0)	;very wide -"-

ALIGN 4
	db	44*8 dup(0) ;negative overflow for videobuffer
vbuf	LABEL BYTE
	db	44*200 dup(0) ;video buffer
	db	44*8 dup(0) ;positive overflow for videobuffer

ALIGN 4
font	LABEL BYTE
	db	8 dup(320 dup(0)) ;font buffer


DOTNUM1	equ	256	;number of dots used for text
DOTNUM	equ	444	;total number of dots
ALIGN 4
dots	LABEL WORD
	dw	DOTNUM dup(0,0,0,0) ;x,y,z,routine data for each dot
	
;2x2 rotation matrices
r00 	dw	0
r10 	dw	0
r01 	dw	0
r11 	dw	0
p00 	dw	0
p10 	dw	0
p01 	dw	0
p11 	dw	0

;zero initialized 3d rotation stuff
zadder	dw	0
wave1	dw	0
udwave	dw	0
wwave	dw	0
sinus1	dw	0
sinus2	dw	0

;adlib data
a_musiccnt dw	0
a_chdelaycnt db	9 dup(0)
a_chdelay db	9 dup(0)
ALIGN 2

;misc
nextdot	dw	0
scrollsubber dw	0
framecounter dw	0
oldint8	dd	0
seed	dd	0

padder	db	16 dup(0)
zeroend	LABEL WORD ;end zero clear here

code 	ENDS
	END start
