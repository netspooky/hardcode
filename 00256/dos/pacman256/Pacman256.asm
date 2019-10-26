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
g equ p+6      ; Pacman256 by Baudsurfer/rsi 2015 aka olivier.poudade.free.fr
w equ word     ; A 256 bytes intro tested for XPSP3 and VMWare (set x=1) only
b equ byte     ; Presented at QB Multi-platform Party 2015 in Sülysáp/Hungary
x equ 0        ; greet Blabla Bon^2 DESiRE Live! MNDRN Onslaught RZR1911 TRBL 
org 100h       ; UkkO Ggn Fra Den g0blinish Sensenstahl & all assembly coders
  mov al,13h         ; psp+256, if pb or VMWare then set x equ 1 set video fx
  int 10h            ; bios video api
  mov bp,450h        ; DECOMPRESS AND DISPLAY MAZE
  cwd                ; dx=0
  mov cl,16h         ; board 22 non-symetric rows
a:mov ch,11h         ; board 16 cols+ 1 overlay (col17=col1)
u:inc dx             ; col++ inc byte [fs:450h]
  mov al,0dbh        ; al=dbh=219=wall
  rol w[m+si-100h],1 ; get next col bitmask in maze map array
  jc c               ; if not wall then obligatory dot
  mov al,0f9h        ; al=f9h=249=dot
c:mov w[fs:bp],dx    ; empty - update curs row/col pos
  int 29h            ; putchar short dos call
  dec ch             ; *this row's col total--
  jnz u              ; all cols of *this row processed ?
  lodsw              ; maze idx+=siz(w)
  mov dl,ch          ; crlf=xor dl,dl
  inc dh             ; row++ add dh,cl;inc dh;inc byte [fs:451h]
  loop a             ; INIT/DIPLAY PACMAN AND GHOSTS struct siz=6       
  mov edx,10100202h  ; disp extra col off. enable row|col dx symetry
  mov di,g           ; ghost status base idx
  mov cl,4           ; 4 ghost structs to init
e:mov al,1eh         ; al=glyph ascii val ah=putback tile glyph
  stosw              ; store ghost glyph+color
  ror edx,8          ; (col=16 row=2)/(col=2 row=16) symetry
  int 29h            ; display char /w dx=curs pos
  mov al,48h         ; default starting direction for ghost is up
  stosw              ; ghost direction (false kbd scancode) - w padded
  mov ax,dx          ; dw ghost position
  stosw              ; save ghost row/col pos di+=2
  loop e             ; all ghost structs init done ?
f:mov di,p           ; run - GAME LOOP rst to glyph struct base
h:in al,60h          ; delay - messy but shortest working code
  test al,al         ; is it make scancode ?
  js i               ; else skip break scancode 
  mov b [di+2],al    ; glyph direction
i:loop h             ; break - cx=65535 rollover from below loop
  mov cl,5           ; pacman+4 ghosts start /w pacman (should be cx)
j:mov dx,w[di+4]     ; switch - store rollback position
  mov w[fs:bp],dx    ; glyph col+row positions
  mov si,k           ; dir mov array for keys
  mov bl,4           ; test 4 arrow keyb keys
t:lodsb              ; direction - out: car ah=scancode al=ascii
  cmp al,b[di+2]     ; scancode=arrow ?
  lodsw              ; NULL last mov deltaX deltaY assumed in seg
  jz l               ; found asked deltas=>check collision
  dec bl             ; test all 4 NSWE directions 
  jnz t              ; test next direction     
