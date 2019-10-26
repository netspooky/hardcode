;   Uz dlhsi cas som chcel spravit nejaku tu demovecicku a ked som sa dozvedel
;o DEMOBITe 95 tak som si povedal ze uz je najvissi cas. Takze, dal som dokopy
;nejake moje starsie rutiny, nieco som dopisal a tu je vysledok :
;
; ÚÄÄÄÄÄÄÄÄÄÄÄ¿                   ÚÄÄÄÄÄÂÄÄÄÄÄÂÄÂÄÄÄÄÄÄÂÄÄÄÄÄÂÄ¿ ÚÄÄÄÄÄÂÄÄÄÄ¿
; ÀÄÄ¿ÚÄ¿ÚÂ¿ÚÄ¿                   ³ ÚÄ¿ ³ ÚÄ¿ ³ ³ Ú¿Ú¿ ³ ÚÄ¿ ³ ÀÄ´ ÄÄÂÄ´ ÚÄ¿À¿
; Ú¿ ³ÃÄÙ³³³³ ³  P R E S E N T S  ³ ÀÄÙ ³ ³ ³ ³ ³ ³³³³ ³ ÀÄÙ ³ ÚÄ´ ÚÄÙ ³ ³ ³ ³
; ³³ ³³ ³³³³³ ³                   ³ ÚÄ¿ ³ ³ ³ ³ ³ ³³³³ ³ ÚÄ¿ ³ ÀÄ´ ÀÄÄÄ´ ÀÄÙÚÙ
; ÀÄÄÙÀÄÙÙÙÙÀÄÙ                   ÀÄÙ ÀÄÁÄÙ ÀÄÁÄÁÄÙÀÙÀÄÁÄÙ ÀÄÁÄÄÄÁÄÄÄÄÄÁÄÄÄÄÙ
;
;   Spomenul som si ako som pred dvoma rokmi zacinal na PCdle s takymito
;somarinkami a mal som strasne malo zdrojov z ktorych by som sa mohol nieco
;naucit (vecsinou to bolo len debugovanie starych znamych vecicek). Teraz
;je uz vo svetovej demoscene dost ludi, ktory ked nieco napisu tak uverejnia
;aj zdrojaky. Mne sa taky pristup velmi paci aj ked tu stale hrozi to, ze sa
;za par mesiacov v obehu objavi uplne podobna vec od ineho autora s nejakymi
;drobnymi zmenami (tymto by som chcel pozdravit Lamerov).
;Ale k veci: Takze rozhodol som sa zverejnit kompletny zdrojak tohto intra.
;Samozrejme netvrdim ze sa z neho kazdy nieco dozvie, ale nejakym coderom
;mozno da nieco noveho. Neviem ci z neho nieco budu mat uplny zaciatocnici
;s assemblerom, lebo ja zrovna nepisem moc 'pekne' (s asm som zacinal na ZX
;Spectre a preto moc nepouzivam struktury, makra a ine vymozenosti) a pretoze
;som toto intro optimalizoval na dlzku a teda niekde je dost nezrozumitelne.
;Co sa tyka komentarov, tak nejake by sa tam nasli, aj ked niesu zrovna
;podrobne. Ked som toto programoval, chcel som do tych 4k narvat co najviac
;efektov, ktore by ale neboli az take stupidne. Ak by si vedel nieco napisat
;o dost kratsie alebo nejako inac vyhodnejsie, nevahaj a posli mi maila.
;   COM ma po skompilovani (2 prechody) 4370 bajtov. Ziadnym mne znamym
;pakovacom exacov a comov sa mi to nepodarilo dostat pod hranicu 4096, tak
;som jednemu pakovacu upravil rozpakovavaciu procedurku a bol som velmi
;prekvapeny. Takto sa mi to totizto podarilo spakovat na 3972 bajtov,
;cize mi tam ostalo miesto aj na nejake trapne anti-debug rutinky.
;Ak nahodou vies o nejakom pakovaci co je este uspesnejsi, mailni mi prosim
;jeho nazov, verziu a ine podrobnosti.
;
;   Informacie, pripomienky, navrhy, nazory a nadavky posielaj na:
;        Email: semancip@decef.elf.stuba.sk
;        (Peter Semancik, Romanova 44, 851 02  BRATISLAVA)
;
;   Thanx 4 reading.
;   5.5.1995 (C) SEMO
;


stiming	equ	0		; Nenulova hodnota zapne vykreslovanie timingu
start0	equ	start		; Moze tu byt 'start' alebo 'part2' - 'part12'


code	segment	para
	assume	cs:code,ds:code
	
	.386p
	org	100h

;±±±±±±±±±±±±±±±±±±±±±±±±±±  ALOKOVANIE PAMETE  ±±±±±±±±±±±±±±±±±±±±±±±±±±±
start:	cld
	mov	ax,offset stakdno
	mov	sp,ax
	push	0
	shr	ax,4
	inc	ax
	mov	bx,cs
	add	ax,bx
	mov	di,offset fontseg
	mov	cx,8		; 'Alokuje' 8 plnych segmentov
segco1:	stosw
	add	ax,1000h
	loop	segco1
	sub	ax,2496		; Posledny ma len 26k
	js	memok1
error:	mov	ax,4c01h	; Malo pamete, Nieje 386+, Nieje VGA
	int	21h
memok1:	cmp	ax,word ptr ds:[2]	; Staci pamet ?
	ja	error
;±±±±±±±±±±±±±±±±±±±±±±±±±  TEST 386ky A VGAcky  ±±±±±±±±±±±±±±±±±±±±±±±±±±
	push	sp		; 286+ test
	pop	ax
	cmp	ax,sp
	jne	error
	sgdt	pword ptr stakdno	; 386+ test
	inc	byte ptr ds:[offset stakdno+5]
	jz	error
	mov	ax,1a00h	; VGA test
	int	10h
	cmp	al,1ah
	jne	error
	mov	dx,offset beg1txt
	call	puts
;±±±±±±±±±±±±±±±±±±±  PREPOCITANIE COSINUSOVEJ TABULKY  ±±±±±±±±±±±±±±±±±±±
	mov	ebx,1000000h	; Darrenov cosinus generator
	xor	edx,edx
	mov	di,offset costab
	mov	bp,offset costab2
	mov	cx,400h
	cld
mkcos1:	imul	eax,ebx,5
	sar	eax,11h
	sub	edx,eax
	add	ebx,edx
	imul	eax,ebx,1Fh
	sar	eax,0Eh
	stosw
	mov	[bp],ah
	inc	bp
	loop	mkcos1
;±±±±±±±±±±±±±±±±±±±±±  PREPOCITANIE DREVENEJ TEXTURY  ±±±±±±±±±±±±±±±±±±±±
	mov	es,cs:frc1seg
	xor	di,di
	mov	cx,257
frc1c1:	call	rnd		; Prvy riadok je nahodny
	stosb
	loop	frc1c1
	mov	cx,-257
	mov	bh,0
frc1c2:	call	rnd		; Ostatne zavisia od predchadzajuceho + rnd
	and	ax,63
	sub	ax,31
	mov	bl,es:[di-256]
	add	ax,bx
	mov	bl,es:[di-257]
	add	ax,bx
	sar	ax,1
	jns	frc1c3
	xor	ax,ax
frc1c3:	or	ah,ah
	jz	frc1c4
	mov	al,255
frc1c4:	stosb
	loop	frc1c2
	call	putbod
;±±±±±±±±±±±±±±±±±±±  PREPOCITANIE MRAMOROVEJ TEXTURY  ±±±±±±±±±±±±±±±±±±±±
	mov	ds,cs:frc2seg
	xor	di,di
frc2c1:	call	rnd		; Najprv je to uplny sum
	mov	[di],al
	inc	di
	jnz	frc2c1
	mov	cx,4
frc2c2:	push	cx
	call	pbsoft		; ktory sa 4x vyhladzuje
	pop	cx
	loop	frc2c2
	push	cs
	pop	ds
	mov	dx,offset beg2txt
	call	puts
;±±±±±±±±±±±±±±±±±±±±±±±  PREPOCITANIE FONTU 32x64  ±±±±±±±±±±±±±±±±±±±±±±±
	mov	es,cs:fontseg
	push	es
	push	es
	pop	ds
	call	clseg
	mov	ax,1130h
	mov	bh,6
	int	10h
	push	es
	pop	fs
	pop	es
	add	bp,16*'<'
	mov	di,32		; Zvecsi a zapise 32 pismen
cmfnt1:	push	di		; Slucka pre pismeno
	mov	bl,16
cmfnt2:	mov	bh,4		; Slucka pre 4x zvecseny riadok
cmfnt3:	mov	cx,8		; Slucka pre riadok
	mov	dl,fs:[bp]
