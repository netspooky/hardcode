;1 kanal, 1 instrument (ladovanej pro kazdou notu), echa

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
;ted' uz to ale neplati, ze ne?

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

;jemna paleta neni az tak nutna, rozdil je temer k nepoznani.
; mov  al,3Fh
;@pal:
; mov  dx,03C8h
; out  dx,al
; inc  dx
; out  dx,al
; out  dx,al
; out  dx,al
; dec  ax
; jnz  @pal

 mov  bx,offset work
 fInit
 mov  si,offset zaTune  ;si=adresa pristi noty

@MAINLOOP:
 mov  di,(100-MAXY-1)*320+320
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
 fidiv word ptr [bx+offset _8-offset work]      ;fstack: ((127-x)*(127-x)/64+tim)/8

 fsin
 fimul word ptr [bx+offset _64-offset work]     ;fstack: sin(((127-x)*(127-x)/64+tim)/8)*64

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

;do es:[di] zapise cl/8*st(0)+16 (tj. cislo v rozsahu 16..31)
; mov  [bx],cl
; shr  word ptr [bx],1+2 ;zmenseni z 0..127 na 0..15
; fimul word ptr [bx]   ;fstack: x div 2 * abs(sin( pi/(123+x) * (sin(((127-x)*(127-x)/64+tim)/8)*64 + (y-40)*6) ))
; fistp word ptr es:[di]        ;ve work je barva pixelu, ktera prijde na [x,y]
; add byte ptr es:[di],16;pouzivame-li barvy 16..31, musime pricist 16
; scasw

;<dela totez co predesly zakomentovany a stejne dlouhy kod, ale rychleji
 fimul word ptr [bx+offset _64-offset work]
 fistp word ptr [bx]
 mov al,cl
 imul byte ptr [bx]
 shr ax,3+6
 add al,16
 stosw
;/>

 dec  cl
 jnz  @ForX
 add  di,320+66
 dec  ch
 jnz  @ForY
 inc  word ptr [bx+2]

;kazdej nekolikatej snimek zahraje notu
;si=adresa noty
;bp=citac kolik framu zbyva do dalsi noty
     shr bp,1
     jz @play
     cmp bp,80h
     jnz @pause
     dec si
   @play:
     push bx
     call NextNote
     pop bx
     or bp,bp
     jnz @pause
     mov bp,2000h
   @pause:

;*ceka na paprsek (melodie bude normalnejsi=rychlejsi, ale zavisla na CPU)
;     mov dx,3dah
;@r2: in al,dx
;     test al,8
;     jz @r2
;@r1: in al,dx
;     test al,8
;     jnz @r1

 in   al,60h
 das
 jb   @MAINLOOP
 retn
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;[ADLIBovy veci]
RestartTune:
;        xor     byte ptr [bx+offset zaoktavou-offset work-1],1 ;strida dve oktavy
        mov     si,offset Tune
NextNote: ;{vstup si=adresa noty, nici ax,bx,cx=0,dx=389h,si=adresa pristi noty}
        lodsb
        dec     ax
        jz      RestartTune

        pusha
        mov     si,offset Data
@1:     lodsw
         push ax
         add al,3
         call Adlib
         pop ax
        call    Adlib
        dec     ah
        jnz     @1
        popa

        mov     ah,8+4+1
zaoktavou:
        sub     ax,bp
        rol     ax,8+2
        mov     bx,0a0b0h
        xchg    bh,al
        call    Adlib ;frequency low byte
        xchg    ax,bx
;       call    Adlib ;frequency high byte

Adlib:  ;{input al=port, ah=data, destroys al,cx=0,dx=389h}
        mov     dx,388h
        call    write
        inc     dx
        mov     al,ah
write:  out     dx,al
        mov     ch,1
@3:     in      al,dx
        loop    @3
        ret

tune    db      740/4+1,554/4+1,370/4+1,740/4+1
        db      740/4+1,554/4+1,370/4+1,740/4+1
        db      880/4+1,659/4+1,440/4+1,880/4+1
        db      988/4+1,659/4+1,494/4+1,988/4+1
zatune: ;nasledovat musi bajt 1!

data    db      01h,02h ;{}
;       dw      00008h  ;{lze vynechat, nastaveni nema vliv}
;       dw      000bdh  ;{udela key off...nelze behem hrani}

ins1    db      0b0h,0  ; key off
        db      020h,0e0h; 1. modulator frequency multiple, misc flags
;       db      023h,0f0h; 2. modulator frequency multiple, misc flags
_64     db      040h,0  ; 1. output level
;       db      043h,0  ; 2. output level
        db      060h,087h; 1. attack+decay
;       db      063h,087h; 2. attack+decay
        db      080h,0ffh; 1. sustain+release
;       db      083h,0ffh; 2. sustain+release
        db      0e0h,0  ; 1. waveform select
;       db      0e3h,0  ; 2. waveform select
        db      0c0h,1  ; feedback+algorithm
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
_8      dw 0008h
;_64    dw 0040h ;zakomentovat, pokud neni pouzito vyse
work    dw ?    ;odtud si koprocesor cte vstupni data
tim     dw ?
;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
crs ends
end all

;na zaver:
;projit ;*!
;podivat se, jestli se v kodu (vyjma promennych) nahodou nevyskytuje
;"40 00" nebo "08 00". Pokud ano, znicit promennou _cislo a
;nahradit jeji adresu adresou tohoto mista v kodu.

;"amplitudu" vln zmeni parametr v instrukci "imul ax,ax,6"
;"perioda" vln: zmena vice zpusoby, napr. dosazenim jineho cisla za "_8"
