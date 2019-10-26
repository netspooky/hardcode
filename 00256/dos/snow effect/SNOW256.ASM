;snow effect by spoook (spoook@hotmail.com) for the 256b compo at #coders..
;I know I don't have much of a chance to win, but I thought it was fun 
;participating..took my about 3 hours.. please send me a note about anything!
;Compile with:
;tasm snow /m
;tlink snow /t

.model tiny
.code                                        
.386                                         
org 100h       
assume cs:@code
start:         
mov ax, 13h                                  
int 10h                                      
push 0a000h             ;push & pop's saves 1 byte
pop es                                            
                                                              
xor si, si      
mov cx, maxflakes                                              
CreateFlake:                                                  
        mov bx, 320
        call random                                           
        mov [Snow.x+si], dx                                   
        call random
        mov [snow.y+si], dx
                
        mov bx, 20
        call random        
        mov [snow.xcounter+si], dl           
                                             
        mov byte ptr [snow.switch+si], 0
        mov bx, 3                            
        call random                     
        inc dl                          
        mov byte ptr [snow.yv+si], dl
                                                              
add si, SnowStrucSize                                         
loop Createflake
                                                              
heppa:                                                        
call movesnow              
call displaysnow           
 
mov cx, 3  
            
mov Cx,65400
Delayer:       
call draw_flake
loop delayer
                     
 
                        
 
                 
in al, 60h                                                    
cmp al, 129                                                   
jne heppa                   
                            
                                                              
slut:                                                         
mov ax, 3h                                                    
int 10h                                                       
mov ax, 4c00h                                                 
int 21h                                                       
                                                              
displaysnow:                                                  
xor si, si                                                    
mov cx, maxflakes
viewsnow:                                                     
mov ax, [snow.y+si]                                           
mov di, ax                                                    
shl di, 6                                                     
shl ax, 8                                                     
add di, ax                                                    
add di, [snow.x+si]                                           
                 
mov al, 15                                                              
call draw_flake  
                 
mov [snow.old+si], di                                         
                                                              
add si, SnowStrucSize                                         
loop viewsnow    
ret                                                           
                                                              
moveSnow:       
mov cx, maxflakes                                              
xor si, si                                                    
AdvanceSnow:                                              
mov di, [snow.old+si]                                     
xor ax, ax                                                
call draw_flake                                           

        cmp [snow.xcounter+si], 0
        ja  dont_reset                       
        ;ifall det „r tid att byta h†ll
        mov [snow.xcounter+si], 10
                   
        cmp [snow.switch+si], 0              
        jne decca                            
        inc [snow.switch+si]                 
        jmp hoo                              
        decca:                               
        dec [snow.switch+si]
        hoo:  
                                       
        dont_reset:                          
        dec [snow.xcounter+si]               
        cmp [snow.switch+si], 1              
        je add_one                            
        dec [snow.x+si]
        je forrs
        add_one:       
        inc [snow.x+si]
        forrs:  
                       
        dec [snow.x+si]                      
        mov al, [snow.yv+si]                                  
        add [snow.y+si], ax                                   
                                                              
add si, SnowStrucSize                                         
loop advancesnow      
ret                                                           
                                                              
random:         ;input: cx=highest number, output: dx=randomnmb
        mov     ax,seed
        add     ax, 7495                                       
        ror     al, 1                                         
        mov     seed, ax                                      
        xor     dx, dx
        div     bx                                            
ret                                                           
                                                              
         
                                                              
         
draw_flake:               
mov byte ptr es:[di], al
mov byte ptr es:[di+1], al
mov byte ptr es:[di-1], al
mov byte ptr es:[di+320], al
mov byte ptr es:[di-320], al
ret                                                     
                                                              
                                                              
Snow_struc STRUC                                              
x dw ?                                                        
y dw ?                                                        
z dw ?                                                        
                                                              
xcounter db ?   ;xcounter =+ 1 om switch = 1 else xcounter=- 1
switch db ?     ;0 eller 1                   
                                             
yv db ?                                      
old dw ?                                     
Snow_struc ends                              
                                             
SnowStrucSize = 11                           
                                             
MaxFlakes equ 200                            
                                             
Seed    dw      0fe1ch         
                                             
Snow            Snow_Struc MaxFlakes Dup (<>)                                         
end start
