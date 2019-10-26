; SET TABS TO 8
; ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
; บฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐบ
; บฐฐฐฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟฐฐฐบ
; บฐฐฐณ 1k Intro - (c)1996 SparC                                        ณฐฐฐบ
; บฐฐฐณ                                                                 ณฐฐฐบ
; บฐฐฐณ code:Frenzy                                                     ณฐฐฐบ
; บฐฐฐณ                                                                 ณฐฐฐบ
; บฐฐฐณ read SOURCE.NFO for details                                     ณฐฐฐบ
; บฐฐฐภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฐฐฐบ
; บฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐบ
; ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
	.MODEL small
        .386
	 IDEAL
	 LOCALS
	 
; ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
; ณฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐMAIN CODE SEGMENTฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐณ
; ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
SEGMENT MAIN_CS DWORD PUBLIC 'CODE'
	ASSUME CS:MAIN_CS, DS:MAIN_CS, SS:MAIN_CS
	ORG     100h

        ; some equates for julia fractal
        J_maxiterations equ     63           
        J_maxsize       equ     4
        J_xmax          equ     28643     
        J_xmin          equ    -28643    
        J_ymin          equ    -48643    
        J_ymax          equ     48643      
        J_pvalue        equ     26107
        J_qvalue        equ     29452        

        J_xsize1        equ     320
        J_ysize1        equ     200           
        J_deltax1       equ     (J_xmax - J_xmin) / 320
        J_deltay1       equ     (J_ymax - J_ymin) / 200
        J_xsize2        equ     256
        J_ysize2        equ     256           
        J_deltax2       equ     (J_xmax - J_xmin) / 256
        J_deltay2       equ     (J_ymax - J_ymin) / 256


        Start:
; ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
; บฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐMAIN BODY OF PROGRAMฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐบ
; ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
PROC    Main
        ; On entry to a .COM file we have our registers set to:-
        ;
        ; AX=0, BX=0, CX=0, DX=0

        mov     di,offset ZeroData      ; initalise zero data
	mov     cx,di
	neg     cx
        repz    stosb

        mov     bx,1000h 
        mov     ah,4Ah   
        int     21h

        call    AllocMem
	mov     fs,ax                   ; fs->bump map
        call    AllocMem                 
	mov     gs,ax                   ; gs->fractal
        call    AllocMem                 
        mov     es,ax
        mov     [tunnellookup],ax
  อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ
	mov     di,offset sintab        ; builds sine/cosine table
        finit                           
        fldpi                           
        fstp    [pi]
        mov     bx,512
@@buildsincos:                       
        fldpi
        fimul   [temp1]        
        fidiv   [degs]                 
	fsincos                       
	fimul   [temp2]                 
        fistp   [word ptr di]      
	fimul   [temp2]
        fistp   [word ptr di + bx]
        inc     di
        inc     di
        dec     [temp1]
	jnz     @@buildsincos
  อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ
        xor     di,di                   ; builds tunnel table
        mov     ebp,200                 
@@yloop:mov     ecx,160
@@xloop:mov     eax,ecx
        sub     eax,80             
        mov     ebx,ebp 
        sub     ebx,100             
	mov     [temp1],eax
	mov     [temp2],ebx
        fild    [temp2]                 
	fild    [temp1]
        fpatan                     
        fimul   [degs]                   
        fdiv    [pi]               
        frndint                     
        fistp   [word ptr temp4]        
        imul    eax,eax                 
        imul    ebx,ebx               
        add     eax,ebx               
	mov     [temp1],eax
	fild    [temp1]
        fsqrt                        
	fistp   [temp1]
        mov     ebx,[temp1]
        inc     bx
        mov     ax,10 * 256             
	cdq
        idiv    bx                      ; this gives tunnel some perspective
        shl     ax,8
        and     [word ptr temp4],255    
        add     ax,[temp4]
        stosw
	loop    @@xloop
	dec     bp
	jnz     @@yloop
  อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ
        mov     ax,13h                  ; set gfx mode
	int     10h
	push    0A000h
        pop     es                      ; es->video buffer
  อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ
        push    ds                      ; creates our bump map...
        push    fs                      
        pop     ds
        mov     bx,64000
        mov     bp,36                   
@@make_surface:
	mov     cx,255
        movsx   dx,[bx-3]
	rol     dx,cl
	xor     cx,dx
        mov     ax,1234         
        add     ax,bp           
        xor     al,ah           
        add     ax,4321         
        ror     al,2                   
        xor     ah,al           
        mov     bp,ax           
        xor     dx,dx           
        div     cx              
        mov     cx,dx           
        mov     [bx],cl
	dec     bx
        jnz     @@make_surface
        mov     dl,7
@@smoothloop1:                          ; smooth out the bump map
        xor     si,si
	mov     cx,64000
@@smoothloop2:
        lodsb                           ; a little size optimize here.
        mov     bl,[si]                 ; the lodsb saves a inc si :)
        add     ax,bx                  
        mov     bl,[si+319]
        add     ax,bx
        mov     bl,[si+320]
	add     ax,bx
	shr     ax,2
        mov     [si-1],al
        loop    @@smoothloop2
        dec     dx
        jnz     @@smoothloop1
        pop     ds
  อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ
        mov     cx,255                  ; set our palette for 1st effect
	mov     dx,3C8h
        mov     al,1              
	out     dx,al
	inc     dx
@@makepal:
	mov     ax,cx                   ; crappy linear palette.. next time
	shr     ax,2                    ; i'll make it better :)
	out     dx,al
        shr     ax,1                    
	out     dx,al
        shr     ax,2                  
	out     dx,al
	loop    @@makepal
  อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ
        mov     [J_xsize],J_xsize2      ; make julia texture for tunnel
        mov     [J_ysize],J_ysize2
        mov     [J_deltax],J_deltax2
        mov     [J_deltay],J_deltay2
        call    JuliaSet                
	push    cs
	pop     ds
  อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ
        xor     dx,dx                   ; bump mapping controlling loop
@@MAINLOOP:
        mov     bx,cx                   ; just make a path for light
	shl     bx,1
	mov     ax,[costab + bx]
	imul    ax,[sintab + bx]
	sar     ax,10
	mov     [lx],ax
	mov     bx,dx
	shl     bx,1
	mov     ax,[sintab + bx]
	sar     ax,3
	mov     [ly],ax
        pusha
        call    DoBump                  ; do that bump
        popa
        add     cl,2
	add     dl,2
	inc     [framecounter]
        cmp     [framecounter],256      ; shite frame counting.. no sync :)
	jae     @@stopbump
        cmp     [yclip],10              ; just some lamer clipping..:)
        jbe     @@MAINLOOP          
	dec     [yclip]
	jmp     @@MAINLOOP
@@stopbump:
  อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ
        mov     cx,64000                ; clears the screen..
        xor     al,al
        xor     di,di
        rep     stosb   
        mov     dx,3C8h                 ; set our grey scale palette
	out     dx,al
	inc     dx
	mov     cx,64
@@greys:out     dx,al
	out     dx,al
	out     dx,al
        inc     ax                      ; inc ax 1 byte smaller than inc al 
	loop    @@greys
        mov     [J_xsize],J_xsize1
        mov     [J_ysize],J_ysize1
        mov     [J_deltax],J_deltax1
        mov     [J_deltay],J_deltay1
	push    gs
	push    es
	pop     gs
	call    JuliaSet
	pop     gs
        mov     cx,500                  ; this is one way to do a delay
@@delay:mov     dx,3DAh                 ; i suppose :)
@@r1:   in      al,dx
        test    al,8
        jnz     @@r1
@@r2:   in      al,dx
        test    al,8
        jz      @@r2
	loop    @@delay
  อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ
        mov     dx,2024                 ; little tunnel routine :)
        mov     ax,[tunnellookup]
        mov     ds,ax
@@MAINLOOP2:
        mov     cx,64000 / 2    
        xor     di,di
@@tunneldraw:
        mov     bx,[di]               
        mov     al,[gs:bx]             
        mov     ah,al                   ; double resolution in x direction
        add     [word ptr di],257
        stosw                       
        loop    @@tunneldraw
        dec     dx
        jnz     @@MAINLOOP2
  อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ
        mov     ax,3                    ; and its back to dos....
	int     10h
	push    cs
	pop     ds
        mov     dx,offset quitmsg     
	mov     ah,9
	int     21h
        int     20h                     ; say goodbye.............
ENDP

;ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
;บ AllocMem - allocates 64k of memory                                       บ
;บ                                                                          บ
;บ  in: -                                                                   บ
;บ out: AX = segment of memory block                                        บ
;ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
PROC    AllocMem NEAR
	mov     bx,1000h
	mov     ah,48h
	int     21h
	ret
