.MODEL  LARGE
jumps
locals
.STACK  100h
.386
.DATA
	assume  DS:@DATA
size_x  EQU 80
size_y  EQU 5+150
FIRELEN EQU size_x*size_y
NUMP        EQU 4
fontY   EQU 12
fontX   EQU 8
topPICLN    EQU 36
botPICLN    EQU 55
texty   dw  52;78
fadeout db  0
endpage db  0
textc   dw  0
txtpause    db  46
fontOff dw  0
indic   db  0
yesno   db  0
evsec   db  0
;tmp_pal db  768 DUP (0)
include ORG_KAOS.PAL
RandSeed    dw      ?                       ; random generator seed.
textcol db  0
;include orgkaos1.inc
include boo.inc
include font_hdr.inc
include font_dat.inc
include logo_top.inc         ;lPICTURE
include logo_bot.inc         ;bPICTURE
text	db	6,6
;		|/---5----0-max5leng0h-of5text0----5---0\|
	db	"         This file passed thru",13,6,6
	db	"             ORGANiZEd kAOS",13,6,6
        db      "    - Strictly For Kreative Minds -",13,6,6
	db	"            +612-9876-1536",13,6,6
        db      "        Sysops : kRiSiS ",13,6,6
        db      "                 kURRUPt",13,13,13
	db	4,13
        db      "               Featuring :",13,6,6
        db      "        kURRUPts Ansi Help Centre",13,6,6
        db      "    (Providing help for all artists)",13,6,6
        db      "  Art-Music-Modding-Manga-Emagz-Demos",13,6,6
        db      "            ... and more!",13,13
	db	4
        db      "              Message Nets :",13,6,6
        db      "  fORCENEt                 (World HQ)",13,6,6
        db      "  DaemonNet International  (Aust. Hub)",13,6,6
        db      "  Sysops TechNet           (Aust. Hub)",13,6,6
        db      "  ScamNet                  (NSW Hub)",13,6,6
        db      "  Ka0zNet",13,13
	db	4
        db      "              Affiliations :",13,6,6
        db      "  XPRESS                (World HQ)",13,6,6
        db      "  fORCE                 (Member Board)",13,6,6
        db      "  SOi                   (Aust. HQ)",13,6,6
        db      "  PUNC                  (Aust. HQ)",13,13
        db      4
        db      "              Affiliations :",13,6,6
        db      "  Skyjump Team          (Aust. HQ)",13,6,6
        db      "  Fact                  (Aust. HQ)",13,6,6
        db      "  Explizit              Distro Site",13,6,6
        db      "  Prick                 Distro Site",13,13
	db	4,13,13,13,13,13
;		|\---5----0-max5leng0h-of5text0----5---0/|
	db  0
;   db  "               0123456789",13
;   db  "       ABCDEFGHIJKLMONPQRSTUVWXYZ",13
;   db  "       abcdefghijklmonpqrstuvwxyz",13
;   db  "              :;.,?!@()-+/",1,13
.FARDATA    BUF0
	assume  FS:BUF0
fplas   db  FIRELEN*NUMP    dup (0)
.FARDATA    BUF1
	assume  GS:BUF1
txtscrn db  175*320 dup (0)
.CODE
	assume  CS:@CODE
include Player.Asm
IPS     =   50
OldInt      dd  ?
TimerCnt    dw  ?
TimerSteps  dw  ?
Random  PROC NEAR
	mov ax,RandSeed
	mov dx,8405h
	mul dx
	inc ax
	mov RandSeed,ax
	ret                   
Random  ENDP                  
WaitVRT PROC    NEAR
	push    dx
	push    ax
	mov dx,3dah
	@@VRT:
			in  al,dx
		test    al,8
	jnz @@VRT               ;wait until Verticle Retrace starts
	@@NoVRT:
		in  al,dx
			test    al,8
	jz  @@NoVRT         ;wait until Verticle Retrace Ends
	pop ax
	pop dx
	ret
