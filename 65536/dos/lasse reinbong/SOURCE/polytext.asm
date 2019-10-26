;// (c) 1995-1997 Niklas Beisert / pascal
;// lasse reinboeng source
;// this header must stay on top of this file
;// free for non-commercial use of any kind as long as proper credits are given.

.386
model flat,prolog
locals

.data
include polygons.inc

.code

public textureline_
textureline_ proc
  push ebp

  mov eax,ebx
  mov edx,[ebp-128].curpv[0]
  mov ebx,[ebp-128].curpv[4]
  mov esi,[ebp-128].dltpx[0]
  mov edi,[ebp-128].dltpx[4]
  rol edx,16
  rol ebx,16
  rol esi,16
  rol edi,16
  xchg bx,dx
  xchg si,di
  mov ebp,[ebp-128].par.polyTxtPtr
  xchg eax,ebp

  mov ah,dl
  mov al,bl
  sub bx,di
  add ebx,edi

@@afterloop:
    adc edx,esi
    mov al,ds:[eax]
    adc ebx,edi
    mov ah,dl
    mov ss:[ebp],al
    mov al,bl
    inc ebp
  dec ecx
  jnz @@afterloop

@@done:
  pop ebp
  ret
endp


public tex2sumline_
tex2sumline_ proc
  push ebp

  push ecx

  mov eax,ebx
  mov edx,[ebp-128].curpv[0]
  mov ebx,[ebp-128].curpv[4]
  mov esi,[ebp-128].dltpx[0]
  mov edi,[ebp-128].dltpx[4]
  rol edx,16
  rol ebx,16
  rol esi,16
  rol edi,16
  xchg bx,dx
  xchg si,di
  mov ebp,[ebp-128].par.polyTxtPtr
  xchg eax,ebp

  mov ah,dl
  mov al,bl
  sub bx,di
  add ebx,edi

@@afterloop:
    adc edx,esi
    mov al,ds:[eax]
    adc ebx,edi
    mov ah,dl
    mov ss:[ebp],al
    mov al,bl
    inc ebp
  dec ecx
  jnz @@afterloop

  pop ecx
  sub ebp,ecx
  mov eax,ebp
  pop ebp
  push ebp
;  mov ebp,[esp]

  mov edx,[ebp-128].curpv[8]
  mov ebx,[ebp-128].curpv[12]
  mov esi,[ebp-128].dltpx[8]
  mov edi,[ebp-128].dltpx[12]
  rol edx,16
  rol ebx,16
  rol esi,16
  rol edi,16
  xchg bx,dx
  xchg si,di
  mov ebp,[ebp-128].par.polyTxt2Ptr
  xchg eax,ebp

  mov ah,dl
  mov al,bl
  sub bx,di
  add ebx,edi

@@afterloopadd:
    add edx,esi
    mov al,ds:[eax]
    adc ebx,edi
    mov ah,dl
    adc dl,0
    add ss:[ebp],al
    mov al,bl
    inc ebp
  dec ecx
  jnz @@afterloopadd

@@done:
  pop ebp
  ret
endp

end
