.model small

RadSeg segment para 'CODE' 
	include music.inc
RadSeg ends

CsSeg segment para 'CODE' use16
assume cs:CsSeg,ds:CsSeg
.386
.387
main:
     call SetInt
     push cs
     pop ds
     push FsSeg
     pop fs
     push fs
     pop es
     push GsSeg
     pop gs

     mov ax,13h
     int 10h

     call Randomize
     call GetFontInfo
     call CalcSQRTab
     mov si,offset LisX
     call CalcLis
     call CalcPic
     call CalcYTab
     call NullTab
     call Intro
     mov dx,6500h
     call PutSpot
     mov ax,RadSeg
     mov es,ax
     call InitPlayer

     mov word ptr ds:Ys,0
     mov word ptr cs:TOffs,offset DemTxt
ml1:
     call Txt
     call CalcLines
     call MakeSpot
     call MakeBuff
     call Show
     in al,60h
     dec al
     jnz ml1

     call ResetInt
     call EndPlayer
     call TextOutro
     mov ax,3
     int 10h
     mov ax,4c00h
     int 21h

Show:
     push es
     push ds
     push TempSeg
     pop ds
     mov ax,0a000h
     mov es,ax
     mov cx,16000
     xor si,si
     xor di,di
     rep movsd
     pop ds
     pop es
     ret


MakeSpot:
     push cs
     pop ds
     push fs
     pop es
     add byte ptr ds:Ys,1
     mov bx,word ptr ds:Ys
     mov dl,byte ptr ds:LisX[bx]
     mov dh,byte ptr ds:LisY[bx]
     add dh,65h
     call PutSpot
     ret

MakeBuff:
assume ds:CsSeg
     push TempSeg
     pop es
     mov si,320
     mov bp,58
mbl3:
     xor cx,cx
mbl1:
     xor dx,dx
     xor bx,bx
     mov bl,byte ptr ds:Y[si+320]
     or bl,bl
     jz mbl6
     mov dl,byte ptr ds:Y[si]
     mov di,dx
     or dl,dl
     jz mbl6
     sub bx,dx
     js mbl6
     cmp bl,1
     jle mbl4
     xor dx,dx
     mov ah,byte ptr ds:Lite[si+320]
     sub ah,byte ptr ds:Lite[si]
     sbb dx,0
     idiv bx
     mov dx,ax
     mov bh,byte ptr ds:Lite[si]
     mov ah,bl
     xor bl,bl
     shl di,1
     mov di,word ptr ds:YTab[di]
     add di,cx
mbl5:
;			mov al,byte ptr es:[di]
;			shr al,4
;			jnc mbll1
;			xor al,al
;		mbll1:
;			add al,bh
;			jnc mbll2
;			mov al,0ffh
;		mbll2:
     mov al,bh
     stosb
     add di,320-1
     add bx,dx
     dec ah
     jnz mbl5
mbl6:
     inc si
     inc cx
     cmp cx,320
     jnz mbl1
     dec bp
     jnz mbl3
     jmp mbl7
mbl4:
     mov al,byte ptr ds:Lite[si]
     shl di,1
     mov di,word ptr ds:YTab[di]
     add di,cx
     stosb
     jmp mbl6
mbl7:
     ret

SetPal:
     mov dx,3c8h
     xor ax,ax
     out dx,al
     inc dx
     mov si,offset pal
     mov cx,768
     rep outsb
     ret

;ebx - y
;ebp - k
CalcLines:
     mov ebx,453
     xor bp,bp
     xor si,si
     mov cx,61
     push fs
     pop ds
cll6:
     push cx
     push ebx
     push bp

     mov word ptr cs:[sil1+2],si
     add word ptr cs:[sil1+2],256
     movzx ecx,bp
     shl bp,1
     mov bp,word ptr cs:YTab[bp]
     mov word ptr cs:[bpl1+2],bp

     mov eax,512 shl 8
     cdq
     div ebx
     mov ebp,-128
     imul ebp,eax
     mov dword ptr cs:[ebxl2+2],eax
     mov dword ptr cs:[xn+3],eax
     mov byte ptr cs:[bhl1+1],ah

     imul ecx,eax
     shr ecx,8
     add cx,122
     mov byte ptr cs:Y-1,cl
     xor di,di
