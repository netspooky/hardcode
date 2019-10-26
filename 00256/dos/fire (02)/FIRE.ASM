; This code isn't as fast as it should be, but, you know, size...
; It was compiled with tasm 3.2 and tlink 5.1

.386
locals @@

assume cs:code_seg, ds:code_seg

_PROFILE	equ	0

; CONSTANS ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

; Screen size constants. Linear 320x100.
_screen_X_size			equ	320
_screen_Y_size			equ	100

; Sizes of the fire itself.
_fire_X_size			equ	320
_fire_Y_top_lines		equ	20
_fire_Y_size			equ	70	; the code is too slow...
_fire_offscreen_X		equ	4	; 32-bit aligned for speed
_fire_offscreen_Y		equ	4
_fire_offscreen_Y		equ	4
_fire_sum_elements		equ	4	; hardcoded, BTW

_fire_decrement			equ	13
_fire_hot_spot_probability	equ	08000h
	; Each point in the bottom lines has 0a000h/10000h chance to become
	; a 'hot spot'.
_fire_non_hot_spot_color	equ	070707070h

; €€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€

code_seg	segment para public use16 'Code'
org 100h

; CODE ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

BORDER	macro R, G, B
ifdef _PROFILE
	if _PROFILE
		push	ax
		push	ds
		mov	dx,3c8h
		mov	al,0
		out	dx,al
		inc	dx
		mov	al,&R
		out	dx,al
		mov	al,&G
		out	dx,al
		mov	al,&B
		out	dx,al
		pop	dx
		pop	ax
	endif
endif
endm

INIT_FIRE_BUFFER	macro
; Allocate fire buffer and clear it.
	mov	ax,cs
	add	ax,1000h
	mov	ds,ax
	mov	es,ax
	xor	ax,ax
	mov	cx,8000h
	mov	di,ax
rep	stosw
endm

