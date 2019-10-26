;nasm compatimle.
;Code is silly and full of dirty tricks.


org 100h
	mov al, 13h
	int 10h

	call T_HOOK		;Hook subroutine for the sound.

scene_n equ $+1
	push 0a000h
	pop es			;Screen area.
	push 09000h
	pop ds			;sin table.
	push 08000h
	pop fs			;Video buffer.
	push 07000h
	pop gs			;Texture buffer.
				;Total: 192 kB

	
PAL:	shrd bx, cx, 20			;Make palette with four gradients:
	and bl, 0ch
SETCOL_00:
	mov al, cl
	;0 - col=cl^2, 1 - col=cl
	;       -bgr-bgr-bgr-bgr	;grayscale, white-green-black,
	mov dx, 0000001001000011b	;white-blue-black, white-yellow-black.
	bt dx, bx
	jc SETCOL_01
	and al, 3fh
	mul al
	shr ax, 6
SETCOL_01:
	mov dx, 3c9h
	out dx, al
	inc bx
	test bl, 3
	jnp SETCOL_00
	loop PAL

	mov cl, 30
	call TEX01		;Make landscape texture.

	mov si, 395		;Make sin table.
SIN:	mov [bx-512], ch
	add cx, si
	mov ax, 40
	imul cx
	sub si, dx
	inc bx
	jnz SIN

	xor si, si		;reset timer
MLOOP:
	movzx bp, [cs:scene_n]	;Take current scene number
	cmp bp, 12		;If it's 12 - game over.
	je M_EXIT
	call [cs:scenes+bp]
	call NEXT_SCENE		;Check if we need change scene.

	xor cx, cx
COPY:	mov ax, 255		;Clear and copy buffer to video memory.
	xchg al, [fs:di]
	stosb
	loop COPY

	inc si			;si - global timer.
	in al, 60h
	dec ax
	jnz MLOOP
M_EXIT:				;Exit through next subroutine.

;========SCENES============	;Scenes description.


SCENE01:
	call F_PLANET
	cmp si, 1024	;timer 1024	;Each scene has life time.
	ret
SCENE02:
	call F_STARFLD
	mov di, F_WATER
	call F_3D
	cmp si, 256	;timer 256
	ret
SCENE03:
	call F_PLANET
	call F_SUN
	test si, 15
	jnz SCENE03_SH
	dec byte [cs:PL_COL+1]		;Planet motion.
SCENE03_SH:
	cmp si, 1024	;timer 1024
	ret
SCENE04:
	mov di, F_ISLAND
	call F_3D
	cmp si, 1700	;timer 1700
	ret
SCENE05:
	mov di, F_BUSH
	call F_3D
	
	mov ch, 40
L_BUSH:	call TEX_BUSH
	loop L_BUSH
	cmp si, 800	;timer 800
	ret

SCENE06:
	call F_FISH
	cmp si, 1024	;timer 1024
	ret

NEXT_SCENE:				;If scene lifetime is over,
	jne NEXT_SCENE_EXIT
	xor si, si			;reset timer
	mov di, scene_n
	add byte [cs:di], 2		;and change scene.
	cmp byte [cs:di], 8		;If it's F_BUSH,
	jne NEXT_SCENE_EXIT
	call TEX_ZZ			;clear texture,
	mov byte [cs:CORE_R-2], 2	;change voxel height
	mov byte [cs:COPY+1], 0		;and change background color.
NEXT_SCENE_EXIT:
	ret


F_3D:					;Voxel engine.
L0:	mov cx, 50
LP:	mov bx, 319
LX:	mov bp, bx

	push di
	cmp byte [cs:scene_n], 2	;Don't show sky on second scene.
	je L_N2
	mov di, F_SKY
	call CORE
L_N2:
	pop di
	push di
	call CORE			;Make groubd layer.
	pop di
	dec bx
	jns LX
	inc cx
	cmp ch, 2
	jne LP
	ret

;scene_n db 0				;Scene counter and link list
scenes dw SCENE01, SCENE02, SCENE03, SCENE04, SCENE05, SCENE06

%include "i_core.asm"
%include "i_tex.asm"
%include "i_fun.asm"
%include "i_covox.asm"

TIMER:





