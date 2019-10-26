
; Lazy effect by a lazy coder :P

; By The VaW ^ HeXeTeR / CensosiS  (c) nov01

; NOTE:
; code is not optimized for size nor velocity, is just a crap!
; I know that some calculations are done and not used or done iside the loop
; when it shouldn't be but I'm almost at deadline and too much laziness to fix it.

ORG 100h

SECTION .text

intro:

mov		al,13h
int 	10h

mov		ax, 0x0a000
mov		es,ax



; inicializo la textura
textura:

mov		si, imagen


mov		cx, 128*128+128

xor		bx, bx

.rellena

	;in		al,20h
	mov		ax,cx
	mov		ah,al
	and		ah,01111111b
	;sub		ah,32
	shr		al, 4
	and		al, 1
	xor		al, bl
	
	
	not		ah
	shr		ah,1
	add		ah,16*3
	neg		al
	and		al, ah		
	xchg		al, ah
	in		al, 40h
	shr		al, 1
	and		al, 1
	add		al, ah
	mov		[ds:si], al
	inc		si
	
	
.noline:

	test	cx, 011111111111b
	jnz		.nonextch
	
		xor		bl,1
	
.nonextch:
	

loop	.rellena

finit

mainloop:

mov		word [ftmp], 256
fild	word [ftmp]
fldpi
fdivp	st1, st0
fstp	dword [rad2ang]


xor		di, di
mov		si, imagen
inc		si
mov 	cx,200

seno:

	add		dx,	cx
	mov		[ftmp], edx
	sub		dx, cx
	fild	word [ftmp]
	fld		dword [rad2ang]	
	fdivp	st1, st0
	fsin

	
	mov		word [ftmp], 256
	fild	word [ftmp]
	fmulp	st1
	
	fild	word [ftmp]
	faddp	st1
	fistp	word [ftmp]

	mov	bx, [ftmp]
	
	push	di
	push	si
	push	cx
					
		push	ax
		push	dx
		push	bp
		
		xor		dx, dx
		
		mov		bp, bx
		shr		bp, 1
		add		di, bp
						
		mov		cx, 320
	
				
.lineazoom:		
		
		mov		bp, dx
		shr		bp, 8
		and		bp, 1111111b
		mov		al, [si+bp]
			
		mov		[es:di], al
		
		add		dx, bx
		inc		di

		loop 	.lineazoom
		
		
		pop		bp
		pop		dx
		pop		ax
		
		
	pop		cx
	pop		si
	pop		di
	
	add		si, 128
	cmp		cl, 200-127
	jne		.no128
	
	sub		si, 128*128
	
.no128:
	
	add		di,320


loop seno


inc 	dx

mov		ah, 0x0b
int		21h

cmp		al,0xff
je		nomainloop

jmp		mainloop

nomainloop:

mov al,3
int 10h

int		20h



rad2ang	dd 0x41a2f983

SECTION .bss


ftmp	resd 1
ftmpq	resq 1

imagen resb 128*128
	
	




