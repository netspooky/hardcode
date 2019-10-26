;  TheSnake - Made by Zaifrun of Immaculate in 1997 (Martin Knudsen)
;  This is my contribution to the 256-bytes worm game competition     
;  Contact: Zaifrun@geocities.com                     
;  Compile with : "Tasm thesnake /m2"                     
;  Link with    : "Tlink thesnake /t"
;  I used Tasm 4.0 and Tlink 6.0 to make this worm game.                 
;  Enjoy!   Total size = 256 bytes
;           data = 16 bytes  (for the keyboard table)
;           code = 240 bytes
;           number of instructions = 122
;           That's about 1.97 bytes per instruction!!!
;  There is one 4-bytes instruction --- The rest is 3 bytes and below
;  If anyone can optimize this program and save
;  just a single byte and still keep the code doing the same
;  thing as now - please let me know about it. 

								      
ideal                                              
model tiny              
p286

;------------------------------                       
; Here comes some constants....                       
;------------------------------                       
 
  Player1up     = 72            ; Cursor keys for player 2
  Player1Left   = 75            ; These are scan codes for                           
  Player1Right  = 77            ; the arrow keys
  Player1Down   = 80            ;
				; Cursor keys for player 1 (scan codes)
  Player2Up     = 17            ; 'w'           
  Player2Down   = 31            ; 's'            
  Player2Left   = 30            ; 'a'           
  Player2Right  = 32            ; 'd'
  Player1Start  = 32020         ; Player one start offset in video ram
  Player2Start  = 32300         ; Player two start offset in video ram
								      
				; player1 red - si - arrowkeys - bh - ch -dh
				; player 2 green - di - other - bl - cl- dl
		     
codeseg           
  org 100h                      ; Start at 100h to make a com file
  startupcode                   ; The code starts here                       
;----------------                                  
; just some init
;----------------  
  push 0A000h                   ; shorter than 'mov ax,0A000h' and
  pop  es                       ; 'mov es,ax'. es is used to acces video mem
  push es                       ; Also initialize ds to 0A000h. This way
  pop  ds                       ; I can avoid segment overrides, which
				; takes one byte 
  xor  dx,dx                    ; Initialize points (dx) to zero 
  mov  cl,1                     ; Border color at startup (blue)
  cld                           ; This isn't strictly neccesary                                 
@restartgame:                   ; but I had a byte left...so why not?
  mov  ax,13h                   ; Set mode 13h (320x200x256C)
  int  10h                                                               
;-------------                                     
; Palette part  
;-------------  
  mov  al,16                    ; The first index for the red worm       
 @redloop:                      ; red is 16..31, yellow is 32..47
  pusha                         ; I use ALL 16 bits registers - so gotta save
  mov  dx,3c8h                  ; DAC index port (for changing the palette)
  out  dx,al                    ; since 'out dx,al' is just 1 byte
  inc  dx                       ; this way is smaller than using bios
  add  al,al    
  cmp  al,62                    ; Do we want a yellow or red shade this time?
  ja   @yellow                                          
  out  dx,al                    ; Tell the DAC about the first component
  mov  al,32                    ; Got to do this - so that al will be
 @yellow:
  sub  al,32                    ; zero when it is a red color
  out  dx,al                    ; second component (green) to DAC
				; Have to zero for a red shade
  out  dx,al                    ; Third component for the DAC
  xor  al,al                    ; if it's a red color there will be
  out  dx,al                    ; 4 outs to the port, but the last is
  popa                          ; ignored so no harm done. 
  inc  ax                       ; shorter than 'inc al' (strange but true)
  cmp  al,47    
  jbe  @redloop                 ; Are we done with the shades?  
;---------------------------------                                           
; Drawing the border color is next                 
;---------------------------------
  mov  ch,cl                    ; cl holds the border color
  xchg ax,cx                    ; shorter than 'mov ax,cx'
  xor  di,di                    ; set to start of screen
  mov  bp,320     
  mov  cx,bp            
  rep  stosb                    ; Draw upper horizontal line                    
  dec  di         
  mov  cl,193                   ; playing area is 193 pixel in vert. size
@Doagain:                                                                 
  mov  [di],ax                  ; Draws the vertical borders - 
  add  di,bp                    ; since di is assumed to point to ds
				; I avoid a segment override. 
  loop @Doagain                 ; Done??                      
							      
  mov  cx,bp                                                  
  inc  cx                                                     
  rep  stosb                    ; Do the last horizontal border
									     
  add  di,bp                    ; start to draw point bar for red worm
  mov  cl,dh                    ; dh is red's points          
  mov  al,31                    ; use a nice red shade        
  rep  stosb                    ; Draw it                     
									  
  mov  cl,dl                    ; dl is yellow's points       
  mov  al,42                    ; use a yellow shade          
  mov  di,63040                 ; screen offset                            
  rep  stosb                    ; Draw it
									     
;---------------------
; Worms initialization
;---------------------
  mov  di,player1start          ; Player 1 start offset is stored in di      
  mov  si,player2start          ; Player 2 start offset in si                
  mov  bx,player1left*256+player2right ; bh is used for the current          
				; direction for player 1                     
				; and bl is for player 2's direction         
  mov  cx,1020h                 ; Initialize worm start colors               
