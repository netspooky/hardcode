;
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
;b equ byte  ; Sunroad by Baudsurfer/rsi 2015 (aka olivier.poudade.free.fr)
;w equ word  ; A 128 bytes intro with sound tested on XPSP3 and Virtual Box
;d equ dword ; Presented first Outline demoparty in Willemsoord/Netherlands
;i equ 095h  ; greet Blabla Bon^2 DESiRE Live! MNDRN Onslaught RZR1911 TRBL
;t equ 46ch  ; UkkO Ggn Fra Den g0blinish Sensenstahl & all assembly coders
  org 100h
  mov dx,331h
  mov al,3fh
  out dx,al
  dec dx
  mov d[si],009a7dcah
  mov cl,8
  rep outsb
  mov al,93h
  int 10h
  les bx,[bx]
  mov si,140h
a:mov cl,0ffh
c:lea ax,[di-10h]
  xor dx,dx
  div si
  mov bx,cx
  not bl
  call h
  xchg ax,dx
  call h
  mov al,bl
  shr al,1
  add bl,b[fs:t]
  jns e
  neg al
e:sub ah,al
  mov al,dh
  shld bp,bx,8
  sub dh,[bp]
  and dh,bl
  and dh,ah
  xor dh,al
  and dh,60h
  loopz c
  jz f
  test al,al
  jns f
  xor al,bl
  xor al,ah
  aad 8
  xlatb
  and al,0a0h
  add ax,cx
  jmp g
f:mov ax,di
  shr ax,6
  add ax,500h
g:shr ax,5
  adc al,16
  stosb
  jmp a
h:sub ax,8ch
  imul ax,bx
  add ah,i
  ret