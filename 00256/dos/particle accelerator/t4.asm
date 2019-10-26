;%define vsync
%ifndef speed_of_camera
;%define dump
%define speed_of_camera 150
%endif

org 100h
	;mode 13h
	mov al,13h
	int 10h
	
	%define screenx bx+0
	%define screeny bx+2
	%define time bx+4	
	
	;mov bp,0*speed_of_camera
	mov bp,-60*speed_of_camera
	
	main:
		push 0a000h
		pop es
		
		mov di,bp
		and di,3
		;xor di,2
		imul di,320

		%define base 400h
		
		mov bx,base
		mov word [screeny],200
		row:
			mov word [screenx],320
			pixel:
				call function
				mov ah,al
				stosw
				stosw
				sub word [screenx],4
				jnz pixel
			add di,320*3
			sub word [screeny],4
			jnz row
		inc bp
		
		;;wait for retrace
	%ifdef vsync
        xor ax,ax
        mov dx,03DAh
    pmw1:
        in al,dx;
        and al,8
        jnz pmw1
    pmw2:
        in al,dx
        and al,8
        jz pmw2;
	%endif
		
		;keyboard check
		in al,60h
		dec al
		jnz main
		
	ret;
function:

	%define dist bx+40h
	%define pos bx+10h
	%define dir bx+20h
	%define tmp bx+30h
	
	;build dir
	fild word [screenx]	
	fisub word [11ah] ;codeconst 200 approx 160
	fstp dword [dir] 
	fild word [screeny]
	fisub word [107h] ;codeconst 104 approx 100
	fstp dword [dir+4]
	fild word [107h] ; codeconst 1024 approx 100
	fstp dword [dir+8]
	
	;normalize
	push bx
	mov cl,3
	fx0:
		fld dword [dir]
		fmul st0,st0
		add bx,4
		loop fx0
	pop bx
	fadd
	fadd
	fsqrt
	fld st0
	fld st0
	push bx
	mov cl,3
	fx1:
		fld dword [dir]
		fdivr
		fstp dword [dir]
		add bx,4
		loop fx1
	pop bx

;
;	fld dword[constthreshold];
;	fld st0
;	fld st0
;	mov cl,3
;	push bx
;	fx0:
;		fmul dword[dir];
;		fstp dword[dir];
;		add bx,4
;		loop fx0
;	pop bx
		
	mov [time],bp
	
	;build pos
	;mov [bx+4],bp
	fild word [camspeed2]
	fild word [camspeed] 
	fild word [time]
	fdiv st0,st1
	fld st0
	fmul st0,st0
	fmul
	fst dword [pos+8]
	fdiv st0,st2
	fiadd word [1e8h] ; codeconst 1219 - big number 
	fst dword [pos+4]
	fdiv st0,st2
	fstp dword [pos]
	
	;loop, 15 iterations max
	xor ax,ax
	it:
		;compute distance
		finit
		push bx
		mov cl,3
		fx4:
			fild word [const4]
			fld dword [pos]
			fprem
			fadd st0,st0
			fsub
			fmul st0,st0
			add bx,4
			loop fx4
		pop bx
		fadd
		fadd
		fsqrt
		fld1
		fsub
		fld st0
		fld st0
		
		;if distance < threshold then return
		fld dword [constthreshold]
		fcomip st0,st1
		jnc escape
	
		
		;position += distance * direction
		push bx
		mov cl,3
		fx2:
			fmul dword[dir]
			fadd dword[pos]
			fstp dword[pos]
			add bx,4
			loop fx2
		pop bx
		
		inc al
		cmp al,15
		jne it
	
	escape:
	
	;use grayscale colors from palette
	add al,16
	
	%ifdef dump
	push ax
	mov ah,02h
	mov dl,al
	int 21h
	pop ax
	%endif
	
	ret;
	
;constants
const:
constthreshold: dd 0.008;
const4:dw 2;
camspeed2: dw 4
camspeed: dw speed_of_camera*15