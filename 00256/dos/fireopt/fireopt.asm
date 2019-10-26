; 193-byte fire effect for DOS
; Press [ESC] to exit the program.
;
; How to compile:
;  tasm /m fireopt.asm
;  tlink /t fireopt.obj
;

 
.model tiny		;Not neccesary, but it's the correct way to do it
.386			;Enable 386 instructions	
code segment use16	;Set up the 64k segment in wich all code/data will reside
assume cs:code, ds:code	;Point cs and ds to this segment
org 0100h		;This line must be present in a .COM file

;<Main code> 
start:		; <-- execution starts here 
mov al,13h	;set mode 19
int 10h

;<Palette stuff>
mov cx,256
xor ax,ax
mov dx,3C8h
out dx,al
mov si,offset color
inc dx
mov di,si
@@palloop:
	mov ax,cx
	dec ax		; Convert to 0..255
	not ax		; Flip the bits
	add al,al	; Multiplicate by 2	
	and al,63	; Put it in the desired range
	mov [di],al
	mov bx,cx
	mov cx,3
	rep outsb
	mov cx,bx
	sub si,3
	
	cmp cl,225
	jne short @@1
	jmp short @@2
	@@1:
	cmp cl,193
	jne short @@3
	@@2:
	mov [di],al
	inc di
	@@3:
loop @@palloop	


	
 
; Set es to point at VGA video memory
push 0a000h
pop es

mov dl,58 
mov bp,318

@@mainloop:
 	mov dh,160
 	mov si,12798		;(y*320)+x-2  	
 	mov di,12160		;((y-2)*320)+x 	

	; Draw column by column, left to right 
 	@@xloop:
 	 	push di
  		push si
  		push ds
  		push es
  		pop ds
  		mov ch,82		; start_y
  		@@yloop:
   			xor ah,ah
   			lodsb			;si=(y*320)+x-2
   			mov bx,ax
   			inc si
   			lodsb			;si=(y*320)+x
   			add bx,ax
   			inc si
   			lodsb			;si=(y*320)+x+2
   			add bx,ax
   			mov al,[si+639]
   			add ax,bx
   			shr ax,2
   			je short nopixeldec
    			dec ax			; color=color-1		
   			nopixeldec:		
   			mov ah,al
   			stosw
   			add di,bp
   			stosw
   			add si,635
   			add di,bp		;di = last di + 640
   			dec ch
  		jnz short @@yloop
  		sub di,640
  		pop ds
  

  		; Pseudo-random number generator
  		;---------------------
  		mov si,OFFSET random16
  		mov al,dl
  		add al,cl
  		and ax,3
  		add ax,ax
  		add si,ax
  		mov ax,[si]
  		rol ax,11
  		xchg al,ah
  		mov cl,al
  		mov [si],ax
  		;--------------------
  		
  		and ax,0bfh		;Cut ax to be max 191
  		pop si 

  		stosb 
  		pop di
  		inc si		;Add 2 to read-offset
  		inc di
  		inc si 
  		inc di
  		dec dh
 	jnz @@xloop

 	in al,60h		;Check for ESC key
 	dec al
jnz @@mainloop


@@quit:
mov al,03h		;Set textmode
int 10h
mov ah,04ch		;Exit to DOS
int 21h

;</Main code>



;<Data>
; Some random 16-bit numbers for use with the random-number generator
random16 dw 25662,56977,36314,46707

color	db 0,0,0

;</Data>

code ends	;Segment ends here
END start	;End of program


;/Mic, stabmaster_@hotmail.com
