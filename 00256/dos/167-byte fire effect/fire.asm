; 167-byte fire effect for DOS
; /mic, 2007
; Press [ESC] to exit the program.
 
[org 0x100]

mov 	al,0x13	
int 	0x10

mov 	cx,256
xor 	ax,ax
xor 	bp,bp
mov 	dx,0x3C8
out 	dx,al
inc 	dx
@@palloop:
	and 	bp,63
	or 	ax,bp
	inc 	bp
	inc 	bp
	cmp 	cl,193
	jbe 	short @@2
	cmp 	cl,225
	jb 	short @@3
	mov 	ah,al
	jmp 	short @@store
	@@3:
	mov 	bl,al
	jmp 	short @@store
	@@2:
	mov 	bh,al
	@@store:
	mov 	al,ah
	out 	dx,al
	mov 	al,bl
	out 	dx,al
	mov 	al,bh
	out 	dx,al
	loop	@@palloop

push 	0xA000
pop 	es
push 	es
pop 	ds

@@mainloop:
 	mov 	cl,160 
 	mov 	si,13438		 	
 	mov 	di,12800		 	

 	@@xloop:
  		push 	si
  		mov 	bl,82
  		@@yloop:
   			xor 	ah,ah
   			lodsb		
   			mov 	bp,ax
   			inc 	si
   			lodsb		
   			add 	bp,ax
   			inc 	si
   			lodsb		
   			add 	bp,ax
   			mov 	al,[si+639]
   			add 	ax,bp
   			shr 	ax,2
   			jz 	$+3 
    			dec 	ax				
   			mov 	ah,al
   			add 	si,635
   			stosw
   			mov 	[di+318],ax
   			add 	di,638
   			dec 	bx
   			jnz 	short @@yloop
  
  		mov 	si,random
  		mov 	bp,dx
  		and 	bp,3
  		add 	bp,bp
  		mov 	ax,[bp+si]
  		rol 	ax,11
  		xchg 	al,ah
  		mov 	dl,al
   		mov 	[bp+si],ax
  		
  		and 	al,0xBF		
  		pop 	si 
  		mov 	[di-640],al
  		
  		inc 	si		
  		inc 	si 
  		sub 	di,52478
  		loop	@@xloop

 	in 	al,60h		
 	dec 	al
	jnz 	@@mainloop

ret

random dw 25662,56977,36314,46707



