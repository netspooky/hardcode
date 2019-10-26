;// (c) 1995-1997 Niklas Beisert / pascal
;// lasse reinboeng source
;// this header must stay on top of this file
;// free for non-commercial use of any kind as long as proper credits are given.

.486
model flat,prolog
locals

.code

adc_ecx macro lab
  db 081h,0D1h
    lab dd 0
endm

adc_edx macro lab
  db 081h,0D2h
    lab dd 0
endm

add_edx macro lab
  db 081h,0C2h
    lab dd 0
endm

add_ecx macro lab
  db 081h,0C1h
    lab dd 0
endm

sub_ecx macro lab
  db 081h,0E9h
    lab dd 0
endm

add_edi macro lab
  db 081h,0C7h
    lab dd 0
endm

textureblock proc
  add_ecx beforedfy0
  mov bh,dl
  adc dl,0
  mov bl,cl

@@block:
    add_edx dfx0dy0_0
    mov al,[ebx]
    adc_ecx dfy0dx0_0
    mov bh,dl
    mov bl,cl
    adc_edx dfx0dy0_1
    mov ah,[ebx]
    adc_ecx dfy0dx0_1
    mov bh,dl
    bswap eax
    mov bl,cl

    adc_edx dfx0dy0_2
    mov ah,[ebx]
    adc_ecx dfy0dx0_2
    mov bh,dl
    mov bl,cl
    adc_edx dfx0dy0_3
    mov al,[ebx]
    adc_ecx dfy0dx0_3
    mov bh,dl
    bswap eax
    adc dl,0
    op0 db 089h,007h ;//op [edi],eax
    mov bl,cl

    add_edx dfx0dy0_4
    mov al,[ebx]
    adc_ecx dfy0dx0_4
    mov bh,dl
    mov bl,cl
    adc_edx dfx0dy0_5
    mov ah,[ebx]
    adc_ecx dfy0dx0_5
    mov bh,dl
    bswap eax
    mov bl,cl

    adc_edx dfx0dy0_6
    mov ah,[ebx]
    adc_ecx dfy7dx0
    mov bh,dl
    mov bl,cl
    adc_edx dfx7dy7
    mov al,[ebx]
    adc_ecx dfy0dx7
    mov bh,dl
    bswap eax
    adc dl,0
    op1 db 089h,047h,004h ;//op [edi+4],eax
    mov bl,cl

    add_edi scrwidth
  dec esi
  jnz @@block

  sub_ecx afterdfy0
  sbb dl,0

  ret
endp

public texturescreen_

texturescreen_ proc dst:dword, src:dword, x0:dword, y0:dword, xx:dword, xy:dword, yx:dword, yy:dword, xblocks:dword, yblocks:dword, scrwid:dword, op:dword
local c1:dword, c2:dword, retxf1:dword, retyf1:dword, retsp1:dword, retxf2:dword, retyf2:dword, retsp2:dword, retxi1:byte, retyi1:byte, retxi2:byte, retyi2:byte
  lea edi,textureblock+128

  mov eax,scrwid
  mov [edi-128+scrwidth-textureblock],eax

  mov al,byte ptr op
  mov [edi-128+op0-textureblock],al
  mov [edi-128+op1-textureblock],al

  mov eax,xx
  shl eax,16
  mov al,byte ptr xy+2
  mov [edi-128+dfx0dy0_0-textureblock],eax
  mov [edi-128+dfx0dy0_1-textureblock],eax
  mov [edi-128+dfx0dy0_2-textureblock],eax
  mov [edi-128+dfx0dy0_3-textureblock],eax
  mov [edi-128+dfx0dy0_4-textureblock],eax
  mov [edi-128+dfx0dy0_5-textureblock],eax
  mov [edi-128+dfx0dy0_6-textureblock],eax
  mov ebx,xy
  shl ebx,3
  sub ebx,xy
  neg ebx
  add ebx,yy
  shr ebx,16
  mov al,bl
  mov ebx,xx
  shl ebx,19
  sub eax,ebx
  mov ebx,yx
  shl ebx,16
  add eax,ebx
  mov [edi-128+dfx7dy7-textureblock],eax

  mov eax,xy
  shl eax,16
  mov [edi-128+beforedfy0-textureblock],eax
  mov [edi-128+afterdfy0-textureblock],eax
  mov al,byte ptr xx+2
  mov [edi-128+dfy0dx0_0-textureblock],eax
  mov [edi-128+dfy0dx0_1-textureblock],eax
  mov [edi-128+dfy0dx0_2-textureblock],eax
  mov [edi-128+dfy0dx0_3-textureblock],eax
  mov [edi-128+dfy0dx0_4-textureblock],eax
  mov [edi-128+dfy0dx0_5-textureblock],eax
  mov ebx,xx
  shl ebx,3
  sub ebx,xx
  neg ebx
  add ebx,yx
  shr ebx,16
  mov al,bl
  mov [edi-128+dfy0dx7-textureblock],eax
  mov ebx,xy
  shl ebx,19
  sub eax,ebx
  mov ebx,yy
  shl ebx,16
  add eax,ebx
  mov al,byte ptr xx+2
  mov [edi-128+dfy7dx0-textureblock],eax

  shl xx,3
  shl xy,3
  shl yx,3
  shl yy,3

  mov eax,xx
  cdq
  xor eax,edx
  sub eax,edx
  mov ebx,eax
  mov eax,xy
  cdq
  xor eax,edx
  sub eax,edx
  cmp ebx,eax
  jle @@vert

@@horz:
  mov eax,xx
  sub eax,yx
  rol eax,16
  mov retxi1,al
  and eax,not 65535
  mov retxf1,eax

  mov eax,xy
  sub eax,yy
  rol eax,16
  mov retyi1,al
  and eax,not 65535
  mov retyf1,eax

  mov eax,scrwid
  neg eax
  inc eax
  shl eax,3
  mov retsp1,eax

  mov eax,xblocks
  neg eax
  imul xx
  add eax,yx
  rol eax,16
  mov retxi2,al
  and eax,not 65535
  mov retxf2,eax

  mov eax,xblocks
  neg eax
  imul xy
  add eax,yy
  rol eax,16
  mov retyi2,al
  and eax,not 65535
  mov retyf2,eax

  mov eax,xblocks
  neg eax
  add eax,scrwid
  shl eax,3
  mov retsp2,eax

  mov ebx,src
  mov edi,dst

  mov edx,x0
  rol edx,16
  mov ecx,y0
  rol ecx,16
  xchg cl,dl

  mov eax,yblocks
  mov c1,eax
@@l1:
    mov eax,xblocks
    mov c2,eax
  @@l2:
      mov esi,8
      call textureblock
      add edx,retxf1
      adc cl,retxi1
      add ecx,retyf1
      adc dl,retyi1
      add edi,retsp1
    dec c2
    jnz @@l2

    add edx,retxf2
    adc cl,retxi2
    add ecx,retyf2
    adc dl,retyi2
    add edi,retsp2
  dec c1
  jnz @@l1
  jmp @@done

@@vert:
  mov eax,yblocks
  neg eax
  imul eax,yx
  add eax,xx
  rol eax,16
  mov retxi1,al
  and eax,not 65535
  mov retxf1,eax

  mov eax,yblocks
  neg eax
  imul eax,yy
  add eax,xy
  rol eax,16
  mov retyi1,al
  and eax,not 65535
  mov retyf1,eax

  mov eax,yblocks
  neg eax
  imul scrwid
  inc eax
  shl eax,3
  mov retsp1,eax

  mov ebx,src
  mov edi,dst

  mov edx,x0
  rol edx,16
  mov ecx,y0
  rol ecx,16
  xchg cl,dl

  mov eax,xblocks
  mov c1,eax
@@l3:
    mov esi,yblocks
    shl esi,3
    call textureblock
    add edx,retxf1
    adc cl,retxi1
    add ecx,retyf1
    adc dl,retyi1
    add edi,retsp1
  dec c1
  jnz @@l3

@@done:
  ret
endp

end
