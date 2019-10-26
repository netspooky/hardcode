;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Pusher
;;  Whizart, November 2014
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; control keys
KEY_PUSHER_UP       equ 72    ; arrow up
KEY_PUSHER_DOWN     equ 80    ; arrow down
KEY_PUSHER_LEFT     equ 75    ; arrow left
KEY_PUSHER_RIGHT    equ 77    ; arrow right
KEY_ESC             equ 1

;; output character codes
FLOOR_CHAR          equ 0
BOX_CHAR            equ 1
BIN_CHAR            equ 2
WALL_CHAR           equ 3
PUSHER_UP_CHAR      equ 4
PUSHER_DOWN_CHAR    equ 5
PUSHER_LEFT_CHAR    equ 6
PUSHER_RIGHT_CHAR   equ 7
CHARS_TO_LOAD       equ 7

;; output character colors
BIN_COLOR           equ 02h
ON_BIN_COLOR        equ 0ah
PUSHER_COLOR        equ 09h
PUSHER_ON_BIN_COLOR equ 0ah
BOX_COLOR           equ 6eh
BOX_ON_BIN_COLOR    equ 6ah
FLOOR_COLOR         equ 07h
WALL_COLOR          equ 7fh

;; status line
STATUS_LINE         equ 24
STATUS_LINE_COLOR   equ 1fh

;; misc
BYTES_PER_LINE      equ 80

;; global variables
Variables           equ 80h
LevelDataSize       equ Variables+0
PusherPos           equ Variables+2
;  register bp stores number of bins (spares 6B)

ORG 100h
BITS 16

inc ax                            ; assume ax = 0 at startup
                                  ; set mode 1: 40x25 text mode w/ 16x8 characters
int 10h                           ; video mode set here to spare clear screen

xchg ax, dx                       ; for below dx = 1

;; load characters
mov si, Chars8B                   ; for each character 8 bytes are
mov di, Chars16B                  ; stored; as characters are 8x16
mov bp, di                        ; each row of the character is doubled here
mov cx, Chars8BSize

Chars8BtoChars16BLoop:
  lodsb
  stosb
  stosb
  loop Chars8BtoChars16BLoop

; dx = 1 needed here
mov ax, 1110h                     ; load character definitions
mov cl, CHARS_TO_LOAD             ; cx = 0 before because of loop above
mov bx, 1000h
int 10h

mov ch, 20h                       ; "turn off" cursor, al = 7 from above
mov ah, 1                         ; as at moment there are 7 characters to load
int 10h

push 0b800h                       ; es -> video ram (color text mode)
pop es

mov si, LevelData 
cwd                               ; dx = 0, for GetBitOfLevelData()
xor bp, bp                        ; reset empty bins
mov al, [si]
mov [LevelDataSize], al
mov di, 4*BYTES_PER_LINE+12       ; upper left corner of level shown
mov bx, di                        ; bx stores next line offset
jmp isInNextLine

nextLine:
;; fill rest of line
  mov cx, bx
  sub cx, di
  rep stosb                       ; ax = 0 from below, no change up to here
isInNextLine:
  add bx, 80                      ; shift to beginning of next line
