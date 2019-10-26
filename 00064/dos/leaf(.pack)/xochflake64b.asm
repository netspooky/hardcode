les bx,[bx]
mov al,0x13
int 0x10
mov bh,0x80
mov ds,bx
S: 
sbb bx,dx		
adc dx,bx
	mov al,[fs:0x46c]
	push ax
	test al, byte 0x40
	jnz FF
	not al
	FF:
	and al, byte 0x3f
	sar bx,0x01	
	rcr bp,1
	jnc F
	adc bx,ax
	F:
imul di,dx,320
pop ax
sub al,bl
xor al,dl
and al,63
add al,32
G:
mov [bx+di+320*65+140],al
loop S
mov si,di
B:
movsb
mov [si-1],ah
loop B
jmp short S

