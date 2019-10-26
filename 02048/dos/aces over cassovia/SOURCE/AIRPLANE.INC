;***************************************************************************;
;* 'AIRPLANE.INC' ASMINC Ped / 7 Gods (C)2000          #ASM compo 2kB game *;
;* - player's airplane class (inherits basic object class)                 *;
;* - launchs shot objects                                                  *;
;* - needs input (up/down/fire/start) (0/FF !)                             *;
;* - collisions are handled of course by special class, not here           *;
;* - a global variable DWORD Temp0 must exists outside                     *;
;* - a global object OBJECT JunkObject must exists outside                 *;
;***************************************************************************;

AIRPLANEFIRCNT EQU     SIZEOFOBJECT+0  ; byte FireCounter (0=may shoot)
AIRPLANETURCNT EQU     SIZEOFOBJECT+1  ; byte TurnCounter (0=may turn)
AIRPLANEFALDIR EQU     SIZEOFOBJECT+2  ; byte FallDir
AIRPLANESCORE  EQU     SIZEOFOBJECT+3  ; byte Score
AIRPLANEKEYUP  EQU     SIZEOFOBJECT+4  ; byte keyUp flag
AIRPLANEKEYDN  EQU     SIZEOFOBJECT+5  ; byte keyDown flag
AIRPLANEKEYFR  EQU     SIZEOFOBJECT+6  ; byte keyFire flag
AIRPLANEKEYST  EQU     SIZEOFOBJECT+7  ; byte keyStart flag
AIRPLANEFALSPD EQU     SIZEOFOBJECT+8  ; float fallspd
AIRPLANEINITX  EQU     SIZEOFOBJECT+12 ; float initX
AIRPLANEINITY  EQU     SIZEOFOBJECT+16 ; float initY
AIRPLANESHOT1  EQU     SIZEOFOBJECT+20 ; shot1 object is hosted here
AIRPLANESHOT2  EQU     SIZEOFOBJECT+20+SIZEOFSHOT  ; shot2 object is hosted here
SIZEOFAIRPLANE EQU     SIZEOFOBJECT+20+(2*SIZEOFSHOT)

; constants
PLN_TURNDELAY  EQU     5
PLN_SHOTDELAY  EQU     20              ; 1/3 of second = delay between shots
PLN_SHOTDUR    EQU     162             ; 2.7 sec will shot exist
PLN_SHOTDURINV EQU     100             ; how long is plane immune to own shot
PLN_DEATHCNT   EQU     80              ; 80 gameticks will took to respawn
PLN_DEATHHIDE  EQU     50              ; after 30 gt will airplane vanish...

; static constants (allocated only once)
PLN_maxspd     DD      +0.00390625     ; maximum speed (2.5 pix in 640 mode)
PLN_spdAccel   DD      +0.000023390718562874   ; maxspd/167 (almost 1.5 sec from 1/2 spd)
PLN_falspdtrig DD      +0.001953125    ; maxspd/2 - this will trigger FALL
PLN_spdBounced:                        ; same as falspdpull
PLN_falspdpull DD      +0.0026041666666; cca. maxspd*(2/3) - this spd must be gain to regain control
;PLN_gravityF   DD      +0.000038112049954598   ; spdAccel*1.629366359659 (1.6... by trial&error ;)
PLN_gravityF   DD      +0.000026112049954598   ; lowered to make the plane more powerfull (gameplay issue)

; functions (for all functions bx = pointer to object)
PLN_constructor:
; eax = (8:8:8:8) = (initdir:junk:gfxnum:gfxflag)
;       gfxnum+[0,..,32] assigned to airplane(0..31), shot1 = shot2 (+32)
; [ecx,edx] = PlaneInitX/Y
; modifies eax
       MOV     WORD PTR [bx+OBJECTREFRESH],OFFSET PLN_refresh
       MOV     [bx+AIRPLANEINITX],ecx
       MOV     [bx+AIRPLANEINITY],edx
       MOV     BYTE PTR [bx+AIRPLANESCORE],0    ; guess what ...
       MOV     DWORD PTR [bx+OBJECTGFXFLAG],eax
       ; init shot1, shot2
