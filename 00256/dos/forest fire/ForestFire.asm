org 100h
use16
empty =0
tree = 2
burn=4
 mov al,13h
 int 10h
;o=0A000(es),n=8000(ds)
 mov bh,0A0h
 mov es,bx
 mov bh,080h
 mov ds,bx
;;;; xor si,si
doi:
 mov di,321
 mov dx,198
ylp:
 mov cx,319
;; push di
xlp:
 mov bx,burn+256*tree;BH=tree,BL=burn
 mov ah,[es:di]
 or ah,ah;cmp al,empty
 jne case2
;    Select o(x,y)
;      Case 0:
;        If 655>Random(65536)
;          n(x,y) = 1
;        EndIf
 call perturb
 cmp bp,655
 jnc next
  mov byte [ds:di],bh;tree

case2:
; Case 2:
;                n(x,y) = 0
 cmp ah,bl;burn
 jne case1

 mov [ds:di],dh;empty
; jmp next;?
 
 
;Case 1:
;                If f > Random(65536)/65536 Or o(x-1,y)=2 Or o(x+1,y)=2 Or o(x-1,y-1)=2 Or o(x,y-1)=2 Or o(x+1,y-1)=2 Or o(x-1,y+1)=2 Or o(x,y+1)=2 Or o(x+1,y+1)=2
;                  n(x,y) = 2
;                EndIf
case1:
 cmp ah,bh;tree
 jne next
; mov bl,burn
 call perturb

 cmp bl,[es:di-321]
 JE put2
 cmp bl,[es:di-320]
 JE put2
 cmp bl,[es:di-319]
 JE put2

 cmp bl,[es:di+321]
 JE put2
 cmp bl,[es:di+320]
 JE put2
 cmp bl,[es:di+319]
 JE put2

 cmp bl,[es:di-1]
 JE put2
 cmp bl,[es:di+1]
 JE put2

 cmp bp,6
 Jnc next;put2

put2:
 mov byte [ds:di],bl;burn
next:
 inc di
 loop xlp

;; pop di
;; add di,320

 inc di;;;add di,1
 dec dl
 jne ylp

mov dx,03DAh
wret:
 in al,dx
 and al,8
 jz short wret

;;;; push si
 xor si,si
 xor di,di
 mov ch,0FAh;;mov cx,64000
 rep movsb
;;;; pop si
 
  in al, 60h
  dec al
  jnz doi

; jmp doi

 perturb:
 xor bp,0AA55h
 shl bp,1
 adc bp,0118h
 ret
