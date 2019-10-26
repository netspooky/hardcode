.model tiny
.386
.387

.code
        org 100h

main    proc


        push    ds                      ;es = psp
        pop     es

        push    cs                      ;ds = code
        pop     ds


        mov     ah,4Ah                  ;release all but 64k
        mov     bx,1000h
        int     21h

        mov     ah,48h                  ;allocate       vidbuf1
        mov     bx,1000h                ;64k
        int     21h
        mov     vidbuf1,ax

        mov     ah,48h                  ;allocate       vidbuf
        mov     bx,1000h                ;64k
        int     21h
        mov     vidbuf,ax
        mov     es,ax

        call    cls


        mov     ax,0013h
        int     10h

        call    setpal

        fldpi
        fild    i180
        fdiv
        fstp    angleStep

        mov     ah,0                    ;init random seed
        int     1Ah                     ; to timer
        mov     word ptr r3[0],dx       ;
        mov     word ptr r3[2],cx       ;

restart:
        mov     outFlag,0
        mov     color,0

        fild    i160
        fstp    x
        fild    i100
        fstp    y







start:
        call    sprig
        cmp     outFlag,1
        jne     start


        call    average

        ;mov     di,0
        ;mov     al,250
        ;mov     es:[di],al

        call    rndpal
        call    setpal

        ;call    rotate


        mov     dx,3DAh                 ;vsync loop

vert2:
        in      al,dx
        test    al,8h
        jz      vert2
notvert2:
        in      al,dx
        test    al,8h
        jnz     notvert2


        push    ds
        push    es
        push    vidbuf ;vidbuf1
        pop     ds
        push    0A000h
        pop     es
        xor     si,si
        xor     di,di
        mov     cx,16000
        xor     eax,eax
        rep     movsd
        pop     es
        pop     ds


        ;call    showpal

keytest:
        mov     ah,1
        int     16h
        jnz     keyin



        jmp     restart



keyin:
        xor     ah,ah
        int     16h

        cmp     ah,1                    ;ESC, exit
        jne     k2
        jmp     xit
k2:
        cmp     ah,57                   ;SPACE, something...
        jne     k3

k3:

xit:
        mov     ax,0003h
        int     10h

        mov     ax,4C00h
        int     21h

main    endp


comment #
rotate  proc

        call    cls1

        push    es

        push    vidbuf1
        pop     es

        mov     ax,word ptr sy
        shl     ax,6
        mov     si,ax
        shl     ax,2
        add     si,ax
        add     si,word ptr sx

        xor     di,di

        push    vidbuf
        pop     fs

        mov     cx,200
rot1:
        push    cx


        mov     cx,320
rot2:
        mov     al,fs:[si]
        inc     si

        stosb

        loop    rot2






        pop     cx
        loop    rot1




        mov     ax,sx
        add     ax,sxf
        cmp     ax,0
        jl      rot12
        cmp     ax,319
        jg      rot12

        jmp     rot13

rot12:
        neg     sxf
        add     ax,sxf
rot13:
        mov     sx,ax


        mov     ax,sy
        add     ax,syf
        cmp     ax,0
        jl      rot14
        cmp     ax,199
        jg      rot14

        jmp     rot15

rot14:
        neg     syf
        add     ax,syf
rot15:
        mov     sy,ax




        pop     es
        ret
rotate  endp
#

average proc
        push    ds
        mov     ax,vidbuf
        mov     ds,ax

        xor     bh,bh
        xor     si,si
        mov     cx,64000
av1:
        xor     ax,ax
        mov     bl,[si]
        add     ax,bx
        mov     bl,[si-1]
        add     ax,bx
        mov     bl,[si-320]
        add     ax,bx
        mov     bl,[si-321]
        add     ax,bx

        mov     bl,4
        div     bl


        mov     [si],al

        inc     si
        loop    av1


        pop     ds
        ret
average endp

sprig   proc
        fld     x
        fistp   x1
        fld     y
        fistp   y1


        mov     r2,10
        call    rnd
        mov     radius,cx

        mov     r2,360
        call    rnd
        mov     angleFactor,cx


        fld     angleStep
        fild    angleFactor
        fmul
        fild    i005
        fmul
        fadd    angle
        fst     angle
        fsin
        fild    radius
        fmul
        fadd    x
        fstp    x

        fld     angle
        fcos
        fild    radius
        fmul
        fadd    y
        fstp    y


        fld     x
        fistp   x2
        fld     y
        fistp   y2

        call    line

        ret
sprig   endp


rnd     proc    near            ;call w/ r1 = lower limit  r2 = upper limit
        push    ax              ;        r3 and r3a = dword seeds
        push    dx
        mov     ecx,r3          ;seed
        add     ecx,249D62E4h   ;add some weird #
        ror     ecx,12          ;ror to obscure further
        push    r3a             ;exchange seeds
        pop     r3
        mov     r3a,ecx         ;new seed

        mov     ax,r2           ;upper        * adjust to input values *
        sub     ax,r1           ; - lower
        mul     cx              ; * seed
        mov     cx,dx           ;whole part
        add     cx,r1           ; + lower
        pop     dx
        pop     ax
        ret                     ;return w/ cx = rnd number r1 - r2
