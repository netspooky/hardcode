; Kod napisany przez Piotra Tarsê
; Dziura promieñ 20 pikseli lub mniej
; Cieniowanie promieñ 30 pikseli
.486p
locals

code32 segment para public use32
	assume cs:code32, ds:code32

SPEED			equ	1
video_mode		EQU	112h	; tryb 640x480x24
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
krowiarz_y		dw 0
krowiarz_x		dw 0

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
	mov	[edi._ecx],video_mode
	mov	[edi._edi],offset mode_info
	mov	ax,0300h
	mov	bx,10h
	int	31h			;Sprawdzenie, czy mo¿na w³¹czyæ tryb
	mov	eax,data16
	shl	eax,4
	sub	eax,code32_base
	add	eax,offset mode_info
	mov	bx,[eax.modeattributes]
	and	bl,1
	jz	koniec
	mov	ebx,[eax.physbaseptr]
	or	ebx,ebx		;Adresowanie liniowe?
	jz	koniec		;Jeœli eax=0, to nie.

	
	mov	cx,bx
	shr	ebx,16
	mov	si,0eh
	mov	di,1000h
	mov	ax,800h
	int	31h
	jc	koniec
	shl	ebx,16
	mov	bx,cx
	sub	ebx,code32_base
	mov	_a0000h,ebx

	mov	[edi._eax],4f02h
	xor	ebx,ebx
	mov	bx,video_mode
	or	bx,bit_adresowania;14 bit okreœla rodzaj
					;adresowania 1-liniowe, 0-okna.  
	mov	[edi._ebx],ebx
	mov	ax,0300h
	mov	bx,10h
	int	31h			;Prze³¹czenie trybu



poczatek:
	mov	cx,0e000h
	mov	bx,0002eh
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
	add	ebx,640*480*3
	mov	tablica1,ebx
	add	ebx,640*480*2
	mov	tablica2,ebx
	add	ebx,640*480*2
	mov	tekstura,ebx


	mov	ecx,512*512
	mov	edi,tekstura
tex_gen:
	mov	[edi],al
	mov	[edi+1],al
	mov	[edi+2],al
	inc	al
	seto	bl
	add	al,bl
	add	edi,3
	dec	ecx
	jnz	tex_gen

mamy_teksture:
	mov	ecx,640*480
	mov	edi,tablica1
tab1_gen:
	mov	tx,-320
	mov	ax,x
	add	tx,ax
	fild	tx
	fimul	tx
	fistp kuppa
	mov	ty,-240
	mov	ax,y
	add	ty,ax
	fild	ty
	fimul	ty
	fiadd	kuppa
	fsqrt
	fstp	kuppa
	fild	promien
	fdiv	kuppa
	fistp	temp
	mov	ax,temp
	and	ax,511
	mov	[edi],ax
	inc	[x]
	cmp	x,640
	jnz	tab1_gen_koniec
	mov	x,0
	inc	[y]
tab1_gen_koniec:
	inc	edi
	inc	edi
	dec	ecx
	jnz	tab1_gen

	mov	ecx,640*480
	mov	edi,tablica2
	mov	x,-320
	mov	y,-240
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
	cmp	x,320
	jnz	tab2_gen_koniec
	mov	x,-320
	inc	[y]
tab2_gen_koniec:
	mov	ax,temp
	and	ax,511
	mov	[edi],ax
	inc	edi
	inc	edi
	dec	ecx
	jnz	tab2_gen

	mov	cx,128*128
	xor	ax,ax
	mov	esi,offset kolo
	mov	x,0
	mov	y,0
kolo_gen:
	fild	x
	fimul	x
	fild	y
	fimul	y
	faddp
	fsqrt
	fistp	temp
	mov	ax,temp
	cmp	ax,127
	jna	dssds
	mov	bl,0
	jmp	krowafds
dssds:mov	bx,128
	sub	bx,ax
	shl	bx,1
	dec	bx
krowafds:
	mov	[esi],bl
	inc	x
	cmp	x,128
	jnz	dalse
	mov	x,0
	inc	y
dalse:inc	esi
	dec	cx
	jnz	kolo_gen

	lea	edx,nazwa_tekstury
	mov	ax,3d02h
	int	21h
	jc	main_loop
	xchg	eax,ebx
	mov	ah,3fh
	mov	ecx,18
	mov	edx,tekstura
	int	21h
	mov	ah,3fh
	mov	ecx,512*512*3
	mov	edx,tekstura
	int	21h

main_loop:
	mov	ecx,640*480
	xor	esi,esi
klatka:
	mov	eax,tablica2
	xor	ebx,ebx
	mov	bx,[eax+esi*2]
	add	bx,krowiarz_x
	mov	edi,tablica1
	and	bx,511
	xor	edx,edx
	shl	ebx,9
	mov	dx,[edi+esi*2]
	add	dx,krowiarz_y
	and	dx,511
	or	ebx,edx

	lea	ebx,[ebx+ebx*2]
	lea	edi,[esi+esi*2]
	add	ebx,tekstura
	add	edi,ekran

	mov	ax,[ebx]
	mov	dl,[ebx+2]
	mov	[edi],ax
	mov	[edi+2],dl


	inc	esi
	dec	ecx
	jnz	klatka

	mov	ecx,128*128
	mov	esi,offset kolo
	mov	edi,ekran
	add	edi,(240*640+320)*3
	mov	x,0
