;
; "across the through"
; by gargaj / ümlaüt design
;
; i never thought raymarching in 256b is this easy.
; as you can tell there's plenty of room for optimization,
; but since it fits into 256b, what's the point? :)
;
; big hello to sensenstahl for some design tips! :)
;
; http://gargaj.umlaut.hu
;

org 0x100
bits 16

%define load_code_as_data_hax

%ifdef load_code_as_data_hax
%define speed 0x104
%define dirz 0x139
%endif

mov al, 0x13
int 0x10

push word 0xa000
pop es
push word 0x0040
pop fs

inc cx
paletteloop:
  mov al, cl
  xor al, 0xff
  mov dx, 0x3c9
  ;out dx, al
  ;inc dx
  shr al, 2
  out dx, al
  out dx, al
  out dx, al
loop paletteloop

mainloop:
  ;mov cx, 320 * 200
  dec cx

  xor di, di

  pixel_loop:
    push cx
    push di

    mov ax, 0xCCCD
    mul di
    mov cx, dx

    ; --- create ray from screen coordinates
    xor ax, ax
    mov al, cl
    sub ax, 160
    cwd
    sal ax, 5
    mov bx, 6
    idiv bx
    ;sal ax, 3         ;; this actually would replace the top 3 lines and save 5 bytes but the aspect ratio looks bad that way
    mov word [dirx], ax

    xor ax, ax
    mov al, ch
    push ax
    sub ax, 100
    cwd
    sal ax, 7
    mov bx, -25
    idiv bx
    mov word [diry], ax

    ; --- rotate ray direction
    fild word [fs:0x6C]
    fist word [ray_position + 4] ; reuse this for translation later
    fidiv word [speed]
    fsincos
    fld st1
    fld st1

    fimul word [dirz]
    fxch st1
    fimul word [dirx]
    fsubrp st1, st0
    fistp word [ray_direction]

    fimul word [dirx]
    fxch st1
    fimul word [dirz]
    faddp st1, st0
    fistp word [ray_direction + 4]

    mov bx, word [diry]
    mov word [ray_direction + 2], bx

    ; --- reset ray step position
    mov ax, 10000
    mov word [ray_position + 0], ax
    mov word [ray_position + 2], ax
    shl word [ray_position + 4], 10

    ; --- march march march
    xor ax, ax
    xor bh, bh
    mov cx, 128
    steps:
      mov bl, byte [ray_position + 1]
      xor bl, byte [ray_position + 3]
      xor bl, byte [ray_position + 5]
      add ax, bx
      mov bx, word [ray_direction]
      add word [ray_position], bx
      mov bx, word [ray_direction + 2]
      add word [ray_position + 2], bx
      mov bx, word [ray_direction + 4]
      add word [ray_position + 4], bx
    loop steps

    shr ax, 7
    xor ah, ah

    mov bl, 1

    pop cx

    cmp cl, 31
    ja dontfade_top
      mov bl, cl
      shr bl, 2
      xor bl, 7
      inc bl
    dontfade_top:

    cmp cl, 168
    jna dontfade_bottom
      mov bl, cl
      sub bl, 164
      shr bl, 2
      inc bl
    dontfade_bottom:

    div bl

    pop di
    stosb

    pop cx
    dec cx
  jnz pixel_loop

in al, 60h
cmp al, 1
jnz mainloop
ret

;section .data

%ifndef load_code_as_data_hax
speed dw 100
dirz dw 512
%endif

section .bss

dirx resw 1
diry resw 1
ray_position resw 3
ray_direction resw 3
