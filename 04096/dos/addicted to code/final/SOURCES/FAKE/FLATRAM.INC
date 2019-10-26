;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;======= Flatmode 16bit library - enables 32bit addressing in realmode ========
;====================== author: khamoon/tube27^byteway ========================
;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
newgdt	dw 8*2		;New GDT address register
	dw offset gdtbl
	dw 0 
gdtbl	dw 0,0,0,0	;Zero descriptor
	dw 0ffffh	;New decriptor ( base = 0 , limit =4Gb )
	dw 0
	db 0
	db 10010010b
FlatC:  db 10001111b
	db 0
;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
flatinfo	db 'V86!$'
XMSInfo		db 'XMS!$'
XMSInfo2	db 'Mem!$'
XMSDriver	dd 0
TabPtr		dd 0
;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
runflatmode PROC
	smsw	ax			;Check if machine is in protected mode
	and	al,1
	jz	CanRunFlatMode
	mov	dx,offset flatinfo	;Machine IS in protected mode
	mov	ah,9
	int	21h
	mov	ah,4ch
	int	21h
CanRunFlatMode:				;All ok , can switch flatram mode
	xor	eax,eax
	mov	ax,cs
	shl	eax,4
	mov	dword ptr cs:[CodeLinear],eax
	add	dword ptr cs:[newgdt+2],eax
DisableFlatMode:
	lgdt	qword ptr cs:[newgdt]
	mov	bx,1000b
	cli
	mov	eax,cr0
	or	al,1
	mov	cr0,eax
	jmp	@tu1
@tu1:
	mov	ds,bx
	mov	es,bx
	mov	fs,bx
	mov	gs,bx
	and	al,0feh
	mov	cr0,eax
	jmp	@tu2
@tu2:
	sti
	ret
ENDP
;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++XMSInit	PROC
InitSystem	PROC
	call	runflatmode
	push	cs
	pop	ds

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
	mov	ds:[TabHandle],dx
	mov	ah,0ch
	call	dword ptr [XMSDriver]

	inc	dx
	inc	dx
	sub	dx,word ptr ds:[CodeLinear+2]
	and	dl,0FEh
	mov	word ptr ds:[TabPtr+2],dx

	push	cs
	pop	es
	xor	ax,ax
	mov	fs,ax
	ret
InitSystem	ENDP
;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++XMSInit	PROC
DeInitSystem	PROC
	mov	dx,ds:[TabHandle]
	mov	ah,0dh
	call	dword ptr [XMSDriver]
	mov	ah,0ah
	call	dword ptr [XMSDriver]
	mov	byte ptr cs:[FlatC],0
	call	DisableFlatMode
	ret
DeInitSystem	ENDP
;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++XMSInit	PROC
