;juste un delire !
; Sed - Sat Aug 28 02:07:59 MET DST 1999

BITS 32

%define	NB_BYTES	3747

	org 0x800004A

	mov	esi, data_pack
	mov	edi, data_unpack
	mov	ecx, NB_BYTES
l1:	mov	dl, 8
	mov	al, 1
l2:	test	[esi], al
	jz	l3
	dec	byte [edi]
l3:	inc	di
	shl	al, 1
	dec	dl
	jnz	l2
	inc	si
	loop	l1

	mov	ebx, 1
	mov	eax, 4
	mov	ecx, hello
	mov	edx, 75
	int	0x80

	mov	eax, 5
	mov	ebx, 0x8000007
	mov	ecx, 1
	int	0x80

	mov	ebx, eax
	mov	eax, 4
	mov	ecx, data_unpack
	mov	edx, NB_BYTES*8
	int	0x80

	mov	ebx, 1
	mov	eax, 4
	mov	ecx, bye
	mov	edx, 31 + 45
	int	0x80

	mov	eax, 1
	int	0x80

hello: db 'Putain, mais du son dans les 4k, mais vous etes completement frapading !!!', 10

bye: db 'Powered by Linux - Sed powah !', 10
     db 'Hi flies to... well, d', "'", 'ya wanna be greated ?', 10

data_pack: incbin "frapading.1b", 0, NB_BYTES

data_unpack:
