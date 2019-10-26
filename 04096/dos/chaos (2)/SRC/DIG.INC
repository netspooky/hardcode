 a = 01111011b ;bitmasks for the 7-segment digital letters
 b = 01111111b ;each bit represents one segment (only bit 0-6 are used)
 c = 00101101b ;this is easyer for writing text                                                        
 d = 01111101b                                            
 e = 00101111b                                            
 f = 00101011b                                            
 g = 01101101b                                            
 h = 01111010b                                            
 i = 00101000b                                            
 j = 01110100b                                               
 k = 01101011b                                            
 l = 00101100b                                            
 m = 01111001b                                            
 n = 01100010b                                            
 o = 01111101b                                            
 p = 00111011b                                            
 q = 01111101b                                            
 r = 01111011b                                            
 s = 01001111b                                            
 t = 00101001b                                            
 u = 01111100b                                            
 v = 01111100b                                            
 w = 01100100b                                            
 x = 01111010b                                            
 y = 00111010b                                            
 z = 01110111b                                            
_1 = 00101000b                                            
_2 = 00110111b                                            
_3 = 01010111b                                               
_4 = 01011010b                                            
_5 = 01001111b                                            
_6 = 01101111b                                            
_7 = 01011001b                                            
_8 = 01111111b                                            
_9 = 01011111b                                            
_0 = 01111101b                                            
                                                          
                                                          
label vd byte      ;image of a vertical segment
include "vdig.inc"                                        
                                                          
label hd byte      ;image of a horizontal segment                                       
include "hdig.inc"                             
                                               
screenseg dw 0a000h                            
                                                          
proc show_v           ;shows a vertical segment on a 320*200 screenbuffer
  mov si,offset vd    ;image adress in si                                                  
  mov cl,28           ;vertical length                                      
    y_loop:                                               
      mov ch,7        ;horizontal length                                      
      xloop:                                            
        mov bl,[ds:si];get image pixel                                  
        test bl,255   ;check if it's 0                                  
        jz vbl_null                                     
        shl bl,1      ;if not:increase the color number a little                                  
        add bl,20                                               
        or [es:di],bl ;an write it to the destination via "or"
        vbl_null:                                             
        inc si        ;move the 'scanner'                                  
        inc di        ;next pixel                  
        dec ch                                 
        jnz xloop                              
      add di,313      ;new line                
      dec cl                                   
      jnz y_loop                               
  ret                                                        
endp                                           
                                               
proc show_h           ;shows a horizontal segment  
  mov si,offset hd    ;same as above, but in horizontal direction
  mov cl,7                                              
    hy_loop:                                   
      mov ch,55                                
      hxloop:                                  
        mov bl,[ds:si]                         
        test bl,255                            
        jz hbl_null                            
        shl bl,1                               
        add bl,20                              
        or [es:di],bl                          
        hbl_null:                              
        inc si                                 
        inc di                                 
        dec ch                                 
        jnz hxloop                                           
      add di,265                               
      dec cl                                   
      jnz hy_loop                              
  ret                                                            
endp                                                             
proc gen_letter        ;generates a 7-segment letter, bitmask in bh
  push si                                                          
  test bh,1            ;bit 0 set ?                              
  jz s0                                                          
  push di              ;yes, show upper horizontal segment       
  add di,3                                                       
  call show_h                                                    
  pop di                                                         
                                                                 
  s0: test bh,2        ;bit 1 set ?                              
  jz s1                                                          
  push di              ;yes, show middle horizontal segment            
  add di,(320*27)+3                                              
  call show_h                                                    
  pop di                                                         
                                                                 
  s1: test bh,4        ;bit 2 set ?                              
  jz s2                                                          
  push di              ;yes, show lower horizontal segment       
  add di,(320*54)+3                                              
  call show_h                                                    
  pop di                                                         
                                                                 
  s2: test bh,8        ;bit 3 set ?                              
  jz s3                                                          
  push di              ;yes, show upper left vertical segment              
  add di,320*3                                                   
  call show_v                                                    
  pop di                                                         
  s3: test bh,16       ;bit 4 set ?                              
  jz s4                                                          
  push di              ;yes, show upper right vertical segment       
  add di,(320*3)+54                                              
  call show_v                                                    
  pop di                                                         
  s4: test bh,32       ;bit 5 set ?                              
  jz s5                                                          
  push di              ;yes, show lower left vertical segment    
  add di,320*30                                                  
  call show_v                                                    
  pop di                                                         
  s5: test bh,64       ;bit 6 set ?                              
  jz s6                                                          
  push di              ;yes, show lower right vertical segment   
  add di,(320*30)+54                                             
  call show_v                                                    
  pop di                                                         
  s6: pop si                                                     
  ret                                                            
endp                                                             
proc pufferclear       ;clear the buffer                                           
  mov ax,[cs:speichers]                                          
  mov es,ax                                                      
  xor eax,eax                                                    
  xor di,di                                                      
  mov cx,16000                                                   
  rep stosd                                                      
  ret                                                            
endp                                                             
proc pr_string                ;prepares a complete digital string
  push eax                    ;si points to it, the first byte is the length                                    
  mov bx,cs                   ;the following bytes are 7-segment-bitmasks 
  mov ds,bx                                                      
  mov al,[ds:si]              ;get the length                                    
  inc si                                       
  _letter_loop: mov bh,[ds:si];get a letter         
    call gen_letter           ;show it             
    inc si                    ;make si point to next letter         
    add di,64                 ;move di one 'letter' to the right                             
    dec al                                                      
    jnz _letter_loop          ;until the string's end         
  pop eax                                        
  ret                                           
endp                                            
proc prep_string              ;same as pr_string, but the fontbuffer is               
  push eax                    ;cleared before              
  push di                                      
  call pufferclear                             
  pop di                                       
  mov bx,cs                                    
  mov ds,bx                                    
  mov al,[ds:si]                               
  inc si                                       
  letter_loop: mov bh,[ds:si]                 
    call gen_letter                          
    inc si                                   
    add di,64                                
    dec al                                   
    jnz letter_loop                          
  pop eax                                    
  ret                                        
endp                                         
show db 0                     ;variable used to control if write_string
                              ;shows or hides the string in the fontpuffers
proc write_string             ;shows/hides the fontbuffers                 
  test [cs:show],255          ;show=0                                            
  jz shows_                                                               
  mov ax,[cs:speichers2]      ;no, hidebuffer
  jmp hides_                                                              
  shows_:                                                
  mov ax,[cs:speichers]       ;yes, showbuffer                    
  hides_:                                         
  mov ds,ax                                       
  mov ax,[cs:screenseg]                           
  mov es,ax                                       
  mov di,64000                                    
  copy_loop:                                      
    mov al,[ds:di]                                
    test al,255                                   
    jz ist_null                                   
    test [cs:show],255        ;show=0                           
    jz addy                                                     
    neg al                    ;no, hide the buffer              
    addy:                                                       
    add [es:di],al            ;thats the secret of the glassfont                
    ist_null:                                                   
    dec di                                                      
    jnz copy_loop                                               
  ret                                                           
endp                                                            