MAKE_PALETTE	macro
local	@@build_pal_00_1f, @@build_pal_20_5f, @@build_pal_60_bf
; Palette looks like this:
; 00-1f: black to red
; 20-5f: red to yellow
; 60-bf: yellow to white
; c0-ff: white
; This thing wastes a lot of space. :(

	xor	ax,ax
	xor	bx,bx
	xor	dx,dx
	lea	si,[palette]
	mov	di,si

; Black to red.
	mov	cx,20h
@@build_pal_00_1f:
	call	Write_to_palette
	add	al,02h
	loop	@@build_pal_00_1f
	dec	al			; Back to 3fh.

; Red to yellow.
	mov	cl,40h
@@build_pal_20_5f:
	call	Write_to_palette
	inc	bl
	add	dx,40h
	loop	@@build_pal_20_5f
	dec	bl			; Back to 3fh.

; Yellow to white.
	mov	cl,60h
@@build_pal_60_bf:
	call	Write_to_palette
	add	dx,80h
	loop	@@build_pal_60_bf

; White.
	mov	cl,3*40h
rep	stosb

	mov	al,0
	mov	dx,3c8h
	out	dx,al
	mov	cx,3*100h
	inc	dx
rep	outsb
; Set 100 lines.
	mov	ax,0309h
	mov	dl,0d4h
	out	dx,ax
endm

MAKE_DIV_TABLE	macro
local	@@next_entry, @@color_OK
; CX=0
; DI=offset [division_table]

; Generates a lookup table to avoid SUBs and stuff in the actual inner loop.
@@next_entry:
	mov	ax,cx
	sub	ax,_fire_decrement
	sar	ax,2
	jge	@@color_OK
	mov	al,1
@@color_OK:
	stosb
	inc	cx
	cmp	cx,_fire_sum_elements*256
	jb	@@next_entry
endm

WAIT_RETRACE	macro
local	@@wait_retrace_1, @@wait_retrace_2
	BORDER	0, 0, 0
	mov	dx,3dah
; Correct retrace checking sacraficed for size... :(
;@@wait_retrace_1:
;	in	al,dx
;	test	al,8
;	jnz	@@wait_retrace_1
@@wait_retrace_2:
	in	al,dx
	test	al,8
	jz	@@wait_retrace_2
	BORDER	30, 30, 30
endm

CALC_FIRE	macro
local	@@init_next_pixel, @@hot_spot, @@next_line, @@next_pixel
; Create hotspots.
; The random number algo I use is from dLux/Hydrogen, he got it from
; Tomcat/Abaddon, he got it from...
; In it's original 32-bit form it produced quite balanced numbers, and it
; still does, I hope.
	mov	si,(_fire_Y_top_lines+_fire_Y_size+_fire_offscreen_Y-2)*(_fire_X_size+2*_fire_offscreen_X)
	mov	cx,(_fire_X_size+2*_fire_offscreen_X)/4
@@init_next_pixel:
	mov	ax,bp
	mov	dx,5d45h	;31415621 and 0ffffh
	inc	ax
	mul	dx
	mov	bp,ax
	xor	eax,eax
	dec	eax
	cmp	bp,_fire_hot_spot_probability
	jb	@@hot_spot
	mov	eax,_fire_non_hot_spot_color
@@hot_spot:
	mov	[si],eax
	mov	[si+_fire_X_size+2*_fire_offscreen_X],eax
	add	si,4
	loop	@@init_next_pixel

; Move lines upwards.
	xor	ax,ax
	mov	dx,_fire_Y_size+_fire_offscreen_Y-2
	mov	di,_fire_Y_top_lines*(_fire_X_size+2*_fire_offscreen_X)+1
@@next_line:
	mov	cx,_fire_X_size+2*(_fire_offscreen_X-1)
@@next_pixel:
	movzx	bx,byte ptr [di+2*(_fire_X_size+2*_fire_offscreen_X)]
; These MOVs & ADDs are again sacraficed for size.
;	mov	al,[di+_fire_X_size+2*_fire_offscreen_X-1]
;	add	bx,ax
;	mov	al,[di+_fire_X_size+2*_fire_offscreen_X]
;	add	bx,ax
;	mov	al,[di+_fire_X_size+2*_fire_offscreen_X+1]
;	add	bx,ax
; This code with LEA and LODSBs is a pain in the ass, but it's a bit shorter.
	lea	si,[di+_fire_X_size+2*_fire_offscreen_X-1]
	lodsb
	add	bx,ax
	lodsb
	add	bx,ax
	lodsb
	add	bx,ax
	mov	al,cs:division_table[bx]
	mov	[di],al
	inc	di
	loop	@@next_pixel
	inc	di
	inc	di
	dec	dx
	jnz	@@next_line
endm

COPY_FIRE	macro
local	@@next_line
; DS: fire buffer
; ES: 0a0000h
; Just copy everything from the buffer to the screen.
	mov	si,_fire_Y_top_lines*(_fire_X_size+2*_fire_offscreen_X)+_fire_offscreen_X
	mov	di,_fire_Y_top_lines*_screen_X_size
	mov	bx,_fire_Y_size
@@next_line:
	mov	cx,_fire_X_size/4
rep	movsd
	add	si,2*_fire_offscreen_X
	dec	bx
	jnz	@@next_line
endm

; ENTRY POINT ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

Come_on_fire_Light_my_babe:
	mov	ax,0013h
	int	10h

	MAKE_PALETTE			; And set 100 lines.
; CX=0
; SI=DI=offset [division_table]
	MAKE_DIV_TABLE

	INIT_FIRE_BUFFER
; AX=CX=0
; DS: fire buffer (don't forget, otherwise it hurts)

	push	0a000h
	pop	es
@@fire_loop:
	CALC_FIRE
	WAIT_RETRACE
	COPY_FIRE
	in	al,60h
	cmp	al,1
	jne	@@fire_loop
	
; EXIT ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞

	mov	ax,0003h
	int	10h
	ret

; PROCEDURES ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

Write_to_palette:
; Used when calculating the palette.
	stosb
	mov	[di],bl
	inc	di
	mov	[di],dh
	inc	di
	ret

; DATA ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

palette		label	byte
	db	100h dup (?, ?, ?)
division_table	label	byte
	db	_fire_sum_elements*100h dup (?)

code_seg	ends

; €€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€

end Come_on_fire_Light_my_babe
