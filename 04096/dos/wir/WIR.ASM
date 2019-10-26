; Kod napisany przez Piotra Tarsê
; Dziura promieñ 20 pikseli lub mniej
; Cieniowanie promieñ 30 pikseli
.486p
locals

code32 segment para public use32
	assume cs:code32, ds:code32

SPEED			equ	7
video_mode		EQU	101h	; tryb 640x480x256
bit_adresowania	EQU	0100000000000000b

global _main:proc
global code32_base:dword

; Struktura danych dla funkcji 4F00h  przerwania 10h
;( Pobranie informacji o VBE)

     VbeInfoBlock STRUC
     VbeSignature       db  'VESA'   ; Napis VESA
     VbeVersion         dw  0200h    ; Wersja
     OemStringPtr       dd  ?        ; Nazwa producenta
     Capabilities       db  4 dup (?); Zarezerwowane
     VideoModePtr       dd  ?        ; Lista trybów
     TotalMemory        dw  ?        ; Liczba bloków po
                                     ; 64 Kb ka¿dy
                                     ; dodane dla VBE 2.0
     OemSoftwareRev     dw  ?         
     OemVendorNamePtr   dd  ?         
     OemProductNamePtr  dd  ?         
     OemProductRevPtr   dd  ?         
     _Reserved_         db 222 dup (?)
                                      
     OemData            db 256 dup (?)
     VbeInfoBlock ENDS



;Funkcja 4F01h 
;( Pobranie informacji o trybie )

     ModeInfoBlock   STRUC

     ; Informacje dotycz¹ce ka¿dej wersji VBE
     ModeAttributes      dw ? ; Atrybuty trybu;
                              ; pierwszy bit okreœla,
                              ; czy tryb dostêpny.
     WinAAttributes      db ?      
     WinBAttributes      db ?      
     WinGranularity      dw ?      
     WinSize             dw ?      
     WinASegment         dw ?      
     WinBSegment         dw ?      
     WinFuncPtr          dd ? ;WskaŸnik do funkcji
                              ;prze³¹czaj¹cej okna.
     BytesPerScanLine    dw ? ;Liczba bajtów w linii.

     ; Informacje dla wersji 1.2 lub nowszej
     XResolution         dw ? ; Rozdzielczoœæ pozioma
     YResolution         dw ? ; Rozdzielczoœæ pionowa
     XCharSize           db ?      
     YCharSize           db ?      
     NumberOfPlanes      db ? ; Liczba p³atów pamiêci
     BitsPerPixel        db ?       
     NumberOfBanks       db ?      
     MemoryModel         db ?      
     BankSize            db ?      
     NumberOfImagePages  db ?      
     _Reserved           db ?      

     RedMaskSize         db ? ;Liczba bitów przypadaj¹cych
                              ;na sk³adow¹ czerwon¹.
     RedFieldPosition    db ? ;Pozycja sk³adowej czerwonej
     GreenMaskSize       db ? 
     GreenFieldPosition  db ? 
     BlueMaskSize        db ? 
     BlueFieldPosition   db ? 
     RsvdMaskSize        db ? ;Sk³adowa dodatkowa. 
     RsvdFieldPosition   db ? 
     DirectColorModeInfo db ? 

     ;Informacje dla wersji 2.0 lub nowszej
     PhysBasePtr         dd ? ;Adres fizyczny odwzorowania VRAM
     OffScreenMemOffset  dd ? ;Pocz¹tek pamiêci poza
                              ;obszarem widocznym na 
                              ;ekranie
     OffScreenMemSize    dw ? ;Rozmiar tego obszaru 
     __Reserved          db 206 dup (?) 
     ModeInfoBlock ENDS

dpmi_regs struc
	_edi		dd ?
	_esi		dd ?
	_ebp		dd ?
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

x			dw 0
y			dw 0

_main proc
	finit

