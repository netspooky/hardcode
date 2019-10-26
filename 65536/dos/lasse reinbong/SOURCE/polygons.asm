;// (c) 1995-1997 Niklas Beisert / pascal
;// lasse reinboeng source
;// this header must stay on top of this file
;// free for non-commercial use of any kind as long as proper credits are given.

.386
model flat,prolog
locals

.data

include polygons.inc

polyLocals polyloc <>
_polyPar polypar <>

.code

drawtrigon macro fnname,PARMS,BACKWARDS,CLIP,USEW32,MINAREA
public fnname
fnname proc
  push ebp

  lea ebp,polyLocals+128

;// get top point, sort by y-coord, round&clip y-coords.
  mov edi,[ebp-128].par.polyCoords
  sub edi,ebp

  mov eax,[ebp+edi+00+0]
  mov ebx,[ebp+edi+00+4]
  mov ecx,[ebp+edi+00+8]
  mov edx,[ebp+edi+12+0]
  mov esi,[ebp+edi+12+4]
  mov edi,[ebp+edi+12+8]

  cmp eax,ebx
  jg @@top1
    cmp eax,ecx
    jle @@top2
      mov [ebp-128].toppointpar,24+8
      jmp @@order1
  @@top2:
      mov [ebp-128].toppointpar,24+0
      jmp @@order1
@@top1:
    cmp ebx,ecx
    jle @@top3
      mov [ebp-128].toppointpar,24+8
      jmp @@toporder
  @@top3:
      mov [ebp-128].toppointpar,24+4

@@toporder:
    xchg eax,ebx
    xchg edx,esi
@@order1:
  cmp eax,ecx
  jle @@order2
    xchg eax,ecx
    xchg edx,edi
@@order2:
  cmp ebx,ecx
  jle @@order3
    xchg ebx,ecx
    xchg esi,edi
@@order3:

  mov [ebp-128].coords[00+0],eax
  mov [ebp-128].coords[00+4],ebx
  mov [ebp-128].coords[00+8],ecx
  mov [ebp-128].coords[12+0],edx
  mov [ebp-128].coords[12+4],esi
  mov [ebp-128].coords[12+8],edi

  add eax,0ffffh
  add ebx,0ffffh
  add ecx,0ffffh
  sar eax,16
  sar ebx,16
  sar ecx,16

if CLIP
  cmp eax,[ebp-128].par.polyMaxY
  jge @@done
  cmp ecx,[ebp-128].par.polyMinY
  jle @@done
  cmp eax,[ebp-128].par.polyMinY
  jge @@clipy1
    mov eax,[ebp-128].par.polyMinY
@@clipy1:
  cmp ecx,[ebp-128].par.polyMaxY
  jle @@clipy2
    mov ecx,[ebp-128].par.polyMaxY
@@clipy2:
endif

  cmp eax,ecx
  je @@done

  mov [ebp-128].currow,eax
  mov [ebp-128].midrow,ebx
  mov [ebp-128].endrow,ecx

;// calc parameter delta values
  mov edi,[ebp-128].par.polyCoords
  sub edi,ebp
  add [ebp-128].toppointpar,edi

  mov eax,[ebp+edi+00+8]
  mov edx,[ebp+edi+12+4]
  sub eax,[ebp+edi+00+0]
  sub edx,[ebp+edi+12+0]
  mov [ebp-128].diffy3,eax
  mov [ebp-128].diffx2,edx
  imul edx
  mov ecx,eax
  mov ebx,edx
  mov eax,[ebp+edi+00+4]
  mov edx,[ebp+edi+12+8]
  sub eax,[ebp+edi+00+0]
  sub edx,[ebp+edi+12+0]
  mov [ebp-128].diffy2,eax
  mov [ebp-128].diffx3,edx
  imul edx
  sub eax,ecx
  sbb edx,ebx
  mov [ebp-128].shiftdown,0
  shrd eax,edx,15
  sar edx,15
@@adjustloop:
    lea ebx,[edx+1]
    cmp ebx,1
    jbe @@adjusted
    shrd eax,edx,4
    sar edx,4
    add [ebp-128].shiftdown,4
  jmp @@adjustloop