;       MOV     al,OBJ_GFXF_DONTDRAWHOLD        ; don't draw holded shot
;       ADD     ah,32           ; gfxnum += 32
       ADD     ax,2000h+(OBJ_GFXF_DONTDRAWHOLD-OBJ_GFXF_32DIR)      ; above two instructions
       ; SHOT1
       PUSH    bx
       ADD     bx,AIRPLANESHOT1
       CALL    SHT_constructor
       ; SHOT2
       ADD     bx,(AIRPLANESHOT2-AIRPLANESHOT1)
       CALL    SHT_constructor
       POP     bx
       ; rest of airplane init
PLN_constructor2:    ; keep gfx things as initialized before
; modifies eax
       FLD     DWORD PTR [bx+AIRPLANEINITX]
       FLD     DWORD PTR [bx+AIRPLANEINITY]
       FLD     DWORD PTR [PLN_maxspd]
       FLD     DWORD PTR [PLN_falspdtrig]
       FSTP    DWORD PTR [bx+AIRPLANEFALSPD]   ; init fallspd to trig value
       FSTP    DWORD PTR [bx+OBJECTSPD]
       FSTP    DWORD PTR [bx+OBJECTY]
       FSTP    DWORD PTR [bx+OBJECTX]
       MOV     eax,00010000h   ; (hold=1, other zeroed)
       MOV     ah,BYTE PTR [bx+OBJECTINITDIR]  ; init direction
       MOV     DWORD PTR [bx+OBJECTCNT],eax    ; set it all
       MOV     WORD PTR [bx+AIRPLANEFIRCNT],0101h      ; ready to shot/turn
       ; fall direction doesn't need to be initialised
;       XOR     eax,eax                         ; clear input state array
;       MOV     DWORD PTR [bx+AIRPLANEKEYUP],eax        ; needed ? prob. not
       RET

PLN_refresh:
; modifies eax, ecx
       CMP     BYTE PTR [bx+OBJECTCNT],0
       JZ      PLN_refresh_NoCnt
       DEC     BYTE PTR [bx+OBJECTCNT]
       JZ      PLN_constructor2        ; if (--cnt == 0) reSpawn();
PLN_refresh_NoCnt:
       CMP     BYTE PTR [bx+OBJECTHOLD],0
       JZ      PLN_refresh_Flying
       CMP     BYTE PTR [bx+AIRPLANEKEYST],0
       JZ      PLN_refresh_Ret         ; wait for take off
       MOV     BYTE PTR [bx+OBJECTHOLD],0      ; take off !
PLN_refresh_Flying:
       CMP     BYTE PTR [bx+OBJECTSHOTDOWN],0
       JNZ     PLN_refresh_DeathFall
       DEC     BYTE PTR [bx+AIRPLANEFIRCNT]
       JNZ     PLN_refresh_Flying_NoFire       ; not ready to shoot
       CMP     BYTE PTR [bx+AIRPLANEKEYFR],0
       MOV     BYTE PTR [bx+AIRPLANEFIRCNT],1  ; ready anytime now
       JZ      PLN_refresh_Flying_NoFire       ; didn't push Fire
       ; FIIIREEEEEEEfire();
       FLD     DWORD PTR [bx+OBJECTY]          ; load all things into regs...
       FLD     DWORD PTR [bx+OBJECTX]
       XOR     eax,eax
       MOV     al,PLN_SHOTDUR
       MOV     ah,BYTE PTR [bx+OBJECTDIR]
       MOV     cl,PLN_SHOTDELAY
       ; search for free shot
       PUSH    bx
       ADD     bx,AIRPLANESHOT1
       CMP     BYTE PTR [bx+OBJECTHOLD],0
       JNZ     PLN_refresh_FoundFreeShot       ; shot1 is in hold state ?
       ADD     bx,(AIRPLANESHOT2-AIRPLANESHOT1)
       CMP     BYTE PTR [bx+OBJECTHOLD],0
       JNZ     PLN_refresh_FoundFreeShot       ; shot2 is in hold state ?
       MOV     bx,OFFSET JunkObject            ; no shot available, don't fire
       MOV     cl,1