cmfnt4:	shl	dl,1		; Slucka pre 4x zvecseny bod
	sbb	eax,eax
	stosd
	loop	cmfnt4
	add	di,256-32	; Pismena su ulozene po 8 v 4 riadkoch
	dec	bh
	jnz	cmfnt3
	inc	bp
	dec	bl
	jnz	cmfnt2
	pop	ax
	add	al,32
	jnc	cmfnt5
	add	ah,64
	jc	cmfnt6
cmfnt5:	mov	di,ax
	jmp	cmfnt1
cmfnt6:	mov	cx,9		; Pismena sa po zvecseni 9x vyhladia
cmfnt7:	push	cx
	call	pbsoft
	pop	cx
	loop	cmfnt7
	xor	si,si
	mov	bl,63
cmfnt8:	mov	al,[si]		; a potom sa zmenia na dvojfarebne
	cmp	bl,al
	sbb	al,al
	mov	[si],al
	inc	si
	jnz	cmfnt8
;±±±±±±±±±±±±±±±±±±±±±  PREPOCITANIE OBRAZKU KRUHOV  ±±±±±±±±±±±±±±±±±±±±±±
	call	putbod
	mov	ds,cs:kruhseg
	xor	bx,bx		; BL,BH - suradnice
cmkru1:	mov	al,bl		; Slucka pre bod
	sub	al,128
	jnc	cmkru2
	neg	al
cmkru2:	mul	al		; xý
	xchg	ax,dx
	mov	al,bh
	sub	al,128
	jnc	cmkru3
	neg	al
cmkru3:	mul	al		; yý
	add	dx,ax
	mov	cx,40h		; Odmocnina
	cmp	dh,40h		; DX=BLý+BHý
	jae	cmkru6
cmkru4:	or	ch,cl
	mov	al,ch
	imul	ch
	cmp	ax,dx
	jbe	cmkru5
	xor	ch,cl
cmkru5:	shr	cl,1
	jnc	cmkru4
	xor	ch,127		; CH=ûDX
cmkru6:	shl	ch,1
	mov	[bx],ch
	test	bx,0fffh
	jnz	cmkru7
	call	putbod
cmkru7:	inc	bx
	jnz	cmkru1
;±±±±±±±±±±±±±±±±±±±  PREPOCITANIE SINUSOVEHO OBRAZKU  ±±±±±±±±±±±±±±±±±±±±
	push	cs		; Su to sinusy po riadkoch, ktore maju
	pop	ds		; v strede 0 a frekvenciu zavisiacu od
	mov	es,cs:sinoseg	; sinusu cisla riadku
	xor	di,di
	mov	cx,200
msino1:	push	cx		; Slucka pre riadok
	mov	bx,cx
	shl	bx,2
	sub	bx,200h+400
	call	getcos
	movsx	ebp,ax		; EBP=frekvencia
	imul	eax,ebp,160
	neg	eax
	xchg	eax,edx		; EDX=zaciatocna hodnota riadku
	mov	cx,320
msino2:	add	edx,ebp		; Slucka pre bod
	mov	ebx,edx
	sar	ebx,10
	call	getcos
	sar	ax,8
	stosb
	loop	msino2
	pop	cx
	loop	msino1
	call	putbod
;±±±±±±±±±±±±±±±±  PREPOCITANIE ZACIATOCNEHO MANDELBROTA  ±±±±±±±±±±±±±±±±±
	mov	es,cs:mandseg
	xor	di,di
	mov	ebp,mzystr-mzzstep*(rozmer-1)/2
	mov	si,rozmer
mmand1:	mov	cx,rozmer	; Slucka pre riadok
	mov	ebx,mzxstr-mzzstep*(rozmer-1)/2
mmand2:	call	mandel		; Slucka pre bod
	stosb
	add	ebx,mzzstep
	loop	mmand2
	add	ebp,mzzstep
	test	si,3
	jnz	mmand3
	call	putbod
mmand3:	dec	si
	jnz	mmand1
;±±±±±±±±±±±±±±±±±±±±±±±  UKONCENIE TEXTOVEHO MODU  ±±±±±±±±±±±±±±±±±±±±±±±
	call	getpal		; Vyfadovanie
	call	filpalb
	mov	ax,64
	call	fdwvrc
	mov	ax,13h
	int	10h
	call	fbsgpal

if start0 ne start
	jmp	start0		; Pripadny zaciatok od inej casti
endif

;±±±±±±±±±±±±±±±±±±±±±±±±±  STARS + FADING NAME  ±±±±±±±±±±±±±±±±±±±±±±±±±±
part1:	mov	si,offset logotxt; Vykreslenie nazvu
	mov	di,32+75*320
	call	prinf1
	call	inistar		; Inicializacia hviezd
	mov	si,offset starpal; Nastavenie palety 'iba hviezdy'
	call	mkpcpp
	mov	ax,64		; a jej nabeh
	push	ax
	call	fade
	mov	cx,200		; Cakanie na nabeh nazvu
	call	mstars
	mov	si,offset namepal; Nastavenie palety 'nazov pred hviezdami'
	call	mkprzp
	mov	si,offset starpal
	call	makepal
	mov	ax,256		; a jej nabeh
	call	fade
	mov	cx,400		; Cakanie na vypnutie hviezd
	call	mstars
	call	mkf16n		; Nastavenie palety 'iba nazov'
	pop	ax		; a jej nabeh
	push	ax
	call	fade
	pop	cx		; Cakanie na zaciatok crossfadovaneho textu
	call	mstars

;±±±±±±±±±±±±±±±±±±±±±±±±±±±  CROSSFADED TEXT  ±±±±±±±±±±±±±±±±±±±±±±±±±±±±
part2:	mov	si,offset crostxt
	push	si
crsfd1:	push	0a000h
	pop	es
	xor	di,di
	mov	cx,64000
	push	cx
crsfd2:	mov	al,es:[di]	; Zmazanie stareho textu
	and	al,0f0h
	stosb
	loop	crsfd2
	push	cs		; Paleta stareho = paleta noveho
	pop	es
	mov	si,offset newpal+16*3
	mov	di,offset newpal+1*3
	mov	cx,15
crsfd3:	movsw
	movsb
	add	si,15*3
	loop	crsfd3
	call	setpal
	push	0a000h		; Novy => Stary
	pop	es
	xor	di,di
	pop	cx
crsfd4:	mov	al,es:[di]
	shr	al,4
	stosb
	loop	crsfd4
	call	copypal		; Nastavenie palety 'iba stary'
	call	sgpal
	pop	si		; Vykreslenie noveho textu
	lodsb
	and	ax,0ffh
	jz	crsfd5
	mov	di,75*320
	add	di,ax
	mov	fs,frc2seg
	call	print1
	push	si
	mov	si,offset crospal; Nastavenie palety 'iba novy'
	call	mfprzp
	mov	ax,64		; Prefadovanie na novy text
	call	fade
	mov	cx,140		; Cakanie na dalsi text
	call	waitvrc
	jmp	crsfd1
crsfd5:	call	filpalb		; Posledne odfadovanie
	mov	ax,64
	call	fdwvcc

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±  SPOT LIGHTS  ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
part3:	mov	si,offset mepal	; Poskladanie palety
	call	mkprzp
	mov	di,offset newpal
	push	di
	mov	al,7		; Hodnota bielej farby ak sa nesvieti na text
	mov	cx,16*3
	rep	stosb
	mov	bp,16
	pop	di
spot1:	mov	si,offset spotdiv; Slucka pre jednu farbu textu
	mov	bx,8
spot2:	mov	cx,3		; Slucka pre jednu z 8 moznosti tejto farby
	lodsb
	xchg	ax,dx
spot3:	mov	ah,0		; Slucka pre jednu farebnu zlozku
	mov	al,[di]
	div	dl
	stosb
	loop	spot3
	dec	bx
	jnz	spot2
	add	di,8*3
	dec	bp
	jnz	spot1
	mov	si,offset metxt	; Vypisanie textu "SEMO"
	mov	di,48+75*320
	call	prinf1
	push	cs		; Vypocitanie spot kruhu (80x80)
	pop	es
	mov	di,offset bufer
	mov	si,5858h
	mov	ds,kruhseg
	mov	dl,(128-37)*2	; Kruh ma naozaj priemer len 37
	mov	bx,80
cspot1:	mov	cx,80		; Slucka pre riadok
cspot2:	lodsb			; Slucka pre bod
	cmp	dl,al
	sbb	al,al
	stosb
	loop	cspot2
	add	si,256-80
	dec	bx
	jnz	cspot1
	mov	ax,64		; Samotne spotlights
	call	fade
	mov	cx,300
	call	mspot
	mov	si,offset mepal	; Vybeh spotov a uplny nabeh textu
	call	mfprzp
	mov	ax,128
	call	fade
	mov	cx,200
	call	mspot
	call	filpalb
	mov	ax,32
	call	fdwvcc

