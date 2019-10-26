.radix 10
syze=2047		; size is a reserved word in ASM
			; 2047 the is largest value which allows
			; denom to be less than 65536
	; 2047 words is 8188 digits, of which the 1st 4 digits
	; are the 0003 to the left of the decimal, and the last
	; digit is probably wrong
	; Note:  This program waits until after calculating all
	; values.  This means that there may be a long pause before
	; any display.  The delay can be over a minute on 486's
	; or slower Pentiums.
	; Note:  It appears that a rounding error creeps into
	; the last 1 or 2 words of display.  In actual usage, it's
	; probably best to calculate 2 more words than displaying.
	; In this case, the last displayed WORD should be 209C.

terms=syze*16
denom=2*terms+1

.model tiny
.code
org 100h
start:
array=terms		; note, am defining array=terms, which
			; permits copying values from other registers
			; "terms" was used instead of "syze", because
			; terms is always even, allowing faster
			; access of memory variables


	mov	bx,terms	; terms=syze*16
	mov	bp,(terms*2)+1	; denom=2*terms+1
	mov	si,bx		; si=base of array[], start of printing
				; should be "mov si,offset array", but
				; am reducing size to allow "mov si,bx"
	mov	di,si		; di=array[0], or same as si register

;	sub	ax,ax		; assume program begins with AX=0000
;	push	di		; it's not required to clear the array[]
;	rep	stosw		; only effect is that the last digits
;	pop	di		; error might be slightly different.

L1:
;	mov	di,offset array	; di=array[0] from above & below
;	sub	cx,cx		; remainder=0, zero from below,
				; from above doesn't matter
L2:
		; dx:ax = dividend	; cx = remainder
		; bp = denom		; bx = terms
	mov	dx,cx	;dividend+= (remainder <<16)
	mov	ax,[di]		; ax = array[i]
	div	bp		; dividend = dividend/denom
	stosw			; array[i] = dividend/denom
				; and goes to next array[i] element
	mov	cx,dx		; remainder = dividend mod denom
	cmp	di,offset array+(syze*2) ; bx increases by 2 per array[i]
	jb	L2

L3:		; dx:ax = dividend	; cx = remainder
		; bp = denom		; di = terms
	dec	di
	dec	di		; point to beginning of array[i]
	mov	ax,[di]		; array[i] -> ax
	mul	bx		; dx:ax dividend =  terms*array[i]
	add	ax,cx		;       dividend += remainder
	adc	dx,+00
	mov	[di],ax		; array[i] = dividend / 65536
				;  same as = dividend & 0x0000ffff;
	mov	cx,dx		; remainder = dividend mod 65536
				;   same as = dividend >> 16;
	cmp	di,si
	ja	L3

;------------------------------------
; this section displays a progress meter
; since program can get slow with high syze value.
; Is safe to alter the AX value when branching up to L1.
;	test	bl,0ffh	; prints a "*" every 256 loops
;	jnz	past
;	mov	al,'*'
;	int	29h	; this section adds 9 bytes to the size.
past:
;------------------------------------
	add	word ptr[si],+02	;array[0]+=2
	dec	bp
	dec	bp	;denom -=2
	dec	bx	;terms--
	jnz	L1
	mov	bp,syze	; use "syze-1" to avoid printing error
			; in last word.
	mov	cl,4	; display in base 16 hexadecimal
Num1:
	lodsw
	mov	bl,4
Num2:
	; Note: you can save 2 byte by changing this routine to
	; generate the digit with code valid only for 286's or
	; better.  replace the "rol ax,cl" with "rol ax,4",
	; which allows using CX as the loop instead of
	; decrementing through BX.
	rol	ax,cl
	push	ax
	and	al,0fh
	cmp	al,0ah
	sbb	al,69h
	das
;	or	al,20h	; add this "or al,20h" for lowercase output.
	int	29h	; if you need to be able to redirect
			; the data to disk, rem out this "int 29h"
			; and un-REM the following 3 lines.
;	xchg	dx,ax
;	mov	ah,02
;	int	21h
	pop	ax
	dec	bx
	jnz	Num2

	dec	bp
	jnz	Num1
	ret

; Array:	; saving space by setting Array[] to same value as syze
		; see top of program.
end start
