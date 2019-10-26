; 4kB intro for WiRED96  --- code by Bear/Sinope
;Contact:
;   e-mail: lindner@elf.stuba.sk
;   fido:   2:422/81.8
;   tel:    ++42 7 818557
;   smail:  Michal Lindner
;           Sustekova 15
;           851 04 Bratislava
;           Slovakia
;
; Compile with:
;  tasm /m maximum
;  tlink /t /m maximum


seg_main   segment byte public
           assume  cs:seg_main,ds:seg_main

           org 100h         ; Zaciatok .COM programu
engine    proc
.386p

LOCALS __

; Torus Resolution
M_SHIFT   equ   4
N_SHIFT   equ   5

b           equ   byte ptr
w           equ   word ptr
d           equ   dword ptr

; mali by byt delitelne 16
MAX_SHIFT   equ   (N_SHIFT+M_SHIFT)
MAX_V       equ   (1 shl MAX_SHIFT)   ; Maximalny pocet vertexov
MAX_F       equ   (1 shl MAX_SHIFT)    ; Maximalny pocet facesov

VRT_SIZE    equ   32
VRT_SHIFT   equ   5
FCS_SIZE    equ   16
FCS_SHIFT   equ   4

; vrt - 32 byte
; 3 * 2 byte - x,y,z,q
; 2 * 2 byte - dysplay coordinates
; 2 * 2 byte - texture coordinates
; 3 * 2 byte - normal
; 3 * 2 byte - recomputed x,y,z
; 3 * 2 byte - recomputed normal
x           equ   0
y           equ   2
z           equ   4
tx          equ   6
ty          equ   8
nx          equ   10
ny          equ   12
nz          equ   14
rx          equ   16
ry          equ   18
rz          equ   20
rnz         equ   22
shd         equ   24
om          equ   26    ; suradnica omega pre body
omn         equ   28    ; suradnica omega pre normaly

; fcs - 16 byte
; 4 * 2 byte - vertexes
;     2 byte - face type
;     2 byte - minimum z
;     1 byte - z normal sign  (0 odvrateny/1 prinrateny)
;     1 byte - shade_f
;     2 byte - reserved
vrt_0       equ   0
vrt_1       equ   2
vrt_2       equ   4
vrt_3       equ   6
ftype       equ   8
z_min       equ   10
z_norm      equ   12
fshade      equ   14

;  1  0  0  x
;  0  1  0  x
;  0  0  1  x
;  0  0  0  x
;   x y
mat_0_0     equ   0  ; os-x   ; natocenie v priestore - matica
mat_1_0     equ   2
mat_2_0     equ   4
mat_0_1     equ   6  ; os-y
mat_1_1     equ   8
mat_2_1     equ   10
mat_0_2     equ   12 ; os-z
mat_1_2     equ   14
mat_2_2     equ   16
mat_0_m     equ   18 ; x      ; posunutie v priestore
mat_1_m     equ   20 ; y
mat_2_m     equ   22 ; z
scale       equ   24          ; velkost objektu
ux          equ   26          ; uhly natocenia
uy          equ   28
uz          equ   30
_mat_0      equ   32 ; normala z
_mat_1      equ   34
_mat_2      equ   36

zv          equ   7000h

; face type
; bit  10..15 - reserved
; bit  10 - (0-triangle,1-fourangle)
; bit  8,9 - mapping type(0-color,1-texture,2-animation,3-mirror)
; bit  7 - visible (one/two sides)
; bit  4,5,6 - shading type (0-non;1-flat;2-fix gouraud;3-gouraud;4-phong;
;              5-metal)
; bit  3 - surface type(0-flat,1-blur)
; bit  2 - mask surface(0-no,1-yes)
; bit  1 - typ of surface(0-solid;1-translucent)
; bit  0 - reserved

PIT_FREQ    equ   01234DDh

start:
            ;лллллллллллллллллллллллллллл
            ;  Alokacia potrebnej pamate
            ;лллллллллллллллллллллллллллл
            push  0
            pop   es
            mov   ax, es:[413h]
            shl   ax, 6     ; to this segment

            mov   bx, cs
            add   bh,10h; 65536 Byte    ; max 64kB of code + stack

            mov   w ds:[bck_seg],bx
            add   bh,10h     ; allocate space for 3d background

            mov   w ds:[img_seg],bx
            add   bh,10h ; allocate space for image buffer

            mov   w ds:[buf_seg],bx
            add   bh,10h     ; allocate space for dysplay buffer
            
            mov   w ds:[sin_seg],bx
            add   bx,32      ; allocate space for sinus and cosinus table
            mov   w ds:[cos_seg],bx
            add   bx,128
            mov   w ds:[_sin_seg],bx
            add   bx,16

            mov   w ds:[mat_seg],bx
            add   bx,3       ; allocate space for matrix

            mov   w ds:[lohi_seg],bx
            add   bx,400     ; locate memory for polygom x limits

            mov   w ds:[vrt_seg],bx
            add   bx,(VRT_SIZE*MAX_V)/16  ; allocate space for vertex data

            mov   w ds:[fcs_seg],bx
            add   bx,(FCS_SIZE*MAX_F)/16  ; allocate space for faces data

            mov   w ds:[lst_seg],bx
            add   bx,MAX_F/4  ; allocate space for lst of polys

            mov   w ds:[pol_seg],bx
            add   bx,16       ; allocate space for poly work data

            mov   w ds:[pal_seg],bx
            add   bx,48       ; allocate space for pallette

            mov   dx,offset err1_text
            cmp   bx,ax
            ja    quit_error

            mov   ax,3508h
            int   21h
            mov   ds:[int_seg],es
            mov   ds:[int_off],bx
            mov   ax,2508h
            mov   dx,offset TimerHandler
            int   21h

            mov   ax,1130h         ; precitanie MCGA/VGA fontu z karty
            mov   bh,6
            int   10h
            mov   w ds:[fnt_seg],es
            mov   w ds:[fnt_off],bp
            mov   al,34h            ; set timer to 70 ticks/sec
            out   43h,al
            mov   al,(PIT_FREQ/70)and 255
            out   40h,al
            mov   al,(PIT_FREQ/70)shr 8
            out   40h,al

            mov   es,w ds:[mat_seg] ; znulovanie hodnot natocenia a pozicie
            xor   ax,ax
            mov   di,mat_0_m
            mov   cx,uz-mat_2_2
            rep   stosb

            ;ллллллллллллллллллллллллллллл
            ;     generate sinus table
            ;ллллллллллллллллллллллллллллл
            mov   es,w ds:[sin_seg]
            xor   ebx,ebx
            mov   edx,18000h  ; bulharska konstanta pre amplitudu 32000+
            mov   cx,500h     ; pre kolko stupnov
            xor   di,di
__sin_cyklus:
            mov   eax,ebx
            sar   eax,9       ; fit to 16bit size
            stosw
            imul  eax,9ddh    ; bulharska konstanta na 1024 vzoriek sinusu
            sar   eax,11h
            sub   edx,eax
            add   ebx,edx
            loop  __sin_cyklus

            mov   ch,1h     ; 8 bit sinus table
            xor   si,si
            xor   di,di
            push  es
            mov   es,ds:_sin_seg
            pop   ds
__sin8:     lodsw
            sar   ax,10
            add   si,6
            stosb
            loop  __sin8

;            jmp   __LF

            ;лллллллллллллллллллллллллллл
            ;         M  A  I  N
            ;лллллллллллллллллллллллллллл
            call  GenerateMandel    ; generovanie textury mandel mnoziny

            ;*************Feather fractal
__Feather:
            mov   ax,12h         ; nastavenie grafiky pre fearher
            int   10h            ; fractal (skor pre spamateanie monitora)
            mov   w cs:_counter,0
__Feather_loop:
            call  FeatherFract
            call  TestESC
            cmp   w cs:_counter,600
            jb    __Feather_loop
            call  FadeDown

            ;*************Loofty
__LF:       call  Init13
            call  GenerateMandel    ; generovanie textury mandel mnoziny
            call  GetPalette
            mov   w cs:_counter,0
            call  FadeUp
__loofty:
            mov   ch,cs:_counter
            call  Loofty
            call  TestESC
            cmp   w cs:_counter,1000
            jb    __loofty
            call  FadeDown
__loofty_fade:
            mov   ch,cs:_counter
            call  Loofty
            cmp   b cs:_fade,0
            jne   __loofty_fade

            ;*********** Starwars scroller
__SW:
            call  Init13
            mov   al,0
            mov   si,offset blue
            call  MakePal
            mov   al,64
            mov   si,offset yellow
            call  MakePal
            mov   al,128
            mov   si,offset green
            call  MakePal
            mov   al,192
            mov   si,offset pink
            call  MakePal
            call  ClearImgBuffer   ; clr buf pre graf. txt. do scrl.
            mov   bp,offset scroll_0
            mov   es,w cs:[img_seg]
            mov   di,8
            mov   al,64
__WriteStarWarsScroll:
            call  PutString
            add   di,400h
            cmp   b cs:[bp],0  ; check end of text (0)
            jnz   __WriteStarWarsScroll   ; vedlajsi ucinok -> destroy text
            call  GetPalette
            call  BKPal
            call  StarWarsBackground
            push  cs
            pop   ds
            mov   w ds:_counter,-360
            mov   b ds:_fade_dir,8
            mov   b ds:_fade,8
__SW_00:
            call  TestESC
            mov   ax,cs:_counter
            call  StarWars
            push  cs
            pop   ds
            cmp   w ds:_counter,500
            jl    __SW_00
;            call  WaitFade
__TR:
            mov   es,w ds:[bck_seg]
            mov   fs,w ds:[buf_seg]
            push  0a000h
            pop   ds
            mov   cx,32000
            xor   di,di
