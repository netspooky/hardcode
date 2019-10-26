; simple matrix raytrace , ugly & slow
; without d3d
;
; zen333@rambler.ru
; icq: 106666811
;(c) by Zen from Vladivostok / Russia
;         in 2000
;released in 2002
;respect to:
;T-rex
;ryg/farbrausch
;baze/3sc
;and all sceners
.486p
.487
seg_a           segment byte public use16
                assume  cs:seg_a, ds:seg_a
;const
profil_tex_1 equ 100
_fov equ 150 ;150
x_sh equ 110
y_sh equ 80;110
z_sh equ 93
r_shr equ 333
maxx equ 320
razmery equ 200
maxy equ 200
;tabdy equ offset tab_dy
tabdx equ offset tab_dx
tabdy equ ((maxx-maxy)/2)*4 + tabdx;60*4 =240
max_distanse equ 255
xcentr equ maxx/2
ycentr equ 200
                org     100h

nice            proc    far

start:
       mov bx,es
       add bh,10h
       mov es,bx
       mov fs,bx  ; matrix
       add bh,10h
       mov gs,bx  ; texture
       xor di,di
       rep stosd  ; flush matrix
       add bh,10h
       mov es,bx
         mov     al,13h
         int     10h                     ; Video display   ah=functn 00h
call pal
call texgen
call matrix_build
;===box   побочный эффект матрицы это кубики
mov bx,4+8*3+64*1
mov byte ptr fs:[bx],2   ; stroim iz nih fignyu
mov byte ptr fs:[bx-8*2],4
mov byte ptr fs:[bx-8+64],2
;===box
call init
;--------
setscr:
        call memtoscr
        mov di,maxx*maxy
        mov si,razmery
nextline:
        mov cx,maxx
        dec si
        jz  exit
line1:
        dec di
        mov bp,cx
        shl bp,2
        fld dword ptr [bp+tabdx]
        mov bp,si
        shl bp,2
        fld dword ptr [bp+tabdy]
        fld1
        call rotate
        fild  [x_pl]
        fild  [y_pl]
        fild  [z_pl]  ;z y x za ya xa
;move one of 320 rays , forward
ray1:

fist [z]
fadd st,st(3)
fxch st(1)

fist [y]
fadd st,st(4)
fxch st(2)

fist [x]
fadd st,st(5)
fxch st(2)
fxch st(1)
    call trans
    mov al,fs:[bx]
    cmp al,2
    jz short _plottex
    cmp al,4
    jz short _plottex1

    cmp al,255
    jz short _plot
    cmp al,1
    jnz short noball
    call ball
    jc short _plotball ;*
noball:
        mov ax,z
        cmp ax,max_distanse
        jc short ray1
_plot:
           mov ax,x
           xor ax,y
           xor ax,z
and al,32
jmp plot

_plotball:
           mov ax,x
           xor ax,y
           add ax,z
jmp plot

_plottex1: mov ax,z
          and ax,63
          shl ax,6
          mov bx,y
          and bx,63
          shl bx,6
          add bx,ax
          mov ax,x
          and ax,63
          add bx,ax
          add bx,32768
          mov al,gs:[bx]
jmp plot



_plottex: mov ax,z
          and ax,63
          shl ax,6
          mov bx,y
          and bx,63
          shl bx,6
          add bx,ax
          mov ax,x
          and ax,63
          add bx,ax
          mov al,gs:[bx]
          add al,gs:[bx+1]
          add al,gs:[bx-1]
          add al,es:[di+1]
          add al,es:[di-1]
          shr al,3


plot:
        fcompp
        fcompp
        fcompp
        mov es:[di],al
        loop _loop
        jmp nextline
_loop: jmp line1

exit:
mov ax,z_pl
add ax,2
and ax,255
mov z_pl,ax
inc ang
inc ang
inc ang
       in al,60h
       dec al
       jnz setscr ;exit
       mov ax,3
       int 10h
       retn

