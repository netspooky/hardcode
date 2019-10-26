



GetUVTunnel  PROC


        finit

        fild small t_x     ;xd=t_x-160;
        fisub small t160
        fstp small xd

        fild small t_y
        fisub small t100   ;yd=t_y-100
        fstp small yd

        fld small zd0
        fstp small zd

;             xdir=xd*cosAC-yd*sinAC
;             ydir=yd*cosAC+xd*sinAC

                fld small dword ptr xd
                fmul small dword ptr cosAC
                fld small dword ptr yd
                fmul small dword ptr sinAC
                fsub
                fstp small dword ptr xdir

                fld small dword ptr yd
                fmul small dword ptr cosAC
                fld small dword ptr xd
                fmul small dword ptr sinAC
                fadd
                fstp small dword ptr ydir

;              yd=ydir*cosAA-zd*sinAA;
;              zd=ydir*sinAA+zd*cosAA;

                fld small dword ptr ydir
                fmul small dword ptr cosAA
                fld small dword ptr zd
                fmul small dword ptr sinAA
                fsub
                fstp small dword ptr yd

                fld small dword ptr ydir
                fmul small dword ptr sinAA
                fld small dword ptr zd
                fmul small dword ptr cosAA
                fadd
                fstp small dword ptr zd

;              zdir=zd*cosAB-xdir*sinAB;
;              xdir=zd*sinAB+xdir*cosAB;

                fld small dword ptr zd
                fmul small dword ptr cosAB
                fld small dword ptr xdir
                fmul small dword ptr sinAB
                fsub
                fstp small dword ptr zdir

                fld small dword ptr zd
                fmul small dword ptr sinAB
                fld small dword ptr xdir
                fmul small dword ptr cosAB
                fadd
                fstp small dword ptr xdir

;      ydir=yd;

                fld small dword ptr yd
                fstp small dword ptr ydir

;      len=sqrt(xdir*xdir+ydir*ydir+zdir*zdir);
;      xdir /= len;              ;hallamos el vector unitario direccion
;      ydir /= len;
;      zdir /= len;

                fld1
                fld     small dword ptr xdir
                fmul    st,st
                fld     small dword ptr ydir
                fmul    st,st
                faddp   st(1),st
                fld     small dword ptr zdir
                fmul    st,st
                faddp   st(1),st

                fsqrt                   ;calcula el m¢dulo del vector
                fdivp   st(1),st             ;st(0)=1/sqrt(xdir*xdir+ydir*ydir+zdir*zdir)

                fld     small dword ptr xdir
                fmul    st,st(1)
                fstp    small dword ptr xdir           ;primera componente

                fld     small dword ptr ydir
                fmul    st,st(1)
                fstp    small dword ptr ydir         ;segunda componente

                fld     small dword ptr zdir
                fmul    st,st(1)
                fstp    small dword ptr zdir         ;tercera componente
                fstp    st              ;quitar el modulo del vector de la pila


;              a=xdir*xdir+ydir*ydir;

                fld     small dword ptr xdir
                fmul    st,st
@mod3:          db 090h,090h   ;fpatan d9 f3
                fld     small dword ptr ydir
                fmul    st,st
@mod3_:         db 090h,090h   ;fcos d9 ff
                fadd
                fstp    small dword ptr _a


;              b=2*(xorig*xdir + yorig*ydir);

                fld     small dword ptr xorig
                fmul    small dword ptr xdir
                fld     small dword ptr yorig
                fmul    small dword ptr ydir

@mod1:          nop     ;d8c8 fmul st,st
                nop
                nop     ;d8c8 fmul st,st
                nop
                fadd

                fstp    small dword ptr _b

;              c=xorig*xorig+yorig*yorig-Radio*Radio;

                fld     small dword ptr xorig
                fmul    st,st
                fld     small dword ptr yorig
                fmul    st,st
                fadd
                fld     small dword ptr Radio
                fmul    st,st
                fsub
                fstp    small dword ptr _c

;              delta=b*b-4.*a*c;

                fld     small dword ptr _b
                fmul    st,st
@mod2:          db 090h,090h  ;d8c8

                ;fld     small dword ptr 4.0*a
                fld small dword ptr _a
                fimul t4

                fmul    small dword ptr _c
                fsub
                fstp    small dword ptr delta

