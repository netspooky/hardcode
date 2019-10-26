; Amaze (fixed version)         : 128-byte intro Wolfenstein 3D raycasting engine (fasm 1.70.03/WinXP 5.1.2600)
; fixed                         : 1)divide overflow error bug 2)flickering/tearing /w double-buffer 3)speed 4)viewpoint angle bug 
; compatibility                 : XP/Win7 DOS ntvdm or size coding competition compliant systems (retrolandia.net/hugi/showthread.php?tid=4) 
; credit                        : written by Olivier Poudade 2013 aka baudsurfer^red sector incorporated 1985 (olivier.poudade.free.fr)
; credit (auxilliary)           : inspired by Justin Frankel^Nullsoft's 256-byte intro gaycast (www.1014.org/code)
; credit (auxilliary)           ; original algorithm written by John Carmack^id Software (www.armadilloaerospace.com/n.x/johnc)
; credit (auxilliary)           ; feedback (thank you) provided by Photon, Pirx, rain_strom, Sensenstahl, Shockwave, zorke
; greets                        : Adok, Frag, lordKelvin, Pirx, Rudi, Shockwave, y0bi
; shouts                        : dark bit factory forum users (www.dbfinteractive.com)
         org 100h               ; program startup  : start binary at psp+256
         pop cx                 ; program setup    : startup assumed sp=fffeh / cx=[sp]=[fffeh]=0 / sp=sp+2=0
         pop es                 ; program setup    : es=[sp]=20cdh double-buffer / sp=sp+2=0 
         pop fs                 ; program setup    : fs=[sp]=ff9fh=a000h-16=(mode 13h video memory)-16 / sp=sp+2 / [sp+2]=9a00h
	 mov al,13h             ; program setup    : set vga chained mode 320x256x8 and clear screen funtion
	 int 10h                ; program setup    : vga video bios api clear screen function
	 fldz                   ; maze angle       : st0=ANGBEG
         fldz                   ; maze angle       : st0=ANGVAL st1=ANGBEG
BEGANG:  es lodsb               ; buffer to screen : al=[es:si++]
         mov [fs:si+7d0fh],al   ; buffer to screen : 7d0fh=32015b=middle of *this column's screen offset (width*height/2) with ff9fh fixup / si=[32335;32015]
         loop BEGANG            ; buffer to screen : 1st time cx=0=>no loop / after cx=[0ffffh;0]=[65535b;O] from "loop BEGANG"
         salc                   ; clear buffer     : al=cf=0 fixed palette index color pixel
         dec cx                 ; clear buffer     : cx-=1=>cx=0ffffh=65535b
         rep stosb              ; clear buffer     : [es:di++]=0 65535 times
         fadd dword [ANGADD]    ; maze angle       : st0=ANGVAL*ANGADD st1=ANGBEG / [cs:ANGADD]=3bb90372h=0.0056f as angle stepping
	 fld st0                ; maze angle       : st0=ANGVAL*ANGADD st1=ANGVAL*ANGADD st2=ANGBEG
	 fld1                   ; maze angle       : st0=1 st1=ANGVAL*ANGADD st2=ANGVAL*ANGADD st3=ANGBEG
	 faddp st3,st0          ; maze angle       : st0=ANGVAL*ANGADD st1=ANGVAL*ANGADD st2=ANGBEG++ 
	 mov bp,319             ; column to screen : bp=screen width-1=xloop viewport index
ADDANG:  fadd dword [ANGADD]    ; viewport angle   : st0=(ANGVAL+ANGBEG)*ANGADD st1=ANGBEG*ANGADD st2=ANGBEG
         fld st0                ; viewport angle   : st0=(ANGVAL+ANGBEG)*ANGADD st1=(ANGVAL+ANGBEG)*ANGADD st2=ANGBEG*ANGADD st3=ANGBEG
         fsincos                ; viewport angle   : st0=cos((ANGVAL+ANGBEG)*ANGADD) st1=sin((ANGVAL+ANGBEG)*ANGADD) st2=(ANGVAL+ANGBEG)*ANGADD st3=ANGBEG*ANGADD st4=ANGBEG
         fld st4                ; viewport angle   : st0=ANGBEG st1=cos((ANGVAL+ANGBEG)*ANGADD) st2=sin((ANGVAL+ANGBEG)*ANGADD) st3=(ANGVAL+ANGBEG)*ANGADD st4=ANGBEG*ANGADD st5=ANGBEG
         fld st5                ; viewport angle   : st0=ANGBEG st1=ANGBEG st2=cos((ANGVAL+ANGBEG)*ANGADD) st3=sin((ANGVAL+ANGBEG)*ANGADD) st4=(ANGVAL+ANGBEG)*ANGADD st5=ANGBEG*ANGADD st6=ANGBEG
         mov cx,7e0h            ; viewport angle   : 07e0h=2016b=32*63 size of maze portion to cast
