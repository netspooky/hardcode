;              _  _  _                          
; |\ | _    _   )|_ |_ |_  Intro for Attrib Compo II | Compile with NASM
; | \|(/_\/(/_ /_ _)|_)|_)    [attrib.escena.org]     \ ._  _. _._ _  
;       by Keymon                                      || |(_|_>| | | forever.
;              \_keymon@ceibe.org                     <___,


   ORG 100h
   SECTION .text

MAX_NUM_COPOS        EQU     400

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Funcions varias

;------------------------------
;SetMode Cambia de modo grafico
%macro SetMode 1
   mov ax, %1             
   int 10h
%endmacro

;--------------------------------------------
;SetCursorPos(x,y) Cambia a posicion do cursor
%macro SetCursorPos 2
   mov ah, 02h
   mov dx, (%2<<8)|%1
   int 10h
%endmacro

;--------------------------------------------
;PrintMsx(msx) Imprime unha mensaxe
%macro PrintMsx 1
   mov ah, 09h
   mov dx, %1
   int 21h
%endmacro


;---------
; Retrazo
%macro Wait_Vr 0
    mov dx, 3dah
 %%r1:
    in al, dx
    test al, 8
    jz %%r1
 %%r2:
    in al, dx
    test al, 8
    jnz %%r2
%endmacro


;***********************************************************************
;***********************************************************************
Start:

   SetMode 013h   ;Inicia modo grafico

   mov cx, MAX_NUM_COPOS+1  ; Iniciamos as posicions dos copos
   mov di, copo             
   mov ax, 0fc01h             ; Fora de pantalla
   rep stosw
   
   
   mov dx, 3C8h         ; set 256 color palette
;  mov al, 1            ; iniciado a 1 antes
   out dx, al           ; init
   inc dx
   
   mov al, 63-3*2       ; A compoñente crece a cada salto do bucle
   mov cx, 7*3-1        ; Poñemos a branco todos as constantes de cor das
                        ; 7 primeiras cores salvo a green&blue da 7
.bucle:
   inc al
   out dx, al
   loop .bucle

   SetCursorPos 8,20          ; imprime mensaxe de saudo
   PrintMsx msx

   push word 0a000h         ; Incia o segmento
   pop es

;*******************************NEVE************************************
;Bucle Principal da Neve

MainLoop:                             
   inc byte [cs:loop_cont]

   Wait_Vr                  ; espera retrazo
   
   mov cx, [cs:num_copos]   ; Procesamos a neve
   cmp cx, MAX_NUM_COPOS
   je Procesa_copos
   inc word [cs:num_copos]

Procesa_copos:

   test cx, 01h                    ; Uns copos + rápido q outros
   jnz Despraza_Copo
   test byte [cs:loop_cont], 01h
   jnz Fin_Proces

;-----------------------------------------------------------------------
;Despraza o copo cara abaixo cun movemento aleatorio
Despraza_Copo:

   mov bx, cx                      
   shl bx, 1

   mov di, [cs:copo+bx]            ; En di ser  a posici¢n seguinte do
   mov si, di                      ; copo, en si a actual.

   mov [es:si], byte 0             ; Borramos o copo anterior 

   add di, 320                     ; Sumamos unha li¤a

   cmp di, 64000                   ; Se sae por abaixo o fixamos
   jae .fixar                      ; Tb inicializa novos copos


   cmp [es:di], byte 2             ; se non é vacio desprazamos a un lado
   jnb .desp_hor

   add si, 320                     ; Non choca, baixamos todo
   
   call randbit                    ; Decidimos se caerá recto ou se se moverá
   jc .exit                        


 .desp_hor: 
   mov dx, 1                       ; DX será o despazamento
   call randbit                    ; Decidimos o desprazaneto
   jnc .ezquerda                   
 .dereita:  
   neg dx
 .ezquerda:
   add di, dx
   cmp [es:di], byte 2             ; Se tampouco se pode proba ezqueda
   jb .exit
   sub di, dx
   sub di, dx
   cmp [es:di], byte 2             ; e se non se pode dereita
   jb .exit
                                   ; E se non se fixa 
 .fixar:
   mov [es:si], byte 2 

; Volvemos a sacar un copo arriba.
   xor ax, ax      
   mov al, [cs:rbseed]           ; Collemos un nº aleatorio de 0 a 256
   mov di, ax                    ; Cambiamola posicion
   add di, 32                    ; e deixamos unha pequena marxe de 32
   jmp short .garda_copo

 .exit:
   mov [es:di], byte 1             ; Po¤emos o novo punto

 .garda_copo:
   mov [CS:copo+bx], di            ; Gardamos a nova posicion

Fin_Proces:
   mov ah, 1                       ; Comproba se se pulso escape
   int 16h
   jnz ExitProg

   loop Procesa_copos
   jmp MainLoop

ExitProg:
   SetMode 03h
   int 20h


;--------------------------------------------------------------------------
; Toma un bit aleatorio
; (c) Idea basada en codigo de Joe Koss (Shades/2O3)

randbit: 
    mov al, [cs:rbseed]   
    test al, 80h             
    jz .false             
.true: 
    xor al, 01010111b      
.false:
    rol al, 1              
    mov [cs:rbseed], al    
    ret


;--------------------------------------------------------------------------

[SECTION .data]
num_copos   dw 1
msx         db 'Attrib__256b '
            db '[Compo II]$'

[SECTION .bss]
rbseed      EQU 0          ; A semente aleatoria apunta ó comezo do psp
loop_cont   resb 1
ALIGNB 2
copo        resw MAX_NUM_COPOS
