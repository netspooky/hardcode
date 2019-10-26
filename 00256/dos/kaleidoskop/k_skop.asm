;
;       KaleidoSkop by bEETLE.3sc
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Dokoncil bEETLE dna 23 marca roku pane 2000
;
;Mail : nemecekm@decef.elf.stuba.sk
;
;
;         P O Z O R ! ! !
;
;     compilujte IBA pod nasm !!! (www.web-sites.co.uk/nasm/)
;
;Srdecna vdaka :
;      BAZEmu za optimalizaciu
;      LovCovi za to iste
;
;
[org 100h]


start		mov	ax,13H
		int	10h
		mov     ah,4Ah
		mov     bh,020h
		int     21h
		jnc     pokra
		ret
	
pokra		xchg	ax,cx
palloop		mov	dx,3c8h
		mov	al,cl
		out	dx,al
		inc	dx
		shr	al,1
		out	dx,al
		mov	al,cl
		out	dx,al
		shr	al,2
		out	dx,al
		loop	palloop

		mov	di,data
creloop		call	rnd
		stosw
		xor	ax,ax
		stosw
		call	rnd
		and	ah,0eh
		add	ah,2
		stosd
		dec	dx
	        jnz	creloop

		mov     ax,cs
		add     ah,16
		mov     fs,ax
		push	word 0a000h
		pop	es

hloop		mov     dx,03DAh
FRAM		in      al,dx
		and     al,8
		jz      FRAM


zoom		mov	bp,[data+8*4+88]	;48]	;32]
		sar	bp,4	;4
		mov	ah,128
		imul	si,bp,100
		add	si,ax
		imul	dx,bp,160
		add	dx,ax

		mov	ah,200
		xor	di,di
ylooop		mov	cx,320
		push	dx
xlooop		mov	bx,si
		mov	bl,dh
		mov	al,[fs:bx]
		stosb
		sub	dx,bp
		loop	xlooop
		pop	dx
		sub	si,bp
		dec	ah
		jnz	ylooop
				
		xor	di,di
clloop		mov	[fs:di],ah
		inc	di
		jnz	clloop



obrloop		mov	ax,[pozx]
		mov	al,[pozy+1]
		or	al,al
		xchg	ax,bx
		mov	al,[colo+1]
		jns	nicnebude
		cmp	bh,bl
		jnc	ajustbude
nicnebude	xor	bx,bx
		salc
ajustbude	mov	ah,4
		mov	si,bp
		add	bp,cx
		ror	bp,cl
		and	si,BYTE 060h			;pocet
		mov	di,pozx
vycoloop	mov	[fs:bx],al
		xchg	bl,bh
		mov	[fs:bx],al
		not	bl
		mov	dx,[si+data]
		add	dh,128
		add	dx,[di]
		rcr	dx,1
		mov	[di],dx
		inc	di
		inc	di
		add	si,BYTE 8
		dec	ah
		jnz	vycoloop
		loop	obrloop
		mov	ch,4
		mov	si,cx
rotloop		mov	di,[si+4]
		lodsw
		imul	di
		add	dx,[si]
		mov	[si],dx
		xchg	ax,dx
		imul	di
		sub	[si-2],dx
		add	si,BYTE 6
		loop	rotloop	
		

		in	al,60h
		dec	al
		jnz	NEAR hloop

ENDPR		mov     ax,03h
		int     10h


rnd		mov	ax,27533	;27533;27533;19833
		imul	ax,10217	;17217;17217;09657
		add	ax,11749	;11749;17749;09643
		mov	[rnd+1],ax
		ret


pozx            equ	1024-8
pozy		equ	1024-6
colo		equ	1024-4
data		equ	1024






