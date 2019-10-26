;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;          ú
;          . ÛÛÛßßÛÜ  ÜÛÛßßßß  ÜÛßßÜ  ÛÛÛ     ÛÛÛ ÛÛÛÛÛÜ  ÛÛ  ÛÛÛ ú
;          : ÛÛÛÜÜÛß  ÛÛÛÜÜ   ŞÛÛÜÜÛİ ÛÛÛ     ÛÛÛ    ßÛÛİ ßÛÜÜÛÛÛ :
;          ³ ÛÛÛ ßÛÛÜ ÛÛÛ     ÛÛÛ  ÛÛ ŞÛÛÜ    ÛÛÛ     ÛÛÛ     ÛÛÛ |
;  Ú Ä ÄÍÄÍ¼ ßßß   ßßß ßßßßßß ßßß  ßß  ßßßßßß ßßß     ßßß ßßßßßß  ÀÄÄ Ä -ÄÄÄ¿
;  ³ ÜÛßßÜ ÛÛßßÜ ÛÛ    ÛÛ ÛÛßßÜ   ßßßÛÜ ÛÛßßÜ ÜÛßßÜ ÜÛßßÜ ÛÛ  Û ÜÛßßß ÛÛßßÜ :
;  | ÛÛßßÛ ÛÛ  Û ÛÛ    ÛÛ ÛÛßßÜ      ÛÛ ÛÛßßÜ ÛÛßßÛ ÛÛ  Ü ÛÛßßÜ ÛÛß   ÛÛßßÜ .
;  : ßß  ß ßßßß   ßßßß ßß ßßßß       ßß ßß  ß ßß  ß  ßßß  ßß  ß  ßßßß ßß  ß ú
;                                version 1.0a
;
;                        Code by SHAYDE/REALITY Feb 95
;
;                                    - * -
;
; Feel free to use/hack this code about as much as you like.  In the good old
; dayz of Amiga, ALL tracker writers gave away player source-code so that the
; coder could do what he/she wanted with it.  On PC every tracker writer thinks
; their player code should be protected and they either don't release a player
; or they release it in .OBJ format which means if you need to make changes to
; the code to fit in with your demo/intro you're fucked!!!  So message to all
; tracker writers out there:
; FOR THE SAKE OF CODER SANITY, ALWAYS RELEASE PLAYER CODE FOR YOUR TRACKERS!!
; OTHERWISE WOT'S THE POINT OF WRITING A TRACKER?!?!??!?!  And release it in
; source-code form to reduce head-aches!
;
;				     - * -
;
; This source-code doesn't contain any segment directives so it is only
; INCLUDEable in other source-code.  Also it requires a minimum of a 286
; to run.  I avoided using ASSUMEs so that the code that INCLUDEs this code
; doesn't lose it's ASSUMEs, hence variables are accessed via CS:.  You can
; save a few bytes by dropping them (which you'll need to do if you want to
; use this player in protected-mode), although I use DS: to reference the
; tune segment.
;
;				     - * -
;
; INSTRUCTIONS FOR USE:
;
;	To initialise the player, call "InitPlayer".
;	To stop play, call "EndPlayer".
;	To play music, call "PlayMusic" 50 times a second (18.2/sec for a
;					"slow-timer" tune).
;
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²

		locals
		jumps



; Tracker commands
cmPortamentoUp	=	1		; Portamento up
cmPortamentoDwn	=	2		; Portamento down
cmToneSlide	=	3		; Tone Slide: xx is speed of slide
cmToneVolSlide	=	5		; Tone slide of 00 + Vol. Slide
cmVolSlide	=	10		; Volume Slide: <50=down, >50=up
cmSetVol	=	12		; set volume
cmJumpToLine	=	13		; Jump to line in next track
cmSetSpeed	=	15		; set speed

FreqStart	=	156h		; low end of frequency in each octave
FreqEnd		=	2aeh		; high end of frequency in each octave
FreqRange	=	FreqEnd-FreqStart




