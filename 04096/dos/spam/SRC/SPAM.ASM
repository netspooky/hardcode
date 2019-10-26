		.MODEL COMPACT
		PAGE 65535, 132

STACK		100h			; stack-size

HUGE		=	16384		; used in ray-part
ROWS		=	120		; screen-height
COLUMNS		=	160		; screen-width
ZOOM_SIZE	=	0100h		; border-length of zoom-data
SIN_BASE	=	11		; dual-logarithm of sin_size
SIN_SIZE	=	1 SHL SIN_BASE	; sin-values in [0;pi/2[
CBOXCOLOR	=	9		; additional colors for rays
CPLANE		=	3		; planes for ray

_DATA		SEGMENT PUBLIC 'DATA'
					; initialized data
					  ; general
Timer		DW	0		    ; timer -- clock of the intro
Rand		DW	69		    ; random number store
RandMax		DW	16		    ; random-amplitude
aCRT		DW	00e11h		; most crt-registers must be
		DW	00d06h
		DW	03e07h
		DW	0c109h
		DW	0ea10h
		DW	0df12h
		DW	04013h
		DW	0e715h
		DW	00616h
CCRT		= (OFFSET $ - OFFSET ACRT) / 2

					  ; ray-part
include		ray.inc 		    ; data for ray-positions
aBoxColor	DB	004h, 004h, 01ch    ; blue
		DB	03fh, 03fh, 004h    ; brite yellow
		DB	004h, 03fh, 007h    ; green
		DB	02fh, 02fh, 02fh    ; brite grey
		DB	01fh, 01fh, 01fh    ; grey
		DB	011h, 011h, 011h    ; dark grey
		DB	037h, 033h, 004h    ; gold
		DB	03fh, 004h, 004h    ; red
		DB	000h, 000h, 000h    ; black

;		box flying in the background
RaPlane1	DW	   0h,    0h,  100h ; left side
		DW	   0h,  200h,  100h
		DW	 200h,    0h,-0c00h
		DB	3, 1
		DW	   0h,    0h, -100h ; right side
		DW	   0h,  200h,  100h
		DW	 200h,    0h,-0c00h
		DB	5, 0
		DW	 200h,    0h,  100h ; front side
		DW	   0h,  200h,  100h
		DW	   0h,    0h,-0c00h
		DB	4, 0

;		german flag flying in the foreground
RaPlane2	DW	 300h,    0h,  100h ; black stripe
		DW	   0h,  0aah,  100h
		DW	   0h,    0h, -500h
		DB	 8, 0
		DW	 300h,    0h,  100h ; red stripe
		DW	   0h,  0aah,   55h
		DW	   0h,    0h, -500h
		DB	 7, 0
		DW	 300h,    0h,  100h ; gold stripe
		DW	   0h,  0aah,  -55h
		DW	   0h,    0h, -500h
		DB	 6, 0

;		box flying from back-right to front-left
RaPlane3	DW	   0h,    0h, -100h ; right side
		DW	   0h,  200h,  100h
		DW	 200h,    0h,-0200h
		DB	5, 0
		DW	 200h,    0h,  100h ; left side
		DW	   0h,  200h,  100h
		DW	   0h,    0h,-0200h
		DB	4, 0
		DW	   0h,    0h,  100h ; front side
		DW	   0h,  200h,  100h
		DW	 200h,    0h,-0200h
		DB	3, 1

					  ; zoom-part
ZShrink		DW	0ffffh		    ; zoom-quotient: ffff=min, 8000=max
ZLevel		DW	20		    ; count of zooms of the landscape
					  ; voxel-part
VAlpha		DW	OFFSET aSin	    ; rotate-angle around x-axis
VBeta		DW	OFFSET aSin+2*SIN_SIZE+4; rotate-angle around y-axis
VaEdge		DW	-5555h,-5555h	    ; coordinated of the edge-points
		DW	-5555h, 5555h
		DW	 5555h, 5555h
		DW	 5555h,-5555h
Waver		DW	0
					; un-initialized data
					  ; general
qDummy		DD	?		    ; dummy, used in initialization
					  ; ray-part
RaNormal	DW	CPLANE*3 DUP (?) 
RpNormal	DW	?
Rt		DW	?
RpaPlane	DW	?
RColor		DB	?
RBackground	DB	?
RcVisiblePlanes	DW	?
Rtemp		DW	?
Rc0		DW	?
Rc1		DW	?
Ry2		DW	?
Rx		DW	?
Ry		DW	?
Rr		DW	?
Rl1		DW	?
Rl2		DW	?
Rts		DW	8 DUP (?)
Rte		DW	8 DUP (?)
R_a04		DW	200h
R_a24		DW	0h
Ra00		DW	?
Ra01		DW	?
Ra02		DW	?
Ra03		DW	?
Ra04		DW	?
Ra10		DW	?
Ra11		DW	?
Ra12		DW	?
Ra13		DW	?
Ra14		DW	?
Ra20		DW	?
Ra21		DW	?
Ra22		DW	?
Ra23		DW	?
Ra24		DW	?
					  ; voxel-part
Vx0		DW	?		    ; mapped coordinates of the
Vy0		DW	?		    ; edge-points
Vx1		DW	?
Vy1		DW	?
Vx2		DW	?
Vy2		DW	?
Vx3		DW	?
Vy3		DW	?
Vdx1		DW	?		    ; differentials for display
Vdx2		DW	?
Vdx3		DW	?
Vdx		DW	?
Vddx		DW	?
Vdy1		DW	?
Vdy2		DW	?
Vdy3		DW	?
Vdy		DW	?
Vddy		DW	?
aSin		=	THIS WORD	    ; sin-values
aSin0		DW	2*SIN_SIZE DUP (?)  ; area: [0.0*pi; 1.0*pi[
aSin1		DW	2*SIN_SIZE DUP (?)  ; area: [1.0*pi; 2.0*pi[
aSin2		DW	1*SIN_SIZE+1 DUP (?); area: [2.0*pi; 3.0*pi]
SIN2COS		=	2*SIN_SIZE

aaColor		DB	128*128 DUP (?)     ; colors of voxels
aaLevel		DB	128*128 DUP (?)     ; heights of voxels

aLevel		DW	2*SIN_SIZE DUP (?)  ; heights in sin-sample
_DATA		ENDS

_DATA2		SEGMENT PUBLIC 'BSS'	; holds various stuff
		DB	65535 DUP (?)
_DATA2		ENDS

_DATA3		SEGMENT PUBLIC 'BSS'	; holds various stuff
		DB	65535 DUP (?)
_DATA3		ENDS

INTRO_TEXT	SEGMENT PUBLIC 'CODE'
		ASSUME	CS:INTRO_TEXT; DS:_DATA; ES:_DATA2

; ============================================================================
;		Routines that are not part-specific
; ============================================================================
		.286

ynSync	DB	0			; boolean, indication new frame
pTimerOld	=	THIS DWORD	; pointer to system timer-handler
offTimerOld	DW	?
segTimerOld	DW	?
Timer_Counter	DW	0		; system-timer-handler on overflow!

BubbleSort	PROC
		mov	cx, RcVisiblePlanes
BS_Loop1:	dec	cx
		jle	BS_End
		push	si
		push	cx
BS_Loop2:	mov	ax, ds:[si]
		cmp	ax, ds:[si+2]
		jng	BS_NoSwap
		xchg	ax, ds:[si+2]
		mov	ds:[si], ax
BS_NoSwap:	add	si, 2
		dec	cx
		jne	BS_Loop2
		pop	cx
		pop	si
		dec	cx
		jmp	BS_Loop1
BS_End:		ret
BubbleSort	ENDP

Delay		PROC NEAR
		pushf
		mov	cx, 70
Delay_Loop:	call	Sync
		loop	Delay_Loop
		sub	ds:[Timer], 70
		popf
		ret
Delay		ENDP

MDone		PROC NEAR		; clear-up everything
		mov	dx, 0043h	; slow-down the system-clock to
		mov	al, 34h		; it's common speed - 18.2 Hz
		out	dx, al
		mov	dl, 40h
		mov	al, 00h
		out	dx, al
		out	dx, al
		mov	ax, 2508h	; restore the old timer-interrupt
		mov	dx, cs:[segTimerOld] ; handler
		mov	ds, dx
		mov	dx, cs:[offTimerOld]
		int	21h
		mov	ax, 0003h	; switch back to text-mode
		int	10h
		mov	ah, 01h		; clear keyboard-buffer
		int	16h
		jz	MDone_NoKey
		mov	ah, 00h
		int	16h
MDone_NoKey:	mov	ax, 4c00h	; quit the program
		int	21h
MDone		ENDP

MInit		PROC NEAR
		ASSUME	DS:INTRO_TEXT
		push	cs		; set-up segments
		pop	ds
		cld
		mov	ax, 3508h	; store old timer-interrupt
		int	21h
		mov	ds:[offTimerOld], bx
		mov	ds:[segTimerOld], es
		mov	ah, 25h		; redirect timer-interrupt
		mov	dx, OFFSET TimerHandler
		int	21h
		mov	dx, 0043h	; set new speed of timer
		mov	al, 34h		; to approx. 70 Hz
		out	dx, al
		mov	dl, 40h
		mov	al, 95h
		out	dx, al
		mov	al, 42h
		out	dx, al
		ASSUME DS:_DATA
		mov	ax, SEG _DATA
		mov	ds, ax
		mov	ax, 0013h	; init standard mode13
		int	10h
		mov	dx, 03c4h
		mov	dx, 03c2h
		mov	al, 0e3h	; increase y-resolution to 60%
		out	dx, al
		mov	dx, 03d4h
		mov	si, OFFSET aCRT
		mov	cx, CCRT
		rep	outsw
		mov	dx, 03c8h	; adress DAC-controller
		xor	ax, ax
		out	dx, al
		inc	dl
		xor	bx, bx		; fill the first 64 DAC-registers
		mov	cx, 40h		; with colors, ranging from black
MInit_DAC1:	out	dx, al		; to green
		mov	al, bl
		out	dx, al
		mov	al, bh
		out	dx, al
		inc	bl
		loop	MInit_DAC1
		xor	bl, bl
		mov	cx, 40h		; fill the next 64 DAC-registers with
MInit_DAC2:	out	dx, al		; colors, ranging from black to blue
		mov	al, bl
		shr	al, 1
		out	dx, al
		mov	al, bl
		out	dx, al
		mov	al, bh
		inc	bl
		loop	MInit_DAC2
		mov	si, OFFSET aBoxColor
		mov	cx, CBOXCOLOR*3
		rep	outsb
		mov	ax, 0a000h
		.386
		mov	gs, ax
		.286
		ret
MInit		ENDP

Main		PROC NEAR		; start-point of intro
		call	MInit		; MInitialization
		call	RRun		; show the ray-part
		call	ZInit		; show the zoom-part
		call	ZRun
		call	VInit		; show the voxel-part
		call	VRun
		jmp	MDone		; clear-up everything
Main		ENDP

Random		PROC NEAR		; this is just a simple random
		push	ax		; number generator, that yields a
		push	dx		; random-number in bp, while leaving
		mov	ax, ds:[rand]	; all other registers unchanged
		mov	dx, 4217h
		imul	dx
		xor	ax, 1974h
		mov	ds:[rand], ax
		mov	dx, RandMax
		imul	dx
		mov	bp, dx
		pop	dx
		pop	ax
		ret
Random		ENDP

Sqrt		PROC
		mov	bx, ax
		mov	dl, 40h
		xor	cx, cx
Sqrt_TryNext:	xor	cl, dl
		mov	al, cl
		mul	al
		cmp	ax, bx
		jle	Sqrt_TakeIt
		xor	cl, dl
Sqrt_TakeIt:	shr	dl, 1
		jnz	Sqrt_TryNext
		mov	si, cx
		ret
Sqrt		ENDP

Sync		PROC NEAR
		cmp	cs:[ynSync], 0	; wait for a new frame ...
		je	Sync
		mov	cs:[ynSync], 0	; now it's an old frame
		inc	ds:[Timer]	; enhance timer
Sync_End:	push	ax
		mov	ah, 01h
		int	16h
		jz	Sync_Done
		jmp	MDone
Sync_Done:	pop	ax
		ret
Sync		ENDP

TimerHandler	PROC	FAR
		mov	cs:[ynSync], 1	; report a new frame
		add	cs:[Timer_Counter], 4295h ; call the system-timer-
		jc	Timer_UseOld	; interrupt if it's time again
		push	ax
		mov	al, 20h		; acknowledge the interrupt to
		out	20h, al		; the irq-controller
		pop	ax
		iret
Timer_UseOld:	jmp	cs:[pTimerOld]	; call system-timer-handler
TimerHandler	ENDP

; ============================================================================
;		routines for the ray-tracing-part
; ============================================================================
RAnimate	PROC
		call	Sync
		mov	dx, Rt
		push	ds
		mov	bx, seg _DATA2
		neg	bx
		mov	WORD PTR cs:RAnimate_Poke, bx
		neg	bx
		xor	si, si
		mov	dx, Rt
		mov	bp, ROWS
RAnimate_Loop1:	mov	cx, COLUMNS
RAnimate_Loop2:	mov	ds, bx
		cmp	[si], dx
		jle	RAnimate_Move
RAnimate_Next:	inc	bx
		dec	cx
		jne	RAnimate_Loop2
		add	WORD PTR cs:[RAnimate_Poke], 256-COLUMNS
		dec	bp
		jne	RAnimate_Loop1
		pop	ds
		ret

RAnimate_Move:	mov	ax, [si]
		and	al, 0fh
		or	al, 80h
		.386
		mov	ah, al
		push	bx
		add	bx, 1234h
RAnimate_Poke	=	$-2
		add	bx, bx
		mov	gs:[bx], ax
		pop	bx
		.286
RAnimate_More:	mov	ax, [si+2]
		mov	[si], ax
		cmp	ax, 07fffh
		je	RAnimate_Moved
		add	si, 2
		jmp	RAnimate_More
RAnimate_Moved:	xor	si, si
		jmp	RAnimate_Next
RAnimate	ENDP

RFade1		PROC
		mov	si, OFFSET aBoxColor
		mov	cx, CBOXCOLOR*3
		mov	dx, 03c8h
		mov	al, 80h
		out	dx, al
		inc	dx
RFade1_Loop1:	inc	BYTE PTR ds:[si]
		lodsb
		cmp	al, 3fh
		jna	RFade1_Ok
		mov	al, 3fh
RFade1_Ok:	out	dx, al
		loop	RFade1_Loop1
		ret
RFade1		ENDP

RFade2		PROC
		mov	dx, 03c8h
		mov	al, 25h
		out	dx, al
		inc	dx
		mov	ax, 3fh
		sub	ax, Timer
		out	dx, al
		mov	ah, al
		cmp	al, 0e5h
		jae	RFade2_Ok
		mov	al, 0e5h
RFade2_Ok:	out	dx, al
		mov	al, ah
		out	dx, al
		mov	ax, Timer
		sub	al, 40h
		shr	al, 1
		cmp	al, 10h
		jae	RFade2_End
		xor	ah, ah
		mov	si, ax
		mov	di, COLUMNS-1
		sub	di, si
		add	si, si
		add	di, di
		mov	cx, ROWS
RFade2_Loop:	.386
		mov	WORD PTR gs:[si], 0000h
		mov	WORD PTR gs:[di], 0000h
		add	si, 0200h
		add	di, 0200h
		.286
		loop	RFade2_Loop
RFade2_End:	ret
RFade2		ENDP

RInit		PROC
		mov	ax, SEG _DATA
		mov	ds, ax
		mov	es, ax
		call	RNormalize
		mov	ax, SEG _DATA2
		.386
		mov	fs, ax
		.286
		xor	di, di
		mov	Ry, -ROWS/2
RInit_NRow:	mov	Rx, -COLUMNS/2
RInit_NColumn:	mov	RBackground, 0
		mov	ax, Ry		; get the "distance" r to the z-axis
		imul	Ry
		mov	cx, ax		;  y^2
		mov	ax, Rx
		imul	Rx
		add	ax, cx		; +x^2
		call	Sqrt		; sqrt
		mov	Rr, si
		add	si, si
		jne	RInit_NoMid
		jmp	RInit_Cont	; so we dont have /0 below
RInit_NoMid:	add	si, OFFSET aDr
		mov	bx, [si]	; get the angle of the (fracted?) ray
		mov	ax, bx		; calculate the angle to y-z-plane
		mov	dx, [si+OFFSET aZ - OFFSET aDr]
		mov	Ry2, dx
		imul	Rx
		idiv	Rr
		mov	Rc0, ax
		mov	bp, ax
		mov	ax, bx		; calculate the angle to x-z-plane
		imul	Ry
		idiv	Rr
		neg	ax		; flip the ray in y-direction
		mov	Rc1, ax		; (coz 0;0 is at the TOP of the screen)
		mov	bx, ax		; if the ray descends very slow, it
		cmp	bx, 16		; won't intersect the checkered plane
		jng	RInit_Cont
		mov	dx, 2		; 2/dy = l = units in z-direction till
		xor	ax, ax		; the ray intersects the plane
		div	bx
		mov	cx, ax
		imul	bp		; l*dx is the x-coordinate of the point
		mov	ax, cx
		add	si, OFFSET aZ-OFFSET aDr ; l+"z-coordinate of the point
		add	ax, Ry2		; where the ray crosses the z-axis"
		sar	ax, 8		; is the z-coordinate
		cmp	dx, 13		; x < 13  - the borders of the plane
		jge	RInit_Cont
		cmp	dx, -13		; x > -13
		jl	RInit_Cont
		cmp	ax, 22		; z < 22
		jge	RInit_Cont
		cmp	ax, -2		; z > -2
		jl	RInit_Cont
		shr	ax, 1		; make checkers 2*x units large
		shr	dx, 1
		adc	ax, dx
		and	al, 1		; 1/0 is the color here
		inc	al
		mov	RBackground, al

RInit_Cont:	mov	ds:[Rtemp], di
		mov	ds:[RpNormal], OFFSET RaNormal
		mov	bp, OFFSET Rts
		mov	RcVisiblePlanes, 0
		mov	si, RpaPlane     ; Fill in the plane-coordinates
		mov	cx, CPLANE
RInit_NextWall:	push	cx
		mov	di, ds:[RpNormal]; check with the common scalar-
		mov	ax, ds:[Rc0]	 ; product if the wall is visible
		imul	WORD PTR ds:[di] ; at all
		mov	cl, ah
		mov	ch, dl
		mov	ax, ds:[Rc1]
		imul	WORD PTR ds:[di+2]
		add	cl, ah
		adc	ch, dl
		add	cx, ds:[di+4]
		sub	cx, 10h		; be a little bit conservative
		cmp	cx, 0
		jns	RInit_Section
		add	si, 20
		jmp	RInit_NoSect
RInit_Section:	mov	di, OFFSET Ra00	; into the equations for the
		mov	cx, 3		; intersection-algorithm
RInit_FillIn:	movsw
		movsw
		add	di, 2
		movsw
		add	di, 2
		dec	cx
		jne	RInit_FillIn
		lodsw
		mov	RColor, al
		push	si
		call	RSec
		pop	si
		cmp	ax, bx
		jg	RInit_NoSect
		shl	ax, 4
		shl	bx, 4
		or	al, RColor
		or	bl, RColor
		mov	ds:[bp], ax
		mov	ds:[bp+OFFSET Rte-OFFSET Rts], bx
		inc	RcVisiblePlanes
		add	bp, 2
RInit_NoSect:	pop	cx
		add	ds:[RpNormal], 6
		dec	cx
		jne	RInit_NextWall
		mov	si, OFFSET Rts
		call	BubbleSort
		mov	si, OFFSET Rte
		call	BubbleSort
		call	RPack
		.386
		mov	ax, fs
		inc	ax
		mov	fs, ax
		.286
		mov	di, ds:[Rtemp]
		mov	al, RBackground
		or	al, 80h
		.386
		mov	ah, al
		mov	gs:[di], ax
		add	di, 2
		.286
		inc	Rx
		cmp	Rx, COLUMNS/2
		je	RInit_NextR
		jmp	RInit_NColumn
RInit_NextR:	

		add	di, 2*(256-COLUMNS)
		inc	Ry
		cmp	Ry, ROWS/2
		je	RInit_Done
		jmp	RInit_NRow
RInit_Done:	ret
RInit		ENDP

RNormalize	PROC
		mov	si, RpaPlane	; RInitialize normal-vectors
		mov	di, OFFSET RaNormal
		mov	cx, CPLANE
RNormalize_Loop:mov	ax, ds:[si+6]	; x2*y3
		imul	WORD PTR ds:[si+14]
		mov	bl, ah
		mov	bh, dl
 		mov	ax, ds:[si+12]	; -x3*y2
		imul	WORD PTR ds:[si+8]
		sub	bl, ah
		sbb	bh, dl
		mov	ds:[di], bx	; = z1
		mov	ax, ds:[si+12]	; x3*y1
		imul	WORD PTR ds:[si+2]
		mov	bl, ah
		mov	bh, dl
		mov	ax, ds:[si]	; -x1*y3
		imul	WORD PTR ds:[si+14]
		sub	bl, ah
		sbb	bh, dl
		mov	ds:[di+2], bx	; = z2
		mov	ax, ds:[si]	; x1*y2
		imul	WORD PTR ds:[si+8]
		mov	bl, ah
		mov	bh, dl
		mov	ax, ds:[si+6]	; -x2*y1
		imul	WORD PTR ds:[si+2]
		sub	bl, ah
		sbb	bh, dl
		mov	ds:[di+4], bx	; = z3
		cmp	BYTE PTR ds:[si+19], 0
		je	RNormalize_Ok
		neg	WORD PTR ds:[di]
		neg	WORD PTR ds:[di+2]
		neg	WORD PTR ds:[di+4]
RNormalize_Ok:	add	si, 20
		add	di, 6
		loop	RNormalize_Loop
		ret
RNormalize	ENDP

RPack		PROC
		xor	di, di
		mov	cx, RcVisiblePlanes
		or	cx, cx
		je	RPack_Void
		mov	si, OFFSET Rts
RPack_Loop:	lodsw
		.386
		mov	fs:[di], ax
		.286
		add	di, 2
		dec	cx
		jne	RPack_Loop
		mov	ax, ds:[si+OFFSET Rte-OFFSET Rts-2]
		and	al, 0f0h
		or	al, RBackground
		.386
		mov	fs:[di], ax
		.386
		add	di, 2
RPack_Void:	.386
		mov	WORD PTR fs:[di], 07fffh
		.286
		ret
RPack		ENDP

RRun		PROC
		cmp	Timer, 0	; first animation-part
		jne	RRun_1b
		mov	Rt, -4000h
		mov	RpaPlane, OFFSET RaPlane1
		mov	R_a04, 400h
		mov	R_a24, 0
		call	RInit
RRun_1b:	cmp	Timer, 100h
		jae	RRun_2
		add	Rt, 084h
		call	RAnimate
		jmp	RRun_End
RRun_2:		cmp	Timer, 100h
		jne	RRun_2b
		mov	Rt, -4200h
		mov	RpaPlane, OFFSET RaPlane2
		mov	R_a04, 200h
		mov	R_a24, 0h
		call	RInit
RRun_2b:	cmp	Timer, 200h
		jae	RRun_3
		add	Rt, 100h
		call	RAnimate
		jmp	RRun_End
RRun_3:		cmp	Timer, 200h
		jne	RRun_3b
		mov	Rt, -2000h
		mov	RpaPlane, OFFSET RaPlane3
		mov	R_a04, -400h
		mov	R_a24,  300h
		call	RInit
RRun_3b:	cmp	Timer, 300h
		jae	RRun_4
		add	Rt, 080h
		call	RAnimate
		jmp	RRun_End
RRun_4:		cmp	Timer, 340h
		jae	RRun_4b
		call	RFade1
		call	Sync
		jmp	RRun_End
RRun_4b:	cmp	Timer, 340h
		jne	RRun_5
		call	RFade2
		call	RWhite
RRun_5:		cmp	Timer, 380h
		jae	RRun_End
		call	RFade2
		call	Sync
RRun_End:	cmp	Timer, 380h
		.386
		jl	RRun
		.286
		ret
RRun		ENDP

RSec		PROC
		mov	ax, Rc0		; fill in the variables for c
		neg	ax
		mov	Ra02, ax
		mov	ax, Rc1
		neg	ax
		mov	Ra12, ax
		mov	Ra22, -100h
		mov	ax, Ry2		; fill in the variables for y
		add	Ra23, ax
		mov	ax, R_a04	; fill in the "time" vector
		mov	Ra04, ax
		mov	ax, R_a24
		mov	Ra24, ax
		mov	Ra14, 0

		mov	cx, 2
		mov	si, OFFSET Ra00
RSec_LoopI:	mov	bx, 0
RSec_LoopJ:	cmp	bx, 4
		je	RSec_Skip1
		mov	ax, ds:[OFFSET Ra20+bx]
		imul	WORD PTR ds:[si+4]
		mov	dh, dl
		mov	dl, ah
		add	ds:[si+bx], dx
RSec_Skip1:	add	bx, 2
		cmp	bx, 10
		jne	RSec_LoopJ
		add	si, 10
		dec	cx
		jne	RSec_LoopI

;    *  *  0  *  *
;    *  *  0  *  *
;    *  * -1  *  *

		cmp	Ra01, 0
		je	RSec_Idle1

		cmp	Ra11, 0
		jne	RSec_Mark1
		mov	ax, Ra00
		xchg	ax, Ra10
		mov	Ra00, ax
		mov	ax, Ra01
		xchg	ax, Ra11
		mov	Ra01, ax
		mov	ax, Ra03
		xchg	ax, Ra13
		mov	Ra03, ax
		mov	ax, Ra04
		xchg	ax, Ra14
		mov	Ra04, ax
		jmp	RSec_Idle1

RSec_Mark1:	mov	cx, 5
		mov	si, OFFSET Ra00
RSec_Loop3:	cmp	cx, 4
		je	RSec_Skip2
		cmp	cx, 3
		je	RSec_Skip2
		mov	ax, ds:[si]
		imul	Ra11
		mov	bh, dl
		mov	bl, ah
		mov	ax, ds:[si+10]
		imul	Ra01
		sub	bl, ah
		sbb	bh, dl
		mov	ds:[si], bx
RSec_Skip2:	add	si, 2
		dec	cx
		jne	RSec_Loop3
		mov	Ra01, 0

;    *  0  0  *  *
;    *  *  0  *  *
;    *  * -1  *  *

RSec_Idle1:	cmp	Ra00, 0
		je	RSec_Short1
		mov	si, OFFSET Ra01
		mov	cx, 4
RSec_Loop4:	cmp	cx, 3
		je	RSec_Skip3
		mov	ax, ds:[si+10]
		imul	Ra00
		mov	bh, dl
		mov	bl, ah
		mov	ax, ds:[si]
		imul	Ra10
		sub	bl, ah
		sbb	bh, dl
		mov	ds:[si+10], bx
RSec_Skip3:	add	si, 2
		dec	cx
		jne	RSec_Loop4

;    *  0  0  *  *
;    0  *  0  *  *
;    *  * -1  *  *

RSec_Short1:	cmp	Ra04, 0
		jne	RSec_NoZero1
		mov	ax, Ra03
		mov	dx, Ra00
		or	ax, ax
		jns	RSec_NoSign1
		neg	ax
		neg	dx
RSec_NoSign1:	or	dx, dx
		js	RSec_JumpX
		cmp	dx, ax
		jl	RSec_JumpX
		mov	Rl1, -HUGE
		mov	Rl2,  HUGE
		jmp	RSec_Done1
RSec_JumpX:	jmp	RSec_NoSection

RSec_NoZero1:	mov	ax, Ra03
		mov	dx, -100h
		imul	dx
		idiv	Ra04
		mov	bx, ax
		mov	ax, Ra00
		sub	ax, Ra03
		mov	dx, 100h
		imul	dx
		idiv	Ra04
		cmp	bx, ax
		jg	RSec_NoSwap1
		xchg	bx, ax
RSec_NoSwap1:	mov	Rl1, ax
		mov	Rl2, bx

RSec_Done1:	cmp	Ra14, 0
		jne	RSec_NoZero2
		mov	ax, Ra13
		mov	dx, Ra11
		or	ax, ax
		jns	RSec_NoSign2
		neg	ax
		neg	dx
RSec_NoSign2:	or	dx, dx
		js	RSec_NoSection
		cmp	dx, ax
		jl	RSec_NoSection
		mov	ax, -HUGE
		mov	bx,  HUGE
		jmp	RSec_Done2
RSec_NoZero2:	mov	ax, Ra13
		mov	dx, -100h
		imul	dx
		idiv	Ra14
		mov	bx, ax
		mov	ax, Ra11
		sub	ax, Ra13
		mov	dx, 100h
		imul	dx
		idiv	Ra14
		cmp	bx, ax
		jg	RSec_Done2
		xchg	bx, ax

RSec_Done2:	cmp	ax, Rl1
		jg	RSec_NoChange1
		mov	ax, Rl1
RSec_NoChange1:	cmp	bx, Rl2
		jl	RSec_NoChange2
		mov	bx, Rl2
RSec_NoChange2:	ret
RSec_NoSection:	xor	ax, ax
		xor	bx, bx
		dec	bx
		ret
RSec		ENDP

RWhite		PROC
		push	es
		.386
		push	gs
		.286
		pop	es
		mov	ax, 2525h
		xor	di, di
		mov	cx, 256*ROWS
		rep	stosw
		pop	es
		ret
RWhite		ENDP

; ============================================================================
;		routines for the zoom-part
; ============================================================================
		yZoom	DW	0

ZInit		PROC NEAR
		xor	al, al
		mov	dx, SEG _DATA3	; Initialize height with 40h
		mov	es, dx		; use fs as the "new" buffer segment
		xor	di, di
		mov	ax, 2525h
		mov	cx, 8000h
		rep	stosw
		.386
		mov	ax, SEG _DATA2	; use es as the "old" buffer segment
		mov	fs, ax
		mov	Timer, 0
		ret
ZInit		ENDP

ZRun		PROC NEAR
ZRun_Start:	mov	ds:[ZShrink], 0ffffh ; reset the zoom-factor each stage
		xor	ah, ah
		mov	cx, ZOOM_SIZE/2	; Zoom old _DATA2 into the new _DATA2;
		mov	si, ZOOM_SIZE/4*(ZOOM_SIZE+1) ; the inner quarter is
		xor	di, di		; magnified to whold size, so that only
ZRun_Zoom2:	push	cx		; the wholes have to be filled
		mov	cx, ZOOM_SIZE/2
ZRun_Zoom1:	push	cx
		mov	al, es:[si+ZOOM_SIZE+1] ; get the heights of four
		cbw			; points that build a square
		mov	dx, ax
		mov	al, es:[si+ZOOM_SIZE]
		cbw
		mov	cx, ax
		mov	al, es:[si+1]
		cbw
		mov	bx, ax
		mov	al, es:[si]
		cbw
		mov	fs:[di], al	; just copy the point at the top-left
		push	bx		; interpolate and randomly displace
		add	bx, ax		; the point at the top-middle
		sar	bx, 1
		call	Random
		add	bx, bp
		mov	fs:[di+1], bl
		add	cx, ax		; interpolate and randomly displace
		push	cx		; the point at the left-middle
		sar	cx, 1
		call	Random
		add	cx, bp
		mov	fs:[di+ZOOM_SIZE], cl
		pop	cx		; interpolate and randomly displace
		pop	bx		; the point at the center
		add	dx, bx
		add	dx, cx
		sar	dx, 2
		call	Random
		add	dx, bp
		mov	fs:[di+ZOOM_SIZE+1], dl
		inc	si		; move to next column
		add	di, 2
		pop	cx
		dec	cx
		jne	ZRun_Zoom1	; loop to next column
		add	si, ZOOM_SIZE/2 ; move pointers to next row
		add	di, ZOOM_SIZE
		pop	cx		; check if it's time to refresh
		push	cx		; the display
		test	cx, 3
		jne	ZRun_NoRefresh
		push	si
		push	di
		call	ZShow		; draw the next picture
		mov	ax, ds:[ZShrink]; recalculate the zoom-factor
		mov	dx, 64136
		mul	dx
		mov	ds:[ZShrink], dx
		pop	di
		pop	si
ZRun_NoRefresh:	pop	cx		; loop to next row
		dec	cx
		jne	ZRun_Zoom2
		call	Random		; avoid cycles in randomness
		cmp	ds:[ZLevel], 6
		ja	ZRun_ItsOK
		sub	ds:[RandMax], 3 ; fractal-dimension <2.5 ...
ZRun_ItsOK:	mov	ds:[ZShrink], 0ffffh ; reset the zoom-factor each stage
		mov	ax, es		; swap between display- and calculation
		mov	dx, fs		; _DATA2
		xchg	ax, dx
		mov	es, ax
		mov	fs, dx
		dec	ds:[ZLevel]	; do a few loops 
		jne	ZRun_Start
		mov	ax, 1409
ZRun_Slow:	push	ax
		call	ZShow
		pop	ax
		sub	ds:[ZShrink], ax
		sub	ax, 31
		jnc	ZRun_Slow
		mov	ds:[ZShrink], 8000h
ZRun		ENDP

ZShow		PROC NEAR
		call	Sync
ZShow_NoExpand:	mov	ax, ds:[ZShrink]
		push	ax
		neg	ax
		push	ax
		mov	dx, ZOOM_SIZE/2
		mul	dx
		add	ax, 8000h
		adc	dx, 0000h
		mov	cs:[yZoom], ax
		mov	ax, ZOOM_SIZE
		mul	dx
		mov	si, ax
		pop	ax
		mov	dx, ZOOM_SIZE/2
		mul	dx
		add	ax, 8000h
		adc	dx, 0000h
		mov	bp, ax
		add	si, dx
		pop	dx
		add	dx, dx
		push	ds
		mov	di, (ROWS-ZOOM_SIZE/2) SHL 8 + (COLUMNS-ZOOM_SIZE/2)
		mov	cx, ZOOM_SIZE/2
		push	es
		pop	ds
ZShow_Loop2:	push	cx
		push	si
		mov	bx, bp
		mov	cx, ZOOM_SIZE/4
ZShow_Loop1:	mov	al, ds:[si]
		add	bx, dx
		adc	si, 1
		mov	ah, al
		mov	gs:[di], ax
		add	di, 2
		mov	al, ds:[si]
		mov	ah, al
		mov	gs:[di], ax
		add	bx, dx
		adc	si, 1
		add	di, 2
		dec	cx
		jne	ZShow_Loop1
		pop	si
		add	cs:[yZoom], dx
		jnc	ZShow_NoSkip
		add	si, ZOOM_SIZE
ZShow_NoSkip:	add	si, ZOOM_SIZE
		add	di, 512-ZOOM_SIZE
		xor	bx, bx
		pop	cx
		dec	cx
		jne	ZShow_Loop2
		pop	ds
		ret
ZShow		ENDP

; ============================================================================
;		routines for the voxel-part
; ============================================================================
VAdvance	PROC NEAR
		cmp	ds:[Timer], 080h
		jne	VAdvance_0b
		call	Delay
VAdvance_0b:	jae	VAdvance_1
		add	ds:[VAlpha], 18h
		sub	ds:[VaEdge+00h], 0018h
		sub	ds:[VaEdge+02h], 0018h
		sub	ds:[VaEdge+04h], 0018h
		add	ds:[VaEdge+06h], 0018h
		add	ds:[VaEdge+08h], 0018h
		add	ds:[VaEdge+0ah], 0018h
		add	ds:[VaEdge+0ch], 0018h
		sub	ds:[VaEdge+0eh], 0018h
		call	VLift
		jmp	VAdvance_End
VAdvance_1:	cmp	ds:[Timer], 110h
		jae	VAdvance_2
		add	ds:[VBeta], 10h
		jmp	VAdvance_End
VAdvance_2:	cmp	ds:[Timer], 200h
		jne	VAdvance_2b
		call	Delay
VAdvance_2b:	jae	VAdvance_3
		sub	ds:[VBeta], 10h
		jmp	VAdvance_End
VAdvance_3:	cmp	ds:[Timer], 280h
		jne	VAdvance_3b
		call	Delay
VAdvance_3b:	jae	VAdvance_4
		call	VWater
		jmp	VAdvance_End
VAdvance_4:	cmp	ds:[Timer], 300h
		jne	VAdvance_4b
		call	Delay
VAdvance_4b:	jae	VAdvance_5
		call	VPull
		jmp	VAdvance_End
VAdvance_5:	cmp	ds:[Timer], 582h
		jae	VAdvance_6
		call	VWave
		jmp	VAdvance_End
VAdvance_6:	call	VFade
		call	VWave
VAdvance_End:	call	VRotate
		ret
VAdvance	ENDP

VBuild		PROC NEAR
		mov	ax, ds:[Vx2]
		sub	ax, ds:[Vx3]
		mov	ds:[Vdx], ax
		mov	bx, ds:[Vx1]
		mov	cx, ds:[Vx0]
		sub	bx, cx
		sub	cx, ds:[Vx3]
		sar	cx, 5
		mov	ds:[Vdx3], cx
		sub	bx, ax
		sar	bx, 7
		mov	ds:[Vddx], bx

		mov	ax, ds:[Vy2]
		mov	dx, ds:[Vy3]
		sub	ax, dx
		mov	ds:[Vdy], ax
		mov	bx, ds:[Vy1]
		mov	cx, ds:[Vy0]
		sub	bx, cx
		sub	cx, dx
		sar	cx, 5
		mov	ds:[Vdy3], cx
		sub	bx, ax
		sar	bx, 7
		mov	ds:[Vddy], bx

		mov	cx, ds:[Vx3]
		shl	cx, 2
		shl	dx, 2
		add	dh, 10
		mov	ax, ds:[Vdx]
		mov	bx, ds:[Vdy]
		mov	si, OFFSET aaColor
		mov	di, OFFSET aaLevel
		mov	bp, 128
VBuild_Loop2:	push	ax
		push	bx
		push	cx
		push	dx
		push	bp

		sar	ax, 5
		mov	WORD PTR cs:[OFFSET VBuild_Inc1 + 2], ax
		sar	bx, 5
		mov	WORD PTR cs:[OFFSET VBuild_Inc2 + 2], bx
		mov	bp, 128
VBuild_Loop1:	mov	bh, dh				;  1
		mov	bl, ch				;  1
		sub	bh, [di]			;  1
		mov	al, [si]			;  1
		inc	si				;  1
		inc	di				;  1
		mov	ah, al				;  1
		mov	WORD PTR es:[bx], ax		;  3
		mov	WORD PTR es:[bx+0100h], ax	;  3
		mov	WORD PTR es:[bx+0200h], ax	;  3
		mov	WORD PTR es:[bx+0300h], ax	;  3
		mov	WORD PTR es:[bx+0400h], ax	;  3
VBuild_Inc1:	add	cx, 01234h			;  1
		jc	VBuild_EoL			;  1
VBuild_Inc2:	add	dx, 01234h			;  1
		dec	bp				;  1
		jne	VBuild_Loop1			;  3
							;=26
VBuild_EoL:	pop	bp
		pop	dx
		pop	cx
		pop	bx
		pop	ax
		add	cx, ds:[Vdx3]
		add	dx, ds:[Vdy3]
		add	ax, ds:[Vddx]
		add	bx, ds:[Vddy]
		dec	bp
		jne	VBuild_Loop2
		ret
VBuild		ENDP

VFade		PROC NEAR
		mov	dx, 03c8h
		mov	al, 40h
		out	dx, al
		inc	dx
		mov	cx, ds:[Timer]
		sub	cx, 580h
		shr	cx, 1
		mov	bx, cx
		mov	al, 0h
VFade_DAC1:	out	dx, al
		out	dx, al
		out	dx, al
		dec	cx
		jne	VFade_Dac1
		mov	cx, 40h
		sub	cx, bx
		xor	bx, bx
VFade_DAC2:	out	dx, al
		mov	al, bl
		shr	al, 1
		out	dx, al
		mov	al, bl
		out	dx, al
		mov	al, bh
		inc	bl
		dec	cx
		jne	VFade_DAC2
		ret
VFade		ENDP

VInit		PROC NEAR
		mov	di, OFFSET aaColor ; Use the colors of the zoom
		mov	si, 4040h
		mov	bp, 4000h
		mov	cl, 80h
VInit_Color2:	push	cx
		mov	cl, 80h
VInit_Color1:	mov	al, es:[si]
		mov	ds:[di], al
		mov	BYTE PTR ds:[di+(OFFSET aaLevel-OFFSET aaColor)], 00h
		mov	BYTE PTR fs:[bp], 00h
		inc	bp
		inc	si
		inc	di
		loop	VInit_Color1
		add	si, 0080h
		pop	cx
		loop	VInit_Color2
		xor	di, di		; clear the background-buffer
		xor	ax, ax
		mov	cx, 8000h
		rep	stosw
		mov	cx, 128		; distance = sqrt (x^2+y^2)
VInit_Sqrt3:	mov	bx, 128
VInit_Sqrt2:	mov	al, cl		; calculate x^2
		sub	al, 128/2 + 1
		imul	al
		mov	si, ax
		mov	al, bl		; calculate y^2
		sub	al, 128/2 + 1
		imul	al
		add	si, ax
		shl	esi, (SIN_BASE - 6) * 2	; stretch distance according
		mov	ds:[qDummy], esi ; to the size of the sin-table
		mov	esi, SIN_SIZE
		xor	ebp, ebp
VInit_Sqrt1:	add	ebp, esi	; get the square-root by testing each
		mov	eax, ebp	; bit in the result, starting with the
		mul	eax		; most significant one
		cmp	eax, ds:[qDummy]
		jna	VInit_Mark1
		sub	ebp, esi
VInit_Mark1:	shr	esi, 1
		jnc	VInit_Sqrt1
		mov	eax, ebp
		add	ax, ax		; align the result to a word-boundary
		mov	fs:[di], ax
		add	di, 2
		dec	bx
		jne	VInit_Sqrt2	; next column
		loop	VInit_Sqrt3	; next row

		xor	di, di		; get a sin-lookup-table with taylor
		xor	cx, cx		; approximation
VInit_Sin:	mov	ebx, 51472	; <-- that is pi/4 * 65536
		xor	eax, eax	; calculate the x for sin(x)
		mov	ax, cx
		mul	ebx
		shr	eax, SIN_BASE
		mov	esi, eax	; iteratively calculate the summands
		mov	ebp, eax	; +x
		xor	bx, bx
		mov	bl, 6		; -x^3 / 3!
		call	VTaylor
		sub	ebp, eax
		mov	bl, 20		; +x^5 / 5!
		call	VTaylor
		add	ebp, eax
		mov	bl, 42		; -x^7 / 7!
		call	VTaylor
		sub	ebp, eax
		mov	bl, 80		; +x^9 / 9!
		call	VTaylor		; take 80 > 8*9 to avoid overflow
		add	ebp, eax
		mov	ds:[OFFSET aSin0 + di], bp ;   sin(x)
		mov	ds:[OFFSET aSin2 + di], bp ; = sin(2pi+x)
		neg	di
		mov	ds:[OFFSET aSin1 + di], bp ; = sin(pi-x)
		neg	bp
		mov	ds:[OFFSET aSin2 + di], bp ; =-sin(2pi-x)
		neg	di
		mov	ds:[OFFSET aSin1 + di], bp ; =-sin(pi+x)
		add	di, 2		; move pointer to next sin-place
		inc	cx
		cmp	cx, SIN_SIZE
		jna	VInit_Sin	; loop to next calculation
		call	Delay
		mov	ds:[Timer], 0
		ret
VInit		ENDP

VLift		PROC NEAR
		mov	cx, 128*128
		mov	si, OFFSET aaColor
		mov	di, 4000h
VLift_Loop:	mov	al, 20h
		sub	al, ds:[si]
		add	al, al
		jc	VLift_Down
		add	fs:[di], al
		jnc	VLift_NoMove
		dec	BYTE PTR ds:[si+(OFFSET aaLevel-OFFSET aaColor)]
		jmp	VLift_NoMove
VLift_Down:	neg	al
		add	fs:[di], al
		jnc	VLift_NoMove
		inc	BYTE PTR ds:[si+(OFFSET aaLevel-OFFSET aaColor)]
VLift_NoMove:	inc	si
		inc	di
		dec	cx
		jne	VLift_Loop
		ret
VLift		ENDP

VPull		PROC NEAR
		mov	ax, ds:[Timer]
		and	al, 3
		jne	VPull_End
		mov	si, OFFSET aaLevel
		mov	cx, 4000h
VPull_Loop:	cmp	BYTE PTR ds:[si], 0
		je	VPull_Next
		dec	BYTE PTR ds:[si]
		jne	VPull_Next
		mov	BYTE PTR ds:[si+(OFFSET aaColor-OFFSET aaLevel)], 60h
VPull_Next:	inc	si
		dec	cx
		jne	VPull_Loop
VPull_End:	ret
VPull		ENDP

;1) Drehung um die X-Achse mit Winkel a
;2) Drehung um die Y-Achse mit Winkel b
;
;     ( 1    0      0   )
;A1 = ( 0  cos a -sin a )
;     ( 0  sin a  cos a )
;
;     ( cos b  sin b  0 )
;A2 = (-sin b  cos b  0 )
;     (   0      0    1 )
;
;	   (    cos b          sin b     0   )   ( x )
;A1*A2*v = (-cos a*sin b  cos a*cos b -sin a ) * ( y ) ; z=0
;	   (-sin a*sin b  sin a*cos b  cos a )   ( z )

VRotate		PROC NEAR
		mov	si, ds:[VAlpha]
		mov	di, ds:[VBeta]
		mov	bx, OFFSET VaEdge
		mov	bp, OFFSET Vx0
		mov	cx, 4
VRotate1:	push	cx
		mov	ax, ds:[di+SIN2COS]	;  x*cos b
		mov	dx, ds:[bx]
		imul	dx
		mov	cx, dx
		mov	ax, ds:[di]		; +y*sin b
		mov	dx, ds:[bx+2]
		imul	dx
		add	cx, dx
		mov	ds:[bp], cx
		mov	ax, ds:[si+SIN2COS]	; x*cos a*sin b
		mov	dx, ds:[di]
		imul	dx
		sal	dx, 1
		mov	ax, ds:[bx]
		imul	dx
		neg	dx
		mov	cx, dx
		mov	ax, ds:[si+SIN2COS]	; +y*cos a*cos b
		mov	dx, ds:[di+SIN2COS]
		imul	dx
		sal	dx, 1
		mov	ax, ds:[bx+2]
		imul	dx
		add	cx, dx
		mov	ds:[bp+2], cx
		mov	ax, ds:[si]		; -x*sin a*sin b
		mov	dx, ds:[di]
		imul	dx
		sal	dx, 1
		mov	ax, ds:[bx]
		imul	dx
		neg	dx
		mov	cx, dx
		mov	ax, ds:[si]		; y*sin a*cos b
		mov	dx, ds:[di+SIN2COS]
		imul	dx
		sal	dx,1
		mov	ax, ds:[bx+2]
		imul	dx
		add	cx, dx
		sar	cx, 1
		add	ch, 60h
		mov	ax, ds:[bp]		; central projection in 
		imul	cx			; x-direction
		add	dh, 20h
		mov	ds:[bp], dx
		mov	ax, ds:[bp+2]		; central-projection in
		imul	cx			; y-direction
		add	dh, 20h
		mov	ds:[bp+2], dx
		add	bx, 4
		add	bp, 4
		pop	cx
		dec	cx
		je	VRotate_End
		jmp	VRotate1
VRotate_End:	ret
VRotate		ENDP

VRun		PROC NEAR
		call	VAdvance
		call	VBuild
		call	VShow
		cmp	ds:[Timer], 05feh
		jna	VRun
		ret
VRun		ENDP

VShow		PROC NEAR
		call	Sync
		push	ds
		mov	ax, es
		add	ax, 04e3h
		mov	ds, ax
		xor	eax, eax
		xor	di, di
		xor	si, si
		mov	cx, ROWS
VShow_Copy2:	push	cx
		mov	cx, COLUMNS/2
VShow_Copy1:	mov	dl, ds:[si+1]
		mov	dh, dl
		shl	edx, 16
		mov	dl, ds:[si]
		mov	dh, dl
		mov	gs:[di], edx
		mov	ds:[si], ax
		add	di, 4
		add	si, 2
		dec	cx
		jne	VShow_Copy1
		pop	cx
		add	si, 96
		add	di, 192
		dec	cx
		jne	VShow_Copy2
		pop	ds
		ret
VShow		ENDP

VTaylor		PROC NEAR		; get from one taylor-summand of
		mul	esi		; sin to another by multiplicating
		shr	eax, 15		; it with x^2 and dividing it by
		mul	esi		; a suitable number
		shr	eax, 15
		idiv	ebx
		ret
VTaylor		ENDP

VWater		PROC NEAR
		mov	ax, ds:[Timer]
		and	ax, 7fh
		shr	ax, 2
		jc	VWater_End
		sub	ax, 1fh
		mov	si, OFFSET aaLevel
		mov	cx, 4000h
VWater_Loop:	cmp	ds:[si], al
		jnle	VWater_Ok
		inc	BYTE PTR ds:[si]
		mov	BYTE PTR ds:[si+(OFFSET aaColor-OFFSET aaLevel)], 60h
VWater_Ok:	inc	si
		dec	cx
		jne	VWater_Loop
VWater_End:	ret
VWater		ENDP

VWave		PROC NEAR
		mov	si, OFFSET aSin
		mov	bx, ds:[Timer]
		mov	bp, bx
		sub	bp, 300h
		cmp	bp, 7fh
		jna	VWave_Growth
		mov	bp, 7fh
VWave_Growth:	shl	bp, 9
		shl	bx, 8
		neg	bx
		mov	di, OFFSET aLevel
		mov	cx, 2*SIN_SIZE
VWave_Loop:	and	bx, 8*SIN_SIZE - 2
		mov	ax, ds:[si+bx]
		add	ah, 128
		mul	bp
		shr	bp, 1
		sub	dx, bp
		add	bp, bp
		mov	ds:[di], dx
		add	di, 2
		add	bx, 8
		dec	cx
		jne	VWave_Loop

		xor	bp, bp
		mov	di, OFFSET aaLevel
		mov	si, OFFSET aLevel
		mov	cx, 128*128
VWave_Level:	mov	bx, fs:[bp]
		mov	ax, ds:[si+bx]
		sub	dx, ax
		shr	dx, 5
		add	dl, 080h
		shr	dl, 2
		add	dl, 40h
		mov	ds:[OFFSET aaColor - OFFSET aaLevel + di], dl
		mov	dx, ax
		sar	ax, 11
		mov	ds:[di], al
		inc	di
		add	bp, 2
		dec	cx
		jne	VWave_Level
		mov	cx, 128
		mov	si, OFFSET aaColor
VWave_Adjust:	mov	al, ds:[si+1]
		mov	ds:[si], al
		add	si, 128
		dec	cx
		jne	VWave_Adjust
		ret
VWave		ENDP

INTRO_TEXT	ENDS
		END	Main
