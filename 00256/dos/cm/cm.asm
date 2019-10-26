USE16
CPU P4
;; vars

org 100h
	xor bl, bl      ; Inhalt löschen
	mov ax,  1112h  ; 80x50
	int  10h

	push 0xb800
	pop es
start:

	mov di,bx
	add di,bx
	and di,8191
	es mov ax,[di]
	and ax,63
	imul ax,ax,3
	shr ax,1
	add al,36
	stosb
	inc bx
	mov si,bx
	add bx,si
	add bx,si
	rol bx,8
	
	pusha
	
	xor di,di
	mov cx,80*50
circle:
	xor dx,dx
	mov ax,di
	mov bx,160
	div bx
	shr dx,1
	sub dx,word[x]
	sub ax,word[y]
	imul ax,ax
	imul dx,dx
	add ax,dx
	cmp ax,[r2]
	jg skip
	xor al,al
	mov si,word[color_idx]
	add si,colors
	mov ah,byte[si]
	es mov [di],ax
skip:
	add di,2
	loop circle
	
	sub byte[cnt],10
	ja nomove

	dec word[cnt4]
	jnz skipcnt4
	mov byte[cnt4+1],2
	mov byte[fx-1],255
skipcnt4:
	
	
	mov bx,x
	mov dx,80
	call move
	mov bx,r2
	call move
	mov bx,y
	mov dx,49
	call move

	sub byte[cnt2],255
fx:
	ja nomove
	
	mov bx,color_idx
	mov dx,5
	call move

	add word[cnt3],49
	jno nomove
nextfx:
	xor byte[fx-1],255^15
	
	nomove:	
	popa
	in al,60h
	dec al
	jnz start
	ret

move:	
	mov ax,word[bx]
	add ax,word[bx+2]
	mov word[bx],ax
	cmp ax,dx
	jl nobounce_1
	neg word[bx+2]
nobounce_1:
	cmp ax,0
	jnl nobounce_2
	neg word[bx+2]
nobounce_2:
	ret
		db 0
colors:	db 8,7,15,14,6,4
x:	dw 0
d_x:	dw 1
y:	dw 0
d_y:	dw 1
r2:	dw 0
d_r2:	dw 1
color_idx: dw 0
d_color_idx: dw 1
cnt4: dw 512
cnt: db 0
cnt2: db 0
cnt3: dw 0