;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; This routine initialises the player.
; IN:
;	ES:	- points to .RAD module to play
; OUT:
;	Carry	- set on error (such as invalid module)
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
InitPlayer:	pusha

		call	EndPlayer	; clear Adlib ready for tune

	; initialise certain Adlib registers that aren't changed
		mov	ax,0120h	; allow waveforms
		call	Adlib
		mov	ax,0800h
		call	Adlib
		mov	ah,0bdh		; no drums, etc.
		call	Adlib

	; check to see if it is a RAD file first
;		cmp	word ptr es:[0],'AR'
;		jnz	@@err
;		cmp	word ptr es:[2],' D'
;		jnz	@@err
;		cmp	byte ptr es:[16],10h		; correct version?
;		jnz	@@err

		mov	cs:ModSeg,es		; keep the segment of module

	; read initial speed
		mov	si,17
		mov	al,byte ptr es:[si]
		mov	ah,al
		and	al,1fh
		mov	cs:Speed,al

	; see if there's a description to skip
		inc	si
		test	ah,80h			; description flag
		jz	@@lc			; no description

		xor	al,al
		jmp	@@le

	@@ld:	inc	si
	@@le:	cmp	es:[si],al		; look for null-termination
		jnz	@@ld
		inc	si			; move past null

	; create table of instrument pointers
	@@lc:	xor	bx,bx

	@@la:	mov	bl,es:[si]		; instrument no.
		inc	si
		add	bx,bx
		jz	@@lb			; no more instruments

		mov	cs:InstPtrs-2[bx],si	; record pointer to instrument
		add	si,11
		jmp	@@la

	; record offset of order list
	@@lb:	xor	ax,ax
		mov	al,es:[si]		; no. of orders in order-list
		mov	cs:OrderSize,ax
		inc	si
		mov	cs:OrderList,si
		xor	bx,bx
		mov	bl,es:[si]		; first pattern to play
		add	bx,bx
		add	si,ax			; move to end of list

	; record table of pattern offsets
		mov	cs:PatternList,si
		mov	ax,es:[si+bx]		; first pattern offset
		mov	cs:PatternPos,ax	; pointer to first pattern

	; initial pointers
		xor	ax,ax
		mov	cs:OrderPos,ax		; start at position 0.
		mov	cs:SpeedCnt,al
		mov	cs:Line,al		; start at line 0

		clc
		jmp	@@lx			; successful initialisation

	@@err:	stc
	@@lx:	popa
		ret





;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; This stops music playback (stops sound channels).
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
EndPlayer:	push	ax
		mov	ax,020h shl 8
	@@la:	call	Adlib
		inc	ah
		cmp	ah,00f6h
		jb	@@la
		pop	ax
		ret





