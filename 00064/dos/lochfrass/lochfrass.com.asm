;Agglomerate 64b
;64 byte intro source by T$
;Greets to mados, cthulhu, spacey and neo

org 100h

  mov    al,13h
  int    10h
  lds    ax,[bx]

mov bx,36345
inc byte [bx] 

schleife:

imul ebx,65539357
add ebx,4237

mov cl, [bx+1]
add cl, [bx-1]
add cl, [bx-320]
add cl, [bx+320]
cmp cl,[bx]
jbe schleife

inc byte [bx]

in al,60h
dec al
jnz schleife
ret

