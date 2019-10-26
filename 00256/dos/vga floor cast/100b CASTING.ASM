
 ;
 ; 100 byte Floor casting with thanks to Hellfire
 ; for optimising this for both speed and size
 ; also thanks to mind for his distance shading
 ; which worked out very nicely and only 3 bytes
 ;


 ORG 100h

 PALLET = 0x03C8
 VTRACE = 0x03DA
 KEYBRD = 0x60

 init: mov   al,0x13
       int   0x10
       push  0xA000
       pop   es

       mov   dx,PALLET
       xor   ax,ax
       out   dx,al
       inc   dx
 colr: out   dx,al
       out   dx,al
       out   dx,al
       inc   ax
       jnz   colr

       mov   si,dwu
       mov   bl,0x02
       fldz
 main: fld1
       faddp st1,st0
       push  0x38
       xor   di,di

 fory: fild  word[si-0x02]
       fidiv word[esp]
       fld   st0

       push  0x0140
       fimul word[esp]
       fsub  st0,st2
       fistp word[si+bx]

       fld   st0
       fimul word[si-0x02]
       fadd  st0,st2

       pop   cx
 forx: fadd  st0,st1
       fist  word[si]

       mov   al,byte[si]
       xor   al,byte[si+bx]

       mul   byte[esp]
       shr   ax,0x0A
       stosb
       loop  forx

       fistp word[si]
       fistp word[si+bx]
       inc   byte[esp]
       jnz   fory

 exit: in    al,KEYBRD
       dec   ax
       jnz   main
       ret

 ddx   dw -160
 dwu:
 dwv = $ + 2