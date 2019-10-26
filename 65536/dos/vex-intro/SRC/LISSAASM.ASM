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



;// lissajous function, calculates the coordinates of the points for given
;// parameters

.model large,c
.386
locals

.data
extrn SinTab:dword

.code

public calclissapoints

calclissapoints proc uses ds si edi, pts:dword, num:word, a:dword, b:dword, c:dword, d:dword, e:dword, f:dword
  lds si,SinTab
  mov es,word ptr pts+2

  mov bx,word ptr d+2
  shl bx,2
  mov di,word ptr d
  shl edi,16
  mov di,word ptr pts
  mov dx,word ptr a
  shl edx,16
  mov dx,12
  mov cx,num
  push bp
  mov bp,word ptr a+2
  shl bp,2
  add bp,3
  @@l0:
    and bx,8188
    mov eax,ds:[si+bx]
    mov es:[di],eax
    add edi,edx
    adc bx,bp
  loop @@l0
  pop bp

  mov bx,word ptr e+2
  shl bx,2
  mov di,word ptr e
  shl edi,16
  mov di,word ptr pts
  add di,4
  mov dx,word ptr b
  shl edx,16
  mov dx,12
  mov cx,num
  push bp
  mov bp,word ptr b+2
  shl bp,2
  add bp,3
  @@l1:
    and bx,8188
    mov eax,ds:[si+bx]
    mov es:[di],eax
    add edi,edx
    adc bx,bp
  loop @@l1
  pop bp

  mov bx,word ptr f+2
  shl bx,2
  mov di,word ptr f
  shl edi,16
  mov di,word ptr pts
  add di,8
  mov dx,word ptr c
  shl edx,16
  mov dx,12
  mov cx,num
  push bp
  mov bp,word ptr c+2
  shl bp,2
  add bp,3
  @@l2:
    and bx,8188
    mov eax,ds:[si+bx]
    mov es:[di],eax
    add edi,edx
    adc bx,bp
  loop @@l2
  pop bp

  ret
endp

end
