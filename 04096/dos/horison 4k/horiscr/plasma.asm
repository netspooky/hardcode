;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;@@@@@@@@@@@@@@@@@@ Plasma generator routine for flatmode @@@@@@@@@@@@@@@@@@@@@@
;@@@@@@@@@@@@@@@@@@@@@@ Written by Khamoon / Tube27 '98 @@@@@@@@@@@@@@@@@@@@@@@@
;@@@@@@@@@@@@@@ plasma is 256x256 size and is drawn in [EBX] @@@@@@@@@@@@@@@@@@@
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

plmax	equ 255
plmin	equ 0
plseed	equ 1204h
plm1	equ 5
plm2	equ 3


gpix PROC
	mov	al,es:[bx]	;ebx
	and	ax,0ffh
	jnz	short @NiePixPlasm
ncol:
	mov	ax,[bp-22]
	add	di,ax
	add	ax,ax
	add	si,9248h
	ror	si,3
	mul	si

	mov	ax,di	
	sub	ax,dx
	shr	ax,cl
	cmp	ax,plmax
	jb	short @we1
	mov	ax,plmax
@we1:
	cmp	ax,plmin
	ja	short @we2
	mov	ax,plmin
@we2:
	mov	es:[bx],al
@NIePixPlasm:
	ret
ENDP
;###############################################################################
Plasma	PROC
	xor	di,di
	xor	ax,ax
	mov	cx,0ffffh
	rep	stosb
	
	mov	bp, offset plasma_points+22
	
	mov	si,plseed						;Seed
	mov	dword ptr [bp-4],0*65536+0		;px1,py1
	mov	dword ptr [bp-8],256*65536+256	;px2,py2

	call	plasma1
	ret
	
plasma1:
	mov	ax,[bp-8]
	sub	ax,[bp-4]
	cmp	ax,2
	jge	short @poki1
	mov	ax,[bp-6]
	sub	ax,[bp-2]
	cmp	ax,2
	jl	@PlasmEnd
@poki1:
	xor	ah,ah
	mov	bh,[bp-2]
	mov	bl,[bp-4]
	mov	al,es:[bx]	;ebx
	mov	[bp-14],ax

	mov	bh,[bp-6]
	mov	al,es:[bx]	;ebx
	mov	[bp-16],ax

	mov	bl,[bp-8]
	mov	al,es:[bx]	;ebx
	mov	[bp-20],ax
	
	mov	bh,[bp-2]
	mov	al,es:[bx]	;ebx
	mov	[bp-18],ax

	mov	ax,[bp-8]
	add	ax,[bp-4]
	shr	ax,1
	mov	[bp-12],ax
	mov	ax,[bp-6]
	add	ax,[bp-2]
	shr	ax,1
	mov	[bp-10],ax

	mov	ax,[bp-8]
	sub	ax,[bp-4]
	add	ax,[bp-6]
	sub	ax,[bp-2]
	mov	dx,plm1
	mul	dx
;	add	ax,ax
	mov	bx,plm2
	div	bx
	mov	[bp-22],ax

	mov	cl,1

	mov	bh,[bp-2]
	mov	bl,[bp-12]
	mov	di,[bp-14]
	push	di
	add	di,[bp-18]
	call	gpix

	mov	bh,[bp-10]
	mov	bl,[bp-4]
	pop	di
	add	di,[bp-16]
	call	gpix

	mov	bl,[bp-8]
	mov	di,[bp-20]
	push	di
	add	di,[bp-18]
	call	gpix

	mov	bh,[bp-6]
	mov	bl,[bp-12]
	pop	di
	add	di,[bp-16]
	push	di
	call	gpix

	inc	cl
	pop	di
	add	di,[bp-14]
	add	di,[bp-18]
	mov	bh,[bp-10]
	mov	bl,[bp-12]
	call	ncol

	mov	eax,[bp-12]

	push	eax
	push	dword ptr [bp-4]
	push	dword ptr [bp-8]
		mov	dword ptr [bp-8],eax
		call	plasma1
	pop	dword ptr [bp-8]
	pop	dword ptr [bp-4]
	pop	eax
	push	eax
	push	dword ptr [bp-4]
	push	dword ptr [bp-8]
		ror	eax,16
		mov	[bp-6],eax
		call	plasma1
	pop	dword ptr [bp-8]
	pop	dword ptr [bp-4]
	pop	eax
	push	eax
	push	dword ptr [bp-8]
		mov	[bp-8],ax
		shr	eax,16
		mov	[bp-2],ax
		call	plasma1
	pop	dword ptr [bp-8]
	pop	dword ptr [bp-4]
	call	plasma1
@PlasmEnd:
	ret
Plasma	ENDP


