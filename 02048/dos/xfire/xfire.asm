; Mikolaj Felix 1/05/2001
; mfelix@polbox.com

.model tiny
.386
.code
org 100h

start:
	

loading_ok:
	call	alloc_screen_buffer
	call	clear_screen_buffer

	mov	ax, 13h
	int	10h
	
	mov	si, offset fire_pal
	mov	cx, 768
	xor	ax, ax
	mov	dx, 03c8h
	out	dx, al
	inc	dx
	cld
	rep	outsb

main_loop:
	call	burn
	call	wait_for_frame
	call	copy_screen_buffer
	in	al, 60h
	dec	al
	jnz	main_loop

	mov	ax, 03h
	int	10h
	call	free_screen_buffer
	mov	ax, 4c00h
	int	21h
	ret

comment #
make_palette proc
	mov	di, offset fire_pal
	mov	cx, 64
	cld
g_color1:
	xor	al, al
	stosb
	mov	al, ah
	stosb
	xor	al, al
	stosb
	inc	ah
	loop	g_color1

	xor	ax, ax
	mov	cx, 64
g_color2:
	xor	al, al
	stosb
	mov	al, 63
	stosb
	mov	al, ah
	stosb
	inc	ah
	loop	g_color2

	xor	ax, ax
	mov	cx, 64
g_color3:
	mov	al, ah
	stosb
	mov	al, 63
	stosb
	stosb
	inc	ah
	loop	g_color3

	mov	al, 63
	mov	cx, 64
g_color4:
	stosb
	stosb
	stosb
	loop	g_color4
	ret
endp #

burn proc
	push	ds
	mov	ds, buffer_seg

	mov	di, 64000
	mov	cx, 80
burn_loop1:
	mov	bx, cs:[random_seed]
	add	bx, 9248h
	ror	bx, 3
	mov	cs:[random_seed], bx
	mov	ax, MAX_COLORS
	mul	bx
	mov	ax, dx
	
	mov	ah, al
	mov	dx, ax
	shl	eax, 16
	mov	ax, dx
	mov	dword ptr [di], eax
	mov	dword ptr [di+320], eax
	mov	dword ptr [di+640], eax
	mov	dword ptr [di+960], eax

	add	di, 4
	dec	cx
	jnz	burn_loop1

	mov	di, 640
	mov	cx, 64000+640
	xor	ax, ax
	xor	bx, bx
burn_loop2:
	mov	al, byte ptr [di-1]
	mov	bl, byte ptr [di+1]
	add	ax, bx
	mov	bl, byte ptr [di-320]
	add	ax, bx
	mov	bl, byte ptr [di+320]
	add	ax, bx
	shr	ax, 2
	dec	al
	jz	burn_next
	mov	byte ptr [di-320], al
	mov	byte ptr [di-640], al
burn_next:
	inc	di
	dec	cx
	jnz	burn_loop2

	pop	ds
	ret
endp

include graphlib.asm
include fire_pal.inc

MAX_COLORS equ 255

random_seed dw 1111h

end start