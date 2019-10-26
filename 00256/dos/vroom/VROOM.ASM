; VROOM.ASM
; This is my contribution to the 256 Byte Game Contest
; This program is freeware.You may distribute this program anywhere you want.
; To contact me, try: pcmaniac@nuxes.frmug.fr.net
; I hope you'll enjoy it

   .386P

o equ <offset>
b equ <byte ptr>
w equ <word ptr>

Gauche  equ <4bh>
Droite  equ <4dh>
BORD    equ '²'
VOITURE equ '^'
LONGMUR equ 7

LONGECR equ 39
HAUTECR equ 24

code segment para public use16
   assume cs:code,ds:code
   org 100h
Start:

   mov ax,0001h             ; CGA 40*25 16coul
   int 10h
   
   mov ah,0bh
   mov bx,0009h
   int 10h                  ; border bleu
   
   mov ax,0040h
   mov fs,ax
   
   mov ah,2ch
   int 21h
   mov u.seed,ax
   
   mov ax,0b800h
   mov es,ax

Bcle:
   mov ax,fs:[1ch]
   mov w fs:[1ah],ax                   ; on ecrase le buffer clavier

   call rand
   test al,1
   jnz krk

   mov di,PosMur                       ; on le met au milieu du chemin
   mov ax,1 + 7 shl 8                  ; Un p'tit obstacle !
   stosw
krk:

   call rand
   test al,1                           ; Une chance sur deux !
   jnz jkjk

   add PosMur,2                        ; on va a droite
   cmp PosMur,2*LONGECR
   jl suite
   
   sub PosMur,2
   jmp suite
jkjk:
   sub PosMur,2                        ; on va a gauche
   jns suite
   add PosMur,2


; *** L'affichage ***

suite:
   mov di,PosMur
   sub di,2*LONGMUR
   mov ax,BORD + 7 shl 8
   stosw                               ; affichage mur gauche
   add di,2*2*LONGMUR
   stosw                               ; affichage mur droite

   mov di,2*(LONGECR+1)*(HAUTECR-1); test de collision (ligne 23 => la ligne
   add di,Pos                      ; du dessus car l 24 non scroll‚e !)
   cmp b es:[di],20h               ; c'est un blanc ?
   jne stop                        ; non ? donc collision

   mov ah,86h
   xor cx,cx
   mov dx,0f000h
   int 15h                         ; on attend f000h microsec.
   
   in al,60h
   

   cmp al,1
   je stop

   cmp al,Gauche
   jne jgpig
   sub b Pos,2
   jmp continue
   
jgpig:
   cmp al,Droite
   jne continue
   add b Pos,2

continue:
; affichage de la "voiture"

   mov ax,0701h
   xor cx,cx
   mov dh,HAUTECR-1
   mov dl,LONGECR+1
   mov bh,07h
   int 10h    ; decale ecran 1 ligne vers le bas (jusqu'a ligne 23 et pas 24)

   mov di,2*(LONGECR+1)*HAUTECR    ; derniere ligne
   push di
   mov cx,LONGECR+1
   mov ax,0700h
   rep stosw               ; on efface toute la ligne 24
   pop di
   add di,Pos
   mov ax,'^' + 7 shl 8 
   stosw                   ; on ‚crit la voiture
   jmp Bcle

Stop:
   mov ax,0003
   int 10h
   mov ax,4c00h
   int 21h

rand:
   mov     ax,u.seed
   imul    k1
   add     ax,k2
   mov     u.seed,ax
   ror     al,1
   rol     ah,1
   xor     al,ah
   retn

;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
Pos     dw (LONGECR+1)            ; pos voiture
PosMur  dw (LONGECR+1)            ; milieu du mur

k1      dw      9821
k2      dw      1


undef STRUC
seed    dw      ?
ends
;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
u label undef

code    ends
end     Start
