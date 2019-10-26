
		.386
		Ideal
		Jumps
                Model   Tiny
                CodeSeg
                org     100h
                StartupCode

bufferheight    = 59

; Define this to show the 'FAJASTATAH'-logo
picture         = 1

; Define this to use the cooltextmode... :)
;cooltextmode	= 1

;----------------------------------------------------------
; Set screenmode (mode 13h)
;----------------------------------------------------------
randseed:	mov	al,13h
		int	10h

;----------------------------------------------------------
; SetPalette
;----------------------------------------------------------
		mov	di,offset palette

		xor	ax,ax
		mov	cl,18*3/2
		rep stosw

		mov	cl,63
sp_loop2:
		stosw
		mov	[di],bh
		inc	al
		inc	di
		loop	sp_loop2

		mov	cl,63
sp_loop3:
		stosw
		mov	[di],bh
		inc	ah
		inc	di
		loop	sp_loop3

		mov	cl,256-64-64-16
sp_loop4:
		stosw
		mov	[di],bh
		inc	di
		loop	sp_loop4

		mov	ax,1012h
		mov	ch,1
		mov	dx,offset Palette
		int	10h

;----------------------------------------------------------
; Stretch the screen
;----------------------------------------------------------
		mov	dx,3D4h
		mov	al,9
		out	dx,al
		inc	dx
		in	al,dx
		and	al,not 10011111b
                or      al,07h
		out	dx,al

		mov	bh,0A0h
		mov     es,bx

;----------------------------------------------------------
; SmoothBuffer
;----------------------------------------------------------
loop1:

		mov	cx,bufferheight
		mov	si,offset OffScreen
sb_loop1:
		call	GetRandom
		sar	dx,14
		mov	bx,dx

		xor	dl,dl

		push	cx
		mov	cl,160
sb_loop2:
		xor	ax,ax
                mov     al,[bx+si+160-1]
                add     al,[bx+si+160]
	       	adc	ah,dl
                add     al,[bx+si+160+1]
		adc	ah,dl
                add     al,[bx+si+320]
		adc	ah,dl

                sub     ax,8
		jns	sb_notneg
		xor	ax,ax
sb_notneg:
		shr	ax,2
                mov     [si],al
		inc	si
		loop	sb_loop2
		pop	cx
		loop	sb_loop1

IFDEF picture
;----------------------------------------------------------
; DisplayPic
;----------------------------------------------------------
		mov     cl,5
		mov	si,offset fajastatah
		mov	di,320*40 + 160-80
		xor	dx,dx
dp_loop1:
		push	cx
		mov	cl,5
dp_loop2:
		push	cx
		lodsb
		mov	cl,8
dp_loop3:
		shl	al,1
		jnc	dp_nope
		mov	[es:di],edx
dp_nope:
		add	di,4
		loop	dp_loop3

		pop	cx
		loop	dp_loop2

		add	di,320-160
		pop	cx
		loop	dp_loop1

ENDIF

;----------------------------------------------------------
; GenerateFire
;----------------------------------------------------------
		mov	ch,2h		;mov cx,160*2
		mov	si,offset NewBuffer
gf_loop1:
		call	GetRandom
		mov	[si],dl
		inc	si
		loop	gf_loop1

;----------------------------------------------------------
; Waitbeam
;----------------------------------------------------------
		mov	dx,3DAh
wb_loop1:
		in	al,dx
		test	al,8
		jz	wb_loop1

;----------------------------------------------------------
; CopyBuffer
;----------------------------------------------------------
		mov	ch,25h			;160*bufferheight + noe
		xor	di,di
 		mov	si,offset OffScreen
cb_loop1:
		lodsb
		mov	ah,al
		stosw
		loop	cb_loop1

                in      al,60h
		cmp	al,01h
                jne     loop1
quit:
IFDEF cooltextmode
		xor	ah,ah
ELSE
		mov	ax,3
ENDIF
                int     10h

Proc		GetRandom
                mov     ax,[word RandSeed]
		mov	dx,8405h
		mul	dx
		inc	ax
                mov     [word RandSeed],ax
		ret
EndP		GetRandom


IFDEF picture

fajastatah	db	11101110b,00101110b,11101110b,11101110b,11101010b
		db	10001010b,00101010b,10000100b,10100100b,10101010b
		db	11001110b,00101110b,11100100b,11100100b,11101110b
		db	10001010b,10101010b,00100100b,10100100b,10101010b
		db	10001010b,11101010b,11100100b,10100100b,10101010b

ENDIF

palette:
		org	$+256*3
offscreen:
		org	$+160*bufferheight
newbuffer:
		org	$+160*2
		end


