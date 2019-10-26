    DOSSEG
    .MODEL SMALL
    .STACK 200h
    .CODE
    .386
    Ideal
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
CharSeg     dw  0b800h

Msg     db  "here's the test >€€<  blah..$"

MinX    =   1   *8
MaxX    =   78  *8
MinY    =   1   *8
MaxY    =   41  *8

BlockChr    dw  0,0,0,0,0,0,0,0
            dw  0001100000000000b
            dw  0111111000000000b 
            dw  0111111000000000b
            dw  1111111100000000b
            dw  1111111100000000b
            dw  0111111000000000b
            dw  0111111000000000b
            dw  0001100000000000b
            dw  0,0,0,0,0,0,0,0
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
MACRO @vidmemm0                    ; Vidmem mode 0 (character bitmap dat)
        mov dx,3c4h
        mov ax,00402h
        out dx,ax
        mov ax,00604h
        out dx,ax
        ÄÄ
        mov dx,3ceh
        mov ax,00005h
        out dx,ax
        mov ax,00c06h
        out dx,ax
        mov ax,00204h
        out dx,ax
ENDM

MACRO @vidmemm1                       ; Vidmem mode 1 (screen character dat)
        mov dx,3c4h
        mov ax,00302h
        out dx,ax
        mov ax,00204h
        out dx,ax
        ÄÄ
        mov dx,3ceh
        mov ax,01005h
        out dx,ax
        mov ax,00e06h
        out dx,ax
        mov ax,00004h
        out dx,ax
ENDM

MACRO @FullVertWait
 LOCAL @@Vr, @@Nvr
    mov     dx,3dah
@@Vr:
    in      al,dx
    test    al,8
    jz      @@Vr                    ;wait until Verticle Retrace starts
@@Nvr:
    in      al,dx
    test    al,8
    jnz     @@Nvr                   ;wait until Verticle Retrace Ends
ENDM @FullVertWait

    ;this only sets 80x43... does ANYONE know how to set 80x50
    ; with a character width of 8 NOT 9???
PROC Set80x50 NEAR
    mov     ax,1201h        ;set 350 scan lines
    mov     bl,30h
    int     10h

    mov     ax,0003h
    int     10h

;    mov     ax,1202h        ;set 400 scan lines
;    mov     bl,30h
;    int     10h

    mov     dx,3cch
    in      al,dx
    mov     dx,3c2h
    and     al,00111111b
    or      al,01000000b
    out     dx,al
    
    mov     ax,1112h
    mov     bl,0
    int     10h             ;load 8x8 bios font

    mov     dx,3cch         ;set 400 scan lines
    in      al,dx
    mov     dx,3c2h
    and     al,00111111b
    or      al,01000000b
    out     dx,al

    mov     dx,3d4h         ;set char height to 8
    mov     al,9
    out     dx,al
    inc     dx
    in      al,dx
    and     al,11100000b
    or      al,7
    out     dx,al

    ret
ENDP Set80x50

PROC FillScreen
    pusha
    push    ds es
    mov     ax,cs
    mov     ds,ax
    mov     es,[CharSeg]

    mov     di,0
    mov     ax,180h
    shl     eax,16
    mov     ax,181h
    mov     bx,182h
    shl     ebx,16
    mov     bx,183h
    mov     dx,50
@@TopLoop:
    mov     cx,40
@@MidLoop:
    mov     [es:di],eax
    mov     [es:di+160],ebx
    add     di,4
    dec     cx
    jne     @@MidLoop
    add     di,160
    dec     dx
    jne     @@TopLoop

    pop     es ds
    popa
    ret
ENDP FillScreen
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

OldDotdi    dw  0
DotXpos     dw  0
DotYpos     dw  0
DotXvel     dw  3
DotYvel     dw  2

PROC PlaceDot
    pusha
    push    es ds
    mov     bx,cs
    mov     ds,bx
    mov     es,[CharSeg]

    mov     ax,[DotYpos]
    mov     cx,[DotXpos]

    cmp     cx,80*8     ;make sure the dot is in range..
    jb      @@Xok
    mov     cx,80*8-1
@@Xok:
    cmp     ax,50*8
    jb      @@Yok
    mov     ax,50*8-1
@@Yok:
    mov     di,ax
    shr     di,3
    imul    di,80
    mov     bx,cx
    shr     bx,3
    add     di,bx   
    add     di,di       ;di = dest for object
    
    xchg    [OldDotDi],di
    or      di,di
    je      @@NoErase
    xor     ebx,ebx
    mov     [es:di],ebx
    mov     [es:di+160],ebx     ;erase old block
@@NoErase:
    and     ax,111b         ;make both range 0-8
    xor     ax,111b        ;because -y is up
    and     cx,111b

    mov     di,[OldDotDi]
    mov     [DWORD es:di],01800181h     
    mov     [DWORD es:di+160],01820183h ;write new block
    
    push    ax
    @VidMemM0
    pop     ax

    add     ax,ax

    mov     di,128*32
    mov     si,offset BlockChr
    add     si,ax
    mov     bp,8
    cld
@@TheLoop:
    lodsw
    ror     ax,cl
    mov     [es:di],al
    mov     [es:di+32],ah
    inc     di
    dec     bp
    jne     @@TheLoop

    mov     di,130*32
    mov     bp,8
@@TheLoop2:
    lodsw
    ror     ax,cl
    mov     [es:di],al
    mov     [es:di+32],ah
    inc     di
    dec     bp
    jne     @@TheLoop2

    @VidMemM1

    pop     ds es
    popa
    ret
ENDP PlaceDot

ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
START:
    mov     ax,cs
    mov     ds,ax

    call    Set80x50
    call    FillScreen
    
@@MainLoop:
    call    PlaceDot
    
    mov     ax,[DotXvel]
    add     [DotXpos],ax
    cmp     [DotXpos],MinX
    jge     @@DXminok
    neg     [DotXvel]
    mov     [DotXpos],MinX
@@DXminok:
    cmp     [DotXpos],MaxX
    jl      @@DXmaxok
    neg     [DotXvel]
    mov     [DotXpos],MaxX-1
@@DXmaxOK:
    
    mov     ax,[DotYvel]
    add     [DotYpos],ax
    cmp     [DotYpos],MinY
    jge     @@DYminok
    neg     [DotYvel]
    mov     [DotYpos],MinY
@@DYminok:
    cmp     [DotYpos],MaxY
    jl      @@DYmaxok
    neg     [DotYvel]
    mov     [DotYpos],MaxY-1
@@DYmaxOK:

    @FullVertWait
    mov     ah,1
    int     16h
    jz      @@MainLoop
    
    mov     ah,0
    int     16h
    mov     ax,3
    int     10h
    mov     ax,4c00h
    int     21h
END START
