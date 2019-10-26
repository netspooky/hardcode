;1 kanal, 1 instrument (ladovanej jen na zacatku tune)

;Program by mel delat zhruba toto:
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
MAXY  EQU 100    ;1..100 se vejde na obrazovku, od 105 preteka
MAXX  EQU 127   ;1..127 je ok, od 128 se objevuji spatne barvy
sync=0          ;ceka na paprsek
introsize=256   ;ocekavana velikost intra, ovlivnuje nektere optimalizace
zarovnat=0      ;FINALNI optimalizace naprosto zavisla na vsem ostatnim, pred jakoukoliv zmenou vypnout! tento strasny hacking vsechno dulezite zarovna na sude adresy takze intro je rychlejsi
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
 push 0a000h
 pop  es
 mov  al,13h
 int  10h
if introsize eq 256
 mov  bh,2   ;pri delce intra 256 vyuzijeme ze bl=0 a nemusime ho nastavovat
else
 mov  bx,offset work
endif
; fInit ;v pripade nouze lze bez obav zakomentovat
; mov  si,offset zaTune  ;si=adresa pristi noty
; trik: vyuzijeme ze si=100h, tj. ted vime ze pristi nota je 1.bajt intra

;Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä

@OCCASIONAL_STUFF:      ;jednou za cas zahraje notu a zmeni paletu

 PUSH BX

 mov cl,255
@paleta:
 mov  dx,03C8h
 mov  al,cl
 out  dx,al
 inc  dx
if introsize lt 256
 mov  bl,2      ;pokud je intro kratsi nez 256, mame bh=1 uz nastavene
else
 mov  bx,102h
endif
@rgb:

;Dee's tricky palette section:
; rgb slozky nejjasnejsi barvy jsou na adresach 102,101,100h
; neustale je vsechny inkrementuje a nechava pretekat
; aby to vypadalo dobre, misto rgb pak pocita s abs(r)/2,abs(g)/2,abs(b)/2
 inc  byte ptr [bx]
 mov  al,[bx]
 @neguj:        ; pocita absolutni hodnotu al, btw jina delsi rutina je: cbw; xor al,ah; sub al,ah
  neg al
  jl  @neguj    ; je-li vysledek zaporny, neguje, v al zustane cislo z 0..128
 shr  al,1      ; lze zakomentovat, vzhled se trochu zmeni
 sub  al,cl     ; dela gradient zleva doprava
 neg  al        ; prohodi svetly<->tmavy barvy
 jns  @rgb0     ; oreze zaporny cisla na nulu
  mov al,0
  @rgb0:
 cmp  al,63     ; oreze vysoky cisla na 63
  jc  @rgb1
  mov al,63
  @rgb1:
 OUT  DX,AL     ; posle to na port

 dec  bl
 jns  @rgb
 loop @paleta

 call @NextNote

 POP  BX

;Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä

@REGULAR_STUFF:         ; v kazdym snimku kresli vlny a testuje klavesnici

 shl  bp,1
 jz   @occasional_stuff


 mov  di,(100-MAXY)*320 + 16
 mov  cl,MAXY
@ForY:
 mov  ch,MAXX
@ForX:

 mov  al,MAXX
 sub  al,ch
 mul  al
 shr  ax,6              ;ax=(127-x)*(127-x)/64
 add  ax,[bx+2]
 mov  [bx],ax           ;work=(127-x)*(127-x)/64+tim
 fild word ptr [bx]     ;fstack: (127-x)*(127-x)/64+tim
 fidiv word ptr [bx+_8-work]  ;fstack: ((127-x)*(127-x)/64+tim)/8

 fsin
 fimul word ptr [bx+_64-work]  ;fstack: sin(((127-x)*(127-x)/64+tim)/8)*64

 mov al,cl
 sub al,MAXY/2
 cbw
 imul ax,ax,6           ;ax=(y-40)*6
 mov [bx],ax
 fiadd word ptr [bx]    ;fstack: sin(((127-x)*(127-x)/64+tim)/8)*64 + (y-40)*6

 mov  ax,123
 add  al,ch             ;ax=123+x
 mov  [bx],ax           ;work=123+x
 fldpi                  ;fstack: pi,sin(((127-x)*(127-x)/64+tim)/8)*64 + (y-40)*6
 fidiv word ptr [bx]    ;fstack: pi/(123+x),sin(((127-x)*(127-x)/64+tim)/8)*64 + (y-40)*6
 fmulp                  ;fstack: pi/(123+x) * (sin(((127-x)*(127-x)/64+tim)/8)*64 + (y-40)*6)
 fsin
 fabs                   ;fstack: abs(sin( pi/(123+x) * (sin(((127-x)*(127-x)/64+tim)/8)*64 + (y-40)*6) ))

 mov  [bx],ch
 fimul word ptr [bx]    ;fstack: x * abs(sin( pi/(123+x) * (sin(((127-x)*(127-x)/64+tim)/8)*64 + (y-40)*6) ))
 fistp word ptr es:[di] ;ve work je barva pixelu, ktera prijde na [x,y]
 scasw

 dec  ch
 jnz  @ForX
 add  di,320+320-2*MAXX
 loop @ForY
 @timespin:inc  word ptr [bx+2]

