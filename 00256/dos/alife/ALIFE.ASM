.386
.MODEL TINY
ASSUME CS:INTRO,DS:INTRO

INTRO SEGMENT PARA USE16
   org  0100h

STARTUPCODE
   mov ah,0a0h
   mov gs,ax
   mov ax,3508h
   int 21h
   push ds
   push bx
   push es  ; Actual timer saving...
   mov ah,25h
   mov dx,offset(Timer)
   int 21h
   mov al,036h
   out 043h,al
   out 040h,al
   mov al,0ffh
   out 040h,al   ; New timer setting -> 29702 ~= 59659 ~= 1193180/20

   mov ax,13h
   int 10h      ; Video mode setting

   mov bx,64*40
init_pool_next:
   mov ax,1351
   mul word ptr seed
   add ax,4971
   mov word ptr seed,ax
   shr al,7
   dec bx
   mov [pool+bx],al
   jnz init_pool_next

mainloop:
   mov al,Sync
framewait:
   cmp al,Sync
   je  framewait ; Timer delay

   mov bx,(64*40)-1
   xor si,si
   xor cx,cx
show_pool_next:
   mov di,cx
   add di,si

   push cx
   xor dx,dx
   mov ax,bx
   mov cx,64
   div cx
   xor cx,cx
   or ax,ax
   jz pool_neighbours_up
   add ch,[pool+bx-64]
   add ch,[pool+bx-65]
   add ch,[pool+bx-63]
pool_neighbours_up:
   cmp ax,39
   je pool_neighbours_down
   add ch,[pool+bx+64]
   add ch,[pool+bx+63]
   add ch,[pool+bx+65]
pool_neighbours_down:
   add ch,[pool+bx-1]
   add ch,[pool+bx+1]

   mov ax,cx
   pop cx

   mov al,15
   cmp [pool+bx],byte ptr 0
   je show_pool_no_cell
   cmp ah,2
   je show_pool_survival
   mov [newpool+bx],0
show_pool_survival:
   mov al,33
show_pool_no_cell:
   cmp ah,3
   jne show_pool_no_birth
   mov [newpool+bx],1
show_pool_no_birth:

   mov dh,5
show_pool_next_line:
   mov dl,5
show_pool_next_dot:
   mov [gs:di],al
   inc di
   dec dl
   jnz show_pool_next_dot
   add di, 320-5
   dec dh
   jnz show_pool_next_line

   add si,5
   cmp si,320
   jne show_pool_no_carrier
   xor si,si
   add cx,1600
show_pool_no_carrier:
   dec bx
   jns show_pool_next

   mov bx,64*40
show_pool_dump_next:
   dec bx
   mov al,[newpool+bx]
   mov [pool+bx],al
   jnz show_pool_dump_next

   in  al,60h
   dec al
   jnz mainloop  ; Detect pressed key and, if not ESC, continue execution
finish:
   mov ax,2508h
   pop ds
   pop dx
   int 21h         ; Restore original timer
   pop ds
   mov ax,3h       ; Set standart textmode
   int 10h
   int 20h         ; End

Timer proc near
   push ax
   inc Sync
   mov al,20h
   out 20h,al
   pop ax
   iret
Timer endp

   seed    db  25
   Sync    db ?
   pool     db 64*40 dup(?)
   newpool  db 64*40 dup(?)

INTRO ENDS
      END
