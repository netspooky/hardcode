;#########################################################################
;	 	        ASC to DW file (for HxCIntro 2001 Intro)
;				tasm source file...
;                          by Del Nero Jean Francois 
;                               (c)  HxC 2001
;                              www.powerofasm.fr.st
;                          jeanfrancoisdelnero@libero.it
;				  13/12/2001
;#########################################################################



;    .MODEL HUGE
;    .STACK 1000
;    .CODE
;    .DATA
     .486P
;    ASSUME CS:@CODE, DS:@CODE


_TEXT   segment use32 dword public 'CODE'
        assume  cs:_TEXT,ds:_DATA,ss:_stack



 

;=== SUBROUTINES

;///////////////////////////////////////////////////////////////////////////


;===========Debut du Programme===========
START:
jmp short STARTJP1

db 'WATCOM... What me worry?'   ; The "WATCOM" string is needed in
                                ; order to run under DOS/4G and WD.

STARTJP1:

mov ah,3dh
mov al,0
mov edx,offset filename
int 21h
jc errorfe
mov ds:[handle1],ax


xor eax,eax
xor ebx,ebx
xor ecx,ecx
xor edx,edx


mov ah,3fh
mov bx,ds:[handle1]
mov ecx,800000
mov edx,offset bufferfichier
int 21h
jc errorfe
mov ds:[taille1],eax

mov ah,3eh
mov bx,ds:[handle1]
int 21h


call affiche

call reelentier
call supxyz
call supvetrex

call classage



mov edx,offset bufferfichier
mov esi,edx
add esi,ds:[taille1]
mov al,'$'
mov ds:[esi],al

mov edx,offset bufferfichier2
mov ah,9
int 21h

   errorfe:

    mov     ax,4c00h        ;return control to DOS
    int     21h
    XOR ax,ax
    INT 21h
    INT 20h
    INT 20h



classage proc
pushad
mov ecx,ds:[taille1]
mov edi,offset bufferfichier
mov esi,offset bufferfichier2

boucleclacage:
push esi
mov esi,offset nom2  ;face
call cmpmot ;si=source di=dest
pop esi
cmp ax,0
jne suitefdgdhrthtjjjjjj

        mov ebx,0ffffffh
        bouclec2:
        call cmpmot2 ;si=source di=dest  ;A: B: C:
        cmp ax,0
        jne suitefjj
           push edi
            push ecx
             call copynb
               mov edi,offset bufferfichier
                boucleaaaaaaa:

                push esi
                mov esi,offset temp1
                call  cmpmot
                pop esi

                cmp ax,0
                jne suitehgfth
                  call copyligne
                  inc edi
                 jmp finctyt
                suitehgfth:
                inc edi
                jmp boucleaaaaaaa
               finctyt:
             pop ecx
           pop edi

        suitefjj:
        inc edi
        dec ecx
        jz finboucleclacage

        cmp bl,0
        jne bouclec2

    mov ax,'wd'
    mov ds:[esi],ax
    add esi,2
    mov al,' '
    mov ds:[esi],ax
    inc esi  
    mov ax,'55'
    mov ds:[esi],ax
    add esi,2
    mov ax,'00'
    mov ds:[esi],ax
    add esi,2
    mov al,'h'
    mov ds:[esi],al
    inc esi
    mov al,10
    mov ds:[esi],al
    inc esi
   ; mov al,13
   ; mov es:[si],al
   ; inc si
    
    mov word ptr ds:[esi+1],'$'
                      
suitefdgdhrthtjjjjjj:
inc edi
dec ecx
jnz boucleclacage
finboucleclacage:
popad
ret
classage endp






copyligne proc
   mov ds:[esi],'wd'
   add esi,2
   mov ds:[esi],2020h
   add edi,5

   bouclecopy2:
   mov al,ds:[edi]
   mov ds:[esi],al
   inc esi
   inc edi
   cmp al,13
   jne bouclecopy2
   mov al,10
   mov ds:[esi],al
   inc esi
   mov al,'$'

   mov ds:[esi],al
   mov ds:[esi+2],al
   mov ds:[esi+4],al
   mov ds:[esi+6],al

