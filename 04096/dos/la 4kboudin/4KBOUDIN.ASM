.model small
.486                
.code                



;fait(1) x = sin (2t) - y = sin (3t) - t de 0 … 10
;fait(3) x = cos(t)^3 - y = sin(t)^3
;x = cos(t)-sin(t)^2 - y = sin(t)cos(t)+sin(t) cardiode
;fait(2) x = sin(10t) - y = cos(9t) ; trop forte
                       
                                                       
;thanks too elendil qui cest bi casser le cul pour m aider
;chojin again ;) panik pour les couleurs ...
;tuo ...       
                     
;di pour la base                                         
        org 100h                                         
debut:                                                   
        jmp start                                        
matrice_rond db ''                  
        db 00000011b,11100000b,00000000b
        db 00001111b,11111000b,00000000b
        db 00011111b,11111100b,00000000b
	db 00111111b,11111110b,00000000b
        db 01111111b,11111111b,00000000b
        db 01111111b,11111111b,00000000b
        db 11111111b,11111111b,10000000b
        db 11111111b,11111111b,10000000b
        db 11111111b,11111111b,10000000b
        db 11111111b,11111111b,10000000b
        db 11111111b,11111111b,10000000b
        db 01111111b,11111111b,00000000b
	db 01111111b,11111111b,00000000b
        db 00111111b,11111110b,00000000b
        db 00011111b,11111100b,00000000b
        db 00001111b,11111000b,00000000b
        db 00000011b,11100000b,00000000b
matrice_equation_parametrique db '' 
        dw (?)                      
                             
t_numerateur    dw 0                                    
t_denominateur  dw 400              
fpu     dw 0                        
x       dw 50                
rouge   db 0       
vert    db 0       
bleu    db 0       
dec_rond_feu    dq 0.01                         
color   db 0                                    
temp    dw 0
y       dw 50                                                             
;mandelbrot                                                               
;color   db 0                                                              
var_zoom    dq 1.5 
a       dw 0                                                              
b       dw 0               
sinadd    dw 0                                                                          
plasma_position dw 0
segment_buffer_logo dw 0
segment_buffer_palette dw 0
segment_buffer dw 0                                                                     
segment_buffer_ecran dw 0                                                               
segment_chr    dw 045bh         ;fct int10h,11h,30h pour retrouver                      
offset_chr     dw 01E12h                                                                             
text_scrolling db 'That''s All Folks ...',255                                                        
text_fin       db 'CoDe : fRogGy                  ',254
               db 'GfX  : IsObeL                  ',254
               db 'ZiK  : Ripped :''((((          ',254
               db 'inJeCtIon ??? A kE zA RulEz oN Zis wORld of lAmhA',255
                                                                                                     
