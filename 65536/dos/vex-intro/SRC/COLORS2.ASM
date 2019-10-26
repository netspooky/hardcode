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



;// palette set and interpolate functions

.model large, c
.386
locals

.code

public GetColors
public SetColors
public SetColorsBlack
public SetColor
public MakeFadeStep
public InterpolCols

MakeFadeStep proc uses ds si di, cols:dword, colss:dword, colsd:dword, n:word, s:word
  cld
  lds si,colsd
  lfs bx,colss
  sub bx,si
  les di,cols
  mov cx,n
  shl cx,1
  add n,cx
  jz @@end
  mov dx,s
  mov dh,128
  sub dh,dl

@@lp:
    mov al,fs:[bx+si]
    mul dh
    mov cx,ax
    lodsb
    mul dl
    add ax,cx
    shr ax,7
    stosb
  dec n
  jne @@lp
@@end:
  ret
endp

InterpolCols proc uses si di, cols:dword, n:word, crs:word, cgs:word, cbs:word, crd:word, cgd:word, cbd:word
  cld
  les di,cols
  mov cx,n
  jcxz @@end
  mov ax,32768
  xor dx,dx
  div cx
  mov cx,ax
  xor bx,bx
  mov dx,128

@@lp:
    mov al,byte ptr crs
    mul dl
    mov si,ax
    mov al,byte ptr crd
    mul dh
    add ax,si
    shr ax,7
    stosb
    mov al,byte ptr cgs
    mul dl
    mov si,ax
    mov al,byte ptr cgd
    mul dh
    add ax,si
    shr ax,7
    stosb
    mov al,byte ptr cbs
    mul dl
    mov si,ax
    mov al,byte ptr cbd
    mul dh
    add ax,si
    shr ax,7
    stosb

    add bx,cx
    mov dh,bh
    mov dl,128
    sub dl,dh
  dec n
  jne @@lp
@@end:
  ret
endp

GetColors proc uses di, cols:dword, c0:word, n:word
  cld
  les di,cols
  mov cx,n
  shl cx,1
  add cx,n
  mov dx,3C7h
  mov al,byte ptr c0
  out dx,al
  add dx,2
  jcxz @@end
@@lp:
    in al,dx
    shl al,2
    stosb
  loop @@lp
@@end:
  ret
endp

SetColors proc uses ds si, cols:dword, c0:word, n:word
  cld
  lds si,cols
  mov cx,n
  shl cx,1
  add cx,n
  mov dx,3C8h
  mov al,byte ptr c0
  out dx,al
  inc dx
  jcxz @@end
@@lp:
    lodsb
    shr al,2
    out dx,al
  loop @@lp
@@end:
  ret
endp

SetColorsBlack proc
  mov cx,300h
  mov dx,3C8h
  xor al,al
  out dx,al
  inc dx
@@sc:
  out dx,al
  loop @@sc
  ret
endp

SetColor proc n:word, r:word, g:word, b:word
  mov dx,3C8h
  mov ax,n
  out dx,al
  inc dx
  mov al,byte ptr r
  shr al,2
  out dx,al
  mov al,byte ptr g
  shr al,2
  out dx,al
  mov al,byte ptr b
  shr al,2
  out dx,al
  ret
endp

end
