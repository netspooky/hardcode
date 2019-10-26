;========= black and white light balls ===============
; Second program for the tuhb 256 byte compo
; it's just a simple ball program with a 256 color
; grey pallette, using standard vga stuff
; but i think it looks kinda nice... :)
;-----------------------------------------------------
; this is the technique i used to calculate the balls:
; color ball1 = 07777h / ((xscreen - bx1)^2 + (yscreen - by1)^2)
; color ball2 = 07777h / ((xscreen - bx2)^2 + (yscreen - by2)^2)
; color ball3 = 07777h / ((xscreen - bx3)^2 + (yscreen - by3)^2)
;-----------------------------------------------------
; (C) The Awakener - Coder for The Third Foundation
;     contact me at : m.bruins@st.hanze.nl
;-----------------------------------------------------
; other members of The Third Foundation:
; DutchPanther - Coder / Pixel
; Shogun       - Coder / Music
;=====================================================

.model tiny
.286              
.data             
                  
;starting coordinates of the balls
bx1     dw      0       
by1     dw      0       
bx2     dw      95      
by2     dw      0       
bx3     dw      47      
by3     dw      95      
                  
.code             
.startup          
                               
                     
        ;initialise graphics mode
        mov     al,13h               
        int     10h
        ;caculate pallette
        mov     cl,255                       
        mov     dx,3c8h
setloop:                                     
                mov     al,cl
                out     dx,al
                inc     dx   
                shr     al,2 
                out     dx,al
                out     dx,al              
                out     dx,al
                dec     dx
        loop    setloop                      
                   
;put balls on the screen :)
        ;load the VGA segment  
        push    0a000h      
        pop     es          
        std                     ;set the direction flag, so the screen is
                                ;drawn fine :)
nextframe:                     
        ;wait for monitor vertical retrace
        mov     dx,3dah
w1:                     
                in      al,dx
                test    al,8h
                jz      w1

        mov     di,47887     ;set the start of the screen
        mov     cl,96        ;that many y lines :)
yloop:                                     
                xor     bx,bx   ;bx contains the x-coordinate          
        xloop:                             
                mov     si,offset bx1   ;load offset to the balls
                mov     dl,3            ;want three balls
                xor     ax,ax           ;starting color = 0
        calculate_loop:                       
                ;=============== calculate the color ================
                push dx         ;store the ball counter :)                                          
                push ax         ;push the color                                          
                mov ax,[si]     ;get the xcoordinate of the ball                                          
                and ax,95       ;make sure it doesn't got out of the window                                          
                sub ax,bx       ;calculate delta-x
                mul ax          ;delta-x * deltax
                mov bp,ax       ;bp = deltax * deltax (something like that :)
                                                            
                mov ax,[si+2]   ;get the ycoordinate of the ball                          
                and ax,95       ;make sure it doesn't get out of the window 
                sub ax,cx       ;calculate delta-y 
                mul ax          ;delta-y * deltay
                             
                add bp,ax       ;dx = delta-x * delta-x + deltay * delta-y                          
                or  bp,1        ;we don't want a divide by zero!!!
                mov ax,7777h                                   
                cwd              
                div bp          ;and divide the stuff :)
                pop dx          ;get the back the color
                add ax,dx       ;add new color to old color
                pop dx          ;pop the ball counter
                             
                ;=============== end of calculation =========
                add     si,4    ;point to next ball
                dec     dl      
                jnz     calculate_loop
                or      ah,0    ;look for an overflow
                jz      ok
                        or     al,255   ;if so, give al maximum color     
                ok:                        
                stosb                   ;put the color on the screen   
                inc     bl              ;next point
                cmp     bl,96           ;see if line is done
                jb      xloop           ;if not, then do again
        sub     di,224                  ;point to next line on screen
        loop    yloop                   ;do everything again
                                    
        inc     bx1                     ;move the balls
        inc     by1          
        dec     bx2          
        inc     by2          
        dec     by3          
                                                                  
        in      al,60h                  ;see if esc was pressed
        dec     al           
        jnz     nextframe
                             
        mov     al,3                    ;exit the program
        int     10h      
        ret

        end                                       
                     
                     
