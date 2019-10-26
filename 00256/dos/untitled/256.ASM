; gal.anonim
; 256byte intro
; for Abstract2oo3

; jedna noc - dlatego takie slabe...

IDEAL
p386
MODEL TINY

CODESEG
org 100h

Start:
    fld [dword ptr _delta]
   
    mov al,13h
    int 10h

    push 0A000h
    pop es

    db 0d6h
    mov dx,3c8h
    out dx,al
    inc dx

@@Palette:
    mov cl,40h
@@PaletteLoop:
    out dx,al
    out dx,al
    push ax
    xor ax,ax
    out dx,al
    pop ax
    inc ax
    loop @@PaletteLoop
    out dx,al
    test al,80h
    jz @@Palette


@@MainLoop:
    mov di,offset add_data
    mov al,127
    mov bl,50

@@BackGLoop:
    mov cx,640
@@BackGLoop1:
    mov [ds:di],al
    inc di
    loop @@BackGLoop1
    dec ax
    dec bx
    jnz @@BackGLoop

    fld [dword ptr _ypocz]
    mov cl,100

@@YLoop:
    fld [dword ptr _xpocz]
    mov bp,320

@@XLoop:
    mov dl,63

    fld st(1)
    fld st(1)

@@ItLoop:
    fld st(0)
    fmul st(0),st(0)
    fld st(2)
    fmul st(0),st(0)
    fsubp

    fld st(2)
    fmul st(0),st(2)
    fadd st(0),st(0)
    fstp st(3)
    fstp st(1)

    fld st(1)
    fadd [dword ptr _stalx]
    fst st(2)
    fmul st(0),st(0)

    fld st(1)
    fadd [dword ptr _staly]
    fst st(2)
    fmul st(0),st(0)

    faddp
    fsqrt

    fild [word ptr _kular]
    fcompp
    fnstsw ax
    sahf
    jbe @@KoniecIt
    dec dx
    jnz @@ItLoop
@@KoniecIt:

    mov si,di

    mov al,128
    sub al,dl
    add al,bl

    sub al,dl
    add al,[di+320]

    shr al,2

    mov bl,dl
    mov [di+640],dl

    shr dl,1

    mov bh,32
    sub bh,dl

@@HeightLoop:
    mov [ds:si],al
    sub si,320
    dec bh
    jnz @@HeightLoop

    inc di

    fcompp
    fadd st(0),st(2)
    dec bp
    jnz @@XLoop

    fcomp    
    fadd st(0),st(1)
    fadd st(0),st(1)
    loop @@YLoop

    fcomp
    fld [dword ptr _time]
    fadd st(0),st(1)
    fst [dword ptr _time]
    fld st(0)
    fsin
    fstp [dword ptr _stalx]
    fidiv [word ptr _kular]
    fsin
    fstp [dword ptr _staly]

    xor di,di
    mov si,offset add_data
    mov ch,07Fh
    rep movsw

    in al,60h
    dec al
    jnz @@MainLoop

    mov ax,0003h
    int 10h

    ret

_xpocz dd -2.0
_ypocz dd -1.25
_delta dd 0.0125
_kular dw 4
_fill db 'gal'
_stalx dd ?
_staly dd ?
_time dd ?
add_data db ?

END Start