sciemniaj1:
	mov	al,[esi]
	mov	bl,[edi]
	sub	bl,al
	jnc	dsakl
	mov	bl,0
dsakl:mov	[edi],bl
	mov	bl,[edi+1]
	sub	bl,al
	jnc	dssfe
	mov	bl,0
dssfe:mov	[edi+1],bl
	mov	bl,[edi+2]
	sub	bl,al
	jnc	dssdf
	mov	bl,0
dssdf:mov	[edi+2],bl
	inc	x
	cmp	x,128
	jnz	sjgjg
	mov	x,0
	add	edi,(640-128)*3
sjgjg:add	edi,3
	inc	esi
	dec	ecx
	jnz	sciemniaj1

	mov	ecx,128*128
	mov	esi,offset kolo
	mov	edi,ekran
	add	edi,(240*640+320-128)*3
	mov	x,0
	add	esi,127
sciemniaj2:
	mov	al,[esi]
	mov	bl,[edi]
	sub	bl,al
	jnc	dsak2
	mov	bl,0
dsak2:mov	[edi],bl
	mov	bl,[edi+1]
	sub	bl,al
	jnc	dssf2
	mov	bl,0
dssf2:mov	[edi+1],bl
	mov	bl,[edi+2]
	sub	bl,al
	jnc	dssd2
	mov	bl,0
dssd2:mov	[edi+2],bl
	inc	x
	cmp	x,128
	jnz	sjgj2
	mov	x,0
	add	edi,(640-128)*3
	add	esi,256
sjgj2:add	edi,3
	dec	esi
	dec	ecx
	jnz	sciemniaj2

	mov	ecx,128*128
	mov	esi,offset kolo
	mov	edi,ekran
	add	edi,(240*640-128*640+320-128)*3
	mov	x,0
	add	esi,128*128-1
sciemniaj3:
	mov	al,[esi]
	mov	bl,[edi]
	sub	bl,al
	jnc	dsak3
	mov	bl,0
dsak3:mov	[edi],bl
	mov	bl,[edi+1]
	sub	bl,al
	jnc	dssf3
	mov	bl,0
dssf3:mov	[edi+1],bl
	mov	bl,[edi+2]
	sub	bl,al
	jnc	dssd3
	mov	bl,0
dssd3:mov	[edi+2],bl
	inc	x
	cmp	x,128
	jnz	sjgj3
	mov	x,0
	add	edi,(640-128)*3
sjgj3:add	edi,3
	dec	esi
	dec	ecx
	jnz	sciemniaj3

	mov	ecx,128*128
	mov	esi,offset kolo
	mov	edi,ekran
	add	edi,(240*640-128*640+320)*3
	mov	x,0
	add	esi,128*127
sciemniaj4:
	mov	al,[esi]
	mov	bl,[edi]
	sub	bl,al
	jnc	dsak4
	mov	bl,0
dsak4:mov	[edi],bl
	mov	bl,[edi+1]
	sub	bl,al
	jnc	dssf4
	mov	bl,0
dssf4:mov	[edi+1],bl
	mov	bl,[edi+2]
	sub	bl,al
	jnc	dssd4
	mov	bl,0
dssd4:mov	[edi+2],bl
	inc	x
	cmp	x,128
	jnz	sjgj4
	mov	x,0
	add	edi,(640-128)*3
	sub	esi,256
sjgj4:add	edi,3
	inc	esi
	dec	ecx
	jnz	sciemniaj4


	mov	dx,03dah
c1:
	in	al,dx
	test	al,8
	jz	c1
c2:
	in	al,dx
	test	al,8
	jnz	c2

	add	krowiarz_y,SPEED*2
	and	krowiarz_y,511
	add	krowiarz_x,SPEED
	and	krowiarz_x,511
	mov	esi,ekran
	mov	edi,_a0000h
	mov	ecx,640*480*3/4
	cld
	rep	movsd

	in	al,60h
	dec	al
	jnz	main_loop


	mov	eax,uchwyt_bufora
	mov	di,ax
	shr	eax,16
	mov	si,ax
	mov	ax,0502h
	int	31h

	mov	ebx,_a0000h
	add	ebx,code32_base
	mov	cx,bx
	shr	ebx,16
	mov	ax,801h
	int	31h

koniec:
	; z powrotem tryb tekstowy
	mov	ax,0300h
	mov	bx,10h
	mov	edi,offset _regs
	mov	[edi._eax],03h
	int	31h

	mov	ah,4Ch
	int	21h

nazwa_tekstury	db 'tekstura.tga',0
even
promien		dw 20000
tx			dw 0
ty			dw 0
_256			dw 256
temp			dw 0
align 4
_a0000h		dd 0
ekran			dd 0
tablica1		dd 0
tablica2		dd 0
uchwyt_bufora	dd 0
tekstura		dd 0
kolo			dd 0
kuppa			dd 0
kolo_coord		db 128*128 dup(?)
napis			dw 11 dup(0f00h)
_regs			dpmi_regs ?
endp
code32 ends

data16 segment para public use16
	mode_info modeinfoblock <>;
	card_info vbeinfoblock <>;
data16 ends
end