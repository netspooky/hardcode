org 100h
use16

mov al,13h
int 10h

mov bh,$A0
mov es,bx
mov bh,$90
mov fs,bx

mov [es:320*99+150],al
lp_loop1:
 mov di,321
 mov bx,199
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
dec bx
jne lp_loop3
;------------output to screen
xor di,di
lp_loop5:
 mov al,[fs:di]
 and al,1
; je lp_store
; mov al,$0F
lp_store:
 stosb
 or di,di
 jne lp_loop5
 je lp_loop1