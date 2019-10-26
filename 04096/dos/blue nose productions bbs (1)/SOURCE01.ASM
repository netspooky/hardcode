;∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
; Remember: TAB-Size is 4 on this File!
;
; Don't Worry, It's Just Coded By Troop In Just The Early Attempts On Doing
; Some Real Stuff...
;
; Some Text About The Logo: (Chiparus.Asm)
; The Main Screen Has 16 Colors  (Huh?). The logo uses up 15 of them already
; so, no really cool crunch stuff could be made. (well, could be, but it's an
; intro remember?) The Logo is 'Packed' As follows: The First Nibble is the
; color of the first pixel, the 2nd nibble is the 2nd pixel... Well, Ain't
; This easy... Well....
; The only damn reason is that almost no pcx converter can write this format,
; and most converters cant even do 640x480x16 (and not even cut out a block
; of 640x64.) Well.. Lame Stuff Eh?
; I Used Some silly shareware stuff (Back from 1988 or so) which did the
; global work for me. I Then just wrote the first 640x64/2 bytes from it to
; nibbles in a data file...
;
; Figure out yourself if you really want to.
;
; The basic stuff around this intro is just made up a pixelplotting routine.
; and it's not really optimized (Think of moving the port-stuff in the main-
; code) But for such an intro it's absolutely not needed to optimize.
; at least its done in asm, like most bbs-intro's are done in pascal (Which
; greatly sucks)  :>
;
; Well, what is this all about???
;
;
; GET STONED AND DIAL!!! +31-345-619-401
;
;
;∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
				DOSSEG
				IDEAL
				P386
				MODEL   SMALL
				STACK   768
				ASSUME  CS:_TEXT,DS:_DATA
;∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;
;
;
;∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
		CODESEG
;∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
; Main Function/Startup Code.
;-----------------------------------------------------------------------------
PROC            Main

				mov		ax,01130h				;; Get ROM 8x14 Font Ptr.
				mov		bh,06h
				int		010h
				mov		[Word Ptr Font_Seg],ES
				mov		[Word Ptr Font_Off],BP

				mov		AX,12h					;; Set 640x480x16
				int		10h
				call    PutPicture

				mov		cx,32					;; Create A Double Line
				mov		ax,8
@@MakeLine:     mov		bx,127
				call	PutPixel
				mov		bx,129
				call	PutPixel
				mov		bx,415
				call	PutPixel
				mov		bx,417
				call	PutPixel
				inc		cx
				cmp		cx,640-32
				jne		@@MakeLine

				mov		CX,64
@@FadeI:		call	Retrace
				call	Retrace
				call	FadeIn
				loop	@@FadeI

@@WaitKey:		call	Retrace
				call	Writer
				mov     AH,01h                  ;; Check For KeyPress
				int     16h
				jz      @@WaitKey

				mov		CX,64
@@FadeO:		call	Retrace
				call	Retrace
				call	FadeOut
				loop	@@FadeO

				mov     AX,03h                  ;; TextMode
				int     10H
				mov     AH,00h                  ;; Read Pressed Key
				int     16h
				mov     AX,04C00h               ;; Return To DOS
				int     21h
				ret
ENDP
;∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
; Screen Clearer For Use With The Writer
;-----------------------------------------------------------------------------
PROC			ClearScreen

				push	ax
				push	cx
				push	bx
				push	dx
				push	es

				mov		ah,0ffh
				mov     DX,3CEh             ; GC address register port
                                mov     AL,8                ; AL = Bit Mask Register number
				out     DX,AX
				mov     AX,0205h
				out     DX,AX
                                mov     AX,3                ; AL = Data Rotate/Func select reg #
				out     DX,AX

				mov		ax,0a000h
				mov		es,ax

				xor		ax,ax
				xor		dx,dx
@@fil2:			call	Retrace
				mov		bx,160*80
				add		bx,dx
				mov		cx,384-160
@@fil1:			mov		[es:bx],al
				add		bx,80
				loop	@@fil1
				inc		dx
				cmp		dx,80
				jne		@@fil2


