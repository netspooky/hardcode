;// (c) 1995-1997 Niklas Beisert / pascal
;// lasse reinboeng source
;// this header must stay on top of this file
;// free for non-commercial use of any kind as long as proper credits are given.

.486
model flat,prolog
locals

.code

public wobbletunnel_
wobbletunnel_ proc
  shr edx,1
  mov ecx,ebx
  push ebp
  mov ebp,25
@@lineloop1:
    push ebp
    mov ebp,40
  @@lineloop2:
      push ebp
      mov ebp,8
    @@lineloop3:
        i=0
        mov bx,[esi+2*i+4]
        mov cx,[esi+2*i+6]
        mov dl,bh
        add bx,[2*edx]
        mov dl,ch
        add cx,[2*edx]
        mov ah,[ebx]
        mov bx,[esi+2*i+0]
        mov al,[ecx]
        mov cx,[esi+2*i+2]
        mov dl,bh
        bswap eax
        add bx,[2*edx]
        mov dl,ch
        add cx,[2*edx]
        mov al,[ebx]
        mov bx,[esi+12]
        mov ah,[ecx]
        mov cx,[esi+14]
        mov dl,bh
        mov [edi],eax
        add bx,[2*edx]
        mov dl,ch
        add cx,[2*edx]
        mov ah,[ebx]
        mov bx,[esi+8]
        mov al,[ecx]
        mov cx,[esi+10]
        mov dl,bh
        bswap eax
        add bx,[2*edx]
        mov dl,ch
        add cx,[2*edx]
        mov al,[ebx]
        mov ah,[ecx]
        mov [edi+4],eax

        add esi,16
        add edi,320
      dec ebp
      jnz @@lineloop3
      add edi,8-320*8
      pop ebp
    dec ebp
    jnz @@lineloop2
    add edi,8*320-320
    pop ebp
  dec ebp
  jnz @@lineloop1
  pop ebp
  ret
endp

end
