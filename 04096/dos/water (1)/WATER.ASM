        .Model Small,C
        .Stack 400
        .Seq
        .386P
        Jumps
        Locals

Semilla_Inicial         Equ     9234H
Ancho_Olas              Equ     0002
Densidad_Inicial        Equ     0005
Syncronize              Equ     0000
Borde                   Equ     0002
Ancho                   Equ     0160
Alto                    Equ     0100
Maximo                  Equ     0150
Ancho_Puntos            Equ     0320
Debug_Test              Equ     0000
Crlf                    Equ     0Dh,0Ah

        .Code

;***************************************************************************
;  Transporta la tabla de vectorizaci¢n
;***************************************************************************
St_Lidt         Proc
        Xor     Ax,Ax
        Mov     Ds,Ax
        Mov     Es,Ax
        Mov     Si,8H
        Shl     Si,2
        Mov     Di,50H
        Shl     Di,2
        Mov     Cx,8*2
        Rep     Movsw
        Cli
        In      Al,21H
        Push    Ax
        Mov     Al,0Ffh
        Out     21H,Al
@@1:
        Cli
        Mov     Al,0Bh
        Out     20H,Al
        In      Al,20H
        Sti
        Nop
        Nop
        Nop
        Or      Al,Al
        Jnz     @@1
        Mov     Dx,20H
        Mov     Al,11H
        Out     Dx,Al
        Nop
        Mov     Dx,21H
        Mov     Al,50H
        Out     Dx,Al
        Nop
        Mov     Al,04H
        Out     Dx,Al
        Nop
        Mov     Al,01H
        Out     Dx,Al
        Nop
        Mov     Al,0Ffh
        Out     Dx,Al
        Pop     Ax
        Out     21H,Al
        Ret
St_Lidt         Endp

;***************************************************************************
;  Restaura la tabla de vectorizaci¢n
;***************************************************************************
Cl_Lidt Proc
        Xor     Ax,Ax
        Mov     Ds,Ax
        Mov     Es,Ax
        Mov     Si,50H
        Shl     Si,2
        Mov     Di,8H
        Shl     Di,2
        Mov     Cx,8*2
        Rep     Movsw
        Cli
        In      Al,21H
        Push    Ax
        Mov     Al,0Ffh
        Out     21H,Al
@@1:
        Cli
        Mov     Al,0Bh
        Out     20H,Al
        In      Al,20H
        Sti
        Nop
        Nop
        Nop
        Or      Al,Al
        Jnz     @@1
        Mov     Dx,20H
        Mov     Al,11H
        Out     Dx,Al
        Nop
        Mov     Dx,21H
        Mov     Al,8H
        Out     Dx,Al
        Nop
        Mov     Al,04H
        Out     Dx,Al
        Nop
        Mov     Al,01H
        Out     Dx,Al
        Nop
        Mov     Al,0Ffh
        Out     Dx,Al
        Pop     Ax
        Out     21H,Al
        Ret
Cl_Lidt Endp

;***************************************************************************
;  Anula todas las IRQs del IMR excepto la 1 (INT 09h)
;***************************************************************************
Irqs_Out        Proc
        In      Al,21H
        Mov     Cs:[Imr],Al  
        Or      Al,011111111B
        And     Al,011111101B
        Out     21H,Al
        Ret
Irqs_Out        Endp

;***************************************************************************
;  Deja el registro InterruptMaskRegister tal y como estaba al iniciar
;  la ejecuci¢n
;***************************************************************************
Restore_Imr     Proc
        Mov     Al,Cs:[Imr]
        Out     21H,Al
        Ret
Restore_Imr     Endp

;***************************************************************************
;  Establece el nuevo vector de la IRQ1, para que apunte hacia el handle
;  'keyboard' del propio codigo
;***************************************************************************
Set_Irq1        Proc
        Xor     Ax,Ax
        Mov     Ds,Ax
        Mov     Eax,Dword Ptr Ds:[4H+50H*4]
        Mov     Dword Ptr Cs:[Old_09H],Eax
        Cli
        Mov     Word Ptr Ds:[4H+50H*4],Offset Keyboard
        Mov     Word Ptr Ds:[4H+2+50H*4],Cs
        Sti
        Ret
Set_Irq1        Endp

;***************************************************************************
;  Handle para la INT 09h
;***************************************************************************
Keyboard        Proc
        Push    Ax
        In      Al,60H
        Test    Al,80H
        Jz      @@1
        Mov     Al,20H
        Out     20H,Al
        Pop     Ax
        Iret
