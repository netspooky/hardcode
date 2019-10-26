;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;                           Tornado BBS Intro II
;                               final release
;                           (C) 1997 by Maverick
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;
; This is the second intro I made for our WHQ, the Tornado BBS. This Addy is
; using Fake-Mode with a resolution of 320 x 400, so it's not useful to run
; it on a 386-SX, isn't it? I made this in about one weekend, this is my first
; prog using Fake-Mode, so it's not the best one and sure there are better
; possibilities to code, well search'em!
; So, let's come to the technical part. As you've seen it, maybe, this Intro
; uses some kind of pixel-pattern, that's called Fake-Mode, I think. You
; take 4 pixels and handle them like they would be one. In this case I took
; following order:
;                      RG
;                      BI
;
; This is one logical pixel, but what means R, G, B and I? As you probably
; know the VGA palette consists of 256 colors. I've prepared my palette in
; this order:
;             color:    0- 63       black - red
;               "      64-127       black - green
;               "     128-191       black - blue
;               "     192-255       black - white
;
; Now you can draw nearly all colors you want, using the above mentioned
; pattern, for example, you put one red and one green pixel together and
; if your resolution is high enough it seems to be a yellow one, got it?
; In this way, I made 3 bobs and one font, which seem to mix if you don't
; look to exactly at your screen. Of course you can put more than 3 or 4 bobs,
; but then you have to care of bobs using the same pattern-pixel, which means
; you have to add them together or whatever you want to look your effect like.
;
; This Addy is free-ware, you can copy it to wherever you want to, but it's
; permitted to use this code as it is or to change only a few lines and call
; it your own. This source is released to you, so that you probably learn s.th.
; out of it, but I think if you understand Fake-Mode there's not much new in
; here, but just have a look and you'll see! If you use parts of this code,
; don't forget to greet me and/or my group!!!
;
; I assume you know how to code ASM, but if there are any more questions about
; this Addy, try to page me in the BBS and I'll TRY to answer them...
;
; OK, I think that's all for now....Cu l8r...ASM rulez!!!

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;                        CODE starts right here....
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; This macro allocates 4 x 64000 byte next to the code-segment.
; The first two buffers will contain the background pic, which is of course
; the font-stuff, the last two buffers will contain the final picture(with
; bobs) before being copied to the VGA...
; First 2 Buffers are cleared already
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Init_Buffers MACRO
	mov     ax,cs
	mov     bx,ds:[0002]
	sub     bx,4E80h
	cmp     ax,bx                   ; check if there's enough memory
	jnb     Ende
	add     ax,4096
	call    ClearBuffer             ; clear the buffer
	mov     ds:BuffSeg1,ax          ; 1st Buffer directly after CS
	add     ax,(64*1000)/16         ; the other ones in steps of 64000
	call    ClearBuffer             ; bytes
	mov     ds:BuffSeg2,ax
	add     ax,(64*1000)/16
	mov     ds:BuffSeg3,ax
	add     ax,(64*1000)/16
	mov     ds:BuffSeg4,ax
	jmp     ZeroData                ; next part

ClearBuffer:                            ; fill buffer with zeros
	push    ax
	push    es
	mov     es,ax
	xor     di,di
	mov     cx,64000/2
	xor     ax,ax
	rep     stosw
	pop     es
	pop     ax
	ret
ENDM
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; This macro initializes the Mode-X with a 320 x 400 resolution.
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Init_Fake_Mode MACRO
	mov     dx,03c4h                ; chain-4 off
	mov     ax,0604h
	out     dx,ax
						
	mov     dx,03d4h
	mov     ax,0a14h                ; Double-Word-Mode off
	out     dx,ax
	mov     ax,0e317h               ; Byte-Modus on
	out     dx,ax
	mov     ax,0009h                ; double-scan off to get 400 lines
	out     dx,ax
ENDM
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; This one prepares the pal for the Fake-Mode.
; Pal goes like this:
;                       R  G  B   --     R  G  B
;     color 0-63:       0  0  0         63  0  0
;   color 64-127:       0  0  0          0 63  0
;  color 128-191:       0  0  0          0  0 63
;  color 192-255:       0  0  0         63 63 63
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Prepare_Pal MACRO
	LOCAL   @@1,@@2,@@3
	mov     di,OFFSET PalBuffer     ; first write pal to Buffer for
	push    di                      ; later access when fading
	mov     si,OFFSET PalTable
	mov     ch,4
