; Kod napisany przez Piotra Tarsê

; Linie zaczynaj¹ce siê od œrednika s¹ komentarzem i nie s¹ brane pod uwagê
; przy kopilacji

; Program: Bum (wersja dwuwymiarowa - 2W).
; Opis: Program przedstawiaj¹cy dziecinnie prosty do wykonania efekt graficz
; ny typu wybuch. Zrobiona przeze mnie wersja tego efektu jest doœæ znacznie
; uproszczona (dla wiêkszej czytelnoœci kodu). Program dzia³a w rozdzielczoœ
; ci 320x200x256 kolorów. Korzysta z kernela prze³¹czaj¹cego w tryb 32-bitow
; y autorstwa Miko³aja Feliksa (nie zawar³em tutaj jego kodu, gdy¿ objaœnien
; ie jego dzia³ania od strony technicznej i zasad pracy procesora (przede ws
; zystkim obliczania adresów bezwzglêdnych) w ró¿nych trybach; u¿yty tutaj p
; rzeze mnie 32-bitowy tryb chroniony jest doœæ trudny do opanowania, wiêc d
; o³¹czy³em tylko skompilowany kernel (plik kernel.obj). Pobie¿ny opis dwóch
; najwa¿niejszych trybów procesora zaj¹by kilkanaœcie kilobajtów i nie jest
; potrzebny do zrozumienia dzia³ania poni¿szego programu.
; Algorytm: Program dzia³a w pêtli. Na pocz¹tku inicjujemy wszystkie punkty:
; ich wspó³rzêdne ustawiamy na (0,0) - aby wybuch zacz¹³ siê od œrodka ekran
; u, a prêdkoœci pionowe (vy) i poziome (vx) ustawiamy na losow¹ wartoœæ z m
; a³ego przedzia³u. Potem zmniejszamy wartoœæ koloru. Wartoœæ ta jest zmniej
; szana z ka¿d¹ klatk¹ animacji, a wiêc punkty z czasem staj¹ siê coraz bard
; ziej ciemne. Po dojœciu do zera kolor siê przekrêca i ma wartoœæ 255 (jest
; zmienn¹ typu bajt, a wiêc bêdzie przekrêca³ siê co 256 klatek animacji). W
; ka¿dym powtórzeniu pêtli sprawdzane jest czy przypadkiem kolor nie przyj¹³
; wartoœci zero. W takim przypadku punkty s¹ reinicjowane (dlatego pocz¹tkow
; ¹ wartoœ zmiennej kolor ustawi³em na 1 - aby na pocz¹tku zainicjowaæ wszys
; tkie punkty). Teraz rysujemy punkty: do wspó³rzêdnych x i y dodajemy korek
; ty odpowiednio x i y, aby wybuch by³o widaæ na œrodku ekranu i obliczamy p
; ozycjê piksela w buforze ze wzoru: p = 320*y + x, poniewa¿ szerokoœæ ekran
; u wynosi 320. W tym programie rysowane s¹ kwadraty 2x2 zamiast pikseli, by
; by³y bardziej widoczne. Wa¿ne jest te¿, by punkty nie wychodzi³y poza ekra
; n i nie by³y na jego brzegu - w takim przypadku nie rysujemy ich. Po narys
; owaniu punktów rozmazujemy obraz (rozmazywanie tutaj polega na zsumowaniu
; pikseli nad, pod, z lewej i z prawej aktualnego piksela i podzielenia wyni
; ku przez 4) i œciemniamy obraz o 1. Rysowanie odbywa siê ca³y czas na tym
; samym ekranie, dziêki czemu widaæ tak jakby œlad po ruchu pikseli. Po nary
; sowaniu wszystkich punktów przetwarzamy je: do wspó³rzêdnych x i y dodajem
; y odpowiednio prêdkoœci vx i vy (punkty poruszaj¹ siê we wszystkie strony)
; , prêdkoœci spowalniamy mno¿¹c je przez np: 0.95 (aby punkty porusza³y siê
; coraz wolniej) i dodajemy grawitacjê do prêdkoœci pionowej (vy) - aby punk
; ty te¿ powoli spada³y w dó³. Ca³y proces jest powtarzany dopóty, dopóki u¿
; ytkownik nie naciœnie klawisza 'Esc' co koñczy ca³y program.

MAX_P			equ 600 ; iloœæ punktów

; Program wykorzystuje interfejs DPMI, a wiêc musi byæ zainstalowany w pamiê
; ci jakiœ DOS extender typu CWSDPMI, EMM386 lub inny. Mo¿e te¿ byæ wINDOW$
; 32-bitowy.
.486p
locals

code32 segment para public use32	; u¿ywamy segmentów 32-bitowych, a wiêc
	 assume cs:code32, ds:code32	; mamy wszystko w jednym segmencie, tak
						; jak pod wINDOZE

global _main:proc				; potrzebne kernelowi
global code32_base:dword		; zwrócone przez kernel


dpmi_regs struc				; struktura potrzebna do wywo³añ przerwa
	_edi		dd ?			; ñ 16-bitowych w trybie 32-bitowym, par
	_esi		dd ?			; ametry przekazywane s¹ do tej struktur
	_ebp		dd ?			; y, reszt¹ zajmuje siê DOS extender
	_none1	dd ?
	_ebx		dd ?
	_edx		dd ?
	_ecx		dd ?
	_eax		dd ?
	_flags	dw ?
	_es		dw ?
	_ds		dw ?
	_fs		dw ?
	_gs		dw ?
	_none2	dw ?
	_none3	dw ?
	_sp		dw ?
	_ss		dw ?
ends
losuj proc

	mov	bx,los_pom
	add	bx,9248h
	ror	bx,3
	mov	los_pom,bx
	mov	ax,los_max
	sub	ax,los_min
	mul	bx
	mov	ax,dx
	add	ax,los_min				; ax - liczba losowa
	ret
endp
_main proc
	finit					; inicjujemy koprocesor matematyczny

poczatek:
	; alokujemy 64000 bajtów pamiêci (na nasz bufor ekranu)
	mov	cx,64000			; rozmiar pamiêci do zaalokowania podaje
	xor	bx,bx				; my w BX:CX
	mov	ax,0501h			; wybieramy funkcjê alokowania pamiêci
	int	31h				; wywo³ujemy host DPMI
	jc	koniec			; jak b³¹d to kaplica
	shl	ebx,16
	mov	bx,cx
	sub	ebx,code32_base
	mov	ax,si
	shl	eax,16
	mov	ax,di
	mov	uchwyt_bufora,eax		; uchwyt zwracany w SI:DI
	mov	ekran,ebx			; adres bezwzglêdny BX:CX (ale przerobil
						; iœmy go na wzglêdny, aby mo¿na go by³o
						; u¿ywaæ)

	; czyœcimy nasz bufor ekranu
	mov	edi,ebx
	xor	eax,eax
	mov	ecx,64000/4
	cld
	rep	stosd

	; obliczamy wzglêdny adres VRAM - pamiêæ ekranu
	mov	eax,0a0000h
	sub	eax,code32_base
	mov	_a0000h,eax

	; ustaw tryb 13h (graficzny)
	mov	ax,0300h
	mov	bx,10h
	mov	edi,offset _regs
	mov	[edi._eax],13h
	int	31h

	; podajemy numer koloru od którego zaczynamy (w tym przypadku 0)
	mov	dx,03c8h
	xor	ax,ax
	out	dx,al
	; zwiêkszamy numer portu (podawanie kolorów), i wysy³amy kolory (skala
	; odcieni szaroœci). Podajemy sk³adowe R, G, B. Maksymalna wartoœæ któ
	; rejkolwiek sk³adowej wynosi 63 (bo wczesne karty graficzne VGA mia³y
	; 6-bitowy przetwornik analogowo-cyfrowy (DAC) i tak pozosta³o, aby pr
	; ogramy by³y kompatybilne z ka¿d¹ kart¹ graficzn¹. Mo¿na w³¹czyæ 8-bi
	; towy DAC, ale to jest rzadko u¿ywane (w tym programie te¿ jest u¿ywa
	; ny 6-bitowy DAC).
	inc	dx
	; za ka¿dym razem ustawiamy 4 jednakowe kolory, zwiêkszamy jasnoœæ o j
	; eden i tak w kó³ko 64 razy
	mov	bx,64
paleta:
	mov	cx,12
paleta_pentla:
	out	dx,al
	loop	paleta_pentla		; loopniêcie, czyli inaczej dec cx \ jnz
	inc	al
	dec	bx
	jnz	paleta

main_loop:					; siedzimy ostro w pêtli dopóki u¿yszkod
						; nik nie naciœnie eskejta
	dec	kolor	
	jnz	jedziemy_dalej

	; inicjujemy punkty
	mov	ecx,MAX_P
	mov	esi,offset punkt_tab
inicjujemy_punkty:
	fldz					; ³adujemy zero i ustawiamy nim wspó³rzê
	fst	dword ptr [esi]		; dne punktów (wybuch zaczyna siê na œro
	fstp	dword ptr [esi+4]		; dku ekranu)

	mov	los_max, 12000		; losujemy liczbê z przedzia³u 0...12000
	call	losuj				; , odejmujemy 6000 otrzymuj¹c wartoœæ z
	sub	ax,6000			; przedzia³u -6000...6000, dzielimy prze
	mov	fpom16,ax			; z skalê (700) i ustawiamy ni¹ prêdkoœæ
	fild	fpom16			; vx
	fdiv	skala
	fstp	dword ptr [esi+8]

	call	losuj				; to samo co wy¿ej dla prêdkoœci vy
	call	losuj				; dwa razy losuj, bo funkcja losuj jest
	sub	ax,6000			; niedoskona³a
	mov	fpom16,ax
	fild	fpom16
	fdiv	skala
	fstp	dword ptr [esi+12]

	add	esi,16			; przechodzimy do nastêpnego punktu
	dec	ecx				; je¿eli jeszcze coœ zosta³o to powtarza
	jnz	inicjujemy_punkty		; my pêtlê

jedziemy_dalej:
; zaczynamy wykonywanie punktów

	mov	ecx,MAX_P
	mov	esi,offset punkt_tab
	mov	edi,ekran
wykonuj_punkty:
	fld	dword ptr [esi]		; ³adujemy wspó³rzêdne punktu, dodajemy
	fadd	korekta_x			; korekty x i y (aby wybuch by³ na œrodk
	fistp	word ptr [xe]		; ku ekranu) i zapisujemy je w zmiennych
	fld	dword ptr [esi+4]		; przechowuj¹cych wspó³rzêdne ekranowe
	fadd	korekta_y
	fistp	word ptr [ye]

	fld	dword ptr [esi+8]		; ³adujemy prêdkoœæ vx
	fadd	dword ptr [esi]		; dodajemy do wspó³rzêdnej x
	fstp	dword ptr [esi]		; zapisujemy wynik we wspó³rzêdnej x
	fld	dword ptr [esi+12]	; ³adujemy prêdkoœæ vy
	fadd	dword ptr [esi+4]		; dodajemy do wspó³rzêdnej y
	fstp	dword ptr [esi+4]		; zapisujemy wynik we wspó³rzêdnej y
	fld	dword ptr [esi+8]		; ³adujemy prêdkoœæ vx
	fmul	delta_v			; spowalniamy deczko
	fstp	dword ptr [esi+8]		; zapisujemy wynik w prêdkoœci vx
	fld	dword ptr [esi+12]	; ³adujemy prêdkoœæ vy
	fmul	delta_v			; spowalniamy deczko
	fadd	grav				; dodajemy grawitacjê (aby sobie spada³y
	fstp	dword ptr [esi+12]	; zapisujemy wynik w prêdkoœci vy

	cmp	word ptr [xe],0		; sprawdzamy wspó³rzêdne ekranowe
	je	punkt_nastempny		; nie powinny one byæ na brzegu ekranu
	cmp	word ptr [ye],0		; (obojêtne, czy górnym, czy lewym, czy
	je	punkt_nastempny		; jakim), ani nie powinny wychodziæ poza
	cmp	word ptr [xe],318		; ekran (logiczne)
	ja	punkt_nastempny
	cmp	word ptr [ye],198
	ja	punkt_nastempny

	xor	eax,eax			; obliczamy pozycjê naszego pikselka w b
	mov	ax,ye				; uforze ekranu ze wzoru: p = 320*y + x,
	shl	ax,6				; stosujê metodê przesuniêæ logicznych,
	mov	bx,ax				; bo jest o wiele szybsza od mno¿enia (o
	shl	ax,2				; ptymalizacja)
	add	ax,bx
	add	ax,xe				; mamy nasz¹ pozycjê p pikselka
	add	eax,edi			; dodajemy adres bufora ekranu
	mov	bl,kolor			; rysujemy kwadracik 2x2 o kolorze podan
	mov	bh,bl				; ym w zmiennej kolor
	mov	[eax],bx
	mov	[eax+320],bx
punkt_nastempny:
	add	esi,16			; przechodzimy do nastêpnego punktu
	dec	ecx				; sprawdzamy czy zosta³y jeszcze punkty
	jnz	wykonuj_punkty		; je¿eli tak to powtarzamy pêtlê


; koñczymy wykonywaæ punkty

	; blur start
	mov edi,ekran			; zerujemy (czyœcimy) pierwsz¹ liniê ekr
	xor eax,eax				; anu
	mov ecx,320/4
	cld
	rep stosd

	mov edx,64000-640			; rozmazujemy ca³y ekran oprócz pierwsze
	xor ebx,ebx				; j i ostatniej linii
blur_skok:
	mov al,[edi-1]			; bierzemy piksele po lewej, prawej, u g
	mov bl,[edi-320]			; óry i u do³u, sumujemy je, dzielimy to
	add ax,bx				; przez 4, odejmujemy 1 (œciemniamy) i z
	mov bl,[edi+1]			; apisujemy
	add ax,bx
	mov bl,[edi+320]
	add ax,bx
	shr ax,2
	jz blur_dalej
	dec al
	mov [edi],al
blur_dalej:
	inc edi
	dec edx
	jnz blur_skok

	xor eax,eax				; zerujemy (czyœcimy) ostatni¹ liniê ekr
	mov ecx,320/4			; anu
	rep stosd
	; blur end

	; czekamy na odœwie¿enie ekranu
	mov	dx,03dah
c1:
	in	al,dx
	test	al,8
	jz	c1
c2:
	in	al,dx
	test	al,8
	jnz	c2

	; wywalamy nasz bufor na ekran
	mov	esi,ekran
	mov	edi,_a0000h
	mov	ecx,64000/4
	cld
	rep	movsd

	; je¿eli nie naciœniêto eskejta to powtarzamy pêtelkê
	in	al,60h
	dec	al
	jnz	main_loop

	; zwalniamy pamiêæ
	mov	eax,uchwyt_bufora
	mov	di,ax
	shr	eax,16
	mov	si,ax
	mov	ax,0502h
	int	31h

	; z powrotem tryb tekstowy (03h)
	mov	ax,0300h
	mov	bx,10h
	mov	edi,offset _regs
	mov	[edi._eax],03h
	int	31h
koniec:
	; koniec programu i powrót do DOS'a
	mov	ah,4Ch
	int	21h

kolor			db 1				; kolor do rysowania pikseli
even
los_min		dw 0				; do losowania: liczba minimalna,
los_max		dw 0				; maksymalna i liczba pomocnicza (
los_pom		dw 1234h			; tak jak zmienna randomseed w pas
fpom16		dw 0				; zczalu)
xe			dw 0				; wspó³rzêdne ekranowe x i y (po k
ye			dw 0				; orekcie)
align 4
_a0000h		dd 0				; adres pamiêci ekranu (dostêp bez
							; poœredni)
ekran			dd 0				; przechowuje adres bufora ekranu
uchwyt_bufora	dd 0				; a ten jego uchwyt (potrzebny do
fpom32		dd 0.0			; póŸniejszego zwolnienia pamiêci)
korekta_x		dd 160.0			; korekty wspó³rzêdnych (rysujemy
korekta_y		dd 100.0			; od œrodka ekranu)
delta_v		dd 0.95			; spowolnienie
grav			dd 0.056636246626546456 ; si³a grawitacji
skala			dd 700.0			; do obliczania prêdkoœci punktów
hor_resolution	dd 320.0			; rozdzielczoœæ pozioma
_regs			dpmi_regs ?
punkt_tab		dd MAX_P dup(?,?,?,?)	; x,y,vx,vy	(16 bajtów)
endp
code32 ends
end