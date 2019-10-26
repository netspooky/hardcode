[BITS 16]
[ORG 0x300]

start:
        mov ax, 0x13
        int 10h

        xor ax, ax
        mov di, 0x500
        mov dx, di


; setup palette so
;    0-127 = black
;  128-255 = black->red gradiant

        xor ax, ax
        xor bx, bx
        xor dx, dx
ps1:
        mov [di], al
        inc di
        mov [di], bl
        inc di
        mov [di], dl
        inc di

        inc dx
        ;inc dx
        cmp di, 0x067d   ; 0x0500 + 0x007f * 3
        jb ps1


ps2:
        mov [di], al
        inc di
        mov [di], bl
        inc di
        mov [di], dl
        inc di

        inc bx
        ;inc bx
;        dec bx
        cmp di, 0x07fd   ; 0x0500 + 0x00ff * 3
        jb ps2

        xor bx, bx
        mov cx, 0xff
        mov ax, 0x1012
        mov dx, 0x500
        int 0x10

        push word 0xa000
        pop es

        mov cx, 0x60
        mov  bx, SINTAB
        mov  si, 395
SINGEN: mov  [bx], ch
        add  cx, si
        mov  ax, 40
        imul cx
        sub  si, dx
        inc  bl
        jnz  SINGEN

main_loop:

; wait vert retrace
        mov dx,0x03da
vt1:    in  al,dx;
        and al,0x08;
        jnz vt1;
vt2:    in  al,dx;
        and al,0x08;
        jz  vt2;


; start plasma

        mov eax, [p1]
        mov [t1], eax

        xor bx, bx
        xor di, di
ploop:

        mov si, t1-1
        xor ax, ax
acos:
        inc si
        mov bl, [si]
        add ax, [SINTAB+bx]

        cmp si, t4
        jb  acos


        ;sal ax, 1
        mov [es:di], al
        inc di

        mov bl, [t2]
        mov al, [SINTAB+bx]
        sar al, 3
        add byte [si], al;3
        inc byte [t3]

        mov ax, di
        xor dx, dx
        div word [row]
        cmp dx, 0
        jnz ploop

        mov ax, [p3]
        mov [t3], ax

        inc byte[t2]
        add byte[t1], 4

        cmp di, 0xfa00
        jb  ploop

        dec byte[p1]
        ;mov al, [t1]
        ;shr al, 6
        sub byte[p2], 1

        inc byte[p3]
        ;mov al, [t3]
        ;shr al, 5
        add byte[p4], 2;al

; end plasma

        mov ah, 1     ;Check for keypress
        int 16h
        jz main_loop

done:
;        xor ax, ax
;        int 0x16

        mov ax, 0x03
        int 10h

        ret




;Roses are #FF0000
;Violets are #0000FF
;chown -R ~/base you


;-==-===-==-=--=---=--=-==-===-==-=--=---=--=-==-===-==-=--=---=--=-

row  dw 0x0140  ; 320


p1 equ 0x0800
p2 equ 0x0801
p3 equ 0x0802
p4 equ 0x0803

t1 equ 0x0804
t2 equ 0x0805
t3 equ 0x0806
t4 equ 0x0807

SINTAB equ 0x1000

;-==-===-==-=--=---=--=-==-===-==-=--=---=--=-==-===-==-=--=---=--=-
;
; mov: mov bx, sp / push word 0xB813 / push byte 0x00 / push word 0xCD10 / jmp bx
;
; Ong-Bak
;
;
;
;
;
;
;
;
;EFNet#asm[2004/8/11-23:14:02] <baze> 
;
;<baze>         mov  bx,SINTAB
;<baze>         mov  si,395
;<baze> SINGEN: mov  [bx],ch
;<baze>         add  cx,si
;<baze>         mov  ax,40
;<baze>         imul cx
;<baze>         sub  si,dx
;<baze>         inc  bl
;<baze>         jnz SINGEN
;<baze> this should generate sinus-like curve with amplitude ~64 and period 256
;<baze> but, SINTAB must be a multiple of 256
;<baze> basically it's a harmonic oscillator equation in fixed point math
;<baze> you can even approximate cosinus with parabola
;<baze> like 1 - (x/2pi)^2
;<baze> and then flip and mirror it
;
