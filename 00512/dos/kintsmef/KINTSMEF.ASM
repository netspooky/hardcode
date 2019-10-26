; KIntSmEf (KiLLeR Integer Smoothing Effects)
; a complex 512b intro for asmcompo#10-2004 (and for fun) bY
; -=* thE /P.A.P.+O./ (BraiN)KiLLeR *=-
; [Src in NBASM 00.24.00 free beta]
; History:
; 2004.09.19 15:00+5H	 Assembled main from:
;            CSIGAEG1+BTSINC4+1LESSAVG+ASCDECO1
.model tiny
.optof
.186
.code
 org	100h	; 148h to be exact
 mov	al,13h
 int	10h
;
; part 0
 mov	dx,(happy+72)
 mov	ah,9
 int	21h
 mov	dx,3dah
 mov	cl,0ffh
p0l0
 call	vsync
 loop	p0l0
;
; part 1
 mov	di,[bx] ; di=start point
 push	0a000h
 pop	es
 mov	bl,91h  ; bx=length
p1l0
 mov	si,1
 test	bx,si
 jz	p1s0
 mov	si,320
p1s0
 test	bl,2
 jz	p1s1
 neg	si
p1s1
 mov	cx,bx
p1l1
 inc	byte es:[di]
 add	di,si
 test	cl,3
 jnz	p1s2
 call	vsync
p1s2
 loop	p1l1
 sub	bx,5
 jnz	p1l0
;
; part 2
 call	blitx
p2l0
 mov	bp,200
p2l1
 mov	si,1280
 xor	di,di
 call	blitn
p2l2
 mov	al,7
 add	al,bl
 and	al,es:[di]
 dec	al
 xor	al,bl
 js	p2s0
 inc	byte [di+1279]
 inc	byte [di+1281]
 inc	byte [di+960]
 inc	byte [di+1600]
p2s0
 inc	di
 loop	p2l2
 dec	bp
 jnz	p2l1
 add	bl,252
 jnc	p2l0
 xor	ax,ax
 mov	di,63680
 mov	cx,2176
 rep
 stosb
;
; part 3
 mov	bl,1
 mov	bp,400
p3l0
 call	blitx
 xor	ah,ah
p3l1
 mov	al,[di+1279]
 add	al,[di+1281]
 adc	ah,0
 add	al,[di+960]
 adc	ah,0
 add	al,[di+1600]
 adc	ah,0
 shr	ax,2
 sub	al,bl
 stosb
 loop	p3l1
; mov	es:[32160],bl
 dec	bp
 jnz	p3l0
 mov	bp,120
 dec	bx
 jz	p3l0
p4
;
; part 4
 mov	bp,400
p4l0
 call	blitx
p4l1
 lea	si,[di+959]
 lodsb
 add	al,[si]
 add	al,[si+1]
 lea	si,[di+1599]
 add	al,[si]
 add	al,[si+1]
 add	al,[si+2]
 add	al,[di+1279]
 add	al,[di+1281]
 and	al,15
 sub	al,4
 jz	p4s1
 cmp	al,2
 jz	p4s0
 xor	al,al
p4s0
 mov	es:[di],al
p4s1
 inc	di
 loop	p4l1
 dec	bp
 jnz	p4l0
;
;
exit
 mov	ax,0003h
 int	10h
 int	20h
blitx
 xor	si,si
 mov	di,1280
blit
 push	es
 push	ds
 pop	es
 pop	ds
blitn
 mov	cx,32000
 rep
 movsw
 mov	cx,63360	; 320*198
 cmp	di,si
 jc	blit_e
 push	es
 push	ds
 pop	es
 pop	ds
blit_e
 mov	di,320
vsync
vsync1
 in	al,dx
 and	al,8
 jnz	vsync1
vsync2
 in	al,dx
 and	al,8
 jz	vsync2
 mov	ah,11
 int	21h
 test	al,al
 jz	vsynd
 mov	ah,7
 int	21h
 jmp	short exit
vsynd
 ret
happy db 13,10," th1s'll maek yA ",2,".$"
.end
