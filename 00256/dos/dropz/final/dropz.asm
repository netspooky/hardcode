;-------------------------------------------------------------------------------
; dr()pz [refined], 256B intro, 1st place at Demobit 98 demoparty
; coded by -baze-> of 3SC [with help of bEETLE and loveC (many refinements)]
; e-mail: baze@decef.elf.stuba.sk
;-------------------------------------------------------------------------------
; This source code is written to be compiled by cool Netwide Assembler (NASM).
; Visit it's web site at www.web-sites.co.uk/nasm.
;-------------------------------------------------------------------------------
; And now few comments in worldwide used Slovak language :)

[org 100h]
[segment .text]

	push	si		; naplnime niecim zasobnik pre nahodne cisla

	mov	ax,13h
	int	10h		; inicializacia grafickeho modu 320x200x256

; VYPOCET PALETY FARIEB

	mov	cl,0		; do CL hodnota "256" (CH = ?, minus 1 byte)
PALETTE	mov	dx,3C8h		; do DX port PEL ADDRESS registra
	mov	al,cl
	out	dx,al		; odoslanie indexu farby
	inc	dx		; do DX port PEL DATA registra
	mov	al,0
	out	dx,al		; odoslanie zlozky R
	mov	al,cl
	shr	al,1                                             
	out	dx,al		; odoslanie zlozky G
	mov	al,cl
	cmp	al,64
	jc	OKPAL
	mov	ax,4A3Fh	; do AH cislo DOS sluzby na realokaciu pamate
OKPAL	out	dx,al		; odoslanie zlozky B
	loop	PALETTE		; opakujeme pre vsetky farby

; ALOKACIA PAMATE POTREBNEJ PRE DVE 256 x 256 PIXELOVE MAPY

	mov	bh,3*16		; do BX aspon 3*16*256 paragrafov (BL = ?, -1B)
	int	21h		; alokujeme 3 segmenty (program + 2 mapy)
	jc	near ENDPROG	; ak je malo pamate, ukoncime program

	mov	ax,cs
	add	ah,16
	mov	ds,ax		; do DS segmentova adresa prvej mapy
	add	ah,16
	mov	es,ax		; do ES segmentova adresa druhej mapy

; VYPIS BITMAPOVEHO TEXTU

WATER	push	es		; ulozime ES (budeme potrebovat pointer na mapu)
	mov	ax,1130h	; sluzba VGA BIOS - informacie o fonte
	mov	bh,3		; budeme pouzivat font 8 x 8 pixelov
	int	10h		; v ES:BP je adresa fontu

	mov	bx,TEXT		; ideme "virit hladinu" textom
	mov	si,64*256+38	; do SI umiestnenie textu v mape
	call	DRAWTEX		; zavolame vypis znakoveho retazca
	mov	si,100*256+100
	call	DRAWTEX		; a to celkovo 3 krat
	mov	si,136*256+36
	call	DRAWTEX

	pop	es		; obnovime pointer na pixelovu mapu

; "KVAPNUTIE" NA HLADINU

RANDOM	pop	si		; nahodne cisla x[n] = (5 * x[n-1] + 7) % 65536
	lea	si,[esi+4*esi+7]; takto pocita uvedeny vyraz loveC :)
	mov	[si],byte 255	; umiestnime na nahodne miesto mapy kvapku
	push	si		; ulozime nahodne cislo do buducej iteracie

; VYPOCET SIRENIA VLNENIA V MAPE (nemam miesto na odvodenie vztahov z fyziky)
	
WATLINE	mov	al,[di+1]
	add	al,[di-1]	; spocitame okolite pixely
	add	al,[di+256]
	add	al,[di-256]
	shr	al,1		; vydelime sucet dvoma
	sub	al,[es:di]	; odcitame predchadzajucu fazu
	jnc	OK		; pripadne orezeme zaporne vlny ...
	mov	al,0		; ... ziskame tak vacsiu amplitudu (0 - 255)
