;#########################################################################
;	 	        ASC to DW file (for HxCIntro 2001 Intro)
;				a86 16bit version
;                          by Del Nero Jean Francois 
;                               (c)  HxC 2001
;                              www.powerofasm.fr.st
;                          jeanfrancoisdelnero@libero.it
;				  13/12/2001
;#########################################################################

jmp init

start:

mov ax,cs
mov ds,ax

mov ah,48h
mov bx,4096
int 21h
jc errorfe
mov ds:[memoire1],ax
mov es,ax


mov ah,3dh
mov al,0
mov dx,offset filename
int 21h
jc errorfe
mov ds:[handle1],ax

mov ah,3fh
mov bx,ds:[handle1]
mov cx,64000
mov dx,offset bufferfichier
int 21h
jc errorfe
mov ds:[taille1],ax


mov ah,3eh
mov bx,ds:[handle1]
int 21h

call reelentier
call supxyz

call supvetrex
call classage

call affiche


;mov dx,offset bufferfichier
;;mov si,dx
;add si,ds:[taille1]
;mov al,'$'
;mov ds:[si],al
;mov ah,9
;int 21h

mov ax,es
mov ds,ax
xor dx,dx
mov ah,9
int 21h


mov ax,4c00h
int 21h




errorfe:
mov ax,4cffh
int 21h





classage proc
pusha
mov cx,ds:[taille1]
mov di,offset bufferfichier
xor si,si

boucleclacage:
push si
mov si,offset nom2  ;face
call cmpmot ;si=source di=dest
pop si
cmp ax,0
jne suitefdgdhrthtjjjjjj

        mov bx,0ffffh
        bouclec2:
        call cmpmot2 ;si=source di=dest  ;A: B: C:
        cmp ax,0
        jne suitefjj
           push di
            push cx
             call copynb
               mov di,offset bufferfichier
                boucleaaaaaaa:

                push si
                mov si,offset temp1
                call  cmpmot
                pop si

                cmp ax,0
                jne suitehgfth
                  call copyligne
                  inc di
                 jmp finctyt
                suitehgfth:
                inc di
                jmp boucleaaaaaaa
               finctyt:
             pop cx
           pop di

        suitefjj:
        inc di
        dec cx
        jz finboucleclacage

        cmp bl,0
        jne bouclec2

    mov ax,'wd'
    mov es:[si],ax
    add si,2
    mov al,' '
    mov es:[si],ax
    inc si  
    mov ax,'55'
    mov es:[si],ax
    add si,2
    mov ax,'00'
    mov es:[si],ax
    add si,2
    mov al,'h'
    mov es:[si],al
    inc si
    mov al,10
    mov es:[si],al
    inc si
   ; mov al,13
   ; mov es:[si],al
   ; inc si
    
    mov word ptr es:[si+1],'$'

suitefdgdhrthtjjjjjj:
inc di
dec cx
jnz boucleclacage
finboucleclacage:
popa
ret
classage endp

copyligne proc
   mov es:[si],'wd'
   add si,2
   mov es:[si],2020h
   add di,5

   bouclecopy2:
   mov al,ds:[di]
   mov es:[si],al
   inc si
   inc di
   cmp al,13
   jne bouclecopy2
   mov al,10
   mov es:[si],al
   inc si
   mov al,'$'

   mov es:[si],al
   mov es:[si+2],al
   mov es:[si+4],al
   mov es:[si+6],al

ret
copyligne endp

copynb proc
  push si
   add di,2
   mov si,offset temp1
   bouclecopy2f:
   mov al,ds:[di]
   mov ds:[si],al
   inc si
   inc di
   cmp al,20h
   jne bouclecopy2f
   dec si
   mov al,':'
   mov ds:[si],al
  inc si
   mov al,0
   mov ds:[si],al

  pop si
ret
copynb endp


supvetrex proc
pusha
mov cx,ds:[taille1]
mov di,offset bufferfichier
mov si,offset nom1
boucledweb:
call cmpmot ;proc  ;si=source di=dest
cmp ax,0
jne suitefdgdhrtht
mov ds:[di],'wd'
mov ds:[di+2],2020h
mov ds:[di+4],2020h

