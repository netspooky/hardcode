;===========================================================;
;                                                           ;
;     (C)opyright 2003 by "Blue Cobold"                     ;
;     http://www.Blue.Cobold.de.vu                          ;
;     BlueCobold@gmx.de                                     ;
;                                                           ;
;===========================================================;

.MODEL TINY

.386
.387

.CODE
org 100h

Start:

Help equ $

;; ================= Grafik =====================
    mov al, 13h

x   equ $

    int 10h

;; ================= Palette ====================
    mov dx, 3c8h
    mov ax, 192
    out dx, al
    inc dx
    mov cx, 64

@pal1:
      mov al, ch
      out dx, al
      out dx, al
      mov al, cl
      dec al
      out dx, al
      loop @pal1

      mov cl, 64
@pal2:
      mov al, 64
      sub al, cl
      out dx, al
      out dx, al
      mov al, ch
      out dx, al
      loop @pal2

;;================== Textur =====================

Tex   equ Offset RestSeg
Array equ Tex + 128*200

      mov di, 128*200
      @TEXTURE:
        mov cx, di
      	mov	bx,cx
	rcl	dh,cl
	mov	ah,dh

Amp   equ $+1

	sar	ah,3
	add	al,ah

	add	al,[bx+128+Tex]
	sub	al,[bx+130+Tex]
	sar	al,1
	mov	[bx+Tex],al
        dec di
        jnz @Texture

;;================== Array ======================

      mov cx, 256

Periode equ $-2

      mov di, Array
      add cx, cx
@Array:
        mov word ptr [Help], cx
        fldpi
        fimul word ptr [Help]
        fidiv word ptr [Periode]
        fsin
        fimul word ptr [Amp]
        frndint
        fistp word ptr [di]
        add di, 2
        dec cx
        jnz @Array


;;================== Main =======================

@MainLp:
        mov  dx, 3dah
    @Bildaufbau:
          in   al, dx
          test al, 8
          jnz  @Bildaufbau
    @Retrace:
          in   al, dx
          test al, 8
          jz   @Retrace

        push 0a000h
        pop es
        mov dx, 160
        mov di, 20*320

     @y_Loop:
          mov cx, 320

       @x_Loop:
           mov bx, cx
           mov ax, word ptr [x]
           sub bx, ax
           shl bx, 1
           and bx, 511
           shl bx, 1
           mov si, [bx+Array]
           shr si, 5
           add si, dx
           and si, 127
           shl si, 7

           mov bx, dx
           shl bx, 1
           add bx, dx
           shl ax, 2
           add bx, ax
           and bx, 511
           shl bx, 1
           mov ax, [bx+Array]
           shr ax, 6
           add ax, cx
           and ax, 127

           add si, ax
           add si, Tex
           movsb
           dec cx
           jnz @x_Loop

         dec dx
         jnz @y_Loop

        inc word ptr [x]
        in al, 60h
        dec al
        jnz @MainLp

      mov al, 3
      int 10h

      mov dx, OFFSET CR
      mov ah, 9
      int 21h

      mov ah, 4ch
      int 21h

CR    db 'Blue Cobold :: Sm-Blur$'

RestSeg:

END Start

