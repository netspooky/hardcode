    DOSSEG
    .MODEL SMALL
    .STACK 200h
    .CODE
    .386
    ASSUME CS:@CODE, DS:@CODE
    Locals
    Ideal
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
CsSeg       dw  ?

ScreenWidth =   400

INCLUDE "Modex.inc"

VLAsig      db  "oooooooooooooooooo",1
            db  "o                o",1
            db  "o x   x x    xx  o",1
            db  "o x   x x   x  x o",1
            db  "o  x x  x   xxxx o",1
            db  "o  x x  x   x  x o",1
            db  "o   x   xxx x  x o",1
            db  "o                o",1
            db  "oooooooooooooooooo",0

Roff        dw  0
Boff        dw  0
Goff        dw  0
Rvel        =   6
Bvel        =   3
Gvel        =   -3

INCLUDE "DaPal.DB"
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
    ;can you guess what this does?
PROC WriteSig
    push    es ds
    pusha
    
    mov     ah,1111b    ;latch in all 4 planes
    @Set_Write_Plane

    mov     ds,[cs:CSseg]
    mov     es,[VGAseg]

    mov     bp,30
    imul    bp,ScreenWidth/4
    add     bp,10
    mov     si,offset VLAsig
    mov     di,bp
@@DaLoop:
    mov     cl,[si]
    inc     si
    or      cl,cl
    je      @@AllDone
    dec     cl
    je      @@NextLine
    sub     cl," "-1

    mov     [es:di],cl
    mov     [es:di + ScreenWidth/4 * 2],cl
    mov     [es:di + ScreenWidth/4],cl
    mov     [es:di + ScreenWidth/4 * 3],cl
    inc     di
    jmp     @@DaLoop
@@NextLine:
    add     bp,ScreenWidth/4 * 4
    mov     di,bp
    jmp     @@DaLoop

@@AllDone:
    popa
    pop     ds es
    ret
ENDP WriteSig

    ;fills the screen w/ the palette
PROC WriteJunk
    push    es ds
    pusha

    mov     es,[cs:VGASeg]
    mov     di,0
    mov     cx,80
    mov     ax,2
    cld
    mov     bp,ScreenWidth
    shr     bp,2
@@Fw:
    mov     cx,bp
    push    ax

@@fff:
    stosb
    inc     al
    dec     cx
    jne     @@fff

    pop     ax
    inc     ax
    cmp     ax,480
    jb      @@Fw

    popa
    pop     ds es
    ret
ENDP WriteJunk

PROC WierdPal
    push    ds
    pusha 

    mov     ds,[cs:CSseg]
    mov     dx,3c8h
    xor     al,al
    out     dx,al
    inc     dx

    mov     si,[Roff]
    mov     di,[Goff]
    mov     bx,[Boff]
    mov     cx,256
@@DaLoop:
    mov     al,[Palette + si]
    out     dx,al
    mov     al,[Palette + di+1]
    out     dx,al
    mov     al,[Palette + bx+2]
    out     dx,al
    add     si,3
    add     di,3
    add     bx,3
    dec     cx
    jne     @@DaLoop

    add     [Roff],Rvel
    cmp     [Roff],768
    jl      @@Rok
    sub     [Roff],768
@@Rok:
    cmp     [Roff],0
    jge     @@Rok2
    add     [Roff],768
@@Rok2:

    add     [Boff],Bvel
    cmp     [Boff],768
    jl      @@Bok
    sub     [Boff],768
@@Bok:
    cmp     [Boff],0
    jge     @@Bok2
    add     [Boff],768
@@Bok2:

    add     [Goff],Gvel
    cmp     [Goff],768
    jl      @@Gok
    sub     [Goff],768
@@Gok:
    cmp     [Goff],0
    jge     @@Gok2
    add     [Goff],768
@@Gok2:

    popa
    pop     ds
    ret
ENDP

컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
START:
    mov     [cs:CsSeg],cs
    mov     ds,[cs:CsSeg]
    
    @SetModeX m256x240x256,ScreenWidth;m360x480x256,ScreenWidth

    mov     cx,256
    mov     ah,0
    mov     si,offset Palette
    @WritePalette

    mov     ah,1111b    ;latch in all 4 planes
    @Set_Write_Plane

    call    WriteJunk
    call    WriteSig

    mov     bx,0
    mov     bp,1
@@ScanLoop:
    @FullVertWait
    @Set_Split
    @Set_Start_Offset
    call    WierdPal

    mov     ah,1
    int     16h
    jnz     KeyPress

    add     bx,bp
    cmp     bx,[ModeXScanLines]
    jle     @@NotOver480
    neg     bp
    mov     bx,[ModeXScanLines]
@@NotOver480:
    cmp     bx,1
    jge     @@ScanLoop
    neg     bp
    mov     bx,1
    jmp     @@ScanLoop

KeyPress:
    mov     ah,0
    int     16h         ;get or wait for keypress 
    mov     ax,3        
    int     10h         ;set 80x25x16 text mode
    mov     ax,4c00h
    int     21h         ;return control to DOS
END START
