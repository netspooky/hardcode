;- Dare thee to enter my realm ! - a 256 byte intro by Kuemmel for Revision 2017 demo party
;assembled with flat assembler 1.71.58
;DOSBox version, sound synced to 40000 cycles and vsync
org 100h
use16
push 08000h 			;double buffer second screen
pop ds
push 0a000h				
pop fs					;keep es unchanged for textplot							

mov al,13h									
cwd						;clear ah,dx
palette_loop:			;hellmood's palette generation hint including screen mode activation 320x200
add cl,2				;blue / sub cl,2 looks also interesting
int 10h					;init screen mode and change palette
mov ax,1010h
inc dh					;red		  ;green: ch is zero already
inc bl					;index, bx would be cheaper, but takes too long on XP and I need bh to be zero there
jnz palette_loop

push ax					;for sound

main_loop:

mov bp,devildude		;text plot pointer
mov ax,1300h			;al = attribute (cursor fix=0),  ah = 13h = write string
mov dx,(19+256*12)   	;dl = x,			         	 dh = y position of text
mov bl,63				;colour, bh is zero
mov cl,7				;cx = length of string, ch is zero
int 10h 				;plot string, attention: ES needs to be = CS ! ...so can't use ES elsewhere or save it

screen_loop:
mov ax,0xcccd			;rrrola's trick 
mul di					;=> dh = y | dl = x (range x = 0...255 ; y = 0...199)
sub dh,103
mov al,dl
sub al,127				;ax = ax - 127  => center
cbw
xor al,ah
sub al,ah				;127...0...128 => calc abs (okay...doesn't work for 255 as input...)
xor ah,ah				;clear ah
cmp dh,8
jle fortress
	div dh
	cmp al,0			;trigger 
	jg side
		xor al,dh		
		add ax,si		;movement
		and al,31
		sub al,15
		cbw
		xor al,ah
		sub al,ah		;15...0...16 => calc abs
		add al,32		;red palette part
		jmp plot
side:
	shl al,2			;some more stripes on the side...
	and al,31			;limit to blue palette part
fortress:
	shl al,1			;range extend...
	sub al,dh			;background upper level
	sub ax,si 			;movement
plot:
mov byte[ds:di],al
inc di
jnz screen_loop

mov dx,3dah				;flickers otherwise with the devil plot...
vsync:
 in al,dx
 test al,8
jz vsync

;tune
  mov dx,0x331	
  mov al,0x3F
  out dx,al				;change to UART mode
  dec dx				;dec to data address
  mov al,11000000b		;change instrument
  out dx,al
  mov al,19				;church organ
  out dx,al
  
  ;---music
  test si,11b			;trigger sound from counter
  jne dont_play
	mov al,10000000b	;note off from note before - otherwise organ doesn't stop
	out dx,al
	pop ax  			;get note from last one
	out dx,al
	mov al,0
	out dx,al
    mov al,10010000b	;note on
    out dx,al
	push si
	shr si,2			;take away trigger bits
	and si,111111b		;mask 64 notes
	mov al,byte[bp+si+7]
    pop si
	out dx,al		
	push ax				;backup for note off
    mov al,01111111b	;velocity max
    out dx,al
  dont_play:
  
copy_screen_loop:
  mov al,byte[ds:di]
  mov byte[fs:di],al
  inc di
jnz copy_screen_loop	;...didn't find a shorter version due to es usage for the text plot...:-(

inc si					;inc movement

;---check keyboard 
in al,0x60			  	;check for ESC
dec al
jnz main_loop
mov al,10000000b	  	;note off...could be same like above and use a 'call' but somehow XP didn't like it
out dx,al
pop ax  
out dx,al
mov al,0
out dx,al
ret

;Idea: loop a door opening, like 4 steps...no space for that =>
;door1: DB 219->   B1  177     -> B0   176 -> Dude
;door2: DB 219-> DD/DE 221/222 -> Dude     -> Dude
devildude   db 32,148,10,8,8,32,234
;tune = slightly modified extract from J.S.Bach – Toccata and Fugue in d minor
;could be encoded with 4 Bits as difference to former note
;...but overhead to decode those +/- offsets takes more space...
tune	    db 74,76,77,74, 76,77,79,76, 77,79,81,77, 79,81,82,79    
			db 81,77,79,76, 77,74,76,73, 74,69,70,67, 69,65,67,64 			
		    db 65,62,67,64, 65,62,64,61, 62,57,58,55, 57,53,55,52  
		    db 53,50,55,52, 53,50,52,49, 50,45,46,43, 45,41,43,40