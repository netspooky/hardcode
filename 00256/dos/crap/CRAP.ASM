.MODEL tiny
.486
.CODE
ORG 100h
shift    equ 5
aantal   equ 256
grav     equ 1
vscreen  equ 09000h
vga      equ 0a000h
START:               jmp     hetbegin
                     db      'aardbei',1ah
hetbegin:            mov     al, 13h
                     int     10h
                     mov     cx, aantal
                     mov     si, offset particle
genloop:             call    nieuweparticle
                     in      ax, 40h
                     add     si, 8
                     loop    genloop
MAINLOOP:            push    vscreen
                     pop     es
                     dec     cx
                     mov     al, 0
                     rep     stosb
                     mov     di, 180*320
                     mov     al, 12
                     mov     dx, 19
balkv:               mov     cx, 160
                     rep    stosb
                     add    di, 160
                     dec    dx
                     jnz    balkv
                     mov     cx, aantal
                     mov     si, offset particle
                     mov     ax, cs
                     mov     ds, ax
particleloop:        mov     ax, [si]
                     add     ax, [si+4]
                     mov     [si], ax
                     cmp     ax, 319 shl shift
                     jb      xok
                     call    nieuweparticle
                     jmp     tekenpixel
xok:                 mov     ax, [si+2]
                     add     ax, [si+6]
                     cmp     ax, 199 shl shift
                     jb      yok
                     call    nieuweparticle
                     jmp     tekenpixel
yok:                 mov     [si+2], ax
                     add     word ptr [si+6], grav
tekenpixel:          mov     ax, [si+2]
                     shr     ax, shift
                     mov     bx, 320
                     mul     bx
                     mov     dx, [si]
                     shr     dx, shift
                     add     ax, dx
                     mov     di, ax
                     cmp     byte ptr es:[di], 12
                     jne     nobounce
                     neg     word ptr [si+6]
                     sub     di, 640
nobounce:            mov     al, 9
                     stosb
                     add     si, 8
                     loop    particleloop
                     mov     dx, 3dah
                 l1: in      al, dx
                     and     al, 8
                     jnz     l1
                 l2: in      al, dx
                     and     al, 8
                     jz      l2
                     mov     ax, ds
                     push    vga
                     pop     es
                     push    vscreen
                     pop     ds
                     dec     cx
                     mov     si, di
                     rep     movsb
                     mov     ds, ax
                     in      al, 60h
                     cmp     al, 1
                     jne     mainloop
                     mov     ax, 3h
                     int     10h
                     mov     dx, offset crap
                     mov     ah, 9
                     int     21h
nieuweparticle:      imul    di
clip:                sub     ax, 15
                     cmp     ax, 54
                     ja      clip
                     sub     ax, 20
                     mov     word ptr [si], 60 shl shift
                     mov     word ptr [si+2], 100 shl shift
                     mov     [si+4], ax
                     mov     ax, cx
                     shr     ax, 2
                     neg     ax
                     mov     word ptr [si+6], ax
                     ret
crap db 'Crap...so what?    $'
particle db 8*(aantal+1) dup (?)
END START
