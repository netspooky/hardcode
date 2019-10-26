; Lightbox 512b for MS-DOS
; October 2014

[org 100h]

mov ax, 13h
int 10h

xor cx, cx
loop:
  mov dx, 0x3c8
  mov al, cl
  out dx, al
  inc dx
  shr al, 2
  out dx, al
  out dx, al
  out dx, al
dec cl
jnz loop

push 0a000h
pop es

sub sp, 48

render:

  mov bp, sp
  fld dword [fval]
  fadd dword [finc]
  fst dword [fval]
  fsincos
  fst dword [bp+4]
  fst dword [bp+20]
  fstp dword [bp+44]
  fst dword [bp+12]
  fst dword [bp+28]
  fstp dword [bp+36]

  xor cx, cx
  yloop:

    xor dx, dx
    xloop:

      mov bp, sp

      mov word [temp], cx
      fild word [temp]
      fadd st0
      fild word [height]
      fdivr st1
      fld1
      fsubrp
      fst dword [bp+16]
      fstp dword [bp+32]

      mov word [temp], dx
      fild word [temp]
      fadd st0
      fild word [width]
      fdivr st1
      fld1
      fsubp
      fst dword [bp]

      fmul dword [bp+12]
      fld dword [half]
      fmul dword [bp+4]
      faddp
      fst dword [bp+40]
      fchs
      fstp dword [bp+24]

      fld dword [half]
      fchs
      fstp dword [bp+8]

      fild word [width]
      fmul st0
      fstp dword [t]

      fninit
      fld dword [ten]

      xor si, si
      outer:
        mov bp, sp
        xor di, di
        inner:

          fld dword [bp] ; a | 10
          fmul dword [bp+4] ; a*b | 10
          fld dword [bp+8] ; c | a*b | 10
          fmul dword [bp+12] ; c*d | a*b | 10
          faddp ; c*d+a*b | 10
          add bp, 16

          fdivr st1
          fstp dword [tx]
          cmp dword [tx], 0
          jge first
            fld dword [t]
            fstp dword [tx]
          first:
          mov eax, dword [tx]
          cmp eax, dword [t]
          jge second
            mov dword [t], eax
          second:

        inc di
        cmp di, 3
        jne inner

        fchs

      inc si
      cmp si, 2
      jne outer

      fld dword [t]
      fdiv dword [ten]
      fld st0
      fmul st0
      fmulp st1
      fld1
      faddp
      fld1
      fdivrp st1
      fstp dword [tx]

      fninit
      fild word [eight]

      mov bp, sp
      xor di, di
      lights:
        mov word [temp], di
        fild word [temp]
        fldpi
        fadd st0
        fmulp st1
        mov word [temp], 12
        fild word [temp]
        fdivp st1
        fld dword [fval]
        fchs
        fadd st0
        fadd st0
        faddp st1
        fsincos ; cos | sin | s

        fld dword [bp] ; x | cos | sin | s
        fmul dword [t]
        fld st2 ; sin | x | cos | sin | s
        fmul st4
        fsubp st1 ; sin-x | cos | sin | s
        fmul st0

        fld dword [bp+16] ; y | sin-x | cos | sin | s
        fmul dword [t]
        fld st2 ; cos | y | sin-x | cos | sin | s
        fmul st5
        fsubp st1 ; cos-y | sin-x | cos | sin | s
        fmul st0
        faddp st1 ; cos+sin | cos | sin | s

        fld dword [bp+40] ; z | cos+sin | cos | sin | s
        fdiv dword [half]
        fmul dword [t]
        fsub st4 ; z-s | cos+sin | cos | sin | s
        fmul st0
        faddp st1 ; x+y+z | cos | sin | s

        fld1
        faddp st1 ; 1+x+y+z | cos | sin | s
        fld1
        fdivrp st1 ; 1/(1+x+y+z) | cos | sin | s

        fadd dword [tx]
        fstp dword [tx]
        fstp dword [temp]
        fstp dword [temp]
        fchs
      inc di
      cmp di, 12
      jne lights

      fld1
      fst dword [temp]
      mov eax, dword [temp]
      cmp dword [tx], eax
      jle saturate
        mov dword [tx], eax
      saturate:
      fld dword [tx]

      fmul dword [scale]
      fistp word [temp]
      mov ax, word [temp]

      mov di, cx
      imul di, 320
      add di, dx
      mov byte [es:di], al

    inc dx
    cmp dx, 320
    jne xloop
  inc cx
  cmp cx, 200
  jne yloop
mov ah,01h
int 16h
jz render

add sp, 48
ret

finc dd 0.05
fval dd 0.0
width dw 320
height dw 200
temp dd 0.0
half dd 0.5
ten dd 10.0
eight dw 10
t dd 0.0
tx dd 0.0
scale dd 255.0
dila db 0
