; RainBow Rhomb        (RBR)           Coded By Ufix/dSK!
; '''''''''''''
;
;  ok.. I know this is crapped. It has been done within an hour and a
; half, the day before the deadline (20-dec-98). It is absolutely unoptimized.
; It relies too much on the FPU (two FSQR per pixel!!),... I know I should
; have made a SQR precalculated table (but once again I didn't have time).
; So... my only satisfaction is having done a cute effect in only 171 bytes.
;
; Note for PII users:
;  It doesn't wait for the vertical retrace, so it will go faster than hell.
;
; Note for 486 users:
;  ..emm... nice static effect, isn't it?  ;-)
;
;
; Here is the Asm source: Sorry... no comments.
;
.MODEL TINY
.386
.CODE

ORG 100h
start:
        mov al,13h
        int 10h

        push 0a000h
        pop es

        mov cx,606
bigloop:
        xor bp,bp
        mov bx,200
vlin:   mov ax,320
hlin:   call CalcPix
        inc bp
        dec ax
        jnz hlin
        dec bx
        jnz vlin
        inc [xp]
        dec [xp2]
        in al,60h
        dec al
        jz exit
        loop bigloop

exit:   mov ax,03h
        int 10h
;        mov ax, 4c00h
;        int 21h
        ret

CalcPix         proc
        pusha
        mov cx,[xp]
        mov dx,[yp]
        sub cx,ax
        sub dx,bx

        shl cx,3
        shl dx,3

        mov ax,dx
        imul ax
        mov ax,cx
        mov di,dx
        imul ax
        add di,dx
        shl di,3
        mov [res],di        
        fild [res]
        popa
        fsqrt
        fistp [res]

        pusha

        mov cx,[xp2]
        mov dx,[yp2]
        sub cx,ax
        sub dx,bx

        shl cx,3
        shl dx,3

        mov ax,dx
        imul ax
        mov di,dx
        mov ax,cx
        imul ax
        add di,dx
        shl di,3
        mov [res2],di        
        fild [res2]
        fsqrt
        fistp [res2]

        mov ax,[res]
        add ax,[res2]
        mov es:[bp],al                   
        popa
        ret
CalcPix         endp

xp      dw 2
yp      dw -34

xp2     dw 333
yp2     dw 421

res     dw ?
res2    dw ?

END start
