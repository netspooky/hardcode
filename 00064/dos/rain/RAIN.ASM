
 ;
 ; RAIN_STORM.COM
 ;
 ; WRITTEN BY RAIN_STORM
 ;
 ; http://dbfinteractive.com/
 ;

 ORG 100h

 PALLET = 003C8h	; DH = 03 ... DL = C8
 VTRACE = 003DAh	; DH = 03 ... DL = DA
 KEYBRD = 00060h

 INIT:MOV   AL,13h	; YOU SHOULD KNOW WHAT THIS DOES
      INT   10h 	;
      LES   AX,[BX]	;
      LDS   AX,[DI]	; DS = DOUBLE BUFFER (AX = TRASH THOUGH)

      MOV   DX,PALLET+1 ; SKIPS PALLET INDEXING (JUST SETS RGB'S)
 COLR:ROR   AX,01h	; DECREASE COLOUR
      OUT   DX,AL	; RED
      OUT   DX,AL	; GREEN
      ROL   AX,01h	; REPAIR AX & MAKE BLUE SCALE
      OUT   DX,AL	; BLUE
      INC   AX		;
      JNZ   SHORT COLR	; LOOP FOR <= 0FFFFh ITERATIONS

 MAIN:DEC   CX		; CX = 0FFFFh
      MOV   DL,0DAh	; DX = VTRACE (DH IS PRESERVED)
 SYNC:IN    AX,DX	; SYNC TO MONITOR'S REFRESH RATE
      TEST  AL,08h	;
      JZ    SHORT SYNC	;
      REP   MOVSW	; DOUBLE BUFFERING (DS -> ES)

      MOV   BX,140h	; THESE 3 BYTES SAVES 6 BYTES BELOW
 RAIN:DEC   DI		;
      XCHG  AL,[DI]	; READ & WRITE (SAVES 2 BYTES)
      LEA   SI,[BX+DI]	; SI @= DI + 320
      ADC   AL,[SI-1]	; AL += [DI+319]
      ADC   AL,[SI]	; AL += [DI+320]
      ADC   AL,[SI+1]	; AL += [DI+321]
      ADC   AL,[BX+SI]	; AL += [DI+640]
      SBB   AL,[DI-320] ; 4 BYTES NOT MUCH I CAN DO HERE
      SHR   AL,2	; 3 BYTES ASSEMBLED WITH FASM :)
      LOOP  SHORT RAIN	;

 EXIT:IN    AX,KEYBRD	; AND YOU KNOW WHAT THIS IS ALL ABOUT
      DEC   AX		;
      JNZ   SHORT MAIN	;
      RET		;