@@1:
        Add     Sp,8
        Xor     Ax,Ax
        Mov     Ds,Ax
        Cli
        Mov     Eax,Dword Ptr Cs:[Old_09H]
        Mov     Dword Ptr Ds:[4H+50H*4],Eax
        Sti
        Mov     Al,20H
        Out     20H,Al
        Jmp     End_Proc
Keyboard        Endp

;***************************************************************************
;  Pone los registros de segmento apuntando a la VRAM y al buffer de la
;  tabla, borra el buffer y cambia al modo 13h (320*200*256)
;***************************************************************************
Put_320 Proc
        Push    Cs
        Pop     Ds
        Mov     Ax,0A000H
        Mov     Es,Ax
        Mov     Ax,Seg Uninit
        Mov     Gs,Ax
        Push    Es
        Push    Gs
        Pop     Ax
        Mov     Es,Ax
        Xor     Di,Di
        Mov     Cx,65535
        Xor     Al,Al
        Rep     Stosb
        Pop     Es
        Call    Zero_Pal
        Mov     Ax,0013H
        Int     10H
        Ret
Put_320 Endp

;***************************************************************************
;  Pone el modo texto
;***************************************************************************
Text_Mode       Proc
        Mov     Ax,0003H
        Int     10H
        Ret
Text_Mode       Endp

;***************************************************************************
;  Espera un retrazo y cambia el color del borde si la constante
;  'debug_test' est  a 1
;***************************************************************************
Vsync   Proc
If      Debug_Test
        Mov     Dx,3Dah
        In      Al,Dx
        Mov     Dx,3C0H
        Mov     Al,31H
        Out     Dx,Al
        Mov     Al,80
        Out     Dx,Ax
Endif
        Mov     Dx,03Dah
@@1:    In      Al,Dx
        Test    Al,8
        Jnz     @@1
@@2:    In      Al,Dx
        Test    Al,8
        Jz      @@2
If      Debug_Test
        Mov     Dx,3Dah
        In      Al,Dx
        Mov     Dx,3C0H
        Mov     Al,31H
        Out     Dx,Al
        Mov     Al,0
        Out     Dx,Ax
Endif
        Ret
Vsync   Endp

;***************************************************************************
;  Pone la paleta a 0, para evitar cambios bruscos
;***************************************************************************
Zero_Pal        Proc
        Mov     Dx,3C8H
        Xor     Al,Al                  
        Out     Dx,Al
        Inc     Dx
        Xor     Al,Al
        Mov     Cx,768
@@1:
        Out     Dx,Al
        Loop    @@1
        Ret
Zero_Pal        Endp

;***************************************************************************
;  Pone en el DAC la paleta del buffer 'palette'
;***************************************************************************
Put_Palette     Proc
        Mov     Dx,3C8H
        Xor     Al,Al                  
        Out     Dx,Al
        Inc     Dx
        Mov     Si,Offset Palette
        Mov     Cx,450
@@1:    Mov     Al,[Si]
        Inc     Si
        Out     Dx,Al                  
        Loop    @@1
        Ret
Put_Palette     Endp

;***************************************************************************
;  Imprime la pagina actual ('actual_page') y espera un sincronismo si la
;  constante 'syncronize' est  a 1.
;***************************************************************************
Print_Frame     Proc
        Mov     Si,Word Ptr Cs:[Actual_Page]
        Mov     Di,64000
        Mov     Cx,Ancho
@@4:
        Push    Di Cx
        Xor     Ax,Ax
        Xor     Dx,Dx
        Xor     Bx,Bx
@@3:
        Mov     Cx,Word Ptr Gs:[Si]
        Sar     Cx,7
        Add     Cx,Ax
        Sub     Cx,Dx
        Jle     @@1
        Add     Dx,Cx
@@2:
        Mov     Word Ptr Es:[Di],Bx
        Sub     Di,Ancho_Puntos
        Loop    @@2
@@1:
        Add     Si,2
        Add     Bx,0101H
        Inc     Ax
        Cmp     Ax,Alto
        Jnz     @@3
        Mov     Dh,Dl
@@5:
        Sub     Di,Ancho_Puntos
        Mov     Word Ptr Es:[Di],Dx
        Add     Dx,0101H
        Cmp     Dx,Maximo+Maximo*256
        Jnz     @@5
        Pop     Cx Di
        Add     Di,2
        Loop    @@4
If Syncronize
        Call    Vsync
Endif
        Ret
Print_Frame     Endp

