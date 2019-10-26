; Wejscie: st=x, st1=y, st2=Rf, st3=ddx, st4=ddy
; U=128*x+128*COS(RFactor+x*y)
; V=128*y+128*SIN(Rfactor+x+y)

        fild ds:[xd]; st=128 st1=x, st2=y, st3=ddx, st4=ddy, st5=Rfactor
        fld st(1)     ; st=x st1=128 st2=x st3=y st4=ddx st5=ddy st6=RF
        fmul st,st(3)
        fadd st,st(6)
        fld st
        fadd st,st(7)
        fsub st,st(4)
        fmul st,st(2)
        fistp ds:[U]
        fsin
        fmul st,st(1)
        fld st(2)     ; st=x 1=128*cos(rf+x*y) 2=128 3=x 4=y 5=dx 6=dy 7=RF
        fmul st,st(2)
        faddp st(1)   ; st=128*x+128+128*cos(y*x+RF) 1=128 2=x3=y4=dx5=dy6=RF
        fistp ds:[V]  ; st=128 1=x 2=y 3=dx 4=dy 5=RF
        mov bx,ds:[U] ; BX - skladowa V textury funkcja 1
        mov ax,ds:[V] ; AX - skladowa V textury funkcja 2

        fld st(1)     ; st=128 1=x 2=y 3=dx 4=dy 5=RF
        fsub st,st(3) ; st=x 1=128 2=x 3=y 4=dx 5=dy 6=RF
        fadd st,st(6)
        fld st
        fadd st,st(7)
        fsub st,st(4)
        fmul st,st(2)
        fistp ds:[U]
        fcos
        fmul st,st(1) ; st=a*sin(y+x+(2?)Rf)
        fld st(3)     ; st=y 1=a*sin(y+x+(2?)Rf) 2=128 3=x 4=y 5=dx 6=dy 7=RF
        fmul st,st(2)
        faddp st(1)   ; st=a*y+a+a*sin(y+x+(2?)Rf) 1=128 2=x 3=y 4=dx 5=dy 6=RF
        fistp ds:[V]

        fstp st

        fsub st,st(2)           ; x:=x-ddx

        and bx,ds:[U]
        xor ax,ds:[V]
