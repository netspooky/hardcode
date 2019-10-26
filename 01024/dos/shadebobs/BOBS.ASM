;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
;
; BOBS.ASM
;
; Shadebobs.
; FRiAR TuCK [PCi]
;
; This is how the "shadebobs" in a lot of demos are done. Many other effects
; use this type of technique, I figured it out while trying to duplicate the
; lines in the beginning of Renaissance's "Amnesia".
;
; Simple stuff.. Put together a palette with a fade in it, and then go around
; incrementing the value in the pixel. I use a block of BOBSIZE*BOBSIZE size.
; XMove and YMove are equates to move the block, but you can use a sine
; routine, anything.. All you do is put the X and Y coords for the block in
; [_x] and [_y], and then call _plotbob. Also you must call _init once in
; the beginning to set the screen and palette. Don't trust anything with
; these routines, because they're quick hacks. They destroy all registers,
; except the BP and SP regs.
;
; This is made into a .COM file, so all data work is in the same segment...
; For the uneducated, to create from this source:
;
;       TASM bobs
;       TLINK /t bobs
;
; Enjoy!
; -FT
;
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; mumbo jumbo
    DOSSEG
    .MODEL TINY
    .CODE
    .386
    ORG 100h
    ASSUME CS:@CODE, DS:@CODE
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
;
; GENERAL EQUATES
;
;==============================================================================
; Try different numbers here. BOBBER is the increment in color each time.
BOBSIZE equ 51
XMOVE   equ 19
YMOVE   equ 12
BOBBER  equ 4

; Comment the next line for a neat effect.
; FULLSCRN equ 1

; Lets make this a .COM file.
START:  jmp begin
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
;
; GENERAL DATA VARS
;
;==============================================================================

_x      dw      0
_y      dw      0
xm      db      XMOVE
ym      db      YMOVE

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
;
; PALETTE VALUES
;
;==============================================================================
colors  db       0, 0, 0, 0, 1, 0, 0, 2, 0, 0, 3, 0
	db       0, 4, 0, 0, 5, 0, 0, 6, 0, 0, 7, 0
	db       0, 8, 0, 0, 9, 0, 0,10, 0, 0,11, 0
	db       0,12, 0, 0,13, 0, 0,14, 0, 0,15, 0   ; 16
	db       0,16, 0, 0,17, 0, 0,18, 0, 0,19, 0
	db       0,20, 0, 0,21, 0, 0,22, 0, 0,23, 0
	db       0,24, 0, 0,25, 0, 0,26, 0, 0,27, 0
	db       0,28, 0, 0,29, 0, 0,30, 0, 0,31, 0   ; 32
	db       0,32, 0, 0,33, 0, 0,34, 0, 0,35, 0
	db       0,36, 0, 0,37, 0, 0,38, 0, 0,39, 0
	db       0,40, 0, 0,41, 0, 0,42, 0, 0,43, 0
	db       0,44, 0, 0,45, 0, 0,46, 0, 0,47, 0   ; 48
	db       0,48, 0, 0,49, 0, 0,50, 0, 0,51, 0
	db       0,52, 0, 0,53, 0, 0,54, 0, 0,55, 0
	db       0,56, 0, 0,57, 0, 0,58, 0, 0,59, 0
	db       0,60, 0, 0,61, 0, 0,62, 0, 0,63, 0   ; 64
	db       0,63, 0, 1,63, 1, 2,63, 2, 3,63, 3
	db       4,63, 4, 5,63, 5, 6,63, 6, 7,63, 7
	db       8,63, 8, 9,63, 9,10,63,10,11,63,11
	db      12,63,12,13,63,13,14,63,14,15,63,15   ; 80
	db      16,63,16,17,63,17,18,63,18,19,63,19
	db      20,63,20,21,63,21,22,63,22,23,63,23
	db      24,63,24,25,63,25,26,63,26,27,63,27
	db      28,63,28,29,63,29,30,63,30,31,63,31   ; 96
	db      32,63,32,33,63,33,34,63,34,35,63,35
	db      36,63,36,37,63,37,38,63,38,39,63,39
	db      40,63,40,41,63,41,42,63,42,43,63,43
	db      44,63,44,45,63,45,46,63,46,47,63,47   ; 112
	db      48,63,48,49,63,49,50,63,50,51,63,51
	db      52,63,52,53,63,53,54,63,54,55,63,55
	db      56,63,56,57,63,57,58,63,58,59,63,59
	db      60,63,60,61,63,61,62,63,62,63,63,63   ; 128

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
;
; MACROS
;
; I use these macros because they make the code a little more readable.
; Nuthin' fancy, just nicer lookin'.
;
;==============================================================================

