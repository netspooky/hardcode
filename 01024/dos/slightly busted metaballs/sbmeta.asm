; Slightly busted metaballs
;
; by Mikael Kalms (mikael@kalms.org) on 2001-12-01
;
; For EFNet #asm compo 5: make a dos demo/game/effect in max 1kB
;
;
; This piece of code was supposed to show a set of balls which blob together
; when getting close to each other, often referred to as 'metaballs'.
; Marching tetrahedrons was used to polygonize the scalar field. Unfortunately
; the implementation is broken somewhere; the end result is not quite the expected.
; I don't have time to track the error down, so this will have to do as-is.
;
; Marching tetrahedrons was chosen over marching cubes because mtetras has
; fewer 'unique' cases that need to be specified by hand, smaller code
; implementation, and I was curious as to how the end result would look.
;
; Assembles/links with TASM 4/TLINK 7.


b		EQU	byte ptr
w		EQU	word ptr
d		EQU	dword ptr

FIELDFUNC	EQU	1			; Set to 1 for 1/dist^2, and to 2 for dist^2


		LOCALS	@@
		.MODEL	TINY
		.CODE
		.386

		ORG	100h

;---------------------------------------------------------------------
; Init; set greyscale palette

start:
		mov	ax,ds
		add	ah,10h
		mov	fs,ax

		mov	ax,13h
		int	10h

		mov	dx,3c8h
		xor	ax,ax
		out	dx,al
		inc	dx
@@col:
		out	dx,al
		out	dx,al
		out	dx,al
		inc	al
		jne	@@col


;---------------------------------------------------------------------
; Frame loop

@@frame:

		call	UpdateMetaBallPositions

		call	ClearBackbuffer
;		call	Meta_calcFieldValues		; Fallthrough

		call	Meta_generatePolys

		call	VSync
;		call	CopyBackbufferToScreen		; Fallthrough

		mov	ah,1
		int	16h
		jz	@@frame

;---------------------------------------------------------------------
; Exit sequence

		mov	ax,3
		int	10h

		ret


;---------------------------------------------------------------------
; Wait for vertical retrace

VSync:
		mov	dx,03dah
@@v1:		in	al,dx
		test	al,8
		jz	@@v1
@@v2:		in	al,dx
		test	al,8
		jnz	@@v2
;		ret		; Fallthrough


;---------------------------------------------------------------------
; Copy the rendering buffer to graphics memory

CopyBackbufferToScreen:
		push	es
		push	ds
		push	0a000h
		pop	es
		push	fs
		pop	ds
		xor	si,si
		xor	di,di
		mov	cx,16000
		rep	movsd
		pop	ds
		pop	es
		ret

;---------------------------------------------------------------------
; Subpixeled flat-triangle rasterizer
; inputs:
;	[si+0]	w	triangle colour
;	[si+2]	w	vertex 0 x (as 12.4 fixed point)
;	[si+4]	w	vertex 0 y (as 12.4 fixed point)
;	[si+6]	w	vertex 1 x (as 12.4 fixed point)
;	[si+8]	w	vertex 1 y (as 12.4 fixed point)
;	[si+10]	w	vertex 2 x (as 12.4 fixed point)
;	[si+12]	w	vertex 2 y (as 12.4 fixed point)

DrawTri:
		push	es
		pusha
		mov	di,OFFSET TriEdges		; Reset spantable to all 0's
		xor	ax,ax
		mov	cx,200*2
		rep	stosw

		xor	ecx,ecx

		mov	bx,[si+1*2]			; Draw triangle edges into spantable
		mov	dx,[si+2*2]
		mov	ax,[si+4*2]
		mov	cx,[si+5*2]
		call	@@drawEdge
		mov	bx,[si+4*2]
		mov	dx,[si+5*2]
		mov	ax,[si+7*2]
		mov	cx,[si+8*2]
		call	@@drawEdge
		mov	bx,[si+7*2]
		mov	dx,[si+8*2]
		mov	ax,[si+1*2]
		mov	cx,[si+2*2]
		call	@@drawEdge


		mov	bp,320

		mov	dl,200				; Go through all entries in spantable,
		mov	dh,[si]				; and render any lines which are more
		mov	si,OFFSET TriEdges		; than 0 pixels wide
		push	fs
		pop	es
		xor	di,di
