;       
;       flashy stars 128b demo
;       ----------------------
;                             
;       programmer:     Axel Lindholm aka. ElMaco
;                       <axel.lindholm@swinet.se>
;                                                
;       thanks to KranK for helping me shrink the size to 128b
;                                                             
;       sorry about this uncommented piece of crap code, but i
;       feel totally exhausted after shrinking it from 192b...
;         
                                                              
 	code	segment                                       
        .386                                                  
 	assume	cs:code, ds:code                              
        org     100h                                          
                                                              
start:                                                        
        push    videoseg                                      
        pop     es                                            
                                                              
        mov 	al,13h                                        
    	int 	10h                                           
                                                              
        mov     cl,4                                          
@makecolor:                                                   
        mov     al,10                                         
        imul    cx                                            
        add     al,20                                         
        mov     ah,cl                                         
        xchg    al,ah                                         
        mov     dx,3c8h                                       
        out     dx,al                                         
        inc     dx                                            
        xor     al,al                                         
        out     dx,al                                         
        out     dx,al                                         
        mov     al,ah                                         
        out     dx,al                                         
        loop    @makecolor                                    
                                                              
        mov     ah,2ch                                        
        int     21h                                           
        mov     bp,dx                                         
                                                              
@mainloop:                                                    
 	mov	cx,videosize                                  
                                                              
        push    ds                                            
        push    es                                            
        pop     ds                                            
@dec_loop:                                                    
        mov     di,cx                                         
        mov     si,cx                                         
        lodsb                                                 
        test    al,al                                         
        jz      @@nochange                                    
        dec     al                                            
        stosb                                                 
@@nochange:                                                   
        loop    @dec_loop                                     
        pop     ds                                            
                                                              
        add     bp,bp                                         
        xor     bp,dx                                         
        rol     bp,5                                          
                                                              
        mov     di,bp                                         
        mov     si,bp                                         
        mov     dx,bp                                         
        add     dx,957                                        
        mov     bx,dx                                         
        add     bx,6                                          
        add     si,1920                                       
        mov     cl,4                                          
@ds_loop:                                                     
        mov     al,4                                          
        sub     al,cl                                         
        push    di                                            
        stosb                                                 
                                                              
        mov     di,si                                         
        stosb                                                 
        mov     di,dx                                         
        stosb                                                 
        mov     di,bx                                         
        stosb                                                 
                                                              
        pop     di                                            
        dec     bx                                            
        inc     dx                                            
        mov     ax,320                                        
        sub     si,ax                                         
        add     di,ax                                         
                                                              
        loop    @ds_loop                                      
                                                              
 	mov 	ah,1                                          
 	int 	16h                                           
 	jz 	@mainloop                                     
                                                              
@quit:                                                        
	mov 	ax,3h                                         
   	int	10h                                           
 	ret                                                   
                                                              
 	videoseg     	equ 0a000h                            
   	videosize    	equ 0fa00h                            
                                                              
code ends                                                     
end start 