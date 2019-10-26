ideal
p386
model tiny

CODESEG
ORG 100h
start: ASSUME es:@code 
       ASSUME ds:@code
    
     mov al,13h 
     int 10h

; clear array 
     mov di, offset FireArray    
     sub ax, ax
     mov ch, 126
     rep stosw

; palette
     mov dx, 03C8h
     out dx, al   ;start color
     inc dx
     mov cx, 256
@@setPal:
     mov ax, 256
     sub al, cl
     shr al, 2
     out dx, al
     shr al, 1
     out dx, al
     shl al, 1
     out dx, al
     dec cx
     jnz short @@setPal
    
; write creds in array
     mov dx, offset credits
     mov ah, 09h
     int 21h        ; print

     push ds
; copy to array
     mov di, offset firearray+640
     sub si, si
     push 0A000h
     pop ds
     mov ch, 12    ; 3200/256
@@sprloop:    
     mov al, [ds:si]
     cmp al, 0
     jz short @@plotspr
     mov ax, cx
     shr ax, 4
     mov [ds:si], al
     add al, 49
     dec di
     stosb
@@plotspr:     
     movsb
     dec cx
     jnz short @@sprLoop
 
     pop ds
     
;----------------------------
@@MainLoop:
; do soft/fire/whatever
     mov di, offset FireArray+3840
     mov cx, 64000-3200-3840 
     sub ax, ax
@@Looper:
     mov al, [es:di-320]
     mov bl, [es:di+320]
     add ax, bx
     mov bl, [es:di+1]
     add ax, bx
     mov bl, [es:di-1]
     add ax, bx
     shr ax, 2
     inc ax
     stosb
     dec cx
     jnz short @@Looper
      
; update scroll
     mov di, offset firearray+320
     mov si, offset firearray+321
     mov ch,12; 2880
     rep movsb
; fix the sideeffect at the 319th row
     mov di, offset firearray+3199+320
     mov si, offset firearray+3199
     mov cl, 10
@@moveDown:
     movsb
     sub di, 321
     sub si, 321
     dec cx
     jnz short @@moveDown

; big scrolly in the middle
     mov di, offset firearray+75*320+80
     mov si, 640
     mov dx, 640+80
     mov cl, 11
@@midScrolly:
@@oneRow:     
     movsw
     dec si
     cmp si, dx
     jl short @@oneRow
     add di, 800
     add dx, 320
     add si, 240
     dec cx
     jnz short @@midScrolly

; blit to screen
     push es
     mov si, offset firearray
     sub di, di
     push 0A000h
     pop es
     mov ch, 125   ;cx=32000
     mov dx, 03DAh
@@VSync:
     in  al, dx
     test al, 08h
     jz short @@VSync
     rep movsw
     pop es

     ; one frame done - check if any key pressed (not reset or power :))
     mov ah, 01h
     int 16h
     jz @@MainLoop

;Get out
     mov ax, 0003h 
     int 10h
     
     int 16h
     
     mov ah, 09     
     mov dx, offset credits+7
     int 21h    
    
     mov ah, 4ch
     int 21h

credits    db "FYSK - Coded by Jinesra.",36
FireArray  db 320*200+320 dup(?)

end start
