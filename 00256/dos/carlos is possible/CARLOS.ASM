.386
crs segment use16
assume es:crs,cs:crs,ss:crs,ds:crs
org 100h
all:

 mov  al,13h
 int  10h
 push 0A000h
 pop  es
 mov  di,160+100*320
 mov  si,offset napisdata
 mov  cl,NAPISDATASIZE
 ;predpokladam, ze bh=0
@kresli:
 lodsb		;nahraje dalsi byte
 cmp  al,_c
 je   @kreslicolor
 mov  bl,al	;bx poslouzi pro nacteni smeru (resp.relativnimu offsetu k di)
 mov  dh,al
 shr  bl,3
 and  bl,00001110b
 and  al,0Fh
@kresliloop:
 or   dh,dh
 js   @kresli2
 mov  es:[di],ah
@kresli2:
 dec  al
 js   @kreslimainloop
 add  di,word ptr ds:[offset smer+bx]
 jmp  @kresliloop
@kreslicolor:
 lodsb
 dec  cx
 mov  ah,al	;zmeni barvu
@kreslimainloop:
 loop @kresli
@kreslikonec:
 xor  ax,ax
 int  16h
 retn

napisdata:
 _b	EQU 10000000b
 _u	EQU 00000000b
 _e	EQU 00010000b
 _r	EQU 00100000b
 _f	EQU 00110000b
 _d	EQU 01000000b
 _g	EQU 01010000b
 _l	EQU 01100000b
 _h	EQU 01110000b
 _c	EQU 11100000b

 db   _c,65,_d+2,_g+1,_d+4,_f+1,_d+2,_f+1,_d+1,_u+5,_l+1,_r+1,_c,88,_u+1,_l+1,_u+2,_b+_u+2
 db   _b+_r+1,_u+2,_r+1,_d+3,_c,65,_r+1,_u+3,_r+1,_d+6,_l+1,_d+7,_l+1,_u+7,_r+2,_d+8,_r+1
 db   _u+8,_r+1,_d+7,_c,65,_r+1,_u+7,_r+1,_d+6,_u+7,_b+_u+2,_h+1,_g+1,_l+1,_u+1,_r+2,_u+1
 db   _l+2,_u+1,_r+3,_c,89,_d+2,_f+1,_d+8,_e+1,_u+10,_l+1,_d+3,_e+1,_c,160,_u+3,_r+1,_d+6
 db   _u+5,_l+4,_u+1,_r+4,_l+12,_d+3,_u+3,_e+1,_r+10,_h+1,_l+8,_b+_f+2,_r+2,_f+1,_r+2,_b+_d+4
 db   _c,6,_h+1,_g+1,_l+1,_d+1,_c,161,_r+1,_c,29,_r+1,_c,6,_r+1,_c,30,_h+1,_c,65,_d+0,_b+_l+7
 db   _b+_u+1,_c,6,_r+1,_f+1,_l+1,_c,87,_d+0,_b+_r+2,_c,6,_d+1,_c,28,_l+1,_c,6,_l+1,_c,27,_d+0
 db   _b+_r+2,_b+_d+1,_c,89,_d+2,_b+_r+2,_c,12,_u+2,_b+_r+1,_b+_d+5,_c,39,_l+3 
;hlava by byla, a ted mam 35 bytu na telo
 db   _b+_r+2,_b+_d+4,_c,165,_g+2,_e+2,_f+2,_h+2,_d+3,_g+2,_e+2,_f+2
smer:
 dw -320,-320+1,1,320+1,320,320-1,-1,-320-1

 NAPISDATASIZE	EQU offset smer-offset napisdata

crs ends
end all
