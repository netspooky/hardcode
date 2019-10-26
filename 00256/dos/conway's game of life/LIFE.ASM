;------------------------------------------------------------;
;  LIFE.COM -- Conway's Game of Life                         ;
;  Danny Dulai's submission to the 256 byte game competition ;
;                                                            ;
;  Arrow keys - move cursor                                  ;
;  Space      - places cell                                  ;
;  Enter      - one generation                               ;
;                                                            ;
; NOTE: NO ERROR HANDLING! MAKE SURE YOU HAVE AT LEAST       ;
;       192K AVAILIBLE MEMORY!                               ;
;                                                            ;
;------------------------------------------------------------;

.model tiny
.code
.386
org 100h
start proc
	mov	ah,4ah
	mov	bx,4096
	int	21h

	mov	ah,48h
	int	21h
	mov	bp,ax

	mov	ah,48h
	int	21h
	mov	di,ax

	mov	ax,13h
	int	10h

	mov	fs,di
	mov	ds,bp

	mov	es,bp
	xor	di,di
	mov	cx,32000
	xor	ax,ax
	rep	stosw

	mov	ax,0a000h
	mov	es,ax

helu:	xor	si,si
	xor	di,di
	mov	cx,16000
	rep	movsd
	mov	si,cs:cursor
	mov	byte ptr es:[si],15

	mov	ah,0
	int	16h

	cmp	ah,1
	je	done

	cmp	ah,39h
	jne	noput

	mov	si,cs:cursor
	mov	byte ptr ds:[si],1
	
noput:	cmp	ah,4dh
	jne	noright
	inc	cs:cursor

noright:cmp	ah,4bh
	jne	noleft
	dec	cs:cursor

noleft:	cmp	ah,50h
	jne	nodown
	add	cs:cursor,320

nodown:	cmp	ah,48h
	jne	noup
	sub	cs:cursor,320

noup:	cmp	ah,1ch
	jne	helu
	call	generate
	jmp	helu

done:
	mov	ax,3
	int	10h
	ret
start endp

generate proc
	pusha
	mov	cx,64000-642
	mov	si,321
	mov	di,si
hello:

	mov	al,ds:[si-1]
	add	al,ds:[si+1]
	add	al,ds:[si+320]
	add	al,ds:[si-320]
	add	al,ds:[si+321]
	add	al,ds:[si-321]
	add	al,ds:[si+319]
	add	al,ds:[si-319]

	cmp	al,2
	jae	nodead

	mov	byte ptr fs:[di],0
	jmp	guby

nodead:	cmp	al,3
	je	nodead2

	cmp	al,2
	jne	dead

	cmp	byte ptr ds:[si],0
	jne	nodead2

dead:	mov	byte ptr fs:[di],0
	jmp	guby

nodead2:
	mov	byte ptr fs:[di],1
	
guby:
	inc	si
	inc	di
	dec	cx
	jnz	hello

	mov	ax,ds
	mov	bx,fs
	mov	ds,bx
	mov	fs,ax

	popa
	ret
generate endp

cursor	dw	32160

end start
