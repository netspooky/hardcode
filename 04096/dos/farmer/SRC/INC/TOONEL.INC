
; toonel = 171 bytes

jak	db 1

draw_toonel:
	mov ax,Segment1 ;SegmentEkr
	mov es,ax
	mov ax,Segment2
	mov ds,ax
	mov ax,Segment3
	mov fs,ax
	mov ax,Segment0 ;1
	mov gs,ax
	xor bp,bp
	xor di,di

	mov si,200
 Lizq:

	mov cx,160
 Drawed:	
	mov bx,fs:[bp]

	mov dx,ds:[bp]
	xchg dh,bl
	add bx,liczn
	sub dx,liczn
	mov ah,gs:[bx]
	mov bx,dx
	mov al,gs:[bx]
	add al,64
	mov bl,jak
	or bl,bl
	jl kic
	xchg al,ah
 kic:	stosw
	inc bp
	inc bp
	neg jak
	loop Drawed

	neg jak

	dec si
	jnz Lizq

	ret
	
	zoom 	EQU 3002
calc_toonel:
	mov ax,Segment2
	mov fs,ax
	mov ax,Segment3
	mov ds,ax
	xor di,di
	mov si,o stosF
        mov bx,-100
 pilujY:
        mov cx,-160
 pilujX:
        mov cs:[si],cx ;<-X
        fild w cs:[si] 
        mov cs:[si],bx ;<-Y
        fild w cs:[si] 
        fpatan     
        mov w cs:[si],128
        fimul w cs:[si]
        fldpi
        fdivp st(1),st
        fistp w cs:[si]
        mov ax,cs:[si]
        mov ds:[di],al
        mov w cs:[si],zoom
        fild w cs:[si]
        mov cs:[si],cx
        fild w cs:[si]
        fmul st,st(0)
        mov cs:[si],bx
        fild w cs:[si]
        fmul st,st(0)
        faddp st(1),st
        fsqrt
        fdivp st(1),st
        fistp w cs:[si]
        mov ax,cs:[si]
        mov fs:[di],al
	inc di
        inc cx
        cmp cx,160
        jne PilujX
        inc bx
        cmp bx,100
        jne PilujY
        ret


