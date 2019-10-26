;АБЮ═╜╜╝ Ц ╛╔╜О ГЦ╒АБ╒╝ ГБ╝ ё╓╔Б╝ О ╒╗╓╔╚ МБ╝Б МДД╔╙Б
.486p ;                                         з©
; by Zen  from Vladivostok      дрдддрддд©     зыю©   зд© з©    з© з©   з©
;Sorry its only ugly effect      ╨   ╨мммоямммяоммоямяомомоояяяяоьяоомяяооя
; i use it to generate texture       ╨    юддды    юды      юыюы юы   юы  юд
; zen333@rambler.ru                                   з©
; look at :                                 д©       зыю©   з©       з©  з©
; fan333.chat.ru                             ткмяямяяоммомяяоояямммяяоояяоомм
; for more my releases in 256b and smaller    ╨ цы юы     юы  юы   юы  юы
seg_a           segment public byte use16
                assume  cs:seg_a
                org     100h

rad             proc    far
start:
                les     bp,[bx]
                mov     al,13h   ;vga_init
                int     10h                ;
            push 06000h
            pop ds
        mov dx,3C9h
        mov cl,64
pal:
        xor al,al
;        shr al,cl
        out dx,al
        sub al,cl
        out dx,al
        out dx,al
        loop pal

loc_1:       ;╜═Г═╚╝ ╝║И╔ё╝ Ф╗╙╚═
hlt                           ;time waiting
smoot:
mov di,cx
mov al,ds:[di+1]
add al,ds:[di-320]
add al,ds:[di+320]
add al,ds:[di-1]
inc al
shr al,2
inc al
mov ds:[di],al
stosb ;to screen
loop smoot

loc_5:          in      al,60h                  ; port 60h, keybd scan or sw1
                dec     al
                jnz  short loc_1
exit:
                mov     al,3
                 int     10h
                  retn
rad             endp
seg_a           ends
                end     start





