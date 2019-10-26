;*******************************************************************************
;                 /\______          /\______          /\________
;             __\\\___    \_    __\\\___    \_    __\\\______   \
;            |      /      /   |      /      /   |     _____/    \_
;            |     /      /____|     /      /____|     \           |
;            |     \____       :      _____/     :      \          |
;            |        /                \                 \         |
;            |       /         .        \        .        \        |
;      __   _|_     /                    \                 \      _|_   __
;   \ \\_\ \\__\  _/           :          \_     :          \_   /__// /_// /
;            |____/_ _         :______ _         :______ _         |
;               \\\____________|  \\\____________|  \\\____________|
;
;    _______      _______      _______      _______      _______      _______
; _\\\__    \___\\\__    \___\\\__    \___\\\_____ \___\\\_____ \___\\\__    \_
;|    /______/|    /      /|    /      /|       /    |       /    |    /      /
;\            |   /      /_|   /      /_|      /     |      /     |   /      /_
;|\_______    :    _____/  :   \_____/  :     /      :     /      :   \____    |
;|      /     .     \      .     \      .    /       .    /       .     /      |
;|     /             \            \         /                          /       |
;|___         :___         :___         :___\        :___         :___/    sns |
;  \\_________: \\_________: \\_________: \\_________: \\_________: \\_________|
;
;                          R E D   S E C T O R   I N C
;
; Crawlspace 256b dos tiny intro Baudsurfer/rsi 2015 aka olivier.poudade.free.fr
; Presented first at Riverwash #7 2015 multi-platform demoparty in Cracow Poland
; Greets Blabla Conscience Bon^2 BReWErS CODEX Flush Lineout Mandarine Onslaught
; Paranoimia Quartex Rebels Razor1911 RiOT Titan and to all assembly programmers
; Youtube video courtesy of Astrofra https://www.youtube.com/watch?v=3RGNI2zwlno
;*******************************************************************************
b equ byte
w equ word
d equ dword
  org 100h
  mov al,93h
  int 10h
  mov es,[bx]
  mov ax,1124h
  int 10h
  lds si,[gs:10ch]
  mov ch,0fh
a:lodsb
  mov bl,10h
c:inc ax
  stosb
  dec bx
  jnz c
  loop a
  mov bp,140h
  mov ds,dx
  les ax,[bx]
  mov fs,ax
  mov d[0e2h],7f00005Bh
  mov dx,j
  mov ax,251ch
  int 21h
e:xor dx,dx
  lea ax,[di-10h]
  div bp
  sub dx,64h
  sub ax,0a0h
  nop
f:fninit
  fild w[3h]
  mov [si],ax
  fild w[si]
  fdiv st0,st1
  mov [si],dx
  fild w[si]
  fdiv st0,st2
  fldz
  fld st0
  mov al,cl
g:fld st3
  faddp st2,st0
  fadd st0,st2
  fld st1
  fistp w[si]
  mov bx,[si]
  add bl,ch
  fist w[si]
  mov bh,bl
  mov bl,[si]
  add bl,b[0d0h]
  cmp al,b[fs:bx]
  jbe h
  dec ax
  jnz g
h:shr al,4
  adC al,0fh
  stosb
  test di,di
  jnz e
  mov al,b[0e4h]
  aam
  cmp ch,0d2h
  jnc i
  mov b[0d0h],0f4h
  sub cl,al
  inc ch
  jmp e
i:mov cl,0b4h
  sub b[0d0h],al
  jnc e
  xor b[cs:f-1],2
  mov ch,20h
  jmp e
j:pusha
  push cs
  pop ds
  mov si,01ah
  xor b[si],1
  jz m
  lodsb
  mov di,019h
  dec b[di]
  jnz k
  inc b[si]
  mov b[di],4
k:mov bl,b[di]
  shr bl,1
  pushf
  mov al,bl
  mov bx,o
  xlatb
  popf
  jc l
  shr al,4
l:mov bx,n
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
  mov cx,6
  rep outsb
  out dx,al
m:popa
  iret
n db 2
  db 049h
  db 0a5h
o db 02h,01h