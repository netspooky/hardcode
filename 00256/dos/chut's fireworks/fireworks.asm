;title:         Chut's fireworks
;version:       v1.00 (30.10.2004)
;category:      256b intro
;author:        Akos Fekete (alias: Chut)
;country:       Hungary
;e-mail:        fekete.akos@freemail.hu
;compiler:      Flat Assembler 1.55
;assumed:       AX=0000 BX=0000 CX=00FF DX>0080
;               SI=0100 DI=FFFE BP=09xx SP=FFFE DF=0

		Org	0100h

FIREWORKS:	mov	al,13h		;videomode: 320x200x8
		int	10h		;

GEN_PAL:	mov	dx,03C8h	;generating colors
		mov	al,cl		;00..3F: green
		out	dx,al		;40..7F: cyan
		inc	dx		;80..BF: yellow
		test	al,80h		;C0..FF: white
		jz	RED_OK		;
		salc			;
RED_OK: 	out	dx,al		;
		mov	al,cl		;
		out	dx,al		;
		test	al,40h		;
		jz	BLUE_OK 	;
		salc			;
BLUE_OK:	out	dx,al		;
		loop	GEN_PAL 	;

FILLwZERO:	push	bx		;this program will use the upper half
		or	sp,sp		;of the stack. so at first it clears
		js	FILLwZERO	;the undefinead areas.

		;MAIN PROGRAM CYCLE     ;

GO_TOP: 	xor	sp,sp		;recycling, 32k is ok for actual particles
NEW_BUNCH:	mov	word [CNTDWN],12;set countdown timer for next explosion
		or	sp,sp		;
		jg	GO_TOP		;jump if "stack is full"

		call	RND_AX		;select a color for new particle bunch
		and	al,0C0h 	;
		xchg	ax,dx		;DX=color (type)
		call	RND_AX		;generate a random Y value
		and	ax,127*128	;Y=(0..127)*128
		add	ax,16*128	;Y=(16..143)*128
		xchg	ax,bp		;BP=Y value in 9.7 format
		call	RND_AX		;generate a random X value
		and	ax,255*128	;X=(0..255)*128
		add	ax,31*128	;X=(31..286)*128
		xchg	ax,di		;DI=X value in 9.7 format

		mov	bx,ALFA 	;
		mov	cx,128		;ONE particle bunch consists 512 particles
GEN_BUNCH:	pusha			;occupy area for a particle datapack
		mov	si,sp		;--> X,Y,color  (push di,bp,dx)
		mov	word [si+08],105;--> "lifetime" (extension of explosion)
		fninit			;empty cooprocessor stack
		fild	word [bx]	;ALFA
		fld	st0		;ALFA ALFA
		fsincos 		;COSA SINA ALFA
		fldlg2			;0.3 COSA SINA ALFA
		fmul	st0,st3 	;BETA COSA SINA ALFA       (BETA=0.3*ALFA)
		fsin			;SINB COSA SINA ALFA
		fimul	word [bx+2]	;64*SINB COSA SINA ALFA
		fld	st0		;64*SINB 64*SINB COSA SINA ALFA
		fmul	st0,st2 	;64*SINB*COSA SINB*64 COSA SINA ALFA
		fistp	word [si+02]	;--> speed of X = -64..+64 (-1..+1 in 9.7)
		fmul	st0,st2 	;64*SINB*SINA COSA SINA ALFA
		fistp	word [si+06]	;--> speed of Y = -64..+64 (-1..+1 in 9.7)
		add	word [bx],2   ;new vector
		loop	GEN_BUNCH	;

		;a particle datapack struckture (in the stack)
		;n+14   unused
		;n+12   unused
		;n+10   color
		;n+ 8   lifetime
		;n+ 6   Y speed of particle
		;n+ 4   Y coordinate of particle
		;n+ 2   X speed of particle
		;n+ 0   X coordinate of particle

		push	0A000h		;video segment
		pop	es		;

		mov	dx,03DAh	;retracing - not important!
RETRACE:	in	al,dx
		test	al,08h
		je	RETRACE

SCAN_QUEUE:	mov	si,8000h	;address of 1st particle datapack
PARTICLES:	lodsw			;AX=current X coordinate
		xchg	ax,di		;DX=current X coordinate
		lodsw			;AX=X speed
		add	di,ax		;DX=new X coordinate
		mov	[si-4],di	;new -> current
		shr	di,7		;9.7 -> 16.0 format conversion

		lodsw			;AX=current Y coordinate
		xchg	ax,bx		;BX=current Y coordinate
		inc	word [si]	;gravity
		lodsw			;AX=Y speed
		add	ax,bx		;AX=new Y coordinate
		mov	[si-4],ax	;new -> current
		shr	ax,7		;9.7 -> 16.0 format conversion

		imul	ax,ax,320	;AX=Y coord * 320
		add	di,ax		;DI=videocoord

		lodsw			;AX=lifetime
		dec	ax		;
		jle	DEAD_PARTICLE	;
		mov	word [si-2],ax	;writeback rest of lifetime
		cmp	al,3Fh		;lifetime->brightnes
		jb	BURNOUT 	;
		mov	al,3Fh		;
BURNOUT:	mov	bl,3Fh		;
		and	bl,[es:di]	;
		cmp	al,bl		;
		jb	DEAD_PARTICLE	;backround is brighter!
		or	al,[si] 	;
		stosb			;
DEAD_PARTICLE:	add	si,6		;
		jnz	PARTICLES	;

		dec	word [CNTDWN]	;count for new bunch
		jz	NEW_BUNCH	;

FADE:		test	byte [es:si],3Fh;fading
		jz	BLACK		;
		dec	byte [es:si]	;
BLACK:		inc	si		;
		jnz	FADE		;

		in	al,60h		;check 'ESC' key
		cbw			;
		dec	ax		;
		jnz	SCAN_QUEUE	;

		push	ax		;set text mode
		mov	al,03h		;and exit
		int	10h		;

RND_AX: 	mov	ax,13579	;random number generator
		add	ah,al		;
		xchg	al,ah		;
		mov	[RND_AX+1],ax	;
		ret			;

ALFA		dw	1		;
SF64		dw	64		;
CNTDWN		dw	?		;