;±±±±±±±±±±±±±±±±±±±±  STROBO EFFECT (ROTUJUCE KRUHY)  ±±±±±±±±±±±±±±±±±±±±
part4:	call	lowres		; Rozlisenie 320x100 pre nasledujuce 3 party
	mov	si,offset strbpal; Nastavenie palety a jej vyfadovanie
	call	makepal
	mov	ax,16
	call	fade
	mov	eax,2f3f1fh
	call	fillpal		; Prichystanie palety na koniec
	mov	cx,1000		; Samotne strobo
	call	mstrobo
	mov	ax,32		; Vyfadovanie
	push	ax
	call	fade
	pop	cx
	call	mstrobo
	call	cls

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±  PLASMA 1  ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
part5:	
if start0 eq part5
	call	lowres
endif
	mov	bx,offset mplasma; Nastavenie procedury, ktorou sa bude plasmit
	call	plasma

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±  PLASMA 2  ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
part6:	
if start0 eq part6
	call	lowres
endif
	mov	bx,offset msucobr
	call	plasma

	call	cls		; Naspet do normalnych 320x200
	call	norres

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±  POINT TUNNEL  ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
part7:	mov	si,offset starpal; Nastavenie palety
	call	makepal
	inc	stunel
	call	inistar		; Inicializacia hviezd
	mov	ax,32
	call	fade
	mov	cx,900		; Samotny tunel
	call	mtunel
	mov	stunel,255	; Vyfadovanie tunela
	mov	cx,100
	call	mtunel
	call	fbsgpc

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±  COOPERBARS  ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
part8:	mov	dx,3d4h
	push	dx
	mov	ax,13h		; Genialny mod 320x1
	out	dx,ax
	mov	ax,500dh	; Zacina sa az od adresy 140h
	out	dx,ax
	mov	si,offset cooppal; Nastavenie palety
	call	mkpspt
	push	0a000h
	pop	es
	mov	dx,3dah
	mov	cx,398
coop5:	push	cx		; Nabiehajuce coopers
	mov	bp,400
	sub	bp,cx
	shr	bp,1
	call	mcooper
	pop	cx
	dec	cx
	dec	cx
	jnz	coop5
	mov	cx,350
coop6:	push	cx		; Normalne coopers
	xor	cx,cx
	mov	bp,200
	call	mcooper
	pop	cx
	loop	coop6
	mov	bp,200
coop7:	push	bp		; Odchadzajuce coopers
	xor	cx,cx
	call	mcooper
	pop	bp
	dec	bp
	jnz	coop7
	pop	dx		; Nastavi naspet VGA-cku
	mov	ax,2813h
	out	dx,ax
	mov	ax,0dh
	out	dx,ax
	call	cls

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±  FLAMES  ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
part9:	mov	si,offset flampal; Nastavenie palety
	call	makepal
	call	setpal
	mov	es,bufseg1	; Vyrobenie 'plnej textury'
	push	es		; (Aby sa mohla pouzit procedura print1)
	pop	fs
	mov	ax,0ffffh
	xor	di,di
	mov	cx,8000h
	rep	stosw
	mov	es,bufseg2	; Vykreslenie textov do volneho segmentu
	push	es
	pop	gs
	call	clseg
	mov	fontand,0ffh
	mov	si,offset flamtxt
	mov	di,40*320+16
	call	prin11		; Vypise "FIRE"
	mov	di,140*320
	call	prin11		; Vypise "RULES"
	push	cs		; Zmazanie bufra plamena
	pop	es
	mov	di,offset bufer
	mov	cx,102*82
	xor	ax,ax
	rep	stosw
	mov	cx,8000h	; Vytvorenie segmentu plneho rnd (30-3f)
	xor	bx,bx
flame1:	call	rnd
	and	ax,0f0fh
	add	ax,3030h
	mov	fs:[bx],ax
	inc	bx
	inc	bx
	loop	flame1
	mov	bx,-2		; Horiace FIRE
	mov	cx,210
	call	mflames
	mov	bx,160		; Dohorenie FIRE
	mov	cx,40
	call	mflames
	mov	bx,32000-2	; Horiace RULES
	mov	cx,350
	call	mflames
	mov	bx,160		; Dohorenie RULES
	mov	cx,60
	call	mflames
	call	fbsgpc		; Zmazanie obrazovky
	mov	fontand,0f0h

;±±±±±±±±±±±±±±±±±±±±±±±±±±  MANDELBROT ZOOMER  ±±±±±±±±±±±±±±±±±±±±±±±±±±±
mzzstep	equ	2097152
mandcol	equ	63
rozmer	equ	160
mzxstr	equ	-84999400
mzystr	equ	 -8399800
part10:	mov	ds,mandseg	; Vykreslenie prveho obrazku (predpocitaneho)
	push	0a000h
	pop	es
	mov	di,160-rozmer/2+(100-rozmer/2)*320
	xor	si,si
	mov	bx,rozmer
mz0:	mov	cx,rozmer/2	; Slucka pre riadok
	rep	movsw
	add	di,320-rozmer
	dec	bx
	jnz	mz0
	mov	si,offset mzpal	; Nabeh prveho obrazku
	call	makepal
	mov	ax,64
	call	fdwvrc
	mov	cx,rozmer/2	; Prepocitanie zaciatocnej zumovacej tabulky
	mov	di,offset bufer
	mov	eax,mzzstep*(rozmer-1)/2
mkmkro:	stosd
	sub	eax,mzzstep
	loop	mkmkro
	xor	ax,ax
	stosw
	stosw
	mov	cx,680
mz1:	mov	si,offset mzkrtab
mz2:	lodsb			; Zuumovacia slucka
	and	ax,0ffh
	jz	mz1
	push	0a000h		; Posuny na obrazovke pre vlozenie novych
	pop	es
	push	es		; riadkov a stlpcov
	pop	ds
	pusha
	push	ax		; Posun vlavo
	mov	bx,ax
	mov	dx,320
	sub	dx,ax
	mov	bp,rozmer
	push	bp
	mov	di,160-rozmer/2+(100-rozmer/2)*320
	push	di
	mov	si,di
	inc	si
	call	mpresun
	pop	di		; Posun hore
	pop	ax
	push	ax
	lea	si,[di+320]
	mov	bp,bx
	mov	dx,320-rozmer
	call	mpresun
	std			; Posun vpravo
	mov	ax,bx
	lea	dx,[bx-320]
	pop	bp
	push	bp
	mov	di,159+rozmer/2+(99+rozmer/2)*320
	push	di
	mov	si,di
	dec	si
	call	mpresun
	pop	di		; Posun dole
	pop	ax
	lea	si,[di-320]
	mov	bp,bx
	mov	dx,rozmer-320
	call	mpresun
	pop	dx		; Posun v tabulke riadkov a stlpcov
	push	cs
	pop	ds
	push	cs
	pop	es
	mov	cx,dx
	mov	si,offset bufer+4
	mov	di,offset bufer
	cld
	rep	movsd
	mov	si,di		; Vlozenie novej medzihodnoty
	lodsd
	sar	eax,1
	mov	ebx,eax
	lodsd
	sar	eax,1
	add	eax,ebx
	stosd
	push	0a000h		; Vykreslenie laveho zvisleho stlpca
	pop	es
	mov	ebx,mzxc
	sub	ebx,eax
	mov	di,dx
	push	eax
	push	dx
	call	mvtlacx
	mov	ebx,mzxc	; Vykreslenie praveho zvisleho stlpca
	pop	dx
	pop	eax
	push	eax
	push	dx
	mov	di,rozmer-1
	sub	di,dx
	add	ebx,eax
	call	mvtlacx
	mov	ebp,mzyc	; Vykreslenie horneho riadku
	pop	dx
	pop	eax
	push	eax
	push	dx
	mov	di,dx
	sub	ebp,eax
	call	mvtlacy
	mov	ebp,mzyc	; Vykreslenie dolneho riadku
	pop	dx
	pop	eax
	mov	di,rozmer-1
	sub	di,dx
	add	ebp,eax
	call	mvtlacy
	popa
	cld
	in	al,60h
	cmp	al,81h
	je	mz3
	dec	cx
	jnz	mz2
mz3:	call	filpalb		; Vyfadovanie a zmazanie obrazovky
	mov	ax,32
	call	fdwvcc

;±±±±±±±±±±±±±±±±±±±±±±  POZDRAVY - STARWARS SCROLLY  ±±±±±±±±±±±±±±±±±±±±±
part11:	mov	si,offset swspal; Nastavenie palety
	call	mkpspt
	mov	di,offset bufer	; Prepocitanie parametrov pre 128 riadkov
	mov	cx,128
