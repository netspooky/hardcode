;opracowano dzieki wiedzy z ksi¹¿ki asembler nie tylko ...
ASSUME CS:CODE
CODE SEGMENT
org 100h
start:
jmp poczatek
;;
status dw ?
sa dd -2e0
sb dd -1e0
a dd 0e0
b dd 0e0
dda dd 1e-2
ddb dd 1e-2
x dd 0e0
y dd 0e0
xn dd 0e0
yn dd 0e0
ilex equ 320
iley equ 200
len dd 6.4e1
;;
poczatek:
	finit
	mov dx,0a000h
	mov ds,dx
	call tryb13h
	mov cx,iley
	fld sb
	fstp b
	mov di,0
pion:
	push cx
	mov cx,ilex
	fld sa
	fstp a
	mov bx,0
poziom:
	call iter
	fld a
	fadd dda
	fstp a
	inc bx
	loop poziom
	pop cx
	fld b
	fadd ddb
	fstp b
	add di,320
	loop pion
	mov ah,10h
	int 16h
	mov ax,3
	int 10h
	mov ax,4c01h
	int 21h
;;
iter PROC
	fldz
	fstp x
	fldz
	fstp y
skok:
	fld x
	fmul x
	fld y
	fmul y
	fsubp st(1),st
	fadd a
	fstp xn
	fld x
	fmul y
	fadd st(0),st
	fadd b
	fstp yn
	fld xn
	fabs
	fld yn
	fabs
	faddp st(1),st
	fcomp len
	fstsw status
	mov ah,byte ptr status[1]
	sahf
	jng koniec
	inc byte ptr ds:[bx][di]
	js koniec
	fld xn
	fstp x
	fld yn
	fstp y
	jmp skok
koniec:
	ret
ENDP
;;
tryb13h PROC
	mov ax,13h
	int 10h
	ret
ENDP
CODE ENDS
END start