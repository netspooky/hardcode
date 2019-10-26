;// (c) 1995-1997 Niklas Beisert / pascal
;// lasse reinboeng source
;// this header must stay on top of this file
;// free for non-commercial use of any kind as long as proper credits are given.

.386
.model flat,prolog
locals

.code

;//void sortfaces(const face *start, const face *end);
;//#pragma aux sortfaces parm [] modify [esi edi eax ebx ecx]
public sortfaces_
sortfaces_ proc pascal end:dword, start:dword
  mov esi,start
  mov edi,end

  mov ebx,edi
  sub ebx,esi
  shr ebx,1
  and ebx,not 3
  mov ebx,[esi+ebx]
  mov ecx,[ebx+8]

@@lp:
  @@lpesi:
      mov ebx,[esi]
      cmp [ebx+8],ecx
      jbe @@lpesib
      add esi,4
      cmp esi,end
      jb @@lpesi
  @@lpesib:
  @@lpedi:
      mov ebx,[edi]
      cmp [ebx+8],ecx
      jae @@lpedib
      sub edi,4
      cmp edi,start
      ja @@lpedi
  @@lpedib:
    cmp esi,edi
    ja @@fini

    mov eax,[esi]
    xchg eax,[edi]
    mov [esi],eax
    add esi,4
    sub edi,4
    jmp @@lp

@@fini:
  cmp edi,start
  jbe @@nosortedi
    push esi
    push edi
    push start
    call sortfaces_
    pop esi
@@nosortedi:
  cmp esi,end
  jae @@nosortesi
    push end
    push esi
    call sortfaces_
@@nosortesi:
@@done:
  ret
endp

;//void putpolyverts(long (*polyverts)[3], const face &f, const vert2d *vertbuf, int wrapx, int wrapy);
;//#pragma aux putpolyverts parm [edi] [edx] [esi] [ecx] [eax] modify [ebx]
public putpolyverts_
putpolyverts_ proc
  mov ch,al

  movzx ebx,word ptr [edx+0]
  mov eax,[esi+8*ebx+0]
  mov [edi+00+0],eax
  mov eax,[esi+8*ebx+4]
  mov [edi+12+0],eax

  movzx ebx,word ptr [edx+2]
  mov eax,[esi+8*ebx+0]
  mov [edi+00+4],eax
  mov eax,[esi+8*ebx+4]
  mov [edi+12+4],eax

  movzx ebx,word ptr [edx+4]
  mov eax,[esi+8*ebx+0]
  mov [edi+00+8],eax
  mov eax,[esi+8*ebx+4]
  mov [edi+12+8],eax

  cmp cl,0
  je @@nowrapx
    mov eax,[edi+00+0]
    mov ebx,[edi+00+4]
    mov edx,[edi+00+8]
    shl eax,cl
    shl ebx,cl
    shl edx,cl
    sub ebx,eax
    sub edx,eax
    sar eax,cl
    sar ebx,cl
    sar edx,cl
    add ebx,eax
    add edx,eax
    mov [edi+00+0],eax
    mov [edi+00+4],ebx
    mov [edi+00+8],edx
@@nowrapx:

  cmp ch,0
  je @@nowrapy
    mov cl,ch
    mov eax,[edi+12+0]
    mov ebx,[edi+12+4]
    mov edx,[edi+12+8]
    shl eax,cl
    shl ebx,cl
    shl edx,cl
    sub ebx,eax
    sub edx,eax
    sar eax,cl
    sar ebx,cl
    sar edx,cl
    add ebx,eax
    add edx,eax
    mov [edi+12+0],eax
    mov [edi+12+4],ebx
    mov [edi+12+8],edx
@@nowrapy:

  ret
endp

end
