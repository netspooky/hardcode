; 13:54 24-08-2012 An origin of the species:
; I've found source on the ZX named 'Border', so have no idea where algo has been disassembled
; some try to reincarnate demo failed. hope you like it.
; no fucking improvements, lovely colors.goblinish
org 100h
use16
 edgec =078h

mov al,13h
int 10h

mov bh,070h
mov ds,bx
mov bh,0A0h
mov es,bx
;setpal
;?xor cx,cx
;pallp:
; mov dx,03c8h
; xor bx,bx
; xor ch,ch
; test cl,1
; jz brapal1
; mov bl,03fh;r
;brapal1:
; test cl,2
; jz brapal2
; mov bh,03fh;g
;brapal2:
; test cl,4
; jz brapal3
; mov ch,03fh;b
;brapal3:
; mov al,cl
; rcl al,4;*16
; out dx,al
; inc dx
; mov al,bl
; out dx,al
; mov al,bh
; out dx,al
; mov al,ch
; out dx,al
; inc cl
; cmp cl,8
; jnz pallp
;

       mov ah,016h;mov ax,1600h
       mov [bp+2],ax;mov word [LA4A2],ax
       ;in al,40h
       mov [bp],ah
       mov [bp+4],ax;word [LA4A4],ax
M0:
    mov dh,edgec
	mov dl,[bp+3]
	CALL LA53A
	add al,4
	jnc LA573
	CALL LA53A
	and al,3
	mov dl,8
	jz LA573
	mov dl,28h
	dec al
	jz LA573
	mov dl,18h
	dec al
	jz LA573
	mov dl,dh;edgec
LA573:
	mov [bp+3],dl
	mov al,[bp+4]

	and al,8
	jnz LA585
	mov al,[bp+4]
	and al,3
	jnz LA598
LA585:
	CALL LA53A
	movzx bx,al
;;    mov bh,al
	CALL LA53A

	and al,07fh;???
;;	mov bl,al
	xor ah,ah
	push dx;1
	xor dx,dx;1
	imul ax,320
	pop dx;1
	add bx,ax
	mov al,[ds:bx]
	add al,dl
	xor al,[ds:bx]
	and al,dh;edgec;038h

	xor al,[ds:bx]
	mov [ds:bx],al
LA598:
	CALL LA53A
	and al,0feh
	mov al,[bp+4]
	jnz LA5A4
	xor al,8
LA5A4:
       inc al
       and al,0Bh
       mov [bp+4],al
LA506:
	xor si,si
	xor di,di
	mov cx,320*200
LA510:
	mov al,[ds:si]
	add al,dl
	and al,dh;edgec;038h
	cmp al,[es:di+1]
	jz @store
	cmp al,[es:di+320]
	jz @store
	cmp al,[es:di-320]
	jz @store
	cmp al,[es:di-1]
	jnz LA52C
@store:
    mov [ds:si],al

LA52C:
	inc si
	inc di
	cmp di,cx;0fa00h
	jnz LA510
;copy
 std
 rep movsb
;-------------------------------------
 in al,60h
 dec al
 jne M0
 int 20h
;	jp M0

LA53A:
	mov cl,[bp]
	mov al,[bp+1]
	mov [bp],al
	add al,cl
	mov cl,al
	mov al,[bp+2]
	mov [bp+1],al
;        ADD A,C:RRCA
	add al,cl
	;rcr al,1
	mov [bp+2],al
	RET
