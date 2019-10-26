logo    proc near                                                         
        mov cx,0         
        mov al,1         
boucle_logo:                       
        call affichage_ligne_logo                                         
        dec al           
        jz pouet_logo    
retour_pouet_logo:       
        inc cx         
        call clear     
        cmp cx,80    
        jne boucle_logo
        ret          
                     
pouet_logo:          
        mov al,25    
        jmp retour_pouet_logo                                                                  
                     
        endp logo                                                         
                                                                          
affichage_ligne_logo    proc near                                         
;a nombre de ligne            
;cx debut du                  
        pusha                      
                              
        push segment_buffer_logo
        pop fs                
        push segment_buffer_ecran
        pop es                
        xor di,di                                                         
        xor si,si                                                         
                                                                          
;        cmp cx,0
;        je suite_logo
;boucle_recherche_logo:        
;        mov al,fs:[si]        
;        inc si                                                            
;        inc di                                                            
;        cmp al,227            
;        jne boucle_recherche_logo                                         
;        loop boucle_recherche_logo
                              
suite_logo:                                                                   
;ligne de code de la mort qui tue que je devrai mettre plus souvent       
;pas de chance faut que je vire sa :)))
        mov ax,320            
        mov cx,plasma_position
        mul cx       
boucle_suite_logo:   
        mov cl,fs:[si]
        cmp cl,0     
        je suite_logo_2        
        cmp cl,227   
        je suite_logo_2
        mov es:[di],cl
suite_logo_2:        
        inc di               
        inc si               
        dec ax       
        jnz boucle_suite_logo                
                                 
        popa         
        ret                      
        endp affichage_ligne_logo  
                                                                          
initialisation_logo proc near      
;on va balancer tout le logo dans ma zone memoire
        mov ax,segment_buffer_logo
        mov es,ax  
        xor di,di                                
        lea si,injection_logo                                             
                                
        mov cx,49  
        mov temp,0  
boucle_affichage_logo_1:        
        mov al,cs:[si]
        cmp al,227    
        je fin_ligne                                                      
        mov bl,10000000b                                                  
boucle_affichage_logo_2:                                                  
        add di,4    
        test al,bl                                                        
        jne affiche_point_logo
retour_affichage_point_logo:                                              
        shr bl,1                                                          
        jnz boucle_affichage_logo_2
        inc si                                                            
        jmp boucle_affichage_logo_1    
                                       
fin_ligne:                             
        inc temp    
        mov bx,temp 
        mov ax,320*4
        mul bx      
        mov di,ax   
        inc si                  
        loop boucle_affichage_logo_1
                         
;on mets les 227 en fin de chaque ligne
        mov di,308 
        mov al,227 
boucle_227:                        
        mov es:[di],al          
        add di,320              
        cmp di,65000
        jna boucle_227
        ret                                                               
affiche_point_logo:                    
        mov edx,01010101h
        mov es:[di],edx  
        mov es:[di+320],edx
        mov es:[di+320*2],edx
        mov es:[di+320*3],edx
                   
        jmp retour_affichage_point_logo
        endp initialisation_logo

animation_debut proc near   
                     
        call initialisation_plasma
        call initialisation_logo
        mov di,0     
        mov cx,100   
                     
        xor di,di    
boucle_pouet_2:             
        call chargement_palette_plasma
        call buffer1_vers_buffer2_ecran
                            
        call affichage_buffer_ecran
                     
        add di,3     
        cmp di,254*3 
        jna boucle_pouet_2
                     
        xor di,di    
        mov plasma_position,1
boucle_pouet_3:      
        call chargement_palette_plasma
        call buffer1_vers_buffer2_ecran
                            
        cmp plasma_position,200
        je suite_45  
        inc plasma_position
suite_45:            
        call affichage_ligne_logo
        call affichage_buffer_ecran
                            
        add di,3     
        cmp di,255*3        
        jna boucle_pouet_3
                     
        xor di,di    
        mov plasma_position,200
boucle_pouet_4:      
        call chargement_palette_plasma
        call buffer1_vers_buffer2_ecran
                               
        call affichage_ligne_logo
        call affichage_buffer_ecran
                            
        add di,3     
        cmp di,255*3        
        jna boucle_pouet_4
                     
        xor di,di    
        mov plasma_position,200
boucle_pouet_5:      
        call chargement_palette_plasma
        call buffer1_vers_buffer2_ecran
                               
        cmp plasma_position,1
        je suite_46  
        dec plasma_position
