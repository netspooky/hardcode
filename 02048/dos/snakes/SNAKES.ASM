.model tiny
.stack 100h
.386
ASSUME CS:KOD,DS:DANE

DANE SEGMENT USE16
	DlugStosb				equ	3
	KlawiszEsc				equ	1
	KlawiszGora				equ	72
	KlawiszDol				equ	80
	KlawiszLewo				equ	75
	KlawiszPrawo			equ	77
	KlawiszGora2			equ	17
	KlawiszDol2				equ	31
	KlawiszLewo2			equ	30
	KlawiszPrawo2			equ	32

Config:
	KolorGlowki				db	100
	KolorGlowki2			db	100
	KolorGracza				db	StartK
	KolorGracza2			db	StartK2
	KolorRamek				db	120
	KolorTla				db	0
	KierunekGracza			db	StartK
	KierunekGracza2			db	StartK2
	Speed					db	?
	TrybGry				db	0	;0 - 2P; 1 - 1P; 2 - 2P|;
DlugCfg equ ($-Config)

	FALSE					equ	0
	PlikCfg				db	'CONFIG.JAH',0
	StartX				equ	240
	StartX2				equ	80
	StartY				equ	100
	StartK				equ	4
	StartK2				equ	2

	SzerokoscEkranu			equ	320
	SzybkoscGry				equ	4
	TRUE					equ	0FFh
	WysokoscEkranu			equ	200
	X					dw	StartX
	X2					dw	StartX2
	Y					dw	StartY
	Y2					dw	StartY
DANE ENDS

KOD SEGMENT USE16
START:
	mov	ax,seg DANE
	mov	ds,ax

	call	UstawNowePrzerwanieKlawiatury
	call	ZainstalujPrzerwanieZegara
	call	UstawSzybkiTimer
	call	WczytajKonfiguracje

	mov	ax,seg Ekran
	mov	es,ax

	mov	ax,13h
	int	10h

PlayGame:
	mov	sp,100h

	mov	X,StartX
	mov	X2,StartX2
	mov	Y,StartY
	mov	Y2,StartY
	mov	KierunekGracza,StartK
	mov	KierunekGracza2,StartK2

	call	WyczyscEkran
	call	NarysujRamki

PetlaGry:
	cmp	cs:[BuforKlawiszy+KlawiszEsc],TRUE
	jz	ZakonczProgram

	call	Zareaguj
	call	NarysujGraczy
	call	NarysujGlowki


	call	NarysujBuforNaEkranie
	call	OpoznijGre
	jmp	PetlaGry

ZakonczProgram:
	call	PrzywrocstarePrzerwanieKlawiatury
	call	PrzywrocNormalnyTimer
	call	PrzywrocStarePrzerwaniaZegara

	mov	ax,3
	int	10h

	mov	ax,4C01h
	int	21h


;***********************************************;
NarysujBuforNaEkranie:					;rysuj tablicê "Ekran" w pamiêci
	push	ds						;ekranu - A000:0000
	push	es						;
								;
	mov	ax,seg Ekran				;
	mov	ds,ax						;
	mov	si,0						;
	push	0A000h					;
	pop	es						;
	mov	di,0						;
	mov	cx,SzerokoscEkranu*WysokoscEkranu/4	;to jest 16000 -jakby nie mo¿na by³o
	cld							;normalnie...?
	rep	movsd						;
								;
	pop	es						;
	pop	ds						;
ret								;
;***********************************************;
NarysujGraczy:
	cmp	KierunekGracza,1
	jnz	NGNieGora
	mov	bx,X
	mov	ax,Y
	inc	ax
	call	Pixel
	mov	di,bx
	mov	al,KolorGracza
	stosb
NGNieGora:

	cmp	KierunekGracza,2
	jnz	NGNiePrawo
	mov	bx,X
	mov	ax,Y
	dec	bx
	call	Pixel
	mov	di,bx
	mov	al,KolorGracza
	stosb
NGNiePrawo:

	cmp	KierunekGracza,3
	jnz	NGNieDol
	mov	bx,X
	mov	ax,Y
	dec	ax
	call	Pixel
	mov	di,bx
	mov	al,KolorGracza
	stosb
NGNieDol:

	cmp	KierunekGracza,4
	jnz	NGNieLewo
	mov	bx,X
	mov	ax,Y
	inc	bx
	call	Pixel
	mov	di,bx
	mov	al,KolorGracza
	stosb