ADDRAY:  fadd st0,st3           ; raycast depth    : st0=ANGBEG+sin((ANGVAL+ANGBEG)*ANGADD) st1=ANGBEG st2=cos((ANGVAL+ANGBEG)*ANGADD) st3=sin((ANGVAL+ANGBEG)*ANGADD) st4=(ANGVAL+ANGBEG)*ANGADD st5=ANGBEG*ANGADD st6=ANGBEG
         fist dword [si]        ; raycast depth    : [si]=ANGBEG+sin((ANGVAL+ANGBEG)*ANGADD)
         fxch                   ; raycast depth    : st0=ANGBEG st1=ANGBEG+sin((ANGVAL+ANGBEG)*ANGADD) st2=cos((ANGVAL+ANGBEG)*ANGADD) st3=sin((ANGVAL+ANGBEG)*ANGADD) st4=(ANGVAL+ANGBEG)*ANGADD st5=ANGBEG*ANGADD st6=ANGBEG
         fadd st0,st2           ; raycast depth    : st0=ANGBEG+cos((ANGVAL+ANGBEG)*ANGADD) st1=ANGBEG+sin((ANGVAL+ANGBEG)*ANGADD) st2=cos((ANGVAL+ANGBEG)*ANGADD) st3=sin((ANGVAL+ANGBEG)*ANGADD) st4=(ANGVAL+ANGBEG)*ANGADD st5=ANGBEG*ANGADD st6=ANGBEG
         mov bx,[si]            ; raycast depth    : bh=[si+1]=ANGBEG+sin((ANGVAL+ANGBEG)*ANGADD)
         fist dword [si]        ; raycast depth    : [si]=ANGBEG+cos((ANGVAL+ANGBEG)*ANGADD)
         fxch                   ; raycast depth    : st0=ANGBEG+sin((ANGVAL+ANGBEG)*ANGADD) st1=ANGBEG+cos((ANGVAL+ANGBEG)*ANGADD) st2=cos((ANGVAL+ANGBEG)*ANGADD) st3=sin((ANGVAL+ANGBEG)*ANGADD) st4=(ANGVAL+ANGBEG)*ANGADD st5=ANGBEG*ANGADD st6=ANGBEG
         mov bl,[si+1]          ; raycast depth    : bl=[si+1]=ANGBEG+cos((ANGVAL+ANGBEG)*ANGADD)
         cmp byte [bx],ah       ; raycast depth    : test map wall hit ([bx]=0) at ray from null bitmask in code segment
         loopnz ADDRAY          ; raycast depth    : 1)if wall found exit raycast loop 2)ANGVAL++ 3)07e0h=2016b=32*63=maze portion to cast 4)else continue
RAYHIT:  neg cx                 ; wall found       : cx=[1;2016] equivalent / fixup divide overflow
         add cx,7f0h            ; wall found       ; 07f0h=2032=32*63+16 / was add cx,10h when counter register increased
         mov ax,[ANGMUL]        ; depth to height  : [cs:ANGMUL]=3bb9h=15289d as zscale divisor lower word
         cwd                    ; depth to height  : dx=0 divisor upper word
         div cx                 ; depth to height  : cx=divisor=distance ax=result=wall height/2 dx=remainder
         mov cx,4               ; wall found       : reset fpu stack state ...
POPFPU:  fstp st0               ; wall found       : ... from : st0=ANGBEG+sin((ANGVAL+ANGBEG)*ANGADD) st1=ANGBEG+cos((ANGVAL+ANGBEG)*ANGADD) st2=cos((ANGVAL+ANGBEG)*ANGADD) st3=sin((ANGVAL+ANGBEG)*ANGADD) st4=(ANGVAL+ANGBEG)*ANGADD st5=ANGBEG*ANGADD st6=ANGBEG
         loop POPFPU            ; wall found       : ... to : st0=(ANGVAL+ANGBEG)*ANGADD st1=ANGBEG*ANGADD st2=ANGBEG
         xchg ax,cx             ; depth to height  : ax=0 cx=result=wall height/2 (dx=remainder)
         xchg ax,si             ; height to screen : ax=previous column's lowest vertical pixel si=0 (dx=remainder) 
         mov di,bp              ; height to screen : di= this column's xloop viewport index
         cmp cx,3ch             ; height to screen : clipping test (wall<120 ?)  
ANGADD:	 jc ADDTEX              ; height to screen : no clipping needed 
ANGMUL:	 mov cx,3bh             ; height to screen : clipping (-1 byte candidate with glitchy mov cl,3bh)
ADDTEX:  mov ax,cx              ; height to screen : note this is where ah is nulled for test byte [bx],ah above 
ADDCOL:  stosb                  ; column to screen : plot upper vertical pixel
         sub di,321             ; column to screen : get next upper vertical pixel
         mov [es:si+bp],al      ; column to screen : plot lower vertical pixel
         add si,320             ; column to screen : get next lower vertical pixel
         loop ADDCOL            ; column to screen : repeat until all pixels of *this column wall processed
         dec bp                 ; column to screen : decrement screen column index
         jnz ADDANG             ; column to screen : repeat until all 320 columns [319,0] of this screen processed 
         fstp st0               ; maze angle       : st0=ANGBEG*ANGADD st1=ANGBEG
         loop BEGANG            ; maze angle       : process next frame / cx=0ffffh for next clear screen