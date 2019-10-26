;Contact a 256 bytes dos (xpsp3) intro by Baudsurfer/RSI olivier.poudade.free.fr 
;First presented at Riverwash 8 multi-platform demoparty 2016 in Katowice Poland
;      ________                ________                _________                
;    _/_ ___   \_            _/_ ___   \_   s n s    _/_____ _ /__              
;    \    \ \   /_________   \    \ \   /_________   \     \__/   \             
;     \    \ \ /          \   \    \ \_/          \   \            \            
;      \    \/             \   \    \/             \   \            \           
;       \     /\            \   \_____/\            \   \            \          
;        \    \ \            \    /   \ \            \   \            \         
;         \    \ \            \   \    \ \            \   \            \        
;          \    \ \            \   \    \ \            \   \            \       
;           \    \ \            \_  \    \ \            \_  \            \_     
;            \    \ \ red        /   \    \/ sector      /   \ inc.       /     
;            /____/ /___________/ /\ /__________________/ /\ /___________/      
;                                                                               
;Ascii logo by SnS/Break! and capture by Fra/RSE youtube.com/watch?v=XWKCrwT9KI0
;#rsi/ircnet rsi.untergrund.net twitter/red_sector_inc facebook.com/RedSectorInc
b equ byte         ;MMMMMNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN
  org 100h         ;MMMMMNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN
  mov al,13h       ;MMMMMMNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN
  int 10h          ;MMMMNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN
  mov dx,n         ;MMMNNNNNNNNNNNNNNNNNNmmNNmmNNNmmmNNNNNNNNNNNNNNNNNNNNNNNNNNN
  mov ax,251ch     ;MMMNNNNmmmmmmmmmmmmsoyhssssNysssssyossossssymmmmmmmmmNNNNNNN
  int 21h          ;MMNNNNmhhhyyhhsyyhmoosyossoNy+os+os/ss++os+sNyyhyhyysmNNNNNN
  les cx,[bx]      ;MMNNNNNNhhsyhysyyhdo+shoossNy+ososy+oo+/+++yNmhdshyssmNNNNNN
  mov ah,9         ;NNNdhNNNNNmmmmmmmmmmmdmmmdmNmdmmdmmdmmmddddmNNmmmmmmmNNmdNNN
  mov dl,p-100h    ;NNNdsNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNddNNN
  int 21h          ;NNNdyNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNmmNNNNNhdNNN
  mov di,4828h     ;NNNdyNNNNNNNNNNNNNNNNNNNNNNNNNNNNNmNNNNNNNNNNNNNmhmmNNNhmNNN
a:es lodsb         ;NNNhsmNNNNNNNNNNNNNNNNNNNNNNNNNNNmmNNNNNNNNNNNNNNdmdNNmydNNN
  add al,21h       ;NNNdsmNNNNNNNNNNNNNNNNNNNNNmNNNNmmmNNNNNNNNNNNNNNdmddNmsdNNN
  mov ah,al        ;NNNmhNNNNNNNNNNNNNNNNNNNNNNmmmmNmmmNNNmNNmNNNNNNNhdhdmmydNNN
  stosw            ;NNNdsmNNNNNNNNNNNNNNNNNNNNmmmmNmNmmNNNmNNmmNNNNNNhhdddmydNNN
  loop a           ;NNNdsmNNNNNNNNNNNNNNNNNNNNmmmmmmmmmNNNmNmmmNNNNNNhhdddmhdNNN
c:mov cl,0ffh      ;NNNdymNNNNNNNNNNNNNNNNNNNNNmmmmmmmmmmmmmmmmmNNNmNhhhhmmhdNNN
q:mov bl,cl        ;NNNdhNNNNNNNNNNNNNNNNmNNmNmmmmmmmmmmmmmmmmmmmNmmmhdhdmmydNNN
  lea ax,[di-10h]  ;NNNdyNNNNNNNNNNmNNNNmmmmmNmmmmmmmmmmmmmmmmmmNNNmmdmmmNmsdNNN
  not bl           ;NNNmhNNNNNNmhyhdmmNNmmmmmmmmmmmmmmmmmmmmmmmmmNNmmmmmmmmydNNN
  mov si,140h      ;NNNdhNNNNNd+:::/mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmNmydNNN
  xor dx,dx        ;NNNdmNNNNm/:shs/mmmmNmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmNNmydNNN
  push cx          ;NNNdmNNNNs:hNNNmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmNNmhdNNN
  div si           ;NNNddNNNm:oNNNNNmy/:+hs+mmmh/+////hmymmmh+:/o/////mmNNmhdNNN
  mov cx,bp        ;NNNdymNNh:hNNNNNy:yho:h:ymmh:sh:ysdh/mmd:shy+ys/hsmmNNmyhNNN
  test cl,80h      ;NNNdsmNNy:dNNNNm/ymmm/o:/mmd/mm:dmmo:dmoommmmmh/mmmmNNmydNNN
  jz d             ;NNNdsmNNs:mNNNNd:mmNms/:/smd/mm:dmm/osm:hmmmmmh/mmmmNNmhdNNN
  xchg ax,dx       ;NNNdhmNNs:dNNNNy/mmmmh::y:dd/mN:dmh+d/d:dmmmmmh/mNNNNNmydNNN
