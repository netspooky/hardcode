;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;File: hell.asm; heavily commented hell fire demo using fasm 1.53   ;;
;;Author: AsmDemon  asmdemon@cox.net                                 ;;
;;Date: August 8, 2004                                               ;;
;;Use: Compo #9 modified from compo #8                               ;;
;;IRC: #asm   Web: http://members.cox.net/asmdemom/                  ;;
;;Greetz to kalipara, mov, and others                                ;;
;;It is better to be on the right side of the devil than in his path.;;
;;R.A.C. 11131983 0x41 0x73 0x6d 0x44 0x65 0x6d 0x6f 0x6e            ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;
;;Code Starts at;;
;; offset 100h  ;;
;; using 16-bit ;;
;;;;;;;;;;;;;;;;;;
$=0x0100
use16

;;;;;;;;;;;;;;;;;;;
;;Set Screen mode;;
;;to 320x200x256 ;;
;;;;;;;;;;;;;;;;;;;
mov al, 0x13
int 0x10

;;;;;;;;;;;;;;;;;;;;;
;;Select Buffer for;;
;;output to screen.;;
;;;;;;;;;;;;;;;;;;;;;
push 0xa000
pop es

;;;;;;;;;;;;;;;;;
;; Set Color to;;
;;  red scale  ;;
;;;;;;;;;;;;;;;;;
mov dx, 0x03c9
setcolor:
out dx, al
xchg bx, ax
out dx, al
out dx, al
xchg bx, ax
inc ax
jnz setcolor

;;;;;;;;;;;;;;;;;;;;;
;;Main Program Loop;;
;;;;;;;;;;;;;;;;;;;;;;;
;;set adc ax, 0x0001 ;;
;;this fixes demo 8  ;;
;;shows what I wanted;;
;;;;;;;;;;;;;;;;;;;;;;;
mainloop:
adc ax, cx
cmc
stosb
loop mainloop ; minus 1 from cx
inc ax
jmp mainloop

;;;;;;;;;;;;;;;;;;;;;;;
;;Following added for;;
;; the 32 byte limit ;;
;;;;;;;;;;;;;;;;;;;;;;;
db 0x52
db 0x41
db 0x43
db 0x39