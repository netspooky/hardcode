;ku psi brejle
.386
cra segment use16
assume es:cra,cs:cra,ss:cra,ds:cra
org 100h
all:

 mov  al,13h
 int  10h
 push 0A000h
 pop  es
;nastavi gradientni sedou paletu
 mov  dx,03C8h
 mov  cl,63
@0:
 mov  al,cl
 out  dx,al
 inc  dx
 out  dx,al
 out  dx,al
 out  dx,al
 dec  dx
 loop @0
;napise maly napis do rohu obrazovky
 mov  dx,offset msg
 mov  ah,9
 int  21h
;skopiruje ho a zvetsi ho 1x1 -> 4x7
 mov  di,75*320
 mov  ch,8
@1:
 mov  cl,80
@2:
 mov  al,es:[bx]
 inc  bx
 mov  dl,al
 shl  dl,3
 mov  ah,4
@3:
 mov  al,7
@4:
 mov  es:[di],dl
 add  di,320
 dec  al
 jnz  @4
 sub  di,7*320-1
 dec  ah
 jnz  @3
 dec  cl
 jnz  @2
 add  bx,320-80
 add  di,6*320+320-10*8*4
 dec  ch
 jnz  @1
;vymaze puvodni napis
 xor  di,di
 mov  ax,di
 mov  cx,8*320/2
 rep  stosw
;skopiruje napis do CodeSegmentu do ofsetuu 0200h a 5200h.
 PUSH DS
 push es
 pop  ds
 push cs
 pop  es
 mov  si,70*320
 mov  di,200h
 mov  cx,8*8*320/2
 rep  movsw
 mov  si,70*320
 mov  cx,8*8*320/2
 rep  movsw
 push cs
 pop  ds
;hlavni cyklus
@main:
;prekopiruje napis do mezibuferu
 mov  si,5200h
 mov  di,200h
 mov  cx,8*8*320/2
 rep  movsw
;rozostri napis v mezibuferu
;00yxxxxx - x=cislo, y=1 pro zvetsovani
 mov  al,ah
 shr  al,4
 and  al,2
 dec  al
 add  ah,al
 jns  @5
 mov  ah,00100000b
@5:
 push ax
@oko:
 mov  si,200h+320
 mov  cx,62*320
@oko1:
 mov  al,ds:[si]
 shl  al,1
 add  al,ds:[si+320]
 add  al,ds:[si-320]
 shr  al,2
 mov  ds:[si],al
 inc  si
 loop @oko1
; mov  si,201h
; mov  cx,64*320-2
;@oko2:
; mov  al,ds:[si]
; shl  al,1
; add  al,ds:[si+1]
; add  al,ds:[si-1]
; shr  al,2
; mov  ds:[si],al
; inc  si
; loop @oko2
 dec  ah
 test ah,1Fh
 jnz  @oko
 pop  ax
;hodi napis na obrazovku
 push 0A000h
 pop  es
 mov  si,200h
 mov  di,70*320
 mov  cx,8*8*320/2
 rep  movsw
 push cs
 pop  es
;pocka na Retracy Chapmana
 mov  dx,03DAh
@trace1:
 in   al,dx
 test al,8
 jz   @trace1
 in   al,60h
 dec  al
 jnz  @main
 POP  DS
 xor  ah,ah
 int  16h
 retn

msg	db   'FIASKO ',27h,'99$'

cra ends
end all
