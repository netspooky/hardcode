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
pontok equ 2E2h		; adatterulet eleje + random-befolyasolo - eleg bonyi
			; szabalyok befolyasoljak h milyen ertekkel nez ki jol
			; a cimek es koordinatak signed/unsigned dolgai + oian
			; szepen kilovik 1mast :) nincs is szukseg masra
pontdb equ 9

_szinvonal equ 0
_idozit equ 0
_kockak equ 1
_gyorskockak equ 0

; --------- init, palettabeallitas, tablageneralas (256*256 g”mb) ---------
; ------------ gl”b”csk‚k startpozicioinak eloallitasa (random) -----------
start:
	fninit
	mov al,13h
	int 10h

;	mov cx,1111	; ezt nemertem de most epp nem zavarja a mozgast
	mov ch,1	; minden gepen legyen szurke is...
pal:
	mov dx,3c8h	; 3
	mov ax,cx	; 2
	out dx,al	; 1
	inc dx		; 1
	add al,0x10	; 2
	out dx,al	; 1
	out dx,al	; 1
	das		; 1
	out dx,al	; 1
	loop pal	; 2

pozgen:
	mov cl,pontdb*2			; ez a random resz
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
	mov ah,70h			; es itt a tablazat generalasa
	mov es,ax
	mov fs,ax
	xchg ax,si			; jo lesz nekunk az adatszegmens kozepe
@tablax:
	push cx
	movsx ax,ch
	mov [si],ax
	fild word [si]			; x
	xchg ax,cx
	cbw
	pop cx
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

; ---------- ez a kirajzolo resz, a tablabol eloszedett adatokkal --------

	push word 0xA000
	pop es
frame:
	mov si,pontok
	xor di,di
	mov bp,HEIGHT			; Y
@MYcik:
	mov dx,WIDTH			; X
@MXcik:
	push si
	mov cl,pontdb
	xor ax,ax
@MPcik:
	push ax
	mov bx,bp
	lodsw				; ld X
	sub bx,ax
	lodsw				; ld Y

	shl bx,8
	sub bx,ax
;	shl dx,8
;	add dx,ax

	pop ax
	add bx,dx

	add al,[fs:bx]
	cmovc ax,sp			; lasd font (main komment)
;	jnc @nsat
;	salc
@nsat:
	loop @MPcik

	cmp al,70			; 180
;	jg @rajz
;	salc
	cmovng ax,sp
;	or al,dl
	jmp @nerajz
@rajz:
	add ax,bp
	xor ax,dx
;	add ax,dx
;	xor ax,bp
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
	shr bp,2
	mov bx,dx
	shr bx,2
	imul di,bp,320
	lea di,[bx+di+10*320+240-10]

	mov cx,3
@kockaloop:
	add al,-48
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
;ezer dw 0x4AF4			; ez ugy kb 8.005M
;ezer dd 200000.0

;w256	dw 333