@@2:
	lodsw
	mov     bx,ax
	lodsb
	mov     dh,al
	xor     dl,dl
	xor     ax,ax
	mov     cl,64
@@1:
	stosw
	add     ax,bx
	mov     es:[di],dl
	inc     di
	add     dl,dh
	dec     cl
	jnz     @@1
	dec     ch
	jnz     @@2
				
	pop     si
	xor     al,al
	mov     dx,03c8h                ; sends colors 0-191 to VGA
	out     dx,al
	inc     dx
	mov     cx,768-(64*3)
	rep     outsb
				
	mov     cl,64*3                 ; colors 192-255 will be black at the
@@3:                                    ; beginning
	out     dx,al
	dec     cl
	jnz     @@3
ENDM
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; This Macro first quads the BOB-Data included to get one whole BOB
; and then prepares the three bobs
; BOB is epanded as followed:
;
; Included Bob:
;               000000011111
;               000011111111
;               001111111111
;               011111111111
;               011111111111
;               111111111111
; This shoul be one quarter of the BOB, of course not existing of 0 and 1,
; but of bytes from 0-63, this part is first doubled horizontally and then
; vertically to get the whole bob...
;
;               000000011111       111110000000
;               000011111111       111111110000
;               001111111111       111111111100
;               011111111111  =>   111111111110
;               011111111111       111111111110
;               111111111111       111111111111
;
; Vertically the same method, so I won't draw this now, OK?
;
; The resulting 3 Bobs are described in the DATA-Part.
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Prepare_BOBs MACRO
	LOCAL   @@1,@@2,@@3,@@@1,@@@2,@@@3,@@@4,@@@5
	pushf
	mov     si,OFFSET BobINC
	mov     di,OFFSET Stuff
	push    di
	xor     ch,ch
	mov     dh,30
@@2:
	push    si
	cld
	mov     cl,30
	rep     movsb
	pop     si
	mov     cl,30
	add     di,29
@@1:
	cld
	lodsb
	std
	stosb
	loop    @@1
	add     di,31
	dec     dh
	jnz     @@2
	pop     si
	mov     di,OFFSET Stuff + 900*4 - 1
	mov     cx,3600/2
@@3:
	cld
	lodsb
	std
	stosb
	loop    @@3
	popf
					
	mov     di,OFFSET Bob1
	mov     dh,3
	mov     bp,OFFSET BOB_PrepareTable
@@@4:
	mov     si,OFFSET Stuff-1
	mov     dl,2
@@@3:
	inc     si
	push    si
	mov     ch,60
@@@2:
	add     di,ds:[bp]
	mov     cl,30
@@@1:
	xor     ax,ax
	lodsb
	add     al,byte ptr ds:[bp+2]
	cmp     byte ptr ds:[bp+5],0
	jz      @@@5
	xchg    ah,al
@@@5:
	stosw
				
	inc     si
	dec     cl
	jnz     @@@1
	add     di,ds:[bp+3]
	dec     ch
	jnz     @@@2
	pop     si
	dec     dl
	jnz     @@@3
	add     bp,6
	add     di,8
	dec     dh
	jnz     @@@4
ENDM
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
.MODEL TINY
.CODE
.386
	LOCALS @@
	ORG 100h
	ASSUME CS:@CODE
					
; CS = DS = ES = SS
					
Start:  cld
					
	push    0000h                   ; FS points to Zero-Seg for later
	pop     fs                      ; access to Timer-Int

	push    0F000h                  ; for later access to the Font-Data y
	pop     gs
					
	Init_Buffers
					
ZeroData:
	mov     di,OFFSET ZeroBegin     ; this part clears the ZeroData-Area
	mov     cx,ZeroEnd-ZeroBegin
	xor     al,al
	rep     stosb
					
	mov     ax,13h                  ; no need to explain...-g-
	int     10h
					
	Init_Fake_Mode
	Prepare_Pal
	Prepare_BOBs
	call    Init_Timer              ; init Timer.
	call    PrintInfo               ; print 1st Info-Screen
							
	mov     ds:Bob1_X,5             ; sets the bob starting params
	mov     ds:Bob1_Y,90            ; for all 3 bobs
	mov     ds:Bob1_X_A,-1
	mov     ds:Bob1_Y_A,2
					
	mov     ds:Bob2_X,50
	mov     ds:Bob2_Y,20
	mov     ds:Bob2_X_A,2
	mov     ds:Bob2_Y_A,-2
					
	mov     ds:Bob3_X,150
	mov     ds:Bob3_Y,100
	mov     ds:Bob3_X_A,-3
	mov     ds:Bob3_Y_A,1
	
	jmp     MainLoop
