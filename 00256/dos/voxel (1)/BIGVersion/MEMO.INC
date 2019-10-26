;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;°±²  Ajusta, prepara y pide memoria
;°±²  para las pantallas virtuales.
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Memoria PROC
        ;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
        ;°±²    Ajusta la memoria asignada al programa
        ;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
        MOV BX,300                      ;°±² Reserva 256*16 = 4 Kb
        MOV AH,4Ah                      ;°±² Modifica el tama¤o del bloque reservado
        INT 21h                         ;°±² al segmento indicado en ES.Ahora ES = Seg.Programa
        PUSH CS                         ;°±² DS = Segmento de datos
        POP  DS

        ;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
        ;°±²    Pide memoria para guardar imagen 1
        ;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
        MOV BX,8096                     ;°±² N£mero de p rrafos. 64k/16 bytes por p rrafo
        MOV AH,48h
        INT 21h                         ;°±² Reserva memoria
        MOV WORD PTR [SegImagen],AX

        RET
Memoria ENDP
