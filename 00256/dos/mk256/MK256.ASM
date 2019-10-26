;This is my submission to the 256 byte fire compo...
;It's also (c)Copyright MrKite, 1996
;mrkite@acid.org
;or find me on #coders as mrk or mrkay

        .model  tiny
	.386

	.data

cnt     dw      0               ;this is for timing the ending clear
fireof  dw      81              ;this is for the ending clear
rand1   dw     1234h
rand2   dw     4321h
pad     dd      0               ;pad it to 256 bytes

	.code

        org     100h
main    proc
start:

        ;;;set the video mode;;;
	mov     ax,13h
	int     10h
	mov     dx,3c4h
	mov     ax,604h
	out     dx,ax
	mov     ax,0f02h
	out     dx,ax
	mov     dx,3d4h
	mov     ax,14h
	out     dx,ax
	mov     ax,0e317h
	out     dx,ax
	mov     al,9
	out     dx,al
	inc     dx
	in      al,dx
	and     al,0e0h
	add     al,7
	out     dx,al

        ;;;set the palette;;;
        mov     dx,3c8h
	xor	ax,ax
	out	dx,al
	inc	dx
        mov     cx,128
pallp:
        push    ax
        shr     al,1
        out     dx,al
        shr     al,2
        out     dx,al
        shr     al,1
        out     dx,al
        pop     ax
	inc	al
        loop    pallp

        push    0a000h
        pop     es

        ;;;main loop;;;
firelp:
	mov     cx,4399
        mov     di,80
bufr1:
        mov     ax,es:[di-1]            ;angle the flame
        add     al,ah
        shr     al,1                    ;average top two
        mov     bx,es:[di+80]
        add     bl,bh
        shr     bl,1                    ;average bottom two
        add     al,bl
        shr     al,1                    ;average top/bottom
        jz      bufr2
	dec     al
        jz      bufr2
        dec     al
bufr2:
	mov     bx,di
	sub     bx,fireof
        mov     es:[bx],al
	inc     di
	loop    bufr1

        cmp     cnt,0
        jg      blowflame

        mov     ah,1
        int     16h
        jz      ok
        inc     cnt
ok:
	xor     dl,dl
        mov     di,4320
	mov     cx,80
newline:

        ;;;get random;;;
        in      al,40h
        add     ax,rand1
        mov     bx,ax
        add     ax,rand2
        mov     rand2,bx
        xchg    al,ah
        mov     rand1,ax

        and     al,1
	dec     al
	mov     dl,al

        mov     es:[di],dl
        mov     es:[di+80],dl
	inc     di
	loop    newline
        jmp     doloop
blowflame:
        inc     cnt
        cmp     cnt,50  ;kill flame?
        jge     killflame
        dec     fireof
        jmp     doloop
killflame:
	xor     ax,ax
        mov     di,4320
	mov     cx,80
fllp:
        mov     es:[di],ax
	add     di,2
	dec     cx
	jne     fllp
doloop:
        mov     dx,3dah
vt:     in      al,dx
	test    al,8
	jnz     vt
nvt:    in      al,dx
	test    al,8
	jz      nvt

        cmp     cnt,60  ;quit?
        jne     firelp

        mov     ax,3
        int     10h
	mov     ax,4c00h
	int     21h
main    endp

	end     start
