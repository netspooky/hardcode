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



; // sine plasma, calculates one line for one operator

.model large,c
.386
locals

.data
extrn SinTab:dword

.code

public makesintab
public plasmaline

blockbeg macro exp
blocksize=(1 shl exp)
  mov ax,num
  and ax,blocksize-1
  sub ax,blocksize
  neg ax
  mov ah,al
  mov al,(@@blockend-@@block) shr exp
  mul ah
  add ax,offset @@block
  shr num,exp
  inc num
  jmp ax
@@block:
endm

blockend macro
@@blockend:
  dec num
  jnz @@block
endm

makesintab proc uses ds si di, plsin:dword, max:word
  cld
  lds si,SinTab
  les di,plsin
  movzx ebx,byte ptr max
  mov cx,2048
@@l:
    lodsd
    add eax,65536
    imul eax,ebx
    shr eax,17
    stosb
  loop @@l
  ret
endp

plasmaline proc uses ds si edi, plsin:dword, buf:dword, num:word, p:dword, f:dword
  mov di,word ptr p
  shl edi,16
  mov dx,word ptr f
  shl edx,16
  mov dx,1
  mov bx,word ptr p+2
  mov cx,word ptr f+2
  lds si,plsin
  les di,buf
  blockbeg 5
    rept blocksize
      and bx,2047
      mov al,ds:[bx+si]
      add es:[di],al
      add edi,edx
      adc bx,cx
    endm
  blockend
@@end:
  ret
endp

end