@@span:
		lodsw					; Fetch span from spantable
		xchg	ax,cx
		lodsw

		test	ax,ax				; Clip span against screen X borders
		jns	@@nClipSpanLeft
		xor	ax,ax
@@nClipSpanLeft:
		cmp	cx,bp
		jle	@@nClipSpanRight
		mov	cx,bp
@@nClipSpanRight:

		sub	cx,ax				; Skip spans with width <= 0
		jle	@@skipSpan

		push	di				; Render pixels
		add	di,ax
		mov	al,dh
		rep	stosb
		pop	di

@@skipSpan:
		add	di,bp

		dec	dl
		jnz	@@span

		popa
		pop	es
		ret

;--------------------------------------------------------------------
; Draw triangle-edge into spantable
; inputs:
;	bx	x0	12.4 fixed point
;	dx	y0	12.4 fixed point
;	ax	x1	12.4 fixed point
;	cx	y1	12.4 fixed point


@@drawEdge:
		mov	di,OFFSET TriEdges-2
		cmp	dx,cx				; Check if edge goes downward
		jl	@@drawEdge_left			; If it does, it's on right side
		je	@@drawEdge_skip
		inc	di				; Left-side edge
		inc	di
		xchg	ax,bx
		xchg	cx,dx
@@drawEdge_left:
		sub	ax,bx
		sub	cx,dx

		shl	eax,16
		shl	ebx,16

		push	dx				; Calculate dx/dy gradient
		cdq					; along edge
		idiv	ecx
		xchg	eax,ebx
		pop	dx
		push	dx

		add	cx,dx				; Subpixel pre-step edge
		not	dl
		and	edx,0fh
		imul	edx,ebx
		add	eax,edx
		sar	eax,4
		pop	dx
		sar	cx,4
		sar	dx,4

		sub	cx,dx
		je	@@drawEdge_skip
		mov	bp,dx
		shl	bp,2
		add	di,bp

@@drawEdge_row:					; Draw all edge's rows to spantable

		test	dh,dh			; Skip row if (unsigned) y > 255
		jne	@@drawEdge_nClipY

		push	ax			; Write edge to spantable
		mov	ax,[di]
		mov	[di],eax
		pop	ax

@@drawEdge_nClipY:
		add	di,4

		add	eax,ebx			; Step down edge X counter

		inc	dx
		loop	@@drawEdge_row

@@drawEdge_skip:
		ret



;--------------------------------------------------------------------
; Calculate new positions for the metaballs
;

UpdateMetaBallPositions:
		mov	si,OFFSET start+46
		mov	di,OFFSET MetaBallPositions+2
		mov	cx,[di-2]
		fld	t
		fadd	tstep
		fst	t
		imul	cx,3
@@ball:					; Use our code as random input values,
		fld	st		; and calculate new XYZ positions for
		fiadd	w [si]		; the balls
		lodsw
		fmul	scaledown1
		fsincos
		fstp	st
		fimul	w [si]
		lodsw
		fmul	scaledown2
		fstp	d [di]
		add	di,4

		loop	@@ball
		ret


t		dd	0
tstep		dd	0.1
scaledown1	dd	0.1
scaledown2	dd	0.0002


;--------------------------------------------------------------------
; Clear our rendering-buffer
;

ClearBackbuffer:
		push	es
		push	fs
		pop	es
		xor	di,di
		xor	eax,eax
		mov	cx,16000
		rep	stosd
		pop	es
;		ret			; Fallthrough

;--------------------------------------------------------------------
; Calculate field strength
;
; Iterates through the 3d grid, and at each intersection point in the
; grid, evaluates at that position in space the strength of the force
; field generated by the balls.
;
; The force function is the sum of the force created by each ball on
; point and the force created by each ball is either 1/distance^2
; or distance^2 (depending on which field function you choose).
;

Meta_calcFieldValues:
		push	ax
		push	ax
		push	ax
		mov	bx,sp

		mov	bp,-8

		mov	di,OFFSET MetaFieldStrength
		mov	[bx+4],bp		; Iterate through all field positions,
