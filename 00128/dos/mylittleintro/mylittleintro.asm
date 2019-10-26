%define mem 0
%define ant_dir mem+0
%define var(x) [bx+x]
;mov var(ant_dir),ax

org 100h

init:

	;screenmode
	mov ax,13h
	int 10h
	push 0a000h
	pop es
	
	;mov ax,160
	;mov var(x),ax
	;mov ax,100
	;mov var(y),ax


	;init pc speaker
	in al,0x61
	or al,3
	out 0x61,al
	
reset:


	;reset frame counter;
	xor bp,bp

	; render logic`
	mov cx,200
	mov di, 0
	mov al, 15
filly:
	push cx
	mov ah,cl
	mov cx,320
fillx:
	mov al,ah
	xor al,cl
	stosb
	loop fillx
	pop cx
	loop filly

main:
	;setup palette registers
	mov dx,0x03c8
	mov al,0
	out dx,al
	inc dx
	; init palette logic
	mov ax,bp
	mov cx, 255*3;
	
ploop:
	; palette fuction
	out dx,al
	mov ax,bp
	cmp al,cl
	je yep
	
	mov al,0
	jmp finally
	yep:
	mov al,63
	
	finally:
	loop ploop;

	
	
	
	
	;vsync
	mov dx, 03dah
	mov ah, 0x08
vsync_poll:
	in al,dx
	test al,ah
	jz vsync_poll
	
	;sound
	mov dx, 0x42
	mov ax, bp
	
	out dx, ax
	
	;inc frame variable
	inc bp

keyboard_test:
	in al,60h
	dec al
	jnz main
	ret
	