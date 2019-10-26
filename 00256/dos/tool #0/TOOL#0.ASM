;copyleft 		Mr. False 		copyright
.model tiny
.386
.387
.code
org 100h


start:
;set es to video segment
	mov	ax, 0b800h
	mov	es, ax
	jmp	@@resm

;fill plasma maps
CalcPlasm	proc
	finit
	fild 	col
	fldpi
	fild	nx
	fmul	ST, ST(1)
	fild	maxx
	fdiv	ST(1), ST	;ST(1) = nx*pi/maxx
	fild	ny
	fmul	ST, ST(3)
	fild	maxy
	fdiv	ST(1), ST	;ST(1) = py = ny*pi/maxy

	fxch	ST(3)		;ST(0) = px 
;get px,py coeffs
	mov 	y, 0
@@y_lp:
	mov	x, 0
	fild 	y
	fmul	ST, ST(2)
	fsin			;ST(0) = sin(py*y)
	fmul	ST, ST(5)	;ST(0) = ysin
@@x_lp:
;loop Body
	fild	x
	fmul	ST, ST(2)
	fsin	
	fmul	ST, ST(6)
	fadd	ST, ST(1)
	fistp	col
	mov	ax, col
	mov	[di], al
	inc	di
	inc	x
	cmp	x, maxxE
	jne	@@x_lp
	fistp	col
	inc	y
	cmp	y, maxyE
	jne	@@y_lp
	ret
CalcPlasm	endp

;precalculate

@@resm:
	lea	di, map1
	call	CalcPlasm
	lea	di, map2
	mov	nx, 3
	mov	ny, 5
	mov	col, maxcolor
	call	CalcPlasm


;Do it
	mov	a, 0
@@al_lp:
	mov	cx, max
	mov	di, a
	xor	si, si
@@s_loop:
	mov	al, [si+offset map1]
	add	al, [di+offset map2]
	mov	bx, cx
	shl	bx, 1
	add	al, 43
	mov	es:[bx], al
	sub	al, 42
	and	ax, 00001111b
	mov	es:[bx+1], al
	inc	di
	cmp	di, max
	jb	@@inc_si
	sub	di, max
@@inc_si:
	inc	si
	loop	@@s_loop
	inc	a
	
	mov	ecx, 65535
@@delay:
	loop	@@delay

;read key
	mov	dx, 60h
	in	al, dx
	cmp	al, 1
	jne	@@al_lp
	ret

;Some data
maxxE equ 80
maxyE equ 50
max equ maxxE*maxyE
maxcolor equ 32
col dw maxcolor
maxx dw maxxE
maxy dw	maxyE
nx dw 7
ny dw 5
x dw ?
y dw ?
a dw ?
map1 db max dup(?)
map2 db max dup(?)
end start