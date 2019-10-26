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
;                       P R I N C I P A L   C O D E                          | 
;-----------------------------------------------------------------------------
.model tiny                                                            
.386                                                                   
.CODE                                                                  
org 100h                                                               
                                                                       
sy equ si ;Just for Fun ;o)                                            
                                                                       
START:                                                                 
;        cld           ;no need to init                              
;        finit         ;earns some bytes
        mov dx, offset ouais            
        mov ah,9                        
        int 21h  ; A small text while pre-calculating
                                                                       
        mov ax,cs                                                      
        add ah,10h                                                     
        mov an_seg,ax ;angles                                          
        add ah,10h                                                     
        mov te_seg,ax ;texture 256x256                                 
        add ah,10h                                                     
        mov vs_seg,ax ;screen buffer                                    
        add ah,10h                                                     
        mov pr_seg,ax ;depth                                      
                                                                       
                                                                       
                                                                       
                                                                       
;----------------------------------------------[ Precalcs ]---+        
        mov gs,ax                                             ;        
      	mov fs,an_seg                                         ;        
                                                              ;        
        fild  rayonXdi  ;radius * distance                    ;
        fstp  RD_factor                                       ;        
                                                              ;        
        fild  kool                                            ;        
        fldpi                                                 ;        
                                                              ;        
        fdivp st(1)                                           ;        
                                                              ;        
        mov di, -50 ;center x position                        ;
        xor ax, ax                                            ;        
        xor si, si                                            ;        
        mov dx, 200                                           ;
        mov Y,  di  ;center y position                        ;
@@lign:                                                       ;        
 	mov adder,di                                          ;        
        mov X,  di                                            ;        
        mov cx, 320                                           ;        
@@preuk:                                                      ;        
                                                              ;        
        fild   Y                                              ;        
        fild   adder                                          ;        
        fpatan                                                ;        
        fst    st(2)                                          ;        
        fmul   st,st(1)                                       ;        
        fistp  word ptr fs:[si]                               ;        
        fxch   st(1)                                          ;        
        fcos                                                  ;
                                                              ;        
         ;      Deforms the tunnel                            ;
         fsin                                                 ;        
         fsin      ;those 15 fsin                             ;
         fsin      ;get best ratio than a loop                ;
         fsin      ;when packing                              ;        
         fsin                                                 ;        
         fsin                                                 ;        
         fsin                                                 ;        
         fsin                                                 ;        
         fsin                                                 ;        
         fsin                                                 ;        
         fsin                                                 ;        
         fsin                                                 ;        
         fsin                                                 ;        
         fsin                                                 ;        
         fsin                                                 ;        
                                                              ;        
                                                              ;        
        f2xm1             ;deforms the edges of the tunnel    ;
        f2xm1             ;making it smoother                 ;        
                          ;and it earns some bytes            ; 
                                                              ;        
	fmul RD_factor                                        ;        
	fidiv adder                                           ;        
        fistp word ptr gs:[si]                                ;        
                                                              ;        
        add  X,  1                                            ;        
        inc  si                                               ;        
        mov  bx, X                                            ;        
	adc  bx, ax                                           ;        
 	mov  adder, bx                                        ;        
        loop @@preuk                                          ;        
                                                              ;        
        inc Y                                                 ;        
        dec dx                                                ;        
        jnz @@lign                                            ;        
;------------------------------------------[ Precalcs End ]---+
                                                                       
                                                                       
                                                                       
        call calcmap                                   
                                                                       
                                                                       
        mov al,13h                                                     
        int 10h                                                        
                                                                       
                                                                       
                                                                       
                                                                       
;-------------------------------------------[ PaL ]------+             
        mov dx, 3c8h                                     ;             
        xor ax, ax                                       ;             
        out dx, al                                       ;             
        inc dx                                           ;             
                                                         ;             
        mov cl, 128    ;cx = 0 after calcmap             ;
@@pa1:                                                   ;             
        mov al, ah                                       ;             
        shr al, 1                                        ;             
        out dx, al                                       ;             
        xor al, al                                       ;             
        out dx, al                                       ;             
        out dx, al                                       ;             
        inc ah                                           ;             
       	loop @@pa1                                       ;             
                                                         ;             
        mov cl, 128                                      ;
