;Zooming scroll
;Coded by Mr.Dsteuz//Proxium [10 august 1997 year]
;Released 3 february 2001 year

.model tiny
.486
.code
.startup

        mov ax,cs
        add ah,10h
        mov fs,ax

        lea di,font
        xor ax,ax
        mov cx,24576
        rep stosw

        mov ax,1130h
        mov bh,3
        int 10h
        push es
        pop ds
        push cs
        pop es
        mov si,bp
        mov di,font
        mov cx,1024
        rep movsd

        mov ax,cs
        mov es,ax
        mov ds,ax

        mov si,font
        lea di,fntcrn
        mov cx,256*8
fnt4:   lodsb
        mov bl,8
fnt3:   xor dh,dh
        rcl al,1
        jnc fnt2
        add dh,48
fnt2:   mov [di],dh
        inc di
        dec bl
        jnz fnt3
        inc bh
        and bh,7
        loop fnt4

        mov ax,13h
        int 10h

        mov dx,3c8h
        xor al,al
        out dx,al
        inc dx
l0:     mov al,cl
        out dx,al
        out dx,al
        out dx,al
        inc cl
        jnz l0

fnt1:   push cs
        pop es

pixp:   mov al,1
        dec al
        jnz fnt6
txtp:   lea si,text
        mov al,[si]
        and al,al
        jnz fnt5
        lea si,text
fnt5:   lodsb
        mov word ptr [txtp+1],si
        xor ah,ah
        shl ax,6
        add ax,offset fntcrn
        mov si,ax
        lea di,bufer+320
        mov bl,8
fnt7:   movsd
        movsd
        add di,320
        dec bl
        jnz fnt7
        mov al,8
fnt6:   mov byte ptr [pixp+1],al

        lea si,bufer+1
        lea di,bufer
        mov cx,656
        rep movsd

        push fs
        pop es

        mov eax,0
        xor di,di
        mov cx,16000
        rep stosd

        xor dx,dx
        xor bp,bp
        finit
        fldpi
        fimul m1
        fidiv m256
        fsin
        fimul m240
        fiadd m15
        fistp m2
        inc byte ptr m1
        mov al,byte ptr m2
        and al,al
        jnz fnt12
        inc bp
fnt12:  mov cl,al
        xor dx,dx
        mov di,ax
        mov ax,8*256
        div di
        mov dl,al
        mov bx,200
        sub bx,ax
        shr bx,1
        shl bx,6
        mov di,bx
        shl bx,2
        add di,bx
        xor ch,ch
        lea si,bufer
        mov ax,255
        sub al,byte ptr m2
        add si,ax
        mov ah,1
fnt10:  push si
        push cx
        mov bx,320
fnt8:   add ch,cl
        adc si,bp
        mov al,[si]
        stosb
        dec bx
        jnz fnt8
        pop cx
        pop si
        and cl,cl
        jz fnt13
        add ah,cl
        jnc fnt9
fnt13:  add si,328
fnt9:   dec dl
        jnz fnt10

        mov di,320
        mov cx,63360
lll6:   mov al,fs:[di-320]
        add al,fs:[di+320]
        add al,fs:[di-1]
        add al,fs:[di+1]
        shr al,2
        stosb
        loop lll6

        mov dx,3dah
        in al,dx
        test al,8
        jz $-3
        in al,dx
        test al,8
        jnz $-3

        push ds
        push 0a000h
        pop es
        push fs
        pop ds
        xor di,di
        xor si,si
        mov cx,16000
        rep movsd
        pop ds
        in al,60h
        dec al
        jnz fnt1
        mov ax,3
        int 10h
        ret

m256    dw 256
m240    dw 210
m15     dw 15
m1      dw 0
m2      dw 0

text    db "HI PEOPLE !!! I'AM ANTIALIASED ZOMMING SCROLL :))) CAN YOU VOTE FOR ME ???! TO BE OR NOT TO BE. CYA !!!             ",0

font:
fntcrn  equ font+2048
bufer   equ fntcrn+16384

end