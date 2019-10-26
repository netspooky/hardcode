; This file was created using SALUT V2.70 (c) 1992-95 by Solar Designer

; Definitions for TASM :
	locals
	jumps

; Highway by Solar Designer \\ BPC

.model small
.code
	org  100h
start:
.186

MinY =   136       ; Only MaxY-MinY is used in this simplified version
MaxY =   199       ; Also, MaxY-MinY should be equal to 63 in this version
PosY =   16        ; Position at which the road is motionless
MinW =   32        ; Road width at top
MaxW =   MinW+256  ; Road width at bottom, should be MinW+256 in this version
CosMax = 79h

mov  al,13h        ; Hope noone will run it with invalid drive as the
int  10h           ; second command line parameter ;)

	push 0A000H
	pop  ES
	push ES
	pop  DS
mov  di,Shifts-(MaxY-MinY)*320    ; DI will point to the shifts array after
	; the loop below

mov  ch,78h        ; Initialize the sine generator, value in CL is not
	; important, BX is assumed to contain zero here
@@DO_PRG_1:
	pusha

	mov  bx,Shifts+2*(MaxY-MinY)   ; DS:BX -> shifts array end
@@DO_PRG_2:
; Set SI to current road width divided by -2
	lea  si,[bx-(Shifts + 2*(MaxY-MinY) + MinW/2)]

	mov  bp,160                 ; Screen center
	add  bp,ds:[bx]             ; ...add current shift
	sub  bp,ds:[Shifts+2*PosY]  ; ...subtract motionless position shift
	lea  cx,[si+bp]             ; Current road left edge's position
	xchg ax,si
	lea  si,[di+bp]             ; Current mark's memory offset
	sub  bp,ax                  ; Current road right edge's position
	imul ax,-2                  ; Real current road width
	push AX

	mov  al,7                   ; Draw the background's left
	rep  stosb

	pop  CX
	inc  ax
	rep  stosb                  ; Draw one horizontal line of the road

	mov  cx,320
	sub  cx,bp
	dec  ax
	inc  dx
	test dl,8                   ; Are we drawing a mark?
	JZ   @@IF_PRG_1
	mov  ds:[si],al          ; Draw it
@@IF_PRG_1:
	rep  stosb                  ; Draw the background's right

	sub  bl,2                   ; Move to the next horizontal line
	JNZ  @@DO_PRG_2

	mov  si,Shifts + 2             ; DI already points to the shifts array
	mov  cl,MaxY-MinY
	rep  movsw                     ; Move the road's shifts

	popa

	dec  dx                        ; Move the marks
	push DX

	mov  ax,-39                    ; Calculate a new shift
	imul cx                        ; I use a modification of sine generator
	add  bx,dx                     ; by Wally/RAGE here
	add  cx,bx
	mov  ax,cx
	sar  ax,8+2
	sub  ax,CosMax shr 2           ; Make it always negative
	mov  word ptr ds:[Shifts+2*(MaxY-MinY)],ax

	mov  dx,3DAh                   ; Wait for vertical retrace to make the
@@DO_PRG_3:
	in   al,dx                  ; fast video cards
	test al,8
	JZ   @@DO_PRG_3

	pop  DX

	in   al,60h                    ; Read a scan code
	cbw                            ; Zero out AH for use by INT 10h below
	dec  ax                        ; Exit on Escape
	JNZ  @@DO_PRG_1

mov  al,3                         ; Restore the text mode
int  10h

retn                              ; Exit

db   'Solar!'                     ;-)

Shifts = 320*200
	end  start
