;*****************************************************************************
t160			dw -160
t100			dw -100
tun_y		equ	1024*16
tun_dz		equ	256/256
tun_dzy		dd	tun_dz*tun_y;1048576
tunnel_pos	db	0
tunnel_firstTime	db	1
;
;z = dz*y/dy
;
degs           dd   61.115498;128;1/(2pi)*128*antall_wraps
;degs           dd   122.230111;128;1/(2pi)*128*antall_wraps
;------------------------------------
gen_tunnel2	PROC
			mov	es,textureSeg3
			mov	fs,textureSeg2
	          xor  di,di
	          fld1
	          fild	t100
	          mov  bp,200
texture1: 	mov  cx,320
			fild t160
texture2:		fld  st(1)
	          fmul st,st
	          fld	st(1)
	          fmul st,st
	          faddp
	          fsqrt
	          fidivr tun_dzy
	          fistp word ptr ds:[gen_tun_dest+1]
gen_tun_dest:  mov  ax,0
          	sub	eax,86
          	test	eax,0ff00h
          	jz	short tunnel_ok
          	mov	al,0ffh
tunnel_ok:     mov	fs:[di],al
	          fld	st(1)
	          fld	st(1)
	          fpatan
	          fmul degs
	          fadd	f_016
	          fistp word ptr ds:[gen_tun_dest2+1]
gen_tun_dest2: mov  ax,0
			stosb
	          fadd	st,st(2)
			loop	texture2
	          fstp	st
	          fadd	st,st(1)
;	          fadd	st,st(1)
	          dec  bp
	          jnz  short texture1      ;For every line
	          fcompp
			ret
gen_tunnel2	ENDP
;*****************************************************************************
display_tunnel	proc
			shr	tunnel_firstTime,1
			jnc	short tunnel_notFirstTime
			mov	texturePtr,offset TexMakeTab9;10
			call	generateTexture
			; generate particles for tunnel
			call	generateRandomParticles			
tunnel_notFirstTime:
			push	ds
			mov	es,bufferSeg_r
			mov	fs,textureSeg3
			mov	gs,textureSeg2
			mov	ds,textureSeg1
			xor	si,si
			mov	bp,200
dispTunnel_y:	mov	cx,320
			xor	di,di
dispTunnel_x:	xor	edx,edx
			mov	dl,0ffh			
			mov	bl,fs:[si]
			mov	bh,gs:[si]
			sub	dl,bh
			add	bh,tunnel_pos
			shr	bh,1
			shl	bl,1
			shl	bx,1
			mov	eax,ds:[bx]
			call	color_mul_24
			mov	dh,255
			sub	dh,dl
			mov	dl,dh
			shl	edx,8
			mov	dl,dh
			;add	eax,edx
			stosd
			inc	si
			loop	dispTunnel_x
			mov	ax,es
			add	ax,320*4/16
			mov	es,ax
			dec	bp
			jnz	short dispTunnel_y			
			dec	tunnel_pos
			pop	ds
			ret
display_tunnel	endp
;*****************************************************************************
