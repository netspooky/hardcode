; Wormie. Programmed March 1997 by Aquanaut / JUNK Productions
; Assembled with TASM


.MODEL TINY     
                           
.486                                                         
                      
ORG 100h              
LOCALS               
                       
.CODE                                          
.STARTUP                                                       

	a_up	=	72
	a_left	=	75
	a_right	=	77    
	a_down	=    	80
        
        chrofs	=	chr2-chr1
                                 
                                  
	push	0a000h		; VGA seg in es
	pop	es                             
                                               
    	lea	si,chr1+1       ; Ptr to first score                             
                                 
StartLoop:                       
        mov	ax,13h          ; VGA Mode 13h
 	int	10h             ; This also clears the screen              
	                                                     
	mov    	bx,320                                       
                                                               
        xor	di,di           ; Draw a line in the top                                
        mov	cx,bx                                        
        mov	al,01                                        
        rep	stosb                                        
                                                               
	mov	cl,(200-8-1)-2  ; Draw the lines in left and right                          
SideLoop:
     	mov	es:[di],al                                   
	mov	es:[di-bx-1],al                              
	add	di,bx                                        
	loop	SideLoop                                     
                                
	mov	cx,bx		; Draw a line in the bottom           
	rep	stosb           
                                
        mov	di,320*100 + 20 ; Load pointers to the head of the worms
        mov	bp,320*100 + 300                                   
                                                                   
 	mov	ax,(a_left shl 8) + 'D'   ; Initial keys pressed                         
 	                                                           
GameLoop:                                                      
                                       
; Process keys - update worm positions
Keys:                                  
	cmp 	al,'A'                 
	jne 	@@not_a                
	dec	di                                           
	jmp	Arrows   	                   
@@not_a:                                       
                                       
 	cmp	al,'D'                 
 	jne	@@not_d                
	inc	di                             
	jmp	Arrows   	               
@@not_d:                               
                                                               
     	cmp	al,'S' 
	jne	@@not_s                
	add	di,bx                  
	jmp	Arrows      	                               
@@not_s:             
                        
	cmp	al,'W'                 
	jne	@@not_w                     
	sub	di,bx                  
	jmp	Arrows   	               
@@not_w:                                                     
                                                   
	mov	al,dl     	; The key was not 'AWSD' - load the old key 
	jmp	Keys            ; and process again
Arrows:                                            
                                                   
	cmp	ah,a_right                         
	jne	@@not_right                        
	inc	bp     	                           
	jmp	EndKeys   	                               
@@not_right:                                       
                                                   
	cmp	ah,a_left                          
	jne	@@not_left                                     
	dec	bp                                 
	jmp	EndKeys   	                   
@@not_left:                                        
                                                   
	cmp	ah,a_up                            
	jne	@@not_up                           
	sub	bp,bx                                        
	jmp	EndKeys   	                   
@@not_up:                                      
                                      
	cmp	ah,a_down             
	jne	@@not_down            
	add	bp,bx                          
	jmp	EndKeys   	               
@@not_down:                           
	mov	ah,dh           ; The key was not an arrow-key - load the                               
 	jmp	Arrows          ; old key and process again      
                                                           
EndKeys:                                                   
 	mov	dx,ax           ; Save keys                               
                                                           

                                                           
 	mov	cx,2            ; popped in here to preserve 2 in cx
 		     	 	; and to use it in the pushpop loop
                                                           
 	pusha		                   
                                           
	mov	bx,cx           ; for later ...          


; wait a bit ...                                           
 	mov	ah,86h                                       
 	xor	cx,cx                      
; 	mov	dx,15000      	; Here we use the backup keys instead ... ;-)
 	int	15h                        
                                           
; set cursor pos for first chr                                 
                      
	mov 	ah,02h      
 	mov	dx,(24 shl 8) + 0
 	int	10h	; bx = 2
                                                                   
                       
;write score          
chr1:	mov	ax,09h shl 8 + '0'
	inc	cx   	; cx = 1 ; bx = 2
	int     10h
                                                               
;set cursor pos for second chr 
	mov	ah,02h
  	mov	dx,(24 shl 8) + 39
	int	10h     ; bh = 0
                      
;write score          
chr2: 	mov	ax,09h shl 8 + '0'          
 	mov     bl,4              
	int     10h	; cx = 1 ; bx =2
 	                       
  	popa                   
                                  
; Test if the worms collides with something / update score ...
 	                                      
 	or	es:byte ptr[di],ch	; ch = 0
 	je	@@NL1                                          
 	inc	byte ptr[si+chrofs]           
@@Jmp_Start:
 	jmp	StartLoop                      
                                              
@@NL1: 	                                      
	or 	es:byte ptr[bp],ch                                 
  	je	@@NL2            
 	inc	byte ptr[si]                  
 	jmp	@@Jmp_Start                    
@@NL2: 	                                      
                                              
; This makes sure that at least one of the scores are always 0

	cmp 	byte ptr[si],'0'  
	je	@@no_adjust                   
 	cmp	byte ptr[si+chrofs],'0'                        
     	je	@@no_adjust                                    
                                                               
	dec	byte ptr[si]                                   
	dec	byte ptr[si+chrofs]                            
     	                                                       
@@no_adjust:	                                               
                                                               
; have we got a ... WINNER ?                                   
                                                               
 	cmp	byte ptr[si],'9'+1                               
 	je	TheEnd                                           
                              			; cx = 2                                 
	mov	es:byte ptr[di],cl		; draw 1st worm
	                                                       
	mov	cl,04                                          
 	cmp	byte ptr[si+chrofs],'9'+1                        
 	je 	TheEnd                                           
                                                               
        mov	es:byte ptr[bp],cl              ; draw 2nd worm               
                                       
; test om der er trykket p† en taste
CheckKey:              
                                                               
	mov	ah,01
	int	16h                            
 	jnz	Getit

; Clear the crap that the key-check might return ...                                            
 	xor  	ax,ax    
Jmp_Game:
 	jmp	GameLoop  
          
GetIt:                                               
; Get the key from the buffer
	xor	ah,ah
     	int	16h

; remove the shift-bit !! (make 'awsd' in capitals)
     	and	al,11011111b

; If ESC was pressed - quit the game         
	xor	cx,cx       	; black border
    	cmp	al,''          
	jne	Jmp_Game
                        
TheEnd:                                                          
                                                                   
; textmode                        
	mov ax,03h                          
	int 10h
                            
; set the border-color from the value of bx
 	mov	bx,cx   
	mov	ah,0bh    
	int     10h

; ***
; In the other version the coloring goes like this:
                            
;    	mov	bh,cl
; 	mov	ax,1000h
; 	int     10h  
; ***  
                     
         ret
                     
ENDS                    
                        
END                 
