;
;   16 bytes and less
;   Fun...sort of
;
;   

; You know this bit...
        mov al,13h                
        int 10h                   
        les bp,[bx] 

DEMO:              
       
; sin wave...sort of 
;	stosb 
;       rcl al,cl
;       loop DEMO
;	mov cx,di
        

; busy street...sort of
;        stosb
;        xchg [es:di], al            
;        add ax,di
;        sar ax,1         
 

; 3D panning...sort of    
;	stosb
;        adc al,ch
;        loop DEMO
;        xor cx,di
;        stc
        

; rotzoomer...sort of
        xchg [es:di], al            
        adc ax,di
        dec di 

        
        jmp short DEMO                  