;              if (delta<0){u=128; v=128; return;}

                jnz @@NOCERODELTA
                mov small dword ptr __u,128*256
                mov small dword ptr __v,128*256
                ret

@@NOCERODELTA:

;              t=sqrt(delta);

                fld     small dword ptr delta
                fsqrt
                fstp    small dword ptr t

;        t1=(-b +t)/(2.*a);
;        t2=(-b -t)/(2.*a);

                fld     small dword ptr t
                fsub    small dword ptr _b

                ;fdiv    small dword ptr 2.*a
                fld small dword ptr _a
                fimul _t2
                fdivp

                fstp    small dword ptr t1


                fld     small dword ptr t
                fadd    small dword ptr _b
                fchs

                ;fdiv    small dword ptr 2.*a
                fld small dword ptr _a
                fimul _t2

                fdivp

                fstp    small dword ptr t2

;              if (t1>t2) t=t2; else t=t1; ;el minimo en t

                mov     eax,small dword ptr t1
                mov     ebx,small dword ptr t2
                cmp     eax,ebx
                jg @@T1MAYORT2
                mov     small dword ptr t,ebx
                jmp @@FINT1T2
@@T1MAYORT2:
                mov     small dword ptr t,eax
@@FINT1T2:

;        _intx=xorig+t*xdir;
;        _inty=yorig+t*ydir;
;        _intz=zorig+t*zdir;

                fld small dword ptr xdir
                fmul small dword ptr t
                fadd small dword ptr xorig
                fstp small dword ptr _intx

                fld small dword ptr ydir
                fmul small dword ptr t
                fadd small dword ptr yorig
                fstp small dword ptr _inty

                fld small dword ptr zdir
                fmul small dword ptr t
                fadd small dword ptr zorig
                fstp small dword ptr _intz




        ;mapeado conico :-9

        fld small _intz
        fmul small _temp1 ;u=(int)((_intz)*0.2)<<8;

        fimul t256
        fistp small __u


        fld small _inty
        fld small _intx 
        fpatan    ;v=((int)(fabs(atan2(_inty,_intx)*256/PI)))<<8;
        fmul small f256_entre_pi
        fabs

        fimul small t256
        fistp small __v

        

        fld small _intz        
        fimul small t256 ;z=((int)_intz)<<8;
        fistp small __z


        ret

GetUVTunnel  ENDP

fti dd 0
speed real4 0.2

tunnel proc ;eax=i, edi=renderbuffer, esi=textura

        mov small ti,eax
        fild ti
        fmul speed
        fstp fti

        fld small f04
        fsincos
        fstp small cosAA
        fstp small sinAA

        fld small f004
        fmul small fti
        fsincos
        fstp small cosAB
        fstp small sinAB

        fld small f003
        fmul small fti
        fsincos
        fstp small cosAC
        fstp small sinAC

        fild small t160
        fmul small fti
        fistp small zcam

        mov small _t_x,0
@t_loopX:

        mov small _t_y,0
@t_loopY:

        mov eax,small _t_x
        shl eax,3 ; *8
        mov small t_x,eax

        mov eax,small _t_y
        inc eax
        shl eax,3 ; *8
        mov small t_y,eax


        ;xorig
        ;100+sin(float(i)/5.)*200.

        fld small fti
        fidiv small t5
        fsin

        fimul small t200
        fiadd small t100

        fstp small xorig


        ;yorig
        ;100+cos(float(i)/5.)*100.

        fld small fti
        fidiv small t5
        fcos

        fimul small t100
        fiadd small t100

        fstp small yorig
        
        ;zorig

        fild small zcam
        fstp small zorig


        call GetUVTunnel

        mov ebx,small _t_y
        shl ebx,6

        add ebx,small _t_x
        shl ebx,2 ;*4

        mov eax,small __v
        mov [_u+ebx],eax

        mov eax,small __u
        mov [_v+ebx],eax

        
        inc small _t_y
        cmp small _t_y,31
        jb @t_loopY

        inc small _t_x
        cmp small _t_x,41
        jb @t_loopX


        ret


tunnel endp
