;Coded by: Albe
;-albe-@libero.it
;"Al-blur" written for #asm 128 bytes competition
;
;2/11/2000
;
;Hey boys, i'm looking for a group (games, demos, and so on)
;...though i'm not very experienced... :)
;if you want, contact me at -albe-@libero.it
;
;Greets to: KiNg[G]hZ and Sephirot
;and greets also to Denthor and his excellent tutorials...

.386
.model tiny
.code
org 100h
main	proc
	mov al,13h		;set vga mode 13h
	int 10h

	mov dx,3c9h		;palette register
;this palette routine only affects color >= 13, but i don't care...
palette3:
	dec dx			;dec and inc save some bytes instead of
				;"mov dx,3c9h", "mov dx,3c8h"
	out dx,al
	inc dx
	push ax			;saves ax
	xor al,al
	out dx,al		;don't set red...
	out dx,al		;don't set green!
	pop ax
	push ax
	cmp al,210		;the first 210 colors are the same (dark blu)
	ja pal5
	mov al,15		;set dark blu (15)
pal5:
	out dx,al		;set blu
	pop ax
	inc al
	jnz palette3

	mov ah,080h		;ax=8000h (some free memory between the PSP
				;and 0a000h)
	mov ds,ax		;memory allocated in DS
				;this is the same size as push & pop
	mov ah,0a0h
	mov es,ax
	mov bp,317		;we need to add 317 to SI 2 times, and using
				;lea si,[si+bp] is better (saves 1 byte)
a2:
	cbw			;AL here is always 0, so cbw will set AX to 0
	cwd			;AX here is always 0, so cwd will set DX to 0
	push si			;save current position
	sub si,321
	call loadsb
	lea si,[si+bp]
	lodsb
	add dx,ax
	inc si
	lodsb
	add dx,ax
	lea si,[si+bp]
	call loadsb
	pop si

	shr dx,3		;calculate the average of pixels around
	inc dx			;2 "inc"s save 1 byte (instead of add dx,2)
	inc dx
a4:
	mov byte ptr ds:[si],dl	;store the pixel
	inc si
	jnz a2

	mov dx,3dah		;this is waitretrace
l1:
	in al,dx
	and al,08h
	jnz l1
l2:
	in al,dx
	and al,08h
	jz l2

	mov cx,0ffffh/2+1
	rep movsw		;copy mem to mem

	mov ah,11h
	int 16h			;key pressed?
	jz a2

	push cs
	pop ds
	mov dx,offset msg	;write the message
	mov ah,09h
	int 21h
	ret
main	endp

loadsb	proc
	lodsb
	add dx,ax
	lodsb
	add dx,ax
	lodsb
	add dx,ax
	ret
loadsb	endp

msg	db 'ALBLUR$'
end	main
