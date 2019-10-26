;bits 16
;org 0x100
;
;cld
;
;pillu:
;        call initadlib
;
;.l9:    call player
;        mov dx,0x3da
;
;        mov cx,8
;.l0:    in al,dx
;        test al,8
;        jne .l0
;.l1:    in al,dx
;        test al,8
;        je .l1
;        loop .l0
;
;        in al,0x60
;        cbw
;        dec ax
;        jne .l9
;
initadlib:

        mov ax,244              ; clear regs
        mov di,adlib
    .l0:call di
        dec ax
        jne .l0

        mov ax,0x2001           ; enable waveforms
        call di
        mov si,adlibstring      ; init with instrdata
        mov cx,8+8
    .l1:lodsw                   ; 3 chns each
        call di
        inc ax
        call di
        inc ax
        call di
        loop .l1

        ret

player:

        pusha

;        xor ax,ax
        xor bx,bx
;        xor cx,cx
;        xor dx,dx
;       xor si,si
;        xor di,di
;        xor bp,bp

.hou:   mov si,patt_temp+128
	.rowptr equ $-2

        cmp si,patt_temp+128
        jne .c0

           ; calc next pattern

           mov si,patt_temp
           mov di,si
           stosw

         mov edx,0x120b100d  ; F<-A#0<-D#<-C
         .baseline equ $-4

            mov cx,4
        .l1:
            mov bx,7
        .l0:
           mov al,[melody0+bx]
	   .melody equ $-2
           mov ah,[bass0+bx]
           .bass equ $-2

       .k2:push ax
           and al,0xf
           je .k0
           add al,dl
       .k0:
           and ah,0xf
           je .k1
           add ah,dl
       .k1:
           stosw
           pop ax
           shr ax,4
           xor cl,128
           js .k2

           dec bx
           jns .l0

           shr edx,8
	   loop .l1

;        mov dl,1
;        .effect equ $-1
;
;        test dl,1
;        je .e1
;           sub di,2+16*2
;           mov ax,16
;       .l9:stosb
;           inc di
;           dec ax
;           jne .l9
;           xor byte [.effect],1

.e1:

.c0:    mov cx,(4*4*256)+0xa3+3

play_note:


	lodsb			; read note
	mov bl,al
        test bl,bl              ; ==0: none
        je .c1

        add bl,0                ; add n halftones
	.offset equ $-1

        mov al,-3               ; chn=row mod 3
        .subch equ $-1
        inc al
        jne .k7
            mov al,-3
        .k7:
        mov [.subch],al

        add al,cl               ; chn += basechn
        mov dl,ch               ; oct += baseoct

	;;;;;;;;;;;;

    .l0:cmp bl,12
        jc .c0
                sub bl,12       ; note overflow -> inc oct
                add dl,4
                jmp .l0
        .c0:

        mov ah,[bx+freqs]       ; freq
;        or [render_frame.flasher],ah
        call adlib

        add al,0x10             ; key off
        mov ah,dl
        call adlib

        or ah,0x20              ; key on
        call adlib

	;;;;;;;;;;;;
	
	.c1:

;;;;;;;;;;;;

        cmp cl,0xa0+3           ; done drums?
        je .c2
            mov cx,(3*4*256)+0xa0+3
            jmp play_note
   .c2: 

   mov word [player.rowptr],si
   popa
   ret

adlib:          ; ah=data, al=addr
pusha

 mov dx,0x388

 out dx,al
   mov cx,6+1
   t1:in al,dx
   loop t1

 mov al,ah

 inc dx
  out dx,al
 dec dx
   mov cl,35+2
   t2:in al,dx
   loop t2
popa
ret

freqs:  db 0x2ae/8
        db 0x16b/4
        db 0x181/4
        db 0x198/4
        db 0x1b0/4
        db 0x1ca/4
        db 0x1e5/4
        db 0x202/4
        db 0x220/4
        db 0x241/4
        db 0x263/4
        db 0x287/4

adlibstring:

dw 0x2020,0xa023          ; drums
dw 0xf860,0xf363  ; ad
dw 0x4a80,0x3283  ; sr
dw 0x01e3  ;01
dw 0x06c0        ; fdbak

dw 0x0128,0xa42b          ; melody   c4
dw 0xd568,0x7c6b  ; ad
dw 0x8e88,0x5a8b  ; sr
dw 0x03e8
dw 0x08c3

;dw 0x006b   ; ?

; 0  none
; 1  c
; 2  c#
; 3  d
; 4  d#
; 5  e
; 6  f
; 7  f#
; 8  g
; 9  g#
; a  a
; b  a#
; c  b
; d  c
; e  c#
; f  d
; 10 d#
; 11 e
; 12 f
; 13 f#
; 14 g
; 15 g#
; 16 a
; 17 a#
; 18 b

melody0: db 0,0,0,0,0,0,0,0
melody1: db 0x08,0x04,0x14,0x80,0x41,0x08,0x14,0x01
melody2: db 0x84,0x8d,0x8d,0x01,0x84,0x8d,0x8d,0xd1
melody3: db 0x14,0x8d,0x10,0x00,0x00,0x00,0x00,0x01

bass1:   db 0x01,0x01,0x00,0x0d,0x00,0x01,0x00,0x0d
bass0:   db 0x1d,0x01,0x0d,0x0d,0x01,0x0d,0x01,0x0d

;patt_temp: db 64*2 dup 0

