;
; Echtfarben 216
; ------------------------------------------------------------------
; 21st Century Masterpiece by Buegeleisen / Bluebox Cinematique GmbH
;
; for the 256 byte intro competition at Function 2012 party
; September 28-30, 2012 - Budapest, Hungary
;
; Requirements:
; - DOS or compatible OS
; - x86 CPU with FPU
; - graphics card with *REAL* support for VBE 1.2
; - works with DOSBox (Hint: Give it your cycles! All of them!)
;
; Compiled with NASM, tested on my K6-2/500 + S3 Trio 64V2/DX
;
; Yes, I did a PC release again. Yes, I still can't do proper code.
; Yes, the Amiga is dead. (Or not.) Nothing to see here, move along.
;
; BTW, this is my first 256 byte intro. And probably my last too.
;
; echtf216.com - BGR truecolor VBE 1.2 version (like my S3 Trio)
; ergbf216.com - RGB truecolor VBE 1.2 version (DOSBox, etc.)
; optif216.com - VGA compatible (256 colors only)
;
;===================================================================
; ... to compile for VGA/Optimalpalette (ugly!)
;%define OPTIPAL
; ... to compile for ARGB color order
;%define ARGB

org 100h 

section .text 

SIZE EQU 98 ; size of the effect "window" on screen
%ifdef OPTIPAL
PIXSIZE EQU 1
%else
PIXSIZE EQU 4
%endif

%define V(arg) bp+(arg-v)
%define C(arg) si+(arg-c)

start:
	; cx = 255 on startup
	push cx
%ifdef OPTIPAL
	mov al, 13h
	int 10h ; good old 320x200 VGA mode, here we are!
	
	; ... highly unoptimized optimalpalette generation
pal:
	mov dx, 03c8h
	mov al, cl
	out dx, al
	inc dx
	;r
	mov al, cl
	and al, 0x07
	mov bl, 256/7
	mul bl
	out dx, al
	;g
	mov al, cl
	and al, 0x38
	shr al, 3
	mul bl
	out dx, al
	;b
	mov al, cl
	and al, 0xc0
	shr al, 6
	mov bl, 256/3
	mul bl
	out dx, al
	
	dec cx
	jno pal
%else
	mov ax, 4f02h
	mov bx, 10Fh
	int 10h ; 320x200/32, VBE 1.2 mode
	xor bx,bx
%endif
	
	push 0a000h
	pop es
	lea bp, [v] ; variables
	lea si, [c] ; constants
fx:
%ifndef OPTIPAL
	xor dx,dx
	mov ax,4f05h
	int 10h ; VBE window switch
%endif
	mov di, (320*PIXSIZE) * ((200-SIZE*2)/2) + (((320*PIXSIZE)-(SIZE*2*PIXSIZE))/2) ; align it to center
	mov word [V(y)], SIZE
	
yl:
	fninit
	fild word [V(t)]
	fst st1
	fmul dword [C(c1_7)] ; t*1.7
	
	fild word [esp] ; we pushed 255 on stack at start
	
	fild word [V(y)]
	fmul dword [C(divider)]
	
	;float r = cos(x+_t*1.7) + sin(y+(5.5*cos(_t*0.7)));
	; ^^^^ second half of the above mess
	fld dword [C(c0_7)]
	fmul st4
	fcos
	fmul dword [C(c5_5)]
	fadd st1 ; st1 = _y
	fsin
	
	mov word [V(x)], SIZE
xl:
	fild word [V(x)]
	fmul dword [C(divider)]
	
	;float r = cos(x+_t*1.7) + sin(y+(5.5*cos(_t*0.7)));
	; ^^^^ first half of the above mess (st4 == t*1.7)
	fld st4
	fadd st1
	fcos
	fadd st2
	
	; register bookkeeping by hand, because x87 sucks
	; st4 = multiplier
	; st3 = _y
	; st2 = rsin
	; st1 = _x
	; st0 = float r
	
	; this is how we calculate the colors
	; r = cos(r*y) ; g = cos(x*y*r) ; b = sin(r*x)
	fld st3
	fmul st1
	fst st7
	fcos
	fmul st5
	fabs
	fistp word [V(p)+1] ; red
	
	fld st6
	fmul st2
	fcos
	fmul st5
	fabs
	fistp word [V(p)+2] ; green
	
	fmulp st1 ; pop the leftover mess
	fsin
	fmul st3
	fabs
	fistp word [V(p)+3] ; blue!!1
	
	; put the pixel
%ifdef OPTIPAL
	mov ax,[V(p)+1]
	shr al, 5
	shr ah, 5
	shl ah, 3
	or al, ah
	mov bl, [V(p)+3]
	and bl, 11000000b
	or al, bl
	mov [es:di],al
	inc di
%else
	mov eax, [V(p)]
%ifndef ARGB
	bswap eax
%endif
	mov [es:di],eax
	add di, 4
	jnc nb
	adc dx,0
	mov ax,4f05h
	int 10h ; VBE window switch
nb:
%endif
	dec word [V(x)]
	cmp word [V(x)],-SIZE
	jne xl
	
	add di, (320*PIXSIZE) - (SIZE*2*PIXSIZE)
	; no VBE switch. with 64k granularity switches are in-line, so fuck it!
	
	dec word [V(y)]
	cmp word [V(y)],-SIZE
	jne yl
	
	inc word [V(t)] ; a very finetuned timing (not)
	
	in al, 60h ; check the keyboard, exit when needed
	dec al
	jnz fx
	
	mov ax, 03h
	int 10h
	pop cx
	ret

section .data 
c:	; we have so many bytes free. lets waste 'em!
	divider	dd 0.05
	c5_5 dd 5.5
	c0_7 dd 0.035
	c1_7 dd 0.085
	extra dd 0 ; overoptimized, didn't want to rename the prod :P

section .bss 
v:	; variables, I see variables!
	x	resw 1
	y	resw 1
	t	resw 1
	p	resq 1

; Jetzt hast du farben.