ret
copyligne endp

copynb proc
  push esi
   add edi,2
   mov esi,offset temp1
   bouclecopy2f:
   mov al,ds:[edi]
   mov ds:[esi],al
   inc esi
   inc edi
   cmp al,20h
   jne bouclecopy2f
   dec esi
   mov al,':'
   mov ds:[esi],al
  inc esi
   mov al,0
   mov ds:[esi],al
  pop esi
ret
copynb endp


supvetrex proc
pushad
 mov ecx,ds:[taille1]
 mov edi,offset bufferfichier
 mov esi,offset nom1
boucledweb:
 call cmpmot ;proc  ;si=source di=dest
 cmp ax,0
 jne suitefdgdhrtht
 mov ds:[edi],'wd'
 mov ds:[edi+2],2020h
; mov ds:[edi+4],2020h

suitefdgdhrtht:
 inc edi
 dec ecx
 jnz boucledweb

popad
ret
supvetrex endp

supxyz proc
pushad
mov ecx,ds:[taille1]
mov esi,offset bufferfichier
boucledb:
mov ax,ds:[esi]
cmp ax,':X'
jne okefe1
mov ax,2020h
mov ds:[esi],ax
okefe1:
cmp ax,':Y'
jne okefe2
mov ax,' ,'
mov ds:[esi],ax
okefe2:
cmp ax,':Z'
jne okefe3
mov ax,' ,'
mov ds:[esi],ax
okefe3:

inc esi
dec ecx
jnz boucledb
popad
ret
supxyz endp


cmpmot proc  ;esi=source edi=dest
pushad
bouclejfke:
mov al,ds:[esi]
cmp al,0
je okjkefj
cmp al,ds:[edi]
jne finrkegnklr
inc esi
inc edi
jmp bouclejfke
finrkegnklr:
popa
mov ax,1
ret
okjkefj:
popad
mov ax,0
ret
cmpmot endp

                    
cmpmot2 proc  ;edi=dest
mov ax,':A'
cmp ax,ds:[edi]
je okjkefjw
mov ax,':B'
cmp ax,ds:[edi]
je okjkefjw
mov ax,':C'
cmp ax,ds:[edi]
je okjkefjwr
ereww:
mov ax,1
ret
okjkefjw:
cmp byte ptr ds:[edi-1],20h
jne ereww
mov ax,0
ret
okjkefjwr:
cmp byte ptr ds:[edi-1],20h
jne ereww
mov bx,0
jmp okjkefjw
cmpmot2 endp


reelentier proc
pushad
mov ecx,ds:[taille1]
mov esi,offset bufferfichier
boucled:
mov ah,0eh
mov al,ds:[esi]
cmp al,'.'
jne okefe
mov ax,2020h
mov ds:[esi],ax
okefe:
inc esi
dec ecx
jnz boucled
popad
ret
reelentier endp

affiche proc
pushad
mov ecx,ds:[taille1]
mov esi,offset bufferfichier
boucle:
mov ah,0eh
mov al,ds:[esi]
inc esi
pushad 
int 10h
popad
dec ecx
jnz boucle
popad
ret
affiche endp





_TEXT   ends


;=== GLOBALS
;=== Data Includes
_DATA   segment use32 dword public 'DATA'

;=== DATA

handle DW 0
filename db "o.asc",0
nom1 db "Vertex ",0
nom2 db "Face ",0
nom3 db "A:",0
nom4 db "B:",0
nom5 db "C:",0
temp1 db 70 dup(0)
temp2 db 70 dup(0)
temp3 db 70 dup(0)

handle1 dw 0
handle2 dw 0
handle3 dw 0
memoire1 dw 0

taille1 dd 0
taille2 dd 0
taille3 dd 0

bufferfichier db 800000 DUP('$')
bufferfichier2 db 10000000 DUP('$')


_DATA   ends

_stack   segment para stack 'STACK'
        db 1000h dup(?)
_stack   ends

END START