WaitVRT ENDP
WriteC  PROC    NEAR
	;   INPUT:  cx = xpos, dx = ypos, al = fontnum.
	;   RETURNS:    cx = input cx + fontX.
	;   DESTROYS:   di, ax.
	push    cx                    
	push    dx            
	push    si            
	push    bx            
							  
	xor ah,ah             
	mov bx,ax               ;Get the font offset.
	add bx,bx             
	mov ax,WORD PTR FONT_HDR[bx]        ;dx = word offset..
	mov si,OFFSET FONT_DAT
	add si,ax               ;store the offset in si.

	mov ax,dx               ;get the y add offset.
	shl dx,8
	shl ax,6
	add ax,dx
	add ax,cx       ;+ xpos.
	mov fontOff,ax          ;put it in fontOff.
												   
	xor bx,bx                ;is y line num.     Begin Drawing...
	NextLine:
		mov cx,fontX
		mov di,bx
		mov dx,bx           ;mul ebx by 320 into eax
		shl di,8
		shl dx,6
		add di,dx           ;ds:si is the source index.

		add di,fontOff      ;es:di is the destination index

		drwln:
			mov al,ds:[si]
			cmp al,0
			je  nobit
				mov al,textcol
					mov gs:[di],al
			nobit:
			inc di
			inc si                
			dec cx
		jnz drwln

		inc bx
		cmp bx,fontY
	jb  NextLine
	nodraw:
	pop bx 
	pop si 
	pop dx          ;Returns input values, edx & ecx + fontX.
	pop cx
	add cx,fontX
	ret
WriteC  ENDP
start:
	mov ax,13h          ;Init mode 13h
	int 10h

	mov ax,@DATA
	mov ds,ax
	mov es,ax

	mov si,OFFSET PALETTE       ;Setup Pal.
	mov dx,3c8h
	xor al,al
	out dx,al
	inc dx
	mov cx,768
	rep outsb

	push    Music
	pop es
	call    InitPlayer
	call    SetInt

	push    0a000h
	pop es
	push    BUF0
	pop fs
	push    BUF1
	pop gs
	cld


        mov si, 24*320+316
        mov di, 175*320
        mov eax, -1
        @@LOOP:
          call WaitVRT
          mov es:[si], eax
          mov es:[di], eax
          add di,4
          sub si,4
          cmp si,24*320 ;-1
          jae @@LOOP

mov ax, 142
@@SUPER_DOOPER_LOOPER:
   call WaitVRT

   mov si, offset lPICTURE
   sub si, 11
   add si, ax
   mov di, 1920
   mov bx, 36
   @@Top_loop:
     mov cx, 142
     sub cx, ax
     rep movsb
     add si, 320-142
     add si, ax
     add di, 320-142
     add di, ax
     dec bx
     jnz @@Top_loop

   cmp ax, 86
   ja @@skip_bot

   mov di,320*146-86
   add di, ax
   mov si, offset bPICTURE
   mov bx, 56
   @@Bot_loop:
     mov cx, 86
     sub cx, ax
     rep movsb
     add si, 320-86
     add si, ax
     add di, 320-86
     add di, ax
     dec bx
     jnz @@Bot_loop

   @@skip_bot:

   dec ax
   jnz @@SUPER_DOOPER_LOOPER

comment ~
	mov	bx,topPICLN-1		;Line num -.	    Scroll pic in top.
	TopScrollLoop:
		mov	di,lPIC_START
		mov	si,OFFSET lPICTURE
		mov	ax,bx
		mov	cx,320
		mul	cx
		add	si,ax
		mov	ax,topPICLN
		sub	ax,bx
		mul	cx
		sub	ax,lPIC_START
		mov	cx,ax
                shr     cx,2

