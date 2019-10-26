    DOSSEG          ; Order the program to order it's segments in the
                    ; same way that high level languages do.

    .MODEL SMALL    ; Different models :
                    ;     Tiny   : Code + Data < 64k  (can be made a COM file)
                    ;     Small  : Code < 64k ;  Data < 64k
                    ;     Medium : Code > 64k ;  Data < 64k
                    ;     Compact: Code < 64k ;  Data > 64k
                    ;     Large  : Code > 64k ;  Data > 64k
                    ;     Huge   : Arrays > 64k

    .286            ; Enable 286 instructions

    .STACK 200h

    .DATA           ; Tells compiler that data is to follow.

endmessage db "This was the Fire Effect       - denthor@beastie.cs.und.ac.za$"
                    ; This is our end message. Must be terminated with a "$"
xsize    =  80      ; The x-width of our screen in pixels
ysize    =  112      ; The y-height of our screen in pixels, plus a few extra
randseed dw ?       ; any number for randomness

pallette db  0, 0, 0, 0, 0, 6, 0, 0, 6, 0, 0, 7, 0, 0, 8, 0, 0, 8, 0, 0, 9, 0, 0,10
         db  2, 0,10, 4, 0, 9, 6, 0, 9, 8, 0, 8,10, 0, 7,12, 0, 7,14, 0, 6,16, 0, 5
         db 18, 0, 5,20, 0, 4,22, 0, 4,24, 0, 3,26, 0, 2,28, 0, 2,30, 0, 1,32, 0, 0
         db 32, 0, 0,33, 0, 0,34, 0, 0,35, 0, 0,36, 0, 0,36, 0, 0,37, 0, 0,38, 0, 0
         db 39, 0, 0,40, 0, 0,40, 0, 0,41, 0, 0,42, 0, 0,43, 0, 0,44, 0, 0,45, 0, 0
         db 46, 1, 0,47, 1, 0,48, 2, 0,49, 2, 0,50, 3, 0,51, 3, 0,52, 4, 0,53, 4, 0
         db 54, 5, 0,55, 5, 0,56, 6, 0,57, 6, 0,58, 7, 0,59, 7, 0,60, 8, 0,61, 8, 0
         db 63, 9, 0,63, 9, 0,63,10, 0,63,10, 0,63,11, 0,63,11, 0,63,12, 0,63,12, 0
         db 63,13, 0,63,13, 0,63,14, 0,63,14, 0,63,15, 0,63,15, 0,63,16, 0,63,16, 0
         db 63,17, 0,63,17, 0,63,18, 0,63,18, 0,63,19, 0,63,19, 0,63,20, 0,63,20, 0
         db 63,21, 0,63,21, 0,63,22, 0,63,22, 0,63,23, 0,63,24, 0,63,24, 0,63,25, 0
         db 63,25, 0,63,26, 0,63,26, 0,63,27, 0,63,27, 0,63,28, 0,63,28, 0,63,29, 0
         db 63,29, 0,63,30, 0,63,30, 0,63,31, 0,63,31, 0,63,32, 0,63,32, 0,63,33, 0
         db 63,33, 0,63,34, 0,63,34, 0,63,35, 0,63,35, 0,63,36, 0,63,36, 0,63,37, 0
         db 63,38, 0,63,38, 0,63,39, 0,63,39, 0,63,40, 0,63,40, 0,63,41, 0,63,41, 0
         db 63,42, 0,63,42, 0,63,43, 0,63,43, 0,63,44, 0,63,44, 0,63,45, 0,63,45, 0
         db 63,46, 0,63,46, 0,63,47, 0,63,47, 0,63,48, 0,63,48, 0,63,49, 0,63,49, 0
         db 63,50, 0,63,50, 0,63,51, 0,63,52, 0,63,52, 0,63,52, 0,63,52, 0,63,52, 0
         db 63,53, 0,63,53, 0,63,53, 0,63,53, 0,63,54, 0,63,54, 0,63,54, 0,63,54, 0
         db 63,54, 0,63,55, 0,63,55, 0,63,55, 0,63,55, 0,63,56, 0,63,56, 0,63,56, 0
         db 63,56, 0,63,57, 0,63,57, 0,63,57, 0,63,57, 0,63,57, 0,63,58, 0,63,58, 0
         db 63,58, 0,63,58, 0,63,59, 0,63,59, 0,63,59, 0,63,59, 0,63,60, 0,63,60, 0
         db 63,60, 0,63,60, 0,63,60, 0,63,61, 0,63,61, 0,63,61, 0,63,61, 0,63,62, 0
         db 63,62, 0,63,62, 0,63,62, 0,63,63, 0,63,63, 1,63,63, 2,63,63, 3,63,63, 4
         db 63,63, 5,63,63, 6,63,63, 7,63,63, 8,63,63, 9,63,63,10,63,63,10,63,63,11
         db 63,63,12,63,63,13,63,63,14,63,63,15,63,63,16,63,63,17,63,63,18,63,63,19
         db 63,63,20,63,63,21,63,63,21,63,63,22,63,63,23,63,63,24,63,63,25,63,63,26
         db 63,63,27,63,63,28,63,63,29,63,63,30,63,63,31,63,63,31,63,63,32,63,63,33
         db 63,63,34,63,63,35,63,63,36,63,63,37,63,63,38,63,63,39,63,63,40,63,63,41
         db 63,63,42,63,63,42,63,63,43,63,63,44,63,63,45,63,63,46,63,63,47,63,63,48
         db 63,63,49,63,63,50,63,63,51,63,63,52,63,63,52,63,63,53,63,63,54,63,63,55
         db 63,63,56,63,63,57,63,63,58,63,63,59,63,63,60,63,63,61,63,63,62,63,63,63
           ; Our pallette ... generated elsewhere and brought in

