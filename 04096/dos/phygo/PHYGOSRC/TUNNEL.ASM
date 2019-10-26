calc_tunnel_table:	; depends on calcsqrt & recursepoly

pusha

push ds
push es

mov ax,cs       ; temp = videobuf
add ah,SEG_VIDEO
mov es,ax

push cs  ; <-- ei vaikuta
pop ds   ; <--

xor di,di ; ??

mov cx,256              ; draws a filled circle divided in 256 sectors
mov dx,0xfe77
mov bx,dx
mov si,sin_table

.l0:    mov dx,bp               ; edge2=prev sin&cos
        mov bp,bx

        lodsw
        mov bl,ah               ; edge0=next sin&cos
        mov bh,[si+126+1]
        add bx,0x8080

        pusha
        mov ah,cl  ;cols
        mov al,cl
        mov di,1
        push bx
        push dx
        push word 0x8080         ; edge1=origo
        call recursepoly
        popa

        loop .l0

push es         ; noinpäin?
pop ds

mov ax,cs       ; final tunneltab
add ah,SEG_TUNNEL
mov es,ax    ; -> copy the circle into the finaltab area
             ;    2x zoomed at 128,128
             ;    write the point<->center distance to every other byte

mov si,0x4040

;       cx=0 already

.l1:    mov al,cl       ; distance
        sub al,128
        imul al
        mov bx,ax

        mov al,ch
        sub al,128
        imul al
        add bx,ax

        je .c0
        js .c0
           call sqrt
    .c0:mov ax,bp

        movsb           ; distance
        stosb           ; angle

        dec ch
        je .c1
        dec ch
        jne .l1
    .c1:
        add si,128
        test cl,1
        je .o1
          sub si,256
    .o1:loop .l1

        mov ax,cs       ; clr da tunnel texture segm
        add ah,SEG_TUNTEX
        mov es,ax
        xor ax,ax
        mov cx,32768
        rep stosw

pop es
pop ds
popa
ret

drawtunnel:
        pusha
        push ds
        push es

        mov ax,cs
        add ah,SEG_BITMAP
        mov ds,ax       ; ds = bitmap   cs+$3000
        add ah,SEG_TUNTEX-SEG_BITMAP
        mov es,ax       ; es = tunmap   cs+$4000

xor di,di
mov cx,256*3
xor ax,ax
rep stosw

        mov si,0
        .offset equ $-2

        mov bx,0x7fff     ; pHuRst addition

        mov bp,1          ; tunnel openness 1..210 230?
        .open equ $-2

.l0:    mov ax,bx
        sar ax,5
        sub bx,ax

        push si
        push bx
          add bx,bx
          mov bl,0
          add si,bx
          cmp si,0xfeff
          jc .o2           ; prevent movsw when si==0xffff
            sub si,0xff00  ; compatibility suxxxx!!!!!!
          .o2:
          mov cx,128
          rep movsw
        pop bx
        pop si
        dec bp
        jne .l0

        inc ch  ;cx=256
        mov ax,0xc0c0   ; hyperborder (set color?)
        rep stosw
        
	mov cx,248*256	; empty
	sub cx,di
        jc .kukko
	shr cx,1
        xor ax,ax
        rep stosw
        .kukko:

        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

o0:     push es         ; ds = tunmap cs+3000
        pop ds

        mov ax,cs       ; es = output cs+1000
        add ah,SEG_VIDEO
        mov es,ax
        add ah,SEG_TUNNEL-SEG_VIDEO  ; fs = tuntab cs+2000
        mov fs,ax

        xor bx,bx
        mov di,65534

.draw:  movsw
        mov esi,[fs:bx]
        movsw
        shr esi,16
        add bx,4
        jne .draw

.c0:    pop es
        pop ds
        popa
        ret

tunnellimit: db 245