d:sub ax,5eh       ;NNNdhmNNy:hNNNNy/mmmmd::m+od/mN:dmooy:y:mmmmmmh/mmNmNNmydNNN
  imul ax,bx       ;NNNdymNNd:oNNNNd:mNNmh:/mh:y/mm:dm///:o:dmmmmmh/mmNmNNmsdNNN
  xchg ax,dx       ;NNNdsmNNN+:hNNmh:ymNmo+/mm+//mm:dh/ddh//smmmmmh/mmmNNNmsdNNN
  imul ax,bx       ;NNNdymNNNd:/shs:+:hmy:h:mmd:/mm:hosmmm:o:hmhsmh:mNmNNNmhdNNN
  mov dl,0a0h      ;NNNdymNNNNh/:::+do://yd:dmmo/md:s:ymmm/+s:/:smy:mmmmNNmhdNNN
  add ah,cl        ;NNNdsmNNNNNmhhdmNmdhmmmdmmdddmmhdddmmmdhdhhddmddmNmmNNmhNNNN
  add bl,cl        ;NNNmdmNNNNNNmmNNNNmmmmmmmdoodyyyoydyhydosyyhyyyyymmmmNmhmNNN
  pop cx           ;NNNdhmNNNNNmmmmNNmmmmmmmmdyssyym+sdodsmyymyymomyhmmmmmmydNNN
  sub bl,dl        ;NNNdmNNNNNmmmmmNNmmmmmmmmdhydyshoyshhymyyhyyh+hshmmmmmmhdNNN
  test bp,100h     ;NNNNNNNNNNmmmmmNNmmmmmmmmmmdmddddmdmddmdmhdmdddddmmmmmmshNNN
  jz e             ;NNNNNNNNNmmmmmmNmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmsdNNN
  sub bl,ah        ;NNNNNNNNNNmmmmNmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmydNNN
e:mov al,dh        ;NNNNNNNNNmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmhdNNN
  push ax          ;NNNNNNNNmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmydNNN
  push bx          ;NNNNNNNNmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmsdNNN
  push dx          ;mhyyhmNNmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmsdNNN
  push cx          ;ysososhmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmNmsdNNN
  sub dh,dl        ;ssosossymmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmNmdmNNN
  shld si,dx,4     ;ssosossosdmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmydNNN
  shld cx,bx,0ch   ;ssossssooshmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmNmsdNNN
  and si,0feh      ;ssssssooooohmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmdmNNN
  and cx,sp        ;ysooossssooshmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmydNNN
  shr bl,7         ;yososoosoossshmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmsdNNN
  mov al,b[m+bx+si];hsosssoooosssohmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmsdNNN
  ror al,cl        ;dsssssssoosssoshmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmsdNNN
  pop cx           ;dssssssssoososssdmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmsdNNN
  and al,3         ;dssssssssssoossssdmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmhmNNN
  pop dx           ;doossossssssoossssdmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmsdNNN
  pop bx           ;dssssoossssssossoosmmmmmmmmmmmmosmmmmmmmmmmmmmmmmmmmmmmshNNN
  jz h             ;dssssoooososososossymmmmmmmmdoo++mmmmmmmmmmmmmmmmmmmmmmsdNNN
  jp g             ;Nyssssosooososs+osssymmmmmhs+://smmmmmmmmmmmmmmmmmmmmNmydNNN
  inc ax           ;Ndsssoosooososooossss+/++////://dmmmmmmmmmmmmmmmmmmmmNmydNNN
  jnp f            ;Nmsssosoosooosoooooooo//yso+///:hmmmmmmmmmmmmmmmmmmmmmmsdNNN
  neg bl           ;Nmyssssoossoooooooooooohmmydo/:/mmmmmmmmmmmmmmmmmmmmmmmddNNN
