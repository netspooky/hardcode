[org 100h]

mov ax, 13h
int 10h

push 0a000h
pop es

top:

  mov eax, dword [prng]
  xor cx, cx
  vert_gen:
    imul eax, 1664525
    add eax, 1013904223
    push eax
    xor edx, edx
    mov ebx, 200
    div ebx
    pop eax
    push dx

    add eax, 1013904223
    imul eax, 1664525
    push eax
    xor edx, edx
    mov ebx, 320
    div ebx
    pop eax
    push dx
  inc cx
  cmp cx, 3
  jne vert_gen
  mov dword [prng], eax

  xor di, di
  frame_loop:

    mov word [temp], 1
    xor cx, cx
    calc_loop:

      mov ax, di
      mov bx, 320
      xor dx, dx
      div bx
      ; div in ax = y
      ; mod in dx = x

      mov [trick], ax
      fild word [trick]
      mov [trick], dx
      fild word [trick]

      mov ax, cx
      shl ax, 2
      push sp
      pop bp
      add bp, ax
      fild word [bp] ; i
      add bp, 2
      fild word [bp] ; i+1

      mov ax, cx
      inc ax
      mov dx, 3
      cmp ax, dx
      jl nodec
        sub ax, dx
      nodec:

      shl ax, 2
      push sp
      pop bp
      add bp, ax
      fild word [bp] ; j
      add bp, 2
      fild word [bp] ; j+1

      ; j+1 | j | i+1 | i | x | y

      fsub st2 ; (j+1)-(i+1) | j | i+1 | i | x | y
      fld st1 ; j | (j+1)-(i+1) | j | i+1 | i | x | y
      fsub st4 ; j-i | (j+1)-(i+1) | j | i+1 | i | x | y
      fld st5 ; x | j-i | (j+1)-(i+1) | j | i+1 | i | x | y
      fsub st5 ; x-i | j-i | (j+1)-(i+1) | j | i+1 | i | x | y
      fld st7 ; y | x-i | j-i | (j+1)-(i+1) | j | i+1 | i | x
      fsub st5 ; y-(i+1) | x-i | j-i | (j+1)-(i+1) | j | i+1 | i | x

      fmul st2 ; y-(i+1) * j-i
      fld st1 ; x-i
      fmul st4 ; x-i * (j+1)-(i+1)
      fsubr st1

      ;fldz
      ;fcomi st1
      ;jb positive
      ;  mov word [temp], 0
      ;positive:

      fld st0
      fabs
      fdiv st1
      fist word [trick]
      cmp word [trick], 0
      jg positive
        mov byte [temp], 0
      positive:

    inc cx
    cmp cx, 3
    jne calc_loop

    cmp byte [temp], 0
    je no_plot
      mov bl, [colour]
      mov byte [es:di], bl
    no_plot:

  inc di
  cmp di, 64000
  jne frame_loop

add sp, 12
inc byte [colour]
jmp top

temp db 0
trick dw 0
colour db 0
prng dd 0
