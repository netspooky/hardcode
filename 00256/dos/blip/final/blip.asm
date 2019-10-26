;Hmm. this source became a nice mess when I commented it. Well, screw it.


org 100h


                mov ax,13h
                int 10h


                mov ax,cs
                add ax,1000h               
                mov es,ax                  
                add ax,1000h               
                mov fs,ax
                add ax,1000h 
                mov ds,ax

;-----------------------------------------------------------------------------
; This is the plasma table generator. It generates a 256x256 image by adding
; a bunch of randomly placed copies of x*x+y*y. Pythagoras would be proud.

                xor ax,ax

                mov dx,'gq'        ;TopSecret code...

                mov cx,65535       ;Empty whole plasma table (minus one pixel, duh)
                rep stosb          ;Fill value is not important     

                mov cl,30          
@@DrawPythazOuterLoop:

                imul cx             
                xchg ax,dx         ;dx -> random value, used as position

                xor bx,bx
@@DrawPatternLoop:
                mov ax,bx          
                add al,dl          ;x*x
                
                imul al
                xchg si,ax

                mov al,bh
                add al,dh
                imul al            ;x*x+y*y
                add ax,si


                add [es:bx],ah                         ;HUMMS ?
                dec bx
                jnz @@DrawPatternLoop

                loop @@DrawPythazOuterLoop

;-----------------------------------------------------------------------------
;dx == 0
;cx == 0t
;bx == 0
;fs -> virt, es -> blasma table
                mov dx,03c8h       ;Set a palette with blue and brown colors
                xor ax,ax
                out dx,al
                inc dx
@@PalLoop:
                out dx,al
                out dx,al
                ror ax,1
                out dx,al
                rol ax,1
                inc ax
                jnz @@PalLoop  ;The palette is set only 256 times..hmmm
;-----------------------------------------------------------------------------
;dh=3
                mov dl,0d4h        ;Set logical width of the screen to 256,
                mov ax,2013h       ;this allows me to make some routines simpler 
                out dx,ax          ;and smaller and actually results in smaller intro
                                   ;Non-tiled screen area becomes 192x200
;-----------------------------------------------------------------------------
;bx == 0
@@MainLoop:

                push bx            ;Store frame counter
;-----------------------------------------------------------------------------
; This piece of code draws the landscape and clouds. It is done by first
; calculating a position in the plane (texture) for each pixel and then
; drawing vertical lines starting from those pixels and going downward.
; I am drawing the interpolated height of the vertical lines rather than
; using a single color. This eliminates some of the noise close to the
; horizon. 

                mov bp,256
                ;bp is the screen pointer, the landscape is drawn back to front
@@PlaneYLoop:
                mov dx,255         ;Camera height, fixed of course
                mov di,dx
                div bp             ;ax - Distance of horizontal line
                                    
                mov si,ax

                shr ax,3         
                
                mov bh,al

                xor cx,cx          ;Center is at the left corner, but who carezz


@@PlaneInnerLoop:

                mov bl,ch        
                mov al,[bx]       ;Get topo value
                push bp

                sub al,230
                setc dl           ;Substract and clip al at 0
                dec dl            ;This is done since we are using only the "top" of the plasma
                and al,dl

                shl al,2         

                mov dh,63         ;Dl -> noize, landscape heights are between
                                  ;0 and 63.

@@FloorLoop:

                cmp dh,al         ;are we inside the landscape ?
                jae @@SkipPixel
                mov [fs:di+bp+100*256+32],dh  ;32 is added here to center the thing

                neg bp
                sub [fs:100*256+di+bp+32],byte 3   ;Draw clouds
                neg bp                                 ;flipped version of the landscape
@@SkipPixel:

                add bp,256      
                jo @@OverFlo

                sub dx,si            ;Interpolate height of verical line
                jnc @@FloorLoop

@@OverFlo:
                mov al,[bx]
                shr al,1                       
                mov [fs:di+bp+100*256+32],al  ;Draw "water" at the end of the linet
                mov [fs:di+bp+101*256+32],al

                pop bp

                mov ax,si       ;interpolate horizontal texture coordinate
                shr ax,3
                sub cx,ax 
 
                dec di
                jnz @@PlaneInnerLoop
                add bp,256
                jno @@PlaneYLoop
;-----------------------------------------------------------------------------
                mov dx,3dah           ;gee..I wonder what this is.
@@Wait1:                                        
                in al,dx
                and al,00001000b
                jnz @@Wait1
@@Wait2:
                in al,dx
                and al,00001000b
                jz @@Wait2
;-----------------------------------------------------------------------------
;di == 0
                pop bx               ;Increase frame counter
                inc bx

                push 0a000h
                pop gs


@@PlasmaAndFlipLoop:
                mov al,[es:di+bx]   ;Calc plasma color 
                add al,[es:di]    
                imul al             
                not ah
                mov [di],ah         ;Plasma is also used as topo
;------------------------------------------
                mov al,127

                xchg al,[fs:di]     ;Perform pixel copy and clear screen with xchg
                mov [gs:di],al
                shr ax,8           
                cmp ax,bx
                jb @@Noh
                shr ax,1
                mov [gs:di],al      
@@Noh:
                inc di
                jnz @@PlasmaAndFlipLoop
;Ah == 0

                in al,60h
                dec ax                
                jnz @@MainLoop

                mov al,3h               
                int 10h

                retn