f:sub dh,bl        ;Nmdossooossooosooo+ooosymm+hd//smmmmmmmmmmmmmmmmmmmmmmmyhNNm
g:and dh,ah        ;mmmsoooooosoooooooooooosym++dh/ymmmmmmmmmmmmmmmmmmmmmmmydNNN
  and dh,20h       ;mdds+osooooossoooooo+oosshs/om/ymmmmmmmmmmmmmmmmmmmmmmmydNNm
h:pop ax           ;Nmdhoooooooosoooooooooosssh+/y+hmmmmmmmmmmmmmmmmmmmmmmmhdNNm
  loopz q          ;Nmddoooooooooooo+oooo+ooossdys/dmmmmmmmmmmmmmmmmmmmmmmdyhNNm
  jnz i            ;mmdmsoooooooooooo+oooooosooymm/dmmmmmmmmmmmmmmmmmmmmmmmydNNm
  mov al,0fh       ;mmdmyooooooooooooooooooosooshm:dmmmmmmmmmmmmmmmmmmmmmmmyhNNN
  jmp j            ;mmmmhooooooooooooooooooooosood:dmmmmmmmmmmmmmmmmmmmmmmmshNNN
i:xor al,bl        ;mmmmdooooo+oooooooo+oooo+oooos:dmmmmmmmmmmmmmmmmmmmmmmmshNNN
  xor al,ah        ;mdmds++oso+ooooooooo+ooooooooo/dmmmmmmmmmmmmmmmmmmmmmmdydNNN
  aad 8            ;Ndms+++oosooooooooo++oooooooooodmmmmmmmmmmmmmmmmmmmmmmmsdNNN
  xlatb            ;Nhh+++oossooooooooooo+oooo+oooohmmmmmmmmmmmmmmmmmmmmmmmsdNNN
  and al,dl        ;Nh++++osssoooooooooooooooo+oooosdmmmmmmmmmmmmmmmmmmmmmmhmNNN
  add ax,cx        ;Nh/+/+sssssoooooooooooooooooooooymmmmmmmmmmmmmmmmmmmmmmsdNNN
  shr ax,5         ;NNso/+sssssoooooooooooo+oooooooosdmmmmmmmmmmmmmmmmmmmmmydNNN
  adc al,10h       ;NNdsyossssyy+ooo+ooooooo+ooooooooymmmmmmmmmmmmmmmmmmmmmydNNN
j:cmp b[es:di],28h ;NNNyhysssymo++++oooooosoooooo+oooodmmmmmmmmmmmmmmmmmmmmydNNN
  jz k             ;NNNdhhsosmy++++osooooooo++ooooooooymmmmmmmmmmmmmmmmmmmmhdNNN
  stosb            ;NNyhNhsshh++++ossooooooooooooooooo+dmmmmmmmmmmmmmmmmmmmsdNNN
  dec di           ;NmomdNyhm++++osssoooooooooooooo+ooosmmmmmmmmmmmmmmmmmmmshNNN
k:inc di           ;NyhNdmNms++++ssssoooooooooo+ooo+oooodmmmmmmmmmmmmmmmmmmydNNN
  jmp c            ;moNNMdNmys+-/ssssoooooooo+o++ooo+oooymmmmmmmmmmmmmmmNNmydNNN
l dw 2350h,2850h   ;yhNNMNdmdhy//ooosooooooo+ooo+ooo+oooodmmmmmmmmmmmmmmNNmsdNNN
  db 3ch,1fh,28h   ;omNNNMmddmhy+sssmsoo++oooooo++ooo+oooymmmmmmmmmmmmmNNNmshNNN
m dw 1f8h,0f5fah   ;omNNNMMmhddhsssdhssso+ooooooo+ooo++o+ommmmmmmmmmmmmNNNmhdNNN
  dw 0c03h,0a05h   ;sNNNNNNmhhmhyohdssssosoo+o+++/+ooo++oohmmmmmNmNmNmNNNNmydNNN
  dd 2f4h,0        ;yddhhhddhhhhyydsssssosoooo+++++ooo+ooosmmmmmNNNmmmmNNNmdmNNN
