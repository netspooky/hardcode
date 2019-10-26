	mov	al,19
	int	16
	mov	si,(d+1)
	les	bp,[bx]
	xor	di,di
	mov	bl,48
l	push	di
	mov	cl,4
m	lodsb
	xchg	ax,dx
	stc
	rcl	dl,1
o	salc
	and	al,100
	stosb
	shl	dl,1
	jnz	o
	loop	m
	pop	di
	add	di,320
	dec	bx
	jnz	l
d	ret ;0wait4key!
.end