screen   db xsize*ysize dup (?) ; Virtual screen

    .CODE           ; Tells compiler that code is to follow.


Random          proc near

    mov     ax,[RandSeed]
    mov     dx,8405h
    mul     dx     ; ax*dx with result in dx:ax
    inc     ax
    mov     [RandSeed],ax
    ret            ; Return back to main section

Random          endp



SetUpScreen     proc near

    mov     ax,0013h
    int     10h       ; Get into 320x200x256 MCGA mode.

    mov     ax,0a000h
    mov     es,ax
    xor     di,di     ; ES:DI is now pointing to the top left hand of the screen

    cli
    cld
    mov     dx,3c4h
    mov     ax,604h   ; Enter unchained mode
    out     dx,ax
    mov     ax,0F02h  ; All planes
    out     dx,ax
    xor     ax,ax
    mov     cx,32767
    rep     stosw     ; Clear the screen
    mov     dx,3D4h
    mov     ax,14h    ; Disable dword mode
    out     dx,ax
    mov     ax,0E317h ; Enable byte mode.
    out     dx,ax
    out     dx,ax
    mov     ax,00409h ; Cell height
    out     dx,ax

    mov     si, offset [pallette]
    mov     dx, 3c8h  ; Pallette write register
    mov     al, 0
    out     dx, al    ; Start at color zero
    inc     dx
    mov     cx, 768
@PalLoop :
    outsb             ; Write value to port; inc DI
    dec     cx
    jnz     @PalLoop
    ret

SetUpScreen    endp



START:
    mov     ax,@DATA
    mov     ds,ax     ; Moves the segment of the data into DS.

    call    SetUpScreen

    mov     randseed,1234h
    mov     si,offset [screen]
    mov     cx,xsize*ysize
    xor     ax,ax
    rep     stosb     ; Clear our virtual screen.

@MainLoop :

                      ;
                      ; This next bit puts either 0 or 255 along the very
                      ; bottom row of our virtual screen.
                      ;

    mov     si,offset [screen]
    add     si,xsize*ysize
    sub     si,xsize  ; si=ofs(screen)+xsize*ysize-xsize ie. start of last row
    mov     cx,xsize  ; loop the entire last row
    xor     dx,dx
@Newline :
    call    random
    mov     ds:[si],dl
    inc     si
    dec     cx
    jnz     @Newline

                      ;
                      ; This "softens" the values in the virtual array,
                      ; creating a fire effect.
                      ;
    mov     cx,xsize*ysize
    sub     cx,xsize
    mov     si,offset [screen]
    add     si,xsize
@FileLoop :
    xor     ax,ax
    mov     al,ds:[si]
    add     al,ds:[si+1]
    adc     ah,0
    add     al,ds:[si-1]
    adc     ah,0
    add     al,ds:[si+xsize]
    adc     ah,0
    shr     ax,2
    jz      @zero
    dec     ax
@Zero :
                      ; al = ((pos)+(pos+1)+(pos-1)+(pos+80))/4 - 1
    mov     ds:[si-xsize],al
    inc     si
    dec     cx
    jnz     @FileLoop

                      ;
                      ; This dumps our virtual screen to the VGA screen.
                      ;
    mov     dx, 3dah
l1:
    in      al, dx
    and     al, 8h
    jnz     l1
l2:
    in      al, dx
    and     al, 8h
    jz      l2

    mov     cx,xsize*ysize
    shr     cx,1
    mov     si,offset [screen]
    xor     di,di
    rep     movsw

    mov     ah,01
    int     16h       ; Has a key been pressed?
    jz      @MainLoop ; If not, carry on.

    mov     ah,0
    int     16h       ;get a key, returned in AX
                      ;this is just to clear the keyboard buffer of the key
                      ;press.

    mov     ax,0003h
    int     10h       ; Get into 80x25 text mode

    mov     dx,offset [endmessage]
    mov     ah,09h
    int     21h       ; Dos interrupt 21, subfunction 09 ... print string.
                      ; DS:DX must be pointing to start of string.

    mov     ax,4c00h  ; This function exits the program
    int     21h       ; and returns control to DOS.
END START

