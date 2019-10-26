; Prod:             " P a r a n o i a " (?)
; Authors:          HellMood & orby
; Group:            DESiRE
; Release Date:     June 4, 2016
; Party:            @party 2016

bits 16                         ; 'nuff said
org 0x100                       ; Where did you think we'd start?

%define temp    bx + si
%define cinc    bx + si + 2
%define tinc    bx + si 
%define hh      bx + si + 6

        mov     al, 0x13        ; also : "temp" location
        dw      0x3CA3          ; "tinc" short (top 2 bytes)
        dw      0x3AFF          ; "cinc" short (top 2 bytes)	
        dw      100             ; hh
        int     0x10
		
        mov     dx, 0x3C9		; define
pal:    mov		al, cl			; shaded
		test	al, 64			; sub
		jz		pal2			; palettes
		salc					; 1) pink
pal2:	out     dx, al			; to 
		test	al, 128			; black
		jz		pal3			; 2) blue
		salc					; to
pal3:	out		dx, al			; black
		mov		al, cl			; 3) white
		out		dx,	al			; to
		loop    pal				; black

		mov dl,0x31				; dh = 0x03 from above
		mov al,0x3f				; init MIDI to UART mode
		out dx,al

        fldz					; theta init

main:   
		mov dx,0x3DA			
vsync:  in      al, dx			; wait
		and     al, 8			; for
		jz      vsync			; retrace

		mov dl,0x30				; dh = 0x03 from above
			mov ax,[fs:0x46c]	; read timer
			test al,3			; play SFX each 4th tick
			jnz nosound			; skip otherwise
		pusha
			inc byte [fs:0x46c]
			bsf ax,ax			; get least significant bit
			sub al,2			; minus 2, because last two empty anyways
			Y:
			mov si,music		; load music command adress
			outsb				; change instrument command (drum kit channel)
			outsb				; change to SFX samples
			outsb				; play note on drum channel
			add si,ax			; chose sample based on LSB
			outsb				; sample number of drum sound
		popa
nosound:
			cmp al,0x80				; switch camera direction
			jnz noflip				; by inverting the sign 
			add byte [bx+si+5],al	; of "cinc" from time to time
noflip:			

			mov ax,0x707F		; double buffer segment
			out dx,al			; also max volume in AL

	
		push    ds              ; Save original DS
			mov     ds, ax
			push    0xA000
			pop     es
			mov     di, si          ; Sync DI and SI
dblbfr: 	movsb                   ; Copy from double buffer
			loop    dblbfr
	 
			push    ds              ; Switch ES to write to double buffer
			pop     es
        pop     ds              ; Restore DS        

clrscr: stosb					; Black ...
        loop    clrscr        	; ... background
        mov     cx, 320			; screen width, needed for floor and walls
		
		mov di,110 * 320
floor:	cwd						; plot a background
		mov ax,di				; line-wise
		idiv cx					; from 
		shr ax,1				; front
		neg al					; white
		sub al,10+192			; to
		stosb					; back
		test di,di				; black
		jnz floor
		
        fldz					; c init
scan:   fld     st0             ; c, c, theta
        fadd    st0, st2        ; c + theta, c, theta
        fsincos                 ; ry, rx, c, theta
        fldz                    ; t, ry, rx, c, theta
        salc                    ; ax = it = 0
march:  fadd    dword [tinc]    ; t += tinc, ry, rx, c, theta
        fld     st0             ; t, t, ry, rx, c, theta
        fmul    st0, st2        ; t * ry, t, ry, rx, c, theta
        fadd    st0, st5        ; py + t * ry, t, ry, rx, c, theta
		fistp   word [temp]     ; t, ry, rx, c, theta
        mov     dx, [temp]      ; dx = j
        fld     st0             ; t, t, ry, rx, c, theta
        fmul    st0, st3        ; t * rx, t, ry, rx, c, theta
        fabs                    ; fabs(t * rx), t, ry, rx, c, theta
        fistp   word [temp]     ; t, ry, rx, c, theta
        test    dx, [temp]
        jz      miss            ; Did we hit a wall?
        fld     st3             ; c, t, ry, rx, c, theta
        fcos                    ; cos(c), t, ry, rx, c, theta
        fmul    st0, st1        ; t * cos(c), t, ry, rx, c, theta
        fidivr  word [hh]       ; hh / t * cos(c), t, ry, rx, c, theta
        fistp   word [temp]     ; t, ry, rx, c, theta
        mov     bp, [temp]      ; bp = height

		shr 	dl,2			; chose subpalette based
        adc     ah,bl			; on geometry
        
noadd:  mov     dx, 100         ; Clip height to 100
        cmp     bp, dx          ; height > 100?
        jle     noclip
        mov     bp, dx          ; height = 100
noclip: sub     dx, bp          ; dx = lineStart = 100 - height
		shl     bp, 1           ; bp = 2 * height
		shr     ax, 2			; compress colors
				
column: 
		imul    di, dx, 320		; plot
		add     di, cx			; vertical
        dec di					; line
		stosb					; pixel
        inc     dx				; by
        dec     bp				; pixel
        jnz     column			; with
        jmp     short break		; love
		
miss:   inc     al				; check next depth
        jnz     march           ; Loop until ax == 256
break:  fstp    st0             ; ry, rx, c, theta
        fstp    st0             ; rx, c, theta
        fstp    st0             ; c, theta
fpu_op: fsub    dword [cinc]    ; c += cinc, theta
        loop    scan
        fstp    st0
        fadd    dword [tinc]    ; theta += tinc
		
        in      al, 0x60		; check for 
        dec     ax				; escape key
        jnz     main			; otherwise loop
        mov     al, 3			; be nice and
        int     0x10			; switch back to textmode
        ret						; end program
music:
		db 0xc9					; change instrument command (drum kit channel)
		db 56					; change to SFX samples
		db 0x99					; play note on drum channel
								; SFX sample sub set as follows :
		db 48					; guitar cut noise up
		db 56				    ; footsteps 1
		db 57					; footsteps 2
		db 55					; heartbeat
		db 50					; double bass string slap
		db 59					; door creaking
		db 60					; door closing
		db 75					; explosion
		db 53					; screaming
		db 52					; laughing