@@adjusted:
  shrd eax,edx,1
  jz @@done
  cmp eax,MINAREA
  jb @@deltazero
  cmp eax,-MINAREA
  ja @@deltazero

  mov [ebp-128].widthconst,eax
;// check this!

  add edi,24
  xor esi,esi
@@deltaloop:
    mov eax,[ebp+edi+8]
    sub eax,[ebp+edi+0]
    imul [ebp-128].diffx2
    mov ecx,eax
    mov ebx,edx
    mov eax,[ebp+edi+4]
    sub eax,[ebp+edi+0]
    imul [ebp-128].diffx3
    sub eax,ecx
    sbb edx,ebx
    mov cl,[ebp-128].shiftdown
    shrd eax,edx,cl
    sar edx,cl
    idiv [ebp-128].widthconst
    mov [ebp-128].dltpy[esi],eax

    mov eax,[ebp+edi+4]
    sub eax,[ebp+edi+0]
    imul [ebp-128].diffy3
    mov ecx,eax
    mov ebx,edx
    mov eax,[ebp+edi+8]
    sub eax,[ebp+edi+0]
    imul [ebp-128].diffy2
    sub eax,ecx
    sbb edx,ebx
    mov cl,[ebp-128].shiftdown
    shrd eax,edx,cl
    sar edx,cl
    idiv [ebp-128].widthconst
    mov [ebp-128].dltpx[esi],eax

    add edi,12
    add esi,4
  cmp esi,PARMS*4
  jnz @@deltaloop
@@deltacalced:

;// calc x values for segment 1 (top->bottom) -> x1
  mov ecx,[ebp-128].coords[00+0]
  mov ebx,[ebp-128].currow
  shl ebx,16
  sub ebx,ecx
  sub ecx,[ebp-128].coords[00+8]
  mov eax,[ebp-128].coords[12+0]
  sub eax,[ebp-128].coords[12+8]

  cmp ecx,10000h
  je @@seg1tiny

  mov edx,eax
  sar edx,16
  shl eax,16
  idiv ecx
  mov [ebp-128].dltx1,eax
  imul ebx
  shrd eax,edx,16
  add eax,[ebp-128].coords[12+0]
  mov [ebp-128].curx1,eax

@@doseg2:
  mov edx,[ebp-128].midrow
  cmp edx,[ebp-128].currow
  jle @@doseg3

;// calc x values for segment 2 (top->middle) -> x2
  mov ecx,[ebp-128].coords[00+0]
  mov ebx,[ebp-128].currow
  shl ebx,16
  sub ebx,ecx
  sub ecx,[ebp-128].coords[00+4]
  mov eax,[ebp-128].coords[12+0]
  sub eax,[ebp-128].coords[12+4]

  cmp ecx,10000h
  je @@seg2tiny

  mov edx,eax
  sar edx,16
  shl eax,16
  idiv ecx
  mov [ebp-128].dltx2,eax
  imul ebx
  shrd eax,edx,16
  add eax,[ebp-128].coords[12+0]
  mov [ebp-128].curx2,eax

@@seg2chk:
  mov eax,[ebp-128].dltx1
  cmp eax,[ebp-128].dltx2
ife BACKWARDS
  jl @@noswapseg2
else
  jg @@noswapseg2
endif
    xchg [ebp-128].dltx2,eax
    mov ebx,[ebp-128].curx1
    mov [ebp-128].dltx1,eax
    xchg [ebp-128].curx2,ebx
    mov [ebp-128].calcseg3,offset @@doseg31
    mov [ebp-128].curx1,ebx
    jmp @@segsok
@@noswapseg2:
    mov [ebp-128].calcseg3,offset @@doseg32
    jmp @@segsok

@@doseg3:
;// calc x values for segment 3 (middle->bottom) -> x2
  mov ecx,[ebp-128].coords[00+4]
  mov ebx,[ebp-128].currow
  shl ebx,16
  sub ebx,ecx
  sub ecx,[ebp-128].coords[00+8]
  mov eax,[ebp-128].coords[12+4]
  sub eax,[ebp-128].coords[12+8]

  cmp ecx,10000h
  jb @@seg3tiny

  mov edx,eax
  sar edx,16
  shl eax,16
  idiv ecx
  mov [ebp-128].dltx2,eax
  imul ebx
  shrd eax,edx,16
  add eax,[ebp-128].coords[12+4]
  mov [ebp-128].curx2,eax

