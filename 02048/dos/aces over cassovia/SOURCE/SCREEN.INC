;***************************************************************************;
;* 'SCREEN  .INC' ASMINC Ped / 7 Gods (C)2000          #ASM compo 2kB game *;
;* - screen class                                                          *;
;***************************************************************************;

; numbers of graphic, as they are assigned to
; objects during initialisation in main assembler module.
;             gfnum
; balloon:    0
; sandbag:    1
; baltower:   2
; player1:    3..34     - 32direction gfx
; pl1_shot1:  35
; pl1_shot2:  35
; player2:    36..67    - 32direction gfx
; pl1_shot1:  68
; pl1_shot2:  68
; maybe clouds and badabooms will be added

; graphics (background & sprite) struct
SCREENGF_OFS   EQU     0       ; offset (sprite gfx || where at screen)
SCREENGF_SIZE  EQU     2       ; size in bytes
SCREENGF_SIZEX EQU     4       ; word SizeX
SCREENGF_SIZEY EQU     6       ; word SizeY
SIZEOFSCREENGF EQU     8       ; must be 8 !

; screen class
SCREENREFRESH  EQU     0       ; refresh function pointer
SCREENBGOFS    EQU     2       ; offset of next background to store
SCREENBGSEG    EQU     4       ; segment for backgrounds to store in
SCREENNUMOFBG  EQU     6       ; word number of background to restore
SCREENSPRSEG   EQU     8       ; segment of sprite graphics
SCREENSPROFS   EQU     10      ; offset for next sprite to create
SCREENNUMOFSPR EQU     12      ; word number of sprites created
SCREENSPRITES  EQU     16      ; tab with sprites offsets and sizes
SCREENBACKGRN  EQU     SCREENSPRITES+(SCREENMAXSPR*SIZEOFSCREENGF) ; tab for backgrounds
SIZEOFSCREEN   EQU     SCREENBACKGRN+(SCREENMAXBG*SIZEOFSCREENGF)

; constants
SCREENMAXBG    EQU     15      ; maximum number of stored background
SCREENMAXSPR   EQU     70      ; maximum number of sprite

; static constants (allocated only once)
SCR_MaxXfp     DD      320.0
SCR_MaxYfp     DD      200.0
SCR_MaxX       DW      320

; functions (for all functions bx = pointer to object)
SCR_constructor:               ; at the moment the 320x200x256 mode
; ax = sprite segment
; dx = background segment
       MOV     WORD PTR [bx+SCREENREFRESH],OFFSET SCR_refresh
       MOV     WORD PTR [bx+SCREENSPRSEG],ax      ; sprite segment
       MOV     WORD PTR [bx+SCREENBGSEG],dx       ; background segment
       MOV     WORD PTR [bx+SCREENBGOFS],0
       MOV     WORD PTR [bx+SCREENNUMOFBG],0
       MOV     WORD PTR [bx+SCREENSPROFS],0
       MOV     WORD PTR [bx+SCREENNUMOFSPR],0
; modifies ax
       MOV     ax,13h
       INT     10h
       RET

SCR_destructor:                ; set up text mode
; modifies ax, doesn't need bx
       MOV     ax,03h
       INT     10h
SCR_refresh_nomorebackgroundtorestore:
       RET

SCR_refresh:           ; waits for retrace, & clears screen
; modifies ax, cx, dx, si, di, es
       MOV     ax,1001h        ; change overscan color (waitForRetrace too)
       INT     10h
       PUSH    0a000h
       POP     es
SCR_refresh_restorebackground_mainloop:
       MOV     si,WORD PTR [bx+SCREENNUMOFBG]
       SHL     si,3            ; *SIZEOFSCREENGF
       JZ      SCR_refresh_nomorebackgroundtorestore
       ADD     si,SCREENBACKGRN-SIZEOFSCREENGF ; si = (ptr to bg)+SIZEOFSCREENGF
       DEC     WORD PTR [bx+SCREENNUMOFBG]
       MOV     ax,WORD PTR [bx+SCREENBGOFS]
       SUB     ax,WORD PTR [bx+si+SCREENGF_SIZE]
       MOV     WORD PTR [bx+SCREENBGOFS],ax    ; ax = pointer to backg. gfx
       MOV     di,WORD PTR [bx+si+SCREENGF_OFS]
       MOV     cx,WORD PTR [bx+si+SCREENGF_SIZEX]
       MOV     dx,WORD PTR [bx+si+SCREENGF_SIZEY]
       MOV     ds,WORD PTR [bx+SCREENBGSEG]
       XCHG    ax,si
       ; ds:si = back gfx, es:di = screen, cx = SizeX, dx = SizeY, (bx)
       CALL    SCR_FromMemToScreen
       JMP     SCR_refresh_restorebackground_mainloop