GetNextItemOfLevel: 
  xor ax, ax
  call GetBitOfLevelData          ; X
  jc AddFloor                     ; 1 -> Floor ( )
  call GetBitOfLevelData          ; 0X
  jc AddWall                      ; 01 -> Wall (#)
  call GetBitOfLevelData          ; 00X
  jc AddBox                       ; 001 -> Box ($)
  call GetBitOfLevelData          ; 000X
  jc AddBin                       ; 0001 -> Bin (.)
  call GetBitOfLevelData          ; 0000X
  jnc nextLine                    ; 00000 -> line break, next column
  call GetBitOfLevelData          ; 00001X
  jnc AddBoxOnBin                 ; 000010 -> Box on bin (*)
;; add pusher here                ; 000011 - "Pusher" (player) (@)
  mov [PusherPos], di
  mov ax, PUSHER_COLOR*256 + PUSHER_LEFT_CHAR
  jmp OutputCharAndGetNextItem  
AddBoxOnBin:
  mov ax, BOX_ON_BIN_COLOR*256 + BOX_CHAR
  jmp OutputCharAndGetNextItem
AddBin:
  inc bp
  mov ax, BIN_COLOR * 256 + BIN_CHAR
  jmp OutputCharAndGetNextItem
AddBox:
  mov ax, BOX_COLOR*256 + BOX_CHAR
  jmp OutputCharAndGetNextItem
AddWall:
  mov ax, WALL_COLOR*256 + WALL_CHAR
  jmp OutputCharAndGetNextItem
AddFloor:
  mov ax, FLOOR_COLOR*256 + FLOOR_CHAR
OutputCharAndGetNextItem:
  stosw
  jmp GetNextItemOfLevel
  
WaitForUserInput:
  xor ax, ax
  int 16h
  mov al, ah                      ; pays off because working with al below
                                  ; spares 5B: +2B-5B = -3B
CheckForKeyUp:
  cmp al, KEY_PUSHER_UP
  jne CheckForKeyDown
  mov bx, -80
  mov al, PUSHER_UP_CHAR
  jmp MovePusher

CheckForKeyDown:
  cmp al, KEY_PUSHER_DOWN
  jne CheckForKeyLeft  
  mov al, PUSHER_DOWN_CHAR
  mov bx, 80
  jmp MovePusher

CheckForKeyLeft:
  cmp al, KEY_PUSHER_LEFT
  jne CheckForKeyRight
  mov al, PUSHER_LEFT_CHAR
  mov bx, -2
  jmp MovePusher

CheckForKeyRight:
  cmp al, KEY_PUSHER_RIGHT
  jne CheckForEscape
  mov al, PUSHER_RIGHT_CHAR
  mov bx, 2
  jmp MovePusher

CheckForEscape:
  cmp al, KEY_ESC
  jne WaitForUserInput
  
Goodbye:
  mov ax, 3
  int 10h
  ret

GetBitOfLevelData:
  dec dl  
  jns HaveBits
  dec byte [LevelDataSize]
  jnz LoadBits
  pop cx   ; pop ip to dummy (arbitrarily cx)
  jmp WaitForUserInput
LoadBits:
  inc si
  mov dh, [si]
  mov dl, 7
HaveBits:
  rol dh, 1
  ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; move pusher
;
; usage of registers:
;  bx - delta one move, direction -80, 80, 2, -2
;  dl - step 0, push 1
;  cl - pusher char (input in al)
;  ch - color of +1 step square
MovePusher:
  cbw                             ; ah = 0, as al < 80h (pusher char)
  cwd                             ; dx = 0
  xchg ax, cx                     ; al -> cl (pusher char)
  mov si, [PusherPos]
  mov di, si                      ; si = di = pusher pos
  
  add si, bx                      ; si = pusher pos + bx
  es lodsw                        ; si = pusher pos + bx + 1
  cmp al, WALL_CHAR
  je WaitForUserInput             ; pusher blocked => do not move pusher!
  
  mov ch, ah
  cmp al, BOX_CHAR
  jne MovePusherFromTo
  
  inc dx                          ; set dl = 1 "moving box" (or blocked by box)
  lea si, [si+bx-2]               ; si = pusher pos + 2*bx
  es lodsb
  test al, 1                      ; wall 3, box 1  | bin 2, floor 0
  jnz WaitForUserInput            ; box blocked => pusher blocked => do not move
  
; moving box -> play sound
  pusha
  mov dx,0x331                    ; set MIDI to UART mode
  mov al,0x3f
  out dx, al
  dec dx                          ; data register
  mov cx, 5
  mov si, PushBoxSound
  rep outsb
  popa

; *do* pusher move
MovePusherFromTo:
  mov si, di                      ; si = di = pusher pos
  es lodsw
  cmp ah, PUSHER_ON_BIN_COLOR
  mov ax, BIN_COLOR*256 + BIN_CHAR
  je MovingPusherFromBin
  mov ax, FLOOR_COLOR*256 + FLOOR_CHAR
MovingPusherFromBin:

  stosw                           ; si = di = pusher pos + 2
; square moved to: was it a bin?
  mov ah, ch
  and ah, 7
  cmp ah, BIN_COLOR  
  mov ah, PUSHER_ON_BIN_COLOR
  je MovingPusherIntoBin
  mov ah, PUSHER_COLOR
MovingPusherIntoBin:
  
  mov al, cl
  lea di, [si+bx-2]
  lea si, [di+bx]
  stosw

; *do* box move (if any)
  dec dx                          ; ZF if "moved box" resp. dl = 1
  jnz MovePusherDone
  
  cmp ch, BOX_ON_BIN_COLOR
  jne DidNotMoveBoxOutOfBin
  inc bp                          ; one more empty bin :(
DidNotMoveBoxOutOfBin:

  mov di, si
  es lodsw
  cmp ah, BIN_COLOR
  mov ah, BOX_COLOR
  jne DidNotMoveBoxIntoBin
  dec bp                          ; one less empty bin :)
  jz Goodbye                      ; no empty bins left: completed level! :-)
  mov ah, BOX_ON_BIN_COLOR  
DidNotMoveBoxIntoBin:  

  mov al, BOX_CHAR
  stosw
  
MovePusherDone:
  add [PusherPos], bx
  jmp WaitForUserInput

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; level data
;; sound data
;; character data

LevelData:           incbin "level.bin"

PushBoxSound         db 0c0h, 116, 90h, 20h   ; !! 7e from below taken as volume !!
Chars8B              equ $
BoxGraphics          db   7eh,  83h,  85h, 89h, 91h, 0a1h,  0c1h,  7eh
BinGraphics          db   00h,  00h,  18h, 24h, 24h,  18h,   00h,  00h
WallGraphics         db   7eh,  91h,  91h, 7eh, 89h,  89h,   89h,  7eh
PusherUpGraphics     db   0,    42h,  42h, 99h, 66h,  3ch,     0,    0
PusherDownGraphics   db   0,    0,    3ch, 66h, 99h,  42h,   42h,    0
PusherLeftGraphics   db   10h,  68h,  0ch, 14h, 14h,  0ch,   68h,  10h
PusherRightGraphics  db   08h,  16h,  30h, 28h, 28h,  30h,   16h,  08h
Chars8BSize          equ $-Chars8B
Chars16B             equ $