@@seg3chk:
  mov eax,[ebp-128].dltx1
  cmp eax,[ebp-128].dltx2
ife BACKWARDS
  jg @@segsok
else
  jl @@segsok
endif
    xchg [ebp-128].dltx2,eax
    mov ebx,[ebp-128].curx1
    mov [ebp-128].dltx1,eax
    xchg [ebp-128].curx2,ebx
    mov [ebp-128].curx1,ebx
@@segsok:

;// calc first row x-clipping
  mov ebx,[ebp-128].curx1
  mov ecx,[ebp-128].curx2
  add ebx,0ffffh
  add ecx,0ffffh
  sar ebx,16
  sar ecx,16

if CLIP
ife BACKWARDS
  cmp ebx,[ebp-128].par.polyMaxX
  jl @@clipx1b
    mov ebx,[ebp-128].par.polyMaxX
    mov ecx,[ebp-128].par.polyMaxX
    jmp @@clipx4b
@@clipx1b:
  cmp ecx,[ebp-128].par.polyMinX
  jg @@clipx2b
    mov ebx,[ebp-128].par.polyMinX
    mov ecx,[ebp-128].par.polyMinX
    jmp @@clipx4b
@@clipx2b:
  cmp ebx,[ebp-128].par.polyMinX
  jge @@clipx3b
    mov ebx,[ebp-128].par.polyMinX
@@clipx3b:
  cmp ecx,[ebp-128].par.polyMaxX
  jle @@clipx4b
    mov ecx,[ebp-128].par.polyMaxX
@@clipx4b:
else
  cmp ecx,[ebp-128].par.polyMaxX
  jl @@clipx1b
    mov ebx,[ebp-128].par.polyMaxX
    mov ecx,[ebp-128].par.polyMaxX
    jmp @@clipx4b
@@clipx1b:
  cmp ebx,[ebp-128].par.polyMinX
  jg @@clipx2b
    mov ebx,[ebp-128].par.polyMinX
    mov ecx,[ebp-128].par.polyMinX
    jmp @@clipx4b
@@clipx2b:
  cmp ecx,[ebp-128].par.polyMinX
  jge @@clipx3b
    mov ecx,[ebp-128].par.polyMinX
@@clipx3b:
  cmp ebx,[ebp-128].par.polyMaxX
  jle @@clipx4b
    mov ebx,[ebp-128].par.polyMaxX
@@clipx4b:
endif
endif

  sub ecx,ebx
if BACKWARDS
  neg ecx
endif

  mov [ebp-128].lastx1,ebx

;// calc parameter start values
  shl ebx,16
  sub ebx,[ebp-128].coords[12]
  mov [ebp-128].diffx1,ebx

  mov ebx,[ebp-128].currow
  shl ebx,16
  sub ebx,[ebp-128].coords[00]
  mov [ebp-128].diffy1,ebx

  mov edi,[ebp-128].toppointpar
  xor esi,esi

@@startloop:
    mov eax,[ebp-128].dltpy[esi]
    imul [ebp-128].diffy1
    shrd eax,edx,16
    mov ebx,eax
    mov eax,[ebp-128].dltpx[esi]
    imul [ebp-128].diffx1
    shrd eax,edx,16
    add eax,ebx
    add eax,[ebp+edi]
    mov [ebp-128].curpv[esi],eax
    add esi,4
    add edi,12
  cmp esi,PARMS*4
  jne @@startloop

  mov ebx,[ebp-128].lastx1

;// calc parameter cache values
  mov edi,[ebp-128].dltx1
  sar edi,16
  mov [ebp-128].cachex,edi
  inc edi
  mov [ebp-128].cachex1,edi
  dec edi

  xor esi,esi
@@cacheloop:
    mov eax,[ebp-128].dltpx[esi]
    imul eax,edi
    mov [ebp-128].cachedltpx[esi],eax
    add esi,4
  cmp esi,PARMS*4
  jne @@cacheloop

  mov eax,[ebp-128].currow
  imul eax,[ebp-128].par.polyScrWid
  add eax,[ebp-128].par.polyScrPtr
  mov [ebp-128].scrpos,eax