FadeIn:
	cmp     ds:TimeCounter,10
	jb      @@mk1
	call    FadeInFont
	mov     ds:TimeCounter,0
@@mk1:
	ret
FadeWait:
	cmp     ds:TimeCounter,7*70
	jb      @@mk3
	mov     ds:Fade,OFFSET FadeOut
@@mk3:
	ret
FadeOut:
	cmp     ds:TimeCounter,10
	jb      @@mk2
	call    FadeOutFont
	mov     ds:TimeCounter,0
@@mk2:
	ret
	
MainLoop:
	call    [Fade]                  ; jmp to the actual Fade-Part stored
					; in DS:Fade
	call    BackGround              ; copy the background to buffer

	mov     ax,OFFSET Bob1_Y
	call    PutBOB
	mov     ax,OFFSET Bob2_Y
	call    PutBOB
	mov     ax,OFFSET Bob3_Y
	call    PutBOB
		
	call    Buffer2VGA              ; the resulting buffer 2 VGA
					
	mov     cl,3                    ; check all 3 bobs for border touches
	mov     si,OFFSET Bob1_X
@@7:
	cmp     word ptr ds:[si],0
	jna     @@4
	cmp     word ptr ds:[si],319-60
	jna     @@3
@@4:
	neg     word ptr ds:[si+4]
@@3:
	mov     ax,ds:[si+4]
	add     ds:[si],ax
	inc     si
	inc     si
					
	cmp     word ptr ds:[si],0
	jna     @@5
	cmp     word ptr ds:[si],196-60
	jna     @@6
@@5:
	neg     word ptr ds:[si+4]
@@6:
	mov     ax,ds:[si+4]
	add     ds:[si],ax
	add     si,6+3600*4
	dec     cl
	jnz     @@7

	mov     ah,01h                  ; check for key
	int     16h
	jz      MainLoop
							
	call    DeInit_Timer            ; restore Time-Settings
						
Ende:
	xor     ah,ah
	int     16h
						
	mov     ax,0003h                ; restore Text-Screen
	int     10h
						
	push    0B800h                  ; this part prints the Info-Line
	pop     es                      ; at the end of the Addy
	xor     di,di
	mov     si,OFFSET OutroText
@@1:
	lodsb
	cmp     al,31
	jae     @@2
	mov     ah,al
	jmp     @@1
@@2:
	jz      @@Real_End
	stosw
	jmp     @@1
@@Real_End:
	mov     ah,4Ch                  ; kick it.
	int     21h
;-----------------------------PROCS------------------------------------------
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; This proc fades in the Text on the Screen.
; Is called timer-oriented.
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
FadeInFont PROC NEAR
	mov     si,OFFSET PalFontActual
	push    si
	mov     di,OFFSET PalBufferFont
	mov     cl,64*3
	xor     al,al
@@mk1:
	cmpsb
	jz      @@mk2
	inc     byte ptr ds:[si-1]
	jmp     @@mk4
@@mk2:
	inc     al
@@mk4:
	dec     cl
	jnz     @@mk1
	pop     si
	mov     cl,64*3
	cmp     al,cl
	jz      @@mk3
	mov     al,256-64
	mov     dx,03c8h
	out     dx,al
	inc     dx
	rep     outsb
	ret
@@mk3:
	mov     ds:Fade,OFFSET FadeWait ; now comes the waiting part
	ret
FadeInFont ENDP
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; This proc fades out the Text on the Screen.
; Is called timer-oriented.
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
FadeOutFont PROC NEAR
	mov     si,OFFSET PalFontActual
	push    si
	mov     cl,64*3
	xor     ah,ah
@@mk2:
	lodsb
	or      al,al
	jz      @@mk1
	dec     byte ptr ds:[si-1]
	jmp     @@mk3
@@mk1:
	inc     ah
@@mk3:
	dec     cl
	jnz     @@mk2
	pop     si
	mov     cl,64*3
	cmp     ah,cl
	jz      @@mk4
	mov     al,256-64
	mov     dx,03c8h
	out     dx,al
	inc     dx
	rep     outsb
	ret
