		.model large
		.386
		.stack  256

		.data
	ASSUME DS:@DATA

bs2    db 32000 dup (0)

i1     db 0
j1     db 0 ; Used for red sinus blobs

i2     db 0
j2     db 0 ; Used for green sinus blobs

i3     db 0
j3     db 0 ; Used for green sinus blobs

sint label byte
include s1.inc   ; Sine tables

sint2 label byte
include s2.inc   ; *** THESE TWO TABLES MUST BE IN THE SAME SEGMENT ***

redt label byte
include rt.inc

picture label byte
include cpw.inc
pic_h EQU 22 ;*3

		.code
    ASSUME CS:@CODE
start:
mov ax,@data
mov ds,ax

;Enable keyboard
;		in   al, 21h
;		or   al, 2
;		out  21h,al

call Set320x400x256

cld

mov si,offset bs2

xor al,al
mov ah,64
mov dx,03c8h
out dx,al
inc dx
@pal_let_loop:
   out dx,al
   outsb
   outsb
   inc al
   dec ah
   jnz @pal_let_loop

   xor al,al
   mov ah,64
@pal_let_loop2:
   outsb
   out dx,al
   outsb
   inc al
   dec ah
   jnz @pal_let_loop2

   xor al,al
   mov ah,64
@pal_let_loop3:
   outsb
   outsb
   out dx,al
   inc al
   dec ah
   jnz @pal_let_loop3

   xor al,al
   mov ah,64
@pal_let_loop4:
   out dx,al
   out dx,al
   out dx,al
   inc al
   dec ah
   jnz @pal_let_loop4

@main_big_ole_loop:
  add [i1],255
  inc [j1]
  xor di,di
mov si,100
 @r0:
  mov bx,si
  add bl,[i1]
  adc bh,0
  and bx,0ffh
  mov dl,sint2[bx]
  mov bl,[j1]
  xor bh,bh
  mov dh,sint2[bx]
mov cx,320
 @r1:
  mov bx,cx
  add bl,dl
  mov al,sint[bx]
  mov bx,si
  add bl,dh
  add al,sint[bx]
  mov bl,al
  mov al,redt[bx]

  mov bs2[di],al
  inc di
  dec cx
  jnz @r1
dec si
jnz @r0

mov di,offset picture
mov si,offset bs2
add si,40*320-5 ;+10

mov bx,pic_h ;21
@tsy:
  mov cx,320
  @tsx:
    mov al,ds:[di]
    cmp al,0
    jz @no_logo
    mov ds:[si],al
    @no_logo:
    inc di
    inc si
    dec cx
    jnz @tsx
    add di,640
  dec bx
  jnz @tsy


mov di, 50*80
call Copy_thing ; THIS COPIES THE Red Sinus blobs TO THE SCREEN

  add [i2],255
  inc [j2]
  xor di,di
mov si,100
 @g0:
  mov bx,si
  add bl,[i2]
  adc bh,0
  and bx,0ffh
  mov dl,sint[bx]
  mov bl,[j2]
  xor bh,bh
  mov dh,sint[bx]
mov cx,320
 @g1:
  mov bx,cx
  add bl,dl
  mov al,sint[bx]
  mov bx,si
  add bl,dh
  add al,sint2[bx]
  mov bl,al
  mov al,redt[bx]
  add al,64

  mov bs2[di],al
  inc di
  dec cx
  jnz @g1
dec si
jnz @g0

mov di,offset picture
add di,320
mov si,offset bs2
add si,40*320-5

mov bx,pic_h ;21
@tsy2:
  mov cx,320
  @tsx2:
    mov al,ds:[di]
    cmp al,0
    jz @no_logo2
    mov ds:[si],al
    @no_logo2:
    inc di
    inc si
    dec cx
    jnz @tsx2
    add di,640
  dec bx
  jnz @tsy2

