;*************************
;*  COPROCESSOR ROTATES  *
;*  CODE BY MOMAT        *
;*************************
;konieczne:  okreslenie wartosci pkt. X, Y, Z, katow obrotu KatX, KatY, KatZ


RotacjaX:
        fild Y          ;Y,Z na stos
        fild Z
        fld KatX        ;wartosc kata w radianach na stos
        fsincos         ;sinus i cosinus ST(0)
        fld st(1)       ;kopiuj sinus na szczyt stosu
        fmul st,st(3)   ;sin*Z
        fld st(1)       ;kopiuj cosinus na szczyt stosu
        fmul st,st(5)   ;cos*Y
        fsubr           ;odejmowanie ST(1) od ST(0)
        frndint         ;zaokraglenie do calokwitej
        fistp Y         ;zdejmij ST(0) do Y

        fxch st(3)      ;Y na szczyt
        fmulp           ;sin*Y
        fxch st(2)      ;cos na szczyt
        fmulp           ;cos*Z
        faddp
        frndint
        fistp Z

RotacjaY:
        fild X          ;X,Z na stos
        fild Z
        fld KatY        ;wartosc kata w radianach na stos
        fsincos         ;sinus i cosinus ST(0)
        fld st(1)       ;kopiuj sinus na szczyt stosu
        fmul st,st(3)   ;sin*Z
        fld st(1)       ;kopiuj cosinus na szczyt stosu
        fmul st,st(5)   ;cos*X
        fadd
        frndint         ;zaokraglenie do calokwitej
        fistp X         ;zdejmij ST(0) do Y

        fxch st(3)      ;X na szczyt
        fmulp           ;sin*X
        fxch st(2)      ;cos na szczyt
        fmulp           ;cos*Z
        fsubr
        frndint
        fistp Z

RotacjaZ:
        fild X          ;X,Y na stos
        fild Y
        fld KatZ        ;wartosc kata w radianach na stos
        fsincos         ;sinus i cosinus ST(0)
        fld st(1)       ;kopiuj sinus na szczyt stosu
        fmul st,st(3)   ;sin*Y
        fld st(1)       ;kopiuj cosinus na szczyt stosu
        fmul st,st(5)   ;cos*X
        fsubr           ;odejmowanie ST(1) od ST(0)
        frndint         ;zaokraglenie do calokwitej
        fistp X         ;zdejmij ST(0) do X

        fxch st(3)      ;X na szczyt
        fmulp           ;sin*X
        fxch st(2)      ;cos na szczyt
        fmulp           ;cos*Y
        fadd
        frndint
        fistp Y

PowrotObroty:
        ret

