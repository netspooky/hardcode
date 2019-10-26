        DOSSEG
        .286
        .MODEL SMALL
        .STACK 200h
        .CODE

        ASSUME CS:@code, DS:@code

;====- DATA -=====
    VgaSeg      dw  0a000h  ;segment for VGA
    SegCode     dw  ?

    Numcolors   dw  200     ;# of colors to rotate
    NumColors3  dw  200*3   ;# of colors*3
    StartAt     db  1       ;color to start rotate at
    PalIndex    dw  0       ;color to start write at- increased every time
                            ;to produce the rotating effect
    PalIndexVel dw  1       ;amount PalIndex Changes for each screen

    Palette     LABEL BYTE
        i=0 
      REPT 63
                db i,i/2,i/3    ;63 increasing colors
        i=i+1
      ENDM

        i=63 
      REPT 63
                db i,i/2,i/3    ;63 decreasing colors
        i=i-1
      ENDM

        i=0 
      REPT 32
                db i/2,i/3,i    ;32 incr colors
        i=i+2
      ENDM

        i=63 
      REPT 32
                db i/2,i/3,i    ;32 decr colors
        i=i-2
      ENDM
                db  10*3 dup (0) ;buffer out to 200 colors total

;========- SubRoutines -========

WriteLines  PROC NEAR
    pusha
    mov   es,cs:[VgaSeg]

    mov   di,10*320
    mov   al,200-20
WrLiLoop:
    mov   ah,al
    mov   cx,160
    rep   stosw

    dec   al
    jne   WrLiLoop

    popa
    ret
WriteLines  ENDP

RotatePalette PROC NEAR
    pusha

    call  WritePalette

    mov   ds,cs:[SegCode]

    mov   ax,[PalIndexVel]
    add   [PalIndex],ax    ;change the palette index

    mov   ax,[PalIndex]    ;are we over the number of colors?
    mov   bx,[NumColors]

    cmp   ax,bx
    jl    NotTooHigh
    sub   [PalIndex],bx    ;add [Numcolors] to the index
    jmp   NotTooLow
NotTooHigh:
    cmp   ax,0
    jge   NotTooLow
    add   [PalIndex],bx    ;subtract [Numcolors] to the index
NotTooLow:

    popa
    ret
RotatePalette ENDP

WritePalette PROC NEAR        
    mov   ds,cs:[SegCode]
    cld

    mov   dx,[PalIndex]
    mov   bx,dx
    add   bx,bx           ;This just multiplies
    add   bx,dx           ;bx by three ( bx = bx + 2*bx )

    mov   si,offset Palette
    mov   dx,03c8h
    mov   ax,[PalIndex]
    add   al,[StartAt]
    out   dx,al           ;start writing at [PalIndex]+[StartAt]
    inc   dx
    mov   cx,[NumColors3]
    sub   cx,bx           ;get the number of colors to write
    rep outsb

    mov   al,[StartAt]
    dec   dx              ;point to palette index
    out   dx,al           ;out the number we want to start writing at 
    inc   dx
    mov   cx,bx           ;get the number of colors to write
    rep outsb             ;note that SI is already where we want it

    ret
WritePalette ENDP         ;well, that's all there is to it

;====- CODE -====

Start:
    mov     ax,cs
    mov     ds,ax
    mov     es,ax
    mov     [SegCode],ax

    mov     ax,0013h    ;changes to 320x200x256 graphics mode
    int     10h

    call    WriteLines
MainLoop:

    mov     dx,3dah
VRT:
    in      al,dx
    test    al,8
    jnz     VRT         ;wait until Verticle Retrace starts

    call    RotatePalette
    
    mov     dx,3dah
NoVRT:
    in      al,dx
    test    al,8
    jz      NoVRT       ;wait until Verticle Retrace ends
                        ;so that we dont rotate more than once a frame

    mov     ah,1        ;wait for a keypress
    int     16h
    jz      MainLoop

    mov     ah,0
    int     16h         ;get the key
    neg     cs:[PalIndexVel]
    cmp     al," "
    je      MainLoop

    mov     ax,0003h    ;changes to 80x25x16 text mode
    int     10h
    mov     ax,4c00h    ;terminate process and
    int     21h         ;return control to DOS

End START
        


