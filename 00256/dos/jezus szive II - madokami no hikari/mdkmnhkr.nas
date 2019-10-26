; ------------------- J‚zus Sz¡ve II: Madokami no Hikari --------------------
; 
; 256 byte intro for the Function:2015 party, Budapest
;
; Made by Alvaro Acwellan (/molecoola) in nasm, mostly under DosBox.
; Despite having been developed under DosBox, it's timed for real hardware.
; Runs quite well on a 2 GHz Athlon 64, very good on a Core 2 Duo @ 3.8 GHz
; [Compo rig is a 3.4 GHz i7, a more recent member of the same P6 clade]
;
; For mythology consult with file_id.diz
;

; ----------------------- entry code, segments etc ------------------------

org 100h

start:
	mov al,13h
	int 10h
	push word 0xA000
	pop es
	mov ch,60h		; ensure an *entire* palette loop and a safe FS
	mov fs,cx

; palette loop runs ~96 times, but who cares? it's out of main loop ;)

palloop:
	mov dx,3c8h
	mov al,cl
	out dx,al
	mov si,dx	; harmless scratch area
	inc dx
	cmp al,63
	jna nsat63
	mov al,63
nsat63:
	push ax
	out dx,al	; R: 0->63 in 64 steps
	mov al,cl
	shr al,2
	out dx,al	; G: 0-63 in 256 steps
	pop ax
	out dx,al	; B=R
	loop palloop

; ------ outer loop with conditional zoom calculation and fpu clearing ------

IFS_init:
	fninit

	mov bx,ifs1-2			; real base of FP32/16 IFS table
	fild word [bx-ifs1+2+scale]	; *
	fild word [bx-ifs1+2+dispy]	; * a - reused as anim step divisor

	inc word [si+2]			; framecounter (animation begins here)
	fild word [si+2]		; * a fc
	fdiv st1			; slow down
	fsincos				; * a c s (light stroke direction)
	fldpi				; * a c s p
	fmul st2,st0
	fmulp st1,st0			; * a c s
	fstp st2			; * s c

	fld1				; * s c x
	fld1				; * s c x y

	mov al,12			; *64k samples (default 12)

; ---------------------------- The Main Loop -----------------------------

flame_loop:

	imul dx,dx,byte 69	; not reusable anymore
	add dx,ax		; changes 12 times per frame, better random

	mov di,dx		; select 12-byte chunks, 0..3
	shr di,14
	imul di,di,byte 12	; bx = triangle pointer
	cmp di,byte 24		; flags: indicate if it's the 3rd triangle

; tx = v0*x + v2*y + v4

	fld dword [di+bx]		; * s c x y tx
	fmul st2
	fld dword [di+bx+2*2]		; * s c x y tx tmp
	jne nsankaku32
	fadd st5			; ANIM1
nsankaku32:
	fmul st2
	faddp st1			; * s c x y tx
	fadd dword [di+bx+4*2]		; * s c x y tx

; ty = v1*x + v3*y + v5

	fld dword [di+bx+1*2]		; * s c x y tx ty
	fmul st3
	fld dword [di+bx+3*2]		; * s c x y tx ty tmp
	jne nsankaku33			; flags are unchanged
	fmul st5			; ANIM3
nsankaku33:
	fmul st3
	faddp st1			; * s c x y tx ty
	fadd dword [di+bx+5*2]		; * s c x y tx ty

; store tx,ty as x,y and scale them by scale variable -> coords

	fst st2				; * s c x y' tx ty
	fmul st6			; scale
	fiadd word [bx+2+dispy-ifs1]

	fistp word [si]			; * s c x y' tx
	imul di,[si],-320

	fst st2				; * s c x' y' tx
	fmul st5			; scale
	fistp word [si]			; * s c x y

	jnc clip			; flags from imul

	add di,[si]
	add di,177+100*320

; -------------- put the pixel into the framebuffer (fs) -----------------

	inc byte [fs:di]
	jnz clip
	dec byte [fs:di]
clip:

	loop flame_loop			; mainloop end
	dec ax				; outer loop (*64k)
	jnz flame_loop

; ------------------------------ display ----------------------------

movloop:
	xor ax,ax		; al to clear backbuffer, ah for keypressed()
	xchg al,[fs:di]
	stosb
	loop movloop

; ---------------- exit part (keyboard check and exit code) --------------

	in al,60h		; ah supposed to be 0 :)
	dec ax
	jnz IFS_init

	mov al,3
	int 10h
	mov ah,9
	mov dx,message
	int 21h
ret

message:
	db 'MaDoKaMi!$'

ifs1:
	db 0x37,0x3F, 0x86,0xBE
	db 0x86,0x3E, 0x37,0x3F
	db 0x26,0xBF, 0x70,0xBF

ifs2:
	db 0x8E,0x3E, 0xD9,0x3E
	db 0xB9,0xBE, 0x9A,0x3E
	db 0x19,0xBF, 0xB0,0xBE

ifs3:
	db 0x45,0x3F, 0x54,0x3E
	db 0xAB,0x3D, 0x3C,0x3F
	db 0xEB,0x3D, 0x0B,0xBF

ifs4:
	db 0xA7,0x3E, 0x1A,0x3E
	db 0x15,0xBE, 0xA7,0x3E
	db 0x51,0xBF, 0xC4,0xBE

scale	 dw 18
dispy	 dw -128