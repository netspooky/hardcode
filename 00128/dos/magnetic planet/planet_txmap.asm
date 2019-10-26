;                        FASM-ART.NAROD.RU
;        ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~=>
;        ~ ___ . -=\_/=-/~|~||\/|  _     ~=>
;        ~  / / /\/ |   \_|_||  | / |/\/ ~=>
;        ~~~~~~~~~~~~~~~~~~~~|~~  ``` ~~~~~~
;         .[32/64/128/256b]. `- pouet.net ->
;
; Improved planet2.asm
; Based on Raytracing Algorithm for Sphere RAS(c=)
; XORmap texture; Grayscale palette

	org 100h
	mov al, 0x13
	int 0x10
	les di, [bx]
	mov si, 29500

	; gray palette
	mov dx, 969
A1:	out dx, al
	out dx, al
	out dx, al
	inc ax
	loop A1

C3:	mov di, 16
	mov bx, -99
C2:	mov cx, -160
C1:	mov ax, bx
	imul bx
	push ax
	mov ax, cx
	imul cx
	pop dx
	add ax, dx
	add ax, 4096			; a = x*x + y*y + 4096
	mov [si+4], ax
	mov word [si+6], 0	       ; RISK! [if remove] In this position should be 0 as default!
	mul si
	ror eax, 16
	xchg ax, dx
	ror eax, 16
	sub eax, 0x17D78400
	neg eax 			; d = C1 - a*C2
	shr ax, 1			; WOW! I take this effect accidentally!
	js nx

	  mov [si], eax 		; [si] = d
	  fild dword [si]
	  fsqrt
	  fistp word [si]
	  sub word [si], 20000
	  fild word [si]
	  fidiv dword [si+4]		; k = (sqrt(d) - 20000) / a, raytracing k.
	  mov [si], cx
	  fild word [si]
	  fmul st, st1
	  fistp word [si]		; =x

	  mov [si+2], bx
	  fild word [si+2]
	  fmul st, st1
	  fistp word [si+2]		; =y

	  finit 			; trash FPU
	  mov ah, [si]
	  mov al, [si+2]
	  add ax, bp
	  xor al, ah
	  and al, 0x1F

nx:	stosb
	inc cx
	cmp cx, 160
	jne C1
	inc bx
	cmp bl, 100
	jne C2

	inc bp
	in al, 0x60
	dec al
	jne C3
	ret
