; ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;
;  The GMIDI music
;
; ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±


; Defines -------------------------------------------------------------------

OF              EQU     OFFSET          ; Makes pattern-data a bit shorter
GMIDI_CHANNELS  EQU     3               ; Midi channels used in music


; Misc stuff ----------------------------------------------------------------

musicStart:

midiInitString  DB      0b9h, 10, 44            ; Init channel 10
                DB      0cah, 29, 0bah, 10, 80  ; Init channel 11
                DB      0cbh, 44, 0bbh, 10, 84  ; Init channel 12
                DB      0ffh

chnl_volume     DB      127, 50, 35

np1             DB      128+24, 0
np2             DB      128+48, 0
np3             DB      128+12, 0
np4             DB      128+6, 0
np5             DB      128+96, 0

null            DB      129, 0


; Drums (midi channel 10) ---------------------------------------------------

; Patterns

dp1:            DB      36, 42, 128+6, 36, 128+6
                DB      36, 42, 128+6, 36, 128+6
                DB      36, 42, 38, 128+6, 36, 128+6
                DB      36, 42, 128+6, 36, 128+6, 0

dp2:            DB      38, 128+6, 36, 128+6, 36, 128+6
                DB      38, 128+6, 36, 128+6, 36, 128+6
                DB      38, 128+6, 36, 128+6, 38, 128+8
                DB      38, 128+4, 38, 128+6, 38, 128+6
                DB      38, 128+6, 38, 128+6, 38, 128+6, 38, 128+6, 0

dp3:            DB      36, 42, 128+6, 36, 128+6
                DB      36, 42, 38, 128+12, 0

dp4:            DB      36, 42, 128+6, 36, 128+6
                DB      36, 38, 57, 128+12, 0

dp5:            DB      36, 53, 128+6, 36, 128+6
                DB      36, 38, 53, 128+12, 0

dp6:            DB      36, 53, 128+6, 36, 128+6
                DB      36, 53, 128+6, 36, 128+6
                DB      36, 53, 38, 128+6, 36, 128+6
                DB      36, 53, 128+6, 36, 128+6, 0

dp7:            DB      36, 42, 128+6, 36, 128+6
                DB      36, 42, 128+6, 36, 128+6
                DB      36, 42, 38, 128+6, 36, 128+6
                DB      36, 42, 128+6, 36, 38, 128+6, 0

dp8:            DB      42, 128+12, 42, 128+12, 42, 128+12, 42, 128+12
                DB      42, 128+12, 42, 128+12, 42, 128+12, 46, 128+12, 0


; Orders

c10_ord:        DW      OF dp1, OF dp1, OF dp1, OF dp7
                DW      OF dp1, OF dp1, OF dp7, OF dp7

                DW      OF dp6, OF dp6, OF dp6, OF dp6
                DW      OF dp6, OF dp6, OF dp2

                DW      OF dp3, OF dp3, OF dp3, OF dp3
                DW      OF dp3, OF dp3, OF dp3, OF dp4
                DW      OF dp1, OF dp1, OF dp7, OF dp7

                DW      OF dp5, OF dp5, OF dp5, OF dp5
                DW      OF dp5, OF dp5, OF dp6
                DW      OF dp5, OF dp5, OF dp5, OF dp5, OF dp2

                DW      OF dp1, OF dp1, OF dp1, OF dp7
                DW      OF dp1, OF dp1, OF dp7, OF dp7

                DW      OF dp6, OF dp6, OF dp6, OF dp7
                DW      OF dp6, OF dp6, OF dp2

                DW      OF dp8, OF dp8
                DW      OF dp8, OF dp8

                DW      OF dp8, OF dp8
                DW      OF dp8, OF dp8

                DW      OF dp8, OF dp8
                DW      OF dp8, OF dp8

                DW      OF dp8, OF dp8
                DW      OF dp8, OF dp8

                DW      OF np5, OF np5
                DW      OF np5, OF np5

                DW      OF np5, OF np5
                DW      OF np5, OF dp2

                DW      OF dp3, OF dp3, OF dp3, OF dp3
                DW      OF dp3, OF dp3, OF dp3, OF dp4
                DW      OF dp1, OF dp1, OF dp7, OF dp7

                DW      OF dp5, OF dp5, OF dp5, OF dp5
                DW      OF dp5, OF dp5, OF dp6
                DW      OF dp5, OF dp5, OF dp5, OF dp5, OF dp2

                DW      OF dp1, OF dp1, OF dp1, OF dp7
                DW      OF dp1, OF dp1, OF dp7, OF dp7

                DW      OF dp6, OF dp6, OF dp6, OF dp7
                DW      OF dp6, OF dp6, OF dp2

                DW      OF np5, OF np5, OF np5, OF np5
                DW      OF np5, OF np5, OF np5, OF np5



; Guitar (midi channel 11) --------------------------------------------------

; Patterns

gp1:            DB      43, 55, 128+5, 128+1, 43, 55, 128+5, 128+1
                DB      43, 55, 128+5, 128+1, 43, 55, 128+5, 128+1, 0

gp2:            DB      41, 55, 128+5, 128+1, 41, 55, 128+5, 128+1
                DB      41, 55, 128+5, 128+1, 41, 55, 128+5, 128+1, 0

gp3:            DB      40, 52, 128+5, 128+1, 40, 52, 128+5, 128+1
                DB      40, 52, 128+5, 128+1, 40, 52, 128+5, 128+1, 0

