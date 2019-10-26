assume ds:CsSeg
CalcLis:
      xor cx,cx
csl1:
      mov word ptr ds:Dat,cx
      fldpi
      fimul word ptr ds:Dat
      fidiv word ptr ds:Divider
      fld st(0)
      fld st(0)
      fsin
      fimul word ptr ds:MullyX
      fistp word ptr ds:[si]
      fadd
      fsin
      fimul word ptr ds:MullyY
      fistp word ptr ds:[si+256]
      inc si
      inc cl
      jnz csl1
      ret
