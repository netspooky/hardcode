;
; jane98.com
;  By skynxnex [LaC]
;
; 249 bytes of stars, stars and more stars. Just code to display stars
; in a 3d world (well, and a scrolly. The star part is around 130 bytes by
; itself).
;
; This is ment to be reassembled with NASM, version 0.94 or later.
;
; The command line I use is: nasm -ostars.com stars.asm
;
; NASM still defaults to bianry format.
;
; It won't work right if run in debug or TD.  Unless you set the regs
; to their "correct" values.
;
; Uncomment if you want to see how close it is to a full vert...
;
;%define debug
%define change_pal
%define include_scrolly
;
num_stars equ 080h+(4 << 8)
hi_val_stars equ 4
;
; The number of Z postions.
;
z_depth equ 256
;
; Random equ's...
;
x equ 2
y equ 4
z equ 0
SCROLLY_COLOR equ 230
;
SECTION .text
;
%macro vert 0
%ifdef debug
        mov dx,3c8h
        mov al,0
        out dx,al
        inc dx
        mov al,0
        out dx,al
        out dx,al
        out dx,al
%endif
;
; Not the full vert, function, but it works.

        mov dx,3dah
.v2
        in al,dx
        and al,8
        jz .v2
;
%ifdef debug
        mov dx,3c8h
        mov al,0
        out dx,al
        inc dx
        mov al,20
        out dx,al
        mov al,0
        out dx,al
        out dx,al
%endif
%endm
;
%ifdef include_scrolly
%macro do_scrolly 0
;do_scrolly:
        push es
        push ds
        pop es
        mov di,si
        inc si
        mov ch,5                ; CX = 8*320/2
        rep movsw
        pop es
;
        mov di,(480h+num_stars*6)+319
;
.draw_scrolly
;
        push word 0f000h
        pop fs
        mov si,0fa6eh
        mov cl,[bx]
        shl cx,3
        add si,cx
        mov cx,8
.draw_loop
        fs lodsb
        and al,[105h]
        mov byte [di],103
.background equ $-1
        jz .not_draw
        mov byte [di],SCROLLY_COLOR
.scrolly_color equ $-1
.not_draw
        add di,320
        loop .draw_loop
;
.kab
        add byte [.background],-4
.bg_dir equ $-1
        jns .ka
        neg byte [.bg_dir]
        jmp .kab
.ka
        ror byte [105h],1
        jnc .nt
        inc bx
        cmp byte [bx],0
        jnz .nt
        mov bx,text
.nt
draw_scrolly:
        mov di,140*320
        mov si,480h+num_stars*6
        mov ch,0ah                  ; CX = 8*320
.l1
        lodsb
        or al,al
        jz .l2
        stosb
        dec di
.l2
        inc di
        loop .l1
%endm
%endif
;
BITS 16
ORG 100h
start
;
; On start I assume: AX=0, and BP=91Ch. But, BP really should be
; the same number, or the PRNG will mess up.
;
; Set the video mode
;
        mov al,013h
        int 10h
;
        mov cx,num_stars
        mov di,cx
;
.ploop
%ifdef change_pal
        mov dx,3c8h
        mov al,cl
        out dx,al
        inc dx
        shr al,2
        out dx,al
        out dx,al
        out dx,al
%endif
;
; some really odd stuff, if I make the range for X and Y to be from -32000 to
; 32000 I can get away with out two imuls later on.
;
        call rand
        xor ah,ah
        call rand2
        call rand2
        stosw
;
        loop .ploop
;
; clear out the buffer for the scrolly
;
%ifdef include_scrolly
        mov ch,0ah                ; CX = 8*320
        xor ax,ax
        rep stosb

        mov bx,text
%endif
;
        push word 0a000h
        pop es
;
mainloop
;
        vert
;
        mov cx,num_stars
        mov si,cx
;
eds_l1
;
        call make_ofs
        xor ax,ax
        stosb                   ; Erase the old star
;
; move the star along Z
;
.d1
        dec byte [si+z]         ; Z
        jz .d1
        call make_ofs
        lodsw
        jnc .d2
%ifdef change_pal
        not ax
%else
        mov al,2
%endif
        stosb
.d2
;
        lodsw
        lodsw                   ; move to the next star
;
        loop eds_l1
;
%ifdef include_scrolly
        do_scrolly
%endif
;
        in al,60h
        das
%ifdef include_scrolly
        jc near mainloop
%else
        jc mainloop
%endif
;
        mov ax,3h
        int 10h
;
rand2:
        stosw
rand:
;
; This PRNG sucks, don't use it.
;
        imul ax,bp,40891
        xchg bp,ax
        ret
;
;

;
; Returns with the DI as the offset for the current star in the screen.
; If the carry flag is clear the star is off the screen.
;
; Okay, this is not the full way to project a 3D point to the screen.
; There should be a few IMULs mixed in. But, I found that I didn't need them.
;
make_ofs:
        mov ax,[si+x]
        cwd
        idiv word [si+z]
        add ax,160
        cmp ax,319
        ja .nodraw
        xchg di,ax
;
        mov ax,[si+y]
        cwd
        idiv word [si+z]
        add ax,100
        cmp ax,199
        ja .nodraw
        imul ax,320
        add di,ax
        stc
.nodraw                         ; ja jumps on zf=0 *and* cf=0...
        ret
;
%ifdef include_scrolly
text db "Jane98! ",0
%endif
