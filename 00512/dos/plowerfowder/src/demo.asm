; the actual demo
; public domain.
; by thefox <fuchs@runkkaajat.org> 2004

	.model tiny, stdcall
	.386
	.code
	
	option casemap: none
	org 2190h
	
; a handy macro for relative indexing

reloff macro var
	local retval

	retval textequ <(type var) ptr [bp + (offset var - offset variables)]>

	exitm retval
endm

start:
	mov al, 13h
	int 10h					; 320x200

	push ds
	pop ax
	add ax, 1000h
	push ax
	pop es					; es = 64k buffer

	mov bp, variables			; for small variable indexing

	fldz
	fldz

main_loop:
	xor ax, ax
	mov di, ax
	mov cx, ax
	dec cx
	rep stosb				; clear double buffer

	mov cx, reloff(huorra)

	fld st(1)

	ficom reloff(_1)
	fnstsw ax
	test ah, 65
	jnz @f
	fstp st(0)
	fld1
@@:
	fld st(1)
	fmul reloff(_6_865879)
	fsin
	fld1
	fadd
	fmul reloff(_0_01)
	fadd reloff(_0_65)
	fstp reloff(kikkeli)

	fldz

render_all:
	fld st(0)				; here starts the magic
	fadd st(0), st(3)
	fld st(1)

	fimul reloff(srcc)
	fsin
	fld1
	fld st(4)
	fsub
	fmul
	fld st(2)
	fimul reloff(dstc)
	fsin
	fld st(4)
	fmul
	fadd
	fmul reloff(_0_5)
	fadd reloff(kikkeli)

	fxch
	fsincos

	fmul st, st(2)
	fimul reloff(SIZEX)
	fistp reloff(x)
	fmul
	fimul reloff(SIZEY)
	fistp reloff(y)

	mov ax, reloff(y)

hline:
	mov dx, 320
	mul dx
	mov di, ax				; di = y * 320

	mov bx, 6

	add di, reloff(x)
	add di, 320 * 100 + 160
	lea si, [di - 320 * 2 - 2]

draw_more:
	mov al, 15				; white
	stosb

	mov al, es:[si]
	test al, al
	jnz @f
	mov al, 9				; blue
	mov es:[si], al
	mov es:[si + 320 + 1], al
@@:

	inc si
	dec bx
	jnz draw_more				; draw six pixels

	fadd reloff(CSTEP)

	dec cx
	jnz render_all				; draw all the "strips"

	fstp st(0)
	fstp st(0)

	fsub reloff(_0_01)
	fsub reloff(_0_01)

	fxch
	fadd reloff(_0_01)

	ficom reloff(_2)
	fnstsw ax
	test ah, 65
	jnz @f

	mov ax, reloff(dstc)
	mov reloff(srcc), ax
	inc ax
	and ax, 7
	mov reloff(dstc), ax

	fstp st(0)
	fldz
@@:
	fxch

	add reloff(huorra), 5
	cmp reloff(huorra), 2048
	jna @f
	mov reloff(huorra), 2048
@@:

	push ds
	push es

	push es
	pop ds
	push 0a000h
	pop es

	mov dx, 3dah				; vsync
@@:
	in al, dx
	test al, 8
	jnz @b
@@:
	in al, dx
	test al, 8
	jz @b

	mov cx, 320*200/4			; flip
	xor si, si
	mov di, si
	rep movsd

	pop es
	pop ds

	in al, 60h				; esc pressed?
	dec al
	jnz main_loop

	; we could clean fpu stack here but who cares :-)

	mov ax, 3				; back to text mode
	int 10h

	ret

variables:

srcc		word	0			; source cycles
dstc		word	4			; destination cycles
SIZEX		word	120			; x size factor
SIZEY		word	60			; y size factor
_2		word	2
_1		word	1
huorra		word	1			; amount of "strips" to draw

_6_865879	real4	6.865879		; some randomish value :-)
_0_5		real4	0.5
_0_65		real4	0.65
_0_01		real4	0.01
CSTEP		real4	0.003067961575		; 1 / 2048 * PI * 2

; these eight bytes can be stripped out after linking

kikkeli		real4	0.0
x		word	0
y		word	0

end start