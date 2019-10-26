;cubeland
;64 byte intro
;
;by frag
;http://fsqrt.blogspot.com/
;pzagrebin@gmail.com
;20-11-2011

;Ray casting in 64 bytes!

org 100h
	mov al, 13h
	int 10h
	push 0a000h
	pop es
	mov si, 320
	mov dx, 3c9h	;Make grayscale palette.
P:	shrd ax, cx, 9
	out dx, al
	out dx, al
	out dx, al
	loop P
	
L:	mov cl, 255	;cx goes from 255 to 1.
			;255 is a maximum view distance.
TRACE:	mov bl, cl	;bx = z, distance
	not bl		;bx goes from 1 to 255
	mov ax, di
	xor dx, dx
	div si		;ax = y, dx = x
			;Trace ray, for each distance bx find point (x, y, z).
	imul dx, bx	;dh = x * R / 256
	mul bl		;ah = y * R / 256

	add dx, bp	;Diagonal movement of camera point.
	add ax, bp

			;Check if (x, y, z) point is in cube or not.
	and ah, bl
	and ah, dh
	and ah, 32	;If (x AND y AND z AND 32 == 32) then it is.
	loopz TRACE	;Loop until ray reach nearest cube.
			;Then negative cl is a rough distance 
			;from camera to the cube surface.
	mov ax, cx	;Express distance as color.
	stosb
	test di, di
	jnz L
	add bp, si	;Every frame camera point moves by 320/256 pixel.
	jmp L
			;Enjoy!


