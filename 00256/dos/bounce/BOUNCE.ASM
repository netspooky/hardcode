.MODEL tiny
.486
.CODE
ORG 100h
BACK    equ 08000h
VSCREEN equ 09000h
VGA     equ 0a000h
AANTAL  equ 25
START:               mov     al, 13h
                     int     10h
                     mov     dx, 3c8h
                     mov     si, dx
                     xchg    ax, bx
                     inc     ax
                     out     dx, al
                     inc     dx
                     push    back
                     pop     es
                     xor     di, di
                     mov     bl, 200
genloop:             mov     cx, 320
                     mov     [si], di
                     mov     word ptr [si+2], cx
                     add     si, 4
                     mov     al, 0
                     out     dx, al
                     out     dx, al
                     mov     ax, bx
                     rep     stosb
                     shr     al, 2
                     out     dx, al
                     dec     bx
                     jnz     genloop
MAINLOOP:            mov      dx, 3dah
                l1:  in       al, dx
                     and      al, 8
                     jnz      l1
                l2:  in       al, dx
                     and      al, 8
                     jz       l2
                     mov   si, di
                     push  vga
                     pop   es
                     push  vscreen
                     pop   ds
                     dec   cx
                     rep   movsb
                     push  back
                     pop   ds
                     push  vscreen
                     pop   es
                     dec   cx
                     rep   movsb
                     push  cs
                     pop   ds
                     mov   cl, aantal
zoekxy:              fldpi
                     mov     ax, cx
                     shl     ax, 4
                     add     ax, bp
                     mov     bx, offset angle
                     mov     [bx], ax
                     fimul   word ptr [bx]
                     fidiv   [_128]
                     fsincos
                     fimul   word ptr [mullerx]
                     fistp   word ptr [x]
                     fimul   word ptr [mullery]
                     fistp   word ptr [y]
                     mov   ax, [y]
                     add   ax, 150
                     mov   dx, 320
                     mul   dx
                     add   ax, [x]
                     add   ax, 160
                     mov   si, offset ball
                     push   ax
                     mov    di, ax
                     mov   ax, (199 * 256) + 199
                     mov   dx, 317
                     stosw
                     add   di, dx
                     stosw
                     stosw
                     add   di, dx
                     stosw
                     pop   di
                     mov   bx, cx
                     shl   bx, 4
                     add   bx, offset zwaarde
                     mov   ax, [bx]
                     add   ax, [bx+2]
                     mov   [bx], ax
                     neg   ax
                     js    okki
                     neg   word ptr [bx+2]
okki:                add   di, ax
                     movsw
                     movsb
                     add   di, 316
                     push  cx
                     mov   cl, 3
bla:                 movsw
                     movsw
                     movsb
                     add   di, 315
                     loop  bla
                     pop   cx
                     inc   di
                     movsw
                     movsb
                     loop  zoekxy
                     inc   bp
                     in    al, 60h
                     cmp   al, 1
                     jne   MAINLOOP
                     mov   ax, 3h
                     int   10h
                     ret
mullerx dw 120
mullery dw 30
_128    dw aantal shl 3
ball    db 203,203,203,202,203,204,203,202,202,203,203,202,202,201,202,202,202,201,201,201,201
angle   dw ?
x       dw ?
y       dw ?
ORG 3c8h
zwaarde  db 80 dup (?)
END START
