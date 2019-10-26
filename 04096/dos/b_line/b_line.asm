;------------------------------------------------------------
;	b_line
;	Mikolaj Felix 03/11/01
;	mfelix@polbox.com
;------------------------------------------------------------

.model tiny
.386
locals

.code
org 100h

start:
	call	alloc_seg
	or	ax,ax
	jz	quit_me
	mov	buffer_seg,ax
	
	call	calc_way

	; init palette
	mov	di,offset fire_pal
	xor	ax,ax
	mov	cx,64
sp1:
	mov	al,ah
	stosb
	xor	al,al
	stosb
	stosb
	inc	ah
	loop	sp1
	xor	ax,ax
	mov	cx,64
sp2:
	mov	al,63
	stosb
	mov	al,ah
	stosb
	xor	al,al
	stosb
	inc	ah
	loop	sp2
	xor	ax,ax
	mov	cx,64
sp3:
	mov	al,63
	stosb
	stosb
	mov	al,ah
	stosb
	inc	ah
	loop	sp3
	mov	al,63
	mov	cx,64*3
	cld
	rep	stosb

	mov	ax,13h
	int	10h
	mov	si,offset fire_pal
	call	set_palette

	call	clear_buffer
main_loop:

	; color
	push	word ptr 255
	; x2, y2
	mov	bx,way_pos
	mov	di,bx
	and	bx,255
	shl	bx,2
	push	word ptr line_way[bx+2]
	push	word ptr line_way[bx]
	; x1, y1
	sub	di,128
	and	di,255
	shl	di,2
	push	word ptr line_way[di+2]
	push	word ptr line_way[di]
	call	draw_line

	call	blur
	call	retrace
	call	copy_buffer

	inc	way_pos

	in	al,60h
	dec	al
	jnz	main_loop

	mov	ax,03h
	int	10h

	mov	ax,buffer_seg
	call	free_seg
quit_me:
	mov	ah,4ch
	int	21h

blur proc
	push	ds
	push	es
	mov	ax,buffer_seg
	mov	ds,ax
	mov	es,ax
	xor	di,di

	xor	ax,ax
	xor	bx,bx
@@do_blur:
	mov	al,byte ptr [di-1]
	mov	bl,byte ptr [di+1]
	add	ax,bx
	mov	bl,byte ptr [di-320]
	add	ax,bx
	mov	bl,byte ptr [di+320]
	add	ax,bx
	shr	ax,2
	stosb
	or	di,di
	jnz	@@do_blur

	pop	es
	pop	ds
	ret
endp

;------------------------------------------------------------
;	in:	x1,y1,x2,y2,color
;	out:	none
;------------------------------------------------------------

draw_line proc

@@x1 equ word ptr [bp+4]
@@y1 equ word ptr [bp+6]
@@x2 equ word ptr [bp+8]
@@y2 equ word ptr [bp+10]
@@color equ word ptr [bp+12]

	push	bp
	mov	bp,sp

	push	es
	mov	es,buffer_seg

	mov	ax,@@x1
	cmp	ax,@@x2
	je	@@ver_line

	mov	ax,@@y1
	cmp	ax,@@y2
	je	@@hor_line

	mov	ax,@@x2
	sub	ax,@@x1
	or	ax,ax
	jge	@@ok1
	neg	ax
@@ok1:
	mov	bx,@@y2
	sub	bx,@@y1
	or	bx,bx
	jge	@@ok2
	neg	bx
@@ok2:

	cmp	ax,bx
	jb	@@dy_bigger

	; line is more horizontal
	mov	ax,@@x1
	cmp	ax,@@x2
	jl	@@ok3
	
	xchg	ax,@@x2
	mov	@@x1,ax

	mov	ax,@@y1
	xchg	ax,@@y2
	mov	@@y1,ax
@@ok3:
	mov	ax,@@y2
	sub	ax,@@y1
	movsx	eax,ax
	shl	eax,SHIFT_CONST
	cdq
	mov	bx,@@x2
	sub	bx,@@x1
	movsx	ebx,bx
	idiv	ebx
	mov	edx,eax			; edx - delta_y
					; = ((y2-y1)<<SHIFT_CONST)/(x2-x1)
	movsx	ebx,@@y1
	shl	ebx,SHIFT_CONST		; ebx - curr_y
	mov	cx,@@x1
	cmp	cx,@@x2
	jge	@@quit