; @grmode = set 320x200x256c mode
@grmode macro
	mov     ax,0013h
	int     10h
endm

; @textmode = set 80x25x16c mode
@textmode macro
	mov     ax,0003h
	int     10h
endm

; @terminate = DOS Terminate.
@terminate macro
	mov     ax,4C00h
	int     21h
endm

; @keypressed - check for keypress, zero flag set if yes.
@keypressed macro
	mov     ah,1                    ;check to see if a key's been pressed
	int     16h
endm
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
;
; CODE BEGINS HERE
;
;==============================================================================

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
;
; _INIT
;
;       pops the screen into graphics mode, and writes the palette.
;
;==============================================================================

_init proc near
	@grmode

	xor ax,ax
	mov dx,03C8h                    ; Tell the VGA card that the
	out dx,al                       ; Palette's comin'.

	mov dx,03C9h                    ; The values go here
	mov cx,384                      ; 3*(128 colors)
	mov si,offset colors            ; Point to the table
	cld                             
in01:   lodsb                           ; In
	out dx,al                       ; and Out
	dec cx                          ; NEXT!
	cmp cx,00h                      ; done?
	jne in01                        ; nope
					;
	std                             ; backwards
	dec si                          ; comment this line for green white and
					; blue
	mov cx,384                      ;
in02:   lodsb                           ;
	out dx,al                       ;
	dec cx                          ;
	cmp cx,00h                      ;
	jne in02                        ;
	cld                             ; Forwards

_init endp

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
;
; _PLOTBOB
;
;       Plots a square of [BOBSIZE x BOBSIZE], upper left at [_x,_y]
;
;==============================================================================
_plotbob    proc    near
	mov     di,word ptr [_x]    ; DI = x
	mov     cx,di               ; CX = x
	jmp     short pb07          ; compare and continue
pb01:                               ;
	mov     si,word ptr [_y]    ; SI = y
	jmp     short pb06          ; same thing
pb02:                               ;
	mov     ax,si               ; AX = y
	;
	; This next stuff is conditional compile, if FULLSCRN is defined
	; the bob will use the full screen, otherwise it clips
	;
ifdef fullscrn
	cmp     ax,200              ; AX > 200?
	jl      pb03                ; nope, skip this
	sub     ax,200              ; AX = y - 200
endif
pb03:   mov     dx,320              ;
	imul    dx                  ; AX = (y|y-200) * 320
ifdef fullscrn
	cmp     cx,320              ; CX > 320?
	jl      pb05                ; nope, skip next line
	sub     ax,320              ; AX = AX - 320
endif
pb05:   add     ax,cx               ; AX = (y*320)+x
	mov     bx,ax               ; ES:[AX] is illegal, so use BX
	mov     dx,0A000h           ;
	mov     es,dx               ; ES = segment 0A000 - the screen mem
	add     byte ptr es:[bx],BOBBER  ; PLOT THE POINT!
	inc     si                  ; y = y + 1
pb06:
	mov     ax,word ptr [_y]    ; SI > y+BOBSIZE?
	add     ax,BOBSIZE          ;
	cmp     ax,si
	jg      short pb02          ; nope, NEXT!
	inc     cx                  ; x = x + 1
pb07:
	mov     ax,di               ;
	add     ax,BOBSIZE          ; CX > x+BOBSIZE?
	cmp     ax,cx               ;
	jg      short pb01          ; nope, next X.
	ret     
_plotbob    endp

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
;
; PROGRAM ENTRY POINT
;
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
begin:
	call _init
	mov [_x],0
	mov [_y],0

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
bg01:   add [_x],XMOVE                  ; Increment the X and Y locations
	add [_y],YMOVE                  ;
ifdef fullscrn
	cmp [_x],320                    ;======================================
	jl bg02                         ;
	sub [_x],320                    ; This stuff is conditional assembled,
bg02:   cmp [_y],200                    ;
	jl bg03                         ; based on the existence of a FULLSCRN
	sub [_y],200                    ;
else                                    ; equate. It clips the screenwork at a
	cmp [_x],320 - BOBSIZE          ;
	jl bg02                         ; MUCH smaller boundary. Looks cool if
	sub [_x],320 - BOBSIZE          ;
bg02:   cmp [_y],200 - BOBSIZE          ; you let it run a while.
	jl bg03                         ;
	sub [_y],200 - BOBSIZE          ;======================================
endif
bg03:   call _plotbob                   ; Plot it.
	@keypressed                     ; Press a key?
	jz     bg01                     ;nope, continue

	@textmode
l8r:    @terminate                      ;Terminate.

       END START
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
