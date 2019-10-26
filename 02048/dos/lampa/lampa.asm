;Mikolaj Felix 26/12/2000
;mfelix@polbox.com

.model tiny
.386c
.code
org 100h

start:
	finit
	mov	ax, cs
	mov	ds, ax
	mov	es, ax
	call	seg_alokacja
	cmp	ax, 0
	je	koniec
	mov	bufor_segment, ax
	call	seg_alokacja
	cmp	ax, 0
	je	koniec
	mov	obrazek_segment, ax
	
	mov	ax, 13h
	int	10h
	call	inicjuj_palete
	call	generuj_obrazek
	call	generuj_mape
	call	inicjuj_droge
petla:
	mov	ax, obrazek_segment
	mov	bx, bufor_segment
	call	seg_kopiowanie
	
	mov	bx, kat_x
	shl	bx, 1
	mov	ax, ds:droga[bx]
	add	ax, 160
	mov	bx, kat_y
	shl	bx, 1
	mov	dx, ds:droga[bx]
	add	dx, 100
	mov	bx, dx
	call	lampa

	mov	si, offset napis
	mov	cx, 160-(32*8)/2
	mov	dx, 191
	call	pisz_string

	call	czekaj
	call	czekaj
	mov	ax, bufor_segment
	mov	bx, 0a000h
	call	seg_kopiowanie
	call	obrazek_scroll

	mov	ax, word ptr kat_x
	add	ax, 2
	and	ax, 255
	mov	word ptr kat_x, ax

	mov	ax, word ptr kat_y
	add	ax, 1
	and	ax, 255
	mov	word ptr kat_y, ax

	in	al, 60h
	cmp	al, 1
	jne	petla

	mov	ax, 03h
	int	10h
koniec:
	mov	ax, bufor_segment
	call	seg_dealokacja
	mov	ax, obrazek_segment
	call	seg_dealokacja
	mov	ah, 4ch
	int	21h
	ret

obrazek_scroll proc
	push	ds
	mov	ax, obrazek_segment
	mov	ds, ax
	xor	si, si
	mov	di, offset linia
	mov	cx, 320/4
	cld
	rep	movsd
	
	mov	di, 320
	mov	cx, (64000-320)/4
scroll_skok:
	mov	eax, dword ptr [di]
	mov	dword ptr [di-320], eax
	add	di, 4
	dec	cx
	jnz	scroll_skok
	pop	ds
	
	push	es
	mov	es, obrazek_segment
	mov	si, offset linia
	mov	di, 64000-320
	mov	cx, 320/4
	cld
	rep	movsd
	pop	es
	ret
endp

lampa proc
	push	es
	p

	ret
endp

lampa2 proc
	push	es
	mov	dx, bufor_segment
	mov	es, dx
	mov	si, offset mapa
	mov	bp, sp
	sub	sp, 8

	mov	dx, MAPA_BOK/2
	mov	word ptr [bp-2], ax
	sub	word ptr [bp-2], dx		;[bp-2] x_start
	mov	word ptr [bp-4], ax
	add	word ptr [bp-4], dx		;[bp-4] x_koniec

	mov	word ptr [bp-6], bx
	sub	word ptr [bp-6], dx		;[bp-6] y_start
	mov	word ptr [bp-8], bx
	add	word ptr [bp-8], dx		;[bp-8] y_koniec

	mov	cx, word ptr [bp-6]
lampa_pion:
	cmp	cx, 0
	jae	lampa_dalej1
	jmp	zmiana_linii
lampa_dalej1:
	cmp	cx, 199
	jbe	lampa_dalej2
zmiana_linii:
	add	si, MAPA_BOK
	jmp	lampa_dalej4
lampa_dalej2:

	mov	bx, cx
	mov	ax, bx
	shl	bx, 6
	shl	ax, 8
	add	bx, ax			; bx offset_y
	mov	dx, word ptr [bp-2]
lampa_poziom:
	cmp	dx, 0
	jb	lampa_dalej3
	cmp	dx, 319
	ja	lampa_dalej3
	
	mov	di, bx
	add	di, dx
	mov	al, byte ptr [si]
	add	byte ptr es:[di], al
