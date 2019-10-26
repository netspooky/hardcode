;----------------------------------------------------------------------------
; The GNU generator needs nothing - it writes the GNU fractal to its two
; allotted segments in colors ranging from 1 to 64 (64 being black)     
; registers killed: 80x87,ax,es,di,bp,dx,ebx,cl                         
;----------------------------------------------------------------------------
Proc    GenGNU                                                          
                                                                        
        finit
        fld     [dword ptr diverge]                                         
        fld     [dword ptr q]                                               
        fld     [dword ptr p]                                               
        ; now st(0) = p, st(1) = q, st(2) = diverge                         
        mov     ax,[gnuseg1]                                            
        mov     es,ax                                                                      
        xor     di,di                                                       
        mov     bp,gysize                                                     
        @@yres:                                                     
                mov     [dword ptr x],linexi    ; load it anew for each line
                mov     dx,gxsize                                             
                @@xres:                                                       
                        ; load xr, xi with the value of the current pixel
                        mov     ebx,[x]                      
                        mov     [xi],ebx                             
                        mov     ebx,[y]                              
                        mov     [xr],ebx                     
                        ; initialize yr and yi               
                        mov     [dword ptr yr],0        ; yr = 0       
                        mov     [dword ptr yi],0        ; yi = 0     
                        mov     cl,maxiter                              
                        @@iterate:                           
                                ; tr = xr; ti = xi --> well, push 'em!
                                push    [dword ptr xr]                  
                                push    [dword ptr xi]                        
                                ; xr = xr*xr - xi*xi + p + q*yr 
                                fld     [dword ptr yr]          
                                fmul    st,st(2)                              
                                fadd    st,st(1)             
                                fld     [dword ptr xr]                        
                                fld     st                                    
                                fmulp   st(1),st                
                                fld     st                      
                                faddp   st(2),st                  
                                fld     [dword ptr xi]               
                                fld     st                           
                                fmulp   st(1),st             
                                fld     st                   
                                fsubp   st(3),st                       
                                fxch    st(2)                        
                                fstp    [dword ptr xr]                  
                                ; xi = 2.0*xr*xi + q*yi         
                                fld     [dword ptr yi]          
                                fmul    st,st(4)                        
                                fld1                                                   
                                fld     [dword ptr xr]
                                fscale      
                                fmulp   st(1),st ; to get the stack right     
                                fld     [dword ptr xi]          
                                fmulp   st(1),st                
                                faddp   st(1),st                              
                                fstp    [dword ptr xi]          
                                ; yr = tr; yi = ti --> and pop 'em
                                pop     [dword ptr yi]               
                                pop     [dword ptr yr]               
                                ; xr*xr+xi*xi                   
                                faddp   st(1),st             
                                ; Okay, so this line uses the xr*xr and
                                ; xi*xi calculated earlier. The value of
                                ; xi*xi would be different if I calql8ed
                                ; it now, but the difference in the images
                                ; is barely noticible and this method
                                ; saves me 10 bytes of code :-)
                                                                              
                                ; does it diverge?                                     
                                fcomp   st(3)                                 
                                fstsw   ax                      
                                sahf                                          
                                jae     @@divergance         
                        dec     cl                              
                        jnz     @@iterate                                     
                        @@divergance:       
                ; putpixel                        
                inc     cl
                mov     [es:di],cl                                   
                inc     di                       
                jnz     @@currentseg    ; when one segment is full,
                mov     ax,[gnuseg2]    ; the other one is used
                mov     es,ax                                 
                @@currentseg:                                           
                ; increment xi                                          
                fld     [dword ptr x]                                
                fld     [dword ptr advx]        
                faddp   st(1),st                                              
                fstp    [dword ptr x]                                                  
                dec     dx                                           
                jnz     @@xres                                       
        ; increment xr                                                        
        fld     [dword ptr y]                                        
        fld     [dword ptr advy]
        faddp   st(1),st                                                      
        fstp    [dword ptr y]                                        
        dec     bp              
        jnz     @@yres     
                                                                    
        ret                                      
EndP                                             
;---------------------------------------------------------------------------- 
; I need: bx = sourceheight, dx = sourcewidth, fs = whereto
; I destroy: ax,gs,si,di,cx                                
; bitmap scaler algorythm courtesy of Tumblin/BiM
;----------------------------------------------------------------------------                            
Proc    DisplayGnu                                                            
        mov     ax,[gnuseg1]                                            
        mov     gs,ax                                                                  
                                                                                  
        ; calculate si so that the gnu always seems centered  
        push    dx                                                            
        mov     ax,gysize       ; y                           
        sub     ax,bx                                         
        and     ax,1111111111111110b    ; so that it's even                   
        mov     si,gxsize                                                     
        mul     si                                            
        mov     si,ax                                         
        pop     dx                                                            
        add     si,gxsize       ; x                           
        sub     si,dx                       
        shr     si,1                        
                                                                              
        xor     di,di                                         
                                                              
        mov     ax,200  ; y-errorterm                         
        mov     bp,200  ; y-resolution                                        
        @@yloop:                                                              
                add     ax,200                                                         
                cmp     ax,bx                                                     
                jbe     @@nonextline                                          
                        sub     ax,bx                                         
                                                              
                        ; store some registers for y-algorythm
                        push    si                                            
                        push    ax                                            
                        push    bp                            
                                                              
                        ; draw a line                                         
                        mov     ax,320  ; x-errorterm         
                        mov     bp,320  ; x-resolution              
                        @@xloop:                                    
                                mov     cl,[gs:si]      ; pixelcolor          
                                add     ax,320                        
                                cmp     ax,dx                         
                                jbe     @@nonextpixel                 
                                        sub     ax,dx
                                        mov     [fs:di],cl      ; putpixel
                                        inc     di              ; advance to next pixel
                                        dec     bp              ; advance the loop
                                @@nonextpixel:                                
                                inc     si                                    
                                jnz     @@minicurrentseg                      
                                        push    [gnuseg2]       ; next segment
                                        pop     gs                            
                                @@minicurrentseg:                             
                        cmp     bp,0                                          
                        jne     @@xloop                                       
                                                                              
                        ; restore the registers used by the y-algorythm       
                        pop     bp                                            
                        pop     ax                                            
                        pop     si                                            
                                                                              
                        dec     bp                                            
                @@nonextline:                                                 
                add     si,gxsize                                             
                jnc     @@currentseg                                          
                        push    [gnuseg2]; data continues in the next segment
                        pop     gs                                                
                @@currentseg:                                                 
        cmp     bp,0                                                          
        jne     @@yloop                                                       
                                                                              
        ret                                                                   
EndP                      
;----------------------------------------------------------------------------
; I need: bl = step (0 = black, 63 = full)                              
; I destroy: dx,ax,cx                                                   
;----------------------------------------------------------------------------
Proc    FadeIn                                                          
        mov     dx,3C8h                                                 
        mov     al,1    ; start with pal-entry #1                       
        out     dx,al                                                   
        inc     dx                                                      
        mov     cl,63                                                   
        @@palloopblack:                                                 
                mov     al,cl                                           
                mul     bl                                              
                shr     ax,6 
                mov     ch,al
                shr     al,1 
                out     dx,al           
                out     dx,al                                                 
                mov     al,ch                                                 
                out     dx,al                                   
        dec     cl                                              
        jns     @@palloopblack
        ; and now the reverse effect (fading from _white_ to bluescale)         
        mov     cl,63        
        @@palloopwhite:   
                mov     al,cl
                mul     bl
                shr     ax,6
                mov     ch,al
                shr     al,1
                add     al,63                   
                sub     al,bl                                           
                out     dx,al                                           
                out     dx,al
                mov     al,ch
                add     al,63
                sub     al,bl       
                out     dx,al           
        dec     cl            
        jns     @@palloopwhite
                                                                     
        ret                                                                   
EndP                                                                             
;---------------------------------------------------------------------------- 
; I need: bl = step (0 = normal, 31 = evil)                          
; I destroy: dx,ax,cx(,bp)                                           
;----------------------------------------------------------------------------
Proc    Evilize                                                               
        mov     dx,3C8h                                                       
        mov     al,24           ; start at palette entry #24                  
        out     dx,al                                                         
        inc     dx                                                            
        mov     cl,16                                                         
        @@palloop:                                                            
                ; red & green                                                 
                mov     al,11                                                 
                mul     bl                                                    
                shr     ax,5                                                  
                mov     ch,al                                                 
                mov     al,cl                                                 
                mul     bl                                                    
                                                                              
                ;push   dx                                          
                ;mov    bp,56
                ;mul    bp
                ;shrd   ax,dx,8                                               
                ;pop    dx                                                    
                
                shr     ax,2
                                                                              
                add     al,cl                                                 
                shr     al,1                                                  
                add     al,11                                                 
                sub     al,ch                                                 
                out     dx,al                                                 
                out     dx,al                                                 
                ; blue                                                        
                mov     al,(64-24-16)                                         
                add     al,cl                                                 
                mul     bl                                                    
                shr     ax,5                                                  
                mov     ah,(64-24-16)                                         
                add     ah,cl                                                 
                sub     ah,al                                                 
                mov     al,ah        
                out     dx,al
        dec     cl                   
        jns     @@palloop   
                                      
        ; just *please* don't ask me how I did this...
                                                
        ret                                                             
EndP                                                                    
;----------------------------------------------------------------------------
; I need:  bl = step (0 = no fade, 3 = full fade)
; I destroy: bx,dx,cx,ax            
;---------------------------------------------------------------------------- 
Proc    FadeOut                       
        neg     bl                    
        add     bl,3
                        
        mov     dx,3C8h                                  
        mov     al,24                                               
        out     dx,al                                    
        inc     dx                                       
        mov     cl,16                                    
        @@palloop1:                   
                mov     al,cl         
                shl     al,2
                mul     bl            
                shr     ax,2
                out     dx,al   ; red                                   
                out     dx,al   ; green                                 
                xor     al,al         
                out     dx,al   ; blue
        dec     cl                                       
        jns     @@palloop1                               
                                                         
        mov     cl,21
        @@palloop2:                                      
                mov     al,cl                            
                mul     bl                               
                shr     ax,2
                mov     ah,al
                shr     al,1
                out     dx,al   ; red                    
                out     dx,al   ; green                  
                mov     al,ah                            
                out     dx,al                            
        dec     cl                                       
        jns     @@palloop2                      
                                                                        
        ret                                                                              
EndP            
;----------------------------------------------------------------------------
; makes a fire plette
; destroys dx,al,cl                             
;----------------------------------------------------------------------------
Proc    FirePalette                             
        mov     dx,3C8h                         
        xor     al,al                           
        out     dx,al                           
        inc     dx                                                  
        mov     cl,0                                               
        palloop:                                
                cmp     cl,8                    
                jb      @@section1              
                cmp     cl,16                   
                jb      @@section2              
                cmp     cl,40                   
                jb      @@section3              
                cmp     cl,72                                           
                jb      @@section4                                      
                cmp     cl,104
                jb      @@section5      
                @@section6:         
                        mov     al,63
                        out     dx,al
                        out     dx,al
                        out     dx,al
                        jmp     @@nextentry
                @@section1:            
                        xor     al,al                               
                        out     dx,al                              
                        out     dx,al
                        mov     al,cl
                        shl     al,1
                        out     dx,al
                        jmp     @@nextentry
                @@section2:  
                        mov     al,cl           
                        sub     al,8                                    
                        shl     al,1                                    
                        out     dx,al
                        xor     al,al   
                        out     dx,al
                        mov     al,16
                        sub     al,cl
                        shl     al,1
                        out     dx,al
                        jmp     @@nextentry
                @@section3:            
                        mov     al,cl                               
                        sub     al,8                               
                        shl     al,1 
                        out     dx,al
                        xor     al,al
                        out     dx,al
                        out     dx,al
                        jmp     @@nextentry 
                @@section4:                     
                        mov     al,63                                   
                        out     dx,al                                   
                        mov     al,cl
                        sub     al,40                   
                        shl     al,1
                        out     dx,al
                        xor     al,al
                        out     dx,al
                        jmp     @@nextentry
                @@section5:           
                        mov     al,63  
                        out     dx,al                               
                        out     dx,al                              
                        mov     al,cl
                        sub     al,72
                        shl     al,1 
                        out     dx,al
                @@nextentry:         
        inc     cl                          
        jnz     palloop                         
                                                                        
        ret                                                             
EndP            
;----------------------------------------------------------------------------
; I want: fs segment where the line should go, [c] color
;         [x1], [y1], [x2], [y2] start and end on line                
; I destroy: di, ax, cx, dx, bx = 2*deltax, bp = 2*deltay               
;----------------------------------------------------------------------------
Proc    line                
                            
        ; do the algorythm from left to right => sort [x1] < [x2]
        mov     ax,[x1]                                             
        cmp     ax,[x2]
        jbe     @@correctsequence
        ;mov     ax,[x1]        ; swaps x1 & x2
        mov     bx,[x2]         
        mov     [x1],bx         
        mov     [x2],ax         
        mov     ax,[y1]         ; swaps y1 & y2
        mov     bx,[y2]                         
        mov     [y1],bx                                                 
        mov     [y2],ax                                                 
        @@correctsequence:
                       
        ; create deltax, deltay and all the other stuff               
        mov     ax,[x2]         ; create delta x
        sub     ax,[x1]                                                 
        mov     [deltax],ax                    
        shl     ax,1            ; & delta x * 2
        mov     bx,ax           ; bx = 2*deltax
        mov     ax,[y2]         ; create delta y
        sub     ax,[y1]                                             
        mov     [deltay],ax     ; & delta y * 2
        shl     ax,1                           
        mov     bp,ax           ; bp = 2*deltay
                                              
        ; check whether the slope is +ve or -ve and ajust y-advance
        mov     dx,320          ; y adjust for positive gradient in dx
        cmp     ax,0            ; ax is deltay2 (^)
        jge     @@slopedown                     
        neg     dx              ; if gradient is negative, y adjust has to
        neg     [deltay]        ; be negative and the deltay's have to be +ve
        neg     bp
        @@slopedown:                                                  
                  
        ; load di with initial pixel value
        movzx   edi,[y1]                                                
        lea     edi,[edi*4+edi] ; *5
        shl     di,6            ; *64 (5*64=320)
        add     di,[x1]
                                                
        ; check whether the slope is less than or greater to 1      
        mov     ax,bp
        cmp     ax,bx
        jg      steep                                                   
                                                                        
        ; shallow slope: [deltax] >= [deltay]                           
        mov     cx,[deltax]     ; x-length of line                      
        sub     ax,cx           ; ax is the errorterm                   
        @@xsize:                                                        
                xchg    al,[c]                                          
                mov     [fs:di],al      ; draw the pixel                
                xchg    al,[c]                                          
                cmp     ax,0                                            
                jle     @@noyadvance                                    
                        add     di,dx   ; advance si by +320 or -320    
                        sub     ax,bx                                   
                @@noyadvance:                                           
                add     ax,bp                                           
                inc     di      ; next x-position                       
        dec     cx                                                      
        jns     @@xsize                                             
                                                                        
        ret                                                             
                                                                        
        steep:                                                          
        ; and now the same for a steep slope: [deltax] < [deltay]       
        mov     ax,bx                                                   
        mov     cx,[deltay]     ; y-length of line                      
        sub     ax,cx                                                   
        @@ysize:                                                        
                xchg    al,[c]                                          
                mov     [fs:di],al      ; draw the pixel                
                xchg    al,[c]                                          
                cmp     ax,0                                            
                jle     @@noxadvance                                    
                        inc     di                                      
                        sub     ax,bp                                   
                @@noxadvance:                                         
                add     ax,bx                                         
                add     di,dx
        dec     cx                                                    
        jns     @@ysize                 
                         
        ret                                              
EndP
;----------------------------------------------------------------------------
; needed: fs:di = destination, cl = stringlength, ds:si = first character
;         [c] = color, [addx], [addy], [addnc]
; destroyed: ax,bx,cx,dx,es,bp,di,si          
;----------------------------------------------------------------------------
Proc	PrintString                                        
	push	cx                                         
                                                           
	mov     ax,1130h        ; character generator.font information                     
	mov     bh,6            ; font (bh=6 ð 8x16)       
	int     10h                                        
	                                                   
	pop	cx	                                   
		                                           
	@@allcharacters:                                     
		movzx   bx,[byte ptr ds:si]   	; character
		shl     bx,4    ; * 16 (number of rows)      
		add     bx,bp                                
		mov     ch,16                                           
		@@columns:                                   
		  	mov     ah,10000000b    ; mask       
			mov     al,[es:bx]      ; current row           
			@@row:                               
				test    al,ah                
		   		jz      @@dark             
		   			mov   	dx,[addx]  
					mov   	dh,[c]     
					@@widthof1pixel:   
			color:			mov   	[fs:di],dh
			nop	; later, a 4-byte opcode will be inserted
					 	inc    	di        
					dec	dl         
				 	jnz	@@widthof1pixel
				 	jmp  	@@noadd  
				@@dark:                  
				add     di,[addx]        
		   		@@noadd:                 
			shr     ah,1                                    
		   	jnz     @@row                    
		add    	di,[addy]                        
		inc     bx                               
		dec     ch                               
		jnz     @@columns                        
	add	di,[addnc]                               
	inc     si      ; next character             
	dec     cl                                   
	jnz     @@allcharacters                                               
                                                     
	ret    