;***************************************************************************
;  Intercambia 'actual_page' y 'other_page' y le aplica una funcion
;  diferencial para "estabilizarla" como si fuese un fluido
;***************************************************************************
Stabylize       Proc
        Mov     Si,Word Ptr Cs:[Actual_Page]
        Mov     Di,Word Ptr Cs:[Other_Page]
        Mov     Word Ptr Cs:[Actual_Page],Di
        Mov     Word Ptr Cs:[Other_Page],Si
        Add     Si,Borde*Alto
        Add     Di,Borde*Alto
        Mov     Cl,Byte Ptr Cs:[Densidad]
        Mov     Bx,Ancho*Alto/2-Borde*Alto/2
@@1:
        Mov     Eax,Dword Ptr Gs:[Si-Alto*2]
        Add     Eax,Dword Ptr Gs:[Si+Alto*2]
        Add     Eax,Dword Ptr Gs:[Si+2]
        Add     Eax,Dword Ptr Gs:[Si-2]
        Ror     Eax,16
        Sar     Ax,1
        Ror     Eax,16
        Sar     Ax,1
        Sub     Eax,Dword Ptr Gs:[Di]
        Mov     Edx,Eax
        Sar     Dx,Cl
        Ror     Edx,16
        Sar     Dx,Cl
        Ror     Edx,16
        Sub     Eax,Edx
        Mov     Dword Ptr Gs:[Di],Eax
        Add     Si,4
        Add     Di,4
        Dec     Bx
        Jnz     @@1
        Ret
Stabylize       Endp

;***************************************************************************
;  Intercambia 'actual_page' y 'other_page' y la modifica haciendo la
;  media aritm‚tica de cada uno de los puntos
;***************************************************************************
Stabylize2      Proc
        Mov     Si,Word Ptr Cs:[Actual_Page]
        Mov     Di,Word Ptr Cs:[Other_Page]
        Mov     Word Ptr Cs:[Actual_Page],Di
        Mov     Word Ptr Cs:[Other_Page],Si
        Add     Si,Borde*Alto
        Add     Di,Borde*Alto
        Mov     Cx,Ancho*Alto-Borde*Alto-100
@@1:
        Mov     Ax,Word Ptr Gs:[Si-Alto*2]
        Add     Ax,Word Ptr Gs:[Si+Alto*2]
        Add     Ax,Word Ptr Gs:[Si+2]
        Add     Ax,Word Ptr Gs:[Si-2]
        Add     Ax,Word Ptr Gs:[Si-Alto*2-2]
        Add     Ax,Word Ptr Gs:[Si-Alto*2-2]
        Add     Ax,Word Ptr Gs:[Si+Alto*2-2]
        Add     Ax,Word Ptr Gs:[Si+Alto*2-2]
        Sar     Ax,3
        Mov     Word Ptr Gs:[Di],Ax
        Add     Si,2
        Add     Di,2
        Loop    @@1
        Ret
Stabylize2      Endp

;***************************************************************************
;  Levanta un punto en el agua, de altura ESI y en las coordenadas
;  DX:BX (fila y columna)
;***************************************************************************
Put_Point       Proc
        Mov     Ax,Si
        Rol     Esi,16
        Mov     Si,Ax
        Mov     Ax,Alto
        Mul     Dx
        Add     Bx,Ax
        Shl     Bx,1
        Add     Bx,Word Ptr Cs:[Actual_Page]
        Mov     Dword Ptr Gs:[Bx],Esi
        Mov     Dword Ptr Gs:[Bx+4],Esi
        Mov     Dword Ptr Gs:[Bx+(Alto*2)],Esi
        Mov     Dword Ptr Gs:[Bx+(Alto*2+4)],Esi
        Mov     Dword Ptr Gs:[Bx+(Alto*4)],Esi
        Mov     Dword Ptr Gs:[Bx+(Alto*4)+4],Esi
        Mov     Dword Ptr Gs:[Bx+(Alto*6)],Esi
        Mov     Dword Ptr Gs:[Bx+(Alto*6)+4],Esi
        Ret
Put_Point       Endp

