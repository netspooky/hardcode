;       Sokoban Classic by Rebels
;       coded via lord Kelvin

	org 0x100		; .COM

	mov al,3		; \ Desired text mode.
	int 0x10		; /

	push 0xB800		; \ ds: points to text buffer segment.
	pop ds			; /

	mov si,level		; si points to level data.

start:	mov ax,0x600		; \ Clear entire screen.
	mov bh,7		; |  ( Attributes - LIGHTGRAY text,
	xor cx,cx		; |   BLACK background )
	mov dx,0x184F		; |
	int 0x10		; /

	xor dx,dx		; \ Move cursor to top left corner.
	mov ah,2		; |
	mov bh,0		; |
	int 0x10		; /

	push ds 		; \ Preserve previous ds: value
	push es 		; |  and change it to code segment.
	pop ds			; /

punch:	lodsb			; Load byte from level data.

	cmp al,'|'		; \ If the symbol is '|' - move cursor
	jne boot		; |  to the next line.
	mov al,13		; |
	int 0x29		; |
	mov al,10		; |
	int 0x29		; |
	jmp hit 		; /

boot:	cmp al,'0'		; \ If it`s a part of a number,
	jb kick 		; |  store it in cx.
	cmp al,'9'		; |  (Numbers more then 10 are possible)
	ja kick 		; |
	imul cx,10		; |
	xor ah,ah		; |
	add cx,ax		; |
	sub cx,'0'		; |
	jmp hit 		; /

kick:	test cx,cx		; \ If there wasn`t a number before symbol -
	jnz nock		; |  output it once, otherwise - output
	inc cx			; |  it _number_ times.
nock:	int 0x29		; |
	loop nock		; /

hit:	cmp al,'@'		; \ If the symbol represents player -
	je hello		; |  store his coordinates in bx.
	cmp al,'+'		; |  (Coordinate is the position of symbol
	jne usual		; |   in text buffer segment)
hello:	push cx 		; |
	mov ah,3		; |
	xor bx,bx		; |
	int 0x10		; |
	pop cx			; |
	mov bl,dh		; |
	imul bx,80		; |
	xor dh,dh		; |
	add bx,dx		; |
	dec bx			; |
	shl bx,1		; /

usual:	test al,al		; \ Zero represents the end of the level.
	jnz punch		; /

	pop ds			; Restore ds:.

here:	xor ah,ah		; \ Wait for keystroke, store key data in ax.
	int 0x16		; /

	cmp ah,1		; \ If <Esc> was hit - say goodbye.
	jne cross		; |
	ret			; /

cross:	mov di,-160		; \ If up arrow was hit - set di to -160,
	cmp ah,72		; |  if left - -2, if right - 2, if down -
	je fly			; |  160. So, bx+di will point to place,
	mov di,-2		; |  where player wishes to step and
	cmp ah,75		; |  bx+2*di - to place, where he could
	je fly			; |  move a crate.
	mov di,2		; |
	cmp ah,77		; |
	je fly			; |
	mov di,160		; |
	cmp ah,80		; |
	je fly			; |
	xor di,di		; /

fly:	cmp byte [bx+di],'-'	; \ If the step place is floor, or _point_ -
	je step 		; |  draw player there and draw floor (point)
	cmp byte [bx+di],'.'	; |  on player`s previous place.
	jne next		; |  (So, '-' will be changed to '@',
	mov al,'+'-'@'		; |  '.' to '+', '+' to '.', '@' to '-')
step:	add al,'@'		; |
	mov byte [bx+di],al	; |
	and byte [bx],15	; |
	xor byte [bx],13	; |
	or byte [bx],0x28	; |
	add bx,di		; /

	jmp here		; Continue.

next:	cmp byte [bx+di],'$'	; \ If there`s a crate before us and free
	je force		; |  space after it, them move it.
	cmp byte [bx+di],'*'	; |  (Like previous block, but kind of
	jne here		; |   more complicated)
force:	sal di,1		; |
	cmp byte [bx+di],'-'	; |
	je can			; |
	cmp byte [bx+di],'.'	; |
	jne here		; |
	mov al,'*'-'$'		; |
can:	add al,'$'		; |
	mov byte [bx+di],al	; |
	sar di,1		; |
	inc byte [bx+di]	; |
	jp trick		; |
	mov byte [bx+di],'@'	; |
trick:	and byte [bx],15	; |
	xor byte [bx],13	; |
	or byte [bx],0x28	; |
	add bx,di		; /

	push es 		; \ Preserve previous ds: value
	push ds 		; |  and change it to code segment.
	pop es			; /
	mov al,'$'		; \ Count all '$' symbols on the screen.
	mov cx,80*25*2		; |  If there aren`t any - then all crates
	xor di,di		; |  are on points and level is completed.
	repne scasb		; |
	pop es			; |
	jz here 		; /

	jmp start		; Go to next level.

db '256b'			; =)

level:				; Packed level data.
db '4 5#|4 #3-#|4 #$2-#|2 3#2-$3#|2 #2-$2-$-#|3#-#-3#-#5-6#|#3-#-3#-7#2-2.#|#-$2-$13-2.#|5#-4#-#@4#2-2.#|4 #6-3#2-6#|4 8#',0
db '12#|#2.2-#5-3#|#2.2-#-$2-$2-#|#2.2-#$4#2-#|#2.4-@-2#2-#|#2.2-#-#2-$-2#|6#-2#$-$-#|2 #-$2-$-$-$-#|2 #4-#5-#|2 12#',0
db '8 8#|8 #5-@#|8 #-$#$-2#|8 #-$2-$#|8 2#$-$-#|9#-$-#-3#|#4.2-2#-$2-$2-#|2#3.4-$2-$3-#|#4.2-10#|8#',0
db '14 8#|14 #2-4.#|3 12#2-4.#|3 #4-#2-$-$3-4.#|3 #-3$#$2-$-#2-4.#|3 #2-$5-$-#2-4.#|3 #-2$-#$-$-$8#|4#2-$-#5-#|#3-#-9#|#4-$2-2#|#-2$#2$-@#|#3-#3-2#|9#',0
db '8 5#|8 #3-5#|8 #-#$2#2-#|8 #5-$-#|9#-3#3-#|#4.2-2#-$2-$3#|#4.4-$-2$-2#|#4.2-2#$2-$-@#|9#2-$2-2#|8 #-$-$2-#|8 3#-2#-#|10 #4-#|10 6#',0
db '6#2-3#|#2.2-#-2#@2#|#2.2-3#3-#|#2.5-2$-#|#2.2-#-#-$-#|#2.3#-#-$-#|4#-$-#$2-#|3 #2-$#-$-#|3 #-$2-$2-#|3 #2-2#3-#|3 9#',0
db '32 15~|35 Applause!|34 You`ve won!|32 15~',0

db '1024'			; =)