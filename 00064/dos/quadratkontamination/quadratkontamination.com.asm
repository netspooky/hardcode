;Snow 64b
;64 byte intro source by T$
;Greets to mados, cthulhu, spacey and neo

org 100h

  mov    al,13h
  int    10h
  lds    ax,[bx]

;  mov    dx,3C9h
;  mov    ch,3
;  locloop_1:
;  ror    eax,8 ;"rol" für rot/orange
;  cmp    al,3Fh
;  jb     loc_2
;  mov    al,3Fh
;  inc    ah
;  loc_2:
;  test   cl,3
;  jz     loc_3
;  out    dx,al
;  loc_3:
;  loop   locloop_1

schleife:

inc bx
setz dl
xor dh,dh
add si,dx

shl dx,5
add ch,dl
adc cl, dh

mov ax,bx
add ax,si
rol ax,cl
xor ax, bx
shr al,1
and al,15
add al, 32
mov [bx], al

in al,60h
dec al
jnz schleife
ret