@@z:		mov	[bx+2],bp		; evaluating the force function
@@y:		mov	[bx],bp			; at each position
@@x:

		mov	si,OFFSET MetaBallPositions
		fldz
		lodsw
		xchg	cx,ax
@@ball:
		fld	d [si]			; Calculate distance^2 between the
		fisub	w [bx]			; intersection point and the ball
		fmul	st,st			; center
		fld	d [si+4]
		fisub	w [bx+2]
		fmul	st,st
		fld	d [si+8]
		fisub	w [bx+4]
		fmul	st,st
		faddp	st(1),st
		faddp	st(1),st
		fadd	fudgeFactor

		IF	FIELDFUNC EQ 1
		fld1				; if you chose fieldfunction 1,
		fdivrp	st(1),st		; convert distance^2 to 1/distance^2
		ENDIF

		faddp	st(1),st		; Add field strength to sum
		add	si,12
		loop	@@ball

		fsub	@@isoSurfaceThreshold	; Subtract threshold value
		fimul	@@isoSurfaceScaler	; .. and scale up a bit, 
		fistp	d [di]			;    we're going integer now

		mov	edx,32767		; Clamp field strength to
		mov	eax,[di]		; -32767 .. +32767
		cmp	eax,edx
		jle	@@nClampMax
		mov	eax,edx
@@nClampMax:
		neg	edx
		cmp	eax,edx
		jge	@@nClampMin
		mov	ax,dx
@@nClampMin:
		stosw

		mov	al,[bx]			; Store grid xyz position too
		stosb
		mov	al,[bx+2]
		stosb
		mov	al,[bx+4]
		stosb

		mov	ax,8

		inc	w [bx]
		cmp	ax,[bx]
		jg	@@x
		inc	w [bx+2]
		cmp	ax,[bx+2]
		jg	@@y
		inc	w [bx+4]
		cmp	ax,[bx+4]
		jg	@@z

		add	sp,6

		ret

		IF	FIELDFUNC EQ 1
@@isoSurfaceThreshold dd 0.3
@@isoSurfaceScaler dw	250
		ELSEIF	FIELDFUNC EQ 2
@@isoSurfaceThreshold dd 300.0
@@isoSurfaceScaler dw	128
		ENDIF


;--------------------------------------------------------------------
; Marching tetrahedrons
;
; This routine will iterate through the 3d grid, and build a polygonized
; representation of the area in space where field function = 0.
;
; For a thorough description of the marching cubes algorithm (which is
; very similar to the marching tetrahedrons algorithm, and more commonly
; known/used), visit www.exaflop.org and search around a bit.
;

Meta_generatePolys:
		mov	si,OFFSET MetaFieldStrength+14*5*16*16+14*5*16+14*5
		xor	ax,ax

		mov	cl,15			; Iterate through all cubes in
@@z:		mov	ch,15			; 3d-grid, performing mtetra
@@y:		push	cx			; polygonization independently
		mov	cl,15			; inside each cube
@@x:

		mov	ch,8			; First do early-out test: check
		mov	di,OFFSET @@indexToOffset ; if all vertices are inside
@@grabBit:					; or if all vertices are outside
		mov	bx,[di]			; the field function. If so, no
		inc	di			; polygons should be generated
		inc	di			; in the current cube
		mov	al,[si+bx+1]
		add	ax,ax
		dec	ch
		jnz	@@grabBit

		inc	ah
		cmp	ah,1
		jbe	@@emptyCube

		push	cx			; There will be triangles generated
		mov	bx,OFFSET MetaTetraConfigs ; inside this cube; iterate over
		mov	ch,[bx]			; the 6 tetrahedrons that make
		inc	bx			; up the cube, and process each separately
@@tetra:

		mov	cl,4			; Calculate in/out codes for each of
