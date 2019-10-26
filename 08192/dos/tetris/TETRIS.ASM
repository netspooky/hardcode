COMMENT %
                        ‹‹‹‹‹ﬂ                     ∞
                ‹‹€€€€≤€ﬂﬂﬂ ‹‹≤‹ ≤≤               ‹≤±   ‹≤±‹
            ﬂ ﬂﬂﬂ∞±≤€€≤  ‹€ﬂﬂ ﬁ≤  ≤€  ‹€ﬂ  ‹‹‹‹‹‹  ﬂﬂ ‹€ﬂ ﬂ€≤±  !!!
                   €€€≤ ﬁ≤‹‹‹≤ﬂ ‹ﬂﬂ≤€ﬂﬂ  ﬂ€€≤› ﬂ≤± ≤ ﬂ€≤‹   ﬂ
        ∞∞±±≤≤€€ﬂ ﬁ€€≤›ﬁ≤≤    ‹±∞ ﬁ≤±∞ €≤‹ ≤€≤    ﬁ≤ ‹ ﬂﬂﬂ€‹ ﬂﬂ€€≤≤±±∞∞
               ‹ ﬁ≤€€≤± ±±≤ ‹≤≤ﬂ  ≤€‹  ﬁ≤± ﬁ≤›  ∞±≤€› ≤≤‹ ≤≤±∞
             ∞±≤‹‹ ﬂ≤±∞  ∞ﬂﬂﬂ ‹‹ ∞±≤≤ﬂﬂﬂ ‹ ﬂﬂ      ﬂﬂ  ﬂﬂﬂﬂ∞
                 ﬂﬂ  ∞      ﬂﬂﬂ       ﬂﬂﬂ≤ ﬂﬂﬂﬂ ﬂ ﬂ   ﬂ^Alc
                       S o u r c e  C o d e
%

.Model Tiny
.386
.Code
 Org 256

