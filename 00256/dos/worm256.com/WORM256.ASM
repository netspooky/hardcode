;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; WORM256.COM
; by BitSwitch (aka Kasper Lund)
; - "http://www.geocities.com/SiliconValley/Heights/2108/"
; - "mailto:3713@hogym.dk"
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
.386p                                                                  
code16	segment	use16                                                  
	assume	cs:code16,ss:code16                        
	org	100h                                                   
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
init:   push    0a000h                          ; es=ds=0a000h (video-segment)
        pop     ds                              
        push    ds                              
        pop     es                              
        push    321                             ; fs=321
        pop     fs                              
                                                ; total = 11 bytes *
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
        mov     dx,3dah                         ; 3dah = input status 0 reg. 
        mov     ax,13h                          ; init video mode 13h
        push    ax                              ; preserve ax
        int     10h                                         
                                                ; total = 9 bytes *
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
        pop     ax                              ; restore ax
        mov     di,321                          ; fill screen with 
@@draw: mov     cx,318                          ; colour 13h (al)
        rep     stosb                           ; leaving a black boundary
        cmpsw           
        cmp     di,63600
        jna     @@draw                          
                                                ; total = 16 bytes *
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
        mov     al,dh                           ; draw player 2's points
        dec     di                              ; as dots along the bottom
        mov     cl,bh                           ; boundary. colour = dh
        rep     stosw                            
                                                ; total = 7 bytes *
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
        mov     al,dl                           ; draw player 1's points
        xor     di,di                           ; as dots along the uppper
        mov     cl,bl                           ; boundary. colour = dl
        rep     stosw                           
                                                ; total = 8 bytes *    
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
        mov     si,32080                        ; init player 2's offset
        mov     di,32240                        ; init player 1's offset
        mov     bp,-1                           ; player 1's direction = <-
        inc     cx                              ; player 2's direction = ->
                                                ; total = 10 bytes *       
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
round:  in      al,dx                           ; wait for vertical retrace
        test    al,08h                          
        jnz     round                           
@@vrt:  in      al,dx                           
        test    al,08h                          
        jz      @@vrt                           
                                                ; total = 10 bytes *
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;° The black-evil-kill-your-mama-with-an-axe-worms                           °
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
        pusha                                   ; preserve all registers
        push    ds                              ; set es = ds = 0a000h
        pop     es                              
        mov     di,fs                           ; di = current black worm offs
        mov     ax,di                           
        inc     ax                              
        xor     dx,dx                           ; calc the background colour
        mov     cx,320                          ; of the last tail segment
        div     cx                              ; of the black worms
        xor     ax,ax
        cmp     dx,ax                                                   
        je      @w1                                                     
        mov     ax,1313h                        
@w1:    shr     cx,1                            ; worm length = 160 (cx/2)
        pusha                                                            
        neg     di
        sub     di,1538                         
        std                                     
        stosw                                   ; delete tail segment of 
        xor     ax,ax                           ; the worm running up
        rep     stosb                           ; draw the up-running worm
        popa                                    
        cld                                     
        stosw                                   ; delete tail segment of 
        mov     fs,di                           ; the worm running down
        xor     ax,ax                           
        rep     stosb                           ; draw the down-running worm
        popa                                    
                                                ; total = 50 bytes *
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
key:    mov     ah,1                            ; check if a key has
        int     16h                             ; been pressed
        je      nokey                           
        mov     al,ah                           
                                                ; total = 9 bytes *
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
        cmp     al,01h                          ; check if key was ESC
        je      deinit                                                                          
                                                ; total = 4 bytes *
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
        push    cs                              ; es = cs
        pop     es                              
        push    di                              ; preserve di and cx
        push    cx                              
                                                ; total = 4 bytes *
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
        mov     cx,15                           ; try to find the scancode
        mov     di,offset scan_table            ; of the key pressed in the
        repnz   scasb                           ; scancode-table
                                                ; total = 8 bytes *  
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
        jcxz    cont2                           ; couldn't find scancode
        shr     cx,1                            ; check if first bit of 
        jnc     bp_set                          ; cx is set
                                                ; total = 6 bytes *  
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
        mov     cx,word ptr cs:[di]             ; update player 2's direction
        pop     di                              ; just popping (making sure
        jmp     cont                            ; cx isn't affected)
                                                ; total = 6 bytes *  
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
bp_set: mov     bp,word ptr cs:[di+1]           ; update player 1's direction
                                                ; total = 4 bytes *          
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
cont2:  pop     cx                              ; restore di and cx
cont:   pop     di                              
                                                ; total = 2 bytes *  
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
keyok:  xor     ax,ax                           ; clear the keyboard buffer
        int     16h                             
                                                ; total = 4 bytes *  
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
nokey:  mov     ax,1304h                        
        cmp     si,di                           ; check if the worms' heads
        jne     chk                             ; have collided
        xchg    dx,ax                           
        jmp     dead                            
chk:    cmp     [di],ah                         ; check if player 1 has 
        jne     p1dead                          ; collided with something
        cmp     [si],ah                         ; check if player 2 has 
        jne     p2dead                          ; collided with something
                                                ; total = 18 bytes *     
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
        mov     [di],dl                         ; draw player 1 (ds = 0a000h)
        mov     [si],dh                         ; draw player 2 (ds = 0a000h)
                                                ; total = 4 bytes *          
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
        add     di,bp                           ; update player 1's offs.
        add     si,cx                           ; update player 2's offs.
                                                ; total = 4 bytes *      
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
        jmp     round                           ; let's have another go...
                                                ; total = 2 bytes *       
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
p1dead: add     bh,al                           ; give player 2 some credit!
        shr     dx,8                            ; dl = colour of player 2
        jmp     dead                                                       
                                                ; total = 7 bytes *        
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
p2dead: add     bl,al                           ; give player 1 some credit
                                                ; total = 2 bytes *  
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
dead:   push    bx                              ; preserve the score
        mov     ax,1001h                        ; make the screen boundary
        mov     bh,dl                           ; the colour of the winning
        int     10h                             ; worm... (dl)
        pop     bx                              ; restore the score
        xor     ax,ax                           ; wait for space to be 
        int     16h                             ; pressed.... <waiting>
        cmp     al,32                           
        jne     dead                            
        cmp     bl,160                          ; check if player 1 has got 
        ja      deinit                          ; enough points...
        cmp     bh,160                          ; check if player 2 has got
        jbe     init                            ; enough points...
                                                ; total = 29 bytes * 
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
deinit: mov     ax,3h                           ; init video mode 3 (text)
        int     10h                             
        int     20h                             ; quit to OS.. <bye for now!>
                                                ; total = 7 bytes *  
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
scan_table      label                                                
                db      48h,11h                                      
                dw      -320                                         
                db      4dh,20h                                      
                dw      1                                            
                db      4bh,1eh                                      
                dw      -1                                           
                db      50h,1fh                                      
                dw      320                     ; total = 16 bytes *         
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
code16 	ends                                    ; program size = 256 bytes
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
end    	init                                                        