n:inc bp           ;hdddmmNmhhhdhmyssssoso++oo+++o+ooo+oooodmmmmNNmmmmNNNNmhmNNN
  pusha            ;dNNNNNNssydhNmsosssoo+o+oo+oo+++ooo+oooymmmmNmmmmmNNNNmydNNN
  mov dx,331h      ;sNNNNNdo+ohhmMhsosso/++o+o+ooo+++oo+ooosmmmmmmmmmmNNmNmydNNN
  mov al,3fh       ;+hNNNNh++ohNyNmhooo//+ooo++oo++/+oo++ooodmmmmNNmmmmNNNmhmNNN
  out dx,al        ;+odNNNy+++yMmhNhy::/+//+++++++o+oooo+oo+ymmmmNNmmNNNNNmsdNNN
  dec dx           ;++omNNy+++yNMhddho/+/+oooo++ooo++ooo+ooosmmmmmmmNNNNNNmsdNNN
  mov al,99h       ;+++yNms+++sNNNymho++++dysoo++ooo+oo++oooodmmmmmmmmNNmmmsdNNN
  out dx,al        ;++++hmo+o+oNmmdyy++++hmddyooo+oo+++o+oo++hmmmmmNNmNmNmmhdNNN
  mov ax,bp        ;s++++h++o+oNmhsmNd++smmmdhhyoo+++++++++oohmmNNmNNmNNNmmsdNNN
  mov bx,l         ;do+++o++o+omhydNNNs+hdmdddhhhsoo+o+++oooohmNNNNNNNNNNNmsdNNN
  and al,7         ;Nh++++++o++yhmNmmNNmmddmmmdddmdooooo++++odmNNNNNNNNNNNmydNNN
  cs xlatb         ;NNh++++++++yNNNmNNNNmmmddmmdmdmdmdhssoooymNNNNNNNNNNNNmydNNN
  cmp al,24h       ;NNNdo++++++hNNNNNNNNmmmmmdddmmhhhhdddddddmNNNNNNNNNNNNmhdNNN
  jnc o            ;oooss++++++dNNNNNNNmNNmmmmmdddhddddddddmmmNNNNNNNNNNNNmydNNN
  out dx,al        ;+++++++++++hNNNNNNmNNmmmmmmmmmmmmmmNmmmNmNNNNNNNNNNNNNmsdNNN
  mov al,7fh       ;yo+++++++++hNNNNNNNNNNmmmmmmmmmmmNmmmmmNNNNNNNNNNNNNNNmhmNNN
  out dx,al        ;dhs++++++++yNNNNNNNNNNmmmmmNmmmmmmmmmmmmNNNNNNNNNNNNNNmsdNNN
o:salc             ;Ndhs+++++++yNNNNNNNNNNmmmmmmmmNNmmmNmmmmmNNNNNNNNNNNNNmodNNN
  sub al,066h      ;NNmhyyyyyyydNNNNNNNNNNmmmmmNmmNNNNNNmNmNNNNNNNNNNNNNNNmydNNN
  out dx,al        ;NNmo+++++ooyNNNNNNNNNNNmmmmNmNNNNNNmmNmNNNNNNNNNNNmdmdhmmNNN
  daa              ;NNh+++++++++mNNNNNNNNNNNNNNNNNNNNNNmNNNNmNNNNNNNNNhsssyNNNNN
  shr bp,8         ;NNh+++++++++mNNNNNNNNNNNNNNNNNNNNNmyssssysssysssosdssyhNNNNN
  adc al,19h       ;NNy+++++++++dNNNNNNNNNNNNNNNNNNNNNN+++/os+ossoh++ydysshNNNNN
  out dx,al        ;NNyossssoooodNNNNNNNNNNNNNNNNNNNNNNo/o+oyooohoy+osdssyhNNNNN
  mov al,7fh       ;NNysssssssssdNNNNNNNNNNNNNNNNNNNNNNmddddmddmmmmddmmmmmmNNNNN
  out dx,al        ;NNssssssssssdNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN
  popa             ;NNssssssssssdNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN
  iret             ;NNssssssssssdNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN
p db 0ah,"C O N T ";NNssssssssssdNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN
  db "A C T$"      ;++::::::::::/+++++++++++++++++++++++++++++++++++++++++++++++
;Greets fly to: Bon^2 BReWErS CODEX Conscience Flush Lineout Mandarine Onslaught
;Paranoimia Quartex Rebels Razor1911 Resistance RiOT KuaiSoft and all asm coders