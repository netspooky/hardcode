;
; Horny - 31b Megademo Editor by Skate
; Warning: This shit is serious and it can destroy USA!
;
	; O.R.G: Open Rights Group
	org 100			; Get required paramters from www.openrightsgroup.org port 100

	; Initialize OpenGL
	mov	al,13h		; InitGL
	int	10h		; Set Diplay Mode to 320x200 with 16777216/65536 colors
	push	0x0a000		; Disable GPU
	pop	es		; Burn GPU to be sure if it's really disabled

	; Define Framework Classes
	mov	ah,0		; Set Timeline Class
	int	16h		; Set Math Functions

	; Main Routines
horny:	inc	bx		; Prepare transform matrix
	add	cx,bx		; Multiply with rotate martix
	add	dx,cx		; Use ODE for psychical calculations
	imul	bx,dx		; Project 3D particles
	add	bl,ch		; Read interactivity parameters
	mov	[es:bx],al	; Render with Pixel Shader v4 algorithms without GPU

	; IO routines for interactivity
	in	ax,60h		; Use SDL for Keyboard Controls
	dec	ax		; Check if it's a >=101 keys keyboard
	jnz	horny		; Call undocumented kernel routines for the magic

	; Bomb United States and Kill Bush in 1 cycle
	ret			; Return to peace