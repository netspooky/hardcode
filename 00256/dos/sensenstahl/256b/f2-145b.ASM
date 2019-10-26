;fire150b
;code: www.sensenstahl.com
;written for the A86
;based on fire154b.asm
;grabs timer only once per loop
;ugly quality compared to fire154b

;for any suggestions/tips to optimize the code feel
;free contact me: kontakt@sensenstahl.com

;thanks to Gaffer/prometheus and his 128 byte fire
;where i got the idea to use the code segment as variable

;history:
;150b 17.jan 10
;145b 17.jan 10 ; kicked generation of colors 193-255

data segment ;ds
;------daten----------
rval db ?    ;the red value
;---------------------

code segment ;cs
org 0100h

start: push 09000h    ;segment vscreen ;start+1 = 00h @ code to get initialization value for green
       pop ds
       push 0a000h    ;segment vga ;start+5 = 00h @ code to get initialization value for blue
       pop es

       mov al,13h     ;320*200*256 ;ax seems to be 0000h at the start of the program
       int 10h
       ;std ;set direction flag --> dec si/di at string operations --> 64000 down to 0 (size 1 byte)
            ;don't set it so inc di @ string operations

;-------create palette------------
            ;xor cx,cx       ;start at color 0; CX ALSO SEEMS TO BE ZERO AT THE START
looping03:  mov byte rval,cl;red 0-63 ;green+blue start with 00h taken from code segment
            call pal
            ;inc cx        ;is @ pal
            cmp cl,64      ;saves size instead of cmp cx,64
            jb  looping03  ;reached 64?

looping04:  ;mov al,cl      ;red to yellow/cl = 64 to 127; cut it out because of line below
            ;sub al,64      ;because value only 0-63 ; kinda strange that it works o_O
            mov byte cs:[offset start+1],cl ;set green value; values for red+blue come from above
            call pal       ;zu pal springen
            ;inc cx        ;is @ pal
            cmp cl,128
            jb  looping04  ;reached 128?

looping05:  ;mov al,cl      ;yellow to white/128-191; cut it out because of line below
            ;sub al,128     ;because value only 0-63 ; kinda strange that it works o_O
            mov byte cs:[offset start+5],cl ;set blue value; red+green come from above
            call pal
            ;inc cx        ;is @ pal
            cmp cl,192
            jb  looping05  ;reached 192?

;letting it out hasn't any bad effect
;looping06:  call pal ;red/green/blue are 63 done above
            ;inc cl   ;inc cl --> jnz possible ;is @ pal
            ;cmp cl,0 ;why?
;           jnz  looping06  ;reached 256?; cl ffh + 1 = cl 00h / ch 01h
;--------------------------------------------------

main:    mov di,320 ;old: mov dx,320 ; create 1 line per loop but draw 2 lines

lines:   in al,40h   ;random start; get value from timer port
         mul al      ;if result larger that ffffh then the higher word goes to dx =)
         mov ds:[di-320+63999-320], al ;old: mov ds:[di-320], al ;row before the last one
         mov ds:[di+63999-320], al     ;old: mov ds:[di], al ;last row
         dec di
         jnz lines          ;do until di=0

        ;it's on fire!
        ;xor di,di         ;0000h-1=ffffh; first line will be written to the bottom of vscreen; mov di,320 = +1 byte
                           ;di = zero at arrival at this point
f_loop: ;xor ax,ax        ;get rid of it and you will see higher flames and save 2 bytes
         mov al,ds:[di]    ;the current pixel
         adc al,ds:[di+1]  ;pixel right
         adc ah,0          ;add with carry; if carry flag is set then add 1 to ah
         adc al,ds:[di+320];pixel below
         adc ah,0
         adc al,ds:[di-1]  ;pixel left
         adc ah,0
         shr ax,2          ;div 4
         ;cmp ax,00h       ;why? not necessary
         jz f01            ;jump if ax=zero and don't do 0000h - 1 = ffffh
         dec ax
f01:     mov ds:[di-320-2],al;draw new pixel above the current one
         inc di
         ;cmp di,63681      ;down to the line before the last; 64000-320+1; +1 because of inc di before
         ;jb  f_loop        ;also works without cmp but di will rise up to 0FFFFh; overwrites something? o_O
         jnz  f_loop
         ;no more fire

         ;--- vscreen to vga -------
         mov cx,32000-1280 ;32000*word = 64000 bytes = 320*200 ;-1280 so don't draw the 2 randomlines
         ;xor di,di    ;start at zero; di will be increased @ movsw BUT CX IS THE ACTIVE COUNTER BECAUSE OF THE REP
                       ;because di=0 when arrival at this point
         xor si,si    ;to se same position at ds:si and es:di
         rep movsw    ;copy word from ds:si to es:di until cx=0 ist; the fast way
         ;-----------------------------------------------------------

         mov ah,01h            ;read keyboard
         int 16h               ;read, dammit!
         jz main                ;nothing so go on

         mov ax,03h             ;textmode 80*25
         int 10h
         ret                    ;back to last call (command.com)
                                ;3 bytes smaller than
                                ;mov ah,4Ch   ;DOS-program-termination
                                ;int 21h      ;terminate

;set palette
pal: mov dx,3c8h       ;port for vga palette
     mov al,cl         ;color number in cl; cl is unchanged by call
     out dx,al         ;send color number to port
     inc dx            ;go on because values will be written to port 3c9h
     mov al,byte rval
     out dx,al         ;write red value
     mov al,byte cs:[offset start+1]
     out dx,al         ;write green value
     mov al,byte cs:[offset start+5]
     out dx,al         ;write blue value
     inc cl            ;put it here to save some bytes @ the loops
     ret               ;back