@@pa2:                                                   ;
        mov al, ah                                       ;
        shr al, 1                                        ;
        out dx, al                                       ;
        out dx, al                                       ;
        xor al, al                                       ;
        out dx, al                                       ;
        inc ah                                           ;
        loop @@pa2                                       ;
;-------------------------------------------[ PaL End ]--+
                                                                       
                                                                       
                                                                       
                                                                       
                                                                       
                                                                       
                                                                       
                                                                       
                                                                       
                                                                       
                                                                       
;---------------------------------------------------------------[ PRINCIPAL ]-
;---------------------------------------------------------------[ Begin ]-----
MAIN:                                                                  
   ;-------------------------[ Calculate the Tunnel ]--+
    push ds es                                         ;
                                                       ;               
    mov dh, pook2                                      ;               
    mov dl, pook1                                      ;               
                                                       ;               
    mov ax, vs_seg                                     ;               
    mov es, pr_seg                                     ;               
    mov fs, te_seg                                     ;               
    mov gs, ax                                         ;               
    mov ds, an_seg                                     ;               
                                                       ;               
    xor eax,eax                                        ;
    xor bx, bx                                         ;               
                                                       ;               
                                                       ;               
    mov cx, 64000                                      ;               
@@yok:                                                 ;               
    mov ah, es:[bx]                                    ;               
    mov al, [bx]                                       ;
    add ah, dh                                         ;
    add al, dl                                         ;
                                                       ;               
    mov al, fs:[eax]                                   ;
    mov gs:[bx],al                                     ;               
                                                       ;               
                                                       ;               
    inc bx                                             ;               
    dec cx                                             ;               
    jnz @@yok                                          ;               
                                                       ;               
    pop es ds                                          ;
                                                       ;               
    add pook2,-4 ;speed *2                             ;
    add pook1, 2 ;rotation *2                          ;
   ;---------------------------[ End of Calculation ]--+
                                                                       
                                                                       
                                                                       
                                                                       
   mov  al, nb_txt
   call writenb   ;Prints the text                                    
                                                                       
                                                                       
                                                                       
                                                                       
  ;---------------------------------------------------[ Show Screen ]-----+
  push ds                                                                 ;
                                                                          ; 
        mov   dx, 3DAh                                                    ;
@@vs1:                          ;Wait VBL                                 ; 
        in    al, dx                                                      ;
        test  al, 8                                                       ;
        jz    @@vs1                                                       ; 
@@vs2:                                                                    ; 
        in    al, dx                                                      ;
        test  al, 8                                                       ;
        jnz   @@vs2                                                       ; 
                                                                          ; 
  mov ax, 0a000h                                                          ;
  mov ds, vs_seg                                                          ;
  mov es, ax                                                              ; 
                                                                          ; 
  xor si, si                                                              ;
  xor di, di                                                              ;
                                                                          ; 
  mov cx, 16000                                                           ;
  rep movsd                                                               ; 
                                                                          ; 
  pop ds                                                                  ;
  ;---------------------------------------------------[ Show Screen End]--+
                                                                           
        add cmpt, 1       ;changes the text every 256 iterations
        jnz @@cbon                                                     
        inc nb_txt                                                     
        cmp nb_txt, 6                                                  
        jnz @@cbon                                                     
        ;jne @@cbon                                                    
        mov nb_txt, bh    ;bx = 0 after "Show Scrren" so,
                          ;we earn 1 byte to make nb_txt = 0
       @@cbon:                                  
                           
        in  al, 60h         
	cmp al, 1           
	jnz MAIN           
                           
;        sti                                                    not needed ;)
        xor eax, eax                                     ; clean exit however
 	int 16h                                              
                                                             
        mov ax, 03                                           
        int 10h                                              
        mov dx, offset txtfin                                       ; bye bye
        mov ah, 9                                            
        int 21h                                              
                                                             
RET  ; The End !                                             
                                                             
