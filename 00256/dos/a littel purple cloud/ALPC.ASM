        .MODEL TINY
        .386
        .DATA
text    db '*duolc elprup lettil A*'
;            A littel purple cloud       
y       db 1 dup(?)
        .code
        org 100h

START:

        mov al,13h
        int 10h

        mov ax,0a000h
        mov es,ax


        mov cl,222         ;   detta
lo3:    mov al,cl          ;   „r
        mov ah,cl          ;   till
        shr ah,2           ;   att
        mov bh,ah          ;   st„lla
        mov bl,0           ;   in
        CALL SetPal        ;   palletten
        loop lo3           ;   som
                           ;   jag
        mov al,7           ;   vill
        mov ah,63          ;   ha
        xor bx,bx
        CALL SetPal        ;   /GoSuB


        mov ch,0fah        ; samma sak som mov cx,64000 fast en byte mindre
        mov si,word ptr [y]
        add si,10000
lo:     mov bx,cx
        mov al,[si+bx]
        cmp al,100
        jb fixa
on:     mov es:[bx],al
        loop lo


        mov cl,7
lo2:    pusha
      mov dx,ds        ; h„r b”rjar interpoleringen
      mov ax,0A000h
      mov ds,ax
      xor si,si
      newpixel:
        xor ah,ah
        xor bh,bh
        mov al,[si+319] 
        mov bl,[si+320] 
        add ax,bx       
        mov bl,[si+321] 
        add ax,bx       
        mov bl,[si]     
        add ax,bx
        shr ax,2      
        jz @dont_dec
        dec al      
        @dont_dec:
        mov [si],al           
        inc si        
      jnz newpixel  
      mov ds,dx        ; h„r slutar interpoleringen
        popa
        loop lo2

        mov cl,24
rensa:  CALL delay
        CALL scroll
        loop rensa

        mov cl,23
        mov ah,02h
lop:    mov bx,23
        sub bx,cx
        mov dl,[text+bx]
        int 21h
        CALL delay
        CALL scroll
        mov dl,8
        int 21h 
        loop lop

avslut: xor     ax,ax
        int     16h
        mov     ax,3
        int     10h

        mov cl,25
        mov ah,02h
lopa:   mov bx,cx
        sub bx,2
        mov dl,[text+bx]
        int 21h
        loop lopa
        
        ret


fixa:   add al,120
        jmp on

SetPal  PROC NEAR   ; al = farg      ah = r”d      bl = gr”n      bh = bl†
        mov dx,3C8h
        out dx,al
        inc dx
        mov al,ah
        out dx,al
        mov al,bl
        out dx,al
        mov al,bh
        out dx,al
        ret
SetPal  ENDP


delay   PROC NEAR   ; sl”ar ner 5 hundradels sekunder p† ett ungif„r..
        pusha
        mov ah,2ch  ; med andra ord.. det g†r 20 s†na h„r p† en sek...
        int 21h
        mov bl,dl
lo1:    int 21h
        cmp dl,bl
        je lo1
        popa
        ret
delay   ENDP

scroll  PROC NEAR
        pusha
        mov ax,0701h
        xor cx,cx
        mov dh,24
        mov dl,0
        int 10h
        popa
        ret
scroll  ENDP


END START
