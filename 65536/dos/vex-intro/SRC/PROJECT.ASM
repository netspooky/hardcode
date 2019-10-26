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



; // 3dproject points

.model large, c
.386
locals

.code

public projectverts

projectverts proc uses si di ds, verts:dword, v:dword, coords:dword, num:word, zoomx:dword, zoomy:dword
  cmp num,0
  je @@x
  cld
  les di,coords
  lds si,v
  lfs cx,verts
@@lp:
    lodsw
    shl ax,2
    mov bx,ax
    shl ax,1
    add bx,ax
    add bx,cx
    mov eax,zoomx
    imul dword ptr fs:[bx+0]
    idiv dword ptr fs:[bx+4]
    add eax,160*65536
    stosd
    mov eax,zoomy
    imul dword ptr fs:[bx+8]
    idiv dword ptr fs:[bx+4]
    neg eax
    add eax,100*65536
    stosd
  dec num
  jnz @@lp
@@x:
  ret
endp

end
