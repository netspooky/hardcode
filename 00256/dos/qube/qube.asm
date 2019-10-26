; Qube 256b by dila
; October 2014

[org 100h]

mov al, 13h
int 10h

fldz
fstp dword [bx+4]

main:

  xor ax, ax
  xor di, di
  mov cx, 32000
  push 09000h
  pop es
  rep stosw

  fld dword [bx+4]
  fadd dword [speed]
  fstp dword [bx+4]

  mov si, verts
  prims:

    xor dx, dx
    render:

      fninit ; reset fpu stack

      mov ax, word [si]
      mov cl, 3
      vertgen:

        push cx
        mov cl, 2
        unpack:
          xor di, di
          mov di, ax
          and di, 1
          shl di, 1
          dec di ; vert.{x,y,z} * 2 - 1
          mov word [bx], di
          fild word [bx]
          shr ax, 1
        loop unpack
        pop cx

        fsub st1
        mov word [bx], dx
        fild word [bx]
        fmulp
        mov word [bx], 255
        fild word [bx]
        fdivp
        faddp

      loop vertgen

      mov cx, 3
      rotate:

        ; z | y | x

        fld dword [bx+4]
        mov word [bx], cx
        fild word [bx]
        fmulp
        fsincos

        ; cos | sin | z | y | x

        fld st4 ; x | cos | sin | z | y | x
        fmul st2 ; x*sin | cos | sin | z | y | x
        fld st3 ; z | x*sin | cos | sin | z | y | x
        fmul st2 ; z*cos | x*sin | cos | sin | z | y | x
        fsubrp st1 ; z' | cos | sin | z | y | x
        fld st4 ; y | z' | cos | sin | z | y | x
        fld st6 ; x | y | z' | cos | sin | z | y | x
        fmul st3 ; x*cos | y | z' | cos | sin | z | y | x
        ffree st7 ; x*cos | y | z' | cos | sin | z | y
        fld st5 ; z | x*cos | y | z' | cos | sin | z | y
        fmul st5 ; z*sin | x*cos | y | z' | cos | sin | z | y
        faddp st1 ; x' | y | z' | cos | sin | z | y

        fxch st1 ; rotate another axis next iteration

        ffree st7 ; required for XP compatibility
        ffree st6
        ffree st5
        ffree st4
        ffree st3

      loop rotate

      fld1
      fadd st0 ; generate 2.0 constant
      fadd st3
      fadd st0 ; z' = (z + 2) * 2

      ; z' | x | y | z

      mov word [bx], 100
      fild word [bx]
      fld st3
      fdiv st2
      fmul st1
      fadd st1
      fistp word [bx]
      mov di, word [bx]
      imul di, 320

      ; 100 | z' | x | y | z

      mov word [bx], 160
      fild word [bx]
      fld st3
      fdiv st3
      fmul st2
      faddp st1
      fistp word [bx]
      add di, word [bx]

      fld st1
      fadd st0
      fist word [bx]
      mov al, 32
      sub al, byte [bx]
      stosb

    inc dl
    jnz render

  inc si
  cmp si, verts+12
  jne prims

  push ds
  push 09000h
  pop ds
  push 0a000h
  pop es
  xor di, di
  xor si, si
  mov cx, 32000
  rep movsw
  pop ds

mov ah,01h
int 16h
jz main
int 20h

speed dd 0.01
verts db 10h, 31h, 23h, 2h, 1Ch, 3Dh, 2Fh, 0Eh, 4h, 34h, 37h, 7h
