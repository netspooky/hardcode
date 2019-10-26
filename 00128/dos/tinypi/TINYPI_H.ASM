.radix 10
syze=2047		; size is a reserved word in ASM
			; 2047 is largest value which allows
			; denom to be less than 65536
	; Note:  This program waits until after calculating all
	; values.  This means that there may be a long pause before
	; any display.  The delay can be over a minute on 486's
	; or slower Pentiums.
	; Note:  It appears that a rounding error can creep into
	; the last 1 or 2 words of display.  In actual usage,
	; probably best to calculate 2 more words than displaying.
	; In this case, the last WORD displays as 209E, but should
	; actually be 209C.

terms=syze*16
denom=2*terms+1

.model tiny
.code
org 100h
start:
	mov	cx,syze
	mov	di,cx		; mov di,offset buffer
				; saves 1 byte, but requires that 
				; syze be large enough to be beyond
				; end of program.
	mov	si,di		; si = index base, start of print location

	push	cx		; save number of words to be printed
;	sub	ax,ax		; assume program begins with AX=0000
	rep	stosw		; just go ahead and clear the whole block

	mov	di,terms	; terms=syze*16
	mov	bp,(terms*2)+1	; denom=2*terms+1
L1:
;	sub	cx,cx		; remainder=0
				; zero from above & below
;	sub	bx,bx		; i=0 (assume bx=0000 at program start)
				; therefore, zero from above & below
L2:
		; dx:ax = dividend
		; cx = remainder
		; bp = denom
		; di = terms
	mov	dx,cx	;dividend+= (remainder <<16)
	mov	ax,[bx+si]	; ax = array[i]
	div	bp		; dividend = dividend/denom
	mov	[bx+si],ax	; array[i] = dividend/denom
	mov	cx,dx		; remainder = dividend mod denom
	inc	bx
	inc	bx		; go to next array[i] element
	cmp	bx,syze*2	; bx increases by 2 per array[i]
	jb	L2

L3:
		; dx:ax = dividend
		; cx = remainder
		; bp = denom
		; di = terms
	dec	bx
	dec	bx		; point to beginning of array[i]
	mov	ax,di		; terms -> ax
	mul	word ptr[bx+si]	; dx:ax dividend =  terms*array[i]
	add	ax,cx		;       dividend += remainder
	adc	dx,+00
	mov	[bx+si],ax	; array[i] = dividend & 0x0000ffff;
	mov	cx,dx		; remainder = dividend >> 16;
	or	bx,bx
	jnz	L3

;------------------------------------
; this section displays a progress meter
; since program can get slow with high syze value.
; Is safe to alter the AX value when branching up to L1.
;	dec	byte ptr[start]	; if SI-1 won't collide with code,
;				; can use "dec byte ptr[si-1]"
;				; to save 1 byte.
;	jnz	past
;	mov	al,'*'
;	int	29h
past:
;------------------------------------

	add	word ptr[bx+si],+02	;array[0]+=2
		; could use "add word ptr[si],+2" if you are
		; certain you will not  be switching program
		; beginning away from "mov si,di".
	dec	bp
	dec	bp	;denom -=2
	dec	di	;terms--
	jnz	L1

	pop	bp	; mov	bp,syze
	; dec	bp	; optional shortening of display since the
			; last digit of the 2047th word is wrong.	
	mov	bl,16	; display in base 16 hexadecimal
Num1:
	lodsw
	mov	cl,4
Num2:
	sub	dx,dx
	div	bx
	push	dx
	loop	Num2

	mov	cl,04
Num3:

;	pop	dx
;	cmp	dl,09
;	jbe	Num4
;	add	dl,27h	; lower case + "A" - "9"
;Num4:			; add 07h for capital letters
;	add	dl,'0'

	pop	ax
	cmp	al,0ah
	sbb	al,69h
	das
;	or	al,20h	; eliminate this if uppercase is OK.
			; this section replaces the above
			; section commented out.


	int	29h	; if you need to be able to redirect
			; the data to disk, rem out this "int 29h"
			; and un-REM the following 3 lines.
;	xchg	dx,ax
;	mov	ah,02
;	int	21h

	loop	Num3

;	mov	dl,20h
;	int	21h
;	int	21h	; this allows you to separate each word of
			; output with a space.
	dec	bp
	jnz	Num1
	ret

Buffer=0200h
end start