suitefdgdhrtht:
inc di
dec cx
jnz boucledweb

popa
ret
supvetrex endp

supxyz proc
pusha
mov cx,ds:[taille1]
mov si,offset bufferfichier
boucledb:
mov ax,ds:[si]
cmp ax,':X'
jne okefe1
mov ax,2020h
mov ds:[si],ax
okefe1:
cmp ax,':Y'
jne okefe2
mov ax,' ,'
mov ds:[si],ax
okefe2:
cmp ax,':Z'
jne okefe3
mov ax,' ,'
mov ds:[si],ax
okefe3:

inc si
dec cx
jnz boucledb
popa
ret
supxyz endp


cmpmot proc  ;si=source di=dest
pusha
bouclejfke:
mov al,ds:[si]
cmp al,0
je okjkefj
cmp al,ds:[di]
jne finrkegnklr
inc si
inc di
jmp bouclejfke
finrkegnklr:
popa
mov ax,1
ret
okjkefj:
popa
mov ax,0
ret
cmpmot endp


cmpmot2 proc  ;di=dest
mov ax,':A'
cmp ax,ds:[di]
je okjkefjw
mov ax,':B'
cmp ax,ds:[di]
je okjkefjw
mov ax,':C'
cmp ax,ds:[di]
je okjkefjwr
ereww:
mov ax,1
ret
okjkefjw:
cmp byte ptr ds:[di-1],20h
jne ereww
mov ax,0
ret
okjkefjwr:
cmp byte ptr ds:[di-1],20h
jne ereww
mov bx,0
jmp okjkefjw
cmpmot2 endp


reelentier proc
pusha
mov cx,ds:[taille1]
mov si,offset bufferfichier
boucled:
mov ah,0eh
mov al,ds:[si]
cmp al,'.'
jne okefe
mov ax,2020h
mov ds:[si],ax
okefe:
inc si
dec cx
jnz boucled
popa
ret
reelentier endp

affiche proc
pusha
mov cx,ds:[taille1]
mov si,offset bufferfichier
boucle:
mov ah,0eh
mov al,ds:[si]
inc si
push cx
int 10h
pop cx
dec cx
jnz boucle
popa
ret
affiche endp




datae:
filename db "o.asc",0
nom1 db "Vertex ",0
nom2 db "Face ",0
nom3 db "A:",0
nom4 db "B:",0
nom5 db "C:",0
temp1 db 50 dup(0)
temp2 db 50 dup(0)
temp3 db 50 dup(0)

handle1 dw 0
handle2 dw 0
handle3 dw 0
memoire1 dw 0

taille1 dw 0
taille2 dw 0
taille3 dw 0

bufferfichier db 60000 DUP(0)



Init:
  mov ah, 4Ah   ; fonction 4Ah de l'interruption 21h
                ; REAJUSTER LA TAILLE D'UN BLOC MEMOIRE

  mov bx, offset fiin + 512 ; BX re‡oit l'offset de la fin du programme
                      ; (pile de 256 mots comprise)

  add bx, 40          ; Ajouter quelques octets pour arrondir la valeur
                      ; au paragraphe suivant (16 octets par paragraphe)

  mov cl, 4           ; on va diviser par 16 la valeur obtenue dans BX
  shr bx, cl          ; c'est un d‚calage de BX de quatre bits vers la droite
  inc bx              ; on rajoute un paragraphe
  int 21h             ; appel de l'interruption

  mov sp, offset fiin + 512; On place le pointeur de Pile (SP = Stack Pointer)
                      ; … la fin du programme
                      ; ATTENTION : EN GENERAL, ON NE TOUCHE *JAMAIS*
                      ; … SP sauf pour bidouiller :-)

  jmp start           ; Retourner au d‚but du programme


  ; { r‚server de quoi mettre un pile de 256 mots (512 octets) }
  ; { et on enlŠve le code commen‡ant aprŠs init car on en a   }
  ; { juste besoin au d‚but du programme                       }

init_fin label near

 ; dw (64-((init_fin - init) shr 1)) dup (?)
fiin equ this byte



