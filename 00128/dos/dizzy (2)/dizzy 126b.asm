org 100h
push 0xa000
pop es
mov al,0x13			; mode 13
int 0x10
; mov fs,bx
X:
;inc di				; next frame
	mov dx,0x3DA			; port number for checking retrace
	vsync:  	
	in al, dx				; wait
	and al, 8				; for
	jz vsync				; retrace	
inc bp
	
S:
cwd
					; we use int10 overflow
					; also, dx=0 for DIV

mov bx,320 			; make x and y
mov ax,di			; from counter
div bx				; dx = y , ax = x

; mov cx,[fs:0x46c]

;mov si,128			; with shr ax,2 = +16 palette offset
xor si,si
mov cl,128

	; AX  CX  DX  BX  SP  BP  SI  DI
	; -4  -6  -8 -10 -12 -14 -16 -18

	pusha					
		; xor bx,bx
		fild word [si-14]
		; fild word [fs:0x46c]
		;fidiv word [byte bx - 16]
		;fidiv word [byte bx-11]
		fidiv word [si-6]
		fsincos				; sin cos
		fld st1				; cos sin cos
		fld st1				; sin cos sin cos
		;fmul dword [si]
		fst st4				; sin cos sin cos sin 	
		FLDL2E				; l2e sin cos sin cos sin 
			
		faddp st5,st0		; sin cos sin cos zoom 

		fimul word [si-4]	; sin*x cos sin cos zoom  
		fxch				; cos sin*x sin cos zoom  
		fimul word [si-8]	; cos*y sin*x sin cos zoom  
c2:		faddp				; cos*y+sin*x sin cos zoom  
		fdiv st3
		fistp word[bp+si]	; sin cos zoom  		-> ah
		fimul word [si-8]	; sin*y cos zoom  
		fxch				; cos sin*y zoom  
		fimul word [si-4]	; cos*x sin*y zoom  
		fsubp				;-cos*x + sin*y zoom  
		fdivrp st1			; result sin cos
		;fmul dword [si]
		fistp word[si-4]	; sin cos					-> al	
	popa
mov bx,bp			; use framecounter for offset
					; but leave untouched

	mov dx,word [bp+si]


i:					; the magic
	push ax
	push dx

		add al,bl
		sub dx,bp	
		sub dx,bx
		xor ax,dx
		; and al,128+64+32+16+8
		and ax,cx	
		or si,ax
		sar bx,1
		sar cx,1
	pop dx
	pop ax
jnz i

xchg si,ax
;dec ax
and al,128+64+32+16+8

bsr ax,ax
shl ax,1
add al,17
; add al,3
stosb
;shr ax,3
; mov ah,0x0c			; = set pixel
inc di
inc di
;test di,di

jnz S
; dec cx
; mov cx,[fs:0x46c]

in al,0x60
dec al
jnz short X
ret
number:
; dw 200