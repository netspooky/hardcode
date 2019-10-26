;   _________  _______  ________  ______    __  _______
;  /__   ___/ / _____/ /__  ___/ / ____ \  / / / _____/
;     / /    / /____     / /    / /___/ / / / / /____
;    / /    / _____/    / /    / __   _/ / / /____  /
;   / /    / /____     / /    / /  \ \  / / _____/ /
;  /_/    /______/    /_/    /_/   /_/ /_/ /______/
;
;
;  256 byte tetris game by megasys
;  <megasys@intro.hu>
;
;  Released at Flag2oo2 party (Hungary)
;  http://flag2002.demoscene.hu
;
;  Missing features:
;  - game over check
;  - quick drop

; Matrix reduced size to 249 bytes
; -Added game over check code (7 bytes)
org 100h
use16

short equ byte
SCREEN_HEIGHT equ	20
STACK_WIDTH   equ	10
SHAPE_CHAR    equ	219			     ; 219 = filled block
SPEED	      equ	20			     ; VGA VSYNC/down
VIDEO_MODE    equ	1
SCREEN_WIDTH  equ	40
; SS = DS = CS, de csak ha a Csink is ugy akarja
	      mov bh,$b8
	      mov es,bx
exit666:      mov	ax, VIDEO_MODE
	      int	10h			     ; text mode (kivéve, ha valamelyik barom fent átírta)
newshape:     xor	ax, ax
	      mov	si, ax
	      mov	di, word STACK_WIDTH - 2     ; kozepen
rndloop:      in	al, 40h 		     ; PIT counter = rnd :)
	      cmp	al, 5			     ; nekunk 0..5 kell
	      ja	rndloop
	      mov	bx,ax
	      mov	al,byte [shapes + bx]
	      mov	bp,ax
	      shl	bp,4			    ; BP-ben a shape
	      add	al,9
	      mov	bh,al			    ; BH-ben a color
	      mov	bl,SHAPE_CHAR
;  Jatekterulet falainak kirajzolasa, es a teli sorok eltuntetese
	      pusha
	      xor	di, di
sorok:	      mov	ax, 8*256 + SHAPE_CHAR
	      stosw				     ; es bal oldali fal lesz belole
	      mov	cl, STACK_WIDTH
	      mov	dl, cl
scan:	      scasw
	      sbb	dl,0
	      loop	scan
	      stosw				     ; meg jobb oldali fal
	      and	dl, dl			     ; tele van-e a sor?
	      jnz	nincstele		     ; mert ha igen, akkor a folotte levoket egyel lejebb kell huzatni
	      push	di			     ; scrollozzunk
	      lea	si, [di - SCREEN_WIDTH * 2]
	      std				     ; visszafele megyunk
	      mov	cx, si			     ; 0-ig
	      rep	es movsb		     ; hajra
	      cld
	      pop	di
nincstele:    lea	di, [di + (SCREEN_WIDTH - STACK_WIDTH  - 2) * 2];add di,(SCREEN_WIDTH - STACK_WIDTH  - 2) * 2
	      cmp	di, SCREEN_WIDTH * 2 * SCREEN_HEIGHT
	      jc	sorok
	      mov	cl, STACK_WIDTH + 2
	      rep	stosw
	      popa
;  Game loop
	      mov	dx,3dah
gameloop:     mov	cl,SPEED
retrace:      and	si,si
	      jnz	newshape
retrace_in:
;.v1:in al,dx   ; 8 bytes to wait for half retrace
;    and al,8
;    jnz .v1
.v2:in al,dx
    and al,8
jnz	  retrace_in
noretrace:    mov	ah, 1
	      int	16h
	      jz	nincsgomb
	      xor	ah,ah
	      int	16h
	      cmp	al,27
	      jz       exit666-1
noexit:       sub	al,"j"
	      cmp	al,3
	      jnc	nemjogomb
	      dec	ax
	      shl	al,1
	      cbw				     ; ezt az AX-et kell majd a DI-hez adni
mozgatas:     push	ax			     ; letoroljuk a shape-t
	      mov	ax,word SHAPE_CHAR
	      call	drawshape
	      pop	ax
	      push	di			     ; eredeti pozicio
	      push	bp			     ; es alakzat mentese
	      add	di,ax			    ; muveletek: mozgatas
	      and	ax,ax
	      jnz	nemforgat
;  abcdefgh jklmnopq -> dhmqcglp bfkoaejn -> ndhmqcgl pbfkoaej
	      push	cx			     ; muveletek: forgatas
	      mov	cl,16
	      mov	ax,1111h		    ; ez jelzi, hogy hol kell visszaforgatni 1-et...
forgatas:     rol	bp,4
	      rcl	ax,1
	      jnc	forgatas2		     ; ...itt kell ;)
	      ror	bp,1
forgatas2:    loop	forgatas
	      ror	ax,1
	      mov	bp,ax
	      pop	cx
nemforgat:    xor	ax,ax			    ; collision check mode
	      call	drawshape
	      and	ah,8
	      jz	nocoll
	      pop	bp			     ; eredeti alakzatok visszatoltese
	      pop	di
	      cmp	di,SCREEN_WIDTH ; game over detect
	      jbe	 exit666-1
	      jmp	short nincsgomb
nocoll:       xor	si,si
	      pop	ax
	      pop	ax
nincsgomb:    mov	ax,bx
	      call	drawshape
nemjogomb:    in	al,dx
	      and	al,8
	      jz	noretrace
	      dec	cx
	      cmp	cl, 1
	      jnz	nemmegy
	      mov	ax, SCREEN_WIDTH * 2
	      inc	si
	      jmp	short mozgatas
nemmegy:      or	cl,cl
	      jnz	retrace
	      jmp	short gameloop
;  Shape kirajzolasa
;  IN: BP = Shape; DI = Position; AX = Color + Character
;      AX = 0 -> collision check mode
;      AH = 0 -> fekete szin (gyk. erase mode), az AL-ben a karakter
;  OUT: collision check mode:
;      AH = 0 -> no collision
;       other -> collision
;  REG DESTROY: NONE
drawshape:    push	di
	      push	cx
	      mov	cl, 4
loop_row:     push	cx
	      mov	cl, 4
loop_col:     rol	bp, 1
	      jnc	nemrajzol
	      and	al,al
	      jz	draw_collisioncheck
	      mov	[es:di], ax
draw_collisioncheck:
	      or	ah, byte [es:di+1]
nemrajzol:    scasw
	      loop	loop_col
	      pop	cx
	      lea	di, [di + (SCREEN_WIDTH - 4) * 2]
	      loop	loop_row
	      pop	cx
	      pop	di
	      ret
; middle two rows (of 4)
shapes	      db	01110100b	; 0 = L
	      db	01110001b	; 1 = J
	      db	00110110b	; 2 = s
	      db	01100011b	; 3 = z
	      db	01110000b	; 4 = I
	      db	01110010b	; 5 = T