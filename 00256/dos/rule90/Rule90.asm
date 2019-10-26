; 256 byte demo by Ameno (ameno_dnl@hotmail.com)
; It's my first one...

[bits 16]
[org 0x0100]
[section .text]

;------------------------------- Initialisation du mode vidéo---;
	mov	ax,0013h	;mode video 320*200		;
	int	10h		;256 couleurs			;
	mov	ax,0A000h	;adresse de la mémoire		;
	mov	es,ax		;vidéo dans ES			;
;---------------------------------------------------------------;

tout_debut:

;-------------------------- Dessin de la première ligne --------;
	mov	dword [y],0					;
	mov	eax,[pointinit]					;
	mov	dword [x],eax					;
	call	efface_pixel					;
	inc	dword [pointinit]				;
	cmp	dword [pointinit],319				;
	jne	suite_init					;
	mov	dword [pointinit],0				;
suite_init:							;
	mov	dword [y],0					;
	mov	eax,[pointinit]					;
	mov	dword [x],eax					;
	mov	al,5
	call	affiche_pixel					;
;----------------------------------------------------------------

	mov	dword [y],0
y_loop:
	mov	dword [x],0
	inc	dword [y]
	cmp	dword [y],200
	ja	boucle
x_loop:
	inc	dword [x]
	cmp	dword [x],319
	ja	y_loop

	call	efface_pixel

;--------------------------On ce place à la ligne du dessus-----;
								;
	mov	di,[x]		;X				;
	mov	ax,[y]		;Y				;
	dec	ax		;Y-1				;
	mov	cx,320						;
	mul	cx		;Y*320				;
	add	di,ax		;Y*320+X			;
								;
;----------------------------------- La règle de l'automate ----;
	cmp	byte [ES:DI-1],0				;
	jne	p1						;
	jmp	n1						;
p1:								;
	cmp	byte [ES:DI+1],0				;
	jne	x_loop						;
	mov	al,2						;
	jmp	appelle_point2					;
n1:								;
	cmp	byte [ES:DI+1],0				;
	je	x_loop						;
	mov	al,4						;
	jmp	appelle_point2					;
;---------------------------------------------------------------;
	
appelle_point2:
	call	affiche_pixel
	jmp	x_loop

;------------------------------- Attend touche    --------------;
boucle:								;
	in	al,60h						;
	cmp	al,1						;
	jne	tout_debut					;
;------------------------------- Fin du programme --------------;
fin:								;
	mov dx, msg        					;
	mov	ax,0900h					;
	int 21h            					;
	mov	ax,4C00h					;
	int	21h						;
;---------------------------------------------------------------;


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
;------------------------------- Efface le pixel ---------------;
efface_pixel:							;
	mov	di,[x]		;X				;
	mov	ax,[y]		;Y				;
	mov	cx,320						;
	mul	cx		;Y*320				;
	add	di,ax		;Y*320+X			;
	mov	al,0		;couleur			;
	stosb			;affiche le pixel		;
ret								;
;---------------------------------------------------------------;

;---Data ------------------------------------------------------------------
[section .data]
pointinit: dw 0
y: dw 2
x: dw 2
msg  db 'Bye !', '$'
;---EOF--------------------------------------------------------------------