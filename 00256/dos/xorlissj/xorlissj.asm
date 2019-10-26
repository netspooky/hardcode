; xorlissj.asm - 2016.09.20 - ern0@linkbroker.hu
; XOR pattern and Lissajous pattern 2-in-1
; 256 byte intro for MS-DOS (compiler: nasm)
; Released at Demobit 2017 sceneparty
;
; Not the best 256b intro so far, but it was
; fun to coding something for 8086 again
; 
; Thanks for Tomcat/Abaddon for the support
; and inspiration (check his 256b intros)

	org 100H

box equ 128+6
top equ (200-box)/2-4
bottom equ 200-top
left equ (320-box)/2
right equ 320-left
modulo equ 320-(left)-(right)

flop:
	mov al,13H
	int 10H

	push 0a000H
	pop es

color:
	mov cx,0
	mov bl,10H

xframe:
	xor di,di

xpix:
	xor dx,dx
	mov ax,di
	mov bp,320
	div bp

	inc cx
	;cmp cx,320*20
	cmp ch,25
	jne nega
	neg word [flip]
	mov cx,[flip]
	xor cx,cx

nega:
	cmp ax,top
	jb draw
	cmp ax,bottom-4
	ja draw
	cmp dx,left
	jb draw
	cmp dx,right
	ja draw

	xor ax,ax
	inc di
	jmp short epix

draw:
	add ax,[flip]
	xor al,dl
	ror al,4
	and al,0eH

dpix:
	stosb

epix:
	cmp di,320*201 ; magic
	jne xpix

lissajous:
	mov bp,[1+color]
	add bp,0101H
	and bp,1f1fH
	mov [1+color],bp
	mov ch,0

xcirc:
	mov al,bl
	xor ah,ah
	mov si,ax
	mov al,[sintab + si]
	mov si,320
	mul si
	mov di,ax

	mov al,bh
	xor ah,ah
	mov si,ax
	mov al,[sintab + si]
	add di,ax

	add di,(320*(top))+left

	mov ax,bp
	mov dl,13
xbigdot:
	stosw
	stosw
	stosw
	stosw
	add di,320-8
	dec dx
	jne xbigdot

fig:
	add bx,01feH
	and bx,3f3fH
	loop xcirc

eframe:
	inc word [flip]
	inc byte [1+flop]
	jnz vb
	not byte [3 + fig]

vb:
	mov dx,3daH
	in al,dx
	test al,8
	jz vb

qframe:
	in al,60H
	cmp al,1
	jne xframe

qapp:
	retn

sintab:
	db 64,70,76,82,88,93,99,104,108,113,116
	db 120,122,124,126,127,127,127,126,124,122,120
	db 116,113,108,104,99,93,88,82,76,70,64
	db 57,51,45,39,34,28,23,19,14,11,7
	db 5,3,1,0,0,0,1,3,5,7,11
	db 14,19,23,28,34,39,45,51,57,64

flip:
