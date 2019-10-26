;	      =============================================
;	      ||	    I N T R U D E R S		 ||
;	      ||					 ||
;	      ||	 Version 2,  9 Mar 1997 	 ||
;	      ||					 ||
;	      ||     Copyright (C) B.W. van Schooten	 ||
;	      ||	 E-mail:  vicman@dds.nl 	 ||
;	      ||		Homepage:		 ||
;	      ||www.geocities.com/TimesSquare/Alley/3583/||
;	      =============================================
;
;			      INSTRUCTIONS
;			      ------------
;
;Aaargh! Intruders from outer space are attacking the earth! Keep them at bay
;with your plasma cannon. If any intruder manages to reach the earth's surface
;(the bottom of the screen), the earth will be taken and the human race thrown
;into slavery!
;
;LEFT	Right Alt
;RIGHT	Right Ctrl
;FIRE	Left shift
;
;You get one point for every intruder destroyed. Scoring is shown at the bottom
;left. The scoring is in Klingonese, to add to the atmosphere. And all that in
;256 bytes! It should be translated as follows:
;
;	SCORE=rightchar-32 + 256*(leftchar-32)
;
;The codes of the characters can be found in any good DOS manual. Anyway,
;any real computer freak should already know these codes by heart!



;COMPILING
;---------
;This thing should compile using either the freeware version of Arrow
;assembler, or TASM, MASM or A86. After assembly, you can link with the
;freeware VAL linker, using the option /CO (generate COM file).


code	segment public
	org	100h
	assume	cs: code
start:


;This bit is needed to make some assemblers compile segment overrides for
;implicit instructions.

cs_opc	EQU	2eh
ds_opc	EQU	3eh
es_opc	EQU	26h
ss_opc	EQU	36h

;ARROWASM doesn't support sign-extension of immediate word-operands with
;AND/OR/XOR. This is officially (?) a .186 addressing mode but most (?) 8086
;clones support this mode and some assemblers do support sign-extension
;in 8086 mode. Sign extension of AND/OR/XOR works analogous (uses the same
;bit) to what is used in the immediate ADD/ADC/SUB/SBB opcodes. For each
;occurrence of these opcodes, I have simply inserted the opcodes instead of
;the mnemonics.

andorxor_isw	equ	10000011b

and_isw_r_di	equ	11100111b
and_isw_m_bpdi	equ	00100011b




enemypos_ofs	equ	0;(0=hard wired!) 17*W screen position 0..1999


rndseed_ofs	equ	34;W


;assumed at start: ss=es=cs (which is documented specification for a COM)



	mov	bp,offset endofprg ;bp=start of heap

	mov	cx,18
	mov	ax,41

	mov	di,bp		;init enemypos_ofs & rndseed_ofs
repe	stosw


	mov	al,1		;ah still 0
	int	10h		;Set 40-char colour text, CLS

	mov	ax,1003h	;Palette func: Blink
	mov	bl,0		;blink OFF
	int	10h


	mov	si,-1		;si=bullet pos	<0=off



	mov	cx,0ff03h	;cl=3, shift constant
				;ch=level (255=easy 0=hard)

	mov	dx,0e029h	;dh=colour of ship/bullet
				;dl=player Xpos

	sub	di,di		;di=-> to enemy pos


mainloop:
	add	di,2			;NEXT enemy


	push	dx
	mov	dx,03dah
waitsync_end:
	in	al,dx
	test	al,8
	jz	waitsync_end		;wait for sync to end
waitsync_start:
	in	al,dx
	test	al,8
	jnz	waitsync_start		;wait for sync to start
	pop	dx


	mov	bx,40h
	mov	ds,bx			;ds=BDA.
	mov	al,[ds:bx-40h+17h];kb flags: b0=rshift b1=rshift b2=alt b3=ctrl

	mov	bx,0b800h
	mov	ds,bx		;ds=video mem


	mov	bl,dl
	mov	bh,8			;offsets from page 8

	mov	byte ptr[ds:bx+24*80-8*256],7 ;clear ship sprite



;	 test	 al,1			 ;right shift=quit
;	 jz	 noquit
;	 ret
;noquit:

	test	al,2			;left shift=shoot
	jz	nofire

	or	si,si
	jge	nofire
	lea	si,[bx+24*80-8*256]
	mov	byte ptr[ds:si],dh		;draw bullet sprite
nofire:

	test	al,4
	jz	nogoright
	add	dl,2
	cmp	dl,80
	jl	nogoright
	mov	dl,1
nogoright:

	test	al,8
	jz	nogoleft
	sub	dl,2
	jge	nogoleft
	mov	dl,79
nogoleft:


	sub	bx,bx			;bh=0


	or	si,si
	jl	nomovebul

	xchg	[ds:si],bl		;clear bullet sprite
	cmp	bl,dh			;bullet undisturbed?
	jne	collide

	sub	si,80
	jl	nomovebul

	mov	bl,dh
	xchg	[ds:si],bl		;draw bullet sprite
	test	bl,0f0h 		;test for collision
	jz	nocollide

collide:
	dec	ch			;increase level
	jne	nomaxlevel
	inc	ch
nomaxlevel:


	;scoring
	inc	byte ptr[ds:2000-78]
	jnz	noscorehibyte
	inc	byte ptr[ds:2000-80]
noscorehibyte:


	push	di

	mov	di,bx			;bh is still 0
	shr	di,cl
	mov	bx,[ss:bp+di]		;fetch pos of ufo that's hit
	call	clearufo		;clear ufo



	db	andorxor_isw, and_isw_m_bpdi,  127
	; = and     word ptr[ss:bp+di],127 ;ufo retreats to top of screen

	pop	di

	not	si			;disable bullet

nocollide:

nomovebul:



	mov	bh,8			;Page 8
	mov	bl,dl
	mov	byte ptr[ds:bx+24*80-8*256],dh ;draw ship sprite


	mov	ax,di
	mov	ah,ch
	shr	ah,cl
	shr	ah,1
	cmp	al,ah
	jl	noenemy


	push	ax

	mov	bx,[ss:bp+di]		;fetch enemy pos

	call	clearufo


;RND generator
	mov	al,[ss:bp+rndseed_ofs+1]
	rol	word ptr[ss:bp+rndseed_ofs],1
	and	al,1
	xor	[ss:bp+rndseed_ofs],al
;Output: al=0 or 1

	mov	ah,76
	mul	ah
	add	ax,2

	add	bx,ax
	mov	[ss:bp+di],bx

	pop	ax

	shl	al,cl
	call	drawufo

	cmp	bx,2000-160	;ufo reached bottom?
	jge	quit

noenemy:

	db	andorxor_isw, and_isw_r_di,  15
	; = and     di,15

	jmp	mainloop

quit:
	ret			;non-preferred method of exiting



;bx=screen pos
;O:al=0
clearufo:
	mov	al,0
;al=colour  bx=screen pos
drawufo:
	mov	byte ptr[ds:bx],al
	mov	byte ptr[ds:bx+2],al
	mov	byte ptr[ds:bx+4],al
	mov	byte ptr[ds:bx+78],al
	mov	byte ptr[ds:bx+82],al
	mov	byte ptr[ds:bx+86],al
	ret

endofprg:




code	ends
	end	start