ifdef sync
     ;ceka na paprsek
     mov dl,0dah        ;ocekava dh=3
@r2: in al,dx
     test al,8
     jz @r2
;@r1: in al,dx
;     test al,8
;     jnz @r1
endif

 in   al,60h
 dec  ax        ; ocekavame ah=0
 jnz  @REGULAR_STUFF
ifdef zarovnat
 retn
endif

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

;[ADLIBovy veci]
@RestartTune:
;        mov     al,8   ; pravidelne obraci smer vln
;        xor     byte ptr [offset @timespin+1],al
        mov     si,offset Data
@FillNextRegister:
        lodsw
        call    @Adlib
        cmp     ah,iend
        jnz     @FillNextRegister

@NextNote: ;{vstup si=adresa noty,dh=3!, nici ax,bx,cx=0,dx=389h,si=adresa pristi noty}
        mov     ah,8+3
        mov     bx,0a0b0h

ifdef sync
        db 0bdh  ;zacatek mov bp,8
else
        inc bp
endif
_8      dw 8     ;jinak tez or [bx+si],al

randomize=5            ;prida nahodne jevy

if randomize eq 1      ;vyssi noty
        in al,40h
        cmp al,100
        adc ah,cl
endif
if randomize eq 2       ;vyssi noty+nahodna modulace
        in al,40h
        cmp al,100
        out dx,al
        adc ah,cl
endif
if randomize eq 3       ;vyssi noty+nahodna modulace+bile vlny
        in al,40h
        cmp al,100
        out dx,al
        out dx,al
        out dx,al
        adc ah,cl
endif
if randomize eq 4       ;vyssi noty+nekdy nahodna modulace+nekdy sede vlny
        in al,40h
        test al,2
        jnz @xx
        inc ah
        out dx,al
        out dx,al
        out dx,al
        @xx:
endif
if randomize eq 5       ;vyssi noty+nekdy nahodna modulace
        in al,40h
        test al,32;+16  ;pro 32 v 50% pripadu, pro 32+16 v 75%
        jz @xx
        inc ah
        out dx,al
        @xx:
endif

        lodsb
        cmp     al,byte_za_tune
        jz      @RestartTune
        rol     ax,8+2
        xchg    bh,al
        call    @Adlib ;frequency low byte
        xchg    ax,bx
;       call    @Adlib ;frequency high byte

@Adlib:  ;{input al=port,ah=data,dh=3, destroys al,cx=0,dx=389h}
        mov     dl,88h  ;ocekava dh=3
        call    @write
        inc     dx
        mov     al,ah
@write: out     dx,al
        mov     ch,1
@write3:in      al,dx
        loop    @write3
@ret:   ret

data    dw      02001h
;       dw      00008h  ;lze vynechat, nastaveni nema vliv
;       dw      000bdh  ;udela key off...nelze behem hrani

ins1    db      176,0   ; key off
        db      32 ,1   ; 1. modulator frequency multiple, misc flags
        db      35 ,192 ; 2. modulator frequency multiple, misc flags
        db      64 ,200 ; 1. output level
_64     db      67 ,0   ; 2. output level
        db      96 ,012h; 1. attack+decay
        db      99 ,0f1h; 2. attack+decay
        db      128,05fh; 1. sustain+release
        db      131,05bh; 2. sustain+release
;       db      224,3   ; 1. waveform select   nema slysitelny vliv
        db      227,1   ; 2. waveform select
        db      192,iend; feedback+algorithm
                    iend=6+8

tune    db      740/4,554/4,370/4,740/4
        db      740/4,554/4,370/4,740/4
        db      880/4,659/4,440/4,880/4
        db      992/4,659/4,494/4,988/4
byte_za_tune = 067h     ;jakykoliv bajt neobsazeny v tune, musi se rovnat prvnimu bajtu intra-1!
zatune  db      byte_za_tune
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
ifdef zarovnat
        db ?
endif
;_8      dw 8
;_64     dw 0040h
work    dw ?    ;odtud si koprocesor cte vstupni data
tim     dw ?    ;timer
;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
crs ends
end all

;"amplitudu" vln zmeni parametr v instrukci "imul ax,ax,6"
;"perioda" vln: zmena vice zpusoby, napr. dosazenim jineho cisla za "_8"