__toci_sa_mi_toci:
            mov   ax,[di]
            mov   fs:[di],ax
            stosw
            loop  __toci_sa_mi_toci

            call  MakeTorus
            call  ChessBoard
            mov   w cs:_counter,30
            call  GetPalette

;            call  FadeUp
            mov   w cs:[faces],1
__3d_torus:
            call  TestESC
            mov   ds,w cs:[mat_seg]
            mov   bx,cs:_counter
            mov   w ds:[ux],bx
            sal   bx,1
            mov   w ds:[uy],bx
            mov   w ds:[uz],bx
            add   bh,2
            shl   bx,2
            and   bx,1023*2
            mov   es,w cs:sin_seg
            mov   ax,w es:[bx]
            imul  ax
            sar   dx,2
            mov   w ds:[mat_2_m],dx

            mov   ax,cs:_counter
            shr   ax,1
            cmp   ax,((1 shl M_SHIFT)-1)*((1 shl N_SHIFT)-1)
            jb    __3d_torus_paint
            mov   ax,((1 shl M_SHIFT)-1)*((1 shl N_SHIFT)-1)
__3d_torus_paint:
            mov   cs:faces,ax
            call  PaintPolys
            ;лллллллллллллллллллллллллллл
            ; Dysplay screen buffera
            ;лллллллллллллллллллллллллллл
            mov   ds,w cs:[buf_seg]
            mov   fs,w cs:[bck_seg]
            push  0a000h
            pop   es
            xor   di,di
            mov   cx,16000
__PutLoop:
            mov   eax,fs:[di]
            xchg  ds:[di],eax
            stosd
            dec   cx
            jnz   __PutLoop
            cmp   w cs:_counter,1080
            jb    __3d_torus
            call  FlowDown

__RT:
            call  Init13
            ;*************Rotacia juliovej mnoziny
            call  GenerateJulia    ; generovanie textury julioej mnoziny
            mov   bp,offset scroll_1
            mov   es,w cs:[img_seg]
            mov   di,070e0h
            mov   al,15
__write_scroll:
            call  PutString
            cmp   b cs:[bp],0  ; check end of text
            jnz   __write_scroll
            xor   ax,ax                   ; rot position
            mov   cs:_counter,ax
            call  GetPalette
            call  FadeUp
            call  BKPal
__rot:
            mov   di,cs:_counter
            call  RotBitMap               ; nakresli pootoceny obraz
            call  TestESC
            cmp   w cs:_counter,2080
            jb    __Rot
            push  0a000h
            pop   ds
            mov   es,cs:buf_seg
            mov   cx,16000
            xor   si,si
            xor   di,di
            rep   movsd
            call  FlowDown
            call  WaitFade
__ES:
            call  Init13
            mov   al,0
            mov   si,offset green
            call  MakePal
            call  ClearImgBuffer
            mov   bp,offset scroll_2
            mov   es,w cs:[img_seg]
            xor   di,di
            mov   al,64
__write_scroll_2:
            call  PutCompressString
            cmp   b cs:[bp],0  ; check end of text
            jnz   __write_scroll_2
            call  GetPalette
            mov   w cs:_counter,300*4
            call  FadeUp
__ES_loop:
            mov   si,cs:_counter
            sar   si,2
            call  EndScroll
            call  TestESC
            cmp   w cs:_counter,740*4
            jb    __ES_loop
            mov   b cs:_fade_dir,-8
            mov   b cs:_fade,-8
__ES_fade:
            mov   si,cs:_counter
            sar   si,2
            call  EndScroll
            call  TestESC
            cmp   b cs:_fade,0
            jne   __ES_fade

__TE:       ; "The End"
            call  Init13
            mov   al,20
            mov   si,offset Blue
            call  MakePal
            mov   al,0
            mov   si,offset Pink
            call  MakePal
            call  ClearImgBuffer
            mov   bp,offset end_txt
            mov   es,w cs:[img_seg]
            mov   di,0
            mov   al,63
            call  PutString
            mov   w cs:_counter,1
            call  GetPalette
__TE_loop:
            mov   bx,w cs:_counter
            call  Zoom
            call  TestESC
            cmp   w cs:_counter,255
            jb    __TE_loop
__TE_wait:
            call  TestESC
            cmp   w cs:_counter,500
            jb    __TE_wait
            call  WaitFade
koniec:
            in    al,21h                  ; set timer to 18.3 ticks/sec
            mov   dl,al
            mov   al,255
            out   21h,al
            mov   al,34h
            out   43h,al
            xor   ax,ax
            out   40h,al
            mov   al,ah
            out   40h,al
            mov   al,90h
            out   43h,al
            mov   al,dl
            out   21h,al
            mov   ax,2508h
            push  cs
            pop   ds
            mov   dx,cs:int_off
            mov   ds,cs:int_seg
            int   21h
            mov   ax,3
            int   10h
            push  cs
            pop   ds
            mov   dx,offset exit_txt
quit_error:
            mov   ah,9
            int   21h
            int   20h

Init13 PROC NEAR
            ;лллллллллллллллллллллллллллл
            ;  Nastavenie mode 13h
            ;лллллллллллллллллллллллллллл
            push  cs
            pop   ds
            mov   w ds:_fade,0
            mov   ax,13h
            int   10h
            ret
Init13 ENDP

FlowDown PROC NEAR
            ;лллллллллллллллллллллллллллл
            ;  Screen flow
            ;лллллллллллллллллллллллллллл
            xor   dx,dx
            mov   w cs:_counter,dx
            mov   ds,w cs:[buf_seg]
            push  0a000h
            pop   es
            add   dx,199
__big_loop:
            call  TestESC
            mov   bx,dx
            mov   ax,320
            mul   bx

            mov   si,ax
__last:
            mov   di,si
__small_loop:
            mov   cx,80
            rep   movsd
            sub   si,320
            inc   bl
            cmp   bl,200
            jb    __small_loop

            mov   dl,200
            sub   dx,cs:_counter
            or    dx,dx
            jge   __big_loop
            or    si,0
            jz    _return
            xor   si,si
            jmp   __last
FlowDown ENDP

TestESC PROC NEAR
            ;лллллллллллллллллллллллллллл
            ;  Test stlacenia ESC
            ;лллллллллллллллллллллллллллл
            mov   ah,0bh
            int   21h                     ; ak nebola stlacena klavesa tak sa
            or    al,al                   ; vrat na ret
            jz    _return
            mov   ah,1
            int   16h
            xor   al,27
            jz    koniec
            xor   ah,ah
            int   16h
_return:
            ret
TestESC ENDP

BKPal PROC NEAR
            ;лллллллллллллллллллллллллллл
            ;   Set black palette
            ;лллллллллллллллллллллллллллл
            mov   dx,3c8h
            xor   al,al
            out   dx,al
            inc   dx
            mov   cx,768
__Loop:
            out   dx,al
            loop  __Loop
            ret
BKPal ENDP

TimerHandler PROC NEAR
            ;лллллллллллллллллллллллллллл
            ;   Timer handler
            ;лллллллллллллллллллллллллллл
            pusha
            inc   w cs:_counter
            mov   bl,cs:_fade
            or    bl,bl
            jz    __NoFade
            add   bl,cs:_fade_dir
            jz    __NoFade
            push  ds
            mov   cs:_fade,bl
            mov   ds,cs:pal_seg
            xor   si,si
            mov   dx,3c8h
            xor   al,al
            out   dx,al
            inc   dx
            mov   cx,768
__Loop:
            lodsb
            mul   bl
            mov   al,ah
            out   dx,al
            loop  __Loop
            pop   ds
__NoFade:
            mov   cs:_fade,bl
            mov   al,20h
            out   20h,al
            popa
            iret
TimerHandler ENDP

WaitFade PROC NEAR
            ;лллллллллллллллллллллллллллл
            ; caka na koniec FadeDownu
            ;лллллллллллллллллллллллллллл
            call  GetPalette
            mov   b cs:_fade_dir,-4
            mov   b cs:_fade,-4
__a:
            call  TestESC
            cmp   b cs:_fade,0
            jnz   __a
            ret
WaitFade ENDP

FadeDown PROC NEAR
            mov   b cs:_fade_dir,-2
            mov   b cs:_fade,-2
GetPalette:
            cli
            mov   es,cs:pal_seg
            xor   di,di
            mov   dx,3c7h
            xor   al,al
            out   dx,al
            inc   dx
            inc   dx
            mov   cx,768
            rep   insb
            sti
            ret
FadeDown ENDP

FadeUp PROC NEAR
            mov   b cs:_fade,1
            mov   b cs:_fade_dir,1
            ret
FadeUp ENDP

MakePal PROC NEAR
            ;лллллллллллллллллллллллллллл
            ;  Make shades
            ;лллллллллллллллллллллллллллл
            ; cs:[si] 3 byte RGB
            ; al - from color

            mov   bx,w cs:[si]
            mov   cl,b cs:[si+2]

            xor   ch,ch    ; counter
            mov   dx,3c8h
            out   dx,al
            inc   dx
            mov   di,64
__PalLoop:
            mov   al,ch ; red
            mul   bl
            cmp   ah,63
            jna   __red
            mov   ah,63
__red:
            mov   al,ah
            out   dx,al
            mov   al,ch ; green
            mul   bh
            cmp   ah,63
            jna   __green
            mov   ah,63
__green:
            mov   al,ah
            out   dx,al
            mov   al,ch ; blue
            mul   cl
            cmp   ah,63
            jna   __blue
            mov   ah,63
__blue:
            mov   al,ah
            out   dx,al
            add   ch,4
            dec   di
            jnz   __PalLoop
            ret
MakePal ENDP

