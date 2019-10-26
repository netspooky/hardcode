CalcTab:
	xor	ebx, ebx
	mov	cx, 256
@sqrt:
	push	ebx
	xor	ax, ax
	xor	edx, edx
	inc	dx
@Sl:	sub	ebx, edx
	js	@ends
	inc	ax
	add	edx, 2
	jmp	@Sl
@ends:
	shl	ax, 1
	pop	ebx

	stosw
	add	ebx, 4194304
	loop	@sqrt
	xor	ax, ax
	dec	ax
	stosw
	ret


Sqrt:
  movzx  di,bh
  movzx  ecx,bl
  shl	 di,1
  movzx  eax,SqrtTab[di+2]
  imul	 eax,ecx
  mov	 esi,eax
  movzx  eax,SqrtTab[di]
  not	 cl
  imul	 eax,ecx
  add	 eax,esi
  shr	 eax,8
  ret

