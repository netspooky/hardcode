
				.model small,c

_screendata		segment public para 'FAR_DATA'
_screendata		ends


				locals

				public DrawText,PutBits

				extrn font:byte
				extrn bits_screen:byte
				extrn screen_seg:word

wd				equ 80

copyline		macro line

				mov ecx,[bx+8*line]
				or es:[di+wd*line],ecx
				mov ecx,[bx+8*line+4]
				or es:[di+wd*line+4],ecx

				endm


.code
.386

param1			equ [bp+4]
param2			equ [bp+6]
param3			equ [bp+8]

DrawText		proc near

				push bp
				mov bp,sp

				push si
				push di

				mov es,screen_seg

				mov dx,03ceh
				mov ax,01000000b*256+5
				out dx,ax

				xor ah,ah
@@1:
				mov dx,03ceh
				mov al,04h
				out dx,ax

				mov al,02h
				mov cl,ah
				mov ah,1
				shl ah,cl
				mov dx,03c4h
				out dx,ax
				mov ah,cl

				imul di,param2,wd
				add di,param1

				mov si,param3

@@next_char:
				mov bh,[si]
				inc si

				sub bh,1
				jc @@exit
				jz @@space

				xor bl,bl
				shl bh,2
				lea bx,[bx+offset font-1024]
				add bh,ah

				copyline 0
				copyline 1
				copyline 2
				copyline 3
				copyline 4
				copyline 5
				copyline 6
				copyline 7
				copyline 8
				copyline 9
				copyline 10
				copyline 11
				copyline 12
				copyline 13
				copyline 14
				copyline 15
				copyline 16
				copyline 17
				copyline 18
				copyline 19
				copyline 20
				copyline 21
				copyline 22
				copyline 23
				copyline 24
				copyline 25
				copyline 26
				copyline 27
				copyline 28
				copyline 29
				copyline 30
				copyline 31

@@space:
				add di,8
				jmp @@next_char

@@exit:
				inc ah
				cmp ah,4
				jb @@1

				pop di
				pop si

				pop bp

				ret


DrawText		endp


PutBits			proc near

				push ds
				push es
				push si
				push di

				mov es,screen_seg
				mov ax,_screendata
				mov ds,ax

				xor esi,esi
				mov si,offset bits_screen
				mov dx,03c4h
				mov ax,0102h
				cld

@@1:
				out dx,ax

				mov edi,(43+20)*80
				mov ecx,(320*200)/16
				rep movsd

				shl ah,1
				cmp ah,8
				jbe @@1

				pop di
				pop si
				pop es
				pop ds
				ret

PutBits			endp

				end



