cmpsws:	mov	bx,128+33	; Vypocitanie riadku textu, ktory sa bude
	sub	bx,cx		; na tento riadok vykreslovat
	mov	ax,8234
	cwd
	div	bx
	xchg	ax,bx
	mov	ax,249
	sub	ax,bx
	stosw
	shl	ax,4		; Vypocitanie tmavosti tohto riadku
	mov	bl,200
	div	bl
	shl	ax,12
	stosw
	mov	ax,cx		; Zaciatok tohto riadku od kraja
	dec	ax
	stosw
	mov	bx,160		; Vypocitanie zoom faktoru (8.8 fixpoint)
	sub	bx,ax
	mov	ax,160*256
	xor	dx,dx
	div	bx
	stosw
	loop	cmpsws
	mov	es,bufseg1	; Zmazanie bufra (textu)
	call	clseg
	mov	si,offset swstxt; Samotny StarWarsScrolly
	xor	bp,bp
	mov	fs,frc2seg
	mov	dl,13
sws1:	dec	dl		; Slucka pre posun riadku textu
	jz	sws9
	mov	dh,56
sws2:	pusha			; Slucka pre posun riadku (frejm)
	call	waitvr
	push	cs		; Vykreslenie frejmu
	pop	ds
	xor	cx,cx
swsfr1:	push	cx		; Slucka pre riadky
	push	bp
	mov	si,cx		; Zistenie adresy (SI) terajsieho riadku textu
	shl	si,3
	add	si,offset bufer
	lodsw
	add	ax,bp
	cmp	ax,200
	jb	swsfr2
	sub	ax,200
swsfr2:	imul	ax,ax,320
	push	ax
	lodsw			; Nacitanie tmavosti riadku (AH)
	push	ax
	xchg	ax,cx		; Zistenie adresy (DI) videopamete
	add	ax,72
	imul	di,ax,320
	lodsw
	add	di,ax
	mov	cx,160		; Vypocitanie sirky riadku (CX)
	sub	cx,ax
	add	cx,cx
	lodsw			; Prepocitanie zoom faktoru (BX.BP)
	xchg	ax,bp
	mov	bx,bp
	shr	bx,8
	shl	bp,8
	pop	ax
	pop	si
	push	ds
	push	es
	push	es
	pop	ds
	push	0a000h		; Vykreslovanie riadku
	pop	es
	mov	dx,8000h
swsfr3:	mov	al,[si]		; Slucka pre bod
	or	al,ah
	mov	es:[di],al
	inc	di
	add	dx,bp
	adc	si,bx
	loop	swsfr3
	pop	es
	pop	ds
	pop	bp
	pop	cx
	inc	cx
	cmp	cl,128
	jb	swsfr1
	popa
	imul	di,bp,320
	mov	cx,10
sws6:	push	cs		; Vlozenie noveho riadku (10 pismen) do bufra
	pop	ds
	push	cx
	lodsb
	push	si
	call	dajznak
	mov	ax,56*256
	sub	ah,dh
	add	si,ax
	mov	cx,30
sws7:	mov	ah,fs:[si]	; Slucka pre bod
	shr	ah,4
	lodsb
	and	al,ah
	stosb
	loop	sws7
	pop	si
	inc	di
	inc	di
	pop	cx
	loop	sws6
	inc	bp
	cmp	bp,200
	jb	sws8
	xor	bp,bp
sws8:	dec	dh
	jz	sws1
	sub	si,10
	jmp	sws2
sws9:	call	fbsgpc
;±±±±±±±±±±±±±±±±±±±±±±  END TEXT (ZOOMING+ROTATING)  ±±±±±±±±±±±±±±±±±±±±±
part12:	call	lowres		; Modo 320x100
	mov	si,offset endpal; Nastavenie palety
	call	mkprzp
	call	sgpal
	call	filpalb
	mov	word ptr [offset printa+2],256-30; Upravenie proc. print1
	mov	es,bufseg1	; Vytvorenie textu v bufseg1
	call	clseg
	mov	fs,frc1seg
	mov	si,offset endtxt; 'T H E'
	mov	di,48+78*256
	call	prin11
	mov	di,48+128*256	; 'E N D'
	call	prin11
	push	es
	pop	fs
	mov	rotacia,0
	mov	ax,20
endt1:	push	ax		; Nabeh obrazku (zo zadu)
	mov	rvzdial,ax
	call	rotobr
	pop	ax
	add	ax,14
	cmp	ax,400
	jb	endt1
	mov	cx,300		; Zumovanie a rotovanie textu
	call	mendtxt
	mov	ax,64		; Vybeh textu
	push	ax
	call	fade
	pop	cx
	call	mendtxt

koniec:	mov	ax,3		; TXT mod
	int	10h
	xor	ax,ax		; Flush keys
	mov	ds,ax
	mov	ax,word ptr ds:[41ah]
	mov	word ptr ds:[41ch],ax
	mov	ax,4c00h	; KONIEC
	int	21h

;±±±±±±±±±±±±±±±±±±±±±±±  VRATI NAHODNE CISLO V AX  ±±±±±±±±±±±±±±±±±±±±±±±
rnd	proc
	mov	ax,cs:rndseed
	inc	ax
	imul	ax,9871
	xchg	al,ah
	mov	cs:rndseed,ax
	ret
rndseed	dw	12345
rnd	endp

;±±±±±±±±±±±±±±±±±±±±±±  VYPISANIE STRINGU NA DS:DX  ±±±±±±±±±±±±±±±±±±±±±±
puts	proc
	mov	ah,9
	int	21h
	ret
puts	endp

;±±±±±±±±±±±±±±±±±±±±±±±±±±±  VYPISANIE BODKY  ±±±±±±±±±±±±±±±±±±±±±±±±±±±±
putbod	proc
	call	esctst
	mov	ah,2
	mov	dl,'.'
	int	21h
	ret
putbod	endp

;±±±±±±±±±±±±±±±±±±±±±±  FADE; WAIT; ALLBLACK; CLS  ±±±±±±±±±±±±±±±±±±±±±±±
fdwvcc:	call	fdwvrc
	jmp	cls
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±  ALLBLACK; CLS  ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
fbsgpc:	call	fbsgpal
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±  CLEAR  SCREEN  ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
cls	proc
	push	0a000h
	pop	es
clseg:	mov	cx,4000h	; Clear full segment
clsbb:	xor	di,di		; Clear CX dwords segmentu
clsb:	xor	eax,eax		; Clear CX dwords od DI
	rep	stosd
	ret
cls	endp

;±±±±±±±±±±±±±±±±±±±±±±±±  ZMENA MODU NA 320x100  ±±±±±±±±±±±±±±±±±±±±±±±±±
lowres	proc
	mov	ax,4309h
	jmp	newres
norres:	mov	ax,4109h	; Zmena na normalnych 320x200
newres:	mov	dx,3d4h
	out	dx,ax
	ret
lowres	endp

;±±±±±±±±±±±±±±±±±  MAKEPAL; ROZPAL; BLACKS 1. 16 COLORS  ±±±±±±±±±±±±±±±±±
mfprzp:	call	mkprzp
;±±±±±±±±±±±±±±±±±±±±±±±  BLACKS PRVYCH 16 COLORS  ±±±±±±±±±±±±±±±±±±±±±±±±
mkf16n:	mov	si,offset f16npal
;±±±±±±±±±±±±±±±  PREPOCITANIE PALETY PODLA TABULKY NA SI  ±±±±±±±±±±±±±±±±
makepal	proc
	push	cs
	pop	ds
	push	cs
	pop	es
	mov	bp,offset newpal
	xor	ax,ax		; Zacina sa vzdy od ciernej
	mov	di,offset palent
	stosw
	stosw
	stosw
makep1:	lodsb			; Prva polozka v tabulke - pocet farieb
	xchg	ax,dx
	or	dl,dl		; Tabulka je ukoncena 0
	jnz	makep2
	ret
makep2:	mov	cx,3
	mov	di,offset palent
	cmp	dl,-3
	jne	makep5
makep3:	lodsb			; Nastavenie farby
	shl	ax,8
	stosw
	loop	makep3
	jmp	makep1
makep4:	pop	bp
	inc	bp
makep5:	lodsb			; Urobi farebny prechod
	cbw
	shl	ax,4
	mov	bx,[di]
	push	bp
	mov	dh,dl
makep6:	add	bx,ax		; Zmena zlozky o zadanu hodnotu
	mov	[bp],bh
	add	bp,3
	dec	dh
	jnz	makep6
	xchg	ax,bx
	stosw
	loop	makep4
	pop	ax
	dec	bp
	dec	bp
	jmp	makep1
makepal	endp