ball:
        mov ax,x        ;x_shara
        sub ax,x_shr
        mul ax
        xchg bx,ax
        mov ax,y
        sub ax,y_shr
        mul ax
        add bx,ax
        mov ax,z
        sub ax,z_shr
        mul ax
        add ax,bx
        cmp ax,r_shr
        retn



bloksize equ 32
worldsize equ 256;256 ;320*3
maxblox equ worldsize / bloksize
;matrix_size equ maxblox*maxblox*maxbloks ; = 27000


matrix_build:
              mov ax,worldsize
              mov y,ax
build_y:      mov bx,worldsize
              mov x,bx
build_x:      mov cx,worldsize
              mov z,cx
build_z:
        call trans
        mov ax,y
        cmp ax,255
        jz short build_wall
        cmp  ax,1
        jz short build_wall

        mov ax,x
        cmp ax,255
        jz short build_wall
        cmp  ax,1
        jz short build_wall

        mov ax,z
        cmp ax,255
        jz build_wall
;        cmp  ax,1
;        jz build_wall



        push bx
        call ball
        pop bx
        mov al,0
        jnc short noop ;*
        mov al,1
        jmp short noop


build_wall:
        mov al,255
noop:
        or fs:[bx],al

        dec z
        jnz  build_z

        dec x
        jnz  build_x

        dec y
        jnz  build_y


             retn

trans:


        mov bx,z
        shr bx,5 ; idiv ax,ax,bloksize
        mov ax,y
        shr ax,5 ; idiv ax,ax,bloksize
        shl ax,6 ; imul ax,ax,maxblox*maxblox
        add bx,ax

        mov ax,x
        shr ax,5 ; idiv ax,ax,bloksize
        shl ax,3 ; imul ax,ax,maxblox
        add bx,ax
        retn



init:
        fninit
        mov cx,320
        mov si,tabdx
init_loop:
        mov x,cx
        sub x,xcentr
        fild [x]        ;precalculate magic numb.
        fidiv [fov]     ;x-160/fov
        fstp dword ptr [si]
        add si,4
        loop init_loop
        retn




pal: mov dx,3c8h
     mov al,cl
     out dx,al
     inc dx
     mov al,cl
     out dx,al
     shr al,3
     out dx,al
     rcr al,cl
     out dx,al
     loop pal
 retn

scrtex equ 63

texgen:
         mov cx,profil_tex_1
smoot:
    mov al,gs:[di+1]
    add al,gs:[di-scrtex]
    add al,gs:[di+scrtex]
    add al,gs:[di-1]
    inc al
    shr al,2
    inc al
    mov gs:[di],al

    dec di  ; no_screen

;stosb     ;+   screen
;or di,di  ;+     screen

        jnz short smoot
        loop smoot


        mov di,32767
texgen2:
        mov al,gs:[di]
        dec al
        mov gs:[di+1],al
        mov gs:[di-1],al
        mov gs:[di+scrtex],al
        mov gs:[di-scrtex],al
        inc di
        jnz texgen2
retn


rotate:
                push cx
                mov     cx,2
_rotate:
                fild    [ang]
                fidiv   [fov]
                fsincos
                fld     st(2)
                fmul    st,st(1)
                fld     st(4)
                fmul    st,st(3)
                fsubp   st(1),st
                fxch    st(3)
                fmulp   st(2),st
                fmulp   st(3),st
                faddp   st(2),st
                fxch    st(2)
                loop    _rotate
                pop cx
                retn

memtoscr:
mov bp,es
          push es
          pop ds
          push 0a000h
          pop es
              xor si,si      ;c ds:si Ha
              xor di,di  ;    es:di
              mov ch,61  ;
              rep movsd
              mov es,bp
           push cs
           pop ds
                retn


fov dw  _fov
x_shr dw x_sh
y_shr dw y_sh
z_shr dw z_sh
z_pl dw 33
y_pl dw 50
x_pl dw 80
ang dw 0
z dw  ?
y dw  ?
x dw  ?
zm dw ?
ym dw ?
xm dw ?
tab_dx dd 320 dup (?)
nice            endp
seg_a           ends
                end     start
