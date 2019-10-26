;---[ TLT.ASM ]----------------------------------------------------------------


;==============================================================================
;
; Tiny Land Thingy ... Ansi/Adlib ... Sound-system by Chicken (=HSCtracker 1.0)
; The Picturez are not included ... 2 bad
;
; Included aRe:
;
; TLT.COM -------> The end-result Of This piece Of ShiT
; TLT.ASM -------> Source (this ThiNg!)
; TLT_SND.OBJ ---> Da Sounds (HSCtrackerz TECHNO)
; TLT_SYS.OBJ ---> Da SoundSystem (HSCOBJ v1.0)
; TINYLAND.STX --> Will B created while running da MEGA-PARTED-WINNING-DEMO
;
; Do all except lame ...
;
;==============================================================================


extrn music
extrn hscplayer:far


.model small
.stack 400h

;---[ DATA ]-------------------------------------------------------------------

.data

promp	db'C:\>$'
f1	db'f$'
o1	db'o$'
r1	db'r$'
m1	db'm$'
a1	db'a$'
t1	db't $'
c1	db'c$'
c2	db':',13,10,10
	db'$'
se	db'SùNTAX error',13,10
	db'$'
@ss	db'System crashed'
	db'$'
@@1     label byte			; Yeah Sure!...Piccy By Piccy
        include 001.ASM
        @@1lng=$-offset @@1
@@2     label byte
        include 002.ASM
	@@2lng=$-offset @@2
@@3     label byte
        include 003.ASM
        @@3lng=$-offset @@3
@@4     label byte
        include 004.ASM
        @@4lng=$-offset @@4
@@5     label byte
        include 005.ASM
        @@5lng=$-offset @@5
@@6     label byte
        include 006.ASM
        @@6lng=$-offset @@6
@@7     label byte				; I hate iT!!!
        include 007.ASM
        @@7lng=$-offset @@7
@@8     label byte
        include 008.ASM
        @@8lng=$-offset @@8
@@9     label byte
        include 009.ASM
        @@9lng=$-offset @@9
@10     label byte
        include 010.ASM
        @10lng=$-offset @10
@11     label byte
        include 011.ASM
        @11lng=$-offset @11
filen	db"TinyLand.stx",0			; Create a Ascii thing
text	label byte
	include text.dat
einde	label byte
lengte	equ einde - text


;---[ CODE ]-------------------------------------------------------------------


.code

		mov	ax,@data		; Put .Data in AX
		mov	ds,ax
		mov	ds,ax
		mov	ah,3ch
		mov	cx,0
		mov	dx,offset filen
		int	21h
		jc	error1
		mov	bx,ax
		mov	ah,40h
		mov	cx,lengte
		mov	dx,offset text
		int	21h
		mov	ah,3dh
		int	21h
error1:		mov	ax,3
		int	10h
		mov	ah,4
		call	hscplayer		; No SoundCard?
		jc	nosoundz		; Jump To NOSOUNDZ
		mov	ax,seg music
		mov	es,ax
		mov	si,offset music
		xor	bl,bl
		mov	ah,bl
		call	hscplayer
nosoundz:	mov	dx,offset promp		; Here starts Da LAME-Typing
		mov	ah,9			; EffEcT ... I hate it!
		int	21h
		mov	cx,20
		call	retrace
		mov	dx,offset f1
		mov	ah,9
		int	21h
		mov	cx,20
		call	retrace
		mov	dx,offset o1
		mov	ah,9
		int	21h
		mov	cx,20
		call	retrace
		mov	dx,offset r1
		mov	ah,9
		int	21h
		mov	cx,20
		call	retrace
		mov	dx,offset m1
		mov	ah,9
		int	21h
		mov	cx,20
		call	retrace
		mov	dx,offset a1
		mov	ah,9
		int	21h
		mov	cx,20
		call	retrace
		mov	dx,offset t1
		mov	ah,9
		int	21h
		mov	cx,20
		call 	retrace
		mov	dx,offset c1
		mov	ah,9
		int	21h
		mov	cx,30
		call	retrace
		mov	dx,offset c2
		mov	ah,9
		int	21h
		mov	cx,30
		call	retrace
		mov	dx,offset se
		mov	ah,9
		int	21h
		mov	cx,100
		call	retrace
		mov	dx,offset @ss
		mov	ah,9
		int	21h
		mov	cx,160
		call	retrace
		mov	ax,3			; End of LaMe-Typing EffeCt
		int	10h
		mov	ax,100h			; Kill CurSor
		mov	cx,800h
		int	10h
		mov	ax,0b800h
		mov	es,ax
                mov     si,offset @@1           ; TL-AnSi Piccy
		xor	di,di
                mov     cx,@@1lng/2
		rep	movsw
loopit:         mov     ah,0                    ; Wait 4 a KeYprEz
                int     16h
                mov     ax,0b800h               ; HeRe STaRts Da 'AniMATIOn'
                mov     es,ax                   ; It's NoThing but A Few
                mov     si,offset @@2           ; PiCTUres...It SUx
		xor	di,di
		mov	cx,@@2lng/2
		rep	movsw
                mov     cx,5
                call    retrace
		mov	ax,0b800h
		mov	es,ax
                mov     si,offset @@3
		xor	di,di
                mov     cx,@@3lng/2
		rep	movsw
                mov     cx,5
                call    retrace
		mov	ax,0b800h
		mov	es,ax
                mov     si,offset @@4
		xor	di,di
                mov     cx,@@4lng/2
		rep	movsw
                mov     cx,5
                call    retrace
		mov	ax,0b800h
		mov	es,ax
                mov     si,offset @@5
		xor	di,di
                mov     cx,@@5lng/2
		rep	movsw
                mov     cx,5
                call    retrace
		mov	ax,0b800h
		mov	es,ax
                mov     si,offset @@6
		xor	di,di
                mov     cx,@@6lng/2
		rep	movsw
                mov     cx,5
                call    retrace
		mov	ax,0b800h
		mov	es,ax
                mov     si,offset @@7
                xor     di,di
                mov     cx,@@7lng/2
		rep	movsw
                mov     cx,5
                call    retrace
		mov	ax,0b800h
		mov	es,ax
                mov     si,offset @@8
		xor	di,di
                mov     cx,@@8lng/2
		rep	movsw
                mov     cx,5
                call    retrace
		mov	ax,0b800h
		mov	es,ax
                mov     si,offset @@9
		xor	di,di
                mov     cx,@@9lng/2
		rep	movsw
                mov     cx,5
                call    retrace
		mov	ax,0b800h
		mov	es,ax
                mov     si,offset @10
                xor     di,di
                mov     cx,@10lng/2
		rep	movsw
                mov     cx,5
                call    retrace
		mov	ax,0b800h
		mov	es,ax
                mov     si,offset @11
		xor	di,di
                mov     cx,@11lng/2
		rep	movsw
                mov     cx,5
                call    retrace
                mov     ah,2
		call	hscplayer		; StoP Music
		mov	ax,4c00h		; Back 2 DOs
		int	21h


;---[ RETRACE SUBROUTINE ]-----------------------------------------------------


retrace 	proc
		mov	dx,3dah
	frt:	in	al,dx
		test	al,8
		jnz	frt
		mov	dx,3dah
	nfrt:	in	al,dx
		test	al,8
		jz	nfrt
		loop	frt
		ret
		endp


;---[ END TLT.ASM ]------------------------------------------------------------

end 



; Greets Fly 2 :		- MRF
;				- Valos
;				- Mr. Wody
;				- The Brain
;				- Chicken
