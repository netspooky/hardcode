;----------------------------------------------------------------------------
;  S I L Y C O N E
;  4kb Intro Source-code
;  
;  It's soon two years since I wrote this code, so I thought it's time to
;  release the source. Maybe someone will learn something from it..
;  It's not very commented, but shouldn't be very hard to understand.
;  As usual, don't use my code in your own productions, unless you ask me
;  first. Happy Xmas 98!
;
;  Copyright (c) 1997 Petrik Clarberg <Spyko>
;----------------------------------------------------------------------------
        IDEAL
        P386
        MODEL tiny

NrPhotoStarts           EQU     140h
DelayEndPlasma          EQU     15
GreetingDelay           EQU     240

MandelZoom              EQU     1501
MandelStartX            EQU     -27700000
MandelStartY            EQU     -150000
MandelIterations        EQU     120
MandelLoopLength        EQU     3142    ; time(s) = LoopLength / 70

WormLength              EQU     200
WormLoopCounter         EQU     1400

BallNrPoints            EQU     3000
BallXCenter             EQU     128
BallYCenter             EQU     97
BallLoopCounter         EQU     1500
BallInitZoomSpeed       EQU     279

EndTextLoopCounter      EQU     1700
LensMag                 EQU     11
LensLoopCounter         EQU     1000

LandYSize               EQU     64
LandscapeLoopCounter    EQU     3200
LandZoomStart           EQU     100
        DATASEG
PhotoDelay      DB      2               ; start-delay-time for "photo"-effect

MsgLback        DB      "°°°°°°°°°",0
MsgL1           DB      "Spyko  ",2,0
MsgL2           DB      "presents",0
MsgL3           DB      "4k-",0
MsgL4           DB      "Silycone",0
MsgLdata        DW      30,4,0180h,OFFSET MsgL1        ; x,y, color&size, offset text
                DW      30,74,0080h,OFFSET MsgL2
                DW      198,80,0180h,OFFSET MsgL3
                DW      30,130,0180h,OFFSET MsgL4
Msg1            DB      "Greetings",0
Msg2            DB      "to everyone",0
Msg3            DB      "at",0
Msg4            DB      "HYPE-97",0
Msg5            DB      "REALTIME"
Msg6            DB      "Now this Intro is",0
Msg7            DB      "almost over and it",0  
Msg8            DB      "is time to sleep...",0
Msg9            DB      "with       phong-",0
Msg10           DB      "NO",0
Msg11           DB      "shaded 3d-objects!",0
Msg12           DB      "the Earth is",0
Msg13           DB      "STILL Flat !!!",0

MsgEndDos1      DB      "C:\>",0
MsgEndDos2      DB      "intro.end"
MsgEndDos       DB      "  This was my first intro, so Tyst and have a Nice day!",10,10,13,36

MandXstart      DD      MandelStartX
MandYstart      DD      MandelStartY
MandXskill      DD      MandelZoom
MandYskill      DD      MandelZoom

XScreen         DB      128
YScreen         DB      100
Distance        DW      55000
BallTexSize     DW      256                     ; 3d-ball
BackBallColor   DB      6 DUP (0)
RandSeed        DW      0
yv              DB      0
xvc             DB      0
yvc             DB      0
bv              DB      (64+37)
bvc             DB      1

Copyright       DB      "(c)     1997"

INCLUDE         "sine.16k"              ; 130 byte
SpaceForSine    DW      256 DUP (?)
Org3dPoints     DW      BallNrPoints*3 DUP (?)
xv              DB      ?
zv              DB      ?
MandB           DD      ?
TextData        DW      4 DUP (?)
BackBall        DB      64 DUP (?)      ; space for 2d-ball for background in end-text
Palette         DB      768 DUP (?)
        CODESEG
        ORG     100h
        ASSUME  cs:@code, ds:@code
Start:
;----------  Setup Mem  -------------
        mov     ax,cs
        add     ax,1000h        ; next segment
        mov     fs,ax           ; fs=screenbuffer
        add     ax,1000h
        mov     es,ax           ; es=extra data segment (plasma)
        add     ax,1000h
        mov     gs,ax           ; gs=more data (lens etc.)
        cld
;--------  Check Integrity (if someone has changed the Msgs) --------
        mov     si,OFFSET PhotoDelay
        mov     cx,313
        xor     dx,dx
        xor     ax,ax
@@int:  lodsb
        add     dx,ax
        loop    @@int
        cmp     dx,6117h
        je      SHORT @@int_ok
        mov     ah,4Ch          ; if checksum of Msgs is incorrect then exit to dos!
        int     21h
@@int_ok:
;----------  Setup Screen  ------------
        call    FadeOutPalette  ; Fade dos away
        mov     ax,0013h
        int     10h
        call    ClearScreenBuffer

;------ Setup Sine-table (43 byte total)  1.25*256 degrees, 2.14 FP --------
        mov     si,OFFSET Sine
        push    si
        mov     di,OFFSET Sine+256
        mov     cx,65
@@sst1: lodsw   
        mov     [si+510],ax     ; ie. +512 see below
        mov     [di],ax
        neg     ax
        mov     [si+254],ax     ; ie. +256 but si is already +2 (lodsw)
        mov     [di+256],ax
        sub     di,2
        loop    @@sst1
;----- Setup another Sine-table, offset ds:E000h, 256 degrees, 2.6 FP ------
        pop     si
        mov     bx,0E000h
@@2:    lodsw
        mov     [bx],ah
        inc     bl
        jnz     SHORT @@2

;----------------- Pre-Calculate Lens (110 bytes) ---------------------
        xor     di,di
        mov     bh,-32          ; y             s=(r*r-M*M)=924
@@l2:   mov     bl,-32          ; x
@@l1:   mov     al,bl
        imul    al              ; ax=x*x
        mov     dx,ax                
        mov     al,bh
        imul    al
        add     ax,dx           ; ax=x*x+y*y
        mov     cx,bx           ; cl = a = x,      ch = b = y
        cmp     ax,((32*32)-(LensMag*LensMag))          ; r*r-M*M
        jae     SHORT @@l3

        mov     cx,1024         ; cx = r*r = 1024
        sub     cx,ax           ; cx = r*r-(x*x+y*y)
        shl     ecx,16
        push    bx
;---------------------------------------------------------------------------
;  Low-Precision   Sqrt(ecx) > eax    16.16 FP, modifies eax,ebx,ecx,edx
;---------------------------------------------------------------------------
        xor     eax,eax
        mov     ebx,40000000h
@@s1:   mov     edx,ecx
        sub     edx,ebx
        jl      SHORT @@s2
        sub     edx,eax
        jl      SHORT @@s2
        mov     ecx,edx
        shr     eax,1
        or      eax,ebx
        shr     ebx,2
        jnz     SHORT @@s1
        shl     eax,8
        jmp     SHORT @@s3
@@s2:   shr     eax,1
        shr     ebx,2
        jnz     SHORT @@s1
        shl     eax,8
