;		GLASENAPY.ASM

.model tiny
.code
.386
		org     100h
n equ 10

start:
                mov     ax,13h
                int     10h
		
		mov	dx,3C8h
		mov	al,248
		out	dx,al
		inc	dx
		xor	al,al
		mov	cx,24
m0:
		out	dx,al
		loop	m0

m1:
		push    ds
                pop     es

                mov     cx,n*2
		mov	dx,320
                mov     di,offset koord
m2:
                mov     ax,[di]
                add     ax,[di+n*4]
                cmp     ax,dx
                jb	short m3
                neg     word ptr [di+n*4]
m3:
                stosw
		xor	dx,392
                loop    m2

                xor     bp,bp	;Y
		mov	di,offset buffer
m8:
		push	di
		mov	si,offset koord
		mov	di,offset u
		mov	cx,n
m9:
		lodsw		;Xn
		movsx	eax,ax
		push	eax
		db	66h
		imul	ax,ax
		push	eax
		lodsw		;Yn
		sub	ax,bp	;Yn-Y
		movsx	eax,ax
		db	66h
		imul	ax,ax

		pop	ebx
		add	eax,ebx	;(Yn-Y)^2+Xn^2=
		stosd		;=Un
		pop	eax
		add	eax,eax
		neg	eax
		inc	eax	;1-2*Xn=
		stosd		;=DUn
		loop	m9

		pop	di
                mov	cx,320
m4:
		push	cx
		mov	cl,n
		mov	si,offset u
		mov	ebx,-1
m5:
		lodsd
		cmp	ebx,eax
		jb	m6
		mov	u1,ebx
		mov	col,ch		
		mov	ebx,eax
		mov	ch,cl				
		jmp	m10
m6:
		cmp	eax,u1
		jae	m10
		mov	u1,eax
		mov	col,cl
m10:
		mov	edx,eax
		lodsd			     ; DU
		add	edx,eax
		mov	dword ptr [si-8],edx ;U=U+DU
		add	eax,2
		mov	dword ptr [si-4],eax ;DU=DU+2
		dec	cl
		jnz	m5
		
		xor	edx,edx
                mov     eax,ebx
		shl	eax,8
		inc	u1
		div	u1
m7:                
		stosb
		pop	cx
		loop	m4

		inc	bp
		cmp	bp,200
		jb	m8

                push    0A000h
                pop     es
                mov     si,offset buffer 
		xor	di,di
                mov     cx,16000
                rep     movsd
		      
		in	al,60h
		dec	al
                jnz     m1
		mov	ax,3
		int	10h
		retn

koord	        dw      120, 132, 200, 70, 140, 30, 6, 98, 50, 44, 10, 192
                dw	16, 74, 258, 136, 300, 74, 212, 28 

		dw      2, 1, -2, 1, 1, 2, -2, 1, 1, -2, -1, 2
		dw	1, -1, 2, 2, -1, -2, 2, -1

col	db ?
u1	dd ?
u		dd	n*2 dup (?)	 
buffer          db      320*200 dup (?)     

end     start