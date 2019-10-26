; StarWars, by Spanska (23 sept 1998)
; For the Christmas 256 Bytes Demo Compo
;
; Compile it with "tasm starwars /m2" and "tlink starwars /t"
; 
; Comments are in french, if you have questions:
;   spanska@redneck.efga.org
;   el_gato@rocketmail.com

code    segment
	assume  ds:code, ss:code, cs:code, es:code
	org 100h
	.386p

largeur equ 255	
profondeur equ 50

terrain:

;--------------------passer en VGA-------------------------------

mov al, 13h     ;passer en mode 320x200
int 10h         ;go!

;---------------Mettre la palette en place--------------------

mov dx, 3c8h
xor al, al	;initialisation de la palette
out dx, al
inc dx

mov cl, 3*8
ee:
out dx, al	;couleurs de 0 à 8 = noires
loop ee

mov cl, 63
rouge:
mov al, cl
out dx, al
xor al, al	;couleurs de 9 à 72 = dégradé de rouge
out dx, al
out dx, al
loop rouge

;--------------affichage du message----------------------------------

mov dx, offset message     ;le texte s'affiche
mov ah, 9                  ;mais on le voit pas
int 21h

;--------------initialisation des segments-----------------------

push 0A000h
pop ds                  ;ds pointe sur l'ecran video

mov ax, cs
inc ah                  ;astuce stupide
mov es, ax              ;es pointe vers le segment de stockage
push es                 ;sur la pile pour ne pas recalculer (cf [@@] + bas)

;------------creation de la table (x, couleur, z) NB: y fixe--------------
;ici ds=video  es=stock

mov cx, (largeur*profondeur)  	;255*50 coordonnees
xor si, si              	;debut de l'ecran video
xor di, di              	;debut du segment stock
xor dx, dx             		;compteur qui marque chaque fin de ligne

table:

mov al, cl		;LE X... 0<al<255
sub al, 130		;pour le centrage
stosb                   ;on stocke LE X

inc dx                  ;now, la COULEUR; le compteur de ligne augmente
or dl, dl		;cmp dl, 0; fin de ligne?
jnz pas_fin_de_ligne    ;si dl=0 on est en fin de ligne
add si, 319-largeur     ;ds ce cas pointeur video sur la ligne suivante
pas_fin_de_ligne:	;si on est pas a la fin
movsb			;LA COULEUR: on stocke

mov al, ch              ;LES Z (PROFONDEUR): on veut que la partie lourde 0<al<50
xor ah, ah		;
shl al, 2		;0<al<100 puis 0<al<200
inc ax          	;1<ax<201 pour éviter une div par zero
stosw                   ;on stocke

loop table

;-------------------effacement du texte-----------------------------
;ici ds=video, es=stock, pareil

push ds
pop es  		       ;maintenant es=video
pop ds                         ;et ds pointe vers le segment de stockage [@@]

;xor di, di
;xor al, al
;mov cx, (320*50)/4
;rep stosd

;-------------------animation-----------------------------
;ici es=video, ds=stock

anime:                         ;revient ici apres chaque ecran dessine

mov cx, largeur*profondeur     ;on va dessiner 255*50 points
xor si, si                     ;ds:si=stockage des coordonnees
xor di, di                     ;es:di=video

dessine:                       ;revient ici apres chaque point dessine

push cx				;va etre utilisé pour stocker Z
lodsw			       ;X et couleur dans ax
xchg ax, bx		       ;on les passe dans bx
lodsw                          ;le Z dans ax
mov cx, ax			;on le passe ds cx
cmp ax, (128+4*profondeur)     ;le point est a la limite vers le fond?
jb ca_sort_pas                 ;si non on va l'eloigner
sub ax, 240                    ;si oui on le remet devant
ca_sort_pas:                   ;
inc ax                         ;on l'eloigne donc
mov word ptr ds:[si-2], ax     ;et on stocke sa nouvelle coordonnee

;------calcule xx et yy (ecran) a partir de x, y et z (espace)------
;x est dans bl, couleur dans bh, z dans cx

xchg ah, bl			 ;on recupere X dans ah
xor al, al                       ;X est dans ah: meme ordre que Z  
xor dx, dx                       ;pour que dx vienne pas foutre la merde     
div cx				;on divise X par Z
push ax                          ;le resultat est la coordonnee 2D (XX)
mov ah, 68                       ;Y est a l'envers, niveau 70 = sol
xor al, al                       ;calcul en virgule fixe: Y est dans ax   
xor dx, dx                       ;pour que dx vienne pas foutre la merde           
div cx				;on divise Y par Z
	                      ;le resultat est la coordonnee 2D (YY) 

;-------calcule l'offset video des points-----------------
;YY est dans ax, XX sur la pile
;la couleur est tjs ds bh, Z est dans cx

pop dx                               ;on recupere XX de la pile dans dx
cmp dx, 250                          ;pas afficher si trop sur le cote
ja pas_plot

push dx                              ;on remet XX sur la pile
mov dx, 320                          ;calcul de l'offset video
mul dx                               ;on multiplie YY par 320
pop dx                               ;on recupere XX de la pile dans dx
sub ax, dx                           ;on soustrait XX a ax

sub ax, (320*5)+50                 ;image bien placee sur l'ecran

;--------calcule la couleur du point (effet d'ombre)------------------
;l'offset du pixel est dans ax
;la couleur est tjs ds bh, Z est dans cx

mov di, ax		;ax est donc l'offset video du point
push ax			;on le met sur la pile pour apres
or bh, bh		;cmp bh, 0 ;couleur noire?
je eteindre		;oui: on affiche un point noir

shr cx, 2			;on avait 128<cx<328, maintenant 32<cx<82
mov al, cl			;32<al<82
sub al, 14			;16 (rouge) <al< 66 (noir)
jmp pas_eteindre
eteindre:
xor al, al			;pour afficher un point noir
pas_eteindre:

;--------calcule la taille du point------------------
;la couleur est dans al

pop dx			;recup de l'offset du point
mov ah, al		;mettre ah=al pour pouvoir faire un stosw
cmp dh, 80		;au-dessus de la ligne 64? (320*64 = 255*80)
jb fond			;oui: il est petit (loin)
cmp dh, 155		;au-dessus de la ligne 123? (320*123 = 255*155)
jb moyen		;oui: il est moyen

proche:			;sinon, il est gros (proche)
stosw
stosw
add di, 320-5		;gros= 2 lignes de 4 pixels
stosw
stosw
jmp pas_plot
moyen:
stosb			;moyen= 2 pixels
fond:
stosb			;petit= 1 pixel

pas_plot:                 ;on tombe la en cas de depassement de l'ecran
pop cx                    ;ne pas oublier de recuperer le compteur
dec cx                    ;un point de plus
jne dessine               ;on recommence pour le point suivant

suite9:
in al,60h
dec ax			;escape?
jnz anime		;on recommence pour l'ecran suivant

;---------------------------fin du programme----------------------------

fin:
mov ax, 3        ;revenir en    
int 10h          ;mode texte

mov ah,4ch     ;redonner la main
int 21h          ;au DOS

;----------------------zones memoire utilisees-----------------------

message db " A long"    ,13,10
	db "time ago"   ,13,10
	db "  in a"   ,13,10
	db "very far"   ,13,10
	db " galaxy"   ,13, 10
	db "  ...$"

code    ends
	end     terrain

;----------------(c) Spanska 1998------------------------------------
