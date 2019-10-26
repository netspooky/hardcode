
;                 ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ
;                 Û            -  f l a m e  -             Û
;                 Û   Entry into the 256 byte fire compo   Û
;                 Û    Copyright 1996 Gaffer/PRoMETHEUS    Û
;                 Û         email: gaffer@ar.com.au        Û
;                 ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ

.MODEL TINY
.386

DATASEG 
Seed   DW 141

UDATASEG
Buffer DB 320*203 dup(?)

CODESEG
ORG 100h
LOCALS



;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;°°   INITIALIZATION - Set mode & palette, setup vidmode, palette & stuff   °°
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
    .STARTUP

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ SETUP VGA SEG ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    push 0A000h
    pop es

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ INIT VGA MODE 13h ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    mov al,13h
    int 10h

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ GENERATE PALETTE ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    mov al,63                                       ; Fill palette with white
    mov cx,768
    mov di,64*3
    rep stosb                  
	
    mov si,2+63*3
    xor ax,ax
    call PaletteGen                                 ; Green   ->    __/*
    mov ah,1                                                          
    call PaletteGen                                 
	
    mov si,1+63*3
    call PaletteGen                                 ; Blue    ->    _/**
	
    xor si,si
    call PaletteGen                                 ; Red     ->    /***
    
	   
;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ SET PALETTE ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    mov ax,1012h
    mov cl,255
    xor dx,dx
    int 10h


;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;°°        MAIN LOOP - Cycle through flame animation until keypressed       °°    
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
MainLoop:

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ FLAME ANIMATION ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    mov cx,320
    mov di,OFFSET Buffer
    xor ah,ah
    mov bx,100
@@L1:
    mov al,ds:[di+639]                ; Average it out...
    mov dl,ds:[di+640]
    add ax,dx
    mov dl,ds:[di+641]
    add ax,dx
    mov dl,ds:[di+1280]
    add ax,dx
    shr ax,2
    jz @@ZERO                         ; Cool a bit...
    dec al         
@@ZERO:            
    mov ds:[di],al
    mov dl,[di+1280]
    add ax,dx
    shr ax,1
    mov ds:[di+320],al                                ; double the height
    inc di         
    loop @@L1      
    mov cx,320     
    add di,cx      
    dec bx         
    jnz @@L1       
                    
;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ OUTPUT FLAME TO SCREEN ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    xor di,di
    mov si,OFFSET Buffer
    mov cx,(320/4)*95*2
    rep movsd                       

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ FLAME GENERATOR BAR ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    mov di,OFFSET Buffer + 320*199
    mov cx,320-4
@@L2:     
    in  al,40h                        ; read from timer
    add ax,Seed
    add Seed,ax
    mov ah,al
    mov ds:[di],ax
    mov ds:[di+2],ax
    add di,4
    dec cx
    jnz @@L2

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ CHECK FOR KBHIT ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    in al,60h
    das
    jc mainloop                       ; thanks goes to icepick! *8)

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;°°             DOS EXIT CODE - Switch to textmode, return to DOS           °°    
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
    mov ax,0003h                                  ; textmode
    int 10h
    ret                               ; ret to dos




;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;°°   PALETTE GEN FUNCTION - simple 64 color step 3 palette gen thingo *8)  °°    
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
PaletteGen:     
    mov cl,64
    xor al,al
@@L2:
    mov es:[si],al
    add al,ah
    add si,3
    loop @@L2
    ret

END
