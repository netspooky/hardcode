;
; incompatibility version
;
;The routine to fill a 4sided polygon with Texture
;!!! Modified for Texture !!! GS = Texture segment (128x128) !!!
;(C)oded by RoByMuS / ByTeaM   at   1-20-1995
;No clipping included, so be ware !!!
;!!! 80386 required !!!
;Input DS:SI -> X/Y (word) of all points...
;      ES    -> video segment (256x256 resolution)
;      DS:BX -> 4 byte -> colors of points (0-63)
;
;Usage: Set the input datas, then call near the Gouraud routine !!!
;

assume ds:code

TextureColorAdd db 0

.386
jumps

MandelTexture:
call HorizontalMandelTexture
retn

Texture:
call HorizontalTexture
retn

horizontalMandelTexture:
push ds si bx
mov di,offset TextureXYArea
mov cx,8
CopyTextureXY1_:
lodsw
mov cs:[di],ax
add di,2
loop CopyTextureXY1_
mov di,offset TextureColorArea
mov cx,8
CopyTextureColor1_:
mov al,ds:[bx]
mov cs:[di],al
inc bx
inc di
loop CopyTextureColor1_
;
;then do the job...
;
mov ax,cs
mov ds,ax
mov bp,offset Texture2Horizline
call TexturePolygon
pop bx si ds
retn

HorizontalTexture:
;
;First copy original datas to internal area...
;
push ds si bx
mov di,offset TextureXYArea
mov cx,8
CopyTextureXY1:
lodsw
mov cs:[di],ax
add di,2
loop CopyTextureXY1
mov di,offset TextureColorArea
mov cx,8
CopyTextureColor1:
mov al,ds:[bx]
mov cs:[di],al
inc bx
inc di
loop CopyTextureColor1
;
;then do the job...
;
mov ax,cs
mov ds,ax
mov bp,offset TextureHorizline
call TexturePolygon
pop bx si ds
retn

TextureXYArea dw 2*4 dup (?)
TextureColorArea db 8 dup (?)

TextureLeftArea:
dw ?                 ;position in TextureXYArea
dw ?                 ;position in TextureColorArea
dd ?                 ;current x value * 65536
dd ?                 ;add it to x value...
dw ?                 ;current color value * 256
dw ?                 ;add it to color...
;
TextureLeftAdd dw -4    ;add it to TextureXYOfs/left
TextureLeftColAdd dw -2 ;add it to TextureColorOfs/left
TextureLeftColCmp dw -2 ;compare TextureColorOfs/left with this
TextureLeftColRep dw 6  ;replace TextureColorOfs/left with this
TextureLeftOfsRep dw 3*4;replace TextureXYOfs/left with this...
;
dw ?,?                  ;secondary colors...
;
TextureRightArea:
dw ?                 ;position in TextureXYArea
dw ?                 ;position in TextureColorArea
dd ?                 ;current x value * 65536
dd ?                 ;add it to x value...
dw ?                 ;current color value * 256
dw ?                 ;add it to color...
;
dw 4
dw 2
dw 8
dw 0
dw 0
;
dw ?,? ;2nd color...

TextureXYOfs equ word ptr ds:[bx+0]
TextureColorOfs equ word ptr ds:[bx+2]
TextureDwordX equ dword ptr ds:[bx+4]
TextureWordX equ word ptr ds:[bx+6]
TextureXAdd equ dword ptr ds:[bx+8]
TextureCol equ word ptr ds:[bx+12]
TextureColAdd equ word ptr ds:[bx+14]
TextureAdd equ word ptr ds:[bx+16]
TextureCol_Add equ word ptr ds:[bx+18]
TextureColCmp equ word ptr ds:[bx+20]
TextureColRep equ word ptr ds:[bx+22]
TextureOfsRep equ word ptr ds:[bx+24]
TextureCol_ equ word ptr ds:[bx+26]
TextureColAdd_ equ word ptr ds:[bx+28]
;
TextureXYOfs2 equ word ptr ds:[bx+0+30]
TextureColorOfs2 equ word ptr ds:[bx+2+30]
TextureDwordX2 equ dword ptr ds:[bx+4+30]
TextureWordX2 equ word ptr ds:[bx+6+30]
TextureXAdd2 equ dword ptr ds:[bx+8+30]
TextureCol2 equ word ptr ds:[bx+12+30]
TextureColAdd2 equ word ptr ds:[bx+14+30]
TextureCol_2 equ word ptr ds:[bx+26+30]
TextureColAdd_2 equ word ptr ds:[bx+28+30]

TextureGlobalY dw ?
TextureMaximum dw ?

TexturePolygon:
;
;Select smallest and largest Y value...
;
mov si,4
xor di,di                         ;minimum
mov bx,di                         ;maximum
mov cx,3
TextureSelect:
mov ax,TextureXYArea[si+2]        ;Y Coord
cmp ax,TextureXYArea[di+2]
jae TextureNoMinimum
mov di,si
TextureNoMinimum:
cmp ax,TextureXYArea[bx+2]
jbe TextureNoMaximum
mov bx,si
TextureNoMaximum:
add si,4
loop TextureSelect
mov cx,TextureXYArea[bx+2]
mov ax,TextureXYArea[di+2]
mov TextureGlobalY,ax
sub cx,ax
add cx,2     ;Looks better...
push cx
mov TextureMaximum,bx
mov bx,offset TextureLeftArea
mov TextureXYOfs,di
mov TextureXYOfs2,di
shr di,1                         ;/2
mov TextureColorOfs,di
mov TextureColorOfs2,di
call InitTexture
mov bx,offset TextureRightArea
call InitTexture
pop cx
TextureMainCik:
push cx
mov bx,offset offset TextureLeftArea
call bp            ;do the horizontal line...
call DoTexture
mov bx,offset offset TextureRightArea
call DoTexture
inc TextureGlobalY
pop cx
loop TextureMainCik
retn

