;/* tab-size is 4!
;
; what to say...
;
; it could be optimized at least 500 bytes and made so much faster..
; but you know, the deadline eh... and we were also in a hurry ofcourse..
; anyway, some guys asked for it so i just compiled the whole bunch
; together into a zip.. here it is. don't expect much!!
;
; it's a dead old effect with some basic gus routines. gus-init is not really
; 100% .. gus-routines can be optimized with inc dx, inc dx in stead of just
; loading the registers from a datablock. this will gain about 150 bytes of
; code, but with packing with wwpack the file gets 50 bytes larger in stead
; of 50 bytes smaller... :(
;
; maybe we should have done envinronment checking instead of hardware testing
; maybe we should have done GUSRampVolume() in stead of looping GUSSetVolume()
; maybe we had better not spread the source
; maybe you learn something from it
; maybe you just rip or copy it saying it is yours
; maybe we have done the same if you know the gus development kit
; maybe you're right...
;
; btw: have you noticed the intro is only 2745 bytes?!
;      and oh... this version has a little bug. ;')
;
; þ Troop/Chiparus þ bluenose@pi.net þ
; þ Blue Nose Productions þ ++31-(0)345-619401 þ
; þ Demos-Sources-Chiptunes þ

;----------------------------------------------------------------------------

			ideal
			dosseg
			p386
			model	large
			stack	1024

ADDV1		=	-1
ADDV2		=	2
ADDV3		=	-2
ADDV4		=	-3

ADDH		=	-3
ADDH2		=	2
ADDH3		=	1
ADDH4		=	3

;----------------------------------------------------------------------------

dataseg

label		VSine
			include "sine.inc"
label		Font
			include "font.inc"

Text		db	"BLUE#NOSE#PRODUCTIONS",13
			db	93,"+31-345-619401",13
			db	104,"CHIPARUS#WHQ",13
			db	40,13
			db	45,"DEMOS-SOURCES-CHIPTUNES",0
TextPos		dw	0
TextX		dw	62
TextY		dw	16

FontTable	dw	000,000,000,000,000,000,000,000,000,000,138,000,147,000,000
			dw	156,165,000,172,181,190,199,000,000,208,000,000,000,000,000,000
			dw	000,000,009,018,027,036,000,000,045,054,000,000,059,217,066,075
			dw	084,093,102,111,120,129,000,230,000,000,000,000,000,000,000,000
FontWidth	dw	002,003,006,006,006,006,006,006,006,006,009,006,009,006,006
			dw	009,007,006,009,009,009,009,006,006,009,006,006,006,006,006,006
			dw	006,009,009,009,009,009,009,009,009,005,009,009,007,013,009,009
			dw	009,009,009,009,009,009,009,013,009,009,009,006,006,006,006,006

Message		db	"Intro by Troop & Kr'33",13,10,10
			db	"þ Blue Nose Productions þ +31-345-619401 þ",10,13
			db	'$'

tabel		db	10,0
			db	20,48
			db	20,0
			db	20,48
			db	20,0
			db	20,48
			db	20,0
			db	20,48
			db	20,0
			db	20,48
			db	10,0
			db	0

CoolPalette	db	0,0,0
			db	34,26,34
			db	63,63,63
			db	00,00,00
			db	38,30,38
			db	34,26,34
			db	00,00,00
			db	00,00,00
			db	00,00,00
			db	00,00,00
			db	00,00,00
			db	00,00,00
			db	00,00,00
			db	00,00,00
			db	00,00,00
			db	00,00,00
			db	00,00,00
			db	00,00,00
			db	00,00,00
			db	00,00,00
			db	42,34,42
			db	38,30,38
			db	00,00,00
			db	00,00,00
			db	00,00,00
			db	00,00,00
			db	00,00,00
			db	00,00,00
			db	63,63,63
			db	55,55,55
			db	00,00,00
			db	00,00,00
			db	34,26,34
			db	00,00,00
			db	00,00,00
			db	00,00,00
			db	00,00,00
			db	00,00,00
			db	00,00,00
			db	00,00,00
			db	00,00,00
			db	00,00,00
			db	00,00,00
			db	00,00,00
			db	00,00,00
			db	00,00,00
			db	00,00,00
			db	00,00,00
			db	49,49,53

i			dw	0
j			dw	0
k			dw	0
l			dw  0
j2			dw	0
i2			dw	0
k2			dw	0
l2			dw	0

HSine		dw	256 dup (?)
Block		db	32000 dup (?)
palette		db	150 dup (63)
Vol			dw	40000

ends

;----------------------------------------------------------------------------

segment		BUFFER

Virt		dd	16000 dup (?)

ends

;----------------------------------------------------------------------------

codeseg
assume		cs:@code,ds:@data,es:nothing,fs:nothing,gs:nothing

proc		main

			push	ds
			mov		ax,@data
			mov		ds,ax
			call	InitSound

			mov		cx,256/4
			xor		si,si
			mov		di,126

@@makesin:	mov		bx,si
			add		bx,128
			mov		ax,[VSine+bx]
			mov		bx,di
			mov		[VSine+bx],ax
			mov		dx,ax
			mov		ax,400
			sub		ax,dx
			add		bx,256
			mov		[VSine+bx],ax
			mov		bx,si
			add		bx,384
			mov		[VSine+bx],ax

			inc		si
			inc		si
			dec		di
			dec		di

			loop	@@makesin

			mov		cx,256
			xor		bx,bx
@@lp:		mov		ax,[VSine+bx]
			push	ax
			push	cx
			mov		cx,5
			xor		dx,dx
			idiv	cx
			mov		[HSine+bx],ax
			pop		cx
			pop		ax
			shr		ax,2
			mov		[VSine+bx],ax
			add		bx,2
			loop	@@lp

			mov		ax,013h
			int		10h
			call	SetPalette

			mov		ax,seg Virt
			mov		es,ax
			mov		di,offset Virt
			mov		cx,64000/4
			mov		eax,004040404h
			cld
			rep		stosd

			call	MakeZebra
			call	Writer

			mov		cx,64
@@fade:		push	cx
			call	Retrace
			call	FadeIn
			call	VertSinus
			call	HorSinus
			call	Flip
			call	LoopSound

			add		[Vol],1200
			cmp		[Vol],60000
			jbe		@@go
			mov		[Vol],60000
@@go:		mov		bx,[Vol]
			mov		ax,1
			call	SetVolume
			mov		bx,[Vol]
			mov		ax,2
			call	SetVolume
			pop		cx
			loop	@@fade

@@WaitKey:	call	Retrace
			call	VertSinus
			call	HorSinus
			call	Flip
			call	LoopSound
			mov		ah,01h
			int     16h
			jz      @@WaitKey

			mov		cx,34
@@fado:		push	cx
			call	Retrace
			call	FadeOut
			call	FadeOut
			call	VertSinus
			call	HorSinus
			call	Flip
			call	LoopSound
			sub		[Vol],600
			mov		bx,[Vol]
			mov		ax,1
			call	SetVolume
			mov		bx,[Vol]
			mov		ax,2
			call	SetVolume
			pop		cx
			loop	@@fado

			call	Ginit

			mov		ax,03h
			int		10h
			mov     AH,00h
			int     16h
			mov		dx,OFFSET Message
			mov		ah,9
			int		21h
			pop		ds
			mov     AX,04C00h
			int     21h
			ret
endp

;----------------------------------------------------------------------------

proc		SetPalette		near

			push	cx

			xor		bx,bx
			mov		cx,49*3

			cli
			mov		dx,03c8h
			xor		ax,ax
			out		dx,al
			inc		dx
@@wp:   	mov		al,[palette+bx]
			out		dx,al
			inc		bx
			loop	@@wp
			sti
			pop		cx
			ret
endp
;----------------------------------------------------------------------------

proc		FadeIn		near

			mov		cx,150
			xor		bx,bx
@@lp1:		mov		al,[palette+bx]
			cmp		[CoolPalette+bx],al
			je		@@ok
			dec		al
			mov		[palette+bx],al
@@ok:   	inc		bx
			loop	@@lp1
			call	SetPalette
			ret
endp

;----------------------------------------------------------------------------

proc		FadeOut		near

			mov		cx,150
			xor		bx,bx
@@lp1:		mov		al,[palette+bx]
			cmp		al,0
			je		@@ok
			dec		al
			mov		[palette+bx],al
@@ok:   	inc		bx
			loop	@@lp1
			call	SetPalette
			ret
endp

;----------------------------------------------------------------------------

proc		Retrace		near

			push	dx
			push	ax
			mov		dx,03dah
@@ws:		in		al,dx
			and		al,08h
			jnz		@@ws
@@we:		in		al,dx
			and		al,08h
			jz		@@we
			pop		ax
			pop		dx
			ret
endp

;----------------------------------------------------------------------------

proc		Flip		near

			pusha
			push	ds
			mov		ax,0a000h
			mov		es,ax
			mov		ax,seg Virt
			mov		ds,ax
			xor		di,di
			xor		si,si
			cld
			mov		cx,16000
			rep		movsd
			pop		ds
			popa
			ret
endp

;----------------------------------------------------------------------------

proc		VertSinus		near

			pusha

			mov		ax,seg	Block
			mov		es,ax
			mov		di,offset Block
			mov		cx,32000/4
			mov		eax,004040404h
			cld
			rep		stosd

			mov		ax,ds
			mov		es,ax

			add		[i],ADDV3
			and		[i],255
			add		[k],ADDV4
			and		[k],255

			mov		ax,[i]
			mov		[j],ax
			mov		ax,[k]
			mov		[l],ax
			xor		si,si

@@drawon:	add		[j],ADDV1
			and		[j],255
			add		[l],ADDV2
			and		[l],255

			mov		bx,[j]
			shl		bx,1
			mov		ax,[word VSine+bx]
			mov		bx,[l]
			shl		bx,1
			add		ax,[word VSine+bx]
			shr		ax,1

			mov		bx,ax
			shl		bx,7
			shl		ax,5
			add		bx,ax

			add		bx,si
			add		bx,offset Block

			mov		cx,100
			mov		dh,1
@@l2:		mov		[es:bx],dh
			add		bx,160
			loop	@@l2

			inc		si
			cmp		si,160
			jne		@@drawon

			popa
			ret
endp

;----------------------------------------------------------------------------

proc    	HorSinus		near

			pusha
			push	fs

			mov		ax,seg Virt
			mov		es,ax
			mov		di,offset Virt
			mov		cx,64000/4
@@f1:		mov		eax,[es:di]
			and		eax,0fcfcfcfch
			mov		[es:di],eax
			add		di,4
			loop	@@f1

			mov		ax,BUFFER
			mov		fs,ax
			mov		ax,ds
			mov		es,ax

			add		[i2],ADDH3
			and		[i2],255
			add		[k2],ADDH4
			and		[k2],255

			mov		ax,[i2]
			mov		[j2],ax
			mov		ax,[k2]
			mov		[l2],ax
			xor		si,si

@@drawon:	mov		bx,[j2]
			shl		bx,1
			mov		ax,[word HSine+bx]
			mov		bx,[l2]
			shl		bx,1
			add		ax,[word HSine+bx]
			shr		ax,1
			mov		bx,ax

			mov		ax,160
			mul		si
			add		bx,ax
			add		bx,ax
			add		bx,40

			add		ax,offset Block
			mov		di,ax

			mov		cx,40
			mov		dx,4
@@l1:		mov		eax,[es:di]
			or		[fs:bx],eax
			add		bx,dx
			add		di,dx
			loop	@@l1

			add		[j2],ADDH
			and		[j2],255
			add		[l2],ADDH2
			and		[l2],255

			inc		si
			cmp		si,200
			jne		@@drawon

			pop		fs
			popa
			ret
endp

;----------------------------------------------------------------------------

proc		Writer			near

@@again:	mov		bx,[TextPos]
			mov		al,[Text+bx]
			cmp		al,13
			je		@@endl
			cmp		al,0
			je		@@endt
			cmp		al,'#'
			je		@@mat
			mov		di,[TextX]
			mov		si,[TextY]
			xor		bx,bx
			mov		bl,al
			call	PrintChar
			inc		[word TextPos]
			jmp		@@again
@@endl:		add		[word TextY],32
			inc		bx
			xor		ax,ax
			mov		al,[Text+bx]
			mov		[word TextX],ax
			inc		[word TextPos]
			jmp		@@net
@@mat:		add		[word TextX],6
@@net:		inc		[word TextPos]
			jmp		@@again
@@endt:		ret
endp

;----------------------------------------------------------------------------

proc		PrintChar		near

			pusha
			push	es

			mov		ax,si
			shl		si,8
			shl		ax,6
			add		si,ax
			add		di,si

			mov		ax,BUFFER
			mov		es,ax

			sub		bx,33
			shl		bx,1
			mov		si,[FontWidth+bx]
			add		bx,offset FontTable
			mov		bx,[ds:bx]
			add		bx,offset Font

			mov		cx,30
@@cvert:	push	cx
			push	bx
			push	di
			mov		cx,si
@@cline:	mov		al,[ds:bx]
			shl		al,2
			or		[es:di],al
			inc		bx
			inc		di
			loop	@@cline
			pop		di
			pop		bx
			pop		cx
			add		bx,243
			add		di,320
			loop	@@cvert

			inc		si
			add		[word TextX],si

			pop		es
			popa
			ret

endp

;----------------------------------------------------------------------------

proc		MakeZebra		near

			push	es
			mov		ax,seg Virt
			mov		es,ax
			xor		bx,bx
			mov		si,0
			mov		di,280

@@fill3:    xor		cx,cx
			mov     cl,[tabel+bx]
			cmp		cl,0
			je		@@ende
			inc		bx
			mov		ah,[tabel+bx]
			mov		al,[tabel+bx]
			inc		bx

@@fill2:	push	cx
			mov		cx,20
@@fill1:	stosw
			mov		[es:si],ax
			inc		si
			inc		si
			loop	@@fill1
			add		di,280
			add		si,280
			pop		cx
			loop	@@fill2
			jmp		@@fill3
@@ende:		pop		es
			ret
endp

ends

;----------------------------------------------------------------------------

include "gus.asm"

;
; En nu belle he!?
;

end
