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



;// vertical xmode dithered gouraud shading

.model large,c
.386
locals

.data

extrn poly_width:word
extrn poly_scrseg:word
extrn poly_x:word
extrn poly_y:word
extrn poly_len:word
extrn poly_tx:dword
extrn poly_dtx:dword

.code

public vxshadeline
public vxshadelined
public vxshadelineq320
public vxshadelinedq320

exp=4

vxshadeline proc uses ds edi
  mov ax,poly_y
  mul poly_width
  add ax,poly_x
  adc dx,0
  mov cl,al
  and cl,3
  shrd ax,dx,2
  add ax,poly_scrseg
  push ax

  mov dx,3c4h
  mov ax,0102h
  shl ah,cl
  out dx,ax

  mov edx,poly_dtx
  mov edi,poly_tx
  rol edx,16
  rol edi,16
  mov ax,di
  mov ah,dl
  mov dx,poly_width
  shr dx,2
  pop di

  mov cx,poly_len

  mov bx,0a000h
  mov ds,bx

  xchg ax,bx
  mov al,cl
  and al,(1 shl exp)-1
  sub al,1 shl exp
  neg al
  mov ah,(@@blockend-@@block) shr exp
  mul ah
  add ax,offset @@block
  shr cx,exp
  inc cx
  xchg ax,bx
  jmp bx
@@block:
    rept 1 shl exp
      mov ds:[di],al
      add edi,edx
      adc al,ah
    endm
@@blockend:
  dec cx
  jnz @@block

@@done:
  ret
endp

jmppos dw 0

vxshadelined proc uses ds edi si
  mov ax,poly_y
  mul poly_width
  add ax,poly_x
  adc dx,0
  mov cl,al
  and cl,3
  shrd ax,dx,2
  add ax,poly_scrseg
  mov di,word ptr poly_tx
  shl edi,24
  mov di,ax

  mov dx,3c4h
  mov ax,0102h
  shl ah,cl
  out dx,ax

  mov si,word ptr poly_dtx+1
  mov dx,word ptr poly_tx+1
  mov bl,byte ptr poly_dtx
  shl ebx,24
  mov bx,poly_width
  shr bx,2

  mov cx,poly_len

  mov ax,0a000h
  mov ds,ax

  mov al,cl
  and al,(1 shl exp)-1
  sub al,1 shl exp
  neg al
  mov ah,(@@blockend-@@block) shr exp
  mul ah
  add ax,offset @@block
  mov jmppos,ax
  xor ax,ax
  shr cx,exp
  inc cx
  jmp jmppos
@@block:
    rept 1 shl exp
      add ax,dx
      mov ds:[di],ah
      xor ah,ah
      add edi,ebx
      adc dx,si
    endm
@@blockend:
  dec cx
  jnz @@block

@@done:
  ret
endp

vxshadelineq320 proc uses ds di
  mov ax,poly_y
  mul poly_width
  add ax,poly_x
  adc dx,0
  mov cl,al
  and cl,3
  shrd ax,dx,2
  add ax,poly_scrseg
  mov di,ax

  mov dx,3c4h
  mov ax,0102h
  shl ah,cl
  out dx,ax

  mov dx,word ptr poly_dtx+1
  mov ax,word ptr poly_tx+1

  mov cx,poly_len

  mov bx,0a000h
  mov ds,bx

  xchg ax,bx
  mov al,cl
  and al,(1 shl exp)-1
  sub al,1 shl exp
  neg al
  push ax
  mov ah,80
  mul ah
  sub di,ax
  pop ax
  mov ah,(@@blockend-@@block) shr exp
  mul ah
  add ax,offset @@block
  xchg ax,bx
  shr cx,exp
  inc cx
  jmp bx
  o=0
@@block:
    rept 1 shl exp
;      mov ds:[di+o],ah
      db 3eh,88h,0a5h
      dw o
      o=o+80
      add ax,dx
    endm
@@blockend:
  add di,80 shl exp
  dec cx
  jnz @@block

@@done:
  ret
endp

vxshadelinedq320 proc uses ds si di
  mov ax,poly_y
  mul poly_width
  add ax,poly_x
  adc dx,0
  mov cl,al
  and cl,3
  shrd ax,dx,2
  add ax,poly_scrseg
  mov di,ax

  mov dx,3c4h
  mov ax,0102h
  shl ah,cl
  out dx,ax

  mov si,word ptr poly_dtx+1
  mov dx,word ptr poly_tx+1

  mov cx,poly_len

  mov ax,0a000h
  mov ds,ax

  mov al,cl
  and al,(1 shl exp)-1
  sub al,1 shl exp
  neg al
  mov bl,al
  mov ah,80
  mul ah
  sub di,ax
  mov al,(@@blockend-@@block) shr exp
  mul bl
  add ax,offset @@block
  mov bx,ax
  xor ax,ax
  shr cx,exp
  inc cx
  jmp bx
  o=0
@@block:
    rept 1 shl exp
      add ax,dx
;      mov ds:[di+o],ah
      db 3eh,88h,0A5h
      dw o
      o=o+80
      xor ah,ah
      add dx,si
    endm
@@blockend:
  add di,80 shl exp
  dec cx
  jnz @@block

@@done:
  ret
endp

end
