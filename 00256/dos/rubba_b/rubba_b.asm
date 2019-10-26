; rubba by tmb

faces equ 4

.model tiny
.code
.386
                org     100h
start:          mov     al,13h
                int     10h
                
		mov	dh,80h
                mov     gs,dx           
                mov     dh,70h
                mov     es,dx
                mov     dh,60h
                mov     fs,dx

                fldz
@@gensine:
		fld	st
                fcos
                fimul   word ptr sinescale 
                fistp   word ptr gs:[bx]
                fadd    dword ptr sinestep        ; Next sine value
		inc	bx
		inc	bx
		jnz	@@gensine
		fstp	st

                xor     cx,cx
pal:            mov     dx,3C8h
                mov     al,cl
                out     dx,al
                inc     dx
                out     dx,al
                sar     al,1
                out     dx,al
                and     al,15
                out     dx,al
                loop    pal

tex:            mov     bx,cx
                rcl     dh,cl
                mov     ah,dh
                sar     ah,3
                adc     al,ah
                adc     al,fs:[bx+32]
                shr     al,1
                mov     fs:[bx],al
                loop    tex

again:          xor     ax,ax
                xor     di,di
                mov     ch,(64000/2)/256
                rep     stosw


                mov     bx,0
            rot equ $-2
                mov     word ptr yofs,160
                mov     dh,200
yloop:
                mov     dl,faces
next:           mov     ax,gs:[bx]
                add     bh,256/faces
                mov     bp,gs:[bx]

                mov     di,ax
                mov     cx,ax
                sub     cx,bp
                cmp     cx,0
                jnl     oo
                neg     cx
oo:             add     di,0beefh
           yofs equ $-2
                cmp     ax,bp
                jge     oo2
                mov     byte ptr col,cl
                push    bx
                push    dx
                mov     ah,256/faces
                cwd
                div     cx
                pop     dx
                mov     bp,ax
                mov     si,1234h
           tofs equ $-2
drawline:       add     si,bp
                mov     bx,si
                mov     bl,dh
                mov     al,fs:[bx]
                cbw
                imul    ax,42
                col     equ $-1
                mov     al,ah
                stosb
                loop    drawline
                pop     bx
oo2:
                add     byte ptr tofs+1,256/faces
                
                dec     dl
                jnz     next

                add     word ptr yofs,320
                mov     ax,gs:[1234h]
           sofs equ $-2
                sal     ax,1
                
                add     bx,ax
                add     word ptr sofs,2

                dec     dh
                jnz     yloop

                sub     byte ptr rot+1,3

                mov     dx,03dah        ; retrace
vert1:          in      al,dx
                test    al,8
                jnz     vert1
vert2:          in      al,dx
                test    al,8
                jz      vert2

                push    es
                push    es
                pop     ds
                push    0a000h
                pop     es
                xor     di,di
                xor     si,si
                mov     ch,(64000/4)/256+1
                rep     movsd
                pop     es
                push    cs
                pop     ds

                in      al,60h
                cbw
                dec     ax
                jnz     again
                mov     al,3h
                int     10h
		ret
sinestep:       dd      0.0001917476
sinescale:      dw      0050h
end start

