newgdt	dw 8*2
	dw offset gdtbl
	dw 0 
flatinfo	db 'Turn off V86 !$'
gdtbl	dw 0,0,0,0	;Zero descriptor
	dw 0ffffh	;New decriptor ( base = 0 , limit =4Gb )
	dw 0
	db 0
	db 10010010b
FlatC:  db 10001111b
	db 0


runflatmode PROC
	smsw	ax
	and	al,1
	jz	CanRunFlatMode
	mov	dx,offset flatinfo
	mov	ah,9
	int	21h
	mov	ah,4ch
	int	21h
CanRunFlatMode:
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
