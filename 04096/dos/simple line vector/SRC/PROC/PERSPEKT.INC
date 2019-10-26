;*****************************
;*  COPROCESSOR PERSPECTIVE  *
;*  CODE BY MOMAT            *
;*****************************
;konieczne: zdefiniowanie wartosci punktow X, Y, Z  oraz
;           polozenia obserwatora xo, yo, zo

Perspektywa:
        fild X
        fild Y
        fild Z
        fisub zo
        fxch st(2)
        fisub xo
        fimul zo
        fdiv st,st(2)
        fiadd xo
        frndint
        fistp X

        fisub yo
        fimul zo
        fdiv st,st(1)
        fiadd yo
        frndint
        fistp Y
        ffree st(0)
        ret

