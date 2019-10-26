;***************************************************************************;
;* 'AOC     .ASM' ASMCOD Ped / 7 Gods (C)2000          #ASM compo 2kB game *;
;* ACES OVER CASSOVIA - 2kB game for #ASM compo - sources, see AOC.TXT for *;
;* more information about game and license condition for this game         *;
;* - I tried to do sort of OOP coding, because the size didn't really      *;
;*   matter. (2kB is quite enough for such simple game)                    *;
;*   (well, lately I discovered, that 2kB is really not THAT much, damn)   *;
;*   So maybe the sources will be at least a bit understandable ... :)))   *;
;* - due to size restriction I was forced to remove baloon's sandbag feat. *;
;*   so don't care, if you find any reference to it in sources ...         *;
;*   any numbering like BallonTower gfnum = 2 does mean 1 instead, so on.. *;
;* - build with: (TASM 3.2, TLINK 5.1, APACK 0.96b used)                   *;
;* tasm /m9 /q /w2 /la /x aoc.asm                                          *;
;* tlink /t /x aoc.obj                                                     *;
;* apack -vf aoc.com aoc.com                                               *;
;* and than I patched it by hand to have 'PED' at the beginning of file ;) *;
;* BTW: TASM versions above 3.2 ARE bugged, realmode versions A LOT, pmode *;
;* version 5.0 looks very stable, but has some bugs TOO! (own experience)  *;
;***************************************************************************;

       page    255,132
SALC   EQU     DB      0d6h

code   SEGMENT use16
       ASSUME  cs:code,ds:code,es:code
       ORG     100h
       .386
       .387

;__DEBUG        EQU     1
;__SANDBAG      EQU     1       ; this will compile the game with sandbag
               ; feature, wich is incomplete (no collision detection)

start:
       JMP     trueStart

INCLUDE CONFIG.INC             ; some init constants
INCLUDE RANDOM.INC             ; random numbers generator
INCLUDE SCREEN.INC             ; screen output related stuff
                               ; also has impact at collision detection
INCLUDE KEYBOARD.INC           ; keyboard handler
;INCLUDE TIMER.INC              ; timer handler - not used, timing is done
; with "WaitForRetrace()" (i.e. 120Hz screen refresh will cause the game
; to run 2 times faster :))) but who cares ? ;))
INCLUDE SCORING.INC            ; scoring class
INCLUDE TEXTOUT.INC            ; text output class (for scoring) (gfx too)
   ; due to size restriction a "bar" type scoring is used
