org 100h

  mov    al,13h
  int    10h
  lds    ax,[bx]

  schleife:
  mov ah,[bx]
  inc bx
  mov al,[bx]
  inc byte [bx]
  add bx,ax
  jmp schleife
