;======---- --          - ---=========;
   ;===--  -              -- --=======;
    ;==- --       -  -- - ----====;
    ;=-- --      - -  - -- - --=====;
    ;==----      - - ---- ----======;
    ;==- --       -  - -- --======;
   ;===- ---             ---- ========;
;======-- -- -         - -- -=========;

    ;1nf0:1c3ck0-1nt3r51tyexpr35:]
;					..by Assembler !30T
;assembler_bot@hotmail.com   http:\\assemblerbot.home.sk
;2001

[ORG 0x0100]	
[SEGMENT .text]

VECTORS equ 6 ;len XZ
VSCR equ VECTORS+320*4*2
    mov al,13h
    int 10h
    fninit

    mov di,VECTORS+POM
    fild word [vectorz]
    fld st0
    mov cx,320
defvect:
    fst dword [di]
    fxch st1
    fst dword [di+4]
    fxch st1
    fld1
    fsubp st1
    add di,8
;pal
    or ch,ch
    jnz skip_pal
    mov dx,03c8h
    mov al,cl
    out dx,al
    inc dx
    test cl,64+128
    jnz skip_xor
    xor al,al
skip_xor:
    out dx,al
    out dx,al
    jz skip_63
    mov al,63
skip_63:
    or al,cl
    out dx,al
skip_pal:

    loop defvect
;    fstp st0
;    fstp st0

    mov bp,POM
    fld dword [alpha]
    fsincos
render_frame:

    mov si,POM+VECTORS
    mov cx,320
rotation:
    fld dword [si+4]
    fld st0
    fdiv st2
    fxch st1
    fmul st3
    fld dword [si]
    fmul st3
    fsubrp st1
    fld dword [si]
    fmul st4
    faddp st2
    fstp dword [si]
    fstp dword [si+4]
    add si,8
    loop rotation

    mov bx,POM+VECTORS+80*8 ;y

    mov di,POM+VSCR
    mov dx,160
render_line:
    mov cx,320
    mov si,POM+VECTORS
render_pixel:
;alpha
    fld dword [bx]
    fld dword [si]
    fpatan
    fld st0
;corection alpha
    fild word [vectorz]
    fldpi
    fdivp st1
    faddp st1
    fsin

    fxch st1
;z
    fld dword [bx]
    fmulp st1
    fmul st0
    fld dword [si]
    fmul st0
    faddp st1
    fsqrt
    fldpi
    fdivrp st1
    fld dword [si+4]
    fmulp st1

;corection z
    fild word [vectorz]
    faddp st1

    fsin

    faddp st1
    fld1
    faddp st1
    fld1
    faddp st1
    fdiv st2

    fistp word [bp]
    mov al,[bp]

    stosb

    add si,8
    loop render_pixel

    add bx,8
    dec dx
    jnz render_line

;synchronization
    mov dx,03DAh
wait_for_retrace:
    in al,dx
    test al,8
    jz	wait_for_retrace

;copy vscr
    push es
    push word 0a000h
    pop es
    mov ch,320*160/256/2
    mov di,320*20
    rep movsw
    pop es

    inc word [vectorz]

    mov ah,1
    int 16h
    jnz exit
    jmp render_frame
exit:
;    mov ax,03h
;    int 10h
    int 20h

vectorz dw 160
alpha dd 0.032

POM: