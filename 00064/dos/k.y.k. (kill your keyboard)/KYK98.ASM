IDEAL
P386
MODEL Tiny
CODESEG
ORG  100h
Start:
mov  AL,13h
int  10h
push 0a7bch
pop  ES
Lop:
mov  AL,[fs:417h]
push AX
xor  AX,CX
pop  CX
shr  AL,1
jz   Loc1
stosb
Loc1:
jnc  Loc2
inc  BX
Loc2:
mov  [Byte Ptr ES:BX],04h
mov  AL,[ES:13fh]
or   AX,AX
jz   Lop
ret
END Start