;±±±±±±±±±±±±±±±±±±±±±  VYNULOVANIE PALETY (CIERNOU)  ±±±±±±±±±±±±±±±±±±±±±
filpalb:xor	eax,eax
;±±±±±±±±±±±±±±±±±±±±  NASTAVENIE PALETY FARBOU V EAX  ±±±±±±±±±±±±±±±±±±±±
fillpal	proc
	push	cs
	pop	ds
	push	cs
	pop	es
	mov	di,offset newpal
	mov	cx,256
fillp1:	stosd
	dec	di
	loop	fillp1
	ret
fillpal	endp

;±±±±±  PREPOCITA PALETU A ROZLOZI PRVYCH 16 FARIEB DO CELEJ PALETY  ±±±±±±
mkprzp	proc
	call	makepal
	mov	di,offset newpal+3*240
	mov	si,offset newpal+3*15
	mov	bx,15
rozpa1:	push	di		; Slucka pre 16 farieb
	mov	cx,16
rozpa2:	push	si		; Slucka  pre jednu farbu
	movsw
	movsb
	pop	si
	loop	rozpa2
	sub	si,3
	pop	di
	sub	di,3*16
	dec	bx
	jnz	rozpa1
	ret
mkprzp	endp

;±±±±  NASTAVI PALETU A PREKOPIRUJE PRVYCH 16 FARIEB DO CELEJ PALETY  ±±±±±
mkpcpp:	call	makepal
;±±±±±±±±  OPAKOVANE PREKOPIRUJE PRVYCH 16 FARIEB DO CELEJ PALETY  ±±±±±±±±
copypal	proc
	push	cs
	pop	ds
	push	cs
	pop	es
	mov	di,offset newpal+3*16
	mov	si,offset newpal
	mov	cx,(768-3*16)/2
	rep	movsw
	ret
copypal	endp

;±±  VYTVORI A VYTIENUJE PRVYCH 16 FARIEB DO CELEJ PALETY A NASTAVI JU  ±±±
mkpspt:	call	mkpcpp
	mov	di,offset newpal+240*3-1
	mov	bl,15*16	; Svetlost farby
mtien1:	mov	cx,3*16		; Slucka pre 16 farieb
mtien2:	mov	al,[di]		; Slucka pre jednu zlozku
	mul	bl
	mov	[di],ah
	dec	di
	loop	mtien2
	sub	bl,16
	jnz	mtien1
;±±±±±±±±±±±±±±±±±±±±±  NASTAVI PREPOCITANU PALETU  ±±±±±±±±±±±±±±±±±±±±±±±
setpal	proc
	mov	si,offset newpal
setpsi:	mov	dx,3c8h		; Nastavi paletu na SI
	mov	al,0
	out	dx,al
	inc	dx
	mov	cx,300h
	rep	outsb
	ret
setpal	endp

;±±±±±±±±±±±±±±±±  NASTAVI PALETU NA CIERNO A NACITA JU  ±±±±±±±±±±±±±±±±±±
fbsgpal:call	filpalb
;±±±±±±±±±±±±±±±±±±±±±  NASTAVI PALETU A NACITA JU  ±±±±±±±±±±±±±±±±±±±±±±±
sgpal:	call	setpal
;±±±±±±±±±±±±±±±±±±±±±±±  NACITA TERAJSIU PALETU  ±±±±±±±±±±±±±±±±±±±±±±±±±
getpal	proc
	push	cs
	pop	es
	mov	di,offset curpal
	mov	dx,3c7h
	mov	al,0
	out	dx,al
	inc	dx
	inc	dx
	mov	cx,768
getpa1:	in	al,dx
	shl	ax,8		; CurentPal je 8.8 fixpoint
	stosw
	loop	getpa1
	ret
getpal	endp

;±±±±±±±±±±±±±±±±±±±±±  VYFADUJE A POCKA AX FREJMOV  ±±±±±±±±±±±±±±±±±±±±±±
fdwvrc:	push	ax
	call	fade
	pop	cx
;±±±±±±±±±±±±±±±±±±±±±±±±±±  POCKA CX FREJMOV  ±±±±±±±±±±±±±±±±±±±±±±±±±±±±
waitvrc	proc
waitc1:	call	waitvr
	loop	waitc1
	ret
waitvrc	endp

;±±±±±±±±±±±±±±±±±±±±±±±±  POCKA 1 FREJM (+FADE)  ±±±±±±±±±±±±±±±±±±±±±±±±±
border	macro	farba
if stiming
	mov	dx,3dah
	in	al,dx
	mov	dx,3c0h
	mov	al,31h
	out	dx,al
	mov	al,farba
	out	dx,al
endif
	endm

waitvr	proc
	cmp	cs:fadecnt,0
	jz	waitv4
	pusha			; Pripravenie novej palety (ak sa faduje)
	push	ds
	push	es
	push	cs
	pop	ds
	push	cs
	pop	es
	mov	di,offset curpal	; Terajsia paleta
	mov	si,offset incpal	; Pripocitavanie k terajsim farbam
	mov	bx,offset tmppal
	mov	cx,768
waitv3:	lodsw
	add	ax,[di]
	stosw
	mov	[bx],ah
	inc	bx
	loop	waitv3
	pop	es
	pop	ds
	popa
waitv4:	border	0
	mov	dx,3dah
waitv1:	in	al,dx		; Caka na koniec Vertical Retrace
	and	al,8
	jnz	waitv1
waitv2:	in	al,dx		; Caka na VR
	and	al,8
	jz	waitv2
	border	191
	cmp	cs:fadecnt,0
	je	esctst
	push	ds		; Nastavenie novej palety
	push	si
	push	cx
	push	cs
	pop	ds
	mov	si,offset tmppal
	call	setpsi
	dec	fadecnt
	pop	cx
	pop	si
	pop	ds
esctst:	in	al,60h		; Test na stlacenie ESC
	dec	al
	jz	koniec
	ret
waitvr	endp

;±±±±±±±±±  NASTAVI FADING NA PREPOCITANU PALETU ZA AX FREJMOV  ±±±±±±±±±±±
fade	proc
	push	cs
	pop	ds
	push	cs
	pop	es
	mov	fadecnt,ax
	mov	si,offset curpal
	mov	bx,offset newpal
	mov	di,offset incpal
	mov	cx,768
fade1:	mov	ah,[bx]
	inc	bx
	mov	al,0
	sub	ax,[si]
	inc	si
	inc	si
	cwd
	idiv	fadecnt
	stosw
	loop	fade1
	ret
fade	endp

;±±±±±±±  VYPISE BODKU A UROBI SOFTEN EFEKT (Ako v AA) PRE CELY DS  ±±±±±±±
pbsoft:	call	putbod
;±±±±±±±±±±±±±±±±±  SOFTEN EFEKT (Ako v AA) PRE CELY DS  ±±±±±±±±±±±±±±±±±±
soften	proc
	push	ds
	mov	es,cs:bufseg1	; Docasny
	xor	si,si
	xor	di,di
	mov	bh,0
softe1:	mov	bl,[si]
	mov	ax,bx
	shl	ax,2		; 4*stary bod +
	mov	bl,[si-256]
	add	ax,bx		; + stary bod hore +
	mov	bl,[si-1]
	add	ax,bx		; + stary bod vlavo +
	mov	bl,[si+1]
	add	ax,bx		; + stary bod vpravo +
	mov	bl,[si+256]
	add	ax,bx		; + stary bod dole
	shr	ax,3		; cele / 8
	stosb			; = novy bod
	inc	si
	jnz	softe1
	mov	cx,4000h
	push	es
	push	ds
	pop	es
	pop	ds
	rep	movsd		; Novy -> stary
	pop	ds
	ret
soften	endp

;±±±±±±±±±±±±  VRATI ADRESU ZNAKU AL PRE VELKY FONT V DS:SI  ±±±±±±±±±±±±±±
dajznak	proc
	sub	al,59		; Znaky zacinaju od '<'
	ja	dajzn1
	xor	al,al
dajzn1:	xchg	ax,bx
	mov	bh,bl
	and	bh,18h
	shl	bh,3
	shl	bl,5
	lea	si,[bx+0ffh]
	mov	ds,cs:fontseg
	ret
dajznak	endp

;±±±±±±±±±±±±±±±±  VYPISANIE TEXTU Z SI NA DI TEXTUROU 1  ±±±±±±±±±±±±±±±±±
prinf1:	mov	fs,frc1seg
;±±±±±±±±±±±±±±±±  VYPISANIE TEXTU Z SI NA DI TEXTUROU FS  ±±±±±±±±±±±±±±±±
print1	proc
	push	0a000h
	pop	es
prin11:	push	cs
	pop	ds
	lodsb			; Nacitanie pismena
	or	al,al
	jz	prin16
	push	si
	call	dajznak		; DS:SI - zaciatok pismena
	call	rnd
	and	ax,1ffh
	dec	ah
	xchg	ax,bp		; BP - nahodny posun textury
	mov	bx,62
	push	di
	mov	ah,cs:fontand
