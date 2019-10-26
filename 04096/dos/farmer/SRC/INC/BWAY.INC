
	lea di,TrasaBump
	mov cx,360
	mov bx,0
 BumpsWay:
	finit
	mov _angle,bx
	fldpi
	fimul _angle
	fidiv _180
	fsin
	fimul _128
	fistp wyn
	mov ax,wyn
	mov _sin,ax
	fldpi
	fimul _angle
	fidiv _180
	fcos
	fimul _128
	fistp wyn
	mov ax,wyn
	mov _cos,ax
	imul _sin
	shrd ax,dx,7
	imul _sin
	shrd ax,dx,7
	sub ax,160
	mov cs:[di],ax
	mov ax,_sin
	imul _cos
	shrd ax,dx,8
	sub ax,100
	mov cs:[di][2],ax
	inc bx
	add di,4
	dec cx
	jnz BumpsWay

	lea di,TrasaWater
	mov cx,360
	xor bx,bx
 BumpsWay2:
	finit
	mov _angle,bx
	fldpi
	fimul _angle
	fidiv _180
	fsin
	fimul _128
	fistp wyn
	mov ax,wyn
	mov cs:[di],ax

	fldpi
	fimul _angle
	fidiv _180
	fcos
	fimul _128
	fistp wyn
	mov ax,wyn
	mov cs:[di][2],ax

	inc bx
	add di,4
	dec cx
	jnz BumpsWay2





