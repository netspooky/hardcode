;--Putpixel
;--IN:
;       al, color to set
;       edi, y coordinate
;       ebx, x coordinate
;       es, target segment
;--OUT:
proc    PutPixel near
        pusha
                mov cx,di
                shl cx,6
                lea edi,[ecx*4+ecx]
                add di,bx
                stosb
        popa
        ret
endp

;--DrawBar
;--IN:
;       di = upper left corner offset in buffer
;       es = segment of buffer
;       dx = width
;       cx = height
;       al = color
;--OUT:
proc DrawBar    near
        pusha
        mov  bx, 320
        sub  bx, dx
        @vbl:
                push dx
                @vhl:
                  stosb
                  dec dx
                  jnz @vhl
                pop  dx
        add  di, bx
        loop @vbl
        popa
        ret
endp

;--DrawText
;--IN:
;       ds:si=pointer to 0 terminated string
;       al=color
;       dx=pixel size
;       es=segment of buffer
;       fs:bp=pointer to 8x8 font
;       di=upper left corner in buffer
proc    DrawText near
	pusha
	call kippaa		;jajaja
                mov cx, dx
                shl cx,3
                @nextch:
                mov bh,0
                mov bl,[si]
                inc si
                call drawChar
                add  di,cx
                cmp  bl,0
                jne  @nextch
        popa
        ret
endp

;--Drawchar
;--IN:
;       bl=character ascii code
;       bh=0
;       al=color to use when drawing
;       di=left upper corner offset in buffer
;       dx=pixel size
;       es=segment of buffer
;       fs:bp = pointer to 8x8 font
;--OUT:
;
proc    DrawChar        near
        pusha

mov cx, dx
shl cx, 3
mov si, cx

push dx
shl  dx, 6
shl  cx, 5
add  cx, dx
pop  dx

sub  cx, si                    ; cx=320*pixsize-pixsize*8
          shl bx,3
          add bx,bp
          mov dh,8
          @cov:
push cx
            mov cl,8
            @coh:
push bx            ;hack--_
push dx
push cx
                   mov dh,[fs:bx]
                     mov bx,1
                     shl bx,cl
                     shr bx,1           ; gotta get fix :)
                   mov bh,dh
                   mov dh,0
                     and bh,bl
                     jz @cpixel
                        mov  cx, dx
                        call drawBar
                     @cpixel:
                        add  di,dx
pop  cx
pop  dx
pop  bx             ;hack--_
                  dec cl
                  jnz @coh
pop cx
add di, cx
                inc bx
                dec dh
                jnz @cov
        popa
        ret
endp

;--MakeBar
;--IN:
;  AX=x2
;  DX=y2
;  BX=x1
;  DI=y1
;  CH=color
proc            makebar near
                pusha
                mov si,bx
                @yl:
                  mov bx,si
                  @xl:          ;bx=xcoord, di=ycoord
                  call putpixel
                  inc bx
                  cmp bx,ax
                  jbe @xl
                inc di
                cmp di,dx
                jbe @yl
                popa
                ret
endp

;-----------------------------------------
;-- SetRGB, set an individual VGA color --
;-- Call registers:                     --
;--   AL, color to set                  --
;--   CL, Red value (0-63)              --
;--   CH, Blue value (0-63)             --
;--   BL, Green value (0-63)            --
;-----------------------------------------
proc SetRGB near
  push ax
  push dx
  mov  dx,3c8h
  out  dx,al
  inc  dx
  mov  al,cl
  out  dx,al
  mov  al,bl
  out  dx,al
  mov  al,ch
  out  dx,al
  pop  dx
  pop  ax
  ret
endp

