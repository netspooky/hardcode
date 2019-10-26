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
stars:	mov si,1024
		push ds
		push cs
		pop ds
l1:		cmp byte [gs:si],0
		jne s11
		mov di,si
		shl di,4
		add di,400h
		rdtsc
		xor eax,[time+10]
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
		add dword [time+10],eax
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
		inc dword [time]
		mov si,1024
l3:		mov di,si
		shl di,4
		add di,400h
		fild word [di+8]
		fmul dword [vm]
		frndint
		fld dword [di+4]
		fsubrp st1,st0
		fst dword [di+4]

		xor bx,bx
		clc
		call scalc
		mov bl,2
		stc
		call scalc

		fistp word [time+8]
		mov bx,[time+4]
		add bx,60
		cmp bx,0
		js s31
		cmp bx,320
		jnc s31
		mov ax,[time+6]
		cmp ax,0
		js s31
		cmp ax,200
		jnc s31
		imul ax,320
		add ax,bx
		xchg ax,si
		xor bl,bl
		sub bl,[time+8]
		or bl,0Fh
		pop ds
		mov [si],bl
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
scalc:	fild word [di+bx]
		fimul word [sm]
		fdiv st1
		fild dword [time]
		fmul dword [tm]
		jc sc1
		fcos
		jmp sc2
sc1:	fsin
sc2:	fld1
		faddp st1,st0
		fimul word [hm]
		faddp st1,st0
		fistp word [time+bx+4]
		ret
vm:		dd 0.008
tm:		dd 0.002
sm:		dw 1000
hm:		dw 100
time:	