Begin:
      ; - InitGraph -=-=-=-=-=-=-
           Mov      Ax, 13H
           Int      10H
           Call     SetPal
           Call     SetNewINT_1C
           Push     0a000h
           Pop      Es
           Call     Setbg

 NewGame:  Call     ClearBox
           Mov      X, 7
           Mov      Y, 3
           Mov      Z, 0
           Mov      oX, 7
           Mov      oY, 3
           Mov      oZ, 0
           Mov      OoX, 0
           Mov      Score, 0
           Mov      Speed, 0
           Call     SScore
           Call     SSpeed

           Xor      Bx, Bx
           Call     Random
           Mov      Bl, Nf

           Mov      Si, Speed
           Mov      Al, Byte Ptr CS:TSpeed[Si]
           Mov      CS:Counter, Al

 MainLoop:
           Call     ClearFig
           Call     MainFig

           Cmp      Y, 2
           Je       NewGame

    Delay: Mov      Ah, 1
           Int      16h
           Jnz      Keys

           Cmp      Cs:Counter, 0
           Jne      Delay

           Mov      Si, Speed
           Mov      Al, Byte Ptr CS:TSpeed[Si]
           Mov      CS:Counter, Al

           Mov      Ah, 5
           Mov      Ch, 80
           Int      16h

     Keys: Xor      Ax, Ax
           Int      16h

     Key0: Cmp      Ah, 80   ;
           Jne      Key1     ;  -Down
           Call     NextFig
           Inc      Y
           Mov      Al, Oy
           Mov      OoX, Al

     Key1: Cmp      Ah, 75   ;
           Jne      Key2     ;    - Move Left
           Call     NextFig
           Dec      X        ;

     Key2: Cmp      Ah, 77   ;
           Jne      Key3
           Call     NextFig
           Inc      X        ;    - Move Right

     Key3: Cmp      Ah, 72   ;
           Jne      Key4
           Call     NextFig
           Inc      Z        ;    - Rotate

     Key4: Cmp      Al, 'n'  ;  N/n - New Game
           Je       NewGame  ;
                             ;
           Cmp      Al, 'N'  ;
           Je       NewGame  ;

           Cmp      Ah, 1    ; ESC - Exit
           Jne      MainLoop ;

 EndGame:  Call     Restoreold_Int_1C
           Mov      Ax, 03h
           Int      10h
           Call     SeeYa
           Ret

 ; =\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=
 ; =\=\=\=\=\= P R O C E D U R E S  S E G M E N T \=\=\=\=\=\=\=\=\=\=\=\=\=
 ; =\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=
 Setnewint_1C Proc Near
           Mov      Ax,351Ch
           Int      21H
           Mov      Word Ptr Oint_1C, Bx
           Mov      Ax, Es
           Mov      Word Ptr Oint_1C+2, Ax
           Lea      Dx, Int1C_
           Mov      Ax, 251Ch
           Int      21H
           Mov      Dx, 2E9Bh
           Mov      Al, 034H
           Out      043H, Al
           Mov      Al, Dl
           Out      040H, Al
           Mov      Al, Dh
           Out      040H, Al
           Ret
 Setnewint_1C Endp
 Restoreold_Int_1C Proc Near
           Mov      Dx, Word Ptr Oint_1C
           Mov      Ax, Word Ptr Oint_1C+2
           Mov      Ds, Ax
           Mov      Ax, 251Ch
           Int      21H
           Mov      Al, 034H
           Out      043H, Al
           Xor      Al, Al
           Out      040H, Al
           Out      040H, Al
           Ret
 Restoreold_Int_1C Endp

 NextFig  Proc Near
           Mov      Al, OoX
           Cmp      Al, Y
           Jne      NoFinish
           Mov       X, 7
           Mov      oX, 7
           Mov       Y, 3
           Mov      oY, 2
           Mov       Z, 0
           Mov      oZ, 0
           Mov      Bl, Nf
           Call     Random
           Call     ShowNextF
           Call     Line
           Call     SScore
           Call     SSpeed
 NoFinish: Ret
 NextFig  Endp

 ClearFig Proc Near
           Mov      Fa, 0
           Mov      Al, Ox
           Xchg     X,  Al
           Mov      Ox, Al
           Mov      Al, Oy
           Xchg     Y, Al
           Mov      Oy, Al
           Mov      Al, Oz
           Xchg     Z, Al
           Mov      Oz, Al

           Call     ShowFig

           Mov      Al, X
           Xchg     Ox, Al
           Mov      X, Al
           Mov      Al, Y
           Xchg     Oy, Al
           Mov      Y, Al
           Mov      Al, Z
           Xchg     Oz, Al
           Mov      Z, Al
           Mov      Fa, 1
           Ret
 ClearFig Endp

 MainFig Proc Near
           Mov      Fb, 0
           Call     ShowFig
           Mov      Fb, 1
           Call     ShowFig
           Mov      Al, X
           Xchg     Ox, Al
           Mov      Al, Y
           Xchg     Oy, Al
           Mov      Al, Z
           Xchg     Oz, Al
           Ret
  MainFig Endp
  Line    Proc Near
           Pusha
           Mov      Si, 111+(320*180)
           Mov      Bx, 8*15
  Again:   Push     Si
           Mov      Cx, 96
           Xor      Al, Al
           Mov      Di, Si
           Repnz    Scasb
           Jz       NoLine

           Inc      Score
           Inc      Score

           Xor      Dx, Dx
           Mov      Ax, Score
           Mov      Cx, 80
           Div      Cx
           Test     Dx, Dx
           Jnz      NoIncSpd
           Inc      Speed

           Mov      Ax, 10
           Add      Score, Ax

 NoIncSpd: Mov      Dx, 7*15
   StoreL: Mov      Cx, 96
   StoreB: Mov      Al, Byte Ptr ES:[Si-320]
           Mov      Byte Ptr ES:[Si+(320*7)], Al
           Inc      Si
           Dec      Cx
           Jnz      StoreB
           Sub      Si, 320+96
           Cmp      Si, 111+(320*68)
           Jb       OLine
           Dec      Dx
           Jnz      StoreL
    Oline: Pop      Si
           Jmp      Again
   NoLine: Pop      Si
           Sub      Si, 320*8
           Dec      Bx
           Jnz      Again
           Popa
           Ret
  Line    Endp

 ; =\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=
 ; =\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=
 ; =\=\=\=\=\=    M A I N  F I G U R E  P R O C E D U R E S   \=\=\=\=\=\=\=
 ; =\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=
 ; Game Box 12x16
 ; Pos : X1 = 95  X2 = 183
 ;       Y1 = 52  Y2 = 172

 ; =\=\=\=\=\=\=\=\=\=\=\=\=\ Last X, Last Y, Last Z =\=\=\=\=\=\=\=\=\=\=\=
 New2OldX Macro
           Mov      Al, Ox
           Mov       X, Al
 Endm
 New2OldY Macro
           Mov      Al, Oy
           Mov       Y, Al
 Endm
 New2OldZ Macro
           Mov      Al, Oz
           Mov       Z, Al
 Endm

 OneBlock Proc Near
           Push     Di
           Lea      Si, Blc0
           Cmp      Fa, 0
           Je       Clear
           Mov      Cx, 8
   WBline: Movsw
           Movsw
           Movsw
           Movsw
           Add      Di, 312
           Dec      Cx
           Jnz      Wbline
           Jmp      Done
    Clear: Xchg     Fa, Ax
           Mov      Cx, 8
  WBCLine: Stosw
           Stosw
           Stosw
           Stosw
           Add      Di, 312
           Dec      Cx
           Jnz      WbCline
           Xchg     Fa, Ax
     Done: Pop      Di
           Ret
 OneBlock  Endp

 X_Y2Di   Proc Near
           Xor      Di, Di
           Mov      Al, Y
           Mov      Ah, 8
           Imul     Ah
           Sub      Al, 8
           Add      Al, 52
           Mov      Si, 320
           Imul     Si
           Mov      Di, Ax
           Mov      Al, X
           Mov      Ah, 8
           Imul     Ah
           Sub      Al, 8
           Add      Al, 95
           Xor      Ah, Ah
           Add      Di, Ax
           Ret
 X_Y2Di   Endp

 ShowFig   Proc Near
 ; Bx  = Fig [0..6]
 ; Z   = Rotate [0..3]
 ; X,Y = Pos [1..12,1..16]
           Cmp      Z, 4            ; Test Z
           Jne      Tz              ;
           Mov      Z, 0            ;
       Tz: Pusha
           Call     X_Y2Di
           Shl      Bx, 1           ; Count Offset
           Shl      Bx, 1           ;
           Shl      Bx, 1           ;
           Shl      Bx, 1           ;
           Xor      Ax, Ax          ;
           Mov      Al, Z           ;
           Shl      Ax, 1           ;
           Shl      Ax, 1           ;
           Add      Bx, Ax
           Mov      Ah, 4
 NextByte: Lea      Si, Fig0[Bx]
           Mov      Dl, 00001000b
           Lodsb
           Mov      Dh, 4
  NextBit: Test     Al, Dl
           Jz       NoBit

           Cmp      Fb, 0                 ;
           Je       TeBlock               ;
           Call     OneBlock              ;
           Jmp      NoBit                 ;
  TeBlock:                                ;
           Cmp      Byte Ptr ES:[Di], 0
           Je       NoBit
           New2Oldx
           New2Oldz
           New2Oldy
           Jmp      Col
    NoBit: Add      Di, 8
           Ror      Dl, 1
           Dec      Dh
           Jnz      NextBit
           Inc      Bx
           Add      Di, (320*8)-32
           Dec      Ah
           Jnz      NextByte
     Col:  Popa
           Ret
 ShowFig   Endp

 ShowNextF Proc Near
           Mov      Al, X
           Mov      Ah, Y
           Push     Ax  Bx
           Mov      X, -6
           Mov      Y,  6
           Mov      Fa, 0
           Call     ShowFig
           Mov      Fa, 1
           Mov      Bl, Nf
           Call     ShowFig
           Pop      Bx  Ax
           Mov      X,  Al
           Mov      Y,  Ah
           Ret
 ShowNextF Endp

 ; =\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=
 ; =\=\=\=\=\=\=\=\ S C O R E  &  S P E E D \=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=
 ; =\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=

   Ax2Val  Proc Near
           Mov      Cx, 5                   ;Convert Ax Value
     Cax:  Xor      Dx, Dx
           Mov      Bx, 10
           Div      Bx
           Add      Dx, 48
           Mov      Di, Cx
           Mov      Val[Di-1], Dl
           Loop     Cax
           Ret
   Ax2Val Endp

    ShowS Proc Near
           Push     Cx
           Mov      Fb, Si
           Xor      Ax, Ax
           Lodsb
           Sub      Ax, 48
           Mov      Bx, 57
           Imul     Bx
           Xchg     Di, Ax
           Lea      Si, D0[Di]
           Mov      Di, Fa
           Mov      Dx, 7
     Sh1:  Mov      Cx, 8
           Rep      Movsb
           Add      Di, 320-8
           Dec      Dx
           Jnz      Sh1
           Mov      Si, Fb
           Inc      Si
           Add      Fa, 9
           Pop      Cx
           Dec      Cx
           Jnz      ShowS
           Ret
    ShowS Endp

   SScore Proc Near                  ; Show Score
           Pusha
           Mov      Ax, Score        ;
           Call     Ax2Val           ;
           Lea      Si, Val          ;
           Mov      Fa, 320*102+243  ;
           Mov      Cx, 5            ;
           Call     ShowS
           Popa
           Ret
   SScore Endp

   SSpeed Proc Near                  ; Show Speed
           Pusha                     ;
           Mov      Ax, Speed        ;
           Call     Ax2Val           ;
           Lea      Si, Val[3]       ;
           Mov      Fa, 320*158+252  ;
           Mov      Cx, 2            ;
           Call     ShowS
           Popa
           Ret
   SSpeed Endp

   Random Proc Near
            Xor      Ah, Ah
            Int      1Ah
            Xor      Dh, Dh
            Shr      Dx, 5
            Test     Dx, Dx
            Jz       NoDec
            Dec      Dx
     NoDec: Mov      Nf, Dl
            Ret
   Random Endp

   Int1C_ Proc Near
            Dec      Cs:Counter
            Iret
   Int1C_ Endp
 ; =\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=
 ; =\=\=\=\=\=\=  F R A M E  D R A W I N G  P R O C E D U R E=\=\=\=\=\=\=\=
 ; =\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=

 Frame1   Proc    Near
           Mov      Bx, 60
           Mov      Cx, 8
       F0: Mov      Ax, 320
           Imul     Bx
           Add      Ax, 87+16
           Xchg     Di, Ax
           Lea      Si, Left
           Mov      Dx, 16
           Xchg     Cx, Ax
       F1: Mov      Cx, 8
           Rep      Movsb
           Add      Di, 312
           Dec      Dx
           Jnz      F1
           Xchg     Cx, Ax
           Add      Bx, 16
           Loop     F0
           Ret
 Frame1   Endp
 Frame2   Proc      Near
           Mov       Bx, 60
           Mov       Cx, 8
      FF0: Push      Cx
           Mov       Ax, 320
           Imul      Bx
           Add       Ax, 223-16
           Xchg      Di, Ax
           Push      Bx
           Mov       Bx, 8
           Mov       Dx, 16
      FF2: Lea       Si, Left[Bx-1]
           Mov       Cx, 8
      FF1: Std
           Lodsb
           Cld
           Stosb
           Loop      FF1
           Add       Di, 312
           Add       Bx, 8
           Dec       Dx
           Jnz       FF2
           Pop       Bx
           Add       Bx, 16
           Pop       Cx
           Loop      FF0
           Ret
 Frame2   Endp
 Frame3   Proc       Near
           Mov       Cx, 6
           Mov       Bx, 95+16
     FFF3: Push      Cx
           Mov       Ax, 320     ; 188
           Mov       Dx, Fa
           IMul      Dx
           Add       Ax, Bx
           Xchg      Di, Ax
           Xchg      Bx, Ax
           Mov       Dx, 7
     FFF2: Xor       Bx, Bx
           Mov       Cx, 16
     FFF1: Lea       Si, Left[Bx]
           Add       Si, Dx
           Movsb
           Add       Bx, 8
           Loop      FFF1
           Add       Di, Fb      ; 304
           Dec       Dx
           Jnz       FFF2
           Xchg      Bx, Ax
           Add       Bx, 16
           Pop       Cx
           Loop      FFF3
           Ret
 Frame3   Endp

 LinLeft  Proc  Near
           Mov       Ax, 320
           Mov       Dx, Fa ;52,195
           Imul      Dx
           Add       Ax, 87+16
           Xchg      Di, Ax
           Lea       Si, Link
           Mov       Bx, 8
       L0: Mov       Cx, 8
           Rep       Movsb
           Add       Di, Fb ; 312,-328
           Dec       Bx
           Jnz       L0
           Ret
 LinLeft  Endp

 LinRight Proc  Near
           Mov       Bx, 8
           Mov       Ax, 320
           Mov       Dx, Fa ; 52,195
           Imul      Dx
           Add       Ax, 223-16
           Xchg      Di, Ax
           Mov       Dx, Bx
       L1: Lea       Si, Link[Bx-1]
           Mov       Cx, 8
       LL: Std
           Lodsb
           Cld
           Stosb
           Loop      LL
           Add       Bx, 8
           Add       Di, Fb ; 312,-328
           Dec       Dx
           Jnz       L1
           Ret
 LinRight Endp

 ; =\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=
 ; =\=\=\=\=\=\=\=\=\\= S E T  B A C K G R O U N D \=\=\=\=\=\=\=\=\=\=\=\=\
 ; =\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=
 SeeYa    Proc Near
           DB  00Eh,00Eh,007h,01Fh,0BFh,0E0h,03Eh,0BEh,0E0h,03Eh,0B9h,0DEh
           DB  002h,0ACh,034h,01Ah,0AAh,0E2h,0FAh,0BAh,0E0h,03Eh,0B4h,009h
           DB  0CDh,021h
           Ret
 SeeYa    Endp

 ClearBox Proc Near
           Mov      Di, 111+(320*60)
           Mov      Dx, 128
           Xor      Ax, Ax
     CBox: Mov      Cx, 48
           Rep      Stosw
           Add      Di, 320-96
           Dec      Dx
           Jnz      CBox
           Mov      Di, 25+(320*90)
           Mov      Dx, 60
           Xor      Ax, Ax
     NBox: Mov      Cx, 25
           Rep      Stosw
           Add      Di, 320-50
           Dec      Dx
           Jnz      NBox
           Ret
 ClearBox Endp

 SetPal   Proc Near                   ; Set Palette
           Lea     Si, Pal
           Mov     Dx, 3c8h
           Xor     Al, Al
           Out     Dx, Al
           Inc     Dx
           Mov     Cx, 105
           Rep     Outsb
           Ret
 SetPal   Endp

 ShowLogo Proc  Near
           Mov      Cx, Fa
           Rep      Movsw
           Add      Di, Fb
           Dec      Bx
           Jnz      ShowLogo
           Ret
 ShowLogo Endp

 ShowAlch Proc Near
           Lea      Si, Alchem
           Mov      Di, (162*320)+20
           Mov      Dx, 28
 Alchemic: Mov      Cx, 34
           Rep      Movsw
           Add      Di, 320-68
           Dec      Dx
           Jnz      Alchemic
           Ret
 ShowAlch Endp

 SetBg    Proc Near
        ; - Main Logo -=-=-=-=-
           Mov      Di, 80
           Lea      Si, Logo
           Mov      Bx, 45
           Mov      Fa, Di
           Mov      Fb, 160
           Call     ShowLogo
         ; - "Next" Logo
           Mov      Di, 320*50+5+10
           Lea      Si, NextL
           Mov      Bx, 35
           Mov      Fa, 38
           Mov      Fb, 320-76
           Call     ShowLogo
         ; - "Score" Logo
           Mov      Di, 320*55+235-10
           Lea      Si, ScoreL
           Mov      Bx, 33
           Mov      Fa, 40
           Mov      Fb, 320-80
           Call     ShowLogo
         ; - "Speed" Logo
           Mov      Di, 320*125+242-10
           Lea      Si, SpeedL
           Mov      Bx, 19
           Mov      Fa, 30
           Mov      Fb, 320-60
           Call     ShowLogo
         ; - Frame Routine -=-=-
           Mov      Fa, 52
           Mov      Fb, 312
           Call     LinLeft
           Call     LinRight
           Mov      Fa, 195
           Mov      Fb, -328
           Call     LinLeft
           Call     LinRight
           Call     Frame1
           Call     Frame2
           Mov      Fa, 59
           Mov      Fb,-336
           Call     Frame3
           Mov      Fa, 188
           Mov      Fb, 304
           Call     Frame3
         ; - End Of Frame Routine -=-=
           Call     ShowAlch
           Ret
 SetBg    Endp

 ; =\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=
 ; =\=\=\=\=\=\=\=\=\=\ D A T A   S E G M E N T \=\=\=\=\=\=\=\=\=\=\=\=\=\=
 ; =\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=
 oINT_1C  DD 0
       X  DB 7
       Y  DB 3
       Z  DB 0
      Ox  DB 7
      Oy  DB 3
      Oz  DB 0
     OoX  DB 0
      Nf  DB 0
      Fa  DW 0
      Fb  DW 0
     Val  DB 5 Dup (0),' ','$'
   Score  DW 0
   Speed  DW 0
  TSpeed  DB 80,48,32,26,20,16,14,12,10,8
 Counter  DB 0

  Even
  ; Fig0  Fig1  Fig2  Fig3  Fig4  Fig5  Fig6
  ;  €     €                       €
  ;  €‹   ‹€    ‹€ﬂ   ﬂ€‹   ‹€‹    €     €€
  ;
  ; Rotations:
  ;        0  (ofs=Fig)     1 (ofs=Fig+4)    2 (ofs=Fig+8)    3 (ofs=Fig+12)

 Fig0 Db 04h,04h,06h,00h, 00h,0Eh,08h,00h, 0Ch,04h,04h,00h, 02h,0Eh,00h,00h
 Fig1 Db 04h,04h,0Ch,00h, 08h,0Eh,00h,00h, 06h,04h,04h,00h, 00h,0Eh,02h,00h
 Fig2 Db 06h,0Ch,00h,00h, 04h,06h,02h,00h, 00h,06h,0Ch,00h, 08h,0Ch,04h,00h
 Fig3 Db 0Ch,06h,00h,00h, 02h,06h,04h,00h, 00h,0Ch,06h,00h, 04h,0Ch,08h,00h
 Fig4 Db 04h,0Eh,00h,00h, 04h,06h,04h,00h, 00h,0Eh,04h,00h, 04h,0Ch,04h,00h
 Fig5 Db 02h,02h,02h,02h, 00h,00h,0Fh,00h, 04h,04h,04h,04h, 00h,0Fh,00h,00h
 Fig6 Db 00h,06h,06h,00h, 00h,06h,06h,00h, 00h,06h,06h,00h, 00h,06h,06h,00h

  Even
  Blc0 DB 012h,012h,012h,012h,012h,012h,012h,012h,012h,010h,010h,010h,010h
       DB 010h,010h,012h,012h,010h,00Fh,00Fh,00Fh,00Fh,010h,012h,012h,010h
       DB 00Fh,00Eh,00Eh,00Fh,010h,012h,012h,010h,00Fh,00Eh,00Eh,00Fh,010h
       DB 012h,012h,010h,00Fh,00Fh,00Fh,00Fh,010h,012h,012h,010h,010h,010h
       DB 010h,010h,010h,012h,012h,012h,012h,012h,012h,012h,012h,012h

  LEFT DB 022h,022h,01Ch,01Ch,017h,01Ah,016h,016h,01Fh,022h,01Dh,01Ch,01Dh
       DB 01Ah,014h,015h,020h,020h,01Fh,01Ch,01Ah,01Bh,017h,014h,022h,022h
       DB 01Ch,01Dh,01Dh,017h,017h,015h,01Fh,01Ch,021h,01Ch,017h,016h,018h
       DB 014h,022h,022h,020h,01Ah,01Ah,018h,015h,014h,021h,020h,01Bh,01Eh
       DB 015h,018h,017h,018h,022h,01Fh,020h,01Ah,019h,01Ah,015h,014h,021h
       DB 01Dh,01Fh,01Ch,01Ch,015h,016h,017h,01Eh,021h,01Ah,01Eh,019h,019h
       DB 01Ah,015h,020h,01Eh,01Eh,01Dh,016h,015h,018h,015h,022h,022h,020h
       DB 01Dh,017h,01Ah,018h,015h,022h,022h,020h,01Dh,016h,01Ah,014h,014h
       DB 021h,020h,020h,01Fh,018h,018h,015h,014h,01Eh,01Fh,01Dh,01Eh,01Ch
       DB 017h,018h,015h,022h,01Eh,01Dh,018h,01Bh,015h,019h,015h

  LINK DB 01Fh,022h,021h,021h,022h,020h,020h,021h,021h,020h,021h,020h,01Eh
       DB 020h,01Fh,01Dh,021h,021h,020h,021h,01Fh,01Fh,01Eh,01Eh,021h,020h
       DB 020h,020h,020h,01Ch,01Ch,01Eh,022h,021h,01Eh,01Ch,021h,01Bh,01Dh
       DB 01Ch,022h,021h,022h,01Bh,01Ch,01Ch,01Bh,01Dh,022h,022h,022h,021h
       DB 018h,01Ah,01Ah,016h,022h,020h,022h,01Ch,01Bh,01Ch,01Bh,018h

 NextL DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,013h,012h,012h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,013h,012h,012h,012h,012h,013h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,013h,013h,013h,012h,011h,012h,012h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,013h,013h,000h
       DB 000h,000h,013h,012h,011h,012h,013h,000h,000h,000h,000h,000h,000h
       DB 000h,013h,013h,013h,012h,012h,012h,012h,012h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,013h,012h,012h,012h,013h,013h,000h
       DB 000h,013h,012h,011h,012h,000h,000h,000h,000h,000h,012h,012h,012h
       DB 012h,012h,012h,011h,011h,011h,012h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 013h,013h,013h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,013h,012h,012h,012h,011h,011h,012h,012h,012h,000h,013h
       DB 012h,011h,012h,013h,000h,000h,000h,000h,012h,011h,011h,011h,011h
       DB 011h,011h,011h,012h,013h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,013h,013h,013h,013h,012h,012h
       DB 013h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,013h
       DB 012h,012h,011h,011h,011h,010h,011h,011h,012h,000h,013h,012h,011h
       DB 011h,012h,000h,000h,000h,013h,012h,011h,010h,010h,010h,010h,010h
       DB 011h,012h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,013h
       DB 013h,012h,012h,012h,012h,012h,012h,012h,012h,012h,013h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,013h,012h,011h,011h
       DB 011h,010h,010h,010h,010h,011h,012h,000h,013h,012h,011h,011h,012h
       DB 000h,000h,000h,013h,012h,011h,010h,010h,00Fh,010h,011h,011h,013h
       DB 000h,000h,000h,013h,013h,012h,012h,012h,012h,012h,012h,012h,011h
       DB 011h,011h,011h,011h,011h,011h,011h,012h,013h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,013h,012h,011h,011h,010h,010h,00Fh
       DB 00Fh,010h,011h,011h,012h,000h,013h,012h,011h,011h,012h,013h,000h
       DB 000h,013h,012h,011h,010h,00Fh,010h,011h,011h,012h,000h,000h,013h
       DB 012h,012h,012h,012h,011h,011h,011h,011h,011h,011h,011h,010h,010h
       DB 010h,010h,010h,011h,011h,012h,013h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,013h,012h,011h,011h,010h,00Fh,010h,010h,010h,010h
       DB 011h,012h,000h,000h,013h,012h,011h,011h,011h,012h,000h,000h,012h
       DB 011h,011h,010h,00Fh,010h,011h,012h,013h,000h,013h,013h,012h,011h
       DB 011h,011h,011h,010h,010h,010h,010h,010h,010h,010h,00Fh,00Fh,00Fh
       DB 010h,010h,011h,012h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 013h,013h,012h,012h,012h,012h,013h,000h,000h,000h,000h,000h,000h
       DB 013h,013h,012h,011h,011h,010h,010h,011h,011h,011h,011h,011h,012h
       DB 000h,013h,012h,012h,011h,010h,011h,012h,013h,000h,012h,011h,010h
       DB 00Fh,010h,011h,011h,012h,000h,000h,013h,012h,012h,011h,010h,010h
       DB 010h,010h,010h,010h,011h,010h,010h,00Fh,00Fh,00Eh,00Fh,010h,011h
       DB 011h,012h,000h,000h,000h,000h,000h,000h,000h,000h,000h,013h,012h
       DB 011h,011h,011h,011h,012h,013h,000h,000h,000h,000h,013h,013h,012h
       DB 012h,011h,010h,011h,011h,011h,012h,012h,012h,012h,012h,000h,013h
       DB 012h,011h,011h,010h,011h,011h,012h,000h,012h,011h,010h,00Fh,010h
       DB 011h,012h,013h,000h,013h,013h,012h,011h,011h,011h,011h,011h,010h
       DB 010h,011h,011h,011h,010h,010h,010h,00Fh,00Fh,010h,011h,012h,013h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,012h,011h,010h
       DB 010h,010h,010h,011h,012h,000h,000h,013h,013h,012h,012h,011h,011h
       DB 011h,011h,012h,012h,012h,013h,000h,000h,000h,000h,000h,013h,012h
       DB 011h,011h,010h,011h,012h,013h,012h,011h,010h,010h,011h,011h,012h
       DB 000h,000h,013h,012h,011h,011h,011h,012h,012h,011h,010h,010h,011h
       DB 012h,011h,011h,011h,010h,010h,010h,010h,011h,012h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,013h,011h,011h,010h,00Fh
       DB 010h,010h,011h,000h,000h,013h,012h,012h,011h,011h,010h,011h,012h
       DB 013h,013h,000h,000h,000h,000h,000h,000h,000h,000h,013h,012h,011h
       DB 010h,010h,011h,012h,012h,011h,010h,010h,011h,012h,013h,000h,013h
       DB 012h,012h,012h,012h,012h,013h,012h,011h,010h,011h,011h,012h,012h
       DB 012h,011h,011h,011h,010h,010h,011h,012h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,012h,011h,010h,00Fh,00Fh,010h
       DB 011h,012h,000h,013h,012h,011h,011h,010h,011h,011h,012h,000h,000h
       DB 000h,000h,013h,012h,012h,000h,000h,000h,013h,012h,011h,011h,010h
       DB 010h,011h,012h,011h,010h,011h,011h,012h,000h,013h,012h,012h,013h
       DB 000h,000h,000h,013h,012h,011h,011h,011h,012h,013h,000h,013h,012h
       DB 012h,011h,011h,011h,011h,012h,000h,000h,000h,000h,000h,013h,013h
       DB 013h,013h,013h,000h,000h,013h,011h,011h,010h,00Fh,010h,011h,012h
       DB 000h,013h,012h,012h,011h,010h,011h,012h,013h,000h,000h,013h,012h
       DB 012h,011h,012h,000h,000h,000h,000h,013h,012h,011h,011h,010h,011h
       DB 011h,010h,010h,011h,012h,013h,000h,000h,013h,013h,000h,000h,000h
       DB 000h,012h,011h,011h,011h,012h,013h,000h,000h,000h,000h,013h,012h
       DB 012h,011h,012h,013h,000h,000h,000h,000h,013h,012h,012h,011h,012h
       DB 012h,013h,000h,000h,012h,011h,011h,00Fh,00Fh,010h,011h,013h,013h
       DB 013h,012h,011h,010h,011h,012h,013h,012h,012h,012h,011h,011h,011h
       DB 012h,000h,000h,000h,000h,000h,013h,012h,011h,010h,010h,010h,010h
       DB 010h,011h,012h,013h,000h,000h,000h,000h,000h,000h,000h,013h,012h
       DB 011h,010h,011h,012h,000h,000h,000h,000h,000h,000h,000h,013h,012h
       DB 012h,000h,000h,000h,000h,000h,013h,012h,011h,011h,011h,011h,012h
       DB 013h,000h,013h,012h,011h,010h,00Fh,010h,011h,013h,000h,013h,012h
       DB 011h,011h,011h,012h,012h,011h,011h,011h,011h,010h,011h,012h,000h
       DB 000h,000h,000h,000h,013h,012h,011h,010h,010h,010h,011h,011h,011h
       DB 011h,012h,000h,000h,000h,000h,000h,000h,000h,013h,012h,011h,010h
       DB 011h,012h,013h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,013h,012h,011h,010h,010h,010h,011h,012h,012h
       DB 013h,012h,011h,011h,010h,00Fh,011h,012h,000h,013h,012h,012h,011h
       DB 011h,011h,011h,011h,010h,010h,010h,011h,012h,013h,000h,000h,000h
       DB 000h,000h,013h,012h,011h,010h,010h,011h,012h,011h,010h,011h,012h
       DB 013h,000h,000h,000h,000h,000h,000h,013h,012h,011h,010h,011h,011h
       DB 012h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,013h,012h,011h,010h,00Fh,010h,010h,011h,011h,012h,013h
       DB 012h,011h,010h,010h,010h,011h,013h,013h,013h,012h,011h,011h,011h
       DB 011h,011h,011h,011h,010h,011h,012h,013h,000h,000h,000h,000h,000h
       DB 013h,012h,011h,010h,010h,011h,012h,011h,011h,011h,011h,012h,000h
       DB 000h,000h,000h,000h,000h,012h,011h,011h,010h,010h,011h,012h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,012h,011h,010h,010h,00Fh,010h,010h,011h,011h,012h,013h,011h
       DB 011h,00Fh,010h,011h,013h,000h,013h,012h,012h,011h,012h,012h,012h
       DB 012h,011h,011h,011h,012h,000h,000h,000h,000h,000h,000h,012h,012h
       DB 011h,010h,011h,011h,012h,012h,011h,010h,011h,012h,013h,000h,000h
       DB 000h,000h,013h,012h,011h,010h,010h,010h,011h,012h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,013h
       DB 011h,011h,010h,010h,010h,010h,010h,011h,011h,012h,011h,010h,010h
       DB 010h,011h,012h,000h,013h,013h,012h,011h,011h,012h,013h,013h,012h
       DB 012h,012h,012h,000h,000h,000h,000h,000h,013h,012h,012h,011h,010h
       DB 011h,012h,013h,012h,011h,011h,010h,011h,012h,013h,000h,000h,000h
       DB 013h,012h,011h,010h,00Fh,010h,011h,012h,013h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,013h,012h,011h
       DB 010h,010h,011h,011h,010h,010h,011h,011h,010h,010h,00Fh,010h,010h
       DB 011h,013h,000h,013h,012h,011h,010h,011h,012h,000h,000h,000h,000h
       DB 013h,013h,012h,012h,000h,000h,013h,012h,011h,011h,010h,011h,012h
       DB 000h,013h,012h,011h,010h,011h,011h,012h,000h,000h,000h,013h,012h
       DB 011h,010h,00Fh,010h,011h,011h,012h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,013h,012h,011h,011h,010h
       DB 011h,012h,011h,010h,010h,010h,010h,010h,00Fh,00Fh,010h,011h,012h
       DB 000h,013h,012h,011h,010h,011h,012h,013h,013h,012h,012h,012h,012h
       DB 011h,012h,000h,000h,013h,012h,011h,010h,010h,011h,012h,000h,000h
       DB 012h,011h,011h,010h,011h,012h,013h,000h,013h,012h,012h,011h,011h
       DB 010h,00Fh,010h,011h,012h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,012h,012h,011h,010h,011h,012h
       DB 012h,011h,010h,010h,00Fh,00Fh,00Eh,00Fh,010h,011h,012h,000h,013h
       DB 012h,012h,011h,011h,011h,012h,012h,011h,011h,010h,011h,011h,012h
       DB 000h,000h,013h,012h,011h,010h,010h,011h,012h,000h,000h,013h,012h
       DB 011h,010h,011h,011h,012h,000h,000h,012h,012h,012h,011h,010h,00Fh
       DB 010h,011h,012h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,013h,012h,011h,010h,011h,012h,000h,012h
       DB 011h,010h,010h,00Fh,00Eh,00Fh,010h,010h,011h,013h,000h,013h,012h
       DB 011h,010h,011h,011h,011h,010h,010h,00Fh,010h,011h,012h,013h,000h
       DB 013h,012h,011h,010h,011h,011h,012h,000h,000h,013h,012h,011h,010h
       DB 010h,011h,012h,013h,000h,000h,013h,012h,011h,011h,010h,010h,011h
       DB 012h,013h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,013h,012h,011h,011h,011h,012h,000h,000h,012h,011h
       DB 010h,010h,00Fh,00Fh,00Fh,010h,011h,012h,000h,013h,012h,011h,010h
       DB 010h,010h,010h,00Fh,00Fh,00Fh,010h,011h,012h,013h,000h,013h,012h
       DB 011h,010h,011h,012h,013h,000h,000h,000h,012h,011h,011h,010h,011h
       DB 011h,012h,013h,000h,013h,012h,012h,011h,010h,010h,011h,011h,012h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,013h,012h,012h,011h,011h,012h,000h,000h,000h,012h,011h,010h
       DB 010h,010h,010h,010h,011h,012h,000h,013h,012h,011h,011h,011h,011h
       DB 010h,010h,010h,00Fh,010h,011h,012h,013h,000h,013h,012h,011h,011h
       DB 011h,012h,000h,000h,000h,000h,013h,012h,011h,010h,010h,011h,011h
       DB 012h,000h,000h,013h,012h,012h,011h,010h,011h,011h,012h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 013h,012h,011h,011h,011h,012h,000h,000h,000h,012h,011h,011h,011h
       DB 010h,011h,011h,012h,013h,000h,013h,012h,012h,012h,011h,011h,011h
       DB 011h,010h,010h,011h,012h,012h,000h,013h,012h,011h,011h,012h,012h
       DB 000h,000h,000h,000h,000h,012h,011h,011h,010h,010h,011h,011h,013h
       DB 000h,000h,013h,012h,011h,010h,010h,011h,012h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,013h,012h
       DB 012h,012h,012h,012h,000h,000h,000h,000h,013h,012h,012h,011h,012h
       DB 012h,012h,013h,000h,000h,000h,013h,013h,012h,012h,012h,012h,011h
       DB 011h,011h,011h,012h,000h,013h,012h,012h,012h,013h,000h,000h,000h
       DB 000h,000h,000h,013h,012h,011h,010h,010h,010h,011h,012h,013h,000h
       DB 013h,012h,011h,011h,011h,011h,012h,013h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,013h,013h,013h,013h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,013h,013h,013h,013h,013h
       DB 013h,000h,000h,000h,000h,000h,000h,000h,013h,013h,012h,012h,012h
       DB 012h,013h,000h,013h,013h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,012h,011h,011h,010h,010h,011h,011h,012h,000h,000h,013h
       DB 012h,012h,011h,011h,011h,012h,013h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,013h,013h,013h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 013h,012h,011h,011h,010h,010h,011h,012h,013h,000h,000h,000h,013h
       DB 012h,012h,012h,012h,013h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,012h
       DB 012h,011h,011h,011h,011h,011h,012h,000h,000h,000h,000h,013h,013h
       DB 013h,013h,013h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,013h,012h
       DB 012h,012h,012h,011h,012h,013h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,013h
       DB 013h,012h,012h,012h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h
