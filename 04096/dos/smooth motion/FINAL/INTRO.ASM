; ============================================
;  4Kb Intro for the Assembly '95 competition
; ============================================

; Programmed by:
;    Kim Holviala
;    Aladininkatu 7 B 19
;    49400 Hamina
;    FINLAND


; Asm '95 rules for the 4Kb intro:
;  - Under 4Kb's  (more than enough for anything....)
;  - Not more than 3 minutes
;  - Must stop with ESC
;  - No musics


; To compile a .COM file (Turbo Assembler v3.0 -> ):
;  - Make sure INTRO.ASM and VAR.MAC are present
;  - TASM /m intro
;  - TLINK /t intro

; To compile an .EXE with full debug data:
;  - TASM /m /zi /ddebug intro
;  - TLINK /v intro


IDEAL

MODEL TINY                              ; One segment is more than enough

P386N                                   ; The only way to do it!


IFDEF debug                             ; .EXE must have an stack
   
   STACK   500h

ENDIF


INCLUDE "var.mac"                       ; Include macros for stack-variables


; Variables ===============================================

VAR     codesegment,    WORD            ; Current codesegment
VAR     vgasegment,     WORD,   0A000h  ; VGA memory
VAR     virtualscr,     WORD            ; Segment of the virtual screen
VAR     firestartscr,   WORD            ; Needed for the fire-effect

VAR     temp,           WORD            ; Temporal storage
VAR     count,          BYTE            ; Counts anything
VAR     power_meter,    WORD            ; Calculates the speed of the computer
VAR     timer,          WORD,   0       ; 60 ticks/sec clock

VAR     dot_curr_char,  WORD            ; Current charptr for the dot-scroll
VAR     dot_horiz_place,BYTE,   0       ; Next vertical column to be printed

VAR     sin_start_char, WORD            ; Start charptr for the sinus-scroll
VAR     sin_curr_char,  WORD
VAR     sin_horiz_start,BYTE,   0       ; Horizontal starting-place
VAR     sin_sinptr,     BYTE            ; Pointer to the sine-table

VAR     x_rotation,     BYTE,   0       ; Rotation around the x-axis
VAR     y_rotation,     BYTE,   0
VAR     z_rotation,     BYTE,   0
VAR     distance,       DWORD,  390000h ; Distance of the 3D-object

VAR     center_x,       WORD,   420     ; Place of the 3D-object on screen
VAR     center_y,       WORD,   80

VAR     sin_x,          DWORD           ; SIN(x_rotation)
VAR     sin_y,          DWORD
VAR     sin_z,          DWORD
VAR     cos_x,          DWORD
VAR     cos_y,          DWORD
VAR     cos_z,          DWORD

VAR     cosz_cosy,      DWORD           ; cos_z * cos_y
VAR     sinz_cosy,      DWORD
VAR     sinz_cosx,      DWORD
VAR     cosz_sinx,      DWORD
VAR     cosz_cosx,      DWORD
VAR     sinz_sinx,      DWORD
VAR     cosy_sinx,      DWORD
VAR     cosy_cosx,      DWORD

VAR     matrix0,        DWORD           ; 9 slots for the 3*3 matrix
VAR     matrix1,        DWORD
VAR     matrix2,        DWORD
VAR     matrix3,        DWORD
VAR     matrix4,        DWORD
VAR     matrix5,        DWORD
VAR     matrix6,        DWORD
VAR     matrix7,        DWORD
VAR     matrix8,        DWORD
VAR     matrix9,        DWORD

VAR     new_x,          DWORD           ; Rotated x-coordinate (on screen)
VAR     new_y,          DWORD
VAR     new_z,          DWORD

VAR     fade_in_progress, BYTE          ; Variables for color-fading
VAR     fade_source,    WORD

VAR     morph_source,   WORD            ; Variables for ball-morphing

VAR     retadress,      WORD            ; Variables for polygon-drawing
VAR     x1,             WORD
VAR     y1,             WORD
VAR     x2,             WORD
VAR     y2,             WORD
VAR     x_increase,     WORD
VAR     color,          BYTE
VAR     pgon_min_y,     WORD
VAR     pgon_max_y,     WORD

VAR     worm_x1,        BYTE            ; Variables for the worm
VAR     worm_x2,        BYTE
VAR     worm_x3,        BYTE
VAR     worm_y,         BYTE
VAR     worm_lenght,    BYTE


; Code ====================================================

CODESEG
STARTUPCODE
	

; Initialize everything -----------------------------------

type_message:
	
	VAR_INITIALIZE                  ; Initialize & allocate variables

	MOV     AX,CS                   ; Make sure SREGs are correct
	MOV     DS,AX
	MOV     ES,AX

	CLD                             ; Just to be sure

	MOV     AX,CS                   ; Calculate and store segments
	MOV     codesegment,AX
	ADD     AX,1001h
	MOV     virtualscr,AX
	ADD     AX,1001h
	MOV     firestartscr,AX

	CALL    init_palettes           ; Initialize palettes
	
	MOV     fade_in_progress,1      ; Fade all colors to black
	MOV     fade_source,OFFSET black_palette

init_fadeout:
	CALL    vert_retrace            ; Wait for an retrace before
	CALL    fade_palette            ; setting new palette

	CMP     fade_in_progress,1
	JE      init_fadeout

	MOV     AX,13h                  ; Set VGA mode 13h
	INT     10h

	CALL    get_fonts               ; Get CGA & VGA fonts
	
	CALL    create_sincos_table     ; Create full sincos-table

	CALL    init_virtual            ; Initialize virtual screen
	
	CALL    init_pgtable            ; Initialize table for polygons
	
	CALL    init_starfield          ; Initialize starfield
	
	MOV     dot_curr_char,OFFSET dot_text  ; Start dot-scroll from here

	MOV     count,30                ; Wait for the screen to settle down        
	
screen_wait:
	CALL    vert_retrace

	DEC     count
	JNZ     screen_wait


; Part 1: Ball-vectors ------------------------------------

	MOV     fade_in_progress,1      ; Fade in
	MOV     fade_source,OFFSET palette

	MOV     morph_source,OFFSET ball_objects + 84

	MOV     sin_start_char,OFFSET sintext_balls  ; Sinus-scroll start
	
	CALL    handle_sinus            ; Show sinus-scroll

ball_loop:
	CALL    draw_background         ; Redraw backround (erase balls)
	
	CALL    starfield               ; Draw stars
	
	CMP     morph_source,OFFSET ball_objects + 84*5
	JB      ball_no_end_slide       ; Is the object '95'?
	
	CMP     timer,300               ; Is it time for sliding?
	JB      ball_no_end_slide
	
	SUB     center_x,2              ; Slide object to the left

	CMP     center_x,-100           ; Time for the next part?
	JL      part_2

ball_no_end_slide:
	CMP     morph_source,OFFSET ball_objects
	JB      ball_no_start_slide     ; Is the object 'circle'?
	
	CMP     center_x,154            ; Is the object in the center of the
	JB      ball_no_start_slide     ; screen?
	
	SUB     center_x,2              ; No -> Slide object to the left

ball_no_start_slide:
	CALL    morph_balls             ; Morph ball-objects
	
	CALL    calc_matrix             ; Calculate 3D-matrix

	MOV     SI,OFFSET ball_objects
	MOV     count,28
	CALL    rotate_all              ; Rotate all balls

	MOV     SI,OFFSET screen_coords
	MOV     CX,28
	CALL    sort_coords             ; Sort balls by distance
	
	CALL    draw_balls              ; Draw balls & shadows
	
	CALL    dot_scroll              ; Update dot-scroll

	CALL    vert_retrace            ; Wait for an vertical retrace
	
	CALL    flip_screen             ; Show virtual screen
	
	INC     x_rotation              ; Rotate object
	INC     y_rotation
	ADD     z_rotation,2

	MOVZX   CX,x_rotation           ; Rotate some more (break the pattern)
	BT      CX,7
	ADC     y_rotation,0

	MOV     AH,1                    ; Check for a key
	INT     16h
	JZ      ball_loop               ; No key pressed -> Keep looping

	MOV     AH,0                    ; Get the keypress from buffer
	INT     16h

	CMP     AL,27                   ; ESC exits
	JE      exit2dos

	CMP     AL,' '                  ; Space skips this part
	JNE     ball_loop


; Part 2: Filled vectors ----------------------------------

part_2:
	MOV     center_x,160            ; Slide to left from here
	
	MOV     x_rotation,215          ; Change viewpoint
	MOV     y_rotation,128

	MOV     distance,310000h        ; Move object closer
	
	MOV     sin_start_char,OFFSET sintext_fvectors  ; Sinus-scroll start
	
	CALL    handle_sinus

	MOV     timer,0                 ; Reset timer

fvectors_loop:
	INC     timer                   ; Advance timer

	CMP     timer,100               ; Morph from dot to stick?
	JB      morph_to_stick
	
	CMP     timer,600               ; Morph from stick to flag?
	JB      morph_to_flag

	CMP     timer,1200              ; From flag to map?
	JB      morph_to_map
	
	CMP     timer,1470              ; From map to dot?
	JB      morph_to_dot
	
	JMP     part_3                  ; Jump to the next part


