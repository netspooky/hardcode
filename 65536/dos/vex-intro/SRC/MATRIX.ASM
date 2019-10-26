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



;// matrix and vector routines

.model large,c
.386
locals

extrn ZeroOn:word

.data

extrn SinTab:dword
sintabsize equ 2048

.code

public vecmove
public vecscl
public vecadd
public vecsub
public vecmul
public vecsqr
public vecnorm
public vecxmul
public veccopy
public vecxform
public vecxformvec
public vecxlate
public vectsqr
public matscl
public matmul
public matxlate
public makematnorm
public makematxlate
public makematrotx
public makematroty
public makematrotz

vecmove proc uses ds si di, r:dword, p:dword, t:dword, l:word
  cld
  les di,r

  xor eax,eax
  mov es:[di+0],eax
  mov es:[di+4],eax
  mov es:[di+8],eax

  cmp l,1
  jb @@end
  lds si,p
  lodsd
  add es:[di+0],eax
  lodsd
  add es:[di+4],eax
  lodsd
  add es:[di+8],eax

  cmp l,2
  jb @@end
  mov ecx,t
  lodsd
  imul ecx
  shrd eax,edx,16
  add es:[di+0],eax
  lodsd
  imul ecx
  shrd eax,edx,16
  add es:[di+4],eax
  lodsd
  imul ecx
  shrd eax,edx,16
  add es:[di+8],eax

  cmp l,3
  jb @@end
  mov eax,ecx
  imul eax
  shrd eax,edx,17
  mov ecx,eax
  lodsd
  imul ecx
  shrd eax,edx,16
  add es:[di+0],eax
  lodsd
  imul ecx
  shrd eax,edx,16
  add es:[di+4],eax
  lodsd
  imul ecx
  shrd eax,edx,16
  add es:[di+8],eax

  cmp l,4
  jb @@end
  mov eax,ecx
  imul t
  mov ecx,30000h
  idiv ecx
  mov ecx,eax
  lodsd
  imul ecx
  shrd eax,edx,16
  add es:[di+0],eax
  lodsd
  imul ecx
  shrd eax,edx,16
  add es:[di+4],eax
  lodsd
  imul ecx
  shrd eax,edx,16
  add es:[di+8],eax

@@end:
  mov ax,di
  mov dx,es
  ret
endp

vecscl proc uses ds si di, r:dword, a:dword, b:dword
  cld
  lds si,a
  les di,r
  mov ecx,b
  lodsd
  imul ecx
  shrd eax,edx,16
  stosd
  lodsd
  imul ecx
  shrd eax,edx,16
  stosd
  lodsd
  imul ecx
  shrd eax,edx,16
  stosd
  ret
endp

vecadd proc uses ds si di, r:dword, a:dword, b:dword
  cld
  lds si,a
  lfs bx,b
  les di,r
  lodsd
  add eax,fs:[bx+0]
  stosd
  lodsd
  add eax,fs:[bx+4]
  stosd
  lodsd
  add eax,fs:[bx+8]
  stosd
  ret
endp

vecsub proc uses ds si di, r:dword, a:dword, b:dword
  cld
  lds si,a
  lfs bx,b
  les di,r
  lodsd
  sub eax,fs:[bx+0]
  stosd
  lodsd
  sub eax,fs:[bx+4]
  stosd
  lodsd
  sub eax,fs:[bx+8]
  stosd
  ret
endp

vecmul proc uses si di ds, a:dword, b:dword
  cld
  lds si,a
  les di,b
  lodsd
  imul dword ptr es:[di+0]
  mov ecx,eax
  mov ebx,edx
  lodsd
  imul dword ptr es:[di+4]
  add ecx,eax
  adc ebx,edx
  lodsd
  imul dword ptr es:[di+8]
  add eax,ecx
  adc edx,ebx
  shr eax,16
  ret
endp

vecsqr proc uses si ds, a:dword
  cld
  lds si,a
  lodsd
  imul eax
  mov ecx,eax
  mov ebx,edx
  lodsd
  imul eax
  add ecx,eax
  adc ebx,edx
  lodsd
  imul eax
  add eax,ecx
  adc edx,ebx
  shr eax,16
  ret
endp

