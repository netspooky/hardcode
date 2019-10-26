;ЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫ
; 512b intro for BYTEFALL Compo Party'96
; CopyLefted 06.09.96 by Professor Nimnull \\ BYTEFALL Gr0uP
; CoProcessor _required_
; Min Config: 		386/387DX 40MHz
; My  Config: 		amd5x86 160MHz
; Recommended Config: 	iPentium 160MHz
;
; Partition idias:
; 	Thomas Hagen	???
;	Jeremy Longley	jcl1008@cus.cam.ac.uk
;
; Contact to me by:
; FidoNet:	2:5020/552.69
; InterNet:	nimnull@bfg.ips.ras.ru
.model tiny
.386p
.code

MAX_MOV_COMB 	equ 10000  


org 100h

Start:
	mov	bh,60h
        mov     ah,4ah
        int     21h
	jc 	Exit

	fldcw	word ptr CW

	mov	di,offset _30
	push	di
	xor	ax,ax
	mov	cx,bx
	rep	stosb

	pop	di
	mov	si,offset b30
	mov	cx,bx
UnPack:
	lodsb	
	stosw
	loop	UnPack

;ЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫ
; First generate the plasma map.  This is effectively just an
; arbitrary function of x and y which gives a smooth but
; non-uniform surface 


	mov	dx,es
	add	dh,10h
	mov	plasma_seg,dx

	mov	bp,3
LoopPlazma:
	mov	es,dx

	xor	di,di
	mov	cx,128
	call	GeneratePlazma
	add	dh,10h
	dec	bp
	jnz	LoopPlazma


;ЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫ
; Then arbitrary movement for two pointers 

	mov	es,dx
	mov	move_seg,dx

	xor	di,di
	mov	cx,MAX_MOV_COMB
	mov	word ptr [si],di

LoopCount:
; 92*cos(count/32)
	fild	word ptr [si]
	fidiv	word ptr _32
	fcos

	call	Cool92

; 512*(int)(48+47*sin(count/16));
	fidiv	word ptr _16
	fsin

	call	CoolSinCos
	
	stosw

;---------------------------------------------------------

; 92*sin(count/21)
	fild	word ptr [si]
	fidiv	word ptr _21
	fsin

	call	Cool92

; 512*(int)(48+47*cos(count/24));
	fidiv	word ptr _24
	fcos

	call	CoolSinCos

	sub	ax,es:[di-2]
	stosw

	inc	word ptr [si]

	loop	LoopCount

;ЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫ
; And a smooth transition color lookup table 

	mov	dx,es
	add	dh,10h
	mov	es,dx
	mov	color_seg,dx

	xor	di,di
	mov	ch,(256*40)/100h
	mov	word ptr [si],di

LoopI:

; sin(i/20)*sin(i/15)*31+31
	mov	bx,offset _20
	mov	ax,offset _15
	call	CoolSin

;---------------------------------------------------------
; sin(i/35)*sin(i/22)*31+31
	mov	bx,offset _35
	mov	ax,offset _22
	call	CoolSin

;---------------------------------------------------------
; sin(i/13)*sin(i/30)*31+31
	mov	bx,offset _13
	mov	ax,offset _30
	call	CoolSin

	inc	word ptr [si]

	loop	LoopI

;ЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫ

        mov     ax,13h          ; set video mode 13
        int     10h
        mov     ax,0a000h
        mov     es,ax

        xor     ax,ax           ; clear ax
	mov	bp,si
        mov     [bp],ax      	; store counter

mainloop:

; ------------------ Vert Retrace
waitfly:
        mov     dx,03dah        ; VGA input status register 1
        in      al,dx           ; load value
        test    al,08           ; vertical retrace??
        je      waitfly         ; if not, try again...

; ------------------ Calc

        mov     si,[bp]      	; source = count *3
        shl     si,1
        add     si,[bp]
        mov     dx,3c8h         ; DAC index register
        mov     al,1            ; start with reg 1
        out     dx,al           ; and load
        inc     dx              ; DAC read/write register
        mov     cx,255*3        ; write 255 items
        push    ds              ; store DS
        mov     ds,[color_seg]	; address segment

; ------------------ Set Palette

	rep	outsb

	pop     ds              ; and restore DS

; ------------------ Draw

        mov     di,[bp]      	; source = count * 4
        shl     di,2
        push    ds              ; save DS (again...)
        mov     ds,[move_seg]   ; get segment address of movement data
        mov     si,[di]         ; load point 1
        mov     bx,[di+2]       ; load point 2
        pop     ds              ; restore DS

        push    ds              ; and store it ...
        mov     ds,[plasma_seg] ; get segment of start of plasma
        xor     di,di           ; DI = 0

        mov     ch,200          ; y loop = 200 pixels