injection_logo db ''                                                                                 
        db 227                                
        db 01111011b,11111111b,11111101b,11111101b,11101110b,11110111b,00111101b,227
        db 01111011b,11111111b,11111101b,01010100b,11001000b,10010101b,10100101b,227
        db 01111011b,11111111b,10001101b,01010100b,11001110b,10010100b,10111101b,227
        db 01111011b,11111111b,11111101b,01010100b,11000010b,10010100b,10100001b,227
        db 01111000b,11110011b,11111101b,01010101b,11101110b,10010111b,10111101b,11000000b,227
        db 01111000b,11110011b,11000001b,01010100b,00000000b,10010000b,227
        db 01111111b,11110011b,11000001b,01010101b,11101110b,10010111b,10111001b,01000000b,227
        db 01111111b,11110011b,11000001b,01010101b,00001010b,10010100b,00100001b,01000000b,227     
        db 01111111b,11110011b,11000001b,01010101b,10001110b,10010101b,10101100b,10000000b,227     
        db 01111111b,11110011b,11000001b,01010101b,00001100b,10010100b,10100100b,10000000b,227     
        db 01111111b,11110011b,11000001b,11111101b,00001010b,11110111b,10111100b,10000000b,227     
        db 00000000b,00000000b,00000000b,00000000b,00000000b,00000000b,00000000b,00001001b,11000000b,227
        db 00000000b,00000000b,00000000b,00000000b,00000000b,00000000b,00000000b,00000000b,01100000b,227        
        db 00000000b,01111111b,11111001b,11100000b,00000000b,00000000b,00000000b,00000001b,10010000b,227        
        db 00000001b,11111111b,10101110b,00011100b,00000000b,00000000b,00000000b,00000000b,11110000b,227        
        db 00000011b,11111111b,11010101b,01110011b,00000000b,00000000b,00000000b,00000000b,00011110b,227        
		db 00000111b,11111111b,11101010b,10000000b,10000000b,00000000b,00000000b,00000000b,00000110b,227
        db 00000110b,00001111b,11010101b,01011111b,01100000b,00000000b,00000000b,00000000b,00000011b,10000000b,227 
        db 00001100b,00000111b,11101010b,10100000b,00010000b,00000000b,00000000b,00000000b,00000011b,11000000b,227
        db 00001000b,00000011b,11110101b,01011111b,11101000b,00000000b,00000000b,00000000b,00000011b,11000000b,227
        db 00001000b,00000011b,11101010b,00110000b,00000100b,00000000b,00000000b,00000000b,00000000b,11000000b,227
        db 00001000b,00000011b,11110101b,00010111b,11111100b,00000000b,00000000b,01000000b,00100001b,11000000b,227
        db 00001100b,00000011b,11101010b,10001000b,00000010b,00000000b,00000000b,10100000b,01010001b,11100000b,227
        db 00000100b,00000011b,11010100b,01001111b,11111110b,00000000b,00000000b,01000000b,00100001b,11100000b,227
        db 00000100b,00000111b,11101010b,00101000b,00000001b,00000000b,00000000b,01000000b,00100000b,11100000b,227
        db 00000110b,00001111b,11010101b,00011111b,11111111b,00000000b,00000000b,01000000b,00100001b,11110000b,227
        db 00000101b,10011111b,10101000b,10001000b,00000001b,00000000b,00000000b,00100000b,01000000b,11100000b,227
        db 00000101b,01111101b,01010100b,01001111b,11111111b,10000000b,00000000b,00100000b,01000000b,11000000b,227
        db 00000110b,10101010b,10101010b,00101000b,00000000b,10000000b,00000000b,00100000b,01000000b,11000000b,227
        db 00000011b,01010101b,01010001b,00011111b,11111110b,10000000b,00000000b,00101111b,01000000b,11000000b,227
        db 00000010b,10101010b,10101000b,10010000b,00000000b,10000000b,00000000b,00110000b,11000000b,01100000b,227
        db 00001001b,00100010b,00100010b,00100000b,00000000b,10000000b,00000011b,11000011b,11110000b,00100000b,227
        db 00001111b,10010001b,00010001b,01111111b,11111000b,10000000b,00000100b,00100111b,11111000b,00100000b,227
        db 00001000b,01001000b,10001000b,10000000b,00000000b,10000000b,00000100b,10100111b,11111000b,00100000b,227
        db 00000101b,10100100b,01000101b,11111111b,11110001b,00000000b,00000101b,10100100b,11001000b,227        
        db 00000100b,00011010b,00100110b,00000000b,00000001b,00000000b,00000100b,00100100b,00001000b,227        
      		db 00000101b,11100111b,11111111b,11111111b,10000001b,00000000b,00000011b,11000010b,00010000b,227
        db 00000010b,00000000b,00000000b,00000000b,00000011b,11111100b,00000010b,00000001b,11100000b,11100000b,227
        db 00011110b,11111111b,11111111b,11111111b,00000010b,00010010b,00001101b,00000000b,01000000b,11100000b,227
        db 00100101b,00000000b,00000000b,00000000b,00000100b,00100001b,11110001b,00000000b,01000001b,11100000b,227
        db 01001001b,01111111b,11111111b,11111100b,00000100b,00100000b,01000001b,00000000b,01111111b,10000000b,227
        db 01001000b,10000000b,00000000b,00000000b,00001000b,00100000b,01000000b,10000000b,10000000b,227
        db 10010000b,01001111b,11111111b,11100000b,00010000b,01000000b,10000000b,01001111b,227  
        db 10000000b,00110000b,00000000b,00000000b,01100000b,00000000b,00000000b,00110000b,227  
        db 10000000b,00001001b,11111110b,00000000b,10000000b,00000000b,00000000b,01000000b,227 
        db 10000000b,00000110b,00000000b,00000011b,00000000b,00000000b,01111111b,10000000b,227 
        db 01111111b,11111111b,11000000b,00011111b,11111111b,11111111b,10000000b,227          
        db 00000000b,00000000b,00111111b,11100000b,227
                                                                                                              
