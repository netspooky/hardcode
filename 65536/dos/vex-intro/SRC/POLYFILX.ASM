comment #
/*****************************************************************************
                                  ATTENTION!
                           this source is VOTEWARE,
              you may only use it to the conditions listed below:

  -You may modify it, or use parts of it in your own source as long as
    this header stays on top of all files containing this source.
  -You must give proper credit to the author, Niklas Beisert / pascal.
  -You may not use it in commercial productions without the written
    permission of the author.
  -AND MOST IMPORTANT: you have to buy an Assembly '94 CD-ROM
    by Sound Solutions (if you don't have it already) and vote for VEX-InTrO
    in the PC-64k-Intro-Compo! (if you have already sent your voting card,
    buy another one and fill it out CORRECTLY!!!)
*****************************************************************************/
#



;// fills one line for the polygon routine.
;// for x mode and horizontally
;//  xfillliner reads before it writes => or-put

.model large,c
.386
locals

.data

extrn poly_width:word
extrn poly_scrseg:word
extrn poly_col:byte
extrn poly_x:word
extrn poly_y:word
extrn poly_len:word

.code

public xfillline
public xfillliner

blockbeg macro exp
blocksize=(1 shl exp)
  xchg ax,dx
  mov ax,cx
  and ax,blocksize-1
  sub ax,blocksize
  neg ax
  sub di,ax
  mov ah,(@@blockend-@@block) shr exp
  mul ah
  add ax,offset @@block
  xchg ax,dx
  shr cx,exp
  inc cx
  jmp dx
@@block:
dioffs=0
endm

blockend macro
@@blockend:
  add di,dioffs
  dec cx
  jnz @@block
endm

xfillline proc uses ds di
  mov ax,poly_y
  mul poly_width
  add ax,poly_x
  adc dx,0
  mov cl,al
  and cl,3
  shrd ax,dx,2
  add ax,poly_scrseg
  mov di,ax
  mov ax,1102h
  rol ah,cl

  mov bl,poly_col
  mov cx,poly_len

  mov dx,0a000h
  mov es,dx

  mov dx,3c4h

  cmp cx,4
  jl @@small
  cmp al,11h
  je @@ok3
@@loop1:
    out dx,ax
    mov es:[di],bl
    dec cx
    rol ah,1
    jnc @@loop1
  inc di
@@ok3:
  mov ah,0Fh
  out dx,ax
  push cx
  shr cx,2
  mov bh,bl
  mov ax,bx
  shl eax,16
  mov ax,bx

  cmp cx,4
  jl @@small2

  test di,3
  jz @@ok4
@@loop2:
    stosb
    dec cx
  test di,3
  jnz @@loop2
@@ok4:

  push cx
  shr cx,2
  rep stosd
  pop cx
  and cx,3

@@small2:
  rep stosb

  pop cx
  and cx,3
  mov dx,3c4h
  mov ax,1102h
@@small:
  jcxz @@done
@@smallloop:
    out dx,ax
    mov es:[di],bl
    rol ah,1
    adc di,0
  loop @@smallloop
@@done:

  ret
endp

xfillliner proc uses ds di
  mov ax,poly_y
  mul poly_width
  add ax,poly_x
  adc dx,0
  mov cl,al
  and cl,3
  shrd ax,dx,2
  add ax,poly_scrseg
  mov di,ax
  mov ax,1102h
  rol ah,cl

  mov cx,poly_len
  mov bl,poly_col

  mov dx,0a000h
  mov ds,dx

  mov dx,3c4h

  cmp cx,4
  jl @@small
  cmp al,11h
  je @@ok3
@@loop1:
    out dx,ax
    mov bh,ds:[di]
    mov ds:[di],bl
    dec cx
    rol ah,1
    jnc @@loop1
  inc di
@@ok3:
  mov ah,0Fh
  out dx,ax
  push cx
  shr cx,2
  mov al,bl

  blockbeg 5
    rept blocksize
      db 8ah, 65h, dioffs
      db 88h, 45h, dioffs
      dioffs=dioffs+1
    endm
  blockend

  pop cx
  and cx,3
  mov dx,3c4h
  mov ax,1102h
@@small:
  jcxz @@done
@@smallloop:
    out dx,ax
    mov bh,ds:[di]
    mov ds:[di],bl
    rol ah,1
    adc di,0
  loop @@smallloop
@@done:

  ret
endp

end
