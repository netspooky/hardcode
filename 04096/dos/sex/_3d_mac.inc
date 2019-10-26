;Genere la table des sinus, 256+64 r‚els.
_calc_sin macro
  fldpi
  mov si,(256+127)*4
  _calc_sin_boucle:
    fld st(0)
    fsin
    fstp dword ptr ds:[offset sinus+si]
    fsub [float_sin]
    sub si,4
  jns _calc_sin_boucle
endm