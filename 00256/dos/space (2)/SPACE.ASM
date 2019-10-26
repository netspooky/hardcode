;  space - The Immaculate contribution to the 256-bytes space invader compo.
;  Made by Zaifrun & Phluph of Immaculate in 1998.
;  Contact: Zaifrun@geocities.com or Phluph@geocities.com
;  Compile with : "Tasm thesnake /m2"                            
;  Link with    : "Tlink thesnake /t"                            
;  We used Tasm 4.0 and Tlink 6.0 to make this space invader game.
;  Sorry, but the code is not too documented yet - please mail if you find
;  any space optimizations that we didn't see.
;  move with ',' (left) and '.' (right) use space to shot - esc to quit
;  Total code size = 256 , data size = 0
               
   
ideal
model tiny
p386
   
bptr equ byte ptr
wptr equ word ptr
dptr equ dword ptr
maxmonster = 16
  
codeseg
org 100h 
  
  
startupcode
; code begins
  mov  al,13h  			; ah = 0 from start - length of command line 
  int  10h     			; ah = hi byte of length, al = low
  push 0A000h
  pop  ds
  push ds
  pop  es
  mov  bp,101101111011010b 	; register with living monsters (1=alive)
  xor  bx,bx   			; bx = monster start offset
  mov  si,62880 		; si = player start offset
  xor  di,di    		; di = shot offset - 0 = no shot
  mov  dx,0108h
 @mainloop:                
  mov  cl,2                
  pusha                    
  @l3:                     
  mov  dx,3DAh                  ; Wait for a vertical retrace to happen
@l1:                            ; This takes 13 bytes
  in   al,dx                    ; we could have used function nr. 86h
  and  al,08h                   ; of interrupt 15h (casette) to do
  jnz  @l1                      ; a delay - that would have taken just 9
@l2:                            ; bytes - but there will be some jerky
  in   al,dx                    ; movement once every 70th frame due
  and  al,08h                   ; to non-synchronization with screen
  jz   @l2                           
  loop @l3
  mov  ah,7dh                        
  xchg ax,cx                         
  xor  di,di   
  rep  stosw   
  out  61h,al     		; sound off - al is zero
  popa                                                    
       	 			; update monster - move it
  movsx ax,dh                                             
  add  bx,ax                                              
                                                          
                                                          
  push  bx                  
  mov   al,63               
  and   bl,al               
  xor   bl,al               
  pop   bx                  
  jne   @nope               
  mov   dh,-1  			; Set monsters to move left
  @nope:                                                   
  and  al,bl                                               
  or   al,al                                               
  jnz  @nope2                                              
  mov  dh,1			; Set monsters to move right
  @nope2:
  mov  al,bl                                               
  and  al,8                                                
  cmp  al,dl                                               
  jne  @nix                                                
  add  bx,320                                              
  xor  dl,8                                                
  @nix:
  ; draw monsters
  xor  ax,ax
  pusha    
  @monsterloop:
  mov  ecx,3535352fh
  bt   bp,ax
  jnc  @drawfini		; We draw the colored sprites using the
  mov  [bptr bx+2],cl		; compiled sprite method.
;  mov  [bptr bx+3],cl   	; alternative gfx
  mov  [dptr bx+320],ecx        
  mov  [bptr bx+324],cl         
  mov  [wptr  bx+641],cx        
  mov  [bptr bx+643],cl         
  mov  [bptr bx+962],cl         
  ;  mov  [bptr bx+1282],cl 	; alternative gfx
  @drawfini:                    
  add  bx,16                    
  inc  ax                       
  cmp  al,16                    
  jb   @monsterloop
  ; draw player
  mov  [si+639],ecx
  mov  [si+320],cl
  mov  [si],cl			; could delete this for slightly worse gfx
      				; but you can't do much with 2 bytes anyway
  popa
           
  ; draw shot  
  cmp   di,si  
  ja   short @dontdraw
  mov   [bptr di],al  		; al = 0
  sub   di,960  
  cmp   [bptr di],40
  mov   ax,320
  jb    @nohit
           
  ; collision - monster killed?
  mov   cx,di                  
  sub   cx,bx     
  @difagain:      
  sub   cx,ax     
  jg    @difagain 
  add   cx,ax     
  shr    cx,4     
                  
    
  btr    bp,cx     		; saves 4 bytes
  xor    di,di   		; init new shot
  mov    al,11b                 
  out    61h,al  		; Do some sound
  jmp    @dontdraw              
  @nohit:                       
  mov   [bptr di],cl  		; maybe use another color??
  @dontdraw:  
              
 ; collision - you are dead!
  cmp   bx,si
  ja    short @quit		; quit the game
  ; all monsters died?
  ;or   bp,bp      		; no check
  ;je    short @quit  
       
  ; check keyboard
  mov  ah,1  
  int  16h   
  jz   @next2
  xor  ah,ah 
  int  16h   
  cmp  al,1Bh  			; esc
  je   short @quit              
  cmp  al,20h  			;space - shot
  jne  @noshot
  cmp  di,si 
  jb   @noshot
  mov  di,si 
  @noshot:   
  cmp   al,2Ch  		; left - ,
  jne   @next                   
  cmp   si,62725                
  jbe   @next                  
  sub   si,8                  
  @next:                        
  cmp   al,2Eh  		; right - . 
  jne   @next2              
  cmp   si,63034           
  jae   @next2            
  add   si,8             
  @next2:               
  jmp   @mainloop		; guess what
 @quit:                                            
  mov   ax,3h    		; restore text mode
  int   10h
  ret         			; exit
end          
             
  