mov di, 51*80
call Copy_thing ; THIS COPIES THE Green Sinus blobs TO THE SCREEN

  add [i3],255
  inc [j3]
  xor di,di
mov si,100
 @b0:
  mov bx,si
  add bl,[i3]
  adc bh,0
  and bx,0ffh
  mov dl,redt[bx]
  mov bl,[j3]
  xor bh,bh
  mov dh,sint2[bx]
mov cx,320
 @b1:
  mov bx,cx
  add bl,dl
  mov al,sint[bx]
  mov bx,si
  add bl,dh
  add al,sint[bx]
  mov bl,al
  mov al,redt[bx]
  add al,128

  mov bs2[di],al
  inc di
  dec cx
  jnz @b1
dec si
jnz @b0

mov di,offset picture
add di,640
mov si,offset bs2
add si,40*320-5

mov bx,pic_h ;21
@tsy3:
  mov cx,320
  @tsx3:
    mov al,ds:[di]
    cmp al,0
    jz @no_logo3
    mov ds:[si],al
    @no_logo3:
    inc di
    inc si
    dec cx
    jnz @tsx3
    add di,640
  dec bx
  jnz @tsy3

mov di, 52*80
call Copy_thing ; THIS COPIES THE Blue Sinus blobs TO THE SCREEN

;Get keypress(es)
@keys:		in   al, 60h
                dec  al
		jne  @main_big_ole_loop


mov ax,0003h
int 10h
;Disable keyboard
;		in   al, 21h
;		and  al, NOT 2
;		out  21h,al

	mov     ax,4c00h
	int     21h         ; Quit to Dos

Set320x400x256 PROC NEAR
	mov	ax,13h		;Set mode 13h Initialise 320x200
	int	10h			;And tweak it to 320x400

	mov   dx,3ceh	 ;Memory division
	mov   al,5		 ;Disable bit 4 of
	out   dx,al            ;graphic mode register
	inc   dx               ;in graphics controller
	in    al,dx
	and   al,11101111b
	out   dx,al
	dec   dx

	mov   al,6		    ;And change bit 1
	out   dx,al            ;in the miscellaneous
	inc   dx               ;register
	in    al,dx
	and   al,11111101b
	out   dx,al

	mov   dx,3c4h	      ;Modify memory mode register in
	mov   al,4  		 ;sequencer controller so no further
	out   dx,al            ;address division follows in
	inc   dx               ;bitplanes, and set the bitplane
	in    al,dx            ;currently in the
	and   al,11110111b     ;bit mask register
	or    al,4
	out   dx,al

	push  0a000h			;Fill all four bitplanes with color
	pop   es				;code 00H and clear the screen
	xor   di,di
	mov   ax,di
	mov   cx,8000h
	rep   stosw

	mov   dx,3d4h	   	 ;Double pixel rows in maximum
	mov   al,9			 ;scan line register of the CRT
	out   dx,al            ;controller by disabling bit 7,
	inc   dx               ;while setting bits 0-4 to 1 to
	in    al,dx            ;change the character
	and   al,01110000b     ;height
	out   dx,al
	dec   dx               ;Return DX to CRT index register

	mov   al,14h		 ;Set double word mode using bit 6
	out   dx,al            ;in underline register of
	inc   dx               ;CRT controller
	in    al,dx
	and   al,10111111b
	out   dx,al
	dec   dx

	mov   al,17h		  ;Using bit 6 of mode control reg.
	out   dx,al             ;of CRT controller, change
	inc   dx                ;from word mode to byte mode
	in    al,dx
	or    al,01000000b
	out   dx,al
        ret
ENDP Set320x400x256

Copy_thing PROC NEAR
;{ *************************************************************** }
;{ THIS IS THE FIRST COPY LOOP, IT COPIES THE RED VALUES TO SCREEN }
;{ *************************************************************** }
  push ds
  push dx
  mov  ax, seg bs2
  mov  ds, ax
  mov  si, offset bs2