OK	stosb			; ulozime pixel
	or	di,di
	jnz	WATLINE		; opakujeme pre vsetky pixely v mape

	push	ds		; ulozime DS (neskor POPneme do ES)

	push	es
	pop	ds		; do DS hodnota ES (vymena pointrov na mapy)
	push	word 0A000h
	pop	es		; do ES segmentova adresa zaciatku videoram

; CAKANIE NA NOVY SNIMOK

	mov	dl,0DAh		; do DX port INPUT STATUS registra (DH = 3, -1B)
FRAME	in	al,dx
	and	al,8
	jz	FRAME		; pockame na novy snimok

; VYKRESLENIE MAPY NA OBRAZOVKU

	mov	di,32		; budeme vykreslovat od 32. stlpca (centrovanie)
	xor	si,si		; do SI zaciatok vykreslovanej mapy
	mov	dl,200		; kreslime 200 riadkov
DRAW	mov	cl,128		; prenasame 256 bajtov, cize 128 slov (word)
	rep	movsw		; prenos slov z mapy do videoram (rychlejsie)
	movzx	bx,[si]		; vyberieme hodnotu z mapy kvoli "osciloskopu"
	or	bx,bx		; je vyska hladiny v mape nulova? ...
	jz	NOOSCIL		; ... ak ano, nevykreslujeme pixel (estetika)
	mov	[es:bx+di-128],byte 80	; inak vykreslime symetricky dva pixely
	neg	bx			; s danou intenzitou
	mov	[es:bx+di-128],byte 80
NOOSCIL	add	di,byte 64	; posunieme sa na dalsi riadok obrazovky
	dec	dl
	jnz	DRAW		; a opakujeme pre vsetky riadky

	pop	es		; dokoncenie vymeny ES <-> DS

	in	al,60h		; test klavesy ESC
	dec	al
	jnz	near WATER	; ak nebola stlacena, skok na dalsi snimok

	mov	ax,03h
	int	10h		; nastavenie textoveho rezimu

	pop	si		; oprava zasobnika po nahodnych cislach
ENDPROG	ret			; navrat do operacneho systemu

; RUTINA NA VYPIS TEXTOVEHO RETAZCA

DRAWTEX	movzx	di,byte [cs:bx]	; do DI ASCII hodnota znaku
	inc	bx		; zvysime ukazovatel na text
	shl	di,3		; DI = DI * 8, mame offset znaku vo fonte
	jz	ENDPROG		; ak bol znak nulovy, koniec vypisu
	mov	cl,8		; budeme vypisovat 8 riadkov
CHARLIN	mov	al,[es:bp+di]	; vyberieme bajt z predlohy znaku
	inc	di		; zvysime ukazovatel na dalsi bajt predlohy
	mov	ch,8		; znak ma 8 stlpcov
ROTATE	shl	al,1		; do CARRY pixel z predlohy
	jnc	NOPIXEL		; ak pixel nebol nastaveny, nic nekreslime
	add	[si],dword 02040304h	; inak pripocitame "stvorpixel"
NOPIXEL	add	si,byte 4	; posunieme sa na dalsi pixel v mape
	dec	ch
	jnz	ROTATE		; opakujeme 8-krat
	add	si,1024-32	; posunieme sa na dalsi riadok
	loop	CHARLIN		; opakujeme 8-krat (LOOP trik, CH = 0, setrime)
	add	si,32-8192	; posunieme sa na dalsi znak
	jmp	DRAWTEX		; skok na vypis dalsieho znaku

TEXT	db	"dr()pz",0	; hadajte co :)
	db	"by",0
	db	"-baze>",0

;-------------------------------------------------------------------------------
; Initially, this intro was hacked up during sleepless night before party.
; Few days after Demobit 98 we made this refined version. Although it is not
; as carefully optimized as it can be [loveC was able to make it in less than
; 230 bytes], I decided to spread this [almost original] code. It is easier
; to understand and it actually shows our poor mental state at given time :)
;-------------------------------------------------------------------------------
