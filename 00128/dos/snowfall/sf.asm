org 100h
use16
;---------------------------------------------------------------------
		mov	al, 13h
		int	10h
;		les bp,[bx]
mov bh,0A0h
mov es,bx
		mov bp,3000
		xor di,di
init:
		push di
		call	perturb	; perturbation
		movzx ax,ch

		imul	ax, 0F0h
;         add     ah, 5

		mov	[cs:di+1+bp], ah

		movzx dx,ah
		movzx	  ax, cl
		mul	dx

		inc	ah
		mov	[cs:di+bp], ah

		pop di
		inc di
		cmp di,bp;3000
		jnz	short init

snowf:
		 xor di,di

snow_lp:
		push di
		call	perturb	; perturbation
		
		mov	si, [cs:di+2+bp]

		mov	byte [es:si], bl
		mov	dx, [cs:di+bp]
		cmp	dl, cl
		jb	short endif1
		inc	si
endif1:
		movzx	  ax, dh
		cmp	al, ch
		jb	short endif2
		add	si,320
endif2:
		shr	ax, 5
		add	ax, 18h
		mov	[es:si], al
		mov [cs:di+2+bp],si
pop di
inc di
cmp di,bp;3000
		jnz	short snow_lp
waitv:
		mov	dx, 3DAh
		in	al, dx
		and	al, 8
		je     short waitv
		in al,60h
		dec al
		jnz    short snowf

perturb:
shl di,2
		xor	cx, 0AA55h
		shl	cx, 1
		adc	cx, 118h
		ret