gp4:            DB      38, 50, 128+5, 128+1, 38, 50, 128+5, 128+1
                DB      38, 50, 128+5, 128+1, 38, 50, 128+5, 128+1, 0

gp5:            DB      43, 55, 128+5, 128+1, 43, 55, 128+5, 128+1
                DB      43, 55, 128+5, 128+1, 0

gp6:            DB      41, 55, 128+5, 128+1, 41, 55, 128+5, 128+1
                DB      41, 55, 128+5, 128+1, 0



; Orders

c11_ord:        DW      OF np5, OF np5, OF np5, OF np5
                DW      OF np5, OF np5, OF np5, OF np5

                DW      OF gp1, OF np2, OF np1, OF gp2, OF np2, OF gp2
                DW      OF gp3, OF np2, OF np1, OF gp4, OF np2, OF gp4

                DW      OF gp1, OF np2, OF gp1, OF gp2, OF np2, OF gp2
                DW      OF gp3, OF np2, OF gp3, OF gp4, OF np2, OF gp4

                DW      OF gp1, OF np2, OF np1, OF gp2, OF np2, OF gp2
                DW      OF gp3, OF np2, OF np1, OF gp4, OF np2, OF gp4

                DW      OF gp1, OF np2, OF gp1, OF gp2, OF np2, OF gp2
                DW      OF gp3, OF np2, OF gp3, OF gp4, OF np2, OF gp4

                DW      OF np5, OF np5, OF np5, OF np5
                DW      OF np5, OF np5, OF np5, OF np5

                DW      OF gp1, OF np3, OF gp1, OF np3, OF gp5, OF np4
                DW      OF gp1, OF np3, OF gp1, OF np3, OF gp5, OF np4
                DW      OF gp1, OF np3, OF gp1, OF np3, OF gp5, OF np4
                DW      OF gp1, OF np3, OF gp1, OF np3, OF gp5, OF np4

                DW      OF gp2, OF np3, OF gp2, OF np3, OF gp6, OF np4
                DW      OF gp2, OF np3, OF gp2, OF np3, OF gp6, OF np4
                DW      OF gp2, OF np3, OF gp2, OF np3, OF gp6, OF np4
                DW      OF gp2, OF np3, OF gp2, OF np3, OF gp6, OF np4

                DW      OF gp1, OF np3, OF gp1, OF np3, OF gp5, OF np4
                DW      OF gp1, OF np3, OF gp1, OF np3, OF gp5, OF np4
                DW      OF gp1, OF np3, OF gp1, OF np3, OF gp5, OF np4
                DW      OF gp1, OF np3, OF gp1, OF np3, OF gp5, OF np4

                DW      OF gp2, OF np3, OF gp2, OF np3, OF gp6, OF np4
                DW      OF gp2, OF np3, OF gp2, OF np3, OF gp6, OF np4
                DW      OF gp2, OF np3, OF gp2, OF np3, OF gp6, OF np4
                DW      OF gp2, OF np3, OF gp2, OF np3, OF gp6, OF np4

                DW      OF gp1, OF np3, OF gp1, OF np3, OF gp5, OF np4
                DW      OF gp1, OF np3, OF gp1, OF np3, OF gp5, OF np4
                DW      OF gp1, OF np3, OF gp1, OF np3, OF gp5, OF np4
                DW      OF gp1, OF np3, OF gp1, OF np3, OF gp5, OF np4

                DW      OF gp2, OF np3, OF gp2, OF np3, OF gp6, OF np4
                DW      OF gp2, OF np3, OF gp2, OF np3, OF gp6, OF np4
                DW      OF gp2, OF np3, OF gp2, OF np3, OF gp6, OF np4
                DW      OF gp2, OF np3, OF gp2, OF np3, OF gp6, OF np4

                DW      OF gp1, OF np3, OF gp1, OF np3, OF gp5, OF np4
                DW      OF gp1, OF np3, OF gp1, OF np3, OF gp5, OF np4
                DW      OF gp1, OF np3, OF gp1, OF np3, OF gp5, OF np4
                DW      OF gp1, OF np3, OF gp1, OF np3, OF gp5, OF np4

                DW      OF gp2, OF np3, OF gp2, OF np3, OF gp6, OF np4
                DW      OF gp2, OF np3, OF gp2, OF np3, OF gp6, OF np4
                DW      OF gp2, OF np3, OF gp2, OF np3, OF gp6, OF np4
                DW      OF gp2, OF np3, OF gp2, OF np3, OF gp6, OF np4

                DW      OF np5, OF np5, OF np5, OF np5
                DW      OF np5, OF np5, OF np5, OF np5



; Keyboard (midi channel 12) ------------------------------------------------

; Patterns

kp1:            DB      67, 55, 128+96, 67, 53, 128+96
                DB      67, 52, 128+96, 67, 50, 128+96, 0

kp2:            DB      67, 55, 128+120, 0


; Orders

c12_ord:        DW      OF np5, OF np5, OF np5, OF np5
                DW      OF np5, OF np5, OF np5, OF np5

                DW      OF kp1, OF kp1, OF kp1, OF kp1
                DW      OF kp1, OF kp1, OF kp1, OF kp1
                DW      OF kp1, OF kp1, OF kp1, OF kp1
                DW      OF kp1, OF kp1, OF kp1, OF kp2

                DW      OF np5