;		rep	movsd ;b
		call    WaitVRT
		rep	movsd  ; Test which pos of the rep movsd
                               ; Has least shearing (on SLOW computer)

		dec	bx
	jnz	TopScrollLoop

	mov	bx,0					;Scroll pic rest of way.
	TopScrollLoop2:
		mov	di,lPIC_START
		mov	ax,bx
		mov	cx,320
		mul	cx
		add	di,ax
		mov	si,OFFSET lPICTURE
		mov	cx,(topPICLN*320)-lPIC_START ;320)-lPIC_START
;		rep	movsb
		call    WaitVRT
                rep     movsb

		cmp	bx,0
		je	Skipdel1
;		mov	ax,bx
;		dec	ax
;		mov	cx,320
;		mul	cx
;		mov	di,ax
sub di, 37*320
		xor	eax,eax
		mov	cx,320/4
		rep	stosd
		Skipdel1:

		inc	bx
		cmp	bx,6
	jbe	TopScrollLoop2

	mov	bx,botPICLN-1		;Line num -.	    Scroll pic in bottom.
	botScrollLoop:
		mov	si,OFFSET bPICTURE
		mov	di,(320*(200-botPICLN-1)) +bPIC_START
		mov	ax,bx
		mov	cx,320
		mul	cx
		add	di,ax
		mov	ax,botPICLN
		sub	ax,bx
		mul	cx
		sub	ax,bPIC_START
		mov	cx,ax
                shr     cx,2
;		rep	movsd ;b
		call    WaitVRT
                rep     movsd
		dec	bx
	jnz	botScrollLoop
~
;	mov di,(320*6)+lPIC_START		;Draw pic to screen. (top)
;	mov si,OFFSET lPICTURE
;	mov cx,(topPICLN*320)-lPIC_START
;	rep movsb

;	mov di,(320*145)+bPIC_START		;Draw pic to screen. (bottom)
;	mov si,OFFSET bPICTURE
;	mov cx,(botPICLN*320)-bPIC_START
;	rep movsb

loopbegin:                              ;Main loop begining.
	push    es
	mov ax,fs
	mov es,ax

	cmp fadeout,0
	jne nobotplane
	mov di,OFFSET fplas[size_x]                 ;Randomize bottom plane.
	nextcol:
		call    Random
		xor al,ah
		js  abv128
			xor al,al
			jmp blw128
		abv128:
			mov al,254
		blw128:
		mov cx,7
		rep stosb
		cmp di,OFFSET fplas[FIRELEN-4]
	jb  nextcol
	nobotplane:

	mov di,OFFSET fplas[size_x]     ;Calculate the fplas bit colour.
	nextbit:
		xor ah,ah
		xor bh,bh
		xor dh,dh

		mov bl,es:[di+size_x]       ;One pix below cur.
		mov al,es:[di-size_x]       ;One pix above cur.
		add bx,ax

		mov al,es:[di-1]        ;One pix to left.
		mov dl,es:[di+1]        ;One pix to right.
		add ax,dx
		add ax,bx

		cmp di,FIRELEN
		jb  nobelo
			xor bh,bh
			mov bl,es:[di-FIRELEN]  ;One pix Below.
			add ax,bx
		nobelo:

		mov bl,5            ;Divide by 5
		div bl
;                shr ax,2

		stosb
		cmp di,OFFSET fplas[FIRELEN*NUMP-size_x]
	jb  nextbit
	pop es

	cmp txtpause,0
	jg  notext
	xor cx,cx                ;Write The Text.
	mov dx,texty                ;Y pos..
	mov si,textc
	cmp endpage,1
	jne nextone
		push    es
		push    cx
		mov endpage,0
		mov di,OFFSET txtscrn
		mov ax,gs
		mov es,ax
		xor eax,eax
		mov cx,(175*320)/4
		rep stosd
		pop cx
		pop es
	nextone:
		mov al,text[si]
		cmp al,0                ;Is it the end?
		jne dontendwr
			mov cx,0            ;Go back to first page.
			mov dx,0
			mov texty,52;78
			mov endpage,1
			mov txtpause,64
			mov textc,0
			jmp nodectxtp
		dontendwr:
		cmp al,20h              ;Is it a Space?
		jne notspace
			add cx,fontX
			inc si
			jmp nextone
		notspace:
		cmp al,13               ;Is it Enter?
		jne notenter
