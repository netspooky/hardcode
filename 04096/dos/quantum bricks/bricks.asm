;---------------------------------------------------------------------
; BRICKS.ASM - by Tylisha C. Andersen
;---------------------------------------------------------------------

.model tiny
.186

;---------------------------------------------------------------------
.data
;---------------------------------------------------------------------

font:                               ; a 7x9 pixel font, chars 32-127
  dw 5 dup(0),6168,6168,24,24,13878,54,0,0,0,13878,13951,13951,54
  dw 6168,24638,1596,6268,24,0,27750,13848,102,14336,14444,27758,13932
  dw 6144,6168,0,0,0,6156,12336,12336,6192,12300,3096,3084,3084,12312
  dw 0,7222,7295,54,0,6144,32280,6168,0,0,0,0,6168,48,0,32256,5 dup(0)
  dw 6168,0,1538,6156,24624,64,15360,26214,26214,15462,0,7180,3132
  dw 3084,12,15360,1638,6156,32304,0,3198,15384,26118,60,3584,13854
  dw 32358,1542,0,24702,1660,26118,60,15360,31840,26214,15462,0,1662
  dw 3084,6168,24,15360,26214,26172,15462,0,26172,26214,1598,60,0
  dw 6168,0,6168,0,6144,24,6144,12312,1536,6156,6192,1548,0,0,126
  dw 126,0,12288,3096,3078,12312,0,26172,3078,24,24,15360,26214,28270
  dw 15456,0,15384,26214,26238,102,31744,26214,26236,31846,0,26172
  dw 24672,26208,60,30720,26220,26214,30828,0,24702,31840,24672,126
  dw 32256,24672,24700,24672,0,26172,28256,26214,62,26112,26214,26238
  dw 26214,0,6204,6168,6168,60,3584,1542,26118,15462,0,26214,30828
  dw 26220,102,24576,24672,24672,32352,0,26178,32382,26214,102,17920
  dw 30310,28286,25190,0,26172,26214,26214,60,31744,26214,24700,24672
  dw 0,26172,26214,27750,62,31744,26214,27772,26214,0,26172,15456
  dw 26118,60,32256,3 dup(6168),0,3 dup(26214),60,26112,26214,26214
  dw 6204,0,26214,32358,26238,66,26112,15462,15384,26214,0,26214,15462
  dw 6168,24,32256,3078,12312,32352,15360,3 dup(12336),15408,16384
  dw 12384,3096,518,15360,3 dup(3084),15372,15384,102,6 dup(0),32512
  dw 6168,24,0,0,0,0,1596,26174,62,24576,31840,26214,31846,0,0,26172
  dw 26208,60,1536,15878,26214,15974,0,0,26172,24702,60,7168,12342
  dw 12412,12336,0,0,26174,15974,15366,24576,31840,26214,26214,0,24
  dw 6200,6168,24,1536,3584,1542,26214,60,24672,27750,27768,102,14336
  dw 3 dup(6168),0,0,32364,26238,102,0,31744,26214,26214,0,0,26172
  dw 26214,60,0,31744,26214,24700,96,0,26174,15974,1542,0,31744,24678
  dw 24672,0,0,24638,1596,124,12288,31792,12336,7216,0,0,26214,26214
  dw 62,0,26112,26214,6204,0,0,26214,26238,66,0,26112,6204,26172,0
  dw 0,26214,15974,31750,0,32256,6156,32304,3072,6168,12312,6168,3096
  dw 4 dup(6168),12312,6168,3096,6168,12312,32306,76,0,0,0

xtitle      dw    49                ; title rectangle list
  db 32, 1, 5, 6, 6,32, 2, 7, 7, 8,32, 1, 9, 7,10,32, 1, 6, 2, 9
  db 32, 5, 6, 6, 7,32, 6, 8, 7, 9,36, 8, 5,13, 6,36, 9, 7,14, 8
  db 36, 8, 6, 9,10,36,12, 6,13, 7,36,13, 8,14,10,40,15, 5,20, 6
  db 40,15, 9,20,10,40,17, 6,18, 9,44,21, 5,26, 6,44,21, 9,26,10
  db 44,21, 6,22, 9,48,28, 7,33, 8,48,27, 5,28,10,48,31, 5,32, 7
  db 48,32, 8,33,10,52,34, 5,39, 6,52,34, 7,39, 8,52,34, 9,39,10
  db 52,34, 6,35, 7,52,38, 8,39, 9
  db 25, 1, 0, 5, 1,25, 1, 3, 6, 4,25, 1, 1, 2, 3,25, 4, 1, 5, 3
  db 27, 7, 3,11, 4,27, 7, 0, 8, 3,27,10, 0,11, 3,29,12, 0,16, 1
  db 29,13, 2,15, 3,29,12, 1,13, 4,29,15, 1,16, 4,31,17, 0,21, 1
  db 31,17, 1,18, 4,31,20, 1,21, 4,29,22, 0,27, 1,29,24, 1,25, 4
  db 27,28, 3,32, 4,27,28, 0,29, 3,27,31, 0,32, 3,25,33, 0,38, 1
  db 25,33, 1,34, 4,25,35, 1,36, 4,25,37, 1,38, 4

