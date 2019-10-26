;께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께�
;              
; Source code for fire compo on #coders.
; Kinda wiered fire implementation, but i wanted very hot fire,
; and seems that i got it :), Looks almost as sun crown. :-)
; A bit messy and not really optimized,but thats one night code and it works.
;              
; By Adept/ESTEEM,1996.
;                      
; Greatings fly to:
;   Altair,Aphelion,Brazil,Crest,DeathScar,Eckart,Fatslayer,Gaffer,Goblin,
;   Jare,Jmagic,Jugi,Kalms,Lewis-PF,Mali,Mikma,Mr_P,Mr_Z,OCoke,Onyx,OsPepsi,
;   PGeist,Thingy,Vastator,Zhorlack,Xanthome...  Am i forgot someone?
;   And all cool guys on #coders.
;                     
;께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께�
.model tiny           
.386
                                                                            
;.stack 1024	      	; enable it if u don`t want annoying "no stack" msg.
                                                                            
MaxColor  equ 	255                                                         
                                                                            
.code                                                                       
org 100h                                                                    
                                                                            
SetPalette    	macro                                                       
     	mov cx,MaxColor                                                     
     	mov bx,03F3Fh                                                       
     	mov [R],bl                                                          
@@ColorLoop:                                                                
	cmp cx,125                                                          
 	jg @@PutColor                                                       
    	cmp cx,95
     	jl @@32
     	sub bl,2 
     	jmp @@PutColor
@@32:	cmp cx,64
 	jl @@0   
    	dec bh   
      	jmp @@PutColor
@@0:	sub [R],1
     	cmp cx,32
     	jl @@PutColor
     	dec bh
@@PutColor:           
  	mov dx,03C8h  
 	mov al,cl                  
    	out dx,al                  
	inc dx                     
	mov al,[R]                 
 	out dx,al                  
 	mov al,bh
	out dx,al
	mov al,bl
	out dx,al                  
	dec cx                     
	jnz @@ColorLoop            
endm                               

Fire	macro
	mov di,319
	xor dx,dx
@@LoopX:
	in al,040h
	add bx,ax
	mov byte ptr [di+64000],255
	mov cl,al    
	and cl,63        
	test bx,64                
     	jne @@Skip                
     	mov [di+64000],dl
     	test di,1                        
     	je @@Skip                        
     	test di,4                 
     	je @@Skip                 
	push bx      
 	add cl,192   
 	and bx,2047
 	mov [bx+di+64000-320*5],cl
     	pop bx
@@Skip:	dec di   
      	jnz @@LoopX
 	mov cx,44800 
 	mov di,19200          
	xor ax,ax
@@Loop1:                      
	mov al,[di+319]   	; mov al,[di+319]
	mov dl,[di+3*320] 	; mov dl,[di+320]
	add ax,dx    
    	mov dl,[di+321]  	; mov dl,[di+321]
 	add ax,dx      
	mov dl,[di]                              
	add ax,dx    
	sub ax,4
	shr ax,2     
	jz @@SkipPut 
	cmp al,MaxColor
	jb @@ALColor 
	mov al,MaxColor           
@@ALColor:
   	mov [di],al  
@@SkipPut:                        
       	inc di                    
	dec cx                    
   	jnz @@Loop1               
   	mov cx,(44800-5*320)/2
   	mov di,19200+5*320
 	mov si,19200              
   	rep movsw    
endm                   
                       
Start:	mov ax,13h     
	int 10h        
	mov ax,cs    
	add ax,1000h   
	mov ds,ax
	mov es,ax
	mov bx,64000
@@RandLoop:        
	in al,040h 
	add cl,al
	mov [bx],cl
	dec bx       
	jnz @@RandLoop
	
	push 0A000h         
	pop es              
 	SetPalette          
@@FireLoop:                 
 	Fire                
	in al,60h           
	cmp al,1            
	jne @@FireLoop      
                            
@@End:  mov ax,3            
	int 10h             
;      		mov ax,4c0fh	; Must be enabled for exe.
;     		int 21h
       	int 20h      
                     
R	db    	?    
	             
	end    	Start