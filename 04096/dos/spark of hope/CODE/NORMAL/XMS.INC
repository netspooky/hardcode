XMSInfo		db 'XMS Driver not found !$'
XMSInfo2	db 'Memory error !$'
XMSDriver	dd 0
TabPtr		dd 0
;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++XMSInit	PROC
XMSInit	PROC
	mov	ax,4300h
	int	2fh
	cmp	al,80h
	je	XMSPresent
	mov	dx,offset XMSInfo
XMSExit:
	mov	ah,9
	int	21h
	mov	ah,4ch
	int	21h
XMSPresent:
	mov	ax,4310h
	int	2fh
	mov	word ptr [XMSDriver],bx
	mov	word ptr [XMSDriver+2],es

	mov	dx,MemSize
	mov	ah,9
	call	dword ptr [XMSDriver]
	or	ax,ax
	jnz	MemoryPresent
	mov	dx,offset XMSInfo2
	jmp	XMSExit
MemoryPresent:
	mov	ds:[TabHandle],ax
	mov	ah,0ch
	call	dword ptr [XMSDriver]

	inc	dx
	inc	dx
	sub	dx,word ptr ds:[CodeLinear+2]
	and	dl,0FEh
	mov	word ptr ds:[TabPtr+2],dx
	ret
XMSInit	ENDP
;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++XMSInit	PROC
; >>  dx - handle
XMSDealloc	PROC
	mov	ds,ds:[TabHandle]
	mov	ah,0dh
	call	dword ptr [XMSDriver]
	mov	ah,0ah
	call	dword ptr [XMSDriver]
	ret
XMSDealloc	ENDP
;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++XMSInit	PROC
