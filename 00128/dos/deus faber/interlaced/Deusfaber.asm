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
b equ byte  ; Deusfaber by Baudsurfer/rsi 2015 aka olivier.poudade.free.fr
w equ word  ; A 128 bytes intro with sound tested on XPSP3 and Virtual Box
d equ dword ; Presented first Outline demoparty in Willemsoord/Netherlands
i equ 095h  ; greet Blabla Bon^2 DESiRE Live! MNDRN Onslaught RZR1911 TRBL
t equ 46ch  ; UkkO Ggn Fra Den g0blinish Sensenstahl & all assembly coders
  org 100h
  mov al,93h
  int 10h
  les bp,[bx]
  mov dx,k
  mov ax,251ch
  int 21h
  mov dx,3c9h
a:shrd ax,cx,9
  times 3 out dx,al
  loop a
  mov bp,140h
c:mov cl,0ffh
e:mov bl,cl
  not bl
  lea ax,[di-10h]
  xor dx,dx
  div bp
  call f
  xchg ax,dx
  call f
  mov al,[fs:t]
  inc ax
  jnz g
  add b[h-1],8
g:add bl,al
  add al,ah
  sub al,cl
  sub dh,30h
  mov ah,dh
  and dh,al
  and dh,bl
  xor dh,ah
  loopnz e
  mov al,cl
  stosw     ; change to stoW if too slow
  jmp c
f:sub ax,40h
h:imul ax,bx
  add ah,i
  jo z
  neg ah
z:ret
k:mov dx,331h
  mov al,3fh
  out dx,al
  dec dx
  salc
  out dx,al
  mov al,0cah
  out dx,al
  mov al,60
  out dx,al
  rol si,1
  sbb al,0a2h
  out dx,al
  lea ax,[si+23h]
  times 2 out dx,al
  or al,ah
  out dx,al
  iret