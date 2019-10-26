 org 100h
 use16

 mov al,13h
 int 10h

; push 0A000h
; pop es
les di,[bx] ;Sweet little trick that loads 0a000h

;xor di,di

drlp1:
; mov di,16
 inc bx
drlp:
		xor	dx, dx
		mov	ax, di
		mov	cx, 140h
		div	cx
;c.a=(x!y)!(x+y+b)
 mov cx,ax
 add cx,dx
 add cx,bx
 
 xor ax,dx
 xor ax,cx
 
 ;mov al,ah
 cmp al,127
 jbe skipp
 xor al,al
skipp:
 stosb
 or di,di
 jne drlp
 in al,60h
 dec al
 jne drlp1
 ret