ball        db     0,23, 0,21,21, 0,23, 0
            db     0,27,22,26,26,22,27, 0
            db    21,29,26,28,28,26,29,21
            db    23,30,27,29,29,27,30,23
            db    23,30,27,29,29,27,30,23
            db    21,29,26,28,28,26,29,21
            db     0,27,22,26,26,22,27, 0
            db     0,23, 0,21,21, 0,23, 0

xcodes      dw    00C11h, 00B06h, 03E07h, 0EA10h, 08C11h
            dw    0DF12h, 00014h, 0E715h, 00416h, 0E317h

bounces     dw    00000h,0FFFFh,0FFFFh,0FF00h
            dw    0FFFFh,000FFh,0FFFFh,0FFFFh
            dw    0FFFFh,0FFFFh,000FFh,0FFFFh
            dw    0FF00h,0FFFFh,0FFFFh,00000h

movement    db    3, 1, 2, 0        ; movement table

highscore   dw    0                 ; the high score

color       db    15                ; the drawing color
            db    0                 ; alignment

feat1$      db    'featuring',0
feat2$      db    'Quantum Tunneling & the Uncertainty Principle',0
author$     db    'Written by Tylisha C. Andersen',0
anykey$     db    'Press any key except Escape to play',0
escape$     db    'Press Escape to quit to DOS',0
toplay$     db    'Left and Right Shift Keys move the paddle',0
schigh$     db    'High Score:',0
score$      db    'Score          Level     Lives     Bricks    ',0
ready$      db    'READY...',0
gover$      db    'GAME OVER, press any key',0
hiscor$     db    'You have a high score!',0

;---------------------------------------------------------------------
.data?
;---------------------------------------------------------------------

save_sp     dw    ?                 ; stack pointer at g_1

randseed    dw    ?,?               ; random number seed
score       dw    ?                 ; the current score
lives       dw    ?                 ; number of lives
level       dw    ?                 ; what level its at
numbricks   dw    ?                 ; number of bricks

ballx       dw    ?                 ; position of ball
bally       dw    ?
paddlex     dw    ?                 ; position of paddle
speedctr    dw    ?                 ; counter (1-4) for speed

xyspeed     label word
xspeed      db    ?                 ; x-speed of ball
yspeed      db    ?                 ; y-speed of ball
pspeed      db    ?                 ; speed of paddle
flags       db    ?                 ; hit flags
tunnel      db    ?                 ; quantum tunneling flag

bricks      db    200 dup(?)        ; array of bricks
number      db    20 dup(?)         ; number buffer

;---------------------------------------------------------------------
.code
;---------------------------------------------------------------------

org 100h
start:      call  setupx            ; set up mode-x

s_1:        call  titlescr          ; display title screen
            call  flushkey          ; flush the keyboard buffer
            xor   ah, ah            ; read a key
            int   16h
            cmp   ah, 1             ; quit if it's the <Esc> key
            je    s_2
            call  game              ; play the game
            jmp   s_1

s_2:        call  savehigh          ; save high scores
            mov   ax, 3             ; reset to text mode
            int   10h
            ret                     ; return to dos


;---------------------------------------------------------------------
; game -- play the game
;---------------------------------------------------------------------

game:       call  initgame          ; initialize the game
            mov   save_sp, sp       ; save stack pointer

g_1:        inc   speedctr          ; increment speed counter
            and   speedctr, 3

            call  flushkey          ; flush keyboard buffer
            call  vrt               ; wait for vertical retrace
            call  killpaddle        ; erase paddle & ball
            call  killball

            cmp   bally, 223        ; can't move paddle if dying
            jg    g_3

            mov   al, pspeed        ; bx = paddle movement
            call  getspeed
            xchg  bx, ax

            mov   ah, 02h           ; check for shift-keys
            int   16h
            test  al, 1             ; right-shift?
            jnz   g_2
            test  al, 2             ; left-shift?
            jz    g_3

            sub   paddlex, bx       ; move the paddle left
            cmp   paddlex, 4        ; bumped into left side?
            jge   g_3
            mov   paddlex, 4
            jmp   g_3

g_2:        add   paddlex, bx       ; move the paddle right
            cmp   paddlex, 284      ; bumped into right side?
            jle   g_3
            mov   paddlex, 284

g_3:        call  putpaddle         ; draw the paddle

            mov   al, xspeed        ; move the ball
            call  getspeed
            add   ballx, ax
            mov   al, yspeed
            call  getspeed
            add   bally, ax

; check to see if it has bounced off the walls

            cmp   ballx, 4          ; bounce off the left?
            jnl   g_4
            mov   ballx, 4
            neg   xspeed
            call  g_wbounce         ; noise

g_4:        cmp   ballx, 308        ; bounce off the right?
            jng   g_5
            mov   ballx, 308
            neg   xspeed
            call  g_wbounce         ; noise

g_5:        cmp   bally, 14         ; bounce off the top?
            jnl   g_6
            mov   bally, 14
            neg   yspeed
            call  g_wbounce         ; noise

            test  flags, 2          ; if it hasn't done this before,
            jnz   g_6
            mov   al, flags         ; add 3 to yspeed if it has hit
            and   al, 1             ; a 3rd level brick, 6 if it has
            xor   al, 1             ; not (this can happen if it is
            add   al, 2             ; a new life)
            add   al, al
            add   yspeed, al
            or    flags, 2

; check to see if it has bounced off the paddle or hit the bottom

g_6:        cmp   bally, 223        ; if near the bottom, then
            jl    g_11

            mov   bx, paddlex       ; ax = left end
            lea   ax, [bx-7]        ; bx - cx = normal range
            lea   cx, [bx+24]       ; dx = right end
            lea   dx, [bx+31]

            cmp   ballx, ax         ; missed the paddle?
            jl    g_10
            cmp   ballx, dx
            jg    g_10

            mov   ax, 3800          ; noise
            call  g_bounce

            mov   ax, 00FEh         ; get random speed less than the
            add   al, pspeed        ; paddle's speeed, but not zero
            call  rand
            inc   ax

            cmp   ballx, bx         ; if it hit the left end, then
            jnl   g_7
            neg   ax                ; set a random speed to the left
            jmp   g_8

g_7:        cmp   ballx, cx         ; if it hit the right end, then
            jng   g_9
g_8:        mov   xspeed, al        ; set a random speed to the right

g_9:        mov   bally, 222        ; ball y-position is 222
            neg   yspeed            ; ball is now moving up
            jmp   g_14

g_10:       cmp   bally, 228        ; ball hit the bottom?
            jl    g_11
            jmp   g_18

; check to see if it has hit a brick

g_11:       xor   si, si            ; zero si
            mov   bx, ballx
            mov   cx, bally
            call  hitbrick          ; hit with top left?
            push  ax                ; push brick value
            adc   si, si            ; shift into si
            add   bx, 7
            call  hitbrick          ; hit with top right?
            push  ax                ; push brick value
            adc   si, si            ; shift into si
            add   cx, 7
            sub   bx, 7
            call  hitbrick          ; hit with bottom left?
            push  ax                ; push brick value
            adc   si, si            ; shift into si
            add   bx, 7
            call  hitbrick          ; hit with bottom right?
            push  ax                ; push brick value
            adc   si, si            ; shift into si

            mov   cx, 4             ; redraw these bricks
g_12:       pop   dx
            call  killbrick

            cmp   dx, 40            ; if hit a brick in level 3,
            jl    g_13              ; and haven't done this before,
            test  flags, 1          
            jnz   g_13

            mov   al, yspeed        ; increase yspeed by two
            cbw
            shl   ah, 2
            add   ah, 2
            add   yspeed, ah
            or    flags, 1          ; and set the flag
g_13:       loop  g_12

            or    si, si            ; hit no bricks?
            jz    g_14

            mov   ax, xyspeed       ; direction of movement is
            sar   al, 7             ; always set
            sar   ah, 7
            add   al, ah
            add   al, ah
            neg   al
            xchg  cx, ax

            mov   bx, 1             ; bx = value for lookup
            shl   bx, cl
            or    bx, si

            mov   al, 0             ; quantum tunneling effect
            xchg  al, tunnel        ; can tunnel through 2 layers
            or    al, al            ; if tunnel = 1 then tunnel,
            jnz   g_14              ; but set tunnel to 0

            mov   ax, 2             ; quantum tunneling effect
            call  rand              ; set tunnel flag half the time
            mov   tunnel, al
            mov   ax, 10            ; quantum tunneling effect
            call  rand              ; 1 in 10 hits cause tunneling
            or    ax, ax
            jz    g_14

            mov   tunnel, 0         ; no tunneling, clear flag
            add   bx, bx            ; get bounce activators
            mov   ax, bounces[bx]
            xor   xyspeed, ax       ; bounce on -1, none on 0
            sub   xspeed, al
            sub   yspeed, ah

g_14:       call  putball           ; draw the ball

            mov   ax, 300           ; uncertainty principle:
            call  rand              ; ball can turn in midair
            or    ax, ax            ; average every 6 seconds
            jnz   g_16

            mov   bl, pspeed        ; bl = upper limit
            mov   bh, bl            ; bh = lower limit
            neg   bh

g_15:       mov   ax, 9             ; random between -4 and 4
            call  rand
            sub   al, 4
            add   al, xspeed        ; add in xspeed
            or    al, al            ; cannot be zero
            jz    g_15
            cmp   al, bl            ; faster than paddle to right?
            jge   g_15
            cmp   al, bh            ; faster than paddle to left?
            jle   g_15

            mov   xspeed, al        ; set new xspeed
g_16:       mov   ah, 1             ; check for key
            int   16h
            jz    g_17              ; if <Esc> pressed, then quit
            cmp   ah, 1
            je    g_20

g_17:       jmp   g_1               ; loop

g_18:       mov   bally, 228        ; draw ball at bottom
            call  putball

            mov   ax, 40            ; sound 40 Hz for 60 vrt's
            call  sound             ;  (buzz)
            mov   cx, 60
g_19:       call  vrt
            loop  g_19
            call  nosound

            dec   lives             ; if there are lives left, then
            jz    g_20
            call  initlife          ; new life
            call  ready             ; display ready message
            jmp   g_1

g_20:       mov   ax, score         ; check for high score
            cmp   highscore, ax
            jae   g_21
            mov   highscore, ax

            mov   bx, 83            ; display hiscor string
            mov   cx, 180
            mov   dx, offset hiscor$
            mov   color, 44
            call  string

g_21:       mov   bx, 76            ; display gover string
            mov   cx, 170
            mov   dx, offset gover$
            mov   color, 40
            call  string

            call  flushkey          ; flush keyboard buffer
            xor   ah, ah            ; wait for key
            int   16h
            ret                     ; return !!!

g_wbounce:  mov   ax, 3400          ; bounce of wall = 3400Hz
g_bounce:   call  sound             ; sound tone for one vrt
            call  vrt
            call  nosound
            ret

;---------------------------------------------------------------------
; clrscr -- clear screen
;---------------------------------------------------------------------

clrscr:     pusha                   ; save registers
            mov   dx, 03C4h         ; activate all four planes
            mov   ax, 0F02h
            out   dx, ax
            xor   ax, ax            ; ax = 0, di = 0
            xor   di, di
            mov   cx, 2800h         ; clear the screen
            rep   stosw
            popa                    ; restore registers and return
            ret

;-----------------------------------------------------------------------
; conv16 -- put 16-bit number in buffer as string
;-----------------------------------------------------------------------
; ax = number

conv16:     pusha                   ; save registers

            mov   di, offset number ; di = buffer

            mov   bx, 10            ; bx = base
            xor   cx, cx

cv_1:       xor   dx, dx            ; divide ax by 10
            div   bx

            add   dl, 30h           ; push on stack as digit
            push  dx      
            inc   cx                ; add 1 to count of digits
            or    ax, ax            ; loop
            jnz   cv_1

cv_2:       pop   ax                ; pop and store digits
            mov   [di], al
            inc   di
            loop  cv_2

            mov   byte ptr [di], 0  ; string terminator
            popa                    ; restore registers and return
            ret


;---------------------------------------------------------------------
; dispscore -- display score, lives
;---------------------------------------------------------------------

dispscore:  pusha                   ; save registers

            xor   ax, ax            ; clear score area
            xor   bx, bx
            mov   cx, 319
            mov   dx, 9
            mov   color, al
            call  frect

            mov   color, 10         ; color is green
            inc   bx                ; display score string
            xor   cx, cx
            mov   dx, offset score$
            call  string

            mov   color, 14         ; color is yellow

            mov   ax, score         ; display score
            mov   bx, 43
            call  ds_disp

            mov   ax, level         ; display level
            mov   bx, 148
            call  ds_disp

            mov   ax, lives         ; display lives
            mov   bx, 218
            call  ds_disp

            mov   ax, numbricks     ; display bricks
            mov   bx, 295
            call  ds_disp

            popa                    ; restore registers and return
            ret

ds_disp:    call  conv16            ; convert and display
            mov   dx, offset number
            call  string
            ret

;---------------------------------------------------------------------
; drawbrick -- draw a brick
;---------------------------------------------------------------------
; dx = brick

drawbrick:  pusha                   ; save registers
            mov   ax, dx            ; divide by 20
            mov   bx, 20
            div   bl
            mov   bl, al            ; ax = x, bx = y
            shr   ax, 8

            xor   si, si            ; assume brick is off
            mov   word ptr color, si
            mov   di, dx            ; if brick is on, then
            cmp   bricks[di], 0
            je    db_1

            mov   si, 104           ; main color = 32 + 2 * y
            add   si, bx            ; shadow color = 104 + 2 * y
            mov   word ptr color, si
            sub   si, 72

db_1:       shl   ax, 4             ; get screen position
            shl   bx, 3

            mov   cx, 8             ; make staggered pattern
            and   cx, bx
            add   ax, cx
            sub   ax, 4

            neg   bx                ; start wall at y = 60
            add   bx, 132
            mov   cx, 15            ; get lower-right corner
            add   cx, ax
            lea   dx, [bx+7]
            
            cmp   ax, 4             ; adjust if left half-brick
            jge   db_2
            mov   ax, 4
db_2:       cmp   cx, 315           ; adjust if right half-brick
            jle   db_3
            mov   cx, 315

db_3:       call  frect             ; draw shadow rectangle
            mov   word ptr color, si; set main color
            inc   ax                ; move past shadow
            inc   bx
            call  frect             ; draw main rectangle

db_4:       popa                    ; restore registers and return
            ret


;---------------------------------------------------------------------
; flushkey -- flush the keyboard buffer
;---------------------------------------------------------------------

flushkey:   push  ax                ; save registers
            push  ds
            push  40h               ; ds = bios-segment
            pop   ds
            mov   ax, ds:[1Ch]      ; make head of buffer
            mov   ds:[1Ah], ax      ; equal to the tail
            pop   ds                ; restore registers and return
            pop   ax
            ret


;---------------------------------------------------------------------
; frect -- draw filled rectangle
;---------------------------------------------------------------------
; ax = x1, bx = y1, cx = x2, dx = y2

frect:      pusha                   ; save registers
            xchg  ax, bx            ; y1 x1 x2 y2
fr_1:       call  hline             ; draw a horizontal line
            dec   dx                ; move up one line
            cmp   dx, ax            ; loop
            jge   fr_1
            popa                    ; restore registers and return
            ret


;---------------------------------------------------------------------
; getspeed -- how much to move at this speed
;---------------------------------------------------------------------
; al = speed, returns ax = movement

getspeed:   push  bx                ; save registers
            push  dx
            cbw                     ; temporarily make positive
            cwd
            xor   ax, dx
            sub   ax, dx

            mov   bx, speedctr      ; bx = speed counter
            mov   ah, al            ; al = base, ah = fraction
            shr   al, 2
            and   ah, 3
            cmp   movement[bx], ah  ; if movement threshold is
            adc   al, 0             ; less than fraction, add 1
            xor   ah, ah

            add   ax, dx            ; restore original sign
            xor   ax, dx
            pop   dx                ; restore registers and return
            pop   bx
            ret


;---------------------------------------------------------------------
; hitbrick -- did the ball hit a brick?
;---------------------------------------------------------------------
; bx = x, cx = y of ball, returns cf = hit brick, ax = brick

hitbrick:   push  bx                ; save registers
            push  cx
            sub   cx, 60            ; y out of range?
            cmp   cx, 80
            mov   ax, -1            ; assume no brick
            jae   hb_1

            neg   cx                ; cx = y position from bottom
            add   cx, 79

            mov   ax, cx            ; adjust for staggered pattern
            and   ax, 8
            sub   bx, ax
            add   bx, 4

            shr   cx, 3             ; bx = brick number
            shr   bx, 4
            imul  cx, 20
            add   bx, cx

            cmp   bricks[bx], 0     ; check for a brick
            mov   ax, -1
            je    hb_1

            mov   ax, bx            ; ax = number of brick 

hb_1:       cmp   ax, -1
            pop   cx                ; restore registers and return
            pop   bx
            ret

;---------------------------------------------------------------------
; hline -- draw horizontal line
;---------------------------------------------------------------------
; bx = x1, cx = x2, dx = y

hline:      pusha                   ; save registers
            imul  dx, 80            ; dx = y-part of offset
            mov   di, bx            ; di = address of start
            shr   di, 2
            add   di, dx
            mov   si, cx            ; si = address of end
            shr   si, 2
            add   si, dx

            mov   ch, bl            ; cx = planes
            and   cx, 0303h

            mov   bx, 0201h         ; bx = plane masks
            shl   bh, cl
            dec   bh
            mov   cl, ch
            shl   bl, cl
            neg   bl

            mov   dx, 03C4h         ; dx = sequencer port
            mov   al, 2             ; set up to activate planes
            mov   ch, color         ; ch = color

            cmp   si, di            ; check for a tiny line
            je    hl_1

            mov   ah, bh            ; draw right end of line
            out   dx, ax
            mov   es:[si], ch
            mov   ah, bl            ; draw left end of line
            out   dx, ax
            mov   es:[di], ch
            inc   di

            mov   ah, 0Fh           ; activate all four planes
            out   dx, ax
            mov   al, ch            ; ax = color
            mov   ah, ch
            mov   cx, si            ; cx = number of bytes
            sub   cx, di
            rep   stosb             ; draw middle of line
            jmp   hl_2

hl_1:       and   bh, bl            ; get single plane value
            mov   ah, bh            ; draw the line
            out   dx, ax
            mov   es:[si], ch

hl_2:       popa                    ; restore registers and return
            ret


;---------------------------------------------------------------------
; initgame -- initialize game variables, screen
;---------------------------------------------------------------------

initgame:   pusha                   ; save registers
            xor   ax, ax            ; score is 0
            mov   score, ax
            inc   ax                ; level is 1
            mov   level, ax
            mov   lives, 3          ; lives is 3

            mov   ballx, 156        ; ball starts in the middle of
            mov   bally, 140        ; the screen, below the wall
            mov   paddlex, 144      ; paddle also in the middle

            call  initlevel         ; beginning of level
            popa                    ; restore registers
            ret                     ; return


;---------------------------------------------------------------------
; initlevel -- initialize for beginning of level
;---------------------------------------------------------------------

initlevel:  pusha                   ; save registers

            mov   di, offset bricks ; fill bricks-array with 1's
            mov   cx, 200
il_1:       mov   byte ptr [di], 1
            inc   di
            loop  il_1

            mov   numbricks, 200    ; 200 bricks on screen

            call  clrscr            ; clear the screen
            xor   ax, ax            ; starting at position
            mov   bx, 10            ; (0, 10)-(319, 239),
            mov   cx, 319
            mov   dx, 239
            mov   color, 24         ; draw four rectangles,
            call  rect              ; to appear as a round bar
            mov   color, 27
            call  il_rect
            mov   color, 25
            call  il_rect
            mov   color, 21
            call  il_rect

            call  initlife          ; proceed as new life

            mov   dx, 199           ; draw the wall
il_2:       call  drawbrick
            dec   dx
            jnl   il_2

            call  ready             ; display ready message
            popa                    ; restore registers
            ret                     ; return

il_rect:    inc   ax                ; move in 1 pixel and
            inc   bx                ; draw a rectangle
            dec   cx
            dec   dx
            call  rect
            ret


;---------------------------------------------------------------------
; initlife -- initialize for new life
;---------------------------------------------------------------------

initlife:   pusha                   ; save registers
            call  killpaddle        ; draw paddle & ball
            call  killball

            mov   ballx, 156        ; ball starts in the middle of
            mov   bally, 141        ; the screen, below the wall
            mov   paddlex, 144      ; paddle also in the middle
            mov   flags, 0          ; haven't hit anything
            mov   tunnel, 0         ; not tunneling

            mov   al, 4             ; ball y-speed is 4+level
            add   ax, level
            mov   yspeed, al
            add   al, 7             ; paddle speed is 9+level,
            and   al, -2            ; but it must be even
            mov   pspeed, al

if_1:       mov   ax, 7             ; ball x-speed is a random
            call  rand              ; number between -3 and 3,
            sub   al, 3             ; but zero is not allowed
            jz    if_1
            mov   xspeed, al

            call  putpaddle         ; draw paddle & ball
            call  putball

            call  dispscore         ; display score
            popa                    ; restore registers
            ret                     ; return


;---------------------------------------------------------------------
; killball -- erase the ball
;---------------------------------------------------------------------

killball:   pusha                   ; save registers
            mov   color, 0          ; color is black
            mov   ax, ballx         ; clear a rectangle,
            mov   bx, bally         ; 8 pixels wide, 8 high
            mov   cx, 7
            add   cx, ax
            lea   dx, [bx+7]
            call  frect
            popa                    ; restore registers
            ret                     ; return


;---------------------------------------------------------------------
; killbrick -- remove a brick
;---------------------------------------------------------------------
; dx = brick

killbrick:  pusha                   ; save registers
            cmp   dx, -1            ; -1 = no brick
            je    kb_1
            mov   bx, dx            ; set to zero in array
            cmp   bricks[bx], 0     ; no brick here?
            je    kb_1
            mov   bricks[bx], 0
            call  drawbrick         ; erase from the screen

            mov   bx, 20            ; ax = row number of brick
            xchg  ax, dx            ; starting at 1 (not 0!!!)
            cwd
            div   bx
            inc   ax
            mul   level             ; multiply by level
            add   score, ax         ; add into score

            mov   ax, 3             ; uncertainty principle:
            call  rand              ; add random number -1, 0, or 1
            dec   ax
            add   score, ax

            div   level             ; tone is higher for top bricks
            imul  ax, 100           ; than for bottom bricks
            add   ax, 1900          
            call  sound             ; sound tone for one vrt
            call  vrt
            call  nosound

            dec   numbricks         ; decrease number of bricks
            call  dispscore         ; display score

            cmp   numbricks, 0      ; finished this level?
            je    kb_2
kb_1:       popa                    ; restore registers
            ret                     ; return

kb_2:       mov   ax, 1200          ; make crescendo sound from
            mov   cx, 60            ; 1200 to 3000 Hz for 60 vrt's
kb_3:       call  sound
            call  vrt
            mov   bx, ax
            shr   bx, 6
            add   ax, bx
            loop  kb_3
            call  nosound

            imul  ax, level, 100    ; add 100*level^2 points
            mul   level
            add   score, ax

            inc   level             ; go to the next level
            call  initlevel
            mov   sp, save_sp       ; restart at g_1
            jmp   g_1


;---------------------------------------------------------------------
; killpaddle -- erase the paddle
;---------------------------------------------------------------------
; bx = x

killpaddle: pusha                   ; save registers
            mov   color, 0          ; color is black
            jmp   pp_1


;-----------------------------------------------------------------------
; nosound -- turn sound off
;-----------------------------------------------------------------------

nosound:    push  ax                ; save ax
            in    al, 61h           ; turn speaker off
            and   al, 0FCh
            out   61h, al
            pop   ax                ; restore ax and return
            ret


;---------------------------------------------------------------------
; putball -- draw the ball
;---------------------------------------------------------------------

putball:    pusha                   ; save registers
            mov   si, offset ball   ; si = ball image
            imul  di, bally, 80     ; di = y-part of address

            mov   cx, ballx         ; cx = x
            mov   dx, 03C4h         ; dx = sequencer port
            mov   ax, 1102h         ; ax = value to use to
            rol   ah, cl            ; activate plane (x mod 4)

            shr   cx, 2             ; di = address of start
            add   di, cx

            mov   bp, 8             ; 8 rows
pb_1:       mov   cx, 4             ; 4 planes
pb_2:       out   dx, ax            ; activate plane
            mov   bx, [si]          ; copy 2 pixels
            mov   es:[di], bx
            inc   si                ; advance source index
            inc   si
            rol   ah, 1             ; move right 1 pixel
            adc   di, 0
            loop  pb_2              ; loop
            add   di, 79            ; move down 1 pixel
            dec   bp                ; loop
            jnz   pb_1

            popa                    ; restore registers and return
            ret


;---------------------------------------------------------------------
; putpaddle -- draw the paddle
;---------------------------------------------------------------------
; bx = x

putpaddle:  pusha                   ; save registers
            mov   color, 14         ; color is yellow
pp_1:       mov   ax, paddlex       ; draw filled rectangle,
            mov   cx, 31            ; 32 pixels wide, 4 high
            add   cx, ax
            mov   bx, 231
            mov   dx, 234
            call  frect
            popa                    ; restore registers and return
            ret


;---------------------------------------------------------------------
; putpix -- put pixel
;---------------------------------------------------------------------
; bx = x, cx = y, al = color

putpix:     push  di                ; save registers
            push  dx
            push  cx
            push  ax

            imul  di, cx, 80        ; di = y-part of address
            mov   cx, bx            ; cx = x
            mov   dx, 03C4h         ; dx = sequencer port
            mov   ax, 1102h         ; activate plane (x mod 4)
            rol   ah, cl
            out   dx, ax

            shr   cx, 2             ; di = address of pixel
            add   di, cx
            pop   ax                ; al = color, store at di
            stosb

            pop   cx                ; restore registers and return
            pop   dx
            pop   di
            ret


;---------------------------------------------------------------------
; rand -- generate random number
;---------------------------------------------------------------------
; ax = limit, returns ax = number

rand:       push  bx                ; save registers
            push  cx
            push  dx
            xchg  cx, ax            ; cx = limit

            mov   ax, randseed[0]   ; generate next number
            mov   dx, 660Dh
            mul   dx
            imul  bx, randseed[2], 0019h
            add   dx, bx
            imul  bx, randseed[0], 660Dh
            add   dx, bx
            add   ax, 0DCDh
            adc   dx, 0001h
            mov   randseed[0], ax
            mov   randseed[2], dx

            mov   bx, dx            ; divide ax:dx by cx
            xor   dx, dx
            div   cx
            xchg  ax, bx
            div   cx
            xchg  ax, dx            ; ax = remainder

            pop   dx                ; restore registers
            pop   cx
            pop   bx
            ret                     ; return


;---------------------------------------------------------------------
; ready -- display ready message for 100 vrt's
;---------------------------------------------------------------------

ready:      pusha                   ; save registers
            mov   dx, offset ready$ ; dx = ready message
            mov   bx, 139           ; to be displayed at middle of
            mov   cx, 170           ; screen, below the wall

            mov   color, 42         ; display ready message
            call  string            ; in orange

            mov   ax, 100           ; delay 100 vrt's
rd_3:       call  vrt
            dec   ax
            jnz   rd_3

            mov   color, 0          ; remove ready message
            call  string
            popa                    ; restore registers
            ret                     ; return


;---------------------------------------------------------------------
; rect -- draw rectangle
;---------------------------------------------------------------------
; ax = x1, bx = y1, cx = x2, dx = y2

rect:       pusha                   ; save registers
            xchg  cx, dx            ; x1 y1 y2 x2
            call  vline             ; draw right side
            xchg  ax, dx            ; x2 y1 y2 x1
            call  vline             ; draw left side
            xchg  ax, cx            ; y2 y1 x2 x1
            xchg  bx, dx            ; y2 x1 x2 y1
            call  hline             ; draw top side
            xchg  ax, dx            ; y1 x1 x2 y2
            call  hline             ; draw bottom side
            popa                    ; restore registers and return
            ret


;---------------------------------------------------------------------
; savehigh -- save high scores in executable
;---------------------------------------------------------------------

savehigh:   mov   es, ds:[2Ch]      ; no need to save registers
            xor   di, di            ; es:di = environment
            xor   al, al            ; al = 0, cx = 0FFFFh
            xor   cx, cx
            dec   cx
sh_1:       repne scasb             ; find two consecutive zeros
            scasb
            jne   sh_1

            push  es                ; ds:dx = program file name
            pop   ds
            lea   dx, [di+2]

            mov   ax, 3D01h         ; open the executable file
            int   21h
            xchg  ax, bx            ; bx = file handle

            mov   ax, 4200h
            xor   cx, cx
            mov   dx, offset highscore-100h
            int   21h

            push  cs                ; ds:dx = highscore
            pop   ds
            mov   dx, offset highscore
            mov   ah, 40h           ; write 2 bytes to file
            mov   cx, 2
            int   21h

            mov   ah, 3Eh           ; close the file
            int   21h
            ret                     ; return


;---------------------------------------------------------------------
; setupx -- set mode-x 320x240
;---------------------------------------------------------------------

setupx:     pusha                   ; save registers
            mov   ax, 13h           ; set 320x200 mode
            int   10h

            mov   es, ax            ; seed the randomizer
            mov   ax, es:[033Ch]
            mov   randseed[0], ax
            mov   ax, es:[033Eh]
            mov   randseed[2], ax

            mov   dx, 03C2h         ; set polarity
            mov   al, 0E3h
            out   dx, al
            mov   dl, 0C4h          ; set x-mode memory access
            mov   ax, 0604h
            out   dx, ax

            mov   dl, 0D4h          ; set 240 vertical resolution
            mov   si, offset xcodes
            mov   cx, 10
            rep   outsw

            push  0A000h            ; es = video memory
            pop   es
            call  clrscr            ; clear the screen
            popa                    ; restore registers and return
            ret


;-----------------------------------------------------------------------
; sound -- make a sound
;-----------------------------------------------------------------------
; ax = pitch

sound:      pusha                   ; save registers
            xchg  bx, ax            ; divide 1.2MHz by pitch
            mov   dx, 12h
            mov   ax, 34DCh
            div   bx
            xchg  bx, ax

            mov   al, 0B6h          ; set the clock delay in
            out   43h, al           ; microseconds (sort of) between
            xchg  bx, ax            ; each pulse
            out   42h, al
            mov   al, ah
            out   42h, al

            in    al, 61h           ; turn speaker on
            or    al, 3
            out   61h, al
            popa                    ; restore registers and return
            ret