;-----------------------------------------------------------------------------
;-----------------------------------------------------------------------------
;-----------------------------------------------------------------------------
;-----------------------------------------------------------------------------
;-----------------------------------------------------------------------------
;-----------------------------------------------------------------------------
;-----------------------------------------------------------------------------
;-----------------------------------------------------------------------------
;-----------------------------------------------------------------------------
                                                             
include fractal.asm
                                           
                                           
                                           
                                           
                                           
;---------------------------------------------------------------[ Strings ]---
                                           
; in: al = Nb_Txt    Number of the text to be displayed               
proc    writenb near                                   
xor     ah, ah                                         
add     ax, ax    ;shl ax, 1                           
mov     bx, offset table_t                             
add     bx, ax                                         
                                                       
mov     al, nb_txt                                     
and     al, 00000001b                                  
jnz     @@impair                                       
mov     blty, 40d                                      
mov     bltx, 144d                                     
jmp     @@pair ;Ends with 90h, what explains the following line :
nop            ;creates a 90h 90h string which compacts well
@@impair:                                  
mov     blty, 100d                         
mov     bltx, 78d                          
@@pair:                                    
mov     si, [bx]                           
;-----------------------------[ ds:si = string ]------+
push    si                                            ; 
push    bltx                                          ; 
@@loop:                                               ; 
mov     al, ds: byte ptr [si]                         ; 
cmp     al, 36d                                       ; 
je      @@end                                         ; 
cmp     al, 0ah                                       ; 
jne     @@passaut                                     ; 
add     blty, 08d                                     ;
inc     si                                            ; 
pop     bltx                                          ;
push    bltx                                          ;
jmp     @@loop                                        ; 
@@passaut:                                            ; 
inc     si                                            ;
;----------------------------[ Show Char ]--------+   ;
; in: al = char (0-127)                           ;   ; 
push    si                                        ;   ; 
xor     bx, bx                                    ;   ;
mov     si, bx                                    ;   ; 
mov     bl, al                                    ;   ; 
shl     bx, 03d                                   ;   ;
add     bx, 0FA6Eh                                ;   ;
mov     ax, 0F000h                                ;   ; 
mov     ch, 08d                                   ;   ;   
mov     es, ax                                    ;   ;   
@@y:                                              ;   ; 
mov     cl, 08d                                   ;   ;
mov     al, es: byte ptr [bx]                     ;   ; 
@@x:                                              ;   ; 
mov     ah, 0FFh                                  ;   ; 
shl     al, 1                                     ;   ;
jc      @@empty                                   ;   ; 
not     ah                                        ;   ;
@@empty:                                          ;   ; 
mov     ds: byte ptr [offset charspr + si], ah    ;   ; 
inc     si                                        ;   ;
dec     cl                                        ;   ; 
jnz     @@x                                       ;   ; 
inc     bx                                        ;   ;
dec     ch                                        ;   ;
jnz     @@y                                       ;   ; 
PoP     sY                                        ;   ; 
call    affchar                                   ;   ; 
;------------------[ Back to the Line Proc ]------+   ;
add     bltx, 08d                                     ;
;jmp @@loop                                           ; 
jnz     @@loop                                        ;
@@end:                                                ; 
PoP     sY ;Clears bltx                               ; 
PoP     sY ;Gets si back                              ;
;-----------------------------------------------------+
                                                       