;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; This routine does the actual playing.  It MUST be called 50 times a second
; to maintain accurate music playback.  Refer to accompanying timer source-code
; for ways of providing a 50/sec timer service.
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
PlayMusic:	pusha
		push	ds

		mov	ds,cs:ModSeg	; segment of module

		cmp	cs:SpeedCnt,0
		jz	@@la		; play a line of music
		dec	cs:SpeedCnt

	; no new line, so just update any effects
		call	UpdateNotes
		jmp	@@lx

	; switch off any effects that are in operation
	@@la:	mov	si,8
		xor	al,al

	@@laa:	mov	cs:PortSlide[si],al	; reset any slides
		mov	cs:VolSlide[si],al	; reset any slides
		mov	cs:ToneSlide[si],al	; reset any slides
		dec	si
		jns	@@laa

	; playing a new line, PatternPos should have been set-up already
		mov	si,cs:PatternPos
		or	si,si
		jz	@@lb		; rest of this pattern is blank

		mov	al,[si]		; line indicator
		and	al,7fh		; eliminate bit 7
		cmp	al,cs:Line	; is this current line?
		jnz	@@lb		; haven't reached it yet

		test	byte ptr [si],80h	; last line?
		jz	@@lc		; no, still more to check
		mov	cs:PatternPos,0	; mark rest of pattern as blank

	@@lc:	inc	si		; move to first channel

	; play channels
	@@lf:	mov	cl,[si]		; channel we are processing
		push	cx
		and	cl,7fh		; get rid of bit 7
		mov	ax,1[si]	; AL=octave/note, AH=inst/command
		add	si,3

		test	ah,15		; if there's a cmd, there'll be a param.
		jz	@@le		; no parameter byte
		mov	ch,[si]		; read parameter
		inc	si

	@@le:	call	PlayNote	; play the note

		pop	cx
		jc	@@lg		; skip rest of line, AX has new line

		test	cl,80h		; last channel to play?
		jz	@@lf		; not yet

		mov	cs:PatternPos,si; keep position in crunched track

	; update pointers
	@@lb:	mov	al,cs:Speed	; needs to be set AFTER note playing
		dec	al
		mov	cs:SpeedCnt,al	;    for new speeds to take effect!

		inc	cs:Line
		cmp	cs:Line,64	; end of pattern?
		jb	@@lx		; nope

		mov	cs:Line,0	; top of next pattern
		call	NextPattern

	@@lx:	pop	ds
		popa
		ret

	; jump to line AX
	@@lg:	mov	bl,cs:Speed	; needs to be set AFTER note playing
		mov	cs:SpeedCnt,bl	;    for new speeds to take effect!

		mov	cs:Line,al

		; find start of next pattern
		call	NextPattern
		jz	@@lx		; there isn't any data in next pattern

		; find line that is greater or equal to the current line
	@@ll:	mov	cl,[si]		; line id.
		and	cl,7fh		; ignore bit 7
		cmp	cl,al
		jae	@@lh		; found line

		test	byte ptr [si],80h
		jz	@@li		; not last line
		xor	si,si
		jmp	@@lh		; ignore rest of pattern as it's last

		; skip to next line definition
	@@li:	inc	si
	@@lj:	mov	cl,[si]
		add	si,3
		test	byte ptr cs:[si-1],15	; is there a valid command?
		jz	@@lk
		inc	si		; skip parameter

	@@lk:	add	cl,cl
		jnc	@@lj		; wasn't last channel spec.
		jmp	@@ll		; check next line

	@@lh:	mov	cs:PatternPos,si
		jmp	@@lx





;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Advances pointers to next pattern in order list.
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
NextPattern:	mov	bx,cs:OrderPos
		inc	bx
		cmp	bx,cs:OrderSize
		jb	@@ld
		xor	bx,bx		; end of tune, move back to start

	@@ld:	mov	cs:OrderPos,bx
		mov	si,cs:OrderList
		mov	bl,[si+bx]	; no. of next pattern

		test	bl,80h
		jz	@@lda
		and	bl,7fh
		jmp	@@ld		; bit 7 = jump to new order

	@@lda:	mov	si,cs:PatternList
		add	bx,bx
		mov	si,[si+bx]	; offset of next pattern
		mov	cs:PatternPos,si
		or	si,si
		ret





