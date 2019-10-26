.386p
locals

code32 segment para public use32
	assume cs:code32, ds:code32

clear_buffer proc
	mov	edi,frame_buffer
	xor	eax,eax
	mov	ecx,64000/4
	cld
	rep	stosd
	ret
endp

copy_buffer proc
	mov	esi,frame_buffer
	mov	edi,_a0000h
	mov	ecx,64000/4
	cld
	rep	movsd
	ret
endp

retrace proc
	mov	edx,03dah
@@r1:
	in	al,dx
	test	al,8
	jz	@@r1
@@r2:
	in	al,dx
	test	al,8
	jnz	@@r2
	ret
endp

;------------------------------------------------------------
;	in:	esi - offset to palette
;	out:	none
;------------------------------------------------------------

set_palette proc
	mov	edx,03c8h
	xor	eax,eax
	out	dx,al
	inc	edx
	mov	ecx,768
	cld
	rep	outsb
	ret
endp

;------------------------------------------------------------
;	in:	edi - offset to palette
;	out:	none
;------------------------------------------------------------

get_palette proc
	mov	edx,03c7h
	xor	eax,eax
	out	dx,al
	add	edx,2
	mov	ecx,768
	cld
	rep	insb
	ret
endp

_a0000h		dd ?
frame_buffer	dd ?

code32 ends