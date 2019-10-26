;          FIRETINY.ASM
; .the quest for the smallest fire.

; Rex Deathstar/WaterLogic, September 1996
; <deathstr@singnet.com.sg>
;
; All comments/suggestions/improvements/chitchat are welcome!
;
; LOG:
; 0x25 Mar 1995 : 900 bytes, 154 bytes, 128 bytes, 100 bytes, 93 bytes!
; 0x28 Mar 1995 : 89 bytes, 85 bytes, 84 bytes!
; 0x29 Mar 1995 : 78 bytes, 76 bytes!
; 0x29 Jun 1995 : 75 bytes!
; 0x03 Sep 1996 : 57 bytes! (Hi Wili! :)

; Greetings to Dune/Orange, Gaffer and many others whom I forgot (sorry!)
; for their lovely effort in this tinyfire quest :)

.MODEL TINY
.386

.CODE
.STARTUP

	push	0a000h
	pop   es
	push  es
	pop	ds		; since no variables used...how convenient!

        mov   al,13h    ; the legacy mode : 320x200x256
	int   10h

MainLoop:
	mov   si,320	; screen width
	mov   ch,7dh	; 320x100 = 32000 = 0x7D00 -> lower byte is null

	push	si
	push	cx

	xor di,di

smoothloop:
	lodsb
	add   al,[si]
	add   al,[si+319]
	add   al,[si-2]
	shr   al,2

	and	al,0Fh	; colors 16...31 is a little grayscale region in standard
	add	al,10h	; VGA 256-color palette ;)

	stosb
	loop	smoothloop

	pop	di		; di = cx = 32000
	pop	cx		; cx = si = 320

randline:
        in      al,40h  ; lame random numbers with no mathematical background ;)
	stosb
	loop	randline

        in      al,60h
	das
	jc   	MainLoop

Bye:
	mov     ax,3
	int     10h
	ret

END

