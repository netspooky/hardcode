comment #*/
********************************************************************************
				    A
			   256 bytes intro called 

				-= EQC =-

   		     Estrato's Quadratic Circularity


	By:	Arsenij Vodjanov (aka Estrato)
		estrato@hotmail.com

	This intro is optimized for _size_, not for speed. Although
	I'm aware of the fact that the size could be reduced even
	more, I stopped as soon as I achieved my goal - rotating
	pixel sphere moving around the screen.

	P.S. Hehe, I actually squezzed out around 10h b from the code,
	so I made what I originally intended to: a rotating softed pixel
	sphere!... happy now =)
********************************************************************************
/*#

IDEAL
MODEL tiny
p386

	w               EQU     word ptr

	CODESEG
	ORG 100h
Start:
	ASSUME  DS:@CODE
	ASSUME  ES:@CODE

;videomode
	mov     al, 13h
	int     10h
;grey palette
	sub     ax, ax
	mov     dx, 03c8h
	out     dx, al
	inc     dx
	mov	cl, 64
@@ploop:
	out     dx, al
	out     dx, al
	out     dx, al
	inc	ax
	loop    short @@ploop   

;initialize FPU
	FINIT

	push	0A000h
	pop	es

@@bigloop:

;soft/blit buffer
        mov     si, offset screen
        sub     di, di
        sub     ax, ax
	sub	bx, bx
        mov     ch, 252 ;64000+256*2
@@softloop:
        lodsb
	add	al, [si+319]
        mov     bl, [si]
        adc     ax, bx
        mov     bl, [si+2]
        add     ax, bx
        shr     ax, 2
        stosb
	mov	[si], al
        loop    short @@softloop

;angle
	inc	[angle]
	fild    [angle]
	fidiv	[w _64]
	fsincos
	fimul   [w _64]
	fistp   [cosv]
	fimul   [w _64]
	fistp   [sinv]

	mov     ch, 2    ; _Verts=256*2
@@VertexLoop:

; calc vertex on a sfere
	mov     [v], cx
	fild    [v]
	fsincos
	fimul   [w _64]
	fistp   [y]
	fimul   [w _64]
	fist	[sv]

	fimul	[w _64]
	fsincos
	
	fimul   [sv]
	fistp   [x]
	fimul   [sv]
	fistp   [z]

; rotate vertex
	mov     si, [sinv]
	mov     di, [cosv]

	mov     bx, [x]
	push	bx
	imul    bx, si  ;[w sinv]
	mov     ax, [z]
	imul    di      ;[w cosv]
	sub     ax, bx
	sar     ax, 6
	mov     bp, ax  ;bp=iz

	mov     bx, [y]
	imul    bx, si  ;[w sinv]
	mov     ax, bp  ;bp=iz
	imul    di      ;[w cosv]
	add     ax, bx
	sar	ax, 7	;color=z/2=ax/128
	pop	bx	;[x]
	push    ax      ;mov    [z], ax

	imul    bx, di  ;[w cosv]
	mov     ax, [z]
	imul    si      ;[w sinv]
	add     ax, bx
	sar     ax, 6
	push    ax      ;mov    [x], ax
	
	mov     bx, bp  ;bp=iz
	imul    bx, si  ;[w sinv]
	mov     ax, [y]
	imul    di      ;[w cosv]
	sub     ax, bx
	sar     ax, 6

;"project" vertex
	sar	si, 1
	add     ax, 100
	add	ax, si
	imul	ax, 320
	pop     bx      ;[x]
	add     ax, bx
	add	di, ax

;get color and plot
	pop     ax      ;mov    ax, [z]
	add	al, 32
	mov	[di], al	;ds:di

	dec	cx
	jnz	@@vertexLoop

;check if any key is pressed
	mov	ah, 01
	int	16h
	jz	@@bigloop
	
;set textmode and exit
	mov     ax, 03h
	int     10h

	ret
;------------------------------------------------------------------------------
; Data
;
	_64	DW	63
	angle	DW	?
	v       DW      ?
	sinv    DW      ?
	cosv    DW      ?
	sv      DW      ?
	x       DW      ?
	y       DW      ?
	z       DW      ?
	dummy	DB	270 dup(?)
	Screen  DB      64000 dup(?)
;
END Start