GTPoly PROC NEAR
; Konstanty pre gouraud texturovany polygon
__x         equ   0
__y         equ   2  ; v datach pre vrchol polygonu
__y_        equ   0
__x_        equ   2
__s         equ   4
__s_        equ   8
__tx        equ   12
__ty        equ   16
__tx_       equ   20
__ty_       equ   24
__SIZE      equ   32
__SHIFT     equ   5
            ;лллллллллллллллллллллллллллллллллллллллллл
            ;   Paint gouraud texture polygon
            ;лллллллллллллллллллллллллллллллллллллллллл
            ;  bx-cislo polygonu
            ;  destroy - all
            push  cs
            pop   ds
            mov   gs,w ds:[fcs_seg]
            mov   fs,w ds:[vrt_seg]
            mov   es,w ds:[pol_seg]
            push  es
            pop   ds

            shl   bx,FCS_SHIFT  ; gs:[bx] <- pointer na aktualny polygon
            ; oznaci hranice polygonu y

            xor   si,si                ; copy vertexes data from array
            mov   cx,4                 ; to work variables
__poly_02:
            mov   di,w gs:[bx]
            shl   di,VRT_SHIFT
            mov   ax,w fs:[di+rx]
            mov   w ds:[si+__x_],ax

            mov   ax,w fs:[di+ry]
            mov   w ds:[si+__y_],ax

            xor   eax,eax
            mov   ax,w fs:[di+shd]
            shl   eax,8
            mov   d ds:[si+__s],eax

            mov   ax,w fs:[di+tx]
            shl   eax,16
            mov   d ds:[si+__tx],eax

            mov   ax,w fs:[di+ty]
            shl   eax,16
            mov   d ds:[si+__ty],eax
            add   si,__SIZE*2
            inc   bx
            inc   bx
            loop  __poly_02

            xor   si,si                ; copy supplementary vertexes
            mov   di,__SIZE*3          ; to line variables
            add   cx,__SIZE/4
            rep   movsd             ; 0->3
            add   si,__SIZE
            add   cx,__SIZE/4
            add   di,__SIZE
            rep   movsd             ; 2->5
            add   si,__SIZE
            add   cx,__SIZE/4
            add   di,__SIZE
            rep   movsd             ; 4->7
            add   si,__SIZE
            add   cx,__SIZE/4
            mov   di,__SIZE
            rep   movsd             ; 6->1

            add   cx,3              ; test highest and lowest y values
            mov   bx,7*__SIZE+__y_   ; from edge lines
            mov   dx,w ds:[bx]
            mov   bp,dx
__pol_y_test:
            sub   bx,__SIZE*2       ; move bx ptr to next vertex
            mov   ax,w ds:[bx]
            cmp   ax,dx
            jg    __pol_y_test_0    ; y_lo test
            mov   dx,ax
__pol_y_test_0:
            cmp   ax,bp
            jl    __pol_y_test_1    ; y_hi test
            mov   bp,ax
__pol_y_test_1:
            loop  __pol_y_test
            mov   w cs:[poly_y_lo],dx
            mov   w cs:[poly_y_hi],bp

            xor   di,di    ; vyber vyssieho bodu z kazdej ciary polygonu
            xor   ecx,ecx
            add   cx,4
__poly_00:
            mov   ax,w ds:[di+__y_]
            cmp   ax,w ds:[di+__y_+__SIZE]
            jl    __poly_01
            mov   bx,__SIZE/4
__poly_03:
            mov   eax,d ds:[di]        ; vymenenie poloziek zaznamu
            xchg  eax,d ds:[di+__SIZE]
            mov   d ds:[di],eax
            add   di,4
            dec   bx
            jnz   __poly_03
            sub   di,__SIZE
__poly_01:
            add   di,__SIZE*2
            loop  __poly_00


            ; vycisti x limity pre jednotlive y urovne   лллллл No clipping!!!!
            mov   es,w cs:[lohi_seg]
            mov   di,dx
            mov   cx,bp
            sub   cx,dx
            inc   cx    ; cx=y_hi-y_lo+1
            shl   cx,__SHIFT-2
            shl   di,__SHIFT
            mov   eax,80007fffh
            rep   stosd

            mov   si,6*__SIZE ; pointer na suradnice pocitonej hranicnej ciary
;            xor   ecx,ecx ; je vycistene;)
            cli                     ; zakaze interrupty
            mov   fs,sp             ; ulozi stack pointer
__edge_line:
            mov   w cs:[pom_w0],si

            mov   ebx,d ds:[si+__y_]          ; vyssi bod
            mov   eax,d ds:[si+__y_+__SIZE]   ; nizsi bod

;            ror   eax,16            ; umiestni y hodnoty do dolnych 16bit
;            ror   ebx,16

            xor   edi,edi           ; set xp lsw (hi edi)

            mov   cx,ax             ; compute LOOPCOUNT
            sub   cx,bx
            inc   cx

            mov   di,bx             ; set offset
            shl   di,__SHIFT

            sub   eax,ebx           ; zostavaju drobne desatine miesta po y
            shr   ebx,16            ; set xp
            mov   sp,bx

            cdq
            idiv  ecx               ; nie je mozne, ze nastane delenie nulou
            rol   eax,16            ; nastavi xp-inc a xp-inc lsw
            mov   bp,ax
            mov   ax,si
            mov   esi,eax

            mov   ebx,d ds:[si+__tx] ; pocitanie TXR-X INC
            mov   eax,d ds:[si+__tx+__SIZE]
            sub   eax,ebx
            cdq
            idiv  ecx
            mov   d cs:[TXR_X_INC],eax
            mov   d cs:[TXR_X],ebx

            mov   ebx,d ds:[si+__ty] ; pocitanie TXR-Y INC
            mov   eax,d ds:[si+__ty+__SIZE]
            sub   eax,ebx
            cdq
            idiv  ecx
            mov   d cs:[TXR_Y_INC],eax
            mov   d cs:[TXR_Y],ebx

            mov   ebx,d ds:[si+__s] ; pocitanie SHADE-INC
            mov   eax,d ds:[si+__s+__SIZE]
            sub   eax,ebx
            cdq
            idiv  ecx
            mov   d cs:[SHADE_INC],eax
            mov   eax,d cs:[TXR_X]
            mov   edx,d cs:[TXR_Y]
            mov   si,__SIZE            ; set size of one record field
__y_level:                             ; Edge line for gouraud shaded texture
            cmp   sp,w es:[di+__x]     ;        ЩЭЭЭЭЭЭЭЭЭЭЭЭЭЫЭЭЭЭЭЭЭЭЭЭЭЭЭЛ
            jg    __line_not_less      ;        К UPPER 16BIT К LOWER 16BIT К
            mov   w es:[di+__x],sp     ;ЩЭЭЭЭЭЭЭЮЭЭЭЭЭЭЭЭЭЭЭЭЭЮЭЭЭЭЭЭЭЭЭЭЭЭЭЙ
            mov   d es:[di+__s],ebx    ;К  REG  К   HI WORD   К   LO WORD   К
            mov   d es:[di+__tx],eax   ;ЬЭЭЭЭЭЭЭЮЭЭЭЭЭЭЭЭЭЭЭЭЭЪЭЭЭЭЭЭЭЭЭЭЭЭЭЙ
            mov   d es:[di+__ty],edx   ;К  EAX  К           TXR-X           К
__line_not_less:                       ;ЬЭЭЭЭЭЭЭЮЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЙ
            cmp   sp,es:[di+__x_]      ;К  EBX  К           SHADE           К
            jl    __line_not_greater   ;ЬЭЭЭЭЭЭЭЮЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЙ
            mov   w es:[di+__x_],sp    ;К  ECX  К         LOOPCOUNT         К
            mov   d es:[di+__s_],ebx   ;ЬЭЭЭЭЭЭЭЮЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЙ
            mov   d es:[di+__tx_],eax  ;К  EDX  К           TXR-Y           К
            mov   d es:[di+__ty_],edx  ;ЬЭЭЭЭЭЭЭЮЭЭЭЭЭЭЭЭЭЭЭЭЭЫЭЭЭЭЭЭЭЭЭЭЭЭЭЙ
__line_not_greater:                    ;К  EDI  К    XP LSW   К   OFFSET    К
            add   edi,esi              ;ЬЭЭЭЭЭЭЭЮЭЭЭЭЭЭЭЭЭЭЭЭЭЮЭЭЭЭЭЭЭЭЭЭЭЭЭЙ
            adc   sp,bp                ;К  ESI  К XP-INC LSW  К  REC-SIZE   К
            add   ebx,d cs:[SHADE_INC] ;ЬЭЭЭЭЭЭЭЮЭЭЭЭЭЭЭЭЭЭЭЭЭЮЭЭЭЭЭЭЭЭЭЭЭЭЭЙ
            add   eax,d cs:[TXR_X_INC] ;К  EBP  К     ---     К   XP-INC    К
            add   edx,d cs:[TXR_Y_INC] ;ЬЭЭЭЭЭЭЭЮЭЭЭЭЭЭЭЭЭЭЭЭЭЮЭЭЭЭЭЭЭЭЭЭЭЭЭЙ
            dec   cx                   ;К  ESP  К     ---     К     XP      К
            jnz   __y_level            ;ШЭЭЭЭЭЭЭЪЭЭЭЭЭЭЭЭЭЭЭЭЭЪЭЭЭЭЭЭЭЭЭЭЭЭЭМ

            mov   si,w cs:[pom_w0]
            sub   si,__SIZE*2
            jns   __edge_line

            mov   sp,fs                ; vrati stack pointer
            sti                        ; povoli interrupty

                                    ; vykresli "scanlajny"
            mov   si,w cs:[poly_y_lo]
            mov   cx,w cs:[poly_y_hi]
            sub   cx,si
            inc   cx                ; pocet scanlines

            shl   si,__SHIFT
            mov   ax,si
            add   ax,si       ; shl ax,1