@MainLoop:                                                                   
;------------------------                                                    
; Do we have a collision?                                                    
;------------------------                                                    
  or   [byte ptr si],0          ; is player 2 on a pixel value other than 0? 
  jne  @collide                 ; Seems so                                   
  mov  [si],ch                  ; draw the worm's color to video ram (ds:si) 
  or   [byte ptr di],0          ; Check player 1                             
  je @nope                                                                   
  inc dh                        ; Give a point to player 2 - collision       
  mov cl,31                     ; cl (border color) will be red next time    
  jmp @waitloop                 ; wait for spacebar to be pressed            
@collide:                                                                    
  inc  dx                       ; same as 'inc dl' but shorter               
  mov  cl,42                    ; choose a new border color                  
@waitloop:                                                                   
  xor  ah,ah                                                                 
  int  16h                      ; use bios keyboard function                 
  cmp  al,32                    ; to wait for space                          
  jne  short @waitloop                                                       
  jmp  short @restartgame       ; yep - restart the game but keep points (dx)                   
@nope:                                                                       
;-----------------------                                                     
; Screen Synchronization                                                     
;-----------------------                                                     
  mov  [di],cl                  ; Since no collision - draw new worm head    
  pusha                                                                      
  mov  dx,3DAh                  ; Wait for a vertical retrace to happen      
@l1:                            ; This takes 13 bytes                        
  in   al,dx                    ; I could have used function nr. 86h         
  and  al,08h                   ; of interrupt 15h (casette) to do           
  jnz  @l1                      ; a delay - that would have taken just 9     
@l2:                            ; bytes - but there will be some jerky       
  in   al,dx                    ; movement once every 70th frame due         
  and  al,08h                   ; to non-synchronization with screen         
  jz   @l2                                                                   
  popa                                                                       
;------------------------
; Change worm color shade                                                    
;------------------------                                                    
  inc  cx                       ; This is 1 byte shorter than                
  inc  ch                       ; 'add cx,0101h'                             
  cmp  ch,32                    ; check for wraparound                       
  jb   @no                                                                   
  mov  cx,1020h                 ; wraparound to the start shades             
  @no:                                                                       
;---------------------                                                       
; Check worm direction                                                       
;---------------------
   call subproc                 ; Now that's a descriptive name!
   add  si,[word ptr bp+1]      ; Store red's direction
   xchg ah,al                                          
   call subproc                                        
   add  di,[word ptr bp+2]      ; Store yellow's direction
;------------------
; check for new key
;------------------
  mov  ah,1                     ; use bios
  int  16h                      ; to see if ANY key has been pressed
  jz   @mainloop                ; nope - continue the main loop
;--------------------------
; Pseudo-random star effect                        
;--------------------------             
  in   al,40h                   ; read LSB from timer chip (intel 8254)
  xchg al,ah                    ; store in ah
  in   al,40h                   ; read MSB from timer chip
  xchg ax,di                    ; use this value as a screen offset
  mov  [byte ptr di],15         ; place pixel (15 = white) on screen
  xchg ax,di                    ; get back old 'di' value 
;--------------------- 
; Effects of a new key
;---------------------  
  xor  ah,ah                    ; read the new key
  int  16h                      ; using bios
  mov  al,ah                    ; only needs the scan code in ah
  cmp  al,1                     ; check for escape (code 1)
  je   @quit                    ; quit game
  jb   @mainloop                ; Checks for ctrl-break (scancode 0)
  cmp  al,40                    ; check if it is player one or player two
  xchg ax,bx                    ; 'xchg' does not change flags - so it's ok
  jb   @gotplayer2keys          ; it's player 2 this time
@gotPlayer1Keys:                                                
  xchg ax,bx                    ;  bl = old player 2 dir
				;  bh = old player 1 dir                    
				;  al = ah = new dir                                                                                                    
@gotplayer2keys:                              
  xchg ah,bh                    ; exchange old and new direction
  jmp  short @mainloop          ; go back to the HUGE loop      
@Quit:                                                          
  mov  ax,3h                    ; Set textmode (80x25x16C)      
  int  10h                      ; using bios                    
;-------------------- 
; Keyboard Table Code
;--------------------
SubProc:                                                        
  mov  bp,(offset keys)-1       ; set bp to start of table (-1)    
 @siloop:                       ; since bp points to ss I can  
  inc  bp                       ; use bp to acces data in cs without                    
				; a segment override (ss=cs in com files)               
  cmp  bp,(offset keys)+13      ; check for end of table - only 4 byte
				; instruction - can't seem to get rid of it.
  jbe  @yep                     ; Not the end yet. 
  mov  bh,ah                    ; The key was not in the table, 
  jmp  SubProc                  ; so the key pressed is not valid and
 @yep:                          ; restore the old direction (in ah)
  cmp  [bp],bh                  ; checks with the new direction
  jne  @siloop                  ; not this table entry
  xchg bh,bl                    ; Found it!! - change worm direction
  ret                           ; Nice trick - this ret is used both to end 
				; the subroutine if we got there with a 'call'
				; else it is also used to quit back
				; to good old dos. 
						   
;--------------------------                        
; Data - the keyboard table                        
;--------------------------                        
 keys db  17,72,0C0h,0FEh       ; 0FE 0Ch  = -320 (signed word value)
      db  30,75,0FFh,0FFh       ;  FF FFh  = - 1 (signed word value)                   
      db  32,77,01h,00h         ; ctrl-break issues scancode 0
      db  31,80,40h,01h         ; so does alt keypad-3 (0140h = 320)
													
end                             ; That's all folks.
