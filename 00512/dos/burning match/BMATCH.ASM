
.model tiny

dataseg
palette db 100h*3h dup(?)	;palette table
random dw ?			;variable to store pseudo-random numbers

codeseg
org 100h

.startup

;***************************************************************
;*** enter mode 320x200x256 ************************************
;***************************************************************

entry:
	mov ax,13h		;self-explanatory
	int 10h

;***************************************************************
;*** wait 3600/65536*10 (~0.5) seconds to prevent sudden exit **
;***************************************************************

	push 40h
	pop es
	mov bx,es:[6ch]		;save time stamp in bx
wait1:
	mov ax,es:[6ch]		;get time in ax
	sub ax,bx		;how much?
	cmp ax,10		;have 10 ticks?
	jb wait1

;***************************************************************
;*** create palette ********************************************
;***************************************************************

	mov si,offset palette
	xor bx,bx
	xor ax,ax
	mov dx,3f3fh
	mov cx,40h


	fillpalette:
		mov [si+3h*00h+bx+0h],bl	;flame - red component
		mov [si+3h*00h+bx+1h],ax	;flame - green & blue components

		mov [si+3h*40h+bx+0h],dl	;flame - red component
		mov [si+3h*40h+bx+1h],bl	;flame - green component
		mov [si+3h*40h+bx+2h],al	;flame - blue component

		mov [si+3h*80h+bx+0h],dx	;flame - red & green component
		mov [si+3h*80h+bx+2h],bl	;flame - blue component

		mov [si+3h*0c0h+bx+0h],bl	;wood & sulfur - red component
		mov [si+3h*0c0h+bx+1h],bl	;wood & sulfur - green component
		mov [si+3h*0c0h+bx+2h],bl	;wood & sulfur - blue component
		shr byte ptr [si+3h*0c0h+bx+2h],1
		add si,2
		inc bx
	loop fillpalette
	mov ax,1012h			;set palette function
	push ds
	pop es				;palette table segment
	mov dx,offset palette		;palette table offset
	xor bx,bx			;first register to set
	mov cx,100h			;number of registers to set
	int 10h

;***************************************************************
;*** init values ***********************************************
;***************************************************************

	push 0a000h
	pop es				;video segment
	mov random,8540			;variable to store pseudo-random numbers
	mov si,1h			;end of flame
	mov dx,0c0deh			;fast stage of burning

;***************************************************************
;*** make sulfur & wood ****************************************
;***************************************************************

	mov di,(100+32)*320+160-24	;start of wood
	mov al,0dfh			;fresh sulfur
	mov cx,48			;match length
	@@wood:
		cmp cx,44               ;sulfur or wood?
		ja @@skip8
		mov al,0ffh		;fresh wood
		@@skip8:
		mov es:[di],al
		mov es:[di+320],al
		inc di
	loop @@wood

;***************************************************************
;*** main loop *************************************************
;***************************************************************

again:

	;*******************************************************
	;*** start flame ***************************************
	;*******************************************************

		mov di,(100+32)*320+160-24

		cmp si,48		;end reached?
		je @@skip1

		cmp es:[di],dl          ;fast/slow stage of burning
		jne @@skip7		;fast
		mov dx,0800h            ;slow

		@@skip7:
		call Rnd		;generate random in [0..65535] range
		cmp random,dx		;sometimes...
		ja @@skip1
		inc si			;... move flame end to the right
		@@skip1:
		call Rnd		;generate random in [0..65535] range
		mov cx,si
		@@flame:
			cmp byte ptr es:[di],0c8h
			jna @@skip2
					mov al,7fh		;create flame near match with initial intensity of 7fh
					mov es:[di-320],al

					cmp random,2000h        ;sometimes...
					ja @@skip2a

					dec byte ptr es:[di]	;... waste some sulfur/wood, man!
					dec byte ptr es:[di+320]
					jmp @@skip2a
			@@skip2:
			xor al,al
			mov es:[di-320],al
			@@skip2a:
			inc di
		loop @@flame

	;*******************************************************
	;*** develop flame *************************************
	;*******************************************************

		xor bx,bx
		mov di,(100+32-1)*320+160-24
		mov cx,64
		@@ver:
			push cx
			mov cx,2*48
			@@hor:


				mov al,es:[di]		;fire intensity at (x,y) -> al
				call Divideby3          ;divide al by 3
				add bl,al		;increment fire intensity at (x-1,y-1) by al
				shr bl,1		;divide fire intensity at (x-1,y-1) by 2...
							;...to waste some energy for burning oxygen and for radiation of light
				@@skip5:
				mov es:[di-320-1],bl	;update intensity at (x-1,y-1)

				mov bl,bh		;stored fire intensity at (x,y-1)
				add bl,al		;increment fire intensity at (x,y-1) by al

				mov bh,es:[di-320+1]    ;store fire intensity at (x+1,y-1) in bh
				add bh,al               ;increment fire intensity at (x+1,y-1) by al
				inc di
			loop @@hor
			sub di,320+2*48			;return
			pop cx
		loop @@ver
		in al,60h				;key pressed?
		das
	jc again

;***************************************************************
;*** leave mode 320x200x256 ************************************
;***************************************************************

	mov ax,3h               ;self-explanatory
	int 10h

;***************************************************************
;*** bye bye ***************************************************
;***************************************************************

	ret

;***************************************************************
;*** pseudo-random numbers generator ***************************
;***************************************************************

rnd:
	push ax
	push dx
	mov ax,25173
	mul random
	add ax,13849
	mov random,ax
	pop dx
	pop ax
	ret

;***************************************************************
;*** divide al by 3 ********************************************
;***************************************************************

divideby3:
	push bx
	xor ah,ah
	mov bl,3
	div bl
	pop bx
	ret

;***************************************************************
;*** this space was intentionally left blank :) ****************
;***************************************************************

end