;***************************************************************************
;  Levanta un punto en el agua, de altura ESI y en las coordenadas
;  DX:BX (fila y columna) con un radio mayor que Put_Point
;***************************************************************************
Put_Big_Point   Proc
        Mov     Ax,Si
        Rol     Esi,16
        Mov     Si,Ax
        Mov     Ax,Alto
        Mul     Dx
        Add     Bx,Ax
        Shl     Bx,1
        Add     Bx,Word Ptr Cs:[Actual_Page]
        Mov     Dword Ptr Gs:[Bx],Esi
        Mov     Dword Ptr Gs:[Bx+4],Esi
        Mov     Dword Ptr Gs:[Bx+8],Esi
        Mov     Dword Ptr Gs:[Bx+10],Esi
        Mov     Dword Ptr Gs:[Bx+(Alto*2)],Esi
        Mov     Dword Ptr Gs:[Bx+(Alto*2+4)],Esi
        Mov     Dword Ptr Gs:[Bx+(Alto*2+8)],Esi
        Mov     Dword Ptr Gs:[Bx+(Alto*2+10)],Esi
        Mov     Dword Ptr Gs:[Bx+(Alto*4)],Esi
        Mov     Dword Ptr Gs:[Bx+(Alto*4)+4],Esi
        Mov     Dword Ptr Gs:[Bx+(Alto*4)+8],Esi
        Mov     Dword Ptr Gs:[Bx+(Alto*4)+10],Esi
        Mov     Dword Ptr Gs:[Bx+(Alto*6)],Esi
        Mov     Dword Ptr Gs:[Bx+(Alto*6)+4],Esi
        Mov     Dword Ptr Gs:[Bx+(Alto*6)+8],Esi
        Mov     Dword Ptr Gs:[Bx+(Alto*6)+10],Esi
        Mov     Dword Ptr Gs:[Bx+(Alto*8)],Esi
        Mov     Dword Ptr Gs:[Bx+(Alto*8)+4],Esi
        Mov     Dword Ptr Gs:[Bx+(Alto*8)+8],Esi
        Mov     Dword Ptr Gs:[Bx+(Alto*8)+10],Esi
        Mov     Dword Ptr Gs:[Bx+(Alto*10)],Esi
        Mov     Dword Ptr Gs:[Bx+(Alto*10)+4],Esi
        Mov     Dword Ptr Gs:[Bx+(Alto*10)+8],Esi
        Mov     Dword Ptr Gs:[Bx+(Alto*10)+10],Esi
        Ret
Put_Big_Point   Endp

;***************************************************************************
;  Levanta un punto en posici¢n aleatoria con altura ESI
;***************************************************************************
Touch   Proc
        Push    Esi
        Call    Read_Point
        Pop     Esi
        Shr     Dx,1
        Call    Put_Point
        Ret
Touch   Endp

;***************************************************************************
;  Levanta un punto en posici¢n aleatoria con altura ESI, con un radio
;  mayor que mediante Touch
;***************************************************************************
Big_Touch       Proc
        Push    Esi
        Call    Read_Point
        Pop     Esi
        Shr     Dx,1
        Call    Put_Big_Point
        Ret
Big_Touch       Endp

;***************************************************************************
;  Levanta una linea vertical en el agua, en la columna DX y de altura SI
;***************************************************************************
Put_Line        Proc
        Mov     Ax,Si
        Rol     Esi,16
        Mov     Si,Ax
        Mov     Ax,Alto*2
        Mul     Dx
        Mov     Bx,Ax
        Add     Bx,Ancho_Olas
        Mov     Cx,Alto/2-Ancho_Olas
        Add     Bx,2*8
        Sub     Cx,2*8
@@1:
        Mov     Dword Ptr Gs:[Bx],Esi
        Mov     Dword Ptr Gs:[Bx+Alto*2],Esi
        Mov     Dword Ptr Gs:[Bx+Alto*4],Esi
        Mov     Dword Ptr Gs:[Bx+Alto*6],Esi
        Mov     Dword Ptr Gs:[Bx+Alto*8],Esi
        Mov     Dword Ptr Gs:[Bx+Alto*10],Esi
        Add     Bx,4
        Loop    @@1
        Ret
Put_Line        Endp

;***************************************************************************
;  Levanta el siguiente punto de la funci¢n senoidal
;***************************************************************************
Touch_Sinus     Proc A:Word
        Push    Esi
        Call    Read_Sinus,A
        Pop     Esi
        Call    Put_Point
        Ret
Touch_Sinus     Endp

;***************************************************************************
;  Imprime una pantalla y la estabiliza con la rutina apuntada por BX
;  durante CX veces
;***************************************************************************
Print   Proc
@@1:
        Push    Cx Bx
        Call    Print_Frame
        Pop     Bx
        Push    Bx
        Call    Bx
        Pop     Bx
        Pop     Cx
        Loop    @@1
        Ret
