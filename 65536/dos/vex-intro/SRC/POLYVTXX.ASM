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



;// vertical xmode texture line routines

.model large,c
.386
locals

.data

extrn poly_width:word
extrn poly_scrseg:word
extrn poly_tbmp:dword
extrn poly_twid:word
extrn poly_col:byte
extrn poly_x:word
extrn poly_y:word
extrn poly_len:word
extrn poly_tx:dword
extrn poly_ty:dword
extrn poly_dtx:dword
extrn poly_dty:dword

.code

public vxtextureline
public vxtexturelinex

exp=4

ct dw 0
jmppos dw 0

jccnum macro jcc,i
  jcc @@lab&i
endm

labnum macro i
  @@lab&i:
endm

texture macro name,xpar
name proc uses esi edi ds
  num=0
  mov cx,poly_len
  mov al,cl
  and al,(1 shl exp)-1
  sub al,1 shl exp
  neg al
  mov ah,(@@blockend-@@block) shr exp
  mul ah
  add ax,offset @@block
  mov cs:jmppos,ax
  shr cx,exp
  inc cx
  mov cs:ct,cx

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

  mov esi,poly_ty
  rol esi,16
  imul si,poly_twid
  add si,word ptr poly_tx+2
  add si,word ptr poly_tbmp

  mov ebx,poly_dty
  rol ebx,16
  imul bx,poly_twid
  add bx,word ptr poly_dtx+2

  mov cx,word ptr poly_dtx
  shl ecx,16
  mov cx,poly_width
  shr cx,2

  rol edi,16
  mov di,word ptr poly_tx
  rol edi,16

  mov dx,poly_twid

  mov ax,0a000h
  mov es,ax
  mov ah,poly_col

  mov ds,word ptr poly_tbmp+2

  jmp cs:jmppos

@@block:
    rept 1 shl exp
      mov al,ds:[si]
    if xpar
      test al,0ffh
      jccnum jz,%num
    endif
      add al,ah
      mov es:[di],al
    labnum %num
    num=num+1
      add edi,ecx
      adc esi,ebx
      jccnum jnc,%num
        add si,dx
    labnum %num
    num=num+1
    endm
@@blockend:
  dec cs:ct
  jnz @@block

@@done:
  ret
endp
endm

texture vxtextureline,0
texture vxtexturelinex,1

end