@@tetraVertex:					; the current tetra's 4 vertices
		movzx	bp,b [bx]
		inc	bx
		mov	bp,[@@indexToOffset+bp]
		mov	dl,[si+bp+1]
		add	dx,dx
		dec	cl
		jnz	@@tetraVertex

		push	bx			; Depending on the in/out configuration,
		mov	bl,dh			; choose one out of 15 pre-made
		and	bx,0fh			; polygonization cases
		movzx	bp,b [@@generateTriCases+bx]
		add	bp,OFFSET @@generateTriCase0
		pop	bx

		mov	cl,[bp]			; No polygons inside tetra? if so, skip
		test	cl,cl
		jz	@@skipTetra
		inc	bp

@@tetraTri:					; Emit 1 or 2 triangles inside current tetra
		push	cx

		mov	di,OFFSET MetaTempTri

		mov	cl,3			; Calculate 3 vertices for triangle
@@tetraTriVertex:
		xor	ax,ax
		mov	al,[bp]
		inc	bp
		mov	dx,ax
		shr	ax,2
		and	dl,3
		call	@@emitInterpolatedVertex
		dec	cl
		jnz	@@tetraTriVertex

		call	@@finalizeTri		; Draw triangle

		pop	cx
		dec	cl			; Next triangle in tetra
		jnz	@@tetraTri

@@skipTetra:

		dec	ch			; Next tetra in cube
		jnz	@@tetra

		pop	cx

@@emptyCube:
		sub	si,5			; Next cube in grid
		dec	cl
		jnz	@@x
		sub	si,5
		pop	cx
		dec	ch
		jnz	@@y
		sub	si,5*16
		dec	cx
		jnz	@@z

		ret

@@indexToOffset	dw	0,5,5*16,5*16+5,5*16*16,5*16*16+5,5*16*16+5*16,5*16*16+5*16+5

@@generateTriCases db	@@generateTriCase0-@@generateTriCase0
		db	@@generateTriCase1-@@generateTriCase0
		db	@@generateTriCase2-@@generateTriCase0
		db	@@generateTriCase3-@@generateTriCase0
		db	@@generateTriCase4-@@generateTriCase0
		db	@@generateTriCase5-@@generateTriCase0
		db	@@generateTriCase6-@@generateTriCase0
		db	@@generateTriCase7-@@generateTriCase0
		db	@@generateTriCase8-@@generateTriCase0
		db	@@generateTriCase9-@@generateTriCase0
		db	@@generateTriCase10-@@generateTriCase0
		db	@@generateTriCase11-@@generateTriCase0
		db	@@generateTriCase12-@@generateTriCase0
		db	@@generateTriCase13-@@generateTriCase0
		db	@@generateTriCase14-@@generateTriCase0
		db	@@generateTriCase15-@@generateTriCase0

@@generateTriCase0:	; Triangle configurations inside each tetra,
@@generateTriCase15:	; depending on the in/out vertex test
		db	0
@@generateTriCase1:
@@generateTriCase14:
		db	1,0*4+3,1*4+3,2*4+3
@@generateTriCase2:
@@generateTriCase13:
		db	1,0*4+2,1*4+2,3*4+2
@@generateTriCase3:
@@generateTriCase12:
		db	2
		db	1*4+2,1*4+3,0*4+3
		db	1*4+2,0*4+3,0*4+2
@@generateTriCase4:
@@generateTriCase11:
		db	1,0*4+1,2*4+1,3*4+1
@@generateTriCase5:
@@generateTriCase10:
		db	2
		db	0*4+1,0*4+3,2*4+3
		db	0*4+1,2*4+3,2*4+1
@@generateTriCase6:
@@generateTriCase9:
		db	2
		db	1*4+0,1*4+3,2*4+3
		db	1*4+0,2*4+3,2*4+0
@@generateTriCase7:
@@generateTriCase8:
		db	1,1*4+0,2*4+0,3*4+0

;-----------------------------------------------------------------
; Given two vertex-indices into the grid, interpolates XYZ positions
; between the two vertices (using the force function values as weights)
; to approximately calculate where the force function = 0
; Then emits the XYZ for that position
;
; in	ax	vertex-index 0
;	dx	vertex-index 1
;	di	vertexbuffer
; out		writes to [di++]