@@s3:
;----------- eax = sqrt(ecx)    16.16 fp ------------------
        pop     bx
        shr     eax,8           ; ax=sqrt( r*r-(x*x+y*y) )      8.8 fp
        mov     cx,ax
        xor     ax,ax           ; .
        mov     dx,LensMag      ; dx:ax = LensMag       16.16 fp
        idiv    cx              ; ax=M/z                8.8 fp
        push    ax
        movsx   dx,bl           ; x
        imul    dx              ; ax = x*M/z            8.8 fp
        add     ax,128          ; ax=ax+0.5
        mov     cl,ah           ; cl = a

        pop     ax
        movsx   dx,bh           ; y
        imul    dx
        add     ax,128          ; ax= y*M/z+0.5         8.8 fp
        mov     ch,ah           ; ch = b

@@l3:   add     cl,32
        add     ch,32

        movzx   ax,ch
        shl     ax,6
        xor     ch,ch
        add     ax,cx
        mov     [gs:di],ax      ; ax = (ch+32)*64 + (cl+32)
        add     di,2

        inc     bl
        cmp     bl,32
        jl      @@l1
        inc     bh
        cmp     bh,32
        jl      @@l2

;-------- Pre-Calculate 3D-ball ---------
        mov     si,OFFSET Sine
        mov     di,OFFSET Org3dPoints
        mov     bp,BallNrPoints
@@1:    call    RandomAX
        movzx   bx,al
        shl     bx,1
        mov     dx,[si+bx]      ; dx=sin(rnd1)*16384
        add     bx,128
        mov     cx,[si+bx]      ; cx=cos(rnd1)*16384
        movzx   bx,ah
        shl     bx,1
        mov     ax,[si+bx]      ; ax=sin(rnd2)*16384
        push    ax
        imul    dx
        mov     [di],dx         ; x (-4096 to 4096)
        pop     ax
        imul    cx
        mov     [di+2],dx       ; y (-4096 to 4096)
        add     bx,128
        mov     ax,[si+bx]
        sar     ax,2            ; ax/4
        mov     [di+4],ax       ; z (-4096 to 4096)
        add     di,6
        dec     bp
        jnz     SHORT @@1
;--------------  3D-Ball ready ---------------

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
IntroLens:
;----------- Set Palette -----------
        call    InitPaletteSet
        xor     cx,cx
        
@@1:    xor     al,al
        out     dx,al
        out     dx,al
        mov     al,ch
        out     dx,al
        inc     ch
        test    ch,00111111b
        jnz     SHORT @@1

@@2:    mov     al,ch
        out     dx,al
        out     dx,al
        mov     al,63
        out     dx,al
        inc     ch
        test    ch,00111111b
        jnz     SHORT @@2

        call    SetPaletteBlack2Red

@@3:    mov     al,63
        out     dx,al
        mov     al,ch
        out     dx,al
        xor     al,al
        out     dx,al
        inc     ch
        test    ch,00111111b
        jnz     SHORT @@3

;-------------  Draw Text -------------
        mov     si,OFFSET MsgLdata
        mov     dl,4
@@10:   mov     di,[si]
        mov     ax,[si+2]
        mov     cx,[si+4]
        mov     bx,[si+6]
        push    dx
        call    WriteText
        pop     dx
        add     si,8
        dec     dl
        jnz     SHORT @@10

        mov     cl,10
        call    DitherScreenBuffer

        xor     si,si
@@11:   mov     eax,[fs:si]
        mov     [es:si],eax
        add     si,4
        jnz     SHORT @@11
;----------- Background -----------
        call    ClearScreenBuffer
        mov     ax,4
@@12:   mov     di,16
        mov     cx,01C0h
        mov     bx,OFFSET MsgLback
        push    ax
        call    WriteText
        pop     ax
        add     ax,64
        cmp     al,132
        jbe     SHORT @@12
        
        mov     cl,10
        call    DitherScreenBuffer

;---------  Store background ball for later use (31 bytes) ---------
        mov     di,OFFSET BackBall
        mov     si,(30*320+41)
        mov     dl,8
@@b1:   mov     cx,8
@@b2:   mov     al,[fs:si]
        shr     al,4
        mov     [di],al
        inc     si
        inc     di
        loop    @@b2
        add     si,(320-8)
        dec     dl
        jnz     @@b1
;------------  Ball stored in [BackBall], 8*8 pix. ------------

        xor     si,si
@@13:   mov     al,[es:si]
        cmp     al,0
        jne     SHORT @@14
        mov     al,[fs:si]
        add     al,128
@@14:   mov     [es:si],al
        inc     si
        jnz     @@13

;----------- Draw the lenses -----------
        mov     dx,LensLoopCounter
@@Main:
        xor     si,si
@@15:   mov     eax,[es:si]
        mov     [fs:si],eax
        add     si,4
        jnz     SHORT @@15

        push    dx

        mov     cx,2
@@16:   push    cx
        push    dx
        call    NewXY
        shr     al,1
        shr     ah,1
        add     al,ch
        movzx   cx,al
        movzx   bx,ah
        call    DrawLens
        pop     dx
        add     dx,220
        neg     dx
        pop     cx
        add     ch,70
        dec     cl
        jnz     SHORT @@16

        mov     cl,1
        call    WaitVE
        
;----------  New Y for pic  -------------
        movzx   bx,[bv]
        shl     bx,1
        mov     bx,[Sine+bx]
        sar     bx,7
        add     bx,128
        mov     al,[bvc]
        add     [bv],al
;----------- Update Screen -----------
        cmp     bx,200
        jna     SHORT @@up3
        mov     bx,200
@@up3:  push    es
        push    0A000h
        pop     es

        mov     ax,bx
        shl     ax,8
        shl     bx,6
        add     bx,ax
        xor     di,di
@@up1:  mov     cx,160
@@up2:  mov     ax,[fs:bx]
        stosw
        add     bx,2        
        dec     cx
        jnz     @@up2
        cmp     bx,64000
        jb      @@up1
        mov     bx,64000
        cmp     di,64000
        jb      @@up1

        pop     es
        call    ClearScreenBuffer
        pop     dx
        cmp     dx,(LensLoopCounter-(128-37))
        jne     SHORT @@c1
        mov     [bvc],0
@@c1:   cmp     dx,(128-37)
        jne     SHORT @@c2
        mov     [bvc],-1
@@c2:   dec     dx
        jnz     @@Main

        call    FadeOutPalette
        call    UpdateScreen

;----------------------------------------------------------------------------

;----------  Pre-Calculate Plasma  -------------
        xor     di,di           ; upper: y, lower: x
        mov     bh,0E0h          ; bh=offset to sinus 
@@CalcPlasma:
        mov     ax,di           ; ah=y   al=x
        mov     bl,ah           ; bl=y
        sub     al,128
        imul    al              ; ax=(x-128)*(x-128)
        mov     cx,ax
        mov     al,bl           ; al=y
        sub     al,128
        imul    al
        add     ax,cx           ; ax=(x-128)*(x-128) + (y-128)*(y-128)
        shr     ax,3            ; ax=ax/8
        mov     bl,al           ; bx=offset to cos(al)

;        shr     ax,5            ; .
;        mov     ah,63           ; ..
;        sub     ah,al           ; ...
;        cmp     ah,0            ; ....
;        jnl     SHORT @@cpl1    ; .....
;        xor     ah,ah           ; ......
;@@cpl1: add     ah,64
;        mov     [BYTE gs:di],ah ; Calculates the light source (circle)

        movsx   ax,[BYTE bx]    ; ax=sin(al) i 10.6 fp     OBS! Change to cx
