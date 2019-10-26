;'Mickey' by dila@myrealbox.com

[org 100h]
[segment .text]

mov	al,12h
int	10h

mov	ax,01h
int	33h

mov     cx,350

loopline:

mov 	dx,newline
mov 	ah,09h
int	21h

cmp	cx,400
je	makeleft
cmp	cx,350
je	makeright
jmp	overall
makeright:
mov	byte [right],1
jmp	overall
makeleft:
mov	byte [right],0
overall:

cmp	byte [right],1
je	doright
sub	cx,10
jmp	doneit
doright:
add	cx,10
doneit:

mov	ax,04h
mov	dx,460
int	33h

mov	ah,01h
int	16h
jz	loopline

ret

newline  db  10,13,"                                          ...........$"
right    db  1