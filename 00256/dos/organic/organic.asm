;
;                  ||>
;              <<>=||\=<<¿=||\=||\|=||=<<
;
;1nf0:0ffhByt31ntr0NA5M(puM1n8086;]
;
;					..by Assembler !30T
;assembler_bot@hotmail.com   http:\\assemblerbot.home.sk
;2001

[org 100h]
[segment .text]

MAX_Y equ 255-32
MIN_Y equ 205-32
ROT_KAMERA equ 4

start:
	mov al,13h
	int 10h

;nastavenie farieb
	mov al,03fh ;farby
dalsia_farba:
	mov dx,3c8h
	out dx,al
	inc dx
	out dx,al
	xor al,63
	out dx,al
	xor al,63
	out dx,al
	dec al
	jns dalsia_farba

;rendering
	mov bx,ROT_KAMERA
next_frame:
	push bx
	mov bx,MAX_Y	;delta Y
delta_Y:
	mov di,halda
	mov si,[KameraY]
vektor_Y:
	mov cx,160
	call pries
	add ax,[KZ] ;bp teraz obsahuje Z priesecniku s rovinou
	call upravaf
	mov bp,ax
	mov cx,[KameraX]
vektor_X:
	call pries
	add ax,[KX] ;ax teraz obsahuje X priesecniku s rovinou
	call upravaf

;)
	push bp
	mul al
	push ax
	mov ax,bp
	mul al
	mov bp,ax
	pop ax
	add ax,bp
	shr ax,4

	cmp al,63
	jbe bez_korekcie
	neg al
	add al,127
bez_korekcie:

	pop bp

;ulozenie pixelu
	cmp bl,MAX_Y
	je skip_if

	mov ah,MAX_Y+32
	sub ah,bl
	cmp al,ah
	jae skip_if
max_y_nav:
	inc di
	jmp short skip_stos
skip_if:
	stosb
skip_stos:

	inc cx
	cmp cx,[KameraX1]
	jl vektor_X
	inc si
	cmp si,[KameraY1]
	jl vektor_Y

	sub bl,3		;speed
	cmp bl,MIN_Y
	ja delta_Y

;copy virtual screenu
	mov ax,0a000h
	mov es,ax
	xor di,di
	mov si,halda
	mov ch,32000/256
	rep movsw
	push cs
	pop es

	pop bx

;uprava kamery
	sub byte [KX],16
	add byte [KZ],24

	mov di,KameraX
	mov cx,4
add_kamera:
	add [di],bx
	inc di
	inc di
	loop add_kamera

	dec di
	dec di
	cmp word [di],-240
	jg kamera_2
	neg bx
kamera_2:
	cmp word [di],20
	jl kamera_3
	neg bx
kamera_3:


;klavesnica
	mov ah,1
	int 16h
	jnz exit
	jmp next_frame

exit:
	mov ax,03h
	int 10h
	int 20h

;fcie

pries:
;<bx=delta Y
; si=vektor Y
; cx=vektor X
	push dx
	push si
;korekcia na nekonecno
	cmp si,2
	jge skip_core
	cmp si,-2
	jle skip_core
	mov si,bx
skip_core:
	mov ax,bx
	imul cx
	idiv si
	pop si
	pop dx
	ret

upravaf:
;uprava farieb .. resp suradnice pre farbu
	shr ax,2
	and al,63
	sub al,32
	jns upravaf_skip_neg
	neg al
upravaf_skip_neg:
	jz upravaf_ret
	dec al
upravaf_ret:
	ret

;premenne
KameraX dw -160	;vektory kamery - zaciatok
KameraX1 dw 160	;vektory kamery - koniec
KameraY1 dw 100
KameraY dw -100

KX dw 0				;suradnice kamery
KZ dw 0
halda:
