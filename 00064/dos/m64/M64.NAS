	ORG	100h

DRAW:
	mov al,13h
	int 10h
;	push word 0A000h
;	pop es
	les bp,[bx]
	fninit
;	mov si,100h	; a benti gepeken suxik :(

frame:
;	xor di,di
	fldl2e		; Y=1.4427
NCIKL:
	mov cx,320
	fld1		; X=1.0	-> ln2!!!

MCIKL:
	fld st0		; YXA
	fld st2		; YXAB
;	mov dh,255	; eziskivesz -> lassu, de -2byte!

ITCIK:
	mov bl,GX-103h+2
innest:
	fld st1		; YXABA		a'=a	[a*a-b*b+x]
	fmul st0	; YXABa		*a
	dec bx
	jpo innest	; ez itten a 2es ciklus - bx kilepesi erteke jo lent!

	fcom dword [si]	; ez a lite bailout!
	fnstsw ax

	fsubp st1	; YXABs		a*a-b*b
	fadd st3	; YXABs		+x
	fxch st2	; YXsBA		a=a'  &  b'=a

	fmulp st1	; YXABM		*b
	fadd st0	; YXAM		*2
	fadd st3	; YXAB		+y

	sahf		; bailout ellenorzes
	inc dx		; atengedi carryt, es ez a fo!
	ja short ITCIK	; carry+zero check (legalabbis azt hiszem=)
kirajz:
	xchg ax,dx
	stosb
	fcompp				; YX
	fsub dword [si+bx]		; YX	na ezt kapja a 2s ciklusbol!
	loop MCIKL

	fstp st0			; Y
	fsub dword [si+bx]		; Y

	jc short NCIKL		; carry a sahf-tol kezdve nem ha inside pixel!
				; so: kilepes ha a sor utolso pixele fekete...

;	mov ah,0
;	int 16h
;	mov ax,3
;	int 10h

	ret

; -------------------------------------------------------------------------

section .data align=1

;	XS	DW	0C000h
;	YS	DW	0BFC0h
;	GX	DW	3C4Dh
;	GY	DW	3C75h
;	XS db 0xC0
;	YS db 0xBF
	GX db 0x3B
;	GY db 0x3C
