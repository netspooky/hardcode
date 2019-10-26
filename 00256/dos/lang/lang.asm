org 100h

PAL equ end
PHASE equ 0
X equ 2
FRAME equ 4
TERMS equ 6

NUM_PHASES equ 8
NUM_PHASE_TERMS equ 8
NUM_PHASE_TERM_WORDS equ 4

start:
	mov		ax,13h
	int		10h

	mov		dx,PAL
	mov		di,dx
	mov		bp,dx
	
	xor		cx,cx
initpal:
	mov		ax,cx
	mul		al
	shr		ax,6
	mul		al
	shr		ax,6
	mov		bl,al
	shr		bl,1		; bl=al/2
	mov		bh,bl
	shr		bh,1		; bh=al/4
	
	mov		byte[di+0],al		; r=x
	mov		byte[di+1],bh		; g=x/4
	mov		byte[di+2],ah		; b=0

	mov		byte[di+3],bl		; r=x/2
	mov		byte[di+4],bl		; g=x/2
	mov		byte[di+5],al		; b=x

	mov		byte[di+6],al		; r=x
	mov		byte[di+7],bl		; g=x/2
	mov		byte[di+8],bh		; b=x/4
	
	add		di,9
	inc		cl
	jnz		initpal
	
	push	ds
	pop		es
	xor		bx,bx
	dec		cl
	mov		ax,1012h
	int		10h
	
	lea		di,[bp+TERMS]
	mov		cx,2*NUM_PHASE_TERM_WORDS*NUM_PHASE_TERMS*NUM_PHASES*16
initdata:
	call nextrand
	stosb
	loop initdata
	
	push	0xa000
	pop		es
	
main:
	add word[bp+FRAME],20
	xor dx,dx
	
	mov al,3*64-1
draw:
;	xor cx,cx							; not really needed
	mov	bx,99*320+160
drawframe:
	test cl,7<<2
	jnz nonewline
	add bx,320
	cmp bh,64000/256
	jnb endframe
nonewline:
	inc	word[bp+PHASE]
	lea si,[bp+TERMS]
	add si,dx
	
	fldz 
addterm:
	fild word[bp+PHASE]			; st0:=fi
	fimul word[si]				; st0:=fi*term.a
	fiadd word[si+2]			; st0:=fi*term.a+term.b
	add si,4
	fidiv word[phasediv]		; st0:=(fi*term.a+term.b)/phasediv
	fiadd word[bp+FRAME]
	fidiv word[phasediv]		; st0:=((fi*term.a+term.b)/phasediv+frame)/phasediv
	fcos						; st0:=termn=cos(st0)
	faddp st1,st0				; st0:=term0+...+term3
	dec cx
	test cl,3
	jnz addterm					; cl in [0bxxxxxx11,0bxxxxxx10,0bxxxxxx01]: add next term
	
	fimul word[bp+PHASE]
	fimul word[width]
	fidiv word[phasediv]			; st0:=(width*PHASE/phasediv)*(term0+...+term3)	
	fistp word[bp+X]			
	
	xchg di,ax
	call nextrand
	test al,15					; xchg does not alter flags
	xchg di,ax
	jnz nostore

	mov di,bx
	add di,word[bp+X]
	stosb
nostore:
	jmp drawframe
endframe:
	dec al
	xor cx,cx
	mov word[bp+PHASE],cx
	add dx,2*NUM_PHASE_TERM_WORDS*NUM_PHASE_TERMS
	
	cmp si,end+(2*NUM_PHASES*NUM_PHASE_TERMS*NUM_PHASE_TERM_WORDS)
	jb draw
	
	
	
	mov ch,2
fade:
	call nextrand
	mov di,ax
	es sub byte [di],3
	jnc store
	es add byte [di],3
	jmp fade					; try again
store:
	loop fade

	
	mov ah,1
	int 16h
	jnz exit

	jmp main
	
exit:	
	mov ax,3
	int 10h
	
nextrand:
	imul eax,eax,3
	bswap eax
		
	ret
phasediv:
	dw 0x04ff
width:
	dw 60/4
end:
