;compiled with:
;tasm /m9 (ver 4.1)
;tlink /t (ver 7.1)

.486
code segment byte public use16
assume	cs:code, ds:code
org 100h
start:
	mov	al,13h
	int	10h
	mov	bl,3
	mov	si,0a0a0h
	mov	ds,si
again:	mov	cx,0c8bh
	xor	ch,[bx+si]
	mov	[si+0fec2h],ch
	dec	si
	jnz	again+1
	int	16h		;ah=00h
	xchg	ax,bx
	int	10h		;ax=0003h
	ret
code ends
end start
