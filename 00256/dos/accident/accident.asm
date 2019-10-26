;'Accident' by dila@myrealbox.com

[org 100h]
[segment .text]

mov		al,13h
int		10h

printagain:

mov		ah,01h
int		16h
jnz		exitapp

mov 	ah,0Ch
mov		al,[cull]
mov  	bh,0
mov  	cx,[yval]
mov  	dx,[xval]
int  	10h

mov  	ah,0Ch
mov  	al,7
mov  	bh,0
mov  	cx,[xval]
mov  	dx,[yval]
int  	10h

inc 	byte [xval]
cmp 	byte [xval],200
jne 	printagain

mov		byte [xval],0
inc 	byte [yval]

cmp 	byte [yval],200
jne 	printagain

mov		dx,text
mov		ah,09h
int		21h

cmp 	byte [cull],2
je		changeone

changetwo:
mov 	byte [cull],2
jmp 	overother
changeone:
mov 	byte [cull],4
overother:

mov 	byte [yval],0
mov 	byte [xval],0

inc 	byte [round]
cmp 	byte [round],7
jne		printagain

mov		dx,about
mov		ah,09h
int		21h

keep:
mov		ah,01h
int		16h
jz		keep

exitapp:

ret

about db  10,13,"'Accident' by DiLA$"
text  db  10,13,10,13,10,13,10,13,10,13,10,13,10,13,10,13,10,13,10,13,10,13,10,13,10,13,10,13,10,13,10,13,10,13,10,13,10,13,10,13,10,13,10,13,10,13,10,13,10,13,10,13,10,13,10,13,"$"
round db 0
yval  db 0
xval  db 0
cull  db 2