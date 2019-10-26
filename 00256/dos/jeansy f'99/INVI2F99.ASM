;Invitro to Fiasko'99
.386
crs segment use16
assume es:crs,cs:crs,ss:crs,ds:crs
org 100h
all:

 mov  al,13h
 int  10h
 push 0A000h
 pop  es
 mov  dx,03C8h
 mov  cl,3Fh
@paletu:
 mov  al,cl
 out  dx,al
 inc  dx
 shr  al,2
 out  dx,al
 mov  al,cl
 shr  al,1
 out  dx,al
 shl  al,1
 out  dx,al
 dec  dx
 loop @paletu
 mov  si,offset tabulka
 mov  bx,0210h
@cykl:
 lodsw
 inc  ax
 jz   @ven
 mov  di,ax
 lodsw
 mov  dx,ax
 mov  al,bl
 call @Quad
 jmp  @cykl
@ven:
 xor  bl,bl
 dec  bh
 jnz  @cykl
@cast2:
 xor  di,di
 mov  si,318
 mov  cl,30h
@adding:
 cmp  cx,20h
 ja   @adding0
 mov  si,321
@adding0:
 push cx
 xor  cx,cx
@adding1:
 inc  di
 in   al,40h
 test al,1
 jz   @adding2
 add  di,si
@adding2:
 cmp  byte ptr es:[di],63
 jae  @adding3
 inc  byte ptr es:[di]
@adding3:
 loop @adding1
 pop  cx
 in   al,60h
 dec  al
 jz   @end
 loop @adding
@end:
 mov  ax,1200h
 mov  bl,33h
 int  10h
 xor  ah,ah
 int  16h
 retn

;{procedura, ktera nakresli vyplneny obdelnik
; al-barva, di-nastavena pozice (y*320+x), dh-sirka, dl-vyska}
@Quad:
 push bx

 xor  bh,bh
 mov  bl,dh
 xor  ch,ch
 mov  cl,dl
@Quad1:
 push cx

 mov  cl,dh
 rep  stosb
 add  di,320
 sub  di,bx

 pop  cx

 loop @Quad1
 pop  bx
 retn

origcx	dw	?

;parametry pro kresleni obdelniku:
;prvn¡ word - offset, druhy word - s¡rka shl 8+vyska
;0FFFFh znamena ukonceni
tabulka	dw	10+	20 *320,	17  shl 8+	100
       	dw	26+ 	20 *320,	28  shl 8+	5
       	dw	26+ 	42 *320,	26  shl 8+	7
       	dw	62+ 	20 *320,	13  shl 8+	100
       	dw	84+ 	20 *320,	7   shl 8+	100
       	dw	84+ 	20 *320,	48  shl 8+	5
       	dw	117+	25 *320,	15  shl 8+	98
       	dw	94+ 	42 *320,	23  shl 8+	7
       	dw	139+	20 *320,	49  shl 8+	100
       	dw	197+	20 *320,	17  shl 8+	100
       	dw	214+	42 *320,	36  shl 8+	5
       	dw	231+	20 *320,	7   shl 8+	24
       	dw	238+	42 *320,	12  shl 8+	85
       	dw	258+	20 *320,	51  shl 8+	100
       	dw	120+	133*320,	5   shl 8+	9
       	dw	131+	135*320,	29  shl 8+	43
       	dw	168+	135*320,	29  shl 8+	43
       	dw	0FFFFh
       	dw	139+	48 *320,	32  shl 8+	66
       	dw	153+	25 *320,	35  shl 8+	17
       	dw	272+	25 *320,	22  shl 8+	90
       	dw	139+	138*320,	13  shl 8+	9
       	dw	176+	138*320,	13  shl 8+	9
       	dw	131+	152*320,	21  shl 8+	23
       	dw	168+	152*320,	21  shl 8+	23
	dw	0FFFFh

crs ends
end all