;           add texty,16
			xor cx,cx
			inc si
			jmp endwr
		notenter:
		cmp al,6                ;Is it Skip Lines?
		jne nojpln
			xor ah,ah
			mov al,text[si+1]
			add dx,ax
			xor cx,cx
			add si,2
			jmp nextone
		nojpln:
		cmp al,4                ;Is it the end of this page?
		jne not4
			xor cx,cx                ;Start doing next one.
			xor dx,dx
			inc si
			mov textc,si
			mov texty,52;78
			mov txtpause,48
			mov endpage,1
			jmp nodectxtp
		not4:
		call    WriteC              ;Write the Character.
		inc si
		mov ah,01h              ;Check if a key was pressed.
		int 16h
		jnz endwr
	jmp nextone
	endwr:
	add textcol,4
	cmp textcol,49
	jb  nodectxtp
		add texty,16
		mov textcol,0
		mov textc,si
		mov txtpause,4 ;24
		jmp nodectxtp
	notext:
	sub txtpause,4
	nodectxtp:

	mov di,(64000-((size_y-5)*320))/2               ;Draw to screen.
	mov si,OFFSET fplas + (FIRELEN*NUMP)-FIRELEN
	mov bx,OFFSET lPICTURE-lPIC_START+(320*19)
	mov dx,size_y-5
	nxtline:
		mov cx,320          ;Len of line to draw.
		Drwbit:
			cmp di,(64000-((size_y-5)*320))/2 +((topPICLN-19)*320)-1
			ja  isnotinpic
				mov al,ds:[bx]
				inc bx
				cmp al,0
				jne dontdraw
			isnotinpic:

			cmp di,(64000-((size_y-5)*320))/2 +(320*100)-2
			jne isnotchange
				mov bx,OFFSET bPICTURE;-bPIC_START
			isnotchange:

			cmp di,(64000-((size_y-5)*320))/2 +(320*120) +bPIC_START
			jb  isnotinpic2
				mov al,ds:[bx]
				inc bx
				cmp al,0
				jne dontdraw
			isnotinpic2:

			mov al,fs:[si]
			mov ah,gs:[di]
			cmp ah,0
			je  justdrw
				cmp endpage,1
				jne notendpage
					push    bx
					mov bl,txtpause
					mov textcol,bl
					pop bx
					jmp addtxtcl
				notendpage:
				cmp ah,48
				jb  addtxtcl
					add al,48
					jmp PrepDraw
				addtxtcl:
				add al,textcol
				PrepDraw:
			justdrw:
			shr al,2
			mov es:[di],al
			dontdraw:
			inc si
			inc di
			dec cx
		jnz Drwbit
		sub esi,320-size_x
		dec dx
	jnz nxtline

;   mov al,255
;   mov cx,320
;   rep stosb

	call    WaitVRT

	cmp fadeout,0
	je  fadeoutisok
		inc fadeout
		cmp fadeout,16
		jae endprog
	fadeoutisok:

	cmp evsec,5
	jb  contin
		mov evsec,0
		mov ah,01h
		int 16h
		jz  contin
			inc fadeout
			cmp fadeout,2
			jae endprog
	contin:
	inc evsec
