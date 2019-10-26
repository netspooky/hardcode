; Floorcast64 by Baudsurfer/rsi 2014 aka olivier.poudade.free.fr
; A 64 bytes animated textured planes tested on XPSP3 and DOSBox
; 128 bytes versions : http://www.pouet.net/prod.php?which=10786
;                      http://www.pouet.net/prod.php?which=63271
      org 100h
      mov al,13h
      int 10h
      les cx,[bx]
frame:mov di,10h
      mov si,0fa0fh
      mov bp,64h
yloop:mov sp,0a0h
xloop:mov ax,5454h
      cwd
      div bp
      mov bh,al
      mul sp
      mov al,ah
      add bh,cl
      xor al,bh
      shr al,4
      add al,10h
      stosb
      mov [es:si],al
      dec si
      dec sp
      cmp sp,0ff60h
      jnz xloop
      dec bp
      cmp bp,10h
      jnc yloop
      in ax,60h
      dec ax
      loopnz frame
      int 20h
