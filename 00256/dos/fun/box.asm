org	100h
use16

%define RED 0x27
%define YELLOW 0x0E
%define BLUE 0x0B
%define DBLUE 127
%define BOX_SEPARATOR (10)
%define BOX_WIDTH (75)
%define BOX_HEIGHT (180)
%define LETTER_WIDTH (BOX_WIDTH - (3 * BOX_SEPARATOR))
%define BOX_X ((320 - (2 * BOX_SEPARATOR + 3 * BOX_WIDTH)) / 2)
%define BOX_Y ((200 - (BOX_HEIGHT)) / 2)
%define Y(v) ((v * 0x14) + 0xA000)
%define X(v) (v + 0)
%define STEP 7
%define KEY_ESC 0x1b 

; vga 320x200x256
setvgamode:
	mov ax,0x0013
	int 10h 
	
main:

	mov cx, 12
	call_box:
		push cx
		call box
		pop cx
		loop call_box
	
	mov cx, 12
	xor si, si
	calc_color:		
		mov byte al, [color0+si]
		add al, 11
		mov byte [color0+si], al
		add si, STEP
		loop calc_color
	mov byte [current_box],0
; wait for key
	mov ah, 0x00
	int 16h
	sub al, KEY_ESC
	jnz main
	jmp exit
	
box:
	; es = (320 * y) + 0xA000
	mov si, [current_box]
	mov eax, [y0+si]
	mov es, eax
	
	mov cl, [h0+si]	
	mov dl, [color0+si]
	box_loop_y:		
		mov di, [x0+si]
		mov bl, [w0+si]
		box_loop_x:
			; *(es + di) = 0x0E			
			mov [es:di], dl
			inc di
			dec bl
			jnz box_loop_x
		add eax, 0x14
		mov es, eax
		dec cl
		jnz box_loop_y
	add si, STEP
	mov [current_box], si
	ret
exit:
	; text mode
	mov ax,0x03
	int 0x10
	; return to dos
	int	20h
current_box: dw 0
; variables
x0: dw X(BOX_X)
y0: dw Y(BOX_Y)
w0: db BOX_WIDTH
h0: db BOX_HEIGHT
color0: db YELLOW

x1: dw X(BOX_X + BOX_WIDTH + BOX_SEPARATOR)
y1: dw Y(BOX_Y)
w1: db BOX_WIDTH
h1: db BOX_HEIGHT
color1: db BLUE

x2: dw X(BOX_X + BOX_WIDTH + BOX_SEPARATOR+ BOX_WIDTH + BOX_SEPARATOR)
y2: dw Y(BOX_Y)
w2: db BOX_WIDTH
h2: db BOX_HEIGHT
color2: db RED

x3: dw X(BOX_X + BOX_SEPARATOR)
y3: dw Y(105)
w3: db BOX_SEPARATOR
h3: db BOX_WIDTH
color3: db DBLUE

x4: dw X(BOX_X + BOX_WIDTH + BOX_SEPARATOR + BOX_SEPARATOR)
y4: dw Y(105)
w4: db BOX_SEPARATOR
h4: db BOX_WIDTH
color4: db DBLUE

x5: dw X(BOX_X + BOX_WIDTH + BOX_SEPARATOR + BOX_SEPARATOR + LETTER_WIDTH)
y5: dw Y(105)
w5: db BOX_SEPARATOR
h5: db BOX_WIDTH
color5: db DBLUE

x6: dw X(BOX_X + BOX_WIDTH + BOX_SEPARATOR + BOX_WIDTH + BOX_SEPARATOR + BOX_SEPARATOR)
y6: dw Y(105)
w6: db BOX_SEPARATOR
h6: db BOX_WIDTH
color6: db DBLUE

x7: dw X(BOX_X + BOX_WIDTH + BOX_SEPARATOR + BOX_WIDTH + BOX_SEPARATOR + BOX_SEPARATOR + LETTER_WIDTH)
y7: dw Y(105)
w7: db BOX_SEPARATOR
h7: db BOX_WIDTH
color7: db DBLUE

x8: dw X(BOX_X + BOX_SEPARATOR)
y8: dw (Y(135))
w8: db (LETTER_WIDTH + BOX_SEPARATOR)
h8: db BOX_SEPARATOR
color8: db DBLUE

x9: dw X(BOX_X + BOX_WIDTH + BOX_SEPARATOR + BOX_WIDTH + BOX_SEPARATOR + BOX_SEPARATOR)
y9: dw (Y(105))
w9: db (LETTER_WIDTH + BOX_SEPARATOR)
h9: db BOX_SEPARATOR
color9: db DBLUE

x10: dw X(BOX_X + BOX_SEPARATOR)
y10: dw (Y(105))
w10: db (LETTER_WIDTH + BOX_SEPARATOR)
h10: db BOX_SEPARATOR
color10: db DBLUE

x11: dw X(BOX_X + BOX_WIDTH + BOX_SEPARATOR + BOX_SEPARATOR)
y11: dw (Y(170))
w11: db (LETTER_WIDTH + BOX_SEPARATOR)
h11: db BOX_SEPARATOR
color11: db DBLUE