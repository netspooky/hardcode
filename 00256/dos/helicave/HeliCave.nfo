;****************************************************************************
;HeliCave a 256 bytes game by Baudsurfer/rsi 2014 aka olivier.poudade.free.fr
;                   _ _   --           - -__     -_
;                           --  --___     _ __--__ -" _
;                             _       _ --        -_ "-_
;                           /;:`.                  _--,_
;          ______        _,-'._,'                 /"("\"\
;   _,--'''      `'-._,-'_,-' `'               _/"/"|\ )\>_
; ,'  ` - .,_  __,-' ),-'                   _/"_." _/ / / \"\
;(       __|-`' . _,'/                   /""_-" ,/"  /\  \ ) "-,_
; `--...'___,..--'  /                 _-"/ ( .-/ \ !   )  \ _\"-_"\_
;    /     _/,-'_,-' _  _ __  ___ _-"/_-"   / (    |  / \  | \  \_- "-_  __ _
;   (`---'' _,-' |_,- - --    -<_"__" /  _/|   \ \ | /! \  \  -_( _"-<_">-- -
;    `----''|_,--'                       --"--"-" "-"' "-"  '"  _
;    -'  _,-'  jrei  "" -_O   "O-'         '">        __ -  -
;                 __     - O       __ - - "      - - jjs
;                 _ .-- "    - """
;Synopsis  : Help helicopter pilot TC save Island Hoppers charity funds
;          : from bankrupcy by escaping the nine Hawaïan island underwater 
;          : volcano caves through your unique flying skills avoiding the
;          : lethal earthquake pillow lava flow thus saving the children.
;          : See http://www.ltcstudentweb.com/birrn/charitable-work.html
;Controls  : <Arrow Up/Arrow Down> inscrease helicopter altitude.
;Tested on : WinXP SP3=Yes, Win7 v32-bit=Maybe, DosBox all=No.
;Credits   : Jens "jrei" Reissenweber (ascii) John "jjs" Stachowicz (ascii)
;Greets    : baah Cyg ferris Maracuja p01 Rez rrrola rudi sensenstahl Sir
;          : Stingray wysiwtf and all forgotten assembly language programmers 
;YouTube   : http://youtu.be/pcdHY-eJVIY
;****************************************************************************
    org 100h              ;assumed dl=0 cx=ff sp=di=-2 bp=9xxh
str equ 0f000fd1ch        ;little endian str("L-0 " - "0000")
beg:mov dword [si-26h],str;cs:0dah free placeholder in psp dta
    mov al,13h            ;ah=set video mode,al=chained 320*200*256 AND cls
    int 10h               ;heli. sprite=ascii(236)+ascii(235)+...ascii(195)
spr:int 29h               ;dos 2.x+ fast character i/o,al=char to write
    dec al                ;reverse charmap order asci(255)->asci(108)
    loop spr              ;len(charmap)=93h/147 vs. insufficient 13h/19
    lgs cx,[bx]           ;ds=9fffh,bx=0,cx=[0]=20cdh=8397d
    sub di,cx             ;si=org=100h,di=0fffeh-20cdh=0df31h
    rep gs movsb          ;copy heli sprite bytes to cs:df31h
    mov al,13h            ;ntvdm can't pop ax with gs used apparently
    int 10h               ;clear screen short form
    les di,[bx]           ;bx=0,di=terrain array start address=20cdh=8397d
    mov al,051h           ;bl=si+0aeh bh=0 ax=seed/ang
    mov dl,83h            ;dl=synced al+50 param
bez:inc dl                ;al=bl=x ax=dw coord_x "mov dl,al"
    mov bl,al             ;very modified tiny sine (left original comments)
    pusha                 ;save ax cx
    mul al                ;ax=x*x
    mul cl                ;ax=x*x*4/pi*pi
    xchg ax,bx            ;bx=ax=x*x*4/pi*pi
    mul ch                ;ax=x*4/pi
    shr ax,3              ;tweaked to reproduce some procedural graphics
    sbb ax,bx             ;ax=(x*4/pi)-x*x*(4/pi*pi)
    mov cx,0c0bh          ;ch=write gfx pixel fun, cl=color cx=col
    and ax,0fc0h          ;and 0000111111100000b  ax=(ax/32)%128=[0,127]
    rol ax,cl             ;=sar ax,cl/and ax,127 /w cl=5, enables cl=11 use
    inc ah                ;sub ax,64=position bezel rightside
    xchg ax,cx            ;cx=col dx=row al=pixel color bh=ignored page
    int 10h               ;bios video api dx=row bh=ignored 13H mode page
    popa                  ;restore ax cx
skp:inc ax                ;inc seed/angle
    loop bez              ;repeat 65535 times
snd:mov dx,331h           ;dx=midi command port 331h (helicopter soundfont)
    mov al,3fh            ;3fh=set UART mode on
    out dx,al             ;send midi command
    dec dx                ;dx=midi data/status port 330h
    mid equ 389a7dcah     ;endian order cah=program change 7dh=program num.
    mov dword [si],mid    ;... 9ah=channel select (11), 38h=note value
lev:dec cl                ;byte rollover cl=255
ini:inc di                ;store flat terrain value before
    mov [di],dl           ;flatten level start for safety
    outsb                 ;output dat msg. opportunistic note vol and on (7)
    loop ini              ;255 columns landmark collision-free level start
    inc byte [0dch]       ;[220d]++=increase level number
gam:mov si,0dah           ;si=218d=hexa val score head ptr
gen:inc dx                ;assume PF(t)=1=>y=y+1
    in al,40h             ;read rand from 8253 pic2/pit channel 0
    aaa                   ;garble and affect flags
    jp dwn                ;probability(pf)=50%
    dec dx                ;PF(t)=0=>y=y
    dec dx                ;PF(t)=0=>y=y-1
dwn:test dl,128           ;poor man's clipping : y>128 ?
    jnz gen               ;repeat until valid conforming terrain value
    mov ah,al             ;save rnd val in case of earthquake displacement
adv:inc di                ;di++=advance map ptr (speed/3)
    mov [di],dl           ;store new col terrain value
    mov cl,0ch            ;score format 8 chars+len(levelstr)=4 preceeding
    pusha                 ;save di=*map si=*score cx=len(score) bp=heli_y
asc:lodsb                 ;handle this* unit digit
    add al,30h            ;normalize to ascii '0'
    int 29h               ;dos 2.x+ fast character i/o,al=char to write
    loop asc              ;repeat left for (n-1) unit digits
    mov cl,0bfh           ;x=191 wide ending at 255
    test byte [si-3],cl   ;bit test for earthquake event true for digit 0
    jnz frm               ;if no earthquake then goto frame
    sub cl,ah             ;add eathquake displacement
frm:mov bl,[di]           ;terrain intervals bl=lo limit
    add bx,-98            ;-((256-64)/2)-sp startup value
    add bx,sp             ;decrease cave height=increase level difficulty
    mov dX,0c8h           ;display dx=row=200d
tex:mov ax,di             ;texture texel=x+dx
    imul dl               ;tex=(x*dx)*y
    aaa                   ;tex&15>9 ? tex+=262 : tex&=15
    and ax,sp             ;tex&15>9 ? tex+=262&sp : tex&=15&sp
    cmp dl,bl             ;(clipping) y<y2 ? top terrain above cave
    jnc put               ;if so then tex
    cmp dl,[di]           ;y>y1 ? bottom terrain under cave
    jc put                ;if so then text
    salc                  ;else y1<y=inside cave=no tex<y2
put:cmovz ax,cx           ;cave running lava outline if y=y1 or y=y2
    mov ah,0ch            ;(plot) bios video api fx plot (cx,dx)=al
    dec dx                ;(clipped) row-- predec accounts for scanline 0
    int 10h               ;bios video api
    jnz tex               ;repeat for all 191 rows
    dec di                ;di=new frame map window col idx--
    loop frm              ;all 191 cols done ?
    mov dl,9              ;height
    mov si,0e925h         ;sprite buffer in cs with bell beep=59685d
    lea di,[bp+9eb5h]     ; sprite offset on screen=bp+40629d
    mov [si+4],di         ;si=0e929h cheap helicopter rotor animation
cpy:mov cl,5              ;sprite width=10
    rep movsw             ;sprite si+=10 di+=10 next row
    cmpsw                 ;collision [ds:si+=2]>[es:di+=2] ?
    jnc row               ;no collision detected goto
die:int 1ah               ;ah=0=fun bios get system time
    test dl,dl            ;dl=bda 18.2 Hz rtc little endian hibyte
    jnz die               ;have max 14"=(256/18.2)" elapsed ? Dirty exit
row:mov cl,9ah            ;sprite cx=(scanline-sprite-collisiontest)/2
    cmpsw                 ;si+=2 di+=2 (prefix rep=repnz unfit)
    loop $-1              ;next row  (speed vs. size) 5*2+2+154*2=320
    dec dx                ;dx=row--
    jnz cpy               ;row==sprite height ?
    popa                  ;restore di=*map si=*score cx=len(score) bp=y
    in al,60h             ;al=polled scancode of kbd 8042 controller
    aaa                   ;up=up down=up default=gravity startup=liftoff
    mov bx,140h           ;assumption key up false
    jc kbd                ;bx=+320 key up false =>altitude--
    neg bx                ;bx=-320 key up true =>altitude++ (cyclic stick)
kbd:add bp,bx             ;bp+=320(down) or bp-=320(up)
    rep lodsb             ;si+=cl=0d3h=decimal score tail ptr, clears cf
hex:dec si                ;si-- ascending order=stored left to right (df=0)
    mov al,byte [si]      ;get decimal unit
    inc ax                ;test if decimal unit overflow
    aaa                   ;ascii adjust after addition
    jnc ten               ;cf=0 => (al AND 0fh)<10
    mov ax,cx             ;al=0 reset unit digit and clear ah
ten:mov byte [si],al      ;player score=heli progression=linear delta t 
    jc hex                ;cf preserved -> add carry to next bcd left ?
    mov al,0e2h           ;al=10^4 off=cursy=int(226/40)=cursx=(226/40)%25
    mov [fs:450h],al      ;set bda x cursor pos. for next putchar call
mov [fs:41ch],al          ;avoid key overflow,buff tail ptr=buff head ptr+al
    cmp si,ax             ;is last rollover unit=10^4 ?
    jnz gam               ;if last rollover unit<10^4 return to same level
    pusha                 ;sp-=16=new cave height for new level
    call lev              ;sp-=2=new texture scheme for new level