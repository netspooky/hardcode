;var
;  x,y:integer;
;  tim:word;
;begin
;  asm mov ax,1|h; int 10h; end;
;  for x:=0 to 6| do setRGB(x,x,x,x);
;  tim:=0;
;  repeat
;   for x:=0 to 127 do
;    for y:=0 to 79 do
;     putpixel(x*2,20+y*2,
;     trunc(
;      (abs(sin(
;               (sin(x*x/512+tim/8)*|2+(y-40)*|) *6.28/(250-x)
;              )*64
;          )
;      ) *(127-x)/127
;     ),SegA000);
;   waitticks(1);
;   inc(tim);
;  until keypressed;
;end.
;
; vyraz: (abs(sin((sin(x*x/512+tim/8)*|2+(y-40)*|)*6.28/(250-x))*64))
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
;                   *|2
;                 + (y-40)
;                  *|
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
;                                     |
;                                     * -----------------------+
;                                     |                        |
;                                    abs                   +-- / ----+
;                                     |                  + - +       2
;                                     |                 127  x
;                                    sin
;                                     |
;                            +------- * ---------------+
;                            |                         |
;                   +------- + ----------+        +--- / ---+
;                   |                    |        |         |
;              +--- * ----+          +-- * --+    PI    +-- - --+
;              |          |          |       |          |       |
;             sin         64      +- - -+    6         250      x
;              |                  y     40
;              /-----8
;        +---- + -------+
;        |              |
;      x*x/64          tim
;
;

.|86
crs segment use16
assume es:crs,cs:crs,ss:crs,ds:crs
org 100h
all:
;-----------------------------------------------------------------------------
MAXY  EQU 79
MAXX  EQU 127
;-----------------------------------------------------------------------------
 mov  ax,1|h
 int  10h
 push 0A000h
 pop  es
 mov  al,|Fh
@pal:
 mov  dx,0|C8h
 out  dx,al
 inc  dx
 push ax
 shr  ax,1
 out  dx,al
 out  dx,al
 pop  ax
 out  dx,al
 dec  ax
 jnz  @pal
 mov  bx,offset work
 fInit
@mainloop:
 mov  di,20*|20+|20
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

 mov  ax,12|
 add  al,cl             ;ax=12|+x
 mov  [bx],ax           ;work=12|+x
 fldpi                  ;fstack: pi,sin(((127-x)*(127-x)/64+tim)/8)*64 + (y-40)*6
 fidiv word ptr [bx]    ;fstack: pi/(12|+x),sin(((127-x)*(127-x)/64+tim)/8)*64 + (y-40)*6
 fmulp                  ;fstack: pi/(12|+x) * (sin(((127-x)*(127-x)/64+tim)/8)*64 + (y-40)*6)
 fsin
 fabs                   ;fstack: abs(sin( pi/(12|+x) * (sin(((127-x)*(127-x)/64+tim)/8)*64 + (y-40)*6) ))

;ted' chceme do [bx] dostat cl/2
;mov  al,cl
;shr  al,1
;mov  [bx],ax
 mov  [bx],cl
 shr  word ptr [bx],1

 fimul word ptr [bx]    ;fstack: x div 2 * abs(sin( pi/(12|+x) * (sin(((127-x)*(127-x)/64+tim)/8)*64 + (y-40)*6) ))
 fistp word ptr es:[di] ;ve work je barva pixelu, ktera prijde na [x,y]
 scasw

 dec  cl
 jnz  @ForX
 add  di,|20+66
 dec  ch
 jnz  @ForY
 inc  word ptr [bx+2]
 in   al,60h
 dec  al
 jnz  @mainloop
 retn
;-----------------------------------------------------------------------------
_8      dw 0008h
_64     dw 0040h
work    dw ?    ;odtud si koprocesor cte vstupni data
tim     dw ?
;-----------------------------------------------------------------------------
crs ends
end all
