;code by unic0rn/Asm Force

        org 100h
        segment .code
        mov al,13h
        int 10h
        xor ax,ax
        mov dx,03C8h
        out dx,al
        inc dx
pal:	push ax
		mov cl,al
		shr al,2
		not cl
		and cl,0Fh
		je ps1
		ror ax,1
ps1:	out dx,al
		out dx,al
		je ps2
		rol ax,1
ps2:	out dx,al
		pop ax
		inc al
		jne pal
		les bp,[bx]
		shl bp,1
		mov fs,bp
		mov bx,sm
stars:	mov si,[bx]
l1:		cmp byte [bp+si],cl
		jne s11
		mov di,si
		shl di,4
		add di,[bx]
		rdtsc
		xor eax,[bx+14]
		push ax
		cbw
		mov [di],ax
		pop ax
		mov al,ah
		cbw
		mov [di+2],ax
		mov dword [di+4],43800000h
		bswap eax
		xor ah,ah
		inc ax
		mov [di+8],ax
		inc byte [bp+si]
		add dword [bx+14],eax
s11:	dec si
		jne l1
		not cx
l2:		sub byte [fs:si],17
		jnc s21
		mov byte [fs:si],0
s21:	inc si
		loop l2
		inc dword [bx+4]
		mov si,[bx]
l3:		mov di,si
		shl di,4
		add di,[bx]
		fild word [di+8]
		fmul dword [bx-4]
		fld dword [di+4]
		fsubrp st1,st0
		fst dword [di+4]
		push bp
		xor bp,bp
scalc:	fild word [di+bp]
		fimul word [bx]
		fdiv st1
		fild dword [bx+4]
		fmul dword [bx-4]
		jc sc1
		fcos
		jmp short sc2
sc1:	fsin
sc2:	fld1
		faddp st1,st0
		fimul word [bx+2]
		faddp st1,st0
		fistp word [time+bp+4]
		inc bp
		inc bp
		cmc
		jc scalc
		pop bp
		fistp word [bx+12]
		mov ax,[bx+10]
		cmp ax,cx
		js s31
		cmp ax,200
		jnc s31
		imul ax,320
		mov dx,[bx+8]
		add dx,byte 60
		cmp dx,cx
		js s31
		cmp dx,320
		jnc s31
		add ax,dx
		xchg ax,si
		xor dl,dl
		sub dl,[bx+12]
		or dl,0Fh
		mov [fs:si],dl
		xchg ax,si
		jmp short s32
s31:	mov [bp+si],cl
s32:	dec si
		jne l3
		not cx
		xor si,si
		mov di,16
		rep fs movsb
		in al,60h
        dec al
        jnz stars
		ret
tm:		dd 0.0028
sm:		dw 768
hm:		dw 100
time:	

