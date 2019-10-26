; Kod napisany przez Piotra Tarsê
.486p
locals

code32 segment para public use32
	assume cs:code32, ds:code32


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

clear_dpmi_regs proc

	pushad
	xor	eax,eax
	mov	edi,offset _regs
	mov	ecx,25
	cld
	rep	stosw
	mov	edi,offset _regs
	mov	ax,data16
	popad
	ret

endp

losuj proc

	mov	bx,los_pom
	add	bx,9248h
	ror	bx,3
	mov	los_pom,bx
	mul	bx
	mov	ax,dx
	ret
endp

_main proc
	finit

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
	mov	[edi._ecx],103h ;video_mode
	mov	[edi._edi],offset mode_info
	mov	ax,0300h
	mov	bx,10h
	int	31h			;Sprawdzenie, czy mo¿na w³¹czyæ tryb 112h
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

	
	mov	cx,bx
	shr	ebx,16
	mov	si,9h
	mov	di,600h
	mov	ax,800h
	int	31h
	jc	koniec
	shl	ebx,16
	mov	bx,cx
	sub	ebx,code32_base
	mov	_a0000h,ebx


	mov	[edi._eax],4f02h
	xor	ebx,ebx
	mov	bx,103h ;video_mode
	or	bx,4000h ;14 bit okreœla rodzaj
					;adresowania 1-liniowe, 0-okna.  
	mov	[edi._ebx],ebx
	mov	ax,0300h
	mov	bx,10h
	int	31h			;Prze³¹czenie trybu
					;na 4101h

	mov	[edi._eax],4f07h
	mov	[edi._ebx],0
	mov	[edi._ecx],0
	mov	[edi._edx],0
	mov	ax,0300h
	mov	bx,10h
	int	31h
poczatek:
	mov	cx,05300h
	mov	bx,00007h
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


	mov	edi,data16
	shl	edi,4
	sub	edi,code32_base

	mov	cx,64
	xor	ax,ax
n_kolor1:
	xor	al,al
	stosb
	stosb
	mov	al,ah
	stosb
	inc	ah
	mov	al,ah
	inc	edi
	loop	n_kolor1

	mov	cx,64
	xor	ax,ax
n_kolor2:
	xor	al,al
	stosb
	mov	al,ah
	stosb
	mov	al,63
	stosb
	inc	ah
	inc	edi
	loop	n_kolor2

	mov	cx,64
	xor	ax,ax
n_kolor3:
	mov	al,ah
	stosb
	mov	al,63
	stosb
	stosb
	inc	ah
	inc	edi
	loop	n_kolor3

	mov	cx,64
	mov	al,63
n_kolor4:
	stosb
	stosb
	stosb
	dec	al
	inc	edi
	loop	n_kolor4

	mov	ax,0300h
	mov	bx,10h
	mov	edi,offset _regs
	call	clear_dpmi_regs
	mov	[edi._eax],4f09h
	mov	[edi._ebx],80h
	mov	[edi._ecx],256
	mov	[edi._es],data16
	int	31h

	mov	ecx,600
	mov	edi,ekran
qpa:	mov	eax,800
kaaa:	cld
	stosb
	dec	eax
	jnz	kaaa
	dec	ecx
	jnz	qpa


main_loop:


	mov	edi,ekran
	mov	ecx,800*598
	add	edi,800
qnik:	xor	eax,eax
	xor	ebx,ebx
	mov	al,[edi-800]
	mov	bl,[edi-1]
	add	ax,bx
	mov	bl,[edi+1]
	add	ax,bx
	mov	bl,[edi+800]
	add	ax,bx
	shr	ax,2
	sub	al,5
	mov	[edi],al
	inc	edi
	dec	ecx
	jnz	qnik


	mov	dx,03dah
c1:
	in	al,dx
	test	al,8
	jz	c1
c2:
	in	al,dx
	test	al,8
	jnz	c2

	mov	esi,ekran
	mov	edi,_a0000h
	mov	ecx,800*600/4
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

even
los_pom		dw 1111h
align 4
_a0000h		dd 0
ekran			dd 0
uchwyt_bufora	dd 0
_regs			dpmi_regs ?

endp
code32 ends
data16 segment para public use16
	paleta		db 1024 dup(0)
	mode_info modeinfoblock <>;
	card_info vbeinfoblock <>;
data16 ends
end