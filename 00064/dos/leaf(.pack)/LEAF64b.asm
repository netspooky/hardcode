mov es, ax				; set to zero
lds dx,[bx]				; get screen pointer (xp)
; push 0xa000			; get screen pointer (freedos)
; pop ds				; get screen pointer (freedos)
mov al,0x13				; set screen to
int 0x10				; 320x200 in 256 colors

top:					; iteration
adc dx,bp				;  1	1	0	1
sar dx,1				;  .5	.5	0	1
rcr ebx,1				; pseudo RNG delay by 32
sbb bp,dx				;  .5	.5	-.5 .5

	mov al,[es:0x46c]	; get timer value
	test al,0x40		; flip...
	jz G				; ...half
		neg al			; ... of the ...
	G:					; spectrum
	and al, byte 0x7f	; and cut to max 127
	
mov byte [bx+si],197	; "delete" "random" point

neg bh					; check RNG bit
jns F					; alter iteration based on it
	xchg dx,bp
	adc bp,ax			; offset by timer

F:
imul di,dx,320			; compose-a screen pointer
mov al,bh				; get color from iteration history
and al,7				; reduce to 8 colors
add al,40				; and shift into the autumn ;)

						; implicit centering
						; and compose-b screen pointer
mov byte [ds:bp+di+68*320+111],al
						; then write pixel
loop top				; repeat 65336 times

in al,0x60				; get key
;dec ax					; (freedos)
dec al					; (xp)
jnz top					; repeat if not ESC
ret						; else quit program
