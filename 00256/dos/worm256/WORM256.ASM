start:
  ; Set Mode

  MOV  AL,13h               ; Set mode to 13h. (320*200*256 Color)
  INT  10h                  ; (AX is zero at start)

  ; Create Palette Data.
  ; It consists on 4 sets of 32 RGB values, in each set there are 16
  ; overlapping palettes of 16 colours.

  MOV  DI,0330h             ; Set DI to point to the start of palette data.
  PUSH DI                   ; Store DI for palette generation after clear.
  XCHG AX,BX                ; Set AX to zero. (BX is zero at start)
  MOV  CL,0C0h              ; Length of palette data in words.
  REP  STOSW                ; Clear the palette memory.
  POP  DI                   ; Restore DI to the start of the Palette data.
  MOV  CL,20h               ; Number of palette enties per color set. (32 * 4)
al1:
  STOSB                     ; Store R for background colours (70h - 7Fh).
  STOSW                     ; Store GB for background colours (70h - 7Fh).
  MOV  [DI+05Dh],AX         ; Store RG for border colours. (80h - 8Fh).
  MOV  [DI+0BDh],AL         ; Store R for worm 0 colours. (90h - 9Fh).
  MOV  [DI+11Eh],AL         ; Store G for worm 1 colours. (A0h - AFh).
  ADD  AX,804h              ; Change colours.
  LOOP al1                  ; Until whole palette computed.

  ; Setup my keyboard ISR instead of the current handler.

  MOV AX,3509h              ; Call Dos interrupt function 35h to get the
  INT 21h                   ; current vector for INT 9. (low level keybord)
  PUSH ES                   ; Store current INT 9 segment on stack.
  push BX                   ; Store current INT 9 offset on stack.
  MOV DX, OFFSET isr_j1     ; Put new INT 9 ISR in DS:DX. (DS = CS at start)
  MOV AH,25h                ; Set AX = 2509h. (Set interrupt number 9h)
  PUSH AX                   ; Store this value for when we restore old ISR.
  INT 21h                   ; Start new INT 9 ISR.

  ; Set up ES to Screen Memory

  MOV  CH,0A0h              ; Set CX = A000h (CX is zero at start)
  MOV  ES,CX                ; Transfer CX to ES, so ES points to Screen.

  ; Draw background screen.
                       
  MOV BX,0100h              ; BX = (Palette data start - 30h) / 3.
  XOR  DI,DI                ; Clear DI so ES:DI is top left of screen.
  MOV  AL,80h               ; Top line of border is colour 80h.
  MOV  CX,140h              ; There are 140h pixels in the line.
  PUSH CX                   ; Store 140h on stack so it can be recalled later.
  REP  STOSB                ; Draw top line.
bl1:
  INC  Ax                   ; Change AL to the next colour in sequence,
  AND  AL,8Fh               ; and mask to ensure that colour is 80h - 8Fh.
  STOSB                     ; Store colour for left hand border.
  XOR  AL,0FFh              ; Change colour from border to background.
  MOV  CX,13Eh              ; There are 13Eh pixels of background.
  rep  STOSB                ; Store the background.
  XOR  AL,0FFh              ; Change colour from background to border.
  STOSB                     ; Store colour for right hand border.
  CMP  DI,0F8C0h            ; Have we finished 199 lines ?
  JNE  bl1                  ; If not do next line.
  INC  AX                   ; Change to next border colour.
  POP  CX                   ; Make CX = 140h (Pixels in last line)
  REP  STOSB                ; Draw last line.

  ; Wait for vertical retrace.

zl1:
  MOV  DX,03DAh             ; Port 03DA bit 3 is vertical retrace bit.
cl2:
  IN   AL,DX                ; Get value of port 03DAh
  TEST AL,08h               ; Test bit 3.
  JZ   cl2                  ; Loop until bit 3 is 1. (Vertical retrace)

  ; Update palette

  MOV  DL,0C8h              ; Change DX to 03C8h. (Colour index)
  MOV  AL,70h               ; Start with colour index 70h.
  OUT  DX,AL                ; Tell the VGA chipset this.
  INC  DX                   ; Change DX to 03C9h. (Colour Palette)
  INC  BX                   ; Change to next colour set.
  AND  BL,0Fh               ; Make sure low byte is 0h - Fh.
  LEA  SI,[ebx+ebx*2]       ; Make SI = BX * 3.
                            ; SI = (Palette data start - 30h) + 3*colour set.
  MOV  AL,04h               ; We transfer 4 * 16 colours
