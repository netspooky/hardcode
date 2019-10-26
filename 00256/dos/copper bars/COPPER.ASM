;-----------------------------------------------------------------------------
; /* XtaC */
; hi, there...
; you might be wondering what diz iz... well, run it and zee...
; itz only a cute lil'e copper bar... :)
; anyway... let me explain how it is done...
;           
; all you gotta do is change the palette between one vertical retrace and
; in the middle of two horizontal retraces...
; got it... no?... read the code...
;
; Compile/Link:
;       TASM: tasm copper
;             tlink /t copper
;       MASM: masm copper
;             link /tiny copper;
;-----------------------------------------------------------------------------            
assume cs:code,ds:code

code    segment
        org 100h

mainloop:
        call some_calc    ; call the procedure define further down...

; first palette change
        xor bx,bx         ; zero bx, our counter
@pal1:
        mov dx,3dah       ; lets go to port 3da, to wait for a horizontal
    @hretrace1_1:         ; retrace
        in ax,dx          ; get the port value
        and ax,1          ; compare it with 1
        jnz @hretrace1_1  ; if not zero then loop back 
                                                         
        mov dx,3c8h       ; now we go to port 3c8, palette color
        xor ax,ax         ; zero ax cuz we want to change the color 0
        out dx,al         ; put 0 into port 3c8
        inc dx            ; increase dx cuz port 3c9 is for r,g,b values
        mov ax,bx         ; move our counter to ax
        out dx,al         ; and put the red value in
        xor ax,ax
        out dx,al         ; now the green
        out dx,al         ; and the blue
        inc bx            ; increase the counter  
                                                
        mov dx,3dah       ; lets wait again for a horizontal retrace
   @hretrace1_2:                                                    
        in ax,dx                                                   
        and ax,1                                                   
        jnz @hretrace1_2  
                          
        cmp bx,63         ; check if the couter reached 63, max value for rgb
        jnz @pal1         ; if not, then loop back to start of pal1
                                                                   
; second palette change                                            
        mov bx,63         ; now lets do the same, but starting from the top
@pal2:   
    @hretrace2_1:         ; wait for horizontal retrace
        mov dx,3dah                                   
        in ax,dx           
        and ax,1           
        jnz @hretrace2_1   

        mov dx,3c8h       ; port 3c8
        xor ax,ax
        out dx,al         ; color 0
        inc dx            ; port 3c9
        mov ax,bx
        out dx,al         ; red
        xor ax,ax
        out dx,al         ; green
        out dx,al         ; blue

        mov dx, 03dah     ; yet another horizontal retrace
    @hretrace2_2:
        in al, dx
        and al, 1
        jz @hretrace2_2       
                          
        dec bx            ; decrement the counter
        cmp bx,0          ; check if 0
        jnz @pal2         ; if no, then go back to pal2

        mov ah,1h         ; function 01h: check for a keypress
        int 16h           ; keyboard interrupt 
        jz mainloop       ; no key!... start all over again

        mov dx,offset text ; get the offset of the text
        mov ah,9h          ; SHOW IT!!
        int 21h            ; with dos interrupt service

        mov ah,4ch        ; yes... we made it... :()
        int 21h           ; lets get the hell outta here...

; additional procedures...
some_calc proc
        mov dx,3dah       ; yes... one more... vertical retrace...
    @test1:
        in al,dx
        and al,8h         ; test if port 3da is <> 0
        jnz @test1
    @test2:
        in al,dx
        and al,8h         ; test if port 3da is = 0
        jz @test2
; math...
        mov cl,[line]
        cmp [line],235    ; this check which line we're in... max 235
        jna decr          ; if not, lets decrement the line (down)
        mov [up],-1       ; yep... we're going down

    decr:
        cmp line,2        ; have we reached the top ?
        jnb incr          ; if not, lets increment the line (up)
        mov [up],1        ; yep... going up...
    incr:
        mov al,[up]       ; get up in al (what??)
        add [line],al     ; add line into al
        mov cl, [line]    ; repeat our horizontal retrace "line" times...
    @loop:
        call hretrace     ; repeat horizontal retrace
        loop @loop
some_calc endp

; no... not again....
hretrace proc
         mov dx,3dah
    test1:
         in al,dx
         and al,1h
         jnz test1
    test2:
         in al,dx
         and al,1h
         jz test2
         ret
hretrace endp

line   db 0  ; wich line are we in
up     db 1  ; are we going up or down                 
text   db 'XtaC...assembler...ughh!',13,10,'$' ; some words of wisdom...

code ends

end mainloop              ; the end of our program loop