rnd     endp


line    proc    near                    ;call with x1,y1 = point 1
        push    bx                      ;          x2,y2 = point 2
        push    cx                      ;          color = color
        push    dx
        push    si
        push    di
        push    ax

        mov     outFlag,0


        mov     si,1
        mov     di,1
        mov     dx,y2
        sub     dx,y1
        jge     storey
        neg     di
        neg     dx
storey:
        mov     deldy,di
        mov     cx,x2
        sub     cx,x1
        jge     storex
        neg     si
        neg     cx
storex: mov     deldx,si
        cmp     cx,dx
        jge     setdiag
        mov     si,0
        xchg    cx,dx
        jmp     storedelsxy
setdiag:
        mov     di,0
storedelsxy:
        mov     dels,cx
        mov     delp,dx
        mov     delsx,si
        mov     delsy,di
        mov     si,x1
        mov     di,y1
        mov     ax,delp
        sal     ax,1
        mov     delse,ax
        sub     ax,cx
        mov     bx,ax
        sub     ax,cx
        mov     delde,ax
        inc     cx
        mov     dx,color
lineloop:
        call    pset
        cmp     outFlag,1
        je      lineexit

        cmp     bx,0
        jge     diagonal
straight:
        add     si,delsx
        add     di,delsy
        add     bx,delse
        loop    lineloop
        jmp     lineexit
diagonal:
        add     si,deldx
        add     di,deldy
        add     bx,delde
        loop    lineloop

lineexit:


        pop     ax
        pop     di
        pop     si
        pop     dx
        pop     cx
        pop     bx
        ret
line    endp


pset    proc    near
        push    ax
        push    bx

        cmp     di,0
        jl      psetOut
        cmp     di,199
        jg      psetOut
        cmp     si,0
        jl      psetOut
        cmp     si,319
        jg      psetOut

        mov     ax,di
        shl     ax,6
        mov     bx,ax
        shl     ax,2
        add     bx,ax
        add     bx,si

        inc     color
        inc     dl
plotit:
        mov     es:[bx],dl

psetx:
        pop     bx
        pop     ax
        ret
psetOut:
        mov     outFlag,1
        jmp     psetx

pset    endp


cls     proc
        xor     di,di

        mov     cx,16384
        xor     eax,eax
        rep     stosd

        ret
cls     endp

comment#
cls1    proc
        push    es
        push    vidbuf1
        pop     es

        xor     di,di

        mov     cx,16384
        xor     eax,eax
        rep     stosd

        pop     es
        ret
cls1    endp
#

rndpal  proc
        mov     r2,3
        call    rnd


rndpal1:
        mov     bx,offset redf
        shl     cx,1
        add     bx,cx

        mov     r2,5
        call    rnd
        sub     cx,2
        neg     cx

        mov     ax,[bx]
        add     ax,cx

        cmp     ax,0
        jl      rndpal3
        cmp     ax,64
        jg      rndpal3

        jmp     rndpal4

rndpal3:

        sub     ax,cx
        sub     ax,cx

rndpal4:
        mov     [bx],ax



        ret
rndpal  endp

setpal  proc

        mov     red,0
        mov     green,0
        mov     blue,0

        mov     al,0                     ;set palette
        mov     bl,0
        mov     dx,3C8h
        out     dx,al

        inc     dx

        mov     cx,255
sp1:
        mov     al,byte ptr red[1]
        out     dx,al
        mov     al,byte ptr green[1]
        out     dx,al
        mov     al,byte ptr blue[1]
        out     dx,al

        mov     ax,redf
        add     red,ax
        mov     ax,greenf
        add     green,ax
        mov     ax,bluef
        add     blue,ax

        loop    sp1





        ret
setpal  endp

comment #
showpal proc
        push    ds
        push    0A000h
        pop     ds

        mov     si,320*197
        xor     al,al
        mov     cx,256
showpal1:
        mov     [si],al
        mov     [si+320],al
        mov     [si+640],al
        inc     al
        inc     si
        loop    showpal1

        pop     ds
        ret
showpal endp
#

;.data


angle   dd      0.0
angleStep dd    0.0

sx      dw      0
sy      dw      0
sxf     dw      1
syf     dw      1

radius  dw      10

i005    dw      5
i100    dw      50  ;100
i160    dw      80  ;160
i180    dw      180

r1      dw      0                       ;lower limit
r2      dw      100                     ;upper limit   *returns 0-99 rnd*
r3      dd      0                       ;seed 1
r3a     dd      0                       ;seed 2



redf    dw      64
greenf  dw      32
bluef   dw      32

red     dw      ?
green   dw      ?
blue    dw      ?

angleFactor dw  ?




x       dd      ?
y       dd      ?


x1      dw      ?                       ;line sub variables
y1      dw      ?
x2      dw      ?
y2      dw      ?
deldy   dw      ?
deldx   dw      ?
dels    dw      ?
delp    dw      ?
delse   dw      ?
delde   dw      ?
delsx   dw      ?
delsy   dw      ?

vidbuf1 dw      ?
vidbuf  dw      ?

color   dw      ?

colrtab db      768 dup (?)

outFlag db      ?

        end     main