@@mk4:
	call    PrintInfo
	mov     ds:Fade,OFFSET FadeIn   ; now comes the fade-in part
	ret
FadeOutFont ENDP
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Copies the next Text-Info-Screen to the BackGround-Buffer.
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
PrintInfo PROC NEAR
	pusha
	mov     ax,ds:BuffSeg1
	call    ClearBuffer
	mov     ax,ds:BuffSeg2
	call    ClearBuffer
	mov     si,OFFSET TextMessageTable
	add     si,ds:TextMessageNum
	mov     si,ds:[si]
	cmp     ds:TextMessageNum,2*MessageScreens
	jnz     @@mk1
	mov     ds:TextMessageNum,0-2
@@mk1:
	add     ds:TextMessageNum,2
	push    es
@@5:
	lodsw
	or      ax,ax
	jz      @@End
	cmp     ax,200
	jnb     @@6
	mov     es,ds:BuffSeg1
	jmp     @@7
@@6:
	mov     es,ds:BuffSeg2
	sub     ax,200
				
@@7:
	mov     di,ax
	imul    di,320
	dec     di
	lodsw
	add     di,ax
@@4:
	lodsb
	or      al,al
	jz      @@5
	mov     bp,0FA6Eh
	xor     ah,ah
	shl     ax,3
	add     bp,ax
	mov     ch,9
	mov     bl,202
@@3:
	mov     cl,8
	add     bl,6
	mov     ah,gs:[bp]
	inc     bp
@@2:
	inc     di
	inc     di
	rcl     ah,1
	jnc     @@1
	mov     al,bl
	stosb
	dec     di
@@1:
	dec     cl
	jnz     @@2
	add     di,320*2-16
	dec     ch
	jnz     @@3
	sub     di,9*320*2-16
	jmp     @@4
				
@@End:
	pop     es
	popa
	ret
PrintInfo ENDP
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Copies the BOB to buffer.
; AX must point to Y-pos of Bob, higher part of EAX must be zero.
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
PutBOB PROC NEAR
	pusha
	push    es
	mov     es,ds:BuffSeg3
	mov     si,60*120
	mov     di,ds:[eax]
	cmp     di,100
	jl      @@2
	mov     es,ds:BuffSeg4
	sub     di,100
@@2:
	imul    di,640
	sub     ax,2
	mov     bx,ds:[eax]
	shr     bx,1
	shl     bx,1
	cmp     bx,ds:[eax]
	jz      @@1
	xor     si,si
@@1:
	add     ax,4+4
	add     si,ax
	mov     ch,120
	add     di,bx
@@4:
	mov     cl,60
@@7:
	lodsb
	or      al,al
	jz      @@6
	stosb
	dec     di
@@6:
	inc     di
	dec     cl
	jnz     @@7
	
	add     di,320-60
	cmp     di,64000
	jna     @@5
	sub     di,64000
	mov     es,ds:BuffSeg4
@@5:
	dec     ch
	jnz     @@4
	pop     es
	popa
	ret
PutBOB ENDP
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Writes the two last buffers to the VGA and switches the VGA-page...
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Buffer2VGA PROC NEAR
	pusha
	push    ds es
	push    0A000h
	pop     es
	mov     bl,4
	xor     bp,bp
	mov     bh,01h
@@2:
	mov     di,cs:StartAdress
	mov     cx,64000/16
	push    cx
	mov     ah,bh
	call    SetWritePlane
	mov     si,bp
	push    si
	mov     ds,cs:BuffSeg3
	call    @@1
	mov     ds,cs:BuffSeg4
	pop     si
	pop     cx
	call    @@1
	
	inc     bp
	shl     bh,1
	dec     bl
	jnz     @@2
	pop     es ds
				
	mov     bx,ds:StartAdress
	call    Set_StartAdress
	call    V_Retrace
	or      bx,bx
	jnz     @@4
	mov     ds:StartAdress,320/4*400
	jmp     @@5
@@4:
	mov     ds:StartAdress,0
@@5:
	popa
	ret
@@1:
	mov     ah,ds:[si+12]
	mov     al,ds:[si+8]
	shl     eax,16
	mov     ah,ds:[si+4]
	lodsb
	add     si,15
	stosd
	dec     cx
	jnz     @@1
	ret
				
