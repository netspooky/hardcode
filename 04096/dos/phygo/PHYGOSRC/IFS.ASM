preframe_ifs:	; x ja y rotatoidusta verteksidatasta.
		; zoom ja rot pyörimään kuten resonaattoridatat

render_ifs:
	; ifsparms == 4 points with zoom16,x16,y16,rot8,pad0

	mov si,rotated_vertices
	mov di,ifsparms+2
	mov cx,4
.l9:	movsw
	movsw
	add si,4
	add di,4
	loop .l9

	mov bx,[ifsparms+2]
	mov si,[ifsparms+4]
	mov di,random_table

	mov cx,2000

.l0:	push di
	mov di,[di]
	and di,31-7
	add di,ifsparms

	push si
	sub si,[di+2]	; x
	sar si,1

	push bx	
	sub bx,[di+4]
	sar bx,1

	call rotopart

	pop ax
	add bx,ax

	pop ax
	add si,ax

	mov ax,si
	mov al,bh

	mov di,ax
	mov al,0x7f
	stosb		; dec [di] ?
	stosb
	mov al,0x70
	stosb

.o0:	pop di
	inc di

	loop .l0
	ret

MU equ 256

ifsparms:	; muualle, ei koodiin
	dw 128-60,  128*MU,50*MU,   0
	dw 128+60,  96*MU,160*MU,   0
	dw 128+5,   192*MU,150*MU,  0
	dw 128-5,   128*MU,128*MU,  0