NGNieLewo:



	cmp	TrybGry,1
	jz	NarysujGraczyRET

	cmp	KierunekGracza2,1
	jnz	NGNieGora2
	mov	bx,X2
	mov	ax,Y2
	inc	ax
	call	Pixel
	mov	di,bx
	mov	al,KolorGracza2
	stosb
NGNieGora2:

	cmp	KierunekGracza2,2
	jnz	NGNiePrawo2
	mov	bx,X2
	mov	ax,Y2
	dec	bx
	call	Pixel
	mov	di,bx
	mov	al,KolorGracza2
	stosb
NGNiePrawo2:

	cmp	KierunekGracza2,3
	jnz	NGNieDol2
	mov	bx,X2
	mov	ax,Y2
	dec	ax
	call	Pixel
	mov	di,bx
	mov	al,KolorGracza2
	stosb
NGNieDol2:

	cmp	KierunekGracza2,4
	jnz	NGNieLewo2
	mov	bx,X2
	mov	ax,Y2
	inc	bx
	call	Pixel
	mov	di,bx
	mov	al,KolorGracza2
	stosb
NGNieLewo2:

NarysujGraczyRET:
ret
;***********************************************;
NarysujGlowki:
	mov	bx,X
	mov	ax,Y
	call	Pixel
	mov	di,bx
	mov	al,KolorGlowki
	stosb

	cmp	TrybGry,1					;czy gracz2 nie gra?
	jz	NarysujGlowkiRET

	mov	bx,X2
	mov	ax,Y2
	call	Pixel
	mov	di,bx
	mov	al,KolorGlowki2
	stosb
NarysujGlowkiRET:
ret
;***********************************************;
NarysujRamki:
	mov	al,KolorRamek

	mov	di,0
	mov	cx,320
	cld	
	rep	stosb

	mov	di,SzerokoscEkranu*WysokoscEkranu-SzerokoscEkranu
	mov	cx,320
	cld
	rep	stosb

	mov	di,0
	mov	cx,WysokoscEkranu
RysujRamki1:
	stosb
	add	di,318
	stosb
	loop	RysujRamki1

	cmp	TrybGry,2
	jnz	NieStawiajKreskiPionowejNaSrodkuEkranuWRozdzielczosci320Na200

	mov	di,160
	mov	al,KolorRamek
	mov	cx,200
 StawiajKreskePionowaNaSrodkuEkranuWRozdzielczosci320Na200:
	stosb
	add	di,SzerokoscEkranu-1
	loop	StawiajKreskePionowaNaSrodkuEkranuWRozdzielczosci320Na200	

NieStawiajKreskiPionowejNaSrodkuEkranuWRozdzielczosci320Na200:
ret
;***********************************************;
ObslugaPrzerwaniaKlawiatury:				;procedura obs³ugi przerwania
	pushf							;IRQ 9 klawiatury napisana
	push	ax						;przez Adama B³aszczyka
	push	si						;
								;DZIÊKI ADAM!
	in	al,60h					;
	mov	ah,0 						;
								;zapisuje do BUFORAKLAWISZY
	xchg	ax,si						;TRUE albo FALSE pod offsetem
	in	al,61h					;odpowiadaj¹cym numerowi
	mov	ah,al						;klawisza
	or	al,80						;
	out	61h,al					;
	xchg	ah,al						;	
	out	61h,al					;
								;
	mov	ax,si						;
	and	si,127					;
								;
	mov	ah,FALSE					;
								;
	cmp	al, 128					;
	ja	ooo						;
	mov	ah,TRUE					;
ooo:								;
	mov	cs:[BuforKlawiszy+si],ah		;
	mov	al,20h					;
	out	20h,al					;
	pop	si						;
	pop	ax						;
	popf							;
iret								;
								;
BuforKlawiszy	db	128 dup (FALSE)		;
;***********************************************;
OpoznijGre:							;poczekaj tyle mikrosekund
	cmp	cs:[MoznaGrac],TRUE			;
	jnz	OpoznijGre					;
	mov	cs:[MoznaGrac],FALSE			;
ret								;
;***********************************************;
Pixel:							;
       xchg ah,al 					;
       add bx,ax 						;
       shr ax,1 						;
       shr ax,1 						;
       add bx,ax 						;
       ret							;