fvectors_back_here:
	CALL    draw_background         ; Redraw backround (erase balls)
	
	CALL    starfield               ; Draw starfield
	
	CALL    calc_matrix             ; Calculate 3D-matrix

	MOV     SI,OFFSET vector_start
	MOV     count,31
	CALL    rotate_all              ; Rotate all points

	MOV     SI,OFFSET screen_coords ; Draw bottom half
	MOV     count,8
	MOV     color,15
	CALL    draw_polygon
	
	MOV     count,6                 ; Draw upper half
	MOV     color,15
	CALL    draw_polygon
	
	MOV     count,5                 ; Draw 'head'
	MOV     color,15
	CALL    draw_polygon
	
	MOV     count,4                 ; Draw 'arm'
	MOV     color,15
	CALL    draw_polygon
	
	MOV     count,4                 ; Draw part of the arrow
	MOV     color,95
	CALL    draw_polygon
	
	MOV     count,4                 ; Draw part of the arrow
	MOV     color,95
	CALL    draw_polygon
	
	
	CALL    dot_scroll              ; Update dot-scroll

	CALL    vert_retrace            ; Wait for an vertical retrace
	
	CALL    flip_screen             ; Show virtual screen
	
	INC     z_rotation              ; Rotate viewpoint

	MOV     AH,1                    ; Check for a key
	INT     16h
	JZ      fvectors_loop           ; No key pressed -> Keep looping

	MOV     AH,0                    ; Get the keypress from buffer
	INT     16h

	CMP     AL,27                   ; ESC exits
	JE      exit2dos

	CMP     AL,' '                  ; Space skips this part
	JNE     fvectors_loop


; Part 3: Wormie ------------------------------------------

part_3:
	MOV     sin_start_char,OFFSET sintext_wormie  ; Sinus-scroll start
	
	CALL    handle_sinus            ; Handle sinus-scroll

	MOV     worm_lenght,1           ; Starting lenght
	MOV     center_x,154            ; Center of the object on screen

	MOV     timer,0                 ; Reset timer

wormie_loop:
	INC     timer                   ; Advance timer

	CMP     timer,1800              ; Time to slide to the left?
	JB      wormie_maxsize
	
	SUB     center_x,2              ; Yes -> Slide wormie

	CMP     center_x,-140           ; Time for the next part?
	JL      part_4

wormie_maxsize:        
	CMP     worm_lenght,250         ; Has the worm reached it's max size?
	JE      wormie_cont             ; Yes -> Continue

	CMP     power_meter,500         ; Do we have enough CPU-power?
	JB      wormie_cont             ; No -> Don't grow

	MOV     AX,timer                ; Does the worm need to grow?
	TEST    AX,3
	JNZ     wormie_cont

	INC     worm_lenght             ; Yes

wormie_cont:
	CALL    draw_background         ; Redraw backround (erase balls)
	
	CALL    starfield               ; Draw stars
	
	CALL    draw_wormie             ; Draw worm
	
	CALL    dot_scroll              ; Update dot-scroll

	CALL    vert_retrace            ; Wait for an vertical retrace
	
	CALL    flip_screen             ; Show virtual screen
	
	MOV     AH,1                    ; Check for a key
	INT     16h
	JZ      wormie_loop             ; No key pressed -> Keep looping

	MOV     AH,0                    ; Get the keypress from buffer
	INT     16h

	CMP     AL,27                   ; ESC exits
	JE      exit2dos

	CMP     AL,' '                  ; Space skips this part
	JNE     wormie_loop


; Part 4: The End -----------------------------------------

part_4:
	MOV     fade_in_progress,1      ; Fade all colors to black
	MOV     fade_source,OFFSET black_palette

	MOV     count,100

part4_fadeout:
	CALL    dot_scroll              ; Update dot-scroll

	CALL    vert_retrace            ; Wait for an retrace before
	CALL    fade_palette            ; setting new palette

	CALL    flip_screen             ; Show virtualscreen
	
	DEC     count                   ; Loop
	JNZ     part4_fadeout
	
	CALL    handle_fire             ; Show burning text
	
	JMP     exit2dos_no_fade        ; Exit


; Handle sinus-scroll -------------------------------------

handle_sinus:
	CALL    draw_background         ; Redraw backround (erase everything)
	
	CALL    starfield               ; Draw starfield
	
	CALL    sinus_scroll            ; Update sinus-scroll
	
	CALL    dot_scroll              ; Update dot-scroll

	CALL    vert_retrace            ; Wait for an vertical retrace
	
	CALL    fade_palette            ; Fade palette (if needed)
	
	CALL    flip_screen             ; Show virtual screen
	
	MOV     SI,sin_start_char       ; Get current sinus-scroll char
	MOV     AL,[SI]
	
	CMP     AL,0                    ; Is it 0?
	JNE     _handle_sinus_cont      ; No -> Keep scrollin'
	
	INC     sin_start_char          ; Yes -> Skip over the 0
	
	RET                             ; Quit
	
_handle_sinus_cont:
	MOV     AH,1                    ; Check for a key
	INT     16h
	JZ      handle_sinus            ; No key pressed -> Keep looping

	MOV     AH,0                    ; Get the keypress from buffer
	INT     16h

	CMP     AL,27                   ; ESC exits
	JE      exit2dos

	CMP     AL,' '                  ; Space skips this part
	JNE     handle_sinus

	RET


; Cleanup and exit ----------------------------------------

exit2dos:

	MOV     fade_in_progress,1      ; Fade all colors to black
	MOV     fade_source,OFFSET black_palette

exit_fadeout:
	CALL    vert_retrace            ; Wait for an retrace before
	CALL    fade_palette            ; setting new palette

	CMP     fade_in_progress,1
	JE      exit_fadeout

exit2dos_no_fade:
	MOV     AX,3                    ; Set normal textmode
	INT     10h

	MOV     count,30                ; Wait for the screen to settle down        
	
exit_wait:
	CALL    vert_retrace

	DEC     count
	JNZ     exit_wait

	MOV     AX,1301h                ; Print exitstring
	MOV     BX,30
	MOV     CX,OFFSET end_text_end - end_text
	MOV     DX,0101h
	MOV     BP,OFFSET end_text
	INT     10h
	
	VAR_DEALLOCATE                  ; Deallocate variables

	MOV     AX,4C00h                ; Exit 2 DOS
	INT     21h


; Initalization ===========================================

; Get CGA 8*8 & VGA 8*16 fonts ----------------------------

PROC get_fonts
	
	PUSH    BP

	MOV     AX,1130h                ; Get pointer to the CGA 8*8 font
	MOV     BH,3
	INT     10h

	MOV     AX,ES                   ; ES:BP -> DS:SI = Source adress
	MOV     DS,AX
	MOV     SI,BP

	POP     BP
	
	MOV     ES,codesegment          ; ES:DI = Destination adress
	MOV     DI,OFFSET cga_font

	MOV     CX,512                  ; Copy 512 WORDs (128 characters)

	REP MOVSW                       ; Copy font

	PUSH    BP

	MOV     AX,1130h                ; Get pointer to the VGA 8*16 font
	MOV     BH,6
	INT     10h

	MOV     AX,ES                   ; ES:BP -> DS:SI = Source adress
	MOV     DS,AX
	MOV     SI,BP

	POP     BP
	
	MOV     ES,codesegment          ; ES:DI = Destination adress
	MOV     DI,OFFSET vga_font

	MOV     CX,1024                 ; Copy 128 characters

	REP MOVSW                       ; Copy font

	MOV     DS,codesegment          ; Restore regs

	RET

ENDP


; Create full sincos-table --------------------------------

PROC create_sincos_table

	MOV     SI,OFFSET partial_sincos ; Copy first quadrant of the table
	MOV     DI,OFFSET sincos_table
	MOV     CX,65

	REP MOVSW

	MOV     SI,OFFSET sincos_table + 126

_create_sct_2nd:
	MOV     AX,[SI]                 ; 2nd quadrant is the same as the
	MOV     [DI],AX                 ; first reversed

	DEC     SI
	DEC     SI
	INC     DI
	INC     DI

	CMP     SI,OFFSET sincos_table
	JA      _create_sct_2nd

_create_sct_3rd_4th:
	MOVSW                           ; 3rd & 4th quadrants are the same as
	NEG     [WORD DI-2]             ; the 1st & 2nd, only negative

	CMP     SI,OFFSET sincos_table + 256
	JB      _create_sct_3rd_4th

	RET

ENDP


; Initialize palettes -------------------------------------

PROC init_palettes

	CALL    vert_retrace            ; Must do before reading the palette
	
	MOV     AX,1017h                ; Read current palette
	MOV     BX,0
	MOV     CX,96
	MOV     DX,OFFSET vga_palette
	INT     10h

	MOV     DI,OFFSET black_palette ; Create all black palette
	XOR     AX,AX                   ; and stuff
	MOV     CX,244

	REP STOSW

	MOV     DI,OFFSET palette       ; Create slide of greys
	MOV     CX,16                   ; 16 colors
	XOR     AX,AX

_init_pal_grey:
	STOSW                           ; Store 3 bytes (RGB)
	STOSB
	
	ADD     AX,0404h                ; Advance RGB-values

	LOOP    _init_pal_grey

	MOV     SI,OFFSET colors        ; Copy fixed colors
	MOV     CX,24

	REP MOVSW

	MOV     AL,0                    ; Create slide of blues

_init_pal_blue:
	MOV     [WORD DI],0             ; Red & green are zeros
	MOV     [DI+2],AL               ; Blue

	INC     AL                      ; Next blue is little lighter
	ADD     DI,3                    ; Increase pointer

	CMP     DI,OFFSET palette+288   ; Done?
	JB      _init_pal_blue

	RET

ENDP


; Initialize palette for the fire -------------------------

PROC init_fire_palette

	XOR     AX,AX                   ; Create colors for the fire
	MOV     BL,00

	MOV     DI,OFFSET palette       ; Starting offset of the palette
	
	MOV     count,0                 ; Reset counter

_init_pal_fire:
	INC     count                   ; Increase counter
	
	MOV     [DI],AX                 ; Store RGB
	MOV     [DI+2],BL
	
	ADD     DI,3                    ; Advance pointer
	
	CMP     count,31                ; Do we have enough reds?
	JA      _init_pal_fire_yellow
	
	ADD     AL,2                    ; No -> Increase red

	JMP     _init_pal_fire          ; Loop

_init_pal_fire_yellow:
	CMP     count,62                ; Do we have enough yellows?
	JA      _init_pal_fire_white

	ADD     AH,2                    ; No -> Increase green

	JMP     _init_pal_fire          ; Loop

_init_pal_fire_white:
	CMP     count,93                ; Do we have enough whites?
	JA      _init_pal_fire_end
	
	ADD     BL,2                    ; No -> Increase blue
	
	JMP     _init_pal_fire          ; Loop

_init_pal_fire_end:
	MOV     [DWORD DI],3F3F3F3Fh    ; Store last 2 colors
	MOV     [WORD DI+4],3F3Fh
	
	RET

ENDP


; Initialize virtual screen -------------------------------
	
PROC init_virtual

	CALL    draw_background         ; Draw background
	
	MOV     ES,virtualscr           ; Draw here
	MOV     DI,58240                ; Starting offset

	XOR     AX,AX                   ; Draw 3 black lines
	MOV     CX,240

	REP STOSD

	MOV     count,8                 ; Dot-scroll has 8 rows

_init_virt_dot:        
	MOV     AX,0018h                ; One black and one green dot
	MOV     CX,160                  ; Draw one line

	REP STOSW

	XOR     AX,AX                   ; Draw one black line
	MOV     CX,160

	REP STOSW

	DEC     count                   ; Done?
	JNZ     _init_virt_dot

	MOV     ES,codesegment          ; Restore ES
	
	RET

ENDP


; Initialize table for polygon-drawing --------------------

PROC init_pgtable

	MOV     DI,OFFSET pg_table      ; Fill the table with 8000h
	MOV     CX,200
	MOV     AX,8000h

	REP STOSW

	RET

ENDP


; Initialize starfield ------------------------------------

PROC init_starfield

	MOV     DI,OFFSET starfield_data ; Stardata offset
	MOV     SI,100h                 ; Source for random numbers
	XOR     BX,BX                   ; First star's offset
	MOV     CX,100                  ; Create 200 stars

_init_stars_loop:
	XOR     AX,AX
	
	LODSB                           ; Get random number
	ADD     AX,270
	
	ADD     BX,AX                   ; Advance pointer

	MOV     AX,BX                   ; Store pointer
	STOSW

	ROR     AL,4
	STOSB                           ; Store color
	
	LOOP    _init_stars_loop

	RET

ENDP


; Color routines ==========================================

; Set palette ---------------------------------------------

PROC set_palette

	MOV     DX,3C8h                 ; Start from color 0
	XOR     AL,AL
	OUT     DX,AL

	INC     DX                      ; Output to port 3C9
	MOV     CX,288                  ; Set 288 registers (96 colors)
	MOV     SI,OFFSET vga_palette   ; Offset of the palette

	REP OUTSB                       ; Set DACs

	RET

ENDP


; Fade palette --------------------------------------------

PROC fade_palette

	CMP     fade_in_progress,0      ; Do we have to do it?
	JE      _fade_pal_end

	MOV     SI,fade_source          ; Destination palette
	MOV     DI,OFFSET vga_palette   ; Current palette
	MOV     CX,288
	CALL    morph                   ; Morph (fade) palette

	CMP     AX,0                    ; Are we through with the fading?
	JE      _fade_pal_set

	MOV     fade_in_progress,0      ; Yep

_fade_pal_set:        
	CALL    set_palette             ; Set new palette

_fade_pal_end:
	RET

ENDP


; Scroll routines =========================================

; Update dot-scroll on the bottom of the screen -----------

PROC dot_scroll

	CALL    dot_2left               ; Scroll to the left

	MOV     ES,virtualscr           ; Scroll here

	DEC     dot_horiz_place         ; Are we through with the last char?
	JNS     _dot_still_the_same

	INC     dot_curr_char           ; Yep -> Next char from the string
	MOV     dot_horiz_place,7

_dot_still_the_same:
	MOV     SI,dot_curr_char        ; Get current char
	MOVZX   BX,[SI]

	CMP     BL,0                    ; Is it 0?
	JNE     _dot_char_not_0         ; Nope -> Continue

	MOV     dot_curr_char,OFFSET dot_text ; Yes -> Reset charptr
	
_dot_char_not_0:
	SHL     BX,3                    ; Every char takes 8 bytes
	ADD     BX,OFFSET cga_font      ; BX = Ptr to the char in font

	MOV     DI,0E87Eh               ; Start drawing from here
	MOVZX   DX,dot_horiz_place      ; Draw this column from the char

_dot_loop:
	XOR     AL,AL
	BT      [BX],DX                 ; Get one bit from the font
	ADC     AL,24                   ; Calculate color
	INC     BX

	MOV     [ES:DI],AL              ; Draw

	ADD     DI,640                  ; Next row (2 rows down actually)

	CMP     DI,64000                ; Loop through all rows
	JB      _dot_loop

	MOV     ES,codesegment          ; Restore ES
	
	RET
	
ENDP


; Scroll dot-scroll to the left ---------------------------

PROC dot_2left

	MOV     AX,virtualscr           ; Adress of the video memory 
	MOV     DS,AX
	MOV     ES,AX

	MOV     SI,0E742h               ; Copy from
	MOV     DI,0E740h               ; Copy to

_dot_2left_loop:        
	MOV     CX,159                  ; One line = 159 WORDs

	REP MOVSW                       ; Scroll one line

	ADD     SI,322                  ; SI & DI 2 rows down
	ADD     DI,322
	
	CMP     DI,64000                ; All lines scrolled?
	JB      _dot_2left_loop

	MOV     AX,CS                   ; Restore DS & ES
	MOV     DS,AX
	MOV     ES,AX

	RET

ENDP


; Update sinus-scroll -------------------------------------

PROC sinus_scroll

	MOV     ES,virtualscr           ; Draw here
	
	ADD     sin_sinptr,4            ; Move sinus-effect

	DEC     sin_horiz_start         ; Scroll to the left
	JNS     _sin_same_start_char    ; Next starting char?

	INC     sin_start_char          ; Yep -> Next char from the string
	MOV     sin_horiz_start,7

_sin_same_start_char:
	MOV     AX,sin_start_char       ; Startptr to text
	MOV     sin_curr_char,AX
	
	MOV     AL,sin_sinptr           ; Pointer to sinetable
	
	XOR     BX,BX                   ; Starting x-coordinate
	MOVZX   DI,sin_horiz_start      ; Horizontal position inside char

_sin_loop:
	MOVZX   SI,AL                   ; Get SIN(angle)
	SHL     SI,1                    ; Table contains WORDs
	MOV     DX,[WORD SI+sincos_table] ; Get sine

	INC     AL                      ; Increase sine-pointer
	
	SAR     DX,9                    ; Calculate y-coordinate
	ADD     DX,80

	MOV     SI,sin_curr_char        ; SI=Pointer to char in font
	MOVZX   SI,[SI]
	SHL     SI,4
	ADD     SI,OFFSET vga_font
	
	MOV     CX,15                   ; Loop through 16 rows

_sin_column_loop:
	BT      [SI],DI                 ; Get one bit from the font
	JNC     _sin_column_nodraw      ; Bit was 0 -> Don't draw

	PUSHA

	ADD     BH,DL                   ; Address = (y * 320) + x
	SHL     DX,6
	ADD     BX,DX

	MOV     SI,OFFSET sinus_colors
	ADD     SI,CX        
	
	MOV     AL,[SI]
	MOV     AH,AL

	MOV     [WORD ES:BX],AX         ; Draw 2 points

	POPA                            ; Funny, but must be here!
	PUSHA

	SUB     DX,80                   ; Calculate y-coordinate for shadow
	SAR     DX,2
	ADD     DX,155

	ADD     BH,DL                   ; Address = (y * 320) + x
	SHL     DX,6
	ADD     BX,DX

	MOV     [WORD ES:BX],1A1Ah      ; Draw 2 points of shadow

	POPA

_sin_column_nodraw:
	INC     DX                      ; Increase y-coordinate
	INC     SI                      ; Next row in the font

	LOOP    _sin_column_loop        ; Loop through all rows

	DEC     DI                      ; Next column
	JNS     _sin_char_not_finished  ; This char drawed?

	INC     sin_curr_char           ; Yes -> Next char
	
	MOV     DI,7

_sin_char_not_finished:
	ADD     BX,2                    ; Increase x-coordinate

	CMP     BX,320                  ; All columns drawed
	JNE     _sin_loop

	MOV     ES,codesegment
	
	RET

ENDP


; Graphic routines ========================================

; Wait for the next vertical retrace ----------------------

PROC vert_retrace
	
	MOV     power_meter,0           ; Zero out our counter
	
	MOV     DX,3DAh                 ; Use port 3D4