@@draw1:
	mov	eax,ebx
	sar	eax,SHIFT_CONST
	mov	di,ax
	shl	ax,6
	shl	di,8
	add	di,ax
	add	di,cx
	mov	ax,@@color
	stosb

	add	ebx,edx
	inc	cx
	cmp	cx,@@x2
	jl	@@draw1

	jmp	@@quit

@@dy_bigger:

	; line is more vertical
	mov	ax,@@y1
	cmp	ax,@@y2
	jl	@@ok4
	
	xchg	ax,@@y2
	mov	@@y1,ax

	mov	ax,@@x1
	xchg	ax,@@x2
	mov	@@x1,ax
@@ok4:
	mov	ax,@@x2
	sub	ax,@@x1
	movsx	eax,ax
	shl	eax,SHIFT_CONST
	cdq
	mov	bx,@@y2
	sub	bx,@@y1
	movsx	ebx,bx
	idiv	ebx
	mov	edx,eax			; edx - delta_x
					; = ((x2-x1)<<SHIFT_CONST)/(y2-y1)
	movsx	ebx,@@x1
	shl	ebx,SHIFT_CONST		; ebx - curr_x
	mov	cx,@@y1
	cmp	cx,@@y2
	jge	@@quit
@@draw2:
	mov	ax,cx
	mov	di,ax
	shl	ax,6
	shl	di,8
	add	di,ax
	mov	eax,ebx
	sar	eax,SHIFT_CONST
	add	di,ax
	mov	ax,@@color
	stosb

	add	ebx,edx
	inc	cx
	cmp	cx,@@y2
	jl	@@draw2

	jmp	@@quit

@@ver_line:
	mov	ax,@@y1
	cmp	ax,@@y2
	je	@@quit
	jl	@@v_ok

	xchg	ax,@@y2
	mov	@@y1,ax
@@v_ok:
	mov	di,@@y1
	mov	ax,di
	shl	di,6
	shl	ax,8
	add	di,ax
	add	di,@@x1

	mov	cx,@@y2
	sub	cx,@@y1
	mov	ax,@@color
@@draw_ver:
	stosb
	add	di,319
	dec	cx
	jnz	@@draw_ver

	jmp	@@quit

@@hor_line:
	mov	ax,@@x1
	cmp	ax,@@x2
	je	@@quit
	jl	@@hor_ok

	xchg	ax,@@x2
	mov	@@x1,ax
@@hor_ok:
	mov	di,@@y1
	mov	ax,di
	shl	di,6
	shl	ax,8
	add	di,ax
	add	di,@@x1

	mov	ax,@@color
	mov	ah,al

	mov	cx,@@x2
	sub	cx,@@x1
	sar	cx,1
	jnc	@@draw_hor
	stosb
@@draw_hor:
	rep	stosw

@@quit:
	pop	es

	pop	bp
	ret	10
endp

calc_way proc

@@temp equ word ptr [bp-2]

	push	bp
	mov	bp,sp
	sub	sp,2

	finit
	fldz
	mov	di,offset line_way
	mov	cx,256
@@calc:
	fld	st
	fld	st

	fsin
	fmul	radius_x
	fistp	@@temp
	mov	ax,160
	add	ax,@@temp
	stosw

	fcos
	fmul	radius_y
	fistp	@@temp
	mov	ax,100
	add	ax,@@temp
	stosw

	fadd	delta_a

	dec	cx
	jnz	@@calc
	ffree	st

	mov	sp,bp
	pop	bp
	ret
endp

include libs\mem.asm
include libs\graph.asm

SHIFT_CONST equ 12

.data
	delta_a dd 0.02454369261		; pi/128
	radius_x dd 150.0
	radius_y dd 80.0

	line_way dd 256 dup('A')
	way_pos dw 0

	fire_pal db 768 dup('B')

end start