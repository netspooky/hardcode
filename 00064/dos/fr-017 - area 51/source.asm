; fr-017: area 51 - sources for all kinds of different builds
; (c) ryg/farbrausch 2002
; play around a bit with the defines - if anyone manages a <51
; bytes rotzoom with real rotation & zoom, feel free to contact
; me at: fg@farb-rausch.de

bits      16

section   .text
org       0x100

%ifdef  COMPAT
start   push  word 09fc3h
		pop	  ds
%else
start   lds   bp, [bx]
%endif
    
    	mov   al, 013h
    	int   010h

%ifdef PAL
    	mov   dx, 03c9h
pallp   out	  dx, al
		out	  dx, al
%ifdef BUNT
		push  ax
        ror   al, cl
%endif
        out	  dx, al
%ifdef BUNT
		pop   ax
%endif
        inc	  ax
        jnz	  pallp
%endif

frame	mov	  sp, 64975
	    mov   ax, bx
	    imul  sp
	    add   si, dx
	    mov   ax, si
	    imul  sp
	    sbb   bx, dx

	    imul  di 
	    mov	  di, sp

ylp		mov   cx, 320

	    push  ax
	    push  dx

%ifdef FAST
xlp 	xor	  ax, dx
	    mov	  [di], ah
	    xor	  ax, dx
%else
xlp 	mov	  [di], ah
	    xor	  [di], dh
%endif
	    dec	  di
	    jz    frame
	    add   ax, bx
	    add   dx, si

	    loop  xlp

	    pop   dx
	    pop   ax

	    add   ax, si
	    sub   dx, bx

	    jmp   short ylp
