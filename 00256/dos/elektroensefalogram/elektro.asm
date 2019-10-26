; Elektroensefalogram
; by Anesthetic, 2007
;
; Use NASM to assemble.

		org		0x0100
		
INIT	mov		ax,0x0013
		int		0x10		
		push	word 0xa000
		pop		es
		
		finit
		fldz						; time = 0
		
		in		al,0x40
		mov		byte [COLOR],al		; color = rand()

MAIN	call	PAL					; createPalette(color)
		mov		bh,250				; index = 320*200
		fadd	dword [STEP]		; time += step
		
.fill	mov		ax,bx
		
		dec		ax
		xor		dx,dx
		mov		cx,320
		div		cx
		
		call	GRABC				; y = (index / 320) / C2
		fadd	ST1					; y += time // to scroll down
		mov		ax,dx
		call	GRABC				; x = (index % 320) / C2
		
		mov		si,SET1				; Distort coordinates below
		call	OFFS				; x += cos(time + x*set1[1]) + sin(y - time*set1[2])
		fxch
		mov		si,SET2
		call	OFFS				; y += cos(time + y*set2[1]) + sin(x - time*set2[2])
		
		fsin						; Plazma below
		fxch
		fcos
		faddp	ST1,ST0
		fimul	word [C1]
		fadd	ST1
		fcos
		fimul	word [C2]
		fiadd	word [C2]
		fistp	word [COOR]			; val = cos((cos(x) + sin(y)) * C1 + time) * C2 + C2 ;
		
		mov		al,[COOR]

		mov		[SECOND+bx-1],al	; buffer2[index-1] = val
		dec		bx					; index -= 1

		jnz		.fill				; if index > 0 continue filling frame
		
		mov		bh,250				; index1 = 320 * 200
		xor		si,si				; index2 = 0
.fill2	mov		al,[SECOND+bx-1]
		mov		ah,[SECOND+si]
		shr		ah,2				; Blend x and y mirror with current pixel
		add		al,ah
		mov		[es:si],al			; buffer[index1] = buffer2[index1] + buffer2[index2] / 4
		dec		bx					; index1 -= 1
		inc		si					; index2 += 1
		jnz		.fill2
		
.input	in		al,0x60
		cmp		al,57
		jne		.check				; Check for space key
		inc		word[COLOR]
.check	dec		al
		jnz		MAIN				; Check for escape key
		
EXIT	mov		al,0x03
		int		0x10
		ret							; I know it could be fall through, who cares?

GRABC	mov		[COOR],ax			; Normalize coordinates
		fild	word [COOR]
		fidiv	word [C2]
		ret

OFFS	fld		ST1					; Coordinate distortion, addition of two cosines
		fidiv	word [si]
		fadd	ST3
		fcos
		faddp	ST1,ST0
		fld		ST2
		fidiv	word [si+2]
		fadd	ST2
		fsin
		faddp	ST1,ST0
		ret

PAL		mov		cx,64				; Palette function
.pstart	mov		dx,0x03c8
		mov		al,cl
		out		dx,al
		inc		dx
		mov		bx,[COLOR]
		call	PALS				; R
		call	PALS				; G
		call	PALS				; B
		loop	.pstart
		ret
		
PALS	mov		al,cl
		shr		bx,1
		jnc		.pals				; channel(i) = min(i*3/2, 63)
		mov		ah,3
		mul		ah
		shr		al,1
		cmp		al,63
		jl		.pals
		mov		al,63				; or channel(i) = i, depending on current color
.pals	out		dx,al
		ret
	
COOR	dw		0
COLOR	db		0
STEP	dd		0.08
SET1	dw		4
		dw		3
C1
SET2	dw		9
		dw		1
C2		dw		25

SECOND

		db		"16b's of freedom"