Print   Endp

;***************************************************************************
;  Lee el siguiente valor de la funci¢n senoidal
;***************************************************************************
Read_Sinus      Proc A:Word
        Shl     A,1
@@11:
        Mov     Bx,A
        Mov     Si,Word Ptr Cs:[Fil+Bx]
        Mov     Cx,Word Ptr Cs:[Fila+Si]
        Cmp     Cx,0Ffffh
        Jnz     @@1
        Mov     Bx,A
        Mov     Word Ptr Cs:[Fil+Bx],0
        Jmp     @@11
@@1:
        Mov     Bx,A
        Mov     Si,Word Ptr Cs:[Col+Bx]
        Mov     Dx,Word Ptr Cs:[Columna+Si]
        Cmp     Dx,0Ffffh
        Jnz     @@2
        Mov     Bx,A
        Mov     Word Ptr Cs:[Col+Bx],0
        Jmp     @@1
@@2:
        Mov     Bx,A
        Add     Word Ptr Cs:[Col+Bx],2
        Add     Word Ptr Cs:[Fil+Bx],2
        Mov     Bx,Cx
        Ret
Col     Label
        Dw      5 Dup(0)
Fil     Label
        Dw      5 Dup(0)
Clear_Sinus     Proc
        Mov     Word Ptr Cs:[Col],10
        Mov     Word Ptr Cs:[Col+2],20
        Mov     Word Ptr Cs:[Col+4],40
        Mov     Word Ptr Cs:[Col+6],0
        Mov     Word Ptr Cs:[Col+8],0
        Mov     Word Ptr Cs:[Fil],50
        Mov     Word Ptr Cs:[Fil+2],20
        Mov     Word Ptr Cs:[Fil+4],40
        Mov     Word Ptr Cs:[Fil+6],40
        Mov     Word Ptr Cs:[Fil+8],0
        Ret
Clear_Sinus     Endp
Columna Label
        Dw      015,015,016,016,017,018,020,021,023,025,027,030
        Dw      033,036,039,042,045,049,052,056,060,064,068,072
        Dw      076,080,084,088,092,096,000,104,108,111,115,118
        Dw      121,124,127,130,133,135,137,139,140,142,143,144
        Dw      144,145,145,145,144,144,143,142,140,139,137,135
        Dw      133,130,127,124,121,118,115,111,108,104,100,096
        Dw      092,088,084,080,076,072,068,064,060,056,052,049
        Dw      045,042,039,036,033,030,027,025,023,021,020,018
        Dw      017,016,016,015
        Dd      0Ffffffffh
Fila    Label
        Dw      025,025,026,027,028,030,032,034,037,039,042,045
        Dw      048,052,055,058,061,063,066,068,070,072,073,074
        Dw      075,075,075,074,073,072,070,068,066,063,061,058
        Dw      055,052,048,045,042,039,037,034,032,030,028,027
        Dw      026,025
        Dd      0Ffffffffh
Read_Sinus      Endp

;***************************************************************************
;  Devuelve unas coordenadas "pseudoaleatorias" en DX:BX
;***************************************************************************
Read_Point      Proc
        Call    Rnd_Calc
        And     Dx,11111111B
        Add     Dx,32
        Push    Dx
        Call    Rnd_Calc
        Mov     Bx,Dx
        Pop     Dx
        And     Bx,1111111B
        Add     Bx,36
        Ret
Rnd_Calc:
        Inc     Cs:Rnd
        Xor     Dx,Dx
        Mov     Ax,Cs:Rnd
        Mov     Bx,32719
        Mul     Bx
        Add     Ax,3                    
        Mov     Bx,32749                
        Div     Bx
        Add     Dx,0F000H
        Mov     Cs:Rnd,Dx
        Ret
Rnd     Label   Word
        Dw      0000H
Read_Point      Endp

Density Macro   Densidad_Variable
        Mov     Byte Ptr Cs:[Densidad],Densidad_Variable
        Endm

P@001   Proc
        Xor     Si,Si
        Mov     Cx,40
@@2:
        Push    Cx
        Mov     Cx,3
@@1:
        Push    Cx Si
        Call    Big_Touch
        Call    Stabylize
        Call    Print_Frame
        Call    Stabylize
        Call    Print_Frame
        Call    Stabylize
        Call    Print_Frame
        Call    Stabylize
        Call    Print_Frame
        Pop     Si Cx
        Loop    @@1
        Add     Si,25
        Pop     Cx
        Loop    @@2
        Mov     Cx,40
