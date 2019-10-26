; Watchers 128b ;Baudsurfer/RSi olivier.poudade.free.fr xpsp3 intro Outline 2016
  org 100h      ;Red Sector inc.     /\___      ____     _____/\ xz/dS!         
  mov al,13h    ;     +----------    \ __/_  ___)  (     \__   / ----------+    
  int 10h       ;     |     _ _  _/¯¯¯(\  ¬\/    __/__/¯¯¯ |\  \   _ _     |    
  les bp,[bx]   ;     |    \\\\\ \  __/¯    \   __)  ¬\    |/   \ /////    |    
  mov dx,331h   ;     |      ¯ ¯ /  \       /         /  /¯¯    / ¯ ¯      |    
  mov al,3fh    ;     +--------- ¯¯¯¯\_____/¯¯¯\_____/¯¯¯\_____/ ----------+    
  out dx,al     ;   /\____     /\___     _____     ___       /\___     /\____   
  dec dx        ;  _)    /_    \   (     )   (   _/  (___    \   (_    \  __/_  
  inc si        ;__\__ \/ ¬\/¯¯¯ __/__/¯¯  \_/__/     __/_/¯¯¯    ¬\/¯¯¯ (\  ¬\ 
a equ 009356c3h ;\   /      \   __)  ¬\    /   ¬\     /  ¬\    /)   \  __/¯    \
h equ dword     ;/          /         /         /         /    ¯    /  \       /
  mov h [si],a  ;¯¯¯¯\_____/¯¯¯\_____/¯¯¯\_____/¯¯¯\_____/¯¯¯\_____/¯¯¯¯\_____/ 
  mov cl,8      ;$$$$ZZZZ$$Z$ZZ$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
  rep outsb     ;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$7777777777777777$$$
  mov si,140h   ;$$$$$$$$$$$$$$ZIZ$7Z$$$$$7777$$$7777777777777777777777777777$$$
b:mov cl,0ffh   ;$$$$$$$$$$$$$7IZ?OO?7$I7+77Z+I?$$777777777777777777777777777777
c:mov bx,cx     ;$$$$$$$$$$$$Z77I7ZZ$$7Z7:ZZ,$7ZZI=+7777777777777777777777777777
  not bl        ;$$$$$$$$$$$?7IOO7ZIZ?7II7D?.+$?$$.:+~Z7777777777777777777777777
  cwd           ;$$$$$$$77$IZ$IZZ?I$:Z8DNZZONN88NDZ=$:?I777777777777777777777777
i equ 10h       ;$$$7$$$777$DIONZ7M=N8IZDMD8$ZNO$$OZO7M+,$7777777777777777777777
  lea ax,[di-i] ;$$$7$77777O8$??$DDZO87$D8ZNZZ$?$Z=INN8ZD$7IIIIIIIIIIIIII7777777
  div si        ;77777777777?+?+ND$DMZN87O8O+8Z7$7I7INDONN8I7IIIIIIIIIIIIIIIIIII
  sub ax,0a0h   ;7777777777$$$$D88NM8888DOI7+?+77Z$?ZN$NN8NN7IIIIIIIIIIIIIIIIIII
  imul ax,bx    ;77777777777?$$IM8MNMNMN88NZ+$7?O7Z?N7D888DD$IIIIIIIIIIIIIIIIIII
  sub dx,bx     ;7777777777ZI?7Z7O$+$$ZZ::+$.$O$$I?Z+:Z8DDDD+IIIIIIIIIIIIIIIIIII
  add ah,3fh    ;777777777I$I7IZ$O?7=Z77I77II?$ZZ++ZIZ$O8$D8+IIIIIIIIIIIIIIIIIII
  imul dx,bx    ;III77777II$?8$7+$IO$OI$$+~+Z+=.$OIZ$Z77~~NDIII???????III???????
t equ 46ch      ;IIII7IIIIII?ZI7$$$D?IZ+I$.DZZ.N,ZI8=77$$?7O+II??????????????III
  mov al,[fs:t] ;IIIIIIIIII7IZZI$O$ZO8?OO=$O=:?O$O?$=?=Z$$+ZZ$$7II??????????????
  add bl,al     ;???IIIIIIIIIZ$?Z8Z7$77$IO$$OO:I7Z$~IZO+NN$Z$Z$Z~OZ?????????????
  add al,8      ;IIIIIIIIIII$O8$Z7~7+?$IO7+7$7.+I7$ZZ+$O?$DOZZ7$8Z8+????????????
  jns d         ;IIIIIIIIIII77OI7O7$DOD8?O$I?O$I?IIZ88+II8ZO7ZDDD8N?????????????
  add dh,al     ;IIIIIIIIIIII$77$O77$I$Z$I$$NO.?7=?DDDND8NZN$ODD88D+?++++????+++
d:mov al,dh     ;IIIII???I?I$?$$I=$$?MM$77I7?.=I8DONNDD88=?$8DDDNMM+++++++++++++
  cmp ah,2dh    ;???I???????IIOZI$7I$$+$7OOZ$IO?I$ZO=?ZDD8ND8NDD8M~+++++++++++++
  jc e          ;?????????????I$7$$ZO77Z$IO?7O+7?$7~7?=I77NNDN88M77=++++++++++++
  add bl,28h    ;888ZD???????$Z$Z7ZOZ$OOM$?ZZ7DOI8Z,O+I==I?IZ=DDMNM+++++++++++++
  jmp f         ;$$$$Z$7+????+ZO$I$ZI$$Z,Z8ZZ$$IZ=?7OI77Z$:7787:O?N+============
e:add bl,ah     ;???77NMD87+++IZO$I$OOO8OZ=OZ8II,IO7ZOO$7I$$$O77Z++N============
  lea bp,[bx+8] ;$$$7II$D$DN+?=N8$IO8ZONNZNM8$8?Z~$$Z~77IDOO8Z88D8O8N~~~~~======
  cmp ah,14h    ;$$$I77$7Z=IZNM~~=$OZZ8Z+778+?ZI77IM$877ZZ8ZZ$O8NDNDO~~~~~~~====
  cmovc bx,bp   ;777II$DN88DIIZI++$$ZI$Z$$7O7OZ7Z:7Z78O8O77$ZZ8O8DDN8~~~===~~===
  push dx       ;III7Z7O$ODI7IIIZ778O7I77Z$IZ$?IZOZZ8?ZIZI7?$OI$8ODD8.~~~~~~~~~~
  sub dh,0ch    ;???7$$777$I+IIIII+$ZI$8Z8Z$IDII88IOO7IIZZ7DII=OIZ7O8N~~~~~~~...
  test dh,18h   ;7777$7II7ZIII??I?=$$$7$??I$Z$D$$887I$$$+O?8?8Z8$Z$IZ8??==::.,,,
  pop dx        ;$$$7I7II$$7Z$II+7I$$OZZ7$$7$Z=OZ7$7+?Z7O88$II7IZ$?Z7OII?I7?????
  cmovz bx,bp   ;777$$?777$$II77$II$Z$7ZIIO7Z8$O7$7$$8878Z$7+OZ?7OOO7?$I?7?IIIII
f:and dh,bl     ;DDDO$$?7$$=ZZ7+O7+M$OZ8IZI$$I8ZIII8Z7777D?7ZI~??~ZI?ZI$I=$77ZZZ
  add dh,dh     ;NNN7IN7ZZI?O??I?IDNZZ?OZOI?IZ$OZ$?Z77???IZ$IZI?$$Z?IZZ77??+?ZZZ
  or dh,ah      ;777$O?+NZ?7II$7$?$$MNZZ8$7O777DO$$?7I$I$7+7Z+IZZZZ$Z$7DI$7=+$$$
  and dh,40h    ;7778Z7O87ZI???7I?7$$NDNNDM88$O$Z?I$I$$$O??$777O=$$++?Z+7I?I?$$$
  loopz c       ;777$III7$$Z7OZ7OI8$$OIN8N8NDNN8MZDI$O=7IIIII7+?Z7M$$O?$I$$IIZZZ
  inc ah        ;777Z7Z7$77+7IZIZ7$Z8ZZ+IDNDD88DDNNDMMMMNNDDNNDDNNN7?$7+II7$OIII
  xor al,bl     ;III~ZIII7III$IZ$$Z$IO8?Z7I7NNDD8DDDDDNDNDNNNDDDDDMD7787N?+IIZZZ
  and al,3      ;OOO8?$ZI??7$Z87$$8OZO$7$O8$ZDMD8OD8D8DDDDNNDDDDDDNN?+????$+????
  mul ah        ;???7ZO$77ZZ$Z$I8O$$Z88Z87ZO87I$DDDD8D8DDDDDDDD88NNN8N=+$+7=?777
  aam 5         ;$$$$I77OOZIZ$$$OD88OO8OO?Z?8Z$7N7N8D8DD8DDDDDDONDNDNN?I$I7O$$$$
  jz g          ;$$$$7$O$O8OZZZOOZ$$O7$$O7ZD8ZZOZ7IMDD8888DDDDDNDDNNN8?I$+I$I777
  add al,dh     ;777ZZ787I8ZOO7ZOO$ZOZ$7ZZOOZ$8$7?7$7DDDDDDDDD8DDNDDNN8I7$=+$777
g:stosb         ; Greets: Onslaught Mandarine Flush Razor1911 Quartex Titan Riot
  jmp b         ; Paranoimia Brewers Codex Phf Kuasoft Lineout Rebels Resistance