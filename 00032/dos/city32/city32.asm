;city32
;32 byte intro
;
;by frag
;http://fsqrt.blogspot.com/
;pzagrebin@gmail.com
;17-12-2011

;Flying over the psychedelic city.
;Enjoy!


org 100h
	mov al, 13h
	int 10h
	lds bx, [bx]

L:	lodsw
	dec si
	add ax, [si+319]
	add al, ah
	shr al, 2
	adc al, 0
	mov [si-1], al
	loop L
	imul bx, 53
	dec bx
	mov [bx], bl
	jmp L

	