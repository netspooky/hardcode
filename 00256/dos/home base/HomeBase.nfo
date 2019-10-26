; HomeBase 256b ; Baudsurfer/RSi olivier.poudade.free.fr xpsp3 intro DiHalt 2016
b equ byte      ; Red Sector inc.     /\___      ____     _____/\ xz/dS!         
w equ word      ;     +----------    \ __/_  ___)  (     \__   / ----------+    
  org 100h      ;     |     _ _  _/¯¯¯(\  ¬\/    __/__/¯¯¯ |\  \   _ _     |    
  mov al,13h    ;     |    \\\\\ \  __/¯    \   __)  ¬\    |/   \ /////    |    
  int 10h       ;     |      ¯ ¯ /  \       /         /  /¯¯    / ¯ ¯      |    
a:push w 8000h  ;     +--------- ¯¯¯¯\_____/¯¯¯\_____/¯¯¯\_____/ ----------+    
  pop es        ;   /\____     /\___     _____     ___       /\___     /\____   
  push cs       ;  _)    /_    \   (     )   (   _/  (___    \   (_    \  __/_  
  pop ds        ;__\__ \/ ¬\/¯¯¯ __/__/¯¯  \_/__/     __/_/¯¯¯    ¬\/¯¯¯ (\  ¬\ 
c:mov ax,di     ;\   /      \   __)  ¬\    /   ¬\     /  ¬\    /)   \  __/¯    \
  mov bl,cl     ;/          /         /         /         /    ¯    /  \       /
  not bl        ;¯¯¯¯\_____/¯¯¯\_____/¯¯¯\_____/¯¯¯\_____/¯¯¯\_____/¯¯¯¯\_____/ 
  xor dx,dx     ;MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMNmhshmMMMMMMMMMM
  mov si,140h   ;MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMNyso++++ymMMMMMMM
  div si        ;MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMyosyyyssyysshNMMMM
  sub dx,bp     ;MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMmhsyhmMMMo/:/+osyooooohMMMM
  sub ax,64h    ;MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMhso++++shNyyso+::ossyhhmMMMM
  imul ax,bx    ;MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMhooyyysyyyyo+osssyshhhhhdmMMMM
  xchg ax,dx    ;MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMNo///+osysooooyysosshddhhdmMMMM
  imul ax,bx    ;MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMysso+:/sosyhhdoossshdhhhhhMMMM
  mov al,-64    ;MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMyysssssdhddhhd:--:ohhyoooodMMM
p equ 46dh      ;MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMNyssssysdddhhhd:----/sooooosmNN
  mov ch,b[fs:p];MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMN/+ossssdhhhdhy/-----ooooooohNN
  test ch,1     ;MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMN:---:+sdhysooos:+---/soooossmN
  jz d          ;MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMN:------osooooooss/y--ossyhhydd
  xchg bl,ah    ;MMMMMMNmNMMMMMMMMMMMMMMMMMMMNNmmd-------:sooooooydhhs++hhhhddmN
  neg al        ;MMNmhyssyhdNMMMMMMMMMMMMMMNmddddd/o/::---osooooosdddddhddmmNNNN
d:test ch,2     ;hyo+++ooooosymNMMNNNmmmmmmdddddddhdyyo+o-:soshhhhhddddddddmmmmd
q equ 46ch      ;o+++////++oooosyhdddddddddddddddmmmmmddh+:oshhhhdmmNmmdddddhhss
  mov ch,b[fs:q];oooo+++////+++oossyhddddddddmmNNNNNNNNmmddhhdmmNNNNNmmddddd+ooo
  jz e          ;sysssooo++////++osssddddmmNNNNNNNNNNNNmmmmmmdmmmmmdddhhddhhy++o
  neg ch        ;osyhhysooooo+oosssyhmmNNNNNNmddmNNmmmmmNNNNNmdddddhssssssso+:+o
e:add ah,ch     ;--:/+syhhyssysshdmNNNNNNNNNs+++osyhmNNNNmmddddddddhsoooososooo/
  add bl,al     ;-...--:/+syhhmNNdyymNNNNNNN/-/+//oooshdddddhhhhhhyssoooyssyy+ss
  mov al,dh     ;+:.-------:+oyysooosNNNmmmN/+//--o:/ooshyysoooooysooossyyyhhyso
  push ax       ;oy-/--..---/:so+++osdmmNNNN++--+:/:-ossyosssosssssosyhhssssssys
  push bx       ;ddos--+--..--:ossooosdmmmmm/-//+--+:ssoyooooosysssosssssssyssoo
  push cx       ;dmNNdyy/s--:--/sosyhhhmddddyso/-:++:osooosyssssssssyoooooosssss
  push dx       ;oodNNNNNdy+s:s-osmhsmymNNmmdddhyoo--+:/+syyossoooosssossssooooo
  shld cx,bx,0ch;//sddmmNNNNNdh+/ydhymNNNNNNNNmmdddhys/-+::+oo+osysoooooosysssos
  and cx,sp     ;oooydhsosdmNNNNmmmmNNNNNNNNmmNNmmdhdddhho//::+oo++osssysooooooy
  shr bl,7      ;oossh/++++yddmmNNdydmNNmhy+:/+o/dhhhhhhddddy++:-:o+++osoossssy+
  sub dh,0a0h   ;dhhds.:+oosddysyhhyyhhy/-:o/+oshyyssssyyhyhdddhso+--o//oooosyy:
  shld si,dx,4  ;mssdd+:ohddmdyo//hyo+/:::+hhyyyooooooooosyyhyyhdddhss:-+:/ooos:
  and si,0feh   ;dddddshddmmmmmmdhho/::---hysooooooooosooosoosyyyyyhdddhy+-+::o/
r equ bx+si     ;mmmmdyhddmmmmmmdhdddhs+::sooooooooosoooooooooooosyyyyhddddds/+-
  mov al,b[o+r] ;mmmmmyyhddhhddddhhhhhddhsssyyyhysoooooooooooooooooooyoddhhhmddy
  ror al,cl     ;mdddmhyyhyyhdddddddhho+++yhMMMNmsooosooooooooooooooyyhhsyhddNmd
  and al,3      ;mdhyyyyyyyyyhhhhdmmNNdNss/o++ysoosoossysyydsooooooyyhdyhyyyhmNN
  pop dx        ;mddhyyyyyyyhhhddmMMMMMMMMmo//oo-+oosyyyhdyhooooooyyhddhddmdddNN
  pop cx        ;hhyyyyyyyhyyo+s+ohdNMMMMMm+:::::/ohydmddshooooooyyydddmmmdhyydN
  pop bx        ;ddddhhysyyoyyo/shhyosydNMm+::--::+yohddshooooooyyhddmNNNddhyyyd
  jz i          ;ddhy/+/++ooyooooooooooyyyy+yysyysohyhhshooooooyyhdddmmmmmNNmmNN
  jp g          ;hso//osoo/+ooooooosyyyyhmdso/::+oomdhshooooooyyhdmNNNNNNmmmmmNN
  inc ax        ;ooooooooooooossyyyyhdmNNNmhhyyyyyymhyhooooooyyhddddmmNNNmmdmmNN
  jnp f         ;ooooooooooyyyyyhdmmmdmmhmNNNmmddhhyysooooooyyhddddddhddddNNNNNN
  neg bl        ;oooooossyyyhdmNNNNNddsydmmmdyyyyysoosoooooyyhddhhhdh+yyyohNNNNN
f:sub dh,bl     ;ossyyyyhdmNNNNNNNNNNNmmdhyyyysoooossooooohyhdddmmmmysyyyhhNNNNm
g:test bl,bl    ;yyyhdmNNNNNNNNNNNmy/::::/sooooosyyyyssoohyhdmmNNNNNhhyyyddmmddd
  js h          ;dmmmmNNNNNNNNmmhhh/:-:::/hsoooooooooooshyhdddmmNNNNNNNmmddddddd
  cmp bl,60h    ;NhdmmymNNmmdhyysysoysosy/hsooooooosyyhyhdddddddddmmmddddddddddd
  jc h          ;ddhsyhddhyyyysoooyss+++y/dsooossyyyyhhdddmmmmdddddddddddddddddd
  cmp dh,0dch   ;ymmdhhyyysooo+++oyyyyyyh/dssyyyyhhddddmmNNNNNNNmddddddddddddddd
  jc h          ;hhyyysoooooooooooosysyyhyhyyhhddddmmNNNNNNNNNmmdddddddddhhhyydm
  mov al,ch     ;yssoooooooooooooooosyyyyhhddddmmNNNNNNNNNmmdddddddddddmo+so++hN
  xchg al,ah    ;/oooooooooooooosyyyyhhddddmmNNNNNNNNNmmddddddddddddmddm++yysydM
  aad -4        ;yysyooooooossyyyhhhdddmmNNNNNNNNNmmddddddddddddddddmdmNmNNMMMMM
  test al,0e0h  ;ooooooossyyyyhddddmmNNNNNNNNNmmdddddddddddddddmNddmNNMMMMMMMMMM
  jnz h         ;ysssooooooossyyyyhhddddmmNNNNNNNNNmmdddddddddddddddmdmNdmNNNMMM
  pop ax        ;/osoooooooooooossyyyyhhdddmmmNNNNNNNNNmmdddddddddddmddm++ssosdM
  xlatb         ;yysoooooooooooooooosyyyyyhhddddmNNNNNNNNNNmmddddddddddmsoso++hN
  jmp l         ;dhyyyysooooooooooosyyyyhyhyyyhddddmmNNNNNNNNNNmmddddddddddhhhdm
h:and dh,ah     ;ymmdhhyyyysoo+o+ohyyyyyh/dssyyyyyhhdddmmmNNNNNmmddddddddddddddd
  and dh,20h    ;mhhsyhdmdhyyyssooyoo//+s/dsoooosyyyyhhddddmmddddddddddddddddddd
i:pop ax        ;NdmmmhmNNNmmdhysyssysosy/dsoooooooosyyhyhdddddddmmNmmdddddddddd
  jnz j         ;ddmNNNNNNNNNNNmddh:----::ysooooooooooooyyhdddmmNNNNNNNmmmdddddd
  dec cl        ;yyyyhdmNNNNNNNNNNNho+/+++ysoooosyyhyyysoyhhdmmNNNNNhyssydhNmmdd
  jnz c         ;oosyyyyyhdmNNNNNNNNNNmmmhyyyyysooooo+ooooyyhdddmmmdysssyhhNNNNN
j:jz k          ;oooooosssyyyhmmNNNNddyydmNmmhyyyyysosoooooyhhddhhhdh+yyhodNNNNN
  cmp al,0dch   ;oooooooooosyyyyyhdmmdmmdNNNmmdddhhyyyooooooyhhddddddddmmmmNNNNN
  jns l         ;ooo+oooooooooosysyyyhmmNNmhhyssyssmdshooooooyhydddmmNNNNmmddmNN
  sahf          ;hys/:osoo/+ooooooosyyyyyhd++/::++oNddshooooooyhhdmNNNNNmmmmmNNN
  js l          ;dddyoo//+sohssoossoooosyhysysooysoyshdshooooooyhyddddmmmNNmdmmN
k:mov al,0ffh   ;hhddhyhyyyoss+/osyyoyhmMMm/------/yohddshooooooshyddmNNNdhhyyyd
  jmp m         ;dhyyyyyyyyyyo+ssydmNMMMMMm+////:+ohhdmddshsoooooshydddmmmmhyymN
l:xor al,dh     ;mddhyyyyyyyyhhdmmMMMMMMMMho:/oo-+oooyyyydyhooooooshyddhhdddhdNN
  and ax,3f03h  ;mhyyhyyyyyyhhhhhddmmmydso/osshyossoososyyyhsooooooshydyyyyydmNN
  mul ah        ;mddmdyyyhyyhdddddddhyyo++hdNMMMNyoossooooooooooooooshshyyhhmmdd
  aam 5         ;mmmmdyydmdhdddddhhhhhddyossssssssoooooooooooooooooooyodddhhmdhs
  mov al,dh     ;dmmmdhhddddmmmmddddhs+::-soooooooooossooooooooosyyyyyhdddhh+:/:
  jnz m         ;dddddshdmmmmmmmdhh+/::---hhysooooooooooossosyyyhyhdddhss:-+//o/
  add al,90h    ;msodh/-oyhdmdo/:/hyso+/::+hyhyysooooooooyyyhyhddddsoo--o/++oos/
m:xor ah,ah     ;hhhds-/+++oddhhdmhyyhdd+-:+:/ooyhyyssyyyhhddddyo/+--o+++osssys-
  stosw         ;ooosh+++++hdmmNNNdydNNNmmho/oos+ddhhhhdddhhs//:-/oo++ossoooosso
  test di,di    ;ooohdhysymNNNNNddmNNNNNNNNNNNNNmmdhhddyy/-//:+oo++osssssssssosy
  mov cx,0ffh   ;//sddmNNNNNdyy:/sdhsdNNNNNNNmmddddyoo-.o/++oooosysoooooossoooos
  jnz a         ;osmNNNNdho/s:o-ssdhymyNNmmmdddhs++--o//+oyhsssoooosssssssssoooo
  and bp,cx     ;mNNdyoy:s-.---+sossyyhmddddy++:-:++:ooosoosossyyssssoooooosssoo
  jnz n         ;yh+y--/-----:/oossoosdmmNNm/://+--+:sssysoooosyssoossyysssyssss
  xor b [n],8   ;os-:....---//so+++oodmmmNNN/+--+:+:-ooososoooossssosyyhssssssys
n:dec bp        ;/-.------:/oshyssooyNNNNmmm/++/--o/++oshhyssoossysoooosyhyhhyss
  pusha         ;-..--:/+syyhhdNNmhdNNNNNNNN/-/o+/+osyddddddhhhhdhhyssssyssyy+ss
  mov di,0bb80h ;::/+oyhhysssyssyhdmNNNNNNNNyo+oshhdmNNNNNmmdddddddhoooooooso++/
  mov cx,780h   ;syhhhssoooo+++oossyydmmNNNNNNmmNNNNmmmmmNNNNmdddddhyssssysoo/+o
  push cx       ;syssooo+++////++osssdddddmmNNNNNNNNNNNNmmdmddmmNNmmddddddddh++o
  mov al,28h    ;oooo++////+++ooossyhdddddddddmmNNNNNNNmmdhhhhdmmNNNNNmddddd+ooo
  rep stosb     ;o++++//++oooosyddddddddddddddddddmmmdhhy/-oshhhhddmmmmddddddhyy
  pop cx        ;mhso++oooooydmMMMMNNNNNNmmdddddddhhsso//-:sosyyhhhddddddddmmmmm
  add di,cx     ;MMMNmhssydmMMMMMMMMMMMMMMMMNmdddd:+:-----oooooooshdddhhdddmNNNN
  inc ax        ;MMMMMMMNMMMMMMMMMMMMMMMMMMMMMNNmd-------:sooooooyhhy+:+hhhhhdmm
  rep stosb     ;MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMN:------osooooosss:s--sosyhhydd
  mov si,0a00h  ;MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMN:--:/osddhysooo-:---/sooooosNN 
  mov di,1400h  ;MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMN+osssssdhhhdhh/----:soooooodNN
  push es       ;MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMNyssssssddddhhd:.---+sooooosNNN
  pop ds        ;MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMyyssssohhhdhhd:-:+shdhsooodMMM
  push w 0a000h ;MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMhso+::/ooosyhdssssshhhhhhdMMMM
  pop es        ;MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMN+//++oyhyoo+osysssshhdhhhmMMMM
  mov ch,69h    ;MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMdyoyyyossyysosssysohhhhhhmMMMM
  rep movsw     ;MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMdso++++sdNyso+/:/ooosyhmMMMM
  popa          ;MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMNdhhmNMMM+:/++syyso+oohMMMM
  jmp a         ;MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMdysyyyossyyhdMMMMM
o dd 0f5fa01f8h ;MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMNho++++ohNMMMMMMM
  dd 0a050c03h  ;Greets: Onslaught Mandarine Flush Razor1911 Quartex Titan Riot
  dw 02f4h      ;Paranoimia Brewers Codex Phf Kuasoft Lineout Rebels Resistance