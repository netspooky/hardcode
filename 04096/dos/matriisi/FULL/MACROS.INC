;includes following macros:
; 	generate_cosinetable			| creates cosines and sines
; 	generate_palette					| inits 256 color palette
; 	getfont 									| gets the 8x16 BIOS font pointer
; 	precalc_tunnel						| precalcs a bitmap tunnel for 320x200 resolution
; 	draw_tunnel 							| draws the tunnel
; 	create_plasma 						| creates 256x256x256 plasma, xor-plasma optional
; 	waitretrace 							| VGA wait for vertical retrace
; 	copy_virtual							| copy virtual screen to physical screen
; 	copy_mtv									| copy mtvscreen to virtual screen
; 	precalc_alpha 						| precalculates the "alpha" values
; 	update_mtv								| updates the alpha values on mtvscreen,
; 														| makes the writer

;inits real time clock (1024 Hz)
MACRO INIT_TIMER2
		cli
		mov al,0bh	;enable timer with correct frequency
		out 70h,al
		in al,71h
		or al,64
		mov ah,al
		mov al,0bh
		out 70h,al
		mov al,ah
		out 71h,al
		mov al,0		;mask on all irq:s 8-15
		out 0a1h,al
		sti
ENDM

MACRO hook_timer
	;** hook 1024hz timer, and start it..
push cs
pop ds
	mov al,070h
	mov dx,offset new_int70h_handler
	mov cx, cs
	mov si,offset wanha_timer
	call swapIntVector
	INIT_TIMER2
ENDM

MACRO unhook_timer
push cs
pop ds
	mov al, 070h
	mov si, offset wanha_timer
	mov cx, [wanha_timer]
	mov dx, [wanha_timer+2]
	call swapIntVector
ENDM

MACRO 			precalc_alpha
						mov 	ax,[alphaprecalc]
						mov 	es,ax

						mov 	bh,0ffh
						ayl:
							mov cl,0
							axl:
								mov al,cl
								mov ah,0
								mul bh			;alpha values: 0xffh=original color
								shr ax,8		; 						 0=black
								mov bl,cl
								mov [es:bx],al
								neg al
								neg bl
								mov [es:bx],al	;color values only 7bit
							dec cl
							jnz axl
						dec bh
						jnz ayl
ENDM

MACRO 			copy_mtv
						mov 	dx,320*60
						mov 	si,320*140
						mov 	di,320*140
						mtvlop:
							mov bh,[si]
							inc si
							mov bl,[es:di]
							mov al,[fs:bx]
							stosb
							dec dx
							jnz mtvlop
ENDM

MACRO 			copy_virtual
						mov 	cx,16000
						xor 	si,si
						xor 	di,di
						push	es
						pop 	ds
						push	0a000h
						pop 	es
						rep 	movsd
ENDM

MACRO 			waitretrace
	pusha
	mov 					dx,3dah 				;Wait vertical retrace
	@v1:
	in						al, dx
	test					al, 8
	jnz 					@v1
	@v2:
	in						al,dx
	test					al,8
	jz						@v2
	inc [dword cs:framecount]
	mov ecx,[cs:frameskip]
	mov [cs:lastframe],ecx
	popa
ENDM

MACRO 	create_plasma
				;²²² plasma creator, in: cx=frame, es=target segment
mov ecx,[frameskip]
shr ecx,5
				xor 		di,di
				mov 		bh,0
				xor 		dx,dx

			 yl:
							 xl:
								mov bl,dl
								sub bl,cl
								mov al,[bx+offset costable]
								add bl,dh
								add al,[offset sintable+bx]
IFDEF psychedelic_funkin
								xor bl,dl
ENDIF
								add al,bl
IFDEF halfrate
	test al,080h
	jz	@fucker
	neg al
	@fucker:
	shr al,1
ENDIF

								stosb
								dec ah
								dec dh
								jnz xl
				dec dl
				jnz yl

ENDM