INCLUDE OBJECT.INC             ; basic object routines (Balloon tower)
INCLUDE SHOT.INC               ; shot routines
IFDEF __SANDBAG
INCLUDE SANDBAG.INC            ; sandbag ... (done, but didn't fit into 2kB)
ENDIF
INCLUDE BALLOON.INC            ; balloon
INCLUDE AIRPLANE.INC           ; player's airplane
;INCLUDE BADABOOM.INC           ; explosions class (didn't fit into 2kB)
;INCLUDE CLOUDS.INC             ; clouds (for hiding airplane ;) didn't fit)
INCLUDE PL_INPUT.INC           ; copy key status from keyboard to airplane
INCLUDE BACKGRND.INC           ; background gfx generator
INCLUDE GFXBALL.INC            ; balloon & sandbag & launch tower gfx
INCLUDE GFXPLANE.INC           ; airplane & shot gfx
;INCLUDE GFXCLOUD.INC           ; clouds gfx
INCLUDE COLLIS.INC             ; collision detection class
                               ; works with almost all previous objects

trueStart:
       FNINIT
       ; init screen mode and gfx stuff
       PUSH    cs
       POP     ax
       ADD     ah,10h           ; next 64k segment for background storage (16k)
       MOV     dx,ax
       ADD     ah,04h           ; next 16k for sprite graphics (64+16+16=96k)
       MOV     bx,OFFSET ScreenObj
       CALL    SCR_constructor
       ; generate gfx - prepares gfx info and then calls gfx generators
       ; bx = ScreenObj (!)
       CALL    GFXBAL_gen       ; 0 = balloon, 1 = sandbag, 2 = baltower
       CALL    GFXPLN_gen       ; 3..34 = Pl1, 35 = Shot1, 36..67 = Pl2, 68 = Shot2
       ; initialize TextOut object
       MOV     bx,OFFSET TextOutObj
       TXTOUT_constructor_macro
       ; later maybe badabooms and clouds will be added (if enough free bytes...)
       ; draw background
       BACKGRND_gen_macro
       ; init keyboard handler
       MOV     bx,OFFSET KeyboardObj
       CALL    KBD_constructor
       ; restart game will cause these objects to reinit... (why not? :)
RestartGame:
       ; Player1 init
       MOV     bx,OFFSET Player1
IFDEF __SANDBAG
       MOV     eax,00030300h+OBJ_GFXF_32DIR
ELSE
       MOV     eax,00020200h+OBJ_GFXF_32DIR
ENDIF
       MOV     ecx,PLN1_INITX
       MOV     edx,PLN1_INITY
       CALL    PLN_constructor
       ; Player2 init
       MOV     bx,OFFSET Player2
IFDEF __SANDBAG
       MOV     eax,10062400h+OBJ_GFXF_32DIR    ; dir = 16 ! (left)
ELSE
       MOV     eax,10052300h+OBJ_GFXF_32DIR    ; dir = 16 ! (left)
ENDIF
       MOV     ecx,PLN2_INITX
       MOV     edx,PLN2_INITY
       CALL    PLN_constructor
       ; Balloon init
       MOV     bx,OFFSET Balloon
       XOR     eax,eax
       XOR     ecx,ecx
       CALL    BAL_constructor
       ; Balloon tower init
       MOV     bx,OFFSET BalTower
       MOV     DWORD PTR [bx+OBJECTCNT],0      ; alive object for coll. detect
;       MOV     WORD PTR [bx+OBJECTREFRESH],OFFSET OBJ_refresh
IFDEF __SANDBAG
       MOV     DWORD PTR [bx+OBJECTGFXFLAG],020200h
ELSE
       MOV     DWORD PTR [bx+OBJECTGFXFLAG],010100h
ENDIF
       MOV     DWORD PTR [bx+OBJECTX],BLT_INITX
       MOV     DWORD PTR [bx+OBJECTY],BLT_INITY
       ; scoring object init
       MOV     bx,OFFSET ScoringObj
       SCO_constructor_macro
       ; main game loop
MainGameLoop:
       ; update airplanes input fields
       CALL    INP_refresh
MainGameLoop_noInput:
       ; refresh all
       MOV     si,OFFSET ObjPtrsFresh
       MOV     cx,OBJTOREFRESH
MainGameLoop_RefreshAll:
       LODSW
       XCHG    ax,bx
       PUSHA
       CALL    WORD PTR [bx]   ; call virtual refresh function ...
       POPA
       LOOP    MainGameLoop_RefreshAll
       ; redraw all
       MOV     si,OFFSET ObjPtrsDraw
       MOV     cx,OBJTODRAW
MainGameLoop_DrawAll:
       LODSW
       XCHG    ax,bx
       PUSHA
       CALL    OBJ_draw
       POPA
       LOOP    MainGameLoop_DrawAll
       ; collision detection + scoring
       CALL    COL_doit
       ; scoring (checks, if some player didn't got 15 points)
       SCO_refresh_macro
IFDEF __DEBUG
       ; "~" test to hold game
MainGameLoop_WaitDebugKey:
       CMP     BYTE PTR KeyboardObj[KEYBOARDFLAGS+41],0
       JNZ     MainGameLoop_WaitDebugKey
ENDIF ; __DEBUG
       ; Esc test
       CMP     BYTE PTR KeyboardObj[KEYBOARDFLAGS+SC_ESC],0
       JNZ     GameExit
       ; test, if game is on
       CMP     BYTE PTR ScoringObj[SCORINGGAMEF],0
       JZ      MainGameLoop
       ; game is over, clear inputs, and wait some minimal pause...
       ; (while game is still refreshing, so player may still die/kill !)
       MOV     DWORD PTR Player1[AIRPLANEKEYUP],0
       MOV     DWORD PTR Player2[AIRPLANEKEYUP],0
       DEC     BYTE PTR ScoringObj[SCORINGGAMECNT]
       JNZ     MainGameLoop_noInput
       ; wait now until space or some "take off" button is pressed -> restart
MainGameLoop_RestartButtonTest:
       CMP     BYTE PTR KeyboardObj[KEYBOARDFLAGS+PLN1_ST],0
       JNZ     RestartGame
       CMP     BYTE PTR KeyboardObj[KEYBOARDFLAGS+PLN2_ST],0
       JNZ     RestartGame
       CMP     BYTE PTR KeyboardObj[KEYBOARDFLAGS+SC_ESC],0
       JZ      MainGameLoop_RestartButtonTest
GameExit:
       ; deinit keyboard handler
       MOV     bx,OFFSET KeyboardObj
       CALL    KBD_destructor
       ; restore text mode
       CALL    SCR_destructor  ; doesn't need bx
       RET

ALIGN 4
; object pointers (in the draw & refresh order)
IFDEF __SANDBAG
OBJTOREFRESH   EQU     10
OBJTODRAW      EQU     9
ELSE
OBJTOREFRESH   EQU     9
OBJTODRAW      EQU     8
ENDIF
ObjPtrsFresh   DW      OFFSET ScreenObj        ; refresh will remove sprites!
               DW      OFFSET TextOutObj       ; draw score (in REFRESH!!!)
ObjPtrsDraw    DW      OFFSET Player2 + AIRPLANESHOT2   ; Pl2_shot2
               DW      OFFSET Player1 + AIRPLANESHOT2   ; Pl1_shot2
               DW      OFFSET Player2 + AIRPLANESHOT1   ; Pl2_shot1
               DW      OFFSET Player1 + AIRPLANESHOT1   ; Pl1_shot1
               DW      OFFSET Balloon
IFDEF __SANDBAG
               DW      OFFSET Balloon + BALLOONBAG      ; balloon's sandbag
ENDIF
               DW      OFFSET Player1
               DW      OFFSET Player2
               ; only draw these
               DW      OFFSET BalTower

; temporary memory buffers
Temp0          DD      ?
Temp1          DD      ?
JunkObject     DB      SIZEOFOBJECT DUP (?)
; game objects instances
KeyboardObj    DB      SIZEOFKEYBOARD DUP (?)
ScreenObj      DB      SIZEOFSCREEN DUP (?)
TextOutObj     DB      SIZEOFTEXTOUT DUP (?)
Player1        DB      SIZEOFAIRPLANE DUP (?)
Player2        DB      SIZEOFAIRPLANE DUP (?)
Balloon        DB      SIZEOFBALLOON DUP (?)
BalTower       DB      SIZEOFOBJECT DUP (?)
ScoringObj     DB      SIZEOFSCORING DUP (?)

code   ENDS
       END start
