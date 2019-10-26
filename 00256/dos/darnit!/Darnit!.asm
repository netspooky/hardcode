; Darnit! a 256 bytes by Baudsurfer/rsi 2013 aka olivier.poudade.free.fr
; Greets to all Pouet and Dark Bit Factory users who program in assembly
; Tested on xp sp3 with midi.Have a Happy New Year and a Merry Christmas
; History :
;  "Blue square" glitch fixed -> Darnit!.fixed (256 bytes)
;  DOSBox compatible version added -> Darnit!.safe (259 bytes)
;   dosbox-0.74.conf values
;    frameskip=1
;    aspect=false
;    scaler=normal2x
;    core=dynamic
;    cputype=pentium_slow
;    cycles=max
; Thanks to sensenstahl, Optimus, StingRay & TomoAlien for the feedbacks
  org 100h
  mov word [20ah],0102h
  mov al,93h
  int 10h
  mov dx,3c9h
A:shrd ax,cx,9
  neg al
  out dx,al
  out dx,al
  nop
  nop
  out dx,al
  loop A
  les ax,[bx-2]
B:mov ax,cx
  xor al,0ach
  xor al,ah
  and al,0f0h
  stosb
  loop B
  les ax,[bx]
  mov fs,ax
  mov dword [0e0h+2],7f00005bh
  mov dx,J
  mov ax,251ch
  int 21h
C:dec byte [0d7h]
  jnz D
  xor byte [cs:H],0ddh
D:mov dx,-100
E:mov bp,320
F:fninit
  fild word [3h]
  mov [si],dx
  fild word [si]
  fdiv st0,st1
  mov [si],bp
  fild word [si]
  fdiv st0,st2
  fldz
  fld st0
  mov al,byte [0d2h]
G:fld st3
  faddp st2,st0
  fadd st0,st2
  fld st1
  fistp word [si]
  mov bx,[si]
  add bl,byte [0d1h]
  fist word [si]
  mov ch,[si]
  shld bx,cx,8
  cmp al,byte [fs:bx]
  jbe H
  dec ax
  jnz G
H:nop
  stosb
  dec bp
  jnz F
  inc dx
  cmp dx,100
  jnz E
  mov di,10h
  test word [gs:46ch],di
  jz I
  inc byte [0d1h]
  xor word [0e2h],di
I:in ax,60h
  dec ax
  jnz C
  ret
J:pusha
  push word cs
  pop ds
  mov si,1ah
  xor byte [si],1
  jz N
  lodsb
  mov di,19h
  dec byte [di]
  jnz K
  mov byte [di],4
K:mov bl,byte [di]
  shr bl,1
  pushf
  mov al,bl
  mov bx,20ah
  dec byte [0d2h]
  js L
  dec bx
L:xlatb
  popf
  jc M
  shr al,4
M:mov bx,O
  aas
  xlatb
  shr al,1
  mov si,0e0h
  mov ah,al
  salc
  sub al,066h
  mov [si+003h],ax
  add al,030h
  mov [si],ax
  mov dx,00331h
  mov al,03fh
  out dx,al
  dec dx
  mov cx,7
  rep outsb
N:popa
  iret
O:db 2,49h,0a5h