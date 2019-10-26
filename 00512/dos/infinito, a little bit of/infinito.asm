;	___________________________________________________________________________________________
;	Infinito, a little bit of. (in only 399bytes) - Ska/Apocalypse Design - mfabbri@amanith.org

	org 100h

	; set up 13h mode
START:	mov	al, 13h
	int	10h

	; set up a palette
	xor	cx, cx
PAL1:	mov	dx, 3C8h
	mov	ax, cx
	out	dx, al
	inc	dx
	sar	al, 1
	js	PAL2
	out	dx, al
	mul	al
	shr	ax, 6
	out	dx, al
PAL2:	mov	al, 0
	out	dx, al
	jns	PAL3
	sub	al, cl
	shr	al, 3
	out	dx, al
	sal	al, 1
	out	dx, al
PAL3:	mov	bx, cx
	loop	PAL1

	; main loop
	finit
DOLOOP: fld	[delta]    ; st0 = delta
	fild	[speed]    ; st0 = speed        st1 = speed
	fdivp	st1, st    ; st0 = delta/speed (incr)
	fld	st	   ; st0 = incr         st1 = incr
	fadd	st1, st    ; st0 = incr         st1 = 2*incr
	fld	[delta]    ; st0 = delta        st1 = incr         st2 = 2*incr
	fxch	st2	   ; st0 = 2*incr       st1 = incr         st2 = delta
	fsubp	st2, st    ; st0 = incr         st1 = delta-2*incr
	fld	[xrMin]    ; st0 = xrMin        st1 = incr         st2 = delta-2*incr
	fld	[yrMin]    ; st0 = yrMin        st1 = xrMin        st2 = incr         st3 = delta-2*incr
	fld	st2	   ; st0 = incr         st1 = yrMin        st2 = xrMin        st3 = incr         st4 = delta-2*incr
	fadd	st1, st    ; st0 = incr         st1 = yrMin+incr   st2 = xrMin        st3 = incr         st4 = delta-2*incr
	faddp	st2, st    ; st0 = yrMin+incr   st1 = xrMin+incr   st2 = incr         st3 = delta-2*incr
	fstp	[yrMin]    ; store yrMin
	fstp	[xrMin]    ; store xrMin
	fstp	st	   ; discard
	fstp	[delta]    ; store delta

	; address of the backbuffer
	push	word 08000h
	pop	es
	xor	di, di

	; y-axis loop
	xor	dx, dx	   ; dx = 0 to 100
LOOPY:	mov	[y], dx    ; y = dx
	add	[y], 50    ; y += 50
	fild	[y]	   ; st0 = y
	fild	[_200]	   ; st0 = 200          st1 = y
	fdivp	st1, st    ; st0 = y/200
	fld	[delta]    ; st0 = delta        st1 = y/200
	fmul	st1, st    ; st0 = delta        st1 = (y/200)*delta
	fld	[yrMin]    ; st0 = yrMin        st1 = delta        st2 = (y/200)*delta
	faddp	st2, st    ; st0 = delta        st1 = (y/200)*delta+yrMin (currY)
	fstp	[delta]
	fstp	[curry]

	; x-axis loop
	xor	bx, bx	   ; bx = 0 to 320
LOOPX:	fld	[curry]
	fld	[delta]
	mov	[x], bx    ; x = bx
	fild	[x]	   ; st0 = x            st1 = delta        st2 = currY
	fild	[_320]	   ; st0 = 320          st1 = x            st2 = delta        st3 = currY
	fdivp	st1, st    ; st0 = x/320        st1 = delta        st2 = currY
	fmulp	st1, st    ; st0 =(x/320)*delta st1 = currY
	fld	[xrMin]    ; st0 = xrMin        st1 =(x/320)*delta st2 = currY
	faddp	st1, st    ; st0 = currX        st1 = currY
	fstp	[currx]
	fstp	[curry]
	fldz
	fldz
	fstp	[realp]
	fstp	[imagp]

	; 255 max iterations loop to found the right color
	xor	cx, cx
	mov	cx, 255    ; cl = 255 to 0
