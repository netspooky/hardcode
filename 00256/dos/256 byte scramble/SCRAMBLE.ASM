; 256 Byte Scramble
;
; Written by Mark Incley



Prog_Version	EQU	"v1.00"


		MODEL	TINY

		CODESEG

		IDEAL

		WARN


SceneryChar	EQU	"þ"
ShipChar	EQU	""
ShipColour	=	7
CaveHeight	=	5

ShipX		=	20

PlayAreaWidth	=	80
PlayAreaHeight	=	25


Gap_Y		=	0
Ship_Y		=	1


		ORG	100h


Go:		mov	ax,3
		int	10h

                ;mov     ah,2ch
                ;int     21h
                ;mov     bp,dx

                xor     bp,bp


; First, fill the screen with caverns (note: the gap stays in centre of
; screen).

		mov  	ax,0b800h		; ES = Screen ptr
		mov	es,ax
		mov	cx,PlayAreaWidth

		mov	bx,OFFSET Vars

@@InitLp:	push	cx
		call	Pan_Screen
		pop	cx
		loop	@@InitLp



Game_Loop:	push	[WORD bx+Gap_Y]

		mov	ah,2
		int	16h

		test	al,100b
		jz	SHORT @@NotDown

		inc	[BYTE bx+Ship_Y]

@@NotDown:	test	al,10b
		jz	SHORT @@StoreCoors

		dec	[BYTE bx+Ship_Y]

@@StoreCoors:	push	ds

		mov	si,40h
		mov	ds,si
		mov	si,6ch
		mov	dx,[si]

@@WaitLp:	cmp	dx,[si]
		jz	@@WaitLp

		pop	ds

		pop	ax
		mov	dl," "
		call	Draw_Ship_AH

		call	Pan_Screen

; ############################## MINE DROPPER ###############################

		mov	ax,bp
		cmp	al,241
		jb	SHORT @@NoMine

		and	al,7
		mov	ah,80*2
		mul	ah
		sub	di,ax
		mov	ax,""+256*4
		stosw

; ###########################################################################

@@NoMine:	mov	dl,ShipChar
		call	Draw_Ship

		cmp	dh,ShipColour
		jnz	SHORT @@Quit

		mov	ax,bp
		sub	al,86
		jc	SHORT @@jmpGameLoop

		mov	ah,1
		sub	al,86
		jc	SHORT @@Add

		neg	ah

@@Add:		add	ah,[bx+Gap_Y]
		jle	SHORT @@JmpGameLoop
		cmp	ah,PlayAreaHeight-6
		ja	SHORT @@JmpGameLoop

		mov	[bx+Gap_Y],ah
@@JmpGameLoop:	jmp	Game_Loop

@@Quit:		int	20h




Draw_Ship:	mov	ah,[bx+Ship_Y]

Draw_Ship_AH:	mov	dh,ShipX*2

Draw_Ship_DH_AH:
		mov	al,2*80
		mul	ah
		add	al,dh
		adc	ah,cl
		mov	si,ax
		mov	dh,ShipColour
		xchg	[es:si],dx
		ret


Pan_Screen:	push	ds

	      	add	bp,7163h		; Update random number seed.
		rol	bp,1
		xor	bp,07f8h

		push	es
		pop	ds

		xor	di,di
		mov	si,2
		mov	cx,(PlayAreaWidth*PlayAreaHeight)-1
		rep	movsw
			
		pop	ds

		mov	ax,bp
		and	ah,7
		or	ah,10000b
		mov	al,SceneryChar
		mov	di,2*(PlayAreaWidth-1)
		push	di

		mov	cl,PlayAreaHeight
		call	@@Sling

		pop	di
			
		mov	al,80*2
		mul	[BYTE bx+Gap_Y]
		add	di,ax

		mov	cl,CaveHeight
		mov	ax," "+256*ShipColour

@@Sling:	stosw
		add   	di,(80*2)-2
		loop	@@Sling
		ret


Vars		db	(PlayAreaHeight/2)-(CaveHeight/2); Gap Y	
		db	PlayAreaHeight/2		 ; Ship Y


		END	Go