PLN_refresh_FoundFreeShot:                     ; init shot
       FSTP    DWORD PTR [bx+OBJECTX]
       FSTP    DWORD PTR [bx+OBJECTY]
       MOV     DWORD PTR [bx+OBJECTCNT],eax    ; set up ShotDwn:Hold:Dir:Cnt
       POP     bx                              ; restore airplane pointer
       MOV     BYTE PTR [bx+AIRPLANEFIRCNT],cl ; new shot delay
PLN_refresh_Flying_NoFire:
       DEC     BYTE PTR [bx+AIRPLANETURCNT]
       JNZ     PLN_refresh_Flying2     ; not ready to turn
       MOV     ax,WORD PTR [bx+AIRPLANEKEYUP]
       MOV     BYTE PTR [bx+AIRPLANETURCNT],1  ; ready anytime
       CMP     ax,0
       JZ      PLN_refresh_Flying2     ; didn't push up/down
       MOV     BYTE PTR [bx+AIRPLANETURCNT],PLN_TURNDELAY
       ADD     BYTE PTR [bx+OBJECTDIR],al      ; up key turn anticlockwise
       SUB     BYTE PTR [bx+OBJECTDIR],ah      ; down key turn clockwise
       AND     BYTE PTR [bx+OBJECTDIR],31      ; update direction
       ; player1 (left and green) has up key as up, and down as down
       ; player2 is flying in reverse pattern, so the keys are reversed too!
       JMP     PLN_refresh_Flying2
PLN_refresh_DeathFall:         ; fall in any case, when shot down
       FLD     DWORD PTR [PLN_maxspd]
       FSTP    DWORD PTR [bx+AIRPLANEFALSPD]   ; fallspd = maxspd
       MOV     BYTE PTR [bx+AIRPLANEFALDIR],40 ; couldn't regain speed
PLN_refresh_Flying2:
       MOV     eax,DWORD PTR [bx+AIRPLANEFALSPD]
       CMP     eax,DWORD PTR [bx+OBJECTSPD]    ; fallspd < spd ?
       JGE     PLN_refresh_Falling
       CALL    OBJ_updatePos   ; pos += spd*dir;
       ; fallspd-converge->smaller; (getting kinetic energy .. ;)))
       FLD     DWORD PTR [bx+AIRPLANEFALSPD]
       FSUB    [PLN_spdAccel]
       FSTP    DWORD PTR [Temp0]
       MOV     eax,DWORD PTR [Temp0]
       CMP     eax,[PLN_falspdtrig]
       JG      PLN_refresh_ConvergeFallSpd
       MOV     eax,[PLN_falspdtrig]    ; falspdtrig reachhed
PLN_refresh_ConvergeFallSpd:
       MOV     DWORD PTR [bx+AIRPLANEFALSPD],eax
       CMP     BYTE PTR [bx+OBJECTDIR],17
       JNC     PLN_refresh_FlyingUp
       ; heading down (or horizontaly), accelerate to maxspd
       FLD     DWORD PTR [bx+OBJECTSPD]
       FADD    [PLN_spdAccel]          ; spd += spd_accel
       FSTP    DWORD PTR [Temp0]
       MOV     eax,DWORD PTR [Temp0]
       CMP     eax,[PLN_maxspd]
       JL      PLN_refresh_Accelerate
       MOV     eax,[PLN_maxspd]
PLN_refresh_Accelerate:
       MOV     DWORD PTR [bx+OBJECTSPD],eax
       JMP     PLN_refresh_clampYCoor
PLN_refresh_FlyingUp:
       CMP     BYTE PTR [bx+OBJECTY+3],0
       JG      PLN_refresh_doNotBounce
       ; y <= 0.0 => bounce airplane from top of screen
       MOV     DWORD PTR [bx+OBJECTY],0        ; y = 0.0;
       MOV     DWORD PTR [bx+OBJECTLASTDY],0   ; last dy = 0.0;
       FLD     DWORD PTR [PLN_falspdpull]
       FST     DWORD PTR [bx+AIRPLANEFALSPD]   ; falspd = pullspd
       FSTP    DWORD PTR [bx+OBJECTSPD]        ; spd = pullspd too