EndP
;----------------------------------------------------------------------------
; gimme: pointer in gs:si to the next three coordinates
; I give you: di=x, ax=y
; I destroy: di (duh), ax (duh too), bx, dx, cx
;----------------------------------------------------------------------------
Proc    project                                                      
        mov     cx,[gs:si+4]                                         
        cmp     cx,viewdx                                            
        jg      @@visible                                            
        mov     ax,-1   ; so it's filtered out by the clipping algorythm
        ret                                                          
                                                                     
        @@visible:                                                   
        mov     ax,[gs:si]                                           
        mov     bx,viewdx                                            
        imul    bx                                                   
        idiv    cx                                                   
        mov     di,ax   ; that was x                                 
        add     di,160                                               
                                                                     
        mov     ax,[gs:si+2]                                         
        mov     bx,viewdy                                            
        imul    bx                                                   
        idiv    cx                                                   
        add     ax,100  ; and y                                      
                                            
        ret                                 
EndP                        
;----------------------------------------------------------------------------
; needed: ds:di = source, gs = segment of target, si = length of data,
;         ds:bp pointing to anga,angb,ang,posx,posy,posz
; termin8ed: di,si,bx,cx(,fs,ax,bx,dx by rotate)
;----------------------------------------------------------------------------
Proc    TransformObject                         
        @@allverticies:                         
                ; rotation around x-axis                            
                push    di si bp                
                mov     bx,[ds:di+2]            
                mov     cx,[ds:di+4]            
                mov     si,[ds:bp]                                   
                call    rotate                  
                pop     bp si di                
                mov     [gs:si-4],bx            
                ;mov    [gs:si-2],cx            
                                                                     
                ; rotation around y-axis    
                push    di si bp                
                mov     bx,[ds:di]
                ; cx still loaded
                mov     si,[ds:bp+2]      
                call    rotate
                pop     bp si di                
                ;mov    [gs:si-6],bx
                mov     [gs:si-2],cx
                                          
                ; rotation around z-axis                            
                push    di si bp                 
                ; bx still loaded
                mov     cx,[gs:si-4]            
                mov     si,[ds:bp+4]            
                call    rotate                  
                pop     bp si di                
                mov     [gs:si-6],bx            
                mov     [gs:si-4],cx            
                                                
                ; translation               
                mov     ax,[ds:bp+6]
                add     [gs:si-6],ax
                mov     ax,[ds:bp+8]
                add     [gs:si-4],ax
                mov     ax,[ds:bp+10]
                add     [gs:si-2],ax            
                                                
        add     di,6                            
        sub     si,6                            
        jnz     @@allverticies                                      
                                                
        ret                                     
EndP                                            
;----------------------------------------------------------------------------
; Gimme: bx = x1, cx = y1, si = angle           
; I return: bx = x2, cx = y2                    
; I terminate: fs,si,di,ax,bx,dx,bp             
;----------------------------------------------------------------------------
Proc    rotate                                  
        mov     fs,[sinseg]                     
        shl     si,1                            
        mov     di,si                           
        add     di,(2 shl 13)   ; cosine        
                                                       
        ; y2 = x1*sin(theta) + y1*cos(theta)           
        mov     ax,[word ptr fs:si]             
        imul    bx              ; x1*sin(si)    
        shrd    ax,dx,15                        
        mov     bp,ax                           
        mov     ax,[word ptr fs:di]                                 
        imul    cx              ; y1*cos(si)    
        shrd    ax,dx,15                        
        add     bp,ax           ; bp = y2       
                                                       
        ; x2 = x1*cos(theta) - y1*sin(theta)    
        mov     ax,[word ptr fs:di]             
        imul    bx              ; x1*cos(si)    
        shrd    ax,dx,15                        
        mov     bx,ax                           
        mov     ax,[word ptr fs:si]
        imul    cx              ; y1*sin(si)
        shrd    ax,dx,15
        sub     bx,ax           ; bx = x2
                                                       
        mov     cx,bp
                                            
        ret                                            
EndP                          
;----------------------------------------------------------------------------
; I need ds:di pointing to the object, [c] containing color,
;        si = length of data, ds:bp pointing to stuff
; I destroy si,di,ax,bx,cx,dx,bp,fs, content of [jseg]
; I give you fs = [doublebuffer]
;----------------------------------------------------------------------------
Proc	DisplayVectorObject    
                           
	push	si                               
      	mov	gs,[jseg]      
	call	TransformObject
	          
	pop	si	
	sub	si,12
	mov	fs,[doublebuffer]
	@@VectorObject:       
	   	call	project                  
		mov	[x1],di                  
		mov	[y1],ax                  
		add	si,6  
		call	project                  
		mov	[x2],di                  
		mov	[y2],ax                  
		              
		call	line  
                              
	sub	si,(12+6)          
	jns    	@@VectorObject
                              
	ret    
EndP           
;----------------------------------------------------------------------------
; I need: nothing
; I destroy: ax,bx,cx,dx,gs,bp,di    
;----------------------------------------------------------------------------                           
Proc    FlameFrame                                                     
        mov     cx,[seed]
                                                                       
        mov     gs,[flametable]
        push	ds
        mov	ds,[doublebuffer]
        xor     di,di                                                  
        mov     bx,198                                                 
        @@yres:                                                        
                inc     di                                             
                mov     dx,318                                         
                @@xres:                                                
                        push    dx bx
                                     
                        ; random                                       
			rol     ch,2
                        ror     cl,6
                        add     cx,a
                        mov     bp,cx
                        shr     bp,10
                                                                        
                        movzx   ax,[ds:di-1]
                        movzx   dx,[ds:di]
                        add     ax,dx                                   
                        movzx   dx,[ds:di+1]
                        add     ax,dx                                   
                        movzx   dx,[ds:di+319]
                        add     ax,dx                             
                        movzx   dx,[ds:di+320]
                        add     ax,dx                             
                        movzx   dx,[ds:di+321]
                        add     ax,dx                             
                        movzx   dx,[ds:di+639]
                        add     ax,dx                             
                        movzx   dx,[ds:di+640]
                        add     ax,dx                             
                        movzx   dx,[ds:di+641]
                        add     ax,dx                             
                                                                  
                        shl     ax,6            ; info in 64-byte chunks
                        add     bp,ax                                   
                        mov     al,[gs:bp]      ; check in look-up table
                        mov     [ds:di],al
                                                                        
                        pop     bx dx
                inc     di                                              
                dec     dx                                              
                jnz     @@xres                                          
        inc     di                                                      
        dec     bx
        jnz     @@yres
        
        pop	ds
                                              
        mov     [seed],cx
                                                 
        ret                       
EndP                                             
;----------------------------------------------------------------------------
; y[n+1] = (a*y[n] + r) mod (2**16)
; gives you: ax = [seed] = random number
; kills: ax,bx,dx,[seed]                                            
;----------------------------------------------------------------------------
Proc random                                                                  
        mov     ax,[seed]                                                    
        mov     bx,a
        mul     bx
        add     ax,r
        mov     [seed],ax                                                    
        ret                                                                  
EndP     
;----------------------------------------------------------------------------
; waits for the next vertical retrace to start
; destroys dx,al on the way there
;----------------------------------------------------------------------------
Proc WaitVert                                                                
        mov     dx,3DAh                                                      
        @@j1:   in      al,dx                                                
                test    al,8                                                 
                jnz     @@j1                                                 
        @@j2:   in      al,dx                                                
                test    al,8                                                 
                jz      @@j2                                                 
                                                                             
        ret                                                                  
EndP                                                                         
;----------------------------------------------------------------------------
; clears the doublebuffer with eax
; also clears es,di,cx 
;----------------------------------------------------------------------------
Proc    ClearDblBuf               
        mov     es,[doublebuffer] 
        xor     di,di             
;       xor     eax,eax
        mov     cx,(64000 shr 2) 
        rep     stosd                           
        ret                                     
EndP                                            
;----------------------------------------------------------------------------           
; moves the doublebuffer to the screen
; moves different values into ax,es,di,si,cx
;----------------------------------------------------------------------------           
Proc    DisplayDblBuf                           
        push    ds                                                                              
        mov     ax,0A000h                                                                       
        mov     es,ax
        mov     ds,[doublebuffer]
        xor     di,di
        xor     si,si
        mov     cx,(64000 shr 2)
        rep     movsd
        pop     ds
                                                
        ret                                     
EndP
;----------------------------------------------------------------------------

;  Here comes the music part - I hope I never have to look at it again.
;  So don't expect to be able to understand half of the twists and turns
;  in that piece of code.
                                                                             