;---------------------------------------------------------------------
; string -- draw a string in the 7x9 font
;---------------------------------------------------------------------
; bx = x, cx = y, dx = string

string:     pusha                   ; save registers

            mov   si, dx            ; si = string
st_1:       lodsb                   ; get one character
            or    al, al            ; quit if a null
            jz    st_6
            call  st_2              ; draw the character
            add   bx, 7             ; move 7 pixels right
            jmp   st_1              ; loop

st_2:       pusha                   ; save registers
            sub   al, 32            ; si = bitmap for this character
            mov   ah, 9
            mul   ah
            add   ax, offset font
            xchg  si, ax

            imul  di, cx, 80        ; di = y-part of address
            mov   cx, bx            ; cx = x
            mov   dx, 03C4h         ; dx = sequencer port
            mov   ax, 1102h         ; ax = value to use to
            rol   ah, cl            ; activate plane (x mod 4)
            shr   cx, 2             ; di = address of pixel
            add   di, cx

            mov   bl, 40h           ; mask first pixel

st_3:       out   dx, ax            ; activate plane

            mov   cx, 9             ; 9 rows
st_4:       mov   bh, color         ; bh = color
            test  [si], bl          ; if this pixel is set in the
            jz    st_5              ; bitmap, then draw it on screen
            mov   es:[di], bh       ; text is drawn transparent
st_5:       add   di, 80            ; move down 1 pixel
            inc   si
            loop  st_4              ; loop

            sub   di, 720           ; move back to top
            sub   si, 9
            rol   ah, 1             ; move right 1 pixel
            adc   di, 0
            shr   bl, 1             ; shift mask right
            jnz   st_3              ; loop

st_6:       popa                    ; restore registers and return
            ret


;---------------------------------------------------------------------
; titlescr -- draw the title screen
;---------------------------------------------------------------------

titlescr:   call  clrscr            ; clear the screen
            mov   si, offset xtitle ; si = title rectangle list
            lodsw                   ; bp = number of rectangles
            xchg  bp, ax
ts_1:       lodsb                   ; set the color
            mov   color, al
            call  ts_load           ; load parameters into
            xchg  dx, ax            ; ax, bx, cx, dx
            call  ts_load
            xchg  bx, ax
            call  ts_load
            xchg  cx, ax
            call  ts_load
            xchg  dx, ax
            dec   cx                ; adjust cx, dx
            dec   dx
            call  frect             ; draw filled rectangle
            dec   bp                ; loop
            jnz   ts_1

            mov   bx, 129           ; display feat1 string
            mov   cx, 84
            mov   dx, offset feat1$
            mov   color, 0Fh
            call  string
            mov   bl, 3             ; display feat2 string
            mov   cl, 93
            mov   dx, offset feat2$
            call  string

            mov   bl, 55            ; display author string
            mov   cl, 104
            mov   dx, offset author$
            mov   color, 07h
            call  string

            mov   bl, 37            ; display anykey string
            mov   cl, 125
            mov   dx, offset anykey$
            call  ts_bold
            mov   dx, offset escape$
            mov   bl, 65
            mov   cl, 134
            call  ts_bold

            mov   bl, 16            ; display toplay string
            mov   cl, 220
            mov   dx, offset toplay$
            mov   color, 02h
            call  string

            mov   bl,  95           ; display schigh string
            mov   cl, 164
            mov   dx, offset schigh$
            mov   color, 0Eh
            call  string
            mov   ax, highscore     ; display high score
            call  conv16
            mov   bl, 184
            mov   dx, offset number
            call  string
            ret                     ; return

ts_load:    lodsb                   ; load byte, mul by 8
            xor   ah, ah
            shl   ax, 3
            ret

ts_bold:    mov   color, 08h
            call  string            ; draw a string in bold
            mov   color, 0Fh
            inc   bx
            call  string
            ret

;---------------------------------------------------------------------
; vline -- draw vertical line
;---------------------------------------------------------------------
; bx = y1, cx = y2, dx = x

vline:      pusha                   ; save registers
            mov   si, cx            ; si = length
            sub   si, bx
            imul  di, bx, 80        ; di = y-part of address

            mov   cx, dx            ; cx = x
            mov   dx, 03C4h         ; dx = sequencer port
            mov   ax, 1102h         ; activate plane (x mod 4)
            rol   ah, cl
            out   dx, ax

            shr   cx, 2             ; di = address of start
            add   di, cx
            mov   al, color         ; al = color

vl_1:       stosb                   ; write pixel
            add   di, 79            ; next line
            dec   si                ; loop
            jnl   vl_1

            popa                    ; restore registers and return
            ret

;---------------------------------------------------------------------
; vrt -- wait for next vertical retrace
;---------------------------------------------------------------------

vrt:        pusha                   ; save registers
            mov   dx, 03DAh
vr_1:       in    al, dx            ; wait for non-retrace
            test  al, 8
            jnz   vr_1
vr_2:       in    al, dx            ; wait for retrace
            test  al, 8
            jz    vr_2
            popa                    ; restore registers and return
            ret


;---------------------------------------------------------------------
end start
;---------------------------------------------------------------------