InitTexture:
mov si,TextureXYOfs
mov di,TextureColorOfs
movzx eax,word ptr TextureXYArea[si]
movzx edx,word ptr TextureXYArea[si+2]
shl eax,16
mov TextureDwordX,eax
movzx cx,byte ptr TextureColorArea[di]
shl cx,7
mov TextureCol,cx
movzx cx,byte ptr TextureColorArea[di+1]
shl cx,7
mov TextureCol_,cx
;
;get next...
;
add si,TextureAdd
add di,TextureCol_Add
cmp di,TextureColCmp
jne NoReplaceTexture
mov si,TextureOfsRep
mov di,TextureColRep
NoReplaceTexture:
;
push edx
movzx edx,word ptr TextureXYArea[si]
shl edx,16
sub eax,edx
;
movzx edx,word ptr TextureXYArea[si+2]
pop ecx
sub ecx,edx
jecxz DontDivTexture
cdq
idiv ecx       ;-X / -Y = X/Y
DontDivTexture:
mov TextureXAdd,eax
mov ax,TextureCol
mov dl,TextureColorArea[di]
xor dh,dh
shl dx,7
sub ax,dx
jecxz DontDivTexture2
cwde
cdq
idiv ecx
DontDivTexture2:
mov TextureColAdd,ax
;
mov ax,TextureCol_
mov dl,TextureColorArea[di+1]
xor dh,dh
shl dx,7
sub ax,dx
jecxz DontDivTexture3
cwde
cdq
idiv ecx
DontDivTexture3:
mov TextureColAdd_,ax
;
mov TextureXYOfs,si
mov TextureColorOfs,di
retn

DoTexture:
mov si,TextureXYOfs
mov ax,TextureGlobalY
cmp ax,TextureXYArea[si+2]
jb NoInitTextureNeeded
call InitTexture
retn
NoInitTextureNeeded:
mov eax,TextureXAdd
add TextureDwordX,eax
mov ax,TextureColadd
add TextureCol,ax
mov ax,TextureColadd_
add TextureCol_,ax
retn

TextureHorizline:
;
;Now it's idle...
;
push TextureCol_ TextureCol_2
push TextureCol TextureCol2
mov ax,TextureWordX
mov cx,TextureWordX2
sub cx,ax
jnc TextureNoSwap
neg cx
mov ax,TextureCol
xchg ax,TextureCol2
mov TextureCol,ax
mov ax,TextureCol_
xchg ax,TextureCol_2
mov TextureCol_,ax
mov ax,TextureWordX2
TextureNoSwap:
mov ah,byte ptr TextureGlobalY
mov di,ax
mov ax,TextureCol2
sub ax,TextureCol
jcxz TextureNoDiv
cwd
idiv cx
TextureNoDiv:
mov Textureadd1,ax
mov ax,TextureCol
mov Textureval1,ax
;
mov ax,TextureCol_2
sub ax,TextureCol_
jcxz TextureNoDiv2
cwd
idiv cx
TextureNoDiv2:
mov Textureadd2,ax
mov ax,TextureCol_
mov Textureval2,ax
;
inc cx
TextureHorizCik:
mov ax,Textureval1
and ax,not 7fh         ;y coord
mov si,Textureval2
shr si,7               ;x coord
add si,ax
mov al,gs:[si]
add al,cs:TextureColorAdd
stosb
mov ax,Textureadd1
add Textureval1,ax
mov ax,Textureadd2
add Textureval2,ax
loop TextureHorizCik
pop TextureCol2 TextureCol
pop TextureCol_2 TextureCol_
retn

Textureadd1 dw ?
Textureadd2 dw ?
Textureval1 dw ?
Textureval2 dw ?

Texture2Horizline:
;
;Now it's idle...
;
push TextureCol_ TextureCol_2
push TextureCol TextureCol2
mov ax,TextureWordX
mov cx,TextureWordX2
sub cx,ax
jnc TextureNoSwap_
neg cx
mov ax,TextureCol
xchg ax,TextureCol2
mov TextureCol,ax
mov ax,TextureCol_
xchg ax,TextureCol_2
mov TextureCol_,ax
mov ax,TextureWordX2
TextureNoSwap_:
mov ah,byte ptr TextureGlobalY
mov di,ax
mov ax,TextureCol2
sub ax,TextureCol
jcxz TextureNoDiv_
cwd
idiv cx
TextureNoDiv_:
mov Textureadd1,ax
mov ax,TextureCol
mov Textureval1,ax
;
mov ax,TextureCol_2
sub ax,TextureCol_
jcxz TextureNoDiv2_
cwd
idiv cx
TextureNoDiv2_:
mov Textureadd2,ax
mov ax,TextureCol_
mov Textureval2,ax
;
inc cx
TextureHorizCik_:
mov ax,Textureval1
and ax,not 7fh         ;y coord
mov si,Textureval2
shr si,7               ;x coord
add si,ax
mov al,gs:[si]
test al,31
jz texture_noput_
mov es:[di],al
texture_noput_:
inc di
mov ax,Textureadd1
add Textureval1,ax
mov ax,Textureadd2
add Textureval2,ax
loop TextureHorizCik_
pop TextureCol2 TextureCol
pop TextureCol_2 TextureCol_
retn

assume ds:data1
