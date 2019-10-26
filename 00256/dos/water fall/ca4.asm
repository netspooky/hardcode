; 256 byte demo by Ameno (ameno_dnl@hotmail.com)

[bits 16]
[org 0x0100]
[section .text]

;------------------------------- Initialisation du mode vidéo---;
	mov	ax,0013h	;mode video 320*200		;
	int	10h		;256 couleurs			;
	mov	ax,0A000h	;adresse de la mémoire		;
	mov	es,ax		;vidéo dans ES			;
;---------------------------------------------------------------;

; palette ------------------------------------------------------;
mov dx, 0x03c9
setcolor:
out dx, al
xchg bx, ax
out dx, al
xchg bx, ax
out dx, al
xchg bx, ax
inc ax
jnz setcolor
;------------------------ Premiere ligne ------------------------
	
	mov	word [y],0
	mov	word [x],150
	mov	al,150
ligne0:
	inc	word [x]
	call	affiche_pixel
	cmp	word [x],250
	je	tout_debut_2
	jmp	ligne0

;--------------------- Premier ecran -----------------------------
	
tout_debut_2:
	mov	word [y],0
y_loop:
	mov	word [x],0
	inc	word [y]
	cmp	word [y],200
	ja	boucle
x_loop:
	inc	word [x]
	cmp	word [x],319
	ja	y_loop

;--------------------------On ce place à la ligne du dessus-----;
								;
	mov	di,[x]		;X				;
	mov	ax,[y]		;Y				;
	dec	ax		;Y-1				;
	mov	cx,320						;
	mul	cx		;Y*320				;
	add	di,ax		;Y*320+X			;
								;
								;
;---------------------------------------------------------------;

	mov	ax,0
	mov	al,byte [ES:DI-1]
	add	al,byte [ES:DI]
	add	al,byte [ES:DI+1]
	mov	bl,3
	div	bl
	inc	al


	call	affiche_pixel
	jmp	x_loop

;------------------------------- Attend touche    --------------;
boucle:								;
	in	al,60h						;
	cmp	al,1						;
	jne	decale_ligne					;
;------------------------------- Fin du programme --------------;
fin:								;
	mov	ax,4C00h					;
	int	21h						;
;---------------------------------------------------------------;


decale_ligne:
	mov	ax,319
decale_loop:
	inc	ax
	cmp	ax,63680
	ja	derniere_ligne
	mov	di,ax
	mov	bl,byte [ES:DI]
	mov	byte [ES:DI-320],bl
	jmp	decale_loop
derniere_ligne:
	mov	word [y],198
	mov	word [x],0
x_loop_derniere_ligne:
	inc	word [x]
	cmp	word [x],319
	ja	boucle
;--------------------------On ce place à la ligne du dessus-----;
								;
	mov	di,[x]		;X				;
	mov	ax,[y]		;Y				;
	dec	ax		;Y-1				;
	mov	cx,320						;
	mul	cx		;Y*320				;
	add	di,ax		;Y*320+X			;
								;
								;
;---------------------------------------------------------------;
	mov	ax,0
	mov	al,byte [ES:DI-1]
	add	al,byte [ES:DI]
	add	al,byte [ES:DI+1]
	mov	bl,3
	div	bl
	inc	al
	call	affiche_pixel
	jmp	x_loop_derniere_ligne


;------------------------------- Affiche le pixel --------------;
affiche_pixel:							;
	push	ax
	mov	di,[x]		;X				;
	mov	ax,[y]		;Y				;
	mov	cx,320						;
	mul	cx		;Y*320				;
	add	di,ax		;Y*320+X			;
	pop	ax						;
	stosb			;affiche le pixel		;
ret								;
;---------------------------------------------------------------;

;---Data ------------------------------------------------------------------
[section .data]
y: dw 2
x: dw 2
;---EOF--------------------------------------------------------------------