;(C) 2000 Pajda
;266


SirkaVlajky        equ 200
VyskaVlajky        equ 120

code segment
assume cs:code,ds:code,es:code
org 0100h
.386
;----------------------------------------------------------------------------
Start:             pusha
                   mov ch,29600/256
Decompress:        mov si,offset Sin
Decompre00:        lodsb
                   neg al
                   mov byte ptr ds:[si+32],al
                   loop Decompre00
                   mov al,013h
                   int 010h
                   popa
;----------------------------------------------------------------------------
SetPal00:          mov dx,03c8h                  ; Nastavi paletu barev
                   out dx,al                     ;
                   inc dx                        ;
SetPal01:          xchg ax,bx                    ;
                   out dx,al                     ;
                   out dx,al                     ;
                   xchg ax,bx                    ;
                   out dx,al                     ;
                   inc ax                        ;
                   inc ax                        ;
                   cmp al,64                     ;
                   jb SetPal01                   ;
SetPal02:          out dx,al                     ;
                   xchg ax,bx                    ;
                   out dx,al                     ;
                   out dx,al                     ;
                   xchg ax,bx                    ;
                   inc ax                        ;
                   inc ax                        ;
                   cmp al,128                    ;
                   jb SetPal02                   ;
SetPal03:          out dx,al                     ;
                   out dx,al                     ;
                   out dx,al                     ;
                   inc ax                        ;
                   inc ax                        ;
                   cmp al,196                    ;
                   jnz SetPal03                  ;
;----------------------------------------------------------------------------
CZFlag:            mov di,offset Obr             ;
                   inc bh
                   push di                       ;
                   mov ch,VyskaVlajky/2          ;
                   mov al,96-17+8                ;
                   rep stosb                     ;
                   mov al,64-17+8                ;
                   mov ch,VyskaVlajky/2          ;
                   rep stosb                     ;
                   pop di                        ;
                   mov al,32-17+8                ;
                   inc cx                        ;
CZFla00:           pusha                         ;
                   rep stosb                     ;
                   popa                          ;
                   add di,bx                     ;
                   inc cx                        ;
                   cmp cx,((VyskaVlajky)/2)+1    ;
                   jb CZFla00                    ;
CZFla01:           pusha                         ;
                   rep stosb                     ;
                   popa                          ;
                   add di,bx                     ;
                   loop CZFla01                  ;
                   push 0a000h
                   pop es
;----------------------------------------------------------------------------
Vst0:              mov di,1650                   ;
                   xor cx,cx                     ;
Vst1:              mov bx,cx                     ;
                   add bx,bp                     ;
Vst3:              mov al,byte ptr ds:[Sin+bx]   ;
                   sub al,16
                   cbw                           ;
                   sar ax,1                      ;
                   mov word ptr ds:[AddSIY],ax   ;
                   push di
                   cwd                           ; xor dx,dx
Vst4:              mov bx,dx
                   add bx,bp                     ;
Vst6:              mov al,byte ptr ds:[Sin+bx]   ;
                   sub al,8                      ;
                   cbw                           ;
                   add ax,cx                     ;
                   jl Vst7                       ;
                   cmp ax,SirkaVlajky            ;
                   jge Vst7                      ;
                   mov si,ax                     ;
                   xchg ax,bx                    ;
                   add bx,bp                     ;
;----------------------------------------------------------------------------
Vst6C:             mov al,byte ptr ds:[Sin+20+bx];
                   mov bx,dx                     ;
                   db 081h,0c3h                  ;
AddSIy:            dw ?                          ; add ax, ????
                   jl Vst7                       ;
                   cmp bx,VyskaVlajky            ;
                   jge Vst7                      ;
                   shl bx,8                      ;
                   add si,bx                     ;
                   add al,byte ptr ds:[si+offset Obr];
                   jmp Vst8                      ;
Vst7:              mov al,0
Vst8:              stosb
;----------------------------------------------------------------------------
                   add di,319                    ;
                   inc dx                        ;
                   cmp dl,VyskaVlajky+16         ;
                   jb Vst4                       ;
                   inc cx                        ;
                   pop di
                   inc di                        ;
                   test cl,3                     ;
                   jnz Vst9                      ;
                   add di,320                    ;
Vst9:              cmp cl,SirkaVlajky+16         ;
                   jb Vst1                       ;


Wait00:            mov ah,086h
                   xor cx,cx
                   mov dh,50000/256
                   int 015h
                   inc bp


Vst10:             in al,60h                     ;
                   dec al                        ;
                   jnz Vst0                      ;
;----------------------------------------------------------------------------
Konec:             ret                           ;
;----------------------------------------------------------------------------
Sin:               
                   db 1 dup (0)
                   db 1 dup (1)
                   db 1 dup (2)
                   db 2 dup (3)
                   db 2 dup (4)
                   db 2 dup (5)
                   db 3 dup (6)
                   db 3 dup (7)
                   db 4 dup (8)
                   db 3 dup (7)
                   db 3 dup (6)
                   db 2 dup (5)
                   db 2 dup (4)
                   db 2 dup (3)
                   db 1 dup (2)
                   db 1 dup (1)

SinX:              db 30000 dup (?)
Obr:               db 256*VyskaVlajky dup (?)    ;
code ends
end Start