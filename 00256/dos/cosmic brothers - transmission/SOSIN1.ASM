;Program byl zamyslen, aby delal zhruba toto:
;var
;  x,y:integer;
;  tim:word;
;begin
;  asm mov ax,13h; int 10h; end;
;  for x:=0 to 63 do pal(x,x,x,x);
;  tim:=0;
;  repeat
;   for x:=0 to 127 do
;    for y:=0 to 79 do
;     putpixel(x*2,20+y*2,
;     trunc(
;      (abs(sin(
;               (sin(x*x/512+tim/8)*32+(y-40)*3) *6.28/(250-x)
;              )*64
;          )
;      ) *(127-x)/127
;     ),SegA000);
;   waitticks(1);
;   inc(tim);
;  until keypressed;
;end.
;
; vyraz: (abs(sin((sin(x*x/512+tim/8)*32+(y-40)*3)*6.28/(250-x))*64))
;        *(127-x)/128)
;
; je infixove:
;
;      (abs( sin(
;                ( sin(
;                       x
;                      *x
;                      /512
;                     +tim
;                      /8
;                     )
;                   *32
;                 + (y-40)
;                  *3
;                )
;                *6.28
;                /(250-x)
;               )
;           *64
;          )
;      )
;      *(127-x)
;      /128
;
; nebo:
;
;                                   trunc
;                                     ³
;                                     * ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;                                     ³                        ³
;                                    abs                   ÚÄÄ / ÄÄÄÄ¿
;                                     ³                  Ú Ä ¿       2
;                                     ³                 127  x
;                                    sin
;                                     ³
;                            ÚÄÄÄÄÄÄÄ * ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;                            ³                         ³
;                   ÚÄÄÄÄÄÄÄ + ÄÄÄÄÄÄÄÄÄÄ¿        ÚÄÄÄ / ÄÄÄ¿
;                   ³                    ³        ³         ³
;              ÚÄÄÄ * ÄÄÄÄ¿          ÚÄÄ * ÄÄ¿    PI    ÚÄÄ - ÄÄ¿
;              ³          ³          ³       ³          ³       ³
;             sin         64      ÚÄ - Ä¿    6         250      x
;              ³                  y     40
;              /ÄÄÄÄÄ8
;        ÚÄÄÄÄ + ÄÄÄÄÄÄÄ¿
;        ³              ³
;      x*x/64          tim
;
;

.386
crs segment use16
assume es:crs,cs:crs,ss:crs,ds:crs
org 100h
all:
;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
MAXY  EQU 79
MAXX  EQU 127
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
 mov  al,13h
 int  10h
 push 0A000h
 pop  es
 mov  al,3Fh
@pal:
 mov  dx,03C8h
 out  dx,al
 inc  dx
 out  dx,al
 out  dx,al
 out  dx,al
 dec  ax
 jnz  @pal
 mov  bx,offset work
 fInit
@mainloop:
 mov  di,20*320+320
 mov  ch,MAXY
@ForY:
 mov  cl,MAXX
@ForX:

 mov  al,127
 sub  al,cl
 mul  al
 shr  ax,6              ;ax=(127-x)*(127-x)/64
 add  ax,[bx+2]
 mov  [bx],ax           ;work=(127-x)*(127-x)/64+tim
 fild word ptr [bx]     ;fstack: (127-x)*(127-x)/64+tim
 fidiv word ptr [bx-4]  ;fstack: ((127-x)*(127-x)/64+tim)/8

 fsin
 fimul word ptr [bx-2]  ;fstack: sin(((127-x)*(127-x)/64+tim)/8)*64

 mov al,ch
 sub al,40
 cbw
 imul ax,ax,6           ;ax=(y-40)*6
 mov [bx],ax
 fiadd word ptr [bx]    ;fstack: sin(((127-x)*(127-x)/64+tim)/8)*64 + (y-40)*6

 mov  ax,123
 add  al,cl             ;ax=123+x
 mov  [bx],ax           ;work=123+x
 fldpi                  ;fstack: pi,sin(((127-x)*(127-x)/64+tim)/8)*64 + (y-40)*6
 fidiv word ptr [bx]    ;fstack: pi/(123+x),sin(((127-x)*(127-x)/64+tim)/8)*64 + (y-40)*6
 fmulp                  ;fstack: pi/(123+x) * (sin(((127-x)*(127-x)/64+tim)/8)*64 + (y-40)*6)
 fsin
 fabs                   ;fstack: abs(sin( pi/(123+x) * (sin(((127-x)*(127-x)/64+tim)/8)*64 + (y-40)*6) ))

;ted' chceme do [bx] dostat cl/2
;mov  al,cl
;shr  al,1
;mov  [bx],ax
 mov  [bx],cl
 shr  word ptr [bx],1

 fimul word ptr [bx]    ;fstack: x div 2 * abs(sin( pi/(123+x) * (sin(((127-x)*(127-x)/64+tim)/8)*64 + (y-40)*6) ))
 fistp word ptr es:[di] ;ve work je barva pixelu, ktera prijde na [x,y]
 scasw

 dec  cl
 jnz  @ForX
 add  di,320+66
 dec  ch
 jnz  @ForY
 inc  word ptr [bx+2]
 in   al,60h
 das
 jb   @mainloop
 retn
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
_8      dw 0008h
_64     dw 0040h
work    dw ?    ;odtud si koprocesor cte vstupni data
tim     dw ?
;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
crs ends
end all

;optimalizace:
;projit ;*!
;podivat se, jestli se v kodu (vyjma promennych) nahodou nevyskytuje
;"20 00", "40 00" nebo "DB 0F C9 40". Pokud ano, znicit promennou _NNN a
;nahradit jeji adresu adresou tohoto mista v kodu.