@@12:
        Push    Cx
        Mov     Cx,3
@@11:
        Push    Cx Si
        Call    Big_Touch
        Call    Stabylize
        Call    Print_Frame
        Call    Stabylize
        Call    Print_Frame
        Call    Stabylize
        Call    Print_Frame
        Call    Stabylize
        Call    Print_Frame
        Pop     Si Cx
        Loop    @@11
        Sub     Si,20
        Pop     Cx
        Loop    @@12
        Ret
P@001   Endp

P@002   Proc
        Mov     Cx,5
@@2:
        Push    Cx
        Mov     Si,3000
        Mov     Dx,320/4
        Mov     Bx,150
        Call    Put_Point
        Mov     Cx,50
@@3:
        Push    Cx
        Mov     Si,300
        Call    Touch
        Mov     Si,200
        Call    Touch
        Mov     Si,100
        Call    Touch
        Call    Stabylize
        Call    Print_Frame
        Pop     Cx
        Loop    @@3
        Pop     Cx
        Loop    @@2
        Mov     Cx,80
@@4:
        Push    Cx
        Call    Stabylize
        Call    Print_Frame
        Pop     Cx
        Loop    @@4
        Ret
P@002   Endp

P@003   Proc
        Mov     Cx,30
@@1:
        Push    Cx
        Mov     Si,-4000
        Call    Big_Touch
        Call    Stabylize2
        Call    Print_Frame
        Mov     Si,-4000
        Call    Big_Touch
        Call    Stabylize2
        Call    Print_Frame
        Mov     Si,-4000
        Call    Big_Touch
        Call    Stabylize2
        Call    Print_Frame
        Pop     Cx
        Loop    @@1
        Mov     Cx,20
@@4:
        Push    Cx
        Call    Stabylize2
        Call    Print_Frame
        Pop     Cx
        Loop    @@4
        Ret
P@003   Endp

P@004   Proc
        Mov     Cx,7
@@2:
        Push    Cx
        Mov     Si,3000
        Mov     Dx,320/4
        Mov     Bx,150
        Call    Put_Point
        Mov     Cx,5
@@3:
        Push    Cx
        Call    Stabylize
        Call    Print_Frame
        Pop     Cx
        Loop    @@3
        Mov     Si,-2000
        Mov     Dx,320/4
        Mov     Bx,150
        Call    Put_Point
        Mov     Cx,30
@@6:
        Push    Cx
        Call    Stabylize
        Call    Print_Frame
        Pop     Cx
        Loop    @@6
        Pop     Cx
        Loop    @@2
        Mov     Cx,80
@@4:
        Push    Cx
        Call    Stabylize
        Call    Print_Frame
        Pop     Cx
        Loop    @@4
        Ret
P@004   Endp

P@005   Proc    A:Word,B:Word
        Mov     Si,800
        Mov     Cx,150
@@1:
        Push    Cx Esi
        Cmp     A,4
        Jz      @@5
        Cmp     A,3
        Jz      @@4
        Cmp     A,2
        Jz      @@3
        Cmp     A,1
        Jz      @@2
        Call    Touch_Sinus,0
@@2:
        Call    Touch_Sinus,1
@@3:
        Call    Touch_Sinus,2
@@4:
        Call    Touch_Sinus,3
@@5:
        Call    Touch_Sinus,4
        Mov     Cx,B
        Mov     Bx,Offset Stabylize
        Call    Print
        Pop     Esi Cx
        Loop    @@1
        Ret
P@005   Endp

P@006   Proc    A:Word,B:Word
        Mov     Si,-1500
        Mov     Cx,4
@@1:
        Push    Cx Si
        Mov     Dx,1
        Cmp     A,0
        Jz      @@S1
        Call    Put_Line
@@S1:
        Mov     Cx,50
@@3:
        Push    Cx
        Mov     Si,250
        Cmp     B,0
        Jz      @@S2
        Call    Touch
@@S2:
        Call    Stabylize
        Call    Print_Frame
        Call    Stabylize
        Call    Print_Frame
        Pop     Cx
        Loop    @@3
        Pop     Si Cx
        Loop    @@1
        Ret
P@006   Endp

Stabylize_Water Proc
        Mov     Cx,100
        Mov     Bx,Offset Stabylize
        Call    Print
        Ret
Stabylize_Water Endp

End_Msg Proc
        Push    Cs
        Pop     Ds
        Mov     Dx,Offset @@1
        Mov     Ah,09H
        Int     21H
        Ret
