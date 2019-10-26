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



;// 3d-projection  for starfield and lissajous

.model large, c
.386
locals

.code

public calcpoints3d
public rdrawpointlst
public xchgpointlst

calcpoints3d proc uses si di ds, ptlst:dword, pts3d:dword, num:word, zoomx:dword, zoomy:dword, maxdist:dword, col1:dword
local len:word
  cld
  lds si,pts3d
  les di,ptlst
  mov len,0
  mov cx,num
  jcxz @@2
@@1:
    cmp dword ptr [si+8],1000
    jl @@next

    mov eax,dword ptr [si]
    imul zoomx
    idiv dword ptr [si+8]
    shr eax,16
    cmp ax,-160
    jl @@next
    cmp ax,160
    jge @@next
    mov bx,ax

    mov eax,dword ptr [si+4]
    imul zoomy
    idiv dword ptr [si+8]
    shr eax,16
    cmp ax,-100
    jle @@next
    cmp ax,100
    jg @@next
    neg ax
    add ax,100

    add bx,160
    shl ax,6
    add bx,ax
    shl ax,2
    add ax,bx
    stosw

    mov eax,maxdist
    sub eax,dword ptr [si+8]
    imul col1
    mov al,dl
    stosb

    inc len

@@next:
    add si,12
  loop @@1
@@2:
  mov ax,len
  ret
endp

xchgpointlst proc uses si di ds, ptlst:dword, num:word, pag:word
  lds si,ptlst
  mov ax,0a000h
  mov es,ax
  mov di,pag
  cmp num,0
  je @@end
@@1:
    mov bx,ds:[si]
    mov cl,bl
    shr bx,2
    and cl,3
    mov ah,cl
    mov al,04
    mov dx,3ceh
    out dx,ax
    mov ax,0102h
    shl ah,cl
    mov dx,3c4h
    out dx,ax
    mov al,ds:[si+2]
    xchg es:[di+bx],al
    mov ds:[si+2],al
    add si,3
  dec num
  jnz @@1
@@end:
  ret
endp

rdrawpointlst proc uses si di ds, ptlst:dword, num:word, pag:word
  lds si,ptlst
  mov ax,0a000h
  mov es,ax
  mov di,pag
  mov dx,3c4h
  mov ax,num
  cmp ax,0
  je @@end
  add si,ax
  shl ax,1
  add si,ax
@@1:
    sub si,3
    mov bx,ds:[si]
    mov cl,bl
    shr bx,2
    and cl,3
    mov ax,0102h
    shl ah,cl
    out dx,ax
    mov al,ds:[si+2]
    mov es:[di+bx],al
  dec num
  jnz @@1
@@end:
  ret
endp

end
