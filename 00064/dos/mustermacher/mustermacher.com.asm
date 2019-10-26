;Mustermacher 64b
;64 byte intro source by T$
;Greets to mados, cthulhu, spacey and topy44

org 100h

  mov    al,13h
  int    10h
  lds    ax,[bx]

allpatterns:

mov dl,1

pattern:

xor ah,ah

lodsb
add al,[si-320]
add al,[si-321] ;remove this line for a sierpinski-like effect (otherwise: delannoy-like)

div dl

cmp si,64000
jnb clear ;jb noclear
;mov ah,1 ;horizontal seed - can be changed for other fx
;noclear:

dec bx
jne schleife2
 clear:
 mov bx,320
 mov ah,1 ;vertical seed - can be changed for other fx
 in al,60h ;read port here for medium speed
schleife2:

add ah,16

mov [si],ah

;in al,60h ;read port here for low speed

or si,si
jnz pattern

mov bx,319

inc dl
;and dl,63;15
;setz dh
;add dl,dh

cmp dl,75 ;maximum pattern number
jg allpatterns

in al,60h
dec al
jnz pattern
ret