@@1     Label
        Db      'ð Water by Dä-PhŽSSäD! from RESET-TVC, 12-11-1995, Castelldefels-BARCELONA',Crlf,Crlf

        Db      'þ IGUANA,  grupo espa¤ol dedikado  a la DemoSzene y  ganador del 2§ premio',Crlf
        Db      '  internazional  Assembly`94,  us¢ por primera vez  una t‚knika  LandsKape',Crlf
        Db      '  para representar ‚ste efekto en su SuperMegaDemo "Heartquake".',Crlf
        Db      '  Posteriormente,  ha editado alg£n  dokumento  deskribiendo las komplejas',Crlf
        Db      '  funziones diferenziales y  las  t‚knikas  para  el  desarrollo  de  ‚sta',Crlf
        Db      '  maravilla, sin los kuales yo jam s hubiese konseguido programarla...',Crlf
        Db      '  LOTZ OF ZANX, IGUANA!! ;) ;)',Crlf

        Db      'þ Kreo k es ‚ste  uno de los efektos  m s impaktantes k he visto  jam s en',Crlf
        Db      '  la  DemoSzene  internazional, kiz s por k nos enturbia la konzepzi¢n  de',Crlf
        Db      '  "kaos" mostr ndonos artifiziosamente  el suzeder natural  y  su kompleja',Crlf
        Db      '  belleza de infinitas formas armoniosas a trav‚s de unos silenziosos pero',Crlf
        Db      '  ardientes trozos de silizio...',Crlf

        Db      'þ GREETZ: Chc,Dyonisos,Elfo,KingGraham,Joanmi_Bardera,Gianola,Magic,Tarod,',Crlf
        Db      '  Terminator,JaMiRo,Kalss,TLU,Kiefer,Trojan,Night_Warrior,Franky,Bitspawn,',Crlf
        Db      '  LuisCrespo,Iguana,Micaco BBS,Quartz BBS,UAB BBS and... all the other! ;)',Crlf

        Db      'þ Internet: oiram@bbs-ce.uab.es',Crlf
        Db      '  Telefono: +34-3-6645527 (Mario, Oiram o Dä-PhŽSSäD!) ;)',Crlf
        Db      '  Korreo konvenzional: C/Gral.Palafox, 4, Atc§3¦',Crlf
        Db      '                       08860 Castelldefels,Barcelona. ESPA¥A',Crlf,Crlf
        Db      'þ oh! and.. remember! Timophonika, fuck u again, and again, and again, and',Crlf
        Db      '  again, and again, and again, and again, and again, and again, and.. XD!!','$'



        Db      '(C) Dä-PhŽSSäD! 1995',0Dh,0Ah,0Dh,0Ah,'$'
End_Msg Endp

Main:
        Call    St_Lidt
        Call    Irqs_Out
        Call    Set_Irq1
        Call    Put_320
        Density Densidad_Inicial
        Mov     Bx,Offset Stabylize
        Mov     Cx,1
        Call    Print
        Call    Zero_Pal
        Call    Put_Palette
        Push    Es
        Mov     Ax,0A000H
        Mov     Es,Ax
        Mov     Di,320*101
        Mov     Cx,320/4
        Mov     Eax,63636363H
        Rep     Stosd
        Pop     Es

Again:
        Mov     Rnd,Semilla_Inicial
        Density Densidad_Inicial
        Call    P@001
        Call    P@002
        Density 6
        Call    P@003
        Call    Stabylize_Water
        Call    P@003
        Call    Stabylize_Water
        Density 5
        Call    P@004
        Call    Stabylize_Water
        Call    Clear_Sinus
        Call    P@005,4,2
        Call    P@005,3,2
        Call    P@005,2,2
        Call    P@005,4,1
        Call    P@005,4,1
        Call    P@005,3,1
        Density 6
        Call    P@006,1,0
        Call    P@006,1,1
        Call    P@006,0,1
        Jmp     Again
End_Proc:
        Call    Restore_Imr
        Call    Zero_Pal
        Call    Text_Mode
        Call    End_Msg
        Mov     Ax,4C00H
        Int     21H

