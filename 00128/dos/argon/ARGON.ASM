ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ
;        ммммммммм     А ммммллллм
;        мммммлллл ллллпп  ллллллп   мммммммм      мммммм    лллллмммм
;  мммлллл    ллллнллллн   оллллмллллл   ллллн ммллл   ллллм ллллн   ллллммм
; ллллллл     олллполллп       лллллл    олллпллллл     ллллнолллп    ллллллл
;ллллллВн  a  ллллнллллл   r  оллллВн  g ллллллллВн  o  оллллллллн  n  Влллллл
; ллллллл     оллл оллл        лллллл    олллнллллл     лллллоллл     ллллллл
;  ллллллл    ллллнллллн       плллллл   ллллн ллллл   ллллл ллллн   ллллллл
;       ппппп ллллппппп            Бпппппллллл    ппппппппА  пппп   пппппп
;               А              млллллпппппппп <HK>
;                              Вппппп
;
;                    FULL SOURCE-CODE TO THE 128-BYTE DEMO
ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ
;                      Copyright (C) 1997 Matrix Software
ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ
;                                code .Insomniac
ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ
;           Read MATRIX.NFO for further info about the demo+source.
ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ
code	SEGMENT
	ASSUME	cs:code
	.386

ORG	100h

Start:	mov	al,13h			; enter world of graphics!
	int	10h


ФФФФФФФФФФФФФФФФФФФФ
; CALCULATE SINE/COS - VALUES (Wally/Rage)
ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ
	mov	cx,783Fh		; don't ask me, I just use it..
	xor	si,si
plc1:	mov	ax,65497
	imul	cx
	add	si,dx
	add	cx,si
	mov	[bx],ch
	sar	byte ptr [bx],1
	dec	bx
	cmp	bx,16383
	jne	plc1

	inc	bx			; BX points to the sine/cos-values

	push	0a000h			; play around with the segments
	pop	es
	push	es
	pop	ds

ФФФФФФФФФФФФФФФФФФФФ
; DRAW THE PLASMA-CURVES (Blue,Red)
ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ
	xor	di,di		; the beginning is a good place to start ;)
	xor	cx,cx
plc2:	mov	[di],ch
	mov	[di+380],ch
	mov	si,381
	sub	si,di
	mov	[si],ch
	mov	[si+380],ch
	add	di,3
	inc	ch
	cmp	ch,64			; are we crossing eachother?
	jnz	plc2

	xor	si,si			; set a nice palette
	mov	dx,3c8h
	out	dx,al
	inc	dx
	mov	cx,256*3		; R,G,B - values
	rep	outsb
	push	cs			; could be usefull..
	pop	ds

plc3:	inc	dx
	mov	cl,200			; yes Max-Y = 200..
	xor	di,di

plc4:	mov	bl,cl
	add	bl,dl
	mov	dh,[bx]
	xor	ch,ch
	mov	bl,dh

plc5:	mov	al,[bx]
	sub	al,cl
;	mov	ah,al
cbw
	add	ah,dh
	sub	ax,cx
	test	cl,1
	jz	plc6

	xchg	ah,al
plc6:	stosw				; Use this since we have overlapping
	inc	bl
	inc	ch
	cmp	ch,160		; since we use STOSW, we only need 320/2
	jc	plc5
	dec	cl
	jnz	plc4

;	in	al,60h			; cheap isn't it! But I couln't
;	dec	al			; afford having these 11 bytes :(
	jmp	plc3

;	mov	ax,3
;	int	10h

;	int	20h

code	ENDS
	END	Start