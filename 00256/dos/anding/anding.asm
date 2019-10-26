;Mikolaj Felix 24/10/2000

.model tiny
.386
.code
org 100h

start:
	mov	ax, cs
	mov	ds, ax
	mov	ax, 0a000h
	mov	es, ax

	mov	ax, 13h
	int	10h
	mov	dx, 03c8h
	xor	al, al
	out	dx, al
	mov	dx, 03c9h
	mov	cx, 256
kolor:
	out	dx, al
	mov	al, ah
	out	dx, al
	inc	al
	mov	ah, al
	xor	al, al
	out	dx, al
	loop	kolor

	xor	cx, cx
pion:
	xor	bx, bx
	mov	ax, cx
	mov	dx, ax
	shl	ax, 6
	shl	dx, 8
	add	dx, ax
poziom:
	mov	di, bx
	add	di, dx
	mov	ax, bx
	and	ax, cx
	mov	es:[di], al
	inc	bx
	cmp	bx, 320
	jne	poziom
	inc	cx
	cmp	cx, 200
	jne	pion

petla:
	mov	dx, es
	mov	ax, es
	mov	ds, ax
	xor	si, si
	mov	ax, cs
	mov	es, ax
	mov	di, offset linia
	mov	cx, 320/4
	cld
	rep	movsd
	mov	es, dx
	
	mov	di, 320
	mov	cx, (64000-320)/4
skok:
	mov	eax, es:[di]
	mov	es:[di-320], eax
	add	di, 4
	dec	cx
	jnz	skok

	mov	si, offset linia
	mov	di, 64000-320
	mov	cx, 320/4
	cld
	rep	movsd

	mov	dx, 03dah
c1:
	in	al, dx
	test	al, 8
	jz	c1
c2:
	in	al, dx
	test	al, 8
	jnz	c2

	in	al, 60h
	cmp	al, 1
	jne	petla
	mov	ax, 03h
	int	10h
	mov	ah, 4ch
	int	21h
	ret

linia db 320 dup(?)

end start