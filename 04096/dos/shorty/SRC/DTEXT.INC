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

	mov	ax, [Rnormals.bx]
	mov	dx, ax
	sar	ax, 8
	add	ax, X1
	mov	Dx1, ax
	sar	dx, 6
	add	dx, 128
	mov	Tx1, dx
	mov	ax, [Rnormals.bx+2]
	mov	dx, ax
	sar	ax, 8
	add	ax, Y1
	mov	Dy1, ax
	sar	dx, 6
	add	dx, 128
	mov	Ty1, dx

	mov	bx, [plan.di+2]
	mov	ax, [Rpoints.bx]
	mov	X2, ax
	mov	ax, [Rpoints.bx+2]
	mov	Y2, ax

	mov	ax, [Rnormals.bx]
	mov	dx, ax
	sar	ax, 8
	add	ax, X2
	mov	Dx2, ax
	sar	dx, 6
	add	dx, 128
	mov	Tx2, dx
	mov	ax, [Rnormals.bx+2]
	mov	dx, ax
	sar	ax, 8
	add	ax, Y2
	mov	Dy2, ax
	sar	dx, 6
	add	dx, 128
	mov	Ty2, dx

	mov	bx, [plan.di+4]
	mov	ax, [Rpoints.bx]
	mov	X3, ax
	mov	ax, [Rpoints.bx+2]
	mov	Y3, ax

	mov	ax, [Rnormals.bx]
	mov	dx, ax
	sar	ax, 8
	add	ax, X3
	mov	Dx3, ax
	sar	dx, 6
	add	dx, 128
	mov	Tx3, dx
	mov	ax, [Rnormals.bx+2]
	mov	dx, ax
	sar	ax, 8
	add	ax, Y3
	mov	Dy3, ax
	sar	dx, 6
	add	dx, 128
	mov	Ty3, dx

	pusha
	call	textpoly
	popa

	sub	si, 2
	dec	cx
	jnz	@NextPoly
	ret



textpoly:
    mov    flag3, 0
    mov    si, offset x1
    mov    di, offset x2

    mov    byte ptr cs:[@@labeltje+1],0c7h ;	maak weer di
    mov    cx, 3

@@loop:

    mov    ax, [si+6]		; Y1
    cmp    ax, [di+6]		; Y2
    js	  @NoSwap1

    mov    bx, 30

@@xchgloop:

    mov    ax, [si+bx]		; x1, y1, tx1, ty1, dx1, dy1
    xchg   ax, [di+bx]		; x2, y2, tx2, ty2, dx2, dy2
    mov    [si+bx], ax		;

    sub    bl,6
    jns    @@xchgloop
    xor    flag3, 1

@NoSwap1:


@@labeltje:
    add     di,2
    dec     byte ptr cs:[@@labeltje+1] ;    maak van di si

    loop    @@loop


    mov    cx, y3
    sub    cx, y1
    jz	  @endpoly
    movsx  ecx, cx

    mov    ax, x3	     ; X3r := (X3-X1)*256 DIV (Y3-Y1)
    sub    ax, x1

    movsx  ebx, ax
    Call   Imul256
    mov    x3r, eax
    mov    x4r, eax


    mov    ax, y2	     ; X4 := (Y2-Y1)*(X3-X1) DIV (Y3-Y1) + X1
    sub    ax, y1

    movsx  eax, ax
    mov    ebp, eax	     ; y2y1

    imul   eax, ebx
    cdq
    idiv   ecx

    movzx  ebx, x1
    add    eax, ebx
    mov    x4 , ax


    mov    links, 0

    cmp    x2, ax		 ; x2  if x2<x4 then links = true.
    jns    @nietlinks
    mov    links, 1

    jmp    @wellinks
@nietlinks:
    mov    links, 0

    mov    ax, Tx3		 ; Tx1r := (Tx3-Tx1)*256 DIV (Y3-Y1)
    sub    ax, Tx1
    Call   Imul256
    mov    dword ptr [tx1r-4], eax
    mov    Tx2r, eax

    mov    ax, Ty3		 ; Ty1r := (Ty3-Ty1)*256 DIV (Y3-Y1)
    sub    ax, Ty1
    Call   Imul256
    mov    dword ptr [ty1r-4], eax
    mov    Ty2r, eax

    mov    ax, Dx3		 ; Dx1r := (Dx3-Dx1)*256 DIV (Y3-Y1)
    sub    ax, Dx1
    Call   Imul256
    mov    dword ptr [Dx1r-4], eax
    mov    Dx2r, eax

    mov    ax, Dy3		 ; Dy1r := (Dy3-Dy1)*256 DIV (Y3-Y1)
    sub    ax, Dy1
    Call   Imul256
    mov    dword ptr [Dy1r-4], eax
    mov    Dy2r, eax