zik     db ''         
include neointro.inc  
                      
;start proc                                                            
start:                                                                    
                                                        
                            
        call initialisation
                 
        call playmusic
                      
        call animation_debut
        call playmusic
                 
        call initialisation_feu
        mov cx,150    
        call playmusic
        call playmusic
        call playmusic
        call playmusic
boucle_feu:           
        call feu      
        call affichage_rond_feu
        loop boucle_feu
      
                      
        call affichage_scroll_fin
        call playmusic
      
fin:                               
        mov ah,49h                 
       mov bx,5000h   
       int 21h        
                      
        call endplayer
                 
       mov ax,04c00h
       int 21h   
                 
                 
affichage_palette proc near
       call clear
        xor bx,bx        
boucle_affichage_palette:
        mov gs:[bx],bx   
        inc bx           
        cmp bx,0FFh      
        jne boucle_affichage_palette
        ret                   
        endp affichage_palette                                      
                        
affichage_rond_feu proc near
        pusha         
        push segment_buffer
        pop fs        
        push segment_buffer_ecran
      		pop ds
                                   
;boucle_tourner_truc_fin:                    
                        
        mov bp,320*199
        mov fpu,20    
        mov di,670    
        fldpi         
                      
boucle_rond_4_2:      
        fld st(0)       
        fadd st(0),st(0)
boucle_rond_3_2:        
        fld st(0)       
        fcos            
        fimul fpu       
        fld st(1)       
        fsin            
        fimul fpu       
        fistp x         
		fistp y
        add x,160       
        add y,99        
        cmp x,40
        jl saut_truc_machin_2
        call position_pixel
        mov dl,fs:[bp]  
        mov ds:[si],dl          ;calculer par position_pixel
saut_truc_machin_2:           
        dec bp    
        fsub dec_rond_feu     
        dec di                
        jnz boucle_rond_3_2
                              
        ffree st(0)           
        fincstp               
        mov di,670
        sub bp,1;320-200  ; a recalculer
        inc fpu   
        cmp fpu,50
		jne boucle_rond_4_2
                                      
        call affichage_buffer_ecran   
                  
        popa                                      
        ret                           
        endp affichage_rond_feu       
                                                                  
affichage_chr proc near                         
;entree:                                                
;       chr en al                               
;       couleur en ch                           
;       es:si destination darrivee              
;sortie:                                
;       affichage chr                   
        pusha                           
        mov di,offset_chr          
        push segment_chr
        pop ds                          
                                        
		xor ah,ah
        shl ax,3                    
        add di,ax       ;en bp l offset du chr
        mov dx,di    
        add dx,8             
;on affiche le chr                  
boucle_affichage:            
        mov al,ds:[di]
        mov bl,10000000b    
boucle_test_chr:                                        
        test al,bl         
        je suite_affichage_chr
        mov es:[si],ch  
suite_affichage_chr:       
        inc si                     
        shr bl,1      
        jnz boucle_test_chr        
        add si,320-8 
        inc di       
        cmp di,dx    
		jne boucle_affichage
                     
        popa                        
        ret                                   
        endp affichage_chr
                                                   
feu     proc near                                  
        pusha                                                   
                  
debut_pouet:                                       
        push es                                    
                  
;definition du foyer
                  
        push segment_buffer
        pop es    
        mov bx, 63360		  ;create random bottom line