;            shl   ax,6-__SHIFT
            mov   bx,ax
            shl   ax,2
            add   ax,bx
            push  es
            pop   gs
            mov   es,w cs:[buf_seg]
            mov   ds,w cs:[img_seg]
__poly_scanline:
            ; dx - pocet scanline
            ; bx - offset riadku
            ; si - offset dat pre aktualny scanline
            push  cx
            push  ax
            push  si

            xor   edi,edi           ; vypocitanie LOOPCOUNT
            mov   bx,w gs:[si+__x]
            mov   di,w gs:[si+__x_]
            sub   di,bx
            inc   di
            mov   ecx,edi
            shl   edi,16
            add   bx,ax             ; vypocitanie output offsetu
            mov   di,bx
;            mov   d cs:[_EDI],edi

            mov   eax,d gs:[si+__tx_]
            mov   ebx,d gs:[si+__tx]
            sub   eax,ebx
            cdq
            idiv  ecx
            mov   w cs:[_HCX],ax
            shr   eax,16
            mov   w cs:[_BP],ax
            mov   w cs:[_HAX],bx
            shr   ebx,16
            mov   b cs:[_BL],bl

            mov   eax,d gs:[si+__ty_]
            mov   ebx,d gs:[si+__ty]
            sub   eax,ebx
            cdq
            idiv  ecx
            mov   w cs:[_HBP],ax
            shr   eax,16
            mov   b cs:[_DL],al
            mov   w cs:[_HBX],bx
            shr   ebx,16
            mov   b cs:[_BH],bl

            mov   eax,d gs:[si+__s_]
            mov   ebx,d gs:[si+__s]
            sub   eax,ebx
            cdq
            idiv  ecx
            mov   si,ax
            shl   esi,16
;            mov   w cs:[_HSI],ax
            shr   eax,16
            mov   ecx,d cs:[_ECX]
            mov   cx,ax
;            mov   w cs:[_CX],ax
            mov   dx,bx
            shl   edx,16
            mov   dl,cs:[_DL]
;            mov   w cs:[_HDX],bx
            shr   ebx,16
            mov   eax,d cs:[_EAX]
            mov   ax,bx
;            mov   w cs:[_AX],bx

            mov   ebx,d cs:[_EBX]
;            mov   edx,d cs:[_EDX]
;            mov   edi,d cs:[_EDI]
;            mov   esi,d cs:[_ESI]
            mov   ebp,d cs:[_EBP]
            xor   si,si

            dec   di
            cli              ;Gouraud shaded texture in registers.
            mov   cs:_ESP,sp ; 9 instructions
                             ;    ЩЭЭЭЭЭЭЭЭЭЭЭЭЭЫЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЛ
            mov   esp,0ffff0001h ;К UPPER 16BIT К     LOWER 16BIT       К
__Pixel:                     ;ЩЭЭЭЮЭЭЭЭЭЭЭЭЭЭЭЭЭЮЭЭЭЭЭЭЭЭЭЭЭЫЭЭЭЭЭЭЭЭЭЭЭЙ
            add   edx,esi    ;КREGК   HI WORD   К  HI BYTE  К  LO BYTE  К
            adc   eax,ecx    ;ЬЭЭЭЮЭЭЭЭЭЭЭЭЭЭЭЭЭЮЭЭЭЭЭЭЭЭЭЭЭЮЭЭЭЭЭЭЭЭЭЭЭЙ
            mov   dh,[bx]    ;КEAXК  TXT-X LSW  К    ---    К   SHADE   К
            adc   ebx,ebp    ;ЬЭЭЭЮЭЭЭЭЭЭЭЭЭЭЭЭЭЮЭЭЭЭЭЭЭЭЭЭЭЮЭЭЭЭЭЭЭЭЭЭЭЙ
            adc   bh,dl      ;КEBXК  TXT-Y LSW  К TEXTURE Y К TEXTURE X К
            add   dh,al      ;ЬЭЭЭЮЭЭЭЭЭЭЭЭЭЭЭЭЭЮЭЭЭЭЭЭЭЭЭЭЭЮЭЭЭЭЭЭЭЭЭЭЭЙ
            add   edi,esp    ;КECXК  X-INC LSW  К    ---    КSHADE-INC  К
            mov   es:[di],dh ;ЬЭЭЭЮЭЭЭЭЭЭЭЭЭЭЭЭЭЮЭЭЭЭЭЭЭЭЭЭЭЮЭЭЭЭЭЭЭЭЭЭЭЙ
            jc    __Pixel    ;КEDXК  SHADE LSW  КTEXTUREDATAК   Y-INC   К
                             ;ЬЭЭЭЮЭЭЭЭЭЭЭЭЭЭЭЭЭЮЭЭЭЭЭЭЭЭЭЭЭЮЭЭЭЭЭЭЭЭЭЭЭЙ
                             ;КESIКSHADE-INC LSWК    ---    К    ---    К
                             ;ЬЭЭЭЮЭЭЭЭЭЭЭЭЭЭЭЭЭЮЭЭЭЭЭЭЭЭЭЭЭЮЭЭЭЭЭЭЭЭЭЭЭЙ
                             ;КEDIК  LOOPCOUNT  К    ---    К   OFFSET  К
                             ;ЬЭЭЭЮЭЭЭЭЭЭЭЭЭЭЭЭЭЮЭЭЭЭЭЭЭЭЭЭЭЮЭЭЭЭЭЭЭЭЭЭЭЙ
                             ;КEBPК  Y-INC LSW  КX-INC  SIGNК   X-INC   К
                             ;ЬЭЭЭЮЭЭЭЭЭЭЭЭЭЭЭЭЭЮЭЭЭЭЭЭЭЭЭЭЭЮЭЭЭЭЭЭЭЭЭЭЭЙ
                             ;КESPК     -1      К    ---    К      1    К
                             ;ШЭЭЭЪЭЭЭЭЭЭЭЭЭЭЭЭЭЪЭЭЭЭЭЭЭЭЭЭЭЪЭЭЭЭЭЭЭЭЭЭЭМ
            mov   sp,cs:_ESP
            sti
            pop   si    ; lohi offset
            add   si,__SIZE         ; lohi offset to nxt record
            pop   ax    ; aktual scanline offset
            add   ax,320
            pop   cx    ; loopcount
            dec   cx
            jnz   __poly_scanline
__poly_end:
            ret
GTPoly   ENDP

ComputeOBJ PROC NEAR
            ;лллллллллллллллллллллллллллл
            ;    Prepocitanie hodnot
            ;лллллллллллллллллллллллллллл

            call  MakeMAT

;     rx = (mat_0_0*x+mat_0_1*y+mat_0_2]*z)+mat_0_m;
;     ry = (mat_1_0*x+mat_1_1*y+mat_1_2]*z)+mat_1_m;
;     rz = (mat_2_0*x+mat_2_1*y+mat_2_2]*z)+mat_2_m;
            push  cs
            pop   ds
            mov   cx,w ds:[vrtxs]
            mov   fs,w ds:[mat_seg]
            mov   ds,w ds:[vrt_seg]

            xor   si,si
__RecomputeOneVertexData:
            ; ebx - x,y
            ; bp - z
            ; di - out
            mov   bx,w ds:[si+x]
            shl   ebx,16
            mov   bx,w ds:[si+y]
            rol   ebx,16
            mov   bp,w ds:[si+z]

            mov   ax,w fs:[mat_0_0] ; compute x
            imul  bx
            mov   di,dx
            mov   ax,w fs:[mat_0_1]
            rol   ebx,16
            imul  bx
            rol   ebx,16
            add   di,dx
            mov   ax,w fs:[mat_0_2]
            imul  bp
            add   di,dx
;            add   di,w fs:[mat_0_m]
            mov   w ds:[si+rx],di
            mov   ax,w fs:[mat_1_0] ; compute y
            imul  bx
            mov   di,dx
            mov   ax,w fs:[mat_1_1]
            rol   ebx,16
            imul  bx
            rol   ebx,16
            add   di,dx
            mov   ax,w fs:[mat_1_2]
            imul  bp
            add   di,dx
;            add   di,w fs:[mat_1_m]
            mov   w ds:[si+ry],di
            mov   ax,w fs:[mat_2_0] ; compute z
            imul  bx
            mov   di,dx
            mov   ax,w fs:[mat_2_1]
            rol   ebx,16
            imul  bx
            rol   ebx,16
            add   di,dx
            mov   ax,w fs:[mat_2_2]
            imul  bp
            add   di,dx
            add   di,w fs:[mat_2_m]
            mov   w ds:[si+rz],di

            mov   ax,w fs:[mat_2_0] ; compute z-part of normal
            imul  w ds:[si+nx]
            mov   di,dx
            mov   ax,w fs:[mat_2_1]
            imul  w ds:[si+ny]
            add   di,dx
            mov   ax,w fs:[mat_2_2]
            imul  w ds:[si+nz]
            add   di,dx
            mov   w ds:[si+rnz],di

            mov   dx,4000h              ; compute prespective deformation
            xor   ax,ax                ; p= zv/(zv-z)
            mov   di,5000h
            add   di,w ds:[si+rz]
            div   di
            neg   ax

            mov   di,ax                ; transform x
            imul  w ds:[si+rx]
            add   dx,160
            mov   w ds:[si+rx],dx

            mov   ax,di                ; transform y
            imul  w ds:[si+ry]
            add   dx,100
            mov   w ds:[si+ry],dx

            add   si,VRT_SIZE
            dec   cx
            jnz   __RecomputeOneVertexData

            mov   cx,w cs:[faces]
            mov   es,w cs:[fcs_seg]
            mov   si,cx
            shl   si,FCS_SHIFT
__RecomputeOneFaceNormal:
            sub   si,FCS_SIZE
            mov   di,es:[si+vrt_0]        ; ax = u.x
            shl   di,VRT_SHIFT            ; bx = u.y
            mov   ax,w ds:[di+rx]         ; bp = v.x
            mov   bx,w ds:[di+ry]         ; dx = v.y
            mov   di,es:[si+vrt_2]
            shl   di,VRT_SHIFT
            mov   bp,w ds:[di+rx]
            mov   dx,w ds:[di+ry]
            mov   di,es:[si+vrt_1]
            shl   di,VRT_SHIFT
            sub   ax,w ds:[di+rx]
            sub   bp,w ds:[di+rx]
            sub   bx,w ds:[di+ry]
            sub   dx,w ds:[di+ry]
            imul  dx                      ; nz  = ax*dx-bx*bp
            mov   di,ax
            mov   ax,bx
            imul  bp
            sub   ax,di
            mov   w es:[si+z_norm],ax
            loop  __RecomputeOneFaceNormal

            ret
ComputeOBJ ENDP

PaintPolys  PROC NEAR
            ;лллллллллллллллллллллллллллллллллллллл
            ;  Vykreslenie usporiadanych polygonov
            ;лллллллллллллллллллллллллллллллллллллл
            call  ComputeOBJ
            call  ComputeShades
            push  cs       ; ds=cs
            pop   ds
            mov   es,w ds:[lst_seg]
            mov   fs,w ds:[vrt_seg]
            mov   gs,w ds:[fcs_seg]

            ; zaradi len privratene polygony a najde priradovanym
            ; najnizsie z
            mov   cx,w ds:[faces]

            xor   si,si
            xor   di,di
            xor   dx,dx
__paint_01:
            mov   ax,8000h ; maximalne cislo
            cmp   w gs:[si+z_norm],ax
;            jnb   __paint_skip_poly    ; test ci je plocha privratena

            add   si,vrt_3+2           ; najde najblizsie Z z polygonu
            mov   bp,4
            ; ax je maximalne cislo
__paint_find_z_min:
            dec   si
            dec   si
            mov   bx,w gs:[si]
            shl   bx,VRT_SHIFT
            add   bx,rz
            cmp   ax,fs:[bx]
            jg    __paint_not_01
            mov   ax,fs:[bx]
__paint_not_01:
            dec   bp
            jnz   __paint_find_z_min
            stosw       ; store minimum z pos
            mov   ax,dx
            stosw       ; store face number
__paint_skip_poly:
            inc   dx
            add   si,FCS_SIZE
            loop  __paint_01
            shr   di,2
            jz    __ret
            mov   ds:[aktiv_faces],di

            ; usporiada ich podla najblizsieho bodu
            push  es
            pop   ds
            call  HeapSort

            ; vykresli ich do sceny podla poradia v usporiadanom zozname
            mov   di,2
__paint_next_poly:
            mov   bx,w es:[di]
            add   di,4
            push  es
            push  di
            call  GTPoly
            pop   di
            pop   es
            dec   w cs:[aktiv_faces]
            jnz   __paint_next_poly
__ret:
            ret
PaintPolys  ENDP

Prehalduj PROC NEAR ; podprocedura pre HeapSort
            ;PROCEDURE Prehalduj (a, b : INTEGER);
            ;BEGIN
            ;  WHILE (j=2 * a) <= b DO
            ;    BEGIN
            ;      IF j + 1 <= b THEN
            ;        IF data [j + 1] > data [j] THEN j := j + 1;
            ;      IF data [a] < data [j] THEN BEGIN
            ;        vymen (a, j);
            ;        a := j;
            ;      END
            ;      ELSE a := b;
            ;    END;
            ;END;
            ; a - si
            ; b - di
            ; j - dx
__Prehalduj_while:
            mov   bx,si
            shl   bx,1
            cmp   bx,di
            ja    __Prehalduj_koniec
            mov   bp,bx
            add   bp,4
            cmp   bp,di
            ja    __Prehalduj_if1
            mov   ax,w ds:[bp]
            cmp   ax,w ds:[bx]
            jng   __Prehalduj_if1
            mov   bx,bp
__Prehalduj_if1:
            mov   ax,w ds:[si]
            cmp   ax,w ds:[bx]
            jnl   __Prehalduj_if2
            mov   eax,d ds:[si]
            xchg  eax,d ds:[bx]
            mov   d ds:[si],eax
            mov   si,bx
            jmp   __Prehalduj_while
__Prehalduj_if2:
            mov   si,di
            jmp   __Prehalduj_while
__Prehalduj_koniec:
            ret
Prehalduj ENDP

HeapSort PROC NEAR
            ;PROCEDURE HeapSort (l, r : INTEGER);
            ;BEGIN
            ;  FOR i := (l + r) DIV 2 DOWNTO l DO prehalduj (i, r);
            ;  FOR i := r DOWNTO l + 1 DO
            ;   BEGIN
            ;     vymen (l, i);
            ;     prehalduj (1, i - 1);
            ;   END;
            ;END;
;            mov   di,cs:[aktiv_faces]
            mov   cx,di
            dec   di
            shr   cx,1
            push  di
            shl   di,2
__HeapSort_00:
            mov   si,cx
            shl   si,2
            call  Prehalduj
            dec   cx
            jnz   __HeapSort_00
            xor   si,si
            call  Prehalduj

            pop   cx
__HeapSort_01:
            xor   si,si
            mov   di,cx
            shl   di,2
            mov   eax,d ds:[si]
            xchg  eax,d ds:[di]
            mov   d ds:[si],eax
            sub   di,4
            call  Prehalduj
            dec   cx
            cmp   cx,1
            ja    __HeapSort_01
            ret
HeapSort ENDP

MakeMAT PROC NEAR
            ;лллллллллллллллллллллллллллллллллл
            ; Compute transformation matrix
            ;лллллллллллллллллллллллллллллллллл
            push  cs
            pop   ds

            mov   es,w ds:[mat_seg]    ; inicializacia matice
            mov   gs,w ds:[sin_seg]
            mov   fs,w ds:[cos_seg]

            mov   eax,00007fffh       ; inicializacia matice
            mov   cx,ax ; 7fffh
            xor   di,di
            stosd    ; zakladna jednotkova matica
            xor   ax,ax
            stosw    ; mat_x_0
            stosw
            mov   ax,cx
            stosd    ; mat_x_1
            xor   ax,ax
            stosw
            stosw
            mov   ax,cx
            stosw   ; mat_x_0

            xor   si,si
            mov   cx,3
__make_mat_loop:
   ; uy
            mov   bp,w es:[uy]
            and   bp,1023     ; 1022 ak bude treba smensit code o shl bp,1
            shl   bp,1
            mov   bx, es:[si+mat_2_0]
            mov   ax,bx
            imul  w fs:[bp]
            mov   di,dx
            mov   ax,es:[si+mat_0_0]
            imul  w gs:[bp]   ; mat[i][0]*sin_uy
            sub   di,dx       ; mat[i][2]*cos_uy - mat[i][0]*sin_uy
            sal   di,1
            mov   es:[si+mat_2_0],di
            mov   ax,gs:[bp]
            imul  bx
            mov   di,dx
            mov   ax,es:[si+mat_0_0]
            imul  w fs:[bp]   ; mat[i][0]*cos_uy
            add   di,dx       ; pom      *sin_uy + mat[i][0]*cos_uy
            sal   di,1
            mov   es:[si+mat_0_0],di
   ; ux
            mov   bp,w es:[ux]
            and   bp,1023     ; 1022 ak bude treba zmensit code o shl bp,1
            shl   bp,1
            mov   ax,es:[si+mat_2_0]
            mov   bx,ax
            imul  w fs:[bp]   ; mat[i][0]*cos_uz
            mov   di,dx
            mov   ax,es:[si+mat_1_0]
            imul  w gs:[bp]   ; mat[i][1]*sin_uz
            sub   di,dx       ; mat[i][0]*cos_uz - mat[i][1]*sin_uz
            sal   di,1
            mov   es:[si+mat_2_0],di
            mov   ax,gs:[bp]
            imul  bx          ;pom      *sin_uz
            mov   di,dx
            mov   ax,es:[si+mat_1_0]
            imul  w fs:[bp]   ; mat[i][1]*cos_uz
            add   di,dx       ; pom      *sin_uz + mat[i][1]*cos_uz
            sal   di,1
            mov   es:[si+mat_1_0],di
   ; uz
            mov   bp,w es:[uz]
            and   bp,1023     ; 1022 ak bude treba zmensit code o shl bp,1
            shl   bp,1
            mov   ax,es:[si+mat_0_0]
            mov   bx,ax
            imul  w fs:[bp]   ; mat[i][0]*cos_uz
            mov   di,dx
            mov   ax,es:[si+mat_1_0]
            imul  w gs:[bp]   ; mat[i][1]*sin_uz
            sub   di,dx       ; mat[i][0]*cos_uz - mat[i][1]*sin_uz
            sal   di,1
            mov   es:[si+mat_0_0],di
            mov   ax,gs:[bp]
            imul  bx          ;pom      *sin_uz
            mov   di,dx
            mov   ax,es:[si+mat_1_0]
            imul  w fs:[bp]   ; mat[i][1]*cos_uz
            add   di,dx       ; pom      *sin_uz + mat[i][1]*cos_uz
            sal   di,1
            mov   es:[si+mat_1_0],di

            add   si,6
            dec   cx
            jnz   __make_mat_loop

