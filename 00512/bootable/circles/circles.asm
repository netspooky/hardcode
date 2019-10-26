; by zer0`` for efnet #asm compo in feb 2004
; assemble with nasm

org 0h

cli
; alter segments
mov     ax, 0x07C0
mov     ds, ax
mov     fs, ax
mov     gs, ax	

;stack
mov     sp, 0xFFFF
mov     ax, 0x0000
mov     ss, ax

mov ax, 0a000h	;
mov es, ax	;video seg

mov [i], BYTE 8

mov ax, 13h	;300*220*256
int 10h		;change vid mode

; might as well use the default palette

mov [xoffset], WORD 100
mov [yoffset], WORD 100


	mov cx, 720
	spinplz:
		
		push cx
		mov cx, 10
		newcirc:

		mov ax, cx
		mov bx, 6				; circles are 6 pixels apart
		mul bx
		mov [radius], ax

		push cx
			mov cx, 720
			again:
				mov [angle], cx
				fild WORD [angle]	;push angle onto fpu stack
				fdiv DWORD [conv1]
				fdiv DWORD [conv2]
				fsincos			;st(1) = sin(angle), st(0) = cos(angle)
				fimul WORD [radius]	;st(0) *= radius
				fistp WORD [y]		;y = st(0)
				fimul WORD [radius]	;st(0) *= radius
				fistp WORD [x]		;x = st(0)

				mov ax, [yoffset]	;
				add ax, [y]		;
				mov bx, 140h		;
				mul bx			; ax *= bx
				add ax, [xoffset]	;
				add ax, [x]		; 
				mov si, ax		; si = offset of the point to be plotted

				mov dx, cx
				add dx, [spin]		; so the circles rotate over time
				add dx, [radius]	; so the circles dont spin together
				mov [es:si], dl
			loop again

		pop cx
		loop newcirc

	pop cx
	mov [spin], cx
	loop spinplz

mov ax, 0h
int 16h					; getch

mov ax, 3h
int 10h

int 19h

i db 0
x dw 0
y dw 0
xoffset dw 0
yoffset dw 0
angle dw 0
radius dw 30
conv1 dd 2.0
conv2 dd 57.2957795
spin dw 0

times 510-($-$$) db 0		; fill with 0's
dw 0AA55h