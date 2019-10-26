;***************************************************************************;
;* 'BALLOON .INC' ASMINC Ped / 7 Gods (C)2000          #ASM compo 2kB game *;
;* - balloon class (inherits basic object class)                           *;
;* - launchs sandbag object (__SANDBAG must be defined to compile bag)     *;
;***************************************************************************;

BALLOONCNT2    EQU     SIZEOFOBJECT+0  ; WORD cnt2
IFDEF __SANDBAG
BALLOONCNT3    EQU     SIZEOFOBJECT+2  ; BYTE cnt3 + alignment byte
BALLOONBAG     EQU     SIZEOFOBJECT+4  ; SANDBAG bag object hosted here
SIZEOFBALLOON  EQU     SIZEOFOBJECT+SIZEOFSANDBAG+4
ELSE
SIZEOFBALLOON  EQU     SIZEOFOBJECT+4
ENDIF

; constants
;BAL_SPD        EQU     3B000000h       ; +0.0005208333125 = BAL_goUpSpd/2
BAL_SPD        EQU     3A0E8888h       ; +0.0005208333125 = BAL_goUpSpd/2
; BAL_deathcnt is identical with airplane's ...
BAL_MINDIRCHG  EQU     6               ; 0.1 sec will keep direction (min)
BAL_MAXDIRCHG  EQU     3*60-BAL_MINDIRCHG      ; to 5 sec (max)
IFDEF __SANDBAG
BAL_SANDBAGCNT EQU     2*60            ; every 2 sec will launch sandbag
                                       ; if going up rapidly
BAL_SANDBAGINI EQU     20              ; init value = 0.33 sec
ENDIF

; static constants (allocated only once)
BAL_goUpSpd    DD      -0.00208333325  ; PosYInit/400 (6.66 sec)
IFDEF __SANDBAG
BAL_bagOfsY    DD      +0.03125
ENDIF

; functions (for all functions bx = pointer to object)
BAL_constructor:
; ax = (8:8) = (gfxnum:gfxflag), ecx = 0:junk (16:16)
;       gfxnum+1 will be assigned to this balloon's sandbag !
; modifies eax, ecx
       MOV     WORD PTR [bx+OBJECTREFRESH],OFFSET BAL_refresh
       MOV     WORD PTR [bx+OBJECTGFXFLAG],ax
IFDEF __SANDBAG
       ; call sandbag constructor
       ADD     ax,0100h+OBJ_GFXF_DONTDRAWHOLD
       PUSH    bx
       ADD     bx,BALLOONBAG
       CALL    BAG_constructor
       POP     bx
ENDIF
BAL_constructor2:    ; keep gfx things as initialized before
       MOV     DWORD PTR [bx+OBJECTX],BAL_POSXINIT
       MOV     DWORD PTR [bx+OBJECTY],BAL_POSYINIT
       MOV     DWORD PTR [bx+OBJECTSPD],BAL_SPD
       MOV     DWORD PTR [bx+OBJECTCNT],00010000h      ; (hold=1, other zeroed)
       MOV     cx,BAL_MAXTOSTART
       CALL    RND_rand
       ADD     ax,BAL_MINTOSTART
       MOV     WORD PTR [bx+BALLOONCNT2],ax    ; when it will start
IFDEF __SANDBAG
       MOV     BYTE PTR [bx+BALLOONCNT3],BAL_SANDBAGINI
ENDIF
       RET

BAL_refresh:                   ; ecx = 0:junk (16:16)
; modifies eax, ecx
       CMP     BYTE PTR [bx+OBJECTCNT],0
       JZ      BAL_refresh_NoCnt
       DEC     BYTE PTR [bx+OBJECTCNT]
       JZ      BAL_constructor2        ; if (cnt == 0) reinit;
BAL_refresh_NoCnt:
       CMP     BYTE PTR [bx+OBJECTHOLD],0
       JZ      BAL_refresh_Flying
       DEC     WORD PTR [bx+BALLOONCNT2]
       JNZ     BAL_refresh_Ret         ; wait for take off
       MOV     BYTE PTR [bx+OBJECTHOLD],0      ; take off !
       MOV     BYTE PTR [bx+BALLOONCNT2],1
BAL_refresh_Flying:
       DEC     WORD PTR [bx+BALLOONCNT2]
       JNZ     BAL_refresh_KeepDirection
       MOV     cx,32
       CALL    RND_rand
       MOV     BYTE PTR [bx+OBJECTDIR],al      ; random direction
       MOV     cx,BAL_MAXDIRCHG
       CALL    RND_rand
       ADD     ax,BAL_MINDIRCHG
       MOV     WORD PTR [bx+BALLOONCNT2],ax    ; random duration of dir
BAL_refresh_KeepDirection:
       CALL    OBJ_updatePos   ; pos += spd*dir;
       FLD     DWORD PTR [bx+OBJECTY]
       FADD    DWORD PTR [BAL_goUpSpd]
       FSTP    DWORD PTR [bx+OBJECTY]          ; pos.y += go_up_speed
       CMP     BYTE PTR [bx+OBJECTY+3],0
       JL      BAL_constructor2        ; if (pos.y < 0) reinit;
IFDEF __SANDBAG
       CMP     BYTE PTR [bx+OBJECTSHOTDOWN],0
       JNZ     BAL_refresh_Ret                 ; don't drop sandbags after death
       CMP     BYTE PTR [bx+OBJECTDIR],17
       JC      BAL_refresh_Ret                 ; dir points down, not up
       DEC     BYTE PTR [bx+BALLOONCNT3]
       JNZ     BAL_refresh_Ret                 ; not ready to drop sandbag
       MOV     BYTE PTR [bx+BALLOONCNT3],BAL_SANDBAGCNT        ; init cnt3
       ; calculate x/y coord. for sand bag
       FLD     DWORD PTR [bx+OBJECTX]
       FLD     DWORD PTR [bx+OBJECTY]
       FADD    DWORD PTR [BAL_bagOfsY]
       ; init sandbag
       MOV     BYTE PTR [bx+BALLOONBAG+OBJECTHOLD],0   ; wake up bag!
       FSTP    DWORD PTR [bx+BALLOONBAG+OBJECTY]
       FSTP    DWORD PTR [bx+BALLOONBAG+OBJECTX]
ENDIF
BAL_refresh_Ret:
       RET
