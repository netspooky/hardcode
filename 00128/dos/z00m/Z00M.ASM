;Animal's contribution to the #asm 128 byte compo.

box_width  equ 16
box_height equ 14  


;MACROS...
wait_vrt macro
        mov     dx,3dah
      wait_vrt1:
        in      al,dx
        test    al,8
        jz      wait_vrt1
      wait_vrt2:
        in      al,dx
        test    al,8
        jnz     wait_vrt2
        endm

clear_screen macro
        xor     di,di
        xor     ax,ax
        mov     ch,3fh 
        rep     stosd
        endm

code segment
assume cs:code,ds:code
org 100h
start:
.386
        mov     al,13h
        int     10h
        push    0a000h
        pop     es
        mov     bl,0ffh
mainloop:


        mov     dl,box_height
       height:
        mov     dh,box_width
       width_:
        call    plotpixel
        inc     ax
        dec     dh
        jnz     width_
        sub     al,box_width
        inc     cx
        dec     dx
        jnz     height

        wait_vrt
        clear_screen

        dec     bx
        jnz     blarg
        mov     bl,0ffh
        blarg:

        in      al,60h
        cmp     al,1
        jne     mainloop
        mov     al,3
        int     10h
        xor     ax,ax
        int     16h
        mov     dx,offset z00m
        mov     ah,9
        int     21h
        ret

plotpixel proc
        pusha
        xor     di,di
        shl     ax,8
        cwd
        idiv    bx       
        add     di,ax  
        add     di,160
        mov     ax,cx
        shl     ax,8
        cwd
        idiv    bx
        add     al,100
        mov     cx,ax
        shl     ax,8
        shl     cx,6
        add     ax,cx
        add     di,ax
        mov     ax,bx
        stosb
        popa
        ret
plotpixel endp

z00m db "z00m !$"

code ends
end start
