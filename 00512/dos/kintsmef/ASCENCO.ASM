; Encoder for the
; "Perfect", but not automatically relocating
; semi-universal decoder, optimised for the 512b compo.
; (relies on *no* special reg! == portable .com!)
; by -=* thE /P.A.P.+O./ (BraiN)KiLLeR *=-
; 2004.09.15.
 org 100h
cnt equ 326	; (512-77)*(6/8)
 mov	dx,offset n0
 mov	ax,3d00h
 int	21h
 jc	err
 xchg	ax,bx
 mov	dx,offset buf0
 mov	cx,cnt
 mov	ah,3fh
 int	21h
 xchg	ax,cx
 mov	ah,3eh
 int	21h
;
 mov	si,offset buf0
 mov	di,offset buf1
 mov	bl,20h
l0
 jcxz	el0
 dec	cx
 lodsb
 stc
 rcl	al,1
 jmp	short s0
l1
 shl	al,1
 jz	l0
s0
 rcr	bl,1
 jnc	l1
 shr	bl,1
 shr	bl,1
 or	bl,40h
 cmp	bl,7fh
 jnz	s1
 mov	bl,3fh
s1
 mov	[di],bl
 inc	di
 mov	bl,20h
 jmp	short l1
el0 
 xchg	ax,bx
 cmp	al,20h
 jz	s2
l2
 shr	al,1
 jnc	l2
 shr	al,1
 shr	al,1
 or	al,40h
 stosb
s2
;
 mov	dx,offset n1
 xor	cx,cx
 mov	ah,3ch
 int	21h
 jc	err
 xchg	ax,bx
 mov	dx,offset buf1
 mov	cx,di
 sub	cx,offset buf1
 mov	ah,40h
 int	21h
 mov	ah,3eh
 int	21h
 mov	dx,offset ok_
end
 mov	ah,9
 int	21h
 ret
err
 mov	dx,offset e_
 jmp	short end
;
n0 db "IN.COM",0
n1 db "OUT.TXT",0
e_ db "Error!$"
ok_ db "OK!$"
buf0	dup 512,?
buf1	dup 512,?
.end
