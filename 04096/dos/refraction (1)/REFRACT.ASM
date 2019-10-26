COMMENT #


  ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³                                                  ³±
  ³              R E F R A C T I O N                 ³±
  ³                                                  ³±
  ³  A 4k intro for the PC-X competiton.             ³±
  ³  Made by G.O.D. /AbaddoN                         ³±
  ³  Copyright (C)1995. All rights reserved.         ³±
  ³                                                  ³±
  ³  Last modified: 10-31-95 05:24pm                 ³±
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±
   ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±




Compiling:  TASM /m9 refract.asm
            TLINK /t /x refract.obj

Note: The first respect was size optimizing, then the speed optimizing.
      You can find some neglect, when you watching the code.

#
.386
LOCALS


;debug = 0



; ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
; ³         Constants.            ³±
; ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±
;  ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

B	EQU byte ptr		; For an easier life.
W	EQU word ptr
D	EQU dword ptr
O	EQU offset
S	EQU small
L	EQU large

CR	EQU 0dh
LF	EQU 0ah
EOS	EQU '$'



; ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
; ³         Main code.            ³±
; ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±
;  ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

code SEGMENT USE16
ASSUME cs:code, ds:code, ss:code, es:code
	ORG 100h

; Last modified: 10-31-95 05:24pm

Main	PROC
		mov	bx,4000h
		mov	ah,4ah
		int	21h
		jnc	@@Enough_Mem
		mov	dx,O @@NoMemStr
		jmp	@@Wrt_Exit

@@Enough_Mem:
		mov	dx,O @@PleaseStr
		mov	ah,9
		int	21h
		cld
		mov	ax,cs
		add	ax,1000h
		mov	[ChrAddr],ax	; Where the 2nd screen will be.
		add	ax,1000h
		mov	[ScrAddr],ax	; Where the charset will be.

		xor	ax,ax	 ; Make a table which
		xor	bx,bx	 ; contains the offset address
		mov	di,O ScrRowsVGA ; of the screen rows on VGA screen.
		mov	cx,200
@@1:
		stosw
		add	ax,320
		loop	@@1

		call	SinGen	; Make the sinus table

		call	MakeChars	; Make the charset.

		xor	ax,ax
		mov	es,ax

; Setting up new keyboard routine.
	IFNDEF debug
		mov	[StackSegment],ss
		mov	[StackPointer],sp
		mov	dx,cs
		shl	edx,10h
		mov	dx,O KeyboardIRQ
		xchg	edx,es:[24h]
		mov	[Old_Kbd],edx
	ENDIF

; Setting up new timer routine.
		mov	[Timer_Routine],O Timer_Blank
		mov	dx,cs
		shl	edx,10h
		mov	dx,O TimerIRQ
		xchg	edx,es:[20h]
		mov	[Old_Timer],edx
		mov	al,36h	 ; Ticks with 10ms.
		out	43h,al
		mov	al,156
		out	40h,al
		mov	al,46
		out	40h,al

; Making the beginnig effect.
		mov	di,O TitleTexts ; Select title texts.
		mov	ax,600+8000h	 ; Set 6 secs. waiting.
		call	Mandy_Zoom

; Making the broken screen effect.
		call	BreakScr

; Making the chess table effect.
		call	Chess_Mate

; Making the ending effect.
		mov	di,O EndTexts	 ; Select end texts.
		mov	ax,100+8000h	 ; Set 1 sec. wainting.
		call	Mandy_Zoom

Abort_Code:
		xor	ax,ax
		mov	es,ax

; Setting back the timer.
		out	40h,al
		out	40h,al
		mov	edx,[Old_Timer]
		mov	es:[20h],edx

; Setting back the keyboard.
	IFNDEF debug
		mov	edx,[Old_Kbd]
		mov	es:[24h],edx
	ENDIF

; Setting back text mode.
		mov	ax,3
		int	10h

; Writing bye-string.
		mov	dx,O @@EndString
@@Wrt_Exit:
		mov	ah,9
		int	21h

; Exit 2 DOS.
		int	20h

; The string that will be written after finishing.
@@EndString	db '- REFRACTION -',CR,LF
		db 'Coded by G.O.D. /AbaddoN in 1995.',EOS
@@NoMemStr	db 'Not enough memory. ( 256k of base memory needed )',EOS
@@PleaseStr	db 'Warming up !',EOS

Main	ENDP




; ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
; ³          Mandelbrot zoomer.           ³±
; ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±
;  ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

; Input:  ax= Delay before the first text
;         di= Offset of texts & positions & times.
; Modified regsiter(s): eax,ebx,ecx,edx,edi,esi,ebp,es
; Length: 257 bytes.
; Last modified: 10-31-95 02:09pm

Mandy_Zoom PROC NEAR

		mov	[Timer_Cnt],ax	 ; Store the inputs.
		mov	[MZ_TextPos],di
		mov	[MZ_Cnt],1
		mov	[MZ_S_bx],256
		mov	[MZ_S_si],0


		mov	ax,[ScrAddr]	 ; Counting the seg.addr. of
		mov	es,ax	 ; the two buffer for
		mov	bx,ax	 ; mandelbrot.
		add	bx,1000h
		xor	ax,bx
		mov	[MZ_XorScr],ax
		mov	[MZ_ScrSeg],bx
		push	ax
		call	Make_Mandy
		pop	ax
		xor	[MZ_ScrSeg],ax

		mov	ax,13h
		int	10h	 ; Setting 320x200-256 mode.
		mov	ax,0a000h
		mov	es,ax
		mov	ax,808h
		xor	di,di
		mov	cx,32000
	rep	stosw		 ; Clear the screen.

		mov	[MZ_Finish],al
		mov	[MZ_Next],al

		mov	al,1fh
		mov	di,320*8+94
		mov	si,di
		mov	cx,132
@@1:
		mov	es:[di],al	 ; Make the frame.
		mov	es:[di+320*131],al
		inc	di
		mov	es:[si],al
		mov	es:[si+132],al
		add	si,320
		loop	@@1

		mov	dx,3c8h	 ; Setting the colors
		mov	ax,2f00h
		out	dx,al
		inc	dx
		mov	cl,80
@@2:
		cmp	ah,2fh
		jnz	@@3
		mov	ah,0
		mov	bx,1020h
@@3:
		mov	al,bl
		out	dx,al
		mov	al,bh
		out	dx,al
		mov	al,ah
		out	dx,al
		add	bx,101h
		inc	ah
		loop	@@2

		mov	[Timer_Routine],O Put_Mandy
@@4:
		mov	ebx,[MZ_Delta]	 ; Count the next phase's
		shl	ebx,6	 ; left-upper corner &
		mov	eax,@@TargetRe	 ; the difference between
		sub	eax,ebx	 ; two dot.
		mov	[MZ_StartRe],eax
		mov	eax,@@TargetIm
		sub	eax,ebx
		mov	[MZ_StartIm],eax
		shr	ebx,7
		mov	[MZ_Delta],ebx
		call	Make_Mandy

		mov	al,1
		mov	[MZ_Next],al
@@5:
		cmp	[MZ_Next],al
		je	@@5	 ; Wait for the next phase.
		cmp	[MZ_Finish],al
		jne	@@4	 ; Or exit at the end.
		mov	ah,40h
@@6:
		mov	cl,80	 ; Fading down the colors.
		call	FadeDown
		call	Raster
		call	Raster
		dec	ah
		jnz	@@6
		mov	[Timer_Routine],O Timer_Blank
		ret

@@TargetRe = -15049100
@@TargetIm = -43583200
MZ_StartRe	dd -15049100-750000*128
MZ_StartIm	dd -43583200-750000*128
MZ_Delta		dd 750000

Mandy_Zoom ENDP




; ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
; ³          Timer routine for zooming.           ³±
; ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±
;  ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

; Modified regsiter(s): nothing
; Length: 179 bytes.
; Last modified: 10-17-95 10:02pm

Put_Mandy	PROC NEAR

; Streches 256x256 square picture to 128x128.
; Input:  si= The offset of the left-upper corner in the 256x256 pic.
;         bx= The length of the edge of the part that will be zoomed.
Put_Her	MACRO
LOCAL P1,P2
		mov	di,(320-128)/2+320*10	; di= screen position.

		shl	bx,1	; bx= the addition to the row.
		mov	ax,si
		mov	ah,0	; ax= left sid of the square.
		mov	cl,80h
P1:
		mov	ch,80h
		push	bx si
		and	si,0ff00h	; si= the offset of the row to strech.
		add	si,ax	; si= the offset of the left-upper crn.

		mov	bp,8000h
		xor	dx,dx	; bx:dx= the addiotion to the column.
		xchg	bl,dh
		xchg	bh,bl
		dec	bx	; Dec. int. part 'coz of the movsb.
P2:
		movsb
		add	bp,dx
		adc	si,bx
		dec	ch
		jnz	P2	; Jump if not at the end of the row.
		add	di,320-128
		pop	si bx
		add	si,bx	; Count the next row's address.
		loop	P1	; Loop if not at the end of the pic.
ENDM


; It starts. (Timon of LionKing)

		pushad
		push	es
		mov	ax,0a000h
		mov	es,ax
		cmp	[Timer_Cnt],8000h
		jns	@@2	; Jump if no new text needed.
		mov	si,[MZ_TextPos]
		lodsw		; Get its position.
		inc	ax
		jnz	@@1
		mov	[MZ_Finish],1	; Mark finish.
		jmp	@@2
@@1:
		xchg	di,ax
		mov	dx,800h+1fh-8	; Set text colors.
		call	PutTextVGA	; Put a text.
		lodsw
		mov	[Timer_Cnt],ax	 ; Set waiting.
		mov	[MZ_TextPos],si ; Store the textpointer.
