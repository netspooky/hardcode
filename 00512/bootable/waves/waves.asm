;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; File: Waves.bin heavily commented                   ;;
;; Author: AsmDemon  asmdemon@cox.net                  ;;
;; Date: February 29, 2004                             ;;
;; Use: Compo #8 Entry thrown together in 20min        ;;
;; I didn't have the time to align them, move them and ;;
;; didn't have the knoledge to have anymore effects.:( ;;
;; IRC: #asm   Web: http://members.cox.net/asmdemom/   ;;
;; Contributions: KaliPara (Helping with initial idea) ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;
;;Boot Floopy in;;
;;16-Bit Mode at;;
;;0000:7C00     ;;
;;Assume Nothing;;
;;;;;;;;;;;;;;;;;;
$ = 0x7C00
USE16

;;;;;;;;;;;;;;;;;;;
;;Set Screen mode;;
;;to 320x200x256 ;;
;;;;;;;;;;;;;;;;;;;
MOV AX, 0x0013
INT 0x10

;;;;;;;;;;;;;;;;;
;;Select Colors;;
;;;;;;;;;;;;;;;;;
MOV DX, 0x03c8
XOR AX,AX
MOV BX,AX
OUT DX,AL
INC DX

;;;;;;;;;;;;;;;;;;;;
;;Set first colors;;
;;from blk to grn.;;
;;;;;;;;;;;;;;;;;;;;
MOV CX, 0x0040
color:
OUT	DX,AL
XCHG	AL,AH
OUT	DX,AL
XCHG	AL,AH
OUT	DX,AL
INC	AH
LOOP	color

;;;;;;;;;;;;;;;;;;;;
;;Set first colors;;
;;from grn to blk.;;
;;;;;;;;;;;;;;;;;;;;
MOV CX, 0x0040
color1:
OUT	DX,AL
XCHG	AL,CL
OUT	DX,AL
XCHG	AL,CL
OUT	DX,AL
LOOP	color1

;;;;;;;;;;;;;;;;;;;;;
;;Select Buffer for;;
;;output to screen.;;
;;;;;;;;;;;;;;;;;;;;;
PUSH	0xA000
POP	ES
XOR	CX,CX
XOR	AX,AX

;;;;;;;;;;;;;;;;;;;;;
;;Main Program Loop;;
;;;;;;;;;;;;;;;;;;;;;
loopdraw:
STOSB
INC AL
CMP AL, 0x80
JNZ doloop
XOR AL, AL
doloop:
LOOP loopdraw

;;;;;;;;;;;;;;;;;;;;;
;;Wait for keypress;;
;;;;;;;;;;;;;;;;;;;;;
MOV	AH,01
INT	0x16
JZ	loopdraw

;;;;;;;;;;;;;;;;;
;;JMP FFFF:0000;;
;;;;;;;;;;;;;;;;;
db 0xEA
dw 0x0000
dw 0xFFFF

;;;;;;;
;;End;;
;;;;;;;

times ((510 + 0x7C00)-$) db 00 ; Fill space with zero
dw 0xAA55 ; signature for bootable drive