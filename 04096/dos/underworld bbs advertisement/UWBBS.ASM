 COMMENT #
 °°±±²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²±±°° 

     UNDERWORLD BBS ADVERTISEMENT                         04.97
     Sysop : Synoptic / DeVoTiOn
     
     Source Code File in ASM   
     Code by DaKe

     Greets for this code go to : 
     HOWARD SWINEHART - I use his code for the int 09h handler
     ERVIN / ABBADDON - For the code of the video mode twkd 256x128

     Please don't rip this code and say that is yours or you will be
     a fucking lamerz. I'm sure you won't but if you use it, please 
     write my name in your greetings. It will be fine and it costs 
     nothing....

     To compile it (I use A86 v 4.01) :
     A86 UWBBS.ASM

     Note : 
     
     - This version is bit smaller and slower than the original.
       Instead of using some SHR in the SINUS part to multiply by
       120, I use a MUL which, as you probably know, is slower.
     
     - This source is not very optimized. I'm too lazy to make
       it better.... It's packed with Xpack.

     - The palette has been changed because the old one
       wasn't nice.

     For contact :
     -----------------------
     E-Mail : dake@omedia.ch
     -----------------------

     Don't hesitate to check my home page at :
     --------------------------------------------------
     WWW    : http://www.omedia.ch/pages/dake/index.htm 
     --------------------------------------------------
 
     Don't forget to check the Underworld BBS !!!

 °°±±²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²±±°° 
 #


;  °±±²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²±±°
; °   First of all - Handling the keyboard interrupt - HOWARD SWINEHART     °
;  °±±²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²±±°

;     I didn't want to leave to the user, the possibility of pressing
;     Pause. So I choose to put this...


KEY_START:    mov ax,03509h            ;get the interrupt 09h address
              int 21h                  ;and get the ES:BX
  

              mov [oldint9],bx         ;save it in a Dword
              mov [oldint9+2],es       ;but here we have two words
                                       ;word2=seg=es and word1=offset=bx 



              mov al,09h               ;set interrupt vector for int 09h 
              mov dx,offset newint     ;DS:DX = address of interrupt handler
              mov ah,025h              ;func. 25 (set interruption vector)
              int 21h                  ;call the interruption

;  °±±²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²±±°
; °   Init the counter, the VGA tweaked mode and set the palette            °
;  °±±²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²±±°

   

SCR_SET:       call VGA256             ;set the tweaked mode 256x128
               call PAL                ;set the new palette


;              CHECK_2ND_PAGE:         If you want to 
;              mov dx,03d4h            see the second page of the 
;              mov al,0ch              VGA mode where the rotation
;              mov ah,32               the blur are made and the
;              out dx,ax               text is added


                                 
INIT_COUNTER: 

               call TICK               ;TICK takes the actual value in
                                       ;the PIT which is increased 18 times
                                       ;per second

               mov w[dep],w[ticker]    ;saved in dep because we'll use it later   


;  °±±²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²±±°
; °   The main routine with the rotozoom-blur and key testing               °
;  °±±²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²±±°


MAIN_PROG:     call MAINPROG           ;this procedure makes all
                                       ;the stuff
                                       ;test what's going on with keys 
               test b[keytable+70],1   ;check if PAUSE is pressed 
               jnz Main_Prog           ;if PAUSE is on the go to main rout.


               test b[keytable+1],1    ;ESC key ?
               jz Main_Prog            ;No, so continue...
              

;  °±±²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²±±°
; °   The last part with the text effect                                    °
;  °±±²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²±±°


               xor bp,bp               ;bp is used as a counter

FADE_BLACK:    call FADE               ;decrease each color value
               call SYNC               ;two syncro with the VBL
               call SYNC               ;to make a slow fade
               inc bp
               cmp bp,63               ;have we reached the max. 
               jna FADE_BLACK          ;possibility of VGA card ?
                                       
                                       ;Note : colors are coded in
                                       ;6 bits = 0-63 !!!


TEXT_MODE:     mov ax,03h
               int 10h                 ;set the 80x25 text mode


HIDE_CURSOR:   mov ax,0100h
               mov cx,02607h           ;the cursor is hidden
               int 10h



START_SCROLL:  push 0b800h
               pop es                  ;ES:DI is the text screen
               mov w[pointer],0        ;we start on the first character
                                       ;in the text memory for the
                                       ;scrolling

               xor di,di               ;we change the characters colors
               mov ax,0B00h            ;AH=color and AL=charact.
               mov bx,0300h            ;here we have 0B=light cyan

CHESS:         mov es:[di],ax          ;we fill the text memory
               mov es:[di+2],bx
               mov es:[di+4],ax        ;to make the "chess" effect
               add di,6                ;6 because one "text pixel" is a
                                       ;word composed of the color and
                                       ;the char. number

               cmp di,1600*2           ;check if greater than the
               jna CHESS               ;logo (1600 bytes * 2) because
                                       ;there are the color and the char.

SCROLLTXT1:    mov si,offset scrolltxt 
               add si,1600             ;we start at the end of the logo
               mov di,w[pointer]       ;di is the position in the txt screen
               call SYNC               ;a syncronisation to do it slower

SCROLLTXT2:    mov al,ds:[si]          ;in al, we have the char. number
               mov es:[di],al          ;we place it on the screen
               dec di,2                ;we decrease the position on the
                                       ;screen by 2 becoz we don't
                                       ;want to erase the color !

               dec si                  ;but by 1 for the logo - it has
                                       ;only text data not colors
               cmp di,0                ;are we under 0 ?
               jnl SCROLLTXT2          ;if not, the scroll continues

              
               add w[pointer],8        ;we change the position on screen
                                       ;by a multiple of two

               cmp w[pointer],3200     ;check if the pointer is greater
               jna SCROLLTXT1          ;than the logo (1600*2)
                                       ;if not, we can return to the start

;  °±±²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²±±°
; °   We restore the interrupt, the cursor and we return to the DOS         °
;  °±±²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²±±°

POS_CURSOR:    mov ah,2                ;here we set the new cursor position
               mov bh,0                ;at the end of the text logo
               mov dx,01400h           ;ROW=20 (14h) - COLUMN=0
               int 10h                 ;call the interrupt


SHOW_CURSOR:   mov ax,0100h            ;the cursor
               mov cx,0506h            
               int 10h                 ;is now enabled        
               
RESTORE_INT:   mov al,09h              ;we restore the original INT 09h
               mov dx,[oldint9]        ;DX=offset of the old INT
               mov ds,[oldint9+2]      ;DS=seg of the old INT
               mov ah,25h
               int 21h                 ;set new vector

DOS_RETURN:    mov ax,04ch                     
               int 21h                 ;return to the DOS
            
;  °±±²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²±±°
; °   Here's just a Jump which is used to restart the loop                  °
;  °±±²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²±±°

TURN:          jmp Init_counter


;  °±±²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²±±°
;  °±±²²²²²²²²²²²²²²²²²²²²P²R²O²C²E²D²U²R²E²S²²²²²²²²²²²²²²²²²²²²²²²²²²²²±±°
;  °±±²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²±±°

;  °²°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°²°
; ²   The new interrupt handler for keyboard  -  HOWARD SWINEHART           ²
;  °²°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°²° 

NEWINT:        push ax,bx              ;we save the registers
               in al,60h               ;check scan code
               mov bl,al               ;we save in BL the scan code
               and bx,127              ;high bit
               and b[bx+keytable],0feh ;zero key's flag
               test al,128             ;key release ?
               jnz exit_int            ;if it's true => exit
               or b[bx+keytable],1     ;no, key flag is on
               
EXIT_INT:      mov al,20h              ;signal end of interrupt
               out 20h,al              ;send it
               pop bx
               pop ax                  ;restore registers
               iret                    ;exit from this proc

;  °²°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°²°
; ²   These proc. check which message has to be written on the screen       ²
;  °²°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°²° 
;
; I have to use some jumps because A86 cries when the Jump is greater than
; 128 bytes ... I think it's the most ugly part in this source :(


               MSG_JMP2:
               call MSG2

MSG2 PROC      ;in w[compta], there's the number of ticks (18 per second)
               
               cmp w[compta],1020      ;if we arrive at about 55 sec.
               ja turn                 ;we return to the start for a
                                       ;new loop
               cmp w[compta],920
               ja LITTA                ;LITTA is message nø10

               cmp w[compta],820
               ja LITT9                ;LITT9 is message nø9

               cmp w[compta],720
               ja LITT8

               ;---------------------------------------------------------
               
               LITTA:
               mov di,32768+256*45     ;here's the position of 
               lea si,texta            ;the message on the screen
               call STRING             ;this proc. print the char.
               jmp MSG_END2            ;on the screen


               LITT9:
               mov di,32768+256*67
               lea si,text9
               call STRING
               jmp MSG_END2

               LITT8:
               mov di,32768+256*23
               lea si,text8
               call STRING
               
               MSG_END2:
               ret
MSG2 ENDP

MSG1 PROC      ;the first proc to print the message on screen

               cmp w[compta],720       ;if we are greater than 720
               ja MSG_JMP2            ;then we have to go to the
                                       ;others messages...
               cmp w[compta],620
               ja LITT7

               cmp w[compta],520
               ja LITT6

               cmp w[compta],420
               ja LITT5

               cmp w[compta],320       ; <---+
               ja LITT4                ;     ³ about
                                       ;     ³ 6 sec. between each message
               cmp w[compta],220       ; <---+ because the ticker is
               ja LITT3                ;       increased 18 times per sec.

               cmp w[compta],120
               ja LITT2       

               cmp w[compta],20
               ja LITT1

               ;---------------------------------------------------------

               Litt1:
               mov di,32768+256*21
               lea si,text1
               call STRING
               jmp MSG_END1
               

               Litt2:
               mov di,32768+256*34
               lea si,text2
               call STRING
               jmp MSG_END1
               

               Litt3:
               mov di,32768+256*45
               lea si,text3
               call STRING
               jmp MSG_END1

               Litt4:
               mov di,32768+256*53
               lea si,text4
               call STRING
               jmp MSG_END1

               Litt5:
               mov di,32768+256*61
               lea si,text5
               call STRING
               jmp MSG_END1

               Litt6:
               mov di,32768+256*89
               lea si,text6
               call STRING
               jmp MSG_END1

               Litt7:
               mov di,32768+256*73
               lea si,text7
               call STRING
               jmp MSG_END1

               MSG_END1:
               ret
MSG1 ENDP

;  °²°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°²°
; ²   PUT_POINT takes a rotated point in the source image                   ²
;  °²°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°²° 

PUT_POINT PROC 
               cmp w[YT],127           ;are we outside our screen ?
               ja NO_PUT_POINT         ;yes, so keep time

               mov ax,w[YT]            ;YT is the Y of rotated point
               shl ax,8                ;(yt*256)
               add ax,w[XT]            ;(yt*256)+xt = offset_rotated
               mov di,ax               ;and we have our offset in DI
               mov cl,es:[di]          ;in cl, there's the current pixel
               cmp cl,0                ;if pixel<0 -> don't decrease the

               jz no_put_point         ;color
               dec cl                  ;otherwise, decrease color 


               mov ax,w[Y]             ;were goes this point ?
               shl ax,8
               add ax,w[X]             ;(y*256)+x = offset_point
               mov di,ax
               mov ch,cl               ;ch and cl are equal
               mov es:[di+32768],cx    ;and we can print four pixel  
               mov es:[di+32768+256],cx  

               NO_PUT_POINT:
               ret
PUT_POINT ENDP

;  °²°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°²°
;  ² PALETTE Settings...                                                   ²
;  °²°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°²° 

PAL PROC
               SET_PALETTE1:
               lea si,palet            ;we are in the palette data
               xor ax,ax               ;AL = index and it starts at idx. 0

               SET_PALETTE2:           ;I don't divide the component by 4
                                       ;because they have been converted
                                       ;in 6 bits when I take the palette

               mov ah,ds:[si]          ;AH = red       
               
               mov bl,ds:[si+1]        ;BL = green
               
               mov bh,ds:[si+2]        ;BH = blue
               
               call SET_COLOR          ;we set this color...    
               
               add si,3                ;...and we continue with the nxt one  
               inc al                  ;next index
               cmp al,64               ;have we finished with our 64 colors ?
               jna SET_PALETTE2     
               
               ret                     ;return
PAL ENDP

;  °²°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°²°
; ²   The Main Procedure which makes the ROTOZOOM and the BLUR              ²
;  °²°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°²° 

MAINPROG PROC
               MAIN1 :
               mov w[X],0              ;we start
               mov w[Y],0              ;with the first pixel 

               MAIN2 :                 ;Let's rotate the picture     
               call NEW_POINT          ;rotation     
               call PUT_POINT          ;pixels offsets
               add w[X],2              ;next pixel    
               cmp w[X],256            ;end of current line ?
               jna MAIN2               

               mov w[X],0              ;if the line is finished, we start
                                       ;a new one
               add w[Y],2              ;and increase Y by two
               cmp w[Y],125            ;end of screen ?
               jna MAIN2                

               MAIN3 :                 ;Blur and Messages...
               call BLUR                    
               call CHECK_TICK         ;timing => messages

               MAIN4 :                 ;flip new screen with the old one
               xor di,di               ;first pixel and we
               call COPIE              ;copy it...
               ret
MAINPROG ENDP

;  °²°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°²°
; ²   The Main Procedure which makes the ROTOZOOM and the BLUR              ²
;  °²°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°²° 
;
;     All you need to rotate a point is using some SINUS and COSINUS
;     It's slow. You can use offsets and scanlines in pictures to 
;     improve the algorithm but I didn't want to precalculate the
;     offsets.


NEW_POINT PROC    

               Equation_1:             
               xor dx,dx               
               mov ax,w[X]             ;we have the X
               mov cx,ax               ;in CX and AX
                                       ;120=cos(20/128) to use the fixed
               mov bx,120                       
               mul bx
               xchg cx,ax              ;CX saves (X*COS)
            
               mov ax,w[Y]
               shl ax,2                ;here, the sinus is 4 
                                       ;so we have cos(20/128)
                                       ;and sin (2/128)
                                       ;strange but you can assume
                                       ;that cos is the zoom parameter
                                       ;and sin the rotation...
                                       ;try and you'll see ;)
               
               sub cx,ax               ;CX=(X*COS) and AX=(Y*SIN)
               shr cx,7                ;we divide both by 128
               mov w[XT],cx            ;and we have finally
                                       ;XT = [(X*COS)-(Y*SIN)]/128


              Equation_2:
              xor dx,dx        
              mov ax,w[Y]
              mov bx,120               ;we multiply Y by 120        
              mul bx                   ;AX=(Y*COS)


              mov cx,w[X]
              shl cx,2                 ;(X*4)
              add cx,ax                ;AX=(Y*COS) and CX=(X*SIN)
              shr cx,7                 ;CX=[(Y*COS)+(X*SIN])/128
              mov w[YT],cx             

              Crackle:                 ;here's the crackle effect
              mov dx,10         
              call RND                 ;find a random number
              sub w[yt],dx             ;and change yt with that number

              ret
NEW_POINT ENDP

;  °²°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°²°
; ²   Check the timing and put messages                                     ²
;  °²°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°²° 

CHECK_TICK PROC
              call TICK
              mov ax,w[ticker]         ;ticker has the value of the PIT
              sub ax,w[dep]            ;how many from the start of the prog ?
              mov w[compta],ax         ;and compta is the real number  of
              call MSG1                ;ticks since the programm started
              ret
CHECK_TICK ENDP

;  °²°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°²°
; ²   The Fade-Out                                                          ²
;  °²°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°²° 