; for(i=0;i<3;i++){
;    pom         = mat[i][2];
;    mat[i][2]   = mat[i][2]*cos_uy - mat[i][0]*sin_uy;
;    mat[i][0]   = pom      *sin_uy + mat[i][0]*cos_uy;
;    pom         = mat[i][2];
;    mat[i][2]   = mat[i][2]*cos_ux - mat[i][1]*sin_ux;
;    mat[i][1]   = pom      *sin_ux + mat[i][1]*cos_ux;
;    pom         = mat[i][0];
;    mat[i][0]   = mat[i][0]*cos_uz - mat[i][1]*sin_uz;
;    mat[i][1]   = pom      *sin_uz + mat[i][1]*cos_uz;
; }
           ret
MakeMAT     ENDP

ComputeShades PROC NEAR
            ;лллллллллллллллллллллллллллллллллллллллллллл
            ;  compute light levels in vertexes
            ;лллллллллллллллллллллллллллллллллллллллллллл
            mov   cx,w cs:[vrtxs]
            mov   ds,w cs:[vrt_seg]
            xor   di,di
__CompShade:
            mov   ax,w ds:[di+rnz]
            or    ax,ax
            jg    __CompShadeOK
            xor   ax,ax
__CompShadeOK:
            imul  ax,3
            sar   ax,1
            add   ax,14*256
            mov   w ds:[di+shd],ax
            add   di,VRT_SIZE
            loop  __CompShade
            ret
ComputeShades ENDP

ClearImgBuffer PROC
            mov   es,w cs:[img_seg]
            mov   cx,4000h
            xor   di,di
            xor   eax,eax
            rep   stosd
            ret
ClearImgBuffer ENDP

PutString PROC NEAR
            ;лллллллллллллллллллллллллллл
            ; Write string to output
            ;лллллллллллллллллллллллллллл
            ; bp -> cs:[dx] = pointer na ASCIZ string
            ; es:[di] - output (line = 256 bytes)
            ; al - color
            mov   ds,w cs:[fnt_seg]
            mov   si,w cs:[fnt_off]
            push  di
            mov   cx,char_per_line
__CharLoop:
            mov   bl,b cs:[bp]
            inc   bp
            or    bl,bl
            jz    __PutString_koniec
            push  cx
            movzx bx,bl
            shl   bx,4
            push  di
            mov   ch,16
__Char_YLoop:
            mov   ah,b ds:[si+bx]
            inc   bx
            mov   cl,8
__Char_XLoop:
            shl   ah,1
            jnc   __Char_NoPixel
            mov   es:[di],al
__Char_NoPixel:
            inc   di
            dec   cl
            jnz   __Char_XLoop
            add   di,256-8
            dec   ch
            jnz   __Char_YLoop
            pop   di
            add   di,8
            pop   cx
            loop  __CharLoop
__PutString_koniec:
            pop   di
            add   di,1000h
            ret
PutString ENDP

PutCompressString PROC NEAR
__char_per_line   equ   16
            ;лллллллллллллллллллллллллллл
            ; Write string to output
            ;лллллллллллллллллллллллллллл
            ; bp -> cs:[dx] = pointer na ASCIZ string
            ; es:[di] - output (line = 256 bytes)
            ; al - color
            mov   ds,w cs:[fnt_seg]
            mov   si,w cs:[fnt_off]
            push  di
            mov   cx,__char_per_line
__CharLoop:
            mov   bl,b cs:[bp]
            inc   bp
            or    bl,bl
            jz    __PutString_koniec
            push  cx
            movzx bx,bl
            shl   bx,4
            push  di
            mov   ch,16
__Char_YLoop:
            mov   ah,b ds:[si+bx]
            inc   bx
            mov   cl,8
__Char_XLoop:
            shl   ah,1
            jnc   __Char_NoPixel
            push  ax
            sub   al,ch
            mov   es:[di],al
            pop   ax
__Char_NoPixel:
            inc   di
            dec   cl
            jnz   __Char_XLoop
            add   di,128-8
            dec   ch
            jnz   __Char_YLoop
            pop   di
            add   di,8
            pop   cx
            loop  __CharLoop
__PutString_koniec:
            pop   di
            add   di,800h
            ret
PutCompressString ENDP

GenerateJulia PROC NEAR
__Fract_NAS equ   13777216
__Fract_STP equ   4*__Fract_NAS/256
            ;лллллллллллллллллллллллллллл
            ; Compute Julia set
            ;лллллллллллллллллллллллллллл
            ; input  ds - destination
            mov   ds,w cs:[img_seg]
            mov   ebx,-2*__Fract_NAS
            xor   cx,cx
            mov   esi,(48*__Fract_NAS)/100  ; k
__Fract_y_cyklus:
            mov   eax,-2*__Fract_NAS
__Fract_x_cyklus:
            mov   bp,cx
;            mov   eax,d cs:[Fract_xp]
;            mov   ebx,d cs:[Fract_yp]
            push  eax
            push  ebx
            mov   di,107
__Fract_iter:
            sar   eax,12
            sar   ebx,12

            mov   ecx,eax     ; c1 = x1*x1-y1*y1+k
            imul  eax,eax
            mov   edx,ebx
            imul  edx,edx
            sub   eax,edx
            add   eax,esi

            imul  ebx,ecx     ; y1 = 2*x1*y1+k
            sal   ebx,1
            add   ebx,esi

            mov   ecx,eax
            sar   ecx,12
            imul  ecx,ecx

            mov   edx,ebx
            sar   edx,12
            imul  edx,edx

            add   ecx,edx     ; while x1*x1+y1*y1<=4 and maxiter>0

            dec   di
            jz    __Fract_end_of_iter
            cmp   ecx,__Fract_NAS*4
            jle   __Fract_iter
__Fract_end_of_iter:
            mov   ax,di
            mov   b ds:[bp],al
            mov   cx,bp

            pop   ebx
            pop   eax

            add   eax,__Fract_STP
            inc   cl
            jnz   __Fract_x_cyklus

            add   ebx,__Fract_STP
            inc   ch
            jnz   __Fract_y_cyklus

            ret
GenerateJulia ENDP

GenerateMandel PROC NEAR
__Fract_NAS equ   16777216
__Fract_STP equ   5*__Fract_NAS/256
            ;лллллллллллллллллллллллллллллллллл
            ; Mandelbrot computing
            ;лллллллллллллллллллллллллллллллллл
            ; input  ds - destination
            mov   ds,w cs:[img_seg]
            mov   esi,-2*__Fract_NAS
            xor   bx,bx
__Fract_y_cyklus:
            mov   edi,-2*__Fract_NAS
__Fract_x_cyklus:
            push  bx
            mov   eax,edi
            mov   ebx,esi
            mov   bp,151
__Fract_iter:
            sar   eax,12
            sar   ebx,12

            mov   ecx,eax     ; c1 = x1*x1
            imul  ecx,eax
            imul  ebx        ; y1 = 2*x1*y1+py
            sal   eax,1
            add   eax,esi
            xchg  eax,ebx
            imul  eax         ; c2 = y1*y1
            mov   edx,eax
            mov   eax,ecx     ; x1 = c1-c2+px
            sub   eax,edx
            add   eax,edi

            dec   bp
            jz    __Fract_end_of_iter

            add   ecx,edx     ; while c1+c2<=4 and maxiter <>0
            cmp   ecx,__Fract_NAS*4
            jle   __Fract_iter
__Fract_end_of_iter:
            mov   ax,bp
            pop   bx
            mov   b ds:[bx],al

            add   edi,__Fract_STP
            inc   bl
            jnz   __Fract_x_cyklus

            add   esi,__Fract_STP
            inc   bh
            jnz   __Fract_y_cyklus

            ret
GenerateMandel ENDP

RotBitMap PROC NEAR
            ;лллллллллллллллллллллллллллл
            ;     Bitmap rotation
            ;лллллллллллллллллллллллллллл
            ; di-angle
            ; bx-scale
            ; ds-source image
            mov   bx,1c0h

            and   di,1023
            shl   di,1
            mov   ds,w cs:[sin_seg]
;            mov   fs,w cs:[cos_seg]

            mov   ax,w ds:[di]         ; si=sin(x)*scale_u
            imul  bx                   ; bp=cos(x)*scale_v
            mov   ax,w ds:[di+512]
            mov   si,dx
            imul  bx
            mov   bp,dx
            neg   bp

            push  0a000h
            pop   es
            mov   ds,w cs:[img_seg] ; whitch texture to rotate

            mov   ax,-100
            imul  si
            mov   di,ax
            mov   ax,-160
            imul  bp
            add   di,ax
            mov   dx,di
            shl   edx,16
            mov   dx,di

            mov   ax,100
            imul  bp
            mov   di,ax
            mov   ax,-160
            imul  si
            add   di,ax
            mov   cx,di
            shl   ecx,16
            mov   cx,di

;            xor   edx,edx           ; xp
;            xor   ecx,ecx           ; yp


            xor   di,di             ; pociatocny offset
__rot_bmp_y:                        ; rotacia
            rol   edx,16
            add   dx,si             ; inc(xs,cosx)
            mov   ax,dx
            rol   edx,16
            mov   dx,ax

            rol   ecx,16
            sub   cx,bp             ; dec(ys,sinx)
            mov   ax,cx
            rol   ecx,16
            mov   cx,ax

            mov   bh,80
__rot_bmp_x:                        ; 4 pixels loop
            shl   ebx,8

            add   cx,si
            add   dx,bp
            mov   bl,ch
            mov   bh,dh
            mov   al,b ds:[bx]
            add   cx,si
            add   dx,bp
            mov   bl,ch
            mov   bh,dh
            mov   ah,b ds:[bx]
            shl   eax,16
            add   cx,si
            add   dx,bp
            mov   bl,ch
            mov   bh,dh
            mov   al,b ds:[bx]
            add   cx,si
            add   dx,bp
            mov   bl,ch
            mov   bh,dh
            mov   ah,b ds:[bx]
            rol   eax,16
            stosd

            shr   ebx,8
            dec   bh
            jnz   __rot_bmp_x

            dec   si   ; slimmy rotation
            dec   bp

            cmp   di,64000
            jb    __rot_bmp_y

            ret