;IN: es=target segment, fs=holds x coords and gs holds y coords
MACRO 	draw_tunnel
				mov 		bh,cl 					;make the tunnel move and rotate
				mov 		bl,cl
				mov 		si,bx
				shl 		si,2

				xor 		di,di
				mov 		cx,200*320
				dloop:
								mov 		bl,[fs:di]
								mov 		bh,[gs:di]
								mov 		al,[bx+si]
								stosb
								loop		 dloop
ENDM


MACRO 	 precalc_tunnel
				xor 		esi,esi

				mov 		cx,2
				radloop:
								mov 		si,cx
								call		calcdistance
								mov 		[yc1],0

				mov 		[crad],cx

				mov 		ax,64*256
				xor 		dx,dx
				div 		cx
				mov 		[vadder],ax 		;vadder=orig. line length*256/radius

				;in this phase, cx is somewhere between 2 and 190 -> CH is zero
				;we only load the highest 8 bits of [colo1]

				mov 		cl,[offset colo1+1]
				shl 		ecx,16

								circloop: ;²²²

										vertloop: ;²²²
												xor 		eax,eax
												mov 		ax,[yc1]	 ;plot pixel at SI,[yc1]
												shl 		eax,6
												lea 		edi,[eax*4+100*320+eax]
												add 		di,si

												cmp 		edi,64320 			;out of screen test
												ja			vertloope 			;leave 20 rows on top and bottom
												cmp 		si,160
												ja			vertloope

												add 		di,160
												push		di							;save original offset

											mov 		ebx,ecx
											shr 		ebx,8

											add 		bl,64
												mov 		[fs:di],bl	;store offset  (lower right)
												mov 		[gs:di],bh

												neg 		di
												add 		di,200*320+320

											sub 		bl,128
												mov 		[fs:di],bl			;store offset  (upper left)
												mov 		[gs:di],bh

												add 		di,si
												add 		di,si

											neg 			bl
												mov 		[fs:di],bl			;store offset  (upper right)
												mov 		[gs:di],bh

												pop 		di					 ;get the original offset back
												sub 		di,si
												sub 		di,si

												mov 			[gs:di],bh
											add 			bl,128
												mov 		[fs:di],bl	;store offset  (lower left)

									vertloope:
												inc 		[word yc1]
												mov 		ax,[yc1]
												mov 		bx,[yc2]
												cmp 		ax,bx

												jle 		 vertloop ;²²²

												mov 		[yc1],bx		;when we come here, BX holds old [yc2]
												dec 		si					;next x coordinate

												pusha
												mov 		cx,[crad]
												call		calcdistance
												popa
												add 		cx,[vadder]

												cmp 		si,0
												jge 		circloop ;²²²

				mov 		cx,[crad]
								mov 		ax,[coloadder]
								sub 		ax,7
								cmp 		ax,16
								ja			noadshit
								mov 		al,16
							 noadshit:
								mov 		[coloadder],ax
								add 		[colo1],ax

								inc 		cx							;increase radius
								cmp 		cx,190
								jle 		radloop
ENDM

MACRO 					getfont
	mov 					ax,1130h								 ;Load font pointer
	mov 					bh,3										 ;8x8 font
	int 					10h
	mov 					ax,es
	;stosw																	;[fontpointer]:BP points to font
	mov 					[fontpointer],ax
ENDM

;²²²² fucken ripped cosinetable generator
; slight modifications though
macro 	generate_cosinetable
				mov bx,0798fh 									;initial position
				xor si,si 											;initial velocity
				mov di,512
Iloop:
				mov ax,-39
				imul bx
				add si,dx
				add bx,si
				mov [di+offset costable],bh
				dec di
				jns Iloop
endm

MACRO 	generate_palette
		xor cx,cx
		mov al,0
				pl1:
					mov bl, al
					shr bl, 1
					call setRGB
					inc al
					cmp al,128
					jne pl1
				pl2:
					mov bl,al
					dec bl					;a fucken fix
					neg bl
					shr bl,1
					call setRGB
					inc al
					jnz pl2
ENDM