lampa_dalej3:
	inc	si

	inc	dx
	cmp	dx, word ptr [bp-4]
	jne	lampa_poziom
lampa_dalej4:
	inc	cx
	cmp	cx, word ptr [bp-8]
	jne	lampa_pion

	mov	sp, bp
	pop	es
	ret
endp

inicjuj_palete proc
	mov	dx, 03c8h
	xor	ax, ax
	out	dx, al
	inc	dx
	mov	cx, 256
kolor:
	out	dx, al
	out	dx, al
	out	dx, al
	inc	ah
	mov	al, ah
	shr	al, 2
	dec	cx
	jnz	kolor
	ret
endp

seg_alokacja proc
	mov	ah, 4ah
        mov bx, 1000h
        int 21h
        mov ah, 48h
        mov bx, 1000h
        int 21h
        jc brak_pamieci
	ret				;ax segment
brak_pamieci:
	xor	ax, ax
	ret
endp

seg_dealokacja proc
	push	es
        mov es, ax			;ax segment
        mov ah, 49h
        int 21h
	pop	es
	ret
endp

seg_kopiowanie proc			;ax- src,  bx- dest
	push	ds
	push	es
	mov	ds, ax
	xor	si, si
	mov	es, bx
	xor	di, di
	mov	cx, 16000
	cld
	rep	movsd
	pop	es
	pop	ds
	ret
endp

generuj_obrazek proc
	push	es
	mov	ax, obrazek_segment
	mov	es, ax
	xor	di, di
	xor	cx, cx
obrazek_pion:
	xor	dx, dx
obrazek_poziom:
	mov	ax, dx
	and	ax, cx
	and	al, 00111111b
	stosb
	inc	dx
	cmp	dx, 320
	jne	obrazek_poziom
	inc	cx
	cmp	cx, 200
	jne	obrazek_pion
	pop	es
	ret
endp

generuj_mape proc
	mov	di, offset mapa
	mov	cx, MAPA_BOK
mapa_pion:
	mov	dx, cx
	mov	cx, MAPA_BOK
mapa_poziom:
	mov	ax, cx
	sub	ax, MAPA_BOK/2
	mov	_fx, ax
	fild	_fx
	fimul	_fx
	fistp	_fx

	mov	ax, dx
	sub	ax, MAPA_BOK/2
	mov	_fy, ax
	fild	_fy
	fimul	_fy
	
	fiadd	_fx
	fsqrt
	fistp	_fx

	;mov _fy, cx
	;fild _fy
	;fsin
	;fiadd _fx
	;fistp _fx

	;mov _fy, dx
	;fild _fy
	;fcos
	;fiadd _fx
	;fistp _fx

	mov	ax, 90
	sub	ax, _fx

	cmp	ax, 90
	jbe	mapa_dalej1
	xor	ax, ax
mapa_dalej1:
	cmp	ax, 0
	jae	mapa_dalej2
	xor	ax, ax
mapa_dalej2:
	shl	al, 1
	stosb

	dec	cx
	jnz	mapa_poziom
	mov	cx, dx
	dec	cx
	jnz	mapa_pion
	ret
endp

czekaj proc
	mov	dx, 03dah
c1:
	in	al, dx
	test	al, 8
	jz	c1
c2:
	in	al, dx
	test	al, 8
	jnz	c2
	ret
endp

inicjuj_droge proc
	mov	di, offset droga
	xor	cx, cx
droga_skok:
	mov	_fx, cx
	fldpi
	fimul	_fx
	mov	ax, 128
	mov	_fx, ax
	fidiv	_fx
	fsin
	fimul	_fx
	fistp	_fx
	mov	ax, _fx
	stosw				
	inc	cx
	cmp	cx, 320
	jne	droga_skok
	ret
endp

include czcionka.asm
napis db 'CODE BY MIKOLAJ FELIX 26/12/2000', 0

bufor_segment dw 0
obrazek_segment dw 0
_fx dw 0
_fy dw 0

kat_x dw 0
kat_y dw 0
droga dw 320 dup(?)
linia db 320 dup(?)

MAPA_BOK equ 180
mapa db MAPA_BOK*MAPA_BOK dup(?)

end start