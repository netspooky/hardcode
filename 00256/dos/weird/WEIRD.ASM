.MODEL tiny
.486
.CODE
ORG 100h
PLASM1 equ 09000h
PLASM2 equ 08000h
TEX    equ 07000h
START:               jmp      pietjeprecies
                     db 'aardbei',1ah
pietjeprecies:       mov      al, 13h
                     int      10h
                     push     ds
                     mov      dx, 3c8h
                     out      dx, al
                     inc      dx
                     mov      di, offset sintab
calcsin:             fldpi
                     fimul    [angle]
                     fidiv    [_128]
                     fcos
                     fimul    [muller]
                     fistp word ptr [di]
                     mov   al, [di]
                     add   al, 128
                     shr   al, 2
                     out   dx, al
                     out   dx, al
                     out   dx, al
                     inc   di
                     dec   [angle]
                     jnz   calcsin
                     mov      ax, TEX
                     mov      es, ax
texgenloop:          mov      al, cl
                     add      al, ch
                     shr      ax, 2
                     stosb
                     loop     texgenloop
MAINLOOP:            pop      ds
                     push     ds
                     add      dword ptr [t1], 01020301h
                     mov      dx, 3dah
                l1:  in       al, dx
                     and      al, 8
                     jnz      l1
                l2:  in       al, dx
                     and      al, 8
                     jz       l2
                     lea      bx, sintab
                     mov      al, [t2]
                     xlat
                     mov      [t5], al
                     mov      al, [t1]
                     xlat
                     mov      [t4], al
                     mov      ax, PLASM1
                     mov      es, ax
                     xor      di, di
                     mov      dx, 200
plasm1vert:          mov      cx, 320
plasm1hor:           mov      al, cl
                     add      al, [t1]
                     add      al, [t3]
                     xlat
                     mov      ah, al
                     mov      al, dl
                     add      al, [t2]
                     xlat
                     add      al, ah
                     xlat
                     stosb
                     loop     plasm1hor
                     dec      dx
                     jnz      plasm1vert
                     mov      ax, PLASM2
                     mov      es, ax
                     xor      di, di
                     mov      dl, 200
plasm2vert:          mov      cx, 320
plasm2hor:           mov      al, cl
                     add      al, [t5]
                     xlat
                     mov      ah, al
                     mov      al, dl
                     add      al, [t4]
                     xlat
                     add      al, ah
                     add      al, [t1]
                     xlat
                     stosb
                     loop     plasm2hor
                     dec      dx
                     jnz      plasm2vert
                     mov      ax, 0a000h
                     mov      es, ax
                     sub      ah, 10h
                     mov      fs, ax
                     sub      ah, 10h
                     mov      gs, ax
                     sub      ah, 10h
                     mov      ds, ax
                     xor      di, di
                     dec      cx
wobbler:             mov      bl, fs:[di]
                     mov      bh, gs:[di]
                     mov      al, bl
                     add      al, bh
                     stosb
                     loop     wobbler
                     in       al, 60h
                     cmp      al, 1
                     jne      MAINLOOP
                     mov      ax, 3h
                     int      10h
                     int      20h
muller dw 127
_128   dw 128
angle  dw 256
sintab db 256 dup (?)
t1  db ?
t2  db ?
t3  db ?
t4  db ?
t5  db ?
org 1ffh
db 1
END START
