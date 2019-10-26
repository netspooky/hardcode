;knot
;128 byte intro
;
;by frag
;http://fsqrt.blogspot.com/
;pzagrebin@gmail.com
;13-02-12

;Simple z-buffer-based rendering technique.
;Enjoy!


org 100h
	push 0a000h
	pop es
	mov al, 13h
	int 10h
	mov bp, sp

	salc			;al = 0 or 255
	mov dx, 3c9h
PAL:	inc ax
	out dx, al
	out dx, al
	out dx, al
	loop PAL
	fild word [si]		;si = 256, word [si] = 104, ring radius
	mov ah, 90h
	mov ds, ax		;z-buffer

L:				;cx = angle1
	mov si, cx
	shr si, 1		;cx/2 = angle2
	mov ax, cx
	and ax, 31		;ax = r
	mov di, 128
	pusha
	fild word [bp-4]
	fidiv word [bp-16]
	fild word [bp-14]
	fiadd word [bp-6]
	fidiv word [bp-16]
	fsincos
	fxch st2
	fsincos
	fild word [bp-2]
	fmul st1, st0
	fmulp st2, st0
	fadd st0, st4
	fmul st3, st0
	fmulp st2, st0
	fistp word [bp-16]	;Y -> di
	fistp word [bp-2]	;Z -> ax
	fistp word [bp-8]	;X -> bx
	popa
	sar ax, 2
	add di, ax		;fake perspective
	imul di, 320
	lea di, [di+bx+100*320+160]
	add al, 29		;color correction
R:	cmp al, [di]
	jl Z
	mov [di], al
Z:	add di, 320
	neg si
	js R			;place two points
	loop L
	inc dx

COPY:	xor ax, ax		;clean and copy buffer
	xchg al, [di]
	stosb
	loop COPY

	in al, 60h
	dec ax
	jnz L
	ret