Buffer2VGA ENDP
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Sets the Writing-Plane given in AH.
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
SetWritePlane PROC NEAR
	mov     al,02h
	mov     dx,03c4h
	out     dx,ax
	ret
SetWritePlane ENDP
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; This one copies the BackGround-Picture to the 2nd 2 buffers for putting
; the bobs on it.
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
BackGround PROC NEAR
	pusha
	push    ds es
	mov     ds,ds:BuffSeg1
	mov     es,cs:BuffSeg3
	xor     si,si
	xor     di,di
	mov     cx,16000
	push    cx
	rep     movsd
	mov     ds,cs:BuffSeg2
	mov     es,cs:BuffSeg4
	pop     cx
	rep     movsd
	pop     es ds
	popa
	ret
BackGround ENDP
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; This proc changes the Linear-Starting address of the VGA, for page-flipping.
; BX = new start adress.
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Set_StartAdress PROC NEAR
	pusha
	mov     dx,03d4h
	mov     al,0ch
	mov     ah,bh
	out     dx,ax
	inc     al
	mov     ah,bl
	out     dx,ax
	popa
	ret
Set_StartAdress ENDP
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; This proc waits for the vertical retrace.
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
V_Retrace PROC NEAR
	mov     dx,03dah
	in      al,dx
	test    al,00001000b
	jz      $-3
	ret
V_Retrace ENDP
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; This proc (de)initializes the Programmable Interrupt Timer with a rate
; of 70 Hz.
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Init_Timer PROC NEAR
	mov     dx,17000
	mov     eax,fs:[8*4]            ; Int 08h
	mov     ds:Oldint8,eax          ; store old interrupt-vector
	mov     ax,cs
	shl     eax,16
	mov     ax,OFFSET MyInt8
	jmp     @@mk1
Deinit_Timer:
	mov     eax,ds:Oldint8          ; get old interrupt-vector
	xor     dx,dx
@@mk1:  cli
	mov     fs:[8*4],eax
	xor     eax,eax                 ; clear EAX, for later indizes
	mov     al,36h                  ; with DS:[EAX].
	out     43h,al
	mov     al,dl
	out     40h,al
	mov     al,dh
	out     40h,al
	sti
	ret
Init_Timer ENDP
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; This proc is called 70 times a second by the PIT.
; It increases the TimeCounter var, which is needed for fading.
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
MyInt8:
	push    ax
	inc     cs:TimeCounter
	mov     al,20h
	out     20h,al
	pop     ax
	iret
;-----------------------------DATA-------------------------------------------
MessageScreens  equ 4                   ; number of Text-Info-Screens - 1
Fade            dw  OFFSET FadeIn       ; points to the fitting fade part

							
BOB_PrepareTable LABEL BYTE             ; this Table is a pattern for expanding
		dw  0                   ; the three bobs.
		db  0
		dw  60
		db  0
		
		dw  0
		db  64
		dw  60
		db  1
		
		dw  60
		db  128
		dw  0
		db  0
							
PalTable        LABEL BYTE              ; This table describes the way, the
		db  1,0,0               ; pal goes
		db  0,1,0
		db  0,0,1
		db  1,1,1
							
OutroText       LABEL BYTE              ; nomen est omen
		db  3,"ùÄ",11,"Ä",3,"  +",11,"4",3,"9-",11,"7",3,"11-"
		db  11,"7",3,"77411 (",11,"V",3,".34) "
		db  "Ä",11,"Ä",15,"Ä",11,"Ä",3,"Ä  ",15
		db  "T",11,"o",3,"rnado B",11,"B",15,"S  "
		db  3,"Ä",11,"Ä",15,"Ä",11,"Ä",3,"Ä "
		db  "+",11,"4",3,"9-",11,"7",3,"11-"
		db  11,"7",3,"738655 (",11,"X",3,".75)  ",11,"Ä",3,"Äù"
		db  31
		
; Screen-DATA is stored as followed:
; WORD: Y-position (must be odd number)
; WORD: X-position (must be even number)
; BYTE: message text, zero terminated
; WORD: ZERO (Screen ends here)

