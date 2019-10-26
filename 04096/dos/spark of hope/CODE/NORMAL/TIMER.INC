FrameCount	dw 256
Old8h		dd 0
TimerCount	db 10

SetTimer	PROC
	cli
	mov	al,36h
	out	43h,al
	mov	ax,1193181/182
	out	40h,al
	mov	al,ah
	out	40h,al

	mov	ax,cs
	shl	eax,16
	mov	ax,offset New8h
	xchg	eax,fs:[8*4]
	mov	[Old8h],eax
	sti
	ret
SetTimer	ENDP
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
ResetTimer	PROC
	cli
	mov	al,36h
	out	43h,al
	xor	al,al
	out	40h,al
	out	40h,al

	mov	eax,Old8h
	mov	fs:[8*4],eax
	sti
	ret
ResetTimer	ENDP
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
New8h	PROC
	inc	cs:FrameCount
	dec	cs:TimerCount
	jg	NotOld8h
	mov	cs:TimerCount,10
	jmp	dword ptr Old8h
NotOld8h:		
	push	ax
	mov	al,20h
	out	20h,al
	pop	ax
	iret
New8h	ENDP