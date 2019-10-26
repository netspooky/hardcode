;===========================================================;
;                                                           ;
;     (C)opyright 2002 by "Blue Cobold"                     ;
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
      mov bp, Offset RestSeg        ;; cs als Frame-Buffer
      mov al, 13h
      int 10h

    mov dx, 3c8h
    xor ax, ax
    out dx, al
    inc dx
    mov cl, 128

@pal:
   cmp cl, 64
   jg @_not

   mov al, cl
   out dx, al
   out dx, al
   out dx, al
   jmp @_yes

@_not:
   mov al, ah
   out dx, al
   out dx, al
   out dx, al

@_yes:
   inc ah
   loop @pal

@MainLp:
        push cs                     ;; Frame-Buffer laden
        pop es
        mov di, bp
        mov cx, 24000
        xor ax, ax
        rep stosw

        mov si, 319

    @x_Loop:
          mov Helper, si
          fild Movement
          fidiv Fact
          fild Helper
          fidiv Fact3
          fadd
          fsin
          fimul Amplify
          fild Helper
          fidiv Amp2
          fsin
          fmul
          fiadd Amp5
          frndint
          fistp Helper

          mov al, 100
          sub ax, Helper

          mov cx, 320
          mul cx
          add ax, si
          mov cx, Helper
          mov di, ax
          shl cx, 1
          add di, bp
          mov al, 8
          mov bx, cx

      @y_Loop:
            mov ax, bx
            sub ax, cx
            mov Helper2, ax
            fild Helper2
            fild Helper
            fldpi
            fdiv
            fdiv
            fsin
            fimul Amp5
            fiadd Amp5
            frndint
            fistp Helper2
            mov ax, Helper2

            mov es:[di], al
            add di, 320
            loop @y_Loop

          inc Movement
          dec si
          jnz @x_Loop

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
          push cs
          pop ds
          xor di, di
          mov si, bp
          mov cx, 24000
          rep movsw

        in al, 60h     ;; ah is zero, because of the y_Loop!
        dec ax
        jnz @MainLp

      mov ah, 4ch
      int 21h

Fact      dw    53
Fact3     dw    35
Amplify   dw    20
Amp2      dw    16
Amp5      dw    30
bump      dw    13
Helper    dw    ?
Helper2   dw    ?
Movement  dd    ?

RestSeg:

END Start