TextMessage1    LABEL BYTE              ; first Text-Screen
		dw  33
		dw  0
		db  "-=> TORNADO BBS <=-",0
		dw  111
		dw  8
		db  "0711-777411 (V.34)",0
		dw  135
		dw  0
		db  "0711-7738655 (X.75)",0
		dw  223
		dw  12
		db  "-> BABYLON WHQ <-",0
		dw  263
		dw  20
		db  "-> SILDRO WHQ <-",0
		dw  303
		dw  0
		db  "-> EFR Dist-Site <-",0
		dw  0
TextMessage2    LABEL BYTE
		dw  23
		dw  10
		db  "Specialized in all",0
		dw  53
		dw  40
		db  "sorts of Muzax",0
		dw  123
		dw  4
		db  "Demos, Coding, MAGs",0
		dw  183
		dw  18
		db  "-=Nets available=-",0
		dw  243
		dw  40
		db  "Fido, WoS, Games",0
		dw  273
		dw  32
		db  "Rave, Treiber, RO",0
		dw  303
		dw  40
		db  "Short, Easy, VPL",0
		dw  0
TextMessage3    LABEL BYTE
		dw  9
		dw  48
		db  "Thanx 2 Cyron",0
		dw  79
		dw  90
		db  "Greetz:",0
		dw  131
		dw  0
		db  "Cubic Team, EFR, RR,",0
		dw  171
		dw  0
		db  "ART, Iguana, Sildro,",0
		dw  211
		dw  0
		db  "Realtech, DSD, Purge",0
		dw  251
		dw  40
		db  "Nooon, Neutron,",0
		dw  291
		dw  20
		db  "N-Factor, Absence,",0
		dw  331
		dw  40
		db  "Camorra .....",0
		dw  0
TextMessage4    LABEL BYTE
		dw  121
		dw  84
		db  "(C) 1997",0
		dw  181
		dw  86
		db  "Maverick",0
		dw  211
		dw  134
		db  "of",0
		dw  241
		dw  92
		db  "Babylon",0
		dw  0
TextMessage5    LABEL BYTE
		dw  0
			
TextMessageTable LABEL BYTE
		dw  OFFSET TextMessage1 ; the order of appearance of each
		dw  OFFSET TextMessage2 ; of the Info-Screens
		dw  OFFSET TextMessage3
		dw  OFFSET TextMessage4
		dw  OFFSET TextMessage5
				
BobINC          LABEL BYTE              ; the external BOB-Data is included
		INCLUDE BOB.DAT         ; right here
				
BuffSeg1        dw  ?                   ; the background picture fills
BuffSeg2        dw  ?                   ; 64000 bytes of each of this Buffers
BuffSeg3        dw  ?                   ; the resulting picture (with bobs)
BuffSeg4        dw  ?                   ; fills 64000 bytes of each of this Buffers
					
ZeroBegin       LABEL BYTE              ; zero data starts here
					
TextMessageNum  dw  ?                   ; OFFSET-Adder to access the Text-Scr.

TimeCounter     dw  ?
StartAdress     dw  ?                   ; actual linear starting address
		
			
; BOB-Data is stored as followed:
;
; 0: R0 G0     R2 G2    R4 G4
; |  B0 I0     B2 I2    B4 I4
; |  .....
;60:
;         R1 G1     R3 G3    R5 G5
;         B1 I1     B3 I3    B5 I5
;    .....
			
Bob1_X          dw  ?                   ; actual X-pos
Bob1_Y          dw  ?                   ; actual Y-pos
Bob1_X_A        dw  ?                   ; X-Adder
Bob1_Y_A        dw  ?                   ; Y-Adder
Bob1            db  (60*2)*(60*2) DUP(?)
				
Bob2_X          dw  ?
Bob2_Y          dw  ?
Bob2_X_A        dw  ?
Bob2_Y_A        dw  ?
Bob2            db  (60*2)*(60*2) DUP(?)
				
Bob3_X          dw  ?
Bob3_Y          dw  ?
Bob3_X_A        dw  ?
Bob3_Y_A        dw  ?
Bob3            db  (60*2)*(60*2) DUP(?)
				
PalFontActual   db  64*3 DUP (?)        ; the actual stat of the font-colors
					; needed for fading

ZeroEnd         LABEL BYTE              ; zero data ends right here
				
PalBuffer       db  (256-64)*3 DUP (?)  ; Palette Buffer for colors 0-191
PalBufferFont   db  64*3 DUP (?)        ;    "      "     "     "   192-255
					; which is the font-color part

OldInt8         dd  ?                   ; old int 08h vector

Stuff           LABEL BYTE
END Start

