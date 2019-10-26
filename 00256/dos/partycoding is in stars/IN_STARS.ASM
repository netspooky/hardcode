;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
.386
crs segment use16
assume es:crs,cs:crs,ss:crs,ds:crs
org 100h
all:
 MAXSTAR	EQU 255
 STARSIZE	EQU 6
 STARSSIZE	EQU (MAXSTAR+1)*STARSIZE
;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
 finit
 mov  al,13h
 int  10h
 mov  cl,3Fh
@pal:
 mov  dx,3C8h
 mov  al,cl
 out  dx,al
 inc  dx
 out  dx,al
 out  dx,al
 out  dx,al
 loop @pal
;vyplni data hvezd nahodnymi hodnotami
 mov  di,offset stars
 mov  ch,STARSIZE/2
@vypln:
 in   al,41h
 mov  ah,al
 in   al,41h
 shl  al,4
 shr  ax,4 
 mov  ah,0
 stosw
 loop @vypln
 push 0A000h
 pop  es
@outerloop:
 mov  di,offset stars
 mov  ch,1
@innerloop:
; y=cos(fi/128*pi)*r+160
; x=sin(fi/128*pi)*r*sin(xi)+100
;BX bude indexovat jednotlive slozky
 call @FPUload	;"fild" fi
 fild _128
 fdivp		;ST=fi/128
 fldpi
 fmulp		;ST=fi/256*2*pi=fi/128*pi, budu jeste potrebovat, ukladam
 fst  argument
 fcos
 inc  bx
 call @FPUload	;"fild" r
 fmulp
 fild _160
 faddp		;mam prvni slozku
;frndint	;pred ulozenim zaokrouhli (pouzit zbyde-li misto)
 fistp x	;ulozim ho do x, a ted' jeste sin(fi/128*pi)*r*sin(xi)+100
 fld  argument
 fsin		;ST=sin(fi/128*pi)
 call @FPUload	;"fild" r
 fmulp
 inc  bx
 call @FPUload	;"fild" xi
 fsin
 fmulp
 fild _100
 faddp		;ma druhou slozku (y=sin(fi/128*pi)*r*sin(xi)+100)
;frndint	;pred ulozenim zaokrouhli (pouzit zbyde-li misto)
 fistp y
 mov  ax,y
 cmp  ax,200
 jae  @nextstar
 xchg ah,al
 mov  si,ax
 shr  ax,1
 shr  ax,1
 add  si,ax
 mov  ax,x
 cmp  ax,320-16
 jae  @nextstar
 add  si,ax	;mam pozici, ted' jeste vypocitat barvu (24+sin(fi+xi)*8)
mov  byte ptr es:[si],63
inc  byte ptr ds:[di]
inc  byte ptr ds:[di+2]
@nextstar:
 add  di,STARSIZE
 xor  bx,bx
 loop @innerloop

 mov  di,64000
@blr:
 or   di,di
 jz   @blr_
 or   byte ptr es:[di],0
 jz   @blr2
 dec  byte ptr es:[di]
@blr2:
 dec  di
 jmp  @blr 
@blr_:

 in   al,60h
 dec  al
 jnz  @outerloop
mov  ax,3
int  10h
 retn
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
@FPUload:
 shl  bx,1
 mov  ax,ds:[di+bx]
 shr  bx,1
 mov  work,ax
 fild work
 retn
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
downtown	db 'D'
downtown_o	db 'OWNTOWN'
_100		dw 0064h	;*jestli najdu nekde v kodu tyto wordy, presmeruju tam vsechna volani s nima
_128		dw 0080h
_160		dw 00A0h
work		dw ?
y		dw ?
x		dw ?
argument	dd ?		;(mem32 for FPU)
stars		db STARSSIZE DUP (?)	;buffer pro hvezdy
;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
crs ends
end all
