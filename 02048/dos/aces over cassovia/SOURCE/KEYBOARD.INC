;***************************************************************************;
;* 'KEYBOARD.INC' ASMINC Ped / 7 Gods (C)2000          #ASM compo 2kB game *;
;* - keyboard handler class                                                *;
;***************************************************************************;

KEYBOARDFLAGS  EQU     0       ; byte KeyFlags[128]
KEYBOARDOLDI9O EQU     128     ; offset to old INT09 handler
KEYBOARDOLDI9S EQU     130     ; segment to old INT09 handler
SIZEOFKEYBOARD EQU     132

; static constants (allocated only once)
KBD_ptr        DW      ?       ; here will stored ptr to object for interr. handler

; functions (for all functions bx = pointer to object)
KBD_constructor:               ; ds = cs !
; modifies ax, bx, cx, di, es
       PUSH    cs
       POP     es
       MOV     di,bx           ; ptr to KBD instance into di
       MOV     [KBD_ptr],bx    ; store ptr for keyboard handler
       XOR     ax,ax
       MOV     cx,128
       REP STOSB               ; clear KeyFlags
; hook 09 interrupt
       MOV     ax,3509h        ; get old vector of interrupt
       INT     21h
       MOV     WORD PTR [di+KEYBOARDOLDI9O-128],bx
       MOV     WORD PTR [di+KEYBOARDOLDI9S-128],es
       MOV     ah,25h          ; set new vector
       MOV     dx,OFFSET KBD_IntHandler
       INT     21h
       RET

KBD_destructor:
; modifies ax, dx
       MOV     ax,2509h        ; restore old handler
       MOV     dx,WORD PTR [bx+KEYBOARDOLDI9O]
       MOV     ds,WORD PTR [bx+KEYBOARDOLDI9S]
       INT     21h
       PUSH    cs
       POP     ds              ; restore ds
       RET

KBD_IntHandler:                ; real mode interrupt handler
; doesn't handle extended opcodes very well... I don't care
       PUSHA
       IN      al,60h
       MOVZX   bx,al
       AND     bl,7fh
       ADD     bx,cs:[KBD_ptr] ; because KEYBOARDFLAGS == 0, this is ok
       SAR     al,7
       NOT     al
       MOV     cs:[bx],al      ; update state (0=off, 0xFF = pushed)
; end interrupt
       IN      al,61h
       XOR     al,80h
       OUT     61h,al
       XOR     al,80h
       OUT     61h,al
       MOV     al,20h
       OUT     20h,al
       POPA
       IRET
