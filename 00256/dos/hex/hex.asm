org 100h
use16

mov al,13h
int 10h

 mov bh,0A0h
 mov es,bx

 mov bh,090h
 mov fs,bx

;push 0A000h
;pop es
;push 09000h
;pop fs
;les bp,[bx]
;mov fs,bp
;
;mov al,1

mov byte[es:170+100*320],al

xor al,al
mov dx,03c8h
out dx,al
inc dx
pallp:
mov al,bl
 shl al,4
out dx,al
xor al,al
out dx,al
out dx,al
inc bl
cmp bl,dl
jne pallp

run:
 xor bp,bp;sw=0
 mov bx,4;x
x1lp:;For x=4 To 316 Step 2
 xor bp,1
 mov di,4;j or y
jlp:;For y=4 To 196 Step 2
pusha

 add di,bp;y=j+sw

;        If b(x,y)>0:sw1=sw1+1:EndIf
 xor cx,cx;sw1=0
 call getpix
 mov cl,al
 mov ax,[es:si]
 mov [fs:si],ax

 mov ax,[es:si+320]
 mov [fs:si+320],ax

 push si
;        If b(x,y-2)>0:sw1=sw1+1:EndIf
;;sub di,2;di=y
call getpix2
;        If b(x,y+2)>0:sw1=sw1+1:EndIf
add di,4;y+2
call getpix
;        If b(x-2,y-1)>0:sw1=sw1+1:EndIf
sub bx,2;x-2
sub di,3;y-1
call getpix
;        If b(x-2,y+1)>0:sw1=sw1+1:EndIf
add di,2
call getpix
;        If b(x+2,y+1)>0:sw1=sw1+1:EndIf
add bx,4
call getpix
;        If b(x+2,y-1)>0:sw1=sw1+1:EndIf
;sub di,2
call getpix2

;;xor ah,ah;k1=0
 pop si
or ch,ch;If sw1<>0
je next_x
xor ah,ah;k1=0
;If (sw1>=1) And (sw1<=2)
 cmp ch,1
 jl endif;put_to_a
 cmp ch,2
 jg endif;put_to_a
 call some_op
;k1=1+Mod(k,12)
 jmp skippy
endif:;EndIf
 xor ah,ah
skippy:
; If (k>0) And (k1>0):k1=1+Mod(k,12):EndIf
and cl,cl
jns put_to_a;next_x;jns
and ch,ch
jns put_to_a;next_x;jns
 call some_op

put_to_a:
 mov al,ah
 mov [fs:si],ax
 mov [fs:si+320],ax
;a(i1,j1)=k1
next_x:
 popa
;Next j
inc di
inc di
cmp di,196;316
jne jlp
;Next i1
inc bx
inc bx
cmp bx,316;;196
jne x1lp
;Swap a(),b()
; hlt
mov cl,255
walp:
mov dx, 3dah
@wait1: 
in al, dx
test al, 8
jz @wait1
 dec cl
 jne walp
;@wait2:
;in al, dx
;test al, 8
;jnz @wait2

 push fs
 pop ds
 xor si,si
 xor di,di
 mov cx,64000
 rep movsb
 in al,60h
 dec al
 jne run

getpix2:
sub di,2
getpix:
mov ax,320
mul di;bx=x
add ax,bx;di=y
;;add ax,15
mov si,ax
 mov al,[es:si]
 or al,al
 je end_get
 inc ch
end_get:
 ret
some_op:
 movsx ax,cl;  k1=1+Mod(k,12)
; xor ah,ah
; mov al,cl
 cwd
 push cx
 mov cx,12
 div cx
 mov ah,dl
 inc ah
 pop cx
 ret

;mov dx, 0
;mov ax, 1234
;mov bx, 10
;div bx       ; Divides 1234 by 10. DX = 4 and AX = 123
