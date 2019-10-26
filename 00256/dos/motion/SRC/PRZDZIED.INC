; Wejscie - na razie zadne
; Dziedzina : -1 do 1  ostatecznie mozna liczyc jeden przyrost
        fldz                    ; 0
        fld1                    ; 1 0
        fadd st,st              ; 2  0
        fld st                  ; 2 2 0
        fidiv ds:[yd]           ; 2/yd 2 0
        fxch st(1)              ; 2 2/yd 0
        fidiv ds:[xd]           ; 2/xd 2/yd 0
; Wyjscie st=RF st1=ddx st2=ddy  - przyrosty po x i po y
