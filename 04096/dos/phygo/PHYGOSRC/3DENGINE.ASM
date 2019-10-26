numfces equ 100
numvxes equ 100

;render_3d:      ; si=facedata, di=temp_area
;
;        push cs
;        pop es
;
;        ; si == numfaces;facedata (8normal.8color.8v0.8v1.8v2)
;
;        lodsw           ; numfaces
;        mov cx,ax
;
;        push cx
;
;        push es ; outseg
;
;        mov di,facetemp
;        push di
;
;        ; rotated_vertices  == 16z.16x.16y.16b
;        ; di               <== cols,xy0,xy1,xy2,zsum
;
;        ;;; calc facetemp (zeds etc)
;
;       push cs
;       push cs
;        pop ds
;        pop es
;
;.l1     push cx
;        xor dx,dx
;          lodsb         ; cols: 1] normal
;          movzx bx,al
;          shl bx,3
;          mov ah,[bx+rotated_vertices+1]
;
;          lodsb         ; cols: 2] color
;                        ; use lookuptab for each material?
;          stosw
;        mov cx,3
;.l0     lodsb
;        movzx bx,al
;        shl bx,3
;        add bx,rotated_vertices  ; lea bx,[ebx*8+rotated_vertices] ?
;
;        mov ax,[bx]
;        sar ax,2
;        add dx,ax
;
;        mov al,[bx+2+1]
;        mov ah,[bx+4+1]
;        stosw
;        loop .l0
;        pop cx
;
;        mov ax,dx
;        add ah,128
;        stosw
;        loop .l1
;
;        pop si
;        pop es
;        pop cx ;numfaces
;
;        mov dx,cx
;
;        ; sort&render faces: si=facedata cols.xy0.xy1.xy2.zsum
;
;.l3     pusha
;
;        xor dx,dx
;.l2     add si,2*4
;        lodsw
;        cmp ax,dx
;        jc .c0
;                mov dx,ax ; best so far
;                mov di,si
;.c0     loop .l2
;
;        mov word [di-2],cx   ; z=min
;        push dword [di-8]    ; xy0, xy1
;        push word [di-4]     ; xy2
;        mov ax,[di-10]       ; colors
;        mov di,3
;        call recursepoly
;
;        popa
;        dec dx
;        jne .l3
;        ret
;
rotate_vertices:  ; ds:si=src es:di=dest cx=count

	mov si,vertices
	mov di,rotated_vertices
;	mov cx,5

;	pusha
;	mov ah,9
;	mov dx,debug
;	int 0x21
;	popa

.l0	push cx

	lodsw
	mov bx,ax
	lodsw
	mov cx,ax
	lodsw
	push si
	mov si,ax

	;;;roto3d -- bx.cx.si = 3dvector
	push di
	mov di,rotate_angles
	call rotopart
	xchg bx,si
	call rotopart
	xchg cx,si
	call rotopart
	pop di

	mov ax,cx
	add ah,128
	.centerx equ $-1
	stosw
	mov ax,si
	add ah,128
	.centery equ $-1
	stosw
	stosw

	pop si
	pop cx
	loop .l0

	ret

rotopart:	; [di]=angle  bx.si=2dvector

	push bx
	movzx bx,byte [di]
	shl bx,1
	mov ax,[bx+sin_table+128] 
	;imul
	mov word [roto2d.rcos],ax ;dx
	mov ax,[bx+sin_table]
	;imul
	mov word [roto2d.rsin],ax ;dx
	pop bx
	inc di

roto2d:

	call .s0
	add bp,dx
	push bp

	call .s0
	sub bp,dx

	mov bx,bp
	pop si
	ret

.s0	mov ax,32757
	.rcos equ $-2
	imul si
	mov bp,dx
	mov ax,804
	.rsin equ $-2
	imul bx
	xchg si,bx
	add bp,bp
	add dx,dx
	ret

