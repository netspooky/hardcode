NUM_LINES EQU 32
STEP_CREATE EQU (320 / NUM_LINES)
                                                                  
SINE_BUFFER EQU 08000h
SCREEN_BUFFER EQU 09000h
SCREEN_VRAM EQU 0A000h
                                                                     
                                                                     
                                                                     

org 100h
	mov al,13h
	int 10h
                          
	push word SINE_BUFFER
	pop ds
                                                                     
	xor di,di
	xor cx,cx
Singen:
	; random shit
	mov bl,cl
	add bl,64
	MOV	[DI],bl
;        MOV     [DI],CH
	ADD	CX,SI
	MOV	AX,1024
	IMUL	CX
	SUB	SI,DX
	INC	DI
	JNZ	Singen

main:
;        call cls
;cls:
	push word SCREEN_BUFFER
	pop es
	mov cx,16000
	xor di,di
	xor ax,ax
	rep stosd
;ret

	push word SINE_BUFFER
	pop ds
;createlines:
	mov si,frame
	mov dx,[cs:si]
	inc dx
	mov [cs:si],dx

	mov si,random_col+1
	mov [cs:si],dh

	mov cx,NUM_LINES+1
	mov si,points
	xor di,di
	shr dx,1
	add di,dx
	xor ax,ax
;        xor bx,bx
createloop:
	mov bl,[ds:di]

and dh,1
jz change
	add al,bl
change:

	mov [cs:si],ax
	mov [cs:si+2],bx

	add si,4
	add ax,STEP_CREATE
	inc di
	dec cx
	jnz createloop
;ret

	push word SCREEN_BUFFER
	pop ds
;        call drawlines
;drawlines:
	mov di,points
	mov si,NUM_LINES
looplines:
	mov ax,[cs:di]		; read x0
	mov cx,[cs:di+2]	; read y0
	mov bx,[cs:di+4]	; read x1
	mov dx,[cs:di+6]	; read y1
	push si
	push di

;       call drawline
;drawline:
	cld			; stosb increases (x++ in bresenham loop)
	sub bx,ax		; bx = x1 - x0 = dif_x
	jnc dx_pos		; is x1>=x0 ?
	neg bx
	std			; stosb decreases (x-- in bresenham loop)
dx_pos:
	mov bp,320		; di moves down on Y in bresenham loop
	sub dx,cx		; dx = y1 - y0 = dif_y
	jnc dy_pos		; is y1>=y0 ?
	neg dx
	mov bp,-320		 ; di moves up on Y in bresenham loop
dy_pos:
	push dx

	mov di,ax
	mov ax,320
	mul cx
	add di,ax		; di = vram start of (x0,y0)

	pop cx			; cx = dif_y
	xor dx,dx		; remainder = 0 =>dx

	; =============================
	; bx = dif_x
	; cx = dif_y
	; dx = remainder
	; di = starting vram at (x0,y0)
	; =============================

;random_color_paremvasi
random_col:
	add al,0

	mov ah,cl
	inc ah			; iy = dif_y + 1
	mov si,bx
	inc si			; ix = dif_x + 1
line:

case1:
	cmp cx,dx		; is dif_y<=remainder ?
	jnc case2
;        mov al,15      ; should be not commented originally but adds colors randomly to the effect now


	stosb			; write pixel
	add dx,cx		; increase remainder by dif_y
	dec si			; decrease ix
	jnz case1		; is ix==0 ?
case2:
;        mov byte [es:di],15         ; write pixel. Commented-removed for EOR method
	add di,bp		 ; move up or down 1 point on Y
	sub dx,bx		 ; decrease remainder by dif_x
	dec ah			; decrease iy
	jnz line		; is iy==0 ?
;ret

	pop di
	pop si
	add di,4
	dec si
	jnz looplines
;ret

;eorfill:
;        mov di,320
	mov bx,64000 - 320
eorloop:

mov si,frame

change4:
;mov dx,[cs:si]  ; if mov dh,[cs:si] then fuck up

;inc dh

;and dh,7
;jnz nofuck
;        mov si,change4+1
;        mov ax,0x348a
;        mov [cs:si],ax
;nofuck:

;and dh,3
;jz chose3
	mov al,[ds:di]
chose3:
	xor al,[ds:di-320]
	mov [ds:di],al
	inc di
	dec bx
	jnz eorloop
;ret
                                                                     
MOV DX,3DAh
Vsync1:
	IN	AL,DX
	AND	AL,8
	JZ	Vsync1
Vsync2:
;        IN      AL,DX
;        AND     AL,8
;        JNZ     Vsync2
                                                                     
                                                                     
;copyscreen:
	xor di,di
	xor si,si
	push word SCREEN_VRAM
	pop es
	mov cx,16000
	rep movsd
;ret

	in al,60h
	dec al
	jnz main

	mov ax,03h
	int 10h
ret
                                                                     
frame:
dw 0
                                                                     
points:
