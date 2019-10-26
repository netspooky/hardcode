
Proc	InitScreenBuffers
	mov ah,48h
	mov bx,65536/16
	int 21h
	mov [GraphBuffer],ax		;Allocate buffer #1
	mov fs,ax


	mov ah,48h
	mov bx,65536/16
	int 21h
	jnc @@EnoughMemory
	stc
	ret
@@EnoughMemory:

	mov [CopyBuffer],ax		;Allocate buffer #2
	mov gs,ax

	xor eax,eax
	mov cx,64000/4
	xor di,di
Clear1:
	mov [fs:di],eax
	mov [gs:di],eax
	add di,4
	loop Clear1

	clc
	ret
EndP	InitScreenBuffers



Proc	DisplayScreenBuffers
	push ds
	push es

	mov ax,[GraphBuffer]
	mov bx,[CopyBuffer]
	mov ds,ax
	mov es,bx
	push 0A000h
	pop gs

	xor si,si
	xor di,di
	mov cx,16000
CompareAndCopy:
	repe cmpsd
	jcxz NothingToCopy
	mov eax,[ds:si-4]
	sub di,4
	mov [gs:di],eax
	stosd
	jmp CompareAndCopy
NothingToCopy:

	pop es
	pop ds
	ret
EndP	DisplayScreenBuffers


Proc	ClearScreenBuffers

	push es
	mov ax,[GraphBuffer]
	mov es,ax
	xor di,di
	mov cx,64000/4
;	mov eax,80808080h
	xor eax,eax
;ClearBuf:
;	and [es:di],eax
;	add di,4
;	loop ClearBuf
	rep stosd	;Clear buffer

	pop es
	ret
EndP	ClearScreenBuffers

GraphBuffer	dw	?
CopyBuffer	dw	?
