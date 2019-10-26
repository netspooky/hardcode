;/* tab-size is 4!

; most parts taken from the gus development kit! (uh.. all parts?!)


dataseg

NUM_VOICES		equ	14

gf1_base		dw	0200h
gf1_midi_ctrl	dw	0300h
gf1_page		dw	0302h
gf1_reg_select	dw	0303h
gf1_data_lo		dw	0304h
gf1_data_hi		dw	0305h
gf1_dram		dw	0307h

GUS				dw	0
adder			dw	0
GusCounter		dw	1

ends

;----------------------------------------------------------------------------

codeseg

macro		DISABLE
			pushf
			cli
endm
macro		ENABLE
			popf
endm

;----------------------------------------------------------------------------

proc		Gdetect			near

@@testGus:	call	GravTest
			cmp		al,1
			je		@@foundGus
			mov		ax,020h
			add		[gf1_base],ax
			add		[gf1_midi_ctrl],ax
			add		[gf1_page],ax
			add		[gf1_reg_select],ax
			add		[gf1_data_lo],ax
			add		[gf1_data_hi],ax
			add		[gf1_dram],ax
			cmp		[gf1_base],0280h
			jl		@@testGus

@@foundGus:	cmp		[gf1_base],0270h
			jl		@@init
			xor		ax,ax
			jmp		@@weg
@@init:		mov		ax,1
@@weg:		mov		[GUS],ax
			call	Ginit
			ret
endp

;----------------------------------------------------------------------------

proc		Gdelay		near

			push	ax
			push	cx
			push	dx
			mov		cx,8
@@delay:	mov		dx,0300h
			in		al,dx
			loop	@@delay
			pop		dx
			pop		cx
			pop		ax
			ret
endp

;----------------------------------------------------------------------------

proc		_Gping		near

			DISABLE

			mov		dx,[gf1_reg_select]			;; 0103h
			mov		al,04ch
			out		dx,al
			mov		dx,[gf1_data_hi]
			xor		al,al
			out		dx,al
			call	Gdelay
			mov		dx,[gf1_reg_select]			;; 0103h
			mov		al,04ch
			out		dx,al
			mov		dx,[gf1_data_hi]
			mov		al,1
			out		dx,al

			ENABLE
			ret
endp

;----------------------------------------------------------------------------

proc		_ClearDMA		near

			mov		dx,[gf1_reg_select]			;; 0103h
			mov		al,041h
			out		dx,al
			mov		dx,[gf1_data_hi]
			in		al,dx
			mov		dx,[gf1_reg_select]			;; 0103h
			mov		al,049h
			out		dx,al
			mov		dx,[gf1_data_hi]
			in		al,dx
			mov		dx,[gf1_reg_select]			;; 0103h
			mov		al,08fh
			out		dx,al
			mov		dx,[gf1_data_hi]
			in		al,dx
			ret
endp

;----------------------------------------------------------------------------

proc		GravTest		near

			call	_Gping

			xor		eax,eax		; address
			mov		bl,0aah		; value
			call	DramPut
			xor		eax,eax
			call	DramGet
			cmp		al,0aah
			je		@@gusYes
			xor		ax,ax
			ret
@@gusYes:	mov		ax,1
			ret
endp

;----------------------------------------------------------------------------

proc		Ginit		near

			cmp		[GUS],1
			jne		@@nope

			DISABLE
			call	_Gping
			call	Gdelay

			mov		dx,[gf1_reg_select]			;; 0103h
			mov		al,041h
			out		dx,al
			mov		dx,[gf1_data_hi]
			xor		al,al
			out		dx,al
			mov		dx,[gf1_reg_select]			;; 0103h
			mov		al,045h
			out		dx,al
			mov		dx,[gf1_data_hi]
			xor		al,al
			out		dx,al
			mov		dx,[gf1_reg_select]			;; 0103h
			mov		al,049h
			out		dx,al
			mov		dx,[gf1_data_hi]
			xor		al,al
			out		dx,al

			mov		dx,[gf1_reg_select]			;; 0103h
			mov		al,0eh
			out		dx,al
			mov		dx,[gf1_data_hi]
			mov		al,NUM_VOICES OR 0c0h
			out		dx,al

			mov		dx,[gf1_base]
			add		dx,06h
			in		al,dx

			call	_ClearDMA

			mov		cx,NUM_VOICES
@@clear:	mov		dx,[gf1_page]				;; 0102h
			mov		ax,cx
			out		dx,al
			inc		dx
			xor		al,al
			out		dx,al
			mov		dx,[gf1_data_hi]
			mov		al,3
			out		dx,al
			mov		dx,[gf1_reg_select]			;; Volume Ramp Off
			mov		ax,0dh
			out		dx,al
			mov		dx,[gf1_data_hi]
			mov		al,3
			out		dx,al
			loop	@@clear

			call	_ClearDMA

			mov		dx,[gf1_reg_select]			;; Initialize
			mov		al,04ch
			out		dx,al
			mov		dx,[gf1_data_hi]
			mov		al,7
			out		dx,al

			mov		cx,NUM_VOICES				;; Clear Volume-Ramps
@@clrramps:	mov		dx,[gf1_page]
			mov		ax,cx
			out		dx,al
			mov		dx,[gf1_reg_select]			;; Voice Off
			mov		al,6
			out		dx,al
			mov		dx,[gf1_data_hi]
			mov		al,03fh
			out		dx,al
			mov		dx,[gf1_reg_select]			;; Volume Ramp Off
			mov		ax,09h
			out		dx,al
			mov		dx,[gf1_data_lo]
			xor		ax,ax
			out		dx,ax
			loop	@@clrramps

			mov		dx,[gf1_base]
			mov		al,1
			out		dx,al
			add		dx,103
			mov		al,04ch
			out		dx,al
			add		dx,2
			mov		al,3
			out		dx,al

			ENABLE
@@nope:		ret
endp

;----------------------------------------------------------------------------

proc		PlayVoice		near				;; ax= voice  ...  bx = freq

			cmp		[GUS],1
			jne		@@nope

			DISABLE

			push	ax
			mov		dx,[gf1_page]
			out		dx,al

			mov		dx,[gf1_reg_select]			;; Set Sample Start Address
			mov		al,0ah
			out		dx,al
			mov		dx,[gf1_data_lo]			;; HIWORD Start Sample
			xor		ax,ax
			out		dx,ax
			mov		dx,[gf1_reg_select]
			mov		al,0bh
			out		dx,al
			mov		dx,[gf1_data_lo]			;; LOWORD start Sample
			xor		ax,ax
			out		dx,ax

			mov		dx,[gf1_reg_select]			;; Set Loop Start Address
			mov		al,02h
			out		dx,al
			mov		dx,[gf1_data_lo]			;; HIWORD Start Loop
			xor		ax,ax
			out		dx,ax
			mov		dx,[gf1_reg_select]
			mov		al,03h
			out		dx,al
			mov		dx,[gf1_data_lo]			;; LOWORD start Loop
			xor		ax,ax
			out		dx,ax

			mov		dx,[gf1_reg_select]			;; Set Loop End Address
			mov		al,04h
			out		dx,al
			mov		dx,[gf1_data_lo]			;; HIWORD End Loop
			mov		ax,2
			out		dx,ax
			mov		dx,[gf1_reg_select]
			mov		al,05h
			out		dx,al
			mov		dx,[gf1_data_lo]			;; LOWORD End Loop
			xor		ax,ax
			out		dx,ax

			mov		dx,[gf1_reg_select]			;; Turn Voice On
			xor		al,al
			out		dx,al
			mov		dx,[gf1_data_hi]			;; Voice-Mode (loop only)
			mov		al,8
			out		dx,al

			mov		dx,[gf1_reg_select]			;; Set Frequency
			mov		al,1
			out		dx,al
			mov		dx,[gf1_data_lo]
			mov		ax,bx
			out		dx,ax

			mov		dx,[gf1_reg_select]			;; Set PAN
			mov		al,0ch
			out		dx,al
			mov		dx,[gf1_data_hi]
			mov		ax,8
			out		dx,ax

			pop		ax
			mov		bx,0
			call	SetVolume

			ENABLE
@@nope:		ret
endp

;----------------------------------------------------------------------------

proc		DramPut		near					;; eax=location   ... bl=byte

			DISABLE

			push	eax
			mov		dx,[gf1_reg_select]
			mov		al,043h
			out		dx,al
			mov		dx,[gf1_data_lo]
			pop		eax
			out		dx,ax

			push	eax
			mov		dx,[gf1_reg_select]
			mov		al,044h
			out		dx,al
			mov		dx,[gf1_data_lo]
			pop		eax
			shr		eax,16
			out		dx,al

			mov		dx,[gf1_dram]
			mov		al,bl
			out		dx,al

			ENABLE
			ret
endp

;----------------------------------------------------------------------------

proc		DramGet		near					;; eax=loc   ..  al=ret

			DISABLE

			push	eax
			mov		dx,[gf1_reg_select]
			mov		al,043h
			out		dx,al
			mov		dx,[gf1_data_lo]
			pop		eax
			out		dx,ax

			push	eax
			mov		dx,[gf1_reg_select]
			mov		al,044h
			out		dx,al
			mov		dx,[gf1_data_lo]
			pop		eax
			shr		eax,16
			out		dx,al

			mov		dx,[gf1_dram]
			in		al,dx

			ENABLE
			ret
endp
;----------------------------------------------------------------------------
proc		SetVolume		near

			cmp		[GUS],1
			jne		@@nope

			DISABLE

			mov		dx,[gf1_page]
			out		dx,al
			push	bx
			mov		dx,[gf1_reg_select]			;; Set Volume
			mov		al,09h
			out		dx,al
			mov		dx,[gf1_data_lo]
			pop		ax
			out		dx,ax

			ENABLE
@@nope:		ret
endp

;----------------------------------------------------------------------------

proc		InitSound		near

			call	Gdetect
			mov		ax,1
			mov		bx,294
			call	PlayVoice
			mov		ax,2
			mov		bx,298
			call	PlayVoice
			ret
endp

;----------------------------------------------------------------------------

proc		LoopSound		near

			cmp		[GUS],1
			jne		@@nope

			xor		cx,cx
			xor		eax,eax
@@fill1:	mov		ax,cx
			mov		bl,128
			push	cx
			call	DramPut
			pop		cx
			inc		cx
			cmp		cx,[GusCounter]
			jne		@@fill1

@@fill2:	mov		ax,cx
			mov		bl,127
			push	cx
			call	DramPut
			pop		cx
			inc		cx
			cmp		cx,255
			jle		@@fill2

			cmp		[adder],1
			je		@@dec

			inc		[GusCounter]
			cmp		[GusCounter],255
			je		@@reset1
			ret
@@reset1:	mov		[adder],1
			ret

@@dec:		dec		[GusCounter]
			cmp		[GusCounter],0
			je		@@reset2
			ret
@@reset2:	mov		[adder],0
@@nope:		ret

endp

ends

;----------------------------------------------------------------------------

;
; that's it..
;

end
