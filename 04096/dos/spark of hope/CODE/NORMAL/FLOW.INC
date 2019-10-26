FlowTab1	dd 0
FlowTab2	dd 0


Flow	PROC
	mov	esi,Patterns+20000h
	add	esi,ds:[TabPtr]
	mov	ecx,esi
	mov	edi,ds:[FlowTab2]
	mov	eax,ds:[FlowTab2]
	xchg	eax,ds:[FlowTab1]
	mov	ds:[FlowTab2],eax
	mov	cx,ds:[FrameCount]
	shr	cx,3
	mov	si,cx
	shl	si,8
Flow1:
	mov	ah,[ecx]
	add	cx,si
	shr	ah,5
	xor	dh,dh
	mov	al,[esi]
	shr	al,5
	mov	dl,[ecx]
	sub	ax,404h	
	add	ax,di
	sub	cx,si
	mov	al,[eax]
	inc	cx
	shr	dl,4
	xor	ah,ah
	sub	dx,10
	inc	si
	add	ax,dx
	jge	FlowOk1
	xor	ax,ax
FlowOk1:
	cmp	ax,255
	jle	FlowOk2
	mov	al,255
FlowOk2:
	mov	[edi],al
	inc	di
	jnz	Flow1
	ret
Flow	ENDP