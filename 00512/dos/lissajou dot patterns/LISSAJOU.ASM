;----------------------------------------------------------------------------
; LISSAJOU.ASM                            copyright (c) 1997, Xavier Defrang
;----------------------------------------------------------------------------
; only to check out some (trig) fpu functions... not too optimized! :)
; greetings goes to trax and alphatrion.
; brought to live using tasm 3.1 and tlink 5.1...
;----------------------------------------------------------------------------
; e-mail: 106146.1452@compuserve.com
;----------------------------------------------------------------------------

		.386
		.387
		.model  tiny

DOTS            equ     64

dptr            equ     dword ptr

code            segment use16

		org     100h

		assume  cs:code, ds:code, es:code, ss:code

start:          
		mov     ax, 0013h
		int     10h

		push    0a000h
		pop     es			;now, you'll have to write
						;the comments by yourself! :)
mainloop:       
		mov     eax, dptr [i]
		mov     dptr [a], eax
		mov     eax, dptr [j]
		mov     dptr [b], eax

		mov     cx, DOTS

		mov     si, offset oldoffsets
dotloop:        
		fld     dptr [a]
		fsub    dptr [b]
		fmul    dptr [deg]
		fcos
		fmul    dptr [ampx]
		fadd    dptr [startx]
		fistp   dptr [temp]

		mov     edi, dptr [temp]
		
		fld     dptr [a]
		fadd    dptr [b]
		fmul    dptr [deg]
		fsin
		fmul    dptr [ampy]
		fadd    dptr [starty]
		fistp   dptr [temp]
		
		mov     eax, dptr [temp]
		lea     eax, [eax+eax*4]
		shl     eax, 6
		add     edi, eax
		
		mov     ax, 0f00h
		mov     bx, word ptr [si]
		mov     es:[bx], al
		mov     es:[di], ah
		mov     word ptr [si], di
		add     si, 2

		fld     dptr [a]
		fadd    dptr [aa]
		fstp    dptr [a]
		
		fld     dptr [b]
		fadd    dptr [bb]
		fstp    dptr [b]

		dec     cx
		jnz     dotloop

		mov     dx, 03dah
vbl1:           in      al, dx
		test    al, 8
		jnz     $-3
vbl2:           in      al, dx
		test    al, 8
		jz      $-3
		
		fld     dptr [i]
		fadd    dptr [ii]
		fstp    dptr [i]

		fld     dptr [j]
		fadd    dptr [jj]
		fstp    dptr [j]

		mov     ah, 01h
		int     16h
		jz      mainloop

		mov     ax, 0003h
		int     10h

		mov	ah, 09h
		mov	dx, offset byebye
		int	21h

		ret

;-- data --------------------------------------------------------------------

		align   4

deg             dd      0.024543692606                               ;PI/128
startx          dd      160.0
ampx            dd      155.0
starty          dd      100.0
ampy            dd      95.0
aa              dd      4.0
bb              dd      1.0
ii              dd      1.0
jj              dd      2.0
byebye		db	13, 10
		db	'[code] [brioche] [greets] [alphatrion] [trax]'
		db	13, 10, '$'
temp            dd      0
a               dd      0.0
b               dd      0.0
i               dd      0.0
j               dd      0.0
oldoffsets      db      0

code            ends

		end     start

