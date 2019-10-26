; Kod napisany przez Piotra Tarsê
; Dziura promieñ 20 pikseli lub mniej
; Cieniowanie promieñ 30 pikseli
.model tiny
.386
.code
org 100h
start:
	finit
	mov	ax,0013h
	int	10h
	mov	dx,03c8h
	xor	ax,ax
	out	dx,al
	inc	dx
	mov	cx,64
n_kolor1:
	xor	al,al
	out	dx,al
	out	dx,al
	mov	al,ah
	out	dx,al
	inc	ah
	mov	al,ah
	loop	n_kolor1
	mov	cx,64
	xor	ax,ax
n_kolor2:
	xor	al,al
	out	dx,al
	mov	al,ah
	out	dx,al
	mov	al,63
	out	dx,al
	inc	ah
	loop	n_kolor2
	mov	cx,64
	xor	ax,ax
n_kolor3:
	mov	al,ah
	out	dx,al
	mov	al,63
	out	dx,al
	out	dx,al
	inc	ah
	loop	n_kolor3
	mov	cx,64
	mov	al,63
n_kolor4:
	out	dx,al
	out	dx,al
	out	dx,al
	dec	al
	loop	n_kolor4
	mov	ah,4ah
	mov	bx,1000h
	int	21h
	mov	ah,48h
	mov	bx,1000h
	int	21h
	jc	koniec
	mov	tekstura,ax
	mov	ah,4ah
	mov	bx,1000h
	int	21h
	mov	ah,48h
	mov	bx,1000h
	int	21h
	jc	free_tekstura
	mov	tablica2,ax
	mov	ah,4ah
	mov	bx,1000h
	int	21h
	mov	ah,48h
	mov	bx,1000h
	int	21h
	jc	free_tablica2
	mov	tablica1,ax
	mov	ah,4ah
	mov	bx,1000h
	int	21h
	mov	ah,48h
	mov	bx,1000h
	int	21h
	jc	free_tablica1
	mov	ekran,ax

	mov	cx,-1
	xor	di,di
	xor	ax,ax
	xor	bx,bx
	xor	dx,dx
	mov	es,tekstura
tex_gen:
	mov	es:[di],al
	inc	bl
	seto	dl
	add	al,dl
	inc	di
	dec	cx
	jnz	tex_gen
	mov	es:[di],al

	mov	cx,64000
	xor	di,di
	mov	es,tablica1
tab1_gen:
	mov	tx,-160
	mov	ax,x
	add	tx,ax
	fild	tx
	fimul	tx
	fistp temp
	mov	ty,-100
	mov	ax,y
	add	ty,ax
	fild	ty
	fimul	ty
	fiadd	temp
	fsqrt
	fistp	temp
	fild	promien
	fidiv	temp
	fistp	temp
	mov	ax,temp
	mov	es:[di],al
	inc	x
	cmp	x,320
	jnz	tab1_gen_koniec
	mov	x,0
	inc	y
tab1_gen_koniec:
	inc	di
	dec	cx
	jnz	tab1_gen

	mov	cx,64000
	xor	di,di
	mov	x,-160
	mov	y,-100
	mov	es,tablica2
	mov	temp,0
tab2_gen:
	fild	x
	fild	y
	fpatan
	fimul	_256
	fldpi
	fdiv
	fistp	temp
	inc	x
	cmp	x,160
	jnz	tab2_gen_koniec
	mov	x,-160
	inc	y
tab2_gen_koniec:
	mov	ax,temp
	mov	es:[di],al
	inc	di
	dec	cx
	jnz	tab2_gen

	mov	cx,8*8
	xor	ax,ax
	mov	si,offset kolo
kolo_gen:
	mov	[si],al
	inc	si
	dec	cx
	jnz	kolo_gen

	lea	dx,nazwa_tekstury
	mov	ax,3d02h
	int	21h
	jc	main_loop
	xchg	ax,bx
	lea	dx,paleta
	mov	cx,54
	mov	ah,3fh
	int	21h
	lea	dx,paleta
	mov	cx,1024
	mov	ah,3fh
	int	21h
	push	ds
	mov	ds,tekstura
	mov	cx,0ffffh
	mov	dx,0
	mov	ah,3fh
	int	21h
	pop	ds
	mov	di,offset paleta
	mov	dx,03c8h
	xor	ax,ax
	out	dx,al
	inc	dx
	mov	cx,256
kolory:
	mov	al,[di+2]
	shr	al,2
	out	dx,al
	mov	al,[di+1]
	shr	al,2
	out	dx,al
	mov	al,[di]
	shr	al,2
	out	dx,al
	add	di,4
	loop	kolory


main_loop:
	mov	cx,64000
	xor	di,di
klatka:
	mov	es,tablica1
	mov	bh,es:[di]
	mov	es,tablica2
	mov	bl,es:[di]
	add	bl,krowiarz_x
	add	bh,krowiarz_y
	add	bh,predkosc
	push	di
	mov	di,bx
	mov	es,tekstura
	mov	al,es:[di]
	mov	es,ekran
	pop	di
	mov	es:[di],al
	inc	di
	dec	cx
	jnz	klatka
	add	predkosc,12

	mov	dx,03dah
c1:
	in	al,dx
	test	al,8
	jz	c1
c2:
	in	al,dx
	test	al,8
	jnz	c2
	push	ds
	mov	ds,ekran
	xor	si,si
	mov	ax,0a000h
	mov	es,ax
	xor	di,di
	mov	cx,16000
	cld
	rep	movsd
	pop	ds

	inc	v
	cmp	v,180
	jnz	zerowanie_v
	mov	v,-180
zerowanie_v:
	fild	v
	fmul	skaluj
	fcos
	fimul	_256
	fimul	_3
	fist	temp
	mov	ax,temp
	add	krowiarz_x,ah
	fimul	_3
	fistp	temp
	mov	ax,temp
	add	krowiarz_y,ah
	

	in	al,60h
	dec	al
	jnz	main_loop

wychodzimy:
	mov	es,ekran
	mov	ah,49h
	int	21h
free_tablica1:
	mov	es,tablica1
	mov	ah,49h
	int	21h
free_tablica2:
	mov	es,tablica2
	mov	ah,49h
	int	21h
free_tekstura:
	mov	es,tekstura
	mov	ah,49h
	int	21h

koniec:
	mov	ax,0003h
	int	10h
	mov	ah,4ch
	int	21h

krowiarz_x		db 0
krowiarz_y		db 0
predkosc		db 0
nazwa_tekstury	db "tekstura.bmp",0
even
ekran			dw 0
promien		dw 10000
random_seed		dw 1234h
tablica1		dw 0
tablica2		dw 0
temp			dw 0
tekstura		dw 0
tx			dw 0
ty			dw 0
x			dw 0
y			dw 0
_256			dw 128
v			dw 0
_7			dw 7
_3			dw 3
align 4
skaluj		dd 0.0174532925199432957692369076848861
kolo			db 8*8 dup(?)
paleta		db 1024 dup(?)
end start