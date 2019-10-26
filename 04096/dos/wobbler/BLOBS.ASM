;*****************************************************************************
;*                                                                           *
;* Wobbler 1.0                                                               *
;* This code takes the function : z = (x+y), and instead of just doing it    *
;* the old boring way, it takes X and offsets it by htable[y] and offsets    *
;* Y by vtable[x]. htable and vtable are two arrays of sinewaves. Then, it   *
;* takes the value of the old pixels, adds it to 'Z', and plots it.          *
;* This means it feeds back .... much more interesting than colour cycling   *
;* By TH/20/3/96                                                             *
;* tomh@globalnet.co.uk                                                      *
;*                                                                           *
;*****************************************************************************

	.386
        .MODEL  USE16 SMALL
        .STACK 500h
	JUMPS
	LOCAL
	SMART
	PUBLIC	_IMAGE_move_wobbles
	PUBLIC	_WOBBLE_pattern
dopixel MACRO
        LOCAL   @@no_reset
	mov	si, [htableptr]
	mov	bx, cx
	mov	ax, [si]
        add     bx, ax

	mov	si, [vtableptr]
	mov	dx, bp
	mov	ax, [si]
	add	dx, ax

        xor     ah, ah
        add     bx, dx
        mov     al, es:[di]
        add     bx, ax
        mov     es:[di], bl
        inc     di
	mov	ax, [vtableptr]
	add	ax, 2
        dec     cx
	mov	[vtableptr], ax
ENDM
WAIT_RETRACE = 0
	.DATA
	INCLUDE	htable.inc
	INCLUDE	vtable.inc
        INCLUDE palette.inc
credits         DB      'Dancing blobs', 13, 10, 'By Tom Hammersley 1996',13,10,'$'
htableptr	DW	0
vtableptr	DW	0
plane_select    DB      11h
pixel_count     DB      0

	.CODE
_IMAGE_move_wobbles PROC
	cld
        mov     ax, @Data
	mov	es, ax
	mov	ax, [htable]
	mov	[htable+400], ax
	mov	si, OFFSET htable
	mov	di, OFFSET htable
	add	si, 2
	mov	cx, 100
	rep	movsd
	mov	ax, [vtable]
	mov	[vtable+640], ax
	mov	si, OFFSET vtable
	mov	di, OFFSET vtable
	add	si, 2
	mov	cx, 160
	rep	movsd
	ret
_IMAGE_move_wobbles ENDP

_WOBBLE_pattern PROC
	mov	ax, OFFSET htable
        mov     bx, 0A000h
	mov	[htableptr], ax
        xor     di, di
        mov     es, bx
        mov     bp, 200
@@row_loop:
	mov	ax, OFFSET vtable
        mov     cx, 320
	mov	[vtableptr], ax
@@pixel_loop:
        dopixel
        dopixel
        dopixel
        dopixel
        jnz     @@pixel_loop

	mov	ax, [htableptr]
	add	ax, 2
	mov	[htableptr], ax

        dec    bp
        jnz    @@row_loop
	ret
_WOBBLE_pattern	ENDP

main:
.STARTUP
        mov     ax, 0013h
        int     10h
        mov     dx, 3C8h
        xor     ax, ax
        out     dx, ax
        lea     bx, palette
        mov     cx, 768
        mov     dx, 3C9h
pal_loop:
        mov     al, [bx]
        out     dx, al
        inc     bx
        dec     cx
        jnz     pal_loop
	mov	ax, @Data
	mov	ds, ax
frame_loop:
IF WAIT_RETRACE
        mov     dx,3dah
Vrt:                                    ; wait for a vertical retrace
        in      al,dx                   ; b4 we bugger with the VGA regs
        test    al,8
        jnz     Vrt              
NoVrt:
        in      al,dx
        test    al,8
        jz      NoVrt
ENDIF
        call    _WOBBLE_pattern
        call    _IMAGE_move_wobbles
        in      al, 60h
        cmp     al, 1
        jne     frame_loop
        mov     ax, 0003h
        int     10h
        mov     ax, @Data
        mov     ds, ax
        mov     dx, OFFSET credits
        mov     ax, 0900h
        int     21h
        mov     ax, 4C00h
        int     21h

        
;*****************************************************************************
END main

