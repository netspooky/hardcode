; Mikolaj Felix 29/12/2000
; mfelix@polbox.com

; pallete routine fixed on 30/04/2001

.model tiny
.386c
.code
org 100h

start:
	finit
	mov ax,cs
	mov ds,ax
	mov es,ax
	
	call alloc_screen_buffer
	call clear_screen_buffer
	
	mov ax,13h
	int 10h
	call inicjuj_palete
	call inicjuj_punkty
petla:
	call wykonaj_punkty
	call blur
	
	call copy_screen_buffer
	call wait_for_frame
	call wait_for_frame

	inc word ptr licznik
	cmp word ptr licznik,256
	jb licznik_dalej
	mov word ptr licznik,0
	call inicjuj_palete
	call inicjuj_punkty

licznik_dalej:
	in al,60h
	cmp al,1
	jne petla

	mov ax,03h
	int 10h
	
	call free_screen_buffer
	mov ah,4ch
	int 21h
	ret

inicjuj_palete proc
	mov dx,03c8h
	xor ax,ax
	out dx,al
	inc dx
	mov cx,64

	cmp paleta_tryb,0
	je o_kolor1
	cmp paleta_tryb,1
	je z_kolor1

n_kolor1:
	xor al,al
	out dx,al
	out dx,al
	mov al,ah
	out dx,al
	inc ah
	mov al,ah
	loop n_kolor1

	mov cx,64
	xor ax,ax
n_kolor2:
	xor al,al
	out dx,al
	mov al,ah
	out dx,al
	mov al,63
	out dx,al
	inc ah
	loop n_kolor2

	mov cx,64
	xor ax,ax
n_kolor3:
	mov al,ah
	out dx,al
	mov al,63
	out dx,al
	out dx,al
	inc ah
	loop n_kolor3

	mov cx,64
	mov al,63
n_kolor4:
	out dx,al
	out dx,al
	out dx,al
	loop n_kolor4
	mov paleta_tryb,0
	ret
	
o_kolor1:
	out dx,al
	xor al,al
	out dx,al
	out dx,al
	mov al,ah
	inc ah
	loop o_kolor1

	xor ax,ax
	mov cx,64
o_kolor2:
	mov al,63
	out dx,al
	mov al,ah
	out dx,al
	xor al,al
	out dx,al
	inc ah
	loop o_kolor2

	xor ax,ax
	mov cx,64
o_kolor3:
	mov al,63
	out dx,al
	out dx,al
	mov al,ah
	out dx,al
	inc ah
	loop o_kolor3

	mov al,63
	mov cx,64
o_kolor4:
	out dx,al
	out dx,al
	out dx,al
	loop o_kolor4
	mov paleta_tryb,1
	ret

z_kolor1:
	xor al,al
	out dx,al
	mov al,ah
	out dx,al
	xor al,al
	out dx,al
	inc ah
	loop z_kolor1

	xor ax,ax
	mov cx,64
z_kolor2:
	xor al,al
	out dx,al
	mov al,63
	out dx,al
	mov al,ah
	out dx,al
	inc ah
	loop z_kolor2

	xor ax,ax
	mov cx,64
z_kolor3:
	mov al,ah
	out dx,al
	mov al,63
	out dx,al
	out dx,al
	inc ah
	loop z_kolor3

	mov al,63
	mov cx,64
z_kolor4:
	out dx,al
	out dx,al
	out dx,al
	loop z_kolor4
	mov paleta_tryb,2
	ret
endp

blur proc
	push es
	mov ax,buffer_seg
	mov es,ax
	xor di,di
	xor eax,eax
	mov cx,320/4
	cld
	rep stosd

	xor bx,bx
blur_skok:
	mov al,es:[di-1]
	mov bl,es:[di-320]
	add ax,bx
	mov bl,es:[di+1]
	add ax,bx
	mov bl,es:[di+320]
	add ax,bx
	shr ax,2
	jz blur_dalej
	dec al
	mov es:[di],al
blur_dalej:
	inc di
	cmp di,64000-320
	jne blur_skok

	xor eax,eax
	mov cx,320/4
	rep stosd
	pop es
	ret
endp

inicjuj_punkty proc
	mov si,offset punkt_tab
	mov di,offset punkt_kol
	mov cx,MAX_P
losowanie:
	fldz
	fstp _fpom32
	mov eax,_fpom32
	mov dword ptr [si],eax		;x
	mov dword ptr [si+4],eax	;y
	mov dword ptr [si+8],eax	;z
	
	mov los_max,16
	call losuj
	sub ax,8
	mov _fpom16,ax
	fild _fpom16
	fstp _fpom32
	mov eax,_fpom32
	mov dword ptr [si+12],eax	;vx

	call losuj
	sub ax,8
	mov _fpom16,ax
	fild _fpom16
	fstp _fpom32
	mov eax,_fpom32
	mov dword ptr [si+16],eax	;vy

	call losuj
	sub ax,8
	mov _fpom16,ax
	fild _fpom16
	fstp _fpom32
	mov eax,_fpom32
	mov dword ptr [si+20],eax	;vz

	mov los_max,5
	call losuj
	add ax,1
	mov _fpom16,ax
	fild _fpom16
	fstp _fpom32
	fld1
	fdiv _fpom32
	fstp _fpom32
	mov eax,_fpom32
	mov dword ptr [si+24],eax	;grav

	mov los_max,128
	call losuj
	add al,128
	mov byte ptr [di],al

	inc di
	add si,28
	dec cx
	jnz losowanie
	ret
endp

losuj proc
	xor ax,ax
	out 70h,al
	in al,71h
	cbw
	shl ax,6
	mov bx,los_pom
	add bx,9248h
	add bx,ax
	ror bx,3
	mov los_pom,bx
	mov ax,los_max
	sub ax,los_min
	mul bx
	mov ax,dx
	add ax,los_min			; ax liczba losowa
	ret
endp

wykonaj_punkty proc
	push es
	mov ax,buffer_seg
	mov es,ax
	mov si,offset punkt_tab
	mov di,offset punkt_kol
	mov cx,MAX_P
p_skok:
	mov al,byte ptr [di]
	cmp al,0
	je k_dalej
	dec al
	mov byte ptr [di],al
k_dalej:
	mov eax,dword ptr [si]	;x
	mov _fpom32,eax
	fld _fpom32
	mov eax,dword ptr [si+12]	;vx
	mov _fpom32,eax
	fadd _fpom32
	fstp _fpom32
	mov eax,_fpom32
	mov dword ptr [si],eax		;punkt.x+=punkt.vx

	mov eax,dword ptr [si+4]	;y
	mov _fpom32,eax
	fld _fpom32
	mov eax,dword ptr [si+16]	;vy
	mov _fpom32,eax
	fadd _fpom32
	fstp _fpom32
	mov eax,_fpom32
	mov dword ptr [si+4],eax	;punkt.y+=punkt.vy

	mov eax,dword ptr [si+8]	;z
	mov _fpom32,eax
	fld _fpom32
	mov eax,dword ptr [si+20]	;vz
	mov _fpom32,eax
	fadd _fpom32
	fstp _fpom32
	mov eax,_fpom32
	mov dword ptr [si+8],eax	;punkt.z+=punkt.vz
	
	mov eax,dword ptr [si+12]	;vx
	mov _fpom32,eax
	fld _fpom32
	fmul delta_v
	fstp _fpom32
	mov eax,_fpom32
	mov dword ptr [si+12],eax	;punkt.vx*=0.95

	mov eax,dword ptr [si+16]	;vy
	mov _fpom32,eax
	fld _fpom32
	fmul delta_v
	fstp _fpom32
	mov eax,_fpom32
	mov dword ptr [si+16],eax	;punkt.vy*=0.95

	mov eax,dword ptr [si+20]	;vz
	mov _fpom32,eax
	fld _fpom32
	fmul delta_v
	fstp _fpom32
	mov eax,_fpom32
	mov dword ptr [si+20],eax	;punkt.vz*=0.95

	mov eax,dword ptr [si+4]	;y
	mov _fpom32,eax
	fld _fpom32
	mov eax,dword ptr [si+24]	;grav
	mov _fpom32,eax
	fadd _fpom32
	fstp _fpom32
	mov eax,_fpom32
	mov dword ptr [si+4],eax	;punkt.y+=punkt.g

	mov ebx,dword ptr [si+8]	;z
	mov _fpom32,ebx
	fld _fpom32
	fadd dist
	fstp _fpom32
	mov ebx,_fpom32			;ebx punkt.z+dist

	mov eax,dword ptr [si]	;x
	mov _fpom32,eax
	fld _fpom32
	fmul dist
	mov _fpom32,ebx
	fdiv _fpom32
	fadd korekta_x
	fistp _fpom16
	mov dx,_fpom16			;dx x2d=((punkt[i].x*dist)/(punkt[i].z+dist))+160	
	
	mov eax,dword ptr [si+4]
	mov _fpom32,eax
	fld _fpom32
	fmul dist
	mov _fpom32,ebx
	fdiv _fpom32
	fadd korekta_y
	fistp _fpom16
	mov ax,_fpom16			;ax y2d=((punkt[i].y*dist)/(punkt[i].z+dist))+100

	cmp dx,0			
	jb p_nast
	cmp dx,318
	ja p_nast
	cmp ax,0
	jb p_nast
	cmp ax,198
	ja p_nast			;x2d>=2 && x2d<=317 && y2d>=2 && y2d<=197
	
	mov bx,ax
	shl ax,6
	shl bx,8
	add bx,ax
	add bx,dx

	mov al,byte ptr [di]
	mov ah,al
	mov word ptr es:[bx],ax
	mov word ptr es:[bx+320],ax
p_nast:
	inc di
	add si,28
	dec cx
	jnz p_skok
	pop es
	ret
endp

include graphlib.asm

MAX_P equ 600
licznik dw 0
paleta_tryb dw 0

korekta_x dd 160.0
korekta_y dd 100.0
dist dd 600.0
delta_v dd 0.95
_fpom32 dd 0.0
_fpom16 dw 0

los_pom dw ?
los_min dw 0
los_max dw 0

punkt_kol db MAX_P dup(?)
punkt_tab dd MAX_P dup(?,?,?,?,?,?,?)	;x,y,z, vx,vy,vz, grav	(28b)

end start