@@2:
		dec	[MZ_Cnt]	; Do it every 80ms.
		jne	@@4
		mov	[MZ_Cnt],10

		cmp	[MZ_S_bx],128
		jne	@@3	; Jump if no new phase needed.

		cmp	[MZ_Next],1
		jne	@@4	; Jump if the next phase is not ready.
		mov	ax,[MZ_XorScr]
		xor	[MZ_ScrSeg],ax	; Exchange the secondary screens.
		xor	ax,ax
		mov	[MZ_Next],al	; And set up them.
		mov	[MZ_S_si],ax
		inc	ah
		mov	[MZ_S_bx],ax
@@3:
		mov	bx,[MZ_S_bx]
		sub	[MZ_S_bx],2
		mov	si,[MZ_S_si]
		add	[MZ_S_si],101h
		mov	ax,[MZ_ScrSeg]
		xor	ax,[MZ_XorScr]
		mov	ds,ax	; ds:si= adr.of the left-upper corner.

		Put_Her		; Put the streched mandelbrot.
@@4:
		pop	es
		popad
		ret

MZ_Cnt	db 1		; The counter for 80ms.
MZ_S_bx	dw 256		; The length of the edge of the square to strech.
MZ_S_si	dw 0		; The offset of the left-upper corner of the square.
Put_Mandy	ENDP




; ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
; ³          Makes a 256x256 mandelbrot.           ³±
; ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±
;  ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

; Input:  MZ_ScrSeg= The segment address of the mandelbrot.
;         MZ_StartIm & MZ_StartRe= The complex value of the left-upper corner.
;         MZ_Delta= The difference between two dot.
; Modified regsiter(s): eax,ebx,ecx,edx,edi,esi,ebp,es
; Length: 149 bytes.
; Last modified: 10-17-95 10:02pm

Make_Mandy PROC NEAR
MaxIter = 80	; The number of the maximum iteration.
@@FixPoint = 26	; The number of the bit where the fix-point is.

		xor	di,di
		mov	es,[MZ_ScrSeg]
		mov	esi,[MZ_StartIm]

		xor	cx,cx
@@1:
		mov	[MZ_RowCnt],0
		mov	ebx,[MZ_StartRe]
@@2:
		push	ebx ecx esi di
		call	@@Iter	; Do the iteration.
		pop	di
		mov	es:[di],cl	; cl= the color of the dot.
		inc	di

		test	cl,cl	; Test if the color is 0.

		pop	esi ecx ebx

		jnz	@@3
		inc	[MZ_RowCnt]	; If a whole row contains 0,
		jz	@@KillIt	; fill the remained with 0 too.
@@3:
		add	ebx,[MZ_Delta]
		dec	ch
		jnz	@@2	; Jump if not at the end of the row.
		add	esi,[MZ_Delta]
		loop	@@1	; Loop if not at the end of the pic.
		ret
@@KillIt:
		xor	cx,cx	; Fill the remain with 0.
		sub	cx,di
		shr	cx,2
		jmp	Fill0_2




; Counting one dot's color.
; Input:  ebx= reA
;         esi= imA

@@Iter:

		xor	edi,edi	; edi= reZ (=0).
		xor	ebp,ebp	; ebp= imZ (=0).
		mov	cl,MaxIter	; Iteration nubmer.
@@Iter_Loop:
		dec	cl
		jz	@@Iter_End
		mov	eax,edi
		imul	ebp
		shrd	eax,edx,@@FixPoint-1
		add	eax,esi	; eax= 2*reZ*imZ + imA.
		xchg	eax,ebp	; ebp= imZ+ & eax=imZ.
		imul	eax
		shrd	eax,edx,@@FixPoint	; eax= imZ^2.
		xchg	eax,edi	; edi= imZ^2  & eax= reZ.
		imul	eax
		shrd	eax,edx,@@FixPoint	; eax= reZ^2.
		mov	edx,eax	; edx= reZ^2.
		sub	eax,edi
		add	eax,ebx
		xchg	eax,edi	; edi= reZ^2 - imZ^2 + reA= imZ+.
		add	eax,edx	; eax= reZ^2 + imZ^2.
		cmp	eax,4 SHL @@FixPoint
		jb	@@Iter_Loop
@@Iter_End:
		ret
Make_Mandy ENDP



; The title texts.
TitleTexts	dw 168*320+48-1	; The screen position of the text
		db 'ABADDON',0	; The text.
		dw 500+8000h	; The time to wait after putting it.
				; Time=x+8000h waits x*10ms.
		dw 168*320+32-1
		db 'PRESENTS',0
		dw 500+8000h

		dw 168*320+32-1
		db ' G.O.D. ',0
		dw 500+8000h

		dw 168*320+0-1
		db 'PRODUCTION',0
		dw 500+8000h

		dw 168*320+0-1
		db '          ',0
		dw 50+8000h

		dw 0ffffh	; 0ffffh scr.pos. means the end.

; The end texts.
EndTexts		dw 168*320+16-1
		db 'GREETINGS',0
		dw 150+8000h

		dw 168*320-1
		db '    TO    ',0
		dw 150+8000h

		dw 168*320-1
		db 'EVERYBODY',0
		dw 150+8000h

		dw 168*320-1
		db ' WHO IS  ',0
		dw 150+8000h

		dw 168*320+16-1
		db 'WATCHING.',0
		dw 400+8000h

		dw 168*320+16-1
		db 'THIS WAS ',0
		dw 150+8000h

		dw 168*320-1
IntroName		db 'REFRACTION',0
		dw 1500+8000h

		dw 0ffffh




; ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
; ³          Broken screen effect.           ³±
; ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±
;  ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

; Modified regsiter(s): eax,bx,ecx,dx,edi,si,bp,es,fs
; Length: 543 bytes.
; Last modified: 10-26-95 02:17pm

BrkPntNum = 12		; Number of vertices where the breaking line breaks.

BreakScr	PROC NEAR
		mov	ax,13h
		int	10h	; Set 320x200-256 screen.

		call	ClrScr2	; Clear the secondary screen.

		mov	bx,40*100h+45 ;43*100h+45
		call	@@BrkScr_SetC	; Set the colors.


		mov	si,O IntroName
		mov	di,320*84+0
		mov	dx,1
		push	dx di si
		call	PutTextVGA	; Put the text on the sec.scr.
		pop	si di dx
		mov	ax,0a000h
		mov	es,ax
		call	PutTextVGA	; Then onto the real screen.

		mov	ax,400+8000h
		call	Delay	; Wait for 4 seconds.

		xor	cx,cx
		mov	dx,140
		mov	[BrkPoliXS],dx ; The breaking line is on 140 Y.
		;mov	[BrkPoliXC],70 ; The center of the light-source
		;mov	[BrkPoliYC],100 ; is at 70-100.
		mov	si,O BreakingLine
		mov	bp,BrkPntNum-1
@@1:
		lodsw		; Draw the breaking line.
		xor	bx,bx
		xchg	bl,ah
		add	ax,140	; Its middle Y is 140.
		push	ax bx si bp
		mov	bp,O BrkStoreEdge
		call	DrawEdge
		pop	bp si cx dx
		dec	bp
		jnz	@@1
COMMENT ~
		xor	cx,cx	; Break the screen.
@@2:
		push	cx	; The line starts at Y=0 and
		mov	bx,cx	; finishes at T=cx.
		shl	bx,2
		mov	dx,W [TempArea+2][bx]	; dx=X of the brk.l. in the
					; cx-th. rasterrow.
		sub	dx,140
		mov	si,O BreakingLine-2
		mov	di,O BrkLTemp
		push	ds
		pop	es
		mov	dh,BrkPntNum
@@3:
		lodsw		; Make a table for BrkPoli rout.
		cmp	ah,cl	; from a current phase of the brk.l.
		jb	@@4
		mov	ah,cl	; If the vertex is below cx.
		mov	al,dl
@@4:
		stosw
		dec	dh
		jnz	@@3

		mov	si,O BrkLTemp
		call	@@Put_Scr	; Make light & put the screen.

		pop	cx
		add	cx,4
		cmp	cx,200
		jb	@@2
~
		mov	ax,100+8000h
		call	Delay	; Wait for 1 sec.


		xor	bp,bp
@@5:
		mov	[Timer_Cnt],4+8000h

		push	ds	; Prepare for scrolling the two halves.
		mov	ds,[ScrAddr]
		push	ds
		pop	es

		mov	di,320*84	; Scroll only the middle of the screen,
		mov	bx,O TempArea+84*4+2  ; where the text is.
		mov	dl,28	; It is 28 dot high.
@@6:
		mov	cx,cs:[bx]
		sub	cx,bp
		dec	cx
		js	@@7
		push	di
		mov	si,di
		inc	si
	rep	movsb		; Scroll the left side.
		pop	di
@@7:
		mov	cx,320
		sub	cx,cs:[bx]
		sub	cx,bp
		dec	cx
		js	@@8
		push	di
		add	di,319
		mov	si,di
		dec	si
		std
	rep	movsb		; Scroll the right side.
		cld
		pop	di
@@8:
		add	di,320
		add	bx,4
		dec	dl
		jnz	@@6

		mov	si,O TempArea+2
		xor	bx,bx	; Make the highlight gap between
		mov	dl,200	; the two sides.
@@9:
		mov	di,cs:[si]
		sub	di,bp
		js	@@10
		mov	B [bx+di],2
@@10:
		add	di,bp
		add	di,bp
		mov	B [bx+di+1],2
		add	si,4
		add	bx,320
		dec	dl
		jnz	@@9

		pop	ds

		cmp	bp,75
		ja	@@11
		mov	ax,140	; If the gap is above 2*75 pixel,
		sub	ax,bp	; the left light is not visible.
		mov	[BrkPoliXS],ax
		mov	si,O BreakingLine-2
		mov	ax,0c040h
		call	@@BrkPoli
