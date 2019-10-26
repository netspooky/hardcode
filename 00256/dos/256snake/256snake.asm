; hello crazy people!!!!
;
; I decided to release my asm source too
; it went through thousands of changes until 
; I managed to get it into this state
;
; I'm quite sure this can be even more optimised
; since I'm not that experienced with writing x86
; code.
;
; compile it with nasm...
;
; originally I had a vga tweak that increases row
; height, that saved me several bytes and hundreds
; of cycles. But dosbox didn't like my tweak and I
; decided that it's better if it's more compatible.
;
; have fun!
;
; muuuuuuuuuuuuuuuuuuuuuusk/brs
; 

code 	equ 100h
data 	equ code+180h
vseg 	equ 0a000h+320*20/16

;variables

foodseed 	equ data + 0h
level 		equ data + 10h

;constants

delay_count 	equ 5

pixel_width		equ 10
pixel_height	equ 10

level_width_ln	equ 5
level_height_ln equ 4
level_width	    equ 32 ;2^level_width_ln
level_height 	equ 16 ;2^level_height_ln

col_b 	equ 200;200
col_f	equ 35+24;35+24
col_s	equ 32+24+8;32+24+8

CRTC_INDEX 	equ 3d4h
SEQUENCER 	equ	3c4h
MAX_SCAN_LINE equ 9

food_strength 	equ 1;

org 100h

start:
	;assuming ax == 0
	mov ch,10h	
	mov di,end_of_code
	rep stosb 
	
	push vseg
	pop es
	mov al,13h
	int 10h
	
	push 010000000010b
	;mov si,010000000010b
	mov bp,010000100000b
	mov dx,8
	
main:
	;ch == 0
	mov cl,level_height
	;mov cx,level_height
	
	;ch == 0
	xor ax,ax
	push ax
	push ax
	pop si
	pop di
	
	mov bx,level
lvlly:
	push cx
	;ch == 0
	mov cl,level_width
lvllx:
	push cx
	
	xor cx,cx
	mov ax,[bx+si] ;load cell

	mov cl,al;
	and cl,7
	cmp cl,3
	jna scf1
	mov ch,7
	sub ch,cl
	xchg ch,cl
scf1:
	add cl,col_s;32+24+8

	;cmp ax,0
	dec ax
	jns notnull
	
	;xor ax,ax ;opt
	mov cl,col_b;;200
	jmp null
notnull:
	;dec ax
	mov [bx+si],ax
null:
	;mov ax,bp;
	;add ax,level;
	;cmp bx,ax
	cmp bp,si
	jne nevermind
	;mov cl,35
	mov cl,col_f;35+24;
nevermind:
	;inc bx
	;inc bx
	lodsw ;si+=2
	
	mov al,cl
	
	mov cx,pixel_height
pxheightl: ;draw rectanlge basically
	push cx
	
	mov cx,pixel_width
	rep stosb
	
	add di,320-pixel_width
	
	pop cx
	loop pxheightl ;end draw rectangle
	
	sub di,320*pixel_height -pixel_width ;adjust adress to next rectangle
	
	pop cx
	loop lvllx ;process next cx columns
	
	add di,320*pixel_height - level_width*pixel_width ;adjust adress to next line of rectangles
	add si,100000b*2 ;adjust data source
	
	pop cx
	loop lvlly ;process next cx rows

		mov cx,delay_count
	dloop:
		push dx
		mov dx,03DAh
	pmw1:
		;add word [foodseed],31337 ;random
		add word [foodseed],si
        in al,dx;
        and al,8
        jnz pmw1
		
		;call snds_end ;stop the sound
		  
    pmw2:
        in al,dx
        and al,8
        jz pmw2
		
		pop dx
       ; loop delayl

        in al,60h
        ;cmp al,vk_escape
		dec al
        jz exit
		mov bh,al
		
		;mov bx,snakedir;
		
		push cx
		mov cx,4
		
		mov si,in_data
	in_loop:
		lodsb
		mov bl,al
		lodsw
		cmp bl,bh
		jne next
		mov [snakedir],ax
		next:
		loop in_loop
		
		pop cx
	 pmgo:
		;call snd_off
		loop dloop
		
		pop si ;snake position
		;step the snaek
		add si,[snakedir] 
		and si,011110111110b 
		push si ;save snake pos to stack

        ;mov [snakepos],ax
		;call vaxtoaddr
       		
		call snds_fx0 ;play sound
		mov bx,level
		mov ax,[bx+si]
		cmp ax,0
		
		jne exit
		;jne exit
		;jne exit
		
        ;mov ax,[snakesize]
        mov [bx+si],dx
		cmp si,bp
		jne noeat
		;add ax,food_strength
		;add word [ssize],byte food_strength ;make snake longer
		
		;add word[snakesize],food_strength
		inc dx
		
		mov bp,[foodseed]
		and bp,011110111110b
		;mov word [food pos],ax;
		
		call snds_fx1 ;play sound
	noeat:

        jmp main
exit:
	;call snd_off
	;call 0
	pop si
	call snd_off
    ret
	;	mov ax,[bx+1]
	;	mov ax,[1]

snds_fx0:
	mov ax,si
	add ah,al
	xor ah,01101001b
	jmp snds_end
snds_fx1:
	mov ax,bp
	mov ah,06h
snds_end:
	out 42h,al
	xchg al,ah
	out 42h,al
snd_on:
	mov al,33h
	jmp snd_off_2
snd_off:
	mov al,30h
snd_off_2:
	out 61h,al
	ret

vk_left         equ     75 ;
vk_right        equ     77 ;
vk_up           equ     72 ;
vk_down         equ     80 ;
vk_escape       equ     1
		
in_data:
db vk_left-1
dw 0111110b
db vk_right-1
dw 010b
db vk_up-1
dw 011110000000b
db vk_down-1
dw 010000000b
	
snakedir: db 2
end_of_code:
;snakesize: dw 8
;foodpos: dw 0000010000100000b;level+ (level_width*level_height+level_width/2)&0xfffe
;snakepos: dw 0000010000000010b;level + level_width*level_height
		;mov byte [snakedir],2
		;mov byte [snakesize],8
        ;mov word [foodpos],level+ 2 + level_width*2;
        ;mov word [snakepos],level + level_width*level_height
		