;// start drawing
  jmp @@rowloop

    i=0
  @@cachex1:
      rept PARMS
        mov eax,[ebp-128].cachedltpx[i]
        add eax,[ebp-128].dltpy[i]
        add eax,[ebp-128].dltpx[i]
        add [ebp-128].curpv[i],eax
        i=i+4
      endm

@@rowloop:
    cmp ecx,0
    jle @@nodraw
;// draw row

      add ebx,[ebp-128].scrpos
if USEW32
      mov eax,ebx
if BACKWARDS
      sub eax,ecx
endif
      and eax,not 3
      sub ebx,eax
      add ebx,0b8000h
      mov ss:[0bff00h],eax
endif
      call [ebp-128].par.polyDrawLine

  @@nodraw:
    mov eax,[ebp-128].dltx1
    mov ebx,[ebp-128].dltx2
    add [ebp-128].curx1,eax
    add [ebp-128].curx2,ebx
    mov eax,[ebp-128].par.polyScrWid
    add [ebp-128].scrpos,eax
    inc [ebp-128].currow
    mov eax,[ebp-128].currow
    cmp eax,[ebp-128].endrow
    je @@done
    cmp eax,[ebp-128].midrow
    jne @@nosegchange
      jmp [ebp-128].calcseg3
  @@nosegchange:

;// get x coords of next row
    mov ebx,[ebp-128].curx1
    mov ecx,[ebp-128].curx2
    add ebx,0ffffh
    add ecx,0ffffh
    sar ebx,16
    sar ecx,16

;// clip x-coordinates
  if CLIP
  ife BACKWARDS
    cmp ebx,[ebp-128].par.polyMaxX
    jl @@clipx1
      mov ebx,[ebp-128].par.polyMaxX
      xor ecx,ecx
      jmp @@cache0
  @@clipx1:
    cmp ecx,[ebp-128].par.polyMinX
    jg @@clipx2
      mov ebx,[ebp-128].par.polyMinX
      xor ecx,ecx
      jmp @@cache0
  @@clipx2:
    cmp ebx,[ebp-128].par.polyMinX
    jge @@clipx3
      mov ebx,[ebp-128].par.polyMinX
  @@clipx3:
    cmp ecx,[ebp-128].par.polyMaxX
    jle @@clipx4
      mov ecx,[ebp-128].par.polyMaxX
  @@clipx4:
  else
    cmp ecx,[ebp-128].par.polyMaxX
    jl @@clipx1
      mov ebx,[ebp-128].par.polyMaxX
      xor ecx,ecx
      jmp @@cache0
  @@clipx1:
    cmp ebx,[ebp-128].par.polyMinX
    jg @@clipx2
      mov ebx,[ebp-128].par.polyMinX
      xor ecx,ecx
      jmp @@cache0
  @@clipx2:
    cmp ecx,[ebp-128].par.polyMinX
    jge @@clipx3
      mov ecx,[ebp-128].par.polyMinX
  @@clipx3:
    cmp ebx,[ebp-128].par.polyMaxX
    jle @@clipx4
      mov ebx,[ebp-128].par.polyMaxX
  @@clipx4:
  endif
  endif
    sub ecx,ebx
  if BACKWARDS
    neg ecx
  endif

;// update parameters
    mov edi,ebx
    sub edi,[ebp-128].lastx1
    jz @@cache0
    mov [ebp-128].lastx1,ebx

    cmp edi,[ebp-128].cachex1
    je @@cachex1
    cmp edi,[ebp-128].cachex
    jne @@uncached

    @@cachex:
      i=0
      rept PARMS
        mov eax,[ebp-128].cachedltpx[i]
        add eax,[ebp-128].dltpy[i]
        add [ebp-128].curpv[i],eax
        i=i+4
      endm
      jmp @@rowloop

    @@cache0:
      i=0
      rept PARMS
        mov eax,[ebp-128].dltpy[i]
        add [ebp-128].curpv[i],eax
        i=i+4
      endm
      jmp @@rowloop

    @@uncached:
      i=0
      rept PARMS
        mov eax,[ebp-128].dltpx[i]
        imul eax,edi
        add eax,[ebp-128].dltpy[i]
        add [ebp-128].curpv[i],eax
        i=i+4
      endm
      jmp @@rowloop

@@done:
  pop ebp
  ret