ScoreL DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,013h,013h
       DB 013h,013h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,013h,013h,013h,013h
       DB 012h,012h,012h,013h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,013h,013h,013h,013h,012h,012h
       DB 012h,012h,011h,011h,012h,013h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,013h,013h,013h,013h,013h,013h
       DB 013h,013h,000h,000h,000h,000h,000h,013h,013h,012h,012h,012h,012h
       DB 011h,011h,011h,011h,011h,012h,013h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,013h,013h,012h,012h,012h,012h
       DB 012h,012h,012h,012h,013h,013h,000h,000h,013h,012h,012h,012h,011h
       DB 011h,011h,011h,010h,010h,011h,011h,012h,013h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,013h,012h,012h
       DB 012h,012h,012h,012h,012h,013h,013h,000h,000h,000h,000h,013h,012h
       DB 012h,012h,012h,013h,013h,000h,000h,013h,013h,013h,012h,011h,011h
       DB 011h,011h,011h,011h,011h,011h,012h,012h,013h,000h,013h,013h,012h
       DB 011h,011h,011h,010h,010h,010h,00Fh,011h,012h,013h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,013h,013h,012h
       DB 011h,011h,011h,011h,011h,011h,011h,012h,012h,012h,013h,000h,013h
       DB 012h,011h,011h,011h,012h,012h,012h,013h,013h,000h,013h,013h,012h
       DB 011h,010h,010h,010h,010h,010h,010h,011h,011h,011h,012h,013h,000h
       DB 013h,012h,012h,011h,011h,011h,011h,011h,011h,011h,012h,013h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,013h,013h
       DB 013h,013h,013h,013h,000h,000h,000h,000h,000h,000h,000h,013h,012h
       DB 012h,011h,011h,010h,010h,010h,010h,010h,010h,011h,011h,012h,012h
       DB 000h,013h,013h,012h,011h,010h,011h,011h,012h,012h,012h,013h,000h
       DB 013h,013h,012h,011h,011h,011h,011h,011h,010h,00Fh,010h,011h,012h
       DB 013h,000h,000h,013h,012h,012h,012h,012h,012h,012h,011h,012h,013h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,013h,013h,013h
       DB 012h,012h,012h,012h,012h,012h,012h,013h,000h,000h,000h,000h,013h
       DB 012h,012h,011h,011h,010h,010h,011h,010h,010h,00Fh,010h,010h,011h
       DB 011h,012h,013h,000h,013h,012h,011h,010h,010h,010h,011h,011h,012h
       DB 012h,013h,000h,013h,012h,012h,012h,012h,012h,012h,011h,010h,00Fh
       DB 011h,011h,012h,013h,000h,013h,012h,013h,013h,013h,013h,013h,013h
       DB 013h,013h,000h,000h,000h,000h,000h,000h,000h,000h,000h,013h,012h
       DB 012h,012h,011h,011h,011h,011h,011h,011h,012h,012h,012h,013h,000h
       DB 000h,012h,012h,011h,011h,010h,011h,011h,011h,011h,010h,010h,00Fh
       DB 010h,010h,010h,011h,012h,000h,013h,012h,012h,011h,010h,00Fh,010h
       DB 011h,011h,012h,013h,000h,013h,013h,012h,013h,013h,000h,013h,012h
       DB 011h,00Fh,010h,011h,012h,013h,000h,013h,012h,013h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,013h
       DB 012h,011h,011h,011h,011h,010h,010h,010h,010h,010h,011h,011h,012h
       DB 012h,013h,000h,013h,012h,011h,011h,011h,012h,012h,012h,011h,011h
       DB 011h,010h,00Fh,010h,010h,011h,012h,013h,000h,013h,013h,012h,011h
       DB 010h,00Fh,010h,011h,011h,012h,013h,000h,013h,012h,013h,000h,000h
       DB 013h,012h,011h,00Fh,011h,011h,012h,013h,000h,013h,012h,013h,000h
       DB 000h,013h,013h,013h,013h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 013h,012h,011h,011h,010h,010h,010h,011h,011h,011h,011h,011h,010h
       DB 010h,011h,011h,012h,013h,000h,013h,011h,011h,012h,012h,013h,013h
       DB 012h,012h,011h,011h,010h,010h,011h,011h,011h,012h,000h,013h,000h
       DB 013h,012h,011h,010h,00Fh,010h,011h,012h,013h,000h,000h,013h,012h
       DB 013h,013h,013h,012h,011h,010h,011h,012h,012h,013h,000h,013h,012h
       DB 013h,013h,013h,013h,012h,012h,013h,000h,000h,000h,000h,000h,000h
       DB 000h,013h,012h,011h,011h,010h,011h,011h,011h,012h,012h,012h,012h
       DB 012h,011h,011h,010h,011h,011h,012h,000h,013h,012h,011h,012h,013h
       DB 013h,000h,013h,013h,012h,011h,011h,011h,011h,012h,012h,012h,000h
       DB 013h,000h,013h,012h,011h,011h,00Fh,010h,011h,012h,013h,013h,000h
       DB 013h,012h,012h,012h,012h,011h,010h,010h,011h,012h,013h,000h,000h
       DB 013h,012h,012h,012h,012h,012h,011h,012h,013h,000h,000h,000h,000h
       DB 000h,000h,013h,012h,011h,011h,010h,011h,011h,012h,012h,013h,013h
       DB 013h,013h,012h,012h,011h,011h,011h,011h,012h,000h,013h,012h,012h
       DB 012h,013h,000h,000h,000h,013h,013h,012h,011h,012h,012h,012h,013h
       DB 013h,000h,013h,000h,000h,013h,012h,011h,010h,00Fh,010h,011h,012h
       DB 013h,000h,013h,012h,012h,011h,010h,00Fh,010h,011h,011h,012h,013h
       DB 000h,000h,013h,012h,011h,011h,011h,011h,012h,013h,000h,000h,000h
       DB 000h,000h,000h,000h,013h,012h,011h,010h,010h,011h,012h,012h,013h
       DB 000h,000h,000h,000h,013h,012h,012h,011h,012h,012h,013h,000h,013h
       DB 012h,012h,013h,000h,000h,000h,000h,000h,013h,013h,012h,013h,013h
       DB 013h,000h,000h,013h,000h,000h,000h,013h,012h,011h,010h,00Fh,010h
       DB 011h,012h,013h,000h,013h,012h,011h,010h,010h,010h,011h,011h,012h
       DB 013h,000h,000h,013h,012h,012h,011h,010h,010h,011h,012h,013h,000h
       DB 000h,000h,000h,000h,000h,013h,012h,011h,011h,00Fh,010h,011h,012h
       DB 013h,000h,000h,000h,000h,000h,000h,013h,012h,012h,012h,013h,000h
       DB 000h,013h,012h,013h,013h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,013h,013h,000h,000h,000h,000h,013h,012h,011h,010h
       DB 00Fh,010h,011h,012h,013h,000h,013h,012h,011h,00Fh,011h,011h,011h
       DB 012h,013h,000h,000h,013h,012h,011h,011h,010h,00Fh,010h,011h,012h
       DB 013h,000h,000h,000h,000h,000h,000h,013h,012h,011h,010h,00Fh,010h
       DB 011h,012h,012h,013h,000h,000h,000h,000h,000h,000h,013h,013h,013h
       DB 000h,000h,013h,013h,012h,013h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,013h,013h,013h,013h,013h,013h,000h,000h,000h,000h,013h,012h
       DB 011h,010h,00Fh,010h,011h,012h,013h,000h,013h,012h,011h,010h,011h
       DB 012h,012h,013h,000h,000h,013h,012h,011h,011h,011h,011h,010h,011h
       DB 011h,012h,013h,000h,000h,000h,000h,000h,000h,013h,012h,012h,011h
       DB 010h,010h,011h,011h,012h,012h,013h,013h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,013h,013h,012h,012h,013h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,013h,013h,013h,000h,000h,000h
       DB 013h,012h,011h,010h,00Fh,010h,011h,012h,013h,000h,013h,012h,011h
       DB 011h,012h,013h,013h,000h,000h,013h,012h,011h,011h,012h,012h,011h
       DB 011h,011h,012h,013h,000h,000h,000h,000h,000h,000h,000h,000h,013h
       DB 012h,011h,011h,010h,010h,011h,011h,012h,012h,012h,012h,012h,012h
       DB 012h,012h,013h,013h,000h,000h,013h,012h,012h,013h,013h,000h,000h
       DB 000h,000h,000h,013h,012h,012h,013h,013h,000h,000h,000h,012h,013h
       DB 000h,000h,013h,012h,011h,010h,00Fh,010h,011h,012h,013h,000h,013h
       DB 012h,011h,010h,011h,012h,013h,000h,013h,012h,011h,011h,012h,013h
       DB 013h,012h,012h,012h,012h,013h,000h,013h,000h,000h,000h,000h,000h
       DB 000h,000h,013h,012h,011h,011h,011h,010h,010h,011h,011h,011h,011h
       DB 011h,011h,011h,012h,012h,012h,013h,000h,000h,013h,012h,012h,013h
       DB 000h,000h,000h,000h,000h,013h,012h,012h,012h,012h,013h,013h,000h
       DB 012h,013h,000h,000h,013h,012h,011h,010h,00Fh,010h,011h,012h,013h
       DB 000h,013h,012h,012h,011h,010h,011h,012h,013h,000h,013h,012h,011h
       DB 012h,013h,000h,013h,013h,013h,013h,000h,013h,012h,013h,000h,000h
       DB 000h,000h,000h,000h,000h,013h,012h,012h,011h,011h,010h,010h,010h
       DB 010h,010h,010h,010h,011h,011h,011h,012h,012h,013h,000h,000h,013h
       DB 012h,013h,000h,000h,000h,000h,013h,012h,012h,011h,011h,012h,012h
       DB 012h,000h,013h,012h,013h,013h,012h,011h,011h,010h,00Fh,010h,011h
       DB 013h,013h,000h,013h,012h,013h,012h,011h,010h,011h,012h,013h,000h
       DB 013h,012h,011h,012h,013h,000h,000h,000h,000h,013h,012h,012h,013h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,013h,013h,012h,012h,011h
       DB 011h,011h,011h,011h,010h,010h,010h,010h,011h,011h,012h,012h,013h
       DB 000h,013h,012h,012h,000h,000h,000h,000h,013h,012h,011h,010h,010h
       DB 010h,011h,012h,000h,013h,012h,013h,013h,012h,011h,010h,00Fh,010h
       DB 011h,012h,013h,000h,000h,013h,012h,013h,012h,011h,010h,00Fh,011h
       DB 012h,013h,000h,013h,012h,011h,012h,013h,000h,013h,013h,012h,012h
       DB 011h,012h,013h,000h,000h,000h,000h,000h,000h,000h,000h,000h,013h
       DB 013h,012h,012h,012h,012h,011h,011h,011h,010h,00Fh,010h,011h,011h
       DB 012h,012h,000h,013h,012h,012h,013h,000h,000h,000h,013h,012h,011h
       DB 010h,00Fh,010h,011h,012h,000h,013h,013h,012h,012h,011h,011h,010h
       DB 00Fh,010h,011h,012h,013h,000h,013h,012h,012h,013h,013h,012h,011h
       DB 010h,00Fh,011h,012h,013h,000h,013h,012h,012h,013h,013h,012h,012h
       DB 011h,011h,011h,012h,013h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,013h,013h,013h,013h,012h,012h,011h,011h,010h,00Fh
       DB 010h,011h,011h,012h,000h,013h,012h,012h,012h,013h,000h,000h,012h
       DB 012h,011h,010h,00Fh,010h,011h,012h,000h,000h,013h,012h,011h,011h
       DB 010h,00Fh,010h,011h,012h,013h,000h,000h,013h,012h,012h,013h,000h
       DB 013h,012h,011h,010h,011h,012h,013h,000h,000h,013h,013h,012h,012h
       DB 011h,011h,011h,010h,011h,011h,012h,013h,000h,000h,000h,000h,000h
       DB 000h,000h,013h,013h,013h,013h,013h,000h,013h,013h,012h,012h,011h
       DB 010h,00Fh,00Fh,010h,011h,012h,000h,013h,012h,011h,012h,012h,013h
       DB 013h,012h,011h,010h,00Fh,010h,010h,011h,012h,000h,000h,013h,012h
       DB 011h,010h,00Fh,010h,011h,011h,012h,013h,000h,000h,013h,012h,011h
       DB 012h,013h,013h,012h,011h,010h,010h,011h,012h,013h,000h,000h,013h
       DB 012h,011h,011h,010h,010h,010h,010h,011h,012h,013h,000h,000h,000h
       DB 000h,000h,000h,013h,012h,012h,012h,012h,012h,013h,013h,013h,012h
       DB 011h,011h,010h,00Fh,010h,011h,011h,012h,000h,013h,012h,011h,011h
       DB 012h,012h,012h,011h,010h,00Fh,00Fh,010h,011h,012h,013h,000h,000h
       DB 013h,012h,011h,010h,010h,011h,011h,012h,013h,000h,000h,013h,012h
       DB 011h,011h,012h,013h,000h,013h,012h,011h,00Fh,010h,011h,012h,013h
       DB 000h,000h,013h,012h,011h,011h,010h,011h,011h,011h,011h,012h,013h
       DB 000h,000h,000h,000h,013h,012h,012h,011h,011h,011h,011h,012h,012h
       DB 012h,012h,011h,010h,00Fh,010h,011h,011h,012h,013h,000h,012h,011h
       DB 011h,010h,010h,011h,011h,010h,00Fh,00Fh,010h,011h,012h,012h,013h
       DB 000h,013h,012h,011h,010h,010h,011h,011h,012h,013h,000h,000h,013h
       DB 012h,011h,010h,011h,012h,013h,000h,013h,012h,011h,010h,00Fh,010h
       DB 011h,012h,013h,000h,000h,013h,012h,011h,011h,011h,011h,012h,012h
       DB 012h,013h,000h,000h,000h,000h,013h,012h,012h,011h,010h,010h,011h
       DB 011h,011h,011h,011h,010h,010h,010h,010h,011h,012h,013h,000h,000h
       DB 012h,012h,012h,011h,011h,010h,010h,010h,010h,011h,011h,012h,012h
       DB 013h,000h,000h,013h,012h,011h,011h,011h,011h,012h,013h,000h,000h
       DB 013h,012h,011h,010h,010h,011h,012h,012h,013h,000h,013h,012h,011h
       DB 010h,010h,010h,011h,012h,013h,000h,013h,012h,012h,012h,012h,012h
       DB 013h,013h,013h,013h,000h,000h,000h,000h,000h,013h,012h,012h,011h
       DB 010h,010h,010h,010h,010h,010h,010h,011h,011h,011h,012h,013h,000h
       DB 000h,000h,013h,013h,012h,012h,012h,011h,011h,011h,011h,012h,012h
       DB 012h,013h,000h,000h,013h,013h,013h,012h,012h,012h,013h,013h,000h
       DB 000h,013h,013h,012h,011h,011h,011h,011h,012h,012h,013h,000h,013h
       DB 012h,011h,011h,011h,011h,011h,012h,013h,000h,013h,012h,013h,013h
       DB 013h,013h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,013h
       DB 012h,012h,011h,011h,010h,011h,011h,011h,011h,012h,012h,012h,013h
       DB 000h,000h,000h,000h,000h,000h,013h,013h,012h,012h,012h,012h,012h
       DB 012h,013h,013h,000h,000h,000h,000h,000h,013h,013h,013h,013h,000h
       DB 000h,000h,000h,013h,012h,012h,011h,012h,012h,012h,012h,013h,000h
       DB 000h,000h,013h,012h,012h,012h,012h,011h,011h,012h,013h,000h,013h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,013h,013h,012h,011h,011h,012h,012h,012h,012h,013h,013h
       DB 013h,000h,000h,000h,000h,000h,000h,000h,000h,000h,013h,013h,013h
       DB 013h,013h,013h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,013h,012h,012h,012h,012h,013h,013h,013h
       DB 000h,000h,000h,000h,000h,013h,013h,013h,013h,012h,012h,012h,012h
       DB 013h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,013h,012h,012h,012h,013h,013h,013h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,013h,013h,013h,013h,013h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,013h,013h
       DB 013h,013h,013h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,013h,013h,013h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h

