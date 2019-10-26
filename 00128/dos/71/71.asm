; by Zen
;email zen333@rambler.ru
;Vladivostok
;Tasm 3.1
; look at index of
; http://fan333.chat.ru
; root folder
; Hello to T-rex and all Russian demoscene
; and this one is remake to my old demo 71 and now it s
        .286
        org 100h
        jumps
        model tiny
        codeseg
        startupcode
start:
        les bp,[bx]
        push es
        pop ds
        mov      al,13h
        int      10h
pal1:           mov     dx, 3C9h
                mov     al,cl
                test    cl,64
                jz short pal2
                neg al
pal2:           out dx,al
                test cl,128
                jz short pal3
                mov al,ah
pal3:           out dx,al
                out dx,al
                loop    pal1
cicl:
        add      si,cx
        lodsb
        or      al,al
        jz   short  sdv
        inc      al
        mov      [si],al
        mov      [si-2],al
        mov      [si-321],al
sdv:    loop cicl
       mov   di,320*190+160
       mov   al,1
       stosb
       in    al,60h
       dec   al
       jnz   short cicl
zzzex:  mov al,3
        int 10h
         retn
;pouet db 'Especialy for pouet.net',10,13
;      db 'Respect to T-Rex$'
ends
end