_vert_retrace_off:
	IN      AL,DX                   ; Get vertical retrace state
	
	TEST    AL,08h
	JNZ     _vert_retrace_off       ; Loop until it's off

_vert_retrace_on:
	INC     power_meter             ; Increase counter
	
	IN      AL,DX                   ; Get vertical retrace state
	
	TEST    AL,08h
	JZ      _vert_retrace_on        ; Loop until it's on

	RET

ENDP


; Draw sprite ---------------------------------------------

; BX - Sprite number
; CX - X-coordinate
; DX - Y-coordinate

PROC putsprite

	CMP     CX,305                  ; Check x-limits
	JA      _ps_end

	MOV     ES,virtualscr           ; Draw to virtual screen
	
	INC     BX
	SHL     BX,1                    ; Start of the sprite to SI
	MOV     SI,[BX+OFFSET sprites]
	ADD     SI,OFFSET sprites

	MOVZX   AX,[SI]                 ; Get width

	ADD     CH,DL                   ; Count destination adress
	SHL     DX,6
	ADD     CX,DX
	MOV     DI,CX

	MOV     DX,320                  ; DX = 320-width
	SUB     DX,AX

	ADD     AX,DI                   ; End of the first line

	MOV     BL,[SI+1]               ; Height = Lines to draw
	ADD     SI,2

	XOR     CH,CH                   ; We need this for BYTE -> WORD

_ps_loop:
	MOV     CL,[SI]                 ; Jump over the invicible area
	ADD     DI,CX
	MOV     CL,[SI+1]               ; Number of visible points
	ADD     SI,2

	SHR     CL,1                    ; Draw using WORDs

	REP MOVSW                       ; Draw

	JNC     _ps_even                ; Still one to draw?

	MOVSB                           ; Yes -> Draw BYTE

_ps_even:
	CMP     DI,AX                   ; End of this line?
	JB      _ps_loop                ; No -> Keep drawing

	ADD     AX,320                  ; Yes -> Next line ends just below
	ADD     DI,DX                   ; DI to the start of the next line

	DEC     BL                      ; All of the lines drawed?
	JNZ     _ps_loop                ; No -> Loop

	MOV     ES,codesegment
	
_ps_end:
	RET

ENDP


; Draw all balls ------------------------------------------

PROC draw_balls

	MOV     count,28                ; Number of shadows to draw
	MOV     SI,OFFSET screen_coords ; Source offset

_draw_balls_shadows:
	MOV     CX,[SI]                 ; Get x
	MOV     BX,[SI+4]               ; Get z
	SAR     BX,11                   ; Place of the shadow
	MOV     DX,155
	SUB     DX,BX
	MOV     BX,2                    ; Sprite number

	PUSH    SI
	CALL    putsprite               ; Draw shadow
	POP     SI

	ADD     SI,6                    ; Next shadow
	
	DEC     count                   ; Done?
	JA      _draw_balls_shadows

	MOV     count,28                ; Number of balls to draw
	MOV     SI,OFFSET screen_coords ; Source offset

_draw_balls_loop:
	MOV     CX,[SI]                 ; Get x
	MOV     DX,[SI+2]               ; Get y
	MOV     BX,[SI+4]               ; Get z
	SHR     BX,15                   ; Big or small ball?
	XOR     BX,1

	PUSH    SI
	CALL    putsprite               ; Draw ball
	POP     SI
	
	ADD     SI,6                    ; Next ball
	
	DEC     count                   ; Done?
	JA      _draw_balls_loop

	RET

ENDP


; Flip virtual screen to VGA ------------------------------

PROC flip_screen

	MOV     DS,virtualscr           ; Source segment
	MOV     ES,vgasegment           ; Destination segment
	XOR     DI,DI                   ; Offsets
	XOR     SI,SI
	MOV     ECX,16000               ; Copy this many DWORDs

	REP MOVSD                       ; Copy

	MOV     DS,codesegment          ; Restore Sregs
	MOV     ES,codesegment

	RET
	
ENDP


; Redraw background ---------------------------------------

PROC draw_background

	MOV     ES,virtualscr           ; Draw eveything here
	XOR     DI,DI                   ; Starting offset
	XOR     EAX,EAX                 ; Fill with color 0 (black)
	MOV     CX,9440                 ; FIll first lines

	REP STOSD

	MOV     count,64                ; Create slide of blues
	MOV     AX,2020h                ; Starting color

_init_bg_blue:
	MOV     CX,160                  ; Draw one line

	REP STOSW

	ADD     AX,0101h                ; Next color

	DEC     count                   ; Done?
	JNZ     _init_bg_blue

	MOV     ES,codesegment          ; Restore ES
	
	RET

ENDP


; Plot one point ------------------------------------------

; BX - X-coordinate
; DX - Y-coordinate
; AL - Color
; ES - Segment to draw to

PROC plot
	
	CMP     BX,319                  ; Check x-limits
	JA      _plot_end

	CMP     DX,199                  ; Check y-limits
	JA      _plot_end
	
	ADD     BH,DL                   ; Address = (y * 320) + x
	SHL     DX,6
	ADD     BX,DX

	MOV     [ES:BX],AL              ; Draw

_plot_end:
	RET

ENDP


; Draw horizontal line ------------------------------------

; AL - color
; BX - x1
; CX - x2
; DX - y
; ES - Segment to draw to

PROC scanline

	CMP     DX,184                  ; Y-coordinate out of range?
	JA      _scanl_end              ; Yes - > Quit

	CMP     CX,BX
	JE      plot                    ; x1 = x2 -> Plot one point
	JG      _scanl_no_swap          ; x1 > x2?

	XCHG    CX,BX                   ; Yes -> Swap them

_scanl_no_swap:
	CMP     BX,0                    ; x1 < 0?
	JG      _scanl_x1_ok

	XOR     BX,BX                   ; Yes -> x1 = 0

_scanl_x1_ok:
	CMP     CX,320                  ; x2 > 320?
	JL      _scanl_x2_ok

	MOV     CX,320                  ; Yes -> x2 = 320

_scanl_x2_ok:
	CMP     BX,CX                   ; Out of the screen horizontally?
	JG      _scanl_end              ; Yes -> Quit

	SUB     CX,BX                   ; Calculate lenght
	INC     CX

	ADD     BH,DL                   ; DI=y*320+x1 (starting adress)
	SHL     DX,6
	ADD     BX,DX
	MOV     DI,BX

	MOV     AH,AL                   ; Fix color for WORD-size writes

	SHR     CX,1                    ; Draw as WORDs

	REP STOSW                       ; Draw line

	JNC     _scanl_end              ; Was the lenght even?

	STOSB                           ; No -> Draw the last pixel

_scanl_end:
	RET

ENDP


; Draw polygon --------------------------------------------

; color - Color
; Coordinates are pushed to stack: 8000h,X1,Y1,X2,Y2,...,Xn,Yn(,returnadress)
; (There _MUST_ be at least three pairs of coordinates!)

PROC polygon

; This part gets the coordinates from the stack
	
	MOV     ES,virtualscr           ; Draw to virtual screen
	
	POP     retadress               ; Get returnadress

	MOV     pgon_min_y,199          ; Initialize min/max y-coordinate
	MOV     pgon_max_y,0
	
	POP     DX                      ; Get first pair of coordinates
	POP     CX

	CALL    _pgon_check_y           ; Check y for top/bottom
	
	MOV     x1,CX                   ; Save them for the last line:
	MOV     y1,DX                   ;  (Xn, Yn) - (X1, Y1)

	POP     y2                      ; Get next pair of coords
	POP     x2

	CALL    _pgline                 ; Draw the line

_polygon_loop:
	MOV     CX,x2                   ; The ending coords of the last line
	MOV     DX,y2                   ; are the starting coords of the next

	CALL    _pgon_check_y           ; Check y for top/bottom
	
	POP     y2                      ; Get next Y
	CMP     y2,8000h                ; End of the coords?
	JE      _polygon_end            ; Yes - > Quit

	POP     x2                      ; Get next X

	CALL    _pgline                 ; Draw the line

	JMP     _polygon_loop           ; Loop

_polygon_end:
	MOV     y2,DX                   ; Restore DX after POP
	MOV     CX,x1                   ; Get saved (X1, Y1)
	MOV     DX,y1

	CALL    _pgline                 ; Draw the last line

	MOV     ES,codesegment          ; Restore ES
	
	MOV     DI,pgon_min_y           ; Clear PG_TABLE between min & max
	SHL     DI,1                    ; y-coordinate
	ADD     DI,OFFSET pg_table

	MOV     CX,pgon_max_y        
	SUB     CX,pgon_min_y
	INC     CX

	MOV     AX,8000h

	REP STOSW
	
	PUSH    retadress               ; Restore returnadress

	RET                             ; Exit


; This part draws the lines and fills the polygon
; The line is drawed between (CX, DX) and (x2, y2)

_pgline:
	PUSH    x2                      ; Save (x2,y2)
	PUSH    y2

	CMP     DX,y2                   ; Is DX = y2?
	JNE     _pgl_no_horiz

	MOV     BX,x2                   ; Yes -> Draw horizontal line
	
	POP     EAX                     ; Dump saved (x2, y2)
	MOV     AL,color                ; Get color        

	JMP     scanline                ; Draw scanline

