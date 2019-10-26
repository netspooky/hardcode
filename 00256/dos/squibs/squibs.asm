; Squibs 256b by dila
; October 2014

[org 100h]

mov al, 13h
int 10h

push 0a000h
pop es

sub sp, 384
;mov cx, 384
;mov di, sp
;xor al, al
;rep stosb

main:

  mov bp, sp
  mov cl, 24
  update:

    fninit

    mov word [bx], 3
    fild word [bx]
    xor eax, eax
    cmp dword [bp+4], eax
    jg reset
      mov dword [bp+4], eax

      call rand
      fabs
      fmul dword [width]
      fstp dword [bp]

      call rand
      fmul st1
      fstp dword [bp+8]

      call rand
      fabs
      fmul st1
      fadd st1
      fstp dword [bp+12]
    reset:

    fld dword [bp+8]
    fadd dword [bp]
    fstp dword [bp]

    fld dword [bp+12]
    fadd dword [gravity]
    fst dword [bp+12]

    fadd dword [bp+4]
    fst dword [bp+4]

    add bp, 16
  loop update

  mov cl, 199
  yloop:

    mov dx, 319
    xloop:

      fldz

      mov bp, sp
      mov si, 24
      render:
        fld1

        mov word [bx], dx
        fild word [bx]
        fsub dword [bp]
        fmul st0

        mov word [bx], cx
        fild word [bx]
        fsubr dword [height]
        fsub dword [bp+4]
        fmul st0

        faddp
        fadd st1
        fdivp
        faddp
        add bp, 16
      dec si
      jnz render

      mov di, cx
      imul di, 320
      add di, dx

      fmul dword [scale]
      fistp word [bx]
      movzx ax, byte [es:di]
      add ax, word [bx]

      cmp ax, 31
      jle saturate
        mov ax, 31
      saturate:

      dec al
      cmp al, 16
      jge clamp
        mov al, 16
      clamp:

      stosb

    dec dx
    jnz xloop
  loop yloop
mov ah,01h
int 16h
jz main
int 0x20

rand: ; thanks to rgba
  mov eax, dword [prng]
  imul eax, 16807
  mov dword [prng], eax
  and eax, 0x007fffff
  or eax, 0x40000000
  mov dword [bx], eax
  fld dword [bx]
  fsub st1
  ret

prng dd 1
width dd 320.0
height dd 200.0
scale dd 16.0
gravity dd -0.1
