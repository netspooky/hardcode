        .286
        .Model small
.data
db 13, 10
db "*-----------------------------------------------------------------*", 13, 10
db "|Tittle: Interference Plasma                                      |", 13, 10
db "|Author: Heikki Vesalainen (wes/ Appellssiini)                    |", 13, 10
db "|Original release date: 15th may 1994                             |", 13, 10
db "|                                                                 |", 13, 10
db "|  This is greet-ware! You must send me greetings and credit me   |", 13, 10
db "| if you use this effect (or a similar one) in your production(s).|", 13, 10
db "*-----------------------------------------------------------------*", 13, 10
db 13, 10

sarkas  dw      ?                       ;Sarkas is a counter.
x       dw      ?                       ;This also
y       dw      ?                       ;And this.
timecounter db  0
plac    equ     148
adder   equ     30
adder2  equ     0

include hsini.dat                       ;A large sin table
include pal.asm                         ;a palette
include setpal.inc
include ansi.asm
include kone.asm
include fadeall.inc
                  
.code

start:
      mov       ax, 0100h
      mov       cx, 0ff01h
      int       10h

      fadeall   63, 63, 63, 1, 63
      fadeall   0,0,0,1,63

      mov       ax, 0003h
      int       10h
      mov       ax, 0100h
      mov       cx, 0ff01h
      int       10h

      mov       ax, @data
      mov       ds, ax
      mov       si, offset ansi
      mov       ax, 0b800h
      mov       es, ax
      mov       di, 0
      mov       cx, 80*14
      rep       movsw

      mov       cx, 0100
looppi:
      mov       dx, 3dah
  waitvrc5:
      in        al, dx
      test      al, 8
      jnz       waitvrc5
  waitvrc2:
      in        al, dx
      test      al, 8
      jz        waitvrc2
      loop      looppi

      fadeall   0,0,0,1,63

      mov       ax, 0003
      int       10h
      mov       ax, 0100h
      mov       cx, 0ff01h
      int       10h   

      mov       cx, 020
looppi2:
      mov       dx, 3dah
  waitvrc3:
      in        al, dx
      test      al, 8
      jnz       waitvrc3
  waitvrc4:
      in        al, dx
      test      al, 8
      jz        waitvrc4
      loop      looppi2

      mov       si, offset kone
      mov       ax, 0b800h
      mov       es, ax
      mov       cx, 80*9-40
      mov       di, 0
      rep       movsw

      fadeall   63,63,63,1,63

      mov       ax, 0013h               ;Video mode 13h
      int       10h
      
      setpal    256*3, palette          ;set the palette of 3*256 values

      mov       sarkas, plac            ;The starting plase, try changing

      mov       ax, @data               ;Set ds to data
      mov       ds, ax

      mov       ax, 0a000h              ;Set es to video
      mov       es, ax

framejump:

      xor       di, di                  ;first pixel

      mov       si, 200                 ;n:o rows

      inc       sarkas                  ;Next sarkas value
      mov       bx, sarkas

      mov       dl, sin[bx]             ;This changes ones in a frame

      cmp       sarkas, 359             ;Check for the boundary of sarkas
      jna       nextis                  ;if sarkas > 359, then
      mov       sarkas, 0               ;sarkas = 0
nextis:
      cmp       timecounter, 4
      jnz       nextis2
      jmp       dos
nextis2:
      cmp       sarkas, plac - 1
      jnz       rowjump
      inc       timecounter
rowjump:
      mov       cx, 320                 ;pixels / row

      mov       bx, sarkas
      mov       ah, sin[si+adder2]      ;These change ones every row
      mov       dh, sin[bx+si+adder2]
      
        pixeljump:

        mov       bx, cx
        mov       al, sin[bx+adder]       ;These change for every pixel
        add       bx, sarkas
        add       al, sin[bx+adder]

        add       al, ah
        xor       al, dh                  ;This is it! XOR or OR
        sub       al, dl

        mov       byte ptr es:[di], al

        inc       di                      ;next pixel

        dec       cx
        jnz       pixeljump

      in        al, 60h                 ;esc?
      cmp       al, 1
      jz        dos

      dec       si                      ;next row
      jnz       rowjump

      jmp       framejump

dos:
      fadeall  0,0,0,1,63
                         
      mov       ax, 0003h               ;Normal Video
      int       10h
      push      cs
      pop       ds
      mov       dx, offset c
      mov       ah, 9
      int       21h

      xor       al, al                  ;Flush the Keyboard buffer
      mov       ah, 0Ch
      int       21h

      
      mov       ax, 4c00h               ;And out!
      int       21h

c       db      13,10
        db      "                  This was a interference sini-plasma for the", 13, 10
        db      "                          Assembly '94  4k intro compo", 13, 10
        db      13, 10
        db      "                                  Greetings to:       ", 13, 10
        db      13,10
        db      "                                      Wolf              ", 13, 10
        db      "                                      Kari              ", 13, 10
        db      "                                     Moody              ", 13, 10
        db      "                                     Lurppa             ", 13, 10
        db      "                                    Old Wolf            ", 13, 10
        db      "                                    Old Hair            ", 13, 10
        db      "                                  Orange dudes         ", 13, 10
        db      "                                 Bonk Businesses        ", 13, 10
        db      "                                Hot House studios       ", 13, 10
        db      "                            Metropoli/starport users    ", 13, 10
        db      "                           KoNE  ihmiset ovat yst„vi„   ", 13, 10
        db      "           MEGA GREETS to Distance for letting me use his computer!", 13, 10
        db      "                                      and               ", 13, 10
        db      "                            Everyone at Assembly '94    ", 13, 10
        db      13, 10
        db      " Code, ansis and effect by wes/Appellssiini", 13, 10
        db      " Email: wes@pcb.mpoli.fi, ", "$"

  .stack


      END       start



