
; <zinx@linuxfreak.com>
; i couldn't think of a better name for it :(

ORG 100h

SECTION .text
setup:
	mov ah, 09h
	mov dx, zinx
	int 21h

	mov bx, 4
	lea di, [waitvsync]
.sync_fix_loop:
	lea si, [sync_routine]
	mov cx, syncsize
	rep movsb
	dec bx
	jge .sync_fix_loop
	dec byte [waitvsync+jmp_offset]			; 75h -> 74h
	dec byte [waithsyncend+jmp_offset]
	mov byte [waithsync+test_bit_offset], byte 1
	mov byte [waithsyncend+test_bit_offset], byte 1

mainloop:
	mov cx, 350
	cli			; we probably spend more time in this thing
				; than we should, but who cares?
	call waitvsync
.lineloop:
	call waithsyncend

	mov dx, 3c8h
	xchg ax, cx
	mov cx, 63
	lea di, [ybars]
	repne scasw
	dec cx
	jl .nope

	mov bx, ax
	xor al, al
	out dx, al
	mov ax, cx
	inc dx
	out dx, al
	out dx, al
	out dx, al
	mov cx, bx
.do_loop
	call waithsync
	loop .lineloop
	sti

	; now calculate where the bars should be
	mov cx, 63			; stuff them one back
	std
	lea di, [ybars+(63*2)]
	lea si, [ybars+(62*2)]
	rep movsw
	cld

	mov ax, word [ybars_d]		; update direction and the such
	mov bx, word [ybars]
	add bx, ax
	test bx, bx
	je .mov_one
	cmp bx, 300
	je .mov_neg_one
	mov word [ybars], bx

	call waitvsyncend

	mov ah, 11h
	int 16h
	jz mainloop
	int 20h

.nope:
	mov cx, ax
	xor al, al
	out dx, al
	inc dx
	out dx, al
	out dx, al
	out dx, al
	jmp short .do_loop

.mov_one:
	mov word [ybars_d], 2
	jmp short mainloop
.mov_neg_one:
	mov word [ybars_d], -2
	jmp short mainloop

sync_routine:
	push dx
	mov dx, 0x3da
.loop:
	in al, dx
	db 0A8h,
test_bit_offset equ $-sync_routine
		db 8		; test al, 8
jmp_offset equ $-sync_routine
	db 75h, 0fbh		; jnz .loop, jz is 74
	pop dx
	ret
syncsize equ $-sync_routine

SECTION .data	align=1
ybars_d:	dw 2

ybars:	dw 0
zinx:	db 'zinx@linuxfreak.com$'
SECTION .bss	align=1
	resw	53

waitvsync:
	resb syncsize
waitvsyncend:
	resb syncsize
waithsync:
	resb syncsize
waithsyncend:
	resb syncsize

