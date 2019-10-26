; Flame code - Moopy/GPF   entry for Gaffer's 256 byte flame compo '96

model tiny
.386
.code
org 100h

;-----------------------------------------------
; some luverly code
;-----------------------------------------------

goflamergo:

	;pointer to buf
	mov ax,offset pbuf1
	mov gs,ax ; gs= offset to flame buffer

   ;--------
   ;set MCGA
   ;--------
   mov ax,13h
   int 10h

	;------------------------------------
	;make the culurz all pretty and stupf
	;------------------------------------

	mov di,offset palette
	mov fs,di

	xor al,al
	mov cx,3*256
	push cx
	repz stosb

	mov di,fs

	xor bx,bx
	mov ax,01f3fh

	mov cl,31  ; assumes ch is 0
palette_back2:
	add bx,0102h
	inc ah

	mov[es:di+53*3],bx
	mov[es:di+(53+31)*3],ax

	add di,3
	loop palette_back2

	xor al,al
	mov dx,3c8h
   out dx,al
	inc dx

	mov si,fs
;	mov cx,256*3
	pop cx
	repz outsb


   ;-----------------
   ;clear dem bufferz
   ;-----------------
   mov di,gs
   xor eax,eax
   mov cx,(320*100*2)/4
	sub bp,cx
   repz stosd


   ;------------------
   ;diz is da mainloop
   ;------------------
main_repeat:

	;-------------
	;do dat flamer
	;-------------
   mov di,gs
   mov si,di

   mov ax,[bufpos]
   add di,ax
   xor ah,7dh  ;xor ax,32000
   add si,ax

   mov cx,320*(100-4) ; change dis numba to reduce amount of bufa daz flamed
   add si,320 ; src always 1 below dest

doflame_back:
   xor bh,bh
   xor ax,ax

   push si

   xor dh,dh
   mov dl,[ds:si] ; "heat" of current pixel
;   shr dx,6 ; ooh, not too hot
;   shl dx,6 ; add heat to source ypos for supa doopa fx
	and dl,192 ; same as above 2 commented lines
   add si,dx
   shl dx,2
   add si,dx

   mov bl,[ds:si+1+320]
   add ax,bx
   mov bl,[ds:si-1+320]
   add ax,bx
   mov bl,[ds:si-320]
   add ax,bx
   mov bl,[ds:si]
   add ax,bx

   shr ax,2
   pop si

;   mov [ds:di],al
;   inc di
	stosb

   inc si

   loop doflame_back

	;-------------
	;draw sum shat
	;-------------

	mov di,gs
	add di,320*(100-4)
	add di,[bufpos]

	mov cx,320
drawshat_back:
	in al,40h
	xor al,[randbyte]
	ror al,3
	mov [randbyte],al

	shr al,1
	mov dx,bp
;	or dh,80h
	add al,dh

	stosb
	loop drawshat_back

	sub bp,10

	;------------
	;blit dat buf
	;------------
	push es
	mov ax,0a000h
	mov es,ax
	mov di,4+320*(4+12)

	mov si,gs
	add si,4
	add si,[bufpos]

	mov ax,8

	mov cl,100-16 ; assumes ch=0
	blit_backy:

	push cx
	mov cl,(320-8)/4 ; assumes ch=0
	push cx
	push si
	repz movsd
	pop si
	pop cx
	add di,ax
	repz movsd
	add di,ax
	add si,ax
	pop cx
	loop blit_backy
	pop es


	;------------
	;swap bufferz
	;------------
	xor byte ptr[bufpos+1],7dh  ;xor [bufpos],32000

	;-----------------------------------------------
	;quit if sum dudz press da key else loopidy doop
	;-----------------------------------------------
	mov ah,1
	int 16h
	jz main_repeat

   ;-------------------------------
   ;eat keypress & set Mr text mode
   ;-------------------------------
	xor ax,ax
   int 16h
   mov ax,03h
   int 10h

   ret


;-----------------------------------------------
; some luverly data
;-----------------------------------------------

;offset to active buffer
bufpos dw 0

;used bi randum rooteen
randbyte db ?

;me bufferz
pbuf1 db 320*100 dup (?)
pbuf2 db 320*100 dup (?)

palette db 256*3 dup (?)

end goflamergo
