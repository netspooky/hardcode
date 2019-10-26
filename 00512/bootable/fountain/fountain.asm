; code by wasiliy
struc p3d
X3 resw 1
Y3 resw 1
Z3 resw 1
endstruc

struc p2d
 X2 resw 1
 Y2 resw 1
endstruc

struc object
 X resw 1
 Y resw 1
 Z resw 1
 new_X resw 1
 new_Y resw 1
 new_Z resw 1
 t resd 1
 alphaXY resw 1
 alphaXZ resw 1
 frame resw 1
 active resb 1
endstruc

struc RGB
 R resb 1
 G resb 1
 B resb 1
endstruc

%MACRO _pix 3
        imul    bx,word %2,320
        add     bx,%1
        mov     byte [bx+buffer],%3
%endmacro

%MACRO _throw 0

        mov     si,point
        mov     dx,POINTS_PER_RAY
%%lp1:

        mov     cx,AMOUNT
%%lp:
        fld     dword [pi_div_180]
        fld     st0
        fimul   word [si+alphaXZ]
        fstp    dword [alpha_radXZ]
        fimul   word [si+alphaXY]
        fst     dword [alpha_radXY]

        fcos
        fld     dword [alpha_radXZ]
        fcos
        fimul   word [v]
        fmul    dword [si+t]
        fmul    st0,st1
        fild    word [d]
        fidiv   word [s]
        fsin
        fmul    dword [agilty]
        fimul   word [v]
        fmul    dword [si+t]
        faddp   st1,st0 
        fistp   word [si+new_X]

        fld     dword [alpha_radXZ]
        fsin
        fimul   word [v]
        fmul    dword [si+t]
        fmulp   st1,st0
        fiadd   word [si+Z]
        fistp   word [si+new_Z]

        fld     dword [alpha_radXY]
        fsin
        fmul    dword [si+t]
        fimul   word [v]
        fld     dword [si+t]
        fmul    st0
        fimul   word [g2]
        fsubp   st1,st0
        fchs
        fistp   word [si+new_Y]

        cmp     byte [si+active],1
        jnz     %%dont_move
        fld     dword [si+t]
        fadd    dword [t_add]
        fstp    dword [si+t]
        inc     word [si+frame]
        cmp     dx,1
        jz      %%dont_move
        cmp     word [si+frame],25
        jnz     %%dont_move
        mov     byte [si+active+NEXT],1
%%dont_move:

        cmp     word [si+new_Y],10
        jl      %%dont_reset
        fldz
        fstp    dword [si+t]
        mov     word [si+frame],0
%%dont_reset:

        add     si,object_size
        dec     cx
        jnz     %%lp

        dec     dx
        jnz     %%lp1

%ENDMACRO

%MACRO _convert_3D_to_2D 1

        imul    ax,word [si+X],256
        cwd
        idiv    word [si+Z]
        add     ax,160
        mov     word [di+X],ax

        imul    ax,word [si+Y],256
        cwd
        idiv    word [si+Z]
        add     ax,75
        mov     word [di+Y],ax

%ENDMACRO

%MACRO _show_points 2
        mov     si,point+new_X
        mov     di,point2d
        mov     cx,%1

%%lp:
        _convert_3D_to_2D 6
        _pix [di+X],[di+Y],%2
%%dont_show:
        add     si,object_size
        add     di,p2d_size

        dec     cx
        jnz     %%lp
%ENDMACRO


%MACRO _setnew 0
        xor     ax,ax
        xor     bx,bx

        mov     cx,63


        mov     dx,3C8h
        out     dx,al
        inc     dx
%%lp:
                mov     al,ah
                and     al,bl
                out     dx,al
                mov     al,ah
                and     al,ch
                or      al,bh
                out     dx,al
                mov     al,ah
                or      al,ch
                out     dx,al

                inc     ah

        dec     cl
        jnz     %%lp

        or      bl,bl
        jnz     %%done

        or      bl,bh
        or      bh,ch
        dec     ch
        mov     cl,64

        jmp     %%lp
%%done:
       
%ENDMACRO

%MACRO _smudge 2
                mov     di,%1
%%slp:
                movzx   dx,[di-1]
                movzx   ax,[di+1]
                add     dx,ax
                mov     al,[di+320]
                add     dx,ax
                mov     al,[di-320]
                add     dx,ax
                shr     dx,2

                or      dl,dl
                jz      short %%nodec
                dec     dl

%%nodec:
                mov     [di],dl
                inc     di
                cmp     di,%2
                jnz     %%slp  
%ENDMACRO

%MACRO _waitretrace 0
        mov     dx,3DAh
%%l1:
        in      al,dx
        test    al,08h
        jz      %%l1
%%l2:
        in      al,dx
        test    al,08h
        jnz     %%l2
%ENDMACRO

%MACRO _copy_block 1
        mov     si,buffer
        xor     di,di
        mov     cx,%1
        rep     movsd
%ENDMACRO

%MACRO _clear_block 1
        push    ds
        pop     es
        mov     di,buffer
        mov     cx,%1
        xor     eax,eax
        rep     stosd
%ENDMACRO

%MACRO _init_points 1
       
        mov     si,point
        mov     cx,%1
        mov     ax,360
        xor     edx,edx
        mov     bl,1
%%lp:
        mov     dword [si+X],edx
;        mov     word [si+Y],dx
        mov     word [si+Z],200
        mov     word [si+frame],dx

        mov     dword [si+t],edx

        mov     word [si+alphaXY],80
        mov     word [si+alphaXZ],ax
        mov     byte [si+active],bl


        sub     ax,ANGLE
        jns     %%dont_refresh        
        mov     ax,360
        xor     bx,bx
%%dont_refresh:
        add     si,object_size
        dec     cx
        jnz     %%lp

%ENDMACRO


%MACRO REPEAT_UNTIL_ESC 1
 in     al,60h
 dec    al
 jnz    %1
%ENDMACRO



ANGLE equ 30
AMOUNT equ 360/ANGLE
POINTS_PER_RAY equ 16
NEXT equ object_size*AMOUNT

        bits    16
        org     0
main:
        cli
        mov    ax,07C0h
        mov    ds,ax

        mov     ax,0a000h
        mov     es,ax
        sti


        fninit

        mov     ax,13h
        int     10h
        mov     dx,3d4h
        mov     ax,0309h
        out     dx,ax


        _setnew

;        _clear_block 8000
        _init_points AMOUNT*POINTS_PER_RAY
lp:
        _throw
        _show_points AMOUNT*POINTS_PER_RAY,130
        _smudge buffer-320*6,buffer+33679+320
        _copy_block 8000
        _waitretrace

        inc     word [d]


        REPEAT_UNTIL_ESC lp

        jmp     0FFFFh:0

g2 dw 5
s dw 50
v dw 32
pi_div_180 dd 0.017453292
t_add dd 0.05
agilty dd 0.35

times   510-($-$$) db 0
dw 0AA55h


section .bss
d: resw 1
alpha_radXY: resd 1
alpha_radXZ: resd 1

pal: resb 3

point: resb object_size*AMOUNT*POINTS_PER_RAY
point2d: resb p2d_size*AMOUNT*POINTS_PER_RAY
placeholder: resb 320*8
buffer: resb 64000