_pgl_no_horiz:
	JL      _pgl_no_swap            ; Is DX > y2?

	XCHG    x2,CX                   ; Yes -> Swap coordinates
	XCHG    y2,DX

_pgl_no_swap:
	MOV     SI,DX                   ; Save DX (IDIV destroys DX)

	MOV     AX,x2                   ; AX = x2-x1
	SUB     AX,CX
	MOV     BX,y2                   ; BX = y2-y1
	SUB     BX,DX

	CWD                             ; Convert AX -> DX:AX for IDIV
	SHL     AX,6                    ; Lower 6 bits are decimals

	IDIV    BX                      ; AX = (x2-x1)/(y2-y1)
	
	MOV     x_increase,AX           ; Save the result

	MOV     DX,SI                   ; Restore DX

	MOV     SI,CX                   ; Starting x-coordinate
	MOV     BX,CX
	SHL     SI,6                    ; Lower 6 bits are decimals

	MOV     AL,color                ; Get drawing color

	MOV     DI,DX                   ; Calculate index to the table
	SHL     DI,1
	ADD     DI,OFFSET pg_table

	ADD     SI,20h

_pgl_loop:
	MOV     CX,[DI]                 ; Get a value from the table

	CMP     CX,8000h                ; Do we have an value in there?
	JNE     _pgl_draw_scanline      ; Yes -> Draw one line

	MOV     [DI],BX                 ; No -> Store current x to the table

	JMP     _pgl_next_line          ; We don't wanna draw now

_pgl_draw_scanline:
	PUSHA                           ; Save regs
	
	CALL    scanline                ; Draw line

	POPA                            ; Restore regs

_pgl_next_line:
	ADD     SI,x_increase           ; Increase x-coordinate
	MOV     BX,SI                   ; Move it to BX (BX=integer part of x)
	SAR     BX,6                    ; Get rid of the decimals
	
	INC     DX                      ; Increase y-coordinate by 1

	ADD     DI,2
	
	CMP     DX,y2                   ; All lines drawed?
	JLE     _pgl_loop               ; No -> Keep drawing

	POP     y2                      ; Restore (x2, y2)
	POP     x2

	RET


; This subroutine checks if given Y is the top/bottom y-coordinate

_pgon_check_y:
	CMP     DX,pgon_min_y           ; Y greater than top coordinate?
	JGE     _pgon_check_max_y       ; Yes -> Skip set

	MOV     pgon_min_y,DX           ; No -> Set new top

_pgon_check_max_y:
	CMP     DX,pgon_max_y           ; Y less than bottom coordinate?
	JLE     _pgon_check_y_end       ; Yes -> Skip set

	MOV     pgon_max_y,DX           ; Set new bottom coordinate

_pgon_check_y_end:
	RET


ENDP


; Handle polygon-drawing ----------------------------------

; count - Number of points in polygon
; SI    - Pointer to coordinates
; color - Color of the polygon

PROC draw_polygon
	
	MOV     temp,SI                 ; Save SI
	
	MOV     CL,count                ; Use CL as a counter
	
	PUSH    8000h                   ; Push coordinates to stack

_draw_polygon:
	PUSH    [WORD SI]               ; Push x
	PUSH    [WORD SI+2]             ; Push y
	
	ADD     SI,6                    ; Advance pointer

	DEC     CL                      ; Loop through all points
	JNZ     _draw_polygon

	CALL    polygon                 ; Draw polygon

	MOV     SI,temp                 ; Restore SI
	

	PUSH    8000h                   ; Push shadow's coords to stack

	MOV     color,26                ; Change color

_draw_pgon_shadow:
	PUSH    [WORD SI]               ; Push x
	
	MOV     BX,[SI+4]               ; Get z
	SAR     BX,11                   ; Place of the shadow
	MOV     DX,155
	SUB     DX,BX

	PUSH    DX                      ; Push y
	
	ADD     SI,6                    ; Advance pointer

	DEC     count                   ; Loop through all points
	JNZ     _draw_pgon_shadow

	MOV     temp,SI                 ; Save SI
	
	CALL    polygon                 ; Draw shadow

	MOV     SI,temp                 ; Restore SI
	
	RET

ENDP


; Draw starfield ------------------------------------------

PROC starfield

	MOV     SI,OFFSET starfield_data ; Source offset
	MOV     CX,100                  ; Draw 200 stars
	MOV     ES,virtualscr           ; Draw here
	
_starf_loop:        
	LODSW                           ; Get offset of an star

	MOV     BX,AX

	ADD     [BYTE SI],2             ; Change color

	MOVZX   AX,[SI]                 ; Get color
	SHR     AL,3                    ; Divide it by 8 (0-255 -> 0-31)

	INC     SI                      ; Increase source pointer

	CMP     AL,15                   ; Colors 0-15 can be drawed right away
	JBE     _starf_draw

	MOV     DL,AL                   ; Colors 16-31 need some processing
	MOV     AL,31
	SUB     AL,DL

_starf_draw:
	MOV     [BYTE ES:BX],AL         ; Draw star

	LOOP    _starf_loop             ; Loop through all stars

	MOV     ES,codesegment          ; Restore ES
	
	RET

ENDP


; Draw wormie ---------------------------------------------

PROC draw_wormie

	INC     worm_x1                 ; Wiggle worm
	ADD     worm_x2,2 
	INC     worm_x3
	
	INC     worm_y

	MOV     AL,worm_x1              ; Load worm_?? variables to registers
	MOV     AH,worm_x2
	MOV     BL,worm_x3
	MOV     BH,worm_y
	
	MOV     CL,worm_lenght          ; Init loop-counter
	MOV     count,CL

_dworm_loop:        
	MOVZX   SI,AL                   ; Modify x with first sine
	SHL     SI,1
	MOV     CX,[WORD SI+sincos_table] ; Get SIN(AL)
	
	SAR     CX,8                    ; Wiggle worm
	ADD     AL,2
	
	MOVZX   SI,AH                   ; Modify x with second sine
	SHL     SI,1
	MOV     DI,[WORD SI+sincos_table] ; Get SIN(AH)
	
	SAR     DI,9                    ; Wiggle
	ADD     CX,DI
	ADD     AH,9

	MOVZX   SI,BL                   ; Modify x with 3rd sine
	SHL     SI,1
	MOV     DI,[WORD SI+sincos_table] ; Get SIN(BL)
	
	SAR     DI,9                    ; Wiggle
	ADD     CX,DI
	ADD     BL,3

	MOVZX   SI,BH                   ; Modify y with sine
	SHL     SI,1
	MOV     DX,[WORD SI+sincos_table] ; Get SIN(BH)
	
	SAR     DX,8                    ; Wiggle
	ADD     BH,3

	ADD     CX,center_x             ; Move the worm to the center of the
	ADD     DX,center_y             ; screen
	
	PUSHA                           ; Putsprite destroys regs
	
	CALL    draw_worm_dot           ; Draw one dot
	
	POPA                            ; Restore regs

	DEC     count                   ; Loop through all dots
	JNZ     _dworm_loop

	RET

ENDP


; Draw one dot for the wormie -----------------------------

; CX - X-coordinate
; DX - Y   -"-

PROC draw_worm_dot

	MOV     x1,CX                   ; Save (x,y) for the shadow
	MOV     y1,DX
	
	MOV     BX,3                    ; Draw sprite #3 (dot)
	CALL    putsprite

	MOV     CX,x1                   ; Restore (x,y)
	MOV     DX,y1

	SHR     DX,4                    ; Calculate the place of the shadow
	ADD     DX,155
	
	MOV     BX,2                    ; Draw sprite #2 (shadow)
	CALL    putsprite

	RET

ENDP


; Draw burning text ---------------------------------------

; AL - Color of the text
; DX - Startptr to text

PROC draw_burning_text

	MOV     ES,firestartscr         ; Draw here
	
	MOV     BX,35216                ; Startoffset on screen
	MOV     DI,7                    ; Startcolumn inside font

	MOV     color,AL                ; Save original color

	MOV     CX,timer                ; Randomize
	MOV     temp,CX

_dbt_loop:
	MOV     AL,color                ; Get color
	MOV     AH,AL
	
	MOV     SI,DX                   ; SI=Pointer to char in font
	MOVZX   SI,[SI]
	
	CMP     SI,0                    ; End of the string?
	JE      _dbt_end                ; Oh Yes -> Quit
	
	SHL     SI,4
	ADD     SI,OFFSET vga_font
	
	MOV     CX,15                   ; Loop through 16 rows

_dbt_column_loop:
	BT      [SI],DI                 ; Get one bit from the font
	JNC     _dbt_column_nodraw      ; Bit was 0 -> Don't draw

	MOV     [WORD ES:BX],AX         ; Draw 2 points

_dbt_column_nodraw:
	ADD     BX,320                  ; Increase y-coordinate
	INC     SI                      ; Next row in the font

	LOOP    _dbt_column_loop        ; Loop through all rows

	DEC     DI                      ; Next column in font
	JNS     _dbt_char_not_drawed    ; This char drawed?

	INC     DX                      ; Yes -> Next char
	MOV     DI,7

	MOV     AL,color                ; Get original color
	
	MOV     SI,temp                 ; Calculate random color (+/- 8)
	INC     temp                    ; For the next character
	ADD     SI,900
	MOV     CL,[SI]
	AND     CL,00001111b
	SUB     CL,6
	ADD     color,CL        

	CMP     color,96                ; Check palette limits
	JB      _dbt_char_not_drawed
	
	MOV     color,95

_dbt_char_not_drawed:
	SUB     BX,4798                 ; Next column on screen

	JMP     _dbt_loop               ; Loop

_dbt_end:
	MOV     ES,codesegment          ; Restore ES
	
	RET
		
ENDP


; Light me up ---------------------------------------------

PROC light_me_up

	MOV     ES,virtualscr           ; Init SREGs
	MOV     DS,firestartscr

	MOV     DI,8000                 ; Starting offset

_lmu_loop:
	MOVZX   AX,[DI+320]             ; Add together 4 surrounding points
	ADD     AL,[DI+318]
	MOVZX   BX,[DI+640]
	ADD     BL,[DI+642]
	ADD     AX,BX
	
	SHR     AX,2                    ; Divide sum by 4

	DEC     AL                      ; Fade
	JNS     _lmu_draw

	MOV     AL,0

_lmu_draw:
	MOV     AH,AL                   ; Draw as WORDs

	MOV     [ES:DI],AX              ; Draw
	ADD     DI,2
	
	CMP     DI,40640                ; Done?
	JB      _lmu_loop

	MOV     AX,codesegment          ; Restore SREGs
	MOV     ES,AX
	MOV     DS,AX

	RET

ENDP


; Draw mirror for the fire --------------------------------

PROC draw_mirror

	MOV     AX,virtualscr           ; Init SREGs
	MOV     ES,AX
	MOV     DS,AX

	MOV     SI,8000                 ; Starting offsets
	MOV     DI,56000

_dmirror_loop:
	MOV     CX,160                  ; Row has 160 WORDs

_dmirror_row_loop:
	LODSW                           ; Get color

	SHR     AX,1                    ; Fade color
	AND     AX,1111111101111111b
	
	STOSW                           ; Store shadow

	LOOP    _dmirror_row_loop       ; Loop through this row

	ADD     SI,320                  ; Next row
	SUB     DI,640

	CMP     SI,40640                ; Done?
	JB      _dmirror_loop

	MOV     AX,codesegment          ; Restore SREGs
	MOV     ES,AX
	MOV     DS,AX

	RET

ENDP


; Handle burning text -------------------------------------

PROC handle_fire

	MOV     ES,virtualscr           ; Clear virtualscreen
	XOR     DI,DI
	MOV     AX,DI
	MOV     CX,64010

	REP STOSW

	MOV     ES,firestartscr         ; Clear firestartscreen
	XOR     DI,DI
	MOV     CX,64010

	REP STOSW
	
	CALL    flip_screen             ; Clear VGA memory

	CALL    init_fire_palette       ; Create palette for the fire

	MOV     fade_in_progress,1      ; Fade in
	MOV     fade_source,OFFSET palette

	MOV     timer,0                 ; Reset timer

_hfire_loop:
	INC     timer                   ; Advance timer
	
	CMP     timer,750               ; Time to quit?
	JA      _hfire_quit        

	MOV     DX,OFFSET black_palette ; NULL string offset
	
	CMP     timer,700
	JA      _hfire_draw        

	MOV     DX,OFFSET burning_textstring_2 ; 2nd string offset
	
	CMP     timer,375
	JA      _hfire_draw        

	MOV     DX,OFFSET black_palette ; NULL string offset
	
	CMP     timer,350
	JA      _hfire_draw        

	MOV     DX,OFFSET burning_textstring_1 ; 1st string offset
	
_hfire_draw:        
	ADD     count,12                ; Advance pointer to sinetable
	
	MOVZX   BX,count                ; Get SIN(count)
	SHL     BX,1
	MOV     AX,[WORD BX+sincos_table]

	SAR     AX,10                   ; Calculate color
	ADD     AX,80
	
	CALL    draw_burning_text       ; Draw text

	CALL    vert_retrace            ; Wait for retrace
	
	CALL    light_me_up             ; Create fire
       
	CALL    vert_retrace            ; Wait for retrace (again!)
	
	CALL    fade_palette            ; Fade in (if needed)
	
	CALL    draw_mirror             ; Draw mirror
	
	CALL    flip_screen             ; Show virtualscreen

	MOV     AX,virtualscr           ; Swap virtualscr & firestartscr
	XCHG    AX,firestartscr
	MOV     virtualscr,AX
	
	MOV     AH,1                    ; Check for a key
	INT     16h
	JZ      _hfire_loop             ; No key pressed -> Keep looping

	MOV     AH,0                    ; Get the keypress from buffer
	INT     16h

	MOV     timer,700               ; Quit by cheating the timer
	
	JMP     _hfire_loop             ; Loop
	
_hfire_quit:
	RET

ENDP


; 3D-routines =============================================

; Get sine & cosine for an angle --------------------------

; AL - Angle (0 - 255)

; Returns:

; ECX - SIN(angle)
; EDX - COS(angle)

PROC get_one_sincos

	MOVZX   BX,AL                   ; Get SIN(angle)

	SHL     BX,1                    ; Table contains WORDs

	MOVSX   ECX,[WORD BX+sincos_table] ; Get sine

	MOV     BX,64                   ; Get COS(angle)
	SUB     BL,AL                   ; = SIN(64 - angle)

	SHL     BX,1

	MOVSX   EDX,[WORD BX+sincos_table]

	RET

ENDP


; Get all sines & cosines needed --------------------------

PROC get_sincos
	
	MOV     AL,x_rotation           ; Get sine & cosine of x_rotation

	CALL    get_one_sincos

	MOV     sin_x,ECX
	MOV     cos_x,EDX

	MOV     AL,y_rotation           ; y_rotation

	CALL    get_one_sincos

	MOV     sin_y,ECX
	MOV     cos_y,EDX

	MOV     AL,z_rotation           ; z_rotation

	CALL    get_one_sincos

	MOV     sin_z,ECX
	MOV     cos_z,EDX

	RET

ENDP


; Calculate matrix ----------------------------------------

; x/y/z_rotation - Angles of rotation

PROC calc_matrix

	CALL    get_sincos              ; Get sines & cosines

	MOV     EAX,cos_z               ; cos_z * cos_y
	IMUL    EAX,cos_y
	SAR     EAX,14
	MOV     cosz_cosy,EAX
	
	MOV     EAX,sin_z               ; sin_z * cos_y
	IMUL    EAX,cos_y
	SAR     EAX,14
	MOV     sinz_cosy,EAX
	
	MOV     EAX,sin_z               ; sin_z * cos_x
	IMUL    EAX,cos_x
	SAR     EAX,14
	MOV     sinz_cosx,EAX
	
	MOV     EAX,cos_z               ; cos_z * sin_x
	IMUL    EAX,sin_x
	SAR     EAX,14
	MOV     cosz_sinx,EAX
	
	MOV     EAX,cos_z               ; cos_z * cos_x
	IMUL    EAX,cos_x
	SAR     EAX,14
	MOV     cosz_cosx,EAX
	
	MOV     EAX,sin_z               ; sin_z * sin_x
	IMUL    EAX,sin_x
	SAR     EAX,14
	MOV     sinz_sinx,EAX
	
	MOV     EAX,cos_y               ; cos_y * sin_x
	IMUL    EAX,sin_x
	SAR     EAX,14
	MOV     cosy_sinx,EAX
	
	MOV     EAX,cos_y               ; cos_y * cos_x
	IMUL    EAX,cos_x
	SAR     EAX,14
	MOV     cosy_cosx,EAX
	
	MOV     EAX,cosz_cosy           ; matrix0 = cos_z * cos_y
	MOV     matrix0,EAX

	MOV     EAX,sinz_cosy           ; matrix1 = -sin_z * cos_y
	NEG     EAX
	MOV     matrix1,EAX

	MOV     EAX,sin_y               ; matrix2 = sin_y
	MOV     matrix2,EAX

	MOV     EAX,cosz_sinx           ; matrix3 = sin_z * cos_x +
	IMUL    EAX,sin_y               ;           cos_z * sin_x * sin_y
	SAR     EAX,14
	ADD     EAX,sinz_cosx
	MOV     matrix3,EAX

	MOV     EAX,sinz_sinx           ; matrix4 = cos_z * cos_x -
	IMUL    EAX,sin_y               ;           sin_z * sin_x * sin_y
	SAR     EAX,14
	NEG     EAX
	ADD     EAX,cosz_cosx
	MOV     matrix4,EAX
	
	MOV     EAX,cosy_sinx           ; matrix5 = -cos_y * sin_x
	NEG     EAX
	MOV     matrix5,EAX

	MOV     EAX,cosz_cosx           ; matrix6 = sin_z * sin_x -
	IMUL    EAX,sin_y               ;           cos_z * cos_x * sin_y
	SAR     EAX,14
	NEG     EAX
	ADD     EAX,sinz_sinx
	MOV     matrix6,EAX

	MOV     EAX,sinz_cosx           ; matrix7 = cos_z * sin_x +
	IMUL    EAX,sin_y               ;           sin_z * cos_x * sin_y
	SAR     EAX,14
	ADD     EAX,cosz_sinx
	MOV     matrix7,EAX

	MOV     EAX,cosy_cosx           ; matrix8 = cos_y * cos_x
	MOV     matrix8,EAX

	RET

ENDP


; Rotate one point ----------------------------------------

; Matrix _MUST_ be calculated first using correct x/y/z_rotation values

; SI       - Pointer to 3 BYTEs (x, y, z)
; distance - Distance of the point
; DI       - Pointer to 3 WORDs (rotated x, y, z)

