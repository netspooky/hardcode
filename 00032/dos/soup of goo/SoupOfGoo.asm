
;;
;;  "Soup of goo"
;; 
;;  A small 32 byte intro by skurk/depth
;;  Only tested in DOSBox
;;
;;  Let it run for a couple of seconds, the goo soup will appear
;;  and continue zooming into it.
;;
;;  Easter egg: Comment out the "neg cl" line and enable
;;  the seed pixel line for a petri dish instead.
;;

bits 16
org 100h

start:	mov al,13h		; 320x200 chunky
	int 10h			; init mode
	lds bx,[bx]		; bx now points to the screen

;	mov [bx],bx		; set a seed pixel
main:
	imul bx,byte 41		; pseudo-randomize
	jz short ng

	mov cl,[bx+321]		; take lower right pixel
	adc cl,[bx+319]		; and lower left
	neg cl			; invert CL
	shr cl,1		; divide them by two

ng:
	mov [bx],cl		; and store the result here

	dec bx			; next pixel

	in al,60h		; ESC?
	dec ax			; ESC key has scancode=1, so decrementing it..
	jnz main		; ..and if it's not zero, key has not been pressed.
	ret

