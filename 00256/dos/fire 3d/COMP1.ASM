;
;"Fire 3d" message version => 218 bytes
;	no message version => 203 bytes
;
;done by messer | bs369@freenet.hsc.colorado.edu
;

	IDEAL
	P386N

SEGMENT CODE
assume	cs:code, ds:code
org	100h

START:

	mov	bx,cs
	inc	bh
	mov	es,bx

	mov	bp,9877h			;betah seed then .com inital value
	mov	ch,200
	rep	stosw

	mov	al,13h
	int	10h

	mov	dx,offset Msg			;\  useless stuff
	mov	ah,9				; >
	int	21h				;/ cute little "fire 3d" message

	mov	ds,bx

	mov	dx,03c9h
	xchg	ax,cx
@MkPal:
	out	dx,al
	out	dx,al
	out	dx,al
	inc	ax
	jnz	short @MkPal

	mov	si,20*256+6			;where we'd get the fire
	xchg	ax,bx				;clear bx

;--== main loop ==--------

@RepVoxel:

;--== FIRE ==-------------

	xchg	ax,bp				;get seed
@@CreateRLine:
	mov	dx,857Bh
	add	dx,[ds:bx]
	mul	dx
	inc	ax
	mov	[ds:bx],ax
	add	bl,2				;inc bl?
	jnz	short @@CreateRLine
	xchg	ax,bp				;save seed

;----------------------------------------

	dec	bl				;bx = 255
	mov	di,256*81
@DoFire:
	movzx	ax,[di+2]
@F10:
	add	al,[di+bx]			;255
	adc	ah,0
	inc	bx
	add	al,[di+bx]			;256
	adc	ah,0
	inc	bx
	add	al,[di+bx]			;257
	adc	ah,0
	neg	bx
	js	short @F10

	add	al,[di-2]
	adc	ah,0

	shr	ax,3
	jz	short @F20
	cmp	al,32
	ja	short @F20
	dec	ax
@F20:
	mov	[di+512],al

	dec	di
	jnz	short @DoFire

;--== Wannabe Voxel ==------------

	push	0a000h
	pop	es

	;bx = 255 = X counter
@MakeVoxel:
;	 mov	 bh,62
	cwd						;clear dx or something
	mov	ah,62+22+62
	sub	ah,[si+(62 shl 8)+255]
	mov	cl,61					;Y Counter (no clear ch)
@XXX:

	mov	bh,cl

	mov	al,[si+bx-3]
	add	al,20
	sub	al,[si+bx+3]
	mov	dl,20
	sub	dl,cl
	jnle	short @V1
	xor	dl,dl
@V1:
	sub	al,dl
	jnle	short @V2
	xor	al,al
@V2:

	mov	dl,63+22
	sub	dl,[si+bx]
	add	dl,cl

	xor	bh,bh

	lea	di,[edx*4+edx]
	shl	di,6
	add	di,bx
	add	di,(320-256)/2

@Fill:
	cmp	dl,ah
	jae	short @EndFill
	stosb
	dec	ah
	add	di,320-1
	jmp	short @Fill
@EndFill:
	loop	@XXX

	mov	cl,20
	xor	al,al
@ACK:
	stosb
	sub	di,320+1
	loop	@ACK

	dec	bx
	jnz	short @MakeVoxel

	in	al,60h
	dec	al
	jnz	near @RepVoxel

	mov	ax,3h
	int	10h

	ret

;----------------------------------------

Msg	db	"Fire 3D$"                      ;Argl, byte eater

ENDS	CODE
END	START
