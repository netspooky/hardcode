; coLorset1 intro (:

org 100h
mov  al,13h
int  10h
les  bp,[bx]
draw:mov al,[103h] ;al
aaa
adc ax, di
paint:
imul al
sbb ax,bx
stosb
dec dx
jnz draw
dec bx
jmp 101h