RotBitMap ENDP

Loofty PROC NEAR
            ;лллллллллллллллллллллллллллл
            ;       Bitmap loofty
            ;лллллллллллллллллллллллллллл
            ;ch - pos
            xor   cl,cl

            push  0a002h
            pop   es

            mov   ds,cs:_sin_seg
            xor   bx,bx

            mov   fs,cs:img_seg

            mov   bp,cx
__n:
            xor   di,di

            mov   al,cl
            add   al,ch
            xlatb
            add   al,cl
            mov   dh,al

;          xor   cl,cl
            mov   cl,-25
__l:
            mov   al,ch
            xlatb
            add   al,cl
            mov   dl,al
            mov   si,dx
            mov   ah,fs:[si]
            inc   cl
            inc   ch

            mov   al,ch
            xlatb
            add   al,cl
            mov   dl,al
            mov   al,ah
            mov   si,dx
            mov   ah,fs:[si]
            inc   cl
            inc   ch

            shl   eax,16

            mov   al,ch
            xlatb
            add   al,cl
            mov   dl,al
            mov   si,dx
            mov   ah,fs:[si]
            inc   cl
            inc   ch

            mov   al,ch
            xlatb
            add   al,cl
            mov   dl,al
            mov   al,ah
            mov   si,dx
            mov   ah,fs:[si]
            inc   ch
            inc   cl

            rol   eax,16
            stosd

            cmp   di,319-32-32
            jb    __l

            mov   dx,es
            add   dx,20
            mov   es,dx
            inc   bp
            mov   cx,bp
            cmp   cl,200
            jb    __n
            ret
Loofty ENDP

ChessBoard PROC NEAR
            ;лллллллллллллллллллллллллллл
            ; Create chessboard texture
            ;лллллллллллллллллллллллллллл
            mov   ds,cs:[img_seg]
            xor   di,di
__GRandom:
            mov   ax,cs:100
            inc   ax
            imul  ax,4537h
            xchg  al,ah
            mov   cs:100,ax
            and   al,7fh
            mov   [di],al
            inc   di
            jnz   __GRandom
            mov   dx,3
__Soften:
            xor   si,si
            xor   cx,cx
            xor   ah,ah
__loop:
            xor   bh,bh
            mov   bl,[si]
            shl   bx,2
            mov   bl,[si+65535]
            mov   al,[si+1]
            add   bx,ax
            mov   al,[si+65536-320]
            add   bx,ax
            mov   al,[si+320]
            add   bx,ax
            shr   bx,3  ; brightness down
            mov   [si],bl
            inc   si
            loop  __loop

            dec   dx
            jnz   __Soften
__LimitCheck:
            cmp   b [si],8
            jna   __LimitOK
            mov   b [si],8
__LimitOK:  inc   si
            loop  __LimitCheck
            xor   bx,bx
__Chess:
            mov   ax,bx
            xor   al,ah
            add   al,al
;            shl   al,1
            and   al,40h
;            shl   al,1
            add   [bx],al
            add   b [bx],128
            dec   bl
            jnz   __Chess
            dec   bh
            jnz   __Chess
            ret
ChessBoard ENDP

StarWars PROC NEAR
__LineSize  equ   10*8
__Xmin      equ   68
__Ysiz      equ   128
            ;лллллллллллллллллллллллллллл*
            ;     StarWars scroller
            ;лллллллллллллллллллллллллллл*
            ; al-yposition
            shl   ax,5
            mov   dx,ax
            push  0a000h
            pop   es
            push  cs
            pop   ds
            mov   w ds:[pom_w0],321-__Xmin   ; add offset for next line
            mov   w ds:[LOOPCOUNT],__Xmin
            mov   w ds:[pom_w1],__Ysiz
            mov   ds,w ds:[img_seg]
            mov   di,(199-__Ysiz)*320+((320-__Xmin)/2)
            mov   bp,180
            xor   ecx,ecx
__LineLoop:
            push  dx
            push  bp
            mov   bh,dh
            mov   eax,256*256*__LineSize
            cdq
            mov   cx,cs:[LOOPCOUNT]
            div   ecx
            mov   si,ax
            shr   eax,16
            mov   bp,ax
            mov   ax,w cs:[pom_w1]
            shr   ax,1
            neg   ax
            xor   dx,dx
            xor   bl,bl
            and   al,63
__PixelLoop:
            mov   ah,ds:[bx]
            add   ah,al
            mov   es:[di],ah
            add   dx,si
            adc   bx,bp
            inc   di
            dec   cx
            jnz   __PixelLoop
            pop   bp
            pop   dx
            add   dx,bp
            dec   bp
            dec   bp

            sub   w cs:[pom_w0],2
            add   di,cs:[pom_w0]
            add   w cs:[LOOPCOUNT],2

            dec   b cs:[pom_w1]
            jnz   __LineLoop
            ret
StarWarsBackground:
            push  0a000h
            pop   es
            mov   di,(198-__Ysiz)*320
            xor   al,al
__Back:
            mov   cx,640
            rep   stosb
            inc   al
            cmp   al,64
            jb    __Back
            ret
StarWars ENDP

MakeTorus PROC NEAR
__M         equ   (1 shl M_SHIFT)
__N         equ   (1 shl N_SHIFT)
__M_A       equ   __M-1
__N_A       equ   __N-1
__R0        equ   800
__R1        equ   600
__RN        equ   32767-__R0
__U_STP     equ   (2048/(__N-1))
__U_MAX     equ   __U_STP*(__N-1)
__V_STP     equ   (2048/(__M-1))
__V_MAX     equ   __V_STP*(__M-1)
            ;лллллллллллллллллллллллллллл
            ;      Generating torus
            ;лллллллллллллллллллллллллллл
            push  cs
            pop   ds
            mov   fs,w ds:[sin_seg]
            mov   gs,w ds:[cos_seg]
            mov   ds,w ds:[vrt_seg]

            xor   bp,bp ; vrt pointer  ; compute vertex coordinates
            mov   ch,__N
            xor   di,di ; u angle
__Torus_vrt_n:
            xor   si,si ; v angle
            mov   cl,__M
__Torus_vrt_m:
            push  di

            mov   ax,si          ; end check
            shr   ax,3
            cmp   si,__V_MAX
            jne   __VK
            mov   ax,255
            xor   si,si
__VK:
            mov   w ds:[bp+tx],ax

            mov   ax,di
            shr   ax,2
            cmp   di,__U_MAX
            jne   __UK
            mov   ax,511
            xor   di,di
__UK:
            mov   w ds:[bp+ty],ax

            mov   ax,w __R1      ; x=cos(u)*(R0+R1*cos(v))
            imul  w gs:[si]
            sal   dx,1
            add   dx,__R0
            mov   bx,dx
            mov   ax,w gs:[di]
            imul  dx
            mov   w ds:[bp+x],dx

            mov   ax,bx          ; y=sin(u)*(R0+R1*cos(v))
            imul  w fs:[di]
            mov   w ds:[bp+y],dx

            mov   ax,w __R1      ; z=R1*sin(v)
            imul  w fs:[si]
            mov   w ds:[bp+z],dx
                                 ; vertex normal compute
            mov   ax,w __Rn      ; nx=cos(u)*(Rn*cos(v))
            imul  w gs:[si]
            sal   dx,1
            mov   bx,dx
            mov   ax,w gs:[di]
            imul  dx
            mov   w ds:[bp+nx],dx

            mov   ax,bx          ; ny=sin(u)*(Rn*cos(v))
            imul  w fs:[di]
            mov   w ds:[bp+ny],dx

            mov   ax,w __Rn      ; nz=Rn*sin(v)
            imul  w fs:[si]
            mov   w ds:[bp+nz],dx

            add   bp,VRT_SIZE    ; move pointer to next vertex

            add   si,__V_STP
            pop   di
            dec   cl
            jnz   __Torus_vrt_m

            add   di,__U_STP
            dec   ch
            jnz   __Torus_vrt_n

            mov   ds,w cs:[fcs_seg]
            xor   bp,bp ; fcs pointer  ; generate vertices
            mov   dx,__N-1
__Torus_fcs_n:
            mov   cx,__M-1
__Torus_fcs_m:
            call  __ComputeVRT
            mov   w ds:[bp+vrt_0],ax
            dec   dx
            call  __ComputeVRT
            mov   w ds:[bp+vrt_1],ax
            dec   cx
            call  __ComputeVRT
            mov   w ds:[bp+vrt_2],ax
            inc   dx
            call  __ComputeVRT
            mov   w ds:[bp+vrt_3],ax
            inc   cx

            add   bp,FCS_SIZE
            loop  __Torus_fcs_m
            dec   dx
            jnz   __Torus_fcs_n

            mov   ax,(__M-1)*(__N-1)
            mov   cs:[faces],ax
            mov   ax,__M*__N
            mov   cs:[vrtxs],ax

            ret
__ComputeVRT:                    ; common rutine
            mov   ax,dx
            and   ax,__N_A
            shl   ax,M_SHIFT
            mov   bx,cx
            and   bx,__M_A
            add   ax,bx
            ret
MakeTorus ENDP

FeatherFract PROC NEAR
            ;лллллллллллллллллллллллллллл
            ;     Feather fractal
            ;лллллллллллллллллллллллллллл
