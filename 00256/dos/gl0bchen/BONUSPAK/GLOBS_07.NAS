; nem feltetelez SEMMILYEN kezdoerteket ah=0-n kivul (ami ugyis annyi)
; mert eleget szivtam mar veluk... azert hugicompon hasznalom meg oket =)

; sebesseg-issue: a legkozepen levo felteteles dolog kivalthato a kommentezett
; cmov-val, ez uannyi byte viszont nagy valszinuseggel gyorsit, csak epp ugy
; nem fut szegeny 'design overkilles' k6-omon (aminek viszont nem art ugy a
; misprediction es meg a legjobb elorejelzo is van benne - talan a hammernek
; lesz megint ilyen jo?)
; - erdekes, kiprobaltam celeron es lassabb volt a cmov. most erti ezt vki? =)

; masik sebesseg-issue: volt 1 tablazat nelqli pureFPU verzio, kisebb volt
; szegeny es egesz jo volt k6-2/550-en itthon es mint az alom ment 750-es
; duronon, csak epp onkormanyzati celeron333 majd belehalt szegeny, igy lett
; tablazat bele jool =)

; harmadik sebesseg-issue: veletlenul fuggolegesen olvastam a tablazatot...
; megcsereltem a koordinatakat (ebben szabadon te7em, az fpusban nem!) s
; lass csodat - kapasbol vagy 2x gyorsabb lett

; uj komment - palo1650 iszonyuantulgyors... tettem bele visszafutas-idozitot!
; nagyobb 8 bytetal, de lagalabb tuti jo!

org 100h

WIDTH equ 220		; 193 ala ha megy, +1 byte! es 265 folott se mux...
HEIGHT equ 200
pontok equ 2E2h 	; adatterulet eleje + random-befolyasolo - eleg bonyi
			; szabalyok befolyasoljak h milyen ertekkel nez ki jol
			; a cimek es koordinatak signed/unsigned dolgai + oian
			; szepen kilovik 1mast :) nincs is szukseg masra
pontdb equ 9

_textura equ 1		; 0: semmi (xor); 1: fenygl0b0k; 2: elore generalt
_szinvonal equ 1	; paletta jobboldalt
_idozit equ 1		; refresh varakozas
_kockak equ 1		; kiskepek jobbra
_gyorskockak equ 1	; kiskepeken minden pixelt csak 1x (sokat szamit!)
_cpu equ 586		; cmov/salc +oldas. meret ugyanaz, cmov hajlekonyabb
_szoveg equ 1		; szoveg... vajon mi is lenne ez...?

; --------- init, palettabeallitas, tablageneralas (256*256 g”mb) ---------
; ------------ gl”b”csk‚k startpozicioinak eloallitasa (random) -----------
start:
	fninit
	mov al,13h
	int 10h

%if _szoveg!=0
	mov ah,9
	mov dx,szoveg1
	int 21h
%endif

;	mov cx,1111	; ezt nemertem de most epp nem zavarja a mozgast
	mov ch,6fh	; minden gepen legyen szurke is... + szegmens!
	mov fs,cx
pal:
	mov dx,3c8h	; 3
	mov ax,cx	; 2
	out dx,al	; 1
	inc dx		; 1
	xor al,0x3e
;	shr al,1
	out dx,al	; 1
	out dx,al	; 1
	lea eax,[eax*4+ecx]
	out dx,al	; 1
	loop pal	; 2

pozgen:
	mov cl,pontdb*2 		; ez a random resz
	mov di,pontok
@rndcik:
	imul ax,di
	inc ax
iezer:	push ax
	and ax,127			; x/y koordinata <128
	stosw
	pop ax
	cbw
	or ah,dh			; dh=3 (palset ota) -> gl”b”k 1 resze
	mov [di+pontdb*4-2],ah		; 3x sebesseg
	loop @rndcik

tabla:
	push fs
	pop es
@tablax:
	movsx ax,ch
	mov [si],ax			; SI korrekt 100h ertek! (elvileg)
	fild word [si]			; x
	mov ax,cx
	cbw
	mov [si],ax

	fmul st0			; x2
	fild word [si]			; x2 y
	fmul st0			; x2 y2
	faddp st1			; xy
