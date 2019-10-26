
;
; firecube
;
; 256b intro by cryo
; email: me@em-motion.com
;

bits 16

org 0x100

start:
	
	mov al,0x13
	int 10h
 
	; gray-scale palette
	mov     dx,0x3c8
	out     dx,al
	inc     dx
.pal_loop:
	out	dx,al
	out	dx,al
	out	dx,al
	inc	ax
	jnz	.pal_loop
	
	finit 

	push 0x0a000
	pop ss
	
	mov bp,buffer						; Backbuffer address
	
mainloop:
	mov ch,0xF9
	mov di,bp
	mov si,bp
.blur_and_copy:
	mov al,[si+638]
	add al,[si+322]
	shr al,1
	mov [ss:di],al				; Ugh, this is dirty, but i correct the offset later on with the
	stosb						; tweaked centering value.
	lodsb
	loop .blur_and_copy	

	mov si,angle
	
	; Coordinate generation. Had to put this code inside the mainloop
	; and mix the angle increment with it in order to rotate the cube faster.
	mov ebx,11010010111111010000000101101000b
	mov	di,cube3d
	mov cl,2
.cube:
	sbb	ax,ax
	and	ax,96
	sub	ax,96/2
	stosw
	shr	ebx,1
	jnz	.cube
	mov bx,1001101111011010b
	inc word [si]						; this is the angle increment
	loop .cube


	mov cl,16
	mov bx,cube3d
	
.rotate_coords:
	fild word [bx+4]					; z
	call Load

	mov al,3
.rotation:
	fldpi								; Incrementing the angle inside the
	fimul word [si]						; rotation loop is not good, but it
	fidiv word [persp+2]				; works with small increments.
	
	fsincos								; sin cos x y z
	fld st2								; x sin cos x y z
	fmul st2							; x*cos sin cos x y z
	fld st4								; y x*cos sin cos x y z
	fmul st2							; y*sin x*cos sin cos x y z
	fsubrp st1							; x' sin cos x y z
	fxch								; sin x' cos x y z
	fmulp st3,st0						; x' cos x*sin y z
	fxch 								; cos x' x*sin y z
	fmulp st3,st0						; x' x*sin y*cos z
	fxch								; x*sin x' y*cos z
	faddp st2							; y ' x' z

	fxch st2							; 
	dec al
	jnz .rotation						
										; z y x	
	fild word [persp+2]					; zdist z y x
	fadd st1,st0						; zdist z+zdist y x
	fdivp st1							; zdist/(z+zdist) y x
	fmul st1,st0						; zdist/(z+zdist) y*(zdist/(z+zdist)) x
	fmulp st2							; x*(zdist/(z+zdist)) y*(zdist/(z+zdist))
			
	fistp word [bx+96]					; y'
	fistp word [bx+96+2]				; -

	lea bx,[bx+6]						; bx = bx+6
	
	loop .rotate_coords

	mov cl,15
lines:

	call Load
	lea bx,[bx+6]			; bx = bx+6
	call Load
		
	fsub to st2				; x1 y1 x2-x1 y2
	fxch					; y1 x1 x2-x1 y2
	fsub to st3				; y1 x1 x2-x1 y2-y1
	
	fld st2					; x2-x1 y1 x1 x2-x1 y2-y1
	fmul st0				; (x2-x1)² y1 x1 x2-x1 y2-y1
	fld st4					; y2-y1 (x2-x1)² y1 x1 x2-x1 y2-y1
	fmul st0				; (y2-y1)² (x2-x1)² y1 x1 x2-x1 y2-y1
	faddp st1				; (y2-y1)² + (x2-x1)² y1 x1 x2-x1 y2-y1
	fsqrt					; length y1 x1 x2-x1 y2-y1
	
	fdiv to st3				; length y1 x1 x2-x1/length y2-y1
	fdiv to st4				; length y1 x1 x2-x1/length y2-y1/length

	pusha
	mov si,tmp
	
	fistp word [si]			; st0=y1, st1=x1, st2=x2-x1/length, st3=y2-y1/length
	mov cx,[si]

linefpulength:
	
	fadd st3				; st0 = st0 + st3 (y1+=deltay)
	fist word [si]
	fxch					; st0=x1, st1=y1
		
	mov di,[si]				; y offset
persp:
	imul di,320				; this "320" is also used as a perspective factor

	fadd st2				; st0 = st0 + st2 (x1+=deltax)
	fist word [si]
	fxch					; st0=y1, st1=x1

	add di,[si]				; x offset
	add di,32090			; x/y centering
	add di,bp

	
	mov al,16
	stosb
		
	loop linefpulength
	finit
	popa
		
	loop lines

	mov dl,0xDA 	 		; Wait for vertical retrace
retrace:
    in   al,dx
    test al,8
    jz   retrace

	in   al,0x60	 		; check for esc key
	dec  al
	jne  mainloop


Load:
	fild word [bx+2]
	fild word [bx]
	ret
		
	cube3d:
	
	tmp		equ		cube3d+96+96
	angle	equ		cube3d+96+96+4
	buffer 	equ		cube3d+96+96+8	