@wellinks:
    mov   al, flag3
    cmp   al, links
    je	  @EndPoly

    movzx  eax, Tx3		   ; Tx4 := (Y2-Y1)*(Tx3-Tx1) DIV (Y3-Y1) + Tx1
    movzx  ebx, Tx1
    call   Divproc
    mov    Tx4, ax

    movzx  eax, Ty3		   ; Ty4 := (Y2-Y1)*(Ty3-Ty1) DIV (Y3-Y1) + Ty1
    movzx  ebx, Ty1
    call   Divproc
    mov    Ty4, ax

    movzx  eax, Dx3		   ; Dx4 := (Y2-Y1)*(Dx3-Dx1) DIV (Y3-Y1) + Dx1
    movzx  ebx, Dx1
    call   Divproc
    mov    Dx4, ax

    movzx  eax, Dy3		   ; Dy4 := (Y2-Y1)*(Dy3-Dy1) DIV (Y3-Y1) + Dy1
    movzx  ebx, Dy1
    call   Divproc
    mov    Dy4, ax

    mov    cx, X4
    sub    cx, X2
    jz	  @nostep

    movsx  ecx, cx

    mov    ax, Tx4		   ; Xstep1 := (Tx4-Tx2)*256 DIV (X4-X2)
    sub    ax, Tx2
    Call   Imul256
    mov    dword ptr cs:[@self5-4], eax

    mov    ax, Ty4		   ; Ystep1 := (Ty4-Ty2)*256 DIV (X4-X2)
    sub    ax, Ty2
    Call   Imul256
    mov    dword ptr cs:[@self6-4], eax

    mov    ax, Dx4		   ; Xstep2 := (Dx4-Dx2)*256 DIV (X4-X2)
    sub    ax, Dx2
    Call   Imul256
    mov    dword ptr cs:[@self7-4], eax

    mov    ax, Dy4		   ; Ystep2 := (Dy4-Dy2)*256 DIV (X4-X2)
    sub    ax, Dy2
    Call   Imul256
    mov    dword ptr cs:[@self8-4], eax

@nostep:
    mov    cx, Y3
    sub    cx, Y2
    jz	  @flatunder
    movsx  ecx, cx

    mov    ax, x3		   ; X1r := (X3-X2)*256 DIV (Y3-Y2)
    sub    ax, x2
    Call   Imul256
    mov    X1r, eax

    mov    eax, dword ptr [tx1r-4]	   ; waarom dit moet is mij niet duidelijk maar anders werkt het niet.
    mov    Tx2r, eax

    mov    eax, dword ptr [ty1r-4]
    mov    Ty2r, eax

    mov    eax, dword ptr [Dx1r-4]	   ; waarom dit moet is mij niet duidelijk maar anders werkt het niet.
    mov    Dx2r, eax

    mov    eax, dword ptr [Dy1r-4]
    mov    Dy2r, eax

    cmp    links, 1
    jne    @flatunder

    mov    ax, Tx3			   ; Tx2r := (Tx3-Tx2)*256 DIV (Y3-Y2)
    sub    ax, Tx2
    Call   Imul256
    mov    Tx2r, eax

    mov    ax, Ty3	   ; Ty2r := (Ty3-Ty2)*256 DIV (Y3-Y2)
    sub    ax, Ty2
    Call   Imul256
    mov    Ty2r, eax

    mov    ax, Dx3			   ; Dx2r := (Dx3-Dx2)*256 DIV (Y3-Y2)
    sub    ax, Dx2
    Call   Imul256
    mov    Dx2r, eax

    mov    ax, Dy3	   ; Dy2r := (Dy3-Dy2)*256 DIV (Y3-Y2)
    sub    ax, Dy2
    Call   Imul256
    mov    Dy2r, eax

@flatunder:

    mov    cx, y2
    sub    cx, y1
    jz	   @flatabove
    movsx  ecx, cx
    cmp    links, 1
    jne    @nietlinks2

    mov    ax, Tx2		; Tx1r := (Tx2-Tx1)*256 DIV (Y2-Y1)
    sub    ax, Tx1
    Call   Imul256
    mov    dword ptr [tx1r-4], eax

    mov    ax, Ty2		; Ty1r := (Ty2-Ty1)*256 DIV (Y2-Y1)
    sub    ax, Ty1
    Call   Imul256
    mov    dword ptr [ty1r-4], eax

    mov    ax, Dx2		; Dx1r := (Dx2-Dx1)*256 DIV (Y2-Y1)
    sub    ax, Dx1
    Call   Imul256
    mov    dword ptr [Dx1r-4], eax

    mov    ax, Dy2		; Dy1r := (Dy2-Dy1)*256 DIV (Y2-Y1)
    sub    ax, Dy1
    Call   Imul256
    mov    dword ptr [Dy1r-4], eax

