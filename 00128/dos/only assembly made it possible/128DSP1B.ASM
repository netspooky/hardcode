;"Only assembly made it possible"
;
;Another fire effect...
;
;Of course made in a *real* hurry.
;Contact me for any reason : dosop@free.fr
;
;Assemble with NASM. 

org 100h
bits 16

[section .text]
start:
        mov al,0x13
        int 0x10

        mov dx,0x3c8
        xor al,al
        out dx,al
        inc dx
        xor cx,cx
jmp short pal_loop_red
;pal_loop_white:
;        mov byte[pal_loop_yellow+4],0xc7
pal_loop_yellow:
        mov byte[cod2chg+1],0xc3
pal_loop_red:
        mov ah,al
        out dx,al
        mov al,bl
        out dx,al
        mov al,bh
        out dx,al
        mov al,ah
cod2chg:inc al
        inc cl
        cmp cl,63
     jb pal_loop_red
        cmp cl,255      ;2*63
     jb pal_loop_yellow
;        cmp cl,255
;     jb pal_loop_white


fire:
        mov bx,64000-3*320
random_pixels_loop:
        in al,0x40
        add al,[rand_buffer+bx]
        mov [buffer+bx],al
        inc bx
        cmp bx,64000
    jnz random_pixels_loop

        mov si,buffer+320
        mov di,buffer
        mov cx,bx

fire_loop:
        mov al,[si-1]
        add al,[si+1]
        adc ah,0
        add al,[si-320]
        adc ah,0
        add al,[si+320]
        adc ah,0

        shr ax,2
     jz already_zero
        dec al
already_zero:
        inc si
        stosb
   loop fire_loop

        push es
        push word 0xa000
        pop es
        mov si,buffer
        xor di,di
        mov cx,bx
        rep movsb
        pop es

jmp short fire

;        in al,0x60
;        dec al
;    jnz fire
;
;        mov ax,0x3
;        int 0x10
;
;        int 0x20
;
rand_buffer:
buffer:

