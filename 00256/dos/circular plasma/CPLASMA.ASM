                .model tiny
                .code
                .386
                .startup
begin:
                mov     bl,10h        
                push    cs
                pop     ax
                add     ah,bl
                mov     gs,ax           ; radius table  
                add     ah,bl
                mov     fs,ax           ; angles table
                mov     es,ax
                add     ah,bl
                push    ax              ; texture

                xor     eax,eax
                xor     di,di
                mov     bx,200
 TDown:
                mov     cx,320
 TRight:
                mov     ax,bx
                sub     ax,100
                mov     Y,ax
                mul     ax
                mov     es:[di],eax
                mov     ax,cx
                sub     ax,160
                mov     X,ax
                mul     ax
                add     es:[di],eax
                fild    dword ptr es:[di]   
                fsqrt
                fistp   word ptr gs:[di]
                fild    X
                fild    Y
                fpatan
                fmul    Pi256
                fistp   word ptr es:[di]
                inc     di
                loop    TRight
                dec     bx
                jne     TDown
                
                mov     ax,13h
                int     10h

                xor     di,di
                pop     ax
                mov     es,ax           ; es -> texture
                push    es

                xor     al,al
                mov     dx,3c8h
                out     dx,al
                inc     dx
                mov     bx,256
GenTex1:
                mov     Tmp,bx
                call    Wave

                mov     ax,Tmp
                push    ax
                out     dx,al
                cmp     bl,62
                ja      Skip1
                mov     ax,Tmp
                shr     al,1
Skip1:
                out     dx,al
                cmp     bl,124
                ja      Skip2
                xor     al,al
Skip2:
                out     dx,al
                pop     ax
                mov     cx,256
GenTex2:
                push    ax
                mov     Tmp,cx
                call    Wave
                add     ax,Tmp
                add    ax,cx 
                stosb
                pop     ax
                loop    GenTex2
                dec     bx
                jnz     GenTex1

                pop     ds
                push    0a000h
                pop     es
MainLoop:
                xor     di,di
Extract:
                mov     bh,gs:[di]             ; radius
                mov     bl,fs:[di]             ; angle
                mov     al,ds:[bx]             ; extract texure pixel
                add     bl,cl
                add     al,ds:[bx]
                stosb
                cmp     di,64000
                jb      Extract

                inc     cx

                mov     dx,3dah
 retrace:
                in      al,dx
                test    al,8
                jz      retrace

                in      al,60h
                dec     al
                jne     MainLoop

                mov     ax,3
                int     10h

                mov     ah,4ch
                int     21h

 Wave:
                fild    Tmp
                fmul    Ang_i
                fsin
                fimul   Amp
                fiadd   Amp
                fistp   word ptr Tmp
                ret

Pi256   dd      81.49                 
Ang_i   dd      0.098                  
Amp     dw      31
X       dw      ?
Y       dw      ?
Tmp     dw      ?


                end begin
                
