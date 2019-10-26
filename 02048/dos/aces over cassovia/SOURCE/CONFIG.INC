;***************************************************************************;
;* 'CONFIG  .INC' ASMINC Ped / 7 Gods (C)2000          #ASM compo 2kB game *;
;* - some init constants (but not all, just those important ?)             *;
;***************************************************************************;

POINTSTOWIN    EQU     15              ; player should get 15 points to win
RESTARTDELAY   EQU     120             ; how long should be game updating
               ; after some player wins (2sec)
SC_ESC         EQU     01h             ; escape scan code (exit game)

; scoring bar sizes and colors
TXTOUTSIZEX    EQU     10      ; size of single "point"
TXTOUTSIZEY    EQU     5       ; sizeY of bar
TXTOUTPL1COL   EQU     028h    ; red as airplane
TXTOUTPL2COL   EQU     02Fh    ; green as airplane

; player1 keys
PLN1_UP        EQU     10h             ; up = 'Q'
PLN1_DN        EQU     1Eh             ; down = 'A'
PLN1_FR        EQU     2Dh             ; fire = 'X'
PLN1_ST        EQU     2Eh             ; take off = 'C'
; player1 launch position
PLN1_INITX     EQU     3D200000h       ; about 20 pix in 640
PLN1_INITY     EQU     3F74CCCDh       ; 459 pix in 480

; player2 keys
PLN2_UP        EQU     48h             ; up = up
PLN2_DN        EQU     50h             ; down = down
PLN2_FR        EQU     4Eh             ; fire = numpad_plus
PLN2_ST        EQU     1Ch             ; take off = numpad_enter
; player2 launch position
PLN2_INITX     EQU     3F76999Ah       ; cca. 620 pix in 640
PLN2_INITY     EQU     PLN1_INITY

; balloon tower launch position
BLT_INITX      EQU     3F000000h       ; 0.5
BLT_INITY      EQU     3F730000h

; balloon launch position
BAL_POSXINIT   EQU     BLT_INITX
BAL_POSYINIT   EQU     3F590000h
; balloon start timing constants
BAL_MINTOSTART EQU     10*60           ; at least 10 seconds will sit down
BAL_MAXTOSTART EQU     45*60-BAL_MINTOSTART    ; max. 45 seconds
