; multitasking stripes - by owlwolfx 2017 - public domain
; compile with: nasm mts.asm -o mts.com
; run with: dosbox -c "config -set \"cpu cycles=max\"" mts.com

org 0x100

section .text

; main

main:

	; video

	mov	ax,0x0013
	int	0x10

	; timer

	cli

	xor	ax,ax
	mov	es,ax
	mov	di,8*4

	mov	ax,timer
	stosw
	mov	ax,cs
	stosw

	; init flags

	cld
	pushf
	pop	word [task1+12]

	std
	pushf
	pop	word [task2+12]

	; es

	mov	ax,0xa000
	mov	es,ax

	; enable timer, wait for first task switch

	sti
.wait:	jmp	.wait

; graphics

graphics:

	mov	bl,64

.loopa:	cli

	push	ax
	push	bx
	push	di

	mov	cx,320*100
	mov	dx,320

.loopb:	stosb

	dec	bl
	jnz	.nexta
	xchg	al,ah
	mov	bl,32

.nexta:	dec	dx
	jnz	.nextb
	inc	bl
	mov	dx,320

.nextb:	loop	.loopb

	pop	di
	pop	bx
	pop	ax

	dec	bl
	jnz	.nextc
	mov	bl,64

.nextc:	sti

	mov	dx,bp
.wait:	cmp	dx,bp
	je	.wait

	jmp	.loopa

; timer

timer:

	; task switch

	push	bp

	cmp	word [task],task1
	jb	.next

	; save

.save:	mov	bp,[task]

	mov	[bp+0],ax
	mov	[bp+2],bx
	mov	[bp+4],cx
	mov	[bp+6],dx
	mov	[bp+8],si
	mov	[bp+10],di

	add	sp,2		; pop 1 times (bp)
	pop	word [bp+14]	; pop instruction pointer
	add	sp,2		; pop 1 times (cs)
	pop	word [bp+12]	; pop flags
	sub	sp,8		; push 4 times

	; next

.next:	add	word [task],16
	cmp	word [task],task2
	jbe	.load
	mov	word [task],task1

	; load

.load:	mov	bp,[task]

	mov	ax,[bp+0]
	mov	bx,[bp+2]
	mov	cx,[bp+4]
	mov	dx,[bp+6]
	mov	si,[bp+8]
	mov	di,[bp+10]

	add	sp,8		; pop 4 times
	push	word [bp+12]	; push flags
	sub	sp,2		; push 1 times (cs)
	push	word [bp+14]	; push instruction pointer
	sub	sp,2		; push 1 times (bp)

	; end

.end:	pop	bp
	dec	bp

	push	ax
	mov	al,0x20
	out	0x20,al
	pop	ax

	iret

; data

section .data

task:	dw	task1-16
; registers (ax, bx, cx, dx, si, di), flags, instruction pointer (8 words = 16 bytes)
task1:	dw	0x010f,0,0,0,0,0x0000,0,graphics
task2:	dw	0x040f,0,0,0,0,0xf9ff,0,graphics
