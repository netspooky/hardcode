plazma_col	equ 20;цвет плазмы
letter_col	equ 33;цвет буковок
speed1	equ	2;скорости
speed2	equ	-2
speed3	equ	1
speed4	equ	2
screen equ 0a000h
;_________________________________________________________________________
;
;       
;  FIRST2 Xkb intro by Jocker/Critical Mass
;  17.11.1997
;
;_________________________________________________________________________

p486n
seg000          segment byte public 'CODE' use16
                assume cs:seg000
                org 100h
                assume es:nothing, ss:nothing, ds:nothing, fs:nothing, gs:nothing
start:
	mov     ax,13h
	int     10h
	call	instal	
sot:	
	call	wait_traice                     
	call	swap_scr

	call	plazma
	call	main 
	call	main2
	call	strup

sot2:	In   al, 60h 
	Cmp	al, 1
	Jne	sot  
                     
	Mov	ax, 0003h		; Text mode and	Leave the program.
	Int	10h                                        
	Mov	ax, 4c00h
	Int	21h  
	Ret          
stupid	db	128  
stupid2	db	0    
ypos	db	0    
ypos2	db	0    
fastcl	dw	0    
ciclo4	dw	0    
stump	db	0    
stroker:mov	ax,seg001
	mov	ds,ax
	lea	di,st1a
	lea	si,st2a
	mov	cx,7 
restr:	mov	ax,ds:[si]
	mov	ds:[di],ax
	add	di,2 
	add	si,2 
	loop	restr
	mov	ax,[fastcl]
	mov	ds:[di],ax
	mov	al,8 
	mov	[stump],al
	ret          
                     
strup:	mov	al,[stupid]
	cmp	al,254
	jne	obhod1
	call	stroker
obhod1:	mov	al,[stupid2]
	cmp	al,254
	jne	obhod2
	call	stroker
                   
obhod2:	mov	al,[stupid]
	cmp	al,244
	jl     step
	mov	al,[stupid2]
	cmp	al,244
	jl     step
	mov	al,[stump]
	dec	al 
	mov	[stump],al
                   
step:	mov	cx,8
	mov	bl,[stump]
	mov	ax,seg001
	mov	ds,ax
	mov	ax,seg001
	mov	es,ax
	lea	di,st1a
vivod:	lea	si,text
	mov	ax,ds:[di]
	add	ax,si
	mov	si,ax
	push	cx 
	push	bx 
	push	ds 
	push	es 
	push	di 
	mov	al,bl
	call	strok
	pop	di 
	pop	es 
	pop	ds 
	pop	bx 
	pop	cx 
	add	bl,8
	inc	di 
	inc	di 
	loop	vivod
	ret        
                   
strok:	mov	cx,32
	mov	bl,0
str32:	push	cx 
	push	bx 
	push	es 
	push	si 
	push	ax 
	mov	cl,es:[si]
	call	put_letter
	pop	ax 
	pop	si 
	pop	es 
	pop	bx 
	pop	cx 
	add	bl,8
	inc	si 
	loop	str32
	ret          
                     
ciclo1	db	73   
ciclo2	db	6    
cicl11	db	0    
cicl22	db	0  

        
plazma:	
	mov	al,[ciclo1]
	add	al,speed1
	mov	[ciclo1],al
	mov	[cicl11],al
	mov	al,[ciclo2]
	sub	al,speed2
	mov	[ciclo2],al
	mov	[cicl22],al
	lea	di,sinus2
	push	di   
	pop	bx   
	add	al,bl
	mov	ah,bh
	mov	di,ax
	mov	ax,seg001
	mov	ds,ax   
                   
	mov ax,cs
	mov es,ax
	lea si,bufer+32

	mov	cx,200
plzm2:	push	cx 
	mov	al,[cicl11]
	add	al,speed3
	mov	[cicl11],al
	push	di
	push	di
	pop	bx
	mov	ah,bh
	mov	di,ax
	mov	dl,ds:[di]
	mov	al,[cicl22]
	sub	al,speed4
	mov	[cicl22],al
	pop	bx
	mov	ah,bh
	mov	di,ax
	mov	al,ds:[di]
	add	al,dl
	xor	ah,ah
	xchg	ah,al
	push	di
	lea	di,plazmg
	add	ax,di

	mov	di,ax
	mov	cx,128
plzm1:	mov	ax,ds:[di]
	mov	es:[si],ax
	add	di,2
	add	si,2
	loop	plzm1
	mov	ax,64
	add	ax,si
	mov	si,ax
	pop	di
	pop	cx
	loop	plzm2
	ret

instal: 
	mov	ax,seg001
	mov	ds,ax
	lea	si,plazmg
	mov	cx,128
inst3:	push	cx
	mov	ax,128
	sub	ax,cx
	mov	bx,ax
	add	ax,si
	mov	si,ax
	mov	ax,128
	sub	ax,bx
	mov	cx,ax
	mov	al,plazma_col
inst1:	mov	ds:[si],al
	inc	si
	loop	inst1
	mov	di,si
	dec	di
	mov	cx,128
inst2:	mov	al,ds:[di]
	mov	ds:[si],al
	dec	di
	inc	si
	loop	inst2
	pop	cx
	loop	inst3
	ret
           
main:      
	mov	cx,32
	mov	ax,seg001
	mov	ds,ax
	lea	si,sinus
	mov	al,[stupid]
	cmp	al,254
	je 	newstr
	add	al,2  
	mov	[stupid],al
	xor	ah,ah 
	mov	bl,al 
	add	ax,si 
	mov	si,ax 
	mov	al,192
	shr	bl,1  
	sub	al,bl 
	mov	[ypos],al
