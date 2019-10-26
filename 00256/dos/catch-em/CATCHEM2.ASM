;	      =============================================
;	      ||	     C A T C H - E M		 ||
;	      ||					 ||
;	      ||	 Version 2, 10 Mar 1997 	 ||
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
;A bomb maniac is throwing bombs off the top of a wall and you have to prevent
;the bombs from going off by catching them in your pail of water. If you miss
;a bomb, it will hit the ground and explode, killing you!
;
;LEFT	Right Alt
;RIGHT	Right Ctrl
;
;You get one point for each level you manage to get through. The score is shown
;at the bottom left. It should be translated as follows:
;
;	SCORE = charactercode - 33
;
;The codes of the characters can be found in any good DOS manual.



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

and_isw_r_si	equ	11100110b





bombpos_ofs	equ	0;(0=hard wired!) 16*W screenpos 0..1999  <0=OFF

bombsleft_ofs	equ	32;B
rndseed_ofs	equ	33;W  must be inited with value != 0.

;assumed: es=cs=ss


	sub	ax,ax
	int	10h		;Set 16 colour mode, CLS

	mov	ax,1003h	;Palette func: Blink
	sub	bl,bl		;blink OFF
	int	10h


	mov	bp,offset endofprg ;bp=start of heap

	mov	ax,-1


	mov	cx,17
	mov	di,bp		;init bomb array, bombsleft_ofs, rndseed_ofs
repe	stosw			;only init lo byte of seed so it's more rnd


	mov	cx,05f8h	;cl: >0=bomb timeout counter <0=pause counter
				;ch=level (5=easy 1=hard)

	mov	di,39		;di=bomber pos

	mov	dx,0fe25h	;dh=bomber dir.
				;dl=player Xpos

	sub	si,si		;si=offset in bombpos_ofs of next free bomb


mainloop:

	mov	ah,ch
slowdown:

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

	dec	ah
	jge	slowdown



;UPDATE PAIL
	mov	bl,dl
	mov	bh,07h		;address += 700h

	mov	al,7
	call	drawpail


	mov	ds,[ss:bp-3]	;ds=BDA.

	mov	al,[ds:17h]	;kb flags: b0=rshift b1=rshift b2=alt b3=ctrl

	mov	ds,[ss:bp-2]	;ds=video mem


;	 test	 al,1
;	 jnz	 quit

	test	al,4
	jz	nogoright
	inc	dx
	inc	dx		;Assumed dl never carries over to dh!
	cmp	dl,80-10
	jl	nogoright
	mov	dl,79-10
nogoright:
	test	al,8
	jz	nogoleft
	sub	dl,2
	jge	nogoleft
	mov	dl,1
nogoleft:

	mov	bl,dl		;bh still 7h
	mov	al,0e0h
	call	drawpail



;UPDATE BOMBER
	inc	cl
	jg	bombernotpaused
	jl	bomberpaused
	inc	byte ptr[ds:2000-80]
	dec	ch
	jg	nomaxlevel
	inc	ch
nomaxlevel:

bombernotpaused:

	cmp	di,3
	je	flipbomber
	cmp	di,79-4
	je	flipbomber

	mov	al,[ss:bp+rndseed_ofs+1]
	rol	word ptr[ss:bp+rndseed_ofs],1
	test	al,10101001b
	jnz	noflipbomber
flipbomber:
	neg	dh
noflipbomber:
	and	al,1
	xor	[ss:bp+rndseed_ofs],al


	mov	byte ptr[ds:di-2],7
	mov	byte ptr[ds:di+2],7

	mov	al,dh
	cbw
	add	di,ax


;ADD BOMB
	sub	cl,2
	jg	nonewbomb

	mov	cl,4
	mov	[ss:bp+si+bombpos_ofs],di	;store pos. of new bomb

	dec	si

	db	andorxor_isw, and_isw_r_si,  30
	; = and     si,30			;jump to next free pos.

nonewbomb:

bomberpaused:


	mov	byte ptr[ds:di-2],0c0h
	mov	byte ptr[ds:di+2],0c0h




;UPDATE BOMBS
	push	si

	mov	si,30
drawbomb_loop:
	mov	bx,[ss:bp+si+bombpos_ofs]
	or	bx,bx
	jl	drawbomb_next

	mov	al,7h
	xchg	byte ptr[bx],al
	add	bx,80				;move bomb down
	or	al,[bx]
	test	al,020h 			;collision with pail?
	jz	drawbomb_nocol

	neg	bx				;deactivate bomb
	sub	byte ptr[ss:bp+bombsleft_ofs],3
	jnc	drawbomb_nonewlev
	mov	cl,-50				;pause for 50 ticks
drawbomb_nonewlev:
	jmp	short drawbomb_next

drawbomb_nocol:
	cmp	bh,8				;>=2048 => off-screen
	jge	popquit
	mov	byte ptr[bx],0d0h

drawbomb_next:
	mov	[ss:bp+si+bombpos_ofs],bx

	dec	si
	dec	si
	jge	drawbomb_loop

	pop	si



	jmp	mainloop


popquit:
	pop	si
	ret			;non-preferred method of exiting



;al=colour  bx=Xpos + 0700h
;O:bx undef
drawpail:
	mov	[bx-32	   ],al
	mov	[bx-32+80+2],al
	mov	[bx-32+80+4],al
	mov	[bx-32+80+6],al
	mov	[bx-32+   8],al
	ret



	db	40h		;BDA segment(2nd byte overlaps with next value)
	dw	0b800h		;graphics segment
endofprg:



code	ends
	end	start