FADE PROC               
              mov b[color],0           ;start with color 0
              Fader:
              call GETCOLOR            ;GET the color index 0
              xchg ah,bl               ;xchg the registers
              mov bh,al                ;because there are not at the 
              Red:                     ;same emplacement
              cmp ah,0
              jz Green                 ;0 so don't decrease...
              dec ah                   ;if red > 0 then decrease by 1
              Green:
              cmp bl,0                 ;...
              jz Blue
              dec bl
              Blue:
              cmp bh,0
              jz Fin_Color             ;...
              dec bh

              Fin_Color:
              mov al,b[color]          ;set the new decreased color
              call SET_COLOR
              inc b[color]             ;next color
              cmp b[color],0           ;we do all the palette !
              jnz Fader                ;if we have 0 then we stop
              ret
              FADE ENDP

;  °²°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°²°
; ²   Get Color                                                             ²
;  °²°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°²° 

GETCOLOR PROC             
              mov dx, 03C7h            ;register of the VGA card
              mov al, color            ;al is the index of the color
              out dx, al               ;we send it to the card
              add dx, 2                ;the dx=03C9h (R,V,B data)
              xor bh, bh
              in al, dx                ;we start with the red
              mov bl, al               ;bl=al=red
              in al, dx
              mov ah, al               ;ah=green
              in al, dx
              mov dx, bx               ;al=blue
              ret                   
GETCOLOR ENDP

;  °²°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°²°
; ²   Timing Checking - Save the number of ticks                            ²
;  °²°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°²° 

TICK PROC
              push ax
              push di
              push es
              mov ax,040h              ;PIT address is at 040h:06ch
              mov es,ax                ;(for the ticks)
              mov di,06ch
              mov ax,es:[di]           ;we save it but it's normally
                                       ;a 32 bits number - it's not
                                       ;important for us
              mov w[ticker],ax
              pop es
              pop di
              pop ax
              ret 
TICK ENDP

;  °²°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°²°
; ²   Flip the old screen with the new one                                  ²
;  °²°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°²° 


COPIE PROC 
              xor di,di                ;we copy the page 2 (from 32768)
                                       ;to the first one (start at 0)
              COP_2:
              mov ax,es:[di+32768]
              mov es:[di],ax           ;copy one word
              inc di,2
              cmp di,32768             ;the end ?
              jna COP_2
              ret
COPIE ENDP

;  °²°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°²°
; ²   The blur effect                                                       ²
;  °²°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°²° 

BLUR PROC
               mov di,33024            ;we start at offset 33024 in the 2nd
                                       ;page

               BLUR_S:
               xor bx,bx               ;we'll add pixels values in ax
               xor ax,ax               ;and use bx to take the pixel
               
               mov bx,es:[di-256]      ;let's start with the pixel (x)(y-1)
               add ax,bx
               mov bx,es:[di+256]      ;(x)(y+1)
               add ax,bx
               mov bx,es:[di+1]        ;(x+1)(y)
               add ax,bx
               mov bx,es:[di-1]        ;(x-1)(y)
               add ax,bx
               shr ah,2                ;we divide these values by 4 
               shr al,2                ;in fact, we've got 8 pixels
                                       ;but the colors are between 0 and 64
                                       ;so we can't have : value > 255
                                       ;in the byte
                                       
               mov es:[di],ax          ;and we put this on the screen
               add di,2                ;next two pixels
               cmp di,65279            ;the end of the screen
               jna BLUR_S
               ret
BLUR ENDP

;  °²°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°²°
; ²   The binary decomposition for the characters                           ²
;  °²°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°²° 
;
;  Assume you have the binary number (8 bits) : 01010101
;  I want to have only the first bit...
;  So I apply a mask like this one : (1 SHL N)-1
;  For the first byte, it will be (1 SHL 1)-1 = 1
;  And we do (AL=01010101): AND AL, 1 
;  AL=1
;
;  To check the other bits, we do a ROL (rotation to left). The first
;  byte is now the last one and the last is the first. ROL AL,1 will
;  change AL in 10101010. With these knowledges, you can decompose 
;  a number in bits. :)