; Returns:

; New coordinates pointed by DI (3 WORDs)

PROC rotate_point

	MOVSX   EBX,[BYTE SI]           ; Move x to EBX
	
	MOVSX   ECX,[BYTE SI+1]         ; Move y to ECX
	
	MOVSX   EDX,[BYTE SI+2]         ; Move z to EDX

	MOV     EAX,EBX                 ; Rotate x-coordinate
	IMUL    EAX,matrix0
	MOV     new_x,EAX

	MOV     EAX,ECX
	IMUL    EAX,matrix1
	ADD     new_x,EAX

	MOV     EAX,EDX
	IMUL    EAX,matrix2
	ADD     new_x,EAX

	MOV     EAX,EBX                 ; Rotate y-coordinate
	IMUL    EAX,matrix3
	MOV     new_y,EAX

	MOV     EAX,ECX
	IMUL    EAX,matrix4
	ADD     new_y,EAX

	MOV     EAX,EDX
	IMUL    EAX,matrix5
	ADD     new_y,EAX

	IMUL    EBX,matrix6             ; Rotate z-coordinate
	MOV     new_z,EBX

	IMUL    ECX,matrix7
	ADD     new_z,ECX

	IMUL    EDX,matrix8
	ADD     new_z,EDX

	MOV     ECX,new_z               ; Calculate perspective
	ADD     ECX,distance
	SAR     ECX,8

	MOV     EDX,new_x               ; X-coordinate
	MOV     AX,DX
	SAR     EDX,16
	IDIV    CX
	ADD     AX,center_x
	STOSW                           ; Store new x
	
	ADD     ECX,3000                ; Stretch object horizontally
	
	MOV     EDX,new_y               ; Y-coordinate
	MOV     AX,DX
	SAR     EDX,16
	IDIV    CX
	ADD     AX,center_y
	STOSW                           ; Store new y

	MOV     EAX,new_z
	SAR     EAX,6
	STOSW                           ; Store new z

	RET

ENDP


; Rotate all points ---------------------------------------

; Matrix _MUST_ be calculated first using correct x/y/z_rotation values

; SI    - Pointer to coordinates
; count - Number of points to rotate

PROC rotate_all

	MOV     DI,OFFSET screen_coords ; Destination offset

_rot_all_loop:
	CALL    rotate_point            ; Rotate one point

	ADD     SI,3                    ; Next point

	DEC     count                   ; All gone?
	JA      _rot_all_loop

	RET

ENDP


; Sort coordinates by distance ----------------------------

; SI - Pointer to coordinates
; CX - Number of coordinates to sort

PROC sort_coords

	MOV     BX,SI                   ; Save starting adress

	DEC     CX                      ; Calculate ending adress
	IMUL    CX,6
	ADD     CX,SI

_sort_begin:
	MOV     AX,[SI+4]               ; Get z-coordinate
	CMP     AX,[SI+10]              ; Compare to next z-coordinate
	JGE     _sort_no_swap           ; Greater already -> no swapping

	MOV     EAX,[SI]                ; Swap x & y
	XCHG    EAX,[SI+6]
	MOV     [SI],EAX
	MOV     AX,[SI+4]               ; Swap z
	XCHG    AX,[SI+10]
	MOV     [SI+4],AX

	MOV     SI,BX                   ; Start from the beginning again
	JMP     _sort_begin             ; Loop

_sort_no_swap:
	ADD     SI,6                    ; Compare next points
	
	CMP     SI,CX                   ; Done?
	JB      _sort_begin

	RET

ENDP


; Morph routines ==========================================

; Morph any array -----------------------------------------

; SI - Offset of the original array
; DI - Offset of the morphed array
; CX - Lenght of the array in BYTEs

; Returns:

; AX - 1=Morph complete

PROC morph

	MOV     AX,1                    ; Assume morph is complete

_morph_loop:
	MOV     BL,[SI]
	CMP     BL,[DI]                 ; Which way to go?
	JG      _morph_inc              ; Increase destination
	JL      _morph_dec              ; Decrease

_morph_loop2:
	INC     SI                      ; Increase pointers
	INC     DI

	LOOP    _morph_loop             ; Done?

	RET                             ; Yep

_morph_inc:
	INC     [BYTE DI]               ; Increase destination
	MOV     AX,0                    ; Morph is not complete
	JMP     _morph_loop2

_morph_dec:
	DEC     [BYTE DI]               ; Decrease destination
	MOV     AX,0
	JMP     _morph_loop2

ENDP


; Morph ball-objects --------------------------------------

PROC morph_balls

	INC     timer                   ; Increase timer

	CMP     timer,400               ; Do we have to morph?
	JB      _morph_balls_end        ; No -> Quit
	
	MOV     SI,morph_source         ; Object to morph to
	MOV     DI,OFFSET ball_objects  ; Current object
	MOV     CX,84
	CALL    morph                   ; Morph object

	CMP     AX,0                    ; Are we through with the morphing?
	JE      _morph_balls_end        ; No -> Quit

	MOV     timer,0                 ; Yep -> Init counter
	ADD     morph_source,84         ; Next object
	
_morph_balls_end:
	RET


ENDP


; Morph from dot to stick ---------------------------------

PROC morph_to_stick

	MOV     SI,OFFSET on_my_way_to_flag

	JMP     morph_fvectors

ENDP


; Morph from stick to flag --------------------------------

PROC morph_to_flag

	MOV     SI,OFFSET flag_of_finland

	JMP     morph_fvectors

ENDP


; Morph from flag to map ----------------------------------

PROC morph_to_map

	MOV     SI,OFFSET map_of_finland

	JMP     morph_fvectors

ENDP


; Morph from map to dot -----------------------------------

PROC morph_to_dot

	MOV     SI,OFFSET vector_end

ENDP


; Morph filled vectors ------------------------------------
	
PROC morph_fvectors
	
	TEST    timer,3                 ; Slow down morphing
	JNZ     _morph_fv_end
	
	MOV     DI,OFFSET vector_start  ; Morph destination
	MOV     CX,93                   ; Lenght of data

	CALL    morph                   ; Morph object

_morph_fv_end:
	JMP     fvectors_back_here

ENDP


; Data ====================================================

DATASEG

; Partial palette

colors:
	DB      17,00,00,26,00,00,35,00,00,44,00,00
	DB      53,00,00,63,00,00,63,32,32,63,51,51
	DB      00,20,00,31,63,31,00,00,15,63,15,15
	DB      27,27,12,39,39,12,52,52,07,63,63,00


; Texts for the dot-scroll

dot_text:

;        DB      "  Welcome to ""Smooth Motion"", an 4Kb-Intro released at ASSEMBLY '95.                    "
;        DB      "Since no credits were allowed, we'd like to quote "
;        DB      "the legendary Mr. J. Morrison:                    "
;        DB      "......show me the way to the next whiskey bar, "
;        DB      "but Oh, don't ask why......                    "
;        DB      "Sorry, running out of space, must loop now......                      "

	
	DB      "  Welcome to ""Smooth Motion"", an 4Kb-Intro released at ASSEMBLY '95.                    "
	DB      "This incredible (!) intro is a PULP production......                   "
	DB      "Credits:                    "
        DB      "** Kimmy - Design, Coding, GFX **                    "
	DB      "** Mr. Pink - GFX, Ideas **                    "
	DB      "** Mr. Purple - GFX **                    "
	DB      "** Dabsa - Hardware **                    "
	DB      "Sorry, running out of space, must loop now......                    "
		 
	DB      0


; Sinus-scroll stuff

sintext_balls:
	DB      "                      WELCOME TO THE ASSEMBLY '95 4Kb-INTRO COMPETITION. "
	DB      "LET'S START WITH SOME VECTORBALLS...... ", 0

sintext_fvectors:
	DB      "                      NEXT: A DEDICATION TO KING MARA...... ", 0
	
sintext_wormie:
	DB      "                      STILL MORE TO COME ???          SURE, A COOL WORMIE...... ", 0
	DB      "                      "

sinus_colors:
	DB      31, 31, 31, 30, 30, 29, 28, 13, 60, 70, 80, 90, 95, 95, 95, 95


; Endmessages

burning_textstring_1:
	DB      7, "THAT'S", 7, "ALL", 7, "FOLKS", 7, 0

burning_textstring_2:
;        DB      7, "HOPE", 7, "YA", 7, "LIKED", 7, "IT", 7, 0

	DB      7, "PULP", 7, 7, "PRODUCTION", 7, 0


	
;        DB      1
end_text:
;        DB      "ддедее╤ Smooth Motion (VOTE US!) геедедд", 10, 10, 13

	DB      "ддедее╤ Smooth Motion by PULP геедедд", 10, 10, 13

end_text_end:


; First quadrant of the sincos-table

partial_sincos:
	DW           0,   402,   804,  1205,  1606,  2006,  2404,  2801
	DW        3196,  3590,  3981,  4370,  4756,  5139,  5520,  5897
	DW        6270,  6639,  7005,  7366,  7723,  8076,  8423,  8765
	DW        9102,  9434,  9760, 10080, 10394, 10702, 11003, 11297
	DW       11585, 11866, 12140, 12406, 12665, 12916, 13160, 13395
	DW       13623, 13842, 14053, 14256, 14449, 14635, 14811, 14978
	DW       15137, 15286, 15426, 15557, 15679, 15791, 15893, 15986
	DW       16069, 16143, 16207, 16261, 16305, 16340, 16364, 16379
	DW       16383