suite_46:            
        call affichage_ligne_logo
        call affichage_buffer_ecran
                            
        add di,3     
        cmp di,255*3        
        jna boucle_pouet_5
                     
        xor di,di    
boucle_pouet_6:      
        call chargement_palette_plasma
        call buffer1_vers_buffer2_ecran
                            
        call affichage_buffer_ecran
                     
        add di,3     
        cmp di,254*3 
        jna boucle_pouet_6
                            
        ret                 
        endp animation_debut
                            
initialisation_plasma proc near
        mov ax,segment_buffer_palette
        mov es,ax    
        xor di,di        
                         
        mov cx,63     
        xor dx,dx        
        xor ax,ax     
init_1:                   
        inc al           
        mov es:[di],al   
        inc di           
        mov es:[di],dl
        inc di           
        mov es:[di],dl
        inc di           
        loop init_1      
                         
        mov cx,63     
init_2:                  
        dec al           
        mov es:[di],al   
        inc di           
        mov es:[di],dh   
        inc dh           
        inc di           
        mov es:[di],dl   
        inc di           
        loop init_2      
                         
        mov cx,63    
init_3:                  
        mov es:[di],dl   
        inc di           
        mov es:[di],dh   
        dec dh           
        inc di           
        mov es:[di],al   
        inc al           
        inc di           
        loop init_3      
                         
        mov cx,63    
init_4:                  
        mov es:[di],dl   
        inc di           
        mov es:[di],dl   
        inc di           
        mov es:[di],al   
        dec al           
        inc di           
        loop init_4      
                     
        mov cx,4*3
init_5:              
        inc al       
        mov es:[di],al
        inc di           
        mov es:[di],al
        inc di           
        mov es:[di],al   
        inc di           
        loop init_5   
                   
        push segment_buffer
        pop es 
                            
        mov x,0             
        mov y,0      
        xor di,di    
                     
boucle_plasma:           
        fild x        
        mov fpu,22;ax
        fidiv fpu     
        fcos          
        fild y         
        add ax,5     
        mov fpu,22;ax
        fidiv fpu    
        fsin            
        faddp st(1)                      
        mov fpu,150  
        fimul fpu    
        fistp fpu    
        mov ax,fpu                      
        cmp al,0
        jne suite_plasma_2
        mov al,1               
suite_plasma_2:          
        cmp al,253
        jna suite_plasma
        mov al,1     
suite_plasma:        
        mov es:[di],al
        inc di       
        inc x            
        cmp x,320        
        jne boucle_plasma
        mov x,0      
        inc y            
        cmp y,200    
        jne boucle_plasma
                         

                      
        ret                                    
        endp initialisation_plasma
                         
chargement_palette_plasma proc near              
;on definit en entree di qui est le commencement de la palette
        pusha            
        push es          
                         
        push segment_buffer_palette
        pop es                                                
        mov ax,0         
        mov dx,3c8h      
        out dx,al        
        mov dx,3c9h      
        out dx,al       ;pour virer la couleur 0
        out dx,al       ;pour virer la couleur 0
        out dx,al       ;pour virer la couleur 0
                                 
        mov cx,254*3     
boucle_chargement:                 
        mov al,es:[di+1]                              
        out dx,al        
        inc di                              
        cmp di,256*3     
        jne suite_40     
        xor di,di        
suite_40:                
        loop boucle_chargement
                                   
        pop es           
        popa                         
        ret                           
        endp chargement_palette_plasma
                         
affichage_buffer_ecran proc near
        pusha         
        push ds       
        push es       
                      
        push segment_buffer_ecran
        pop ds  
        push 0a000h                                                       
        pop es  
                
        mov dx,3dah
                       
@wait1:
        in al,dx
        and al,8h
        jnz @wait1  
;@wait2:            
;        in al,dx
;        test ax,8h            
;        jnz @wait2
                
        xor si,si                                                         
        xor di,di
        mov cx,0FFFFh
        cld         
        rep movsb   
                    
        pop es      
        pop ds      
        popa        
        ret                                                               
        endp affichage_buffer_ecran
                              
                                                          