;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Plays a note on a channel.
; IN:
;	AL	- Octave (high nibble), Note (low nibble)
;	AH	- instrument (high nibble), command (low nibble)
;	CL	- channel to play note on (0..8)
;	CH	- parameter byte if command is non-zero
; OUT:
;	CARRY	- set if a line is to be jumped to
;	AX	- line to jump to if CARRY set
; Note: don't use SI or segment regs., otherwise registers do not need saving.
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
PlayNote:	mov	di,cx
		and	di,15
		mov	dh,ah
		and	dh,15		; command

		or	al,al
		jz	@@lb		; no note playing, process command

	; check to see if we are actually performing a tone slide
		cmp	dh,cmToneSlide
		jnz	@@lt		; nope, play note

		; note/octave are used as parameters then (instrument ignored)
		mov	bx,ax
		and	bx,15		; note
		shr	al,4
		and	ax,7		; octave
		dec	bx		; we want 1..12
		cmp	bx,12
		jae	@@lx		; not a valid note (probably KEY-OFF)

		imul	ax,FreqRange	; scale octave
		add	bx,bx
		add	ax,cs:NoteFreq[bx]	; add frequency of this note
		sub	ax,FreqStart	; so range starts from zero
		mov	cs:ToneSlideFreqL[di],al	; destination frequency
		mov	cs:ToneSlideFreqH[di],ah

		; set tone slide speed
		mov	byte ptr cs:ToneSlide[di],1	; switch tone slide on
		or	ch,ch
		jz	@@lx		; use last speed setting
		mov	cs:ToneSlideSpeed[di],ch
		jmp	@@lx

	; KEY-OFF the previous note
	@@lt:	push	ax
		mov	al,cs:OldB0[di]	; old register value
		and	al, not 20h	; clear KEY-ON bit
		mov	cs:OldB0[di],al	; so slides after KEYOFF work correctly
		mov	ah,cl
		add	ah,0b0h
		call	Adlib
		pop	ax

	; load instrument (if any)
		mov	dl,ah
		add	al,al
		rcr	dl,1
		shr	dl,3		; instrument no.
		jz	@@la		; no instrument to load
		call	LoadInst

	; load note into channel
	@@la:	mov	bl,al
		and	bx,15*2		; note * 2
		cmp	bx,15*2
		jz	@@lb		; just a KEY-OFF so we're done

		mov	bx,cs:NoteFreq-2[bx]	; frequency of note (BX-1)
		shr	al,3		; octave
		and	al,7*4
		or	al,20h		; KEY-ON
		or	al,bh		; Frequency high byte
		mov	ah,0b0h
		add	ah,cl
		mov	cs:OldB0[di],al	; record the register value
		push	ax

		sub	ah,10h
		mov	al,bl		; Frequency low byte
		mov	cs:OldA0[di],al
		call	Adlib

		pop	ax
		call	Adlib

	; process command (if any), DH has command, CH has parameter
	@@lb:	xor	bx,bx
		mov	bl,dh		; command
		add	bx,bx
		jmp	cs:Effects[bx]

	@@lx:	clc
	@@lxx:	ret
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Portamento up
@@PortUp:	mov	cs:PortSlide[di],ch
		jmp	@@lx
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Portamento down
@@PortDown:	neg	ch
		mov	cs:PortSlide[di],ch
		jmp	@@lx
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Tone slide to note (no note supplied)
@@ToneSlide:	or	ch,ch		; parameter has speed of tone slide
		jz	@@lja		; keep last tone slide speed
		mov	cs:ToneSlideSpeed[di],ch

	@@lja:	mov	byte ptr cs:ToneSlide[di],1	; tone slide on
		jmp	@@lx
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Volume slide & Volume + Tone Slide
@@ToneVolSlide:
@@VolSlide:	cmp	ch,50		; <50 = slide down, >50 = slide up
		jb	@@lga
		sub	ch,50
		neg	ch

	@@lga:	mov	cs:VolSlide[di],ch

		cmp	dh,cmToneVolSlide	; just plain volume slide
		jnz	@@lx
		mov	byte ptr cs:ToneSlide[di],1	; tone slide on
		jmp	@@lx
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Set volume
@@SetVolume:	call	SetVolume	; CH has volume, CL has channel
		jmp	@@lx
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; jump to line in next pattern
@@JumpToLine:	cmp	ch,64
		jae	@@lx		; ignore as it is invalid
		xor	ax,ax
		mov	al,ch
		stc
		ret			; skip rest of channels
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Set speed
@@SetSpeed:	mov	cs:Speed,ch
		jmp	@@lx
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Effects		dw	@@lx
		dw	@@PortUp
		dw	@@PortDown
		dw	@@ToneSlide
		dw	@@lx
		dw	@@ToneVolSlide
		dw	@@lx
		dw	@@lx
		dw	@@lx
		dw	@@lx
		dw	@@VolSlide
		dw	@@lx
		dw	@@SetVolume
		dw	@@JumpToLine
		dw	@@lx
		dw	@@SetSpeed