;@@screen:		call	Retrace
;				mov		cx,320
;@@line:			mov		[es:bx],al
;				inc		bx
;				loop	@@line
;				inc		dx
;				cmp		dx,(480-160)/4
;				jne		@@screen

				pop		es
				pop		dx
				pop		bx
				pop		cx
				pop		ax
				ret
ENDP
;∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
; Line Writer. Call From Retrace.
;-----------------------------------------------------------------------------
PROC			Writer

				cmp		[Word Ptr Delay],0
				je		@@go
				dec		[Word Ptr Delay]
				ret
@@go:			mov		[Word Ptr Delay],0
				cmp		[Word Ptr Clear_Flag],1
				jne		@@doit
				call	ClearScreen
				mov		[Word Ptr Clear_Flag],0
@@no:			ret
@@doit:			mov		di,Offset Write_Text
				add		di,[Word Ptr Write_Pos]
				inc		[Word Ptr Write_Pos]

				mov		al,12					; color
				mov		bx,[Word Ptr Write_Y]	; y
				mov		cx,[Word Ptr Write_X]	; x
				mov		ah,[cs:di]				; char
				cmp		ah,07h
				je		@@continue1
				cmp		ah,09h
				je		@@tab1
				cmp		ah,0ah
				je		@@endofline1
				cmp		ah,00h
				je		@@endoftext1
				cmp		ah,0ffh
				je		@@startover1
				call	PutChar
				add		[Word Ptr Write_X],8
				jmp		@@continue1
@@delay1:		mov		[Word Ptr Delay],25
				jmp		@@continue1
@@tab1:			add		[Word Ptr Write_X],64
				jmp		@@continue1
@@endofline1:	mov		[Word Ptr Write_X],0
				add		[Word Ptr Write_Y],32
@@continue1:

				mov		ax,[Word Ptr Write_X]
				push	ax
				mov		ax,[Word Ptr Write_Y]
				push	ax

				mov		al,11					; color
				mov		di,Offset Write_Text
				add		di,[Word Ptr Write_Pos]

@@herewego:		mov		bx,[Word Ptr Write_Y]	; y
				mov		cx,[Word Ptr Write_X]	; x
				mov		ah,[cs:di]				; char
				cmp		ah,07h
				je		@@delay
				cmp		ah,09h
				je		@@tab
				cmp		ah,0ah
				je		@@endofline
				cmp		ah,00h
				je		@@endoftext
				cmp		ah,0ffh
				je		@@startover
				call	PutChar

				add		[Word Ptr Write_X],8
				inc		di
				jmp		@@continue
@@delay:		mov		[Word Ptr Delay],25
				jmp		@@continue
@@tab:			add		[Word Ptr Write_X],64
				jmp		@@continue
@@endofline:	mov		[Word Ptr Write_X],0
				add		[Word Ptr Write_Y],32
				inc		di

@@continue:		dec		al
				cmp		al,0
				jne		@@herewego

				pop		ax
				mov		[Word Ptr Write_Y],ax
				pop		ax
				mov		[Word Ptr Write_X],ax
				ret

@@endoftext:	pop		ax
				pop		ax
				ret
@@endoftext1:	mov		[Word Ptr Clear_Flag],1
				mov		[Word Ptr Write_Y],160
				mov		[Word Ptr Write_X],0
				ret

@@startover:	pop		ax
				pop		ax
@@startover1:   mov		[Word Ptr Write_Pos],0
				mov		[Word Ptr Write_Y],160
				mov		[Word Ptr Write_X],0
				ret
ENDP

Delay:			dw		0
Clear_Flag:		dw		0
Write_Pos:		dw		0
Write_Y:		dw		160
Write_X:		dw		0
Write_Text:
include	"de_text.txt"

;∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
; Put A Character On The Screen
; Inputs: 	AL=Color
;			AH=Char To Print
;			BX=Y-Pos(!)
;			CX=X-Pos(!)
;-----------------------------------------------------------------------------
PROC			PutChar

				push    AX                      ;; Save Registers
				push    BX
				push    CX
				push    DX
				push    DI
				push    ES

				mov		es,[Word Ptr Font_Seg]
				mov		di,[Word Ptr Font_Off]
				xor		dx,dx
				mov		dl,ah
				shl		dx,4
				add		di,dx

				mov		dx,16
