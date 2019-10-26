_w_          equ word ptr
_d_          equ dword ptr
_b_          equ byte ptr                   
rot_gelb     =   8036
blau_rot     =   8500
waits        =   10                        
p_out        =   65535     
beatc        =   14
textc        =   5       
termc        =   6       
radius       =   100
                          
schrittweite = 32                                      
breite       = 32                ;constants for man-control                               
kbreite      = 20                                              
                                                

              
ideal       
model tiny  
p486        
            
codeseg     
startupcode 
start: jmp strt
                                           
 kp1x   dw 0 ;init all the "unitialised" variables with the same value
 kp1y   dw 0 ;for better compression                                                         
 kp2x   dw 0                        
 kp2y   dw 0                        
 bc     db 0 ;variables used for bsim                       
 tc     db 0                         
 beat   db 0                        
 term   db 0                        
 nt     db 0                        
 p1x    dw 0 ;vars to store the coordinates of the pentagram's corners
 p1y    dw 0                                                          
 p2x    dw 0
 p2y    dw 0                        
 p3x    dw 0                        
 p3y    dw 0                        
 p4x    dw 0
 p4y    dw 0                        
 p5x    dw 0                        
 p5y    dw 0
 te     db 0                                         
 an     db 0 ;variable to control vga_aus, if =0: screen off
             ;                             if<>0: screen on
 text   db 0                                         
i1c_ofs dw 0 ;for the original Interrupt 1c handler  
i1c_seg dw 0                                         
                                                     
kreis_z dw 0 ;used by the circle drawing routine     
speichers  dw 0 ;the buffers for font, fire, etc.
speichers2 dw 0                                                 
speichers3 dw 0                                                 
speichers4 dw 0                                                 
speichere  dw 0 ;and the end of the reserved memory area                                                
                                                        
                                                        
csb     db 3,c,s,b                                      
shows   db 5,s,h,o,w,s                                  
leer    db 1,0                                          
chaos   db 5,c,h,a,o,s                                  
we      db 2,w,e                                        
still   db 5,s,t,i,l,l                                  
need    db 4,n,e,e,d                                    
_a_     db 1,a                                          
gfx     db 3,g,f,x                                      
man     db 3,m,a,n                                      
                                                        
kreis_x dd 160                                          
kreis_y dd 100                                          
   _col db 4                                            
                                                        
armhîhe dw 30           ;and here the variables for man-movement
kopf_x  dd 280                                                  
kopf_y  dd 61                                                   
bein1_x dw 264                                                  
bein1_y dw 167                                                  
bein2_x dw 296                                                  
bein2_y dw 167                                                  
richtung dw -4                                                  
mman    db 2                                               
                                                                
endlogo db 2                                                    
                                                                
                                                                
include "shadebob.inc"                                             
include "dig.inc"                                               
                                                        
proc random         ;random number generator                    
  mov ax,fs                                                     
  mov bx,13                                             
  mul bx                                                
  xchg ah,al                                            
  mov fs,ax                                             
  ret                                                   
endp                                                    
                                                        
macro bshow         ;if a 'beat' is given move the bobs 
  local raus                                            
  test [cs:beat],255                                    
  jz raus                                               
  call moveline                                         
  mov [cs:beat],0                                       
  raus:                                                 
endm                                                    
                                                        
                                                                
macro speicherseg   ;moves valid(I hope it) segment adresses for the buffers
  mov ax,cs         ;get the codeseg                                                        
  add ax,4096       ;add 65535 bytes                                            
  mov [cs:speichers],ax  ;and store it                                        
  add ax,4096       ;add again 65535 bytes                                            
  mov [cs:speichers2],ax ;store it to the next buffer pointer
  add ax,4096                                                   
  mov [cs:speichers3],ax                                        
  add ax,4096                                                   
  mov [cs:speichers4],ax                                        
  mov bx,[cs:2]     ;read last reserved segment from PSP
  mov [cs:speichere],bx ;and store it as the last reserved segment
endm                                                              
proc waitretrace    ;wait for a vertical retrace                  
  push dx                                                         
  push ax                                                         
  mov dx,03dah                                          
 @@l2:                                                  
  in al,dx                                              
  test al,8                                             
  je @@l2                                               
 @@l1:                                                  
  in al,dx                                              
  test al,8                                             
  jne @@l1                                              
  pop ax                                                
  pop dx                                                
  ret                                                   
