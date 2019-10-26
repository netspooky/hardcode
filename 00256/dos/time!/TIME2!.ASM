; attention - la routine est dans l'environnement !!!
;           - code auto-modifiant pour l'appel de l'ancien gestionnaire
;           - le PSP est coup‚ en 2 ...
Int1C              SEGMENT
                   ORG 100h
                   ASSUME CS:Int1C

Start:             MOV AX,351Ch
                   INT 21h
                   MOV JumpOfs,BX
                   MOV BX,ES
                   MOV JumpSeg,BX
                   MOV AX,CS
                   MOV DS,AX
                   MOV AH,9
                   MOV DX,OFFSET Copyright
                   INT 21h
                   MOV BX,DS:[2Ch] ; seg de l'environnement (contenu dans le PSP)
                   MOV ES,BX ; destination
                   XOR DI,DI
                   MOV SI,NewInt1C
                   CLD
                   MOV CX,LgNewInt1C-NewInt1C ; = 94 + 5 (5E + 5) octets !!!
                   REP MOVSB ; on move le code
                   PUSH ES
                   POP DS
                   MOV AX,251Ch
                   XOR DX,DX
                   INT 21h
                   MOV AX,3100h
                   MOV DX,8
                   INT 21h

Copyright          DB 13,10,'Time! 1.2 Coded by Sam 1993',13,10,'$'

NewInt1C           PROC FAR

                   PUSH AX
                   PUSH CX
                   PUSH ES
                   PUSH DI
                   STD ; on affiche par addr video d‚croissante
                   MOV AX,0B800h
                   MOV ES,AX
                   MOV DI,158
                   XOR AL,AL
                   OUT 70h,AL ; CMOS
                   IN AL,71h ; secondes DEJA EN BCD !!!
                   MOV CH,AL
                   AND AL,0Fh ; ‚fface partie haute ;
                   OR AL,30h
                   MOV AH,1Fh ; couleur blanc sur bleu
                   STOSW ; affiche , incremente
                   MOV AL,CH
                   MOV CL,4
                   SHR AL,CL
                   OR AL,30h
                   STOSW
                   MOV AX,1F3Ah ; ':'
                   STOSW
                   MOV AL,2
                   OUT 70h,AL
                   IN AL,71h ; minutes
                   MOV CH,AL
                   MOV AH,1Fh
                   AND AL,0Fh
                   OR AL,30h
                   STOSW
                   MOV AL,CH
                   SHR AL,CL
                   OR AL,30h
                   STOSW
                   MOV AX,1F3Ah
                   STOSW
                   MOV AL,4
                   OUT 70h,AL
                   IN AL,71h
                   MOV CH,AL
                   MOV AH,1Fh
                   AND AL,0Fh
                   OR AL,30h
                   STOSW
                   MOV AL,CH
                   SHR AL,CL
                   OR AL,30h
                   STOSW
                   POP DI
                   POP ES
                   POP CX
                   POP AX

                   DB 0EAh ; opcode d'un jump far vers l'ancien gestionnaire
JumpOfs            DW ?
JumpSeg            DW ?

NewInt1C           ENDP

LgNewInt1C:

Int1C              ENDS
                   END Start