again2:           
        in al, 40h
        mul bx
		add al, ah
        sub bx,150
        mov es:[bx], al
        add bx,150
        inc bx   
        cmp bx, 64000
        jnz again2
                 
        push segment_buffer_logo
        pop es   
        mov bx, 63360		  ;create random bottom line
again3:          
        in al, 40h
        mul bx   
        add al, ah
        sub bx,150
        mov es:[bx], al
        add bx,150
        inc bx   
        cmp bx, 64000
		jnz again3
               
               
               
               
;        push segment_buffer                        
;        pop es                                     
;        mov di,320*197                             
;        mov ax,0bdh                                
;        mov cx,320                                 
;        cld                                        
;        rep stosw                                  
;              
;        push segment_buffer_logo
;        pop es                                     
;        mov di,320*197                             
;        mov ax,0bdh                                
;        mov cx,320                                 
;        cld
;        rep stosw

   
   
        pop es                                     
                                                   
;ripped sur Dlyr|MDR .... promis jle ferait plus :) :/
   	xor eax, eax                               
   	xor ebx, ebx                               
   	xor ecx, ecx                               
      	xor esi, esi                               
                                                   
        push segment_buffer
        pop es                                     
        push segment_buffer_logo
        pop fs                                     
        xor di,di                                  
                                                   
loop1:                                             
   	xor ax, ax                                 
   	xor bx, bx                                 
	mov al, es:[di-1]
   	mov bl, es:[di+1]                          
   	add ax, bx                                 
   	mov bl, es:[di+320]                        
   	add ax, bx                                 
	mov bl, es:[di+640]                        
	add ax, bx                                 
	shr ax, 2                                  
	mov fs:[di], al                            
        inc di                                     
	inc cx                                     
	cmp cx, 63360                              
	jne loop1                                  
                                                   
        push segment_buffer                        
        pop fs                                     
        push segment_buffer_logo                   
        pop es                                     
        xor di,di                                  
   	                                           
loop2:
     	xor ax, ax                                 
   	xor bx, bx                                 
   	mov al, es:[di-1]                          
	mov bl, es:[di+1]                          
	add ax, bx                                 
	mov bl, es:[di+320]                        
	add ax, bx                                 
	mov bl, es:[di+640]                        
	add ax, bx                                 
	shr ax, 2                                  
	mov fs:[di], al                            
        inc di                                     
	inc cx                                     
	cmp cx, 63360           
   	jne loop2                                  
                                                   
        popa
        ret                                        
        endp feu                                   

initialisation_feu proc near                       
        pusha                                      
                                
        push segment_buffer_logo
        pop es                  
        mov cx,0FFFFh/2         
        mov ax,0                
        xor di,di               
        cld                                        
        rep stosw               
                                                   
        xor ax,ax              
        mov dx,3c8h            
        out dx,al                  
        mov dx,3c9h             
        out dx,al 
        out dx,al 
        out dx,al 
                  
		mov cx,0
boucle_palette_feu_3:            
        mov al,cl 
        out dx,al                
        xor al,al                
        out dx,al                
        out dx,al                
        inc cx    
        cmp cx,63 
        jne boucle_palette_feu_3                   
                  
        mov cx,0  
boucle_palette_feu_2:
        mov al,0FFh   
        out dx,al     
        mov al,cl                
        out dx,al     
        xor al,al   
        out dx,al     
        inc cx    
		cmp cx,63
        jne boucle_palette_feu_2
                  
        mov cx,0  
boucle_palette_feu_1:            
        mov al,0FFh   
        out dx,al     
        out dx,al     
        mov al,cl                
        out dx,al                                  
        inc cx    
        cmp cx,63 
        jne boucle_palette_feu_1

        call clear_buffer
        call clear_buffer_ecran
                      
        popa                     
        ret                      
        endp initialisation_feu

clear proc near                                        
;entree:          
;       al = color  
;sortie:          
;       clear de lecran
        push ax   
        push cx   
        push di
        push es                                         
                                                       
        xor di,di                                      
        push 0a000h
        pop es                 
        mov al,color          
        mov cx,0FFFFh
        cld                        
        rep stosb 
               
        pop es
		pop di
        pop cx
        pop ax  
        ret         
        endp clear 
                               
