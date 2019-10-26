;-----------------------------------------------------------
;
; TRON - LightCycles - 2player only.... (AI? yeah, right!)
;
; Keys: (make sure numlock is on, and capslock is off)
;
;         P0    P1
;
; up      A     6
; down    Z     3
; left    X     1
; right   C     2
;
; Rules: first to crash loses.
;
; (going back on yourself constitutes a crash!)
;
; Coded in 45 minutes on 23/03/95 by C.H.Skilbeck (henry@prog.demon.co.uk)
;
;-----------------------------------------------------------

b	equ	byte ptr
w	equ	word ptr
s	equ	short

cseg	segment	byte

	assume	cs:cseg,ds:cseg,es:nothing,ss:cseg

	org	100h

start:	mov	ax,13h	;320x200x256
	int	10h

	mov	es,cs:scrnseg	;es->screen

	sub	bx,bx
	mov	cx,320
	mov	ax,cx
@@box:	mov b	es:[bx],3
	mov b	es:[bx+64000-320],3
	inc	bx
	loop	@@box

	sub	bx,bx
	mov	cx,200
@@box1:	mov b	es:[bx],3
	mov b	es:[bx+319],3
	add	bx,ax
	loop	@@box1

@@loop:	mov	ah,1
	int	16h	;key there?
	jz s	@@nok
	sub	ah,ah
	int	16h	;get it

	mov	bx,p0vel	;change p0 velocity
	cmp	al,'a'
	jne s	@@na
	mov	bx,-320
@@na:	cmp	al,'z'
	jne s	@@nz
	mov	bx,320
@@nz:	cmp	al,'x'
	jne s	@@nx
	mov	bx,-1
@@nx:	cmp	al,'c'
	jne s	@@nc
	mov	bx,1
@@nc:	mov	p0vel,bx

	mov	bx,p1vel	;change p1 velocity
	cmp	al,'6'
	jne s	@@na1
	mov	bx,-320
@@na1:	cmp	al,'3'
	jne s	@@nz1
	mov	bx,320
@@nz1:	cmp	al,'1'
	jne s	@@nx1
	mov	bx,-1
@@nx1:	cmp	al,'2'
	jne s	@@nc1
	mov	bx,1
@@nc1:	mov	p1vel,bx

@@nok:	mov	bx,p0
	mov b	es:[bx],1	;trail p0
	add	bx,p0vel	;move p0
	mov b	al,es:[bx]	;collision detect p0
	or	al,al
	jnz s	@@p0dies
	mov b	es:[bx],15	;plot p0
	mov	p0,bx

	mov	bx,p1
	mov b	es:[bx],2	;trail p1
	add	bx,p1vel	;move p1
	mov b	al,es:[bx]	;collision p1
	or	al,al
	jnz s	@@p1dies
	mov b	es:[bx],15	;plot p1
	mov	p1,bx

	call	waitvb

	jmp	@@loop	;loop

@@p0dies:	mov	bl,1	;p0 dies
	jmp s	@@fla

@@p1dies:	mov	bl,2	;p1 dies

@@fla:	mov	cx,50
@@show:	mov	dx,03c8h	;fade colour of dead player
	mov	al,bl
	out	dx,al
	inc	dx
	mov	al,cl
	out	dx,al
	out	dx,al
	out	dx,al
	call	waitvb
	loop	@@show

@@exit:	mov	ax,3	;back to text mode
	int	10h

	ret

waitvb:	push	dx
	mov	dx,3dah
@@w1:	in	al,dx
	test	al,8
	jnz s	@@w1	;Waitvb
@@w2:	in	al,dx
	test	al,8
	jz s	@@w2
	pop	dx
	ret


scrnseg	dw	0a000h	;screen seg address

p0	dw	32010	;p0 addr
p0vel	dw	1	;p0 vel

p1	dw	32000+309	;p1 addr
p1vel	dw	-1	;p1 vel

cseg	ends

	end	start