@@11:
		mov	ax,140
		add	ax,bp
		mov	[BrkPoliXS],ax
		mov	si,O BreakingLine-2
		call	@@Put_Scr	; Make light & put the screen.


		cmp	bp,75
		jne	@@12
		push	bp	; At the gap=2*75 the light lights
		mov	bx,58*100h+60	; into our eyes.
		mov	ah,40
		call	@@BrkScr_SetC
		pop	bp
@@12:
		cmp	bp,140-24
		jb	@@13
		push	bp	; With 2*24 before the end the
		mov	ax,bp	; "whiting" the colors.
		sub	ax,140-24-40
		mov	ah,al
		mov	bx,58*100h+60
		call	@@BrkScr_SetC
		pop	bp
@@13:

@@18:
		cmp	[Timer_Cnt],0
		js	@@18
		inc	bp
		cmp	bp,140
		jb	@@5

		ret

@@Put_Scr:
		mov	ax,3010h
		call	@@BrkPoli	; Make the right one of the lights.
		push	ds
		call	Copy_Scr
		push	ds
		pop	es
		xor	di,di	; Clear the light from the sec.scr.
		xor	si,si
		mov	edx,0f0f0f0fh
		mov	cx,16000
@@PS1:
		lodsd
		and	eax,edx
		stosd
		loop	@@PS1
		pop	ds
		ret


BrkStoreEdge:
		push	bx	; Store the X coord. of the brk.line.
		shl	bx,2
		mov	D [TempArea][bx],edi
		pop	bx
		ret

		db   0,   0
BreakingLine	db  20,  20	; The coordinates of the brk.line.
		db  14,  40
		db  30,  60
		db  18,  80
		db  25,  90
		db   0, 110
		db  10, 125
		db  15, 140
		db   5, 160
		db  25, 180
		db   0, 200
@@Colors		db 000,000,000	; The color table.
		db 025,025,035
		db 063,063,063


@@BrkScr_SetC:
		mov	dx,3c8h	; Set the colors.
		mov	al,0	; The LS4B is the color;
		out	dx,al	; the 4-5 bit is the right light;
		inc	dx	; the 6-7 bit is the left light.
		mov	bp,16*3

		mov	cx,bp
		call	@@SetCol	;00000000b

		mov	ah,bh
		mov	cx,bp
		call	@@SetCol	;00010000b
		mov	ah,bl
		mov	di,2
		call	@@BSC1
				;00100000b
				;00110000b
		xchg	ah,bh
		mov	di,4
		call	@@BSC1	;01000000b
				;01010000b
				;01100000b
				;01110000b
		xchg	ah,bl
		mov	di,8
				;10000000b
				;10010000b
				;10100000b
				;10110000b
				;11000000b
				;11010000b
				;11100000b
				;11110000b
@@BSC1:
		mov	cx,bp
		call	@@SetCol
		dec	di
		jnz	@@BSC1
		ret
@@SetCol:
		mov	si,O @@Colors
		jmp	SetBloCol



; Makes the lights.
; Let's look at this:
;                     __ V1
;      Brk.line.  ___/  |
;         \   ___/      |
;       ___\_/ Light is /
; LS.__/   /V4   here  |
;   +_____/____________|
;         \V3          V2
;          \


@@BrkPoli:
		push	bp
		mov	cx,BrkPntNum-1
@@BP1:
		push	cx si ax

		mov	bp,O BrkTemp
		mov	di,O BrkTemp+4
		call	@@BrkPoli2		; Count the V4,V1 vertex.

		mov	bp,O BrkTemp+12
		mov	di,O BrkTemp+8
		call	@@BrkPoli2		; Count the V2,V3 vertex.

		mov	si,O BrkTemp

		pop	ax
		push	ax
		mov	ah,1
		mov	cx,4
		call	FillPoli		; Fill the light.

		pop	ax si cx
		xor	al,ah
		inc	si
		inc	si
		loop	@@BP1		; Then the next one.
		pop	bp
		ret
@@BrkPoli2:
		lodsw		; Counting an edge of a light.
		xor	bx,bx
		xchg	bl,ah
		add	ax,[BrkPoliXS]
		mov	[bp],ax	; Store 1st vertex of the line (V3,V4).
		mov	[bp+2],bx
		mov	cx,ax
		sub	cx,70 ;[BrkPoliXC]
		mov	dx,bx
		sub	dx,100 ;[BrkPoliYC]
@@BP2:
		add	ax,cx	; Count the 2nd vertex (V1,V2).
		add	bx,dx
		cmp	ax,400
		ja	@@BP3
		cmp	bx,600
		jb	@@BP2
@@BP3:
		mov	[di],ax	; And store them.
		mov	[di+2],bx
		ret
BreakScr	ENDP




; ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
; ³          Sets a block of colors.          ³±
; ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±
;  ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

; Input:  ds:si= The address of the R,G,B components of the colors.
;         cx= The number of colors to set
;         ah= The addition value to the R,G,B. (Something brightness.)
;
; Modified register(s): al, cx, si
; Length: 13 bytes.
; Last modified: 10-05-95 12:04pm

SetBloCol	PROC NEAR
@@1:
		lodsb
		add	al,ah
		cmp	al,3fh
		jbe	@@2	; Jump if the color value is right.
		mov	al,3fh	; Else set the maximum color.
@@2:
		out	dx,al
		loop	@@1
		ret
SetBloCol	ENDP




; ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
; ³          Chess is looking good.            ³±
; ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±
;  ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

; Modified regsiter(s): eax,ebx,cx,edx,di,si,ebp,es
; Length: 488 bytes (with data).
; Last modified: 10-26-95 04:22pm

Chess_Mate PROC NEAR

; The number of figures thoose are on the table. (6 whites & 7 blacks)
FigsOn	EQU 6+7

		call	Mk_ChFigs	; Make the figures' objects.
		call	Mk_ChTable	; Make the chess table.

		mov	ax,13h	; Set screen to 320x200-256.
		int	10h

		mov	dx,3c8h	; Setting the colors
		mov	al,0
		out	dx,al
		inc	dx

		mov	ch,49h	; 0-3fh table's colors.
		mov	bx,4940h
		call	Ch_SetCol
		mov	ch,64h	; 40h-7fh white's colors.
		mov	bx,5950h
		call	Ch_SetCol
		mov	ch,0	; 80h-0bfh black's colors.
		mov	bx,2921h
		call	Ch_SetCol


		mov	si,O Chess_Text1
		call	Put_ManyText	; Put the names, counry and year.

		push	cs
		pop	es

		mov	di,O ChFig_Pos	; Set up the figs' positions.
		mov	si,O ChStartPos
		mov	cx,FigsON*3
@@1:
		lodsb
		cbw
		shl	eax,2+10h
		stosd
		loop	@@1

		mov	si,O ChFig_Init ; Set up the figs' addrs&colors.
		mov	di,O ChFig_Dat
		mov	cx,FigsOn
@@2:
		movsw
		lodsb
		stosw
		loop	@@2

					; Set up some other variables.
		mov	[LS_Circ],00400000h	; The ligth-circle's size.
					; ( the bigger the less )
		mov	D [Zoom_Factor-2],200*10000h ; Zooming for 3D-2D
					      ; transformation.
		mov	eax,128*10000h		; Starting rotation angles.
		mov	D [Rot_Alfa-2],eax
		mov	D [Rot_Beta-2],eax

		xor	eax,eax
		mov	[Eye_XAdd],eax		; Our eye's position.
		mov	[Eye_YAdd],eax
		mov	[Eye_ZAdd],-300*10000h

		mov	[PO_XLight],eax	; The light- circle's position.
		mov	[PO_ZLight],eax

; ax=0 here!
		mov	di,O New_Values	; It causes no movement at all.
		mov	cx,((9+FigsOn*3)*2)*2
	rep	stosw

		mov	[Timer_Routine],O Chess_Timer	; The addr.of timing r.

@@3:
		call	ClrScr2		; Clear the sec.scr.

		push	cs
		pop	es
		mov	[FPG_Col],al	; eax=0 !
		mov	di,O Trans_XAdd
		mov	si,O Eye_XAdd
		movsd
		movsd
		movsd
		mov	si,O Chess_Table
		call	Put_Obj	; Put the chess-table.

		push	cs	; Sorting the figures from the fartest
		pop	es	; to the nearest.
		mov	si,O ChFig_Pos
		mov	di,O TempArea
		mov	cx,FigsOn
		push	cx cx di
		call	Rotate	; si=original, di=rotated, cx=number.
		pop	si cx
		add	si,8
		mov	di,O ChFig_Srt
		push	di
		xor	eax,eax
@@4:
		neg	D [si]
		movsd
		add	si,12
		stosd
		inc	ax
		loop	@@4
		pop	si cx
		call	QuickSort	; si=rotated, cx=number.

		mov	bx,O ChFig_Srt+4	; [bx]=sorted numbers of the
					;      figures.
		mov	cx,FigsOn
@@5:
		push	cs
		pop	es
		mov	si,[bx]	; si=figs' number to put.
		add	bx,8
		push	bx cx
		shl	si,2
		push	si
		add	si,O ChFig_Dat
		mov	dx,[si]	; dx=offs. of the figure's object.
		mov	al,[si+2]	; al= color of the figure.
		mov	[FPG_Col],al
		pop	si
		mov	ax,si
		shl	si,1
		add	si,ax
		add	si,O ChFig_Pos	; Set its position.
		mov	di,O Trans_XAdd
		lodsd
		add	eax,[Eye_XAdd]
		stosd
		lodsd
		add	eax,[Eye_YAdd]
		stosd
		lodsd
		add	eax,[Eye_ZAdd]
		stosd
		xchg	dx,si
		call	Put_Obj	; And put it.
		pop	cx bx
		loop	@@5

		call	Raster
		push	ds
		call	Copy_Scr	; Put the sec.scr to the primary scr.
		pop	ds
		cmp	[ChFinish],0
		jz	@@3	; Jump back if not at the end.

		mov	si,O Chess_Text2

