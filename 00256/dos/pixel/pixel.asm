; pixel by kat aka chelle, fantasy, katzeh, and many many more
; made for efnet hash asm compo 7
; my first compo entry so dont expect much
; thanks for all your help matja, mcarp, scali, razzi, and of course wb
; and thanks for answering of my stupid questions all the time :)

org 0x100
segment .text

main
  mov ax,13h			;set mode 13h
  int 10h
  mov cx,2			;loop 2 times
  scale_loop:
    push cx			;save cx
    mov cx,95			;loop 95 times
    scale_nestloop:
      push cx			;save cx
      fld dword[scale]		;load scale
      fadd dword[const]		;add const
      fstp dword[scale]		;store scale
      push word 09000h		;begin clear screen
      pop es
      xor di,di
      xor ax,ax
      mov cx,32000
      rep stosw
      call waitretrace		;wait for a vertical retrace
      call waitretrace		;wait again
      call waitretrace		;wait one more time (makes it seem slower)
      call circle		;draw circle
      push ds
      push word 0a000h
      pop es
      xor di,di
      push word 09000h
      pop ds
      xor si,si
      mov cx,32000
      rep movsw
      pop ds
      pop cx
    loop scale_nestloop
    pop cx
  mov dword [const],0bf800000h	
  mov dword [scale],42be0000h
  loop scale_loop
  mov ax,3
  int 10h
  ret

box
  push cx
  and cx,31
  add cx,32
  mov ax,cx
  pop cx
  call putpixel
  inc dx
  call putpixel
  inc cx
  call putpixel
  dec dx
  call putpixel
  ret

circle
  mov cx,45
  circle_loop
    push cx
    push dx
    fld dword[time]
    fadd dword[timediff]
    fst dword[time]
    fsincos
    fmul dword[scale]
    fadd dword[x_offset]
    fistp word[screen_x]
    fmul dword[scale]
    fadd dword[y_offset]
    fistp word[screen_y]
    mov cx,[screen_x]
    mov dx,[screen_y]
    call box
    pop dx
    pop cx
  loop circle_loop
  ret

putpixel
  push ds
  pusha
  push word 09000h
  pop ds
  mov bx,dx
  shl bx,6
  shl dx,8
  add bx,dx
  add bx,cx
  mov [bx],al
  popa
  pop ds
  ret

waitretrace:
  mov dx,3dah
  v1:
    in al,dx
    and al,08h
    jnz v1
  v2:
    in al,dx
    and al,08h
    jz v2
  ret

const dd 1.0
screen_x dd 25.0
screen_y dd 25.0
time dd 0.0
timediff dd 0.139
scale dd 0.0
x_offset dd 160.0
y_offset dd 100.0