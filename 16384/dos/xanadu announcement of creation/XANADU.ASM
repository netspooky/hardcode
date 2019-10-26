;  Xanadu announcement of creation
;
;  Coded by Jammerwokken in June 1994
;
;  DISCLAIMER: This code is distributed to help exchange information and ideas,
;       learn from it. If you use portions of this code in your own programs
;       then please credit me.

; Notes: Sorry this is so sloppy, it is a few routines stuck together. I
;        wrote most of it while half asleep.  Any comment, suggestions,
;        praise, flames, etc, concerning this code should be directed to
;        Jammerwokken at ind00246@pegasus.cc.ucf.edu. Thank you, and enjoy.

.MODEL Tiny

.STACK 10h

.DATA

COLOR_TABLE LABEL Byte
	include colors.inc

;Screen pic
  include XANA2.inc

;graphic pic
  include xanpic.inc

Misc_Port   EQU 03C2h
Sequ_Port   EQU 03C4h
CRTC_Port   EQU 03D4h
ISR1reg EQU 03DAh
PEL     EQU 03C8h

subval equ 80         ; Width of one scan line
addval equ 77         ; Width of one scan line - 3

screenlenb equ 8000   ; Screen length in bytes
screenlenw equ 4000   ; Screen length in words

Textpal DB 9,3,11,15,11,3

Message DB   10,13,"Announcing a new demogroup from the last place you'd expect - the USA!",10,13,10,13
		DB   "                       - X - A - N - A - D - U -",10,13,10,13
		DB   "Look for more releases by Xanadu in the near future!",10,13,10,13
		DB   "                                Members Are:",10,13
		DB   "    ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ",10,13
		DB   "Jammerwokken  ì  Coder, Graphician ì ind00246@pegasus.cc.ucf.edu",10,13
		DB   "Burnout       ì  Coder, Musician   ì rdeck@pegasus.cc.ucf.edu",10,13
		DB   "Maharet       ì  Music, Grfx, PR   ì ind00312@pegasus.cc.ucf.edu",10,13,"$"

.CODE

   ; Funky text thing
   mov ax, 0b800h           ; set es to text memory
   mov es, ax
   xor dl, dl
textloop:
   mov cx, 2000             ; 2000 chars on the screen
   xor bx, bx
innerloop:
   mov al, [es:bx]          ; read a char
   cmp al, 32               ; if its not a space...
   je  its_a_space
   inc al                   ;...then increment it
its_a_space:
   mov [es:bx],al           ; and write it back
   inc bx                   ; move to the next char
   inc bx                   ; and skip the attribute byte
   loop innerloop
   inc dl
   cmp dl, 0FEh             ; do this over again 254 times
   jne textloop



   ; Display image
   mov ax, @data
   mov ds, ax
   mov si, OFFSET XANADU
   mov ax, 0B800h
   mov es, ax
   xor di, di
   mov cx, 2000
   rep movsw                   ; Copy the ANSI pic directly to screen mem

   xor bx, bx
   xor di, di
   xor cx, cx
   mov ax, @data
   mov ds, ax
   mov si, offset COLOR_TABLE

   cli                         ; Turn off all ints but the KBD
   in  al, 21h
   push ax
   or al, 11111101b
   out 21h, al
   cli
start:
   MOV DX, ISR1reg
wait_HRT:                    ; Wait for the beggining of the next scan line
   in al, dx
   test al, 1
   jz wait_HRT
   test al, 8
   jz   NOVrt
VRT:
   in al, dx                      ; In a retrace
   test al, 8                     ; reset pointer to the color table
   jnz VRT
   mov bx, cx
   mov di, 1134
   sub di, cx
   add cx, 9
   cmp cx, 1134
   jb NoVrt
   xor cx, cx
NoVrt:
   mov dx, PEL                    ; Now we are at the beggining of a scan line
   xor al, al                     ; so set the background color to one from
   out dx, al                     ; the color table

   inc dx
   mov al, [si + bx]
   out dx, al
   mov al, [si + bx + 1]
   out dx, al
   mov al, [si + bx + 2]
   out dx, al

   xchg di, bx
   mov al, [si + bx + 2]         ; and set color 1 (was DARKBLUE) to
   out dx, al                    ; one from the color table using the other
   mov al, [si + bx + 1]         ; counter (counts backward) so this color
   out dx, al                    ; gets an upside down copy of the
   mov al, [si + bx]             ; background color. I also send the color
   out dx, al                    ; as B G R instead of R G B so it will be
   xchg di, bx                   ; a different color

   inc bx                        ; increment the color 0 counter (once for
   inc bx                        ; each RGB byte)
   inc bx
   dec di                        ; and decrement the color count the same way
   dec di
   dec di

   in  al, 60h                   ; Check for a space bar
   cmp al, 57
   je  quit                      ; if so, quit

   cmp bx, 1134                  ; check to see if we are at the end of the
   jb start                      ; color table
   xor bx,bx                     ; and if so, wrap around
   mov di, 1134                  ; and reset the backwards counter
   jmp start                     ; and do it all over again
