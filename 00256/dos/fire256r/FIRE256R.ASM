comment~                                          
ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ
                                                                         
                rod's entry in the 256 byte fire coding compo            
                                                                         
                      e-mail: s5001pap@sun10.vsz.bme.hu                  
                    
ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ~

.model small
.stack 256
jumps
locals

load	macro	r,s
	push	s
	pop	r
endm

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
				.fardata? @generator
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

		db	65535 dup (?)

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
				.code
				.386
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

main		proc	far

		mov	al,13h
		int	10h

		mov 	dx,03c8h		; set the palette
		xor	ax,ax
		out 	dx,al
		inc 	dx
		out 	dx,al
		out 	dx,al
		out 	dx,al

		mov	ax,22*256
		xor	bx,bx
		mov	cx,2*256
		mov	bp,64
@@firepal:      push	ax
		mov	al,ah
		out	dx,al
		mov	al,bh
		out	dx,al
		mov	al,ch
		out	dx,al
		pop	ax
		add	ax,158
		add	bx,223
		add	cx,89
		dec	bp
		jnz	@@firepal

		load	es,@generator		; fire generator
		xor	di,di
		xor	ax,ax
		mov	cx,32768
		rep	stosw

		load	ds,es
		mov	cx,256
		mov	di,320*128+160
@@1:            pusha
		shr	cx,8
		sub	di,cx
		add	cx,cx
		in	al,40h
		imul	ax,di
		and	ax,0fh
		sub	ax,7
		add	di,ax
		mov	al,cl
@@gen:		mov	[di],al
		mov	[di-80],al
		mov	[di+80],al
		inc	di
		loop	@@gen
		popa
		add	di,320
		add	cx,128
		cmp	ch,32
		jne	@@1

		cli				; fire
		load	ds,0a000h

@@3:		mov	al,[bx]
		or	ax,ax
		jz	@@5
		dec	ax
		mov	[bx-2],al
		mov	[bx-1],al
		mov	[bx],al
		mov	[bx+1],al
		mov	[bx+2],al
		mov	[bx-319],al
		mov	[bx-320],al
		mov	[bx-321],al
		mov	di,-643
		mov	dx,bx
@@randseed:	imul	dx,01234h
		add	dx,74
		add	dx,bx
		mov	word ptr cs:@@randseed+2,dx
		and	dx,07h
		add	di,dx
@@4:		mov	[bx+di],al
@@5:		mov	al,es:[bx]
		or	[bx+di+320],al

@@8:		add	bx,cx
		inc	cx
		jnz	@@6

		mov	dx,3dah			; poor effort to syncronise
@@wt1:
		in	al,dx
		test	al,8
		jnz	@@wt1
@@wt2:
		in	al,dx
		test	al,8
		jz	@@wt2

@@6:		in	al,60h
		dec	al
		jnz	@@3
		sti

		mov	ax,3
		int	10h

		mov	ah,4ch
		int	21h

main		endp

end		main
