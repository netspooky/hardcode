;wavepatterns by musk @ qbparty 2015
;%define vsync
%define var 0
%define last_pixel var+2;
%define x var+4;
%define y var+6;
%define temp var+8;
%define tx var+10;
%define ty var+12;
%define time var+14;
%define it var+16;4

org 100h
	jmp begin
	
const4 : dd 7.120;
const16 : dd 31.61341;
constdot16 : dd 0.03125
	
begin:
	push 0a000h
	pop es
	mov al,13h
	int 10h
	
	mov bx,512;

	xor ax,ax
	mov[bx+time],ax;
	
main:
	mov word[bx+y],200
	xor di,di
rows:
	mov word[bx+x],320
	xor al,al
columns:

	mov ax,[bx+x];
	add ax,[bx+time]
	mov [bx+tx],ax;
	
	mov ax,[bx+y];
	mov [bx+ty],ax;

	mov cx,2;
	
distr:
	mov [bx+it],cx;
	
	fild word[bx+tx];
	  fild word[const4];
	   fsub;
	  fild word[bx+ty];
	    fld dword[constdot16];
	      fmul
		fild word[bx+it];
		  fmul;
		fld dword[constdot16];
		  fadd;
	  fsin
	  fld dword[const4];
	    fmul;
	  fadd
	fistp word[bx+tx];
	
	fild word[bx+ty];
	  fild word[const4];
	    fadd;
	  fild word[bx+tx];
	    fld dword[constdot16];
	      fmul
		fild word[bx+it];
		  fmul;
		fld dword[constdot16];
		  fadd;
	  fsin
	  fld dword[const4];
	    fmul;
	  fadd
	fistp word[bx+ty];
	
	mov ax,[bx+tx];
	add ax,[bx+time];
	mov [bx+tx],ax;
	
	mov ax,[bx+ty];
	add ax,[bx+time];
	mov [bx+ty],ax;
	
	loop distr;
	
	mov ax,[bx+tx];
	xor ax,[bx+ty];
	shr ax,2;
	
	imul ax,ax;
	mov cx,[bx+tx];
	add cx,[bx+ty];
	shr cx,9;
	add ax,cx;
	mov cx,[bx+time];
	shr cx,4;
	and ax,cx;
	add ax,16;
	
	add ax,[bx+last_pixel];
	shr ax,1;
	mov [bx+last_pixel],ax;
	
	
	stosb;

	dec word[bx+x];
	jne columns;
	
	dec word[bx+y];
	jne rows;
	
	inc word[bx+time];
	
	
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
	
	in al,60h
	dec al
	jnz main
	
	ret

	
		
	