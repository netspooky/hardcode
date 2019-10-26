; Apathy                          : 128-byte intro with sound (fasm 1.70.03/WinXP 5.1.2600)
; credit                          : olivier.poudade.free.fr 2013 aka baudsurfer
; credit                          : inspired by frag^fsqrt's cubeland (fsqrt.blogspot.com)
; greets                          : Adok, Frag, lordKelvin, Pirx, Rudi, sensenstahl, y0bi
; shouts                          : dark bit factory forum users (www.dbfinteractive.com) 
         org 100h                 ; start after psp
	 mov al,13h               ; fun change mode/mode chained 320x200x8
	 int 10h                  ; video bios api          
         les si,[bx]              ; es=09fffh si=020cdh
 	 mov dx,3c9h              ; vga dac data register
palette: shrd ax,cx,9             ; smooth grayscale scheme
         neg al                   ; invert gray gradient
	 out dx, al               ; red palette index value
         out dx, al               ; green palette index value
	 out dx, al               ; blue palette index value
 	 loop palette             ; assumed cx=ffh at start 
         mov dl,031h              ; mov dx,0331h=midi command port
         mov al,03fh              ; set midi mode status command (03fh=set UART mode on)
         out dx,al                ; output midi command                
         dec dx                   ; dx=midi data/status port 330h                                
         dec si                   ; opportunistic address
         mov dword [si],159a5bcah ; in little endian order ; cah=program change, 5bh=program number (ie:choir) 9ah=channel select (ie:11), 15h=note value (ie:A0)
         mov cl,7                 ; cl=length-1 of midi data message (nb : [si+5] note volume thus must >0)
         rep outsb                ; output data/status to midi ; nb: last 3 outs are opportunitic
allrays: push dx                  ; save midi status port
         mov si,320               ; absolute to ordinate divisor
raystart:mov cl,255	          ; cx goes from 255 (maximum viewing distance) to 1
rayscan: mov bl,cl	          ; bx=z (ie: distance)
	 not bl		          ; bx goes from 1 to 255
	 shr bl,1                 ; divide distance to get abscissas for [200;320] when inverting x and y coordinates 
	 sub bl,128               ; bl goes from -128 to 127
	 mov ax,di                ; ax is absolute screen coordinate
	 xor dx,dx                ; clear multiplication recipient
         div si                   ; divide by 320 to get abscissa ax=y, dx=x 
	 imul dx,bx	          ; dh=x*r/256
	 mul bl		          ; ah=y*r/256
         xchg dx,ax               ; invert x and y coordinates
	 add ax,bp                ; move camera horizontally
	 and ah,bl                ; y=ah, z=bl  (VARIATION COMMENT ME!)
         cmp di,256*100           ; which half of screen ?
         jc upper                 ; drawing lower half of screen !
         not ah                   ; inverse y value
	 and ah,dh                ; x=dh
         jmp lower                ; drawing lower half of screen ? 
upper:	 xor ah,dh                ; x=dh / drawing upper half of screen !
lower:	 and ah,64	          ; if x & y & z & 64 = 64 then plot offset is part of cube
	 loopz rayscan            ; loop until ray hit
	 mov ax,cx	          ; pixel color value=distance
         push di                  ; save plot offset before displacement
	 add di,256*100+16        ; compensate for 09fffh vs. 0a000h
	 stosb                    ; plot pixel
         pop di                   ; restore plot offset after displacement
	 inc di                   ; screen filled entirely ?
	 jnz raystart             ; if not continue plotting
         mov al,0eah              ; midi pitch bend command byte
         test byte [gs:46dh],1    ; test bios timer tick dword lsw
         jz moveleft              ; sign flag on half of the time
         neg si                   ; else move camera right 
moveleft:add bp,si                ; move camera left
         pop dx                   ; restore dx=330h midi status port
         out dx,ax                ; send status message to midi
         mov al,byte [es:35440]   ; get screen byte for pitch value
         out dx,al                ; output pitch value msb
         out dx,al                ; output pitch value lsb
         in ax,60h                ; get keyboard buffer status
	 dec ax                   ; test for escape key
	 jnz allrays              ; if not continue to next frame
         ret                      ; return to caller (opcode=0cfh)