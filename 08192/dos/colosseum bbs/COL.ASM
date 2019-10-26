                .286
                jumps
                locals

Code16          segment public use16
                assume cs:Code16, ds:Code16

include ansi.inc

Start:          mov     ax,cs
                mov     ds,ax

mov cs:ModSeg,Music
mov es,cs:[Modseg]

                call    InitPlayer
                call    SetInt

      mov ax,0003h
      int 10h                ; Clear screen and set to 80x25 mode

      mov si,offset BK
      mov ax,0B800h
      mov es,ax
mov es:[1],0

mov di,160*3
      mov cx,2000-140*8
      rep movsw

mov si,offset MSG+2
xor bl,bl
mov dx,3dah
@keyloop:
@l1: in al,dx
     test al,8
     jnz @l1
@l2: in al,dx
     test al,8
     jz @l2

      cmp si,offset MSG+MSGLen
      je @m

      cmp si,offset MSG
      jne @b2
@m:
      neg [add2si]
@b2:
      add si,[add2si]

      mov di,20*160
      mov cx,80
      rep movsw
      sub si,160

      in al,60h
      dec al
      jnz @keyloop            ; Check for ESC

      mov ax,0003h
      int 10h                 ; Clear screen etc

      mov dx,offset endwrit
      mov ah,09h
      int 21h                 ; Write crap at the end

        ; stop tune
                call    ResetInt
                call    EndPlayer
                mov     ax,4c00h
                int     21h


;께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께
; Enables and starts the player interrupt.
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
SetInt:
                cli
                xor     ax,ax
                mov     es,ax
                mov     ax,es:[8*4]
                mov     word ptr OldInt,ax
                mov     ax,es:2[8*4]
                mov     word ptr OldInt+2,ax
                mov     word ptr es:[8*4], offset PlayerInt
                mov     es:2[8*4],cs

                sti
                ret



;께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께
; Disables the player interrupt.
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
ResetInt:
                cli
                xor     ax,ax
                mov     es,ax
                mov     ax,word ptr OldInt
                mov     es:[8*4],ax
                mov     ax,word ptr OldInt+2
                mov     es:2[8*4],ax

                sti
                ret



;께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께
; The player interrupt.  Called 50 times a second.
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
PlayerInt:
                call PlayMusic
                jmp     cs:OldInt               ; call old interrupt handlers


                include Player.asm


OldInt          dd      ?
add2si  DW 2

Endwrit DB 'Code- Goblin/NiS^Xtatic',0dh,0ah
        DB 14,' Lib- Shayde/Reality',0dh,0ah
        DB 14,' - Unknown$'

include MSG.INC
MSGLen EQU 5*160-12
ends

Music           segment para public use16
                include smk.inc
                ends

Stack16         segment para public use16 stack
                dw      20h dup (?)
                ends

                end     Start