@nietlinks2:

    mov    ax, x2		; Ty1r := (X2-X1)*256 DIV (Y2-Y1)
    sub    ax, x1
    Call   Imul256
    cmp    eax, x3r
    js	   @Noswap4
    xchg   eax, x3r
    mov    ebx, x1r
    mov    x1r, eax
    mov    x4r, ebx
@noswap4:
    mov    x2r, eax

    movzx  eax, x1
    shl    eax, 8
    mov    xt1, eax
    mov    xt2, eax

    xor    eax, eax
    mov    ax, tx1
    shl    ax, 8
    mov    txt1, eax

    mov    ax, ty1
    shl    ax, 8
    mov    tyt1, eax

    mov    ax, Dx1
    shl    ax, 8
    mov    Dxt1, eax

    mov    ax, Dy1
    shl    ax, 8
    mov    Dyt1, eax

    jmp    @start
@flatabove:

    movzx  eax, x2
    shl    eax, 8
    mov    xt1, eax

    movzx  eax, x1
    shl    eax, 8
    mov    xt2, eax

    xor    eax, eax
    mov    ax, tx2
    shl    ax, 8
    mov    txt1, eax
    mov    ax, ty2
    shl    ax, 8
    mov    tyt1, eax

    mov    ax, Dx2
    shl    ax, 8
    mov    Dxt1, eax
    mov    ax, Dy2
    shl    ax, 8
    mov    Dyt1, eax

    mov    eax, x1r
    cmp    eax, x4r
    jns    @start
    xchg   eax, x4r
    mov    x1r, eax

    mov    eax, xt1
    xchg   eax, xt2
    mov    xt1, eax

    xor    eax, eax
    mov    ax, tx1
    shl    ax, 8
    mov    txt1, eax
    mov    ax, ty1
    shl    ax, 8
    mov    tyt1, eax

    mov    ax, Dx1
    shl    ax, 8
    mov    Dxt1, eax
    mov    ax, Dy1
    shl    ax, 8
    mov    Dyt1, eax


@start: 			; start drawing triangle
    mov    es, ScrSeg
    mov    fs, Texture1Seg
    mov    gs, Texture2Seg

    mov    ax, 320
    mov    cx, y1
    mul    cx
    mov    di, ax

    mov    ebp, X3r

@nextline:
    cmp    cx, Y2
    jne    @Nochange

    mov    eax, X1r
    mov    X2r, eax

    mov    ebp, X4r

    mov    eax, tx2r
    mov    dword ptr [tx1r-4], eax

    mov    eax, ty2r
    mov    dword ptr [ty1r-4], eax

    mov    eax, Dx2r
    mov    dword ptr [Dx1r-4], eax

    mov    eax, Dy2r
    mov    dword ptr [Dy1r-4], eax
@Nochange:

    push   cx

    mov    ebx, xt1
    shr    ebx, 8				 ; X start in bx

    mov    ecx, xt2
    shr    ecx, 8				 ; X einde in cx

    mov    eax, x2r
    add    xt1, eax
    add    xt2, ebp

    mov    eax, Txt1				  ; Texture X
    mov    edx, Tyt1				  ; Texture Y

    sub    cx, bx
    js	  @skip

    push   di
    add    di, bx

    push   di
    push   cx

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
    jns    @nextpixel

    pop    cx
    pop    di

    mov    eax, Dxt1				  ; Texture2 X
    mov    edx, Dyt1				  ; Texture2 Y

@nextpixel2:		       ; double texture stukje...
    mov    bl, ah
    mov    bh, dh
    add    eax, 0f0f0f0fh   ; + Xstep  -selfmodifying!
@self7:
    add    edx, 0f0f0f0fh   ; + Ystep  -selfmodifying!
@self8:
    mov    bl, gs:[bx]
    add    es:[di], bl
    inc    di
    dec    cx
    jns    @nextpixel2

    pop    di
@skip:

    add    Txt1, 0f0f0f0fh
Tx1r:
    add    Tyt1, 0f0f0f0fh
Ty1r:
    add    Dxt1, 0f0f0f0fh
Dx1r:
    add    Dyt1, 0f0f0f0fh
Dy1r:


    pop    cx

    add    di, 320
    inc    cx
    cmp    cx, Y3
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