SpeedL DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,013h,013h,013h,012h,012h,013h,013h,013h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,013h,013h,012h,012h,011h
       DB 011h,011h,011h,011h,012h,013h,013h,000h,013h,012h,012h,012h,012h
       DB 012h,012h,012h,013h,013h,013h,013h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,013h,012h,011h,011h,012h
       DB 013h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,013h,012h,012h,011h,011h,011h,010h,010h,011h,012h,013h
       DB 000h,000h,013h,012h,010h,011h,011h,011h,011h,012h,012h,012h,012h
       DB 013h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,012h,011h,010h,00Fh,00Fh,010h,011h,012h,012h,000h,000h
       DB 013h,013h,013h,013h,012h,012h,012h,013h,013h,000h,000h,013h,012h
       DB 011h,010h,010h,011h,012h,013h,013h,013h,000h,012h,011h,010h,011h
       DB 012h,012h,012h,012h,013h,013h,013h,000h,000h,013h,013h,013h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,012h,011h,00Fh,00Fh
       DB 010h,00Fh,00Fh,010h,010h,011h,012h,000h,000h,013h,012h,012h,012h
       DB 011h,012h,012h,012h,012h,013h,000h,012h,012h,011h,012h,012h,013h
       DB 013h,000h,000h,013h,011h,010h,010h,012h,012h,013h,013h,013h,013h
       DB 000h,000h,000h,013h,012h,012h,012h,012h,013h,000h,000h,000h,000h
       DB 000h,000h,000h,012h,010h,00Fh,010h,011h,011h,011h,010h,00Fh,00Fh
       DB 010h,011h,012h,000h,013h,012h,011h,013h,000h,013h,013h,012h,011h
       DB 012h,013h,013h,012h,011h,012h,013h,013h,000h,000h,013h,012h,011h
       DB 011h,011h,012h,013h,000h,000h,000h,000h,000h,013h,013h,012h,012h
       DB 011h,011h,011h,012h,013h,000h,000h,000h,000h,000h,013h,012h,00Fh
       DB 011h,011h,012h,000h,000h,011h,010h,010h,010h,012h,013h,000h,013h
       DB 012h,011h,000h,000h,000h,000h,000h,013h,011h,012h,000h,013h,012h
       DB 012h,013h,000h,000h,000h,000h,000h,000h,013h,011h,012h,013h,000h
       DB 000h,000h,000h,013h,012h,012h,012h,011h,011h,00Fh,010h,011h,012h
       DB 013h,000h,000h,000h,000h,012h,010h,00Fh,011h,012h,000h,000h,000h
       DB 000h,012h,011h,012h,013h,000h,000h,013h,013h,011h,013h,000h,000h
       DB 000h,000h,000h,013h,012h,013h,000h,012h,010h,011h,011h,012h,012h
       DB 013h,013h,000h,013h,012h,013h,013h,013h,000h,000h,000h,013h,012h
       DB 012h,011h,012h,010h,00Fh,00Fh,010h,011h,012h,000h,000h,000h,000h
       DB 013h,011h,010h,00Fh,010h,012h,012h,000h,000h,000h,012h,013h,020h
       DB 000h,000h,000h,013h,011h,011h,013h,013h,000h,000h,013h,012h,012h
       DB 013h,000h,012h,010h,00Fh,00Fh,00Fh,010h,010h,011h,012h,000h,013h
       DB 012h,012h,012h,012h,013h,000h,013h,012h,011h,012h,000h,011h,010h
       DB 00Fh,010h,011h,012h,013h,000h,000h,000h,000h,013h,012h,011h,010h
       DB 010h,010h,011h,012h,013h,000h,000h,000h,000h,000h,000h,013h,012h
       DB 011h,012h,012h,012h,012h,011h,011h,012h,013h,000h,012h,010h,010h
       DB 011h,011h,011h,011h,012h,012h,013h,000h,011h,010h,010h,011h,012h
       DB 000h,013h,012h,012h,011h,000h,000h,011h,010h,00Fh,010h,011h,013h
       DB 000h,000h,000h,000h,000h,013h,013h,013h,000h,013h,011h,010h,010h
       DB 012h,013h,000h,000h,000h,000h,013h,012h,011h,011h,011h,011h,011h
       DB 012h,012h,013h,000h,013h,012h,011h,011h,012h,013h,013h,013h,013h
       DB 000h,000h,013h,010h,010h,011h,012h,012h,013h,013h,012h,012h,011h
       DB 012h,000h,012h,011h,00Fh,010h,011h,013h,000h,000h,000h,000h,013h
       DB 011h,011h,012h,000h,000h,013h,012h,011h,010h,011h,013h,000h,000h
       DB 000h,000h,012h,011h,013h,012h,013h,013h,000h,000h,000h,013h,012h
       DB 011h,013h,000h,000h,000h,000h,000h,000h,000h,013h,012h,011h,012h
       DB 012h,013h,013h,000h,013h,013h,012h,012h,011h,012h,011h,010h,00Fh
       DB 010h,011h,013h,000h,000h,000h,013h,012h,011h,010h,011h,012h,000h
       DB 000h,013h,012h,011h,011h,012h,013h,000h,000h,012h,012h,011h,012h
       DB 013h,000h,000h,013h,012h,012h,012h,011h,011h,012h,013h,000h,000h
       DB 000h,000h,000h,013h,011h,011h,012h,013h,013h,000h,000h,000h,013h
       DB 013h,013h,013h,012h,012h,011h,011h,010h,011h,012h,013h,000h,000h
       DB 000h,013h,011h,011h,010h,00Fh,011h,011h,012h,012h,012h,012h,011h
       DB 012h,013h,000h,013h,012h,011h,011h,012h,013h,000h,000h,012h,012h
       DB 011h,011h,010h,011h,011h,012h,013h,013h,013h,000h,000h,013h,012h
       DB 010h,011h,012h,012h,012h,013h,013h,000h,000h,000h,000h,013h,013h
       DB 012h,011h,011h,012h,012h,000h,000h,000h,000h,012h,011h,010h,00Fh
       DB 00Eh,00Fh,010h,011h,011h,011h,011h,012h,013h,000h,000h,013h,011h
       DB 010h,011h,012h,013h,000h,013h,012h,011h,011h,010h,010h,010h,010h
       DB 011h,011h,011h,011h,012h,013h,000h,012h,011h,010h,011h,011h,011h
       DB 012h,012h,012h,012h,013h,013h,000h,013h,012h,012h,012h,012h,013h
       DB 000h,000h,000h,000h,012h,011h,011h,010h,00Fh,00Fh,00Fh,010h,010h
       DB 010h,012h,013h,000h,000h,013h,012h,011h,011h,011h,012h,013h,000h
       DB 013h,012h,011h,010h,010h,00Fh,00Fh,010h,010h,010h,010h,011h,013h
       DB 013h,000h,012h,011h,010h,010h,010h,010h,011h,011h,011h,012h,013h
       DB 000h,000h,013h,013h,013h,012h,013h,000h,000h,000h,000h,000h,000h
       DB 013h,012h,011h,011h,011h,011h,011h,011h,011h,013h,000h,000h,013h
       DB 013h,012h,011h,012h,012h,012h,013h,000h,013h,012h,011h,011h,010h
       DB 010h,010h,010h,011h,011h,011h,012h,013h,000h,000h,012h,011h,011h
       DB 011h,011h,012h,012h,012h,012h,000h,000h,000h,013h,013h,013h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,013h,013h,012h
       DB 012h,012h,013h,013h,000h,000h,013h,012h,012h,012h,012h,013h,013h
       DB 013h,013h,000h,012h,012h,012h,011h,011h,011h,011h,011h,011h,012h
       DB 013h,000h,000h,000h,013h,012h,012h,012h,013h,013h,013h,013h,013h
       DB 000h,000h,013h,013h,013h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,013h,013h,013h,013h,013h,000h,000h,000h,000h,000h,013h
       DB 013h,013h,013h,012h,012h,013h,013h,013h,000h,000h,013h,013h,013h
       DB 013h,013h,013h,013h,013h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h

  Logo DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,013h,013h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,013h,011h,011h,013h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,013h,011h,010h,00Fh,010h,013h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,013h,010h,00Dh
       DB 00Dh,00Ch,00Ch,010h,013h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 013h,010h,00Dh,00Bh,00Ah,00Ah,00Ah,00Dh,013h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,013h,011h,00Fh,00Ch,00Ah,00Ah,00Ah,009h,009h,00Dh,011h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,013h,011h,00Dh,00Ch,00Ah,009h,009h,009h
       DB 009h,009h,00Ah,00Fh,013h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,013h,011h,00Dh,00Bh,00Ah
       DB 00Ah,009h,008h,008h,008h,009h,00Ah,00Dh,013h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,013h,010h
       DB 00Dh,00Bh,00Ah,00Ah,009h,009h,008h,007h,008h,009h,009h,00Ch,012h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,013h,011h,00Dh,00Bh,00Ah,00Ah,009h,009h,008h,008h,007h,008h
       DB 008h,009h,00Ch,011h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 013h,013h,013h,013h,013h,013h,013h,013h,013h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,013h,010h,00Ch,00Bh,00Ah,00Ah,009h
       DB 009h,009h,008h,009h,009h,009h,00Ch,010h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,013h,013h,011h,011h,011h,011h,011h
       DB 012h,013h,013h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,013h,011h,00Fh,00Eh,00Dh,00Fh,00Fh,00Fh,00Fh,00Fh,010h
       DB 011h,013h,000h,000h,000h,000h,000h,000h,000h,000h,000h,011h,00Fh
       DB 00Dh,00Bh,00Ah,00Ah,009h,009h,009h,009h,00Ah,00Ah,00Ch,010h,013h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,013h,011h,010h,00Fh,00Dh
       DB 00Dh,00Dh,00Dh,00Dh,00Dh,00Fh,011h,012h,013h,013h,013h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,013h,013h,010h,00Dh,00Ch,00Ah,00Bh,00Bh,00Ah
       DB 00Bh,00Bh,00Bh,00Dh,00Dh,00Fh,011h,013h,000h,000h,000h,000h,000h
       DB 000h,000h,013h,013h,010h,00Dh,00Ch,00Bh,00Ah,00Ah,00Ah,00Ah,00Ah
       DB 00Bh,00Ch,010h,013h,000h,000h,000h,000h,000h,000h,013h,011h,00Fh
       DB 00Dh,00Bh,00Bh,00Bh,00Bh,00Ah,00Ah,00Bh,00Ch,00Dh,00Fh,010h,011h
       DB 012h,012h,013h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,013h,013h,013h,013h,013h,011h,00Dh,00Ch,00Bh,00Ah
       DB 00Ah,00Ah,009h,009h,009h,009h,009h,00Ah,00Bh,00Ch,00Dh,011h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,013h,011h,00Fh,00Dh,00Bh
       DB 00Ah,00Ah,00Bh,00Bh,00Ch,00Dh,011h,013h,000h,000h,000h,000h,000h
       DB 013h,011h,00Fh,00Dh,00Bh,00Bh,00Ah,00Ah,009h,009h,009h,00Ah,00Bh
       DB 00Ch,00Dh,010h,011h,012h,012h,013h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,013h,012h,013h,013h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,013h,013h,012h,010h,00Fh,010h,011h,010h,00Dh
       DB 00Bh,009h,009h,009h,009h,008h,008h,008h,009h,008h,009h,009h,009h
       DB 00Ah,00Dh,010h,013h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 013h,011h,010h,00Eh,00Dh,00Dh,00Dh,00Dh,00Dh,00Fh,011h,000h,000h
       DB 000h,000h,000h,013h,011h,00Dh,00Ch,00Bh,00Ah,00Ah,009h,009h,009h
       DB 00Ah,00Ah,00Bh,00Ch,00Dh,00Fh,010h,011h,012h,013h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,013h,013h,010h,00Dh,00Dh,010h
       DB 013h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,013h,012h,011h,010h,00Dh,00Dh,00Dh,00Dh
       DB 00Dh,00Dh,00Dh,00Ch,00Ah,009h,008h,008h,008h,008h,00Bh,00Dh,00Dh
       DB 00Ch,009h,009h,009h,00Ah,00Bh,00Fh,013h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,013h,013h,013h,011h,010h,00Fh,00Fh,010h
       DB 011h,012h,000h,000h,000h,000h,013h,011h,00Eh,00Ch,00Bh,00Ah,009h
       DB 009h,009h,00Ah,00Ah,00Bh,00Ch,00Dh,00Fh,010h,011h,012h,013h,013h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,013h,013h,010h,00Dh
       DB 00Ch,00Ah,00Bh,00Dh,010h,013h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,013h,013h,010h,00Dh,00Dh,00Ch
       DB 00Bh,00Ah,00Ah,00Bh,00Bh,00Ch,00Ch,00Bh,00Ah,009h,008h,008h,008h
       DB 009h,010h,000h,013h,011h,00Ch,009h,009h,009h,00Bh,00Dh,013h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 013h,011h,010h,011h,011h,011h,011h,013h,000h,000h,013h,010h,00Dh
       DB 00Bh,00Ah,009h,008h,008h,009h,00Ah,00Bh,00Dh,00Fh,011h,013h,013h
       DB 013h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,013h,012h
       DB 010h,00Dh,00Ch,00Ah,00Ah,00Ah,00Ah,00Bh,00Fh,013h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,013h,013h,013h,012h,010h,00Dh
       DB 00Ch,00Bh,00Ah,009h,00Ah,00Ah,00Ah,00Ah,00Bh,00Ch,00Bh,00Bh,00Ah
       DB 009h,009h,008h,008h,00Dh,012h,000h,000h,000h,00Dh,008h,008h,009h
       DB 00Bh,00Dh,012h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,011h,010h,010h,00Fh,00Fh,010h,012h,000h
       DB 013h,011h,00Dh,00Bh,00Ah,009h,008h,008h,008h,009h,00Bh,00Dh,010h
       DB 013h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,013h,013h,013h,013h,013h,013h,013h,011h,013h,013h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 013h,012h,010h,00Dh,00Bh,00Bh,00Ah,00Ah,009h,009h,00Ah,00Bh,00Dh
       DB 013h,000h,000h,000h,000h,000h,000h,000h,000h,013h,012h,010h,00Dh
       DB 00Dh,00Dh,00Ch,00Ah,00Ah,009h,008h,008h,008h,008h,009h,00Ah,00Bh
       DB 00Bh,00Ch,00Bh,00Bh,00Ah,009h,008h,008h,00Dh,013h,000h,000h,013h
       DB 00Dh,009h,008h,009h,00Bh,00Dh,011h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,013h,013h,011h,00Dh,00Dh,00Dh
       DB 00Dh,00Eh,011h,013h,011h,00Fh,00Ch,00Ah,009h,008h,008h,008h,009h
       DB 00Ah,00Ch,00Fh,013h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,013h,013h,013h
       DB 013h,013h,013h,011h,011h,010h,00Fh,00Dh,00Dh,00Dh,00Dh,00Dh,00Dh
       DB 00Dh,00Fh,011h,013h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,013h,013h,010h,00Dh,00Bh,00Bh,00Ah,00Ah,008h,008h,009h
       DB 00Ah,00Ah,00Ah,00Dh,011h,000h,000h,000h,000h,000h,013h,012h,011h
       DB 00Fh,00Dh,00Ch,00Bh,00Ah,00Ah,00Ah,009h,009h,008h,008h,007h,007h
       DB 008h,008h,009h,00Ah,00Bh,00Ch,00Ch,00Bh,00Ah,009h,008h,008h,00Ah
       DB 010h,000h,000h,011h,00Ch,008h,008h,009h,00Bh,00Eh,011h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,013h,011h,00Fh
       DB 00Ch,00Bh,00Ah,00Ah,00Ch,00Fh,013h,011h,010h,00Dh,00Ah,009h,008h
       DB 008h,009h,009h,00Ah,00Bh,00Dh,011h,013h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,013h,013h,013h,013h,013h,013h,012h,012h,011h
       DB 011h,010h,010h,00Fh,00Dh,00Dh,00Dh,00Dh,00Dh,00Ch,00Bh,00Ah,00Ah
       DB 00Ah,00Ah,00Ah,00Ah,00Ah,00Bh,00Dh,011h,013h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,013h,011h,00Dh,00Dh,00Bh,00Ah,00Ah,008h
       DB 008h,008h,009h,00Ah,00Ah,00Ah,00Bh,00Dh,011h,000h,000h,000h,013h
       DB 013h,010h,00Dh,00Bh,00Ah,00Ah,00Ah,00Ah,009h,009h,009h,008h,008h
       DB 008h,007h,006h,006h,007h,008h,009h,00Ah,00Ah,00Bh,00Ch,00Bh,00Bh
       DB 00Ah,009h,008h,008h,009h,00Bh,00Fh,00Dh,00Ah,008h,009h,009h,00Ch
       DB 010h,013h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 013h,010h,00Dh,00Ch,00Bh,00Ah,00Ah,00Bh,00Dh,011h,012h,011h,00Fh
       DB 00Ch,009h,008h,008h,008h,009h,00Ah,00Bh,00Dh,010h,013h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,013h,011h,010h,00Fh,00Fh,00Dh
       DB 00Dh,00Dh,00Dh,00Dh,00Dh,00Ch,00Ch,00Bh,00Ah,00Ah,00Ah,00Ah,009h
       DB 00Ah,00Ah,008h,009h,008h,008h,008h,008h,00Ah,00Ah,00Bh,00Dh,011h
       DB 013h,000h,000h,000h,000h,000h,000h,013h,013h,010h,00Dh,00Bh,00Ah
       DB 00Ah,009h,008h,008h,009h,00Ah,00Ah,00Bh,00Bh,00Bh,00Bh,00Ch,00Fh
       DB 012h,012h,011h,010h,00Dh,00Ch,00Ah,00Ah,009h,009h,009h,009h,009h
       DB 008h,008h,008h,007h,007h,006h,006h,007h,008h,008h,008h,009h,00Ah
       DB 00Bh,00Ch,00Bh,00Bh,00Bh,009h,009h,008h,008h,009h,009h,009h,008h
       DB 009h,009h,00Bh,00Dh,011h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,013h,00Fh,00Ch,00Bh,00Ah,00Ah,00Ah,009h,00Bh,00Dh
       DB 011h,011h,010h,00Dh,00Bh,009h,008h,008h,009h,009h,00Ah,00Bh,00Dh
       DB 010h,013h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,011h,00Fh
       DB 00Dh,00Ch,00Bh,00Ah,00Ah,00Ah,00Ah,00Ah,00Ah,00Ah,00Ah,009h,008h
       DB 008h,008h,008h,008h,008h,008h,008h,008h,008h,007h,007h,008h,008h
       DB 00Ah,00Ah,00Ch,00Dh,011h,013h,000h,000h,000h,000h,013h,011h,00Fh
       DB 00Ch,00Bh,00Ah,00Ah,009h,009h,00Ah,00Ah,00Ah,00Bh,00Bh,00Bh,00Bh
       DB 00Bh,00Bh,00Bh,00Dh,00Eh,00Dh,00Dh,00Ch,00Ah,009h,009h,009h,009h
       DB 009h,008h,008h,008h,008h,007h,007h,006h,006h,008h,008h,008h,008h
       DB 008h,009h,009h,00Ah,00Bh,00Ch,00Ch,00Ch,00Bh,00Ah,009h,008h,008h
       DB 008h,008h,008h,008h,009h,009h,00Bh,00Dh,010h,013h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,013h,010h,00Dh,00Ah,00Ah,00Ah,009h
       DB 009h,009h,00Bh,00Dh,010h,010h,00Fh,00Ch,00Ah,009h,008h,007h,008h
       DB 009h,00Ah,00Bh,00Dh,00Fh,012h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,010h,00Dh,00Ah,00Ah,009h,009h,009h,008h,008h,008h,009h
       DB 009h,009h,008h,008h,007h,007h,007h,007h,006h,007h,007h,007h,007h
       DB 007h,007h,008h,00Ah,00Ah,00Ah,00Bh,00Ch,00Dh,011h,000h,000h,000h
       DB 000h,012h,00Fh,00Ch,00Bh,00Ah,009h,009h,00Ah,00Bh,00Bh,00Bh,00Ch
       DB 00Dh,00Dh,00Dh,00Dh,00Ch,00Ch,00Ch,00Bh,00Bh,00Bh,00Ah,009h,009h
       DB 009h,008h,008h,008h,008h,008h,008h,008h,008h,008h,008h,008h,008h
       DB 008h,008h,009h,009h,009h,009h,00Ah,00Ah,00Bh,00Ch,00Dh,00Dh,00Dh
       DB 00Bh,00Ah,009h,008h,008h,008h,008h,009h,009h,00Ah,00Bh,00Ch,00Dh
       DB 011h,013h,000h,000h,000h,000h,000h,000h,000h,000h,011h,00Dh,00Bh
       DB 00Ah,009h,009h,009h,009h,00Ah,00Bh,00Dh,00Eh,00Eh,00Dh,00Bh,00Ah
       DB 009h,008h,007h,008h,008h,009h,009h,00Bh,00Dh,00Fh,011h,013h,013h
       DB 013h,013h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,011h,00Dh,00Ah,00Ah,008h,008h,008h
       DB 008h,008h,009h,009h,00Ah,00Ah,00Ah,008h,007h,007h,006h,005h,005h
       DB 006h,007h,008h,008h,008h,008h,00Ah,00Ah,00Ah,00Bh,00Ch,00Dh,00Dh
       DB 011h,013h,000h,000h,000h,011h,00Dh,00Ah,00Ah,009h,009h,00Ah,00Bh
       DB 00Bh,00Dh,00Fh,00Fh,010h,011h,011h,011h,00Fh,00Dh,00Ch,00Bh,00Ah
       DB 009h,009h,008h,008h,008h,008h,009h,009h,009h,009h,009h,008h,008h
       DB 008h,008h,008h,008h,009h,009h,009h,00Ah,00Ah,00Ah,00Ah,00Bh,00Dh
       DB 00Fh,010h,011h,00Fh,00Dh,00Bh,00Ah,009h,009h,009h,009h,009h,00Ah
       DB 00Ah,00Ah,00Bh,00Bh,00Dh,010h,011h,013h,000h,000h,000h,000h,000h
       DB 013h,00Fh,00Bh,00Bh,009h,009h,008h,008h,009h,00Ah,00Bh,00Dh,00Dh
       DB 00Dh,00Dh,00Ch,00Bh,00Ah,009h,008h,008h,007h,008h,008h,009h,009h
       DB 00Ah,00Ch,00Dh,00Dh,00Fh,010h,011h,013h,013h,013h,013h,013h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,00Dh,00Ah
       DB 00Ah,009h,008h,008h,009h,00Ah,00Ah,00Ah,00Ah,00Bh,00Bh,009h,009h
       DB 008h,006h,005h,006h,007h,008h,00Ah,00Ah,00Ah,00Ah,00Ah,00Bh,00Bh
       DB 00Dh,00Eh,010h,011h,013h,013h,000h,000h,013h,010h,00Ch,00Ah,009h
       DB 009h,00Ah,00Bh,00Bh,00Dh,011h,013h,013h,013h,000h,000h,000h,011h
       DB 00Dh,00Ch,00Bh,00Ah,009h,008h,008h,009h,009h,009h,00Ah,00Ah,00Ah
       DB 00Ah,00Ah,009h,009h,009h,009h,009h,009h,00Ah,00Bh,00Bh,00Bh,00Bh
       DB 00Bh,00Dh,00Dh,010h,011h,013h,000h,012h,00Fh,00Bh,00Ah,009h,009h
       DB 009h,009h,009h,009h,009h,009h,009h,009h,00Bh,00Ch,00Dh,010h,011h
       DB 013h,000h,000h,000h,011h,00Dh,00Bh,00Ah,009h,008h,007h,008h,009h
       DB 00Ah,00Bh,00Dh,00Dh,00Eh,00Dh,00Dh,00Ch,00Bh,00Ah,009h,008h,008h
       DB 007h,008h,007h,008h,009h,009h,009h,00Ah,00Bh,00Ch,00Dh,00Dh,00Dh
       DB 00Dh,00Fh,010h,012h,013h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,00Fh,00Ch,00Ah,00Ah,00Ah,00Ah,00Ah,00Ah,00Bh,00Ch,00Dh
       DB 00Dh,00Dh,00Bh,00Ah,008h,007h,006h,007h,008h,00Ah,00Bh,00Dh,00Dh
       DB 00Dh,00Fh,010h,011h,013h,013h,013h,000h,000h,000h,000h,000h,011h
       DB 00Dh,00Bh,00Ah,009h,00Ah,00Bh,00Bh,00Dh,010h,013h,000h,000h,000h
       DB 000h,000h,000h,013h,00Fh,00Dh,00Ch,00Bh,00Ah,009h,009h,00Ah,00Ah
       DB 00Ah,00Ah,00Ah,00Bh,00Bh,00Ah,00Ah,00Ah,00Ah,00Ah,00Ah,00Ah,00Bh
       DB 00Bh,00Dh,00Dh,00Fh,00Fh,010h,011h,013h,000h,000h,000h,000h,010h
       DB 00Ch,00Ah,009h,00Ah,00Ah,00Ah,00Ah,00Ah,00Ah,009h,008h,008h,009h
       DB 00Ah,00Bh,00Ch,00Dh,010h,011h,013h,013h,010h,00Bh,00Ah,00Ah,009h
       DB 008h,007h,008h,009h,00Ah,00Bh,00Dh,00Eh,010h,010h,00Fh,00Dh,00Dh
       DB 00Ch,00Bh,00Ah,009h,008h,008h,007h,007h,007h,008h,008h,009h,009h
       DB 00Ah,00Ah,00Ah,00Ah,00Bh,00Ch,00Dh,00Dh,010h,011h,013h,013h,000h
       DB 000h,000h,000h,000h,000h,000h,013h,00Fh,00Bh,00Ah,00Ah,00Ah,00Bh
       DB 00Ch,00Fh,011h,011h,012h,011h,00Fh,00Ah,009h,007h,007h,007h,008h
       DB 00Ah,00Dh,010h,013h,013h,013h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,011h,00Dh,00Ah,00Ah,009h,00Ah,00Bh,00Ch,00Dh,011h
       DB 000h,000h,000h,000h,000h,000h,000h,013h,010h,00Dh,00Ch,00Bh,00Ah
       DB 00Ah,00Ah,00Ah,00Bh,00Bh,00Bh,00Bh,00Bh,00Bh,00Bh,00Ah,00Ah,00Bh
       DB 00Bh,00Ch,00Dh,00Dh,010h,011h,013h,013h,013h,013h,000h,000h,000h
       DB 000h,000h,000h,011h,00Dh,00Ah,009h,00Bh,00Bh,00Bh,00Bh,00Bh,00Ah
       DB 00Ah,009h,008h,008h,009h,00Ah,00Ah,00Bh,00Ch,00Dh,00Fh,00Dh,00Ch
       DB 00Bh,00Ah,009h,009h,008h,007h,008h,009h,00Ah,00Bh,00Dh,011h,013h
       DB 013h,013h,011h,010h,00Fh,00Dh,00Ch,00Bh,009h,009h,008h,007h,007h
       DB 007h,007h,008h,008h,008h,008h,008h,008h,009h,009h,00Ah,00Bh,00Ch
       DB 00Dh,00Fh,011h,013h,000h,000h,000h,000h,000h,000h,000h,011h,00Eh
       DB 00Dh,00Dh,00Dh,00Fh,00Fh,013h,000h,000h,000h,000h,011h,00Dh,00Ah
       DB 008h,007h,007h,008h,00Ah,00Ch,011h,013h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,010h,00Ch,00Ah,009h,00Bh,00Bh
       DB 00Ch,00Ch,00Dh,010h,011h,013h,013h,013h,013h,013h,012h,012h,011h
       DB 00Fh,00Dh,00Bh,00Bh,00Ah,00Bh,00Bh,00Bh,00Bh,00Ch,00Ch,00Ch,00Ch
       DB 00Bh,00Ah,00Ah,00Bh,00Ch,00Dh,011h,013h,013h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,013h,010h,00Dh,00Ah,009h,00Bh,00Ch
       DB 00Dh,00Dh,00Bh,00Bh,00Bh,009h,008h,008h,008h,009h,009h,00Ah,00Bh
       DB 00Bh,00Ch,00Ch,00Ch,00Bh,00Ah,009h,009h,008h,007h,008h,009h,00Ah
       DB 00Ch,00Fh,013h,000h,000h,000h,000h,013h,013h,011h,00Fh,00Dh,00Ch
       DB 00Ah,009h,008h,008h,008h,007h,007h,007h,007h,007h,007h,007h,008h
       DB 008h,008h,009h,00Ah,00Bh,00Dh,00Fh,011h,013h,000h,000h,000h,000h
       DB 000h,000h,013h,010h,010h,012h,012h,013h,000h,000h,000h,000h,000h
       DB 000h,013h,00Dh,00Ah,009h,008h,007h,007h,009h,00Ah,00Fh,012h,013h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,013h,00Fh,00Bh
       DB 009h,009h,00Bh,00Ch,00Ch,00Ch,00Dh,00Dh,00Fh,00Fh,00Fh,00Fh,00Fh
       DB 010h,011h,013h,013h,011h,00Fh,00Fh,00Fh,00Fh,00Fh,00Fh,00Fh,00Fh
       DB 00Fh,00Fh,00Dh,00Ch,00Ch,00Bh,00Ah,00Bh,00Dh,010h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,013h,00Fh,00Ch
       DB 00Ah,009h,00Bh,00Dh,010h,011h,00Fh,00Dh,00Bh,00Ah,009h,008h,008h
       DB 008h,009h,009h,00Ah,00Bh,00Bh,00Ch,00Ch,00Bh,00Bh,00Ah,009h,009h
       DB 008h,009h,009h,00Ah,00Dh,010h,013h,000h,000h,000h,000h,000h,000h
       DB 013h,013h,011h,00Fh,00Dh,00Ah,00Ah,009h,009h,008h,007h,007h,006h
       DB 006h,007h,007h,007h,007h,008h,008h,009h,00Ah,00Bh,00Ch,00Dh,010h
       DB 013h,000h,000h,000h,000h,000h,000h,013h,013h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,013h,00Fh,00Ah,009h,008h,007h,007h,008h
       DB 009h,00Ah,00Dh,010h,013h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,011h,00Dh,00Ah,009h,00Ah,00Bh,00Bh,00Bh,00Bh,00Ch,00Ch,00Ch
       DB 00Bh,00Ch,00Bh,00Dh,00Fh,011h,000h,000h,013h,013h,013h,013h,013h
       DB 013h,013h,013h,013h,013h,013h,011h,00Dh,00Ch,00Bh,00Ah,00Bh,00Dh
       DB 011h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,011h,00Dh,00Bh,00Ah,009h,00Bh,00Dh,011h,013h,013h,010h,00Dh
       DB 00Bh,00Ah,009h,008h,008h,008h,009h,009h,00Ah,00Bh,00Bh,00Ch,00Ch
       DB 00Bh,00Bh,00Ah,009h,008h,009h,00Ah,00Bh,00Dh,011h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,013h,013h,011h,00Fh,00Ch,00Ah,00Ah
       DB 009h,008h,007h,007h,006h,006h,006h,006h,007h,007h,008h,009h,009h
       DB 00Ah,00Ah,00Ch,00Dh,010h,013h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,010h,00Ah,009h
       DB 008h,007h,006h,006h,007h,008h,009h,00Ch,010h,013h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,011h,00Dh,00Ah,008h,00Ah,00Ah,00Ah,00Bh
       DB 00Bh,00Bh,00Ah,00Bh,00Ah,009h,00Ch,00Dh,011h,013h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,013h,010h,00Ch
       DB 00Bh,00Ah,00Bh,00Ch,011h,013h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,013h,010h,00Dh,00Ah,009h,009h,00Ah,00Dh,011h
       DB 000h,000h,013h,011h,00Dh,00Ah,00Ah,008h,008h,008h,008h,009h,009h
       DB 00Ah,00Bh,00Bh,00Ch,00Ch,00Bh,00Ah,009h,009h,009h,00Ah,00Bh,00Fh
       DB 013h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 013h,00Fh,00Ch,00Ah,00Ah,009h,008h,007h,006h,005h,005h,006h,006h
       DB 007h,008h,008h,008h,009h,00Ah,00Ah,00Ch,00Eh,011h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,011h,00Bh,009h,008h,007h,006h,006h,006h,007h,009h,00Ah,00Ah
       DB 010h,013h,000h,000h,000h,000h,000h,000h,000h,011h,00Ch,009h,008h
       DB 009h,009h,00Bh,00Dh,00Dh,00Dh,00Ch,00Bh,00Ah,00Bh,00Dh,010h,013h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,010h,00Dh,00Bh,00Ah,00Ah,00Bh,00Fh,013h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,013h,011h,00Dh,00Bh,00Ah,009h
       DB 009h,00Ah,00Ch,010h,013h,000h,000h,013h,011h,00Dh,00Ah,009h,008h
       DB 008h,008h,008h,009h,009h,00Ah,00Bh,00Bh,00Ch,00Bh,00Bh,00Ah,00Ah
       DB 009h,00Ah,00Ch,010h,013h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,011h,00Dh,00Bh,00Ah,009h,008h,007h,006h
       DB 006h,005h,005h,006h,007h,007h,007h,008h,008h,009h,00Ah,00Bh,00Dh
       DB 011h,013h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,013h,00Bh,009h,008h,007h,006h,006h,006h
       DB 006h,007h,009h,00Ah,00Ah,00Dh,011h,013h,000h,000h,000h,000h,013h
       DB 00Fh,00Bh,009h,008h,00Ah,00Ah,00Ch,00Fh,010h,00Fh,00Fh,00Dh,00Dh
       DB 00Dh,010h,013h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,013h,010h,00Dh,00Bh,009h,00Ah,00Bh,00Dh
       DB 011h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,013h,00Fh
       DB 00Ch,00Ah,00Ah,009h,009h,00Ah,00Bh,00Dh,011h,000h,000h,000h,013h
       DB 00Eh,00Bh,00Ah,008h,008h,007h,008h,008h,009h,00Ah,00Ah,00Bh,00Ch
       DB 00Ch,00Bh,00Ah,00Ah,009h,00Ah,00Dh,010h,013h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,013h,00Fh,00Ch,00Ah
       DB 009h,008h,007h,007h,006h,006h,006h,006h,006h,007h,007h,008h,008h
       DB 009h,00Ah,00Bh,00Fh,011h,013h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,00Fh,009h,009h
       DB 007h,007h,006h,006h,005h,006h,009h,009h,009h,00Ah,00Ah,010h,013h
       DB 000h,000h,000h,012h,00Dh,00Ah,008h,008h,00Ah,00Bh,00Ch,00Fh,011h
       DB 011h,011h,010h,010h,010h,013h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,013h,00Fh,00Ch,00Ah
       DB 009h,009h,00Ah,00Ch,010h,013h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,013h,011h,00Dh,00Bh,00Ah,009h,009h,009h,00Ah,00Ah,00Dh,011h
       DB 000h,000h,000h,013h,011h,00Dh,00Ah,009h,008h,008h,007h,008h,009h
       DB 009h,00Ah,00Bh,00Bh,00Ch,00Bh,00Bh,00Ah,009h,00Ah,00Ch,010h,013h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 013h,00Fh,00Bh,00Ah,009h,008h,008h,007h,006h,006h,007h,007h,007h
       DB 007h,008h,008h,009h,00Ah,00Bh,00Dh,011h,013h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,010h,00Bh,009h,008h,007h,007h,006h,006h,007h,007h,009h,009h
       DB 009h,00Bh,00Dh,011h,013h,013h,013h,010h,00Ch,00Ah,009h,009h,00Ah
       DB 00Bh,00Ch,00Dh,010h,011h,012h,011h,012h,013h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 013h,00Fh,00Bh,009h,009h,008h,009h,00Bh,00Dh,011h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,013h,00Fh,00Ch,00Ah,009h,009h,008h,009h
       DB 009h,00Ah,00Dh,011h,000h,000h,000h,000h,013h,00Fh,00Bh,009h,009h
       DB 008h,008h,008h,008h,009h,00Ah,00Ah,00Bh,00Ch,00Ch,00Bh,00Ah,009h
       DB 00Ah,00Dh,010h,013h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,013h,010h,00Dh,00Bh,00Ah,009h,008h,008h,007h,007h
       DB 007h,007h,008h,008h,008h,009h,009h,00Ah,00Ah,00Dh,011h,013h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,012h,00Bh,00Ah,009h,008h,008h,007h,008h
       DB 008h,008h,008h,009h,00Ah,00Ah,00Dh,00Fh,011h,013h,011h,00Dh,00Bh
       DB 00Ah,009h,009h,00Bh,00Ah,00Bh,00Ch,00Fh,00Fh,00Fh,010h,011h,012h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,013h,00Dh,00Bh,009h,008h,008h,009h,00Ah,00Bh
       DB 010h,013h,000h,000h,000h,000h,000h,000h,013h,011h,00Dh,00Ah,009h
       DB 008h,008h,008h,008h,009h,00Ah,00Ch,010h,013h,000h,000h,000h,000h
       DB 011h,00Dh,00Ah,009h,009h,008h,008h,009h,00Ah,00Ah,00Bh,00Ch,00Ch
       DB 00Bh,00Bh,00Ah,00Ah,00Ah,00Dh,011h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,013h,011h,00Fh,00Ch,00Bh,00Ah,009h,008h
       DB 008h,008h,008h,008h,008h,008h,009h,009h,009h,00Ah,00Bh,00Ch,00Dh
       DB 011h,013h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,010h,00Ah,009h
       DB 009h,008h,008h,008h,008h,008h,009h,00Bh,00Ch,00Dh,010h,013h,013h
       DB 013h,011h,00Dh,00Ch,00Bh,00Ah,009h,009h,008h,009h,00Bh,00Bh,00Bh
       DB 00Bh,00Dh,00Fh,010h,011h,012h,013h,013h,013h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,013h,00Dh,00Bh,009h,008h
       DB 008h,009h,00Ah,00Bh,00Fh,013h,000h,000h,000h,000h,000h,000h,013h
       DB 010h,00Bh,00Ah,009h,008h,008h,008h,008h,009h,00Ah,00Bh,00Fh,013h
       DB 000h,000h,000h,000h,013h,00Fh,00Ch,00Ah,009h,008h,009h,00Ah,00Ah
       DB 00Bh,00Bh,00Ch,00Bh,00Bh,00Ah,00Ah,00Ah,00Bh,00Dh,012h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,013h,013h,011h,00Fh,00Dh,00Bh,00Ah
       DB 00Ah,009h,009h,008h,008h,008h,008h,009h,009h,009h,009h,00Bh,00Bh
       DB 00Ch,00Dh,010h,011h,013h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,011h,00Bh,00Ah,00Ah,009h,009h,009h,009h,00Ah,00Ah,00Dh,011h
       DB 013h,013h,000h,000h,013h,011h,00Dh,00Ch,00Bh,00Ah,00Ah,009h,008h
       DB 008h,008h,009h,00Ah,00Ah,00Bh,00Ch,00Dh,00Dh,00Eh,010h,011h,013h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,013h
       DB 00Dh,00Bh,009h,009h,008h,009h,00Ah,00Bh,00Dh,013h,000h,000h,000h
       DB 000h,000h,000h,013h,010h,00Ch,00Ah,009h,009h,009h,008h,008h,009h
       DB 00Ah,00Bh,00Dh,011h,000h,000h,000h,000h,000h,011h,00Dh,00Bh,00Ah
       DB 009h,009h,00Ah,00Bh,00Bh,00Ch,00Bh,00Bh,00Ah,00Ah,009h,00Ah,00Bh
       DB 00Dh,012h,000h,000h,000h,000h,013h,013h,013h,011h,010h,00Dh,00Dh
       DB 00Bh,00Bh,00Ah,009h,009h,009h,008h,008h,009h,009h,009h,009h,00Ah
       DB 00Bh,00Ch,00Dh,00Dh,010h,011h,013h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,013h,00Eh,00Bh,00Ah,00Ah,00Ah,00Bh,00Ch
       DB 00Dh,011h,013h,000h,000h,000h,000h,000h,000h,011h,00Fh,00Dh,00Dh
       DB 00Bh,00Ah,00Ah,009h,009h,008h,008h,009h,009h,00Ah,00Bh,00Ch,00Dh
       DB 00Fh,011h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,011h,00Dh,00Bh,00Ah,009h,009h,009h,00Ah,00Bh,00Dh
       DB 013h,000h,000h,000h,000h,000h,000h,013h,010h,00Dh,00Bh,00Ah,009h
       DB 009h,009h,009h,009h,009h,00Bh,00Dh,011h,000h,000h,000h,000h,000h
       DB 013h,010h,00Dh,00Ah,00Ah,00Ah,00Bh,00Bh,00Ch,00Bh,00Bh,00Ah,00Ah
       DB 009h,008h,00Ah,00Bh,00Dh,011h,000h,000h,000h,013h,011h,00Fh,00Eh
       DB 00Dh,00Bh,00Ah,00Ah,00Ah,00Ah,009h,009h,008h,008h,009h,009h,009h
       DB 00Ah,00Bh,00Bh,00Ch,00Dh,00Fh,010h,011h,013h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,013h,011h,00Dh,00Ch
       DB 00Ch,00Dh,00Fh,011h,012h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 013h,013h,011h,00Fh,00Dh,00Dh,00Ch,00Bh,00Ah,00Ah,009h,009h,009h
       DB 009h,00Ah,00Ch,00Eh,011h,013h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,013h,010h,00Dh,00Bh,00Ah,009h,009h
       DB 00Ah,00Ah,00Bh,00Dh,011h,013h,000h,000h,000h,000h,000h,013h,011h
       DB 010h,00Dh,00Ch,00Bh,00Bh,00Bh,00Bh,00Bh,00Bh,00Dh,00Fh,011h,000h
       DB 000h,000h,000h,000h,000h,011h,00Dh,00Bh,00Ah,00Ch,00Dh,00Dh,00Dh
       DB 00Bh,00Bh,00Ah,00Ah,00Ah,00Ah,00Ah,00Bh,00Dh,011h,013h,013h,011h
       DB 00Fh,00Dh,00Bh,00Bh,00Ah,009h,009h,009h,009h,009h,009h,009h,009h
       DB 009h,00Ah,00Bh,00Bh,00Ch,00Dh,00Dh,00Fh,011h,013h,013h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,013h,010h,00Fh,010h,012h,013h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,013h,013h,012h,011h,00Fh,00Dh,00Dh
       DB 00Dh,00Ch,00Ch,00Bh,00Bh,00Bh,00Dh,011h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,013h,010h,00Dh
       DB 00Ch,00Bh,00Ah,00Ah,00Ah,00Bh,00Ch,00Dh,010h,013h,000h,000h,000h
       DB 000h,000h,000h,013h,013h,011h,010h,00Fh,00Fh,00Eh,00Dh,00Dh,00Fh
       DB 010h,011h,013h,013h,000h,000h,000h,000h,000h,013h,010h,00Fh,00Fh
       DB 00Fh,010h,010h,010h,00Dh,00Dh,00Dh,00Bh,00Bh,00Ah,00Bh,00Ch,00Dh
       DB 011h,011h,010h,00Dh,00Ch,00Bh,00Ah,00Ah,009h,009h,009h,009h,009h
       DB 00Ah,00Bh,00Bh,00Bh,00Ch,00Ch,00Dh,00Dh,00Fh,010h,011h,013h,013h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,013h,013h,013h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,013h,011h,011h,010h,010h,00Fh,00Dh,00Dh,010h,011h,013h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,013h,011h,00Fh,00Dh,00Dh,00Ch,00Ch,00Dh,00Eh,00Eh,00Fh,011h
       DB 013h,000h,000h,000h,000h,000h,000h,000h,000h,013h,013h,013h,013h
       DB 013h,013h,011h,011h,013h,013h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,013h,011h,013h,013h,013h,013h,013h,013h,012h,010h,00Dh,00Dh
       DB 00Dh,00Dh,00Dh,00Fh,010h,010h,00Dh,00Ch,00Ah,00Ah,009h,00Ah,00Ah
       DB 00Bh,00Bh,00Bh,00Bh,00Ch,00Dh,00Dh,00Fh,010h,010h,010h,011h,013h
       DB 013h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,013h,013h,013h
       DB 013h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,013h,011h,010h,010h,00Fh,00Fh,010h,011h
       DB 013h,013h,013h,013h,013h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,013h,000h,000h,000h,000h,000h,000h
       DB 000h,013h,013h,013h,011h,011h,011h,011h,011h,010h,00Fh,00Dh,00Dh
       DB 00Ch,00Ch,00Ch,00Dh,00Dh,00Dh,00Fh,00Fh,010h,010h,011h,013h,013h
       DB 013h,013h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,013h,013h,013h
       DB 013h,013h,013h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,013h,013h,013h,011h
       DB 011h,011h,010h,010h,010h,010h,010h,010h,011h,012h,013h,013h,013h
       DB 013h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,013h,013h,013h,013h,013h,013h,013h,013h,013h,013h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h

   PAL DB 000h,000h,000h,000h,005h,01Eh,000h,002h,01Ah,000h,03Fh,016h,000h
       DB 03Ch,012h,000h,039h,00Eh,000h,036h,00Ah,000h,033h,006h,000h,030h
       DB 002h,000h,02Dh,03Eh,000h,02Ah,03Ah,000h,027h,036h,000h,024h,032h
       DB 000h,021h,02Eh,000h,01Eh,02Ah,000h,01Bh,026h,000h,018h,022h,000h
       DB 015h,01Eh,000h,012h,01Ah,000h,00Fh,016h,032h,01Dh,028h,02Fh,01Bh
       DB 026h,02Bh,019h,023h,028h,018h,021h,025h,016h,01Fh,022h,014h,01Ch
       DB 01Fh,012h,01Ah,01Ch,011h,017h,019h,00Fh,015h,016h,00Dh,012h,013h
       DB 00Bh,010h,010h,009h,00Dh,00Dh,007h,00Bh,00Ah,005h,008h,007h,004h
       DB 006h,017h,010h,03Ah,03Ah,03Ah,03Ah,03Ah,03Ah,03Ah,03Ah,03Ah,03Ah
       DB 03Ah,03Ah,04Eh,072h,07Bh,074h,071h,03Ah,043h,075h,06Fh,03Ah,05Ch
       DB 075h,068h,03Ah,04Ah,076h,07Bh,063h,073h,074h,07Dh,034h,034h,034h
       DB 017h,010h,017h,010h,03Ah,03Ah,03Ah,03Ah,03Ah,03Ah,03Ah,03Ah,03Ah
       DB 03Ah,03Ah,03Ah,03Ah,03Ah,03Ah,03Ah,03Ah,03Ah,03Ah,03Ah,03Ah,03Ah
       DB 03Ah,0C6h,0C6h,0C6h,0C6h,0C6h,0C5h,03Ah,03Ah,03Ah,03Ah,03Ah,03Ah
       DB 03Ah,03Ah,03Ah,03Ah,03Ah,03Ah,03Ah,03Ah,03Ah,03Ah,03Ah,03Ah,03Ah
       DB 03Ah,03Ah,0AAh,017h,010h,03Ah,03Ah,03Ah,03Ah,03Ah,03Ah,03Ah,03Ah
       DB 03Ah,03Ah,03Ah,03Ah,03Ah,03Ah,03Ah,0C6h,0C6h,0C1h,0C1h,0C1h,0C1h
       DB 0A8h,0C1h,0C5h,0C5h,0C5h,03Ah,0C6h,0C6h,0A8h,0C6h,03Ah,0A8h,0A8h
       DB 03Ah,03Ah,03Ah,03Ah,03Ah,03Ah,03Ah,03Ah,03Ah,03Ah,03Ah,03Ah,03Ah
       DB 03Ah,03Ah,0C6h,0A8h,0ABh,03Ah,03Ah,03Ah,0C6h,0A8h,0ABh,0C6h,017h
       DB 010h,03Ah,03Ah,03Ah,03Ah,03Ah,03Ah,03Ah,03Ah,03Ah,03Ah,03Ah,0C5h
       DB 03Ah,0C5h,0C5h,0C5h,0AAh,0ABh,0A8h,0C1h,0C1h,0A8h,03Ah,03Ah,0C6h
       DB 0C1h,0C5h,0C5h,03Ah,0C4h,0A8h,03Ah,03Ah,0A8h,0C1h,03Ah,03Ah,0C6h
       DB 0C1h,0C5h,03Ah,03Ah,0C6h,0C6h,0C6h,0C6h,0C6h,0C6h,03Ah,03Ah,0C5h
       DB 0C5h,03Ah,0C6h,0C1h,0C5h,03Ah,0C5h,0C1h,0A8h,0ABh,03Ah,03Ah,03Bh
       DB 03Bh,03Bh,017h,010h,03Ah,03Ah,03Ah,03Ah,03Ah,03Ah,03Ah,03Ah,03Ah
       DB 03Ah,03Ah,03Ah,03Ah,03Ah,03Ah,03Ah,03Ah,03Ah,0C1h,0C1h,0C1h,0A8h
       DB 03Ah,0C4h,0A8h,0C6h,0C6h,0C6h,0A8h,0C5h,03Ah,0C6h,0C5h,0C5h,0A8h
       DB 0C1h,0C5h,0C5h,03Ah,03Ah,0C5h,0C1h,0C1h,0A8h,0C7h,03Ah,0C5h,0A8h
       DB 0ABh,03Ah,0A8h,03Ah,0C5h,0C1h,0A8h,0C6h,03Ah,03Ah,03Ah,0C5h,017h
       DB 010h,03Ah,03Ah,03Ah,03Ah,03Ah,03Ah,03Ah,0AAh,0AAh,0ABh,0ABh,0A8h
       DB 0A8h,0C1h,0C1h,0C5h,03Ah,0C4h,0C1h,0C1h,0A8h,0C7h,0C4h,0A8h,0A8h
       DB 03Ah,03Ah,03Ah,03Ah,0C6h,0ABh,0AAh,03Ah,0C4h,0A8h,0ABh,0AAh,03Ah
       DB 0C1h,0A8h,0C6h,03Ah,0A8h,0C1h,0A8h,03Ah,03Ah,03Ah,03Ah,0C4h,0A8h
       DB 03Ah,0C6h,03Ah,0C5h,0C5h,0C5h,0C1h,0C6h,03Ah,0C5h,0C5h,0C1h,0C1h
       DB 0A8h,0A8h,0ABh,0ABh,0AAh,0AAh,017h,010h,03Ah,03Ah,03Ah,03Ah,03Ah
       DB 03Ah,03Ah,03Ah,03Ah,03Ah,03Ah,03Ah,03Ah,03Ah,0C6h,03Ah,0C4h,0A8h
       DB 0C1h,0C1h,0A8h,0ABh,03Ah,0ABh,0ABh,0A8h,03Ah,0C6h,0A8h,0A8h,0C5h
       DB 03Ah,03Ah,0A8h,0C1h,0C6h,03Ah,03Ah,0C4h,0A8h,0ABh,03Ah,0C4h,0A8h
       DB 0C7h,03Ah,03Ah,0AAh,0ABh,0A8h,0C1h,0C7h,03Ah,0A8h,0A8h,0C6h,03Ah
       DB 0A8h,0A8h,0ABh,0AAh,017h,010h,03Ah,03Ah,03Ah,03Ah,03Ah,03Ah,03Ah
       DB 03Ah,03Ah,03Ah,03Ah,03Ah,0AAh,0ABh,0A8h,0C6h,0C6h,03Ah,0C5h,0A8h
       DB 0ABh,0AAh,03Ah,03Ah,0AAh,0C5h,0C5h,0C5h,03Ah,0C6h,0C6h,03Ah,0AAh
       DB 0ABh,0A8h,0A8h,0C5h,0C5h,0C5h,03Ah,0C6h,03Ah,0C5h,0C5h,03Ah,03Ah
       DB 03Ah,03Ah,03Ah,03Ah,0C5h,0C5h,03Ah,03Ah,0C5h,0C5h,0C5h,0C5h,0AAh
       DB 017h,010h,03Ah,03Ah,03Ah,03Ah,03Ah,03Ah,03Ah,03Ah,03Ah,03Ah,03Ah
       DB 03Ah,03Ah,03Ah,03Ah,03Ah,0C5h,0C5h,03Ah,03Ah,0AAh,03Ah,03Ah,03Ah
       DB 03Ah,03Ah,03Ah,0C5h,0C5h,0C5h,03Ah,03Ah,03Ah,03Ah,03Ah,03Ah,03Ah
       DB 0C5h,0C5h,0C5h,0A8h,03Ah,0C5h,0C5h,0C5h,0C5h,03Ah,0C5h,03Ah,0C5h
       DB 03Ah,03Ah,03Ah,0C5h,03Ah,05Bh,076h,079h,072h,07Fh,077h,073h,079h
       DB 017h,010h,017h,010h,03Ah,03Ah,03Ah,03Ah,03Ah,03Ah,03Ah,03Ah,03Ah
       DB 03Ah,03Ah,03Ah,03Ah,03Ah,03Ah,03Ah,03Ah,03Ah,03Ah,03Ah,03Ah,03Ah
       DB 03Ah,03Ah,03Ah,059h,075h,06Ah,063h,068h,073h,07Dh,072h,06Eh,03Ah
       DB 032h,079h,033h,03Ah,028h,02Ah,02Ah,02Eh,036h,03Ah,05Bh,076h,079h
       DB 072h,07Fh,077h,073h,079h,017h,010h,017h,010h,03Ah,03Ah,03Ah,03Ah
       DB 03Ah,03Ah,03Ah,03Ah,03Ah,03Ah,03Ah,03Ah,03Ah,04Eh,072h,073h,069h
       DB 03Ah,04Ah,068h,075h,07Dh,068h,07Bh,077h,03Ah,053h,069h,03Ah,05Ch
       DB 068h,07Fh,07Fh,06Dh,07Bh,068h,07Fh,034h,03Ah,049h,06Ah,068h,07Fh
       DB 07Bh,07Eh,03Ah,053h,06Eh,03Ah,05Bh,069h,03Ah,057h,06Fh,079h,072h
       DB 03Ah,05Bh,069h,03Ah,043h,075h,06Fh,03Ah,059h,07Bh,074h,034h,017h
       DB 010h,017h,010h,03Ah,03Ah,03Ah,03Ah,03Ah,03Ah,03Ah,03Ah,03Ah,03Ah
       DB 03Ah,03Ah,03Ah,03Ah,03Ah,03Ah,03Ah,03Ah,03Ah,03Ah,03Ah,03Ah,03Ah
       DB 03Ah,03Ah,03Ah,048h,07Fh,076h,07Fh,07Bh,069h,07Fh,07Eh,020h,03Ah
       DB 05Ch,07Fh,078h,068h,06Fh,07Bh,068h,063h,03Ah,028h,02Eh,036h,03Ah
       DB 028h,02Ah,02Ah,02Eh,017h,010h,03Eh

    D0 DB 000h,019h,018h,017h,018h,01Ah,000h,000h,019h,018h,01Bh,000h,01Bh
       DB 016h,018h,000h,018h,017h,000h,01Bh,018h,017h,019h,000h,017h,015h
       DB 01Bh,018h,018h,017h,019h,000h,016h,016h,016h,018h,01Bh,018h,019h
       DB 000h,019h,017h,017h,01Bh,000h,019h,01Ah,000h,000h,019h,018h,018h
       DB 018h,01Ah,000h,000h
    D1 DB 000h,000h,000h,019h,014h,018h,000h,000h,000h,000h,019h,015h,014h
       DB 016h,000h,000h,000h,000h,015h,019h,015h,014h,000h,000h,000h,000h
       DB 019h,000h,017h,015h,000h,000h,000h,000h,000h,000h,017h,015h,000h
       DB 000h,000h,000h,000h,000h,017h,017h,000h,000h,000h,000h,019h,018h
       DB 017h,017h,018h,01Ah,000h
    D2 DB 000h,017h,016h,014h,015h,015h,01Ah,000h,000h,016h,019h,000h,01Bh
       DB 015h,017h,000h,000h,019h,000h,000h,01Bh,017h,017h,000h,000h,000h
       DB 01Bh,017h,017h,017h,01Ah,000h,000h,01Ah,018h,018h,01Ah,01Ah,000h
       DB 000h,000h,018h,018h,01Ah,000h,000h,000h,000h,000h,018h,018h,019h
       DB 01Ah,01Ah,01Ah,000h,000h
    D3 DB 000h,018h,017h,016h,014h,014h,01Bh,000h,000h,01Ah,01Ch,000h,01Bh
       DB 015h,017h,000h,000h,01Ch,000h,000h,000h,016h,018h,000h,000h,000h
       DB 01Ch,019h,016h,018h,01Bh,000h,000h,01Ch,000h,000h,000h,016h,018h
       DB 000h,000h,01Ah,01Ch,000h,01Bh,016h,017h,000h,000h,019h,017h,017h
       DB 016h,016h,01Bh,000h,000h
    D4 DB 000h,000h,000h,000h,01Ah,017h,019h,000h,000h,000h,000h,01Ah,018h
       DB 015h,017h,000h,000h,000h,01Ah,018h,01Bh,016h,017h,000h,000h,01Ah
       DB 018h,01Bh,000h,016h,017h,000h,000h,019h,018h,018h,018h,018h,017h
       DB 019h,000h,000h,000h,000h,01Bh,019h,017h,000h,000h,000h,000h,000h
       DB 000h,017h,019h,000h,000h
    D5 DB 000h,019h,018h,015h,016h,018h,01Bh,000h,000h,017h,015h,01Bh,000h
       DB 000h,000h,000h,000h,01Ah,019h,016h,017h,018h,000h,000h,000h,000h
       DB 01Dh,01Ah,016h,015h,019h,000h,000h,000h,000h,01Dh,01Bh,015h,018h
       DB 000h,000h,000h,01Dh,01Bh,019h,015h,019h,000h,000h,01Bh,019h,017h
       DB 015h,018h,000h,000h,000h
    D6 DB 000h,000h,000h,019h,017h,018h,01Ah,000h,000h,000h,019h,017h,01Ah
       DB 01Bh,000h,000h,000h,019h,015h,01Ah,000h,000h,000h,000h,000h,017h
       DB 015h,015h,018h,018h,01Ch,000h,000h,018h,015h,01Ah,01Ah,015h,016h
       DB 000h,000h,019h,015h,01Ah,000h,017h,019h,000h,000h,000h,019h,017h
       DB 018h,019h,000h,000h,000h
    D7 DB 000h,01Ah,019h,019h,017h,015h,017h,000h,000h,000h,000h,000h,01Bh
       DB 017h,01Ah,000h,000h,000h,000h,01Bh,017h,01Ah,000h,000h,000h,000h
       DB 01Bh,017h,01Ah,000h,000h,000h,000h,01Bh,017h,01Ah,000h,000h,000h
       DB 000h,000h,01Bh,018h,000h,000h,000h,000h,000h,000h,01Bh,01Ah,000h
       DB 000h,000h,000h,000h,000h
    D8 DB 000h,000h,019h,017h,018h,019h,000h,000h,000h,019h,017h,019h,01Ch
       DB 018h,019h,000h,000h,019h,017h,01Bh,000h,016h,019h,000h,000h,000h
       DB 019h,017h,017h,017h,000h,000h,000h,019h,017h,01Bh,01Dh,017h,019h
       DB 000h,000h,019h,017h,01Ch,019h,018h,019h,000h,000h,000h,019h,017h
       DB 018h,019h,000h,000h,000h
    D9 DB 000h,01Bh,019h,017h,018h,01Ah,000h,000h,000h,019h,017h,000h,000h
       DB 018h,01Ah,000h,000h,019h,017h,000h,000h,016h,018h,000h,000h,01Bh
       DB 019h,017h,016h,015h,016h,000h,000h,000h,000h,000h,01Ah,016h,018h
       DB 000h,000h,000h,000h,000h,000h,018h,01Ah,000h,000h,000h,01Ah,018h
       DB 018h,01Ah,01Dh,000h,000h

