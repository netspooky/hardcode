; Left leads to a better future by Preacher/Traction
;
; The name is because it's looking left and the horizon is brighter so
; it's obviously better there.
;
; (I think I need some sleep)
;
; I always wanted to code a checkerboard and here it is, after ten years
; of waiting. I'm not expecting you to enjoy it though, it's just a
; checkedboard..

.model tiny
.486
.code

org 100h

height EQU 255
vinous EQU 50


START:

  push 0a000h
  pop es

  mov ax, 13h
  int 10h

  @mainloop:

    fild [framecounter]

    fldpi
    fadd st(0), st(0)
    fadd st(0), st(0)
    fmul st(0), st(0)
    fdivp st(1), st(0)
    fcos
    fimul [arvo]
    fistp [temp]

    xor di, di
    mov cx, vinous
    @yloop:

      mov bp, 320
      @xloop:

        mov ax, temp
        add ax, 400
        shl ax, 8
        xor dx, dx
        div cx

        ; ax = z

        mov bh, al
        mov dx, bp
        sub dx, 100
        add dx, temp
        mul dx

        shr ax, 8
        mov bl, al

        add bh, byte ptr framecounter
        xor bl, bh

        and bl, 32
        shr bl, 5
        jz skip
          mov bl, 31
        skip:

        mov al, bl
        mov dl, cl
        shr dl, 5
        sub al, dl

        stosb

        dec bp
        jnz @xloop

      inc cx
      cmp cx, 200+vinous
      jb @yloop

    inc [framecounter]

    mov ah, 01h
    int 16h
    jz @mainloop

  mov ax, 3h
  int 10h

  ret

arvo    dw 64
framecounter dw ?
temp     dw ?


END START