endp                                                    
proc vga_aus      ; turn the screen on/off, depends on "an"                                              
  push dx                                                  
  push ax                                               
  mov dx,3c4h                                           
  mov al,1                                              
  out dx,al                                             
  inc dx                                                
  in al,dx                                              
  cmp [cs:an],1                                         
  jne vaus                                              
  and al,0dfh                               
  jmp van                                   
                                            
  vaus:                                     
  or al,020h                                
                                            
  van:                                      
  mov ah,al                                 
  mov al,1                                  
  mov dx,3c4h                               
  out dx,al                                 
  mov al,ah                                 
  inc dx                                    
  out dx,al                                 
  pop ax                                    
  pop dx                                    
  ret                                       
endp                                        
                                            
proc loe_neu    ;undisplays a text and displays a new one
  mov ax,[cs:speichers2]                                 
  xchg [cs:speichers],ax                                 
  xchg [cs:speichers2],ax                                
  call prep_string                                       
  mov  [cs:show],0                                       
  call write_string                                      
  mov [cs:show],1                                        
  call write_string                                      
  ret                                                    
endp                                                     
                                                         
macro tshow ausgabe,position  ;shows the string 'ausgabe' at offset 'position'
  mov si,offset ausgabe                                  
  mov di,position                           
  call loe_neu                              
endm                                        
                                            
macro ts               ;if the beatsimulator says write a new text/empty the page
  test [cs:nt],255                          
  jz tende                                              
    pusha                                   
    push ds                                 
    push es                                 
    inc [cs:text]                           
    cmp [cs:text],2                         
    je leerseite                            
    ja weiter_vergl                         
    tshow csb,21824                         
    jmp tsende                              
    weiter_vergl:cmp [cs:text],4            
    jb leerseite                            
    ja leerseite                            
    tshow shows,21760                       
    jmp tsende                              
    leerseite:                              
    tshow leer,0                            
    tsende:                                 
    pop es                                  
    pop ds                                  
    popa                                                
    mov [cs:nt],0                           
  tende:                                    
endm                                        
                                            
macro bobfx            ;and here the whole shitbob effect
  pushad                                                 
  mov ax,0a000h                             
  mov es,ax                                 
  mov fs,ax            ;init the random number generator
  mov ax,13h                                            
  int 10h              ;and switch to gfxmode
  setup_palette        ;setup the non-linear palette
                                                     
  call vga_aus         ;switch off the screen
                                             
  initbob              ;setup all the variables (stored in the registers)  
  online:                                   
  call show_move       ;show the startup screen
  dec cx                                       
  jne online                                            
                                            
  mov [cs:an],1                             
  call vga_aus         ;and switch the screen on                
  mov [cs:beat],0      ;reset the beatsimulator                         
  mov [cs:bc],beatc                            
  mov [cs:tc],textc                           
  mov [cs:text],0                             
  mov [cs:term],termc                         
  mov [cs:nt],0                             
                                            
  effekt:              ;and here's the main loop
  bshow                ;move the bobs whe a beat occurs                         
  ts                   ;and show the text at the right time                                
  test [cs:term],255   ;termination ?                                    
  jz bfxende           ;yes: exit                                    
  jmp effekt           ;no : here we go again
                                            
  bfxende: pushad      ;save the bob's status
  mov cx,16000         ;clear the screen                      
  xor eax,eax                                           
  xor di,di                                 
  rep stosd                                 
  popad               ;restore the bob's status      
  call moveline       ;move 'em twice                         
  call moveline                             
  mov cx,68           ;and move the 'chaos'       
  xor di,di           ;from top to bottom                      
  mov si,offset chaos                       
  mov [cs:show],0                           
                                            
  chaos_loop:                               
  pusha                                     
  call prep_string    ;yes, rather unefficient stuff...                   
  call write_string                                    
  popa                                                 
  add di,640                                           
  call waitretrace    ;slow down the movement
  dec cx                                               
  jnz chaos_loop                                       
  mov [cs:beat],0     ;reset the beatsimulator                                 
  bwloop:                                              
  test [cs:beat],255                                   
  jz bwloop           ;wait for it                                 
  mov di,21120        ;make a black bar in the middle of the screen           
  xor eax,eax                                                      
  mov cx,5280                                                      
  rep stosd                                                        
  mov di,21760        ;and show a 'chaos' there                                             
  call prep_string                                                 
  call write_string                                                
  mov [cs:tc],1                                                    
  mov [cs:nt],0                                                    
  _bwloop:            ;wait for the bsim    
  test [cs:nt],255                                                 
  jz _bwloop                                
  mov ax,0101bh       ;and perform          
  mov bx,0            ;a greyscale using the videointerrupt
  mov cx,255          ;(why writing an own one ????)                                     
  int 10h                                           
  mov [cs:nt],0       ;setup the bsim                   
  mov [cs:tc],5                             
  twloop:                                   
  test [cs:nt],255                          
  jz twloop           ;wait                 
  mov cx,p_out                              
  pixoutloop:         ;and pixel the screen out 
    call random                                
    mov di,ax                               
    mov al,0                                
    mov [es:di],al                          
    dec cx                                  
    jnz pixoutloop                          
  xor al,al                                 
  mov dx,03c8h                              
  out dx,al                                 
  inc dx                                    
  mov cx,765                                
  black_loop:        ;and set all colors to black  
  out dx,al                                      
  dec cx                                                
  jnz black_loop                            
  popad                                     