;----------------------------------------------------------------------------
; Well, this is the interrupt routine that plays the music.     
; Nothing is destroyed. ;-)                                     
;----------------------------------------------------------------------------
Proc	Music                                                   
	pusha                                                       
	push 	ds                                                  
                                                                    
        ; make ds point to data                                     
 	mov	ax,cs                                               
 	mov	ds,ax                                               
	                                                            
 	mov	di,[count]     	; so it has only to be done once    
                                                                    
	; loop patterns 00C..00D 	                            
 	cmp	di,01000h                                           
 	jae 	@@nextstop                                          
 	cmp	di,00E00h                                           
 	jb	normal
 	ja	@@nopointeradjust1                                  
 	 	sub   	[word ptr songptr],(l2-l1)                  
 		@@nopointeradjust1:                                 
 	  	sub	di,200h                                     
 	     	jmp	@@speedchanged                              
 	  	                                                    
 	@@nextstop:                                                 
	; loop patterns 010..014 	                            
 	cmp	di,01800h                                           
 	jae 	normal        
 	cmp	di,01400h                                           
 	jb	normal
 	ja	@@nopointeradjust2                                  
 		sub   	[word ptr songptr],(l3-l2)                  
 		@@nopointeradjust2:                                 
 	  	sub	di,400h                                     
 	  	                                                    
 	normal:                                                     
	mov	ax,di                                               
 	cmp	ax,00C00h                                           
	je	@@changespeed                                       
	ja	@@speedchanged	                                    
	 	; play ch0rep1                                      
	 	beginningagain:             
	 	cmp	ax,02900h
	 	jae	mainmusic
                                            
		mov	bl,0                
		lea	bp,[ch0rep1]        
		xor	si,si               
		call	DoDoRep             
                                            
 	 	jmp	mainmusic                                   
                                            
      	@@changespeed:                                              
       	 	; reprogram frequency of the timer                  
       	 	mov   	dx,basespeed/96*125                         
       	 	call   	freq                                        
       	 	                                                    
       	@@speedchanged:                                             
                                            
                                                                                                    
       	; third part of music check	    	                                                    
     	mov	ax,di                       
	cmp	ax,01800h                   
	jb	@@fastbeat                  
	je	@@changespeedagain
	cmp	ax,02600h
	jae	beginningagain
	jmp	@@tekknopart
	                    
	@@changespeedagain:                 
	 	mov   	dx,basespeed        
	 	call  	freq                
	                                    
	@@tekknopart:                       
		mov	ax,di               
		cmp	ax,02000h           
		jae	@@nextpart          
;		cmp	ax,01C00h                
; 		jb	@@simplepart             
;                                            
; 		@@doublepart:               
; 		mov	bl,8                
; 		lea	bp,[tek2]
; 		mov	si,6
; 		call	DoDoRep
; 		                                 
; 		mov	ax,di                    
; 		                                 
; 		@@simplepart:                    
 		mov	bl,7                     
		lea	bp,[tek1]                
		xor	si,si                    
		call	DoDoRep                  
	 	                                 
	 	jmp  	@@slowerbeat             
	 	                                 
	 	@@nextpart:                      
                                                 
                test	ah,10b                   
                jnz	@@terzup                 
                                                 
                mov	bl,7                     
		lea	bp,[tek3]                
		xor	si,si                    
		call	DoDoRep                  
                                                 
	 	jmp	@@slowerbeat             
	 	                                 
	 	@@terzup:                        
	 	                                 
	 	mov	bl,7                     
		lea	bp,[tek4]                
		xor	si,si                    
		call	DoDoRep                  
	 	                                 
	      	; play the little bit slower beat
	      	@@slowerbeat:   
		mov    	ax,di
	  	cmp  	al,0                
	 	jnz	@@noloop3           
	 	  	lea  	bp,[drums1] 
	 	  	mov  	[pointer+2],bp
	 	  	lea   	bp,[hihat1] 
	 	  	mov   	[pointer+4],bp
	 	@@noloop3:                
	 	jmp	playbeat            
                                            
  	@@fastbeat:                         
	      	; play fast beat                    
	       	mov    	ax,di                                
	  	cmp	al,0                                 
	 	jnz	@@noloop2                            
	 	  	lea  	bp,[drums2]
	 	  	mov  	[pointer+2],bp
	 	  	lea   	bp,[hihat2]                  
	 	  	mov   	[pointer+4],bp
	   	@@noloop2:                          
                                                    
	; play whatever beat                
	playbeat:                           
 	mov	bl,09h	     	; percussion channel
 	mov	bp,[pointer+2]
 	call	DoRep  	      	; play pattern data at ds:bp
 	mov	[pointer+2],bp
 	mov	ax,di	     	; DoRep needs low byte of [count]
 	mov	bl,09h	  	; percussion channel
 	mov	bp,[pointer+4]
 	call	DoRep  	      	; play pattern data at ds:bp
 	mov 	[pointer+4],bp

	 	                                             
	mainmusic:                     
                                                             
        ;--------------------------------                    
 	; play non-repetitive music part                     
 	;--------------------------------                    
 	mov	bp,[songptr]                                 
 	mov	ax,[ds:bp]                                    
 	cmp	ax,di                                        
   	jne	@@nomusicdata                                
 	add	bp,2                                         
 	mov 	bx,[ds:bp]                                   
 	@@nextnote:                                          
 		xchg 	bh,bl
 		and	bl,1111b
 		mov  	ah,bh                                
		and	bh,01111111b                         
		test	ah,10000000b                         
 		je	@@NoteOff       
 			call	NoteOn 
 		jmp	@@Over                               
 		@@NoteOff:	       
 			call	NoteOff
 		@@Over:                                       
		add	bp,2                                  
		mov	bx,[ds:bp]                                 
		test  	bx,1000000000000000b                 
		jne   	@@nextnote                           
	mov	[songptr],bp                                 
 	@@nomusicdata:
 	                                                     
                                                                            
        ; increment counter every time the timer ticks :-)                  
        inc  	[word ptr count]                             
                                                             
 	; issue an EOI and return to program                      
 	mov 	al,20h
 	out 	20h,al
 	pop 	ds
 	popa                            
    	iret