Palette Label
Db      03Fh,03Fh,03Fh,03Ch,03Fh,03Fh,03Ah,03Fh,03Fh,037H,03Eh,03Fh,034H,03Eh,03Fh,032H
Db      03Eh,03Fh,02Fh,03Eh,03Fh,02Dh,03Dh,03Fh,02Ah,03Dh,03Fh,029H,03Ch,03Fh,028H,03Bh
Db      03Fh,027H,03Bh,03Fh,027H,03Bh,03Fh,026H,03Ah,03Fh,025H,039H,03Fh,024H,038H,03Fh
Db      023H,037H,03Fh,022H,037H,03Fh,021H,036H,03Fh,020H,035H,03Fh,01Fh,034H,03Fh,01Eh
Db      033H,03Fh,01Dh,032H,03Fh,01Ch,031H,03Fh,01Bh,030H,03Fh,01Ah,02Fh,03Fh,019H,02Eh
Db      03Fh,018H,02Dh,03Fh,017H,02Ch,03Fh,016H,02Ah,03Fh,015H,029H,03Fh,014H,028H,03Fh
Db      013H,027H,03Fh,012H,025H,03Eh,011H,025H,03Dh,011H,023H,03Dh,010H,022H,03Ch,00Fh
Db      020H,03Bh,00Fh,020H,03Ah,00Eh,01Eh,039H,00Dh,01Dh,039H,00Ch,01Bh,038H,00Ch,01Bh
Db      037H,00Bh,019H,036H,00Bh,018H,035H,00Ah,016H,035H,009H,016H,034H,009H,014H,033H
Db      008H,013H,032H,007H,012H,031H,007H,011H,031H,006H,010H,030H,006H,00Fh,02Fh,005H
Db      00Eh,02Fh,005H,00Dh,02Eh,004H,00Ch,02Dh,004H,00Bh,02Ch,003H,00Ah,02Bh,003H,009H
Db      02Bh,002H,008H,02Ah,002H,007H,029H,002H,006H,028H,001H,006H,027H,001H,004H,027H
Db      001H,004H,026H,001H,004H,026H,001H,004H,026H,001H,004H,025H,001H,004H,025H,001H
Db      004H,025H,001H,004H,024H,000H,004H,024H,000H,004H,024H,000H,004H,023H,000H,003H
Db      023H,000H,003H,022H,000H,003H,022H,000H,003H,022H,000H,003H,021H,000H,003H,021H
Db      000H,003H,021H,000H,003H,020H,000H,003H,020H,000H,003H,020H,000H,003H,020H,000H
Db      003H,01Fh,000H,003H,01Fh,000H,003H,01Fh,000H,003H,01Eh,000H,003H,01Eh,000H,002H
Db      01Eh,000H,002H,01Dh,000H,002H,01Dh,000H,002H,019H,000H,002H,016H,000H,001H,012H
Db      000H,001H,00Fh,000H,000H,00Ah,000H,000H,005H,000H,000H,000H,00Eh,000H,000H,013H
Db      000H,000H,018H,000H,000H,01Dh,000H,000H,022H,000H,000H,027H,000H,000H,02Ch,000H
Db      000H,031H,000H,000H,034H,000H,000H,038H,000H,000H,037H,000H,000H,036H,000H,002H
Db      035H,000H,004H,035H,000H,005H,034H,000H,008H,033H,000H,009H,033H,000H,00Ah,032H
Db      000H,00Bh,031H,000H,00Ch,030H,000H,00Dh,030H,001H,00Eh,02Fh,000H,00Fh,02Eh,000H
Db      010H,02Eh,000H,010H,02Dh,000H,012H,02Ch,001H,013H,02Ch,001H,014H,02Bh,001H,014H
Db      02Ah,001H,015H,029H,001H,016H,029H,001H,016H,028H,001H,017H,029H,003H,019H,02Ah
Db      005H,01Bh,02Ch,008H,01Dh,02Dh,00Bh,01Fh,02Eh,00Dh,020H,02Fh,010H,022H,031H,013H
Db      025H,032H,017H,027H,033H,01Ah,029H,034H,01Eh,02Bh,036H,021H,02Dh,037H,025H,030H
Db      038H,029H,032H,03Ah,02Dh,034H,03Bh,031H,037H,03Ch,036H,03Ah,03Eh,03Ah,03Ch,03Fh
Db      03Fh,03Fh,03Fh,03Fh,03Fh,03Fh,03Fh,03Fh,03Fh,03Fh,03Fh,03Fh,03Fh,03Fh,03Fh,03Fh

Imr     Label   Byte
        Db      00H
Other_Page      Label   Word
        Dw      Alto*Ancho*2
Actual_Page     Label   Word
        Dw      0000
Densidad        Label   Byte
        Db      00H
Old_09H Label
        Dd      00000000H
Uninit  Segment
Uninit  Ends
        End     Main
