;Wave by dila@myrealbox.com

[org 100h]
[segment .text]

mov	al,13h
int	10h

printspace:
mov	dx,space
mov	ah,09h
int	21h

mov	ah,01h
int	16h
jnz	thend

inc	byte [printed]
mov	al,byte [printed]
cmp	byte [toprint],al
jne	printspace

mov	byte [printed],0

mov	dx,char
mov	ah,09h
int	21h

inc	byte [visible]

cmp	byte [visible],2
jne	printspace

mov	byte [visible],0

cmp	byte [counter],18
jne	noswitchtoinc
mov	byte [catch],1
noswitchtoinc:

cmp	byte [counter],12
jne	noswitchtodec
mov	byte [catch],0
noswitchtodec:

cmp	byte [catch],0
jne	noinc
inc	byte [counter]
inc	byte [toprint]
jmp	overdec
noinc:
dec	byte [counter]
dec	byte [toprint]
overdec:

inc	byte [loops]
cmp	byte [loops],100
jne	printspace

mov	dx,rain
mov	ah,09h
int	21h

more:
mov	ah,01h
int	16h
jnz	thend
jmp	more

thend:

ret

char     db  "(    )",10,13,"$"
rain     db  "'Wave' by DiLA                  (    )$"
space    db  " $"
printed  db 10
toprint  db 16
visible  db 0
catch    db 0
counter  db 0
loops    db 0