vecnorm proc uses esi edi ds, a:dword
  cld
  lds bx,a
  mov eax,ds:[bx+0]
  imul eax
  mov esi,eax
  mov edi,edx
  mov eax,ds:[bx+4]
  imul eax
  add esi,eax
  adc edi,edx
  mov eax,ds:[bx+8]
  imul eax
  add esi,eax
  adc edi,edx

  mov ax,seg ZeroOn
  mov es,ax
  mov ebx,10000h
  mov es:ZeroOn,@@enddiv-@@startdiv
  rept 10
    mov eax,esi
    mov edx,edi
    idiv ebx
    add ebx,eax
    shr ebx,1
  endm
@@break:
  xor eax,eax
  mov edx,1
@@startdiv:
  idiv ebx
@@enddiv:
  mov es:ZeroOn,0
  mov ecx,eax

  mov bx,word ptr a
  i=0
  rept 3
    mov eax,ds:[bx+i]
    imul ecx
    shrd eax,edx,16
    mov ds:[bx+i],eax
    i=i+4
  endm
  ret
endp

vecxmul proc uses si di ds, r:dword, a:dword, b:dword
  les di,r
  lds si,a
  lfs bx,b

  mov eax,ds:[si+8]
  imul dword ptr fs:[bx+4]
  shrd eax,edx,16
  mov ecx,eax
  mov eax,ds:[si+4]
  imul dword ptr fs:[bx+8]
  shrd eax,edx,16
  sub eax,ecx
  stosd

  mov eax,ds:[si+0]
  imul dword ptr fs:[bx+8]
  shrd eax,edx,16
  mov ecx,eax
  mov eax,ds:[si+8]
  imul dword ptr fs:[bx+0]
  shrd eax,edx,16
  sub eax,ecx
  stosd

  mov eax,ds:[si+4]
  imul dword ptr fs:[bx+0]
  shrd eax,edx,16
  mov ecx,eax
  mov eax,ds:[si+0]
  imul dword ptr fs:[bx+4]
  shrd eax,edx,16
  sub eax,ecx
  stosd

  ret
endp

veccopy proc uses si di ds, r:dword, v:dword, n:word
  cld
  lds si,v
  les di,r
  mov cx,n
  shl cx,1
  add cx,n
  rep movsd
  ret
endp

vxform macro vec
  cld
  lds si,m
  les di,r
  lfs bx,v

  cmp n,0
  je @@done
@@loop:
    y=48
    rept 3
      y=y-16
      mov eax,ds:[si+y+0]
      imul dword ptr fs:[bx+0]
      shrd eax,edx,16
      mov ecx,eax
      mov eax,ds:[si+y+4]
      imul dword ptr fs:[bx+4]
      shrd eax,edx,16
      add ecx,eax
      mov eax,ds:[si+y+8]
      imul dword ptr fs:[bx+8]
      shrd eax,edx,16
      add ecx,eax
      if vec
      add ecx,ds:[si+y+12]
      endif
      push ecx
    endm

    pop eax
    stosd
    pop eax
    stosd
    pop eax
    stosd
    add bx,12

  dec n
  jnz @@loop

@@done:
  mov ax,word ptr r
  mov dx,word ptr r+2
  ret
endm

vecxform proc uses si di ds, r:dword, v:dword, m:dword, n:word
  vxform 1
endp

vecxformvec proc uses si di ds, r:dword, v:dword, m:dword, n:word
  vxform 0
endp

vecxlate proc uses di, v:dword, n:word, dv:dword
  cld
  les di,dv
  mov eax,es:[di+0]
  mov ebx,es:[di+4]
  mov edx,es:[di+8]
  les di,v
  mov cx,n
  jcxz @@done
@@loop:
    add es:[di+0],eax
    add es:[di+4],ebx
    add es:[di+8],edx
    add di,12
  loop @@loop
@@done:
  mov ax,word ptr v
  mov dx,es
  ret
endp

