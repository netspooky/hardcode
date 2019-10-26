;---------------------------------------------------------------------------
; PoPsY InTrO by GÄHell / PoPsY TeAm                                        \
; Official source release : 14-june-1999                                     ;
;                                                                            ; 
;Ok this is hardly readable, but my aim was to shrink it, that's why a lot of;
;functions have been deleted and integrated directly in the code             ;
;                                                                            ; 
;                                                                            ; 
;Of course, you can read those lines, understand them and, maybe, greet us :);
;However, please, do not modify this code stupidly                           ;
;This is released only to help people learning assembly langage              ; 
;                                                                            ;
;In one word : don't be a lamer, respect other's work                        ;
;---------------------------------------------------------------------------/



;-----------------------------------------------------------------------------
;                       F R A C T A L   C O D E                              | 
;-----------------------------------------------------------------------------
Calcmap		Proc Near
	Mov	Es,te_seg
	Xor	Di,Di
	Mov	Cx,4000h
	Stc
	Sbb	Eax,Eax
	Rep	Stosd
	Mov	Al,60        
	Stosb                
	Xor	Bx,Bx        ;Earns 4 bytes after packing
        Mov     Cx,256

	Call	Calcfractal
           
;----------------------------------------[ Blur ]----+
	Mov	Ecx,256*256                          ; 
	Mov	Es,te_seg                            ; 
	Xor	Di,Di                                ; 
@@Blurrloop:                                         ; 
	Xor	Ax,Ax                                ; 
	Xor	Dx,Dx                                ; 
	Mov	Al,Es:[Di-255]                       ; 
	Mov	Dl,Es:[Di+255]                       ; 
	Add	Ax,Dx                                ; 
	Mov	Dl,Es:[Di-257]                       ; 
	Add	Ax,Dx                                ; 
	Mov	Dl,Es:[Di+257]                       ; 
	Add	Ax,Dx                                ; 
	Mov	Dl,Es:[Di-256]                       ; 
	Add	Ax,Dx                                ; 
	Mov	Dl,Es:[Di+256]                       ; 
        Add     Ax,Dx                                ; 
	Mov  	Dl,Es:[Di+1]                         ; 
	Add   	Ax,Dx                                ; 
	Mov	Dl,Es:[Di-1]                         ;
	Add	Ax,Dx                                ; 
	Shr   	Ax,3                                 ; 
        stosb                                        ; 
        loop    @@Blurrloop                          ; 
;-------------------------------------[ Blur End ]---+
                                       
 	Ret                           
Calcmap		Endp
 
                              






Calcfractal     Proc Near
        Noise2  Macro         
		Local @@Notnegatif,@@Nottoohigh
                Push    Ax        
                Pusha             
                Mov     Eax,Dword Ptr [Randomseed]
		Mov     Ebx,16807d
                Imul    Ebx       
		And     Eax,07FFFFFFFh
		Mov     Dword Ptr [Randomseed],Eax
                Popa              
		Mov    	Edx,[Randomseed]
                Mov     Ax,Cx           
                Shl     Ax,2            
                Imul    Dx              
                Pop     Ax        
                Add     Dx,Ax     
                Or      Dx,Dx     
		Jge	@@Notnegatif
                Xor     Dx,Dx       
                @@Notnegatif:  
                Cmp     Dx,255d
		Jb	@@Nottoohigh
                Mov     Dl,254d
                @@Nottoohigh:  
                Mov     Al,Dl  
                               
                or      al,al  
                jnz     $+3      
                inc     ax     
       		and     al,127d
                Mov     Es:[Di],Al
		Endm
                
	Noise	Macro
		Local @@Nonoise
		Cmp	Byte Ptr Es:[Di],0FFh
		Jne	@@Nonoise
		Noise2
		@@Nonoise:
		Endm
	Shr	Cx,1
	Jz	@@Endcalc
;:::::::::::::::::::::w(u+l/2,v)=[w(u,v)+w(u+l,v)]/2+noise...
        Xor     Ax,Ax
        Xor     Dx,Dx
        Mov     Di,Bx
        Mov     Al,Es:[Di]
        Add     Bl,Cl
        Add     Bl,Cl
        Mov     Di,Bx
        Mov     Dl,Es:[Di]
        Add     Ax,Dx
        Shr     Ax,1 
                     
        Sub     Bl,Cl
        Mov     Di,Bx
        Noise        
