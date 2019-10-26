bob1_x   equ 0
bob1_y   equ 0
bob1_d   equ 2

bob2_x   equ 309
bob2_y   equ 0
bob2_d   equ 3

bob3_x   equ 309
bob3_y   equ 189
bob3_d   equ 0

bob4_x   equ 0
bob4_y   equ 189
bob4_d   equ 1

macro setup_palette ;setup the non-linear palette used for the shitbob
  xor cx,cx                                                           
  mov dx,3c8h                                                         
  xor al,al                                                           
  out dx,al                                                           
  inc dx                                                              
  color_1:                                                            
    dec dx                                                            
    mov al,cl                                                         
    out dx,al                                                         
    inc dx                                                            
    out dx,al                                                         
    xor al,al                                                         
    out dx,al                                                         
    out dx,al                                                         
    inc cl                                                            
    cmp cl,64                                                         
    jne color_1                                                       
  color_2:                                                            
    mov al,cl                                                         
    dec dx                                                            
    out dx,al                                                         
    inc dx                                                            
    mov al,129                                                        
    sub al,cl                                                         
    out dx,al                                                         
    out dx,al                                                         
    mov al,cl                                                         
    sub al,64                                                         
    out dx,al                                                         
    inc cl                                                            
    cmp cl,127                                                        
    jne color_2                                                       
  color_3:                                                            
    mov al,cl                                                         
    dec dx                                                            
    out dx,al                                                         
    inc dx                                                            
    mov al,255                                                        
    sub al,cl                                                         
    out dx,al                                                         
    xor al,al                                                         
    out dx,al                                                         
    out dx,al                                                         
    inc cx                                                            
    cmp cx,256                                                        
    jne color_3                                                       
endm                                                                  
                                                                      
macro showbob               ;guess what...                                           
local schleife_x                                                      
local schleife_y                                                      
  mov fs,di                 ;Show_da_BOB !!!!                         
  mov gs,bx                                                           
  mov ds,cx                                                           
                                                                      
  shl bx,6                  ;increase the color numbers in a 10*10
  add di,bx                                                       
  shl bx,2                           
  add di,bx                          
  mov bx,10                          
  schleife_y:                        
    mov cx,10                        
    schleife_x:                      
      inc [byte ptr es:di]  ;plain 13h
      inc di                  
      dec cx                  
      jnz schleife_x          
    add di,310                
    dec bx                    
    jnz schleife_y            
  mov cx,ds                   
  mov bx,gs                   
  mov di,fs                   
endm                        
  
macro move             ;controls the movement of a bob
local l_wechseln1                                     
local o_wechseln1             
local nicht_null              
local r_wechseln1             
local u_wechseln1             
local links_unten             
local l_wechseln2             
local u_wechseln2             
local rechts_oben             
local r_wechseln2             
local o_wechseln2             
local naechste_runde          
                              
  cmp bp,0                    
  jne nicht_null              
                              
  dec di                ;Bob moves to upper left
  dec bx                                        
  cmp bx,0              ;collision with upper edge ????
  je  o_wechseln1       ;change the direktion                           
  cmp di,0              ;collision with left edge ????
  je  l_wechseln1                                
  jmp naechste_runde                            
  l_wechseln1: mov bp,1 ;change direction to upper right
  jmp naechste_runde                                    
  o_wechseln1: mov bp,3 ;change direction to lower left
  cmp di,0                                              
  jne naechste_runde    
  mov bp,2              
  jmp naechste_runde    
                        
  nicht_null: cmp bp,2   
  ja links_unten        
  jb rechts_oben        
                       
  inc di                ;bob moves to lower right
  inc bx                                         
  cmp di,309            ;collision with right edge ???
  je  r_wechseln1                                     
  cmp bx,189            ;collision with lower edge ???
  je  u_wechseln1                                     
  jmp naechste_runde                                  
  r_wechseln1: mov bp,3 ;change direction to lower left
  cmp bx,189                                           
  jne naechste_runde                                   
  xor bp,bp               
  jmp naechste_runde      
  u_wechseln1: mov bp,1 ;change direction to upper right
  jmp naechste_runde                                    
                                             
  links_unten: dec di   ;bob moves to lower left
  inc bx                                        
  cmp di,0              ;collision with left edge ???
  je  l_wechseln2                                    
  cmp bx,189            ;collision with lower edge ???
  je  u_wechseln2                                  
  jmp naechste_runde                               
  l_wechseln2: mov bp,2 ;change direction to lower right
  cmp bx,189                                            
  jne naechste_runde                                    
  mov bp,1                                              
  jmp naechste_runde                                    
  u_wechseln2: xor bp,bp;change direction to upper left
  jmp naechste_runde                                    
                                                        
  rechts_oben: inc di   ;bob moves to upper right                                 
  dec bx                                         
  cmp di,309            ;collision with right edge ???
  je  r_wechseln2                                     
  cmp bx,0              ;collision with upper edge ???         
  je  o_wechseln2                                     
  jmp naechste_runde             
  r_wechseln2: xor bp,bp;change direction to upper left 
  cmp bx,0                                             
  jne naechste_runde  
  mov bp,3            
  jmp naechste_runde  
  o_wechseln2: mov bp,2 ;change direction to lower right
                                                        
  naechste_runde:                        
endm                                     
                                         
proc sm                 ;not what _you_ may think...
  showbob               ;it's a combination of movement and show !!!                            
  move                                                              
  ret                                                               
endp                                                                
proc show_move          ;this little one shows and moves 4 bobs,                                            
  call sm               ;coordinates are stored in the processor's registers
  bswap ebx                                                                 
  bswap edi                                                         
  bswap ebp                                                         
                                                                    
  call sm                                                           
  bswap ebx                                                         
  bswap edi                                                         
  bswap ebp                              
  xchg eax,ebx                           
  xchg edi,edx                           
  xchg ebp,esi                           
                                         
  call sm                                
  bswap ebx                              
  bswap edi                              
  bswap ebp                              
                                         
  call sm                                
  bswap ebx                              
  bswap edi                              
  bswap ebp                            
  xchg eax,ebx                         
  xchg edi,edx                         
  xchg ebp,esi                         
  ret                                  
endp                                   
                                       
line_ende dw bob4_d                    
counter dw waits                       
                                       
proc moveline          ;moves the bobs from one edge to another, then exits
  mov cx,waits                                                             
  label1:              ;slow the damned shit down, 'caus u should SEE the movement   
  call show_move                                                                  
  dec cx                  
  jnz weiter              
  call waitretrace        
  mov cx,waits            
  weiter:                 
  cmp [cs:line_ende],bp   
  je label1               
  mov [cs:line_ende],bp   
  ret                     
endp

macro swapall           ;swaps all the registers used for bobby storage
  bswap ebx                                                            
  bswap edi                                                            
  bswap ebp                                                            
endm                                                                   
                                                                       
macro initbob           ;initialises the registers with the coords of the                                                 
  mov bx,bob1_y         ;4 bobs                                                  
  mov di,bob1_x                          
  mov bp,bob1_d                          
                                         
  swapall                                
  mov bx,bob2_y                          
  mov di,bob2_x                          
  mov bp,bob2_d                          
                                         
  mov eax,ebx                  
  mov edx,edi                  
  mov esi,ebp                  
  mov bx,bob3_y                
  mov di,bob3_x                
  mov bp,bob3_d                
                               
  swapall                      
  mov bx,bob4_y                
  mov di,bob4_x                
  mov bp,bob4_d                
  mov cx,rot_gelb              
endm