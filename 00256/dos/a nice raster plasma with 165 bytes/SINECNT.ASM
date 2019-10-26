;                *** PROJECT's INLINE SINETABLE ROUTINE ***
;           *** ACCURATE ENOUGH FOR MOST SIN&COS OPERATIONS ***
;                    Length of procedure: 47 bytes
;
; *NOTE*! This routine is stabile ONLY for pi/2 rads; 90 degrees.
; So if you want the WHOLE 0 to 360 degrees sine, you need to use symmetry.
; Currently this routine contains the symmetry for a 256-byte sinetable.
;           90'
;        ____ ____
;       /    |    \       A diagram on how SINE-function works.
;     /   +  |  +   \     From 0 to 90 degrees SINE increases from 0 to 1.
;180'|_______|_______| 0' From 90 to 180 it decreases from 1 to 0.
;    |       |       |    From 180 to 270 it decreases from 0 to -1.
;     \   -  |  -   /     From 270 to 360 it increases from -1 to 0.
;       \____|____/         ****> All quarters are symmetric <****
;
;           270'
;
       mov bx, 4000h        ; <<=offset of the desired DS:Sinetable
                            ; Suggested offsets: 1024,2048,4096,8192,16384
       mov si, 4080h        ; <<=offset+128
       xor ah, ah
@calcsine:
       mov al, bl           ;        360*x*pi*multiplier
       shr al, 1            ;   ax = ------------------
       add al, bl           ;           max.angle*180
                            ; !! You get an accurate enough value if you !!
                            ; !! replace the PI with the number 3        !!
       mov cx, ax           ; If you choose the right values
                            ; for this job, you can ofcourse
       mul cx               ; SOLVE the equation into a much
       mul cx               ; easier piece of code, as is done here.
       mov di, 6000h        ; << = (3!*multiplier^2)[/2]  ** DON'T SOLVE! **
       div di               ; [If multiplier>100, then use the commands in []
       sub cx, ax           ; [<< Insert shr ax, 1 if necessary]
                            ; The highest safe value for multiplier is
                            ; 128 on this version of calcsine, which
                            ; I think is long enough, giving values
                            ; ranging from -127 to +127. Even if I suggest
                            ; 4,8,16,32 or 64 as the multiplier, you can
                            ; basically use any even number there.
       mov [bx], cl
       mov [si], cl
       neg cl
       mov [bx+80h], cl
       mov [si+80h], cl

       inc bl
       dec si
       cmp bl, 40h
       jbe @calcsine

---- ENDs HERE ----
After this procedure, the BH register contains the offset of your
sinetable in the data segment. SO you can easily address it with BX,
placing only the angle in BL register! Just make sure that BH doesn't
get changed.
