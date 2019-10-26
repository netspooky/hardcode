; MTROOP.ASM - Mars Trooper
;
; Created by Misha Koshelev for the 256-byte game contest on
; rec.games.programmer
;
; To compile (in Turbo Assembler):
;   TASM /M MTROOP
;   TLINK /T MTROOP
;
; This code is FREEWARE, however, if you want to use it in a
; commercial or shareware product, please contact me before you do so.

.MODEL TINY
.386
.CODE
ORG 100h

; Registers used:
;   BP - The address of the player
;   BX - Number of loops before player runs out of oxygen
;   DX - 1950h for scrolling

; Background attributes
GroundAttr EQU (6*16)+6
ScoreAttr EQU (2*16)+5

Start:

; ***
; INITIALIZE
; ***

; Initialize the random-number seed
mov ah, 2ch
int 21h
mov [RandSeed], dx

; Set the segment to the text mode graphics memory
push word ptr 0b800h
pop es

; Clear the screen with a red foreground
mov ax, 0619h
xor cx, cx
mov dx, 1950h
mov bh, 4
int 10h

; Set the X coordinate to the default coordinate of the player
mov bp, (12*160)+80

; Set the number of loops until player dies to 128
mov bx, 128

; ***
; MAIN LOOP
; ***

@@MainLoop:

; Scroll the screen up one line (saving and restoring bx)
push bx
mov ax, 0601h
mov bh, GroundAttr
xor cx, cx
int 10h
pop bx

; ***
; DRAW THE PLAYER'S "SCORE"
; ***

; Increase the number of cycles the player has gone through
mov ax, Score
inc ax
mov Score, ax

; If the player has gone through 4 score letters, then move him down
; one line
mov cx, ax
sub cx, 512
cmp cx, LScore
jle @@NoModY
add bp, 160
mov LScore, ax
@@NoModY:

; And draw the number of times the player has gone through
; 128 cycles (the "Score")
mov di, 158
shr ax, 7
stosb

; Draw the background for the "Score"
mov al, ScoreAttr
stosb

; ***
; SET A RANDOM NUMBER OF CHARACTERS TO CLEAR AS PASSABLE ON THE LINE
; ***

; Get a random number between 0 and 31
@@GetRand:
call GetRandom
and cl, 31

; Make sure it is greater than 3, and if it is not, then get
; another random number
cmp cl, 3
jle @@GetRand

; Double CX
shl cl, 1

; Subtract it from the center to find the starting coordinate
mov di, (24*160)+80
push di        ; Save DI for later use
sub di, cx

; Set the color to the blank color (Black background, Blue foreground)
xor ax, ax
mov ah, 4

; Draw the blank spaces
rep stosw

; ***
; DRAW (IF NECESSARY) A FILLUP HEART
; ***

; If a random number between 0 and 11 is 0, draw a fillup heart

; Restore DI so that it is equal to (24*160)+80
pop di

; First, set the character to draw (and save it for later use)
mov ax, 0003h
push ax

call GetRandom

and cl, 11
jnz @@NoHeart

; Find a random position for the heart (14 pixels from the center max),
; and draw it
call GetRandom

and cl, 14
shl cl, 1

add di, cx

; And draw it
stosb

@@NoHeart:

; ***
; SHOW HOW MUCH OXYGEN THE PLAYER HAS LEFT
; ***

; Draw hearts for every eight units of oxygen the player has left

; Get the number of loops into CX
mov cx, bx

; Divide the number of hearts by 8
shr cx, 3

; If the number of hearts is 0, then make it 1 (so it is shown as 1 heart)
jnz @@LifeOk

inc cx

@@LifeOk:

; Set di to (0,0)
xor di, di

; Set the attribute to draw (character already set from last part)
mov ah, 14h

; And draw the hearts
rep stosw

; Decrease the amount of oxygen left
dec bx

; ***
; KEYBOARD HANDLING
; ***

; Get the shift key status
mov ah, 2
int 16h

; Check the shift keys and move the player accordingly
rcr ax, 1
jnc @@CheckLShift
add bp, 2

@@CheckLShift:
rcr ax, 1
jnc @@DoneKeyCheck
sub bp, 2

@@DoneKeyCheck:

; ***
; DRAWING THE PLAYER
; ***

; Restore AX (so al is 3)
pop ax

; If the player is going onto a heart, give him 64 more cycles
cmp BYTE PTR es:[bp], al     ;(al == 3)
jnz @@NotOnHeart

add bx, 64

@@NotOnHeart:

; Draw the player
mov BYTE PTR es:[bp], 1

; ***
; TIMER
; ***

; Wait for the timer (vertical retrace) 3 times
mov cx, ax

; Save DX (which is used for scrolling)
push dx

; Set DX to the vertical retrace register
mov dx, 3dah

@@TimerLoop:
@@Wait1:
in al, dx
test al, 8
jnz @@Wait1
@@Wait2:
in al, dx
test al, 8
jz @@Wait2

loop @@TimerLoop

; Restore DX
pop dx

; Erase the previous player
mov BYTE PTR es:[bp], cl

; ***
; LOGIC
; ***

; If the player has run out of oxygen, quit
cmp bx, cx              ; Note: CX is 0
jz @@EndProg

; If the player has too much oxygen, quit (because his air tank burst)
; (this happens when the player has reached two rows of hearts)
cmp bx, 1280
jge @@EndProg

; If the player is on a square he should not touch, quit
cmp BYTE PTR es:[bp+1], GroundAttr
jnz @@MainLoop

; Exit
@@EndProg:

; ***
; DESTRUCTION
; ***

; Clear the screen
mov ax, 0003h
int 10h

; And show the score
mov ax, Score
shr ax, 7
xor di, di
stosb

ret

; GetRandom - Returns a random byte. RandSeed must first be set to a random
; word.
GetRandom PROC NEAR
   mov cx, [RandSeed]
   imul cx, 13A7h
   inc cx
   mov [RandSeed], cx

   mov cl, ch
   mov ch, 0

   ret
GetRandom ENDP

; The variable in which the number of loops gone through is stored
; (a kind of score)
Score DW 8320

; The last score letter at which the player was moved down
LScore DW 0

; A random seed
RandSeed DW ?

END Start
