; the base64 loader
; public domain.
; by thefox <fuchs@runkkaajat.org> 2004

	.model tiny, stdcall
	.386
	.code
	
	option casemap: none
	org 100h

start:
	pop dx
	push dx
	push dx
	push dx
	pop edx				; edx = 0
	
	push 2170h
	pop ax				; decoded data ptr, among other things
	
	push ax				; push the decoded data address - 20h
	
	sub ax, 2051h			; ax = 13Fh - 20h
	
	push ax				; main loop counter (11Fh, 287)
	
	push ax
	pop bp				; encoded data ptr, among other things
	
	push 5d5dh
	pop bx				; bx = magic

	sub [bp + 20h], bl
	sub [bp + 26h], bx		; fix some jumps
	
	pop bx				; bx = main loop counter
	pop di				; di = ptr to decoded data (-20h)
	
main_loop:
	and [di + 20h], edx		; clear decoded data dword
	
	push 4 + 20h
	pop ax
	sub al, 20h			; ax = 4 (loop counter)
	
want_more:
	push 20h
	pop cx				; cx = 20h
	sub [bp + 2Ah], cl		; convert from ASCII to real value

	imul ecx, [di + 20h], 64	; shift left 6 bits
	xor cl, [bp + 2Ah]		; add the new 6 bits in

	and [di + 20h], edx		; clear...
	xor [di + 20h], ecx		; ...and xor -> same effect as with or

	inc bp				; increase encoded data ptr
	dec ax				; decrease inner loop counter
	byte 75h			; jnz want_more
inner_loop_jmp_offset:
	byte 43h

	inc di
	inc di
	inc di				; increase decoded data ptr
	
	dec bx				; decrease main loop counter
	byte 75h			; jnz main_loop
main_loop_jmp_offset:
	byte 34h

return_orig:
	byte 47h			; jmp near 2190h
	
	word (2190h - 149h)		; 149h = offset encoded_data_start
	
encoded_data_start:

	include demo.asc		; actual encoded data

encoded_data_end:

end start