man1:	push	cx
	push	ds
	push	si
	mov	bl,al
	mov	al,ds:[si]
	xchg	al,bl
	push	ax    
	lea	si,bufer1
	mov	ax,cx
	add	ax,si
	mov	si,ax
	mov	cl,ds:[si]
	pop	ax
	call	put_letter
	pop	dx
	pop	ds
	pop	cx
	inc	dh
	mov	si,dx
	mov	al,[ypos]
	loop	man1
	ret
newstr:	mov	al,0
	mov	[stupid],al
	lea	di,text
	mov	ax,[ciclo4]
	mov	dx,ax 
	mov	[fastcl],dx
	add	ax,di
	mov	di,ax
	lea	si,bufer1+32
	mov	cx,32
strng:	mov	al,ds:[di]
	mov	ds:[si],al
	dec	si
	inc	di
	loop	strng
	mov	al,ds:[di]
	cmp	al,255
	jne	notend
	mov	dx,-32
notend:	add	dx,32
	mov	[ciclo4],dx

	mov	ax,[fastcl]
	sub	ax,32
	cmp	ax,-32
	jne	noter1
	xor	ax,ax
noter1:	mov	[fastcl],ax
	ret

main2:	mov	cx,32
	mov	ax,seg001
	mov	ds,ax
	lea	si,sinus
	mov	al,[stupid2]
	cmp	al,254
	je	newstr2
	add	al,2
	mov	[stupid2],al
	xor	ah,ah
	mov	bl,al
	add	ax,si
	mov	si,ax
	mov	al,192
	shr	bl,1
	sub	al,bl
	mov	[ypos2],al
man2:	push	cx
	push	ds
	push	si
	mov	bl,al
	mov	al,ds:[si]
	xchg	al,bl
	push	ax
	lea	si,bufer2
	mov	ax,cx
	add	ax,si
	mov	si,ax
	mov	cl,ds:[si]
	pop	ax
	call	put_letter
	pop	dx
	pop	ds
	pop	cx
	inc	dh
	mov	si,dx
	mov	al,[ypos2]
	loop	man2
	ret
newstr2:mov	al,0
	mov	[stupid2],al
	lea	di,text
	mov	ax,[ciclo4]
	mov	dx,ax
	mov	[fastcl],dx
	add	ax,di
	mov	di,ax
	lea	si,bufer2+32
	mov	cx,32
strng2:	mov	al,ds:[di]
	mov	ds:[si],al
	dec	si
	inc	di
	loop	strng2
	mov	al,[di]
	cmp	al,255
	jne	notend2
	mov	dx,-32
notend2:add	dx,32
	mov	[ciclo4],dx
	mov	ax,[fastcl]
	sub	ax,32
	cmp	ax,-32
	jne	noter2
	xor	ax,ax
noter2:	mov	[fastcl],ax
	ret

	ret

put_letter:;печать буквы, al-Y,bl-X,cl-код символа

	mov	dx,seg001
	mov	ds,dx

	push 	ax
	mov 	ax,seg000
	mov 	es,ax	
	pop 	ax

	xor	ah,ah
	mov	dx,320
	mul	dx
	xor	bh,bh
	add	ax,bx
	lea	di,bufer+32
	add	ax,di;
	mov	di,ax 
                        
	lea	si,font1
	mov	al,cl   
	sub	al,32   
	xor	ah,ah   
	add	ax,ax   
	add	ax,ax   
	add	ax,ax   
	add	ax,si   
	mov	si,ax   
	mov	cx,8    
leep2:	push	cx      
	mov	al,ds:[si]
	mov	ah,letter_col
	mov	cx,8
leep1:	shl	al,1
	jnc	nobit
	mov	es:[di],ah
nobit:	inc	di    
	loop	leep1
	add	di,312
	pop	cx
	inc	si
	loop	leep2
	ret

wait_traice:
	Mov	dx, 3dah
@1:
	In	al, dx
	Test	al, 8
	Jnz	@1
@2:
	In	al, dx
	Test	al, 8
	Jz	@2
	Ret

swap_scr:              
	mov	ax,seg000
	mov	ds,ax
                     
	mov	ax,screen
	mov	es,ax
	lea	di,bufer
	xor 	si,si
	mov si,320*8
	mov	cx,16000
	rep	movsd   
	ret
	org 500h
bufer 	db 64000 dup (0)

seg000          ends

seg001          segment byte public 'CODE' use16
                assume cs:seg001
                org 100h
                assume es:nothing, ss:nothing, ds:seg001, fs:nothing, gs:nothing
include sinus.inc
include sinus2.inc
include font1.inc

plazmg:	db	32768 dup (0)
bufer1:	db	33 dup (32)
bufer2:	db	33 dup (32)
st1a	dw	0
st2a	dw	0
st3a	dw	0
st4a	dw	0
st5a	dw	0
st6a	dw	0
st7a	dw	0
st8a	dw	0
text:
db "                                "
db "+------------------------------+"
db "Hi PPL!                         "
db "It's my first work on PC =)     "
db "I was made it about 6 years ago "
db "But who know, maybe you like it?"
db "=)                              "
db "+------------------------------+"
db "                                "
db "Half of greetz:                 "
db "COCOON  NAH KOLOR               "
db "              SUSPEND  RAZOR1911"
db "SCOOPEX  MOONHAZARD             "
db "              AND  TAAT  FR  MFX"
db "KCN  7DUMP  YOMOMA              "
db "              UNLIMIT  BRAINWAVE"
db "                                "
db	255
seg001          ends
                end start