position_pixel proc near
;position dans un plan 320*200 avec x,y
;position en es:[si]       
        push dx                                         
;        push 0a000h
;        pop es           
        mov si,y               
        mov dx,si              
        shl si,6               
        shl dx,8               
        add si,dx                  
        add si,x               
        pop dx      
        ret                    
		endp position_pixel
                    
tempo proc near ;       32b ok                 
;entree:                
;       temp    = temps (temp/18.2 = 1s)
;Sortie:                                
;       ecoulement du temps   
                        
        pusha 
                                                        
        mov bx,temp
                                                     
        mov ax,0h                                    
        int 1ah                                      
        push dx                                      
        dec bx                   
boucle6:                                             
        mov ax,0h                                    
        int 1ah                                      
        pop cx                                       
		push dx
        cmp cx,dx                                    
        je boucle6                                   
        dec bx                   
        cmp bx,0
        jnl boucle6           
                                                     
        pop dx  ;pour virer le surplus
        popa  
                                                        
        ret                      
        endp tempo        

affichage_pixel proc near
;affichage dans un plan 320*200 avec x,y
                           
        call position_pixel        
                           
        cmp si,0           
        jb fin_affichage_pixel

        mov dl,color
        mov es:[si],dl
                    
fin_affichage_pixel:                
        ret                             
        endp affichage_pixel  
                    
clear_buffer proc near
        push es                                         
        pusha       
                          
        mov dx,segment_buffer
        mov es,dx                  
        xor di,di                  
        xor al,al                  
        cld                        
        mov cx,0FFFFh              
        rep stosb                  
                                   
		popa
        pop es                     
        ret                        
        endp clear_buffer          
                                   
clear_buffer_ecran proc near       
        push es                    
        pusha                      
                                   
        mov dx,segment_buffer_ecran                     
        mov es,dx                  
        xor di,di                  
        xor al,al                  
        cld                        
        mov cx,0FFFFh              
        rep stosb                  
                                   
        add dx,01000h              
        mov es,dx                  
        xor di,di                  
		xor al,al
        cld                        
        mov cx,01000h              
        rep stosb                  
              
        popa        
        pop es      
        ret              
        endp clear_buffer_ecran
                                                        
initialisation proc near
;augmente la taille memoire                                                                          
        mov ah,04ah                 
        mov bx,04000h
        push cs                     
        pop es                      
        int 21h                         
        jc fin      
;alloue 4000*16o     
        mov ah,048h                     
	      	mov bx,5000
        int 21h                         
        jc fin             
        mov segment_buffer,ax           
                           
        mov ah,048h        
        mov bx,50          
        int 21h                         
        jc fin            
        mov segment_buffer_palette,ax              
                          
                          
                          
        mov ah,048h                     
        mov bx,5000       
        int 21h                         
        jc fin            
        mov segment_buffer_ecran,ax
;...                                                  
                          
		mov ah,048h
        mov bx,5000       
        int 21h                         
        jc fin            
        mov segment_buffer_logo,ax
                           
        push segment_buffer_logo
        pop es            
        cld               
        xor si,si                                  
        xor di,di         
        xor al,al         
        mov cx,0FFFFh     
        rep stosb         
                          
        call clear_buffer_ecran
        call clear        
;on definit le mode graphique           
        mov ax,13h                                                        
        int 10h                                                           
		push 0a000h
        pop gs          ;gs sera tjrs le segments 0a000h
                          
        lea ax,zik         
        mov es,ax         
        call initplayer

        ret                        
        endp initialisation        
                                                   
buffer1_vers_buffer2_ecran proc near
        pusha             
        push es                    
        push ds                    
                                   
        push segment_buffer_ecran  
        pop es                                          
        push segment_buffer        
        pop ds                     
        xor di,di                  
        xor si,si                  
        mov cx,0FFFFh              
        rep movsb                  

        pop ds                     
        pop es                     
        popa              
        ret                        
        endp buffer1_vers_buffer2_ecran
                                                   
include 4kboudin.inc
include player.asm
                                                              
      end debut                                               
                                                              
                                                              
