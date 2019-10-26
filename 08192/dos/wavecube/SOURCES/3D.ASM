;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Proc	Rotate3D	;ds:si	- input 3d points buffer
			;es:di	- output 3d points buffer
			;cx	- number of 3d points
			;dl	- rotation Z angle
			;dh     - rotation X angle
			;bl	- rotation Y angle
;	x':=x*cos(angleZ)-y*sin(angleZ)
;	y':=x*sin(angleZ)+y*cos(angleZ)
	xor eax,eax

	xor bh,bh
;	xor ah,ah
	add bx,bx
	mov ax,[Sin256+bx]
	cwde
	mov [Sin3],eax		;Calculate Sin(AngleY)
	add bx,384
	and bx,1FFh
	mov ax,[Sin256+bx]	;Calculate Cos(AngleY)
	cwde
	mov [Cos3],eax

	xor bx,bx
	mov bl,dl
	add bx,bx
	mov ax,[Sin256+bx]	;Calculate Sin(AngleZ)
	cwde
	mov [Sin1],eax
	add bx,384
	and bx,1FFh
	mov ax,[Sin256+bx]	;Calculate Cos(AngleZ)
	cwde
	mov [Cos1],eax

	xor bx,bx
	mov bl,dh
	add bx,bx
	mov ax,[Sin256+bx]	;Calculate Sin(AngleX)
	cwde
	mov [Sin2],eax
	add bx,384
	and bx,1FFh
	mov ax,[Sin256+bx]	;Calculate Cos(AngleX)
	cwde
	mov [Cos2],eax
RotateLoop:
	push cx

	lodsw
	cwde
	mov edx,eax	;X
	lodsw
	cwde
	mov ebx,eax
	lodsw
	cwde
	mov ecx,eax
	mov eax,edx

	push eax ebx
	imul eax,[Cos1]
	imul ebx,[Sin1]
	sub eax,ebx
	sar eax,8	;X
	mov edx,eax	;Temporary register for X
	pop ebx eax
	imul eax,[Sin1]
	imul ebx,[Cos1]
	add ebx,eax
	sar ebx,8	;Y

	mov eax,edx

	push ebx ecx
	imul ebx,[Cos2]
	imul ecx,[Sin2]
	sub ebx,ecx
	sar ebx,8	;Y
	mov edx,ebx	;Temporary register for Y
	pop ecx ebx
	imul ebx,[Sin2]
	imul ecx,[Cos2]
	add ecx,ebx
	sar ecx,8	;Z
	mov ebx,edx

	push eax ecx
	imul eax,[Cos3]
	imul ecx,[Sin3]
	sub eax,ecx
	sar eax,8	;X
	mov edx,eax
	pop ecx eax
	imul eax,[Sin3]
	imul ecx,[Cos3]
	add ecx,eax
	sar ecx,8	;Z
	mov eax,edx	


	stosw
	mov ax,bx
	stosw
	mov ax,cx
	stosw

	pop cx
	dec cx
	jz RotateLoopEnd
	jmp RotateLoop
RotateLoopEnd:
	ret
Sin1	dd	?
Cos1	dd	?
Sin2	dd	?
Cos2	dd	?
Sin3	dd	?
Cos3	dd	?
X	dw	?
Y	dw	?
Z	dw	?
EndP	Rotate3D

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

Proc	Convert3Dto2D	;ds:si	- input 3d points buffer
			;es:di	- output 3d points buffer
			;cx	- number of 3d points
			;bx	- perspective
Convert1:
;X=X/perspective*(Z+perspective)
;Y=Y/perspective*(Z+perspective)
	lodsw		;Z
	mov dx,ax
	add dx,bx
	lodsw
	push dx		;Save Z+perspective
	imul dx
	idiv bx
	pop dx		;Restore Z+perspective
	stosw
	lodsw
	imul dx
	idiv bx
	stosw
	loop Convert1
	ret

EndP	Convert3Dto2D

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

Proc	Shake3D		;ds:si - input 3d points buffer
			;es:di - output 3d points buffer
			;cx - number of points
			;bl - angle of shaking
			;dh - X angle of shaking
			;dl - X angle of shaking
	xor bh,bh
	add bx,bx
	mov bp,[Sin256+bx]
	sar bp,3

	mov bl,dl
	xor bh,bh
	add bx,bx
	mov ax,[Sin256+bx]
	sar ax,3

	mov bl,dh
	xor bh,bh
	add bx,bx
	mov bx,[Sin256+bx]
	sar bx,3

	mov dx,ax

DoShake:
	lodsw
	add ax,dx
	stosw
	lodsw
	add ax,bp
	stosw
	lodsw
	add ax,bx
	stosw
	loop DoShake
	ret
EndP	Shake3D
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

	WavesSize	equ	6
Proc	Waves3D		;ds:si - input 3d points buffer
			;es:di - output 3d points buffer
			;cx - number of points
			;bl - angle of waves
DoWaves:
	mov bp,[ds:si]
	add bp,[ds:si+2]
	add bp,[ds:si+4]
	add bp,bx
	shl bp,2	;*2 and make waves faster
	and bp,1FFh
	mov dx,[Sin256+bp]
	sar dx,WavesSize

	lodsw
	add ax,dx
	stosw
	mov bp,[ds:si-2]
	add bp,[ds:si]
	add bp,[ds:si+2]
	add bp,bx
	add bp,162
	shl bp,2
	and bp,1FFh
	mov dx,[Sin256+bp]
	sar dx,WavesSize
	lodsw
	add ax,dx
	stosw
	mov bp,[ds:si-4]
	add bp,[ds:si-2]
	add bp,[ds:si]
	add bp,bx
	add bp,42
	shl bp,2
	and bp,1FFh
	mov dx,[Sin256+bp]
	sar dx,WavesSize
	lodsw
	add ax,dx
	stosw
	loop DoWaves
	ret
EndP	Waves3D
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

Include "Sine.Inc"

