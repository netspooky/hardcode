; FIRE.ASM
;
; Made by Jarmo Pyrr” (Com-Son)

.386P

FIRE segment 'code' USE16

ORG 0100H

startofcode:

   ; Set mode 320x200

   mov   al,13H
   int   10H

   ; Create palette

   mov   dx,03c8H
   xor   al,al
   out   dx,al

   inc   dx
   xor   ch,ch
   mov   cl,64
PaletteLoop1:
   mov   al,ah
   out   dx,al
   inc   ah
   xor   al,al
   out   dx,al
   out   dx,al
   loop  PaletteLoop1

   mov   cl,64
   xor   ah,ah
PaletteLoop2:
   mov   al,63
   out   dx,al
   mov   al,ah
   out   dx,al
   inc   ah
   xor   al,al
   out   dx,al
   loop  PaletteLoop2

   mov   ax,0a000H
   mov   es,ax

FireLoop:
   cmp   si,5
   jb    FirePass
   xor   si,si
FirePass:

   xor   ah,ah
   mov   al,cs:[FireOffsetY+si]
   mov   dx,320
   mul   dx
   xor   bh,bh
   mov   bl,cs:[FireOffsetX+si]
   add   ax,bx

   mov   di,ax
   mov   cl,cs:[FireLength+si]
_FireLoop:
   cmp   byte ptr cs:[FireDirection+si],0
   je    FireStraight
   cmp   byte ptr cs:[FireDirection+si],-1
   je    FireBack
   inc   di
   inc   di
FireBack:
   sub   di,322
FireStraight:
   inc   di

   call  FirePixel
   loop  _FireLoop

   inc   si
   mov   ah,01H
   int   16H
   jz    FireLoop

Quit:

   ; Set mode 80x25

   mov   ax,02H
   int   10H

   ; Exit to DOS

   mov   ah,04cH
   int   21H

FireOffsetX    db 142,162,136,111,143
FireOffsetY    db 60,40,50,45,15
FireDirection  db 1,0,-1,1,-1
FireLength     db 20,10,15,10,7

FirePixel:
   push  di
   push  cx

   mov   cl,60
__FireLoop:
   xor   ah,ah
   xor   bh,bh

   mov   al,es:[di+319]
   mov   bl,es:[di+320]
   add   ax,bx
   mov   bl,es:[di+321]
   add   ax,bx

   and   bp,0ffH
   mov   bl,cs:[bp]
   inc   bp
   and   bl,15
   add   ax,bx

   mov   bx,14
   mul   bx
   add   bx,38
   div   bx

   and   al,07fH
   stosb
   mov   bx,319
   add   di,bx
   loop  __FireLoop

   sub   di,bx
   dec   di

   mov   al,cs:[bp]
   inc   bp
   and   al,31
   add   al,96

   stosb
   add   di,bx
   mov   al,200
   stosb
   add   di,bx
   dec   ax
   stosb
   cmp   si,4
   jb    FireEnd

   mov   dx,di
   and   dl,7
   add   al,dl
   dec   di
__FireLoop2:
   stosb
   add   di,bx
   cmp   di,150*320
   jb    __FireLoop2

FireEnd:
   pop   cx
   pop   di
   retn

FIRE ends

end startofcode