; Puts some text to the screen.
; Input:  si= Offset of the positions+texts.
; Modified regsiter(s): ax,bx,cx,dx,di,si,bp,es
Put_ManyText:
		mov	ax,0a000h
		mov	es,ax
		lodsb
@@6:
		push	ax
		lodsw
		xchg	ax,di
		mov	dx,60h
		call	PutTextVGA	; Put the text on the screen.
		pop	ax
		dec	al
		jnz	@@6
		mov	ax,400+8000h
		jmp	Delay	; Wait for 4 seconds.

; ChFinish <> 0 if this part is over.
ChFinish	db 0

; Some value to make the data understandable.
CB_L =  70	; Left-edge's position.
CB_A =  47	; 'A' column's position.
CB_B =  35	; etc.
CB_C =  21
CB_D =  7
CB_E = -7
CB_F = -21
CB_G = -35
CB_H = -47
CB_R = -70	; Rigth-edge's position.
CB_U = -70	; Upper-edge's position.
CB_1 = -47	; '1' row's position.
CB_2 = -35	; etc.
CB_3 = -21
CB_4 = -7
CB_5 =  7
CB_6 =  21
CB_7 =  35
CB_8 =  47
CB_D = -70	; Down-edge's position.

; The fiures's start positions.
ChStartPos db CB_7,CB_A,0   ; Black Pawn
	 db CB_6,CB_B,0   ; Black Pawn
	 db CB_6,CB_F,0   ; Black Pawn
	 db CB_7,CB_B,0   ; Black Castle
	 db CB_5,CB_E,0   ; Black Queen
	 db CB_7,CB_F,0   ; Black King

	 db CB_2,CB_A,0   ; White Pawn
	 db CB_2,CB_F,0   ; White Pawn
	 db CB_3,CB_G,0   ; White Pawn
	 db CB_5,CB_H,0   ; White Pawn
	 db CB_1,CB_B,0   ; White Bishop
	 db CB_8,CB_H,0   ; White Queen
	 db CB_2,CB_H,0   ; White King

; The figures's object's address and color.
ChFig_Init dw O Pawn
	 db 80h
	 dw O Pawn
	 db 80h
	 dw O Pawn
	 db 80h
	 dw O Castle
	 db 80h
	 dw O Queen
	 db 80h
	 dw O King
	 db 80h

	 dw O Pawn
	 db 40h
	 dw O Pawn
	 db 40h
	 dw O Pawn
	 db 40h
	 dw O Pawn
	 db 40h
	 dw O Bishop
 	 db 40h
	 dw O Queen
	 db 40h
	 dw O King
	 db 40h

; Title texts.
Chess_Text1	db 3
		dw 320*40
		db 'KERES-',0
		dw 320*72+32*3
		db 'TAMINOV',0
		dw 320*104
		db 'USSR, 1951',0
; Finish texts.
Chess_Text2	db 2
		dw 64
		db 'BLACK',0
		dw 320*32+32
		db 'RESIGNS',0

Chess_Mate ENDP




; ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
; ³          Chess timing routine.            ³±
; ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±
;  ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

; Length: 146 bytes + the MoveTable.
; Last modified: 10-26-95 02:18pm

Chess_Timer PROC NEAR

		pushad
		mov	si,O Old_Values
		mov	di,O New_Values
		mov	cx,9+FigsOn*3
@@1:
		lodsd		; Get an old variable.
		mov	ebx,[di]	; Get its finishing value.
		add	di,8
		cmp	eax,ebx
		je	@@5	; Jump if it is reached.
		jg	@@2
		add	eax,[di-4]	; If less, increase it.
		cmp	eax,ebx
		jle	@@4
		jmp	@@3	; Set the finishing value if overflow.
@@2:
		sub	eax,[di-4]	; If greater, decrase it.
		cmp	eax,ebx
		jge	@@4
@@3:
		xchg	eax,ebx	; In case of overflow.
@@4:
		mov	[si-4],eax	; Write it back.
@@5:
		loop	@@1	; Do the next one.

		dec	[@@Counter]
		jnz	@@Exit	; Jump if no next phase needed.

		mov	si,[@@Pointer]
		lodsb		; Set up the next phase.
		cmp	al,0ffh
		jne	@@6	; Jump if not at the end of this part.
		mov	[ChFinish],al	; Else mark it.
		jmp	@@Exit
@@6:
		mov	dl,al	; Count the new delay.
		and	dx,0e0h
		shl	dx,2
		inc	dx
		mov	[@@Counter],dx

		and	al,1fh
		xor	edx,edx
		xchg	al,dl	; edx= the step of modifying.

		lodsb
		mov	ah,0
		shl	ax,3
		add	ax,O New_Values
		xchg	ax,di	; di= adr.of the value to change.

		lodsb
		cbw
		cwde
		shl	eax,18	; eax= finishing value.
		mov	[di],eax
		shl	edx,14
		mov	[di+4],edx

		mov	ax,511
		and	[Rot_Alfa],ax	; Anding the rotating angles,
		and	[Rot_Beta],ax	; to avoid some strange effect.

		mov	[@@Pointer],si	; Write back the pointer of the phases.
@@Exit:
		popad
		ret

; Some value to make life easier.
Mv_BP1 = 9	; 1st black pawn's number.
Mv_BP2 = 12	; etc.
Mv_BP3 = 15
Mv_BC  = 18
Mv_BQ  = 21
Mv_BK  = 24
Mv_WP1 = 27
Mv_WP2 = 30
Mv_WP3 = 33
Mv_WP4 = 36
Mv_WB  = 39
Mv_WQ  = 42
Mv_WK  = 45

; A counter for delaying phases.
@@Counter	dw 1
; The pointer of phases.
@@Pointer	dw O @@MoveTable

; The moving phases.
; Format: 1st byte: bit7-5 the delay for next phase.
;                   bit4-0 the step to reach the new values.
;         2nd byte: the value to modify.
;         3rd byte: the finishing value.

	    ; 0,1, 2, 3, 4, 5,6,7,8,  9, 10, 11, 12
	    ; a,b,ZF,XL,ZL,LC,X,Y,Z,f1X,f1Y,f1Z,f2X,...
	    ;842421«¬            *4
@@MoveTable LABEL
	  db 11100001b, 8,        -5
	  db 10000001b, 8,        -5
	  db 01000001b, 6,       -60
	  db 01000001b, 0,       110
	  db 01000001b, 6,         0
	  db 11100001b, 8,       -20

	  db 00100010b, 3,        20
	  db 00100010b, 4,       -15
	  db 00100010b, 3,       -15
	  db 01100010b, 4,        15
	  ;db 01000001b, 3,        20
	  ;db 01000001b, 4,       -15
	  ;db 01000001b, 3,       -15
	  ;db 11100001b, 4,        15

	  db 00000001b, Mv_WQ,   CB_7
	  db 01000001b, Mv_WQ+1, CB_H
	  ;db 10000001b, Mv_WQ+1, CB_H
	  db 00000001b, Mv_BK,   CB_6
	  db 01000001b, Mv_BK+1, CB_E
	  ;db 01100001b, Mv_BK+1, CB_E

	  db 00000001b, 0,       86
	  db 00000001b, 6,       10
	  db 00000001b, 4,      -18

	  db 00000001b, Mv_WQ,   CB_7
	  db 10000010b, Mv_WQ+1, CB_B
	  db 01000010b, Mv_BC,   CB_L
	  ;db 10000010b, Mv_BC,   CB_L

	  db 01000001b, 0,       120

	  db 00000010b, Mv_BQ,   CB_5
	  db 01000010b, Mv_BQ+1, CB_H
	  db 00000010b, Mv_WP4,  CB_4
	  db 01100010b, Mv_WP4+1,CB_R
	  db 01000010b, Mv_WK+1, CB_G
	  db 01100100b, 5,       85
	  db 0ffh

Chess_Timer ENDP




; ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
; ³          Makes the chess figures.          ³±
; ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±
;  ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

; Modified regsiter(s): eax,ebx,cx,edx,di,si,ebp,es
; Length: 165 bytes. ( with data )
; Last modified: 10-26-95 04:22pm

Mk_ChFigs	PROC NEAR
		mov	si,O ChFig_Tab
		mov	cx,FigNum
@@1:
		lodsw		; Get the contour's address.
		xchg	ax,bx
		lodsw		; Get the object's room address.
		xchg	ax,di
		lodsb		; Get the number of vertices of contour.
		mov	ah,0
		push	cx si
		xchg	ax,si
		xchg	bx,si
		call	Make_Obj	; Make the object.
		pop	si cx
		loop	@@1	; Do the next one.
		ret

FigNum EQU 5	; The number of figures' types.
PVtx  EQU 9	; The number of the vertices in a pawn.
BVtx  EQU 11	; ... in a bishop, etc.
CVtx  EQU 10
QVtx  EQU 12
KVtx  EQU 15

; A table for making objects. ( 1st W: contour's addr., 2nd W: object's addr.,
;                               3rd B: the number of vertices in the contour. )
ChFig_Tab	dw O Cont_Pawn, O Pawn
	db PVtx
	dw O Cont_Bish, O Bishop
	db CVtx
	dw O Cont_Cast, O Castle
	db CVtx
	dw O Cont_Quen, O Queen
	db QVtx
	dw O Cont_King, O King
	db KVtx


; The contours of the figures.

