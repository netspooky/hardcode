;----------------------------------------------------------------
;a little intro-source-code from 	dr.lazy (lkcc berlin)
;----------------------------------------------------------------
;this is the source-code to the 500-bytes mini-intro for our
;whq the skylight bbs
;to get the com-file.. just assemble with tasm 3.x and link with
;tlink 3.xx /t -> see ade.bat
;i hope you can learn something from this too bad-commented (i think)
;source-code.. (sorry for my evil English-knowledge..)
;I though, that it can't be bad to release some sources in order
;to give some others the possibily of learning assembler-coding..
;(just to rot out turbo-pascal.. >|-)  )
;----------------------------------------------------------------
;ok, let's do something do something for friendships:
;I which to send some greets out to...
;	!twin		-hope to c u one day
;	hetero		-draw some more fonts/make some trains for ct
;	mad danger	-hope you can learn s.th. from that
;	xxs		-erm.. what to say...
;	ds		-make some more comments in ur asms!
;	toxic trancer	-don't forget mayday VI.. 
;			-hehe, nice idea to give you the source.. hehe..
;more greets to...
;mrb,tga,ren,elias,baco,roy,g.s.,brayn o'neal,stone,mixx,dasa,lion,...
;and perhaps YOU.. if you don't forget to contact me.. hehe..
;----------------------------------------------------------------
;erm.. if you use some procs or if even learn s.th. from this
;just give me credits by greeting (or giving access in berlin
;elite boards... hehe..) ok.. be seing ya..
;----------------------------------------------------------------
;ok.. let's start with the code..
;----------------------------------------------------------------
;a first tip.... (for real wisdom..)
;if you really wanna understand this prog turn down the speed
;of your pc, and put a ";" before the lines bordered with ";<-" & ";->" 
;then u even might press pause and see what happen =|-) (nice smile,twin..)
;the best way to learn how it works is to make the exe-file by
;starting ade2.bat... it will assmbl and link with full comments, so that
;you can use borlands genial Turbo-debugger to step it through (in the
;source-code).. just try F3 (open module)
;but be careful.. it's a exe-file without stack.. may cause probs..
;-----------------------------------------------------------------

.286					;268-code-possible
.model small				;memory-model for tasm

assume cs:code				;just one segment -> for com-file

code	segment				;open segment
org	100h				;for com-file

h”he		equ	19		;hight of the skylight (SLs)
breite		equ	4		;erm.. width of the... sls

w_h”he		equ	8		;hight of one cube of the big sl
w_breite	equ	8		;width of one cube

;----------------------------------
;start... with code.. (entry-point)
;----------------------------------
start:
	;<-------------------------------------------------
		cli		;no key-beeping & pause
	;------------------------------------------------->
		mov	ax,13h	;grafic-mode 13h
		int	10h

	;-----------------------------
	;clear pal.
	;---------
		mov	di,offset pal	;offset of pal
		sub	al,al		;al=byte to store
		mov	cx,768		;length of pal
		rep	stosb		;do it (es is ok..)

		mov	si,offset pal	;just shorter that push&pop :-)

	;<--------------------------------------------------
		call	set_pal		;put pal to vga (black to forbit
					;seeing how it works... :-)
	;--------------------------------------------------->

		push	0a000h		;es to vga-mem
		pop	es

	;-----------------------------------
	;make small skylights (SLs)
	;---------------
		mov	di,5*320		;desti in vga-mem
		mov	cl,200/h”he		;how many to one screen
prsm_lop_5:	mov	si,offset graf		;datas for sls

		mov	bh,h”he			;hight..
prsm_lop_4:	mov	ch,320/(8*breite)	;how many to one line

prsm_lop_3:	mov	bl,breite		;draw one
prsm_lop_2:	mov	ah,8			;because bits..
		mov	al,[si]			;get data
prsm_lop_1:	rol	al,1			;get bits
		jnc	prsm_jmp_1
		mov	byte ptr es:[di],1	;if bit was set
prsm_jmp_1:	inc	di			;next pixel in vga-mem
		dec	ah			;next bit
		jne	prsm_lop_1		;8 bits..

		inc	si			;next data
		dec	bl			;the width of one sl
		jne	prsm_lop_2

		sub	si,breite 		;adjust source-datas-pos
						;(to draw one sl-line
						;320/breite times..)
		dec	ch			;320/breite..
		jne	prsm_lop_3

		add	si,breite		;next line of the sl-datas
		dec	bh			;dec hight in lines
		jne	prsm_lop_4
		
		dec	cl        		;do it so that the whole screen
						;is filled
		jne	prsm_lop_5


	;-------------------------------
	;draw the big skylight
	;-----------
		mov	di,20*320		;dest. in vga-mem

		mov	cl,8			;superimpsitions (german: šberlagerungen)

prbig_lop_6:	push	cx			;keep
		mov	si,offset graf		;source-datas of sl
		mov	ch,h”he			;hight
prbig_lop_5:	push	di			;keep vga-mem-position
		mov	bh,breite		;the width of the sl
prbig_lop_4:	mov	bl,8			;bits
		mov	al,[si]			;get the byte

prbig_lop_3:	mov	dl,cl			;get cl as color for cube

		rol	al,1			;get bits
		jc	prbig_jmp_1		;draw it!!
	;------------------------
	;draw one cube
	;---------
		sub	dl,dl			;draw no cube (color 0)
prbig_jmp_1:	mov	dh,w_h”he		;highth of the cube
prbig_lop_2:	mov	ah,w_breite		;width of the cube

