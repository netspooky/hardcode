;***************************************************************************;
;* 'COLLIS  .INC' ASMINC Ped / 7 Gods (C)2000          #ASM compo 2kB game *;
;* - collision detection class                                             *;
;* - this class does not need to have an instance (fake class ;))          *;
;***************************************************************************;

SIZEOFCOLLIS   EQU     0               ; seed in static, so no variables

; constants

; static constants (allocated only once)

; functions
; no constructor ... for what ?

COL_doit:
       MOV     bx,OFFSET Player1               ; test this
       MOV     bp,OFFSET Player2               ; add score here
       ; tests for suicides and opponent hit
       CALL    COL_test1
       XCHG    bx,bp
       CALL    COL_test1
       ; balloon test
       MOV     bx,OFFSET Balloon               ; test Balloon against Pl1 shots
       CALL    COL_killballoonttest
       MOV     bp,OFFSET Player2
       CALL    COL_killballoonttest            ; test Balloon against Pl2 shots
       RET

COL_test:
       ; test "bx" sprite with "di" sprite, in case of collision do COL_killme
;       CMP     BYTE PTR [bx+OBJECTSHOTDOWN],0
;       JNZ     COL_test_ret    ; already dead
;       CMP     BYTE PTR [bx+OBJECTHOLD],0
;       JNZ     COL_test_ret    ; holded object is inactive
       CMP     WORD PTR [bx+OBJECTHOLD],0      ; target
       JNZ     COL_test_ret    ; shotdown & hold test in one.
       CMP     WORD PTR [di+OBJECTHOLD],0      ; danger
       JNZ     COL_test_ret    ; shotdown & hold test in one.
       ; WARNING: "above" and "under" do refer to screen orientation (i.e. reversed to number sort)
       ; y coordinates boundary box test + some calculations
       MOV     ax,WORD PTR [di+OBJECTSCRY1]
       MOV     dx,WORD PTR [di+OBJECTSCRY1]
       CMP     ax,WORD PTR [bx+OBJECTSCRY2]    ; CMP Danger.y1,Target.y2
       JGE     COL_test_ret                    ; Danger is under Target
       SUB     ax,WORD PTR [bx+OBJECTSCRY1]    ; ax = Danger.y1-Target.y1
       JGE     COL_test_Yareaoverlapping
COL_test_DangY1AboveTargY1:
       INC     dx
       CMP     dx,WORD PTR [di+OBJECTSCRY2]
       JGE     COL_test_ret                    ; Danger is above target
       INC     ax
       JS      COL_test_DangY1AboveTargY1
COL_test_Yareaoverlapping:
       MOV     cx,WORD PTR [bx+OBJECTSCRX2]
       SUB     cx,WORD PTR [bx+OBJECTSCRX1]    ; GfxSizeX of Target
       MUL     cl                              ; y_offset*GfxSizeX = line address
       ADD     ax,WORD PTR [bx+OBJECTSCRGFX]   ; ax = gfx ptr + y_offset*GfxSizeX, dx = y in Danger
       MOV     WORD PTR [Temp0],cx             ; store GfxSizeX
       ; x coordinates boundary box test + final calculations
       MOV     si,WORD PTR [di+OBJECTSCRX1]
       MOV     cx,WORD PTR [di+OBJECTSCRX1]
       CMP     si,WORD PTR [bx+OBJECTSCRX2]
       JGE     COL_test_ret                    ; Danger is right from Target
       SUB     si,WORD PTR [bx+OBJECTSCRX1]
       JGE     COL_test_Xareaoverlapping
COL_test_DangX1LeftFromTargX1:
       INC     cx
       CMP     cx,WORD PTR [di+OBJECTSCRX2]
       JGE     COL_test_ret                    ; Danger is left from target
       INC     si
       JS      COL_test_DangX1LeftFromTargX1
COL_test_Xareaoverlapping:
       ADD     si,ax                           ; final address
       MOV     es,WORD PTR ScreenObj[SCREENSPRSEG]     ; es:si
       ; cx = Danger.x, dx = Danger.y, [Temp0] = GfxSizeX
COL_test_PixelTest_lines:
       PUSHA
COL_test_PixelTest_line:
       CMP     BYTE PTR es:[si],0              ; is there solid pixel ?
       JNZ     COL_gotcollision
       INC     si
       INC     cx
       CMP     cx,WORD PTR [bx+OBJECTSCRX2]
       JGE     COL_test_nomorepixels           ; hit right end of Target
       CMP     cx,WORD PTR [di+OBJECTSCRX2]
       JL      COL_test_PixelTest_line
COL_test_nomorepixels:
       POPA
       ADD     si,WORD PTR [Temp0]
       INC     dx
       CMP     dx,WORD PTR [bx+OBJECTSCRY2]
       JGE     COL_test_ret                    ; hit lower end of Target
       CMP     dx,WORD PTR [di+OBJECTSCRY2]
       JL      COL_test_PixelTest_lines
COL_test_ret:
       RET

COL_gotcollision:
       POPA                    ; got collision, die & add score
COL_killme:
       ; kill "bx" sprite, add score to "bp" sprite
       BTS     WORD PTR [bx+OBJECTSHOTDOWN],0
       JC      COL_test_ret    ; already dead
       MOV     BYTE PTR [bx+OBJECTCNT],PLN_DEATHCNT
       INC     BYTE PTR [bp+AIRPLANESCORE]
;       RET                     ; may run trough rest...

COL_test1:
       ; ground hit test
       CMP     DWORD PTR [bx+OBJECTY],OBJ_FLOAT1
       JGE     COL_killme
       ; test with Balloon Tower
       MOV     di,OFFSET BalTower
       CALL    COL_test
       ; test with own shots
       LEA     di,[bx+AIRPLANESHOT1]
       CMP     BYTE PTR [di+OBJECTCNT],PLN_SHOTDURINV
       JNC     COL_test1_ThisOneIsTooYoung1
       CALL    COL_test
COL_test1_ThisOneIsTooYoung1:
       LEA     di,[bx+AIRPLANESHOT2]
       CMP     BYTE PTR [di+OBJECTCNT],PLN_SHOTDURINV
       JNC     COL_test1_ThisOneIsTooYoung2
       CALL    COL_test
COL_test1_ThisOneIsTooYoung2:
       ; test with the opponents shots
COL_killballoonttest:
       LEA     di,[bp+AIRPLANESHOT1]
       CALL    COL_test
       LEA     di,[bp+AIRPLANESHOT2]
       CALL    COL_test
       RET