jmp loopbegin           ;Go back to begining.

	endprog:
	xor di,di            ;Palette Fade out, Begin.
	push    ds
	pop es
	fadeloop0:
		mov si,767
		fadeloop1:
			cmp PALETTE[si],0
			je  fadepart2
			dec PALETTE[si]
		fadepart2:
		dec si
		jnz fadeloop1
		mov si,OFFSET PALETTE    ;Set the block palette.
		mov dx,3c8h
		xor al,al
		out dx,al
		inc dx
		mov cx,768
		rep outsb
		call    WaitVRT                     ;Wait for Verticle Retrace.
		inc di
		cmp di,03fh     ;when di == 63 its finnished.
	jne fadeloop0       ;End Fading out.

	call    ResetInt
	call    EndPlayer

        mov ah,12h
        mov al,02h
        mov bl,30h
        int 10h

	mov ax,03h          ;Go back to text mode.
	int 10h

        mov ax,1111h
        xor ebx,ebx
        int 10h

	mov si,OFFSET ANSI
	push    0b800h
	pop es      ;Dest seg
	xor di,di       ;dest off
	mov cx,ANSI_SIZE/4  ;length
	rep movsd       ;Draw Ansi.

	mov ah,02h                      ;Move Cursor.
	xor bh,bh
	mov dh,25 ;16
	xor dl,dl
	int 10h

	mov ax,04C00h           ;Terminate.
	mov al,69
	int 21h

;께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께
; Enables and starts the player interrupt.
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
SetInt:     push    ax es

			cli
		xor ax,ax
		mov es,ax
		mov ax,es:[8*4]
		mov word ptr OldInt,ax
		mov ax,es:2[8*4]
		mov word ptr OldInt+2,ax
		mov word ptr es:[8*4], offset PlayerInt
		mov es:2[8*4],cs
				   
		mov ax,IPS
;       call    SetTimer
				 
		sti
		pop es ax
		ret

;께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께
; Disables the player interrupt.
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
ResetInt:   push    ax es

		cli
		xor ax,ax
		mov es,ax
		mov ax,word ptr OldInt
		mov es:[8*4],ax
		mov ax,word ptr OldInt+2
		mov es:2[8*4],ax

;       call    ResetTimer

		sti
		pop es ax
		ret

;께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께
; The player interrupt.  Called 50 times a second.
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
PlayerInt:  push    ax

		call    PlayMusic

	; see if we have passed 18.2/s mark
	@@lx:   mov ax,TimerSteps       ; this no. of steps per int.
		add TimerCnt,ax
		jnc @@ly            ; don't call timer interrupt
		pop ax
		jmp cs:OldInt       ; call old interrupt handlers

	; standard exit
	@@ly:   mov al,20h
		out 20h,al
		pop ax
		iret

Music   segment para public use16
	include WVCHILD.INC
Ends
END start


;		DrawLoopi1:
;			mov	al,ds:[si]
;			mov	ah,es:[di]
;			cmp	ah,255
;			je	skipthisbit1
;				mov	es:[di],al
;			skipthisbit1:
;			inc	si
;			inc	di
;		loop	DrawLoopi1

COMMENT	~
	mov di,(320*100)+159                ;Dot in beginning.
	mov al,255
	mov es:[di],al
	mov cx,3
	mov bx,159
	nextbitofline:                      ;Becomes line.
		call    WaitVRT
		push    di
		push    cx
		rep stosb
		pop cx
		pop di
		add cx,2
		dec di
		dec bx
	jnz nextbitofline

	mov di,(320*100)            ;Lines split and move up/down.
	mov si,di
	LoopUpMove:
		call    WaitVRT
		mov eax,0ffffffffh
		mov cx,320/4
		push    di
		rep stosd
		xor eax,eax
		mov cx,320/4
		rep stosd
		pop di

		cmp si,(320*175)
		jae JustEndThis
		push    di
		mov di,si
		xor eax,eax
		mov cx,320/4
		push    si
		rep stosd
		mov eax,0ffffffffh
		mov cx,320/4
		rep stosd
		pop si
		pop di
		JustEndThis:

		add si,320
		sub di,320
		cmp di,(320*24)
	jae LoopUpMove
~
