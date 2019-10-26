bols equ 252
bolss equ bols+2

numbols equ 4

; remove the X coord

org 100h
        mov al,13h
        int 10h

; useless code forgotten from the palete initialization that I leave here because it happens to produce proper random values for the data as code balls.
; Changing anything and stuck balls might happen. I could have edited with db but fuck it.
        mov dx,3c8h
        xor al,al
        out dx,al
        inc dx
; end of this useless code

        push word 08000h
        pop es
        xor di,di
xorgen:
        xor ax,di
        and ax,20
        add ax,160
        stosb
        or di,di
        jnz xorgen

        mov di,bols
        xor ax,ax
        mov bx,12
datacode:
        mov [cs:di],ax
        add di,3
        dec bx
        jnz datacode


;        xor si,si
main:
        mov bp,bolss ;ballz

        mov si,[cs:bp]

        push word 08000h
        pop ds
        push word 09000h
        pop es
        xor di,di
        mov cx,16000
        rep movsd


moreballz:

        mov ax,[cs:bp]
        mov bx,[cs:bp+2]

        mov dx,[cs:bp+4]

        inc ax
        cmp ax,320
        jc resetX
        xor ax,ax
resetX:


        add bx,dx
        cmp bx,168 * 256
;        cmp bx,255*256
        jc nobounce
        neg dx
        jmp bounced
nobounce:
        add dx,8
bounced:
        mov [cs:bp+4],dx

        mov [cs:bp],ax
        mov [cs:bp+2],bx

        shr bx,8

        mov di,bx
        shl di,8
        shl bx,6
        add di,bx
        add di,ax

        ;call DrawSphere
        ;DrawSphere:
        mov bl,32
        pixY:
                mov cl,32
                pixX:
                        mov al,cl
                        sub al,16
                        mov dl,al
                        sub dl,16

                        imul al
                        neg ax          ; -y*y
                        mov si,ax

                        mov al,bl
                        sub al,16
                        mov dh,al
                        imul al
                        neg ax          ; -x*x

                        add ax,si       ; -x*x -y*y
                        dec ax  ; that singularity in the center (from 0 to -1, so 256+0 is now 256+-1)
                        inc ah  ; this is like +256 (256 - x*x - y*y)

                        or ah,ah
                        jnz noBlit

                        mov bh,al
                        shr bh,2
                        inc bh

                        mov al,dl
                        idiv bh

                        mov si,di
                        add si,ax

                        mov al,[si]
;                        add al,128
                        add al,146
add ax,bp

                        stosb
                        jmp fuckblit
                noBlit:
                        inc di
                        fuckblit:

                loop pixX
                add di,320-32
        dec bl
        jnz pixY


        add bp,6
        cmp bp,bolss+numbols * 6
        jnz moreballz


        mov dx,3dah
Vsync:
        in al,dx
        and al,8
        jz Vsync

        xor si,si
        xor di,di
        push es
        pop ds
        push word 0a000h
        pop es
        mov cx,16000
        rep movsd


        in al,60h
        dec al
        jnz main

        mov ax,03h
        int 10h
ret
