;moss
;32 byte intro
;
;by frag/fsqrt
;http://fsqrt.blogspot.com/
;pzagrebin@gmail.com
;27-12-2011

;Growing moss.
;Enjoy!

	
org 100h
	;si = 256, di = -2
	mov al, 13h	
	int 10h
	lds bx, [bx]

L:	imul bx, 325		;imm must be > 256
	ror bx, 1
	mov al, [bx]
	or al, [bx+di]
	or al, [bx-321]
	or al, [bx+si+63]
	jz L
	sub word [bx+di], si	;one byte shorter than
				;"dec byte [bx-1]"
	jmp L
				;There are 3 bytes left,
				;i can't save another two and add esc exit
				;or find proper improvement.