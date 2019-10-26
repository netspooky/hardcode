; Fire/Ice by Preacher of Traction
;
; As you can see, the code is bad and hacked together, but I think the
; effect turned out rather nice.. though the colors aren't exactly what
; I had in mind.
;
; Basically the whole thing is just a bunch of zoomed xor-layers with
; displacement mapping. I don't think this source contains much anything
; worth learning, but feel free to try :) It wouldn't probably be too hard
; to cut out some bytes, but that's left as an exercise for the reader :P
; 
; Flames to: mnurmika@cc.hut.fi
;

.model tiny
.486
.code

org 100h

START:

  mov dx, cs
  add dh, 10h
  mov es, dx   ; muistia

  push 0a000h
  pop fs

  mov ax, 13h  ; AL?
  int 10h

  @mainloop:
    inc [framecounter]

    ; sininen -> violetti -> sininen
    ; red = al + 31+31*sin(aika)

    mov cx, 255

    fild [framecounter]
    fld st(0)
    fmul [palettinopeus]
    fcos
    fimul [palettifactor]
    fiadd [palettifactor]
    fistp [fpu1]

    @paletti:
      mov ax, cx
      mov dx, 3c8h
      out dx, al
      shr ax, 2
      inc dx

      push ax
      add al, byte ptr [fpu1]
      out dx, al     ; r
      pop ax

      out dx, al     ; g

      add al, al
      cmp al, 63
      jb pal_ok
        mov al, 63
      pal_ok:

      mov ah, byte ptr [fpu1]
      shr ah, 1
      sub al, ah
      jnc pal_ok2
        mov al, 0;63
      pal_ok2:
      out dx, al     ; b
  
      loop @paletti

    ; st(0) = kokonaisluku framecounter
    fmul [nopeus]

    fsin
    fimul word ptr [zoomfactor]
    fiadd word ptr [zoomfactor]
    fistp [fpu1]

    mov cx, 5
    @xorloop:

      push cx
      shl cx, 4
      add cx, word ptr [fpu1]
      add cx, 50

      xor di, di
      mov dl, 200     ; dh tyhj„

      @xor_y:

        mov bx, 320
        @xor_x:

          ; vapaita ah, dh, si

          mov ax, bx
          imul ax, cx
          shr ax, 6
          add al, byte ptr [framecounter]

          movzx bp, dl
          imul bp, cx
          shr bp, 6
          sub bp, word ptr [framecounter]

          and ax, bp
          ; ruutu = 3*ruutu + value
      
          mov ah, byte ptr es:[di]
          shr ah, 2
          shr al, 2
          add al, ah
          add al, ah
          add al, ah

          stosb

          dec bx
          jnz @xor_x
      
        dec dl
        jnz @xor_y

      pop cx
      loop @xorloop

    ; di = 64000 edellisest„ loopista

    @flip:
      mov bl, byte ptr es:[di]
      shr bl, 1
      add bl, byte ptr [fpu1]

      mov al, byte ptr es:[di+bx]
      add al, byte ptr es:[di+bx+1]
      adc ah, 0
      add al, byte ptr es:[di+bx-1]
      adc ah, 0
      add al, byte ptr es:[di+bx+152]
      adc ah, 0
      shr ax, 2

      mov byte ptr fs:[di], al
      dec di
      jnz @flip

    mov ah, 01h
    int 16h
    jz @mainloop

  mov ax, 3h
  int 10h

  ret

nopeus dd 0.01
zoomfactor dw 63
palettifactor dw 6
palettinopeus dd 0.03

fpu1 dw ?
fpu2 dw ?
framecounter dw ?

END START