LOOPC:	fld	[curry]
	fld	[currx]
	fld	[imagp]    ; st0 = imagp        st1 = currX        st2 = currY
	fld	st	   ; st0 = imagp        st1 = imagp        st2 = currX        st3 = currY
	fmul	st1, st    ; st0 = imagp        st1 = imagp^2      st2 = currX        st3 = currY
	fld	[realp]    ; st0 = realp        st1 = imagp        st2 = imagp^2      st3 = currX        st4 = currY
	fld	st	   ; st0 = realp        st1 = realp        st2 = imagp        st3 = imagp^2      st4 = currX        st5 = currY
	fmul	st1, st    ; st0 = realp        st1 = realp^2      st2 = imagp        st3 = imagp^2      st4 = currX        st5 = currY
	fmulp	st2, st    ; st0 = realp^2      st1 = imagp*realp  st2 = imagp^2      st3 = currX        st4 = currY
	fld	st1	   ; st0 = imagp*realp  st1 = realp^2      st2 = imagp*realp  st3 = imagp^2      st4 = currX        st5 = currY
	faddp	st2, st    ; st0 = realp^2      st1 =2*imagp*realp st2 = imagp^2      st3 = currX        st4 = currY
	fxch	st1	   ; st0 =2*imagp*realp st1 = realp^2      st2 = imagp^2      st3 = currX        st4 = currY
	faddp	st4, st    ; st0 = realp^2      st1 = imagp^2      st2 = currX        st3 = currY+2*imagp*realp
	fadd	st2, st    ; st0 = realp^2      st1 = imagp^2      st2 =currX+realp^2 st3 = currY+2*imagp*realp
	fld	st1	   ; st0 = imagp^2      st1 = realp^2      st2 = imagp^2      st3 =currX+realp^2 st4 = currY+2*imagp*realp
	fsubp	st3, st    ; st0 = realp^2      st1 = imagp^2      st2 =currX+realp^2-imagp^2 st3 = currY+2*imagp*realp
	faddp	st1, st    ; st0 = imagp^2+realp^2 st1 = currX+realp^2-imagp^2 st2 = currY+2*imagp*realp
	fxch	st2	   ; st0 = currY+2*imagp*realp st1 = currX+realp^2-imagp^2 st2 = imagp^2+realp^2
	fstp	[imagp]    ; st0 = currX+realp^2-imagp^2 st1 = imagp^2+realp^2
	fstp	[realp]    ; st0 = imagp^2+realp^2
	fild	[speed]
	fcompp
	fstsw	ax
	fwait
	sahf
	jb	ITEROK
	loop	LOOPC

	; the color has been found, blur it on the backbuffer!
ITEROK: xor	ax, ax
	mov	al, byte [es:di]
	add	ax, cx
	shr	ax, 1
	stosb

	; x-axis loop
	inc	bx
	cmp	bx, 320
	jnz	LOOPX

	; y-axis loop
	inc	dx
	cmp	dx, 100
	jnz	LOOPY

	; copy backbuffer into screen
	push	ds
	push	word 08000h
	pop	ds
	xor	si, si
	push	word 0A000h
	pop	es
	mov	di, 16000
	mov	cx, di
	rep	movsw
	pop	ds

	; esc pressed? thed exit
	in	al, 60h
	dec	al
	jnz	DOLOOP

	; return in text-mode
	mov	al, 03h
	int	10h
	ret

	; variables
	delta dq +2.400000000000000
	xrMin dq -2.190145500089059
	yrMin dq -1.480143798154924
	incr  dq ?
	realp dq ?
	imagp dq ?
	currx dq ?
	curry dq ?
	speed dw 32
	y     dw 0
	x     dw 0
	_320  dw 320
	_200  dw 200