;	fsqrt
;	fdivr dword [ezer-2]
	fidivr dword [iezer]

;	fsqrt
;	fsqrt
;	fimul word [w256]

	fistp word [si]
	mov al,[si+1]
	stosb				; letaroljuk =)
	loop @tablax

%if _textura=2 ; ------------- texturageneralas! ----------------

	mov ah,58h
	mov es,ax
	mov gs,ax
@txcyc:
;	mov al,cl
;	xor al,ch
;	mul cx			; tatvas textura...
	mov bx,cx
	shl bx,2
	mov al,[fs:bx]
	shr al,2
	stosb
	loop @txcyc
%endif
; ---------- ez a kirajzolo resz, a tablabol eloszedett adatokkal --------

	push word 0xA000
	pop es
frame:
	mov si,pontok
	xor di,di
	mov bp,HEIGHT		; Y
@MYcik:
	mov dx,WIDTH		; X
@MXcik:
	push si
	mov cl,pontdb
	xor ax,ax
@MPcik:
	push ax
	mov bx,bp
	lodsw			; ld X
	sub bx,ax
	lodsw			; ld Y

	shl bx,8
;	mov bh,bl		; ferdegl0b0k =)))
	sub bx,ax

	pop ax
	add bx,dx

	add al,[fs:bx]
%if _cpu=686
	cmovc ax,sp		; lasd font (main komment)
%else
	jnc @nsat
	salc
%endif
@nsat:
	loop @MPcik

	cmp al,60		; 180 (mivan?)
	jg @rajz
%if _cpu=686
	cmovnc ax,si		; fullkozep: cx: sszurke, si: vszurke, sp: kek
%else
	jc @nerajz
	mov ax,si
%endif
	jmp @nerajz
@rajz:
%if _textura=0
	add ax,bp
	xor ax,dx
%else
	mov bx,bp
	mov bh,dl
	add bl,al
%if _textura=2
	mov al,[gs:bx]
%else
	shl bx,2
	mov al,[fs:bx]
	shr al,2
	add al,28
%endif
%endif
@nerajz:
	stosb

%if _kockak!=0
%if _gyorskockak!=0
	test bp,3
	jnz @netobbet
	test dx,3
	jnz @netobbet
%endif
	pusha
	mov cl,2
	shr bp,cl
	mov bx,dx
	shr bx,cl
	imul di,bp,320
	lea di,[bx+di+10*320+240-10]

	inc cx
@kockaloop:
	add al,64
	stosb
	add di,64*320-1+11
	loop @kockaloop
	popa
%endif

@netobbet:
	dec dx			; X++
	pop si
;	mov si,pontok
	jnz @MXcik

;ezer:
%if _szinvonal=0
	add di,byte 320-WIDTH
%else
	mov ax,bp
	mov cx,(320-WIDTH)>>1
	rep stosb
	mov cx,(320-WIDTH)>>1
	xor al,80h
	rep stosb
%endif

	dec bp			; Y++
	jnz @MYcik

; ----------------- mozgato resz ------------------
; si-t megkapja az elozobol

;icdc:	dec byte [iezer]
;	jnz @nemnott
;	xor byte [icdc+1],0xE-6
@nemnott:

	mov cl,pontdb*2
mozgat:
	lodsw			; X
	add al,[si+pontdb*4-2]
	mov [si-2],ax
	cmp al,WIDTH-10
	jna @nxinv
	neg word [si+pontdb*4-2]
@nxinv:
	loop mozgat

%if _idozit!=0
	mov dx,0x3da
@timeloop:
	in al,dx
	test al,8
	jz @timeloop
;;	hlt
%endif

	in al,60h
	dec ax			; ax koordinatat tartalmaz, ami 200 korul
	jnz near frame		; van vagva, tehat ah=0!

	mov al,3
	int 10h

	ret

;ezer dd 8000000.0		; 8M
;ezer dw 0x4AF4 		; ez ugy kb 8.005M
;ezer dd 200000.0

;w256	dw 333

%if _szoveg=1
szoveg1 db 9,9,9,9,'gl0bchen$'
%endif