ENDP
;ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
;บ DoBump - Does the 2d bump mapping        **NOT OPTIMISED REALLY**        บ
;บ                                                                          บ
;บ  in: FS->bump map, [lx] and [ly] are light positions                     บ
;บ out: -                                                                   บ
;ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
PROC    DoBump NEAR
	mov     [ycounter],0
	mov     di,321
	mov     si,-99
@@l1:   mov     bp,-158
@@l2:   movzx   ax,[fs:di+1]
	movzx   bx,[fs:di-2]
	sub     ax,bx
	mov     bx,bp
	sar     bx,1
	sub     bx,[lx]
	sub     ax,bx
	movzx   cx,[fs:di+320]
	movzx   dx,[fs:di-640]
	sub     cx,dx
	mov     dx,si
	sar     dx,1
	sub     dx,[ly]
	sub     cx,dx
	imul    ax,bx
	imul    cx,dx
	add     ax,cx
	cwd
	xor     ax,dx
	sub     ax,dx
	shr     ax,4
	inc     ax
	or      ah,ah
	jz      @@PlotPixel
	mov     al,255
@@PlotPixel:
	mov     bx,[yclip]
	cmp     [ycounter],bx
	jl      @@skipy
	neg     bx
	add     bx,199
	cmp     [ycounter],bx
	ja      @@skipy
        stosb
        dec     di
@@skipy:
        inc     di
	inc     bp
	cmp     bp,159
	jle     @@l2
	inc     [ycounter]
        inc     di
        inc     di
	inc     si
	cmp     si,99
	jle     @@l1
	ret
ENDP
;ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
;บ JuliaSet - draws a julia fractal                                         บ
;บ               NOT OPTIMISED AT ALL :)))                                  บ
;บ  in: -                                                                   บ
;บ out: -                                                                   บ
;ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
PROC JuliaSet NEAR
	push    cs
	pop     ds
	xor     ebp,ebp             
	mov     cx,[J_xsize]
@@JuliaA:                               
	push    cx                      
	xor     esi,esi             
	mov     cx,[J_ysize]
@@JuliaB:                               
	push    cx                      
	mov     eax,[J_deltax]
	imul    eax,ebp                 
	add     eax,J_xmin              
	mov     ecx,eax                
	mov     eax,[J_deltay]       
	imul    eax,esi                 
	mov     ebx,J_ymax              
	sub     ebx,eax              
	mov     [J_colour],0       
@@JuliaC:                             
	mov     eax,ecx                 
	cdq                             
	imul    ecx                     
	shrd    eax,edx,16
	mov     [J_xx],eax         
	mov     eax,ebx               
	cdq
	imul    ebx                     
	shrd    eax,edx,16              
	mov     [J_yy],eax        
	mov     eax,ecx                 
	cdq                             
	shl     eax,1                   
	imul    ebx                     
	shrd    eax,edx,16              
	add     eax,J_qvalue     
	mov     ebx,eax                 
	mov     eax,[J_xx]           
	sub     eax,[J_yy]           
	add     eax,J_pvalue       
	mov     ecx,eax                
	inc     [J_colour]           
	mov     al,[J_colour]        
	cmp     al,J_maxiterations    
	jae     @@JuliaD                
	mov     eax,[J_xx]           
	add     eax,[J_yy]           
	shr     eax,16                  
	cmp     eax,J_maxsize       
        jb      @@JuliaC    
@@JuliaD:
	pop     cx                      
	mov     di,si
	imul    di,[J_xsize]
	add     di,bp                   
	mov     al,[J_colour]        
	mov     [gs:di],al
        inc     esi
        dec     cx
        jnz     @@JuliaB
	pop     cx                      
	inc     ebp
        dec     cx
        jnz     @@JuliaA
	ret
ENDP

; ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
; บฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐMAIN DATAฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐบ
; ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
degs            dd      128
temp1           dd      256
temp2           dd      256
yclip           dw      100
quitmsg         db      'code:Frenzy$' 


; everything below this line is removed by POST.EXE. Its all zero data so
; it can be constructed at runtime. Remember, dont forget to make the last
; byte above this marker a non zero byte. In this case its a '$'.
		ZERODATA:

J_xsize         dw      0  
J_ysize         dw      0             
J_deltax        dd      0                      
J_deltay        dd      0                          
lx              dw      0
ly              dw      0
sintab          dw      256 dup(0)
costab          dw      256 dup(0)
temp3           dd      0
temp4           dw      0
temp5           dd      0
ycounter        dw      0
J_xx            dd      0            
J_yy            dd      0          
J_colour        db      0       
tunnellookup    dw      0
pi              dd      0
framecounter    dw      0
fadeframe       db      0
ENDS
END START
