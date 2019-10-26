;code by unic0rn/Asm Force

        org 100h
        segment .code
        mov al,13h
        int 10h
        xor ax,ax
        mov dx,03C8h
        out dx,al
        inc dx
		xor bx,bx
pal:	mov al,bl
		shr al,2
		mov cl,bl
		and cl,0Fh
		cmp cl,0Fh
		jne skip
		out dx,al
		out dx,al
		jmp cont
skip:	ror ax,1
		out dx,al
		out dx,al
		rol ax,1
cont:	out dx,al
		inc bl
		jne pal
		push 9000h
		pop ds
		push 0A000h
		pop es
		push 8000h
		pop gs
		mov bx,time
stars:	push ds
		push cs
		pop ds
		mov si,[bx-4]
l1:		cmp byte [gs:si],0
		jne s11
		mov di,si
		shl di,4
		add di,[bx-4]
		rdtsc
		xor eax,[bx+10]
		push ax
		xor ah,ah
		cbw
		mov [di],ax
		pop ax
		shr ax,8
		cbw
		mov [di+2],ax
		mov dword [di+4],43800000h
		bswap eax
		xor ah,ah
		inc ax
		mov [di+8],ax
		inc byte [gs:si]
		add dword [bx+10],eax
s11:	dec si
		jne l1
		pop ds
		not cx
l2:		cmp byte [si],0
		je s21
		sub byte [si],17
		jnc s21
		mov byte [si],0
s21:	inc si
		loop l2
		push ds
		push cs
		pop ds
		inc dword [bx]
		mov si,[bx-4]
l3:		mov di,si
		shl di,4
		add di,[bx-4]
		fild word [di+8]
		fmul dword [bx-8]
		fld dword [di+4]
		fsubrp st1,st0
		fst dword [di+4]
		xor bp,bp
		clc
		call scalc
		inc bp
		inc bp
		stc
		call scalc
		fistp word [bx+8]
		mov ax,[bx+6]
		cmp ax,cx
		js s31
		cmp ax,200
		jnc s31
		imul ax,320
		mov dx,[bx+4]
		add dx,60
		cmp dx,cx
		js s31
		cmp dx,320
		jnc s31
		add ax,dx
		xchg ax,si
		xor dl,dl
		sub dl,[bx+8]
		or dl,0Fh
		pop ds
		mov [si],dl
		push ds
		push cs
		pop ds
		xchg ax,si
		jmp s32
s31:	mov byte [gs:si],0
s32:	dec si
		jne l3
		pop ds
		not cx
		xor si,si
		xor di,di
		rep movsb
		in al,60h
        dec al
        jnz stars
		ret
scalc:	fild word [di+bp]
		fimul word [bx-4]
		fdiv st1
		fild dword [bx]
		fmul dword [bx-8]
		jc sc1
		fcos
		jmp sc2
sc1:	fsin
sc2:	fld1
		faddp st1,st0
		fimul word [bx-2]
		faddp st1,st0
		fistp word [time+bp+4]
		ret
tm:		dd 0.0028
sm:		dw 768
hm:		dw 100
time:	

