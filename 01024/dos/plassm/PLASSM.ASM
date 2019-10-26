;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;  Org Programmer: Jare of Iguana
;
;  Programmer : Plexus (James Johnson)
;  Date       : 4-2-94
;
;  Comments   : This is an old piece of code that Jare wrote. It helped
;               me imensly in getting to know how mode 13h derivatives
;               are formed. I've changed little of his code but I've added
;               some dox on the vga registers and a nice little patter
;               atop the plasma. I thought I'd share my changes and
;               additions. Hope Jare doens't mind. :)
;
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

.MODEL TINY
.386

WaitVrt Macro
        local @@VRT,@@NOVRT

        mov     dx,3dah
@@VRT:
        in      al,dx
        test    al,8
        jz      @@VRT
@@NOVRT:
        in      al,dx
        test    al,8
        jnz     @@NOVRT
EndM

Code    Segment word public USE16 'CODE16'
        assume cs:Code,ds:Code,es:nothing
        org 100h
;------------------------------------------------
Start:
        push    cs
        pop     ds

        mov     al,13h                  ; Set mode 13h 320x200 256c
	int	10h

        mov     bh,0a0h
        mov     es,bx


;--------------------------------------------------------------------
; Port 3c4h - Sequencer index 4, Memory Mode Register
;
;   To port 0x3c5
;   Write 0 1 1 0
;	  | | | |
;	  | | | \-> Select Graphics Mode
;	  | | \---> Extended Memory Present
;	  | \-----> Sequential Addressing
;	  \-------> Unchained ie Map Mask Register selectes which
;		    plane is beign wrote to.
;
;--------------------------------------------------------------------

	mov	dx,3c4h
        mov     ax,604h                 ; Select unchained
	out	dx,ax

;--------------------------------------------------------------------
; Port 3c4h - Sequencer index 2, Map Mask Register
;
;   To port 0x3c5
;   Write 1 1 1 1
;	  | | | |
;	  | | | \-> Enable Writes to Plane 0
;	  | | \---> Enable Writes to Plane 1
;	  | \-----> Enable Writes to Plane 2
;	  \-------> Enable Writes to Plane 3
;
;--------------------------------------------------------------------

        mov     ax,0f02h                ; Enable writes to all planes
	out	dx,ax

;--------------------------------------------------------------------
; Port 3d4h - CRT Controller Registers index 14h, Underline Location
;	      Register
;
;   To port 3d5h
;   Write 0 0 [0 0 0 0 0]
;	  | | \----|----/
;	  | |	   |
;	  | |	   \----> No underline on characters
;	  | \-----------> Normal Clocking for Unchained
;         \-------------> Normal Word addressing
;--------------------------------------------------------------------

        mov     dx,03D4h
        mov     ax,0014h                  ; Disable dword mode
	out	dx,ax

;--------------------------------------------------------------------
; Port 3d4h - CRT Controller Registers index 17, Mode Control Register
;
;   To port 3d5h
;
;   Write 1 1 1 0 0 0 1 1
;	  | | | | | | | |
;	  | | | | | | | \-> We don't want CGA compatibility.
;         | | | | | | \---> Memory addresses are Output Sequentially
;	  | | | | | \----->
;	  | | | | \------->
;	  | | | \--------->
;	  | | \----------->
;	  | \-------------> Byte mode.
;	  \--------------->
;
;--------------------------------------------------------------------

	mov	ax,0E317h		; Enable byte mode.
	out	dx,ax

;--------------------------------------------------------------------
; Port 3d4h - CRT Controller Registers index 9h, Maximum Scan Line
;	      Register
;
;   To port 3d5h
;   Write 1 1 1 [0 0 0 0 0]
;	  | | | \----|----/
;	  | | |      |
;         | | |      \----> Each scan line is not duplicated
;         | | \----------->
;         | \------------->
;         \--------------->
;
;--------------------------------------------------------------------

	mov	al,9
	out	dx,al

	inc	dx
	in	al,dx
        and     al,0E0h
        or      al,80h
	out	dx,al

        mov     dx,3c8h
	mov	al,64
	out	dx,al
	inc	dx

	mov	cx,384
        mov     si,OFFSET Palette
@@ThisSUX:                                      ; Woo nellay, wait a darn
        lodsb                                   ; microsecond!
        out     dx,al
        dec     cx
        jnz     @@ThisSUX


	mov	si,OFFSET CosTable
MainLoop:

        xor     di,di
        mov     bx,di

        WaitVRT

        mov     ah,200
        mov     cl,Time3
        mov     ch,Time4
@@lv:
	PUSH	ax
        mov     ah,79
        mov     dl,Time1
        mov     dh,Time2
        add     di,1
@@lh:
        mov     al,ah
        and     al,ch

        mov     bl,dl
        add     al,[si+bx]

	mov	bl,dh
        add     al,[si+bx]

	mov	bl,cl
        add     al,[si+bx]

	mov	bl,ch
        add     al,[si+bx]

        shr     al,1
	add	al,64

        stosb

        add     dx,0301h

	dec	ah
	jnz	@@lh

        add     cx,0102h

	pop	ax
	dec	ah
	jnz	@@lv

        dec     bp                              
	mov	bx,bp
	xor	bl,bh
        xor     bl,[di]
	xor	bl,cl
	xor	bl,dl
	add	bl,ch
	add	bl,dh

        xor     bh,bh
	mov	di,offset VTime1
	test	bl,8
	jnz	@@dec
	and	bl,3
        cmp     BYTE PTR [di+bx],3
        jg      @@sum
	inc	BYTE PTR [di+bx]
	jmp	@@sum
@@dec:
	and	bl,3
	cmp	BYTE PTR [di+bx],-3
	jl	@@sum
	dec	BYTE PTR [di+bx]
@@sum:

        mov     dl,VTime1
	mov	dh,VTime2
	mov	cl,VTime3
	mov	ch,VTime4

	add	Time1,dl
	sub	Time2,dh
	add	Time3,cl
	sub	Time4,ch

	mov	ah,1
	int	16h
        jz      MainLoop

        sub     ah,ah
        int     16h

	mov	ax,3
	int	10h
        int     20h

;------------------------------------------------
CosTable LABEL BYTE
        INCLUDE COSTBL.INC

Palette label byte
        i = 0
        REPT 32
                DB      i/2, 32-i/2, i
                i = i + 2
        ENDM
        i = 0
        REPT 32
                DB      32+i/2, i, 63-i
                i = i + 2
        ENDM
        i = 0
        REPT 32
                DB      63-i/2, 63-i, i/2
                i = i + 2
        ENDM
        i = 0
        REPT 32
                DB      32-i/2, i/2, 32+i/2
                i = i + 2
        ENDM


VTime1  DB 2                            ; Waves' speeds.
VTime2  DB 1
VTime3  DB 3
VTime4  DB 4

; Our three indexes.
;------------------------------------------------

Time1   DB ?                            ; Waves' positions. Random, eh? ;-)
Time2   DB ?
Time3   DB ?
Time4   DB ?

Code    ENDS
END     Start