__SHIFT     equ   10
__NAS       equ   (1 shl __SHIFT)
__aa        equ   (-(48*__NAS)/100)
__b         equ   ((93*__NAS)/100)
__c         equ   (2*__NAS-2*__aa)
__x         equ   ebp
__y         equ   edi
__z         equ   ecx
__w         equ   esi
;#define NAS 1024
;              aa=-0.48*NAS;
;              b=0.93*NAS;
;              c=2.0*NAS-2.0*aa;
;              x=3.0*NAS;
;              y=0;
;              w=(aa*x>>10) + c*(x*x>>10)/(1024+(x*x>>10));
            push  0a000h
            pop   ds
            mov   __x,3*__NAS
            xor   __y,edi
            mov   __w,(3*__aa)+((__c*9)/10)
            mov   cx,4000h
__Fract_loop:
            push  cx
            movzx eax,w cs:_counter
            mov   ecx,__x           ; ox=24*x
            imul  ecx,eax
            sar   ecx,__SHIFT+3
            mov   ebx,__y           ; oy=24*y
            imul  ebx,eax
            sar   ebx,__SHIFT+3

            mov   ax,280
            add   cx,ax            ; move to center of screen
            add   bx,ax
            ;лллллллллллллллллллллллллллл
            ; Putpixel pre 640*480*16
            ;лллллллллллллллллллллллллллл
            ;  cx - x
            ;  bx - y

            cmp   cx,639
            ja    __ExitLabel
            cmp   bx,479
            ja    __ExitLabel

            shl   bx,4     ; y*80
            mov   ax,cx
            shr   ax,3
            add   ax,bx
            shl   bx,2
            add   bx,ax

            mov   dx,3ceh
            mov   ax,0205h
            out   dx,ax
            mov   ax,8008h
            and   cl,7
            shr   ah,cl
            out   dx,ax

            mov   al,4
            xchg  ds:[bx],al
__ExitLabel:

            mov   __z,__x           ; z=x

            mov   eax,__b           ; x= b*y+w
            imul  __y
            sar   eax,__SHIFT
            add   eax,__w
            mov   __x,eax

            imul  eax               ; u=x*x
            sar   eax,__SHIFT

            mov   ebx,eax           ; w=aa*x+c*u/(1+u)
            mov   eax,__c
            imul  ebx      ; c*u=>edx:eax
            add   ebx,__NAS
            idiv  ebx
            mov   ebx,eax
            mov   eax,__aa
            imul  __x
            sar   eax,__SHIFT
            add   ebx,eax
            mov   __w,ebx

            sub   ebx,__z         ; y=w-z
            mov   __y,ebx

            pop   cx
            dec   cx
            jnz   __Fract_loop
            ret
FeatherFract ENDP

EndScroll PROC NEAR
            ;лллллллллллллллллллллллллллл
            ; Zaverecny scroller
            ;лллллллллллллллллллллллллллл
            ;  si - y pos
            mov   ds,cs:img_seg
            mov   gs,w cs:_sin_seg
            push  0a000h
            pop   es
            mov   bp,si
            shl   si,7
            xor   di,di
            mov   dx,199
            xor   eax,eax
__loop:
            and   bp,255
            movsx cx,b gs:[bp]
            add   cx,95-8
            rep   stosb
            mov   b es:[di],64
            inc   di
            stosd
            stosd
            mov   cx,128
            rep   movsb
            movsx cx,b gs:[bp]
            neg   cx
            add   cx,95-8
            stosd
            stosd
            mov   b es:[di],64
            inc   di
            rep   stosb
            dec   bp

            dec   dx
            jnz   __loop
            ret
EndScroll ENDP

Zoom PROC NEAR
            ;лллллллллллллллллллллллллллл
            ;  Zooming
            ;лллллллллллллллллллллллллллл
            ; bx - size
            mov   b cs:pom_w0,bl
            mov   bp,bx
            mov   ax,320
            sub   ax,bx
            mov   w cs:pom_w1,ax
            mov   di,100*320-160
            shr   bx,1
            sub   di,bx
            shr   bx,2
            shl   bx,6
            sub   di,bx
            shl   bx,2
            sub   di,bx
            mov   ds,w cs:img_seg
            push  0a000h
            pop   es
            mov   ax,8*7*256
            cwd
            idiv  bp
            mov   si,ax
            mov   ax,16*256
            mov   bx,bp
            shr   bx,2
            jz    __end
            cwd
            idiv  bx
            xchg  ax,bp
            mov   ah,al
            shr   al,2
            xor   bx,bx
            xor   cx,cx
__y_loop:
            xor   dx,dx
            push  ax
            mov   bh,ch
            mov   al,b cs:pom_w0
            shr   al,2
            add   al,3
__x_loop:
            mov   bl,dh
            cmp   b ds:[bx],0
            je    __NoPix
            mov   es:[di],al
__noPix:
            inc   di
            add   dx,si
            dec   ah
            jnz   __x_loop
            pop   ax
            add   cx,bp
            add   di,w cs:pom_w1
            dec   al
            jnz   __y_loop
__end:
            ret
Zoom ENDP

            ;лллллллллллллллллллллллллллл
            ;        D  A  T  A
            ;лллллллллллллллллллллллллллл

char_per_line     equ   13

pink                       db 83,43,73
red                        db 80,53,53
blue                       db 53,53,85
green                      db 53,83,55
yellow                     db 80,80,50
scroll_0                   db " COMMING",0
                           db "   UP",0
                           db " STUPID",0
                           db "  TORUS",0,0
scroll_1                   db "code by",0
                           db "  o_o",0
                           db " (јљј)",0
                           db " сюрч",0,0
scroll_2                   db " GROUP GREETINGS"
                           db "     GOES TO",0
                           db " ",0
                           db "      SiN",0
                           db "Sunrise Software"
                           db "      MiST",0
                           db "  Dark Kingdom",0
                           db "  Shadow  Rays",0
                           db "      DAX",0
                           db " ",0
                           db " all demomakers "
                           db "around the world"
                           db " ",0
                           db "     AND YOU",0,0

end_txt                    db "The End",0
err1_text                  db "Mem!$"
exit_txt                   db "Vote",0,"4",0,"The",0,"MAX­MUM",0,"4kB",0,"intro",0ah
                           db "Code:Bear/Sinope",0ah
                           db "Exit",0,"2",0,"MS",0,"hell$"

vrtxs                      dw ?
faces                      dw ?
aktiv_faces                dw ?  ; visible faces

sin_seg                    dw ?  ; sinus table
cos_seg                    dw ?  ; cosin table (intersect with sin)
_sin_seg                   dw ?  ; 8 bit sinu table
pol_seg                    dw ?
vrt_seg                    dw ?
fcs_seg                    dw ?
img_seg                    dw ?  ; image segment
buf_seg                    dw ?  ; dysplay buffer segment
bck_seg                    dw ?  ; dysplay background
lst_seg                    dw ?  ; array with some polygon varibles
lohi_seg                   dw ?  ; polygon boubdaries
pal_seg                    dw ?
fnt_seg                    dw ?
fnt_off                    dw ?
mat_seg                    dw ?  ; segment transformacnej matice
int_seg                    dw ?
int_off                    dw ?


            ;лллллллллллллллллллллллллллллллллллллллллл
            ; DATA umiestnene pod hranicou cs:[100h]
            ;лллллллллллллллллллллллллллллллллллллллллл
; from cs:[5ch] to cs:[ffh] is usable space for data (one byte offset)
; Program segment prefix

poly_y_lo               equ   5ch   ;dw ?  ; Lo Y limit of polygon
poly_y_hi               equ   5eh   ;dw ?  ; Hi Y limit of polygon

poly_0_0                equ   060h   ; x1,y1
poly_0_1                equ   064h   ; x2,y2
poly_1_0                equ   068h   ; .
poly_1_1                equ   06ch   ; .
poly_2_0                equ   070h   ; .
poly_2_1                equ   074h   ; .
poly_3_0                equ   078h   ; .
poly_3_1                equ   07ch   ; .

pom_w0                  equ   080h
pom_w1                  equ   082h
pom_w2                  equ   084h
pom_w3                  equ   086h

u_x                     equ   088h  ; vector u for normal compute
u_y                     equ   08ah
u_z                     equ   08ch
v_x                     equ   08eh  ; vector v for normal compute
v_y                     equ   090h
v_z                     equ   092h
SHADE_INC               equ   098h  ; dd
TXR_X_INC               equ   09ch  ; dd
TXR_Y_INC               equ   0a0h  ; dd
TXR_X                   equ   0a4h  ; dd
TXR_Y                   equ   0a8h  ; dd
LOOPCOUNT               equ   0ach  ; dd
_EAX                    equ   0b0h
_AX                     equ   0b0h
_AL                     equ   0b0h
_AH                     equ   0b1h
_HAX                    equ   0b2h
_EBX                    equ   0b4h
_BX                     equ   0b4h
_BL                     equ   0b4h
_BH                     equ   0b5h
_HBX                    equ   0b6h
_ECX                    equ   0b8h
_CX                     equ   0b8h
_CL                     equ   0b8h
_CH                     equ   0b9h
_HCX                    equ   0bah
_EDX                    equ   0bch
_DX                     equ   0bch
_DL                     equ   0bch
_DH                     equ   0bdh
_HDX                    equ   0beh
_ESI                    equ   0c0h
_SI                     equ   0c0h
_HSI                    equ   0c2h
_EDI                    equ   0c4h
_DI                     equ   0c4h
_HDI                    equ   0c6h
_EBP                    equ   0c8h
_BP                     equ   0c8h
_HBP                    equ   0cah
_ESP                    equ   0d0h

_fade                   equ   0fch
_fade_dir               equ   0fdh
_counter                equ   0feh

engine     endp
seg_main   ends
end  start

;bye,   o_o
; Bear (јљј)
