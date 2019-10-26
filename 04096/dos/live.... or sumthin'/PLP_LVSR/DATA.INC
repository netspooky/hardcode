; ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;
;  Predefined data
;
; ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

DATASEG

radConversion   DD      162.97466       ; Needed for those stupid radians :)
real16384       DD      16384.000       ; 16384 in real

moveCamera      DW      25000           ; Used for camera movements
                DW      0
                DW      0

moveRotX        DW      0
moveRotY        DW      0
moveRotZ        DW      0

horizVertex     DW      0               ; Used for the horizont
                DW      25000
                DW      0

cameraHeight    DW      CAM_HEIGHT      ; Height of the camera

centerX         DW      160             ; Center of the screen
centerY         DW      100

frameCounter    DW      0               ; Used for animation
tickCounter     DW      0

chnl_on         DW      OFFSET null
                DW      OFFSET null
                DW      OFFSET null

chnl_order      DW      OFFSET c10_ord-2
                DW      OFFSET c11_ord-2
                DW      OFFSET c12_ord-2

chnl_delay      DB      1
                DB      1
                DB      1

fadeInProgress  DB      0               ; The name says it all!

currString      DW      OFFSET textStrings ; Offset to the current textstring

flipScreen      DW      OFFSET blurFlip ; Offset of the current effect

effectNumber    DW      0               ; Number of the current effect

effectOffset    DW      OFFSET blurFlip ; Offsets to different effects
                DW      OFFSET splitFlip
                DW      OFFSET blurFlip
                DW      OFFSET displaceFlip
                DW      OFFSET splitFlip
                DW      OFFSET blurFlip
                DW      OFFSET displaceFlip
                DW      OFFSET blurFlip
                DW      OFFSET splitFlip

morphDest       DW      OFFSET keyframe2 ; Destination offset for the morph

endMessage      DB      "paskan m”iv„t....", 10, 10, 13, "$"

gmidiQueryMsg   DB      "GMIDI baseport (3x0h)? $"


IF MONOMONITOR EQ 1

; Character versions of different grayscales

dotChars        DB      " úù", 7, 7, "+", 4, "þ*", 15, "O0#@", 2, 2

ENDIF


; Include all textstrings here ----------------------------------------------

INCLUDE "text.inc"


; Include the whole 3D-scene here -------------------------------------------

INCLUDE "scene.inc"


; Include the music-data here -----------------------------------------------

INCLUDE "music.inc"



; ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;
;  Undefined data
;
; ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±


UDATASEG

oldTimerHandler DD      ?               ; Address of the old timer-int

newX            DD      ?               ; Rotated coordinates
newY            DD      ?
newZ            DD      ?

matrix          DD      9 DUP (?)       ; Space for the matrix
cameraMatrix    DD      9 DUP (?)       ; Matrix for the camera

distance        DD      ?               ; Distance of the object

cos_x           DD      ?               ; Temporary variables for
sin_z           DD      ?               ; calculating the matrix
sinz_cosx       DD      ?
cosz_sinx       DD      ?
cosz_cosx       DD      ?
sinz_sinx       DD      ?

sincosTable     DD      1024 DUP (?)    ; Space for the sinetable

delta1          DD      ?               ; Deltas for the polygon
delta2          DD      ?
delta3          DD      ?

sortArray       DD      1000 DUP (?)    ; Array for sorting

polyHeight      DW      ?               ; Height of the polygon section
polyHeight2     DW      ?

boxX1           DW      ?               ; Temporary coordinates for the box
boxY1           DW      ?               ; being drawn right now
boxZ1           DW      ?

boxX2           DW      ?
boxY2           DW      ?
boxZ2           DW      ?

boxX3           DW      ?
boxY3           DW      ?
boxZ3           DW      ?

boxX4           DW      ?
boxY4           DW      ?
boxZ4           DW      ?

boxX5           DW      ?
boxY5           DW      ?
boxZ5           DW      ?

boxX6           DW      ?
boxY6           DW      ?
boxZ6           DW      ?

boxX7           DW      ?
boxY7           DW      ?
boxZ7           DW      ?

boxX8           DW      ?
boxY8           DW      ?
boxZ8           DW      ?

tempX           DW      ?               ; Temporary x/y/z-coordinates
tempY           DW      ?
tempZ           DW      ?

virtualBuffer   DW      ?               ; Segmentaddress of the virtual buffer
colorMixTable   DW      ?               ; Segment of the color-mixing table
displaceMap     DW      ?               ; Segment for the displacement-map

count           DW      ?               ; Public counter
count2          DW      ?

rotX            DW      ?               ; Rotation counters
rotY            DW      ?
rotZ            DW      ?
                
moveX           DW      ?               ; Needed for camera movement
moveY           DW      ?
moveZ           DW      ?

horizX          DW      ?               ; Used for the horizont
horizY          DW      ?
horizZ          DW      ?

nextString      DW      ?               ; Offset to the next textstring

gmidiPort       DW      ?               ; Baseport of the GM device

realPalette     DB      780 DUP(?)      ; Space for the palettes
currPalette     DB      780 DUP(?)

channel         DB      ?               ; Used in music

grayScaleTable  DB      256 DUP(?)      ; Table for grayscale-conversion

fontData        DB      256*14 DUP (?)  ; Room for the EGA 8x14 font

morphedFrame    DB      1300 DUP (?)    ; Array for morphing