;***********************************************;
PrzywrocNormalnyTimer:					;
	cli							;
	mov	al,036h					;timer - 18.2 Hz
	out	043h,al					;
	mov	al,0						;
	out	040h,al					;
	out	040h,al					;	
	sti							;
ret								;
;***********************************************;
PrzywrocStarePrzerwanieKlawiatury:			;wiadomo
	push	ds						;
	push	cs						;
	pop	ds						;
	lds	dx,dword ptr cs:[StarePrzerwanieKlawiatury]
	mov	ax,2509h					;
	int	21h						;
	pop	ds						;
ret								;
;***********************************************;
PrzywrocStarePrzerwaniaZegara:			;
	push	ds						;
	push	cs						;
	pop	ds						;
	lds	dx,dword ptr cs:[StarePrzerwanie8]	;
	mov	ax,2508h					;
	int	21h						;
	pop	ds						;
ret								;
;***********************************************;
UstawNowePrzerwanieKlawiatury:			;ustawia adres IRQ 9h na
	push	es						;proc. "ObslugaPrzerwaniaKlawiatury"
	mov	ax,3509h					;
	int	21h						;
	mov	word ptr cs:[StarePrzerwanieKlawiatury],bx
	mov	word ptr cs:[StarePrzerwanieKlawiatury+2],es
	pop	es						;
								;
	push	ds						;
	push	cs						;
	pop	ds						;
	lea	dx,ObslugaPrzerwaniaKlawiatury	;
	mov	ax,2509h					;
	int	21h						;
	pop	ds						;
								;
	push	es						;
	mov	ax,seg BuforKlawiszy			;
	mov	es,ax						;
	lea	di,BuforKlawiszy				;
	mov	cx,128					;
	mov	al,FALSE					;
	cld							;
	rep	stosb						;
	pop	es						;
ret								;
StarePrzerwanieKlawiatury dd ?			;
;***********************************************;
UstawSzybkiTimer:						;
	cli							;
	mov	al,036h					;timer - 200 Hz
	out	043h,al					;
	mov	al,04eh					;
	out	040h,al					;
	mov	al,017h					;
	out	040h,al					;
	sti							;
ret								;
;***********************************************;
ObslugaPrzerwania8:					;
	push	ax						;
	dec	cs:[DelayCount]				;
	jnz	JeszczePoczekaj				;
								;
	mov	al,cs:[DelayGry]				;
	mov	cs:[DelayCount],al			;
	mov	cs:[MoznaGrac],TRUE			;
								;
JeszczePoczekaj:						;
	pop	ax						;
	db	0eah						;
StarePrzerwanie8	dw	0,0				;
								;
PrzerwanieZegara		equ	08h			;
DelayCount			db	SzybkoscGry		;
DelayGry			db	SzybkoscGry		;
MoznaGrac			db	TRUE			;
								;
								;
ZainstalujPrzerwanieZegara:				;czêœæ instaluj¹ca obs³ugê
	push	ds						;przerwania sprzêtowego 08h
	push	es						;
								;
	push	cs						;
	pop	ds						;
								;
	mov	ah,35h					;
	mov	al,PrzerwanieZegara			;
	int	21h						;
	mov	word ptr cs:[StarePrzerwanie8],bx	;
	mov	word ptr cs:[StarePrzerwanie8+2],es	;
								;
	mov	dx,offset ObslugaPrzerwania8		;...i 08h
	mov	ah,25h					;
	mov	al,PrzerwanieZegara			;
	int	21h						;
								;
	pop	es						;
	pop	ds						;
	ret							;
;***********************************************;
WyczyscEkran:
	mov	cl,16
	mov	al,KolorTla
	mov	ah,KolorTla
	shl	eax,cl
	mov	al,KolorTla
	mov	ah,KolorTla
	mov	cx,16000
	mov	di,0
	cld
	rep	stosd
ret
;***********************************************;
Zareaguj:
	cmp	cs:[BuforKlawiszy+KlawiszGora],TRUE
	jnz	GraczNieGora
	cmp	KierunekGracza,3
	jz	GraczNieGora
	mov	KierunekGracza,1
GraczNieGora:
	cmp	cs:[BuforKlawiszy+KlawiszDol],TRUE
	jnz	GraczNieDol
	cmp	KierunekGracza,1
	jz	GraczNieDol
	mov	KierunekGracza,3