comment #
	mov	edi,offset _regs
	mov	[edi._ds],data16
	mov	[edi._es],data16
	mov	[edi._edi],offset card_info
	mov	[edi._eax],4F00h
	mov	ax,0300h
	mov	bx,10h
	int	31h
	cmp	[edi._eax],4Fh
	jnz	koniec
	mov	eax,data16
	shl	eax,4
	sub	eax,code32_base
	add	eax,offset card_info
	cmp	[eax.vbeversion],0200h
	jb	koniec
	mov	[edi._eax],4f01h
	mov	[edi._ecx],video_mode
	mov	[edi._edi],offset mode_info
	mov	ax,0300h
	mov	bx,10h
	int	31h			;Sprawdzenie, czy mo¿na w³¹czyæ tryb 101h
	mov	eax,data16
	shl	eax,4
	sub	eax,code32_base
	add	eax,offset mode_info
	mov	bx,[eax.modeattributes]
	and	bl,1
	jz	koniec
	mov	ebx,[eax.physbaseptr]
	or	eax,eax		;Adresowanie liniowe?
	jz	koniec		;Jeœli eax=0, to nie.
	mov	eax,32457280
	sub	eax,code32_base
	mov	duzy_ekran,eax
	
	mov	eax,ebx
	mov	ecx,10
	mov	esi,offset napis
napisz:
	xor	edx,edx
	mov	ebx,10
	div	ebx
	add	dl,'0'
	mov	[esi],dl
	add	esi,2
	loop	napisz
	mov	esi,offset napis
	mov	ecx,20
	mov	ebx,0b8000h
	sub	ebx,code32_base
kopy:	mov	al,[esi]
	mov	[ebx],al
	inc	esi
	inc	ebx
	loop	kopy

kgh:	in	al,60h
	dec	al
	jnz	kgh

	mov	[edi._eax],4f02h
	xor	ebx,ebx
	mov	bx,video_mode
	or	bx,bit_adresowania;14 bit okreœla rodzaj
					;adresowania 1-liniowe, 0-okna.  
	mov	[edi._ebx],ebx
	mov	ax,0300h
	mov	bx,10h
	int	31h			;Prze³¹czenie trybu
					;na 4101h

	xor	ebx,ebx

klawisz:				;Czekanie na naciœniêcie klawisza
	cmp	ebx,32323232h	;Zmiana koloru
	je	zeruj
	add	ebx,01010101h
	jmp bez_zerowania
zeruj:
	xor	ebx,ebx
bez_zerowania:
	mov	edi,duzy_ekran
	mov	ecx,320*240		;640*480 div 4
	mov	eax,ebx
	cld
	rep	stosd			;Wype³nienie obrazu
	in	al,60h		;Czy naciœniêto
	cmp	al,1			;klawisz?
	jnz	klawisz
#

poczatek:
	mov	cx,0ee00h
	mov	bx,00003h
	mov	ax,0501h
	int	31h
	jc	koniec
	shl	ebx,16
	mov	bx,cx
	sub	ebx,code32_base
	mov	ax,si
	shl	eax,16
	mov	ax,di
	mov	uchwyt_bufora,eax
	mov	ekran,ebx
	add	ebx,64000
	mov	tablica1,ebx
	add	ebx,64000
	mov	tablica2,ebx
	add	ebx,64000
	mov	tekstura,ebx

	; pobierz adres VRAM
	mov	eax,0a0000h
	sub	eax,code32_base
	mov	_a0000h,eax

	; ustawiamy tryb 13h
	mov	ax,0300h
	mov	bx,10h
	mov	edi,offset _regs
	mov	[edi._eax],13h
	int	31h


	mov	dx,03c8h
	xor	ax,ax
	out	dx,al
	inc	dx
	mov	cx,64
n_kolor1:
	xor	al,al
	out	dx,al
	out	dx,al
	mov	al,ah
	out	dx,al
	inc	ah
	mov	al,ah
	loop	n_kolor1
	mov	cx,64
	xor	ax,ax
n_kolor2:
	xor	al,al
	out	dx,al
	mov	al,ah
	out	dx,al
	mov	al,63
	out	dx,al
	inc	ah
	loop	n_kolor2
	mov	cx,64
	xor	ax,ax