EndP                                                         
;----------------------------------------------------------------------------
; I need: ds:bp pointing to pattern data, al containing low byte of [count]
;	  bl containing channel                     
; I destroy: bx,ax,cx,dx                                           
;----------------------------------------------------------------------------
Proc	DoRep                                                
	mov  	dx,[ds:bp]
	cmp	al,dl
 	jne	@@noplay                                     
		mov  	bh,dh
	  	and 	bh,01111111b   	; now containing note
 		test 	dh,10000000b                         
 		je 	@@NoteOff                            
 		  	call	NoteOn                       
 		jmp 	@@Over                               
   		@@NoteOff:                                   
   		  	call	NoteOff
 	   	@@Over:                   
	        add  	bp,2
	@@noplay:                         
                                                            
	ret	                          
EndP                                                
;----------------------------------------------------------------------------
; need: ds:bp pattern data, si pointer, al low byte of [count], bl channel
; destroy: ax,bx,cx,dx,bp
;----------------------------------------------------------------------------
Proc	DoDoRep              
	cmp  	al,0                                                                 
	jnz  	@@noloop     
 	   	mov   	[pointer+si],bp
 	@@noloop:
 	mov	bp,[pointer+si]
 	call	DoRep  	       	; play pattern data at ds:bp
 	mov 	[pointer+si],bp
                               
	ret                                          
EndP                           
;----------------------------------------------------------------------------
; Gimme: bl = value to be written to the MPU
; I destroy: dx,cx,al                     
;----------------------------------------------------------------------------
Proc	WriteMPU                                    
	mov	dx,(MPU+1)        
    	mov	cx,300	; or whatever
 	@@wait:                   
 	      	in   	al,dx     
 		and  	al,40h    
 	 	je  	@@writable                                 
 	dec	cx                
    	jnz	@@wait                    
 	                          
     	ret	; return if not writable
 	                          
 	@@writable:               
 	dec	dx	; dx = MPU                          
 	mov	al,bl                                
      	out	dx,al             
 	                          
	ret                               
EndP                              
;----------------------------------------------------------------------------
; give me: bl = channel, bh = note                  
; I destroy: dx,cx,al,bl
;----------------------------------------------------------------------------
NoteOn:
       	add   	bl,10h		; the assembler gives a warning... so what
Proc	NoteOff                                                              
       	add    	bl,80h
       	call	WriteMPU                                                     
       	mov	bl,bh                                                        
       	call	WriteMPU                                                     
       	mov	bl,07Fh
       	call	WriteMPU                                                     
                                                                             
	ret                                                                  
EndP
;----------------------------------------------------------------------------
; I need: dx with 1193180/frequency
; I destroy: ax
;----------------------------------------------------------------------------
Proc	freq         
	mov	al,36h    
	out	43h,al
    	mov	ax,dx   	; 1193180 / frequency
	out	40h,al
	mov	al,ah
 	out	40h,al           
 	 	
	ret
EndP                                                
;----------------------------------------------------------------------------         
                                                    
