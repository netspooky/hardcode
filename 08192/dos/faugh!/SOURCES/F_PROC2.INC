Proc	FadeOut
	mov bl,32;64
fade:
	mov dx,3c7h
	mov cx,256
l1:
	mov al,cl
	out dx,al
	add dl,2
	in al,dx
	mov ah,al
	in al,dx
	mov bh,al
	in al,dx
	sub al,2
	jnc a1
	xor al,al
a1:
	sub ah,2
	jnc a2
	xor ah,ah
a2:
	sub bh,2
	jnc a3
	xor bh,bh
a3:

	dec dl
	xchg cl,al
	out dx,al
	inc dl
	xchg al,cl
	xchg al,ah
	out dx,al
	mov al,bh
	out dx,al
	mov al,ah
	out dx,al

	sub dl,2
	loop l1
	call WaitVR
	dec bl
	jnz fade
	ret
EndP	FadeOut

Proc	WaitVR
	db	0bah,0dah,03h,0ech,0a8h,08h,75h,0fbh,0ech,0a8h,08h,74h,0fbh
EndP	WaitVR