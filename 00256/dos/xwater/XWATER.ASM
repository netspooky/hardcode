                 .model   tiny
                 .code
                 .386
;****************************************************************************
;* A little water routine in 256 bytes!
;* This is compiled with tasm and linked with tlink. After that EXE2BIN is used!
;* (c)'97 Martin Hristov - Ancient Pain Inc. -> Bulgaria
;* This demo is specialy made for XMAS 256 bytes demo compo
;* Take a look at it and don't try to understand :)
;* see you on #coders! -> EFNET ofcs! ;)
;****************************************************************************
                 mov     ax,cs
                 add     ah,16
                 mov     es,ax
                 add     ah,16
                 mov     ds,ax
;-----------------------------------------------------------------------------
                 xor     si,si
                 mov     ax,13h
ll1:             mov     [si],ah
                 mov     es:[si],ah
                 dec     si
                 jnz     short ll1
                 int     10h
;-----------------------------------------------------------------------------
                 mov     cx,128
                 mov     dx,03c8h
                 mov     al,ah
                 out     dx,al
                 inc     dx
here:            call    opt
                 inc     si
                 loop    here
jere:            call    opt
                 dec     si
                 jns     short jere
;-----------------------------------------------------------------------------
mmt:             mov     cl,3
www:             push    cx
                 mov     bl,160
                 call    random
                 mov     bx,320
                 mov     si,bx
                 imul    dx,bx
                 mov     di,dx
                 call    random
                 add     di,dx
                 mov     bx,4
                 call    random
                 inc     dx
                 push    dx
                 mov     bl,90
                 call    random
                 sub     dx,45
;//////////////////////////////////////////////////////////////////////////////
                 pop     bx
                 mov     cx,bx
l123:            push    cx
                 push    di
kr1:             movzx   ax,byte ptr [di]
                 add     ax,dx
                 call    thecall
                 mov     [di],al
                 inc     di
                 loop    kr1
                 pop     di
                 pop     cx
                 add     di,si
                 dec     bx
                 jnz     short l123
                 pop     cx
                 loop    www
;----------------------------------------------------------------------------
                 mov     di,24135-15-15*320
                 mov     bl,80
                 mov     cl,bl
mm1:             stosb
                 mov     byte ptr es:[bx+di],cl
                 add     di,si
                 dec     bx
                 dec     bx
                 loop    mm1
;----------------------------------------------------------------------------
                 xor     di,di
morep:           movsx   ax,byte ptr [di-320]
                 movsx   dx,byte ptr [di+320]
                 add     ax,dx
                 movsx   dx,byte ptr [di-1]
                 add     ax,dx
                 movsx   dx,byte ptr [di+1]
                 add     ax,dx
                 sar     ax,1
                 movsx   dx,byte ptr es:[di]
                 sub     ax,dx
                 mov     dx,ax
                 sar     dx,6
                 sub     ax,dx
                 call    thecall
                 stosb
                 loop    morep
;----------------------------------------------------------------------------
                 push    ds
                 push    es
                 push    0a000h
                 pop     es
                 mov     dx,03dah
v123:            in      al,dx
                 test    al,8
                 je      short v123
                 dec     cx
                 rep     movsb
                 pop     ds
                 pop     es
                 mov     ah,1
                 int     16h
                 jz      mmt
                 mov     ax,3
                 int     10h
                 ret
;-----------------------------------------------------------------------------
random:          imul    eax,ebp,27021981
                 add     ax,1201
                 mov     ebp,eax
                 xor     dx,dx
                 div     bx
                 ret
;-----------------------------------------------------------------------------
opt:             mov     ax,si
                 shr     ax,2
                 out     dx,al
                 out     dx,al
                 shl     ax,1
                 out     dx,al
;-----------------------------------------------------------------------------
thecall:         cmp     ax,-127
                 jg      short xnd
                 mov     al,-127
xnd:             cmp     ax,127
                 jl      short xnd1
                 mov     al,127
xnd1:            ret
;-----------------------------------------------------------------------------
                 end
