BUFFER_VRAM EQU 09000h
SCREEN_VRAM EQU 0A000h

FRAME EQU 32
STORE EQU 0
CIRCLE EQU 64



org 100h
	mov al,13h
	int 10h

main:
	push word BUFFER_VRAM
	pop es

	call cls

	push cs
	pop ds

part2:
	mov si,variables


	mov bx,3
many_circles:
	push bx

	push word [si+FRAME]
	fild word [esp] ; st(0) = frame
	pop dx
	add bx,bx

	fidiv word [si+bx] ;st(0) = frame / 160
	fsin		  ;st(0) = sin(frame / 160)
	fimul word [si+bx+2] ;st(0) = sin(frame / 160) * 100
	fistp word [si+STORE]
	mov dx,[si+bx+2]
	add dx,dx
	add dx,[si+STORE]

	mov [si+CIRCLE],bl
	call draw_circle

	pop bx
	dec bx
jnz many_circles

	inc word [si+FRAME]
	call eorfill

MOV DX,3DAh
Vsync1:
	IN	AL,DX
	AND	AL,8
	JZ	Vsync1
;Vsync2:
;        IN      AL,DX
;        AND     AL,8
;        JNZ     Vsync2

	call copyscreen

	in al,60h
	dec al
	jnz main

	mov ax,03h
	int 10h
ret

put_pixel:
	;di = x
	;bx = y
	;ch = color

	mov ax,bx
	shl bx,6
	shl ax,8
	add bx,ax

	mov al,[es:di+bx]
	xor al,ch
	mov [es:di+bx],al

;        mov al,ch
;        mov byte [es:di+bx],al
ret

;y = sqrt(r^2 - x^2)
;dx = radius, di,160 = x, y?
draw_circle:
	push dx
	fild word [esp] ; st(0) = radius
	fmul st0,st0	; st(0) = radius^2
	pop dx

	mov cx,dx
	neg cx
	inc cx
	mov di,[si]
	sub di,dx
circle_x:
	push cx
	fild word [esp] ; st(0) = x, st(1) = radius^2
	fmul st0,st0	; st(0) = x^2, st(1) = radius^2
	pop cx

	fsubr st0,st1	; st(0) = radius^2 - x^2, st(1) = radius^2
	fsqrt		; st(0) = sqrt(radius^2 - x^2), st(1) = radius^2

	fistp word [si+STORE] ; st(0) = radius^2

	push cx

	; color selection

	mov ch,1
	mov cl,[si+CIRCLE]
	shl ch,cl
	add ch,[si+FRAME+1]

	mov bx,[si+STORE]
	push bx
	add bx,100
	sub bx,dx
	call put_pixel

	pop bx
	neg bx
	add bx,100
	sub bx,dx
	call put_pixel

	pop cx
	inc di

	inc cx
	cmp cx,dx
	jnz circle_x

	fistp word [si+STORE]
ret


cls:
	mov cx,80
	xor di,di
;        mov eax,0x07070707
xor eax,eax
	rep stosd

	mov cx,16000-80
	xor eax,eax
	rep stosd
ret

eorfill:
	mov di,320
	mov bx,64000 - 320
eorloop:
	mov al,[es:di]
chose3:
	xor al,[es:di-320]
	mov [es:di],al
	inc di
	dec bx
	jnz eorloop
ret

copyscreen:
	xor di,di
	xor si,si
	push word BUFFER_VRAM
	pop ds
	push word SCREEN_VRAM
	pop es
	mov cx,16000
	rep movsd
ret

variables:
dw 60,25
dw 80,35
dw 90,30
dw 65,45
