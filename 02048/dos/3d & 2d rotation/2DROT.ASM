
;
; 2d Rotation, Coded by Ash [NLB/BD]
; Allmost no comments.. I'm sorry :(
;

p386
ideal

segment code
assume cs:code
org 100h

start:
                mov     ax,13h
                int     10h
                push    0a000h
                pop     es

mainloop:       call    docordz                         ; mainloop
                call    keyc
                call    vwait
                call    killthem
                jmp     mainloop

outnow:         mov     ax,3                            ; the end
                int     10h
                mov     ax,4c00h
                int     21h

docordz:        add     [angle],2
                and     [angle],255
                xor     bp,bp

                mov     si,[angle]                      ; get sin(a) & cos(a)
                movsx   ax,[sincos+si]
                mov     [sinval],ax
                add     si,64
                and     si,255
                movsx   ax,[sincos+si]
                mov     [cosval],ax

dumpnow:        mov     ax,[cordz+bp]                   ; x
                imul    [cosval]
                mov     di,ax
                mov     ax,[cordz+bp+2]                 ; y
                imul    [sinval]                        ; sin + angle
                sub     di,ax
                sar     di,7
                add     di,160
                mov     bx,di

                mov     ax,[cordz+bp]                   ; x
                imul    [sinval]
                mov     di,ax
                mov     ax,[cordz+bp+2]                 ; y
                imul    [cosval]
                add     di,ax
                sar     di,7
                add     di,100

                mov     ax,320
                imul    di
                add     ax,bx

                mov     di,ax
                mov     [deltable+bp],di
                mov     [byte es:di],15

                add     bp,4
                cmp     bp,points*4
                jne     dumpnow
                ret

killthem:       xor     bp,bp
		mov	cx,points
killem:         mov     di,[deltable+bp]
                mov     [byte es:di],0
                add     bp,4
                loop    killem
                ret

vwait:          mov     dx,3dah                         ; vertical retrace
                in      al,dx
                test    al,8
                jne     $-3
                in      al,dx
                test    al,8
                je      $-3
                ret

keyc:           in      al,60h                          ; last key scan
                cmp     al,1
                je      outnow
                ret


label           cordz word
                b = -50
                rept 12
                a = -55
                rept 12
                dw a,b
                a = a + 10
                endm
                b = b + 10
                endm


angle           dw 0
cosval          dw ?
sinval          dw ?

points          equ 12*12

include         "sincos.db"

deltable        dw points*4 dup (?)

ends code
end start

