; Interrupt routines....

				extrn DGROUP@:word

				.model small,c
				locals

				extrn DemoInt:near
				extrn Sync:near

				public SetInts,ClearInts,GetRasterLine
				public FrameNum
.data
				align 2

FrameNum		dd 0

.code
.386

frametimeb		dw ?
frametime		dw ?

in_int			db 0

oldint8			dd	?

INTER			equ	8

intti8 			proc far

				push ax
				push ds

				mov ds,cs:DGROUP@

				inc FrameNum

				mov al,20h
				out 20h,al
				call Sync

				mov al,36h
				out 43h,al
				mov al,byte ptr cs:frametimeb[0]
				out 40h,al
				mov al,byte ptr cs:frametimeb[1]
				out 40h,al

				test cs:in_int,1
				jnz @@1

				mov cs:in_int,1

				sti
				call DemoInt
				mov cs:in_int,0
				cli
@@1:
				pop ds
				pop ax
				iret

intti8 			endp



SetInts 		proc near

				cli
				xor ax,ax
				mov es,ax
				mov ax,es:[INTER*4]
				mov word ptr cs:oldint8,ax
				mov ax,es:[INTER*4+2]
				mov word ptr cs:oldint8[2],ax
				mov ax,offset intti8
				mov es:[INTER*4],ax
				mov es:[INTER*4+2],cs
				sti

				call Sync

				mov al,36h
				out 43h,al
				mov al,0
				out 40h,al
				mov al,0
				out 40h,al

				call Sync

				xor al,al
				out 43h,al
				in al,40h
				mov ah,al
				in al,40h
				xchg al,ah
				neg ax
				shr ax,1
				mov cs:frametime,ax
				mov dx,ax
				mov al,ah
				xor ah,ah
				sub dx,ax
				shl dx,1
				mov cs:frametimeb,dx
				mov al,36h
				out 43h,al
				mov al,dl
				out 40h,al
				mov al,dh
				out 40h,al
				ret

SetInts 		endp


ClearInts 		proc near

				cli
				xor ax,ax
				mov es,ax
				mov ax,WORD PTR cs:oldint8
				mov dx,WORD PTR cs:oldint8[2]
				mov es:[INTER*4],ax
				mov es:[INTER*4+2],dx
				sti

				mov al,36h
				out 43h,al
				mov al,0
				out 40h,al
				mov al,0
				out 40h,al
				ret

ClearInts 		endp


GetRasterLine  	proc near

				cli
				xor al,al
				out 43h,al
				in al,40h
				mov dl,al
				in al,40h
				mov dh,al
				shr	dx,1
				mov ax,cs:frametime
				sub ax,dx
				mov cx,400
				mul cx
				mov cx,cs:frametime
				div cx
				sti
				ret

GetRasterLine 	endp

				end
