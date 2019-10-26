;--------------------------------------------------------------------------
; File: 256b competition entry, 2003
; Acknowledgments to: Erhan Yildiz (Original palette-set code)
;                     matja (FPU sine generator)
;                     Scali, Ace1013 (Various optimisations)
;--------------------------------------------------------------------------

[bits 16]                              ; 16-bit code, of course
[org 0x0100]                           ; Start addressing after the PSP

;---Initialise video mode, segments, sine table----------------------------

	mov al,0x13                    ; Mode 0x13, 320x200x8
	int 0x10                       ; Switch video mode
	
	push 0xA000                    ; Segment for video
	pop es                         ; Set ES
	push es                        ; Push it back on
	pop ds                         ; and retrieve into DS
	
;---Set up the palette (the first 64 at least)-----------------------------
	
	mov dx,0x03C8                  ; Palette writing
	xor ax,ax 	               ; Swap with SI (initial=0100)
	out dx,al                      ; Tell the VGA so

	inc dx                         ; Mov to palette data
	xor bx,bx                      ; Temp storage for GREEN data
	xor cx,cx                      ; Temp storage for BLUE data
pallp1:	out dx,al                      ; Current value out as RED
	xchg ax,bx                     ; Swap out to GREEN
	out dx,al                      ; Write that out
	xchg ax,bx                     ; Bring value back
	xchg ax,cx                     ; Swap with BLUE
	out dx,al                      ; for BLUE too
	xchg ax,cx                     ; Bring it back
	cmp al,63                      ; Have we hit maximum red?
	jnz palred                     ; If so...
	add bl,3                       ; Shift along on GREEN
	sub al,3                       ; And take down RED ready for..
palred:	add al,3                       ; Move along on RED
	cmp al,bl                      ; Is R==G (31 each)?
	jae pallp1                     ; If not, loop back
	add cl,3                       ; Move along on BLUE
	cmp bl,cl                      ; If BLUE isn't yet equal to GREEN
	jae pallp1                     ; Loop back

;---LoopLoopLoopLoop-------------------------------------------------------

;===Randomise bottom line for fire=========================================

main:	mov di,64000                   ; Bottom line of display
	mov ch,2                       ; Write whole bottom line
rand:	in ax,0x40                     ; Read timer
	mul cx                         ; Multiply for some randomness
	and al,0x3F                    ; Shift down to 64 colours
	stosb                          ; And write that
	loop rand                      ; Loop back

;===Apply fire filter to bottom portion====================================

;	mov si,54720                   ; A few lines up from bottom
	mov ch,40
draw:	mov ax,[di-1]                  ; Read value at pos and left
	add al,[di+1]                  ; Read to right
	add ah,[di-320]                ; Read above
	add al,ah                      ; Add together left+pos
	shr al,2                       ; Get average
	jz zero                        ; If still positive
	dec al                         ; Reduce a little
zero:	mov [di-320],al                ; Write above current pos
	dec di                         ; Move along pointer
	loop draw                      ; Loop back

;===Copy resultant fire to the top of the screen===========================	
	
	mov si,63680                   ; Starting from the bottom
	xor di,di                      ; Writing to the top
	mov dx,25                      ; Do 25 lines
mvlp:	mov cx,320                     ; For 320 pixels on each line
	rep movsb                      ; Copy the line up
	sub si,640                     ; Move back a line on the bottom
	dec dx                         ; Top has moved forward, so loop
	jnz mvlp                       ; back for another blast

;===Scroll the centre line along one pixel=================================

	mov si,30721                   ; From 1 pixel along the line
	mov di,30720                   ; To the start of the line
	mov dx,8                       ; For 8 lines
lMove:	mov cx,319                     ; Move 39 char's worth
	rep movsb                      ; Do the move (gotta love rep)
	add si,1                       ; Shift down to the
	add di,1                       ; next line
	dec dx                         ; Bring down the counter
	jnz lMove                      ; and loop back

;===Add a new character if necessary=======================================	
	
	push ds                        ; Save the old DS
	mov ax,cs                      ; Set DS to the
	mov ds,ax                      ; code segment
	
	mov al,byte [ds:cChar]         ; Read where we are in the loop
	inc al                         ; Shift that along
	and al,7                       ; Only doing 8 steps at a time
	mov byte [ds:cChar],al         ; Save the result
	mov dl,byte [ds:cChar]         ; Read what we had
	cmp dl,0                       ; Is it zero?
	jne nChar                      ; If not, no need to draw a char in
	
	mov ah,0x02                    ; Move the cursor
	mov bh,0x00                    ; On page 0
	mov dx,0x0C27                  ; Line 12, last column
	int 0x10                       ; Call video to do the move

	movzx bx,byte [ds:cPtr]        ; Check out position in string
	add bx,pMsg                    ; Point to that character
	mov ah,0x09                    ; Print a char
	mov al,[ds:bx]                 ; The one we're looking at
	mov bx,0x003F                  ; In bright white
	mov cx,0x0001                  ; Just the once, kthx
	int 0x10                       ; Do it

	mov dl,[ds:cPtr]               ; Read our position in the str
	inc dl                         ; Move along
	cmp dl,20                      ; We at the EOS?
	jne nLoop                      ; If so...
	xor dl,dl                      ; Back to zero
nLoop:	mov [ds:cPtr],dl               ; Write that back out
	
nChar:	pop ds                         ; Bring back the saved DS
	
;===Check if there was a key-----------------------------------------------
	
	mov ax,0x0100                  ; Check for a key
	int 0x16                       ; via Keyboard int
	jz main                        ; If nothing, look back

;---All done, so quit------------------------------------------------------

	mov ax,0x0003                  ; Mode 0x03, 80x25 text
	int 0x10                       ; Switch video mode

	mov ah,0x4C                    ; Quit to DOS
	int 0x21                       ; Call out
	
;---Data for the message---------------------------------------------------

pMsg:	db "Too lame for y'all! "      ; The string to print
cPtr:	db 0                           ; Where we are in the str
cChar:	db 7                           ; Where we are on the screen

;---EOF--------------------------------------------------------------------