equation_parametrique_1 proc near      
                       
        fild t_numerateur    
        mov fpu,ax      
        fimul fpu               
        fidiv t_denominateur        
        fsin    ;sin 2t      
        mov fpu,120                    
        fimul fpu       
        fistp x         
        add x,150       
        inc ax          
                          
        fild t_numerateur 
        mov fpu,ax        
        fimul fpu         
        fidiv t_denominateur
        fsin    ;sin 3t   
        mov fpu,80        
        fimul fpu         
        fistp y           
        add y,98          
                       
        call affichage_cercle
                          
        ret                         
        endp equation_parametrique_1
                                    
equation_parametrique_2 proc near   
        fild t_numerateur           
        mov fpu,ax     
        fimul fpu                   
        fidiv t_denominateur        
        fsin    ;sin 10t
        mov fpu,120    
        fimul fpu                   
        fistp x                     
        add x,150                   
                       
        dec ax         
        fild t_numerateur
        mov fpu,ax     
        fimul fpu      
        fidiv t_denominateur
        fsin    ;sin 9t
        mov fpu,80     
        fimul fpu        
        fistp y        
        add y,98       
        inc ax
                               
        call affichage_cercle
                             
        ret                         
        endp equation_parametrique_2
                                    
equation_parametrique_3 proc near
        fild t_numerateur           
        fidiv t_denominateur 
        fcos    ;cos t       
        fld st(0)            
        fmul st(0),st(0)
        fmulp st(1);        cos(t)^3
        mov fpu,140
        fimul fpu                   
        fistp x                     
        add x,150                   
                                    
        fild t_numerateur           
        fidiv t_denominateur        
        fsin    ;sin t       
        fld st(0)            
        fmul st(0),st(0)
        fmulp st(1) ;       sin(t)^3
        mov fpu,100     
        fimul fpu                   
        fistp y                     
        add y,90        
                                    
        call affichage_cercle       
                                    
        ret                         
        endp equation_parametrique_3
                        
;bon derniere anim ON NE TOUCHE PLUS SA MARCHE =)
;faut penser a redefinir la tempo
                
affichage_scroll_fin proc near                                            
        call clear_buffer
                    
                    
                    
;        call changement_palette      
        push segment_buffer_ecran   
        pop es                      
                    
        call animation_parametrique_1
        finit                          
;on affiche tout a un segment apres le buffer ( doit rester de la place :p )
        lea di,text_scrolling                                 
        mov ax,segment_buffer_ecran
        add ax,01000h              
        mov es,ax                      
        xor si,si                      
        mov ch,150      
                                                            
boucle_scroll_fin:                                          
        mov al,cs:[di]                                      
        call affichage_chr                                  
        add si,9                                            
        inc di                                              
        mov al,cs:[di]                                      
        cmp al,255                                          
        jne boucle_scroll_fin                               
                                   
                                     
        push es                    
        pop fs                     
;on initialise la procc animation_parametrique
        mov al,1                       
        mov t_numerateur,0         
        push segment_buffer        
        pop es  ;pour la proce changement_couleur                        
        push segment_buffer_ecran  
        pop ds                     
                                   
;procedure pour faire tourner le msg                        
                                   
        fld dec_rond_feu        ;on kick la variable vu que on en a plus besoin
        fadd st(0),st(0)           
        fadd st(0),st(0)           
        fstp dec_rond_feu          
                    
                                   
boucle_tourner_truc_fin:                    
        call animation_parametrique_general
                                   
        xor bp,bp                  
        mov fpu,50                 
        mov di,200                 
        fldpi                      
        push cx                    
boucle_tourner_logo:     
        fadd dec_rond_feu                
        loop boucle_tourner_logo
        pop cx           
boucle_rond_4:                                              
        fld st(0)                                       
        fadd st(0),st(0)                                    
boucle_rond_3:                                              
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
        call position_pixel                                 
        mov dl,fs:[bp]   
        inc bp           
        cmp dl,150      
        jne saut_truc_machin
        mov ds:[si],dl          ;calculer par position_pixel
saut_truc_machin:                                           
        fsub dec_rond_feu                                   
        dec di                
        jnz boucle_rond_3     
                                                            
        ffree st(0)           
        fincstp                      
        mov di,200            
        add bp,320-200        
        sub fpu,2             
        cmp fpu,50-8*2        
        jne boucle_rond_4                                   
                        
        inc cx          ;cx va etre mon pointeur pour faire tourner
                        
        call affichage_buffer_ecran
        mov temp,0      
        call tempo      
                        
        cmp cl,145
        jne boucle_tourner_truc_fin                        
                        
        mov temp,20
        call tempo      
                        
                        
