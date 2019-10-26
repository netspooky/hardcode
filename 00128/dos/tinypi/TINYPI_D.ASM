.radix 10
.model tiny
.code

; This program uses almost all of the 64K code segment.  There might
; be rare situations where the last 4 digits of the printout are
; wrong, but this is less likely than in the previous version.
; The last 4 digits should be 1224.

; Program assumes there is 64K of memory available for the program,
; without checking.  In the rare case where there isn't 64K
; available, it may crash the computer.
; i.e. don't LOADHIGH this program.

org 100h
start:
	mov	cx,2326*14 ;32564 ; this MUST be a multiple of 14
				; might be possible to increase
				; to 2327*14, but that last 4 digits
				; is much more likely to be corrupted
				; and/or corrupt the rest of the array
				; since that ends the scratch area
				; at FFF1h.
	mov	di,Offset Buffer
	mov	bx,cx
	mov	ax,2000		; initial value of the array
	mov	bp,10000	; keeping 10000 constant in extra register
	rep	stosw		; wipes the buffer used.
				; offset 0172h through offset FFD9

		; FFDA-FFFE is stackspace for 18 words.
		; the workspace shrinks by an additional 14 words
		; before calling an INT.  This program is smaller
		; than previous version by 12 bytes, meaning that
		; stack is larger by 6 words, making it less likely
		; that the stack will overrun the workspace.

	; cx = 0000, which is the original value of the remainder.

	; bx is decremented from 32564 by 14's.  Lesser value would
	; not have correct values toward the low end of the output.
	; outer-counter is "i", inner-counter is "j"
	; because counter is decremented at the end, array is accessed
	; by subtracting 2 from the counter.

OuterLoop:
	xor	ax,ax
	push	bx
	cwd			; dx:ax initialized as 0000:0000

InnerLoop:
	push	bx
	mov	si,dx		; save dx thru the multiply
	mul	bx		; bx * ax -> dx:ax
	xchg	si,ax		; get the original dx to multiply it
	push	dx
	mul	bx
	pop	dx
	add	ax,dx
	xchg	di,ax		; dx:ax * bx -> di:si

	mov	ax,bp		; ax = 10,000
	add	bx,bx		; align for 2-byte array elements
	mul	word ptr [bx+offset Buffer-2]
				; because bx is decremented at the end,
				; must subract 2 to point at correct item
	add	ax,si
	adc	dx,di		; dx:ax = dx:ax + di:si
	dec	bx		; bx = 2*j -1
	xor	di,di
	xchg	di,ax
	xchg	dx,ax
	div	bx		; dx = 0, ax = high part of prev di:si
				; dx:ax / bx -> ax, dx=remainder
	xchg	di,ax
	mov	si,dx
	xor	dx,dx
	div	bx		; dx = 0, ax = low part of prev di:si
	xchg	si,ax
	xchg	dx,ax
	div	bx
	mov	[bx+offset buffer-1],dx	; because bx was decremented
					; above, just subtract 1 to
					; access correct element.
	xor	dx,dx
	add	ax,si		; si:di + ax -> dx:ax
	adc	dx,di
	pop	bx
	dec	bx
	jnz	InnerLoop

	div	bp	; div by 10,000 - resulting mod has 4 decimal digits

	push	dx	; save remainder for use in next loop.
	add	ax,cx
	mov	bl,10	; dividing by 10 yields decimal digits.
	mov	cx,4

Num1:
	cwd		; "xor dx,dx" not needed, value is always < 7fff
	div	bx	; divide by 10
	push	dx
	loop	Num1

	mov	cl,4

Num2:
;	pop	dx	
;	add	dl,"0"
;	mov	ah,2
;	int	21H

	pop	ax	; these 3 lines save 3 bytes compared to
	add	al,"0"	; the previous 4 lines, but the output
	int	29H	; can't be redirected to a file

	loop	Num2

	pop	cx	; restore remainder pushed in DX above
	pop	bx	; restore outer-loop's value
	sub	bx,+14	; decrement by 14.

;	jnz	OuterLoop
	jnbe	OuterLoop	; changed from JNZ in case someone
				; didn't make BX a multiple of 14.

	ret		; .COM always has 0000 on the stack.
			; instruction at offset 0000 is always
			; an INT 20H, which ends the program.

ProgramEnd:
Buffer=$ ;+1 ;align even without adding a byte

end start
	; This is offset 016Eh.  Next 32564 words through FFD5h
	; are used as workspace.
