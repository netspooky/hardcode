; SIRDS Piece Of Shiite
; by danslemur (nick@jtan.com)
; for EFnet #asm compo 7 - Make a 256 byte intro for 386/486 class PC's
;
; I got bored and didn't fill in the whole 256 bytes. It's 185 bytes now. Eh!
;
; Thanks to:
; - Razzia for his helpful size optimization post on www.movnet.org/forum,
; - matja for showing me a better way to write a 4x4 block to the buffer,
; - Consub/CSB for the source to his Chaos demo which I borrowed the pseudo-
; random routine from c/o Assembly Gems
; - Gareth Richards' old FAQ on SIRDS, from which I adapted an algorithm for
; ASCII text stereograms for graphics.
; (http://www.nottingham.ac.uk/~etzpc/oldfaq.html)
; - the rest of you crazy #asm kids
; - Copious amounts of Old Style Beer
; - SLUTZ


; initial assumed conditions:
; ds = cs
; es = cs
; sp = FFFEh


; DEPTH0 has to be even for pseudorandom number generator
%define DEPTH0 16
%define SX     16
%define SY     8
%define SPACE  24

org 100h


   mov fs, sp           ; move sp  = FFFEh in to fs (seed for "random" #)
   
   mov al, 13h
   int 10h


;
;  10 bytes - clearing buffer
;
   push BUFFER
   pop di
   mov cx, 64000                       ; 3 bytes
   xor ax, ax                          ; 2 bytes
   rep stosb                           ; 2 bytes


;
; drawing text to buffer
;
; assume
; ds = cs
; 

   mov ax, 1130h  
   mov bh, 6            ; 8x16 character set  
   int 10h     

   mov di, BUFFER + SY*320 + SX

   mov eax, 01010101h         ; 01 - height of text
   xor bx, bx               

letter:
   mov dh, 16           ; height of character  
   movzx si, [blah+bx]                          
   shl si, 4            ; multiply si by number of bytes in char (16)
row:
   mov dl, 10000000b    ; 8 columns per character
col:
   test [es:bp+si], dl                          
   jz nopixel                                   


; 15 bytes:
   push di              ; thanks to matja - i'm an idiot
   mov cx, 4
l1:
   mov [ds:di], eax
   add di, 320
   loop l1
   pop di
   
nopixel:
   add di, 4            ; location in buffer   
   shr dl, 1            ; location in character definition  
   jnz col                                      

   inc si                                     
   add di, 4*(320-8)       ; 8 = width of character      
   dec dh                                      
   jnz row                                     

;   sub di, 20448-SPACE        ; 4*(16-1)*320 + 4*(8-1) + 4*(320-8) - 4*(8-1) - 28(spacing)
   sub di, 10208 - SPACE
   inc bx
   cmp bl, 5            ; length of string     
   jnae letter                                 

   push 0a000h
   pop es
   xor di, di
   

loop1:

   xor bx, bx           ; zero out the x-coordinate counter
   
;
; assume:
; fs = SEED
; es = 0a000h
; di = 0
; bx = 0
; 

   push di
iloop1:
   mov ax, fs
   mov dl, 13
   mul dx
   xchg ah, al
   stosw
   mov fs, ax
   inc bx
   inc bx
   cmp bl, DEPTH0
   jnz iloop1
   pop di


iloop2:

;
;  stereogram algorithm
;
; assume:
; ds = cs
; variables previously set up:
; es = 0a000h
; bx = x coordinate
; di = y coordinate * 320
; 
   lea si, [di + bx - DEPTH0]
   movzx ax, [ds:si + BUFFER]
   add si, ax           ; assumes ah is 0
   es lodsb             ; we can do this because si is cleared in next step
   lea si, [di + bx]
   mov [es:si], al

;
;  7 bytes - steregram loop counter
;
   inc bx                       
   cmp bx, 320                  
   jnz iloop2                   
   
;
;  8 bytes - line loop counter
;
; assume:
; bx = 320
;
   add di, bx           ; instead of add di, 320
   cmp di, 64000              
   jnz loop1                  


smunkpite1:
   xor di, di
   mov cx, 64000
pixel1:
   mov al, [es:di]
   dec al
   stosb
   loop pixel1
   mov ah, 1
   int 16h
   jz smunkpite1

   mov ax, 03h                ; I keep this in because I'm nice
   int 10h                    

   ret

blah db "SLUTZ"

BUFFER:
