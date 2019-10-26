;_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/;
  ;_/                 ___ _  __       _  __  _      _                    _/;
    ;_/                T  R  ][       F  ][  E  |_  D                  _/;
      ;_/                     256B intro by srw                      _/;
       ;_/                                                          _/;
        ;_/                     Compiled by                        _/;
        ;_/      FASM-1.40 (251B) : http://flatassembler.net/      _/;
        ;_/      NASM-0.98 (254B) : http://nasm.sourceforge.net/   _/;
       ;_/                                                          _/
      ;_/                Require about 5ooMhz (Default)              _/
    ;_/  [Height], [dposition] and [dtheta] effect for adjust speed.   _/
  ;_/    TRI FIELD   256B intro by  srw  [srw@users.sourceforge.jp]      _/
;_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/;


		org 100h


Width	equ		320		; Can't chage!
Texsize	equ		64		; Can't chage!

Height	equ		160		; change this under 190


start:
		
		; ax = 00??
		; bx = 0000
		; cx = 00ff
		
		mov			al, 13h
		int			10h
		
		push		word 0a000h
		pop			es
		
		inc			cx		;	cl = 0
		mov			ax, cx	;	ax = 0100h
		
		mov			dx, 3c8h
		out			dx, al		; palette index = al
		
   		inc			dx			; dx = 3c9h
		
		;====================================================================;
		
		inc			cx
		
palette_init:
		
		.loop:
			
			mov			ax, cx
			out			dx, al		; red
			out			dx, al		; green
			shl			al, 1
			out			dx, al		; blue
			
		loop		palette_init.loop
		
		;====================================================================;
		
initialize:
		
		
		mov			si, w_dat		;	fix
		
		
initialize_fp:
		
		
		fldz						;	theta
		
		fld			dword [si+14]	;	radius
		
		fldz						;	position
		
		fsave		[memory + (Texsize * Texsize) + (Width * Height)]
		
		;	st0 = position
		;	st1 = radius (power)
		;	st2 = theta
		
		
		;====================================================================;
		;                        	 main loop
		
main_loop:
		
		;	cx = 0
		
		mov			ch, 10h		;	1000h = 4096 = Texsize * Texsize
		
		.texture_gen_loop_bycx:
			
			mov			di, cx
			mov			ax, cx
			shr			ax, 7
			add			di, memory
			mov			byte [di], al
			
			or			di, ax
			add			ax, word [si]		;	word [si] = position as integer
			mov			byte [di], al
		
		loop		.texture_gen_loop_bycx
		
		
draw:
		
		
		mov			cl, Height
		
		
		.height_loop_bycx:				;	for all line
		
			mov			ax, Height * Width
			imul		bx, cx, Width
			sub			ax, bx
			mov			dx, ax			;	destination line idx
			
			frstor		[memory + (Texsize * Texsize) + (Width * Height)]
			
			mov			word [si], cx	;	line idx
			fild		word [si]
			
			fmulp		st2, st0		;	radius
			
			;	st0 = position
			;	st1 = radius
			;	st2 = theta
			
			fld			st2
			fadd		dword [si + 2]	;	cam_angle
			fsincos
			
			;	endY
			fmul		st0, st3
			fadd		st0, st2
			
			fxch		st1
			
			;	endX
			fmul		st0, st3
			fadd		st0, st2
			
			;	st0 = endX
			;	st1 = endY
			;	st2 = position
			;	st3 = radius
			;	st4 = theta
			
			fld			st4
			fsincos
			
			;	startY
			fmul		st0, st5
			fadd		st0, st4
			
			fxch		st1
			
			;	startX
			fmul		st0, st5
			fadd		st0, st4
			
			;	st0 = startX
			;	st1 = startY
			;	st2 = endX
			;	st3 = endY
			;	st4 = position
			;	st5 = radius
			;	st6 = theta
			
			ffree		st6
			ffree		st5
			ffree		st4
			
			
			mov			word [si], Width
			
			
			;	dy = (endY - startY) / length(Width)
			fld			st3
			fsub		st0, st2
			fild		word [si]
			fdiv		st1, st0
			
			;	st0 = length
			;	st1 = dy
			;	st2 = startX
			;	st3 = startY
			;	st4 = endX
			;	st5 = endY
			
			;	dx = (endX - startX) / length(Width)
			fld			st4
			fsub		st0, st3
			fxch		st1
			fdivp		st1, st0
			
			fld			st3
			fld			st3
			
			;	st0 = x
			;	st1 = y
			;	st2 = dx
			;	st3 = dy
			;	st4 = startX	; not use
			;	st5 = startY	; not use
			;	st6 = endX		; not use
			;	st7 = endY		; not use
			
			mov			bx, word [si]		;	word [si] = Width
			
			
			.scanline_loop_bybx:			;	for all pixel of line
				
				fist		word [si]		;	x
				mov			di, word [si]
				
				fxch		st1
				fist		word [si]		;	y
				
				;	di = x
				;	word [si] = y
				
				shl			word [si], 6
				add			di, word [si]
				and			di, 0fffh			;	texture size mask (64 * 64 = 4096 (1000h))
				mov			al, byte [di + memory]
				
				mov			di, dx				;	dx = destination line idx
												;	bx = pixel idx
				
				mov			byte [di + bx + memory + (Texsize * Texsize) - 1], al
				
				;	st0 = y
				;	st1 = x
				
				fadd		st0, st3	;	y += dy
				
				fxch		st1
				fadd		st0, st2	;	x += dx
				
				dec			bx
			
			jnz			draw.scanline_loop_bybx
			
			
			dec			cx
			jz			fin
			
		jmp			draw.height_loop_bycx
		
		
fin:
		
		
		;====================================================================;
		
update_params:							;	move and rotation
		
		mov			di, memory + (Texsize * Texsize) + (Width * Height)
		
		frstor		[di]
		
		;	st0 = position
		;	st1 = radius (power)
		;	st2 = theta
		
		fadd		dword [si + 6]		;	dposition
		fist		word [si]
		
		fxch		st2
		fadd		dword [si + 10]		;	dtheta
		
		fxch		st2
		
		fsave		[di]
		
		;====================================================================;
		
update_vram:
		
		pusha
		
		mov			si, memory + (Texsize * Texsize)
		mov			di, Width * ((200 - Height) / 2)
		mov			cx, Width * Height / 2
		
		rep	movsw
		
		popa
		
		;====================================================================;
		
ESC_trap:
		
		xor			ax, ax
		in			al, 60h
		dec			ax
		jz			exit
		jmp			main_loop
		
		;====================================================================;
		
exit:
		ret
		
		
;============================================================================;
;				datas


w_dat		dw	2			; temp

;	For adjust camera
cam_angle	dd	0.7850		; camera angle : 0.785 rad  =  90 deg

;	For adjust speed
dposition	dd	0.0600		; move delta
dtheta		dd	0.0008		; rotation delta


cam_radius	dd	2.000		; eye - renz distance

memory:
	;	memory --- memory + 4096	; 64 * 64
	;		texture(field)
	;
	;	memory + 4096 --- memory + 4096 + 320 * 160
	;		image
	;	
	;	memory + 4096 + 320 * 160 - 96byte
	;		fpe data area


;	12/03/2004: remove [fninit] and [int 10h]
;				add [cam_angle]

;by srw
;http://members.jcom.home.ne.jp/3374327001/demo/

