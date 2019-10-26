; textured fraktal tunnel
; eviL/Syn[Rj] ^ Surprise! Productions ^ Scoopex 2003
org		100h
start:
		mov	AL, 13h		; move AL to offset 13h
		clc			; clear carry flag - clears CF in EFLAGS register
		inc	DX		; DX=DX+1 (CF is not affected)
		int	10h		; call to interrupt procedure (call video)
		push	word 0a000h	; push word onto stack
		pop	ES		; pop the value from ES

tunnel:
		mul	BX		; unsigned multiply BX
		inc	AX		; AX=AX+1
		add	AX, DI		; add DI to AX
		adc	[si], BX	; add with carry (rotation of tunnel)
		div	word [si+12]	; unsigned divide DX:AX by word[si+12], result stored in AX (quotient), DX (remainder)
moveit:
		fmul	dword [si]	; multiply ST(0) by dword[si] and store result in ST(0)
		fisub	word [si]	; add word[si] to ST(0) and store result in ST(0)
		fistp	word [bx]	; converts the value in ST(0) register to a signed integer, stores the result in a destination operand and then pops the register stack
		xchg	AX, word [bx]	; exchange register BX with AX
		and	CX, AX		; AX=AX AND CX
		fild	word [bx]	; load integer (push BX into FPU register stack)
		fmul	st0, st0	; multiply ST(0) by ST(0) and store result in ST(0)
		xor	BX, BP		; BX xor BP
		xchg	AX, DX		; exchange register DX with AX
		fxch	st1		; exchange register contents - of ST(0) and ST(1)
		jnbe	near moveit	; jump short if not equal or below (CF=0 and ZF=0)
		faddp	st1, st0	; add ST(0) to ST(1), store result in ST(1), and pop the register stack
		fsqrt			; square root -  computes square root of ST(0) and stores the result in ST(0)
		fdivr	dword [si]	; reverse divide (Z direction of tunnel)
		fild	word [bx]	; load integer (push BX into FPU register stack)
		fild	word [bp]	; load integer (push BP into FPU register stack)
		fpatan			; partial arctangent - replace ST(1) with arctangent(ST(1)/ST(0)) and pop the register stack
		dec	cx		; CX=CX-1
		xchg	AX, CX		; exchange register CX with AX
		stosb			; store AL at address ES:(E)DI
		jmp	near tunnel	; jump to tunnel
		db "eviL"		; wasting 4 bytes yeah :)