@@doline:		push	dx
				mov		dx,080h
@@nextdot:		test	[es:di],dx
				jz		@@nodot
				call	PutPixel
				inc		bx
				call	PutPixel
				dec		bx
@@nodot:		inc		cx
				shr		dx,1
				jnz		@@nextdot
				pop		dx
				inc		di
				add		bx,2
				sub		cx,8
				dec		dx
				jnz		@@doline

				pop     ES
				pop     DI
				pop     DX
				pop     CX
				pop     BX
				pop     AX
				ret

ENDP
;∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
; Put Picture On The Screen
;-----------------------------------------------------------------------------
PROC            PutPicture

				push    AX                      ;; Save Registers
				push    BX
				push    CX
				push    DX
				push    DS
				push    ES

				cli								;; Create a Black Palette
				mov		DX,03c8h
				xor		AX,AX
				out		DX,AL
				mov		DX,03c9h
				mov		CX,48
@@FillPalette:	out		DX,AL
				loop	short @@FillPalette

				mov     DX,3C0h					;; Create a Linear Palette instead of EGA-Palette.
				mov		CX,16
				xor		AL,AL
@@pl1:          out		DX,AL   	        	;; Output index.
				out		DX,AL       		    ;; Output value. Value == index.
				inc		AL
				loop	short @@pl1

				mov     AL,34h  		        ;; Redo it, activating the VGA along.
				out     DX,AL
				xor     AL,AL
				out     DX,AL          			;; Force DAC index bits p4-p7 == 0.
				sti

				mov		AX,SEG Picture
				mov		DS,AX
				mov		SI,OFFSET Picture
				mov		BX,32					;; Y-Pos
				mov		CX,64
@@Loop2:		push	CX
				mov		CX,0					;; X-Pos
@@Loop1:		mov		AL,[DS:SI]
				shr		AL,4
				and		AL,0fh
				call	PutPixel
				inc		CX
				mov		AL,[DS:SI]
				and		AL,0fh
				call	PutPixel
				inc		CX
				inc		SI
				cmp		CX,640
				jne		@@Loop1
				inc		BX
				pop		CX
				loop	@@Loop2

				pop     ES
				pop     DS
				pop     DX
				pop     CX
				pop     BX
				pop     AX
				ret
ENDP
;∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
; Put a Pixel On The Screen
;-----------------------------------------------------------------------------
PROC			PutPixel								;; CX=x BX=y AX=color

				push	AX
				push	BX
				push	CX
				push	DX
				push	DS
				push	ES
				push	SI

				push	AX
				mov     AX,BX
				mov     BX,CX
				mov		CX,80
				mul     CX                  ; DX:AX == y * BytesPerLine

				mov     CL,BL               ; CL == low-order byte of x
				shr     BX,3                ; BX == x/8
				add     BX,AX

				mov     AX,0a000h
				mov     ES,AX

				mov     AH,1                ; AH := unshifted bit mask
				and     CL,7                ; CL := x & 7
				xor     CL,7                ; CL := # bits to shift left

				shl     AH,CL               ; AH := bit mask in proper postion
				mov     DX,3CEh             ; GC address register port
				mov     AL,8                ; AL := Bit Mask Register number
				out     DX,AX
				mov     AX,0205h
				out     DX,AX
				mov     AX,3                ; AL := Data Rotate/Func select reg #
				out     DX,AX

				pop		CX
				mov     AL,[ES:BX]          ; latch one byte from each bit plane
				mov     AL,CL		        ; AL := pixel value
				mov     [ES:BX],AL          ; update all bit planes

				pop		SI
				pop		ES
				pop		DS
				pop		DX
				pop		CX
				pop		BX
				pop		AX
				ret
ENDP
;∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
; Fade Palette Data In Then Call Palette To Registers...
;-----------------------------------------------------------------------------
PROC            FadeIn

				push	CX
				push    DS
				push	DI
				push	SI

				mov		DI,OFFSET Palette
				mov		SI,OFFSET RealPalette

				mov		CX,48