l:add w[fs:bp],ax    ; collision - assumed NULL w at key+12
  mov ah,8           ; ah=read car and attrib @curs pos vga api
  IF x               ; BEG for some non-fully compatible bios clones
  push si            ; "Because of the IBM BIOS specifications may exist
  push di            ; some clone BIOSes which do not preserve SI or DI"
  push bp            ; "Some IBM PC ROM BIOSes destroy BP when in gfx modes"
  push bx            ; should not be necessary in gfx mode as all
  mov bh,0           ; other family calls have implict bh=dontcare
  END IF             ; END for some non-fully compatible bios clones
  int 10h            ; out: ah=car color al=car val bh=page number n/A
  IF x               ; BEG for some non-fully compatible bios clones
  pop bx             ; see Ralf Brown's interrupt list warnings
  pop bp             ; cf. http://www.ctyme.com/intr/rb-0098.htm
  pop di             ; cf. http://www.ctyme.com/intr/rb-0098.htm
  pop si             ; cf. http://www.ctyme.com/intr/rb-0098.htm
  END IF             ; END for some non-fully compatible bios clones
  test al,10b        ; if !(wall 11011011b or ghost 11110b) discrimination
  jz o               ; then move is legal and carry on
  xchg w[fs:bp],dx   ; rollback - is wall =>rollback move
  cmp cl,5           ; test if pacman or ghosts
  jz n               ; if pacman keep prev dir and skip frame
  inc b[di+2]        ; else try all 4 directions 
  jmp j              ; switch break happens above so loop
n:mov al,b[di+3]     ; put rollback
  mov b[di+2],al     ; in active position 
  inc bh             ; see alt direction below in "key" (k) 
  jnp j              ; cf. alt key below - tricky wrap-around 
  jmp s              ; and skip event since move faulty 
o:mov bl,b[di+2]     ; event - preserve al=glyph putback tile
  mov b[di+3],bl     ; and keep prev move dir
  cmp al,9           ; case new tile=pacman ? 
  jnz q              ; if not continue
  ret                ; death - else die and exit game to shell 
q:mov b[di+1],al     ; live - save putback tile
  cmp cl,5           ; test if pacman glyph
  jnz r              ; if not skip hardcoded replacement char 
  mov al,20h         ; space char replaces * exclusively for pacman
r:xchg w[fs:bp],dx   ; samescore - score display was stripped 
  int 29h            ; glyph putback tile=al=[di+1]  
  xchg w[fs:bp],dx   ; switch actual /w requested curs pos
  mov w dx,[fs:bp]   ; and restore it in dx
  mov w[di+4],dx     ; save previous curs pos
  mov al,[di+0]      ; glyph char
  int 29h            ; display glyph new position
s:add di,6           ; nokey - advance to next glyph struct
  loop j             ; next glyph movement
  jmp f              ; next game loop frame 
m dw 0ffffh          ; 11111111111111111b maze data 
  dw 8080h           ; 10000000100000001b little endian 17x22 playfield map
  dw 0b6b6h          ; 10110110101101101b shadow 17th column=1st column
  dw 0b6b6h          ; 10110110101101101b total=44 bytes
  dw 8000h           ; 10000000000000001b
  dw 0b5d6h          ; 10110101110101101b
  dw 8490h           ; 10000100100100001b
  dw 0f6b7h          ; 11110110101101111b
  dw 0f417h          ; 11110100000101111b
  dw 0f557h          ; 11110101010101111b
  dw 8140h           ; 00000001010000000b
  dw 0f5d7h          ; 11110101110101111b
  dw 0f417h          ; 11110100000101111b
  dw 0f5d7h          ; 11110101110101111b
  dw 8080h           ; 10000000100000001b
  dw 0b6b6h          ; 10110110101101101b
  dw 9004h           ; 10010000000001001b
  dw 0d5d5h          ; 11010101110101011b
  dw 8490h           ; 10010000100001001b
  dw 0bebeh          ; 10111110101111101b
  dw 8000h           ; 10000000000000001b
  dw 0ffffh          ; 11111111111111111b 
k db 48h,0,-1        ; up (alt=left) arrow - make scanc lsb,deltaX,deltaY
  db 50h,0,1         ; down (alt=up) arrow - cursor update compensated
  db 4bh,-1,-1       ; left (alt=right) arrow+ compensate sign extend 
  db 4dh,1,0         ; right (alt=down) arrow assumed null b
p dw 3209h,4dh,1008h ; glyp+putback/direction+rollback/col+row