pl1:    
	mov     cl,80           ; x loop = 80 * 4 = 320 pixels
pl2:    
	lodsd                   ; get 4 source pixels
        add     eax,[si+bx]     ; add 4 source pixels
        stosd                   ; and store them
        dec     cl              ; dec counter
        jnz     pl2             ; and loop..
        sub     si,320          ; reset source
        mov     dx,ds           ; add 32 to DS -
        add     dx,32           ; move 32*16 = 512 bytes down in source memory
        mov     ds,dx
        dec     ch              ; dec counter
        jnz     pl1             ; and loop..

        pop     ds              ; restore DS (again)
        inc     word ptr [bp]; increase counter
        cmp     word ptr [bp],MAX_MOV_COMB ; reset it at end of cycle
        jne     mainloop

closedown:
        mov     ax,3h           ; set text mode...
        int     10h


;ЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫ

Exit:
	ret

;ЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫ

;-----------------------------------------------------------------
; Generate cx*512 bytes of plazma to [si]
GeneratePlazma	proc

	mov	si,offset x
	mov	bx,offset y
LoopY:	
	mov	word ptr [si],0
LoopX:	
; sin(x/30)
	fild	word ptr [si]
	fidiv	word ptr _30
	fsin

; cos(y/46)
	fild	word ptr [bx]
	fidiv	word ptr _46
	fcos

; cos(x/37)
	fild	word ptr [si]
	fidiv	word ptr _37
	fcos

; sin(y/70)
	fild	word ptr [bx]
	fidiv	word ptr _70
	fsin

; sin((x+y)/43)
	fild	word ptr [si]
	fiadd	word ptr [bx]
	fidiv	word ptr _43
	fsin

; cos(hypot(256-x,150-y)/20)
	fild	word ptr _256
	fisub	word ptr [si]
	fmul	st(0),st(0)
	fild	word ptr _150
	fisub	word ptr [bx]
	fmul	st(0),st(0)
	faddp	st(1),st(0)
	fsqrt
	fidiv	word ptr _20
	fcos

	mov	ax,5
AddAll:
	faddp	st(1),st(0)
	dec	ax
	jnz 	AddAll

	fimul	word ptr _10
	fiadd	word ptr _64

; plazma
	fistp	word ptr result
	mov	al,byte ptr result
	stosb

	inc	word ptr [si]
	cmp	word ptr [si],512
	jb	LoopX

	inc	word ptr [bx]
	loop	LoopY

	ret
GeneratePlazma	endp
;-----------------------------------------------------------------
CoolSin	proc

	fild	word ptr [si]
	fidiv	word ptr [bx]
	
	fsin

	fild	word ptr [si]
	mov	bx,ax
	fidiv	word ptr [bx]

	fsin
	fimul	word ptr _31
	fmulp	st(1),st(0)
	fiadd	word ptr _31

	fistp	dword ptr result

	mov	al,byte ptr result
	stosb

	ret
CoolSin	endp
;-----------------------------------------------------------------
CoolSinCos	proc

	fcos
	fimul	word ptr _47
	fiadd	word ptr _48

	fistp	dword ptr result

	mov	ax,word ptr result
	mov	dx,512
	mul	dx
; 96 + sin + cos - prev
	add	ax,bx
	add	ax,96

	ret
CoolSinCos	endp
;-----------------------------------------------------------------
Cool92	proc

	fimul	word ptr _92
	fistp	dword ptr result
	mov	bx,word ptr result
	fild	word ptr [si]

	ret
Cool92	endp
;-----------------------------------------------------------------

;const
CW 	dw	0F7Fh		;ЋЄагЈ«Ґ­ЁҐ = ®вбҐЄ ­ЁҐ
_256    dw	256
_150    dw	150

;----------------------

b30	db	30
b46	db	46
b37	db	37
b70	db	70
b43	db	43
b20	db	20
b10	db	10
b64	db	64

b32	db	32
b92	db	92
b16	db	16
b47	db	47
b48	db	47
b21	db	21
b24	db	24

b15	db	15
b31	db	31
b35	db	35
b22	db	22
b13	db	13

;----------------------

_30	dw	?
_46	dw	?
_37	dw	?
_70	dw	?
_43	dw	?
_20	dw	?
_10	dw	?
_64	dw	?

_32	dw	?
_92	dw	?
_16	dw	?
_47	dw	?
_48	dw	?
_21	dw	?
_24	dw	?
		
_15	dw	?
_31	dw	?
_35	dw	?
_22	dw	?
_13	dw	?

;----------------------

;var
x	dw	?
y	dw	?
result	dd	?

plasma_seg	dw ?
move_seg    	dw ?
color_seg  	dw ?

	end Start