;**********************************************************
;
; FlOWER256(Updated with displacement and a nice palette)
; Morphing tunnel of the overused XOR texture. :*)
; Another 256 Byte demo by
; Relsoft (Richard Eric M. Lope BSN RN)
; http://rel.betterwebber.com
; Assemble with FASM (FlatAssembler.net)
;
;**********************************************************

diameter	= 32
diamxscale	= (64 * diameter)
scx		= 160
scy		= 100


org 100h


;*****************************************************************
;*****************************************************************
;*****************************************************************

	       push word 0a000h        ;word
	       pop es		       ;byte

	       mov   al, 13h	       ; mode 13h
	       int   10h	       ; we are now in 320x200x256
	       mov dx, 03c8h	       ;palette write register
	       xor ax, ax
	       mov word[fold_off],ax
	       out dx, al
	       mov cx, 20
	       inc dx
	 genpal:
	       out dx, al
	       xchg al, ah
	       out dx, al
	       xor ax, cx
	       xchg al, ah
	       out dx, al
	       inc al
	       jnz genpal
main_loop:
	;si = frame counter
	inc word [si]

	;flower
	;fold_off += 0.2
	fld [c_fold_off]
	fadd dword[fold_off]
	fstp dword[fold_off]
	;fold_scale = 0.5 * sin(frame / 40)
	fild word [si]		     ;st0 = frame; st1 = 0.3
	mov ax, 90
	mov bx, bp
	mov word [bx], ax
	fidiv word [bx]

	fstp dword [bx]
	fld dword [bx]
	fsincos
	fmul [c_fold_scale]
	fstp dword[fold_scale]

	;displacement
	mov word[bx], ax
	fimul word[bx]
	fistp word[cenx]
	add word[cenx], scx
	fld dword[fold_scale]
	fimul word[bx]
	fistp word[ceny]
	add word[ceny], scy

	;===========tunnel
	mov dx,200
	xor di, di
      tunnel_yloop:
	mov cx,320
      tunnel_xloop:
	;bx = word pointer
	;bp = dword ptr
	;
	;
	;atan2
	fninit				;call this to ditch the st pops
	mov bx, bp
	mov ax, [ceny]
	mov word [bx], ax
	sub [bx], dx
	fild word [bx]			;st0 = dy
	mov ax, [cenx]
	mov word [bx], ax
	sub [bx], cx
	fild word [bx]			;st0 = dx, st1 = dy

	fpatan				;st0 = atan(dy/dx) = atan(st1/st0)
	;flower
	;xdist = xdist * ((sin(fold_off + fold_num * angle) * fold_scale)+1)
	fstp dword [bx]
	fld dword [bx]			;restore
	fld dword [bx]
	fimul [fold_num]
	fadd dword[fold_off]
	fsin
	fmul dword[fold_scale]
	mov word [bx], 1
	fiadd word [bx]
	fstp dword [bp] 		;real_var =((sin(fold_off + fold_num * angle) * fold_scale)+1)

	fmul [c_scale]			;atan(st0))*256/pi
	fistp word [bx] 		;short_var = scaledpi
	mov gs,[bx]
	mov ax, [cenx]
	sub ax, cx			;cmx
	mov [bx], ax
	fild word [bx]			;st0 = cmx
	fmul st0, st0			;cmx * cmx
	mov ax, [ceny]
	sub ax, dx
	mov [bx], ax
	fild word [bx]			;st0 = cmy st1 = cmx*cmx
	fmul st0, st0			;cmy * cmy
	fadd st0, st1			;st0 cmx^2 + cmy^2
	fsqrt				;sqrt st0
	fmul dword [bp]
	mov word [bx], diamxscale	;st0 = diamxscale st1 = sqrt(dist)
	fidivr word [bx]		;st0 = diamxscale / dist
	fistp word [bx]
	mov ax, word [bx]
	add ax, word [si]
	mov bx, gs
	add bx, word [si]
	xor ax, bx
	stosb
	dec cx
	jnz tunnel_xloop
	dec dx
	jnz tunnel_yloop
	mov dx,3dah
  vsync:
	in al,dx
	and al,8
	jz vsync

	in al,60h
	dec al
	jnz main_loop

	ret

fold_num	dw  5
c_fold_off	dd  0.2
c_fold_scale	dd  0.35
c_scale 	dd  40.74
fold_scale	dd  ?
fold_off	dd  ?
cenx		dw  ?
ceny		dw  ?