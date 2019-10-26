;
; Bouncing balls data for TPP's intro #1.
; Nr of balls: 2
;
; Structure: VGA pos X & Y, X 'speed' and Y 'speed' (byte 2 & 1, respectively).

Balldata  dw 170
          dw (320*170)
          db 00000000b

          dw 132
          dw (320*132)
          db 00000010b