Alchem DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,01Ch,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,01Bh,019h,017h,018h,01Ah,000h,000h,000h,000h,000h
       DB 000h,000h,000h,01Ah,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,01Ch,01Bh,01Ah,01Ah,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,01Ch,019h,019h,019h,000h
       DB 000h,000h,000h,000h,000h,01Bh,019h,017h,019h,018h,017h,019h,000h
       DB 000h,000h,000h,000h,000h,000h,018h,01Bh,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,01Ch,019h,01Ch,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,01Bh,017h
       DB 018h,017h,017h,019h,000h,000h,000h,000h,01Bh,019h,017h,01Ah,01Bh
       DB 018h,017h,000h,000h,000h,000h,000h,000h,000h,019h,019h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,01Ah,01Ah,01Ch,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,01Bh,017h,018h,000h,018h,017h,019h,000h,000h,000h,019h,018h
       DB 019h,01Bh,000h,017h,019h,000h,000h,000h,000h,000h,000h,000h,018h
       DB 018h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 01Ch,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,01Ch,017h,019h,000h,000h,018h,017h,000h,000h
       DB 000h,01Ah,018h,018h,019h,000h,019h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,01Ah,017h,01Bh,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,019h,017h,01Ah,000h,01Ah
       DB 017h,000h,000h,000h,000h,01Bh,019h,018h,000h,000h,000h,000h,01Ah
       DB 019h,017h,018h,019h,000h,01Ch,017h,019h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,01Bh,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,017h
       DB 019h,01Bh,01Ah,017h,019h,000h,000h,000h,000h,01Bh,018h,019h,000h
       DB 000h,01Ah,018h,017h,017h,017h,018h,019h,000h,017h,018h,019h,019h
       DB 01Ah,000h,000h,01Ch,01Bh,018h,019h,01Bh,000h,000h,000h,000h,01Dh
       DB 000h,01Dh,01Ch,000h,01Ch,000h,000h,000h,000h,01Bh,01Dh,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,01Bh
       DB 01Dh,000h,019h,017h,019h,01Ah,017h,017h,000h,000h,000h,000h,000h
       DB 018h,017h,01Bh,000h,01Ah,017h,018h,019h,017h,017h,017h,000h,017h
       DB 017h,017h,017h,017h,019h,01Bh,01Ah,018h,017h,017h,018h,01Bh,000h
       DB 000h,01Bh,01Bh,01Dh,01Bh,019h,01Dh,01Bh,01Ch,000h,000h,000h,01Ah
       DB 01Bh,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,01Ah,017h,019h,000h,019h,017h,018h,01Bh,018h,017h,000h,000h
       DB 01Ah,01Ah,019h,019h,017h,019h,000h,018h,017h,019h,01Ah,018h,017h
       DB 018h,000h,017h,018h,019h,01Bh,019h,018h,018h,017h,017h,019h,01Ch
       DB 01Bh,019h,000h,01Ch,018h,019h,01Ah,018h,017h,018h,019h,01Ah,01Ch
       DB 000h,01Eh,018h,019h,01Bh,01Ah,019h,01Bh,01Ch,000h,000h,000h,000h
       DB 000h,000h,000h,000h,018h,017h,01Bh,000h,000h,017h,01Ah,000h,01Ah
       DB 017h,000h,01Ah,019h,017h,019h,017h,017h,019h,01Ah,017h,018h,000h
       DB 000h,019h,018h,01Ah,000h,018h,01Ah,000h,01Ch,017h,017h,019h,017h
       DB 01Ch,000h,019h,017h,01Bh,000h,019h,018h,017h,01Ah,019h,017h,017h
       DB 018h,019h,01Bh,000h,01Ch,018h,01Ah,01Ch,01Ah,019h,017h,019h,01Dh
       DB 000h,000h,000h,000h,000h,000h,000h,018h,017h,000h,000h,019h,017h
       DB 01Ah,000h,01Bh,019h,01Ah,017h,017h,018h,01Ch,019h,017h,018h,01Bh
       DB 017h,01Ah,000h,000h,000h,019h,000h,000h,019h,01Ch,000h,01Ah,017h
       DB 018h,01Ah,017h,019h,018h,018h,01Ah,000h,01Bh,017h,018h,017h,018h
       DB 019h,017h,018h,01Ah,019h,019h,000h,01Ah,017h,01Ah,01Ah,000h,000h
       DB 01Ah,017h,01Bh,000h,000h,000h,000h,000h,000h,000h,019h,017h,01Ah
       DB 019h,017h,017h,01Ah,000h,000h,01Ah,017h,017h,019h,01Ch,01Ah,018h
       DB 017h,017h,019h,017h,017h,019h,000h,000h,01Bh,01Ah,019h,01Ah,000h
       DB 000h,018h,018h,01Ah,01Ch,019h,018h,01Bh,01Dh,000h,01Bh,017h,017h
       DB 019h,018h,018h,01Ah,019h,01Ah,000h,01Ah,018h,000h,019h,017h,017h
       DB 01Ah,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 01Bh,019h,017h,017h,017h,01Ah,000h,000h,000h,000h,01Ah,017h,017h
       DB 017h,018h,01Ah,019h,018h,017h,017h,017h,017h,018h,019h,01Ah,017h
       DB 017h,01Ch,000h,000h,019h,017h,01Ah,01Ah,01Bh,018h,019h,000h,000h
       DB 01Ah,017h,019h,000h,01Bh,01Ah,000h,01Ah,01Ah,000h,01Ah,019h,000h
       DB 019h,017h,017h,019h,000h,000h,000h,017h,01Ah,000h,000h,000h,000h
       DB 000h,000h,000h,000h,01Bh,01Ah,01Ah,01Ah,000h,000h,000h,000h,000h
       DB 000h,01Ah,019h,01Ah,000h,000h,000h,000h,000h,01Ah,018h,017h,017h
       DB 017h,017h,017h,01Ah,01Dh,000h,000h,01Bh,018h,018h,017h,018h,019h
       DB 019h,01Ah,01Bh,017h,019h,000h,000h,01Bh,01Ah,000h,019h,01Ah,000h
       DB 01Ch,019h,000h,018h,017h,018h,017h,01Ah,000h,01Ah,017h,019h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,01Ah,019h,017h,018h,01Ah,01Ch,000h,000h,000h,01Dh,019h,017h
       DB 019h,019h,01Ch,019h,017h,017h,01Ah,000h,000h,000h,01Bh,01Ah,000h
       DB 01Ah,01Ch,000h,000h,01Ah,019h,018h,018h,019h,018h,018h,018h,017h
       DB 019h,019h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,01Bh,01Ah,01Ch,000h,000h,01Bh,019h,01Bh,000h,000h,01Ch,01Ch
       DB 01Bh,01Ch,000h,01Ch,01Ch,000h,000h,01Ah,019h,018h,01Bh,01Ch,000h
       DB 01Bh,019h,019h,019h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,01Ah,01Ch,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,01Bh,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,01Dh,01Ah,019h,019h,019h,01Bh,000h,000h,01Ch,01Bh,01Ch,000h
       DB 000h,000h,000h,000h,01Ah,01Bh,000h,000h,000h,000h,000h,01Bh,01Ah
       DB 01Ch,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,01Dh,01Bh,019h,01Ah,01Ah,018h,019h,000h,01Ch,01Ah
       DB 01Ah,01Ah,01Ch,000h,000h,000h,01Bh,01Ah,01Ah,01Bh,000h,000h,000h
       DB 01Ch,01Ah,019h,01Ah,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,01Dh,019h,01Ah,01Bh,01Bh,019h,019h
       DB 000h,01Ah,019h,018h,019h,01Ah,000h,000h,01Bh,01Ah,019h,019h,01Ah
       DB 01Bh,000h,000h,01Ch,01Ah,01Ch,01Ah,01Dh,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,01Ch,01Ah,01Dh,01Dh
       DB 01Bh,019h,01Ah,000h,01Ah,019h,01Ah,019h,019h,01Bh,000h,01Ah,019h
       DB 01Ah,01Bh,019h,01Ah,000h,01Ch,01Ah,01Bh,000h,01Ah,01Ch,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 01Ch,000h,01Ch,019h,019h,000h,01Ch,01Ah,019h,000h,01Ch,019h,01Ah
       DB 000h,01Ah,018h,000h,000h,019h,01Ah,000h,01Ah,019h,01Ch,000h,01Ah
       DB 01Ch,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,01Ch,01Ah,019h,01Ah,000h,01Bh,019h,01Ah,000h
       DB 01Ch,019h,01Ah,000h,01Ah,019h,01Ch,000h,019h,01Ah,000h,01Ch,01Ah
       DB 01Bh,01Ah,019h,01Ah,01Ch,01Dh,01Eh,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,01Ch,01Ah,019h,01Ah,01Ch,000h,01Ah
       DB 019h,019h,01Ch,01Ah,019h,01Ah,000h,01Ah,019h,01Bh,01Ch,019h,01Ah
       DB 000h,000h,000h,01Dh,01Bh,01Ah,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,01Ch,01Ah,019h,019h,01Ah
       DB 01Ah,01Ch,01Ah,019h,018h,01Ah,019h,019h,01Ah,01Bh,01Bh,01Ah,019h
       DB 01Bh,019h,019h,01Ch,000h,01Dh,01Dh,01Bh,01Ah,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,01Ch,01Bh,01Bh
       DB 01Ah,01Ah,01Ah,01Ah,01Ah,01Ah,01Ah,019h,019h,019h,01Ah,01Ah,01Ah
       DB 01Ah,01Ah,01Bh,01Ah,01Ah,01Ah,01Ah,01Ah,01Bh,01Bh,01Ah,01Bh,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 01Bh,01Ch,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
       DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
End Begin