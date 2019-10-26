;The Matrix Text Scroller
;Coded by G3 (tgm80@mail.ru)
;tasm /m task.asm
;tlink /x /3 /t task.obj
.model tiny
.386
.code

ScreenWidth	equ	80
ScreenHeight	equ	25
YMess		equ	(ScreenHeight-8)/2

		org 100h
Start:
		push	0B800h
		pop	es				;es = screen
		push	0F000h
		pop	ds				;ds = fonts

		push	di				;initial seed for random number generator

		mov	dh,25
		mov	ah,02h
		int	10h				;hide cursor
		
		mov	ch,ScreenHeight*ScreenWidth/256
		rep	stosw				;set attribute of all symbols to 02h
		
MainLoop:


;Move all rows down

		std				
		mov	si,(ScreenHeight-1)*ScreenWidth*2-2
		mov	di,ScreenHeight*ScreenWidth*2-2
L10:
		movs	byte ptr es:[di], byte ptr es:[si]
		dec	di
		dec	si		
		jns	L10


;Fill top row with random symbols

L20:
		cwd
		pop	ax
		add	al,ah
		xchg	al,ah
		push	ax
		shr	al,4

		add	al,'0'
		cmp	al,'9'
		jna	L30
		add	al,'A'-'9'-1
L30:
		stosb
		dec	di
		jns	L20
		cld


;Delay 1/18 seconds

		xor	ax,ax	
L40:	
		int	1Ah			
		cmp	dx,bp
		je	L40
		mov	bp,dx


;Go to next position in message

		inc	bx
		cmp	bx,(EndMess-Message)*8
		jne	L50
		xor	bx,bx
L50:


		mov	cx,8
		mov	di,YMess*ScreenWidth*2+1
L60:

;Move message left

		mov	al,ScreenWidth-1
		lea	si,[di+2]
L70:
		movs	byte ptr es:[di], byte ptr es:[si]
		inc	di
		inc	si		
		dec	ax
		jne	L70


;Read symbol image in font table (F000:FA6E) and write to screen

		pusha
		push	bx
		shr	bx,3
		mov	bl,cs:[bx+offset Message]
		shl	bx,3
		sub	bx,cx
		mov	al,[bx+0FA6Eh+8]
		pop	cx
		and	cl,07h
		inc	cx
		shl	al,cl
		popa
Message:

		mov	al,0Fh
		jc	L80
		mov	al,02h
L80:
		stosb
		inc	di
		loop	L60
	

		in	al,60h
		dec	al
		jnz	MainLoop		;while al<>ESC

		mov	al,03h
		int	10h			;clear screen

		int	20h			;exit
		


		db	20h,48h,69h,20h,4Eh,65h,6Fh,2Eh,20h,47h
		db	6Fh,20h,74h,6Fh,20h,70h,6Ch,61h,79h,20h
		db	77h,69h,74h,68h,20h,74h,68h,65h,20h,77h
		db	68h,69h,74h,65h,20h,72h,61h,62h,62h,69h
		db	74h,2Eh,20h,41h,6Eh,64h,20h,66h,6Fh,72h
		db	67h,65h,74h,20h,61h,62h,6Fh,75h,74h,20h
		db	74h,68h,65h,20h,48h,75h,67h,69h,20h,43h
		db	6Fh,6Dh,70h,6Fh,2Eh,20h,59h,6Fh,75h,20h
		db	68h,61h,76h,65h,20h,6Eh,6Fh,20h,63h,68h
		db	61h,6Eh,63h,65h,73h,20h,74h,6Fh,20h,77h
		db	69h,6Eh,20h,68h,65h,72h,65h,2Eh,20h,52h
		db	75h,75h,64h,2Eh,20h

EndMess:

end Start