GraczNieDol:
	cmp	cs:[BuforKlawiszy+KlawiszLewo],TRUE
	jnz	GraczNieLewo
	cmp	KierunekGracza,2
	jz	GraczNieLewo
	mov	KierunekGracza,4
GraczNieLewo:
	cmp	cs:[BuforKlawiszy+KlawiszPrawo],TRUE
	jnz	GraczNiePrawo
	cmp	KierunekGracza,4
	jz	GraczNiePrawo
	mov	KierunekGracza,2
GraczNiePrawo:

	cmp	TrybGry,1
	jz	Gracz2NieGra

	cmp	cs:[BuforKlawiszy+KlawiszGora2],TRUE
	jnz	GraczNieGora2
	cmp	KierunekGracza2,3
	jz	GraczNieGora2
	mov	KierunekGracza2,1
GraczNieGora2:
	cmp	cs:[BuforKlawiszy+KlawiszDol2],TRUE
	jnz	GraczNieDol2
	cmp	KierunekGracza2,1
	jz	GraczNieDol2
	mov	KierunekGracza2,3
GraczNieDol2:
	cmp	cs:[BuforKlawiszy+KlawiszLewo2],TRUE
	jnz	GraczNieLewo2
	cmp	KierunekGracza2,2
	jz	GraczNieLewo2
	mov	KierunekGracza2,4
GraczNieLewo2:
	cmp	cs:[BuforKlawiszy+KlawiszPrawo2],TRUE
	jnz	GraczNiePrawo2
	cmp	KierunekGracza2,4
	jz	GraczNiePrawo2
	mov	KierunekGracza2,2
GraczNiePrawo2:

	Gracz2NieGra:

	mov	al,KierunekGracza
	cmp	al,1
	jnz	GraczNiePolnoc
	dec	Y
	push	ax
	mov	bx,X
	mov	ax,Y
	call	Sprawdz
	pop	ax
GraczNiePolnoc:
	cmp	al,2
	jnz	GraczNieWschod
	inc	X
	push	ax
	mov	bx,X
	mov	ax,Y
	call	Sprawdz
	pop	ax
GraczNieWschod:
	cmp	al,3
	jnz	GraczNiePoludnie
	inc	Y
	push	ax
	mov	bx,X
	mov	ax,Y
	call	Sprawdz
	pop	ax
GraczNiePoludnie:
	cmp	al,4
	jnz	GraczNieZachod
	dec	X
	push	ax
	mov	bx,X
	mov	ax,Y
	call	Sprawdz
	pop	ax
GraczNieZachod:

	cmp	TrybGry,1
	jz	Gracz2NieGra2

	mov	al,KierunekGracza2
	cmp	al,1
	jnz	GraczNiePolnoc2
	dec	Y2
	push	ax
	mov	bx,X2
	mov	ax,Y2
	call	Sprawdz
	pop	ax
GraczNiePolnoc2:
	cmp	al,2
	jnz	GraczNieWschod2
	inc	X2
	push	ax
	mov	bx,X2
	mov	ax,Y2
	call	Sprawdz
	pop	ax
GraczNieWschod2:
	cmp	al,3
	jnz	GraczNiePoludnie2
	inc	Y2
	push	ax
	mov	bx,X2
	mov	ax,Y2
	call	Sprawdz
	pop	ax
GraczNiePoludnie2:
	cmp	al,4
	jnz	GraczNieZachod2
	dec	X2
	push	ax
	mov	bx,X2
	mov	ax,Y2
	call	Sprawdz
	pop	ax
GraczNieZachod2:

	Gracz2NieGra2:
ret
;***********************************************;
Sprawdz:
	call	Pixel
	mov	di,bx

	mov	bl,byte ptr es:[di]
	cmp	bl,KolorTla
	jz	WszystkoOK
	jmp	PlayGame
WszystkoOK:
ret

WczytajKonfiguracje:
	lea	dx,PlikCfg
	mov	ax,3d02h
	int	21h
	jc	BladPliku
	xchg	ax,bx

	mov	cx,DlugCfg
	lea	dx,Config
	mov	ah,3fh
	int	21h

	mov	ah,3eh
	int	21h

	mov	al,ds:[Speed]
	mov	cs:[DelayGry],al
BladPliku:
ret

KOD ENDS
;***********************************************;

;***********************************************;
Ekran SEGMENT USE16					;segment bufora
	db	65535 dup (0)				;
Ekran ENDS							;
;***********************************************;

END START