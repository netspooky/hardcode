; Paleta - prawie tak jak u Khamoona
  mov dx,3C8h
  xor ax,ax
  out dx,al
  inc dx
Pal:
  mov al,ah
  shr al,2
  out dx,al
  out dx,al
  shr al,1
  out dx,al
  inc ah
  jnz Pal