endm                                        
proc int1croutine far  ;and here is it: the "BEATSIMULATOR"
  dec [cs:bc]          ;first an adlib-player should take this place                                    
  jnz ende             ;but I ran out of time
    mov [cs:bc],beatc  ;this solution was the easyest one: small and fast to code                                    
    mov [cs:beat],1                                        
    dec [cs:tc]                             
    jnz tnde                                
      mov [cs:nt],1                         
      mov [cs:tc],textc                     
      dec [cs:term]                         
    tnde:                                   
  ende:                                     
  iret                                      
endp                                        
                                                                                                        
macro cleardig                ;clear the fontbuffer                             
  call pufferclear                                         
  mov ax,[cs:speichers2]                                   
  xchg [cs:speichers],ax                                   
  xchg [cs:speichers2],ax                                  
  call pufferclear                                         
endm                                        
                                            
macro i_1c                    ;install the bsim
  cli                         ;I chose INT 1c instead of INT 8
  mov ax,351Ch                ;because I don't expect anything important
  int 21h                     ;to call there -> more speed, no probs...
  mov [cs:i1c_ofs],bx                                                  
  mov [cs:i1c_seg],es                                                  
  push ds                                                              
  mov ax,cs                                                            
  mov ds,ax                                                            
  mov dx,offset int1croutine                                           
  mov ax,251ch                                                         
  int 21h                                                              
  pop ds                                                               
  sti                                                                  
endm                                                                   
macro u_1c                    ;and uninstall the damned thing                                           
  mov ds,[cs:i1c_seg]                                       
  mov dx,[cs:i1c_ofs]                        
  mov ax,251ch                               
  int 21h                                    
endm                                        
                                            
                                            
macro putpixel                              
  pusha                                     
  shl bx,6                                  
  mov di,bx                                      
  shl bx,2                                       
  add di,bx                                      
  add di,ax                                      
  mov bl,[cs:_col]                               
  mov [es:di],bl                                 
  popa                                           
endm                                                    
                                                 
