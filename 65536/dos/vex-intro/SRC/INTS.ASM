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



;// 16 bit fixed point routines, takes care of division by zero

.model large, c
.386
locals

.code

public IntMul
public IntSqr
public IntDiv
public IntSqrt
public IntMulDiv
public IntVecMul
public IntVecSqr
public InstallZeroDivide
public DeinstallZeroDivide
public ZeroOn

OldZeroDivide dd 0
ZeroOn dw 0

IntMul proc a:dword, b:dword
  mov eax,a
  imul b
  shr eax,16
  ret
IntMul endp

IntSqr proc a:dword
  mov eax,a
  imul a
  shr eax,16
  ret
IntSqr endp

IntDiv proc a:dword, b:dword
  mov eax,a
  mov edx,eax
  shl eax,16
  sar edx,16
  mov cs:ZeroOn,@@enddiv-@@startdiv
@@startdiv:
  idiv b
@@enddiv:
  mov cs:ZeroOn,0
  shld edx,eax,16
  ret
IntDiv endp

IntSqrt proc uses esi edi ebx, a:dword
  mov esi,a
  mov edi,esi
  shl esi,16
  sar edi,16
  mov ebx,10000h
  mov cx,12
  mov cs:ZeroOn,@@enddiv-@@startdiv
@@l:
  mov eax,esi
  mov edx,edi
@@startdiv:
  idiv ebx
@@enddiv:
  add ebx,eax
  shr ebx,1
  loop @@l
  mov cs:ZeroOn,0
  mov eax,ebx
  shld edx,eax,16
  ret
IntSqrt endp

IntMulDiv proc a:dword, b:dword, c:dword
  mov eax,a
  imul b
  mov cs:ZeroOn,@@enddiv-@@startdiv
@@startdiv:
  idiv c
@@enddiv:
  mov cs:ZeroOn,0
  shld edx,eax,16
  ret
IntMulDiv endp

IntVecMul proc uses ds si di, a:dword, b:dword
  lds si,a
  les di,b
  cld
  lodsd
  imul dword ptr es:[di]
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
IntVecMul endp

IntVecSqr proc uses ds si, a:dword
  lds si,a
  lodsd
  imul dword ptr [si-4]
  mov ecx,eax
  mov ebx,edx
  lodsd
  imul dword ptr [si-4]
  add ecx,eax
  adc ebx,edx
  lodsd
  imul dword ptr [si-4]
  add eax,ecx
  adc edx,ebx
  shr eax,16
  ret
IntVecSqr endp

InstallZeroDivide proc uses ds
  mov ax,3500h
  int 21h
  mov cs:word ptr OldZeroDivide,bx
  mov cs:word ptr OldZeroDivide+2,es
  mov ax,2500h
  push cs
  pop ds
  mov dx,offset ZeroDivide
  int 21h
  ret
InstallZeroDivide endp

DeinstallZeroDivide proc uses ds
  mov ax,2500h
  mov dx,cs:word ptr OldZeroDivide
  mov ds,cs:word ptr OldZeroDivide+2
  int 21h
  ret
DeinstallZeroDivide endp

ZeroDivide proc
  cmp cs:ZeroOn,0
  jnz @@correctit
  jmp cs:OldZeroDivide
@@correctit:
  mov eax,7FFFFFFFh
  push bp
  push ax
  mov bp,sp
  mov ax,cs:ZeroOn
  add ss:word ptr [bp+4], ax
  pop ax
  pop bp
  iret
ZeroDivide endp

end