;        mov     ax,di          ; al=x                     if you enable the
;        add     al,al          ; al=x*2                   following lines     
;        mov     bl,al
;        movsx   ax,[BYTE bx]   ; ax=sin(x*2)
;        add     ax,cx   

        stosb                   ; plasmcol= sin(((x-128)^2+(y-128)^2)/8)+sin(x*2)
        test    di,di
        jnz     SHORT @@CalcPlasma    ; 65536 pixels ready?
;------------- Plasma ready ------------

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
MoreText:
        call    SetFirePalette
        mov     ax,60
        mov     di,18
        mov     cx,0080h
        mov     bx,OFFSET Msg9          ; write
        call    WriteText

        mov     ax,40
        mov     di,111
        mov     cx,01C0h
        mov     bx,OFFSET Msg10         ; write 
        call    WriteText

        mov     ax,140
        mov     di,18
        mov     cx,00A0h
        mov     bx,OFFSET Msg11         ; write 
        call    WriteText

        mov     cl,10
        call    DitherScreenBuffer
        call    UpdateScreen
        mov     cl,200
        call    WaitVE
        call    FadeOutPalette
        call    ClearScreenBuffer
        call    UpdateScreen

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
BurningWorm:
        call    SetFirePalette
        mov     dx,WormLoopCounter      ; angle & loopcounter
@@outer:
;---------- Draw Worm ----------
        push    dx
        mov     si,WormLength   ; length of worm
@@worm:
        call    NewXY           ; ah = New Y,        al = New X
;------------  Draw Point  ---------
        mov     di,ax
        call    RandomAX
        and     ah,127
        add     ah,30
        shl     eax,16
        call    RandomAX
        and     al,127
        add     al,30
        mov     [fs:di],eax
        inc     dx
        dec     si
        jnz     SHORT @@worm
;---------- Worm ready -----------
;-------------  Make Fire  ---------------
        xor     bx,bx
@@1:    mov     ax,[fs:bx+255]
        shr     ah,1
        shr     al,3
        add     ah,al
        mov     al,[fs:bx+257]
        shr     al,3
        add     ah,al
        mov     al,[fs:bx+512]
        shr     al,2
        add     ah,al
        jz      SHORT @@d               ; if ah>0 then ah=ah-1
        dec     ah              
@@d:    mov     [fs:bx],ah
        inc     bx
        cmp     bx,(256*200)
        jb      SHORT @@1
;---------- Loop Worm -----------
        mov     cl,1
        call    WaitVE
        call    UpdateScreen256         ; assumes bl=0
        pop     dx
        dec     dx
        jnz     @@outer
        call    FadeOutPalette
        call    ClearScreenBuffer
        call    UpdateScreen

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Rotate3dBall:
        call    SetPlasmaPalette
        mov     ax,BallLoopCounter
        mov     cx,BallInitZoomSpeed
        xor     dx,dx
@@Main:
        pusha
;---------------- Calculate new offset for Ball ------------------------
        mov     si,OFFSET Sine
;-------------  X  --------------
        movzx   bx,[bv]
        push    bx
        shl     bx,1
        mov     cx,bx
        mov     ax,[si+bx]
        pop     bx
        push    bx
        shl     bl,1            ; bl=[bv]*2
        shl     bx,1
        mov     dx,[si+bx]
        add     ax,dx
        sar     ah,2
        add     ah,BallXCenter
        mov     [XScreen],ah
;-------------  Y  --------------
        pop     bx
        push    bx
        shl     bx,1
        add     bx,128           ; sin>cos
        mov     ax,[si+bx]
        pop     bx
        shl     bl,2            ; bl=[bv]*4
        shl     bx,1
        mov     dx,[si+bx]
        add     ax,dx
        sar     ah,2
        add     ah,BallYCenter
        mov     [YScreen],ah
        inc     [bv]
        
;--------------------  Rotate and Draw Ball  -------------------------
        mov     si,OFFSET Org3dPoints
;------ Inner loop begins ------
@@rot:  mov     bx,[si]                 ; bx=X
        mov     cx,[si+2]               ; cx=Y
        mov     dx,[si+4]               ; dx=Z
        push    si
        call    Rotate3D                ; rotate xyz
        pop     si
        add     dx,[Distance]           ; z=z+Distance
        shr     dx,8                    
        mov     di,dx                   ; di=(z+Distance)/256

        mov     ax,bx
        cwd
        idiv    di
        add     al,[XScreen]
        mov     bl,al                   ; Screen X
        mov     ax,cx
        cwd
        idiv    di
        add     al,[YScreen]
        mov     bh,al                   ; Screen Y

        mov     ax,di
        add     al,15                   ; color
        mov     [BYTE fs:bx],al         ; put pixel in buffer
@@r:    add     si,6
        cmp     si,OFFSET Org3dPoints+(BallNrPoints*6)
        jb      SHORT @@rot
;----------  Inner Loop ends -----------
        inc     [zv]
        add     [xv],2
        mov     cl,1
        call    WaitVE                  ; Vertical Retrace
        mov     si,[BallTexSize]        ; size for texmap
        call    TexScreen               ; updates screen
        call    ClearScreenBuffer       ; clears buffer
;---------- Inc and Dec different things -----------
        popa
@@m1:   dec     cx
        jnz     SHORT @@m2
        mov     [WORD @@m1],9090h
@@m2:   sub     [Distance],cx
        add     [BallTexSize],dx

        cmp     ax,360
        ja      SHORT @@m3
        inc     dx
@@m3:   dec     ax                      ; loopcounter
        jnz     @@Main
;----------------  3D-PixelBall Ready  ----------------------

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PlasmaCircles:
        xor     bp,bp
@@Main:
        mov     bh,0E0h          ; bh = offset sinus, dont TOUCH!
