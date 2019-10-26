;
; TASM macros, synchro VGA vertical retrace & rastertime shower.
;


WVR macro
  local VRTest1, VRTest2
           mov dx,03dah
VRTest1:   in al,dx
           test al,08h
           jne VRTest1
VRTest2:   in al,dx
           test al,08h
           je VRTest2
endm

PWVR macro
  local VRTest1, VRTest2
           push ax dx
           mov dx,03dah
VRTest1:   in al,dx
           test al,08h
           jne VRTest1
VRTest2:   in al,dx
           test al,08h
           je VRTest2
           pop dx ax
endm

RasterTime macro Color
         mov dx,3c8h
         xor al,al
         out dx,al
         mov dx,3c9h
         mov al,Color
         out dx,al
         out dx,al
         out dx,al
endm
