org 100h
use16

		mov	ax, 1112h
;		xor	bl, bl
		int	10h

 push cs
 pop es
 mov di,font
 push di

;generate dither
 mov dl,64*2
DIT_GN1:
 mov bp,MATRIX-1
 mov cl,8
DIT_GN2:
 mov al,1
 mov ah,dl
 test dl,64
 jne noneg
 xor ah,255
noneg:
 and ah,63
DIT_GN3:
 inc bp
 cmp ah,[bp]
 rcl al,1
 jnc DIT_GN3
stosb
 loop DIT_GN2
dec dl
jns DIT_GN1

;store 8x8
;mov bp,font

;pop bp
;push bp
inc bp

inc ch;mov cx,128*2
xor dx,dx;mov dx,65*0
 mov bx,800h
 mov ax,1100h
int 10h

;----------fill attributes,*16-paper
;1-blue
;2-green
;3-cyan
;$4D,$40,5+8=cyan=ink,blue=paper
;$45,$C0;5-ink cyan
;$44,$40;0-ink green
;$4C,$C0;8+4, blu=paper,4-green ink
pop di

mov cx,$40
mov al,3+16;$4D
rep stosb

mov cl,$C0
mov al,3;$45
rep stosb

mov cl,$40
mov al,2;$44
rep stosb

mov cl,$C0
mov al,2+16;$4C
rep stosb

;intro begin
push $b800
pop es

;generate pattern
 xor di,di
 mov dx, 101h
 mov cl, 50
;
m1:
 mov al,dl
 mov ch,80
m2:
 push ax
 sar al,1
 mov word [cs:80*2*50+di],0
 stosw
 pop ax
 add al,dh
dec ch
jne m2
 inc dh
 inc dl
dec cl
jne m1
;xor al,al
;mov ch,8*2
;rep stosb

m5:
mov	dx, 3DAh
waitvr:
 in	 al, dx
 test	 al, 8
 jnz	 short waitvr
loc_448:
 in	 al, dx
 and	 al, 8
 jz	 short loc_448

 mov bp,80*2*50
 xor di,di
m4:

 mov ax,[es:di]
 add al,2+1
 cmp al,$7F+1
 jbe m3
  sub al,$7F

 mov ah,[cs:di+bp]
 inc ah

 and ah,1
 mov [cs:di+bp],ah
 mov bx,ax
 mov ah,[cs:bx+font]
m3:
 stosw
 cmp di, bp;80*2*50
 jne m4
 in al,60h
 dec al
 jne m5
 mov ax,3
 int 10h
 ret
; jmp m5
MATRIX:
	DB    1,33,9,41,3,35,11,43
	DB    49,17,57,25,51,19,59,27
	DB    13,45,5,37,15,47,7,39
	DB    61,29,53,21,63,31,55,23
	DB    4,36,12,44,2,34,10,42
	DB    52,20,60,28,50,18,58,26
	DB    16,48,8,40,14,46,6,38
	DB    64,32,56,24,62,30,54,22
font: