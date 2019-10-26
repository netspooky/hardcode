; Kod napisany przez Piotra Tarsê
.486p
locals

code32 segment para public use32
	assume cs:code32, ds:code32


global _main:proc
global code32_base:dword

dpmi_regs struc
	_edi		dd ?
	_esi		dd ?
	_ebp		dd ?
	_none1	dd ?
	_ebx		dd ?
	_edx		dd ?
	_ecx		dd ?
	_eax		dd ?
	_flags	dw ?
	_es		dw ?
	_ds		dw ?
	_fs		dw ?
	_gs		dw ?
	_none2	dw ?
	_none3	dw ?
	_sp		dw ?
	_ss		dw ?
ends

clear_dpmi_regs proc

	pushad
	xor	eax,eax
	mov	edi,offset _regs
	mov	ecx,25
	cld
	rep	stosw
	popad
	ret

endp

losuj proc

	mov	bx,los_pom
	add	bx,9248h
	ror	bx,3
	mov	los_pom,bx
	mul	bx
	mov	ax,dx
	ret
endp

_main proc
	finit


poczatek:
	mov	cx,0
	mov	bx,6
	mov	ax,0501h
	int	31h
	jc	koniec
	shl	ebx,16
	mov	bx,cx
	sub	ebx,code32_base
	mov	ax,si
	shl	eax,16
	mov	ax,di
	mov	uchwyt_bufora,eax
	mov	ekran,ebx
	add	ebx,512*384
	mov	tekstura,ebx

	mov	eax,0a0000h
	sub	eax,code32_base
	mov	_a0000h,eax

	mov	ax,0300h
	mov	bx,10h
	mov	edi,offset _regs
	call	clear_dpmi_regs
	mov	[edi._eax],4f02h
	mov	[edi._ebx],222h
	int	31h


	mov	edi,data16
	shl	edi,4
	sub	edi,code32_base

	mov	cx,64
	xor	ax,ax
n_kolor1:
	xor	al,al
	stosb
	stosb
	mov	al,ah
	stosb
	inc	ah
	mov	al,ah
	inc	edi
	loop	n_kolor1

	mov	cx,64
	xor	ax,ax
n_kolor2:
	xor	al,al
	stosb
	mov	al,ah
	stosb
	mov	al,63
	stosb
	inc	ah
	inc	edi
	loop	n_kolor2

	mov	cx,64
	xor	ax,ax
n_kolor3:
	mov	al,ah
	stosb
	mov	al,63
	stosb
	stosb
	inc	ah
	inc	edi
	loop	n_kolor3

	mov	cx,64
	mov	al,63
n_kolor4:
	stosb
	stosb
	stosb
	dec	al
	inc	edi
	loop	n_kolor4

	mov	ax,0300h
	mov	bx,10h
	mov	edi,offset _regs
	call	clear_dpmi_regs
	mov	[edi._eax],4f09h
	mov	[edi._ebx],80h
	mov	[edi._ecx],256
	mov	[edi._es],data16
	int	31h

	mov	ecx,384
	mov	edi,ekran
qpa:	mov	eax,512
kaaa:	cld
	stosb
	dec	eax
	jnz	kaaa
	dec	ecx
	jnz	qpa


main_loop:


	mov	edi,ekran
	mov	ecx,512*382
	add	edi,512
qnik:	xor	eax,eax
	xor	ebx,ebx
	mov	al,[edi-512]
	mov	bl,[edi-1]
	add	ax,bx
	mov	bl,[edi+1]
	add	ax,bx
	mov	bl,[edi+512]
	add	ax,bx
	shr	ax,2
	sub	al,5
	mov	[edi],al
	inc	edi
	dec	ecx
	jnz	qnik

	mov	dx,03dah
c1:
	in	al,dx
	test	al,8
	jz	c1
c2:
	in	al,dx
	test	al,8
	jnz	c2

	mov	ax,0300h
	mov	bx,10h
	mov	edi,offset _regs
	call	clear_dpmi_regs
	mov	[edi._eax],4f05h
	mov	[edi._edx],0h
	int	31h
	mov	esi,ekran
	mov	edi,_a0000h
	mov	ecx,65536/4
	cld
	rep	movsd
	mov	ax,0300h
	mov	bx,10h
	mov	edi,offset _regs
	call	clear_dpmi_regs
	mov	[edi._eax],4f05h
	mov	[edi._edx],1h
	int	31h
	mov	edi,_a0000h
	mov	ecx,65536/4
	cld
	rep	movsd
	mov	ax,0300h
	mov	bx,10h
	mov	edi,offset _regs
	call	clear_dpmi_regs
	mov	[edi._eax],4f05h
	mov	[edi._edx],2h
	int	31h
	mov	edi,_a0000h
	mov	ecx,65536/4
	cld
	rep	movsd
	in	al,60h
	dec	al
	jnz	main_loop

wychodzimy:
	mov	eax,uchwyt_bufora
	mov	di,ax
	shr	eax,16
	mov	si,ax
	mov	ax,0502h
	int	31h

	; z powrotem tryb tekstowy
	mov	ax,0300h
	mov	bx,10h
	mov	edi,offset _regs
	mov	[edi._eax],03h
	int	31h
koniec:
	mov	ah,4Ch
	int	21h

even
los_pom		dw 1111h
align 4
_a0000h		dd 0
ekran			dd 0
uchwyt_bufora	dd 0
tekstura		dd 0
_regs			dpmi_regs ?

endp
code32 ends
data16 segment para public use16
	paleta		db 1024 dup(0)
data16 ends
end