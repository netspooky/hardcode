org 100h
use16
; ---------------------------------------------------------------------------
;		mov	ah, 0Fh 	; start effect
;		int	10h		; - VIDEO - GET CURRENT VIDEO MODE
;					; Return: AH = number of columns on screen
;					; AL = current video mode
;					; BH = current active display page
;		cmp	al, 3
;		mov	ax, 0B800h
;		jnz	short loc_183
		mov	ax, 13h
		int	10h		; - VIDEO - SET VIDEO MODE
					; AL = mode
		mov	dx, 3C8h
		xor	ax, ax
		out	dx, al
		inc	dx

loc_11C:
		out	dx, al
		out	dx, al
		inc	ax
		cmp	al, 3Ch ; '<'
		jle	short loc_11C
		mov	dx, 0A000h
		mov	ds, dx
;               assume ds:nothing
		mov	bx, 0
		mov	byte  [ds:7DA0h], 1Eh

loc_130:
		cmp	byte  [si], 0
		jz	short loc_152
		dec	byte  [si]
		cmp	byte  [si], 17h
		jb	short loc_152
		push	si
		inc	si
		mov	bl, 8

loc_140:
		cmp	byte  [si], 0
		jnz	short loc_148
		mov	byte  [si], 1Eh

loc_148:
		add	si, [cs:word_189+bx]
		dec	bx
		dec	bx
		jnz	short loc_140
		pop	si

loc_152:
		add	si, 6D6Ch
		adc	dx, 5A6Ah
		shr	dx, 1
		rcr	si, 1
		jnb	short loc_164
		or	dx, 8000h

loc_164:
		cmp	si, 0FA00h
		ja	short loc_152
		cmp	si, 0F000h
		jb	short loc_130
		mov	ah, 1
		int	16h		; KEYBOARD - CHECK BUFFER, DO NOT CLEAR
					; Return: ZF clear if character in buffer
					; AH = scan code, AL = character
					; ZF set if no character in buffer
		jz	short loc_130
		mov	ah, 0
		int	16h		; KEYBOARD - READ CHAR FROM BUFFER, WAIT IF EMPTY
					; Return: AH = scan code, AL = character
		cmp	al, 1Bh
		jnz	short loc_130
		mov	ax, 3
		int	10h		; - VIDEO - SET VIDEO MODE
					; AL = mode

loc_183:				; CODE XREF: seg000:010Ej
		mov	ah, 4Ch
		int	21h		; DOS - 2+ - QUIT WITH EXIT CODE (EXIT)
					; AL = exit code
; ---------------------------------------------------------------------------
		db  9Ah ; š
		db  78h ; x
word_189	dw 3456h
		db  12h
		db 0C3h ; Ã
		db  80h ; €
		db 0FDh ; ý
		db  41h ; A
		db    1
		db 0FEh ; þ
		db 0FFh
		db  73h ; s
		db  74h ; t
		db  72h ; r
		db  69h ; i
		db  6Eh ; n
		db  67h ; g