;on affiche le code a la fin
        mov ax,3h       
        int 10h         
        lea si,text_fin 
        push 0b800h     
        pop es          
        mov di,80*2*3   
        dec si          
                        
boucle_fin:             
        inc si                     
        mov al,cs:[si]  
        cmp al,254      
        jne suite_fin   
        add di,(80-29)*2
        jmp boucle_fin  
suite_fin:              
        cmp al,255      
        je fin          
        mov es:[di],al  
        add di,2        
        jmp boucle_fin  
                                      
        ret                                             
        endp affichage_scroll_fin               
                        
animation_parametrique_1 proc near ;optimise de mon Q(i)
        call clear_buffer_ecran
        mov ax,2                    
        mov t_numerateur,0          
boucle_animation_3:                 
        mov cx,20                   
boucle_animation_2:                 
        push ax                     
        call equation_parametrique_1
        pop ax                      
        inc t_numerateur               
        loop boucle_animation_2     
        call affichage_buffer_ecran 
        cmp t_numerateur,2520          
        jna boucle_animation_3      
                                     
        call clear_buffer_ecran
        mov ax,2                    
        mov t_numerateur,0          
boucle_animation_5:           
        mov cx,20                   
boucle_animation_4:           
        push ax                     
        call equation_parametrique_2
        pop ax                      
        inc t_numerateur               
        loop boucle_animation_4
        call affichage_buffer_ecran 
        cmp t_numerateur,2520          
        jna boucle_animation_5
                                    
        call clear_buffer_ecran
        mov ax,150            
        mov t_numerateur,0          
boucle_animation_7:                  
        mov cx,20                   
boucle_animation_6:           
        push ax                     
        call equation_parametrique_1
        pop ax                      
        inc t_numerateur               
        loop boucle_animation_6
        call affichage_buffer_ecran 
        cmp t_numerateur,2520          
        jna boucle_animation_7      
                 
        call clear_buffer_ecran     
        mov ax,1600
        mov t_numerateur,0          
boucle_animation_9:           
        mov cx,20                   
boucle_animation_8:           
        push ax                     
        call equation_parametrique_2 
        pop ax                      
        inc t_numerateur               
        loop boucle_animation_8
        call affichage_buffer_ecran 
        cmp t_numerateur,2520          
        jna boucle_animation_9
                              
        call clear_buffer_ecran
        mov ax,1               
boucle_animation:                
        mov t_numerateur,0     
        mov cx,20              
boucle_animation_1:            
        call equation_parametrique_1
        inc t_numerateur               
        loop boucle_animation_1
        call affichage_buffer_ecran
        mov cx,20                                    
        cmp t_numerateur,2520          
        jna boucle_animation_1 
                              
        call clear_buffer_ecran
        ret                          
        endp animation_parametrique_1
                              
animation_parametrique_general  proc near
        push cx                    
        mov cx,20                  
boucle_animation_general_1:            
        call equation_parametrique_3
        inc t_numerateur               
        loop boucle_animation_general_1
                                    
        call buffer1_vers_buffer2_ecran
                                    
        cmp t_numerateur,2520          
        ja suite_boucle_animation_1
fin_parametrique:                                       
        pop cx                     
        ret                                
suite_boucle_animation_1:          
        call clear_buffer          
        mov t_numerateur,0         
        jmp fin_parametrique       
        endp animation_parametrique_general

affichage_cercle proc near           
        pusha   
        lea bx,matrice_rond
        xor dx,dx       ;dl pour les x et dh pour les y
                
boucle_affichage_cercle_2:
        mov al,cs:[bx]
        mov cl,10000000b                               
                                                       
boucle_affichage_cercle_1:                             
        test al,cl                                     
        je saut1
        call changement_couleur                        
saut1:                                                 
        inc x   
        shr cl,1
        jnz boucle_affichage_cercle_1
                
        inc dl           
        inc bx  
        cmp dl,3
        jne boucle_affichage_cercle_2
        xor dl,dl                    
        inc dh                       
        inc y                        
        sub x,24
        cmp dh,17
        jne boucle_affichage_cercle_2
                
        popa    
        ret                           
        endp affichage_cercle         
                                      
changement_couleur proc near          
        push ax                       
        cmp y,0   
        jl fin_changement_couleur
        cmp y,200 
        jg fin_changement_couleur
        call position_pixel
        mov al,es:[si] 
        inc al         
        mov es:[si],al 
fin_changement_couleur:
        pop ax    
        ret                    
        endp changement_couleur
