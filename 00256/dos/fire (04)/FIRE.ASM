;_.,-'`^`'-,._.,-'`^`'-,._.,-'`^`'-,._.,-'`^`'-,._.,-'`^`'-,._.,-'`^`'-,.
;                                                                       . 
;                                     FIRE                              . 
;                                  By Deep One                          . 
;                   For "Gaffer's 256 byte and under" FIRE compo        . 
;                                     1996                              . 
;                                                                       .
;_.,-'`^`'-,._.,-'`^`'-,._.,-'`^`'-,._.,-'`^`'-,._.,-'`^`'-,._.,-'`^`'-,.
;                                                                        
;                                                                        
;                                                                        
;                                         
;                                                           
Fireprogram segment para public                
assume cs:Fireprogram, ds:Fireprogram    
.386
ORG 100h                                 
Start:                                   
        mov al, 13h                            ; Set mode 13h
        int 10h                                              
        xor cx, cx                             ; Set the palette              
        xor ax, ax                                              
        xor bx, bx                             ; Black to blue              
@@1:                                                          
        push bx                                               
        shl bl, 1                                             
        call Setpal                                           
        pop bx                                                
        inc bl                                                
        inc cx                                                
        cmp cx, 9   
        jne @@1                                ; Blue to a darkred
@@2:                                                       
        pusha                                              
        shl al, 1                                        
        mov bl, 16                                      
        sub bl, al                                      
        call Setpal                                   
        popa                                          
        inc al                                                  
        inc cx                                      
        cmp cx, 17d                               
        jne @@2                                  
        mov bh, 24d                              
        mov ah, 47d                             
        xor al, al   
@@3:                                            ; darkred to lightred
        pusha                                                        
        imul ah                                                      
        idiv bh                                                      
        add al, 16                                                   
        xor ah, ah                                                   
        xor bl, bl                                                   
        call setpal                                                  
        popa                                                         
        inc al                                                       
        inc cx                                                       
        cmp cx, 41d                                                  
        jne @@3                                                      
        mov ah, 31d                                                  
        xor al, al                                                   
@@4:                                                                 
        pusha                                    ; lightred to yellow                      
        imul ah                                                      
        shr ax, 4                                                    
        mov ah, al                                                   
        mov al, 3fh                                                  
        xor bl, bl                                                   
        call setpal                                                  
        popa                                                         
        inc al                                                       
        inc cx                                                       
        cmp cx, 74d                                                  
        jne @@4                                                      
        mov ah, 21d                                                  
        xor al, al                                                   
@@5:                                             ; yellow to white                    
        pusha                                                        
        imul ah                                                   
        shr ax, 3                                                 
        mov bx, ax                                                
        mov ax, 3f3fh                                             
        call setpal                                               
        popa                                                      
        inc al                                                    
        inc cx                                                    
        cmp cx, 99d                                               
        jne @@5                                                   
        mov ax, 3f3fh                                             
        mov bl, 3fh                                               
@@6:                                             ; lots of white                 
        call setpal                                               
        inc cx                                                    
        cmp cx, 255d                                              
        jne @@6                                                 
        mov ax, 0a000h                           ; stick segment of video               
        mov es, ax                               ; in es                        
MainLoop:                                                       
        mov cx, 320d                             ; set di to end of screen               
        mov di, 64640d                           ; stick number of pixels to                         
Looper:                                          ; write in cx
        mov ax, [seed]                           ;-           
        mov dx,8905h                             ; ]              
        mul dx                                   ; ]-- random routine              
        inc ax                                   ; ]                 
        mov [seed], ax                           ; -                 
        cmp dl, 0FFh                             ; give fire a little bit more
        jl looper                                ; height.
        mov al, dl                               ;          
        stosb                                    ; write al to screen         
        dec cx                                   ; write 320 pixels in all                             
        jnz Looper                                                        
        mov cx, 16640d                           ; set di near end of screen
        mov di, 48320d                           ; and set pixels to write at
        xor ax, ax                               ; 16640.
Loop2:                                                   
        mov al, es:[di+640]                      ; -       
        adc al, es:[di+321]                      ;  ]  
        adc al, es:[di+319]                      ;  ]-- Average pixels below 
        adc al, es:[di+320]                      ;  ]                       
        shr ax, 2                                ; -                        
        jz dontputdot                            ; if ax=0 then dont put a dot                           
        dec al                                   ; on the screen else stick one                            
        stosb                                    ; on                            
        jmp CarryOnWithFire                      ;     
dontputdot:                                               
        inc di                                   ; do 16640 pixels
CarryOnWithFire:                                 ;                
        dec cx                                       
        jnz Loop2                                    
        mov ah, 01h                              ; keypressed ??????    
        int 16h                                                     
        jz MainLoop                              ; if not back for another run                   
        mov ax,0003h                             ; otherwise its we're outa here                             
        int 10h                                                                 
        ret               
Setpal proc                                      ; sets palette where cl=colour
        pusha                                    ; al=r                              
        mov dx, 03c8h                            ; ah=g      
        xchg al,cl                               ; bl=b      
        out dx, al                               ; may not be too good but i      
        inc dx                                   ; needed it to use up as little                           
        xchg al, cl                              ; bytes as possible
        out dx, al                                                  
        mov al, ah                                                  
        out dx, al                                                  
        mov al, bl                                                  
        out dx, al                                                  
        popa                                                        
        ret                                                         
Setpal endp                                        
seed dw 1234h                                    ; seed for random number 
Fireprogram ends                                 ; generator                         
end Start                                          