;:::::::::::::::::::::w(u,v+l/2)=[w(u,v)+w(u,v+l)]/2
	Xor	Ax,Ax
	Xor	Dx,Dx
	Sub	Bl,Cl
	Mov     Di,Bx
	Mov	Al,Es:[Di]
	Add	Bh,Cl
	Add	Bh,Cl
	Mov     Di,Bx
	Mov	Dl,Es:[Di]
	Add	Ax,Dx
	Shr	Ax,1 
;        Rol     Ax,2         ;Uncomment this line if you want a lazer Fx
	Sub	Bh,Cl             
	Mov     Di,Bx
	Noise        
;:::::::::::::::::::::w(u+l,v+l/2)=[w(u+l,v)+w(u+l,v+l)]/2
	Xor	Ax,Ax
	Xor	Dx,Dx
        Sub     Bh,Cl
        Add     Bl,Cl       
        Add     Bl,Cl       
        Mov     Di,Bx       
        Mov     Al,Es:[Di]  
        Add     Bh,Cl       
        Add     Bh,Cl       
	Mov     Di,Bx       
	Mov	Dl,Es:[Di]  
	Add	Ax,Dx       
	Shr	Ax,1        
	Sub	Bh,Cl       
	Mov     Di,Bx       
	Noise               
;:::::::::::::::::::::w(u+l/2,v+l)=[w(u,v+l)+w(u+l,v+l)]/2
	Xor	Ax,Ax       
	Xor	Dx,Dx       
	Add	Bh,Cl       
	Mov     Di,Bx       
	Mov	Al,Es:[Di]  
	Sub	Bl,Cl       
        Sub     Bl,Cl       
	Mov     Di,Bx       
	Mov	Dl,Es:[Di]  
	Add	Ax,Dx       
	Shr	Ax,1        
	Add	Bl,Cl       
	Mov     Di,Bx       
	Noise               
;:::::::::::::::::::::w(u+l/2,v+l/2)=[w(u+l,v+l)+w(u+l,v)+w(u,v)+w(u,v+l)}/4
	Xor	Ax,Ax       
	Xor	Dx,Dx       
	Add	Bl,Cl       
    	Mov     Di,Bx       
        Mov     Al,Es:[Di]  
	Sub	Bh,Cl       
 	Sub	Bh,Cl       
	Mov     Di,Bx       
	Mov	Dl,Es:[Di]  
	Add	Ax,Dx       
	Sub	Bl,Cl       
        Sub     Bl,Cl       
	Mov     Di,Bx       
	Mov	Dl,Es:[Di]  
	Add	Ax,Dx       
	Add	Bh,Cl       
	Add	Bh,Cl       
	Mov     Di,Bx       
	Mov	Dl,Es:[Di]  
	Add	Ax,Dx       
	Shr	Ax,2        
	Add	Bl,Cl       
	Sub	Bh,Cl       
	Mov     Di,Bx       
        Noise2              
                            
	Sub	Bl,Cl       
	Sub	Bh,Cl       
	Push	Bx Cx       
	Call	Calcfractal 
	Pop	Cx Bx       
        Push    Bx Cx       
	Add	Bl,Cl       
	Call	Calcfractal 
	Pop	Cx Bx       
	Push	Bx Cx       
	Add	Bh,Cl       
	Call	Calcfractal 
	Pop	Cx Bx       
	Add	Bl,Cl       
	Add	Bh,Cl       
	Call	Calcfractal 
@@Endcalc:                  
 	Ret                 
Calcfractal             Endp

;-----------------------------------------------------------------------------
;  By G-Hell / PoPsY TeAm
;                   
;  Ok this .com can be shrinked more, I know, no need to mail me for that.
;  However, it seems to me that 1299 is a fun size for a 1999 production.
;-----------------------------------------------------------------------------





 
 
;----------------------------------------------------------------------------- 
;                                             --------------------------------
;PoPsY TeAm :    http://popsyteam.rtel.fr           --------------------------
;                popsyteam@rtel.fr    (only ASCII) --------------------------- 
;                                                   --------------------------
;GÄHell :        ghell@hotmail.com    (ASCII & Bin)  -------------------------                 
;                                                  ---------------------------
;----------------------------------------------------------------------------- 