BIN_DEC PROC                           ;cl=number to decompose
              mov al,cl        
              and al,1                 ;apply the mask for one bit
              cmp al,0                 ;0 ?
              jz b1                    
              shl al,6                 ;no, so al=64 (pixel color for char)
              mov es:[di],al
              mov es:[di+256],al

              b1:                      ;next bit
              mov al,cl        
              rol al,1                 ;rol by 1
              and al,1
              cmp al,0
              jz b2
              shl al,6
              mov es:[di+1],al          ;we print the value on the
              mov es:[di+256+1],al      ;screen (it's the character)

              b2:
              mov al,cl       
              rol al,2                  ;rol by 2
              and al,1
              cmp al,0
              jz b3
              shl al,6
              mov es:[di+2],al
              mov es:[di+256+2],al

              b3:
              mov al,cl       
              rol al,3
              and al,1
              cmp al,0
              jz b4
              shl al,6
              mov es:[di+3],al
              mov es:[di+256+3],al

              b4:
              mov al,cl        
              rol al,4
              and al,1
              cmp al,0
              jz b5
              shl al,6
              mov es:[di+4],al
              mov es:[di+256+4],al

              b5:
              mov al,cl       
              rol al,5
              and al,1
              cmp al,0
              jz b6
              shl al,6
              mov es:[di+5],al
              mov es:[di+256+5],al

              b6:
              mov al,cl       
              rol al,6
              and al,1
              cmp al,0
              jz b7
              shl al,6
              mov es:[di+6],al
              mov es:[di+256+6],al

              b7:
              mov al,cl      
              rol al,7
              and al,1
              cmp al,0
              jz b8
              shl al,6
              mov es:[di+7],al
              mov es:[di+256+7],al

              b8:
              ret
BIN_DEC ENDP    


;  °²°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°²°
; ²   The character creation                                                ²
;  °²°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°²° 


CARA PROC                               ;BX=character number
              push di
              push ds
              push si 
              push es
              mov ah,11h                ;this function find
              mov al,30h                ;the address of the standard 
              mov bh,3                  ;characters table => ES:BP
              int 10h
              mov ax,es                 ;DS:SI=table
              mov ds,ax
              mov si,bp
              pop es



              mov bh,0                  
              shl bx,3                  ;we multiply by 8 because
              add si,bx                 ;the chars have a size of 8x8
              xor bp,bp

              CARA1:
              mov cl,ds:[si]            ;we take the first line of the char.
              call BIN_DEC              ;binary decomposition to find the
              
              add di,512                ;next line in screen
              inc si                    ;next line in table
              inc bp                    ;counter is increased
              cmp bp,7                  ;end of char. ?
              jna CARA1
              pop si
              pop ds
              pop di

              ret
CARA ENDP

;  °²°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°²°
; ²   STRING takes the message and their letters..                          ²
;  °²°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°²° 


STRING PROC                            ;DS:SI = address of current message
                xor bx,bx              

                Type1:
                mov bl,ds:[si]         ;take the char
                cmp bl,'$'             ;check if end of message
                jz Fino_Strg
                call CARA              ;if not, let's continue and print it
                add di,15              ;there are 15 pix between each char.
                inc si                 ;the next char. in message..
                jmp Type1    
                Fino_Strg:
                ret
STRING ENDP

;  °²°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°²°
; ²   VGA Mode tweaked in 256x128                                           ²
;  °²°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°²° 


VGA256 PROC                            ;this thing can be found in Imphobia 
                                       ;nø10 - Thanks to Ervin
                mov ax,13h             ;if you want more informations
                int 10h                ;read it !    
                mov cx,11              
                mov dx,03d4h           
                mov si,offset tweaker  
                rep outsw              
                mov ax,0a000h
                mov es,ax
                ret
VGA256 ENDP

;  °²°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°²°
; ²   Syncronisation with the VBL                                           ²
;  °²°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°²° 

;  This proc. waits until the video beam is at the end of your screen

SYNC PROC              
                mov dx, 3DAh
                retrace1:
                in al, dx
                test al, 8
                jz retrace1              
                retrace2:
                in al, dx
                test al, 8
                jnz retrace2
                ret
SYNC ENDP

;  °²°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°²°
; ²   Set the color                                                         ²
;  °²°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°²° 

SET_COLOR PROC                         ;al=index ah=r bl=g bh=b   
                push ax
                push bx
                mov dx,3c8h            ;registers of VGA card to change
                out dx,al              ;the index
                mov dx,3c9h            ;and the values of Red, Green and Blue
                mov al,ah
                out dx,al              ;RED
                mov al,bl
                out dx,al              ;GREEN
                mov al,bh
                out dx,al              ;BLUE
                pop bx
                pop ax
                ret
SET_COLOR ENDP


;  °²°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°²°
; ²   The random numbers procedure                                          ²
;  °²°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°²° 

;  Found somewhere in a source code....Thanx to his author ;) - There was no
;  name in the file.. :(

RND PROC
random:         push ax                        ;save ax
                push dx                        ;and limit
                mov ax,31421                   ;start with 31421
                mov bx,w[seed]
                mul bx                         ;multiply by currnt seed value
                add ax,6927                    ;add 6927
                mov seed,ax                    ;update seed
                pop dx                         ;get limit
                mul dx                         ;multiply seed by limti 
                                               ;into DX and AX
                pop ax                         ;Keep overflow as the 
                                               ;random number
                ret
RND ENDP


;  °±±²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²±±°
;  °±±²²²²²²²²²²²²²²²²²²²²²²²²²²D²A²T²A²S²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²±±°
;  °±±²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²±±°

seed    dw 0                            ;current seed value for random nb      

text1 db '    UNDERWORLD$'              ;message for the BBS Adv.
text2 db '        BBS$'     
text3 db '  CALL NOW !!!$'
text4 db '+41-(0)22-9600621$'
text5 db '+41-(0)22-9600622$'     
text6 db '+41-(0)22-9600623$' 
text7 db '  DEMOS*GFX*ZIK$'
text8 db ' DISKMAGS*SOURCES$'
text9 db 'SYSOP IS SYNOPTIC$'
textA db '   CODE BY DAKE $'

Scrolltxt:                                                                          
db'                                                                                '
db' °±±² ÛÛ °±±²ÛÛ   °±±²Û   °±±²ÛÛ °±±²ÛÛ  °±±²   Û °±±²ÛÛ °±±²  °±²    °±±²Û     '
db' ±²ÛÛ ÛÛ ±²ÛÛ  ÛÛ ±²ÛÛ ÛÛ ±²ÛÛÛÛ ±²ÛÛ ÛÛ ±²ÛÛ   Û ±²ÛÛ Û ±²Û Û ±²Û    ±²ÛÛ ÛÛ   '
db' ²ÛÛÛ ÛÛ ²ÛÛÛ  ÛÛ ²ÛÛÛ ÛÛ ²ÛÛÛ   ²ÛÛÛ ÛÛ ²ÛÛÛ   Û ²ÛÛÛ Û ²ÛÛ Û ²ÛÛ    ²ÛÛÛ ÛÛ   '
db' ÛÛÛÛ ÛÛ ÛÛÛÛ  ÛÛ ÛÛÛÛ ÛÛ ÛÛÛÛÛÛ ÛÛÛÛ ÛÛ ÛÛÛÛ Û Û ÛÛÛÛ Û ÛÛÛÛ  ÛÛÛ    ÛÛÛÛ ÛÛ   '
db' ÛÛÛÛ Û² ÛÛÛÛ  Û² ÛÛÛÛ ²Û ÛÛÛÛ   ÛÛÛÛÛ   ÛÛÛÛÛÛÛ² ÛÛÛÛ ² ÛÛÛ ² ÛÛÛ    ÛÛÛÛ ²Û   '
db' ÛÛÛÛ ²± ÛÛÛÛ  ²± ÛÛÛÛ ±² ÛÛÛÛ²± ÛÛÛÛ ²± ÛÛÛÛÛÛ²± ÛÛÛÛ ± ÛÛ² ± ÛÛÛ    ÛÛÛ² ±²   '
db' ÛÛÛÛ²±° ÛÛÛ²  ±° ÛÛ²±°   ÛÛÛ²±° ÛÛÛ² ±° ÛÛÛÛÛ²±° ÛÛÛ²±° Û²± ° ÛÛÛ²±° ÛÛ²±°     '
db'                                                                                '
db'-Ä-Ä-Ä-ÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄÄ-ÄÄ-Ä-Ä- '
db'[o]     ú  úù-ÄÍ[í] ùTúHúEù ùUúNúDúEúRúWúOúRúLúDù ùBúBúSù [í]ÍÄ-ùú  ú       [o] '
db'-Ä-Ä-Ä-ÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄÄ-ÄÄ-Ä-Ä- '
db'-Ä-Ä-Ä-ÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄÄ-ÄÄ-Ä-Ä- '
db'[ BBS Node 1 ]  ++41-(0)22-9600621  ISDN Analogue [ USRobotics Courier   33k6 ] '
db'[ BBS Node 2 ]  ++41-(0)22-9600622  ISDN Analogue [ USRobotics Courier   33k6 ] '
db'[ BBS Node 3 ]  ++41-(0)22-9600623  ISDN Digital  [ ZyXEL Elite 2864I    64kb ] '
db'-Ä-Ä-Ä-ÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄÄ-ÄÄ-Ä-Ä- '
db'[ BBS E-MAiL ]  synoptic@cryogen.com                                          ] '
db'-Ä-Ä-Ä-ÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄÄ-ÄÄ-Ä-Ä- '
db'[ Code by Dake ]  dake@omedia.ch                                                 '

pointer dw ?                            ;pointer for the text scrolling

tweaker :                               ;datas for the VGA card that
dw 00e11h,06300h,03f01h,04002h          ;it needs to do the 256x128 mode
dw 08603h,05004h,00d07h,05810h 
dw 00ff12h,02013h,00915h     

x dw ?                                  ;some values for the rotozoom
y dw ?                                  
xt dw ?
yt dw ?

compta dw ?                             ;values for the timer
ticker dw ?
dep dw ?

color db ?                              ;color for the fade-out

Palet:
 db 000h, 000h, 000h, 000h, 001h, 001h, 001h, 001h, 003h, 001h, 002h, 004h
 db 001h, 002h, 006h, 002h, 003h, 007h, 002h, 003h, 009h, 002h, 004h, 00ah
 db 003h, 005h, 00bh, 003h, 005h, 00dh, 004h, 006h, 00eh, 004h, 006h, 010h
 db 004h, 007h, 011h, 005h, 008h, 012h, 005h, 008h, 014h, 005h, 009h, 015h
 db 006h, 009h, 017h, 006h, 00ah, 018h, 006h, 00ah, 01ah, 007h, 00bh, 01bh
 db 007h, 00ch, 01ch, 007h, 00ch, 01eh, 008h, 00dh, 01fh, 008h, 00dh, 021h
 db 009h, 00eh, 022h, 009h, 00fh, 023h, 009h, 00fh, 025h, 00ah, 010h, 026h
 db 00ah, 010h, 028h, 00ch, 011h, 028h, 00eh, 012h, 027h, 011h, 013h, 027h
 db 013h, 014h, 026h, 015h, 015h, 026h, 017h, 015h, 025h, 019h, 016h, 025h
 db 01bh, 017h, 024h, 01eh, 018h, 024h, 020h, 019h, 023h, 022h, 01ah, 023h
 db 01fh, 01bh, 024h, 01ch, 01bh, 024h, 019h, 01ch, 025h, 016h, 01dh, 026h
 db 013h, 01dh, 026h, 010h, 01eh, 027h, 00dh, 01eh, 027h, 00ah, 01fh, 028h
 db 00ah, 01fh, 028h, 00ah, 020h, 028h, 00ah, 021h, 027h, 00ah, 022h, 027h
 db 00ah, 022h, 027h, 00ah, 023h, 027h, 00ah, 024h, 026h, 00ah, 025h, 026h
 db 009h, 026h, 026h, 009h, 026h, 026h, 009h, 027h, 025h, 009h, 028h, 025h
 db 009h, 029h, 025h, 009h, 029h, 025h, 009h, 02ah, 024h, 009h, 02bh, 024h
 db 63,63,63

oldint9     dw  0,0             ; Original int 9h pointer
keytable    db  128 dup(0)      ; Key state table






















        
        



