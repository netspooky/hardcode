;(c) by ZEN in 2002 for pouet.net     |\
;e-mail: zen333@mail.ru               | \
;--------------------------------------  \
;______________________________________\__|
; @ Radium fire effekt in 256b 
;
;


.486p
.487
maxlng equ 200
maxx equ 320
maxy equ 200
xcntr equ maxx / 2
ycntr equ maxy / 2
maxgrad equ 377

seg_a           segment byte public use16
                assume  cs:seg_a, ds:seg_a ,es:seg_a

        org 100h
radium            proc    far
start:
        mov cx,6000h;es
        mov fs,cx
        les  bp,[bx]
        mov ax,13h
        int 10h
_pal:
                mov     dx,3C8h
                sub  ax,cx
                out     dx,al                   ; port 3C8h, VGA pel address
                inc dx
                out     dx,al                   ; port 3C9h, VGA pel data reg
                rol al,1
                out dx,al
                out dx,al
                loop _pal
_loop_i:
        mov cx,maxlng
_loop_j:
        mov _j,cx
        fild [_i]
        fiadd [_j]
        fidiv [grd]
        fsincos ;s c j
        fimul [_j]
        fiadd [_160]
        fxch st(1)
        fimul [_j]
        fiadd [_100]    ;y x
        mov ax,y
        fistp [y]
        sub ax,y
        add ax,3
        shl al,4
        mov bx,x
        fistp [x]
        sub bx,x
        add bx,3
        and bl,7
        or bl,al
        mov ax,y
        cmp ax,maxy
        jnc short _over
        imul ax,ax,maxx
        mov di,x
        cmp di,maxx
        jnc short _over
        add di,ax
        mov es:[di],cl
        mov fs:[di],bl
_over:
        loop _loop_j
        dec _i
        jnz short _loop_i

        mov si,fs;140*320+97
_cicl:
        add bx,di
        mov al,fs:[bx]
        mov bp,bx
        push ax
        shr ax,4
        and ax,7
        sub ax,3
        imul ax,ax,320
        add bx,ax
        pop ax
        and ax,7
        sub ax,3
        add bx,ax
        xchg bp,bx

        mov al,es:[bp]
        add al,es:[bp+1]
        add al,es:[bp-1]
        add al,es:[bp+320]
        shr al,2
        mov es:[bx],al
        dec di
        jnz short _cicl
                                 inc si
        mov ax,100 ;100
          mov di,si ; ,140*320+97 ;    es:di
            mov cx,ax ;
              rep stosb

sub di,50*320+50
mov cx,ax
_vline:
add di,319
stosb
loop _vline

key_exit:  in al,[60h]
        dec al
        jnz short _cicl

mov ax,3
int 10h
retn

grd     dw 45   ;1/(   2 * pi / (maxgrad * 3))
_160 dw xcntr
_100 dw ycntr
vladivostok db 'VLADIVOSTO';k = Vladivostok it is my sity
;zen db 'ZEN'
_i dw maxgrad*3
_j dw ?
x dw ?
y dw ?
radium          endp
seg_a           ends
                end     start
