;#########################################################################
;                            HxCIntro 2001 Intro
;                           by Del Nero Jean Francois 
;                               (c)  HxC 2001
;                              www.powerofasm.fr.st
;                          jeanfrancoisdelnero@libero.it
;				  13/12/2001
;#########################################################################
;#
;# Declarations diverses...
;#
;#########################################################################

;#########################################################################

;     include files
;     ~~~~~~~~~~~~~
      include e:\MASM32\INCLUDE\windows.inc

      include e:\MASM32\INCLUDE\gdi32.inc
      include e:\MASM32\INCLUDE\user32.inc
      include e:\MASM32\INCLUDE\kernel32.inc
      include e:\masm32\include\winmm.inc

;     libraries
;     ~~~~~~~~~

      includelib e:\MASM32\LIB\gdi32.lib
      includelib e:\MASM32\LIB\user32.lib
      includelib e:\MASM32\LIB\kernel32.lib
      includelib e:\masm32\LIB\winmm.lib

; #########################################################################

        ;=================
        ; Local prototypes
        ;=================
        WinMain PROTO :DWORD,:DWORD,:DWORD,:DWORD

	MAIN_THREAD_STACKSIZE_KB=16
     
        SCREEN_WIDTH=320
        SCREEN_HEIGHT=200
        VSCREEN_WIDTH=640
        VSCREEN_HEIGHT=400

      ;=============
      ; Local macros
      ;=============


      m2m MACRO M1, M2
        push M2
        pop  M1
      ENDM

      return MACRO arg
        mov eax, arg
        ret
      ENDM

   .data

       DmaBufSize       equ     SampleRate

        status db 0
        pWAVEFORMATEXftag dw 1
        nbcha dw 2
        SperS dd SampleRate
        AvBpS dd SampleRate*2*2
        BloAlig dw 4
        BitpS   dw 16
        extrab  dw 1000 dup(0)

       wavehdrpointer1 dd 0
       lengthcv1  dd DmaBufSize 
       len21    dd 0
       user1    dd 0
       dwflags1 dd 0;WHDR_ENDLOOP or WHDR_BEGINLOOP
       dwloops1 dd 0
       tagbuf1  db 150 dup(0)

       wavehdrpointer2 dd 0
       lengthcv2  dd DmaBufSize 
       len22    dd 0
       user2    dd 0
       dwflags2 dd 0;WHDR_ENDLOOP or WHDR_BEGINLOOP
       dwloops2 dd 0
       tagbuf2  db 150 dup(0)


       szDisplayName db "HxC2001",0
       CommandLine   dd 0
       hWnd          dd 0
       hInstance     dd 0
       hIcon         dd 0

	dibinf LABEL BITMAPINFO
	BITMAPINFOHEADER < \ ;
		 sizeof BITMAPINFOHEADER, \ ;biSize
		 SCREEN_WIDTH,            \ ;biWidth
		 -SCREEN_HEIGHT,          \ ;biHeight
		 1,                       \ ;biPlanes
		 8,                       \ ;biBitCount
		 BI_RGB,                  \ ;biCompression
		 0,                       \ ;biSizeImage
		 0,                       \ ;biXPelsPerMeter
		 0,                       \ ;biYPelsPerMeter
		 0,                       \ ;biClrUsed
		 0>                         ;biClrImportant
	Win_Palette RGBQUAD 256 dup (<>) ; RGB + reserved = 4 bytes

	MainThreadHandle DD ?
	myDC HDC ?

	hMemory3         dd ?
	hMemory4         dd ?
	hMemory5         dd ?
	hMemory6         dd ?
	hMemory7         dd ?
	hMemory8         dd ?

	pBufferSound     dd ?
	pImageBuffer     dd ?
	pImageBuffer2     dd ?
	pVImageBuffer     dd ?


	szClassName db   "Project_Class",0

	pointeurchar     dd offset textcredit
	xposichara       db 16


	textcredit      db "    ---THE TINY INTRO---        $HXC2001$     "
			db "PRESS F1 - F4 TO CHANGE THE MUSIC, "
			db "F5 - F8 AND F11 TO CHANGE THE COLOR EFFECT, "
			db "B TO SHOW THE FRAME RATE         "
			db "YOU CAN PLAY WITH THE MOUSE...     "
			db "   CODE BY JEFF    ---100% MASM32---    "
			db "   MUSIC: SYGMA BY SKILLER/SKENGE (F1)      CRY OF DOOM 4/6/7 (F2-F3-F4) BY CLAWZ (DIGITAL)  ---100% CHIP MOD---  "
			db "               WWW.POWEROFASM.FR.ST         "
			db "             WWW.OBSOLETE-TEARS.FR.ST       "
			db "   (EMAIL JEANFRANCOISDELNERO+LIBERO.IT)    "
			db "V(04/03/2003)    $$$HXC2001$$$    ALT F4 TO EXIT.............            ",0

	powerofasm   db "www.powerofasm.fr.st",0
	hxctitle   db "HxC2001",0
	titlepointeur dd offset powerofasm
	benchtitle db "Frame rate : "
	benchtemp db 10 DUP(20h)
	benchtitle2 db "Polygones / f : "
	benchtemp2  db 20 DUP(0h)
	
	benchstatus db 0
	timewait     db 50
		
	Xdepl dw 0
	Ydepl dw 0
	Zdepl dw +3990
	Xangle dw 0
	Yangle dw 0
	Zangle dw 0
	Xt dw 0
	Yt dw 0
	Zt dw 0

	Xtransa dw 0
	Ytransa dw 0
	Ztransa dw 0
	Xtransam dw 0
	Ytransam dw 0
	Ztransam dw 0

	Zposi        dw 10

	XMouse dw 0
	YMouse dw 0

	compteurnb dw 0 
	
	compteurx dw 3
	compteury dw 1
	compteurz dw 10

	compteurxv dw 3
	compteuryv dw 1
	compteurzv dw 10

	compteurpolygone dw 0
	compteurimage dw 0

	SpeedFactor dw 1
	
	ModeAuto db 0
	
	BlurMode db 5
	ThreadStatus db 0
	
	Direction    dw -5
	ObjActif     db 0
	ObjActifb     dd 0
	ObjPointeur  dd 0
	timingold dw 0
	couleurmode db 0
	StatusSon db 1
	tempblur dw 0
	BlurONOFF db 0


	syntxt dw 0
	speedfstatus db 0

	;//////////ligne
	Y1 DD 00
	X1 DD 00
	Y2 DD 200
	X2 DD 320
	VY1 DD 00
	VX1 DD 00
	VY2 DD 200
	VX2 DD 320

	YINCR dd 0
	XINCR Dd 0
	XDIFF Dd 0
	YDIFF Dd 0
	XTRACE Dd 0
	YTRACE Dd 0
	COULEUR DB 255
	
	;////////////ShowPoint
	X      DW 0
	Y      DW 0
	Z      DW 0
	Xoff   DW 256
	Yoff   DW 256
	Zoff   DW 300             ; Distance 
	Mx     DW VSCREEN_WIDTH/2            ; centre
	My     DW VSCREEN_HEIGHT/2
	;///////////

	XSin   dw 0
	YSin   dw 0
	ZSin   dw 0

	XCos   dw 0
	YCos   dw 0
	ZCos   dw 0


	SinCos  dw 0,6,13,19,25,31,38,44,50,56
		dw 62,68,74,80,86,92,98,104,109,115
		dw 121,126,132,137,142,147,152,157,162,167
		dw 172,177,181,185,190,194,198,202,206,209
		dw 213,216,220,223,226,229,231,234,237,239
		dw 241,243,245,247,248,250,251,252,253,254
		dw 255,255,256,256,256,255,255,255,255,254
		dw 253,252,251,250,248,247,245,243,241,239
		dw 237,234,231,229,226,223,220,216,213,209
		dw 206,202,198,194,190,185,181,177,172,167
		dw 162,157,152,147,142,137,132,126,121,115
		dw 109,104,98,92,86,80,74,68,62,56
		dw 50,44,38,31,25,19,13,6,0,-6
		dw -13,-19,-25,-31,-38,-44,-50,-56,-62,-68
		dw -74,-80,-86,-92,-98,-104,-109,-115,-121,-126
		dw -132,-137,-142,-147,-152,-157,-162,-167,-172,-177
		dw -181,-185,-190,-194,-198,-202,-206,-209,-213,-216
		dw -220,-223,-226,-229,-231,-234,-237,-239,-241,-243
		dw -245,-247,-248,-250,-251,-252,-253,-254,-255,-255
		dw -255,-256,-256,-256,-255,-255,-255,-254,-253,-252
		dw -251,-250,-248,-247,-245,-243,-241,-239,-237,-234
		dw -231,-229,-226,-223,-220,-216,-213,-209,-206,-202
		dw -198,-194,-190,-185,-181,-177,-172,-167,-162,-157
		dw -152,-147,-142,-137,-132,-126,-121,-115,-109,-104
		dw -98,-92,-86,-80,-74,-68,-62,-56,-50,-44
		dw -38,-31,-25,-19,-13,-6,0,0



.DATA?
ALIGN 4
		pointeurobjet dd ?
		SoundH  dd ?
		szFileName db ?
		pBackUp dd ?