;  inc  si
  mov bx,100
  mov ax,0a000h
  mov es,ax
;  mov di,50*80
@loop_to_here:

  mov cx,5
        mov dx,3c4h   ;  { Copies in 64 byte chunks }
        push cx
        push di
        push si
        mov ax,0102h
        out dx,ax
@pl1:
        mov ah,ds:[si+12]
        mov al,ds:[si+8]
        shl eax,16
        mov ah,ds:[si+4]
        mov al,ds:[si+0]
        stosd
        mov ah,ds:[si+28]
        mov al,ds:[si+24]
        shl eax,16
        mov ah,ds:[si+20]
        mov al,ds:[si+16]
        stosd
        mov ah,ds:[si+44]
        mov al,ds:[si+40]
        shl eax,16
        mov ah,ds:[si+36]
        mov al,ds:[si+32]
        stosd
        mov ah,ds:[si+60]
        mov al,ds:[si+56]
        shl eax,16
        mov ah,ds:[si+52]
        mov al,ds:[si+48]
        stosd
        add si,64
        loop @pl1

        pop si
        pop di
        pop cx
        inc si
        push cx
        push di
        push si

        mov ax,0202h
        out dx,ax
@pl2:
        mov ah,ds:[si+12]
        mov al,ds:[si+8]
        shl eax,16
        mov ah,ds:[si+4]
        mov al,ds:[si+0]
        stosd
        mov ah,ds:[si+28]
        mov al,ds:[si+24]
        shl eax,16
        mov ah,ds:[si+20]
        mov al,ds:[si+16]
        stosd
        mov ah,ds:[si+44]
        mov al,ds:[si+40]
        shl eax,16
        mov ah,ds:[si+36]
        mov al,ds:[si+32]
        stosd
        mov ah,ds:[si+60]
        mov al,ds:[si+56]
        shl eax,16
        mov ah,ds:[si+52]
        mov al,ds:[si+48]
        stosd
        add si,64
        loop @pl2

        pop si
        pop di
        pop cx
        inc si
        push cx
        push di
        push si

        mov ax,0402h
        out dx,ax
@pl3:
        mov ah,ds:[si+12]
        mov al,ds:[si+8]
        shl eax,16
        mov ah,ds:[si+4]
        mov al,ds:[si+0]
        stosd
        mov ah,ds:[si+28]
        mov al,ds:[si+24]
        shl eax,16
        mov ah,ds:[si+20]
        mov al,ds:[si+16]
        stosd
        mov ah,ds:[si+44]
        mov al,ds:[si+40]
        shl eax,16
        mov ah,ds:[si+36]
        mov al,ds:[si+32]
        stosd
        mov ah,ds:[si+60]
        mov al,ds:[si+56]
        shl eax,16
        mov ah,ds:[si+52]
        mov al,ds:[si+48]
        stosd
        add si,64
        loop @pl3


        pop si
        pop di
        pop cx
        inc si

        push di
        push si

        mov ax,0802h
        out dx,ax
@pl4:
        mov ah,ds:[si+12]
        mov al,ds:[si+8]
        shl eax,16
        mov ah,ds:[si+4]
        mov al,ds:[si+0]
        stosd
        mov ah,ds:[si+28]
        mov al,ds:[si+24]
        shl eax,16
        mov ah,ds:[si+20]
        mov al,ds:[si+16]
        stosd
        mov ah,ds:[si+44]
        mov al,ds:[si+40]
        shl eax,16
        mov ah,ds:[si+36]
        mov al,ds:[si+32]
        stosd
        mov ah,ds:[si+60]
        mov al,ds:[si+56]
        shl eax,16
        mov ah,ds:[si+52]
        mov al,ds:[si+48]
        stosd
        add si,64
        loop @pl4
        pop si
        pop di

    add si,317
    add di,240
    dec bx
    jnz @loop_to_here

    pop dx
    pop ds
    ret
ENDP Copy_thing
END Start