vectsqr proc uses ds si di, m:dword, v:dword, v4:dword
  cld
  lds si,v
  les di,m

  mov ebx,ds:[si+0]
  mov eax,ebx
  imul ebx
  shrd eax,edx,16
  stosd
  mov eax,ds:[si+4]
  imul ebx
  shrd eax,edx,16
  stosd
  mov eax,ds:[si+8]
  imul ebx
  shrd eax,edx,16
  stosd
  mov eax,v4
  imul ebx
  shrd eax,edx,16
  stosd

  mov ebx,ds:[si+4]
  mov eax,es:[di-12]
  stosd
  mov eax,ebx
  imul ebx
  shrd eax,edx,16
  stosd
  mov eax,ds:[si+8]
  imul ebx
  shrd eax,edx,16
  stosd
  mov eax,v4
  imul ebx
  shrd eax,edx,16
  stosd

  mov ebx,ds:[si+8]
  mov eax,es:[di-24]
  stosd
  mov eax,es:[di-12]
  stosd
  mov eax,ebx
  imul ebx
  shrd eax,edx,16
  stosd
  mov eax,v4
  imul ebx
  shrd eax,edx,16
  stosd

  ret
endp

matscl proc uses ds si di, r:dword, m:dword, s:dword
  cld
  lds si,m
  les di,r
  mov ebx,s

  rept 12
    lodsd
    imul ebx
    shrd eax,edx,16
    stosd
  endm

  ret
endp

matmul proc uses ds si di, r:dword, a:dword, b:dword
  cld
  lds si,a
  les di,b

  y=48
  rept 3
    y=y-16
    x=16
    rept 4
      x=x-4
      mov eax,dword ptr ds:[si+y+0]
      imul dword ptr es:[di+0+x]
      shrd eax,edx,16
      mov ebx,eax
      mov eax,dword ptr ds:[si+y+4]
      imul dword ptr es:[di+16+x]
      shrd eax,edx,16
      add ebx,eax
      mov eax,dword ptr ds:[si+y+8]
      imul dword ptr es:[di+32+x]
      shrd eax,edx,16
      add ebx,eax
      ife x-12
	add ebx,dword ptr ds:[si+y+12]
      endif
      push ebx
    endm
  endm

  les di,r
  mov ax,ss
  mov ds,ax
  mov ax,di
  mov si,sp
  mov cx,12
  rep movsd
  add sp,48
  mov dx,es
  ret
endp

matxlate proc m:dword, v:dword
  les bx,v
  mov eax,es:[bx+0]
  mov ecx,es:[bx+4]
  mov edx,es:[bx+8]
  les bx,m
  add es:[bx+12],eax
  add es:[bx+28],ecx
  add es:[bx+44],edx
  mov ax,bx
  mov dx,es
  ret
endp

makematnorm proc uses di, m:dword
  les di,m
  mov cx,12
  xor eax,eax
  rep stosd
  sub di,48
  mov es:[di+00],65536
  mov es:[di+20],65536
  mov es:[di+40],65536
  mov ax,di
  mov dx,es
  ret
endp

makematxlate proc uses esi di, m:dword, v:dword
  les di,v
  mov ebx,es:[di+0]
  mov edx,es:[di+4]
  mov esi,es:[di+8]
  les di,m
  mov cx,12
  xor eax,eax
  rep stosd
  sub di,48
  mov es:[di+00],65536
  mov es:[di+20],65536
  mov es:[di+40],65536
  mov es:[di+12],ebx
  mov es:[di+28],edx
  mov es:[di+44],esi
  mov ax,di
  mov dx,es
  ret
endp

makematrot macro ca, cb, sa, sb
  les di,SinTab
  mov ax,a
  and ax,sintabsize-1
  shl ax,2
  add di,ax
  mov ebx,es:[di]
  sub di,ax
  mov ax,a
  add ax,sintabsize shr 2
  and ax,sintabsize-1
  shl ax,2
  add di,ax
  mov edx,es:[di]
  les di,m
  mov cx,12
  xor eax,eax
  rep stosd
  sub di,48
  mov es:[di+00],65536
  mov es:[di+20],65536
  mov es:[di+40],65536
  mov es:[di+ca],edx
  mov es:[di+cb],edx
  mov es:[di+sa],ebx
  neg ebx
  mov es:[di+sb],ebx
  mov ax,di
  mov dx,es
  ret
endm

makematrotx proc uses di, m:dword, a:word
  makematrot 20 40 24 36
endp

makematroty proc uses di, m:dword, a:word
  makematrot 40 0 32 8
endp

makematrotz proc uses di, m:dword, a:word
  makematrot 0 20 4 16
endp

end
