DoManyTexture:
	push	cs
	pop	ds

	mov	si, OFFSET Sorted + 1404
	mov	cx, 703
@NextPoly:
	mov	di, [si]

	mov	bx, [plan.di]
	mov	ax, [Rpoints.bx]
	mov	X1, ax
	mov	ax, [Rpoints.bx+2]
	mov	Y1, ax

	call	getnorms
	or	glas, 0
	jz	@NoGlas1
	add	ax, X1
	add	dx, Y1
@NoGlas1:
	mov	tx1, ax
	mov	ty1, dx

	mov	bx, [plan.di+2]
	mov	ax, [Rpoints.bx]
	mov	X2, ax
	mov	ax, [Rpoints.bx+2]
	mov	Y2, ax

	call	getnorms
	or	glas, 0
	jz	@NoGlas2
	add	ax, X2
	add	dx, Y2
@NoGlas2:
	mov	tx2, ax
	mov	ty2, dx

	mov	bx, [plan.di+4]
	mov	ax, [Rpoints.bx]
	mov	X3, ax
	mov	ax, [Rpoints.bx+2]
	mov	Y3, ax

	call	getnorms
	or	glas, 0
	jz	@NoGlas3
	add	ax, X3
	add	dx, Y3
@NoGlas3:
	mov	tx3, ax
	mov	ty3, dx

	pusha
	call	textpoly
	popa

	sub	si, 2
	dec	cx
	jnz	@NextPoly
	ret

getnorms:
	mov	ax, [Rnormals.bx]
	mov	dx, [Rnormals.bx+2]
	or	glas, 0
	jz	@NoGlas
	sar	ax, 8
	sar	dx, 8
	jmp	@endN

@NoGlas:sar	ax, 6
	sar	dx, 6
	add	ax, 128
	add	dx, 128
@endN:
	ret


textpoly:
    mov    flag3, 0

    mov    si, offset x1
    mov    di, offset x2

    mov    byte ptr cs:[@@labeltje+1],0c7h ;	maak weer di
    mov    cx, 3

@@loop:

    mov    ax, [si+6]
    cmp    ax, [di+6]
    js	  @NoSwap1

    mov    bx, 18

@@xchgloop:

    mov    ax, [si+bx]
    xchg   ax, [di+bx]
    mov    [si+bx], ax

    sub    bl,6
    jns    @@xchgloop
    xor    flag3,1
@NoSwap1:


@@labeltje:
    add     di,2
    dec     byte ptr cs:[@@labeltje+1] ;    maak van di si

    loop    @@loop

    mov    cx, [di+6]  ; y3
    sub    cx, [si+6-2]  ; y1
    jz	  @endpoly
    movsx  ecx, cx

    mov    ax, [di]	   ; x3     ; X3r := (X3-X1)*256 DIV (Y3-Y1)
    sub    ax, [si-2]	   ; x1

    movsx  ebx, ax
    Call   Imul256
    mov    [si-36], eax 	 ;x3r
    mov    [si-32], eax 	 ;x4r


    mov    ax, [si+6] ; y2     ; X4 := (Y2-Y1)*(X3-X1)	 DIV (Y3-Y1) + X1
    sub    ax, [si+4] ; y1     ;       ((y2-y1)/(y3-y1)) * x3-x1 + x1

    movsx  eax, ax
    mov    ebp, eax	   ;y2y1

    imul   eax, ebx
    cdq
    idiv   ecx

    movzx  ebx, word ptr [si-2] ; x1
    add    eax, ebx
    mov    [si-4] , ax	      ;X4


    mov    byte ptr [si-45], 0

    cmp    [si], ax	; x2  if x2<x4 then links = true.
    jns    @nietlinks
    mov    byte ptr [si-45], 1

    jmp    @wellinks
@nietlinks:
    mov    byte ptr [si-45], 0

    mov    ax, [di+12]	 ; Tx3	 Tx1r := (Tx3-Tx1)*256 DIV (Y3-Y1)
    sub    ax, [si+12-2] ;tx1

    Call   Imul256

    mov    dword ptr [tx1r-4], eax
    mov    [si-28], eax 	    ;tx2r

    mov    ax, [di+18]		   ; ty3     ; Ty1r := (Ty3-Ty1)*256 DIV (Y3-Y1)
    sub    ax, [si+18-2]	   ; ty1

    Call   Imul256

    mov    dword ptr [ty1r-4], eax
    mov    [si-24], eax 	      ; ty2r