; This Bresenham is taken out of "PC Underground", but a little is changed for 
; speed issues (I know, self-modyfying code isn't that fast on 486 or pentium,
; but this was the routine I had and writing a new one would have been stupid
                                            
proc bline near                                  
;zieht Linie von ax/bx nach cx/dx                
  push bp                                        
  push ax                       ;x0 und          
  push bx                       ;y0 sichern      
  mov bx,4340h                  ;Selbstmodifikation vorbereiten
  sub cx,ax                     ;deltax berechnen
  jns deltax_ok                 ;negativ ?       
  neg cx                        ;ja, dann deltax Vorzeichen umkehren
  mov bl,48h                    ;und dec ax statt inc ax
deltax_ok:                                       
  mov bp,sp                     ;Addressierung von y1 auf dem Stack
  sub dx,[ss:bp]                ;deltay berechnen
  jns deltay_ok                 ;negativ ?       
  neg dx                        ;ja, dann deltay Vorzeichen umkehren
  mov bh,4bh                    ;und dec bx statt inc bx
deltay_ok:                                       
  mov si,dx                     ;deltay und 
  or si,cx                      ;deltax = 0 ?
  jne ok                                    
  add sp,6                      ;dann ax, bx und bp vom Stack und Ende
  ret                                       
ok:                                         
  mov [word ptr cs:dist_pos],bx ;dec/inc ax/bx an Ziel schreiben
  cmp cx,dx                     ;deltax >= deltay ?
  jge deltax_gross                          
  xchg cx,dx                    ;nein, dann deltax und deltay tauschen
  mov bl,90h                    ;und inc ax noppen
  jmp konstanten                            
deltax_gross:                               
  mov bh,90h                    ;sonst inc bx noppen
konstanten:                                 
  mov [word ptr cs:dist_neg],bx ;dec/inc ax/bx an Ziel schreiben
  shl dx,1                      ;Add_2 bestimmen
  mov di,dx                     ;in di sichern          
  sub dx,cx                     ;Start-Dist bestimmen
  mov bp,dx                     ;und in bp sichern
  mov si,bp                     ;Add_1 bestimmen
  sub si,cx                     ;und in si sichern
  pop bx                        ;gesicherte Werte fÅr x0 und y0 zurÅckholen
  pop ax                                    
loop_p:                                     
  putpixel                      ;Punkt setzen
  or bp,bp                      ;Dist positiv ?
  jns dist_pos                              
dist_neg:                                   
  inc ax                        ;x weiter (evtl Selbstmodifikation)
  inc bx                        ;y weiter (evtl Selbstmodifikation)
  add bp,di                     ;Dist aktualisieren
  loop loop_p                   ;nÑchsten Punkt
  jmp fertig                    ;danach fertig
dist_pos:                                   
  inc ax                        ;x weiter (evtl Selbstmodifikation)
  inc bx                        ;y weiter (evtl Selbstmodifikation)
  add bp,si                     ;Dist aktualisieren     
  loop loop_p                   ;nÑchsten Punkt
fertig:                                     
  pop bp                                    
  ret                                       
endp                                        
                                            
;little macro for "easyer" calling of bline 
 macro line x1,y1,x2,y2                     
   mov ax,[x1]                              
   mov bx,[y1]                              
   mov cx,[x2]                              
   mov dx,[y2]                              
   call bline                               
 endm                                       
                                            
; Yes, I know, fast code requires ANDable degree-steps...
; and using a 360-Sintab is also very stupid 'cause u can calculate 90-360
; by using symetrics of the sin-function... 
; I use 23:9 bit fixed point maths...       
proc sin                                                
  push bx                                   
  cmp ax,360                                
  jne sin_weiter                            
  xor ax,ax                                 
  sin_weiter:                               
  shl ax,1                                  
  add ax,offset sintab                      
  mov si,ax                                 
  mov ax,[cs:si]  ;move the integer from the tab into ax                         
  cwde            ;and expand it into a longint in eax                                      
  pop bx                                                
  ret                                                   
endp                                                    
proc cos                                    
  add ax,90    ;U didn't sleep in maths ?!  
  cmp ax,360                                
  jb sin                                    
  sub ax,360                                
  jmp sin                                   
endp                                                    
;excuse my german procedure names, but I don't want to change that now... 
proc kreis_punkt ;calculates the point on the circle at (kreis_x;kreis_y)
  push edx       ;with radius=ebx at cx degrees
  mov ax,cx                                                              
  call sin                                                               
  imul ebx                                                               
  mov edx,7                                                              
  imul edx                                                               
  sar eax,12                                                             
  add eax,[cs:kreis_y]                                                   
  mov bp,ax                                                              
                                                                         
  mov ax,cx                                 
  call cos                                  
  imul ebx                                  
  sar eax,9                                 
  add eax,[cs:kreis_x]                      
  pop edx                                   
  ret                                       
endp                                                    
macro kreis_pix    ; sets a pixel at (ax;bp) with color _col
    shl bp,6       ; es is expected to point to the videoseg or a frame                                         
    mov di,bp      ; puffer                                                    
    shl bp,2                                
    add di,bp                               
    add di,ax                               
    mov al,[_col]                                            
    mov [es:di],al                                           
endm                                                         
proc kreis                 ;draws a circle                   
  mov [kreis_z],361        ;U can flame me for that unoptimized code, but this
  xor eax,eax              ;is my second thing I wrote in asm            
  kreis_loop:                                                
    mov cx,[kreis_z]                        
    dec cx                                                   
    call kreis_punkt       ;calculate                                  
    mov [kp1x],ax                                            
    mov [kp1y],bp          ;two                                  
    dec cx                                                   
    jz kende               ;points                                  
    call kreis_punkt                                         
    push bx                ;and                                  
    mov bx,bp                                                
    mov cx,[kp1x]          ;connect them                                  
    mov dx,[kp1y]                                            
    call bline             ;with a line (otherwise it would look a bit silly)                                  
    pop bx                                                                   
    dec [kreis_z]                           
    jnz kreis_loop                                           
  kende:                                                     
  ret                                                        
endp                                                         
                                                             
proc drawpent              ;draws a pentagram with radius "radius"                       
  mov ebx,radius           ;at (kreis_x;kreis_y)
                                                  
  mov cx,270                                    
  call kreis_punkt         ;calculate                     
  mov [p1x],ax                                  
  mov [p1y],bp                                          
  mov cx,342                                    
  call kreis_punkt         ;the             
  mov [p2x],ax                                  
  mov [p2y],bp                                  
  mov cx,54                                     
  call kreis_punkt         ;five                     
  mov [p3x],ax                              
  mov [p3y],bp                              
  mov cx,126                                
  call kreis_punkt         ;corners         
  mov [p4x],ax                              
  mov [p4y],bp                              
  mov cx,198                                
  call kreis_punkt         ;...             
  mov [p5x],ax                              
  mov [p5y],bp                              
                                            
  line p1x,p1y,p3x,p3y     ;and             
  line p1x,p1y,p4x,p4y     ;connect them            
  line p2x,p2y,p4x,p4y     ;in the                      
  line p2x,p2y,p5x,p5y     ;right           
  line p3x,p3y,p5x,p5y     ;order           
  ret                                       
endp                                        
proc copy2vseg             ;copys the segment at es into the videoram      
  push es                                                            
  push ax                                   
  push ds                                   
  mov ax,es                                 
  mov ds,ax                                 
  mov ax,0a000h                             
  mov es,ax                                 
  mov cx,16000                              
  xor di,di                                 
  mov si,di                                 
  rep movsd                                 
  pop ds                                    
  pop ax                                    
  pop es                                    
  ret                                                   
endp                                        
                                            
proc bufrndcopy         ;an important piece of my fire routine...             
  mov si,64000                                                   
  rnd_loop:                                 
    mov al,[gs:si]      ;"scans" the segment at gs             
    test al,255                                 
    jz kein_rnd         ;and if a byte is unequal to 0
    call random         ;write a random byte                              
    or al,128           ;bigger than 128                    
    mov [es:si],al      ;to the same position, but in _es_                
    kein_rnd:                                             
    dec si                                                
    jnz rnd_loop                            
  ret                                       
endp                                        
macro make_av         ;builds the average of the pixels directly
  mov di,cx                                                     
  xor bx,bx                                                     
  mov bl,[es:di+320]  ;below,                                          
  mov ax,bx                                                     
  mov bl,[es:di-320]  ;above,
  add ax,bx                                                     
  mov bl,[es:di-1]    ;left                                          
  add ax,bx                                                     
  mov bl,[es:di+1]    ;and right of cx      
  add ax,bx                                 
  shr ax,2                                  
  mov [es:di+1],al    ;and writes it in the pixel right of cx, this causes
endm                  ;the "storm"          
                                            
macro penttext                              
  test [cs:nt],255    ;cs:nt is changed by my "beatsimulator" installed in
  jz t_ende           ;the timer interrupt                                                    
    pusha                                   
    push ds                                 
    push es                                 
    inc [cs:text]     ;check if a new text should be displayed
    cmp [cs:text],2                                           
    je leer_seite                                       
    ja weitervergl                          
    call pufferclear                                         
    mov si,offset we                                         
    mov di,11616                                             
    call pr_string    ;calculate the string in the fontpuffer
    mov si,offset still                                       
    mov di,32002                                             
    call pr_string                                           
    mov [cs:show],0                                          
    call write_string ;and add it a few times to the "burning-out" buffer
    call write_string                                        
    call write_string                                        
    call write_string                                        
    call write_string                                        
    call write_string                                        
    call write_string                                        
    jmp ts_ende                                              
    weitervergl:cmp [cs:text],4                              
    ja leer_seite                                            
    je gfxman                                                
                                                             
    call pufferclear                                         
    mov si,offset need                                       
    mov di,11552                                             
    call pr_string                                           
    mov si,offset _a_                                        
    mov di,32128                                             
    call pr_string                                           
    mov [cs:show],0                                          
    call write_string                                        
    call write_string                                        
    call write_string                                        
    call write_string                                        
    call write_string                                        
    call write_string                                        
    call write_string                                        
                                                             
    jmp ts_ende                                              
    gfxman:                                                  
    call pufferclear                                         
    mov si,offset gfx                                        
    mov di,11584                                             
    call pr_string                                           
    mov si,offset man                                        
    mov di,32064                                      
    call pr_string                                    
    mov [cs:show],0                                   
    call write_string                                 
    call write_string                                 
    call write_string                                 
    call write_string                                 
    call write_string                                 
    call write_string                                 
    call write_string                                 
                                                      
    leer_seite:                                       
    ts_ende:                                          
    pop es                                            
    pop ds                                            
    popa                                                
    mov [cs:nt],0                                     
  t_ende:                                             
endm                                                  
                                                      
proc pentfx      ;guess what this is ?... right, it's the burning pentagram
  mov ax,[cs:speichers4] ; one of the fire puffers (the material-buffer)
  xor edx,edx                                                           
  mov ebx,radius                                                        
  mov es,ax              ; into es                                      
  mov ax,[cs:speichers3] ; and the other (the burning-out-buffer)
  mov gs,ax              ; into gs                                      
  call kreis             ; draw the pentagram into the material buffer                                              
  call drawpent                             
  mov ax,es              ; exchange the segment registers                             
  mov gs,ax                                              
  mov ax,[cs:speichers3]                              
  mov es,ax                                            
  mov si,13              ; initialize the random number generator
  mov fs,si              ; by writing a value <>0 into the oldrnd-storage fs                                        
  push es                                                                   
  call pufferclear       ; clear the burning-out-puffer              
  pop es                                               
  mov [cs:beat],0        ; reset the variables                             
  mov [cs:bc],beatc      ; changed by the                             
  mov [cs:tc],textc      ; beatsimulator                       
  mov [cs:text],0        ; and init them                       
  mov [cs:term],termc    ; for regulating text, termination, etc.               
  mov [cs:nt],0          ; reset the new_text variable used by penttext                                        
  flacker_loop:                                                        
   call bufrndcopy       ; draw random-numbers at the pent's posion into the                                      
   mov dx,62720          ; burning-out-buffer                                                   
   fl_xloop:mov cx,318   ; for a cind of clipping only 318 columnes
     flame_loop:                                                   
       push cx                                                 
       add cx,dx                                               
       make_av           ; calculate the firestorm                                      
       pop cx                                   
       dec cx                                                  
       jnz flame_loop                                          
     sub dx,320                                                
     jnz fl_xloop                                              
     call copy2vseg                                            
     pusha                                                     
     push es                                                   
     mov ax,es                                                 
     mov [cs:screenseg],ax                                             
     penttext            ;print the text(if the beatsimulater says it)
     pop es                                                            
     popa                                                      
   test [cs:term],255                                          
   jnz flacker_loop                         
  ret                                       
endp                                        
                                            
proc bli                 ;another one for calling bline                
  pusha                  ;but without modifying any regs                              
  call bline                                            
  popa                                                  
  ret                                                   
endp                                                    

macro moveman    ; guess what...                
  pushad                                        
  xor eax,eax                                   
  sub [cs:kopf_x],1                             
  cmp [cs:kopf_x],34 ;check if the man is at the edge of the screen           
  sete [cs:te]                                                     
  setb [cs:te]                                            
  mov ax,[cs:bein1_x]                                     
  cmp [cs:kopf_x],eax                                     
  jne nicht_bewegen2                                      
  sub [cs:bein2_x],schrittweite  ;make him walking        
  sets [cs:te]                   ;and check again if he's at the edge
  nicht_bewegen1:                                                    
  mov ax,[cs:bein2_x]                          
  cmp [cs:kopf_x],eax                          
  jne nicht_bewegen2                           
  sub [cs:bein1_x],schrittweite                
  sets [cs:te]                                 
  nicht_bewegen2:                                       
  mov ax,[cs:richtung]           ;move the arms           
  add [cs:armhîhe],ax                   
  jnz arme_nicht_0                      
  neg [cs:richtung]                     
  arme_nicht_0:                         
  cmp [cs:armhîhe],30                   
  jb arme_nicht_30                      
  neg [cs:richtung]                     
  arme_nicht_30:                        
  popad                                 
endm                                    
                                        
                                 
proc mann                        
  pushad                         
  push ds                        
  push es                        
  xor di,di                      
  mov cx,16000                   
  xor eax,eax                                           
  rep stosd                      
  mov ebx,kbreite                
  mov eax,[cs:kopf_y]            
  mov [cs:kreis_y],eax           
  mov eax,[cs:kopf_x]            
  mov [cs:kreis_x],eax           
  call kreis                   ;draws the little guy  
  mov cx,90                                         
  call kreis_punkt                                  
  mov dx,bp                                         
  add dx,43                                         
  mov ecx,[cs:kreis_x]                              
  mov ax,cx                                         
  mov bx,bp                                         
  call bli                                          
  add eax,breite                                    
  add bx,[cs:armhîhe]                               
  call bli                                          
  sub ax,(breite*2)                                 
  call bli                                              
  mov bx,[cs:bein1_y]                               
  mov ax,[cs:bein1_x]                               
  dec dx                                            
  call bli                                          
  mov ax,[cs:bein2_x]                               
  mov bx,[cs:bein2_y]                               
  call bli                                          
  pop es                                            
  pop ds                                            
  popad                                             
  ret                                               
endp                                                
proc man_fx               ; complete effect for the burning man
  mov ax,[cs:speichers4]  ; u should understand it when looking at pentfx
  xor edx,edx                                                            
  mov es,ax                                                              
  mov ax,[cs:speichers3]                                                 
  mov gs,ax                                                              
  call mann                                                              
  mov ax,es                                                              
  mov gs,ax                                                              
  mov ax,[cs:speichers3]                                                 
  mov es,ax                                                              
  mov si,13                                                              
  mov fs,si                                                              
  mov bp,200                                                             
  mflacker_loop:                                                         
   call bufrndcopy                                                       
   mov dx,62720                                                          
   mfl_xloop:mov cx,318                                                  
     mflame_loop:                                                        
       push cx                                                           
       add cx,dx                                                         
       make_av                                                           
       pop cx                                                            
       dec cx                                                            
       jnz mflame_loop                                                   
     sub dx,320                                                          
     jnz mfl_xloop                                                       
   call copy2vseg                                                        
   dec [cs:mman]                                                         
   jnz nicht_bewegen                                                     
   mov [cs:mman],2                                                       
   pushad                                                                
   push es                                                               
   mov ax,[cs:speichers4]                                                
   xor edx,edx                                                           
   mov es,ax                                                             
   moveman                                                               
   call mann                                                             
   pop es                                                                
   popad                                                                 
   nicht_bewegen:                                                        
   test [cs:te],255                                                      
   jz mflacker_loop                                                      
  ret                                                                    
endp                                                                     
                                                                         
macro setpentpal   ;sets the palette for the fire-effects
  mov cl,63                                                              
  w_g_loop:                                                              
    mov dx,03c8h                                                         
    mov al,cl                                                            
    add al,192                                                           
    out dx,al                                                            
    inc dx                                                               
    mov al,63                                                            
    out dx,al                                                            
    out dx,al                                                            
    mov al,cl                                                            
    out dx,al                                                            
    dec cl                                                               
    jnz w_g_loop                                                         
                               
  mov dx,03c8h     ;well...            
  mov al,192                   
  out dx,al        ;a little correxion            
  mov al,63                           
  inc dx           ;against                             
  out dx,al                
  out dx,al        ;black holes
  xor al,al                    
  out dx,al        ;in the palette     
  mov dx,03c8h                    
  mov al,191                      
  out dx,al                       
  mov al,63                       
  inc dx                          
  out dx,al                       
  out dx,al                       
  xor al,al                       
  out dx,al                       
  mov cl,63                       
  g_r_loop:                       
    mov dx,03c8h                  
    mov al,cl                     
    add al,127                    
    out dx,al                     
    inc dx                                              
    mov al,63                     
    out dx,al                     
    mov al,cl                     
    out dx,al                     
    mov al,0                      
    out dx,al                     
    dec cl                        
    jnz g_r_loop                  
  mov cl,127                      
  r_s_loop:                       
    mov dx,03c8h                  
    mov al,cl                     
    out dx,al                     
    inc dx                        
    mov al,cl                     
    shr al,1                      
    out dx,al                     
    mov al,0                      
    out dx,al                     
    out dx,al                     
    dec cl                        
    jnz r_s_loop                  
endm                              
macro csb_chaos ;displays the "csb chaos" before the burning man
  mov ax,0a000h                                                 
  mov es,ax                       
  xor eax,eax                 
  xor di,di                   
  mov cx,16000                
  rep stosd                   
  mov si,offset csb           
  mov di,11584                
  call pr_string              
  mov si,offset chaos         
  mov di,32000                
  call prep_string            
  mov [cs:screenseg],0a000h   
  call write_string           
  mov [cs:nt],0            ;this one u should know from other parts of this intro   
  mov [cs:beat],0                                                                
  mov [cs:bc],beatc           
  mov [cs:tc],textc           
  chaos_weiter:               
    test [cs:nt],255          
    jz chaos_weiter           
endm     
label logo byte
include "logo2.inc" ;shitty little logo, I didn't know what to do with the space
                                                                                
proc showlogo       ; and the routine to display it
  mov si,offset logo                               
  mov cx,58                                   
  ylogo_loop:                                 
    mov dx,43                                 
      x_logo_loop:                            
         mov al,[cs:si]                       
         shl al,4                             
         add [es:di],al                       
         inc si                               
 	 inc di                               
 	 dec dx                               
 	 jnz x_logo_loop                      
 add di,277                                   
 dec cx                                       
 jnz ylogo_loop                               
 ret                                          
endp                                          
strt: speicherseg ;checks which mem could be used and writes the seg-adresses 
   cmp ax,bx      ;into variables, if there's not enugh...                            
   ja prog_ende   ;just jump out of the intro                                        
   cleardig       ;clears the font puffer                            
   push ds                                    
   i_1c           ;install the beatsimlator                            
                                              
   bobfx          ;starts the bad schadebob fx
                                              
   pop ds                                     
   mov ax,13h      
   int 10h         
   mov ax,[cs:speichers3] ;clear the buffers
   mov es,ax                                
   xor eax,eax                              
   xor di,di                                
   mov cx,16000                             
   rep stosd                                
   mov ax,[cs:speichers4]                   
   mov es,ax                                
   xor eax,eax                              
   xor di,di                                
   mov cx,16000                             
   rep stosd                                
   setpentpal      ; set the palatte                         
                                            
   call pentfx     ; burning pentagram with text                         
   csb_chaos       ; show the "csb chaos"                             
                                                 
   mov ax,[cs:speichers3] ;clear the firebuffers for the man                  
   mov es,ax                                                
   xor eax,eax                                              
   xor di,di                                                
   mov cx,16000                                             
   rep stosd                                                
   mov ax,[cs:speichers4]                                   
   mov es,ax                                                
   xor eax,eax                                              
   xor di,di                                                
   mov cx,16000                                             
   rep stosd                                                
                                                            
   call man_fx     ; burning man
   mov ax,0a000h                                            
   mov es,ax                                                
   xor eax,eax         
   xor di,di           
   mov cx,16000        
   rep stosd           
   mov di,23169        
   call showlogo   ;show the damned logo    
 outer_eloop:      ;and wait for the beatsimulator
   mov [cs:nt],0                                  
   mov [cs:tc],textc          
   mov [cs:bc],beatc          
   tw_loop:test [cs:nt],255   
   jz tw_loop                 
   dec [cs:endlogo]           
   jnz outer_eloop            
   u_1c            ;uninstall the beatsimulator          
   mov ax,3        ;and switch back to textmode                            
   int 10h                                     
                                               
   prog_ende:                                  
                                               
   mov ax,4c00h                                
   int 21h                                     
                                               
label Sintab word                              
include "sintab.inc" ;the sine table, lower 16 bits (signed) of the 23:9 fixed numbers
end start