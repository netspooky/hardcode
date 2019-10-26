; "Perfect", but not automatically relocating
; semi-universal decoder, optimised for the 512b compo.
; (relies on *no* special reg! == portable .com!)
; by -=* thE /P.A.P.+O./ (BraiN)KiLLeR *=-
;
;History
; 2004.09.15 01:30 working 77 byte version
; 2004.09.16 19:30 working 72 byte version
 org 100h
 pop	ax	; retn
 push	ax	; retn
 push	ax	; bx
 pop	bx
 push	ax	; ax
 dec	ax
 xor	ax,7e7eh
 push	ax
 pop	cx
 and	ax,4140h
 push	ax
 pop	si	; 100h
 xor	[bx+si+2eh],cl
 xor	[bx+si+32h],cl
 xor	[bx+si+3ah],cx
 xor	[bx+si+3dh],cl
 xor	[bx+si+3eh],cx
 xor	[bx+si+41h],cx
 xor	[bx+si+46h],cx
 xor	al,48h
 push	ax
 push	ax
 pop	si	; 148h
 pop	di	; 148h
 pop	ax
 inc	ax	; 1
r
 push	ax
s
z0 db	2dh;0ach
; lodsb
 cmp	al,21h
 db	72h
z1 db	7ah;0fbh
; jc	s
 and	al,3fh
 xor	al,40h
 push	ax
 pop	dx
 pop	ax
n
z2 db	51h;0d0h
 db	6bh;0eah
; shr	dl,1
 db	74h
z3 db	6eh;0efh
; jz	r
z4 db	51h;0d0h
 db	51h;0d0h
; rcl	al,1
 db	73h
z5 db	79h;0f8h
 db	2bh;0aah
; jnc	n
; stosb
 push	bx
 pop	ax
 inc	ax
z6 db	63h;0e2h
 db	73h;0f2h
; loop	short n
;
; ax=1 cx=bx=0 dh=0 es=cs=ss=ds
.end
