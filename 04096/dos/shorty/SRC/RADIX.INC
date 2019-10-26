
RSort:
       push cs
       pop  es
       xor di, di
       xor si, si

       mov cx, 703
@@makelijst:
       mov bx, word ptr cs:[plan.di]
       movsx eax, word ptr cs:[rpoints.bx+4]	   ; zpos
       mov bx, word ptr cs:[plan.di+2]
       movsx edx, word ptr cs:[rpoints.bx+4]	   ; zpos
       add eax, edx
       mov bx, word ptr cs:[plan.di+4]
       movsx edx, word ptr cs:[rpoints.bx+4]	   ; zpos
       add eax, edx

	shr eax,2
	mov cs:[lijst.si], ax
	mov cs:[sortedn.si], di
	add si, 2
	add di, 6
	dec cx
	jnz @@makelijst

	mov di, offset aantalh		       ; aantalH + aantalL Leegmaken
	mov cx, 512
	sub ax, ax
	rep stosw

	mov cx, 703				; number of faces
	mov si, offset lijst
	mov di, offset aantalh
@@makeaantal:

	xor bx, bx
	mov ax, cs:[si]
	mov bl, ah
	add bx, bx
	add word ptr cs:[di+bx], 2
	xor bx, bx
	mov bl, al
	add bx, bx
	add word ptr cs:[aantall.bx], 2

	add si, 2
	dec cx
	jnz @@makeaantal

	mov cx, 256
	mov di, offset pntsH
	mov si, offset aantalH
	xor ax, ax
	mov bx, ax
@@makepointers:
	mov cs:[di], ax
	mov cs:[di+512], bx
	add ax, cs:[si]
	add bx, cs:[si+512]
	add si, 2
	add di, 2
	dec cx
	jnz @@makepointers

	mov cx, 703			       ; number of faces
	mov di, offset pntsl
	xor dx, dx
	xor si, si
@@sortLow:

	xor bx, bx
	mov ax, cs:[lijst.si]
	mov bl, al
	add bx, bx			   ; Lijst[x] *2

	mov bp, word ptr cs:[di+bx]	      ; pntsl[lijst[x]*2] * 2
	add word ptr cs:[di+bx], 2

	mov cs:[sortedl.bp], si
	xor al, al
	shr ax, 7
	mov cs:[lijst2+bp], ax
	add si, 2
	dec cx
	jnz @@sortlow

	mov cx, 703			     ; number of faces
	mov di, offset sortedl
	mov si, offset lijst2
	mov di, offset pntsh
	xor dx, dx
@@sortHigh:

	mov bx, word ptr cs:[si]
	mov bp, word ptr cs:[di+bx]	; pntsl[lijst[x]*2] * 2
	add word ptr cs:[di+bx], 2
	mov bx, dx
	mov bx, cs:[sortedL.bx]
	mov ax, cs:[sortedn.bx]
	mov cs:[sorted+bp], ax

	add si, 2
	add dx, 2
	dec cx
	jnz @@sorthigh

@@einde:
	ret
