;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; SNAKEY v2.1
;
;	Author:		David Cronin (Silent Avenger [TCS])
;			email:	dcronin@gpu.srv.ualberta.ca
;			irc:	SAvenger
;			www:	http://gpu.srv.ualberta.ca/~dcronin/dcronin.html
;
;	Desc:		1st Place Entry for the 256 Byte Game Competition
;	Date:		03/09/95 - 03/16/95
;
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; -Greetings-
;
;	Silver Conception, ae-, Seks, Fysx, anxiter, Zed
;	All the dudes on #coders, r.g.p, and c.s.i.p.d
;
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; -The Story (or whatever) -
;	After I had completed the initial coding, I had a game that was
;	almost 100 bytes over the size limit and was faced with what I
;	thought was an impossible situation.  Incidently, just a few days
;	early I had bought "The Zen of Code Optimization" by Micheal Abrash.
;	While reading thru this wonderfully written book I came across a
;	point that Abrash made several times and in many differnet ways.
;	This was simply "know exactly what your code is doing" (he didn't
;	say it like that, but you get the idea).  This may seem obvious,
;	and maybe even needless advice, but I was surprised with how bytes
;	I did save with this idea.  For example I found that after getting
;	a key input, bit 7 of "al" should always be clear.  Using this
;	knowledge I could then use save 1 byte by using "cbw" to clear "ah"
;	instead of "xor ah, ah".  Anyways, after spending 4 hours byte
;	chopping and writing this silly story, SNAKEY (who in fact is quite
;	a nice snake) was brought into this world ...
;
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;
;	- I took a special interest in this competition since I had always
;	  optimized my code for speed.  The challenge of size optimization
;	  was something entirely different.
;	- It took about 2 hrs to code the game and create the bitmaps.
;	- Another 4 hrs were spend byte chopping (347 bytes -> 256 bytes)
;	  and debugging. ( $5/6hours = $0.83/hour ... not bad! :))
;	- no 386+ instructions.  I could have saved a few bytes in doing so
;	  but I didn't think that losing 286 support was worth the small gain
;	  (a game like this _should_ run on a 286, right?).
;	- most of the variables are embedded in the code to save space
;	  (self-modifing code is very useful for some applications!)
;	- the (**XX) comments are simply byte counts.
;
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²

	IDEAL				; TASM is way cooler than MASM! :)
	MODEL	TINY
	P286N

; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
ADD_LENGTH		EQU     	16
UP                      EQU             -1
DOWN                    EQU             1
LEFT                    EQU             -100h
RIGHT                   EQU             100h

; --------------------------------
; --- pointers to variables stored as immed values to instructions
jewel_loc		EQU	(offset _jewel_loc+1)		; **2
direction		EQU	(offset _direction+1)		; **2
snake_length		EQU	(offset _snake_length+2)	; **2
tail_index		EQU	(offset _tail_index+1)		; **2
head_index		EQU	(offset _head_index+1)		; **2
last_time		EQU	(offset _last_time+1)		; **2
							; = 12 bytes saved

; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	CODESEG
	ORG     100h
	Start:
	; ------------------------ (**6)
		mov	al, 13h			; set video mode 13h (320x200)
		int	10h
		xor	bp, bp			; bp = actual_length = 0

	; ------------------------ (**3)
	next_frame:
		push	0A000h
		pop	es

	; ------------------------ (**9)
	; --- draw the jewel
		_jewel_loc:
		mov	ax, 441Fh		;[jewel_loc]
		mov	si, offset jewel_c16
		call	put_bitmap

	; ------------------------ (**7)
	; --- do we erase the last section?
		mov	si, offset snake_loc
		_snake_length:

		db	81h, 0FDh		; cmp bp, immed
		dw	2			; [snake_length]
		jbe	short do_head

	; ------------------------ (**??)
	; --- erase the last section of the snake
		_tail_index:
		mov	bx, 2			;[tail_index]
		mov	ax, [si+bx]

		push	es
		pop	ds                      ; ds = 0A000h
		push	si
		mov	si, (320*200)		; es:di -> black data
		call	put_bitmap
		pop	si
		push	cs
		pop	ds			; ds = cs

		call	inc_bx			; add bx, 2
		mov	[word tail_index], bx

		dec	bp                      ; decrease actual_length

	do_head:
	; ------------------------ (**??)
	; --- move the head
		_head_index:
		mov	bx, 0			;[head_index]
		mov	ax, [si+bx]
		_direction:
		add	ax, UP			;[direction]

	; ------------------------ (**8)
	; --- did we hit a wall?
		cmp	ah, 79			; x_max = 320/4 = 80
		ja	short hit_wall
		cmp	al, 49			; y_max = 200/4 = 50
	  hit_wall:
		jae	short exit

	; ------------------------ (**??)
	; --- save the new head location
		call	inc_bx               	; add bx, 2
		mov	[si+bx], ax
		mov	[word head_index], bx
		inc	bp			; increase actual_length

	; ------------------------ (**8)
	; ---- draw new snake part
		pusha				; save: si ax
		mov	si, offset snake_c16
		call	put_bitmap
		popa				; restore: ax si

	; ------------------------ (**??)
	; --- did we get jewel?
		cmp	ax, [jewel_loc]
		jne	short check_collision

	; ------------------------ (**??)
	; --- increase snake length and place new jewel
		add	[word snake_length], ADD_LENGTH
		mov	cx, di			; di = last_time
		rol	cx, cl			; make "random" number
		and	cx, 4F2Fh		;   within screen boundary
		mov	[jewel_loc], cx		; save new jewel location

	; ------------------------ (**17)
	; --- did we hit ourself?
	check_collision:
		mov	bx, [tail_index]
		mov	cx, bp			; cx = actual_length
	  next_loc:
		dec	cx			; are we of length 1?
		jng	short do_delay		; if yes, then skip check
		cmp	ax, [si+bx]		; have we hit ourself?
		je	short exit		; if yes, then exit
		call	inc_bx			; add bx, 2
		jmp	next_loc

	; ------------------------ (**15)
	; --- wait for 1 timer tick to pass (assumes 1 tick = 55ms)
	do_delay:
		push	0
		pop	es
		mov	cx, di
	check_time:
		mov	ax, [es:046Ch]
		mov	di, ax
		sub	ax, cx			; last_time - this_time
		jz	check_time		; has at least 1 tick passed?

	; ------------------------ (**??)
	; --- is there a key in the buffer?
		mov	ah, 1
		int	16h
		jnz	short get_key
		jmp	next_frame

	get_key:
	; ------------------------ (**4)
	; --- get the key
		mov	ah, 0
		int	16h

	; ------------------------ (**??)
	; --- convert the key to a direction
		sub	al, '2'
		cbw				; ah = 0
		mov	bx, ax
		mov	ax, [direction_codes+bx]
		mov	[direction], ax
		jmp	next_frame

	exit:
	; ------------------------ (**6)
	; --- get back in text mode
		mov	ax, 0003h
		int	10h
		ret				; ip = 0

	; ------------------------ (**10)
	; --- (add bx, 2) with upper bounds checking
	inc_bx:
		inc	bx
		inc	bx
		cmp	bh, 04h			; 400h = 1024 (512 is max len)
		jb	short @@bx_ok
		xor	bx, bx
	@@bx_ok:
		ret


	; ------------------------ (**42)
	; --- displays a 4x4 bitmap
	; --- IN: 	ax = loc, ds:si -> bitmap
	put_bitmap:
		push	di
		mov	dx, ax
		shr	dx, 6			; dx = x*4
		cbw				; ah = 0
		imul	di, ax, (320*4)		; di = y*320*4
		add	di, dx			; di = (y*320*4) + (x*4)
		mov	cx, 4			; height = 4
	pb_loop:
		push	di

		mov	dx, 2			; word width = 2
	  unpack:
		lodsb				; get next 2 bytes
		mov	ah, al
		shr	ah, 4			; ah = left byte
		and	al, 0Fh			; al = right byte
		stosw
		dec	dx
		jnz	unpack

		pop	di
		add	di, 320
		loop	pb_loop
		pop	di
		ret


; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; --- data
; the bitmaps are 4x4 in size with each pixels taking 4 bits
snake_c16		db	40,130,226,46,162,46,40,130	;(**8)
jewel_c16		db	196,76,124,207,252,199,196,76	;(**8)
direction_codes		dw	DOWN,LEFT,RIGHT,UP		;(**8)
snake_loc		db 	'!D'	; snake start position	;(**2)
			db	'C'	; dummy filler
			; in memory a large array of locations
			; will follow of the form:
			;   low byte = y coordinate
			;   hi byte  = x coordinate

; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	ENDS

	END START