;Cont_Pawn	db   0, 76,  -8, 76, -20, 68, -28, 56, -28, 40
;	db -20, 28, -16, 22, -32, 16, -20,  4, -32,-40
;	db -40,-56, -44,-56, -48,-60, -48,-72,   0,-72
Cont_Pawn	db   0, 94, -14, 89, -21, 80, -21, 70, -11, 57
	db -21, 14, -37,  6, -37,  0,   0,  0
Cont_Bish	db   0,118, -14,104, -20, 92, -20, 84, -11, 76
	db -28, 67, -11, 67, -25, 14, -36,  8, -36,  0
	db   0,  0
Cont_Cast	db   0, 97, -15, 97, -20,108, -28,108, -28, 86
	db -18, 76, -28, 15, -38, 10, -38,  0,   0,  0
Cont_Quen	db   0,159,  -3,159,  -6,156,  -6,153, -30,150
	db -12,114, -30,114, -14,105, -30, 18, -42, 12
	db -42,  0,   0,  0
Cont_King	db   0,169,  -3,169,  -3,165,  -8,165,  -8,162
	db  -3,162
	db  -3,156, -24,144, -12,114, -30,105,  -9,105
	db -30, 18, -42, 12, -42,  0,   0,  0

Mk_ChFigs	ENDP




; ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
; ³          Sets 64 colors for gouraud.          ³±
; ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±
;  ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

; Input: ch,bh,bl=R,G,B compnent
;        dx= 3c9h
; Modified regsiter(s): ax,cl,dx,bp
; Length: 34 bytes.
; Last modified: 10-28-95 11:00am

Ch_SetCol	PROC NEAR

		mov	cl,0	; cl goes from 0 to 3fh
@@1:
		mov	bp,3	; There are 3 components for each col.
@@2:
		mov	al,cl
		mul	ch
		shr	ax,6
		cmp	al,3fh	; Check if above the max.
		jb	@@3
		mov	al,3fh	; If above, set the max.
@@3:
		out	dx,al
		xchg	bh,ch	; Change for the next component.
		xchg	bl,bh
		dec	bp
		jnz	@@2	; Do the next component.
		inc	cl
		cmp	cl,40h
		jnz	@@1	; Do the next color.
		ret

Ch_SetCol	ENDP




; ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
; ³          Makes the chess-table object.            ³±
; ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±
;  ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

; Modified regsiter(s): ax,ebx,cx,edx,di,ebp,es
; Length: 98 bytes.
; Last modified: 10-26-95 04:22pm

Mk_ChTable PROC NEAR
@@SqEdge= 56*10000h	; The length of one square's edge.

		push	cs
		pop	es
		mov	di,O Chess_Table+2	; di=adr.of the object.
		mov	W [di-2],81		; It contains 81 vertices.
		mov	edx,@@SqEdge*(-4)	; edx is the Y coordinate.
		xor	ebp,ebp		; ebp is the Z coordinate.
		mov	cl,9		; There are 9 vertex row.
@@1:
		mov	eax,@@SqEdge*(-4)	; eax is the X coordinate.
		mov	ch,9		; There are 9 vertex column.
@@2:
		stosd			; Store X.
		mov	[di],edx		; Store Y.
		mov	D [di+4],ebp           ; Store Z.
		add	di,8
		add	eax,@@SqEdge
		dec	ch
		jnz	@@2
		add	edx,@@SqEdge
		loop	@@1

		mov	ax,32		; There are 32 square.
		stosw
		mov	ax,1
		mov	bx,ax
		mov	cl,8		; 8 row.
@@3:
		mov	ch,4		; 4 squre in each rows.
@@4:
		stosw			; Store one sq.'s vertices'
		dec	ax		; numbers.
		stosw
		add	ax,9
		stosw
		inc	ax
		stosw
		sub	ax,7
		dec	ch
		jnz	@@4		; Next square.
		inc	ax
		add	ax,bx
		xor	bx,0fffeh
		loop	@@3		; Next row.
		ret
Mk_ChTable ENDP





; ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
; ³          Puts a text.          ³±
; ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±
;  ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

; Input:  ds:si= Address of text to put (ASCIIZ).
;         es:di= Screen position of text.
;         dl= Text's color.
;         dh= Text's background - text's color.
; Output: ds:si= The address of the 1st byte after the text.
;
; Modified regsiter(s): ax,bx,cx,dx,di,si,bp
; Length: 74 bytes.
; Last modified: 10-28-95 11:13am

PutText	PROC NEAR

; Entry point for putting text on VGA screen vertically.
;PutTextVGA_Vert:
;		mov	[@@Sub_di],0
;		jmp	@@PutTextVGA2

; Entry point for putting text on VGA screen horizontally.
PutTextVGA:
		mov	[@@Sub_di],32*320-32
@@PutTextVGA2:
		mov	bp,320-32
@@1:
		mov	[PText_Bkg],dh	; Set text colors.
		push	fs
		mov	fs,[ChrAddr]	; fs= Segment address of bigchars.
@@2:
		mov	bl,[si]	; bl= The current char to put.
		inc	si
		sub	bl,20h	; The 1st stored char is the space.

		jc	@@Exit	; Jump if it's the end of the string.
		mov	bh,0
		shl	bx,10	; bx= The offset address of the char.

		mov	cl,32	; We've got 32 row in a char.
@@3:
		mov	ch,4	; We've got 4*8 column in a char.
@@4:
		mov	dh,8
@@5:
		mov	al,fs:[bx]	; Putting a 8 dot wide part of a row.
		inc	bx
		test	al,al
		jz	@@6
		mov	al,dl
@@6:
		add	al,[PText_Bkg]
		stosb
		dec	dh
		jnz	@@5

		dec	ch
		jnz	@@4	; Next 8 dot wide part.

		add	di,bp	; di= next screen row.
		loop	@@3

		sub	di,1234h	; di= next char screen position.
	ORG $-2
@@Sub_di LABEL Word
	ORG $+2
		jmp	@@2	; Next char.
@@Exit:
		pop	fs
		ret

PutText	ENDP





; ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
; ³          Filling a poligon.             ³±
; ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±
;  ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

; Input:  ds:si= The vertices of the poligon. (X1,Y1, X2,Y2, ... in words.)
;                There must be one free space (2 words), after the coordinates.
;         cx= The number of the vertices
;         al= The color of the poligon
;         ah= Putting method. ( 0-Overwrite, 1-Or, 2-Gouraud )
;
; Modified regsiter(s): eax,bx,ecx,edx,edi,si,bp,es
; Length: 271 bytes.
; Last modified: 10-28-95 11:29am

FillPoli	PROC NEAR

		mov	[FPMethod],ah
		push	ax	; Store the color & the putting method.
		mov	eax,[si]
		mov	bx,cx
		shl	bx,2
		mov	[si+bx],eax	; Copy the 1st vertex after the last.
		cmp	[FPMethod],2
		jne	@@2
		mov	ax,[si+4*4+4]	; When gouraud, copy the 1 color
		mov	[si+4*4+4+4*4],ax ; after the last.
@@2:
		mov	[FPoliMin],7fffh  ; Clear the least,
		mov	[FPoliMax],8000h  ; and the greatest y coord.
@@3:
		push	cx
		lodsw		; Get one line.
		xchg	ax,bx	; ( Start: X=ax, Y=bx;
		lodsw		;   End:   X=dx, Y=cx.)
		xchg	ax,bx
		mov	dx,[si]
		mov	cx,[si+2]
		mov	bp,O FPoliTemp
		cmp	cx,bx
		jl	@@4	; Jump if the line is on the left side.
		mov	bp,O FPoliTemp+200*2
@@4:
		mov	[FPoliPnt],bp
		push	si
		mov	bp,O FillPoliEdge  ; This routine will store the edge.
		call	DrawEdge	; Draw an edge of the poligon.
		cmp	[FPMethod],2
		jne	@@5	; Jump if no gouraud nenned.
		pop	si
		push	si
		mov	ax,[si+16]
		mov	bx,[si-2]
		mov	dx,[si+20]
		mov	cx,[si+2]
		add	[FPoliPnt],200*2*2
		mov	bp,O FPGouraud
		call	DrawEdge	; Draw the color on the edge.
@@5:
		pop	si
		pop	cx
		loop	@@3	; Next edge line.

		mov	es,[ScrAddr]
		pop	ax	; Get back color.
		mov	bx,[FPoliMin]	; Poli.is between FPoliMin & FPoliMax.
		cmp	bx,7fffh
		je	@@14
@@6:
		mov	dx,320
		mov	di,[FPoliTemp][bx]	; di= Start X coord.
		cmp	di,dx		; Jump if beyond the right
		jge	@@13		; edge of the screen.
		test	di,di
		jns	@@7		; Jump if it's on the screen.
		xor	di,di		; Else put it to the left edge.
@@7:
		mov	cx,[FPoliTemp+200*2][bx]  ; cx= End x coord.
		test	cx,cx		; Jump if beyond the left
		js	@@13		; edge of the screen.
		cmp	cx,dx
		jl	@@8		; Jump if it's on the screen.
		mov	cx,dx		; Else put it to the right edge.
@@8:
		sub	cx,di		; cx= the length of the line.
		jle	@@13		; Jump if len. <= 0.
		add	di,[ScrRowsVGA][bx]	; di= screen position of line.
;		test	ah,ah
;		jnz	@@9		; Jump if overwrite mode.
;	rep	stosb		; Put the horizontal line onto the scr.
;		jmp	@@13
@@9:
		cmp	ah,1
		jne	@@11
@@10:
		or	B es:[di],al		; 'OR' the horizontal line
		inc	di		; onto the screen.
		loop	@@10
		jmp	@@13