quit:
   mov dx, PEL                   ; Restore colors 0 and 1 to what
   xor al, al                    ; they should be
   out dx, al
   inc dx
   out dx, al
   out dx, al
   out dx, al
   out dx, al
   out dx, al
   mov al, 32
   out dx, al

; Plasma part
;
; This plasma is a simple cellular automaton. Each pixel is the average of all
; its neigbors, plus a value.

		CLD
		mov ax, 0013h              ; turn on mode 13h
		int 10h


; This next chunk of code turn on an unchained 80x100 mode, and is basically
; straight from Iguana's fire demo. Thanks, Iguana!

		CLI
		MOV     DX,Sequ_Port
		MOV     AX,0604h
		OUT     DX,AX
		MOV     AX,0F02h               ;All planes
		OUT     DX,AX

		MOV     DX,CRTC_Port
		MOV     AX,0014h               ; Disable dword mode
		OUT     DX,AX
		MOV     AX,0E317h               ; Enable byte mode.
		OUT     DX,AX
		MOV     AL,9
		OUT     DX,AL
		INC     DX
		IN      AL,DX
		AND     AL,0E0h                 ; Duplicate each scan 4 times.
		ADD     AL,3
		OUT     DX,AL
		STI


; Set up the palette
		mov dx, PEL
		xor al, al                      ; Start with color 0
		out dx, al
		inc dx
		xor cx, cx
colorloop1:                             ; Set the first 32 colors
		mov al, cl
		out dx, al
		out dx, al
	   xor al, al
		out dx, al
		inc cx
		cmp cx, 32
		ja  colorloop1
		mov cx, 33
colorloop2:                             ; Set colors 32-64
		mov al, cl
		out dx, al
		out dx, al
		xor al, al
		out dx, al
		loop colorloop2



   ; Display image
   mov ax, @data
   mov ds, ax
   mov si, OFFSET XANPIC
   mov ax, 0a000h
   mov es, ax
   xor di, di
   mov cx, screenlenw
   rep movsw                            ; Dumps the image to graphic memory

wait_fer_key_release:                   ; Um, waits for the space bar to be
		 in al, 60h                     ; released.
		 cmp al, 185
		 jne wait_fer_key_release

check_space:                            ; and waits for it to be pressed
		in al, 60h                      ; again, while the user admires
		cmp  al, 57                     ; my beautiful Xanadu picture!
		jne check_space

		mov ax, 9000h
		mov ds, ax

pstart:
	  mov cx, screenlenb
	  xor ax, ax
theloop:
	  mov bx, cx
	  sub bx, subval
	  mov al, [es:bx]                    ; Get the above left pixel
	  inc bx
	  mov dl, [es:bx]                    ; add the above center
	  add al, dl
	 inc bx
	  mov dl, [es:bx]                    ; the above right
	  add al, dl

	  add bx, addval                     ; move to the next line
	  inc bx
	  mov dl, [es:bx]                    ; add the left pixel
	  add al, dl
	  inc bx
	  mov dl, [es:bx]                    ; add the origin pixel
	  add al, dl

	  add bx, addval
	  inc bx
	  mov dl, [es:bx]                    ; and so on...
	  add al, dl
	  inc bx
	  mov dl, [es:bx]
	  add al, dl

	  mov bx, cx
	  add ax, 44                         ; Add the magic number. This was
	  shr ax, 3                          ; trial and error for like an
	  mov [ds:bx], al                    ; hour. Why 44? I dunno!
	  loop theloop


	   mov dx, 03DAh   ; Wait for a retrace
pVRT:   in  al,dx
	   and al,8
	   jnz pVRT
	   mov dx, 03DAh
pNoVRT: in al,dx
	   and al,8
	   jz pNoVRT


	  xor di, di          ; Flip
	  xor si, si
	  mov cx,screenlenw
	  rep movsw

	  in al, 60h          ;Check for ESC
	  cmp al, 1
	  je pquit

	  jmp pstart

pquit:
   cli                    ; Restore the interrupts
   pop ax
   out 21h, ax
   sti

   ; Go back to text mode
   mov ax, 0003
   int 10h


   mov ax, @data
   mov ds, ax
   ; Display message
   mov DX, offset Message
   mov ah, 09h
   int 21h
   ; Fill the screen with cool colors
   mov cx, 1960
   xor dx, dx
   mov ax, 0B800h
   mov es, ax
   xor al, al
textfill:
   inc dx
   cmp dx, 6
   jne dont_zero
   xor dx, dx
dont_zero:
   mov bx, offset Textpal
   add bx, dx
   mov ah, [bx]
   mov bx, cx
   mov al, [es:bx]
   mov [es:bx],ax
   dec cx
   loop textfill

   ; Get back to DOS
   mov ax, 4C00h
   int 21h

END              ; Thats all, folks!
