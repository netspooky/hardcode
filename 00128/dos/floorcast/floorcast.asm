; This is a 86-byte modified version of a 114-byte VGA floor Casting code by rain_storm
; by olivier.poudade.free.fr 2013 
; cf. http://www.dbfinteractive.com/forum/index.php?topic=3107.0
; C:\128BIN~1>fasm floorcast.asm
; flat assembler  version 1.70.03  (786431 kilobytes memory)
; 2 passes, 86 bytes.
; NB : 83 bytes if you delete the ESC key check
       ORG   100h           ; nb : sp equ 65534 at program start
       DWU   equ 34h        ; saves 2 bytes / was DWU DW  ?
       DWV   equ 36h        ; saves 2 bytes / was DWV DW  ?
 INIT: MOV   AL,13h
       INT   10h
       les   di,[bx]        ;es=9fffh di=20cdh / was PUSH 0A000H POP ES
       FLDZ
 MAIN: FLD1
       FADDP ST1,ST0 
       mov   di,16          ; make up for les di,[bx]
       mov   si,DWV         ; saves 1 byte
       PUSH  word si        ; was PUSH WORD 56 ; we can't use 0038h but 36h (54d)
 FORY: mov   bp,sp          ; adress stack with base ptr
       FILD  WORD[DDXMIN]
       FIDIV WORD[bp]       ; was FIDIV WORD[ESP] 
       FLD   ST0
       PUSH  320
       FIMUL WORD[bp-2]     ; was FIMUL WORD[ESP] 
       FSUB  ST0,ST2
       fistp word[si]      ; DWV
       FLD   ST0
       FIMUL WORD[DDXMIN]
       FADD  ST0,ST2
       POP   CX
 FORX: FADD  ST0,ST1
       dec   si             ; make up for lodsw below and mov si,DWV above 
       dec   si             ; make up for lodsw below and mov si,DWV above
       fist  word[si]       ; saves 2 bytes / was FIST  WORD[DWU]  
       lodsw                ; saves 1 byte / was  MOV   AL,BYTE[DWU]
       xor   al,byte[si]    ; saves 1 byte / was XOR   AL,BYTE[DWV]
       MUL   BYTE[si+4]     ; was MUL BYTE [ESP] 
       shr   ax,12          ; was SHR   AX,10 & make up for VGA default palette 16->31
       or    al,10h         ; was SHR   AX,10 & make up for VGA default palette 16->31
       STOSB
       LOOP  FORX
       fistp word[si-2]     ; saves 3 bytes was      FISTP  WORD[DWU]
       fistp word[si]       ; saves 3 bytes was      FISTP  WORD[DWV]
DDXMIN:INC   BYTE[ESP]      ; DDXMIN equ $ saves 2 bytes ff67h close to ff60h / was DDXMIN DW -160
       JNZ   FORY
       IN    AL,60h         ; was equ KEYBRD
       dec   ax             ; saves 1 byte / was DEC AL
       JNZ   MAIN
       RET