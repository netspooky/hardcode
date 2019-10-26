;---------------------------------------------------------------------------;
; ReliQ v0.00à                                                              ;
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;
; (c) March 1997 by Sentient Lifeforms                                      ;
; code by MLF/SLi aka Michael Flegel                                        ; 
; music by Hilander/SLi aka Sven Flegel                                     ; 
;---------------------------------------------------------------------------;
%TITLE "ReliQ - a 4k intro"                                                     
; I inserted some "ifdef EXE"s so that I could assemble and link this proggy 
; as an EXE. That made it debuggable in TurboDebugger
	P486            ; I only have TASM 3.0                               
	IDEAL                                             
	DOSSEG                                                                   
	; different memory models for COM and EXE programs              
	ifdef   EXE                                       
		MODEL   small                                                   
		STACK   100h                              
	else                                              
		MODEL   tiny                               
	endif
									
;----------------------------------------------------------------------------   
				         
; used by the random number algorythm       
a       equ     7A7Bh                                                                 
r       equ     543h                                                            
                                                                                      
; equates used by the GNU fractal                                               
gxsize  equ     452     ; 456 is the max for it to fit in two segments
gysize  equ     ((gxsize*5) shr 3)                                             
maxiter equ     63                                                           
linexi  equ     0BFA00000h      ; -1.25
 									         
; amount of stars
amount  equ     5463	; the max, for some reason, is 5463
                                                                                 
; some values needed for the 3D->2D conversion with aspect correction            
viewdx  equ     200	; 300
viewdy  equ     167	; 250                              
                                                                                 
; the size of one pixel in the 3D ReliQ logo and the distance from the screen    
RSize   equ     150                                                             
RDistance  equ	5200                     
                  
; highlight width on the logo                                                         
HWidth	equ	333                         
                                                                                      
; stuff needed by the music routine                                             
MPU	equ	330h	; MIDI port (should always be 330h)                     
basespeed  equ	12000                                                           
                                                                                
; the size of the comet...                         
CSize	equ	400                                                             
	   	   	     	                                                
;----------------------------------------------------------------------------   
	CODESEG                                                                 
	ifndef  EXE                                                             
		ORG     100h    ; standard COM start address                    
	endif                                                                   
				       						
Data:   jmp Start       ; don't want to execute data, now do we :-)             
				       		       	                        
	; some strings to be dispayed along the way                             
;       sinmsg  db      254," generating sin/cos table$"                        
;       gnumsg  db      10,13,254," precalculating GNU fractal$"                
;       strmsg  db      10,13,254," generating starfield$"                      
;       flmmsg  db      10,13,254," calculating table for flame effect$"              
;       fntmsg  db      10,13,254," converting VGA font to 3D object$"
;       fnlmsg  db      10,13,254," trying to impress tpolm$"                         
;	endmsg  db      "ReliQ - SLi 1997",10,13,"$"
					                                        
	; seed for the random number algorythm                               
	seed    dw      026ADh                                                  
					               
	; some variables for the GNU fractal                            
	y       dd      0BF700000h      ; -0.9375                               
	advx    dd      03BB3A62Dh      ; 0.005482456  
	advy    dd      03BD79435h      ; 0.006578947  
	diverge dd      040800000h      ; 4.0              
	p       dd      03EAE147Bh      ; 0.34                                  
	q       dd      0BF960419h      ; -1.172       
			 		                                        
	; some strings needed in the intro                                      
	strings db      "SLiPRESENTSReliQhailHaleBoppTHEND"                     
	                                                                        
	; star rotational and translational position                            
	starstuff       dw      0,0,0,0,0,0
	direction   	dw    	280  	; also used in the starfield
	                                                                        
	                                                                        
	; ReliQ logo stuff                                                            
	ReliQstuff      dw      2000,5000,0,RSize*4,0,RDistance                 
	                                                                
	; comet 3D object                                                       
	comet	dw	0,0,0, CSize,CSize,CSize                        
		dw	0,0,0, CSize,-CSize,CSize                               
		dw	0,0,0, -CSize,CSize,CSize                       
		dw	0,0,0, -CSize,-CSize,CSize                      
		dw	0,0,CSize*6, CSize,CSize,CSize                    
		dw 	0,0,CSize*6, CSize,-CSize,CSize                         
		dw	0,0,CSize*6, -CSize,CSize,CSize                 
		dw	0,0,CSize*6, -CSize,-CSize,CSize                        
		dw	-CSize,-CSize,CSize, -CSize,CSize,CSize         
		dw	-CSize,CSize,CSize, CSize,CSize,CSize           
		dw	CSize,CSize,CSize, CSize,-CSize,CSize           
	       	dw	CSize,-CSize,CSize, -CSize,-CSize,CSize         
	CStuff1	dw	-1200,0,0,5500,700,30000
	CStuff2	dw     	8192,0,0,0,CSize*4,4000		; fmeo
	CStuff3	dw     	0,8192+4096,0,0,CSize*2,4000
	CStuff4	dw     	0,-8192+4096,0,0,CSize*2,4000		
	                                     
	; instrument data
	include	"guspnp.inc"	; include your instrument allocation here
	                     
	; the music itself
	include	"music.inc"                                             
	    				    				
Start:  ; in COM programs these are equal anyway                                      
	ifdef   EXE                                                     
	       	mov     ax,cs                                                         
		mov     ds,ax                                                   
	endif
	
	;--------------------------------------------------------------------   
	; "allocate" memory                                                      
	mov     ax,es                                                        
	add     ax,1000h ; 64k for codeseg so there's no hassle with the stack  
 	mov     [gnuseg1],ax                                                    
        add     ax,1000h
  	mov     [gnuseg2],ax                                            
        add     ax,1000h                                                        
	mov     [sinseg],ax                                                    
	add     ax,1000h                                                
	mov     [flametable],ax                      
	add     ax,1000h                                                        
	mov     [jseg],ax                   
	add     ax,1000h                    
	mov     [doublebuffer],ax                                                     
;	ifndef  EXE                                                     
; 		add     ax,0FA0h  ; 64000 bytes for doublebuffer                      
; 		mov     bx,[cs:2] ; read last reserved segment from PSP         
; 		cmp     ax,bx                                                   
; 		ja      Exit                                                     
; 	endif                                                           
 									       
	;--------------------------------------------------------------------
	; generate a sin table                                                  
									        
;       mov     ah,09h                                                 
;       lea     dx,[sinmsg]                                            
;       int     21h                                                             
                                                                            
	finit
	mov     [word ptr temp],32767                
	fild    [word ptr temp]                                                 
	mov     [word ptr temp],16384       
	fild    [word ptr temp]             
	fldpi                                                                         
	fdivrp  st(1),st                    
	mov     gs,[sinseg]                                                           
	xor     si,si                                                           
	@@sintable:                                                             
		mov     [temp],si                                                
		shr     [temp],1
		fild    [word ptr temp]                                        
		fmul    st,st(1)                                             
		fsin                                                            
		fmul    st,st(2)                                                
		fistp   [word ptr gs:si]
	add     si,2                     
	jnc     @@sintable                                                      
		  						            
	;--------------------------------------------------------------------
	; generate GNU fractal                                                                     
;       mov     ah,09h                                                          
;       lea     dx,[gnumsg]                                                  
;       int     21h                                                          
	;call    GenGNU  -  it's called after the graphics init
	                  
									     
	;--------------------------------------------------------------------         
	; generate stars                                                        
;       mov     ah,09h                                                        
;       lea     dx,[strmsg]                                                      
;       int     21h                                                            
									     
	lea     si,[stars]
	mov     cx,3*amount                                                     
	@@genstars:                                                          
		call    random                                               
		mov     [ds:si],ax                                              
	add     si,2                                                         
	dec     cx                                                           
	jnz     @@genstars
	
	;--------------------------------------------------------------------   
	; calculate flame look-up table                                      
;       mov     ah,09h                                                       
;       lea     dx,[flmmsg]                                                           
;       int     21h                         
                                                                                      
	mov     gs,[flametable]                                                 
	xor     di,di                                                         
	mov     cx,0                                                             
	@@pixelvalue:
		mov     bx,47
		@@divisor:                                                      
			mov     ax,cx                                           
			xor     dx,dx                                   
			shl     ax,3
			div     bx                                              
		 	mov     [gs:di],al                                
		inc     di                                                  
		inc     bx                                                                 
		cmp     bx,(47+64)                                              
		jb      @@divisor                                   
	inc     cx                      
	cmp     cx,1024                     
	jb      @@pixelvalue                                                          
				 	    
	;--------------------------------------------------------------------         
	; take "ReliQ" and make it into a 3D object                             
;       mov     ah,09h                                                        
;       lea     dx,[fntmsg]                                                      
;       int     21h                                                            
	                                                                     
	; clear jseg first                                                      
	mov	es,[jseg]                                                       
	xor	di,di
	mov	cx,160
	xor	eax,eax                                                         
	rep	stosd                                                     
	                                                   
        ; print string to jseg           
	mov	fs,[jseg]     	; destination                                   
	xor	di,di                        
	lea	si,[strings+11]	; "R" in     
	mov	cl,5		; "ReliQ"    
	mov	[byte ptr c],1                                                        
	mov	[word ptr addx],1
	mov	[word ptr addy],0                                                     
	mov	[word ptr addnc],0                                              
	call	PrintString                                                  
	                                    
	; convert string to 3D object	                                       
	mov	di,(-RSize*8*5/2)-RSize/4   	; x                          
 	mov	dx,(-RSize*8) 	       		; y                             
 	xor     bp,bp	      	; pointer                                       
 	xor	bx,bx		; counter          
 	lea     si,[ReliQ]      ; point to the array
 	mov     ah,5                                                            
 	@@makeReliQ:                                                      
 	      	mov     cl,16                              
 		@@columns3D:                       
		     	mov     ch,8                                            
 		    	@@rows3D:                  
 		    	     	cmp     [byte ptr fs:bp],0
 				jz      @@dark3D          
 			  	    	mov     [ds:si],di              ; x           
 		  	  		mov     [ds:si+2],dx            ; y     
 			 		mov     [word ptr ds:si+4],0	; z           
 					      	   	  	     	   	
 		   			mov     [ds:si+6],di            ; x     
 					add     [word ptr ds:si+6],RSize        
 					mov     [ds:si+8],dx            ; y     
 					mov     [word ptr ds:si+10],0 	; z     
 							  	    	    	
 			  		add     si,12                           
 					                                        
 					add	bx,12                           
 				@@dark3D:                                       
 			inc     bp                                              
 			add     di,RSize                                        
 			dec     ch                                              
 		      	jnz     @@rows3D                                        
 		sub	di,RSize*8          
 		add     dx,RSize
 		dec     cl                  
 		jnz     @@columns3D                                                   
 	sub	dx,RSize*16                                                     
 	add	di,RSize*9                                                            
 	dec     ah                                                              
 	jnz     @@makeReliQ                                                     
 	                                    
 	mov     [RCount],bx                                                    

                                                                            
	;--------------------------------------------------------------------
	; do the music routine stuff 	
        
	; initialize counter                                                    
	mov	[word ptr count],0                                        
	lea	bp,[song]
	mov	[songptr],bp             
	                      
	; transpose tek3 3 notes up to tek4 
	lea	si,[tek3]
	lea	di,[tek4]                   
	mov	cl,20                                                                 
	@@allnotes:
		mov	ax,[ds:si]                                                    
		add	ah,3                                                    
		mov	[ds:di],ax                                              
	add	di,2                        
	add	si,2                                                           
	dec	cl
	jnz	@@allnotes
 	                                  
	; initialize MIDI                              
	mov	dx,(MPU+1)	; Command Port
 	mov	al,0FFh	  	; Reset                                         
 	out	dx,al                                                     
 	mov	al,03Fh	   	; UART mode                
 	out	dx,al                      
 	mov	bl,0FFh                                 
 	call	WriteMPU  	; System Reset          
	; initialize instruments                         
 	lea	di,[instrm+18]              
 	mov	bx,9                                                                  
 	@@allchannels:                                  
 	    	push	bx                                                            
 		add  	bl,0C0h	       	; program change                        
 		call	WriteMPU                                                
 		mov	bl,[ds:di]          
 		call	WriteMPU
 	 	pop 	bx
 	 	push	bx                                                  
 	 	add	bl,0B0h           
 	 	call	WriteMPU                       
 	 	mov	bl,7 		; volume control
 	 	call	WriteMPU                                                
 	 	mov	bl,[ds:di+1]                                      
 	 	call	WriteMPU                           
 	 	pop	bx               
	sub	di,2                
 	dec	bx                               
 	jns	@@allchannels                            
 	                                    
 	; put vibrato in channel 6                                                    
 	mov	bl,0B6h
 	call	WriteMPU                                                              
 	mov	bl,1		; modulations wheel                             
 	call	WriteMPU                                                        
 	mov	bl,07Fh                     
 	call	WriteMPU                                                       
 	                                                                     
	;--------------------------------------------------------------------
	; display on final message in the start-up sequence                                
;       mov     ah,09h                                                       
;       lea     dx,[fnlmsg]                                                    
;       int     21h                                                             
;       mov     ah,86h  ; delay                                              
;       mov     cx,10h                                                       
;       xor     dx,dx                                                        
;       int     15h                                                         
				      	    
	dingaling:                                                               
				     	    
	;--------------------------------------------------------------------         
	; GFXmode                                                            
	mov     ax,13h                                                                
	int     10h                                                             
		   						       	        
	;--------------------------------------------------------------------
	; set start-up palette (luckily the same as for the GNU fractal)       
	mov     bl,63                                                        
	call    FadeIn                                                       
	                  
	;--------------------------------------------------------------------
	; wait for graphics mode to stabalize                                
;	mov     ah,86h  ; delay                                                 
;      	mov     cx,10h                                                    
;	xor     dx,dx                                      
; 	int     15h                      
	call	GenGNU        
	; insted of a delay, use this highly computational procedure
	                                                                    
	;--------------------------------------------------------------------
	; do some more music routine stuff                                            
	cli                          
 	; reprogram frequency of the timer                                            
 	mov	dx,basespeed
 	call	freq                                                                  
 	                                                                        
 	; change interrupt vector to my timer interrupt                         
	mov	ax,3508h  	; get vector for interrupt 08h               
 	int	21h   	    	; returns vector in es:bx                   
 	mov	[oldiseg],es                              
 	mov	[oldiofs],bx                              
 	mov	ah,25h	 	; set vector              
 	; ds = cs anywayz                                                       
 	mov	dx,offset Music                                           
 	int	21h                                        
 	                                                  
 	sti                   
 	                              
	;--------------------------------------------------------------------
	; start with the presentation       
	@@stars:                                                                      
		mov	eax,080808080h
		call	ClearDblBuf                                                   
		                            
		lea     bp,[starstuff]                                                
		mov     gs,[jseg]                                               
		lea     di,[stars]                                              
		mov     si,(amount*6)                                         
		call    TransformObject                                     
		                  
		mov     fs,[doublebuffer]
		mov     si,((amount*6)-6)
		@@allstars:                                                     
			call    project                                     
			; clipping                                          
			cmp     ax,200                                         
			jae     @@nogo                                          
		   	cmp     di,320
		       	jae     @@nogo                                          
			; pixel position                                              
			lea     eax,[eax*4+eax] ; *5                                  
			shl     ax,6            ; *64                           
			add     di,ax                                                 
			; color                                                 
			mov     ax,[gs:si+4]                                          
			shr     ax,9                                            
			add     al,65                                           
			mov     [fs:di],al      ; write star to doublebuffer 
		  	@@nogo:                                             
		sub     si,6                                            
		jns     @@allstars
		
		call    WaitVert	; wait for vertical retrace             
		call    DoStuff	  	; do whatever during the starfield
					; and do it quick  
		call    DisplayDblBuf	; display the whole stuff
	  	                                                 
	mov	ax,[count]
	cmp	ax,01800h
	jb	@@stars
	
	;--------------------------------------------------------------------
	; ready the system for the fire part                                          
	xor	eax,eax                  
	call	ClearDblBuf                                             
	call	FirePalette              
	                                 
	; these values will be needed from now on   
	mov	[byte ptr c],104         
	mov	[word ptr addx],8                               
      	mov	[word ptr addy],320-64
      	mov  	[word ptr addnc],-320*16+72
      	                                                                        
	mov  	fs,[doublebuffer]        
	@@flameage:                      
		call	FlameFrame       
 		call	WaitVert
		call	DoStuff
		;call  	DisplayDblBuf
	mov	ax,[count]                                                            
	cmp	ax,02600h
	jb	@@flameage
                                                                                      
 	;--------------------------------------------------------------------  
 	; zoom-in into the gnu fractal                                       
 	mov   	[dword ptr cs:color],40058064h	; modify PrintString
		; now it says: "add [fs:di],64"
 	                                                            
	mov     fs,[doublebuffer]                                   
	mov     dx,gxsize                                           
       	@@zoomin:                                                               
            	lea     ebx,[edx*4+edx] ; *5                        
               	shr     bx,3            ; /8                                    
               	call    DisplayGnu      ; displays gnu in dx*bx resolution
                                       ; in segment fs (=doublebuffer)
               	cmp     dx,(gxsize-64)                                          
               	jle     @@fadeincomplete                                        
                	mov     bx,gxsize                                             
                       	sub     bx,dx                               
                       	call    FadeIn                                                
                                                                                
                       	; write "THE END" over GNU                              
 	    		lea	si,[strings+28]                     
 		 	mov	cl,3                                            
                      	mov	di,26936
                      	;mov	[word ptr addx],8                               
                     	;mov	[word ptr addy],320-64
                       	;mov  	[word ptr addnc],-320*16+72
                     	call	PrintString       
                     	lea    	si,[strings+30]
                     	mov	cl,3
                     	mov	di,32060
                     	call	PrintString                                     

			jmp     @@GnuNOW        
             	@@fadeincomplete:               
               	cmp     dx,(gxsize-64-18)       
               	jg      @@GnuNOW                                                      
               	cmp     dx,(gxsize-64-18-32)    
               	jle     @@evilizecomplete                                             
               	     	mov     bx,(gxsize-64-18)
                       	sub     bx,dx                                   
                       	call    Evilize         
                       	jmp     @@GnuNOW                                       
          	@@evilizecomplete:          
               	cmp     dx,324           
               	jg      @@GnuNOW                
               	       	mov     bx,324              
                       	sub     bx,dx    
                       	call    Fadeout  
		@@GnuNOW:                
		                         
	  	call    WaitVert                                                
               	call    DisplayDblBuf    
                                         
        mov	ax,[count]               
        sub	ax,02600h                
        xor	dx,dx                                                                 
        mov	bx,6                     
        div	bx                                                                    
   	mov	dx,gxsize
	sub	dx,ax                                                   
	cmp     dx,320   
       	jg      @@zoomin                                                       
                             
Exit:                           
     	; set old interrupt vector
	cli                                                 
 	mov	ax,2508h       	; set vector                
 	mov	dx,[oldiofs]                                
	push	ds
 	mov	ds,[oldiseg]            
 	int	21h                                                             
 	pop	ds                                       
    	sti                                                                  
    	                                                                         
 	; shutdown MIDI, well it's an All Notes Off command                      
; 	mov	ah,15                                                            
; 	@@allchannels:                                                           
; 	     	mov	bl,ah                                                    
; 		add	bl,0B0h		; control change                         
; 		call	WriteMPU                                                 
; 		mov	bl,07Bh	  	; All Notes Off                          
; 		call	WriteMPU                                                 
; 		xor	bl,bl                                                    
; 		call 	WriteMPU                                                 
; 	dec	ah                                                               
; 	jns	@@allchannels                                                    
 	                                                                         
 	; Textmode                                                               
	mov     ax,3                                                             
	int     10h                                                              
			    	    					         
 	; Print Endmessage                                                       
;	mov     ah,09h
; 	lea     dx,[endmsg]              
; 	int     21h           
						     				      	   
	; Exit                                                          
	mov     ax,4C00h        ; exit program with errorlevel 0                      
	int     21h             ; call DOS                              
		  		      				    	
;============================================================================
		      		   		 		               
;----------------------------------------------------------------------------   
; All I need is: ds:bp pointing to [starstuff], [count] for synchronization
;                and fs = [doublebuffer]
; All I destroy is                                  
;----------------------------------------------------------------------------
Proc    DoStuff                
	mov	ax,[count]
	
	sub     [word ptr starstuff+10],50
                                    
	sub	ax,00100h                                                    
	js 	donothing                
	sub	ax,0FCh       
	js 	SLi                                                                        
	sub	ax,0100h 
	js 	SLiGo                                                                 
	sub	ax,0104h
	js	donothing             
	sub	ax,0FCh 
	js 	PRESENTS                                                       
	sub	ax,0100h  
	js 	PRESENTSGo
	sub	ax,0204h
 	js	donothing                           
	sub	ax,040h      
	js 	ReliQCome      
	sub	ax,01C0h
	js	ReliQBe    
	sub	ax,040h                   
	js 	ReliQGo             
	sub	ax,0180h
	js	donothing                
	sub	ax,020h       
	js	hail                                                                       
	sub	ax,020h    
	js 	hale                                                                  
	                  
	sub	[word ptr starstuff+10],300
                                                                             
    	sub	ax,020h                                                        
	js 	bopp      
	sub	ax,02A0h
	js 	ComeComet
 	sub	ax,0940h
	js	StarTekkno
	sub	ax,0E00h
 	js	BurnTekkno
                         
 	ret                                                                  
                                                                             
	;--------------------------------------------------------------------                                                                             
 	SLiGo:                                                               
	add  	ax,100h                                                      
	neg	ax                                                           
	SLi:                                                                 
	neg 	ax                                                           
	shr	ax,2                                                         
	inc	al                                                           
	lea	si,[strings]                                                               
	mov	cl,3   	       	; the whole of "SLi"                            
	mov	di,20265                                                              
 	mov	[c],al                                                       
	mov	[word ptr addx],4                                            
	mov	[word ptr addy],320*5-32                                     
	mov	[word ptr addnc],-320*5*16+46                                
 	call	PrintString                                                      
                                                                             
	ret                                                                  
                                                                             
	;--------------------------------------------------------------------	                                                                     
	PRESENTSGo:                                                          
	add  	ax,100h                                                      
	neg	ax                                                           
	PRESENTS:                                                            
	neg 	ax                                                           
	shr	ax,2                                                         
	inc	al                                                           
	lea	si,[strings+3]	; point to "P" in                                
	mov	cl,8	       	; "PRESENTS"                                 
	mov	di,29460                                                                   
	mov	[c],al                                                       
	mov	[word ptr addx],4                                                     
	mov	[word ptr addy],320-32                                           
	mov	[word ptr addnc],-320*16+36                                      
	call	PrintString                                                      
	                                                                         
	ret                                                                      
                                                                             
	;--------------------------------------------------------------------	                                                                     
	ReliQGo:                                                             
	add  	ax,40h                                                       
	neg	ax                                                           
	                                                                     
	ReliQCome:                                                           
	neg	ax                                                           
	shr	ax,2                                                         
	add	ax,48                                                        
	jmp  	DoReliQ                                                      
	                                                                     
	ReliQBe:                                                             
	mov    	ax,48                                                        
	                                                                     
	DoReliQ:                                                                      
	push	ax                                                           
	                                                                         
	lea	di,[ReliQ]                                                       
	mov	gs,[jseg]                                                        
	mov	si,[RCount]                                                      
	lea	bp,[ReliQstuff]                                                  
                                                                               
	sub	[word ptr ds:bp+2],5
                                                                               
	call	TransformObject
                                                    
	mov	fs,[doublebuffer]                                                 
	mov	si,[RCount]                                                 
	sub	si,12                            
	@@doRlogo:                               
	   	call	project                  
		mov	[x1],di                  
		mov	[y1],ax                  
		add	si,6                     
		call	project                                                       
		mov	[x2],di                  
		mov	[y2],ax                  
                                                     
		mov	[byte ptr c],1
 		mov	ax,[ds:bp+2]   	; angle                              
 		cwd                              
 		xor	ax,dx  	       	; abs                                   
 		shl	ax,5                     
 	  	mov	dx,RDistance+HWidth      
 		sub	dx,ax
 		pop	ax   	; contains the color
 		push	ax                          
 		cmp	[gs:si+4],dx                
		jbe 	@@almosthighlight           
    		     	mov  	[c],al
		@@almosthighlight:               
		sub	dx,HWidth*2              
 		cmp	[gs:si+4],dx             
		jae 	@@highlight            
	 	  	mov 	[c],al                                                
		@@highlight:	 	 	
 	   	                                
		push	bp                           
		call	line                    
	  	pop   	bp                                                   
                                                                                 
	sub	si,(12+6)          
	jns	@@doRlogo   
	                                 
	pop	ax	; just to clean up stack
		                   
	ret                
                                                                             
	;--------------------------------------------------------------------	                   
	hail:                                                   
	        lea	si,[strings+16]
	        mov	di,8410               
		jmp	printf 	                     
	hale:                                        
	        lea	si,[strings+20]              
	        mov	di,24410                                                      
	       	jmp	printf	                     
	bopp:                                        
 	        lea	si,[strings+24]              
	        mov  	di,40410     
	printf:	                                                             
	 	mov   	bl,64                        
		add	bl,al                        
		call	FadeIn                       
                                                     
		mov	cl,4                         
		mov	[byte ptr c],65              
		mov	[word ptr addx],4
		mov	[word ptr addy],320*3-32                             
 		mov	[word ptr addnc],-320*16*3+36		
		call 	PrintString  
	                                                                     
	ComeComet:                                                           
	lea  	di,[comet]                                                   
	mov	[byte ptr c],65                                              
	mov	si,(CStuff1-comet)    
	lea	bp,[CStuff1]
	add	[word ptr ds:bp+10],-37	; comet comes toward screen
 	add	[word ptr ds:bp+6],-9  	; comet centers itself
	add	[word ptr ds:bp+2],-27 	; it turns while it comes
	call  	DisplayVectorObject                                          
	                                                                     
	ret                                                                  
                                                                             
	;--------------------------------------------------------------------                                         
	StarTekkno:                                             
	mov  	dx,[temp]
 	mov	di,[direction]
 	mov	bl,[flashdegree]
 	            
 	mov	bp,[pointer+2]                    
 	cmp	bp,dx
 	je	@@nochange                        
                                                  
   	   	mov	[temp],bp	; store current pointer
                                                               
	 	mov	ax,[ds:bp-2]                           
	 	cmp	ah,10100110b 	; snaredrum
	 	jne	@@nosnare
		      	mov  	bl,-18h                        
		      	jmp	@@nochange                     
		@@nosnare:		; bassdrum             
		  	neg   	di
		  	mov	[direction],di
		  	                                       
	@@nochange:                                            
	; flash                                                
	add    	bl,63                                          
	call	FadeIn                                         
	sub	bl,63                                          
	; -"-                                                   
	cmp	bl,0                          
	jge    	@@nodec                                        
	   	inc 	bl                                     
	@@nodec:                                               
	; -"-                                                  
	mov	[flashdegree],bl              
                                              
	; turn	                                 
	add   	[word ptr starstuff+4],di     
 	                                                                     
 	ret                                   
        
	;--------------------------------------------------------------------
	BurnTekkno:               
	                                   
 	
 	push	ax                         
 	                                                       
 	mov	cx,[direction]
 	mov	dx,[temp]                                      
 	mov	bp,[pointer+2] 	 	                       
	mov	ax,[ds:bp-2]
 	cmp	bp,dx
 	je	@@noreversal                                   
                                                               
   	   	mov	[temp],bp 	; store current pointer
                                                               
	 	cmp	ah,10100110b 	; snaredrum
	 	jne	@@noreversal
		  	neg 	cx
		  	mov	[direction],cx
		   	                   
	@@noreversal:                      
                                           
        lea    	di,[comet]                 
 	mov	[byte ptr c],104           
 	mov	si,(CStuff1-comet)         
   	                                   
	cmp	ah,10100110b  	; snaredrum
	jne	@@flameflame              
	 	push 	di si cx    
 	 	lea	bp,[CStuff3]
	 	add	[word ptr ds:bp+2],cx
	 	call  	DisplayVectorObject  
 	 	                             
		pop	cx si di                
	 	lea	bp,[CStuff4]         
	 	add	[word ptr ds:bp+2],cx
	 	call  	DisplayVectorObject  
	                                   
		jmp	@@flameobject             
 	@@flameflame:                                                                     
 	lea	bp,[CStuff2]        
 	add	[word ptr ds:bp+2],400
 	call  	DisplayVectorObject
 	        
 	@@flameobject:
 	                           
 	call	DisplayDblBuf
 	                               
 	pop	ax                     
                                       
	; print THE END when appropiate
	cmp	ax,-40h 	
	jle	@@skipTHEEND
                            
	push	fs    
	mov	bx,0A000h
	mov	fs,bx
	                   
 	cmp	ax,-20h            
 	jle	@@skipEND          
 	                           
 		mov 	di,32060             
	 	lea	si,[strings+30]
	 	mov	cl,3       
	 	call  	PrintString
 	                           
 	@@skipEND:                 
 	                           
 		mov 	di,26936       	
	 	lea 	si,[strings+28]
	 	mov	cl,3       
 	 	call	PrintString
 	                   
 	pop	fs         
 	                   
 	@@skipTHEEND:      

	;-------------------------------------------------------------------- 	                                                                     
 	donothing:                                                           
	                                                                     
	ret                                                                  
EndP                                                                         
;----------------------------------------------------------------------------
                                                                             
include "procs.inc"     ; tempororarily stored seperatly                     
                                                                             
;============================================================================
			  						     
; uninitialized variables                                               
doublebuffer    dw      ?       ; segment for doublebuffering       
sinseg          dw      ?       ; segment for the sin/cos table     
gnuseg1         dw      ?       ; first segment to store GNU data in
gnuseg2         dw      ?       ; and the second
flametable      dw      ?       ; segment for the flame effect  
jseg            dw      ?       ; a general purpose segment     
								
temp    dw      ?       ; you never know when you need one of these
flashdegree	db	?
								
; the following uninitialized variables are needed by the GNU algorythm
x       dd      ?                                                             
xi      dd      ?                                               
xr      dd      ?                                               
yr      dd      ?                                                           
yi      dd      ?                                               
								
; room for the starfield                                        
stars   dw      3*amount dup (?)
                                                                        
; room for the ReliQ logo
ReliQ   dw      3*2*200 dup (?) ; in my font it's 167, so 200 is should be ok
RCount  dw      ?       ; number of pixels in logo
	                        
; variables needed by the line algorythm                        
x1      dw      ?                                               
x2      dw      ?                                               
y1      dw      ?                                               
y2      dw      ?                                                               
c       db      ?	; also used by PrintString
deltax  dw      ?                                               
deltay  dw      ?                                 
                                                  
; the following variables are needed by the procedure PrintString
addx 	dw	?
addy  	dw	?
addnc	dw	?	; NextCharacterADD

; stuff needed by the music routine
oldiseg	dw	?	; old timer interrupt vector segment
oldiofs	dw	?	; old timer interrupt vector offset
count	dw	?	; a counter for synchronization
songptr	dw	?	; points to songs data
pointer	dw	4 dup (?)	; points to pattern data
tek4	db	20*2 dup (?)	; yet another pattern
		 						
;----------------------------------------------------------------------------         
	END     Data            ; end of program / entry point              
	                                                        
