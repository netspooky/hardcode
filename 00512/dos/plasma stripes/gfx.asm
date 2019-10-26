.386p
.model tiny

	_faddp MACRO
		db 0DEh,0C1h
	ENDM

sort SEGMENT PUBLIC USE16
.startup
	
		jmp realstart		;size of loader
		org 	168h
realstart:
	
		mov 	ax, 13h		;set video
		int 	10h		
		push 	0A000h
		pop 	es
		
		fldz				;circle position
		
		jmp start
		
newframe:
		pusha
		mov 	ax, 100h
		int 	16h			;check for keys
		jz @f
		int 	20h			;exit
@@:		popa
		
		;get points for a circle
		fldl2t
		_faddp
		fld 	st(0)
		fidiv 	[n2]
		fsincos
		fild 	[n3]
		fmul 	st(1),st
		fmulp 	st(2),st
		fistp 	[circley]
		fistp 	[circlex]
		add 	[circley],100
		add 	[circlex],160
		
		mov 	bp, 318
scanline:
			;sqrt( ( pow(cx-circley,2) - pow(bp-circlex,2) + a ) >> 4 )
			mov 	ax, bp
			sub 	ax, [circlex]
			mul 	ax
			mov 	bx, ax		
			mov 	ax, cx
			sub 	ax, [circley]
			mul 	ax
			sbb 	ax, bx
			adc 	ax, [a]
			shr 	ax, 4
			mov 	[tmp], ax
			fild	[tmp]
			fsqrt
			
			mul 	cx			;stripes
			cmp 	ax, cx
			jl @f
			shr 	[tmp],8
			fimul	[tmp]
@@:			fistp 	word ptr [tmp]
				
			imul 	di, cx, 320	;plot: (Y*320)+X
			add 	di, bp
			
			mov 	ax, [tmp]
			and 	al, 00Fh	;set palette to rainbow colors :D
			add 	al, 028h
			stosb
			
			dec 	bp
			jnz scanline
		dec 	cx
		jnz newframe
			
		add 	[a],50			;cycle palette colors
start:
		mov 	cx, 200
		jmp newframe
		
;====data
	n2 		dw 7777h
	n3 		dw   22h
	db 198h dup(0)
	tmp 	dw     0	
	a 		dw     0
	circlex dw     0
	circley dw     0
	
sort ENDS
end















