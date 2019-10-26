; Sinus offset table created by SINTBL.C
; For use with TPP's intro #1.
; Total: 30 offsets.

; NOTE! USE A-L-W-A-Y-S DW INSTEAD OF DB IN THIS TABLE!!!!!!!

SineTable  dw 4,4,5,6,6,7,7,7,7,7,7,6,6,5,4,4,4,3,2,2,1,1,1,1,1,1,2,2,3
           dw 4,4

; Extra 23 bytes - allows more speed as the table don't needs wraparround.

           dw 4,4,5,6,6,7,7,7,7,7,7,6,6,5,4,4,4,3,2,2,1,1,1