@@emitInterpolatedVertex:
		pusha

		add	ax,bx
		add	bx,dx
		movzx	bx,b [bx-4]
		xchg	ax,bx
		movzx	bx,b [bx-4]

		mov	bp,[@@indexToOffset+bx]
		xchg	ax,bx
		mov	bx,[@@indexToOffset+bx]

		add	bx,si
		add	bp,si

		mov	ax,[bx]			; calculate interpolation factor:
		mov	cx,[bp]			; t = (force1 / (force1 - force2))
		inc	bx
		inc	bx
		inc	bp
		inc	bp
		test	ax,ax
		jns	@@okayish
		xchg	ax,cx
		xchg	bx,bp
@@okayish:
		neg	cx
		add	cx,ax
		cwd
		mov	dl,ah
		mov	ah,al
		div	cx			; result is 0.8 fixed point

		xchg	ax,si
		mov	cl,3			; Interpolate XYZ
@@emitInterpolatedVertex_component:

		movsx	dx,b [bx]
		inc	bx
		movsx	ax,b [bp]
		inc	bp
		sub	ax,dx
		push	dx
		imul	si
		pop	dx
		add	ah,dl
		stosw

		dec	cl
		jnz	@@emitInterpolatedVertex_component

		popa
		add	di,3*2
		ret

;-----------------------------------------------------------------
; Calculate polygon normal (via cross product), project the vertices,
; then draw the triangle with normal's Z component used as colour
;

@@finalizeTri:
		pusha
		mov	si,OFFSET MetaTempTri
		mov	di,si

		pusha
		mov	cx,3
@@projVtx:

		mov	ax,2			; Calculate triangle normal
		mov	bx,4
		call	@@calcCrossComponent
		fmul	st,st
		xor	bx,bx
		call	@@calcCrossComponent
		fmul	st,st
		mov	bx,2
		call	@@calcCrossComponent
		fld	st
		fmul	st,st
		faddp	st(2),st
		fxch	st(2)
		faddp	st(1),st
		fadd	fudgeFactor
		fsqrt
		fchs
		fdivp	st(1),st		; .. and normalize Z component
		fimul	@@normalScale

		lodsw				; Fetch vertex
		xchg	bx,ax
		lodsw
		xchg	bp,ax
		lodsw
		xchg	ax,bp
		xchg	ax,bx

		fistp	w [di]
		inc	di
		inc	di

		add	bp,300 SHL 4		; .. and project
		mov	dx,ax
		sar	dx,4
		shl	ax,12
		idiv	bp
		add	ax,160 SHL 4
		stosw
		xchg	ax,bx
		mov	dx,ax
		sar	dx,4
		shl	ax,12
		idiv	bp
		add	ax,100 SHL 4
		stosw

		loop	@@projVtx
		popa

		neg	w [si]			; Clamp tri colour to 0
		jns	@@nBack
		neg	w [si]
@@nBack:
		call	DrawTri			; Draw tri

		mov	eax,[si+4*2]		; Flip tri orientation
		xchg	eax,[si+7*2]
		mov	[si+4*2],eax
		call	DrawTri			; Draw tri again (this takes
						; care of tris that don't
						; have proper clockwise orientation)

		popa

		ret


@@calcCrossComponent:				; Calculate one component of cross product
		fild	w [si+bx]
		fisub	w [si+bx+3*2]
		fild	w [si+bx]
		fisub	w [si+bx+6*2]
		xchg	ax,bx
		fild	w [si+bx]
		fisub	w [si+bx+3*2]
		fild	w [si+bx]
		fisub	w [si+bx+6*2]

		fmulp	st(3),st
		fmulp	st(1),st
		fsubp	st(1),st
		ret


@@normalScale	dw	60



fudgeFactor	dd	0.001




MetaTetraConfigs db	6		; Cube subdivision into tetrahedrons
		db	7*2,6*2,5*2,3*2
		db	4*2,5*2,3*2,6*2
		db	4*2,3*2,2*2,6*2
		db	1*2,4*2,5*2,3*2
		db	1*2,3*2,2*2,4*2
		db	0*2,4*2,1*2,2*2

MetaBallPositions dw	5
		dd	5*3 dup (?)

TriEdges	dw	256*2 dup (?)

MetaFieldStrength db	5*16*16*16 dup (?)
MetaTempTri	dw	3*3 dup (?)

		END	start

