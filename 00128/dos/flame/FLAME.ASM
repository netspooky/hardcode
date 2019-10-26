
;                              -  f l a m e  -             
;                           quality 128 byte fire          
;                      copyright 1997 Gaffer/prometheus     
;                             gaffer@zip.com.au             
;
;                         optimization contribution:        
;                  goblin,icepick,mf,patrik sundberg,pgeist   


.MODEL TINY
.486

UDATASEG
Buffer DB 320*203 dup(?)

CODESEG
ORG 100h
LOCALS




; INITIALIZATION: setup video mode & palette
; ------------------------------------------
    .STARTUP


; SETUP VGA SEG
    push 0A000h
    pop es


; INIT VGA MODE 13h
    mov al,13h
    int 10h


; GENERATE PALETTE
    dec di
PaletteGen:                           ; alternate palette generation
    xor ax,ax                         ; (Patrick Sundberg)
    mov cl,63
@@L1:
    stosb
    inc ax
    cmpsw                             ; small way to advance si,di!
    loop @@L1
    push di
    mov cl,192
@@L2:
    stosw
    inc di
    loop @@L2
    pop di
    inc di
    jns PaletteGen                    ; cheesy! :)


; SET PALETTE
    mov ax,1012h
    cwd                               ; equivalent to 'xor dx,dx'
    mov cl,255
    int 10h




; MAIN LOOP: Cycle through flame animation until keypress
; -------------------------------------------------------
MainLoop:

    push es
    push ds
    pop es                            ; set es=ds to use stosw


; FLAME ANIMATION
    inc cx
    mov di,OFFSET Buffer
    mov bl,99
@@L3:
    mov ax,[di+639]                   
    add al,ah                         
    setc ah
    mov dl,[di+641]
    add ax,dx
    mov dl,[di+1280]
    add ax,dx
    shr ax,2
    jz @@ZERO                         ; cool a bit...
    dec ax
@@ZERO:
    stosb
    add ax,dx                         ; double the height
    shr ax,1                          
    mov [di+319],al                   
    loop @@L3                         
    mov cx,320
    add di,cx
    dec bx
    jnz @@L3


; FLAME GENERATOR BAR
    ; assumes cx=320
    ; assumes di=generator bar offset (bottom of flame buffer)
@@L4:
    in ax,40h                         ; read from timer
    xadd ds:[100h],ax                 ; "seed" is first two bytes of code
    mov ah,al                         
    stosw
    stosw
    loop @@L4

    pop es                            ; restore es=A000h


; OUTPUT FLAME TO SCREEN
    xor di,di
    mov si,OFFSET Buffer + 320
    mov ch,60                         ; assumes cl=0
    rep movsd                         ; change to "mov ch,120" "rep movsw"
                                      ; saves one byte but is slower
                                      ; (patrik sundberg)
                                      
; CHECK FOR KEYPRESS
    mov ah,1
    int 16h
    jz MainLoop                       ; alternative keypress check
                                      ; "in al,60h" "das" "jc MainLoop"
                                      ; saves one byte but is not as reliable
                                      ; (icepick)



; DOS EXIT CODE: Switch to textmode, return to DOS
; ------------------------------------------------

    mov ax,03h
    int 10h
    ret                               


END
