Title "bios Forever coded for #coders 256 byte demo comeptition 1997 by DA·AT"
.386                                   
.387                                   
locals                                 
Main segment use16 "code" para                               
assume cs:Main                                               
assume ds:Main                         
assume es:Main                                            
assume fs:nothing                      
assume gs:nothing
Data03 = 169h
org 100h                               
Start:                                     
                                                                   
;------------------------------------------
;Clear palette                             
;------------------------------------------
        
        xor ax,ax
        mov cx,256*3
        mov dx,3c8h
        out dx,al  
        inc dx     
BlackLoop:             
        out dx,al      
        loop BlackLoop 
              
;------------------------------------------
;Do some precalc
;------------------------------------------
                             
        finit                           ;Init FPU
PreCalc:                                                     
        fldpi                           ;Load Pi
        fild    [M128]                     
        fdiv                            ;Pi/128 = One degree                 
        mov     bx,offset Table1
CalcInner:                                     
        fld     st(0)                   
        mov     [Tmp],cx                
        fimul   [Tmp]                   
        fsincos                         ;Cos in st(0) Sin in st(1)
        fiadd   word ptr ds:[Data03]                        
        fimul   [M16]                                       
        fistp   word ptr [bx]           ;Save lenght in mem                                                   
        fimul   word ptr ds:[Data03]                        
        fimul   word ptr [bx]                               
        inc     bx                   
        inc     bx                  
        fistp   word ptr ds:[bx]        ;Save in mem
        wait                             
        mov     dx,[bx]                  
        add     dx,(198)                 
        sub     dx,[bx-2]                
        imul    dx,dx,3                  
        mov     [bx],dx                  
                                         
        inc     bx                          
        inc     bx                          
                                         
        inc     cl                      ;cl=256=0
        jnz     CalcInner               
                                                 
                                                 
;------------------------------------------      
;Precalc done                           
;------------------------------------------      
;Beginning of inner loop                
;------------------------------------------      
                                                 
assume ds:nothing                       
assume es:nothing                          
YVar = 400h                             
        cld                             
                                        
        mov     ax,cs                          
        add     ax,400h/16              
        mov     ds,ax                   ;DS 1:st table
        add     ax,400h/16                         
        mov     es,ax                   ;ES 2:nd table
                                
                                        
        xor     bx,bx
CalcO:
;------------------------------------------      
;Calc screen
;------------------------------------------      
        xor     ax,ax                   ;Fill pal-table with 0
        mov     di,ax                   ;ES:0 = CS:800h
        mov     cx,(400*3/2)                    
        rep     stosw                           
                                                
        mov     cx,3                    ;R,G,B  
CalcI:  push    cx                              
        mov     di,ds:[bx+2]            ;Y      
        add     di,cx                   ;R,G,B=0,1,2
        dec     di                              
                                                
        xor     cx,cx                   ;loop from 0        
CalcUp:                                             
        call    SC                                  
        inc     cx                                  
        cmp     cx,[bx]                             
        jne     CalcUp                  ;to half height 
                                                        
        mov     cx,[bx]                 ;And down from half height
CalcDn:                                                           
        call    SC                                                
        loop    CalcDn                  ;To 0
                                                  
        add     bx,16*4                 ;Next bar 16 deg away
        and     bx,03ffh                ;wraparound at 400h        
        pop     cx                                         
        loop    CalcI                                      
                                                           
        sub     bx,(16*4*3)             ;Restore bx (deg)  
        and     bx,03ffh                ;wraparound at 400h
                                        
;------------------------------------------       
;Type char
;------------------------------------------       
        push    bx                      
        shr     bx,2                    
        and     bx,0111b                              
        mov     ah,0eh                            
        mov     al,cs:[bx+offset Text]            
        xor     bx,bx                             
        int     10h                               
        pop     bx                                
                                                  
;------------------------------------------       
;Draw screen
;------------------------------------------       
                                                  
                                                  
Vret:   mov     dx,3dah                 ;Wait for screen update        
@@2:    in      al,dx                                          
        test    al,08h                                         
        jz      @@2                                            
                                                               
                                                               
                                                    
        mov     si,400h                           
        cli                                       
DrawI: Hret:                            ;Wait for next line           
@@1:    mov     dx,3dah                                    
        in      al,dx                                          
        test    al,1                                           
        jnz     @@1                                        
@@2:    in      al,dx                                          
        test    al,1                                           
        jz      @@2                                        
                                                                
Setpal: mov     dx,3c8h                 ;Modify backgound colour
        xor     al,al                                                  
        out     dx,al                                                  
        inc     dx                                                     
        mov     cx,3                    ;Set R,G,B
        rep     outsb                                                  
        cmp     si,8b0h                                                
        jnz     DrawI                   ;repeat 8b0h-400h times (400*3)
        sti                                                     

        add     bx,4                                            
        and     bx,03ffh                                        
                                                                
        mov     ah,01                   ;Check for keypress
        int     16h                                        
        jz      CalcO                                      
        int     20h                                        
                                                           
sc proc near                            ;SC - sets a colour in the table
        mov     ax,cx                                
        mov     dl,63                                                         
        mul     dl                                         
        div     byte ptr [bx]           ;Loop*63/Half height                   
        mov     es:[di],al                                  
        add     di,3                    ;3 bytes/pal-entry
        ret     
endp sc                                                    
                                                           
                                                           
                                                           
;-----------------Data--------------------                 
        M128    DW 128                                     
        M16     DW 16                                      
        Text    DB '-DA·AT- '                              
        Tmp     DW ?                                       
                                                           
        org 400h                                           
        Table1  DD 256 DUP (?)
        org 800h                                           
        Table2  DB (400*3) DUP (?)
Main ends                                                  
end Start                                                  
                                                                                  
                                                                      
                                                                        