prbig_lop_1:	add	byte ptr es:[di],dl	;put color to vga-mem
		inc	di			;next pixel
		dec	ah			;width..
		jne	prbig_lop_1

		add	di,320-w_breite		;adjust vga-mem-position
		dec	dh			;hight..
		jne	prbig_lop_2

		sub	di,w_h”he*320-w_breite-2;adjust vga-mem-position to
						;next cube

		dec	bl			;8 bits..
		jne	prbig_lop_3

		inc	si			;next source-data-byte
		dec	bh			;width of the sl
		jne	prbig_lop_4

		pop	di         		;
		add	di,(w_h”he+1)*320	;adjust vga-mem-pos to next big line
		dec	ch			;hight..
		jne	prbig_lop_5

		sub	di,(h”he*(w_h”he+1))*320-1-320
						;adjust vga-mem-pos for next
						;superi...
		pop	cx			;restore counts for superi..
		dec	cx			;dec for lop..
		jne	prbig_lop_6

	;----------------------------------------
	;smoothly fill the rest of the vga-mem
	;-----------------------
		sub	di,di			;again vga-mem-pos
		mov	bl,1			;start-color
fill_2:		mov	cx,320			;pixels per line
fill_1:		cmp	byte ptr es:[di],1	;already used?
		jne	jmp4			;yes!!

		mov	ax,cx			;fill it vertical..
		shr	ax,1
		mov	byte ptr es:[di],al
		jmp	jmp5

jmp4:		add	es:[di],bl		;fill it horizontal
jmp5:		inc	di			;next pixel
		loop	fill_1			;320 pixels per line..

		inc	bl			;200 lines per screen..
		cmp	bl,201
		jne	fill_2

		push	cs			;make es:=ds
		pop	es

;-------------------------------
;make the scrolling
;-------------

	;---------------------------
	;random-values
	;----------
		mov	cx,3			;3 times for red,green,blue
		mov	di,offset graf		;use graf as mem.. (save bytes.. hehe)
		sub	ah,ah                   ;becaus STOSWord
zufall1:	in	al,40h			;get random-values
		add	al,40			;prevent too lame scrolling
		stosw				;put it there..
		stosw
		loop	zufall1			;3 times...

;--------------------------------------
;scrol colors until esc was pressed
;----------------------
key_wait:
	;-------------------------
	;scroll pallette
	;-----------
		mov	cx,768-3		;3*100h-3 because not color 0
		mov	si,offset pal+3 	;source
		mov	di,offset pal		;dest
		rep	movsb			;do it..

	;----------------------------
	;set last color new
	;----------
		mov	cl,3			;red,green,blue
		mov	di,offset pal+768-3	;last color
		mov	si,offset graf		;randon values

ch_lop1:	mov	ax,[si]			;get random
		or	ax,ax			;positive or negative
		jns	jmp_nc			;jump if pos.

		add	[si+2],ax		;chg color with random-add
		jc	jmp_3			;values to low?
		neg	word ptr [si]		;negate random-add
		sub	[si+2],ax		;chg color with random-add again (to adjust it)
		jmp	jmp_3

	;positiv..
jmp_nc:		add	[si+2],ax		;chg color with random-add
		cmp	[si+2],3e00h		;bigger that highest color?
		jb	jmp_3			;jump if not..
		neg	word ptr [si]		;negate random-add..

	;very clever lines :-] ,try to understand them..
jmp_3:		add	si,3			;next random-values
		movsb				;put color to pal

		dec	cl			;3 times..
		jne	ch_lop1

	;wait for vbl (for soft-scrolling)
		MOV	AH,8
		MOV	DX,3DAH
	RAST1:	IN	AL,DX
		and	AL,AH
		JE	RAST1

		mov	si,offset pal
		call	set_pal			;put pal to vga...

		in	al,60h			;esc pressed??
		dec	al
		jne	key_wait	

		mov	ax,3			;normal text-video-mode
		int	10h
		mov	ah,9			;put end-text
		mov	dx,offset text
		int	21h

		sti				;don't know if neccessary
		int	20h			;to dos
						;not with mov ax,4c00h/int21
						;because it's a com-file

;--------------------------------------------
;put pal to vga
;-------------------
set_pal	       proc	near
		mov	cx,300h-3	;ds:si & cli
		mov	al,1
setcx:		mov	dx,3c8h
		out	dx,al
		inc	dx
		rep	outsb
		ret
set_pal         endp

;======================================================
;datas
;==================================

;------------------------
;the end-msg
;----------
text:
db 10,10,10
db"			this file was leeched",13,10
db"			from THE SKYLIGHT bbs",13,10
db"			      >lKCc< WHQ",13,10
db"			 code m8 by DR.LAZY$"

;-----------------------------
;sl source-datas (binar)
;----------------
graf:
db 00000111b,11100110b,01100110b,01100000b
db 00000110b,00000110b,11000110b,01100000b
db 00000111b,11100111b,10000111b,11100000b
db 00000000b,01100110b,11000000b,01100000b
db 00000111b,11100110b,01100111b,11100000b
db 00000000b,00000000b,00000000b,00000000b
db 01100000b,11011111b,10110011b,01111110b
db 01100000b,11011000b,00110011b,00011000b
db 01100000b,11011001b,10111111b,00011000b
db 01100000b,11011001b,10110011b,00011000b
db 01111110b,11011111b,10110011b,00011000b

DB 00000000b,00000000b,00000000b,00000000B
DB 00000011b,11100111b,11000111b,10000000B
DB 00000011b,00110110b,01101100b,00000000B
DB 00000011b,11100111b,11000111b,10000000B
DB 00000011b,00110110b,01100000b,11000000B
DB 00000011b,11100111b,11001111b,10000000B

pal:
db	768 dup (?)			;? because only reservate the bytes..

code	ends				;close segment
end	start				;begin execution by label start