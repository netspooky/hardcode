;// (c) 1995-1997 Niklas Beisert / pascal
;// lasse reinboeng source
;// this header must stay on top of this file
;// free for non-commercial use of any kind as long as proper credits are given.

.386
model flat,prolog
locals

.code

plasmarand proc
  push eax
  mov eax,015A4E35h
  imul eax,ebp
  inc eax
  mov ebp,eax
  pop eax
  mov ecx,ebp
  sar ecx,16
  ret
endp

plasmaput proc
  imul ecx,edi
  sar ecx,17
  add eax,ecx
  add eax,2
  sar eax,2
  jns @@nbelow1
    xor eax,eax
@@nbelow1:
  cmp eax,esi
  jb @@nabove1
    mov eax,esi
@@nabove1:
  mov [ebx],al
  ret
endp

public txPlasmaMap_
txPlasmaMap_ proc
  push ebp
  mov ebp,eax
  mov eax,-1
  shl eax,cl
  not eax
  mov esi,eax
  call plasmarand
  and ecx,esi
  mov byte ptr [ebx],cl
  mov edx,0080h
@@l1:
  @@l2a:
    @@l2b:
        movzx eax,byte ptr [ebx]
        add bl,dh
        add al,[ebx]
        adc ah,0
        add bh,dh
        add al,[ebx]
        adc ah,0
        sub bl,dh
        add al,[ebx]
        adc ah,0
        sub bh,dl
        add bl,dl
        call plasmarand
        lea ecx,[ecx+ecx*2]
        call plasmaput
        sub bh,dl
        add bl,dl
      jnz @@l2b
    add bh,dh
    jnz @@l2a

  @@l3a:
    @@l3b:
        movzx eax,byte ptr [ebx]
        add bh,dh
        add al,[ebx]
        adc ah,0
        sub bh,dl
        add bl,dl
        add al,[ebx]
        adc ah,0
        sub bl,dh
        add al,[ebx]
        adc ah,0
        add bl,dl
        call plasmarand
        add ecx,ecx
        call plasmaput
        sub bh,dl

        movzx eax,byte ptr [ebx]
        add bl,dh
        add al,[ebx]
        adc ah,0
        sub bl,dl
        add bh,dl
        add al,[ebx]
        adc ah,0
        sub bh,dh
        add al,[ebx]
        adc ah,0
        add bh,dl
        call plasmarand
        add ecx,ecx
        call plasmaput
        add bl,dl
      jnz @@l3b
    add bh,dh
    jnz @@l3a

    sar edi,1
    mov dh,dl
    shr dl,1
  jnz @@l1
  pop ebp
  ret
endp

public txTwirlify_
txTwirlify_ proc
  push ebp
  mov ebp,eax
  sub esi,ebx
  sub ebp,ebx
  sub edi,ebx
@@lp:
    mov eax,ebx
    mov dl,[ebx+esi]
    mov cl,[ebx+ebp]
    add al,[edx]
    add ah,[ecx]
    mov al,[eax]
    mov [ebx+edi],al
    inc ebx
  test ebx,0FFFFh
  jne @@lp
  pop ebp
  ret
endp

public txSmoothMap_
txSmoothMap_ proc
  mov ecx,9
@@lp:
    xor eax,eax
    add al,[ebx]
    adc ah,0
    dec bh
    add al,[ebx]
    adc ah,0
    dec bl
    add al,[ebx]
    adc ah,0
    inc bh
    add al,[ebx]
    adc ah,0
    inc bh
    add al,[ebx]
    adc ah,0
    inc bl
    add al,[ebx]
    adc ah,0
    inc bl
    add al,[ebx]
    adc ah,0
    dec bh
    add al,[ebx]
    adc ah,0
    dec bh
    add al,[ebx]
    adc ah,0
    inc bh
    dec bl
    xor edx,edx
    idiv ecx
    stosb
  inc bx
  jne @@lp
  ret
endp

end
