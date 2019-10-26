
org 0x100
use16

; 72 = up, -82
; 75 = left, -4
; 77 = right, 0
; 80 = down, 78

up_key: 	scasb		  ; up arrow value
		int	10h
left_key:	cld		  ; left arrow value
right_key:	push	0xB800	  ; 0 is right arrow value
		inc	di	  ; di = 0
down_key:	dec	si	  ; down arrow value

		pop	es
		;xchg    ax,bp
		;xor     bp,bp


		int	0x1A
		xchg	ax,bp	  ; bp = 0
		inc	dx

score:		mov	si,0	  ; zeroize si, score
		mov	cx,40*25*2 - 2
		mov	fs,cx


		jmp	add_food

		; bp = dir
		; fs:bx = head
		; fs:si = tail
		; cx = 1998
		; dl = time

main_loop:
		mov	ax,es
		push	di
		mov	di,word [fs:si]
		stosb
		stosb
		cmpsw	; si += 2
		pop	di

		add	di,bp
		cmp	di,cx
		ja	exit_point
		mov	word [fs:bx],di
		inc	bx
		inc	bx

		cmp	ah,[es:di+1]
		stosw
		ja	no_eat
		je	exit_point

add_food:
		dec	si
		dec	si
		pusha
		mov	di,score+1
		mov	bx,word [di]
		inc	word [di]
		mov	di,cx

score_loop:

		shr	bx,1
		mov	ax,es
		adc	al,'0'
		stosw
		sub	di,82
		jns	score_loop

try_place:
		in	ax,40h
		add	ax,ax
		cwd
		div	cx
		mov	di,dx
		cmp	word [es:di],sp
		jl	try_place
		mov	ah,0xCF ; must be > 0xB8
		stosw
		popa

no_eat:
delay:
		cmp	dl,[gs:0x46C]
		jne	delay
		add	dl,4

		mov	ah,1
		int	0x16
		jz	main_loop
		cbw
		int	0x16
		movzx	bp,ah
		movsx	bp,byte[bp+0x100-72]
		cmp	al,0
		je	main_loop
exit_point:
		ret