@@11:
		push	ax		; Draw a gourauded hrz.line.
		mov	ax,[FPGouTemp+200*2][bx]
		mov	si,[FPGouTemp][bx]
		sub	ax,si	; ax= difference between the colors.
		shl	ax,8
		cwd
		idiv	cx
		xchg	ax,si	; si=addition for the colors.
				; ( Hi8 bit fract., Lo8 bit int. )
		mov	ah,80h	; ah= color fractational.
		add	al,[FPG_Col]	; al= color integer.
		ror	si,8
@@12:
		stosb
		adc	ax,si
		loop	@@12
		pop	ax
@@13:
		inc	bx
		inc	bx
		cmp	bx,[FPoliMax]
		jbe	@@6	; Next horizontal line.
@@14:
		ret
FillPoli	ENDP

; This routine stores the x coordinate of the edge.
FillPoliEdge PROC NEAR

		cmp	bx,200
		jae	@@FPE3	; Jump if Y coord. > 200  or  Y < 0.
		push	bx
		shl	bx,1
		cmp	bx,[FPoliMin]
		jge	@@FPE1	; Jump if greter than the min. so far.
		mov	[FPoliMin],bx	; Else store the new minimum.
@@FPE1:
		cmp	bx,[FPoliMax]
		jle	@@FPE2	; Jump if less than the max. so far.
		mov	[FPoliMax],bx	; Eles store the new maximum.
FPE_Store:
@@FPE2:
		shld	edx,edi,10h	; dx= integer part of x coord.
		add	bx,[FPoliPnt]	; bx= the y coord. in the edge buffer.
		mov	[bx],dx	; Store the x coord.
		pop	bx
FPE_Exit:
@@FPE3:
		ret
FillPoliEdge ENDP

; This routine stores the color of the edge for gouraud.
FPGouraud	PROC NEAR

		cmp	bx,200
		jae	FPE_Exit	; Jump if Y coord. > 200  or  Y < 0.
		push	bx
		shl	bx,1
		jmp	FPE_Store
FPGouraud	ENDP




; ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
; ³          Draws an 'edge line'.             ³±
; ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±
;  ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

; Draws a line. It chages the y coordinate with 1 (up or down) and gives
; the x coordinate accords to it. It is not draw a real line.
; You have to give the address of a routine what puts the point.
; In this routine you must not modify the registers, except edx. You can have
; y coordinate in bx, and x coorinate in the edi's higer 16 bits. (Huh!)
; Input:  ax,bx= Start point's x and y coordinate
;         dx,cx= End point's x and y coordinate
;         bp=    The offset address of the routine, what is called every steps
;
; Modified regsiter(s): eax,bx,ecx,edx,edi,si
; Length: 49 bytes.
; Last modified: 10-28-95 01:56pm

DrawEdge	PROC NEAR
		mov	si,1	; si will be the y step. ( 1 or -1.)
		sub	cx,bx	; cx= Y difference (dY).
		jz	@@Exit	; Jump if dY=0, 'coz no line then.
		jns	@@1	; Jump if dY>0. Going from up to down.
		neg	si	; Else y step is -1.
		neg	cx	; cx=ABS(dY)
@@1:
		sub	dx,ax	; dx= X difference (dX).
		mov	di,ax
		shl	edi,10h
		mov	di,0b000h	; edi= start point's x in fix point.
		xchg	ax,dx
		shl	eax,10h
		cdq		; edx:eax= dX in fix point.
		movzx	ecx,cx
		idiv	ecx	; eax= dX/dY in fix point.
		inc	cx	; Draw loger line by 1.
@@2:
		call	bp	; Call the point-putter.
		add	edi,eax	; Step X.
		add	bx,si	; Step Y.
		loop	@@2	; Next point.
@@Exit:
		ret
DrawEdge	ENDP





; ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
; ³          Fades down colors by 1.          ³±
; ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±
;  ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

; Input:  cl= The number of last color to fade. ( Starts with color 0. )
;
; Modified register(s): al,cx,dx,si,di
; Length: 44 bytes.
; Last modified: 10-02-95 04:42pm

FadeDown	PROC NEAR
		call	Raster	; Waiting for a vertical retrace.
@@1:
		mov	dx,3c7h
		mov	al,cl
		out	dx,al	; Choose color register to read.
		mov	dl,0c9h
		mov	ch,3
@@2:
		in	al,dx	; Get one color register's R or G or B.
		sub	al,1	; Decrement it.
		adc	al,0
		push	ax
		dec	ch
		jnz	@@2	; Next component.
		dec	dx
		mov	al,cl
		out	dx,al	; Choose color register to write.
		inc	dx
		pop	si	; Popping the components.
		pop	di
		pop	ax
		out	dx,al	; Set red component.
		xchg	ax,di
		out	dx,al	; Set green component.
		xchg	ax,si
		out	dx,al	; Set blue component.
		dec	cl
		cmp	cl,0ffh
		jne	@@1	; Next color.
		ret
FadeDown	ENDP




; ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
; ³          Clears the secopndary screen.            ³±
; ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±
;  ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

; Modified register(s): eax,cx,di,es
; Length: 9 bytes.
; Last modified: 10-02-95 04:42pm
; The next routine must be 'Fill0'!

ClrScr2	PROC NEAR
		mov	es,[ScrAddr]
		mov	cx,16000
ClrScr2	ENDP




; ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
; ³          Fills an area with zeros.            ³±
; ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±
;  ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

; Fills an area pointed by es:0 with 0 words. The length of filling is cx words.
; Input:  es= Segment address of filling
;         cx= Length of filling in words.
;         df= Cleared.
; Modified register(s): eax,cx,di
; Length: 9 bytes.
; Last modified: 10-02-95 04:42pm

Fill0	PROC NEAR

		xor	di,di
Fill0_2:
		xor	eax,eax
	rep	stosd
		ret
Fill0	ENDP




; ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
; ³          Waits for vertical retrace.          ³±
; ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±
;  ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

; Modified register(s): al,dx
; Length: 14 bytes.
; Last modified: 08-28-95 12:27pm

Raster	PROC NEAR
		mov	dx,3dah
@@1:
		in	al,dx	; Waiting for finish current vert.ret.
		test	al,8
		jnz	@@1
@@2:
		in	al,dx	; Waiting for vertical retrace.
		test	al,8
		jz	@@2
		ret
Raster	ENDP




; ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
; ³          Waits for some seconds.          ³±
; ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±
;  ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

; Input:  ax= The time for waiting (in 1/100 secs.) + 8000h
; Modified register(s): nothing
; Length: 11 bytes.
; Last modified: 10-03-95 08:31pm

Delay	PROC NEAR
		mov	[Timer_Cnt],ax
@@Delay_Loop:
		cmp	B [Timer_Cnt+1],0
		js	@@Delay_Loop
		ret
Delay	ENDP



; ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
; ³          Copyes the secondary screen onto the real screen.          ³±
; ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±
;  ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

; Modified register(s): ax, cx, di, si, ds, es
; Length: 23 bytes.
; Last modified: 10-07-95 05:12pm

Copy_Scr	PROC NEAR
		mov	ds,[ScrAddr]
		mov	ax,0a000h
		mov	es,ax
		xor	di,di
		xor	si,si
		mov	cx,16000
		call	Raster
	rep	movsd		; Then copy the sec.scr to the real.
		ret
Copy_Scr	ENDP





; ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
; ³          Sinus generator.          ³±
; ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±
;  ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

; Makes a sinus-cosinus table.
; Uses the taylor-progression of the sinus from 0 to pi/2, and copies
; this part of the function to the others.
; sin(x)÷x-(x^3/3!)+(x^5/5!)
;
; Input:  ds,es= Sinus table's segment
; Modified register(s): eax,bx,cx,edx,di,si,bp
; Length: 86 bytes.
; Last modified: 08-27-95 11:10pm

SinGen	PROC NEAR

		mov	di,O SinTab+128*4
		mov	si,O SinTab+127*4
		mov	ecx,381		; 381÷pi/2*256. (With a little
					; neglect.)
@@1:
		movzx	eax,cx
		mul	ecx
		mul	ecx
		div	[@@Fact3]
		mov	bp,ax		; bp= x^3/3!

		mul	ecx
		mul	ecx
		div	[@@Fact5]		; ax= x^5/5!

		mov	bh,cl
		mov	bl,0
		add	ax,bx
		sub	ax,bp		; ax=sin(x)

		stosd			; Store 2nd quater.
		mov	[si],eax		; Store 1st quater.
		mov	[si+512*4],eax		; Store 5th quater.
		neg	eax
		mov	[di+255*4],eax         ; Store 4th quater.
		mov	[si+256*4],eax 	; Store 3rd quater.
		sub	si,4
		sub	cx,3
		jnc	@@1
		ret
@@Fact3	dd 6*100h
@@Fact5	dd 20*10000h
SinGen	ENDP




; ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
; ³          Makes charset.           ³±
; ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±
;  ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

; Makes the big and smoothed charset.
; Modified register(s): ax,bx,cx,dx,di,bp,fs
; Length: 167 bytes.
; Last modified: 10-28-95 02:05pm

MakeChars	PROC NEAR

		mov	ax,1130h
		mov	bh,6	; Get the 8x16 ROM charset address
		int	10h	; to es:bp.

		add	bp,32*16	; es:bp point to the space character.

		mov	fs,[ChrAddr]
; Making big chars.
		xor	di,di
		mov	bx,4040h	; We've got free space for 64 chars.
@@1:
		mov	cl,16
@@2:
		mov	al,es:[bp]
		inc	bp
		mov	ch,8
@@3:
		shl	al,1	; Make one big dot.
		setc	dl
		mov	dh,dl
		push	dx
		shl	edx,10h
		pop	dx
		mov	fs:[di],edx
		mov	fs:[di+32],edx
		add	di,4
		dec	ch
		jnz	@@3
		add	di,32
		loop	@@2
		dec	bl
		jnz	@@1

; Smoothing chars.
; bh=40h here.
		xor	di,di
		mov	dx,303h
		mov	al,1
