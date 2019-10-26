FrameCount	dw 256
Old8h		dd 0
TimerCount	db 10

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