n_kolor3:
	mov	al,ah
	out	dx,al
	mov	al,63
	out	dx,al
	out	dx,al
	inc	ah
	loop	n_kolor3
	mov	cx,64
	mov	al,63
n_kolor4:
	out	dx,al
	out	dx,al
	out	dx,al
	dec	al
	loop	n_kolor4

	mov	cx,-1
	mov	edi,tekstura
tex_gen:
	mov	[edi],al
	inc	al
	seto	bl
	add	al,bl
	inc	edi
	dec	cx
	jnz	tex_gen
	mov	[edi],al

mamy_teksture:
	mov	cx,64000
	mov	edi,tablica1
tab1_gen:
	mov	tx,-160
	mov	ax,x
	add	tx,ax
	fild	tx
	fimul	tx
	fistp temp
	mov	ty,-100
	mov	ax,y
	add	ty,ax
	fild	ty
	fimul	ty
	fiadd	temp
	fsqrt
	fistp	temp
	fild	promien
	fidiv	temp
	fistp	temp
	mov	ax,temp
	mov	[edi],al
	inc	[x]
	cmp	x,320
	jnz	tab1_gen_koniec
	mov	x,0
	inc	[y]
tab1_gen_koniec:
	inc	edi
	dec	cx
	jnz	tab1_gen

	mov	cx,64000
	mov	edi,tablica2
	mov	x,-160
	mov	y,-100
	mov	temp,0
tab2_gen:
	fild	y
	fild	x
	fpatan
	fimul	_256
	fldpi
	fdiv
	fistp	temp
	inc	[x]
	cmp	x,160
	jnz	tab2_gen_koniec
	mov	x,-160
	inc	[y]
tab2_gen_koniec:
	mov	ax,temp
	mov	[edi],al
	inc	edi
	dec	cx
	jnz	tab2_gen

	mov	cx,8*8
	xor	ax,ax
	mov	esi,offset kolo
kolo_gen:
	mov	[esi],al
	inc	esi
	dec	cx
	jnz	kolo_gen

main_loop:
	mov	cx,64000
	xor	edx,edx
klatka:
	xor	ebx,ebx
	mov	eax,tablica1
	add	eax,edx
	mov	bl,[eax]
	add	eax,64000
	mov	bh,[eax]
	add	bl,krowiarz_y
	mov	eax,tekstura
	add	eax,ebx
	mov	bl,[eax]
	mov	eax,ekran
	add	eax,edx
	mov	[eax],bl
	inc	edx
	dec	cx
	jnz	klatka
	mov	dx,03dah
c1:
	in	al,dx
	test	al,8
	jz	c1
c2:
	in	al,dx
	test	al,8
	jnz	c2
	add	krowiarz_y,SPEED
	mov	esi,ekran
	mov	edi,_a0000h
	mov	ecx,64000/4
	cld
	rep	movsd
	in	al,60h
	dec	al
	jnz	main_loop

wychodzimy:
	mov	eax,uchwyt_bufora
	mov	di,ax
	shr	eax,16
	mov	si,ax
	mov	ax,0502h
	int	31h

	; z powrotem tryb tekstowy
	mov	ax,0300h
	mov	bx,10h
	mov	edi,offset _regs
	mov	[edi._eax],03h
	int	31h
koniec:
	mov	ah,4Ch
	int	21h

krowiarz_y		db 0
even
promien		dw 10000
tx			dw 0
ty			dw 0
_256			dw 128
temp			dw 0
align 4
_a0000h		dd 0
ekran			dd 0
tablica1		dd 0
tablica2		dd 0
uchwyt_bufora	dd 0
tekstura		dd 0
kolo			dd 0
duzy_ekran		dd 0
kuppa			dd 0
kolo_coord		db 8*8 dup(?)
napis			dw 11 dup(0f00h)
_regs			dpmi_regs ?

endp
code32 ends

data16 segment para public use16
	mode_info modeinfoblock <>;
	card_info vbeinfoblock <>;
data16 ends
end