cll1:
xn:
     add ebp,1000
     xor ch,ch
     mov cl,byte ptr cs:Y[di-1]
;dy
     xor eax,eax
     xor dx,dx

assume ds:FsSeg
     mov dl,byte ptr ds:Map[si]
     push cx
     mov al,byte ptr ds:Map[si+1]
     sub dx,ax
     push dx
     mov cl,byte ptr ds:lMap[si]
     mov al,byte ptr ds:lMap[si+1]
     sub ax,cx
     shl eax,16
     cdq
ebxl2:
     mov ebx,1000
     idiv ebx
     xor bl,bl
     mov bh,cl
     mov cx,ax
     pop dx
     pop ax
bhl1:
     mov dh,10
     mov edi,ebp
     shr edi,8
     add di,160
bpl1:
     add di,01000
     or dl,dl
     js cll5
loopdy:
     or ax,ax
     js cll2
     mov byte ptr cs:Y[di],al
cll2:
     mov byte ptr cs:Lite[di],bh
     add al,dl
     adc ah,0
     add bx,cx
     inc di
     sub dh,1
     jnc loopdy
     jmp cll4
cll5:
     neg dl
loopMdy:
     or ax,ax
     js cll3
     mov byte ptr cs:Y[di],al
cll3:
     mov byte ptr cs:Lite[di],bh
     sub al,dl
     sbb ah,0
     add bx,cx
     inc di
     sub dh,1
     jnc loopMdy
cll4:
     inc si
sil1:
     cmp si,1000
     jnz cll1
     pop bp
     pop ebx
     pop cx
     dec ebx
     inc bp
     dec cx
     jnz cll6
     ret



assume ds:CsSeg
NullTab:
     push ds
     mov si,offset Y
     mov cx,320*61
     xor ax,ax
ntl1:
     mov word ptr ds:[si],ax
     inc si
     inc si
     loop ntl1

     push TempSeg
     pop ds
     xor si,si
     mov cx,0ffffh
ntl2:
     mov byte ptr ds:[si],al
     inc si
     loop ntl2
     pop ds
     ret

ClsFont:
     xor di,di
     xor al,al
     mov cx,320*111
     rep stosb
     ret

CalcYTab:
     mov si,offset YTab
     mov cx,200
     xor ax,ax
cyl1:
     mov word ptr ds:[si],ax
     add ax,320
     inc si
     inc si
     loop cyl1
     ret

Txt:
     push fs
     push gs
     push es
     push TempSeg
     pop gs
     push TxtSeg
     pop es
     mov si,320*109
     mov cx,320*3/4
     xor eax,eax
tl2:
     mov dword ptr gs:[si],eax
     add si,4
     dec cx
     jnz tl2
     call ShowPage
     mov word ptr cs:TOffs,bx
     jnc tl1
     mov word ptr cs:TOffs,offset DemTxt
tl1:
     pop es
     pop gs
     pop fs
     ret

include spot.asm
include sin.asm
include pic.asm
include timer.asm
include smooth.asm
include random.inc
include intro.asm
include fontlib.asm
include showpage.asm
include outro.asm
include player.asm
include txt.asm
QEndS:
	include quazpic.inc
JumpTab:
	include jtab.inc

MullyX	dw 40h
MullyY	dw 32

Divider dw 128
Ys   	dw ?
Xs   	dw ?
Dat  	dw ?

QPic	label byte
	include q1bit.inc
	db 1
Pal	label byte
     	include Pal.inc

YTab 	dw 200 dup(?)

LisX  	db 256 dup(?)
LisY  	db 256 dup(?)

	db ?
Y    	db 320*61 dup(?)
Lite 	db 320*61 dup(?)
CsSeg ends

FsSeg segment para use16
Map	db 256*61 dup(?)
sMap	db 256*61 dup(?)
lMap 	db 256*61 dup(?)
FsSeg ends

GsSeg segment para use16
     	db 256*256-1 dup(?)
GsSeg ends

TxtSeg segment para use16
     	db 320*110 dup(?)
	db 321 dup(?)
TxtSeg ends

TempSeg segment para use16
     	db 256*256-1 dup(?)
TempSeg ends

SsSeg segment para stack 'STACK' use16
	db 20h dup (?)
SsSeg ends
     end main