ret                                                    
writenb endp                                           
                                                       



                                                       
;We put the char in our buffer (no, it doesn't hurt :)
proc affchar near
push    si  
xor     bx, bx
mov     dx, 0320d
mov     ax, blty              
mul     dx
add     ax, bltx                   
mov     dx, 08d
mov     si, ax                     
mov     ax, vs_seg                 
mov     es, ax                     
@@y2:                              
mov     cl, 08d                    
@@x2:                              
mov     al, ds: byte ptr [offset charspr + bx]
or      al, al                              
jz      @@trans
cmp     cmpt, 30                                  
jl      @@calcpar        ;Let's make some noise on the text
xor     ax, ax                                             
jmp     @@normal                                           
@@calcpar:                                                                
 mov     al, es: byte ptr [si]                             
 xor     ax, si          ;Creats the noise     
@@normal:                                 
and     al, 00000001b                     
jnz     @@trans          ;Noisy now !
not     es: byte ptr [si]          
mov     es: byte ptr [si+321],0    
@@trans:                           
inc     si                 
inc     bx                 
dec     cx                 
jnz     @@x2               
add     si, 0320d - 08d    
dec     dx                         
jnz     @@y2                       
PoP     sY                         
                                   
ret                                
endp affchar
                                   
                                   
                                   
                                   
;-----------------------------------------------------------------------------
;-----------------------------------------------------------------------------
;-----------------------------------------------------------------------------
;-----------------------------------------------------------------------------
;-----------------------------------------------------------------------------
;-----------------------------------------------------------------------------
;-----------------------------------------------------------------------------
;-----------------------------------------------------------------------------
;-----------------------------------------------------------------------------
;                               V A R S :                                     
;-----------------------------------------------------------------------------
;W A R N I N G :
;
;Each variable have been placed carrefully in order to get best packing ratio
;Moving some of them can make bugs appear after packing...
;-----------------------------------------------------------------------------
                                                                              
table_t         dw      txt0                                                  
                dw      txt1                                                  
                dw      txt2                     
                dw      txt3                     
                dw      txt4                     
                dw      txt5                     
nb_txt          db      0  ; Number of text to display
                           ; (do not move this one !)
                                                 
txtfin          db      'PoPsY TeAm   ',1ah
                db      '  http://popsyteam.rtel.fr',0dh,0ah
                db      '                popsyteam@rtel.fr',0Dh,0ah,'$'
txt1            db      '  .-=PoPsY TeAm=-.',0ah            
                db      '     ~~~~~~~~~~',0ah               
                db      '     is part of',0ah               
                db      '    ARF! studios',0ah,0ah          
                db      ' arfstudios.cjb.net$'              
txt0            db      '  .-=PoPsY TeAm=-.',0ah            
                db      '     ~~~~~~~~~~',0ah               
                db      'Invites You to visit',0ah          
                db      'us at:',0ah,0ah                    
                db      ' popsyteam.rtel.fr$'               
txt2            db      ' You can fInd us on',0ah,0ah       
                db      1ah,'IRCnet:',0ah                   
                db      '      #demofr #arfstd',0ah,0ah     
                db      1ah,'RTEL:',0ah                     
                db      '      chat.rtel.fr$'
txt4            db      'Here come some quick',0ah
                db      'Greets :',0ah,0ah        
                db      '     #demofr #arfstd',0ah
                db      ' everyone on RTEL,',0ah
                db      ' Any cool scener',0ah
                db      ' And special Greets ',0ah
                db      ' to BomB !$' ; (We are Explosed too :)
txt3            db      'Here are some other',0ah
                db      'cool sites:',0ah,0ah          
                db      1ah,'www.error-404.com',0ah,0ah             
                db      1ah,'ojuice.citeweb.net',0ah,0ah            
                db      1ah,'deco.citeweb.net',0ah,0ah              
                db      1ah,'defcon.citeweb.net$'                   
ouais           db      'Another strike by GÄHell /PoPsY TeAm   $'
                        ;The spaces at the end, earn 1 byte after packing
                        ;do not remove them
txt5            db      '        ,,,',0ah                           
                db      '       (o o)',0ah       
                db      ' ---oOO-(_)-OOo---',0ah 
                db      'PoPsY TeAm (c) 1999$'
                                                 
charspr         db      08d * 08d dup (?)  
                                           
an_seg          dw      0  ; Angles
pr_seg          dw      0  ; Depths                
te_seg          dw      0  ; Texture                
vs_seg          dw      0  ; Screen                
                                           
pook1           db      0          
pook2           db      0          
cmpt            db      0  ; Timer for the text
bltx            dw      0  ; Text x coordinate
blty            dw      0  ; Text y coordinate
                                              
;---------------- For Precalcs -----
X               dw      0          
Y               dw      0          
adder           dw      0          
RD_factor       dd      0           
kool            dw      128d        
                                    
rayonXdi        dw      5000  ; (Radius x Distance = 100*50 = 5000)
                                                      
Randomseed      dd      9090h ; (90h 90h, reminds me of someting ;o)
                                   
END START                          
                                   


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
