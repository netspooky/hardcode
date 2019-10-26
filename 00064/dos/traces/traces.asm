;traces
;64 byte intro
;
;by frag
;http://fsqrt.blogspot.com/
;pzagrebin@gmail.com
;22-05-2012

;Another cellular automata.
;Enjoy!

org 100h
	mov al, 13h
	int 10h
	lds ax, [bx]

L:	imul si, 57
	lodsb
	or al, [si+1]
	or al, [si+320]
	or al, [si-320]
	shr al, 1
	mov [si], al
	loop L
	
R:	mov ax, 80
	imul bp, 53
	dec bp
	jp A
	neg ax
A:	shld ax, bp, 2
	dec ax
	dec ax

	shld cx, bp, 6
	inc cx
P:	add bx, ax
	mov [bx], di
	loop P
	jp R
	
	in al, 60h
	dec al
	jnz L
	ret

