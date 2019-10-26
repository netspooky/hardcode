;***********
;* Retrace *
;***********
retrace:
	push    dx
	push    ax


;        mov dx,3C8h
;        mov al,0
;        out dx,al
;        inc dx
;        out dx,al
;        out dx,al
;        out dx,al

	mov     dx,3dah
delay_l1:
	in      al,dx
	test    al,8
	jne     delay_l1
delay_l2:
	in      al,dx
	test    al,8
	je      delay_l2

;        mov dx,3C8h
;        mov al,0
;        out dx,al
;        inc dx
;        mov al,63
;        out dx,al
;        mov al,0
;        out dx,al
;        out dx,al


	pop     ax
	pop     dx
ret



;************
;* Settimer *
;************
settimer:
	cli
	mov ax,351Ch
	int 21h
	mov oldtimeroffs,bx
	mov oldtimerseg,es
	
	push ds
	lea dx,newinterrupt
        mov ax,cs
        mov ds,ax
	mov ax,251Ch
	int 21h
	pop ds
	
	;New rate
	mov al,3Ch
	out 43h,al
	nop
	nop
	;mov ax,4DAEh ;1234DDh/60
	mov al,0AEh
	out 40h,al
	nop
	nop
	mov al,4Dh
	out 40h,al
	nop
	nop
	sti
ret



;**************
;* Unsettimer *
;**************
unsettimer:
	push ds
	mov dx,oldtimeroffs
	mov ds,oldtimerseg
	mov ax,251Ch
	int 21h
	pop ds
ret



;***************
; Newinterrupt *
;***************
newinterrupt:
	push ds
	mov ds,cs:[datasegment]
	inc framecounter
	pop ds
iret