NoteFreq	dw	16bh,181h,198h,1b0h,1cah,1e5h	; 156h = C
		dw	202h,220h,241h,263h,287h,2aeh






;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Check each channel for ongoing effects to update.
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
UpdateNotes:	xor	bh,bh		; channel index
		xor	si,si

	; process portamentos
	@@la:	mov	bl,cs:PortSlide[si]
		or	bl,bl
		jz	@@lb		; no slide for this channel
		call	GetFreq
		mov	ch,bl
		sar	cx,8		; sign extend 8bit->16bit
		add	ax,cx
		call	SetFreq

	; process volume slides
	@@lb:	mov	ch,cs:VolSlide[si]
		mov	cl,cs:Old43[si]	; contains current volume
		and	cl,3fh
		xor	cl,3fh
		or	ch,ch
		jz	@@lc
		jns	@@lba

		; slide volume up
		sub	cl,ch
		cmp	cl,64
		jb	@@lbb
		mov	cl,63
		jmp	@@lbb

		; slide volume down
	@@lba:	sub	cl,ch
		jns	@@lbb
		xor	cl,cl

	@@lbb:	mov	ch,cl
		mov	cl,bh		; channel to set
		call	SetVolume

	; process tone slides
	@@lc:	cmp	cs:ToneSlide[si],0
		jz	@@lx		; no tone slide
		mov	bl,cs:ToneSlideSpeed[si]	; shouldn't get wiped uc

		; get current absolute frequency
		call	GetFreq

		; sign extend speed/direction
		mov	dh,bl
		sar	dx,8

		; get destination frequency
		mov	cl,cs:ToneSlideFreqL[si]
		mov	ch,cs:ToneSlideFreqH[si]
		cmp	ax,cx
		jz	@@le		; already at destination?!
		ja	@@ld		; tone slide down (source > dest)

		; doing a tone slide up
		add	ax,dx
		cmp	ax,cx
		jb	@@lg		; still under destination
		jmp	@@le		; reached destination

		; doing a tone slide down
	@@ld:	sub	ax,dx
		cmp	ax,cx
		ja	@@lg		; still over destination

		; reached destination so stop tone slide
	@@le:	mov	ax,cx		; clip it onto destination
		mov	cs:ToneSlide[si],0	; disables tone slide

		; write new frequency back to channel
	@@lg:	call	SetFreq

	@@lx:	inc	bh
		inc	si
		cmp	si,9
		jb	@@la
		ret





;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Returns the current absolute frequency of channel
; IN:
;	SI	- channel
; OUT:
;	AX	- frequency
; USES:
;	CX, DX
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
GetFreq:	mov	cl,cs:OldA0[si]
		mov	ch,cs:OldB0[si]
		and	ch,3		; mask to get high frequency
		sub	cx,FreqStart
		mov	al,cs:OldB0[si]
		shr	al,2
		and	ax,7		; mask to get octave
		mov	dx,FreqRange
		mul	dx
		add	ax,cx
		ret





;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Sets the channel's frequency
; IN:
;	AX	- absolute frequency
;	SI	- channel
; USES:
;	CX, DX
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
SetFreq:	mov	cx,FreqRange
		xor	dx,dx
		div	cx		; extracts octave in AX and freq. in DX
		add	dx,FreqStart

		mov	ah,cs:OldB0[si]
		and	ah,11100000b	; keep old toggles
		shl	al,2		; move octave to correct bit position
		or	al,ah		; insert octave
		or	al,dh		; insert high frequency
		mov	ah,bh
		add	ah,0b0h
		mov	cs:OldB0[si],al
		call	Adlib

		sub	ah,10h
		mov	al,dl		; low frequency
		mov	cs:OldA0[si],al
		jmp	Adlib





