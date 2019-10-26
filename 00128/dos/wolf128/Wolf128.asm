; Wolf128 by Baudsurfer/rsi 2014 aka olivier.poudade.free.fr
; A 128 bytes interactive intro tested on XPSP3 and DOSBox
; Presented at Outline demoparty in Eersel/The Netherlands
; 256 bytes versions : 
; http://www.pouet.net/prod.php?which=24755
; http://www.pouet.net/prod.php?which=3396
; P.S : click left mouse button to start moving in maze
; Greets to UkkO Ggn Fra Den and assembly language lovers 
  org 100h
  mov al,13h
  int 10h
  les dx,[bx]
A:mov cl,0ffh
B:mov bl,cl
  not bl
  lea ax,[di-10h]
  mov bp,140h
  cdq
  div bp
  call G
  call G
  test byte [1dh],7
  jz C
  add dh,[1fh]
  sub bl,[1eh]
  jmp short E
C:mov dl,[fs:46ch]
  sub bl,[si]
  test dl,40h
  jnz D
  add dh,dl
D:add bl,dl
E:shld bp,bx,10
  sub dh,[bp]
  mov al,dh
  and dh,bl
  or dh,ah
  and dh,20h
  loopz B
  xor al,bl
  xor al,ah
  db 0d4h,10h
  add al,10h
  stosb
  or di,di
  jnz A
  mov ax,3
  int 33h
  test bl,al
  mov [1dh],bl
  jz F
  mov [1eh],dl
  mov [1fh],cl
F:in ax,60h
  dec ax
  jnz B
G:xchg ax,dx
  sub ax,64h
  imul ax,bx
  add ax,[si]
  ret