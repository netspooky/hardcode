  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;                                                           ;;
  ;;  млпплм ллпплл лл     лл     лл  лл лл     млпплм ллпплм  ;;
  ;;  лл  пп лл   п лл     лл     лл  лл лл     лл  лл лл  лл  ;;
  ;;  лл     ллпп   лл     лл     лл  лл лл     лл  лл лл  лл  ;;
  ;;  лл  мм лл   м лл   м лл   м лл  лл лл   м ллпплл ллпплм  ;;
  ;;  плммлп ллммлл ллммлл ллммлл плммлп ллммлл лл  лл лл  лл  ;;
  ;;                                                           ;;
  ;;   млпплм лл  ллппллппмлпплм ллплмплм млпплмппллппмлпплм   ;;
  ;;   лл  лл лл  лл  лл  лл  лл лл лл лл лл  лл  лл  лл  лл   ;;
  ;;   лл  лл лл  лл  лл  лл  лл лл лл лл лл  лл  лл  лл  лл   ;;
  ;;   ллпплл лл  лл  лл  лл  лл лл лл лл ллпплл  лл  ллпплл   ;;
  ;;   лл  лл плммлп  лл  плммлп лл лл лл лл  лл  лл  лл  лл   ;;
  ;;                                                           ;;
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;'                                                               `;
; This intro coded especially for BYTEFALL'97 128b demo compo     ;
;                                                                 ;
;                                                                 ;
;                       <ѓ CELLULAR AUTOMATA ђ>                   ;
;                                                                 ;
;                                                                 ;
; Give as parameters rules of reproduction and colors for cells:  ;
;                                                                 ;
;    cellular.com +њњ+++њ++++њ++++њ+њ+њ++њ+њњ+њ+њњ /              ;
;                 `ФФФФФФФФФФФФФФvФФФФФФФФФФФФФФФ'`'              ;
;                            32 (rules)           2 (colors)      ;
;                                                                 ;
; You can specify any codes (ASCII) in range 0і255. Odd codes of  ;
; symbols mean filled cells, even codes mean empty cells. Last    ;
; two symbols are colors of empty and filled cells.               ;
;                                                                 ;
;                                                                 ;
; (c) by MEPS '97                                                 ;
;,                                                               ,;
 ;,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,;
.286


WAIT_FOR_RESCAN equ 1      ; Equalize scrolling speed


CODE    segment byte
        assume CS:CODE, DS:CODE, ES:CODE
        org 100h

START:
        ; Set graph mode
        mov AL,13h
        int 10h

        ; Clear almost all screen buffer
        push DS
        mov DI,offset BUFFER
        pop ES
        xor AX,AX
        mov CX,320*(200-1)/2
        rep stosw

        ; Prepare first line
        mov CX,320
PREP_LOOP:
        mov BL,[DS:DI]
        and BX,1
        mov AL,[BX+82h+32]
        mov [DS:DI],AL
        inc DI
        loop PREP_LOOP

        ; Roll buffer up by one line
DEMO_LOOP:
        push DS
        mov SI,offset BUFFER+320
        pop ES
        mov DI,offset BUFFER
        mov CX,320*(200-1)/2
        rep movsw

        ; Prepare next line
        mov SI,offset BUFFER+320*(200-2)-2
        mov CX,320
LINE_LOOP:
        mov AH,1           ; 5 upper neighbours
        xor BX,BX
NGHB_LOOP:
        lodsb              ; next neighbour
        sub AL,[DS:82h+33] ; check for black pixel
        je ZERO
        or BL,AH
ZERO:
        shl AH,1
        and AH,11111b
        jne NGHB_LOOP      ; check up all neighbours,
        mov BL,[BX+82h]    ; get rule for current pixel
        and BL,1           ; and color offset
        sub SI,4           ; go to next pixel
        mov AL,[BX+82h+32] ; get color for current pixel
        mov [SI+321],AL    ; draw pixel
        loop LINE_LOOP

        ; Copy buffer to screen
        push 0A000h
        mov SI,offset BUFFER
        pop ES
        xor DI,DI
        mov CX,320*200/2
        rep movsw

        ; Check for kbhit
if WAIT_FOR_RESCAN
SYNC_LOOP:
        in AL,60h
        das
        jnc EXIT
        mov DX,3DAh
        in AL,DX
        test AL,8
        je SYNC_LOOP
        jmp short DEMO_LOOP
else
        in AL,60h
        das
        jc DEMO_LOOP
endif

        ; Finish intro and return to text mode
EXIT:
        mov AX,3
        int 10h
        ret

        ; Make =128b intro ;)
if WAIT_FOR_RESCAN
        db ''
else
        db 13, 10, '-M=E№P=S-'
endif

        ; Screen copy
BUFFER:

        ends
end     START


