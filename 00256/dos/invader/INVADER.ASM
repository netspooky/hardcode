;hEY! THIS Code Will prObaBly be unreadable And eVen WRONG but it WaS Only 
;MeanT TO Be a ProtOtypE uNtil my owN deaDlIne Won ver Me! soRry!
;ThE comMments anD conStants Are jUst weIrD!

code   segment para public 'code'
.386                                      
.model tiny                               
assume cs:code,ds:code                    
org    100h                               
                                          
rows   equ    80*2                               
cols   equ    2                           
                                          
monrow equ    5                           
monno  equ    10                          
                                          
monmov equ    30             
monsiz equ    monno*2*cols   
monwid equ    monmov+monsiz/2                                           
monmrg equ    (80-monwid)/2  
                                                                      
moncrd equ    2*rows+monmrg*cols                                      
                                                                      
monpos equ    -monmov        
                       
plypos equ    24*rows+39*cols
plysiz equ             5*cols         
lftbrd equ    24*rows+ 1*cols
rghbrd equ    24*rows+78*cols  
                               
                                                                      
start:                                                                
;init screenmode               
       mov    ax,3                           ;set screen mode         
       int    10h                            ;mode 3=80*25,16 cols,text
                                                                       
;init segments                  
       push   0b800h                                                  
       pop    es                             ;es is screen segment    
       push   40h                                                     
       pop    gs                             ;gs is bios segment      
                                                                      
;clear with zeros!   
       xor    ax,ax  
       mov    di,ax    
       mov    cx,ax  
       dec    cx       
       rep    stosb  
                         
;init monsters
       mov    dx,monpos                      ;dx counts direction of monsters
                                
;draw monsters                  
       mov    ax,0505h
                      
       mov    di,moncrd                      ;monster1 coord
monsters:                                                             
       mov    cx,monno                       ;monsters pr. row                           
       rep    stosd                          ;store the number of monsters
                     
       add    di,rows*2-monsiz               ;di coord of the row 2 below!
       sub    ax,0101h                       ;increase color and char by 1
       jnz    monsters                       ;and go to next line!
                                                                  
;init player                                  
       mov    si,offset ship                 ;[ds:si] points to ship!  
       mov    di,plypos-plysiz/2+1           ;[es:di] points to playerpos!
                                                                          
moveship:                                                                 
       mov    ah,01                          
       int    16h                            
       jz     nokey                          
       cmp    ah,4Bh                         
       jne    notleft                        
       cmp    di,lftbrd           
       jbe    notleft                        
       dec    di                             
       dec    di                             
notleft:                                     
       cmp    ah,4Dh                         
       jne    notright                       
       cmp    di,rghbrd-plysiz    
       jae    notright                       
       inc    di                             
       inc    di                  
notright:                         
       cmp    ah,39h              
       jne    notspace            
       xchg   di,bx  
       mov    word ptr es:[di],0
       mov    di,bx               
       sub    bx,1*rows-plysiz/2+1
notspace:                         
       cmp    ah,01h              
       je     quit                
                                  
;clear buffer                     
       mov    ax,0c00h            
       int    21h                 
nokey:                            
                                  
;test GameOver                             
       pusha                      
       mov    cx,1*rows           
       mov    di,23*rows          
       xor    ax,ax               
       repz   scasb               
       jcxz   nodont              
       popa                       
       jmp    short Quit
nodont:                           
       popa                           
;draw ship                        
       pusha         
       mov    cx,5    
shipl: movsw         
       dec    si       
       loop   shipl   
       popa                       
                                  
;delay                            
       mov    ax,word ptr gs:[6Ch]
       cmp    word ptr ds:[100h],ax          
       jae    moveship            
;       inc    ax
       mov    word ptr ds:[100h],ax
                                  
;move monsters                    
                          
       shr    ax,1
       jnc    move_shot  
       pusha                      
                       
       mov    di,bx    
       xor    ax,ax    
       stosw                  
                       
       std                          
       mov    di,24*rows+1*cols     
       mov    si,24*rows            
       mov    cx,23*rows            
       or     dx,dx                 
       jnz    testsign              
       mov    si,23*rows            
testsign:                           
       jle    negative              
       xor    di,di                 
       mov    si,2                  
       cld                          
negative:                           
       cmp    dx,-29                
       jne    goon                  
       mov    si,80*23*2            
goon:                               
       rep    movs byte ptr es:[si],es:[di]
       cmp    dx,30               
       popa                       
       jne    nope                
       neg    dx                  
nope:                                        
       inc    dx                  
       cld                        
                      
move_shot:             
       cmp    byte ptr es:[bx],'.'
       jne    dont_delete_it
       mov    word ptr es:[bx],0       
        
dont_delete_it:                         
       sub    bx,1*rows                
       jo     noscr                    
       cmp    byte ptr es:[bx],0       
       je     noharm                   
       mov    word ptr es:[bx],0       
noscr: xor    bx,bx                    
       jmp    short wieder             
noharm:                
       mov    word ptr es:[bx],'.'+700h
                              
wieder:                                
       jmp    moveship           
                                 
quit:                            
       retn                      
                                              
                                              
ship   db     0,9,6,9,6,0
                                 
code   ends                      
       end    start