@wellinks:

    mov   al, flag3
    cmp   al, links
    jz	  @endpoly

    movzx  eax, word ptr [di+12]   ; tx3    Tx4 := (Y2-Y1)*(Tx3-Tx1) DIV (Y3-Y1) + Tx1
    movzx  ebx, word ptr [si+12-2] ; Tx1
    call   Divproc
    mov    [di+20], ax		   ; tx4

    movzx  eax, word ptr [di+18]    ;Ty3    Ty4 := (Y2-Y1)*(Ty3-Ty1) DIV (Y3-Y1) + Ty1
    movzx  ebx, word ptr [si+18-2]  ;Ty1
    call   Divproc
    mov    [di+22], ax		    ; ty4

    mov    cx, [si-4]		 ; X4
    sub    cx, [si]		 ; X2
    jz	  @nostep

    movsx  ecx, cx

    mov    ax, [di+20]		 ; Tx4 Xstep := (Tx4-Tx2)*256 DIV (X4-X2)
    sub    ax, word ptr [si+12]  ; Tx2

    Call   Imul256

    mov    dword ptr cs:[@self5-4], eax

    mov    ax, [di+22]		 ; ty4	Ystep := (Ty4-Ty2)*256 DIV (X4-X2)
    sub    ax, word ptr [si+18]  ; Ty2

    Call   Imul256

    mov    dword ptr cs:[@self6-4], eax
@nostep:

    mov    cx, [di+6]	; Y3
    sub    cx, [si+6]	; Y2
    jz	  @flatunder
    movsx  ecx, cx

    mov    ax, [di]	; x3  X1r := (X3-X2)*256 DIV (Y3-Y2)
    sub    ax, [si]	; x2

    Call   Imul256

    mov    [si-44], eax     ;x1r

    mov    eax, dword ptr [tx1r-4]	   ; waarom dit moet is mij niet duidelijk maar anders werkt het niet.
    mov    [si-28], eax

    mov    eax, dword ptr cs:[ty1r-4]
    mov    [si-24], eax      ;ty2r

    cmp    byte ptr [si-45], 1
    jne    @flatunder

    mov    ax, [di+12]	      ; tx3	; Tx2r := (Tx3-Tx2)*256 DIV (Y3-Y2)
    sub    ax, [si+12]	      ; Tx2

    Call   Imul256

    mov    [si-28], eax

    mov    ax, [di+18]	       ; ty3 Ty2r := (Ty3-Ty2)*256 DIV (Y3-Y2)
    sub    ax, [si+18]	       ; ty2

    Call   Imul256

    mov    [si-24],eax		;ty2r
@flatunder:

    mov    cx, [si+6]	; y2
    sub    cx, [si+6-2] ; y1
    jz	   @flatabove
    movsx  ecx, cx
    cmp    byte ptr [si-45],1
    jne    @nietlinks2
    mov    ax, [si+12]	       ; tx2   ;[tx1r-4] := (Tx2-Tx1)*256 DIV (Y2-Y1)
    sub    ax, [si+12-2]       ; tx1

    Call   Imul256

    mov    dword ptr cs:[tx1r-4], eax

    mov    ax, [si+18]	       ; ty2  Ty1r := (Ty2-Ty1)*256 DIV (Y2-Y1)
    sub    ax, [si+18-2]       ; ty1

    Call   Imul256

    mov    dword ptr cs:[ty1r-4], eax
@nietlinks2:

    mov    ax, [si]   ; x2  Ty1r := (X2-X1)*256 DIV (Y2-Y1)
    sub    ax, [si-2] ; x1

    Call   Imul256

    cmp    eax, [si-36]     ;x3r
    js	   @Noswap4
    xchg   eax, [si-36]    ;x3r
    mov    ebx, [si-44]    ;x1r
    mov    [si-44], eax        ;x1r
    mov    [si-32], ebx        ;x4r