@@4:
		mov	cl,15
@@5:
		mov	ch,8
@@6:
		cmp	B fs:[di],al		; Jump if dot is here.
		jne	@@10
		cmp	ch,8
		je	@@8		; Jump at the left edge.
		cmp	B fs:[di+32*2-1],al
		jne	@@8		; Jump if no dot at letf-below.
		cmp	B fs:[di-1],al
		je	@@7		; Jump if dot at left.
		mov	fs:[di+32-2],dx	; Put a 3angle at left. /.
@@7:
		cmp	B fs:[di+32*2],al
		je	@@8		; Jump if dot at below.
		mov	fs:[di+32*2],dx	; Put a 3angle at rght-blw. `/
@@8:
		cmp	ch,1
		je	@@10		; Jump at the right edge.
		cmp	B fs:[di+32*2+4],al
		jne	@@10		; Jump if no dot at right-below.
		cmp	B fs:[di+4],al
		je	@@9		; Jump if dot at rigth.
		mov	fs:[di+32+4],dx	; Put 3angle at right. .\
@@9:
		cmp	B fs:[di+32*4],al
		je	@@10		; Jump if dot at below.
		mov	fs:[di+32*2+2],dx	; Put 3angle at below. \'
@@10:
		add	di,4
		dec	ch
		jnz	@@6		; Check next dot.
		add	di,32
		dec	cx
		jnz	@@5		; Check next row.
		add	di,32*2
		dec	bh
		jnz	@@4		; Check next char.
		ret
MakeChars	ENDP




; ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
; ³          Puts a gourauded object.             ³±
; ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±
;  ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

; Input:  ds:si= Address of the object to put.
; Modified register(s): eax,bx,cx,edx,di,si,bp,es
; Length: 154 bytes.
; Last modified: 10-28-95 02:47pm

Put_Obj	PROC NEAR

		push	cs
		pop	es

		lodsw
		mov	cx,ax	; cx= number of vertices.

; Rotating the vertices.
		mov	di,O TempArea
		push	cx di di
		call	Rotate	; si=original, di=rotated, cx=number.
		pop	di

; Sorting the poligons, by their weightpoints.
		mov	[POPoliAdr],si
		call	WPSort	; di=adr.rotd.,si=adr.polis; to WPTemp.
		pop	si cx

; Transforming the vertices from 3D to 2D.
		push	si
		mov	si,O TempArea
		call	Transform	; si=adr.of rotated,cx=num.of vertices.
		pop	si

		mov	bp,[POPoliAdr]
		mov	cx,[bp]	; cx= number of poligons.
		inc	bp
		inc	bp
		mov	bx,4
@@1:
		pusha
		mov	bx,W [WPTemp][bx]	; bx= number of poligon to put.
		shl	bx,3
		add	bx,bp
		push	cs
		pop	es
		mov	di,O POTemp
		mov	cl,4	; There are 4 vertices in a square. :)
@@2:
		push	si	; Count the color of the vertex by
		mov	bp,[bx]	; its distance from the light source
		inc	bx	; and make the coordinates of the
		inc	bx	; poligon on the screen.
		shl	bp,4
		add	si,bp
		lodsd
		add	ax,160	; XCenter=160.
		stosw		; Store its X coordinate.
		lodsd
		add	ax,100	; YCenter=100.
		stosw		; Store its X coordinate.
		lodsd
		sub	eax,[PO_XLight]
		imul	eax
		mov	ebp,edx
		lodsd
		sub	eax,[PO_ZLight]
		imul	eax
		add	ebp,edx
		mov	eax,[LS_Circ]
		imul	ebp
		mov	ax,2ch
		sub	ax,dx
		jnc	@@3
		xor	ax,ax
@@3:
		add	ax,13h	; Make ambient light.
		mov	[di+16],ax
		pop	si
		dec	cl
		jnz	@@2	; Do the next vertex.

		mov	si,O POTemp	; si=adr.of the poli's coordinates.
		mov	ah,2	; Put by gouraud.
		mov	cx,4	; It's got 4 vertices.
		call	FillPoli	; Put the poligon
@@4:
		popa
		add	bx,8
		loop	@@1	; Do the next poligon.

		ret


Put_Obj	ENDP




; ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
; ³          Sorting by the weightpoints.             ³±
; ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±
;  ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

; Input:  ds:si= Address of the object's poligons. (1st W is the num.of polis.)
; Modified register(s): eax,ebx,cx,edx,di,si,ebp
; Length: 52 bytes.
; Last modified: 10-28-95 05:57pm
; Quick Sort must be the following routine!

WPSort	PROC NEAR

		lodsw
		add	di,8
		mov	cx,ax	; cx= number of poligons.
		mov	bx,O WPTemp
		xor	eax,eax
		push	cx bx
@@1:
		xor	edx,edx
		mov	ch,4
@@2:
		mov	bp,[si]	; bp= number of vertex of the poligon.
		inc	si
		inc	si
		shl	bp,4
		add	edx,[di+bp]	; edx+= Z coordinate.
		dec	ch
		jnz	@@2
		neg	edx
		mov	[bx],edx
		mov	[bx+4],eax
		inc	eax
		add	bx,8
		loop	@@1	; Next poligon.
		pop	si cx
		;jmp	QuickSort

WPSort	ENDP



; ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
; ³          Quick Sort.             ³±
; ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±
;  ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

; Input:  ds:si= Address of the object's poligons. (1st W is the num.of polis.)
; Modified register(s): eax,ebx,dx,di,ebp
; Length: 116 bytes.
; Last modified: 10-28-95 06:13pm

QuickSort	PROC NEAR

		mov	di,cx
		shl	di,3
		add	di,si
		mov	dx,8
		mov	ebx,7fffffffh
		mov	ebp,80000000h
@@QSR:
		cmp	di,si
		je	@@Exit
		mov	eax,ebx
		add	eax,ebp
		sar	eax,1
		cmp	eax,ebp
		je	@@Exit
		push	si di ebp
		call	@@Sort	; Sort it.
		pop	ebp di
		pushad
		mov	ebp,eax
		call	@@QSR	; Sort the first half.
		popad
		pop	di
		xchg	di,si
		mov	ebx,eax
		jmp	@@QSR	; Sort the second half.
@@Exit:
		ret

@@Sort:
		sub	si,dx
@@S1:
		add	si,dx	; si goes from the beginning.
		cmp	si,di
		jae	@@Exit
		cmp	eax,[si]
		jge	@@S1	; si goes until the order is right.
@@S2:
		sub	di,dx	; di goes from the end.
		cmp	di,si
		jbe	@@Exit
		cmp	eax,[di]
		jl	@@S2	; di goes until the order is right.
		mov	ebp,[si]	; Change the items.
		xchg	ebp,[di]
		mov	[si],ebp
		mov	ebp,[si+4]
		xchg	ebp,[di+4]
		mov	[si+4],ebp
		jmp	@@S1

QuickSort	ENDP





; ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
; ³          Rotating.             ³±
; ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±
;  ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

; Input:  ds:si= Address of the vertices to rotatae.
;         ds:di= Address of the buffer for rotated coordinates.
;         cx= Number of vertices to rotate.
; Modified register(s): eax,ebx,cx,edx,di,si,ebp
; Length: 158 bytes.
; Last modified: 10-28-95 06:23pm

Rotate	PROC NEAR

@@1:
		lodsd
		add	eax,[Trans_XAdd]
		mov	[di],eax
		lodsd
		add	eax,[Trans_YAdd]
		mov	[di+4],eax
		lodsd
		add	eax,[Trans_ZAdd]
		mov	[di+8],eax

		mov	bp,[Rot_Alfa]
		and	bp,511
		shl	bp,2
		mov	ebx,[CosTab][bp]
		mov	ebp,[SinTab][bp]
		call	@@Rotate1	; Rotate around the Z axis.

		mov	bp,[Rot_Beta]
		and	bp,511
		shl	bp,2
		mov	ebx,[CosTab][bp]
		mov	ebp,[SinTab][bp]
		call	@@Rotate1	; Rotate around the Y axis.

		mov	eax,[di-8]
		add	di,4
		stosd
		loop	@@1
		ret

@@Rotate1:
		mov	eax,[di]
		imul	ebx	; X= X*cos(alfa)-Y*sin(alfa).
		shld	edx,eax,10h
		push	edx
		mov	eax,[di+4]
		imul	ebp
		shld	edx,eax,10h
		pop	eax
		sub	eax,edx
		xchg	eax,[di]
		imul	ebp	; Y= Y*cos(alfa)+X*sin(alfa).
		shld	edx,eax,10h
		push	edx
		add	di,4
		mov	eax,[di]
		imul	ebx
		shld	edx,eax,10h
		pop	eax
		add	eax,edx
		mov	[di],eax
		ret
Rotate	ENDP




; ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
; ³          Transforms from 3D to 2D.            ³±
; ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±
;  ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

; Input:  ds:si= Address of the vertices to transform.
;         cx= Number of vertices to transform.
;         es=ds.
; Modified register(s): eax,ebx,cx,edx,di,si,ebp
; Length: 46 bytes.
; Last modified: 10-28-95 06:28pm

Transform	PROC NEAR

		mov	di,si
		movzx	ebx,[Zoom_Factor]
@@1:
		mov	ebp,[si+8]
		add	ebp,400*10000h
		lodsd		; Xh= X/(Z+400) * Zoom_Factor
		imul	ebx
		idiv	ebp
		stosd
		lodsd		; Xh= X/(Z+400) * Zoom_Factor
		imul	ebx
		idiv	ebp
		stosd
		movsd
		movsd
		loop	@@1	; Do the next vertex.
		ret
Transform	ENDP




; ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
; ³          Makes an object from a contour.           ³±
; ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±
;  ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

; Input:  ds:si= Address of the vertices of the contour.
;         cs:di= Address of the room for the object
;         bx= Number of vertices of the contour.
; Modified register(s): eax,cx,di,es
; Length: 142 bytes.
; Last modified: 10-31-95 04:52pm

Make_Obj	PROC NEAR
MkObj_Circ_Div=6		; Rotating angle. Divisor of 2*PI.

		push	cs
		pop	es
		xor	eax,eax	; Clear the coordinates' additions.
		mov	[Trans_XAdd],eax
		mov	[Trans_YAdd],eax
		mov	[Trans_ZAdd],eax
		mov	ax,MkObj_Circ_Div
		mov	cx,ax
		mul	bx	; ax= number of vertices in the object.
		stosw		; Store the number of vertices.
		xor	ax,ax
		mov	[Rot_Beta],ax	; Clear the angle beta.
@@1:
		mov	[Rot_Alfa],ax
		push	ax bx cx si
		mov	cx,bx
@@2:
		lodsb
		cbw
		cwde
		shl	eax,0fh	; Copy the 3 coordinates to TempArea.
		mov	D [TempArea],eax
		xor	eax,eax
		mov	D [TempArea+4],eax
		lodsb
		shl	eax,0fh
		mov	D [TempArea+8],eax

		push	cx si
		mov	si,O TempArea
		mov	cx,1
		call	Rotate	; Rotata a vertex.
		sub	di,4
		pop	si cx
		loop	@@2	; Do the next vertex.
		pop	si cx bx ax
		add	ax,512/MkObj_Circ_Div
		loop	@@1	; Do the next phase.

		mov	ax,MkObj_Circ_Div
		mul	bx
		mov	bp,ax
		sub	ax,MkObj_Circ_Div
		mov	cx,ax	; ax= number of poligons.
		stosw		; Store the number of poligons.
		mov	si,1
		mov	cl,MkObj_Circ_Div
@@3:
		mov	ch,bl
		dec	ch
@@4:
		mov	ax,si	; Make a poligon.
		stosw
		dec	ax
		stosw
		add	ax,bx
		cmp	ax,bp
		jb	@@5
		sub	ax,bp
@@5:
		stosw
		inc	ax
		stosw
		inc	si
		dec	ch
		jnz	@@4	; Do the next poligon.
		inc	si
		loop	@@3	; Do the next phase.
Timer_Blank:
		ret
Make_Obj	ENDP




; ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
; ³          Timer interrupt.          ³±
; ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±
;  ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

; Decrases the 'Timer_Cnt' in every 10th ms.
;
; Length: 12 bytes.
; Last modified: 08-27-95 11:17pm

TimerIRQ	PROC
		push	ax ds cs
		pop	ds
		dec	[Timer_Cnt]		; Decrase counter.
		call	[Timer_Routine]	; Calling a control routine.
		mov	al,20h		; Send EnfOfInterrupt sign.
		out	20h,al
		pop	ds ax
		iret
TimerIRQ	ENDP




; ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
; ³          Keyboard interrupt.          ³±
; ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±
;  ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

; Aborts the program when ESC was pressed.
;
; Length: 36 bytes.
; Last modified: 08-28-95 02:50pm

KeyboardIRQ PROC
		push	ax
		mov	al,20h		; Send EnfOfInterrupt sign.
		out	20h,al

		in	al,60h		; Get the pressed scan-code.
		dec	al
		jz	@@1		; Jump if it is ESC.
		pop	ax
		iret
@@1:
		push	cs		; Set back ds.
		pop	ds
		mov	ss,[StackSegment]	; Set back ss.
		mov	sp,[StackPointer]	; Set back sp.
		mov	bl,40h
@@2:
		mov	cl,0ffh
		call	FadeDown
		dec	bl
		jnz	@@2

		jmp	Abort_Code		; Abort the program.

KeyboardIRQ ENDP




; ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
; ³         Variables.            ³±
; ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±
;  ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±



; General variables.

ALIGN 4
Old_Timer	LABEL DWord	; The original INT8 vector.
	ORG $+4
Timer_Cnt	LABEL Word	; Timer counter. Decrased in every 10th ms.
	ORG $+2
Timer_Routine LABEL Word	; A definable timer routine.
	ORG $+2
Old_Kbd	LABEL DWord	; The original INT9 vector.
	ORG $+4
StackSegment LABEL Word	; The stored SS for aborting.
	ORG $+2
StackPointer LABEL Word	; The stored SP for aborting.
	ORG $+2

ScrAddr	LABEL Word	; Segment address of the seconday screen.
	ORG $+2
ScrOffs	LABEL Word	; Offset address of the secondary screen.
	ORG $+2
ChrAddr	LABEL Word	; Segment address of the big characters.
	ORG $+4

ScrRowsVGA LABEL Word	; Offset of rows in a VGA screen.
	ORG $+200*2

SinTab	LABEL DWord	; The sinus table.
	ORG $+128*4
CosTab	LABEL DWord	; The cosinus table.
	ORG $+512*4
CosAdd=O CosTab - O SinTab  ; Addition to the addr.of the sintab to get the
                            ; costab's addr.

; Mandelbrot zoomer's variables

MZ_ScrSeg	LABEL Word	; Secondary screen's address.
	ORG $+2
MZ_XorScr	LABEL Word	; XOR number to get the third screen's address.
	ORG $+2
MZ_Next	LABEL Byte	; Bit0 is set, when the next Mandy-phase is ready.
	ORG $+1
MZ_Finish	LABEL Byte	; 1, when Mandelbrot-part is over.
	ORG $+1
MZ_TextPos LABEL Word	; Addr.for texts to put while Mandelbrot-part.
	ORG $+2
MZ_RowCnt	LABEL Byte	; A counter to indicate, no more non-zero value
	ORG $+4	; in the Mandelbrot.


; Broken screen's variables.

BrkTemp	LABEL Word	; A temporary area for storing poligons' vertices.
	ORG $+5*2*2
;BrkLTemp	LABEL Word	; A tmp.area for storing breaking line.
;	ORG $+BrkPntNum*2
;BrkPoliXC	LABEL Word	; X center of the light.
;	ORG $+2
;BrkPoliYC	LABEL Word	; Y center of the light.
;	ORG $+2
BrkPoliXS	LABEL Word	; The position of the refracted line.
	ORG $+4


; Putting a text' variable

PText_Bkg	LABEL Byte	; The background of the text.
	ORG $+4


; Putting an object's variables

POPoliAdr	LABEL	Word	; Addr.of the poligons.
	ORG $+4
POTemp	LABEL DWord	; Tmp.area for the vertices of a poligon.
	ORG $+128


; Filling a convex poligon's variables.

FPoliTemp	LABEL Word	; The edge of the poligon of the put.
	ORG $+200*4
FPGouTemp	LABEL Word	; The colors of the edges.
	ORG $+200*4
FPoliPnt	LABEL Word	; The pointer to FPoliTemp.
	ORG $+2
FPoliMin	LABEL Word	; The minimum of the Y coordinates.
	ORG $+2
FPoliMax	LABEL Word	; The maximum of the Y coordinates.
	ORG $+2
FPMethod	LABEL Byte	; The method of the putting.
	ORG $+1
FPG_Col	LABEL Byte	; The color of the poligon.
	ORG $+1


; Transfom's variables

Trans_XAdd LABEL DWord	; The additiions for coordinates.
	ORG $+4
Trans_YAdd LABEL DWord
	ORG $+4
Trans_ZAdd LABEL DWord
	ORG $+4


; Sorting by the weigthpoints' variables

WPTemp	LABEL DWord	; The quick sort makes the sorting here.
	ORG $+200*8


; Chess figures' position

ChFig_Dat LABEL		; Data of the chess-figures.
	ORG $+FigsOn*4
ChFig_Srt	LABEL DWord	; The sorted figures' positions.
	ORG $+FigsOn*20


; Chess figures' objects

Chess_Table LABEL	; The chess-table's object.
	ORG $+1232
Pawn	LABEL		; The figres' object.
	ORG $+(4+ PVtx*12*MkObj_Circ_Div+ (PVtx-1)*8*MkObj_Circ_Div)
Bishop	LABEL
	ORG $+(4+ BVtx*12*MkObj_Circ_Div+ (BVtx-1)*8*MkObj_Circ_Div)
Castle	LABEL
	ORG $+(4+ CVtx*12*MkObj_Circ_Div+ (CVtx-1)*8*MkObj_Circ_Div)
Queen	LABEL
	ORG $+(4+ QVtx*12*MkObj_Circ_Div+ (QVtx-1)*8*MkObj_Circ_Div)
King	LABEL
	ORG $+(4+ KVtx*12*MkObj_Circ_Div+ (KVtx-1)*8*MkObj_Circ_Div)

ALIGN 4
Old_Values LABEL
	ORG $+2
Rot_Alfa	LABEL Word	; The angles of rotating.
	ORG $+4
Rot_Beta	LABEL Word
	ORG $+4
Zoom_Factor LABEL Word	; The zooming factor of trasforming.
	ORG $+2
PO_XLight	LABEL DWord	; The light source's coordinates.
	ORG $+4
PO_ZLight	LABEL DWord
	ORG $+4
LS_Circ	LABEL DWord	; The light circle's size.
	ORG $+4
Eye_XAdd	LABEL DWord	; Our eye's position.
	ORG $+4
Eye_YAdd	LABEL DWord
	ORG $+4
Eye_ZAdd	LABEL DWord
	ORG $+4
ChFig_Pos LABEL DWord	; The positions of the chess figures.
	ORG $+FigsOn*12

ALIGN 4
New_Values LABEL		; The table of changed values for moving.
	ORG $+400


; Temporary area.

TempArea	LABEL		; The temporary area up to the stack.


code ENDS

END Main
