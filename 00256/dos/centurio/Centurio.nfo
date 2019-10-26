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
; Centurio 256b xpdos tiny intro Baudsurfer/rsi 2015 aka olivier.poudade.free.fr
; Presented first at Chaos Constructions 2015 demoparty in St. Petersburg Russia
; Greets Blabla Conscience Bon^2 BReWErS CODEX Flush Lineout Mandarine Onslaught
; Paranoimia Quartex Rebels Razor1911 RiOT Titan and to all assembly programmers
; Youtube video courtesy of Astrofra https://www.youtube.com/watch?v=F6vvDUkPihs
;*******************************************************************************
b equ byte            ; type shortner helper
w equ word            ; type shortner helper
d equ dword           ; type shortner helper
  org 100h            ; ip=seg:256 
  mov al,13h          ; mode 320x200w256
  int 10h             ; bios video api 
  mov cl,30           ; sigma of bit-glyphs
a:mov eax,171445ddh   ; logo 10111000101000100010111011101b
  shr eax,cl          ; bt eax,ecx;  ^reversed logo 29-bit bitmask%10
  salc                ; xor al,al=ascii(NUL)~space glyph=mov al,20h
  jnc c               ; cf=block (ie: non-space)
  mov al,0dbh         ; block glyph
c:int 29h             ; fast putch(al) 
  mov al,cl           ; al=cl 
  aam 0ah             ; =aam 10=>ah=cl/10 al=cl%10 
  jnz e               ; time for crlf-2*rows ?
  mov w[fs:450h],ax   ; bda curs pos col=[40:50h]=cx%10 row=[40:51h]=int(cx/10) 
e:loop a              ; process 30 bits
  std                 ; draw bottom to top 
  fld d[bx]           ; load angle start
f:mov es,w[bx]        ; bx=0 entering or looping
  mov cl,52h          ; checker board 3d plane height=82 pixels 
  inc bp              ; increase timer
g:mov si,0a0h         ; yloop checker board 3d plane rightmotst (160) limit
h:mov ah,54h          ; xloop load delta=cos([counter]/9*pi^2)
  cwd                 ; xor dx,dx
  div cx              ; ax=ax/delta
  mov bl,al           ; bl=depth
  mul si              ; dx:ax=ax*si 
  mov al,ah           ; shr ax,8
  add bx,bp           ; bp is k*rtc advance checker board z
  xor al,bl           ; checker board row column parity
  and al,40h          ; checker board single checker size
  add al,0c8h         ; 3d checkerboard single checker color
  stosb               ; plot checkerboard single checker point
  shld ax,cx,0dh      ; rasterbars routine 248b mov ax,cx/shr al,1
  add al,50h          ; rasterbars sky base color
  mov [es:di-62bfh],al; rasterbars bottom of gradient
  dec si              ; beam right to left
  cmp si,0ff60h       ; checkboard 3d plane leftmotst (-160) limit
  jnz h               ; continue checkboard 3d plane horizontal loop
  loop g              ; continue checkboard 3d plane vertical loop   
  not si              ; si=not(ff60h)=159d < this com's 256 org (psp) 
i:sub di,bp           ; plot destination-=timer
j:lodsb               ; parallax starfield : load PSP=starfield 
  test al,al          ; differenciate xyyyyyyb parallax starfield stars
  js i                ; if bit7=1 decrease destination by subtracting timer
  imul si             ; prettify scatter starfield across vga display
  sub di,ax           ; star's absolute coordinates base movement
  mov al,0ffh         ; parallax starfield star's color
  stosb               ; plot this star
  or si,si            ; if si>0
  jnz j               ; continue starfield routine
  mov bx,168h         ; bx=320+40 ; moutain ridge val (+40 for bx remainder)
  mov di,0aeefh       ; 0aeefh; di=mountain ridge start loc fff9h para fixup  
k:sub di,141h         ; MOUTAINS assume mountain ridge slope direction up
  xlatb               ; read a mountain ridge slope value (flags unaffected)
  aaa                 ; randomize mountain ridge peak value (affect flags)
  jp l                ; determine mountain ridge slope direction 
  add di,280h         ; fallthrough moutain ridge slope direction correct down
l:mov si,di           ; preserve mountain ridge peak row value
m:mov b[es:si],cl     ; moutain color is black
  add si,140h         ; get next moutain row point
  cmp si,0d46fh       ; if row height < (mountain height-para fixup) 
  jc m                ; continue filling mountain row  
  dec bx              ; else decrease mountain column 
  cmp bx,28h          ; total 320+remainder rows (ie 40) processed ?  
  jnz k               ; if not continue drawing moutain
n:cwd                 ; xor dx,dx=cx%40
  mov ax,cx           ; cube volume 40^3<2^16<seg 
  div bx              ; divide by mountain loop remainder 
  push dx             ; push first coordinate
  cwd                 ; xor dx,dx
  div bx              ; ax=ax/40
  push ax             ; push second coordinate
  push dx             ; push third coordinate ax%40
  mov si,sp           ; address stack with si
  fild w[si+4]        ; z coord of cloud cube point
  fild w[si+2]        ; y coord of cloud cube point
  fild w[si]          ; x coord of cloud cube point
  call p              ; rotate around x axis
  call p              ; rotate around y axis => rotation around z axis
  fistp w[si]         ; dst=y2 coord of cloud cube point
  add w[si],64h       ; dst->y2+=100 vert centerize
  imul di,[si],140h   ; dst->y2*=line width
  fistp w[si]         ; x coord of cloud cube point
  add di,[si]         ; dst+=x
  fistp w[si]         ; z coord of cloud cube point
  sub di,bp           ; horizontal translation=-k*timer
  lodsb               ; z coord cube color delta
  add al,90h          ; z coord cubes base color
  cmp al,[di]         ; if al>z buffer
  jna o               ; then replace value
  aam 6               ; ah=al/6 al=al%6
  mov al,ah           ; al=al/6
  stosb               ; 1st cube point cloud
  not di              ; inverse coords by negation
  stosb               ; overlap to simulate 3rd cube 
o:xor sp,sp           ; stack reinitialisation
  loop n              ; while( --cx ) goto points;
  fiadd w[q]          ; increase cube rotation angle (cs:018ah=e85800h)
  mov bl,cl           ; xor bl,bl_>bx=0
  les si,[bx]         ; es=09fffh si=0 
  mov fs,si           ; fixed segment
  mov ch,0beh         ; cx=152*320 points to copy
  mov di,0e8aeh       ; physical screen dst start
  fs rep movsb        ; fs src prefix override
  jmp f               ; x y z a 
p:fld st3             ; a x y z a
  fsincos             ; ca sa x y z a
  fmul st0,st2        ; x*ca sa x y z a
  fxch st1            ; sa x*ca x y z a
  fmul st0,st3        ; y*sa x*ca x y z a
  faddp st1,st0       ; y*sa+x*ca x y z,a
  fld st4             ; a y*sa+x*ca x y z a
  fsincos             ; ca sa y*sa+x*ca x y z a
  fmulp st4,st0       ; sa y*sa+x*ca x y*ca z a
  fmulp st2,st0       ; y*sa+x*ca x*sa y*ca z a
  fxch st1            ; x*sa y*sa+x*ca y*ca z a
  fsubp st2,st0       ; y*sa+x*ca y*ca-x*sa z a
  fxch st2            ; z y*sa+x*ca y*ca-x*sa a
  ret                 ; z x2 y2 a 
org 7                 ; 0 word loc far call to CP/M compatibility
  q db 58h            ; step angle increment