;-------------   PL 1  -------------
        mov     ax,bp
        push    ax
        shl     al,1            ; ax=teller*2
        mov     bl,al
        movsx   ax,[bx]         ; ax=sin(al)
        mov     cx,47
        imul    cx      
        shrd    ax,dx,6         ; ax=ax/64
        add     ax,48           ; ax=48+(47*sin(teller*2))
        mov     si,ax

        movsx   ax,[bx]         ; ax=sin(teller*2)
        mov     cx,47
        imul    cx      
        and     ax,0FFC0h       ; clear 6 lsb-bits
        add     ax,(48*64)
        shl     ax,2            ; ax=256*(48+(47*sin(teller*2)
        add     si,ax           ; si = pl1
;------------   PL 2  --------------
        pop     ax              ; ax=teller
        push    ax
        mov     cx,25629
        mul     cx
        shrd    ax,dx,14        ; ax=teller*1.56427
        mov     bl,al
        movsx   ax,[bx]
        mov     cx,47
        imul    cx     
        shrd    ax,dx,6         ; ax=ax/64
        add     ax,48
        mov     di,ax           ; ax=48+(47*sin(teller*1.56427))

        pop     ax              ; ax=teller
        mov     cx,45134
        mul     cx
        shrd    ax,dx,14        ; ax=teller*2.7548
        mov     bl,al
        movsx   ax,[bx]         ; ax=sin(al)
        mov     cx,47
        imul    cx     
        and     ax,0FFC0h       ; clear 6 lsb-bits
        add     ax,(48*64)
        shl     ax,2            ; ax=256*(48+(47*sin(teller*2.7548)
        add     ax,di
        sub     ax,si           ; ax-pl1
        mov     dx,ax           ; dx=pl2
;-------------  Draw Plasma -------------
        xor     di,di
        push    ds
        push    es
        push    es
        pop     ds              ; ds=es
        push    fs
        pop     es              ; es=fs

        mov     cl,100
@@2:    mov     ch,160
@@1:    lodsb                   ; lods [BYTE ds:si]
        add     si,dx
        add     al,[si]
        sub     si,dx
        mov     ah,al
        mov     [WORD es:di+320],ax
        stosw                   ; mov [WORD es:di],ax     add di,2
        dec     ch
        jnz     SHORT @@1
        add     si,(256-160)    ; new line in plasma-data
        add     di,320          ; next line on screen
        dec     cl
        jnz     SHORT @@2
        pop     es
        pop     ds

        mov     cl,1            ; .
        call    WaitVE          ; VRetrace & CheckEsc
        call    UpdateScreen

        inc     bp
        cmp     bp,NrPhotoStarts
        jb      @@Main
        test    bp,063
        jnz     @@Main
        call    MakeGreyScale64
        jmp     @@Main

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
WriteGreeting:
        mov     ax,0
        mov     di,15
        mov     cx,0180h        ; ch=1, cl=128
        mov     bx,OFFSET Msg1
        call    WriteText

        mov     ax,60
        mov     di,70
        mov     cx,0080h
        mov     bx,OFFSET Msg2
        call    WriteText

        mov     ax,93
        mov     di,140
        mov     cx,0080h
        mov     bx,OFFSET Msg3
        call    WriteText

        mov     ax,132
        mov     di,48
        mov     cx,0180h
        mov     bx,OFFSET Msg4
        call    WriteText

        call    UpdateScreen
        mov     cl,GreetingDelay
        call    WaitVE          ; waits for (256/70) sek
;-----------  Fade away greeting  -------------
        mov     cx,220
@@1:    push    cx
        mov     cl,1
        call    DitherScreenBuffer
        mov     cl,1
        call    WaitVE
        call    UpdateScreen
        pop     cx
        loop    SHORT @@1
        call    FadeOutPalette

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
MandelbrotScroll:
        call    SetPlasmaPalette
;--------------  Write "REALTIME" to the left  ----------------
        mov     di,7            ; x
        xor     ax,ax           ; y
        mov     bx,OFFSET Msg5
        mov     cx,0280h        ; size=2        color=80h
        mov     dl,8
@@1:    pusha
        call    WriteText
        popa
        add     al,24           ; y
        inc     bx              ; offset char
        dec     dl
        jnz     SHORT @@1

;--------  Dither  Text ----------
        mov     cx,15
@@2:    push    cx
        mov     cl,1
        call    DitherScreenBuffer
        call    UpdateScreen
        mov     cl,4
        call    WaitVE
        pop     cx
        loop    SHORT @@2
;----------------  Draw and scroll the MandelBrot  ---------------
        call    ClearScreenBuffer
        mov     bp,MandelLoopLength     ; bp=loopcounter
        xor     bl,bl           ; first x = 0
MandelMain:
        push    bx
        call    UpdateScreen256
;------------  Draw new row in Mandeldata ---------
        pop     bx
        pusha
        call    DrawVerticalMandelLine
        popa

        mov     eax,[MandXskill]
        add     [MandXstart],eax
        inc     bl
        mov     cl,1            ; .
        call    WaitVE          ; VRetrace & CheckEsc
        dec     bp
        jnz     MandelMain

        call    FadeOutPalette
        call    ClearScreenBuffer
        call    UpdateScreen

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
EndText:
;----------------- Set Palette -------------------
        call    InitPaletteSet
        mov     ch,16
@@p2:   mov     cl,8
        mov     ah,ch
@@p1:   xor     al,al
        out     dx,al
        out     dx,al
        mov     al,ah
        out     dx,al
        add     ah,2
        dec     cl
        jnz     @@p1
        inc     ch
        cmp     ch,48
        jb      @@p2
;---------------  Main Loop ---------------------
        mov     dx,EndTextLoopCounter
        mov     si,OFFSET BackBallColor
Main:
;-----------  Draw balls in background -------------
        call    NewXY
        push    dx
        push    si
        
        xor     bh,bh
        xor     di,di
        mov     si,OFFSET BackBall
        mov     dh,200
@@1:    mov     cx,320
@@2:    and     ax,0707h
        mov     bl,ah
        shl     bl,3 
        add     bl,al       
        mov     dl,[si+bx]
        mov     [fs:di],dl
        inc     al
        inc     di
        loop    @@2
        inc     ah
        dec     dh
        jnz     @@1
;------------ Write text --------------
        pop     si
        pop     dx
        push    dx
        push    si

        push    si
        mov     ax,(EndTextLoopCounter-100)
        mov     cx,3
@@5:    cmp     dx,ax
        jne     SHORT @@j1
        mov     [BYTE si+1],8
@@j1:   sub     ax,248
        cmp     dx,ax
        jne     SHORT @@j2
        mov     [BYTE si+1],-8
@@j2:   sub     ax,248
        cmp     dx,ax
        jne     SHORT @@j3
        mov     [BYTE si+1],0
@@j3:   add     si,2
        loop    @@5
        sub     ax,496
        pop     si

        test    dl,0111b
        jnz     SHORT @@3
        push    si
        mov     cx,3
@@4:    mov     al,[si+1]
        add     [si],al
        add     si,2
        loop    @@4
        pop     si

@@3:    mov     bx,OFFSET Msg6
        mov     di,22           ; x
        mov     ax,25           ; y
        movzx   cx,[si]
        call    WriteText               ; OBS!  si
        mov     bx,OFFSET Msg7
        mov     di,18           ; x
        mov     ax,75           ; y
        movzx   cx,[si+2]
        call    WriteText
        mov     bx,OFFSET Msg8
        mov     di,10           ; x
        mov     ax,150          ; y
        movzx   cx,[si+4]
        call    WriteText

;---------- Update screen etc. -----------
        mov     cl,1
        call    WaitVE
        call    UpdateScreen
        pop     si
        pop     dx
        dec     dx
        jnz     Main

        call    FadeOutPalette

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
StillFlatText:
;------------- Set Palette -------------
        call    InitPaletteSet
        xor     cx,cx
@@p:    push    cx
        shr     cl,2
        mov     al,cl
        out     dx,al
        out     dx,al
        out     dx,al
        pop     cx
        inc     cl
        jnz     @@p
;------------ Write Text ------------
        mov     di,55
        mov     ax,55
        mov     cx,00C0h
        mov     bx,OFFSET Msg12          ; write
        call    WriteText
        mov     di,45
        mov     ax,95
        mov     cx,00F0h
        mov     bx,OFFSET Msg13         ; write 
        call    WriteText

        mov     cl,7
        call    DitherScreenBuffer
        call    UpdateScreen
        mov     cl,100
        call    WaitVE
;-----------  Fade away -----------        
        mov     cx,100
@@fa:   push    cx
        mov     cl,1
        call    DitherScreenBuffer
        mov     cl,1
        call    WaitVE
        call    UpdateScreen
        pop     cx
        loop    @@fa

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Landscape:
        mov     [yv],-20
        mov     [xv],90
        mov     [zv],10
;--------------  Set Black Palette ------------
        call    InitPaletteSet
@@bp:   out     dx,al
        out     dx,al
        out     dx,al
        dec     ah
        jnz     @@bp
;------------- Init Landscape ------------
        mov     [Distance],1700
        mov     [bv],0
        mov     bp,LandscapeLoopCounter

        xor     cx,cx           ; ZoomSpeed
        xor     bx,bx           ; bh=xvc  bl=yvc
@@Main:
        push    cx
        push    bp
        push    bx

        mov     bh,[bv]
        xor     bl,bl
        
        xor     ch,ch           ; outer-loopcounter
@@1:    mov     cl,64                        
@@2:    push    cx       
        push    bx        
                         
        movzx   dx,[BYTE es:bx]    ; z
        push    dx
        shl     dx,2
        sub     dx,128          ; dx=z (-128 to 128)
        movzx   bx,bl           ; x
        shl     bx,4               
        sub     bx,512          ; bx=x (-512 to 512)
        movzx   cx,ch            
        shl     cx,4                  
        sub     cx,(LandYSize*8)        ; cx=y (-512 to 512)
                         
        call    Rotate3d 
                         
        add     dx,[Distance]           ; z=z+Distance
        shr     dx,4
        mov     di,dx                   ; di=(z+Distance)/256
                                
        mov     ax,cx           
        shl     ax,5
        cwd                     
        idiv    di              
        add     ax,86          ; Screen Y (centering)
        cmp     ax,0
        jnl     SHORT @@11
        mov     ax,201
@@11:   cmp     ax,200
        jl      SHORT @@12
        mov     ax,201
@@12:   mov     cx,ax
        shl     ax,8
        shl     cx,6
        add     cx,ax

        mov     ax,bx
        shl     ax,5
        cwd                     
        idiv    di              
        add     ax,160          ; Screen X
        cmp     ax,0
        jnl     SHORT @@13
        mov     cx,(201*320)
@@13:   cmp     ax,320
        jl      SHORT @@14
        mov     cx,(201*320)
@@14:   add     ax,cx
        mov     bx,ax

        pop     ax                    
        inc     al
        mov     [fs:bx],al              ; draw current pixel

        pop     bx                                      
        inc     bl                                      
        pop     cx                                      
        dec     cl                                      
        jnz     @@2                                     
        xor     bl,bl                                   
        inc     bh                                      
        inc     ch                                      
        cmp     ch,LandYSize                            
        jb      @@1             
                                
        mov     cl,1            
        call    WaitVE          
        xor     bl,bl           
        call    UpdateScreen
        call    ClearScreenBuffer
                                
        test    [bv],63
        jnz     SHORT @@3
        call    MakeLandscape           ; generate new land every 64th pixel
@@3:
        inc     [bv]
        pop     bx
        add     [xv],bh
        add     [yv],bl
        pop     bp
;-----------  Change rotation angles -----------
        test    bp,0FFh
        jnz     SHORT @@ra
        call    RandomAX
        and     ax,0303h
        sub     al,1
        sub     ah,2
        mov     bx,ax
@@ra:
;--------- Set palette when landscape looks like a landscape -------
        cmp     bp,(LandscapeLoopCounter-LandYSize)
        jne     SHORT @@4
        call    SetLandscapePalette
@@4:
;----- Zoom out landscape when there is LandZoomStart nr. of loops left ----
        pop     cx
        cmp     bp,LandZoomStart
        ja      SHORT @@5
        add     cx,12
        add     [Distance],cx
@@5:    dec     bp
        jnz     @@Main
        
        call    FadeOutPalette
        call    UpdateScreen

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
DosPrompt:                              ; (57 bytes)
        call    SetFirePalette
;----------- Write "C:\>" ----------------
        call    ClearScreenBuffer
        mov     di,4            ; x
        xor     ax,ax           ; y
        mov     cx,191
        mov     bx,OFFSET MsgEndDos1
        call    WriteText
        call    UpdateScreen
;---------- Write "intro.end" ------------
        xor     ax,ax
        mov     di,68           ; x+64 ("C:\>" = 64 pixels wide)
        mov     cx,02BFh        ; ch=2        cl=191
        mov     bx,OFFSET MsgEndDos2
@@1:    pusha
        call    WriteText
        mov     cl,40
        call    WaitVE
        call    UpdateScreen
        popa
        inc     bx
        add     di,16
        cmp     di,208
        jb      SHORT @@1
;------------ Fade out text --------------
        mov     cx,80
@@2:    push    cx
        mov     cl,1
        call    DitherScreenBuffer
        mov     cl,1
        call    WaitVE
        call    UpdateScreen
        pop     cx
        loop    @@2

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
Exit:   call    FadeOutPalette
        mov     ax,0003h
        int     10h
        mov     ah,9
        mov     dx,OFFSET MsgEndDos
        int     21h
        mov     ah,4Ch
        int     21h

;-----------------------------------------------------------------------------
;  cx = x,      bx = y          Draw Lens, data from screenbuf
;-----------------------------------------------------------------------------
PROC DrawLens
        mov     ax,320
        mul     bx
        add     ax,cx           ; ax=y*320+x
        push    ax
        mov     si,ax           ; left-top of lens
        mov     di,(64*64*2)

        mov     ch,64
@@1:    mov     cl,16
@@2:    mov     eax,[fs:si]
        mov     [gs:di],eax
        add     si,4
        add     di,4
        dec     cl
        jnz     @@2
        add     si,(320-64)
        dec     ch
        jnz     @@1
;-------- Background saved ----------
        pop     di
        xor     bx,bx

        mov     ch,64  
@@3:    mov     cl,64
@@4:    mov     si,[gs:bx]
        add     si,(64*64*2)
        mov     al,[gs:si]
        mov     [fs:di],al
        inc     di
        add     bx,2
        dec     cl
        jnz     @@4
        add     di,(320-64)
        dec     ch
        jnz     @@3

        ret
ENDP DrawLens

;---------------------------------------------------------------------------
PROC NewXY
        push    si
        push    dx
        mov     si,OFFSET Sine
;------------- next X --------------
        movzx   bx,dl
        shl     bx,1
        push    bx
        mov     ax,[si+bx]      ; ax=sin(dx)*16384
        shr     dx,1
        mov     bx,dx
        shr     dx,2
        sub     bx,dx
        xor     bh,bh
        shl     bx,1
        mov     dx,[si+bx]
        sar     dx,1
        add     ax,dx
        sar     dx,1
        add     ax,dx           ; al=al+sin((3/8)*dx)*48
        add     ah,128
        mov     cl,ah
;------------- next Y  ------------------
        pop     bx
        pop     dx
        push    dx
        mov     ax,[si+bx+128]         ; ah=cos(dx)*64
        mov     bx,dx
        shr     dx,2
        sub     bx,dx
        xor     bh,bh
        shl     bx,1
        mov     dx,[si+bx]
        sar     dx,2
        add     ax,dx
        add     ah,115
        mov     al,cl

        pop     dx
        pop     si
        ret
ENDP NewXY

;-----------------------------------------------------------------------------
;  ax=y         di=x            cl=color        bx=offset text (ends with 0)
;  ch: 000000xy   ( x=1 > write only 1 char, x=0 > write whole string,
;                   y=0 > textsize=2, y=1 > textsize=4 )        si unmodified
;-----------------------------------------------------------------------------
PROC WriteText
        push    si
        push    es
        mov     dx,320
        mul     dx
        add     di,ax           ; di=offset in screenbuf

        mov     [WORD @@mod],0BCEBh  ; jmp   SHORT @@next
        test    ch,010b
        jz      SHORT @@1
        mov     [WORD @@mod],9090h   ; nop   nop
@@1:

        mov     si,OFFSET TextData
        mov     [WORD si],2
        mov     [WORD si+2],(320*2)
        mov     [WORD si+4],(2*320-2*8)
        mov     [WORD si+6],(16*2*320-8*2)
        mov     [BYTE @@in3],90h          ; Init code for 2*2 pixels
        test    ch,1
        jz      SHORT @@c
        mov     [WORD si],4
        mov     [WORD si+2],(320*4)
        mov     [WORD si+4],(4*320-4*8)
        mov     [WORD si+6],(16*4*320-8*4)
        mov     [BYTE @@in3],66h          ; Init code for 4*4 pixels

@@c:    push    bx
        push    cx
        mov     ax,1130h        ; get address of VGA 8*16 charset
        mov     bh,6
        int     10h             ; es:bp pointer to charset
        pop     cx
        pop     bx

        mov     ch,cl           
        push    cx
        shl     ecx,16
        pop     cx              ; ecx=color

;----------- Main Loop ----------
@@next: mov     al,[bx]         ; read next char
        test    al,al
        jz      SHORT @@end     ; if char=0 then exit
        movzx   si,al
        shl     si,4
        add     si,bp           ; es:si pointer to current char
        push    bx
        mov     bx,OFFSET TextData

        mov     dh,16
@@in2:  mov     al,[es:si]
        mov     dl,8
@@in1:  shl     al,1             
        jnc     SHORT @@f1      
;--------- Inner ----------
        push    ax
        mov     ax,[bx]         ; TextSize
@@in3:  nop                     ; get changed to a DWORD mov if size=4
        add     [WORD fs:di],cx
        add     di,320
        dec     ax              ; obs! ah = 0
        jnz     SHORT @@in3
        sub     di,[bx+2]
        pop     ax
;--------------------------
@@f1:   add     di,[bx]         ; TextSize
        dec     dl
        jnz     SHORT @@in1
        inc     si
        add     di,[bx+4]
        dec     dh
        jnz     SHORT @@in2

        sub     di,[bx+6]
        pop     bx
        inc     bx

@@mod:  jmp     SHORT @@next

@@end:  pop     es
        pop     si
        ret
ENDP WriteText

;---------------------------------------------------------------------------
PROC MakeGreyScale64
        push    ds
        mov     ax,fs
        mov     ds,ax
        xor     si,si
        mov     si,64000
@@1:    mov     al,[si]
        cmp     al,128
        jb      SHORT @@2
        mov     ah,255
        sub     ah,al
        xchg    ah,al
@@2:    
;        and     al,63          ; clear 2 msb of color in screenbuf.
;        shr     al,2            ; col/4
        mov     [si],al
        dec     si
        jnz     SHORT @@1
        pop     ds
;-------- Set Grey Palette ----------
        call    InitPaletteSet
                
        mov     cx,(30*256)
@@p1:   mov     al,ch
        out     dx,al        
        out     dx,al
        out     dx,al
        add     cx,(256/4)
        inc     ah
        test    ah,127
        jnz     SHORT @@p1

        mov     cx,(63*256)
@@p2:   mov     al,ch
        out     dx,al        
        xor     al,al
        out     dx,al
        mov     al,cl
        out     dx,al

        mov     al,ch
        out     dx,al        
        xor     al,al
        out     dx,al
        mov     al,cl
        out     dx,al
        
        dec     ch
        inc     cl
        inc     ah
        test    ah,63
        jnz     SHORT @@p2
;----------  Update Screen & Wait  ----------
        call    UpdateScreen
        mov     cl,[PhotoDelay]
        call    WaitVE
        inc     [PhotoDelay]
        cmp     [PhotoDelay],DelayEndPlasma
        je      WriteGreeting
        call    SetPlasmaPalette        ; re-set the old palette
        ret
ENDP MakeGreyScale64

;---------------------------------------------------------------------------
;  bl=x
;---------------------------------------------------------------------------
PROC DrawVerticalMandelLine
        mov     eax,[MandYstart]
        mov     [MandB],eax
        xor     bh,bh           ; y=0
;----------- Main Loop -----------
@@lp1:  push    bx              ; save bx
        mov     edi,[MandXstart]    ;
        mov     esi,[mandB]         ; esi=y
;---------------  Inner Loop  ---------------
        mov     ch,MandelIterations     ; FOR k = NrIter TO 0 step -1
@@in:   mov     eax,edi         ; x
        imul    eax
        shrd    eax,edx,24
        mov     ebx,eax         ; ebx(u) = x * x
        mov     eax,esi
        imul    eax
        shrd    eax,edx,24
        mov     ebp,eax         ; ebp(v) = y * y

        mov     eax,edi
        imul    esi
        shrd    eax,edx,23
        push    eax             ; w = 2 * x * y

        mov     eax,ebx
        sub     eax,ebp
        add     eax,[MandXstart]
        mov     edi,eax         ; x = u - v + a
        pop     esi             ; esi=w  
        add     esi,[MandB]     ; y = w + b
        
        add     ebx,ebp
        cmp     ebx,09900000h            ; 268435456
        jg      SHORT @@dot     ; IF u + v > 16 THEN GOTO dot
        dec     ch
        jnz     SHORT @@in      ; NEXT k
;-----------  Put Pixel in ScreenBuffer  ----------------
@@dot:  pop     bx              ; restore bx
        mov     eax,[MandYskill]
        add     [MandB],eax

        mov     [fs:bx],ch
        push    bx
        mov     ah,bh
        mov     bh,200
        sub     bh,ah
        mov     [fs:bx],ch
        pop     bx
        
        inc     bh
        cmp     bh,101
        jb      SHORT @@lp1

        ret
ENDP DrawVerticalMandelLine

;----------------------------------------------------------------------------
;       bx=x            cx=y           dx=z             
;   Coordinates from -32768 to 32767.              94 bytes
;----------------------------------------------------------------------------
PROC Rotate3D
        push    bx    
        mov     bx,cx
        mov     cx,dx
        movzx   si,[xv]
        call    @@Rot
        mov     ax,bx
        pop     bx
        push    ax
        movzx   si,[yv]
        call    @@Rot
        mov     dx,cx
        pop     cx
        push    dx
        movzx   si,[zv]
        call    @@Rot
        pop     dx
        ret
;-----------  Rotate bx & cx --------------
;    si=v            bx=A            cx=B
@@Rot:  shl     si,1
        add     si,OFFSET Sine
        mov     ax,[si+128]             ; cos(v)
        mov     bp,ax
        imul    bx
        shrd    ax,dx,14
        push    ax
        mov     ax,[si]                 ; sin(v)
        mov     di,ax
        imul    cx
        shrd    ax,dx,14
        pop     dx
        sub     dx,ax
        push    dx
        mov     ax,di                   ; sin(v)
        imul    bx        
        shrd    ax,dx,14
        push    ax
        mov     ax,bp                   ; cos(v)
        imul    cx
        shrd    ax,dx,14
        pop     cx
        add     cx,ax                   ; cx=Ny B
        pop     bx                      ; bx=Ny A
        ret
ENDP Rotate3D

;---------------------------------------------------------------------------
;  Calculate 64*64 pixels landscape at   es:[bv]*256
;---------------------------------------------------------------------------
PROC MakeLandscape
;--------------- Clear old land --------------
        mov     bh,[bv]
        add     bh,LandYSize
        xor     bl,bl
        push    bx
        push    bx
        mov     cx,(64*256/2)           ; 64 lines
@@l1:   mov     [WORD es:bx],0FFFFh     ; z = 255
        add     bx,2
        loop    @@l1                                               
;------------ Calculate new land --------------
        pop     di
        sub     di,256                  ; di=offset last old line i land.
        xor     bx,bx

; p(0) = INT(RND * h)
; p(64) = INT(RND * h)
        call    RandomAX
        and     ax,03F3Fh               ; ah & al = 0-63
        mov     [es:di+16384],al        ; p(64 * 65) = INT(RND * h)
        mov     [es:di+16448],ah        ; p(64 * 65 + 64) = INT(RND * h)

; xs = 64
; ys = 64
; xsk = 32
; ysk = 32
        mov     dx,4020h        ; dh=xs=64      dl=xsk=32     

@@new:  xor     bx,bx           ; bl=x=0        bh=y=0
@@b:    xor     bl,bl           ; x = 0
@@a:

        mov     ch,[es:di+bx]   ; ch=c1 = p(y * 65 + x)
        push    bx
        add     bl,dh
        mov     cl,[es:di+bx]   ; cl=c2 = p(y * 65 + x + xs)
        add     bh,dh
        mov     al,[es:di+bx]   ; al=c4 = p((y + ys) * 65 + x + xs)
        sub     bl,dh
        mov     ah,[es:di+bx]   ; ah=c3 = p((y + ys) * 65 + x)
        pop     bx

;-----------  cn1 ------------
        push    ax
        push    bx
        push    cx
        
        mov     ax,cx
        call    Average         ; al=cn1 = INT((c1 + c2) / 2) + RND * r - r / 2
        add     bl,dl
        call    Store           ; p(y * 65 + x + xsk) = cn1

        pop     cx
        pop     bx              
        pop     ax
;----------- cn2 ---------------
        push    ax              ; save c3 & c4 for later use
        push    bx
        push    cx

        call    Average         ; al=cn2 = INT((c3 + c4) / 2) + RND * r - r / 2
        add     bh,dh
        add     bl,dl
        call    Store           ; p((y + ys) * 65 + x + xsk) = cn2

        pop     cx
        pop     bx
        pop     ax
;------------ cn3 --------------
        push    ax
        push    bx
        push    cx

        mov     al,ch
        call    Average         ; al=cn3 = INT((c1 + c3) / 2) + RND * r - r / 2
        add     bh,dl
        call    Store           ; p((y + ysk) * 65 + x) = cn3

        pop     cx
        pop     bx
        pop     ax
;------------- cn4 --------------
        push    ax
        push    bx
        push    cx

        mov     ah,cl
        call    Average         ; al=cn4 = INT((c2 + c4) / 2) + RND * r - r / 2
        add     bh,dl
        add     bl,dh
        call    Store           ; p((y + ysk) * 65 + x + xs) = cn4

        pop     cx
        pop     bx
        pop     ax
;------------ cn5 -------------

        add     al,ah
        add     cl,ch
        add     cl,al
        shr     cl,2        
        call    RandomAX
        and     al,15
        sub     al,7
        add     al,cl

        cmp     al,0
        jg      SHORT @@sj1
        mov     al,0
@@sj1:  cmp     al,63
        jl      SHORT @@sj2
        mov     al,63           ; al=cn5 = INT((c1 + c2 + c3 + c4) / 4) + RND * r - r / 2
@@sj2:
        push    bx
        add     bh,dl
        add     bl,dl
        call    Store           ; p((y + ysk) * 65 + x + xsk) = cn5
        pop     bx

        add     bl,dh           ; x = x + xs
        cmp     bl,64
        jb      @@a             ; IF x < 64 THEN GOTO a
        add     bh,dh           ; y = y + ys
        cmp     bh,64
        jb      @@b             ; IF y < 64 THEN GOTO b

        shr     dh,1            ; xs = xs / 2
        shr     dl,1            ; xsk = xsk / 2            

        cmp     dh,1
        ja      @@new           ; IF xs > 1 THEN GOTO new

;-------------  Average heights ----------
        pop     di
        inc     di              ; di = offset 2nd X & Y in landscape 
        mov     ch,63
@@1:    mov     cl,63 
@@2:    mov     bl,[es:di-1]
        mov     bh,[es:di+1]
        mov     dl,[es:di-256]
        mov     dh,[es:di+256]
        add     bl,bh
        add     dl,dh
        add     dl,bl
        shr     dl,3
        mov     al,[es:di]
        shr     al,1
        add     al,dl
        mov     [es:di],al
        inc     di
        dec     cl
        jnz     @@2
        add     di,(256-63)
        dec     ch
        jnz     @@1

        ret
;---------------------------------------------------------------------------
;  al = (al+ah)/2 + rnd*16-8
;    modifies           ax, cl
;---------------------------------------------------------------------------
Average:
        add     al,ah
        shr     al,1
        mov     cl,al
        call    RandomAX
        and     al,15
        sub     al,7            ; al=rnd*16-7
        add     al,cl
        cmp     al,0
        jg      SHORT @@av1
        mov     al,0
@@av1:  cmp     al,63
        jl      SHORT @@av2
        mov     al,63           ; al=0-63
@@av2:  ret
;---------------------------------------------------------------------------
;   if   [es:di+bx]=64   then   Store   al
;---------------------------------------------------------------------------
Store:  cmp     [BYTE es:di+bx],255
        jne     SHORT @@st1
        mov     [es:di+bx],al
@@st1:  ret
ENDP MakeLandscape

;---------------------------------------------------------------------------
;  Waits  cl  number of verical blanks, time(s) = cl/70
;  and checks if Esc has been pressed.
;---------------------------------------------------------------------------
PROC WaitVE
;--------- VRetrace --------------
@@1:    mov     dx,03DAh
@@vr1:  in      al,dx
        and     al,08h
        jnz     SHORT @@vr1
@@vr2:  in      al,dx
        and     al,08h
        jz      SHORT @@vr2
;--------- Check Esc ------------
        mov     ah,11h
        int     16h
        jz      SHORT @@2
        mov     ah,10h
        int     16h
        cmp     al,27
        je      Exit
@@2:    dec     cl
        jnz     SHORT @@1
        ret
ENDP WaitVE

;--------------------------------------------------------------------------
PROC FadeOutPalette
        mov     dx,03C7h
        xor     ax,ax
        out     dx,al
        add     dx,2

        mov     di,OFFSET Palette
        mov     cx,768
@@1:    in      al,dx
        mov     [di],al
        inc     di
        loop    @@1
;---------  Palette read  ------------
        mov     bl,64
@@2:    mov     si,OFFSET Palette
        call    InitPaletteSet
        mov     cx,768
@@3:    mov     al,[si]
        cmp     al,0
        jna     SHORT @@4
        dec     ax              ; ah  have to 0
@@4:    mov     [si],al
        out     dx,al
        inc     si
        dec     cx
        jnz     SHORT @@3
        push    dx
        mov     cl,1
        call    WaitVE
        pop     dx
        dec     bl
        jnz     SHORT @@2        
        
        ret
ENDP FadeOutPalette

;---------------------------------------
InitPaletteSet:
        mov     dx,03C8h
        xor     ax,ax
        out     dx,al
        inc     dx
        ret
;---------- Set Plasma Palette -----------
SetPlasmaPalette:
        call    InitPaletteSet
        xor     ch,ch

        call    SetPaletteBlack2Red

        mov     cl,63
@@sp2:  mov     al,cl
        out     dx,al
        xor     al,al
        out     dx,al
        mov     al,ch
        out     dx,al
        dec     cl
        inc     ch
        test    ch,00111111b
        jnz     SHORT @@sp2

        mov     cl,63
@@sp3:  xor     al,al
        out     dx,al
        out     dx,al
        mov     al,cl
        out     dx,al
        dec     cl
        inc     ch
        test    ch,00111111b
        jnz     SHORT @@sp3

        mov     al,0
@@sp4:  out     dx,al
        out     dx,al
        out     dx,al
        inc     ch
        test    ch,00111111b
        jnz     SHORT @@sp4
        ret
;---------- Set Fire Palette -----------
SetFirePalette:
        call    InitPaletteSet
        xor     ch,ch
        
        call    SetPaletteBlack2Red

        mov     cl,63
@@sp2:  mov     al,cl
        out     dx,al
        mov     al,ch
        out     dx,al
        xor     al,al        
        out     dx,al
        inc     ch
        test    ch,63
        jnz     SHORT @@sp2

        mov     cl,63
@@sp3:  mov     al,cl
        out     dx,al
        out     dx,al
        mov     al,ch
        out     dx,al
        inc     ch
        test    ch,00111111b
        jnz     SHORT @@sp3
        ret

;------------ Set Landscape Palette -------------
SetLandscapePalette:
        call    InitPaletteSet
        xor     al,al
        out     dx,al
        out     dx,al
        out     dx,al

        mov     cl,63
@@pn:   xor     al,al
        out     dx,al
        mov     al,ch
        out     dx,al
        mov     al,cl
        out     dx,al
        dec     cl
        inc     ch
        cmp     ch,64
        jb      SHORT @@pn
        ret

        mov     cl,63
@@p:    mov     al,ch
        out     dx,al
        xor     al,al
        out     dx,al
        mov     al,cl
        out     dx,al
        dec     cl
        inc     ch
        cmp     ch,64
        jb      SHORT @@p
        ret


;---------------------------------------
SetPaletteBlack2Red:
@@1:    mov     al,ch
        out     dx,al
        xor     al,al
        out     dx,al
        out     dx,al
        inc     ch
        test    ch,63
        jnz      SHORT @@1
        ret
;--------------------------------------------------------------------------
;  Moves 64000 byte from fs:0000 to A000:0000 (Graphic memory)
;--------------------------------------------------------------------------
PROC UpdateScreen
        push    ds
        push    es
        push    0A000h
        pop     es
        push    fs
        pop     ds
        mov     cx,(64000/4)
        xor     si,si
        xor     di,di
        rep     movsd
        pop     es
        pop     ds
        ret
ENDP UpdateScreen

;---------------------------------------------------------------------------
PROC ClearScreenBuffer
        xor     eax,eax 
        xor     di,di
@@1:    mov     [fs:di],eax
        add     di,4
        jnz     SHORT @@1
        ret
ENDP ClearScreenBuffer

;--------------------------------------------------------------------------
;   cl = number of times to dither screenbuffer (fs)
;--------------------------------------------------------------------------
PROC DitherScreenBuffer
        xor     ch,ch        
@@out:  mov     di,0
        mov     bp,(64000)
@@1:    xor     ax,ax
        xor     dx,dx
        mov     ah,[BYTE fs:di]
        shr     ax,1
        mov     dh,[BYTE fs:di-1]
        shr     dx,3
        add     ax,dx
        xor     dx,dx
        mov     dh,[BYTE fs:di+1]
        shr     dx,3
        add     ax,dx
        xor     dx,dx
        mov     dh,[BYTE fs:di-320]
        shr     dx,3
        add     ax,dx
        xor     dx,dx
        mov     dh,[BYTE fs:di+320]
        shr     dx,3
        add     ax,dx
        xor     dx,dx

        mov     [BYTE fs:di],ah
        inc     di
        dec     bp
        jnz     SHORT @@1
               
        loop    @@out           ; next turn
        ret
ENDP DitherScreenBuffer

;---------------------------------------------------------------------------
;  Moves 256*200 pixels from ScreenBuffer to 0A000h, bl = start x (0 normal)
;---------------------------------------------------------------------------
PROC UpdateScreen256
        push    es
        push    0A000h
        pop     es
        mov     di,32           ; offset on screen (y=0, x=32)
        xor     bh,bh           ; y=0
        mov     ch,200
@@3:    mov     cl,128
@@2:    mov     ax,[fs:bx]      ; read from mandel-data
        add     bl,2
        stosw                   ; write to screen
        dec     cl
        jnz     SHORT @@2
        add     di,(320-256)    ; new line on screen
        inc     bh
        dec     ch
        jnz     SHORT @@3
        pop     es
        ret
ENDP UpdateScreen256
;---------------------------------------------------------------------------
; Updates screen from 256*256 screenbuf. SI = size (8.8 fp).    66 bytes
;---------------------------------------------------------------------------
PROC TexScreen
        push    ds                       
        push    0A000h                  
        pop     ds                      ; ds=A000h
        mov     dx,si                   
        neg     dx                       
        shl     dx,7                    ; start-X in 8.8 fp
        add     dh,96                   ; center screen
        mov     cx,si
        neg     cx
        shl     cx,6                    
        add     ch,64                   ; start-Y in 8.8 fp
        xor     di,di                   ; first pixel to write

@@out:  mov     bp,160                  ; innerloop-counter
        push    dx
@@in:   mov     bl,dh
        mov     bh,ch
        mov     al,[fs:bx]              ; read first pixel
        add     dx,si
        mov     bl,dh
        mov     ah,[fs:bx]              ; read second pixel
        add     dx,si                   ; x=x+size
        mov     [di],ax                 ; write word to 0A000h
        add     di,2
        dec     bp
        jnz     SHORT @@in
        add     cx,si                   ; y=y+size
        pop     dx
        cmp     di,64000
        jb      SHORT @@out

        pop     ds
        ret
ENDP TexScreen

;---------------------------------------------------------------------------
PROC RandomAX
        mov     ax,[RandSeed]
        add     ax,18923
        ror     ax,1
        mov     [RandSeed],ax
        ret
ENDP RandomAX

        END Start




