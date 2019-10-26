assume ds:code, cs:code, es:code
code segment use16
org 100h
start:

	;******************************TASMBOY'S 1KB TEXT ADVENTURE*****************************

	; Welcome to jailbreak. Try and escape from jail and return home safely.
	; In this code 's' stands for scene in labels
	; visit my site at http://www.pcsoftware.co.nz
	; Vote if you like this '1i1 01d sc001 adventure, thx :)
	; Sorry it's so short, but... pffft 1kb.. I rekon I did quite well for all that text
	; hi vulture!
	; and thanks to mcarp for helping with optimization on the story a bit
	; sorry this source might not assemble identicle to the .com (use tasm)
	; hello also to: Scali (who were you again?), Kalms (na you're just too good), SlasherX (keep learning :), |nsomniac (256b all the way), DAL9000 (you suck), Summer_ (can I be an op?), comrade (grr), disturb (me), ticker (tape), matja! (you=cool), _xor (mmm curry), exor674 (sup), hex86 (lets have a nightly compo man), kat (you should go out with _xor), and finally, everyone else in #asm who arn't idling bitches and I may have forgotten!
	; my entry rules! (I know, not really, vulture's is WAY better.)
	; now someone go win the prize I made: AVIMGen2: get the demo at my site - above
	; enjoy. mmm uranium...

	;actual game
s1:
	mov dx,offset msg1
	call write

	;test for keypresses
	call key
	cmp al,'1'
	je s1key1
	cmp al,'2'
	je s1key2

	jmp s1

s1key1:
	mov dx,offset msg4
	call write
	jmp s1

s1key2:
	;*next room - corridoor*
s2:
	mov dx,offset msg6
	call write

	call key
	cmp al,'1'
	je s2key1
	cmp al,'2'
	je s2key2
	
	jmp s2

s2key1:
	mov dx,offset msg8
	call write
	call key
	ret
	
s2key2:
	;**teleported to castle**
	mov dx,offset msg9
	call write
s3:
	mov dx,offset msg14
	call write

	call key
	cmp al,'1'
	je s3key1
	cmp al,'2'
	je s3key2

	jmp s3

	s3key1:
	;**through to LOBBY**
s4:
	mov dx,offset msg2
	call write

	call key
	cmp al,'1'
	je s4key1
	cmp al,'2'
	je s4key2

	jmp s4

s4key1:
	;**approach woman**
	mov al,[gotwaste]		;teleport if we have uranium, otherwise listen to woman
	dec al
	je dhs
	mov dx,offset msg10
	call write
	jmp s4
	dhs: jmp s7

s4key2:
	;**climb stairs**
s5:
	mov dx,offset msg3
	call write

	call key
	cmp al,'2'
	ja s5

s5key1or2:
	push ax
	mov dx,offset msg7
	call write
	pop ax
	cmp al,'2'
	jne s4
	mov al,1
	mov [gotwaste],al		;we got a key feature of the game
	jmp s4

s3key2:
	mov dx,offset msg12
	call write
	jmp s3

s7:
	;**teleport home - finish**
	mov dx,offset msg13
	call write
	call key
	ret

	;sorry this is so messily fucked up, even I can barely understand it
	jmp s3
eof:
	ret


	;***usefull functions I use frequently***;
	write:		;print text with dos, dx=pointer
	mov ah,9
	int 21h
	ret

	key:			;waits for keypress
	xor ax,ax
	int 16h
	ret

;text data with wrong names but in right order (I guess);

msg1   db  "JAIL. You see: crowbar, lockpick, iron window, locked door",10,13
       db  "Use crowbar on:",10,13
       db  "1 Window",10,13
       db  "2 Door",10,13
       db  "$"

msg4   db  "No effect.",10,13,"$"
msg6   db  10,13,"CORRIDOOR. You see: north & south doors",10,13
       db  "Go in door:",10,13
       db  "1 South",10,13
       db  "2 North",10,13
       db  "$"

msg8   db  "You get arrested by gaurds outside!",10,13
       db  "You live, but got 10 more years on your sentence",10,13,"$"

msg9   db  "You walk through the door and feel fuzzy.",10,13
       db  "You've been teleported!",10,13,10,13,"$"
msg14  db  "CASTLE. Puzzled, you see: door, moat",10,13
       db  "Walk to:",10,13
       db  "1 Door",10,13
       db  "2 Moat",10,13
       db  "$"

msg2   db  "The outer door says 'b w4r3'. You enter the lobby confused",10,13,10,13
       db  "LOBBY. You see: woman, stairs",10,13
       db  "Approach:",10,13
       db  "1 Lady",10,13
       db  "2 Stairs",10,13
       db  "$"

msg3   db  "You go up to a bedroom.",10,13,10,13
       db  "BEDROOM. You see: bed, uranium, mirror.",10,13
       db  "Pick up:",10,13
       db  "1 Sheet",10,13
       db  "2 Uranium",10,13
       db  "$"

msg7   db  "You grab it and return to the lobby.",10,13,"$"

msg10  db  "Woman: 'I need uranium to teleport you home'",10,13,"$"

msg12  db  "After skinny dipping a dingo steals your clothes.",10,13,10,13,"$"

msg13  db  "You warp back to your house and relax. You escaped!",10,13
       db  "The End. By TasmBoy$"

;*if they have the nuclear waste*
gotwaste db 0

code ends
end start
