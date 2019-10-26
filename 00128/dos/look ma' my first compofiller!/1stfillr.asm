; Look ma' my first compofiller!
; Made by Vikó for Function 2013

org 100h

;Set mode to 13h (VGA 320x200 256 color palette)
mov		al, 13h
int		10h

; Set ES to 0A000h, zero DI to index into framebuffer
push	0A000h
pop		es

xor		di, di

MAIN_LOOP:
; Compute color for pixel
; function:
;		tmp = (x + translation_x) % 16
;		color_x = tmp > 7 ? (16 - tmp) : tmp			// same for color_y
;		final_color = color_x + color_y + (bias % 128)	// bias is animated

mov		ax, di
mov		cx, ax
mov		bx, word [bp-2]
add		cx, bx
and		cx, 15
cmp		cx, 8
jb		BELOW_8_1
neg		cx
add		cx, 16
BELOW_8_1:

mov		ax, di
mov		bx, 320
xor		dx, dx
div		bx
mov		bx, word [bp]
add		ax, bx
and		ax, 15
cmp		ax, 8
jb		BELOW_8_2
neg		ax
add		ax, 16
BELOW_8_2:

mov		bx, word [bp-4]
and		bx, 127
add		cx, bx
add		cl, al

mov		byte [es:di], cl


; Paint next pixel
inc		di

; If at the last pixel, go back to first
cmp		di, 0FA00h
;test	di, di
jnz		MAIN_LOOP
xor		di, di

; Translate
mov		bx, word [bp]
add		bx, 3
mov		word [bp], bx

mov		bx, word [bp-2]
inc		bx
mov		word [bp-2], bx

mov		bx, word [bp-4]
inc		bx
mov		word [bp-4], bx

; Wait for V-blank
WAIT_VBLANK:
mov		dx, 3DAh
in		al, dx
and		al, 8
jz		WAIT_VBLANK

; Check ESC key, exit if down
in		al, 60h
dec		al
jnz		MAIN_LOOP
int		20h