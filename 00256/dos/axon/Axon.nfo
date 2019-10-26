t equ 80h  ; Axon by Baudsurfer/rsi 2015 aka olivier.poudade.free.fr
w equ word ; A 256 bytes intro with sound tested on XPSP3 and DOSBox
b equ byte ; Presented at 7DX 2015 The Last Party in Istanbul/Turkey
  org 100h ; RSi greets Blabla Bon^2 DESiRE Live! MNDRN RZR1911 TRBL
  mov al,13h
  int 10h
  les dx,[bx]
  mov dx,k
  mov ax,251ch
  int 21h
a:mov cl,0ffh
c:mov bl,cl
  not bl
  cwd
  lea ax,[di-10h]
  mov bp,140h
  div bp
  call i
  call i
  test b [t+1],1
  jnz d
  xchg dh,ah
d:mov al,b [t]
  add bl,al
  sub al,10h
  test al,40h
  jz e
  add dh,al
e:mov al,dh
  shld bp,bx,0ah
  sub dh,b [bp]
  xor dh,ah
  and dh,bl
  xor al,bl
  xor al,ah
  aam 8
  and dh,20h
  loopz c
  and al,4
  mul cl
  shr al,4
  add al,10h
  stosb
  test di,di
  jnz a
  mov si,o+10h
  mov bl,5
f:lodsb
  mov cl,al
  lodsw
  mov di,ax
g:lodsb
  shld bp,ax,0ch
  and bp,0eh
  and al,1fh
  mov ch,al
h:add di,w [bp+o]
  mov al,0fh
  stosb
  dec ch
  jnz h
  loop g
  dec bx
  jnz f
  in ax,60h
  daa
  jns a
i:xchg ax,dx
  sub ax,64h
j:imul ax,bx
  add ax,[si]
  ret
k:mov dx,331h
  mov al,3fh
  out dx,al
  dec dx
  mov al,99h
  out dx,al
  mov ax,w [fs:46ch]
  mov [cs:t],ax
  test al,dh
  jnz n
  and al,6
  xor b [cs:l+1],al
l:adc al,20h
  out dx,al
  jp m
  call j
m:out dx,al
n:iret
o db 0bfh,0feh,0c0h,0feh,0,0,40h,1,3fh,1,3eh,1,0feh,0ffh,0beh,0feh,6,0eeh,2ah
  db 0cbh,3dh,6fh,0a5h,0eah,0b2h,0ch,4ah,0eh,26h,69h,2eh,8ah,0aah,69h,0a6h
  db 0e9h,0aeh,0ah,2ah,0e9h,4,0a1h,19h,33h,73h,0b3h,0f3h,4,0aah,19h,2ah,6ah
  db 0aah,0eah,0bh,61h,35h,0f4h,90h,0c8h,0ch,26h,0e6h,0ah,74h,0dh,48h,9fh