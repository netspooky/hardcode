;***************************************************************************;
;* 'RANDOM  .INC' ASMINC Ped / 7 Gods (C)2000          #ASM compo 2kB game *;
;* - random generator class                                                *;
;* - this class does not need to have an instance (fake class ;))          *;
;***************************************************************************;

SIZEOFRANDOM   EQU     0               ; seed in static, so no variables

; constants
RND_MULCONST   EQU     0DEADF0ADh      ; dead and f.o.a.d. ... you know... ;)

; static constants (allocated only once)
RND_seed       DD      ?               ; whatever

; functions
; no constructor ... for what ?

RND_rand:
; input:  ecx = MAXNUM
; output: eax = random number from 0 .. MAXNUM-1
       PUSH    edx
       MOV     eax,RND_MULCONST
       MUL     DWORD PTR [RND_seed]
       INC     eax
       MOV     DWORD PTR [RND_seed],eax
       XOR     edx,edx
       DIV     ecx
       XCHG    eax,edx         ; eax = rand()%MAXNUM;
       POP     edx
       RET
