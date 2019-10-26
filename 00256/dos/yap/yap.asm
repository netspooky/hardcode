;code by unic0rn/Asm Force

        org 100h
        segment .code
        mov al,13h
        int 10h
        mov bx,0a000h
        mov es,bx
        mov bh,90h
        mov fs,bx
        lea bx,[prange]
        fldz
plasma: mov si,18
        xor ax,ax
        mov dx,03c8h
        out dx,al
        inc dx
pal:    push ax
        cmp al,48
        jnc skip
        mov al,47
skip:   sub al,47
        shl al,2
        out dx,al
        pop ax
        push ax
        mov [bx+si],ax
        fild word [bx+si]
        fld st0
        fld st2
        fidiv word [bx+6]
        fsin
        call setcol
        fld st1
        fidiv word [bx+4]
        fcos
        call setcol
        pop ax
        inc ax
        cmp al,64
        jne pal
        mov cl,200
        xor di,di
        fild word [bx+14]
        fld st1
        fidiv word [bx+4]
        fsin
        fimul word [bx]
        faddp st1
        fstp dword [bx+20]
        fild word [bx+16]
        fld st1
        fidiv word [bx+6]
        fsin
        fimul word [bx]
        faddp st1
        fstp dword [bx+24]
draw:   push cx
        mov [bx+si],cx
        fild word [bx+si]
        fld st1
        fcos
        fimul word [bx+8]
        faddp st1
        fmul st0
        mov cx,320
line:   mov [bx+si],cx
        fild word [bx+si]
        fld st0
        fld st3
        fsin
        fimul word [bx+8]
        faddp st1
        fmul st0
        fadd st2
        fsqrt
        fdiv dword [bx+24]
        fsin
        fxch st1
        fdiv dword [bx+20]
        fsin
        faddp st1
        fabs
        fimul word [bx+2]
        fistp word [fs:di]
        inc di
        loop line
        ffreep st0
        pop cx
        loop draw
        fadd dword [bx+10]
        mov dx,3dah
vb1:    in al,dx
        and al,8
        jnz vb1
vb2:    in al,dx
        and al,8
        jz vb2
        dec cx
        xor si,si
        xor di,di
        rep fs movsb
        in al,60h
        dec ax
        jnz plasma
        ret
setcol: fimul word [bx]
        faddp st1
        fistp word [bx+si]
        mov ax,[bx+si]
        cmp al,0
        jnl skip2
        xor al,al
skip2:  cmp al,63
        jc skip3
        mov al,63
skip3:  out dx,al
        ret
prange: dw 12
pmul:   dw 31
pdiv:   dw 7
pdiv2:  dw 2
radius: dw 160
delta:  dd 0.02
f1:     dw 28
f2:     dw 15
