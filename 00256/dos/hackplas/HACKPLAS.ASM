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
x    equ $+2

;; ================= Grafik =====================
    mov al, 13h
    int 10h

;; ================= Palette ====================
    mov dx, 3c8h
    mov ax, 1
    out dx, al
    inc dx
    mov cl, 33
    mov bh, 20

@pal1:
      mov al, bh
      out dx, al
      mov al, 64
      sub al, cl
      out dx, al
      out dx, al
      inc bh
      loop @pal1

      mov cl, 33
@pal2:
      mov al, cl
      out dx, al
      mov al, cl
      add al, 30
      out dx, al
      out dx, al
;      dec bl
      loop @pal2

;;================== Arrays =====================

SinArray     equ    Offset RestSeg  + 320*160
AbsArray     equ    SinArray        + 2*512

      mov si, SinArray
      mov cx, 512

  @calc:
        mov word ptr [Help], cx
        fild word ptr [Help]
        fldpi
        fmul
        fidiv word ptr [Freq]
        fsin
        fimul word ptr [Freq]
        fimul word ptr [Amp]
        frndint
        fist word ptr [si]
        fabs
        fistp word ptr [si+2*512]
        add si, 2
        loop @calc

;;================== Main =======================

@MainLp:

      push 0a000h
      pop es
      mov word ptr [x], 160
Amp     equ $-2
      mov di, 20*320
      mov si, AbsArray

  @y_Loop:
        mov cx, 320
    @x_Loop:
          mov si, word ptr [x]
          shl si, 2
          sub si, cx
          mov bx, bp
          sub si, bx
          shl bx, 1
          sub si, bx
          and si, 511
          shl si, 1
          mov ax, [si+SinArray]
          cwd
          mov bx, 256

Freq      equ $-2

          idiv bx
          add ax, cx
          add ax, cx
          add ax, bp
          mov si, ax
          shl si, 1
          and si, 511
          mov ax, [si+AbsArray]
          push ax
          mov si, bp
          shl si, 1
          sub si, cx
          shl si, 1
          add si, word ptr [x]
          and si, 511
          shl si, 1
          mov ax, [si+SinArray]
          cwd
          mov bx, 256
          idiv bx
          add ax, bp
          mov si, word ptr [x]
          shl si, 1
          add si, ax
          and si, 511
          shl si, 1
          mov bx, [si+AbsArray]
          pop ax
          add ax, bx

          shr ax, 10
          inc ax
          stosb
          loop @x_Loop
        dec word ptr [x]
        cmp word ptr [x], 0
        jne @y_Loop

        dec bp

        in al, 60h
        dec al          ;; ah ist sicher 0 ... siehe oben
        jnz @MainLp

      mov ah, 4ch
      int 21h

RestSeg:

END Start

