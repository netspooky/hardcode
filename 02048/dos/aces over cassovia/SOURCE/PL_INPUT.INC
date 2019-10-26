;***************************************************************************;
;* 'PL_INPUT.INC' ASMINC Ped / 7 Gods (C)2000          #ASM compo 2kB game *;
;* - copy key status from keyboard class into airplane object              *;
;* - does heavily depend upon airplane and keyboard class ... obviously :) *;
;***************************************************************************;

Pl1Keys        DB      PLN1_UP,PLN1_DN,PLN1_FR,PLN1_ST
Pl2Keys        DB      PLN2_DN,PLN2_UP,PLN2_FR,PLN2_ST ; Pl2 has reversed Up/Down

INP_refresh:                   ; no parameters, uses globals heavily
; modifies ax,bx,cx,si,di,es
       MOV     si,OFFSET Pl1Keys
       MOV     bx,OFFSET KeyboardObj+KEYBOARDFLAGS
       MOV     di,OFFSET Player1+AIRPLANEKEYUP
       PUSH    cs
       POP     es
       CALL    INP_refresh_oneplayer
       MOV     di,OFFSET Player2+AIRPLANEKEYUP
INP_refresh_oneplayer:
       MOV     cx,4
INP_refresh_oneplayer_loop:
       LODSB                   ; which key
       XLAT                    ; status
       STOSB                   ; copy
       LOOP    INP_refresh_oneplayer_loop      ; how efficient could ASM
       RET                                     ; sometimes be ....
