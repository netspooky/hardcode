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



;// intersection help functions

.model large,c
.386
locals

.code

public calcplane
public chkplanecut
public planecutv
public planecuts2
public planecutc2

calcplane proc uses ds si di,norm:dword, vert:dword, plane:dword
  cld
  lds si,norm
  les di,plane
  mov cx,3
  rep movsd
  lds si,vert
  lodsd
  imul dword ptr es:[di-12]
  mov ecx,eax
  mov ebx,edx
  lodsd
  imul dword ptr es:[di-8]
  add ecx,eax
  adc ebx,edx
  lodsd
  imul dword ptr es:[di-4]
  add eax,ecx
  adc edx,ebx
  shrd eax,edx,16
  neg eax
  stosd
  ret
endp

chkplanecut proc uses ds si di, plane:dword, pts:dword, pl:dword, n:word, rt:dword
local a:dword, b:dword, c:dword, d:dword, lst:dword, cur:dword, nl:word, nc:word, s:byte, ls:byte, pal:word, pac:word, pbl:word, pbc:word, vpal:dword, vpac:dword, vpbl:dword, vpbc:dword
  cld
  lds si,plane
  lodsd
  mov a,eax
  lodsd
  mov b,eax
  lodsd
  mov c,eax
  lodsd
  mov d,eax

  mov ax,n
  dec ax
  mov nl,ax

  les di,pts
  lds si,pl

  mov s,0

@@lp1:
    mov bx,n
    shl bx,1
    mov ax,[si+bx-2]

    shl ax,2
    mov bx,ax
    shl ax,1
    add bx,ax
    mov eax,es:[di+bx+0]
    imul a
    shrd eax,edx,16
    mov ecx,eax
    mov eax,es:[di+bx+4]
    imul b
    shrd eax,edx,16
    add ecx,eax
    mov eax,es:[di+bx+8]
    imul c
    shrd eax,edx,16
    add ecx,eax
    add ecx,d
    cmp ecx,-20
    jl @@ok1n
    cmp ecx,20
    jg @@ok1p
    inc s
    dec n
    jnz @@lp1
      mov ax,1
    jmp @@end
@@ok1n:
    mov ls,-1
  jmp @@ok1
@@ok1p:
    mov ls,0
@@ok1:
  cmp s,0
  je @@yo
    xor ecx,ecx
@@yo:
  mov lst,ecx

  mov s,0
  mov nc,0
@@lp:
    lodsw
    shl ax,2
    mov bx,ax
    shl ax,1
    add bx,ax
    mov eax,es:[di+bx+0]
    imul a
    shrd eax,edx,16
    mov ecx,eax
    mov eax,es:[di+bx+4]
    imul b
    shrd eax,edx,16
    add ecx,eax
    mov eax,es:[di+bx+8]
    imul c
    shrd eax,edx,16
    add ecx,eax
    add ecx,d
    cmp ecx,-20
    jl @@ok2n
    cmp ecx,20
    jg @@ok2p
      mov al,ls
    jmp @@ok2
  @@ok2n:
      mov al,-1
    jmp @@ok2
  @@ok2p:
      mov al,0
  @@ok2:
    mov cur,ecx
    mov ah,al
    xchg ah,ls
    xor al,ah
    jz @@nocut
      inc s
      cmp cur,0
      js @@b
	mov ax,nl
	mov pal,ax
	mov ax,nc
	mov pac,ax
	mov eax,lst
	mov vpal,eax
	mov eax,cur
	mov vpac,eax
      jmp @@nocut
    @@b:
	mov ax,nl
	mov pbl,ax
	mov ax,nc
	mov pbc,ax
	mov eax,lst
	mov vpbl,eax
	mov eax,cur
	mov vpbc,eax
  @@nocut:
    mov eax,cur
    mov lst,eax
    mov ax,nc
    mov nl,ax
    inc nc
  dec n
  jnz @@lp

  cmp s,0
  jnz @@cut
    cmp cur,0
    js @@bh
      mov ax,2
      jmp @@end
  @@bh:
      mov ax,0
      jmp @@end
@@cut:
    les di,rt

    mov ax,pal
    stosw
    mov ax,pac
    stosw
    mov eax,vpal
    mov ecx,eax
    sub ecx,vpac
    cdq
    shld edx,eax,16
    shl eax,16
    idiv ecx
    stosd

    mov ax,pbl
    stosw
    mov ax,pbc
    stosw
    mov eax,vpbl
    mov ecx,eax
    sub ecx,vpbc
    cdq
    shld edx,eax,16
    shl eax,16
    idiv ecx
    stosd

    mov ax,3
@@end:
  ret
endp

planecutv proc uses ds si di, a:dword, dtl:dword, dtc:dword, dtr:dword
local b:dword
  mov eax,10000h
  sub eax,a
  mov b,eax

  cld
  lds si,dtl
  lfs bx,dtc
  les di,dtr
  i=0
  rept 3
    mov eax,ds:[si+i]
    imul b
    shrd eax,edx,16
    mov ecx,eax
    mov eax,fs:[bx+i]
    imul a
    shrd eax,edx,16
    add eax,ecx
    mov es:[di+i],eax
    i=i+4
  endm
  ret
endp

planecuts2 proc uses ds si di, a:dword, dtl:dword, dtc:dword, dtr:dword
local b:dword
  mov eax,10000h
  sub eax,a
  mov b,eax

  lds si,dtl
  lfs bx,dtc
  les di,dtr
  i=0
  rept 2
    movzx eax,word ptr ds:[si+i]
    mul b
    shr eax,16
    mov cx,ax
    movzx eax,word ptr fs:[bx+i]
    mul a
    shr eax,16
    add ax,cx
    mov word ptr es:[di+i],ax
    i=i+2
  endm
  ret
endp

planecutc2 proc uses ds si di, a:dword, dtl:dword, dtc:dword, dtr:dword
local b:dword
  mov eax,10000h
  sub eax,a
  mov b,eax

  lds si,dtl
  lfs bx,dtc
  les di,dtr
  i=0
  rept 2
    movzx eax,byte ptr ds:[si+i]
    mul b
    shr eax,16
    mov cl,al
    movzx eax,byte ptr fs:[bx+i]
    mul a
    shr eax,16
    add al,cl
    mov byte ptr es:[di+i],al
    i=i+1
  endm
  ret
endp

end
