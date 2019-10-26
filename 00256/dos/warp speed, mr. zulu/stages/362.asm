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
		push 7000h
		pop fs
		push 8000h
		pop gs
stars:	mov si,1024
l1:		cmp byte [gs:si],0
		jne s11
		mov di,si
		shl di,4
		rdtsc
		xor eax,[cs:time+10]
		push ax
		xor ah,ah
		cbw
		mov [fs:di],ax
		pop ax
		shr ax,8
		cbw
		mov [fs:di+2],ax
		mov dword [fs:di+4],43800000h
		bswap eax
		xor ah,ah
		inc ax
		mov [fs:di+8],ax
		inc byte [gs:si]
		add dword [cs:time+10],eax
s11:	dec si
		jne l1
		mov cx,64000
l2:		cmp byte [si],0
		je s21
		sub byte [si],17
		jnc s21
		mov byte [si],0
s21:	inc si
		loop l2
		inc dword [cs:time]
		mov si,1024
l3:		mov di,si
		shl di,4
		fild word [fs:di+8]
		fmul dword [cs:vm]
		frndint
		fld dword [fs:di+4]
		fsubrp st1,st0
		fst dword [fs:di+4]
		;z
		fild word [fs:di]
		;x z
		fimul word [cs:sm]
		;1000*x z
		fdiv st1
		;1000*x/z z
		fild dword [cs:time]
		;time 1000*x/z z
		fmul dword [cs:tm]
		;time*0.0005 1000*x/z z
		fcos
		;cos(time*0.0005) 1000*x/z z
		fld1
		faddp st1,st0
		;cos(time*0.0005)+1 1000*x/z z
		fimul word [cs:wm]
		;(cos(time*0.0005)+1)*160 1000*x/z z
		faddp st1,st0
		;1000*x/z+(cos(time*0.0005)+1)*160 z
		fistp word [cs:time+4]
		;z
		fild word [fs:di+2]
		;y z
		fimul word [cs:sm]
		;1000*y z
		fdiv st1
		;1000*y/z z
		fild dword [cs:time]
		;time 1000*x/z z
		fmul dword [cs:tm]
		;time*0.0005 1000*y/z z
		fsin
		;sin(time*0.0005) 1000*y/z z
		fld1
		faddp st1,st0
		;sin(time*0.0005)+1 1000*y/z z
		fimul word [cs:hm]
		;(sin(time*0.0005)+1)*100 1000*y/z z
		faddp st1,st0
		;1000*y/z+(sin(time*0.0005)+1)*100 z
		fistp word [cs:time+6]
		;z
		fistp word [cs:time+8]
		;\o/
		mov bx,[cs:time+4]
		cmp bx,0
		js s31
		cmp bx,320
		jnc s31
		mov ax,[cs:time+6]
		cmp ax,0
		js s31
		cmp ax,200
		jnc s31
		imul ax,320
		add ax,bx
		xchg ax,si
		xor bl,bl
		sub bl,[cs:time+8]
		or bl,0Fh
		mov [si],bl
		xchg ax,si
		jmp s32
s31:	mov byte [gs:si],0
s32:	dec si
		jne l3
		mov cx,64000
		xor si,si
		xor di,di
		rep movsb
		in al,60h
        dec al
        jnz stars
		ret
vm:		dd 0.008
tm:		dd 0.002
sm:		dw 1000
wm:		dw 160
hm:		dw 100
time:	