cl3:
  MOV  CL,30h               ; We transfer 96 bytes (3*16).
  ADD  SI,CX                ; We also skip 96 bytes. (colour set = 32*3 bytes)
  REP  OUTSB                ; Output 16 sets of RGB values.
  DEC  AL                   ; Next set of 16 colours.
  JNZ  cl3                  ; Done them all? if not loop.

  ; Update worm positions, draw them and check for crash.

  MOV  DH,BL                ; Copy low nybble of current colour set. (BL)
  XOR  DH,9Fh               ; DH now contains the current colour for worm 0.

  MOV  SI,OFFSET w0direct-4 ; W0direct-4 as we add 4 before getting dir.
  MOV  DL,00h               ; DL is or'd with current colour if collision.
  MOV  CL,02h               ; There are 2 worms.
zl2:
  LODSD                     ; Skip 4 bytes of data.
  LODSW                     ; Get current direction. (disp + 8000h if neg)
  BTR  AX,15                ; Test and reset bit 15.
  JNC  zj1                  ; If bit was zero skip over negation.
  NEG  AX                   ; Negate displacement. (Bit 15 reset by btr)
zj1:
  add  AX,[SI]              ; Add displacement to current offset.
  mov  [SI],AX              ; Save offset back to data.

  XCHG DI,AX                ; Move current offset to DI. (AX trashed)
  SAL BYTE PTR ES:[DI],1    ; Shift current colour under worm head left 1.
  JNC nh                    ; If top bit was clear we didn't hit anything so
                            ; skip over hit flag.
  OR  DL,DH                 ; Set hit flag be or'ing DL with current colour.
nh:
  MOV  ES:[DI],DH           ; Draw current colour at worm head.
  XOR  DH,30h               ; Change colour to other worm colour.
  LOOP zl2                  ; Loop if we havn't done all the worms.
  AND  DL,DL                ; Set flags according to DL. (hit flag)
  JZ   zl1                  ; If no hits continue loop.

  ; Draw end of game screen.

  XOR  DL,30h               ; Change to correct colour for winner.
                            ; Red hit => Green win.
                            ; Green hit => Red win.
                            ; Red + Green hit => Draw (Yellow win).
  XOR  DI,DI                ; Reset DI to zero. (ES:DI = screen start)
  DEC  CX                   ; CX now is FFFFh. (Was zero)
  XCHG AX,BX                ; Make AL equal to colour for screen
  REP  STOSB                ; Fill screen with colour.

  ; Terminate game.

zj3:
  POP AX                    ; Restore 2509h to AX.
  POP DX                    ; Restore old INT 9 ISR offset to DX.
  POP DS                    ; Restore old INT 9 ISR segment to DS.
  INT  21h                  ; Call 'Set interrupt' interrupt.
  XCHG CX,AX                ; Set AX to zero.
  INT  16h                  ; Wait for key.
  INT  20h                  ; Terminate program.

  ; Keyboard ISR routine.

isr_j1:
  PUSHA                     ; Store all general purpose registers.
  MOV  DI,offset w0key1     ; CS:DI is worm 0 key.
  IN   AL,60h               ; Get key pressed.
  MOV  CX,0002h             ; CX is number of worms.
  MOV  DX,8141h             ; disp XOR 8141h is R<=>U L<=>D
isr_l1:
  MOV  BX,CS:[DI]           ; BL is worm key, BH is worm key modifier.
isr_l2:
  CMP  AL,BL                ; Is key pressed current key ?
  JNZ  isr_j2               ; If not skip update code.
  XOR  CS:[DI+2],DX         ; Modify displacement.
  XOR  CS:[DI],BH           ; Modify key by modifer to give correct sense
                            ; to key i.e. initial key turns left always.
isr_j2:
  XOR  BL,BH                ; Modify current key.
  XOR  DH,80h               ; Modify displacement modifer.
  JNS  isr_l2               ; If displacement modifer is 0141h do loop again.
  ADD  DI,6                 ; Skip to next worm data.
  LOOP isr_l1               ; Done all the worms? if not do full loop again.
  MOV  DX,0061h             ; DX is now keyboard controller status port.
  IN   AL,DX                ; Load status.
  OR   AL,82h               ; Set keyboard controller into reset mode.
  OUT  DX,AL                ; Reset controller.
  AND  AL,7Fh               ; Set keyboard controller into normal mode.
  OUT  DX,AL                ; Set controller to normal mode.
  MOV  AL,20h               ; Reset PPI by writting 20h into
  OUT  20h,AL               ; port 20h.
  POPA                      ; Restore all general purpose registers.
  IRET                      ; Return from interrupt.

  w0key1   : DB 2Ch         ; If we start going Left/Right then key 1 is
                            ; the scancode of the key for turn left.
  w0keymod : DB 01h         ; Key2 = Key1 xor Keymod.
  w0direct : DW 0001h       ; Initial displacement (L = 8001h, R = 0001h,
                            ; U = 8141h, D = 0141h)
  w0offset : DW 7D10h       ; Initial offset in segment.
  w1key1   : DB 33h         ; See w0key1.
  w1keymod : DB 07h         ; See w0keymod.
  w1direct : DW 8001h       ; See w0direct.
  w1offset : DW 7E35h       ; See w0offset.

