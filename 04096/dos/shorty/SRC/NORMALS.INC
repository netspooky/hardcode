CalcNormal:
	    ;Vert1,Vert2 and Vert3 contain addresses to three points.
	    ;Dest will be a normal, length 8192.
  mov	 di,Vert2			;
  movsx  ebx,word ptr [di]		; X1
  mov	 [v2.0],ebx
  movsx  ecx,word ptr [di+2]		; Y1
  mov	 [v2.4],ecx
  movsx  edx,word ptr [di+4]		; Z1
  mov	 [v2.8],edx

  Mov	 Di,Vert1
  Mov	 Si,offset V1
  MovSx  EAx,word ptr [Di]		; X2
  Sub	 EAx,EBx
  Mov	 [Si],EAx			; X2-X1
  MovSx  EAx,word ptr [Di.2]		; Y2
  Sub	 EAx,ECx
  Mov	 [Si+4],EAx			; Y2-Y1
  MovSx  EAx,word ptr [Di.4]		; Z2
  Sub	 EAx,EDx
  Mov	 [Si+8],EAx			; Z2-Z1

  Mov	 Di,Vert3
  Mov	 Si,offset V3
  MovSx  EAx,word ptr [di]		; X3
  Sub	 EAx,EBx
  Mov	 [Si],EAx			; X3-X1
  MovSx  EAx,word ptr [Di.2]		; Y3
  Sub	 EAx,ECx
  Mov	 [Si+4],EAx			; Y3-Y1
  MovSx  EAx,word ptr [Di.4]		; Z3
  Sub	 EAx,EDx
  Mov	 [Si+8],EAx			; Z3-Z1


  Mov	 EAx,[V1.4]
  IMul	 EAx,[V3.8]			; (Y2-Y1)*(Z3-Z1)
  Mov	 EBx,[V1.8]
  IMul	 EBx,[V3.4]			; (Y3-Y1)*(Z2-Z1)
  Sub	 EAx,EBx
  Mov	 [D.0],EAx			; PolyNormal.X

  Mov	 EAx,[V1.8]			; (Z2-Z1)*(X3-X1)
  IMul	 EAx,[V3.0]
  Mov	 EBx,[V1.0]			; (X2-X1)*(Z3-Z1)
  IMul	 EBx,[V3.8]
  Sub	 EAx,EBx
  Mov	 [D.4],EAx			; PolyNormal.Y

  Mov	 EAx,[V1.0]			; (X2-X1)*(Y3-Y1)
  IMul	 EAx,[V3.4]
  Mov	 EBx,[V1.4]			; (Y2-Y1)*(X3-X1)
  IMul	 EBx,[V3.0]
  Sub	 EAx,EBx
  Mov	 [D.8],EAx			; PolyNormal.Z

  or	 eax,eax
  jns	@normnoproblem3
  neg	 eax
@normnoproblem3:
  mov	 ebx,[d.4]
  or	 ebx,ebx
  jns	@normnoproblem1
  neg	 ebx
@normnoproblem1:
  or	 eax,ebx
  mov	 ebx,[d.0]
  or	 ebx,ebx
  jns	@normnoproblem2
  neg	 ebx
@normnoproblem2:
  or	 eax,ebx

  mov	 cl,17

@test_shifts:
  rcl	 eax,1
  jc	@startmultiplying
  dec	 cl
  jnz	@test_shifts

@startmultiplying:

  mov	 normalshifter, cl
  mov	 eax, [d.8]
  sar	 eax,cl
  imul	 eax,eax
  mov	 ebx,eax		; sqr(PolyNormal.Z)
  mov	 eax, [d.4]
  sar	 eax,cl
  imul	 eax,eax		; sqr(PolyNormal.Y)
  add	 ebx,eax
  mov	 eax,[D.0]
  sar	 eax,cl
  imul	 eax,eax		; sqr(PolyNormal.X)
  add	 ebx,eax		; EBX := (length)^2
  shr	 ebx,16

  call	 Sqrt
  mov	 cl,normalshifter
  and	 eax,0ffffh
  shl	 eax,cl

  or	 eax,eax
  jz	@endofcalcnorm


  mov	 di,dest

  mov	 ebx,eax
  mov	 eax,[D.0]		; PolyNormal.X
  cdq
  shld	 edx,eax,13
  shl	 eax,13
  idiv	 ebx			; Normalize PolyNormal.X
  mov	 [di],ax		; Normal length 8192

  mov	 eax,[D.4]		; PolyNormal.Y
  cdq
  shld	 edx,eax,13
  shl	 eax,13
  idiv	 ebx			; Normalize PolyNormal.Y
  mov	 [di.2],ax		; Normal length 8192

  mov	 eax,[D.8]		; PolyNormal.Z
  cdq
  shld	 edx,eax,13
  shl	 eax,13
  idiv	 ebx			; Normalize PolyNormal.Z
  mov	 [di.4],ax		; Normal length 8192

 @endofcalcnorm:
  ret



;-------------------------------------------------------------------------

MakeNorms:
  mov	 cx, 704
  mov	 ax, OFFSET polynormals
  mov	 dest, ax
  mov	 di, OFFSET plan
 @gofornextnormal:
    mov    bx, cs:[di]
    add    bx, pointoffset
    mov    vert1, bx
    mov    bx, cs:[di+2]
    add    bx, pointoffset
    mov    vert2, bx
    mov    bx, cs:[di+4]
    add    bx, pointoffset
    mov    vert3, bx
    add    di,6
    push   di
    push   cx
    call   calcnormal
    pop    cx
    pop    di
    add    dest,6
    loop   @gofornextnormal		; Calculate all PolyNormals.

    mov    di, OFFSET NormalBuffer	; 256*9
    mov    cx, 3600
    xor    ax, ax
    rep    stosw

    mov    di, OFFSET plan
    mov    si, OFFSET polynormals
    mov    makenormscounter, 704
@scanthroughpolys:
    mov    cx, 3
@nextnormalpolypoint:
    mov    bx, [di]
    add    di, 2
    imul   bx, 3			; plan offset * 18..
    add    bx, OFFSET normalbuffer
    inc    dword ptr [bx]
    movsx  eax,word ptr [si]
    add    [bx+4],eax
    movsx  eax,word ptr [si+2]
    add    [bx+8],eax
    movsx  eax,word ptr [si+4]
    add    [bx+12],eax
    loop   @nextnormalpolypoint
    add    si,6
    dec    makenormscounter
    jnz   @scanthroughpolys

    mov    cx, 384
    mov    di, OFFSET normalbuffer
    mov    si, NormalOffset
@scanthroughpoints:
    mov    ebx,[di]
    or	   ebx, ebx
    jz	   @afteradjustingnormals

    mov    eax,[di+4]
    cdq
    idiv   ebx
    mov    [si],ax			; avarage Vertex Normal.X

    mov    eax,[di+8]
    cdq
    idiv   ebx
    mov    [si+2],ax			; avarage Vertex Normal.Y

    mov    eax,[di+12]
    cdq
    idiv   ebx
    mov    [si+4],ax			; avarage Vertex Normal.Z

   @afteradjustingnormals:
    add    di,18
    add    si,6
    loop   @scanthroughpoints
    ret