PLN_refresh_doNotBounce:
       MOVZX   ax,BYTE PTR [bx+OBJECTDIR]
       MOV     WORD PTR [Temp0],ax
       FILD    WORD PTR [Temp0]
       FMUL    DWORD PTR [OBJ_dirtorad]
       FSIN
       FMUL    DWORD PTR [PLN_gravityF]
       FADD    DWORD PTR [bx+OBJECTSPD]
       FSTP    DWORD PTR [bx+OBJECTSPD]        ; spd -= how_much_up*gravityF
       MOV     eax,DWORD PTR [bx+AIRPLANEFALSPD]
       CMP     eax,DWORD PTR [bx+OBJECTSPD]    ; fallspd >= spd ?
       JL      PLN_refresh_clampYCoor
       FLD     DWORD PTR [PLN_falspdpull]
       FSTP    DWORD PTR [bx+AIRPLANEFALSPD]   ; falspd = pullspd
       MOV     al,32
       SUB     al,BYTE PTR [bx+OBJECTDIR]
       MOV     BYTE PTR [bx+AIRPLANEFALDIR],al ; calculate falldir
       JMP     PLN_refresh_clampYCoor
PLN_refresh_Falling:
       ; converge lastdeltay to fallspd_deltay
       MOVZX   ax,BYTE PTR [bx+AIRPLANEFALDIR]
       MOV     WORD PTR [Temp0],ax
       FILD    WORD PTR [Temp0]
       FMUL    DWORD PTR [OBJ_dirtorad]
       FSIN
       FMUL    DWORD PTR [bx+AIRPLANEFALSPD]
       FSTP    DWORD PTR [Temp0]       ; [Temp0] = deltaY for "fallspeed"
       MOV     eax,DWORD PTR [Temp0]
       FLD     DWORD PTR [bx+OBJECTLASTDY]
       FADD    DWORD PTR [PLN_spdAccel]
       FSTP    DWORD PTR [Temp0]
       CMP     eax,[Temp0]             ; fallspd_deltaY > updated_deltaY
       JG      PLN_refresh_KeepUpdatedDelta
       MOV     DWORD PTR [Temp0],eax   ; fallspd_deltaY reached
PLN_refresh_KeepUpdatedDelta:
       ; pos += lastdeltax/y;
       FLD     DWORD PTR [Temp0]
       FST     DWORD PTR [bx+OBJECTLASTDY]
       FADD    DWORD PTR [bx+OBJECTY]
       FSTP    DWORD PTR [bx+OBJECTY]
       FLD     DWORD PTR [bx+OBJECTLASTDX]
       FADD    DWORD PTR [bx+OBJECTX]
       FSTP    DWORD PTR [bx+OBJECTX]
       CALL    OBJ_wrap
       MOV     al,BYTE PTR [bx+OBJECTDIR]
       DEC     ax
       CMP     al,BYTE PTR [bx+AIRPLANEFALDIR] ; ?= falldir +1
       JZ      PLN_refresh_Accel
       INC     ax
       CMP     al,BYTE PTR [bx+AIRPLANEFALDIR] ; ?= falldir
       JZ      PLN_refresh_Accel
       INC     ax
       CMP     al,BYTE PTR [bx+AIRPLANEFALDIR] ; ?= falldir -1
       JNZ     PLN_refresh_clampYCoor          ; if ( dir != falldir )
PLN_refresh_Accel:
       FLD     DWORD PTR [bx+OBJECTSPD]
       FADD    DWORD PTR [PLN_spdAccel]
       FSTP    DWORD PTR [bx+OBJECTSPD]        ; spd += spd_accel
PLN_refresh_clampYCoor:
       CMP     DWORD PTR [bx+OBJECTY],OBJ_FLOAT1
       JL      PLN_refresh_Ret         ; if ( pos.y > 1.0 ) pos.y = 1.0;
       MOV     DWORD PTR [bx+OBJECTY],OBJ_FLOAT1
PLN_refresh_Ret:
       RET
