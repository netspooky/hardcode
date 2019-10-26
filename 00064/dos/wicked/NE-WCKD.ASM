;
; WICKED - 45b demo
; insomniac/neon 2002
;
.model tiny
.386
.code
org     100h
main:
	lds     bp,[bx]
	mov     al,13h
	int     10h
      
mainloop:
	mov     cl,200
	xor     di,di
	xchg    dx,ax

yloop:
	mov     ax,320
xloop:
	add     dx,cx
	add     dh,al		; change to SUB for other texture

	mov     ds:[di],dh

	inc     di
	dec     ax
	jnz     xloop
	loop    yloop


	mov     dx,03c9h
pal1:
	mov     cl,63
pal2:
	out     dx,al
	out     dx,al
	out     dx,al
	inc     ax
	loop    pal2
	
pal3:
	out     dx,al
	out     dx,al
	out     dx,al

	dec     ax
	jnz     pal3
	
;	in      al,60h
;	dec     ax
;	jnz     mainloop
jmp	mainloop

;	mov     al,3
;	int     10h

;	ret
	
end     main