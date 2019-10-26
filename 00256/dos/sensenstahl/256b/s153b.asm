;dos skull 162b
;code: www.sensenstahl.com
;written for the A86

;history:
;172b 12.sep 09
;166b 12.sep 09
;162b 12.sep 09
;153b 17.jan 10 ; - row/column into data segment
;            +
;00000000#########00000000
;0000#################0000
;0#######################0
;#########################
;####000000#####000000####
;0###00000###0###00000###0
;0##########000##########0
;##########00000##########
;###00###############00###
;0000#################0000
;0#00###0##0###0#00###00#0
;00#00##00#0#0###0###00#00
;000###################000
;00000###############00000
;00000000#########00000000

DATA SEGMENT

CODE SEGMENT
org 0100h
jmp start

l01 db 00000000xb ;row 0
l02 db 11111111xb
l03 db 00000001xb
l04 db 00000000xb
l05 db 00011110xb ;row 1
l06 db 11111111xb
l07 db 11110001xb
l08 db 00000000xb
l09 db 11111110xb ;row 2
l10 db 11111111xb
l11 db 11111111xb
l12 db 00000000xb
l13 db 11111111xb ;row 3
l14 db 11111111xb
l15 db 11111111xb
l16 db 00000001xb
l17 db 11100001xb ;row 4
l18 db 01111100xb
l19 db 00001110xb
l20 db 00000001xb
l21 db 11100000xb ;row 5
l22 db 11101110xb
l23 db 00001110xb
l24 db 00000000xb
l25 db 11111110xb ;row 6
l26 db 11000111xb
l27 db 11111111xb
l28 db 00000000xb
l29 db 11111111xb ;row 7
l30 db 10000011xb
l31 db 11111111xb
l32 db 00000001xb
l33 db 11001111xb ;row 8
l34 db 11111111xb
l35 db 11100111xb
l36 db 00000001xb
l37 db 00011110xb ;row 9
l38 db 11111111xb
l39 db 11110001xb
l40 db 00000000xb
l41 db 10011100xb ;row 10
l42 db 00111011xb
l43 db 01110010xb
l44 db 00000000xb
l45 db 01001100xb ;row 11
l46 db 10101110xb
l47 db 11100100xb
l48 db 00000000xb
l49 db 00111110xb ;row 12
l50 db 11111111xb
l51 db 11111001xb
l52 db 00000000xb
l53 db 00001110xb ;row 13
l54 db 11111111xb
l55 db 11100001xb
l56 db 00000000xb
l57 db 00000000xb ;row 14
l58 db 11111111xb
l59 db 00000001xb
l60 db 00000000xb

pos dw 0 ;for grabbing the right byte

bla1:  db '#$' ; access [l01+60]
bla2:  db ' $'

column db 0 ;= x position
row db 0  ;= y position

;  col 0    col 1   col 2    col 3    row

;00000000 ######## #0000000 00000000   0
;0000#### ######## #####000 00000000   1
;0####### ######## ######## 00000000   2
;######## ######## ######## #0000000   3
;####0000 00#####0 00000### #0000000   4
;0###0000 0###0### 00000### 00000000   5
;0####### ###000## ######## 00000000   6
;######## ##00000# ######## #0000000   7
;###00### ######## ####00## #0000000   8
;0000#### ######## #####000 00000000   9
;0#00###0 ##0###0# 00###00# 00000000  10
;00#00##0 0#0#0### 0###00#0 00000000  11
;000##### ######## ######00 00000000  12
;00000### ######## ####0000 00000000  13
;00000000 ######## #0000000 00000000  14


start:
;mov ax,0003h ;textmode 80*25 ;why??
;int 10h

weiter2:
;goto xy O_O
MOV AH,02H
MOV BH,00H
MOV DH,byte row ;y
MOV DL,00h      ;x
INT 10H

weiter:
mov cl,8 ;work for 8 bits ;1 byte smaller that mov cx,8
search:
mov di,pos

test byte [l01+di],1 ;check bit
jz gefunden ;took that way and not jnz ... whatever

mov dx,offset bla1 ;get right char
jmp nix_gefunden

gefunden:
mov dx,offset bla2 ;get right char

nix_gefunden:
mov ah,9
int 21h ;output char

rol byte [l01+di],1 ;(=

nicht_tiefer:
loop search ;search 1 byte finished

inc pos ;move a byte
inc column ;move a column
cmp column,4 ;reached end of row?
jne weiter ;don't move to next row!

mov column,0 ;start again
inc row ;move to next row!
cmp row, 15 ;finished drawing?
jne weiter2 ;not yet!


main:
            mov  ah,01h            ;get key (good to see something under windows)
            int  16h               ;GET IT!
            jz main                ;got no key :-(

            ;mov ax,03h             ;textmode ;but why?? it is dos, dammit!
            ;int 10h
            ret