;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Load in instrument data into a given channel.
; IN:
;	CL	- channel to load instrument into (0..8)
;	DL	- instrument no. (1..31)
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
LoadInst:	push	ax bx si

		mov	si,cx
		and	si,0ffh
		mov	ah,cs:ChannelOffs[si]	; Adlib register offsets

		xor	bx,bx
		mov	bl,dl
		dec	bx
		add	bx,bx
		mov	bx,cs:InstPtrs[bx]	; get instrument offset
		or	bx,bx
		jz	@@lx		; no instrument data ?!

		mov	al,2[bx]
		mov	cs:Old43[si],al	; old 43.. value

		mov	dl,4

	@@la:	mov	al,1[bx]
		call	Adlib		; load carrier
		add	ah,3
		mov	al,[bx]
		call	Adlib		; load modulator
		add	bx,2

		add	ah,20h-3
		dec	dl
		jnz	@@la

		add	ah,40h		; do E0 range now
		mov	al,2[bx]
		call	Adlib
		add	ah,3
		mov	al,1[bx]
		call	Adlib

		mov	ah,0c0h
		add	ah,cl
		mov	al,[bx]
		call	Adlib

	@@lx:	pop	si bx ax
		ret

ChannelOffs	db	20h,21h,22h,28h,29h,2ah,30h,31h,32h






;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Outputs a value to an ADLIB register.
; IN:
;	CL	- channel to set volume on
;	CH	- new volume
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
SetVolume:	push	ax bx

		xor	bx,bx
		mov	bl,cl

	; ensure volume is within range
		cmp	ch,64
		jb	@@la
		mov	ch,63

	; get old 43.. value
	@@la:	mov	al,cs:Old43[bx]
		and	al,0c0h		; mask out volume bits
		xor	ch,3fh
		or	al,ch		; insert volume
		mov	cs:Old43[bx],al	; keep new 43.. value

	; write new volume into Adlib
		mov	ah,cs:ChannelOffs[bx]
		add	ah,23h
		call	Adlib

		pop	bx ax
		ret





;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Outputs a value to an ADLIB register.
; IN:
;	AH	- register no.
;	AL	- value
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Adlib:		push	ax dx

		mov	dx,cs:AdlibPort
		xchg	ah,al
		out	dx,al
		rept	6
		in	al,dx
		endm

		inc	dx
		mov	al,ah
		out	dx,al
		dec	dx
		mov	ah,22
	@@la:	in	al,dx
		dec	ah
		jnz	@@la

		pop	dx ax
		ret






AdlibPort	dw	388h		; default Adlib base port

InstPtrs	dw	31 dup (0)	; offsets of instrument data
Old43		db	9 dup (0)	; record of 43..   register values
OldA0		db	9 dup (0)	; record of A0..A8 register values
OldB0		db	9 dup (0)	; record of B0..B8 register values

ToneSlideSpeed	db	9 dup (1)	; speed of tone slide
ToneSlideFreqL	db	9 dup (?)	; destination frequency of tone slide
ToneSlideFreqH	db	9 dup (?)

ToneSlide	db	9 dup (?)	; tone slide flag
PortSlide	db	9 dup (?)	; portamento slide
VolSlide	db	9 dup (?)	; volume slide

ModSeg		dw	?	; segment of module (starts at offset 0)
Speed		db	?	; speed (n/50Hz) of tune
SpeedCnt	db	?	; counter used for deriving speed

OrderSize	dw	?	; no. of entries in Order List
OrderList	dw	?	; offset in module of Order List
OrderPos	dw	?	; current playing position in Order List

PatternList	dw	?	; offset of pattern offset table in module
PatternPos	dw	?	; offset to current line in current pattern
Line		db	?	; current line being played (usually +1)
