;Wellen 64b
;64 byte intro source by T$
;Greets to mados, cthulhu and neo

org 100h

  mov    al,13h
  int    10h
  lds    ax,[bx]

  mov    dx,3C9h
  mov    ch,3
  locloop_1:
  ror    eax,8
  cmp    al,3Fh
  jb     loc_2
  mov    al,3Fh
  inc    ah
  loc_2:
  test   cl,3
  jz     loc_3
  out    dx,al
  loc_3:
  loop   locloop_1

  schleife:
 
  mov al,[di]
  imul ax,320
  mov bl,[bx]
  xor bh,bh
  add bx,ax
  dec byte [bx] ;inc ist auch gut
  sub di,cx

  loop schleife
  loop schleife
