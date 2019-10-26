proc	keanu_morf near
call clear_vscreen
mov  ax, [vscreen]
mov  es, ax
mov  ax, [fontpointer]
mov  fs, ax
call naamat
mov  di, 110*320+20
mov  al, 100
mov  si, offset morfeus
mov  dx,1
call drawText
mov  di, 110*320+200
mov  si, offset keanu
call DrawText
ret
endp

;IN:
;  ES=target segment
;  FS:BP=8x8 (bios) font
PROC			 update_matrix near
hchars	equ 27
vchars	equ 25
charw	equ 12
push ds
mov ax, [cs:mtvscreen]
mov ds, ax
mov ah,0

mov ecx,[cs:framecount]
push ecx
and ecx,7
mov ah,cl
shl cx,6
lea edi,[ecx*4+ecx+64000-320*10-8]
pop ecx
sub ecx,[cs:lastframe]
add ecx,[cs:tempframe]
mov [cs:tempframe],ecx
mov ch,cl
			mov bh,vchars
			@vvl:
				mov bl,hchars
				@hhl:
					push cx
					mov cx,128
					call random	; ---random
					pop cx
cmp ch,25
jbe @no_advance
					mov [dword tempframe],0
					inc [byte bx] ;advance character
@no_advance:
					mov al,[bx]
;scroll it ?
cmp ah,0
jne @not_today
					mov al,[bx-256]
					mov [bx],al
@not_today:
					cmp al,00h
					jne @skip_chrinit
;new character
					mov al,dl		; ---random
					add al,127
					mov [bx],al
@skip_chrinit:

shr dl,2
;print character
push bx
					mov  bx,ax							 ;ah=0
					mov  bh,0
					add  al,dl
					mov  dx,1
					call DrawChar
pop bx
					@skip_chr:
				sub di,charw
				dec bl
				jnz @hhl
		 sub di, 320-charw*hchars+7*320
		 dec bh
		 jnz @vvl
pop ds
	ret
endp