@noswap4:
    mov    [si-40], eax 	 ;x2r

    movzx  eax, word ptr [si-2] ;x1
    shl    eax, 8
    mov    [si-12], eax 	     ;xt1
    mov    [si-8 ], eax 	     ;xt2

    xor    eax, eax
    mov    ax, [si+12-2]	; tx1
    shl    ax, 8
    mov    [si-20], eax 	   ; txt1
    mov    ax, [si+18-2]	; ty1
    shl    ax, 8
    mov    [si-16], eax 	   ;tyt1

    jmp    @start
@flatabove:

    movzx  eax, word ptr [si]	; x2
    shl    eax, 8
    mov    [si-12], eax 	    ;xt1

    movzx  eax, word ptr [si-2] ; x1
    shl    eax, 8
    mov    [si-8], eax		   ;xt2

    xor    eax, eax
    mov    ax, [si+12]		; tx2
    shl    ax, 8
    mov    [si-20], eax 	   ; txt1
    mov    ax, [si+18]		; ty2
    shl    ax, 8
    mov    [si-16], eax 	   ; tyt1

    mov    eax, [si-44] 	    ; x1r
    cmp    eax, [si-32] 	    ; x4r
    jns    @start
    xchg   eax, [si-32] 	    ; x4r
    mov    [si-44], eax 	    ; x1r

    mov    eax, [si-12] 	    ; xt1
    xchg   eax, [si-8 ] 	    ; xt2
    mov    [si-12], eax 	    ; xt1

    xor    eax, eax
    mov    ax, [si+12-2]	; tx1
    shl    ax, 8
    mov    [si-20], eax 	   ; txt1
    mov    ax, [si+18-2]	;ty1
    shl    ax, 8
    mov    [si-16], eax 	   ; tyt1

@start: 			; start drawing triangle
    mov    es, [si+26]	     ; ScrSeg
    mov    fs, [si+28]	     ; TextureSeg

    mov    ax, 320
    mov    cx, [si+6-2]       ; y1
    mul    cx
    mov    di, ax

    ;dus nu wel gebruiken
    ;si staat op x2

    mov    ebp, [si-36]

@nextline:
    cmp    cx, [si+6]
    jne    @Nochange

    mov    eax, [si-44]       ; X1r
    mov    [si-40], eax       ; X2r

    mov    ebp, [si-32]       ; x4r

    mov    eax, [si-28] 	    ; tx2r
    mov    dword ptr cs:[tx1r-4], eax

    mov    eax, [si-24] 	    ; ty2r
    mov    dword ptr cs:[ty1r-4], eax
@Nochange:

    push   cx

    mov    ebx, [si-12] 	      ; xt1
    shr    ebx, 8				 ; X start in bx

    mov    ecx, [si-8 ] 	      ; xt2
    shr    ecx, 8				 ; X einde in cx

    mov    eax, [si-40] 	      ; x2r
    add    [si-12], eax 	      ; xt1

    add    [si-8 ], ebp 	      ; xt2

    mov    eax, [si-20] 		; Texture X
    mov    edx, [si-16] 			     ; Texture Y

    add    [si-20], 0f0f0f0fh	      ; Tx1r
Tx1r:
    add    [si-16], 0f0f0f0fh	    ; Ty1r
Ty1r:

    sub    cx, bx
    js	  @skip
    inc    cx

    push   di
    add    di, bx

@nextpixel:
    mov    bl, ah
    mov    bh, dh
    add    eax, 0f0f0f0fh   ; + Xstep  -selfmodifying!
@self5:
    add    edx, 0f0f0f0fh   ; + Ystep  -selfmodifying!
@self6:
    mov    bl, fs:[bx]
    mov    es:[di], bl
    inc    di
    dec    cx
    jnz    @nextpixel

    pop    di
@skip:

    pop    cx

    add    di, 320
    inc    cx
    cmp    cx, [si+8]
    js	  @nextline

@endpoly:
  ret


DivProc:
    sub    eax, ebx
    imul   eax, ebp
    cdq
    idiv   ecx
    add    eax, ebx
ret


Imul256:
    movsx  eax, ax
    imul   eax, 256
    cdq
    idiv   ecx
ret