@@CalcFade:		mov		DL,[CS:DI]
				mov		DH,[CS:SI]
				cmp     DL,DH
				je		@@NextCol
				inc		DL
				mov		[CS:DI],DL
@@NextCol:		inc		DI
				inc		SI
				loop	@@CalcFade
				call	SetPalette

				pop		SI
				pop		DI
				pop     DS
				pop     CX
				ret
ENDP
;∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
; Fade Palette Data Out Then Call Palette To Registers...
;-----------------------------------------------------------------------------
PROC            FadeOut

				push    CX
				push	DI

				mov		DI,OFFSET Palette

				mov		CX,48
@@CalcFade:		mov		DL,[CS:DI]
				cmp     DL,0
				je		@@NextCol
				dec		DL
				mov		[CS:DI],DL
@@NextCol:		inc		DI
				loop	@@CalcFade
				call	SetPalette

				pop		DI
				pop     CX
				ret
ENDP
;∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
; Put Palette Data In Palette Registers
;-----------------------------------------------------------------------------
PROC            SetPalette

				push    AX                      ;; Save Registers
				push    DX
				push    ES
				push	DI

				mov		DI,OFFSET Palette
				mov		CX,48

				cli
				mov		DX,03c8h
				xor		AX,AX
				out		DX,AL
				mov		DX,03c9h
@@WritePal:		mov		AL,[CS:DI]
				out		DX,AL
				inc		DI
				loop	@@WritePal
				sti

				pop		DI
				pop     ES
				pop     DX
				pop     AX
				ret
ENDP
;∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
; Synchronize to The Vertical Screen Retrace.
;
; Last Edited...: 06/08/95
; Version.......: v1.0
;-----------------------------------------------------------------------------
PROC            Retrace

				push    DX
				push    AX

				mov     DX,03DAh                ;; Wait For End of Retrace
@@LPWaitStart:  in      AL,DX
				and     AL,08h
				jnz     @@LPWaitStart

				mov     DX,03DAh                ;; Wait For Start of Retrace
@@LPWaitEnd:    in      AL,DX
				and     AL,08h
				jz      @@LPWaitEnd

				pop     AX
				pop     DX
				ret
ENDP
;∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€
;∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
Palette:		DB		48 dup (0)
RealPalette:	DB      07h,07h,3Fh
				DB		07h,07h,3fh
				DB		0bh,0bh,3fh
				DB		0fh,0fh,3fh
				DB		13h,13h,3fh
				DB		17h,17h,3fh
				DB		1bh,1bh,3fh
				DB		1fh,1fh,3fh
				DB		23h,23h,3fh
				DB		27h,27h,3fh
				DB		2bh,2bh,3fh
				DB		2fh,2fh,3fh
				DB		33h,33h,3fh
				DB		37h,37h,3fh
				DB		3bh,3bh,3fh
				DB		3fh,3fh,3fh

Font_Seg:		Dw		0h
Font_Off:		Dw		0h


		ENDS
;---------------------
		DATASEG
;∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞

LABEL			Picture
INCLUDE 		"CHIPARUS.ASM"

;∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
		ENDS
;------------------
		END
;∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€
;∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;
;
;
; Want Any Comment.     Then Call Our Board (It's worth checking out!)
; And Leave a Message To Troop.....                  
;
;
; Or, if you are stuck by your feelings: bluenose@pi.net
; 
;
;
;           ------------------------------------------------------- 
;          |               -=˛ Blue Nose Productions ˛=-
;          :                      +31-345-619-401
;          ˘
;          ˙               Assembly/Pascal Demo Sources
;                            Huge ChipTunes Collection
;                             Cannabis/Coke/Lsd Files
;                              Analog Gravis Patches
;                               Samples At Request!
;
;                          Home Made Board Configuration
;                             Running RemoteAcces2.02
;                                                                    ˙
;                           Chiparus World HeadQuarters              ˘
;                         Outlaw Triad World HeadQuarters            :
;                         Adrar Design Distribution Site             |
;           ------------------------------------------------------- 
;
;
;