prin12:	mov	cx,30		; Slucka pre riadok
prin13:	lodsb			; Slucka pre bod
	and	al,ah
	jz	prin15
	and	al,fs:[si+bp]	; Ztexturovanie bodu
	jnz	prin14
	mov	al,10h		; Textura nesmie byt nikdy nulova
prin14:	or	es:[di],al
prin15:	inc	di
	loop	prin13
printa:	add	di,320-30
	add	si,256-30
	dec	bx
	jnz	prin12
	pop	di		; Dalsi znak
	add	di,32
	pop	si
	jmp	prin11
prin16:	ret
print1	endp

;±±±±±±±±±±±  PREPOCITA NOVU POZICIU PODLA KOEFICIENTOV Z SI  ±±±±±±±±±±±±±
newpos	proc
	mov	bx,[si+2]
	add	bx,[si+6]
	mov	[si+2],bx
	call	getco0
	xchg	ax,dx		; AX=Y (-32000,32000)
newpo1:	mov	bx,[si]
	add	bx,[si+4]
	mov	[si],bx
	add	si,8
getco0:	shr	bx,5
getcos:	and	bx,7feh
	mov	ax,costab[bx]	; DX=X (-32000,32000)
	ret
newpos	endp

;±±±±±±±±±±±±±±±±±±±±±±±±±  INICIALIZACIA HVIEZD  ±±±±±±±±±±±±±±±±±±±±±±±±±
hviezd	equ	2500
starsp	equ	2
inistar	proc
	mov	si,offset bufer
	mov	cx,hviezd
inist1:	call	newstar		; Ako kazda ina nova hviezda
	call	rnd		; akurat ze vzdialenost je nahodna (58-240)
	and	ax,255
	add	ax,58
	cmp	ax,240
	ja	inist1
	mov	[si+4],ax
	add	si,8
	loop	inist1
	ret
inistar	endp

;±±±±±±±±±±±±±±±±±±±±±±±  HVIEZDY POCAS CX FREJMOV  ±±±±±±±±±±±±±±±±±±±±±±±
mstars	proc
	push	0a000h
	pop	es
mstar0:	push	cx
	call	waitvr
	mov	si,offset bufer
	mov	cx,hviezd
mstar1:	mov	di,[si+6]	; Adresa minulej pozicie
	and	byte ptr es:[di],0f0h
	mov	bx,[si+4]	; Vzdialenost (od obrazovky)
	sub	bx,starsp
	jbe	mstar3		; Hviezda je uz za pozorovatelom
	mov	[si+4],bx
	mov	ax,[si+0]	; X pozicia (pri vzdialenosti 1)
	cwd
	idiv	bx
	add	ax,160		; Terajsia X pozicia
	cmp	ax,319
	ja	mstar3		; Hviezda je uz mimo obrazovky
	xchg	ax,di
	mov	ax,[si+2]	; Y pozicia (vzd. 1)
	cwd
	idiv	bx
	add	ax,100		; Terajsie Y
	cmp	ax,199
	ja	mstar3		; Hviezda je uz mimo obrazovky
	imul	ax,ax,320
	add	di,ax		; Adresa terajsieho bodu
	mov	[si+6],di
	shr	bl,4
	xor	bl,15		; Vzdialenost -> farba
	or	es:[di],bl
mstar2:	add	si,8
	loop	mstar1
	pop	cx
	loop	mstar0
	ret
mstar3:	call	newstar
	jmp	mstar2
mstars	endp

;±±±±±±±±±±±±±±±±±±±±±±  NAPLNI DATA NOVEJ HVIEZDY  ±±±±±±±±±±±±±±±±±±±±±±±
newstar	proc
	mov	al,stunel
	inc	al
	jz	newstk		; stunel=255 => Nove hviezdy nebudu
	mov	word ptr [si+4],240	; Vzialenost
	mov	word ptr [si+6],-1	; Minuly bod (mimo obrazovky)
	dec	al
	jnz	newtun		; stunel<>0 => Robi sa tunel
	call	rnd		; X
	mov	[si+0],ax
	call	rnd		; Y
	mov	[si+2],ax
newstk:	ret
				; Naplni data novej hviezdy pri tuneli
newtun:	call	rnd		; Uhol
	xchg	ax,bx
	call	getcos
	sar	ax,2		; X
	add	ax,tunelx
	mov	[si+0],ax
	sub	bh,2
	call	getcos
	sar	ax,2		; Y
	add	ax,tunely
	mov	[si+2],ax
	ret
newstar	endp

;±±±±±±±±±±±±±±±±±±  VYKRESLUJE TUNEL POCAS CX FREJMOV  ±±±±±±±±±±±±±±±±±±±
mtunel	proc
	push	cx
	mov	si,offset tundat
	call	newpos		; Nova pozicia stredu
	mov	bx,tunelr	; Velkost kmitania
	push	dx
	imul	bx
	mov	tunelx,dx	; X stredu tunela
	pop	ax
	imul	bx
	mov	tunely,dx	; Y stredu tunela
	add	bx,20
	mov	tunelr,bx	; Zvecsenie kmitania
	mov	cx,1
	call	mstars
	pop	cx
	loop	mtunel
	ret
mtunel	endp

;±±±±±±±±±±±±±±±±±±±±±±±  SPOTLIGHTS NA CX FREJMOV  ±±±±±±±±±±±±±±±±±±±±±±±
mspot	proc
	push	cx
	call	waitvr
	mov	si,offset spotdat
	mov	cx,4
mspot1:	push	cx		; Slucka pre jeden kruh
	call	newpos		; Prepocitanie pozicie
	push	si
	sar	ax,8
	add	ax,120
	xchg	ax,di
	sar	dx,11
	add	dx,60
	imul	ax,dx,320
	add	di,ax
	mov	ch,cl		; Prepocitanie masky
	mov	dx,cx
	shl	edx,16
	mov	dx,cx		; EDX - maska pre kruh
	mov	ebp,edx
	not	ebp		; EBP - maska pre obrazovku
	push	0a000h		; Vykreslenie kruhu
	pop	es
	mov	si,offset bufer
	mov	cx,80
mspot2:	push	cx		; Slucka pre riadok
	mov	cx,20
mspot3:	mov	ebx,es:[di]	; Slucka pre 4 body
	and	ebx,ebp
	lodsd
	and	eax,edx		; Zmazanie takehoto predchadzajuceho kruhu
	or	eax,ebx		; Nastavenie noveho
	stosd
	loop	mspot3
	add	di,320-80
	pop	cx
	loop	mspot2
	pop	si
	pop	cx
	shr	cx,1
	jnc	mspot1
	pop	cx
	loop	mspot
	ret
mspot	endp

;±±±±±±±±±±±±±±  VYKRESLUJE STROBO EFFECT POCAS CX FREJMOV  ±±±±±±±±±±±±±±±
mstrobo	proc
	push	cx
	add	rvzdial,5	; Vzdialovanie kruhov
	mov	ax,rotinc
	add	rotacia,ax	; Uhol natocenia sa zvecsuje nelinearne
	add	ax,9
	mov	rotinc,ax
	mov	fs,kruhseg
	call	rotobr
	pop	cx
	loop	mstrobo
	ret
mstrobo	endp

;±±±±±±±±±±±±  VYKRESLUJE KMITAJUCI END TEXT POCAS CX FREJMOV  ±±±±±±±±±±±±
mendtxt	proc
	push	cx
	mov	si,offset enddat
	call	newpos		; Nove natocenie a vzdialenost
	sar	dx,8
	add	dx,400
	mov	rvzdial,dx
	imul	endrotm
	mov	rotacia,dx
	add	endrotm,20
	call	rotobr
	pop	cx
	loop	mendtxt
	ret
mendtxt	endp

;±±±±±±±±±±±±±±  PODPROGRAM PRE SKRATENIE PROCEDURY ROTOBR  ±±±±±±±±±±±±±±±
rotop1	proc
	sub	bh,4
rotop2:	add	bh,2
rotop3:	call	getcos
	sar	ax,7
	imul	rvzdial
	mov	al,ah
	mov	ah,dl
	ret
rotop1	endp

