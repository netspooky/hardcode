; //////////////// Burst Big Bang in core of the World /////// Made by Easygn ///
; ///////////////////////////////// Finished 2009.04.20 __ Released 2013.01.03 //

.MODEL TINY
.CODE

start:
MOV     AL, 13h
INT     10h
LES     BP, [BX]

chg:
   Dec     AX
   Mov     CX, DI
   tick:
      ADC    DI, AX
      STOSB
   Loop tick
Jmp chg
 
END start