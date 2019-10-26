;ROUTINEN:
;BITMOVE: 	schiebt balken um [balken_speed] pixel nach links
;COPY_BALKEN:	copiert balken (ohne zu l”schen) nach [Balken_Dest]
;FRAME:		

.286
.model small
.stack 100h
assume cs:code,ds:data



code	segment

;vars:
balken_dest	dw	0	;destination in bildschirm
balken_merk1	db	0	;hier wird immer [speed]geaddet wenn 8
				;neuer buchstabe
balken_speed	db	1	;anzahl der pixel nach links
text_adr	dw	0	;zeiger auf buchstaben im text_seg
text_neW	dw	0

text_seg dw	seg text
fnt_seg	dw	seg font
pic_seg	dw	seg pic
dat_seg	dw	seg data
bs_seg	dw	0a000h

;******************************************************************************
start:		cli

	;modus setzen
		mov	ax,12h
		int	10h


	;setze pallette
		mov	ax,seg data
		mov	es,ax
		mov	dx,offset pal
		sub	bx,bx		;erste farbe
		mov	cx,16
		mov	ax,1012h
		int	10h



		mov	ax,0a000h
		mov	es,ax

	;enable set/reset auf 0 sseten
		mov	dx,3ceh
		mov	ax,1
		out	dx,ax

	;read und write 0
		mov	ax,5
		out	dx,ax

		
	;map mask
		mov	dx,3c4h
		mov	ax,102h
		out	dx,ax

		mov	ax,seg pic
		mov	ds,ax

		sub	si,si
		sub	di,di
		mov	cx,480*80
		rep	movsb


	;font rummoven
	;map mask
		mov	dx,3c4h
		mov	ax,202h
		out	dx,ax
	
		mov	ax,seg data
		mov	ds,ax
		mov	di,[position]
		add	word ptr [position],81
		mov	ax,seg font
		mov	ds,ax
	;es noch da....
		call	raster
		sub	si,si
		mov	cx,80*20
		rep	movsb	
	

wait_1:		call	raster
		call	frame


wait_key:	in	al,60h
		dec	al
		jne	wait_1

exit:		mov	ax,3
		int	10h
		sti
		mov	ax,4c00h
		int	21h

;2.5.93*************************************
frame:		mov	al,byte ptr cs:[balken_speed]
		add	byte ptr cs:[balken_merk1],al
		call	bitmove
		cmp	byte ptr cs:[balken_merk1],16	;breite eines letters
		jne	frame_jmp1			;muuáá 16 werden!!!!
		call	letter
		and	byte ptr cs:[balken_merk1],7
frame_jmp1:	call	copy_balken
		add	word ptr cs:[balken_dest],80
		ret


;2.5.93**************************************
;copiert balken nach es:dest
;es,ds:new
copy_balken:	mov	es,word ptr cs:[bs_seg]
		mov	ds,word ptr cs:[dat_seg]

		mov	bh,18		;h”he

		mov	di,word ptr cs:[balken_dest]
		mov	si,offset balken
cb_lop1:	mov	cx,40
		rep	movsw
		add	si,10
		dec	bh
		jne	cb_lop1
		ret






;*******************************************
raster:		mov	dx,3dah
		mov	ah,8
raster_1:	in	al,dx
		and	al,ah
		je	raster_1
		ret


;*******************************************
;routine ,welche speicherblock mit l„nge cx um bl bits nach links schiebt
;schieben des 18*80-byte balkens um cl nach links

bitmove:        mov	cl,byte ptr cs:[balken_speed]
		mov	ds,word ptr cs:[dat_seg]

		mov	di,offset balken
		mov	si,offset balken+1

		mov	bh,18		;H™HE
shl_lop_2:	mov	bl,45		;l„nge einer zeile/2


	;vorbereiten
		mov	al,[di]
		shl	al,cl

	;schleife
shl_lop_1:	mov	dl,[si]

		sub	dh,dh
		shl	dx,cl

		add	al,dh
		mov	[di],al
		add	di,2

		mov	al,[di]
		sub	ah,ah
		shl	ax,cl

		add	dl,ah
		mov	[si],dl
		add	si,2

		dec	bl
		jne	shl_lop_1		

		dec	bh
		jne	shl_lop_2
		RET



;2.5.93***LETTER**************************************+
letter:		mov	bx,word ptr cs:[text_adr]
		mov	es,word ptr cs:[tExt_seg]
		mov	al,es:[bx]
		mov	es,word ptr cs:[fnt_seg]
		mov	ds,word ptr cs:[dat_seg] 
		inc	bx
		mov	word ptr cs:[text_adr],bx
		or	al,al
		jne	letter_jmp1
	;text von vorne
		MOV	AX,word ptr cs:[TeXT_NEW]
		mov	word ptr cs:[text_adr],AX
		jmp	letter_jmp6

letter_jmp1:	cmp	al,1
		jne	letter_jmp2
	;speed up------------
		cmp	byte ptr cs:[balken_speed],8
		je	letter_jmp6
		shl	byte ptr cs:[balken_speed],1 
letter_jmp6:	mov	al,20h
		jmp	letter_jmp5

letter_jmp2:	cmp	al,2
		jne	letter_jmp5
	;speed down----------------
		cmp	byte ptr cs:[balken_speed],1
		je	letter_jmp6
		shr	byte ptr cs:[balken_speed],1
		jmp	letter_jmp6

letter_jmp5:	mov	ah,al
		mov	si,offset alpha
		mov	cx,55		;anzahl der zeichen im alphabet
		sub	bl,bl		;offset des zeichens im alp.
letter_lop1:	lodsb
		cmp	ah,al
		je	letter_jmp7
		inc	bl
		loop	letter_lop1
		mov	bl,0
	;in bl steht der offset
letter_jmp7:	sub	di,di		;adr. zeichen
		cmp	bl,39		;anzahl der zeichen pro 320 pixel breite
		jbe	letter_jmp8
		add	di,80*18	;h”he der zeichen
letter_jmp8:	sub	bh,bh
		shl	bx,1		;breite 2byte
	;in bx steht offset		
		add	bx,di			;zeilen beachten
		mov	si,bx
;*****schreiben des ges. buchstabens*******
		mov	di,offset balken+64
		add	di,200
		mov	bl,18			;h”he
letter_lop2:	mov	ax,es:[si]
		mov	[di],ax
		add	si,80
		add	di,90
		dec	bl
		jne	letter_lop2
		mov	es,word ptr cs:[bs_seg]
		ret





code	ends


data	segment
position dw 0
pal:
include pal.dat

BALKEN	DB 90*20 DUP (0)

alpha	db" ABCDEFGHiJKL                                "

data	ends

pic	segment
include convert.dat
pic	ends






font	segment
;16*16 pixel 2*8 byte pro buchtabe (40 buchstaben nebeneinander)
include	font.dat
font	ends


text	segment
db "ABCDEF",1,"DWDWXWEFIO",1,"JIOJPWIUJIOSOWMOI",2,2,0

text	ends





end start