;±±±±±±±±±±  VYKRESLI ZROTOVANY OBRAZOK Z FS POCAS CX FREJMOV  ±±±±±±±±±±±±
rotobr	proc
	call	waitvr
	mov	bx,rotacia	; Prepocitanie konstant
	sar	bx,5
	call	rotop1
	xchg	ax,bp		; Posun Y v obrazku pre posun X na obrazovke
	call	rotop2
	xchg	ax,si		; Posun X v obrazku pre posun X na obrazovke
	call	rotop2
	imul	asprat
	mov	al,ah
	mov	ah,dl
	mov	yposx,ax	; Posun X v obrazku pre posun Y na obrazovke
	push	ax
	call	rotop1
	imul	asprat
	mov	al,ah
	mov	ah,dl
	mov	yposy,ax	; Posun Y v obrazku pre posun Y na obrazovke
	imul	ax,ax,50	; Vypocitanie zaciatku v obrazku
	xchg	ax,bx
	imul	ax,bp,80
	add	ax,bx
	neg	ax
	add	ax,8000h
	xchg	ax,dx
	imul	ax,si,80
	xchg	ax,bx
	pop	ax
	imul	ax,ax,50
	add	ax,bx
	neg	ax
	add	ax,8000h
	push	ds		; Zobrazenie obrazku (160x100)
	push	fs
	pop	ds
	push	0a000h
	pop	es
	xor	di,di
	mov	cx,100
rotob4:	push	cx		; Slucka pre riadok
	mov	cx,80
	push	ax
	push	dx
rotob5:	add	ax,si		; Slucka pre dva body
	add	dx,bp
	mov	bl,ah
	mov	bh,dh
	mov	bl,ds:[bx]
	mov	bh,bl
	mov	es:[di],bx
	add	ax,si
	add	dx,bp
	mov	bl,ah
	mov	bh,dh
	mov	bl,ds:[bx]
	mov	bh,bl
	mov	es:[di+2],bx
	add	di,4
	loop	rotob5
	pop	dx
	pop	ax
	add	ax,cs:yposx
	add	dx,cs:yposy
	pop	cx
	loop	rotob4
	pop	ds
	ret
rotobr	endp

;±±±±±±±±±±±±±±±±±±  VYKRESLUJE PLASMU PROCEDUROU V BX  ±±±±±±±±±±±±±±±±±±±
plasma	proc
	push	bx
	mov	si,offset plaspal	; Nastavenie palety
	call	makepal
	mov	ax,16
	call	fade		; Nafadovanie
	mov	cx,600		; Vykreslovanie plasmy
	pop	bx
	push	bx
	call	bx
	mov	eax,08383ch	; Vyfadovanie plasmy
	call	fillpal
	mov	ax,16
	push	ax
	call	fade
	pop	cx
	pop	bx
	call	bx
	ret
plasma	endp

;±±±±±±±±±±±±±  UROBI CX FREJMOV KLASICKEJ SINUSOVEJ PLASMY  ±±±±±±±±±±±±±±
mplasma	proc
	push	cx
	call	waitvr
	mov	cx,2		; Prepocitanie novych pozicii X a Y sinusov
	mov	si,offset plasdat
mplas2:	call	newpos
	sar	ax,6
	and	ax,03ffh
	push	ax
	sar	dx,6
	and	dx,03ffh
	push	dx
	loop	mplas2
	pop	dx		; Vykreslovanie
	pop	bx
	pop	bp
	pop	si
	push	0a000h
	pop	es
	xor	di,di
	mov	ch,100
mplas5:	mov	al,costab2[bp]	; Slucka pre riadok
	xchg	bp,dx
	add	al,costab2[bp]	; AL=Hodnota Y sinusov pre riadok
	xchg	bp,dx
	push	bp
	push	dx
	push	si
	push	bx
	xchg	ax,dx
	mov	bp,3ffh
	mov	cl,160
mplas6:	mov	ax,dx		; Slucka pre bod
	add	al,costab2[si]
	add	al,costab2[bx]
	mov	ah,al
	mov	es:[di],ax
	inc	di
	inc	di
	add	si,8
	and	si,bp
	add	bx,5
	and	bx,bp
	dec	cl
	jnz	mplas6
	pop	bx
	pop	si
	pop	dx
	add	dx,4
	and	dx,bp
	pop	bp
	add	bp,10
	and	bp,3ffh
	dec	ch
	jnz	mplas5
	pop	cx
	loop	mplasma
	ret
mplasma	endp

;±±±±±±±±±  UROBI CX FREJMOV TROCH SCITANYCH SINUSOVYCH OBRAZKOV  ±±±±±±±±±
msucobr	proc
	push	cx
	call	waitvr
	push	cs
	pop	ds
	mov	cx,3
	mov	si,offset plasdat
msuob1:	call	newpos		; Pocitanie pozicii
	sar	ax,9
	add	ax,80
	xchg	ax,bx
	sar	dx,10
	add	dx,50
	imul	ax,dx,320
	add	ax,bx
	push	ax		; Zaciatocna adresa jedneho obrazku
	loop	msuob1
	pop	bx
	pop	bp
	pop	si
	push	0a000h
	pop	es
	xor	di,di
	mov	ds,sinoseg
	mov	ch,100
msuob2:	mov	cl,160		; Slucka pre riadok
msuob3:	lodsb			; Slucka pre bod
	add	al,[bx]
	inc	bx
	add	al,ds:[bp]
	inc	bp
	mov	ah,al
	mov	es:[di],ax
	add	di,2
	dec	cl
	jnz	msuob3
	mov	ax,160
	add	si,ax
	add	bx,ax
	add	bp,ax
	dec	ch
	jnz	msuob2
	pop	cx
	loop	msucobr
	ret
msucobr	endp

;±±±±±±±±±±±±±±±±±±±±±±±  CAKANIE NA DALSI RIADOK  ±±±±±±±±±±±±±±±±±±±±±±±±
waitln	proc
waitl1:	in	al,dx		; Cakanie na skoncenie HR
	and	al,1
	jnz	waitl1
waitl2:	in	al,dx		; Cakanie na zaciatok HR
	and	al,1
	jz	waitl2
	ret
waitln	endp

;±±±±±±±±±±±±±±±±  VYKRESLENIE JEDNEHO RIADKU COOPERBARS  ±±±±±±±±±±±±±±±±±
copdraw	proc
	call	newpo1
	sar	ax,8
	push	ax		; 1. zlozka pozicie
	call	newpo1
	sar	ax,9		; 2. zlozka pozicie
	pop	bx
	add	bx,ax
	add	bx,320+160-8	; Posun do stredu obrazovky
	call	waitln
	mov	ch,cl
	mov	ax,cx
	shl	eax,16
	mov	ax,cx
	add	eax,0a0603010h	; 1. 4 body
	mov	es:[bx],eax
	add	eax,04090c0c0h	; 2. 4 body
	mov	es:[bx+4],eax
	sub	eax,050504000h	; 3. 4 body
	mov	es:[bx+8],eax
	sub	eax,080706060h	; 4. 4 body
	mov	es:[bx+12],eax
	ret
copdraw	endp

;±±±±±±±±±±±±±±±±±±±±  SPRAVI JEDEN FREJM COOPERBARS  ±±±±±±±±±±±±±±±±±±±±±
; CX - zaciatok, BP - pocet riadkov
mcooper	proc
	mov	si,offset coopdat
	push	cx
	mov	cx,4
mcoop2:	mov	ax,[si+2]	; Posunutie zaciatocnych pozicii
	add	ax,[si+6]
	mov	[si+2],ax
	mov	[si],ax
	add	si,8
	loop	mcoop2
mcoop3:	in	al,dx		; Cakanie na prvy riadok
	and	al,8
	jz	mcoop3
	cli
	mov	cx,640/4	; Zmazanie 'obrazovky'
	call	clsbb
mcoop4:	in	al,dx		; Cakanie na ukoncenie VR
	and	al,8
	jnz	mcoop4
	pop	cx
	jcxz	mcoop6
mcoop5:	call	waitln		; Cakanie na zaciatok vykreslovania
	loop	mcoop5
mcoop6:	mov	cx,1ffh		; CL=farba, CH=pridavok farby
mcoop7:	add	cl,ch
	js	mcoop6
	cmp	cl,8
	jb	mcoop8
	mov	cx,0ff07h
mcoop8:	push	cx
	mov	si,offset coopdat
	call	copdraw		; Vykreslenie prvej palicky
	add	cl,8
	call	copdraw		; Vykreslenie druhej palicy
	dec	bp
	pop	cx
	jnz	mcoop7
	sti
	call	esctst
	ret
mcooper	endp

;±±±±±±±±±±±±±±±±±±  VYKRESLUJE PLAMEN POCAS CX FREJMOV  ±±±±±±±±±±±±±±±±±±
mflames	proc
	push	cx
	push	bx
	call	waitvr
	push	0a000h
	pop	es
	mov	si,offset bufer
	mov	di,78+56*320
	call	rnd		; Nahodny posun sumu
	and	ax,3ffch
	xchg	ax,bp
	mov	cx,88
mflam0:	push	cx		; Slucka pre riadky
	mov	cx,5202h
mflam1:	mov	ax,[si+164]	; Slucka pre dva body
	add	al,ah
	mov	ah,al
	add	ax,[si]
	add	al,[si+164-1]
	shr	al,cl		; Novy=(Minuly+Vlavodole+Dole+Vpravodole)/4
	xor	al,cl		; Este vecsie znahodnenie plamena
	jz	mflam2
	dec	al
mflam2:	add	ah,[si+164+2]
	shr	ah,cl
	xor	ah,cl
	jz	mflam3
	dec	ah
mflam3:	xchg	ax,dx
	mov	ax,fs:[bp]	; Nacitanie bodov textu
	inc	bp
	inc	bp
	and	ax,gs:[bx]	; ich znahodnenie
	inc	bx
	inc	bx
	or	ax,dx		; a vlozenie do plamena
	mov	[si],ax		; Zapis do bufra
	inc	si
	inc	si
	stosw			; Zapis do videopamete
	dec	ch
	jnz	mflam1
	pop	cx
	add	di,156
	add	bx,156
	loop	mflam0
	pop	bx
	pop	cx
	loop	mflames
	ret
mflames	endp

;±±±±±±±±±±±  VYKRESLENIE NOVEHO STLPCA (EBX) PRE MANDELZOOMER  ±±±±±±±±±±±
mvtlacx	proc
	add	di,160-rozmer/2+(100-rozmer/2)*320
	mov	si,offset bufer
	mov	cx,rozmer/2
	cld
mvtlx1:	lodsd			; Slucka pre bod (horna polovica)
	mov	ebp,mzyc
	sub	ebp,eax
	call	mandel
	stosb
	add	di,319
	loop	mvtlx1
	mov	si,offset bufer +rozmer*2 -4
	mov	cx,rozmer/2
	std
mvtlx2:	lodsd			; Slucka pre bod (dolna polovica)
	mov	ebp,mzyc
	add	ebp,eax
	call	mandel
	stosb
	add	di,321
	loop	mvtlx2
	ret
mvtlacx	endp

;±±±±±±±±±±±  VYKRESLENIE NOVEHO RIADKU (EBP) PRE MANDELZOOMER  ±±±±±±±±±±±
mvtlacy	proc
	imul	di,di,320
	add	di,160-rozmer/2+(100-rozmer/2)*320
	mov	si,offset bufer
	mov	cx,rozmer/2
	cld
mvtly1:	lodsd			; Slucka pre bod (lava strana)
	mov	ebx,mzxc
	sub	ebx,eax
	call	mandel
	stosb
	loop	mvtly1
	mov	si,offset bufer +rozmer*2 -4
	mov	cx,rozmer/2
	std
mvtly2:	lodsd			; Slucka pre bod (prava strana)
	mov	ebx,mzxc
	add	ebx,eax
	call	mandel
	stosb
	inc	di
	inc	di
	loop	mvtly2
	ret
mvtlacy	endp

;±±±±±±±±±±±±±±  PRESUNUTIE OBDLZNIKA PRE MANDELZOOMOVANIE  ±±±±±±±±±±±±±±±
mpresun	proc
mpres1:	mov	cx,ax
	rep	movsb
	add	si,dx
	add	di,dx
	dec	bp
	jnz	mpres1
	ret
mpresun	endp

;±±±±±±±±±±  MANDELBROT(EBX,EBP)=AL  (VSTUPY SU 6.26 FIXPOINT)  ±±±±±±±±±±±
mandel	proc
	push	cx
	push	si
	push	di
	xor	esi,esi		; x1=0
	xor	edi,edi		; y1=0
	mov	ax,mandcol
	push	ax
mande1:	mov	eax,esi
	imul	esi
	shld	edx,eax,6	; EDX=x1ý
	mov	ecx,edx
	mov	eax,edi
	imul	edi
	shld	edx,eax,6	; EDX=y1ý
	mov	eax,ecx
	add	eax,edx
	cmp	eax,10000000h	; ak je û(x1ý+y1ý)>=2 tak sa ukonci iteracia
	jae	mande2
	mov	eax,esi
	mov	esi,ebx
	add	esi,ecx	
	sub	esi,edx		; x1=x+x1ý-y1ý
	shl	eax,1
	imul	edi
	shld	edx,eax,6
	add	edx,ebp		; EDX=2.x1.y1+y=y1
	mov	edi,edx
	pop	ax
	dec	ax
	push	ax
	jnz	mande1		; obmedzenie iteracii
mande2:	pop	ax
	pop	di
	pop	si
	pop	cx
	ret
mandel	endp

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±  TEXTY  ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
beg1txt	db	13,10,'UNPACKING ANIMATED 4K INTRO',13,10
	db	13,10
	db	'LHA',39,'ME SFX 6.66 S (c) Jozhi, 1995',13,10
	db	13,10
	db	'AAPLAY.EXE $'
beg2txt	db	13,10,'INTRO.FLI $'
logotxt	db	'ANIMATED',0
crostxt	db	16,'A MINITRO',0
	db	16,'PRESENTED',0
	db	1,'AT DEMOBIT',0
	db	32,'CODED BY',0
	db	0
metxt	db	'S E M O',0
flamtxt	db	'FIRE',0
	db	'RULES',0
swstxt	db	'GREETS  GO'
	db	'  OUT TO  '
	db	' EVERYONE '
	db	'   HERE   '
	db	'AT DEMOBIT'
	db	'  AND TO  '
	db	' ALL COOL '
	db	'DEMO DUDES'
	db	'EVERYWHERE'
	db	'          '
	db	'          '
	db	'          '
endtxt	db	'T H E',0
	db	'E N D',0

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±  PALETY  ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
f16npal	db	16,0,0,0
	db	0
starpal	db	1,0,0,0
	db	15,64,64,64
	db	0
namepal	db	16,63,40,20
	db	0
crospal	db	16,37,48,63
	db	0
mepal	db	16,40,63,30
	db	0
strbpal	db	255,2,4,3
	db	0
plaspal	db	64,15,3,1
	db	64,-15,-3,-1
	db	64,14,15,2
	db	64,-14,-15,-2
	db	0
cooppal	db	-3,15,0,0
	db	8,96,127,40
	db	-3,34,0,15
	db	8,-64,112,96
	db	0
flampal	db	2,0,0,0
	db	30,34,0,0
	db	16,0,63,0
	db	16,0,0,63
	db	0
mzpal	db	22,46,46,0
	db	21,-46,0,46
	db	21,0,-46,0
	db	0
swspal	db	16,63,43,53
	db	0
endpal	db	16,55,63,31
	db	0

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±  TABULKY  ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
spotdiv	db	64,3,3,2,3,2,2,1
mzkrtab	db	48,31,64,21,55,37,72,49,30,67,19,57,37,76,43
	db	22,63,52,30,73,45,22,67,55,31,78,34,58,45,19
	db	70,37,63,49,21,76,30,58,43,72,34,64,48,16,79
	db	0

;±±±±±±±±±±±±±±±±±  UDAJE PRE POHYBY (PROCEDURA NEWPOS)  ±±±±±±±±±±±±±±±±±±
	align	2
spotdat	dw	8000h,0,320,832
	dw	0,8000h,192,256
	dw	0c000h,0c000h,256,320
enddat	dw	0c000h,0c000h,3584,1024
plasdat	dw	0,0,421,649
	dw	0,0,385,256
	dw	0,0,512,299
tundat	dw	0,0,311,200
coopdat	dw	0,0,256,569
	dw	0,0,873,1024
	dw	0,0,241,768
	dw	0,0,512,855

;±±±±±±±±±±±±±±±±±±±±  PREMENNE A DOPOCITANE TABULKY  ±±±±±±±±±±±±±±±±±±±±±
	align	4
mzxc	dd	mzxstr
mzyc	dd	mzystr

asprat	dw	133h
rvzdial	dw	1
rotacia	dw	0
rotinc	dw	0

endrotm	dw	0

tunelr	dw	0
tunelx	dw	0
tunely	dw	0
stunel	db	0

fontand	db	0f0h

fadecnt	dw	?

yposx	dw	?
yposy	dw	?

fontseg	dw	?		; Segment fontu 32x64 (64k)
frc1seg	dw	?		; Seg drevenej textury (64k)
frc2seg	dw	?		; Seg mramorovej textury (64k)
kruhseg	dw	?		; Seg kruhov (64k)
sinoseg	dw	?		; Seg sinoveho obrazku (64k)
bufseg1	dw	?		; Seg univerzalny 1 (64k)
bufseg2	dw	?		; Seg univerzalny 2 (64k)
mandseg	dw	?		; Seg mrndelbrotu (26k)

palent	dw	?,?,?
newpal	db	768 dup (?)
tmppal	db	768 dup (?)
curpal	dw	768 dup (?)
incpal	dw	768 dup (?)

costab	dw	400h dup (?)
costab2	db	400h dup (?)

dummy20	dw	?
	align	4

bufer	db	20000 dup (?)
stako	db	1000h dup (?)
stakdno	label	byte

code	ends
	end	start

