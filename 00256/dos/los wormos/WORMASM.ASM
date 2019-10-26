			.286
Code   Segment Para 'Code'
			Assume  cs:Code,ds:Code
			Org 100h

public _snake

_snake proc near
cheese:
			;Set DS=CS
			push cs
			pop  ds

			; Set gfx-mode
			mov ax,0013h
			int 10h
			;Clear data
			push ds
			pop es
			mov di,offset data
			xor ax,ax
			mov cx,16384
			rep stosw
			
			; Set ES=0a000h
			push 0a000h
	     		pop es

			;Init and draw frame
			mov di,64000-320-1
			mov cx,65536-64000+640
			mov ax,0b0bh
			rep stosb
			mov cl,200
y:
			mov word ptr es:[di],ax
			add di,320
			loop y

redo_main:
			;Read a key if possible
			mov ax,0100h
			int 16h
			jz no_key_avail
			xor ax,ax
			int 16h
			;Act upon key

		        mov al,ah
			cmp al,75
			jb player2
			sub al,76
			add byte ptr plr1,al
			mov al,0
player2:
;			sub al,17
			add byte ptr plr2,al
no_key_avail:

			; Update both players
			xor di,di
			xor si,si
			mov dx,0d0dh                     	;color of snake
			inc cx
			inc cx
update_players:
			mov bl,byte ptr plr[si]
			and bx,3
			add bx,bx

			mov ax,word ptr plr [si+1]
			add ax,word ptr move_directions [bx]
			mov word ptr plr [si+1],ax

			mov bx,word ptr plr[si+5]              ;Get head
			inc bx                                 ;Advance head
			inc bx
			and bx,16383													 ;Wrap head around
			mov word ptr plr[si+5],bx              ;Store head
			mov word ptr data [bx+di],ax           ;Store position at head

			mov bx,word ptr plr[si+3]				  		 ;Get tail
			mov di,word ptr data[bx+di]            ;Get tail position
			mov word ptr es:[di],0                 ;delete tail
			mov word ptr es:[di+320],0             ;delete tail

			;Draw snake and exit if dead
			mov di,ax                             ;di=ax=cur. pos. of head
			cmp byte ptr es:[di],16
			jb not_cheese_1
			sub bx,64                             
			jmp draw_it
not_cheese_1:
			cmp byte ptr es:[di],0
			jne killed
Draw_it:
			inc bx                               ;advance tail
			inc bx                               ;advance tail
			and bx,16383			    							 ;wrap tail around
			mov word ptr plr[si+3],bx            ;Store tail

			;Draw snake
			mov word ptr es:[di],dx
			mov word ptr es:[di+320],dx

			;Create A new cheese if its time
			inc byte ptr [cheese]
			jnz no_new_cheese
			;Make a cheese at Y=100 X=rand ()
			and di,00feh
			add dx,dx
			mov word ptr es:[di+32032],dx
			mov word ptr es:[di+320+32032],dx
no_new_cheese:
			;Init for next player
			
			add si,7
			mov di,16384
			loop update_players

			;Pause
			push ds
			mov ds,cx
			mov bx,word ptr ds:[046ch]         ;Timer
pause:
			cmp bx,word ptr ds:[046ch]         ;Has timer advanced
			je pause                           ;If not try again
			pop ds

			jmp redo_main
killed:
			mov ah,4ch
			int 21h
endp _snake

move_directions dw 2,640,-2,-640

plr:
plr1 db 0 
p1 dw 32160, 0, 32    ;Start direction, Start position, Tail, Head
plr2 db 2 
p2 dw 32158, 0, 32    ;Start direction, Start position, Tail, Head
data:

Code    Ends

End     _snake
