org 100h
use16

mov al,13h
int 10h

mov bh,$A0
mov es,bx
mov bh,$90
mov fs,bx

mov [es:320*99+150],al
;; mov bl,al;?
lp_loop1:
 mov di,321
 mov si,199
lp_loop3:
 mov cx,318
lp_loop2:
 xor ax,ax;al=count of neighbours

cmp ah,[es:di-321]
 jne test2
 inc al

test2:
cmp ah,[es:di-320]
 jne test3
 inc al

test3:
cmp ah,[es:di-319]
jne test4
inc al

test4:
cmp ah,[es:di-1]
jne test5
inc al

test5:
cmp ah,[es:di+1]
jne test6
inc al

test6:
cmp ah,[es:di+319]
jne test7
inc al

test7:
cmp ah,[es:di+320]
jne test8
inc al

test8:
cmp ah,[es:di+321]
jne test9
inc al

test9:
mov [fs:di],al
inc di
loop lp_loop2
inc di
inc di
dec si
jne lp_loop3
;------------output to screen
xor di,di
lp_loop5:
 mov al,[fs:di]
 and al,1
 je lp_store
 mov al,$02;F;;bl;;
lp_store:
 mov [fs:di],al;stosb
 inc di
 or di,di
 jne lp_loop5
		mov	dx, 3DAh

 push fs
 pop ds
;; xor si,si
 mov cx,64000
wret:
		in	al, dx
		and	al, 8
		jz	short wret
 rep movsb
;once_again:
; inc bl
; and bl,7
; je once_again
 in	 al, 60h; AT Keyboard controller 8042.
 dec	 al
 jnz	  lp_loop1

 ret;jmp lp_loop1