; Vectorball-objects (28 balls each)

ball_objects:

; Circle
	DB      -50, 0, 0, -42,  30, 0, -16,  48, 0,  16,  48, 0,  42,  30, 0
	DB       50, 0, 0,  42, -30, 0,  16, -48, 0, -16, -48, 0, -42, -30, 0
	
	DB      -50, 0, 0, -42,  30, 0, -16,  48, 0,  16,  48, 0,  42,  30, 0
	DB       50, 0, 0,  42, -30, 0,  16, -48, 0, -16, -48, 0, -42, -30, 0
	DB      -50, 0, 0, -42,  30, 0, -16,  48, 0,  16,  48, 0,  42,  30, 0
	DB       50, 0, 0,  42, -30, 0,  16, -48, 0


; Flat
	DB      -50, -50, 0, -25, -50, 0, 0, -50, 0, 25, -50, 0, 50, -50, 0
	DB      -50, -25, 0, -25, -25, 0, 0, -25, 0, 25, -25, 0, 50, -25, 0
	DB      -50,   0, 0, -25,   0, 0,            25,   0, 0, 50,   0, 0
	DB      -50,  25, 0, -25,  25, 0, 0,  25, 0, 25,  25, 0, 50,  25, 0
	DB      -50,  50, 0, -25,  50, 0, 0,  50, 0, 25,  50, 0, 50,  50, 0
	
	DB      -50, -50, 0, -25, -50, 0, 0, -50, 0, 25, -50, 0

; Box
	DB      -40,  40,  40, -15,  40,  40, 15,  40,  40, 40,  40,  40
	DB      -40, -40,  40, -15, -40,  40, 15, -40,  40, 40, -40,  40
	DB      -40,  40, -40, -15,  40, -40, 15,  40, -40, 40,  40, -40
	DB      -40, -40, -40, -15, -40, -40, 15, -40, -40, 40, -40, -40
	DB      -40,  40,  15, -40,  40, -15, 40,  40,  15, 40,  40, -15
	DB      -40, -40,  15, -40, -40, -15, 40, -40,  15, 40, -40, -15
	DB       15,   0,  15, -15,   0,  15, 15,   0, -15, -15,  0, -15
	
; Asm
	DB      -50,  30, 0, -40,  30, 0
	DB      -60,  20, 0, -30,  20, 0,   0,  20, 0,  10,  20, 0, 36,  20, 0, 53,  20, 0
	DB      -60,  10, 0, -30,  10, 0, -12,  10, 0,   0,   5, 0, 30,  10, 0, 45,  10, 0, 60, 10, 0
	DB      -60,   0, 0, -50,   0, 0, -40,   0, 0, -30,   0, 0, 10,  -2, 0, 30,   0, 0, 60,  0, 0
	DB      -60, -10, 0, -30, -10, 0, -10, -10, 0,   0, -10, 0, 30, -10, 0, 60, -10, 0

; 95
	DB      -40,  30, 0, -30,  30, 0,  10, 30, 0, 20, 30, 0, 30, 30, 0, 40, 30, 0
	DB      -50,  20, 0, -20,  20, 0,  10, 20, 0
	DB      -50,  10, 0, -20,  10, 0,  10, 10, 0, 20, 10, 0, 30, 10, 0
	DB      -40,   0, 0, -30,   0, 0, -20,  0, 0, 40,  0, 0
	DB      -20, -10, 0,  40, -10, 0
	DB      -50, -20, 0, -20, -20, 0,  10, -20, 0, 40, -20, 0
	DB      -40, -30, 0, -30, -30, 0,  20, -30, 0, 30, -30, 0


; Vector-objects

on_my_way_to_flag:
	DB      0,   0, 0, 0,   0, 0, 0, -25, 0, 0, -25, 0
	DB      0, -25, 0, 0, -25, 0, 0,   0, 0, 0,   0, 0

	DB      0, 0, 0, 0, 0, 0, 0, 25, 0, 0, 25, 0, 0, 25, 0, 0, 0, 0

	DB      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

	DB      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

	DB      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

	DB      0, -25, 0, 0, 25, 0, 0, 25, 0, 0, -25, 0

flag_of_finland:
	DB       32,   0, 0,  32,   0, 0,  32, -50, 0,  32, -50, 0
	DB      -32, -50, 0, -32, -50, 0, -32,   0, 0, -32,   0, 0
	
	DB      -32,  0, 0, -32,  0, 0, -32, 50, 0
	DB       32, 50, 0,  32, 50, 0,  32,  0, 0

	DB      0, 40, 0, 0, 50, 0, 32, 50, 0, 32, 50, 0, 32, 40, 0

	DB      -32, 40, 0, -32, 50, 0, -5, 50, 0, -5, 40, 0

	DB      -33, -25, 0, -33, -10, 0, 33, -10, 0, 33, -25, 0
	
	DB       -8, -51, 0,  -8,  51, 0,  8,  51, 0,  8, -51, 0

map_of_finland:
	DB       17,   0, 0,  26, -24, 0,  20, -40, 0,  8, -52, 0
	DB      -15, -58, 0, -28, -47, 0, -25, -22, 0, -5,   3, 0

	DB      -5,  3, 0, -11, 16, 0, -12, 44, 0
	DB      10, 42, 0,  15, 30, 0,  17,  0, 0

	DB      -4, 41, 0, 2, 55, 0, 8, 60, 0, 13, 55, 0, 10, 42, 0
	
	DB      -22, 47, 0, -20, 52, 0, -9, 42, 0, -10, 35, 0

	DB       -7, -55, 0, -16, -47, 0, -7, -47, 0,  2, -47, 0
	DB      -10, -48, 0, -10, -30, 0, -4, -30, 0, -4, -48, 0

	
; Sprites (ball, smaller ball, shadow & worm-dot)

sprites:
	DB      004,000,010,000,169,000,047,001,097,001,013,011,003,007,016,017
	DB      017,017,017,017,016,003,000,001,011,016,018,018,019,019,019,019
	DB      019,017,017,016,001,000,001,011,018,019,021,021,021,021,020,020
	DB      019,018,017,001,000,000,013,018,019,021,022,023,022,021,021,020
	DB      019,019,018,017,000,013,018,019,021,023,023,023,021,021,020,020
	DB      019,018,017,000,013,018,019,021,022,023,022,021,021,020,020,019
	DB      018,017,000,013,018,019,020,021,021,021,021,020,020,019,019,018
	DB      017,000,013,018,019,019,020,020,020,020,020,019,019,018,018,017
	DB      001,011,017,019,019,019,019,019,019,018,018,018,017,001,000,001
	DB      011,016,017,017,018,018,018,018,018,017,017,016,001,000,003,007
	DB      016,017,017,017,017,017,016,003,000,012,010,003,006,016,017,017
	DB      017,017,016,003,000,001,010,016,018,018,018,018,018,018,017,017
	DB      016,001,000,001,010,018,019,021,021,021,020,019,018,018,017,001
	DB      000,000,012,016,019,021,021,022,021,021,020,019,018,017,016,000
	DB      012,018,019,021,022,022,022,021,020,019,018,018,017,000,012,018
	DB      019,021,021,022,021,021,020,019,018,018,017,000,012,016,019,019
	DB      021,021,021,020,020,019,018,017,016,001,010,017,018,019,020,020
	DB      019,019,018,018,017,001,000,001,010,016,017,017,018,018,018,018
	DB      017,017,016,001,000,003,006,016,017,017,017,017,016,003,000,011
	DB      004,002,007,026,026,026,026,026,026,026,002,000,000,011,026,026
	DB      026,026,026,026,026,026,026,026,026,000,011,026,026,026,026,026
	DB      026,026,026,026,026,026,002,007,026,026,026,026,026,026,026,002
	DB      000,013,010,004,005,023,023,023,023,023,004,000,002,009,023,023
	DB      022,022,022,022,022,022,021,002,000,001,011,023,022,022,022,027
	DB      027,027,021,021,021,020,001,000,001,011,023,022,027,027,027,027
	DB      027,027,021,021,020,001,000,000,013,023,022,022,027,027,027,027
	DB      027,027,021,020,020,019,000,013,023,022,027,027,027,027,027,027
	DB      021,021,020,019,019,001,011,022,021,021,027,027,021,021,021,020
	DB      020,019,001,000,001,011,022,021,021,021,021,021,020,020,020,019
	DB      019,001,000,002,009,021,020,020,020,020,020,019,019,019,002,000
	DB      004,005,019,019,019,019,019,004,000


; Undefined data ==========================================

UDATASEG

vga_palette:
	DB      288 DUP (?)             ; Space for palettes (96 colors each)

palette:
	DB      288 DUP (?)

black_palette:
	DB      288 DUP (?)

vector_start:
	DB      100 DUP (?)             ; First fvector-object

vector_end:
	DB      100 DUP (?)             ; Last fvector-object

cga_font:
	DB      1024 DUP (?)            ; Space for the CGA 8*8 font

vga_font:
	DB      2048 DUP (?)            ; Space for the VGA 8*14 font

sincos_table:
	DW      256 DUP (?)             ; Space for the full sincos-table

screen_coords:
	DW      100 DUP (?)             ; Space for the screen coordinates

pg_table:
	DW      400 DUP (?)             ; Table for polygon-drawing

starfield_data:
	DB      300 DUP (?)             ; Space for stars

END

   
   That's all folks...

   Elvis lives!