@@doseg31:
;// calc x values for segment 3 (middle->bottom) -> x1
  mov ecx,[ebp-128].coords[00+4]
  mov ebx,[ebp-128].currow
  shl ebx,16
  sub ebx,ecx
  sub ecx,[ebp-128].coords[00+8]
  mov eax,[ebp-128].coords[12+4]
  sub eax,[ebp-128].coords[12+8]

  cmp ecx,10000h
  jb @@seg31tiny

  mov edx,eax
  sar edx,16
  shl eax,16
  idiv ecx
  mov [ebp-128].dltx1,eax
  imul ebx
  shrd eax,edx,16
  add eax,[ebp-128].coords[12+4]
  mov [ebp-128].curx1,eax

;// calc cache
  mov edi,[ebp-128].dltx1
  sar edi,16
  mov [ebp-128].cachex,edi
  inc edi
  mov [ebp-128].cachex1,edi
  dec edi

  xor esi,esi
@@calccache31:
    mov eax,[ebp-128].dltpx[esi]
    imul eax,edi
    mov [ebp-128].cachedltpx[esi],eax
    add esi,4
  cmp esi,PARMS*4
  jne @@calccache31
  jmp @@nosegchange

@@doseg32:
;// calc x values for segment 3 (middle->bottom) -> x2
  mov ecx,[ebp-128].coords[00+4]
  mov ebx,[ebp-128].currow
  shl ebx,16
  sub ebx,ecx
  sub ecx,[ebp-128].coords[00+8]
  mov eax,[ebp-128].coords[12+4]
  sub eax,[ebp-128].coords[12+8]

  cmp ecx,10000h
  jb @@seg32tiny

  mov edx,eax
  sar edx,16
  shl eax,16
  idiv ecx
  mov [ebp-128].dltx2,eax
  imul ebx
  shrd eax,edx,16
  add eax,[ebp-128].coords[12+4]
  mov [ebp-128].curx2,eax
  jmp @@nosegchange

@@seg31tiny:
  imul ebx
  idiv ecx
  add eax,[ebp-128].coords[12+4]
  mov [ebp-128].curx1,eax
  jmp @@nosegchange

@@seg32tiny:
  imul ebx
  idiv ecx
  add eax,[ebp-128].coords[12+4]
  mov [ebp-128].curx2,eax
  jmp @@nosegchange

@@seg1tiny:
  js @@s1sgn
    mov [ebp-128].dltx1,040000000h
    jmp @@s1usgn
@@s1sgn:
    mov [ebp-128].dltx1,0C0000000h
@@s1usgn:
  imul ebx
  idiv ecx
  add eax,[ebp-128].coords[12+0]
  mov [ebp-128].curx1,eax
  jmp @@doseg2

@@seg2tiny:
  js @@s2sgn
    mov [ebp-128].dltx2,040000000h
    jmp @@s2usgn
@@s2sgn:
    mov [ebp-128].dltx2,0C0000000h
@@s2usgn:
  imul ebx
  idiv ecx
  add eax,[ebp-128].coords[12+0]
  mov [ebp-128].curx2,eax
  jmp @@seg2chk

@@seg3tiny:
  js @@s3sgn
    mov [ebp-128].dltx2,040000000h
    jmp @@s3usgn
@@s3sgn:
    mov [ebp-128].dltx2,0C0000000h
@@s3usgn:
  imul ebx
  idiv ecx
  add eax,[ebp-128].coords[12+4]
  mov [ebp-128].curx2,eax
  jmp @@seg3chk

@@deltazero:
  add edi,24
  xor esi,esi
  xor eax,eax
@@deltazeroloop:
    mov [ebp-128].dltpy[esi],eax
    mov [ebp-128].dltpx[esi],eax
    add edi,12
    add esi,4
  cmp esi,PARMS*4
  jnz @@deltazeroloop
  jmp @@deltacalced
endp
endm

;//drawtrigon drawtrigon1CB_,1,1,1,0,32768
;//drawtrigon drawtrigon1CBW_,1,1,1,1,32768
;//drawtrigon drawtrigon2CB_,2,1,1,0,32768
;//drawtrigon drawtrigon2CBW_,2,1,1,1,32768
drawtrigon drawtrigon2C_,2,0,1,0,32768*4
drawtrigon drawtrigon4C_,4,0,1,0,32768*4

end
