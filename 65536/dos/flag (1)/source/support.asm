;
;
; Support.asm
;


				.model small,c

				locals
				.data

screen_seg		dw 0a663h
other_seg		dw 0a000h

current_palette	dw 0

intmask			db ?

OKtoblank		db 0

pal_mod			db 0
pal_change		db 0


param1			equ [4+bp]
param2			equ [6+bp]
param3			equ [8+bp]
param4			equ [10+bp]

				.code

.386
				public SetTextMode,SwapScreens,screen_seg,BlankScreen
				public SetPalette,FadePalette,Sync
				public DemoInt
				public StartASM,EndASM
				public OKtoblank

				extrn SetInts:near,ClearInts:near,GetRasterLine:near

SetTextMode		proc near

				push bp

				mov ax,03h
				int 010h

				pop bp
				ret

SetTextMode		endp


SwapScreens		proc near

				push bp
				push si
				push di

@@1:
				call GetRasterLine

				cmp ax,25
				jb @@1

				cmp ax,390
				ja @@1

				mov bx,other_seg
				xchg screen_seg,bx
				mov other_seg,bx
				shl bx,4

				add bx,43*80 ;+10
				mov dx,03d4h
				mov al,0ch
				mov ah,bh

				cli

				out dx,ax

				inc al
				mov ah,bl
				out dx,ax

				sti

				or OKtoblank,1

				pop di
				pop si
				pop bp

				ret

SwapScreens		endp


BlankScreen		proc near

				test OKtoblank,128
				jnz @@1

				test OKtoblank,1
				jz @@1

				push eax
				push ecx
				push edx
				push edi
				push es

				mov dx,03c4h
				mov ax,0f02h
				out dx,ax

				mov ecx,(320*240)/16
				xor eax,eax
				mov edi,43*80
				mov es,screen_seg

				rep stosd

				mov OKtoblank,0

				pop es
				pop edi
				pop edx
				pop ecx
				pop eax
@@1:
				ret

BlankScreen		endp


SetPalette		proc near

				push bp
				mov bp,sp

				mov ax,param1
				mov current_palette,ax

				mov pal_change,1

				pop bp
				ret

SetPalette		endp


ChangePalette	proc near

				test pal_mod,-1
				jnz @@1

				test pal_change,-1
				jz @@1

				push ax
				push cx
				push dx
				push si

				mov si,current_palette
				mov dx,03c8h
				xor al,al
				out dx,al
				inc dx

				mov cx,256*3
				cld
				rep outsb

				mov pal_change,0

				pop si
				pop dx
				pop cx
				pop ax
@@1:
				ret

ChangePalette	endp


FadePalette		proc near

				push bp
				mov bp,sp

				push si
				push di

				mov si,param1
				mov di,param2

				mov cx,256*3

				mov pal_mod,1

@@1:
				mov al,[si]
				cmp al,[di]
				jz @@2
				inc byte ptr [si]
				jb @@2

				sub byte ptr [si],2
@@2:
				inc di
				inc si
				dec cx
				jnz @@1

				mov pal_mod,0

				pop di
				pop si

				pop bp

				ret

FadePalette		endp


Sync			proc near

				push ax
				push dx

				mov dx,03dah

@@1:
				in al,dx
				test al,8
				jnz @@1

@@2:
				in al,dx
				test al,8
				jz @@2

				pop dx
				pop ax

				ret

Sync			endp


StartASM		proc near

				push bp
				push si
				push di

				in al,021h
				mov intmask,al
				mov al,011111110b
				out 021h,al

				call SetInts

				pop di
				pop si
				pop bp

				ret

StartASM		endp


EndASM			proc near

				push bp
				push si
				push di

				mov al,intmask
				out 021h,al

				call ClearInts

				pop di
				pop si
				pop bp

				ret

EndASM			endp


DemoInt			proc near

				call ChangePalette
				call BlankScreen
				ret

DemoInt			endp


				end