SCR_drawobject:        ; ax = gfxnum, bp = object_ptr
       PUSH    ds
       POP     es
       ; get info about gfx
       SHL     ax,3            ; *SIZEOFSCREENGF
       XCHG    ax,si
       LEA     si,[bx+si+SCREENSPRITES]        ; si = ptr to gfx struct
       LODSW
       MOV     WORD PTR [bp+OBJECTSCRGFX],ax
       PUSH    ax              ; store gfx offset
       LODSW
       XCHG    ax,cx           ; cx = size in bytes
       LODSW
       MOV     WORD PTR [bp+OBJECTSCRX2],ax
       XCHG    ax,dx           ; dx = SizeX
       LODSW
       MOV     WORD PTR [bp+OBJECTSCRY2],ax
       XCHG    ax,si           ; si = SizeY
       ; calculate screen offset
       FLD     DWORD PTR [bp+OBJECTX]
       FLD     DWORD PTR [bp+OBJECTY]
       FMUL    DWORD PTR [SCR_MaxYfp]
       FISTP   DWORD PTR [Temp0]
       FMUL    DWORD PTR [SCR_MaxXfp]
       PUSH    si
       PUSH    dx
       MOV     ax,WORD PTR [Temp0]
       SHR     si,1
       SUB     ax,si           ; Y -= SizeY/2
       MOV     WORD PTR [bp+OBJECTSCRY1],ax    ; store y1 for collis. detect.
       ADD     WORD PTR [bp+OBJECTSCRY2],ax
       MOV     si,dx           ; si = SizeX ;)
       MUL     WORD PTR [SCR_MaxX]
       FISTP   DWORD PTR [Temp0]
       PUSH    ax
       MOV     ax,WORD PTR [Temp0]
       SHR     si,1
       SUB     ax,si           ; X -= SizeX/2
       MOV     WORD PTR [bp+OBJECTSCRX1],ax    ; store x1 for collis. detect.
       ADD     WORD PTR [bp+OBJECTSCRX2],ax
       POP     si
       ADD     ax,si           ; screen pointer
       POP     dx
       POP     si
       ; ax = screen pointer
       ; store background info
       MOV     di,WORD PTR [bx+SCREENNUMOFBG]
       INC     WORD PTR [bx+SCREENNUMOFBG]
       SHL     di,3            ; *SIZEOFSCREENGF
       LEA     di,[bx+di+SCREENBACKGRN]        ; di = ptr to bg struct
       PUSH    ax              ; store screen pointer for latter use
       STOSW
       XCHG    ax,cx           ; ax = size in bytes
       STOSW
       PUSH    WORD PTR [bx+SCREENBGOFS]       ; store bg offset
       ADD     WORD PTR [bx+SCREENBGOFS],ax    ; add size in bytes
       XCHG    ax,dx
       STOSW                   ; SizeX
       XCHG    ax,cx           ; cx = SizeX, ax = screen pointer
       XCHG    ax,si           ; ax = SizeY, si = screen pointer
       STOSW
       XCHG    ax,dx           ; dx = SizeY
       ; prepare for background storing
       POP     di              ; di = store offset for background
       MOV     es,WORD PTR [bx+SCREENBGSEG]    ; es = bg segment
       PUSH    0a000h
       POP     ds
       PUSH    dx
SCR_drawobject_storebackground:
       PUSH    cx
       PUSH    si
       REP MOVSB
       POP     si
       POP     cx
       ADD     si,320
       DEC     dx
       JNZ     SCR_drawobject_storebackground
       ; prepare for gfx drawing
       POP     dx              ; SizeY
       PUSH    ds
       POP     es              ; 0a000h segment
       POP     di              ; pointer at screen
       POP     si              ; pointer to gfx
       MOV     ds,WORD PTR cs:[bx+SCREENSPRSEG]
       ; cx = SizeX, bx = ScreenObj, ax = size in bytes,
       ; ds:si, es:di ready for MOVSB
SCR_FromMemToScreen:
       PUSH    cx
       PUSH    di
SCR_FromMemToScreen_pixels:
       LODSB
       TEST    al,al
       JZ      SCR_FromMemToScreen_pixels_transparent
       MOV     es:[di],al
SCR_FromMemToScreen_pixels_transparent:
       SCASB
       LOOP    SCR_FromMemToScreen_pixels
       POP     di
       POP     cx
       ADD     di,320
       DEC     dx
       JNZ     SCR_FromMemToScreen
       PUSH    cs
       POP     ds              ; restore ds
       RET

SCR_AddNewGfx:                 ; cx = number of bytes for gfx (<256!)
                               ; dx = (8:8) SizeY:SizeX
; return cx = 0, es:di = gfxptr, ax = 0, gfx mem is cleared
       MOV     di,WORD PTR [bx+SCREENNUMOFSPR]
       INC     WORD PTR [bx+SCREENNUMOFSPR]
       SHL     di,3            ; *SIZEOFSCREENGF
       LEA     di,[di+bx+SCREENSPRITES]        ; gfx info
       PUSH    cs
       POP     es
       MOV     ax,WORD PTR [bx+SCREENSPROFS]   ; gfx ptr
       PUSH    ax
       PUSH    ax
       STOSW                   ; store pointer into info
       MOV     ax,cx
       ADD     WORD PTR [bx+SCREENSPROFS],ax
       STOSW
       MOV     al,dl           ; SizeX
       STOSW
       MOV     al,dh           ; SizeY
       STOSW
       MOV     es,WORD PTR [bx+SCREENSPRSEG]
       POP     di
       SALC
       REP STOSB
       POP     di
       RET
