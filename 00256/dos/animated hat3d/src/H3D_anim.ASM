; H3D.ASM

.model tiny
.code
.386
  
org	100h
  
start:

		mov	ax,13h
		int	10h

		push 0a000h
		pop es
		push 7000h
		pop fs

main_loop:

		mov	dx,-64
_For3:
		mov	ax,64
		cmp	ax,dx
		jl	_Next4
		;		movsx	eax,dx
		;		mov	[bp],eax
		;		fild	dword ptr [bp]
		;		fimul	dword ptr [bp]
mov word ptr [bp],dx
fild word ptr [bp]		;zi
		;		fimul word ptr [bp]
fmul st,st
		fmul	F1		;zs
		fst	dword ptr [bp-20h]
		fild	D1
		fsubr
		fsqrt
		fistp	word ptr [bp]
		mov	ax,[bp]
		mov	cx,ax
		neg	ax
		mov	si,ax
_For5:
		movsx	eax,cx
		cmp	ax,si
		jl	_Next6
;		movsx	eax,si
;		mov	dword ptr [esp-4],eax
;		fild	dword ptr [esp-4]
mov [bp],si
fild word ptr [bp]
;		mov	[bp],eax
;		fimul	dword ptr [bp]
fmul st,st
		fadd	dword ptr [bp-20h]
		fsqrt
		fmul	v_XF
			;fstp	v_XT
			;fld	v_XT
			;fsin
			;fld	v_XT
		fld st
		fsin
		fxch

		fimul	F3
		fsin
		fmul	F4

		faddp	st(1),st
		fimul	F5		;yy
		mov	bx,si		;xi
		add	bx,dx		;xi+zi
		add	bx,160	;C160		;x1=xi+zi+160
		fchs				;-yy

		fiadd	F6			;90-yy
				;	add	dword ptr [bp]	;zi
fld t
fsincos

;		movsx	eax,dx		;zi
;		mov	[bp],eax
;		fild dword ptr [bp]	

mov [bp],dx			;zi
fild word ptr [bp]

fmul
fxch
	;movsx	eax,si		;xi
	;mov	[bp],eax
mov [bp],si			;xi
fild word ptr [bp]	;xi
fmul
fmul F4
fadd
fadd
fistp	word ptr [bp]			;y1=90-yy+zi*cos(t)+xi*sin(t)*0.4
	;mov	di,C160
	;add	di,di
		mov di,320
		push	di
		imul	di,[bp]
		add	di,bx
		pop	bx

;		mov	al,4
mov al,64
sub al,dl
shr al,1
add al,32

linelp:
		mov	fs:[di],al
		xor	al,al
		add	di,bx		;+320
		jnc	linelp

		inc	si
		jno	_For5
_Next6:
		inc	dx
		jno	_For3
_Next4:

xor di,di
mov	ch,320*100/256
copyclear:
xor ax,ax
xchg ax, fs:[di]
stosw
loop	copyclear

fld t
fadd v_XF
fstp t

	in al, 60h
	dec al
	jnz main_loop

	retn

;		xor ax, ax
;		int 16h
;		int	20h

F1		dd	5.0625		
v_XF		dd	0.03272492438555		
C160		dw	160
F3		dw	3
F4		dd	0.4			
F5		dw	56			
F6		dw	90			
D1		dw	20736
t		dd	0.0
;v_XT		dd	?
  
end	start
