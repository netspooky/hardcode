; code: Majuma, majuma@wp.pl
; updated: 03/11/02

.386p
locals

b	equ byte ptr
w	equ word ptr
d	equ dword ptr
o	equ offset


code32 segment para public use32
	assume cs:code32, ds:code32

_main:
	mov	eax, 64000 + 512 * 4 + 320 * 4
	call	alloc_mem
	or	eax, eax
	jnz	mem_ok
	ret
mem_ok:
	mov	d [MemHandle], eax
	mov	d [FrameBuffer], ebx
	add	ebx, 64000
	mov	d [CosineTable], ebx

	finit
	fldz
	mov	ecx, 512
cos_make:
	fld	st
	fcos
	fmul	d [_63]
	fistp	d [ebx]
	fadd	d [DeltaAngle]
	add	ebx, 4
	loop	cos_make
	ffree	st

	mov	d [TempTable], ebx


	call	set_13h

	mov	edx, 03c8h
	xor	eax, eax
	out	dx, al
	inc	edx
	mov	ecx, 127
SetPalette1:
	out	dx, al
	out	dx, al
	xor	al, al
	out	dx, al
	inc	ah
	mov	al, ah
	shr	al, 1
	loop	SetPalette1
	mov	ecx, 128
SetPalette2:
	out	dx, al
	out	dx, al
	xor	al, al
	out	dx, al
	dec	ah
	mov	al, ah
	shr	al, 1
	loop	SetPalette2

MainLoop:

	mov	edi, d [TempTable]
	mov	ecx, 320
	mov	eax, d [p_x1]
	mov	d [tp_x1], eax
	mov	eax, d [p_x2]
	mov	d [tp_x2], eax
MakeTemp:
	mov	esi, d [tp_x1]
	and	esi, 511
	shl	esi, 2
	add	esi, d [CosineTable]
	lodsd
	mov	ebx, eax
	mov	esi, d [tp_x2]
	and	esi, 511
	shl	esi, 2
	add	esi, d [CosineTable]
	lodsd
	add	eax, ebx
	stosd
	add	d [tp_x1], 1
	add	d [tp_x2], 2
	dec	ecx
	jnz	MakeTemp

	mov	edi, d [FrameBuffer]
	mov	edx, 200
	mov	eax, d [p_y1]
	mov	d [tp_y1], eax
	mov	eax, d [p_y2]
	mov	d [tp_y2], eax
PlasmaY:
	mov	ecx, 320
	mov	ebx, d [TempTable]
	mov	esi, d [tp_y1]
	and	esi, 511
	shl	esi, 2
	add	esi, d [CosineTable]
	lodsd
	mov	ebp, eax
	mov	esi, d [tp_y2]
	and	esi, 511
	shl	esi, 2
	add	esi, d [CosineTable]
	lodsd
	add	ebp, eax
PlasmaX:
	mov	eax, d [ebx]
	add	eax, ebp
	stosb
	add	ebx, 4
	dec	ecx
	jnz	PlasmaX
	add	d [tp_y1], 1
	add	d [tp_y2], 2
	dec	edx
	jnz	PlasmaY

	call	wait_vr
	call	copy_buffer
	

	add	d [p_x1], 1
	add	d [p_x2], -2
	add	d [p_y1], 1
	add	d [p_y2], -3


	in	al, 60h
	dec	al
	jnz	MainLoop

	call	set_03h

	mov	eax, d [MemHandle]
	call	free_mem
	ret

;------------------------------------------------------------

include kernel\kernel.inc
include alloc.asm
include graph.asm

_63		dd 63.0
DeltaAngle	dd 0.0122718 ; pi / 256

MemHandle	dd ?
CosineTable	dd ?
TempTable	dd ?

p_x1		dd ?
p_x2		dd ?
p_y1		dd ?
p_y2		dd ?

tp_x1		dd ?
tp_x2		dd ?
tp_y1		dd ?
tp_y2		dd ?


code32 ends
end
