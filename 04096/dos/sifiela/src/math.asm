;****************************
;* Fsmod                    *
;*	param:	val=st(0)   *
;*		mod=tempint *
;****************************
;float sfmod(float val, float mod){
;	val-=(int)(val/mod)*mod;
;	if (val<0) val+=mod;
;	return val;
;}
fsmod:
	fld	st(0)
	fidiv	tempint
	fld	CONST0_5
	fchs
	fadd
	frndint
	fimul	tempint
	fchs
	fadd
	fldz
	fcomp
	fstsw	ax
	wait
	sahf
	jns	fsmodcont
	fiadd	tempint
fsmodcont:
ret



;****************************
;* modulo                   *
;*	param:	val=st(0)   *
;*		mod=tempint *
;****************************
;float mod(int val, int mod){
;	val-=(int)(val/mod)*mod;
;	return val;
;}
modulo:
	fld	st(0)
	fidiv	tempint
	fld	CONST0_5
	fchs
	fadd
	frndint
	fimul	tempint
	fchs
	fadd
ret



;*********
;* floor *
;*********
;float floor(float val){
;	return (int)val
;}
floor:
	fsub	CONST0_5
	frndint
ret


;********
;* fpow *
;********
;#pragma aux fpow parm [8087] [8087] value [8087] modify [8087] =
;"fyl2x"
;"fld1"
;"fld st(1)"
;"fprem"
;"f2xm1"
;"faddp st(1),st"
;"fscale"
;"fxch st(1)"
;"fstp st(0)"
fpow:
	fyl2x
	fld1
	fld	st(1)
	fprem
	f2xm1
	faddp	st(1),st(0)
	fscale
	fxch	st(1)
	fstp	st(0)
ret



;********
;* fexp *
;********
;#pragma aux fexp parm [8087] value [8087] modify [8087] =
;"fldl2e"
;"fmulp st(1),st"
;"fld1"
;"fld st(1)"
;"fprem"
;"f2xm1"
;"faddp st(1),st"
;"fscale"
;"fxch st(1)"
;"fstp st(0)"
fexp:
	fldl2e
	fmulp st(1),st(0)
	fld1
	fld st(1)
	fprem
	f2xm1
	faddp st(1),st(0)
	fscale
	fxch st(1)
	fstp st(0)
ret



;************************************
;* Rotatepoint                      *
;*	param:	tempvector = source *
;*		es:di = target      *
;*		si = matrix         *
;************************************
inverserotatepoint:
	push	eax
	push	bx
	push	cx
	push	di

	xor	ebx, ebx
	mov	bx, 0
	mov	cx, 3
	shl	esi, 16
	shr	esi, 16
	shl	edi, 16
	shr	edi, 16
inverserotatepointloop:
        fld	dword ptr [esi + ebx*4 + 0*4]
	fld	dword ptr [tempvector + vector_x]
	fmulp

        fld	dword ptr [esi + ebx*4 + 1*4]
	fld	dword ptr [tempvector + vector_y]
	;fld	tempvector + 1*4
	fmulp
	faddp

        fld	dword ptr [esi + ebx*4 + 2*4]
	fld	dword ptr [tempvector + vector_z]
	;fld	tempvector + 2*4
	fmulp
	faddp

        ;fstp	dword ptr es:[edi + ebx*4]
        fstp	dword ptr es:[edi + vertex_rx]
        add	edi, 4
        add	bx, 3
	;dec	bx
	;jns	rotatepointloop
	loop	inverserotatepointloop

	pop	di
	pop	cx
	pop	bx	
	pop	eax
;for (y=0;y<3;y++){
;  vr[y]=0;
;  for (x=0;x<3;x++){
;    vr[y]+=camera[x][y]*v[x];
;  }
;}	
ret



;***************
;* Rotatepoint *
;***************
rotatepoint:
	push	eax
	push	bx

	mov	eax,[di+0*4]
	mov	dword ptr [tempvector + vector_x],eax
	mov	eax,[di+1*4]
	mov	dword ptr [tempvector + vector_y],eax
	mov	eax,[di+2*4]
	mov	dword ptr [tempvector + vector_z],eax
	xor	ebx,ebx
	mov	bx,2
	shl	esi,16
	shr	esi,16
	shl	edi,16
	shr	edi,16
rotatepointloop:
        fld	dword ptr [esi+ebx*4+0*4]
	fld	dword ptr [tempvector + vector_x]
	fmulp

        fld	dword ptr [esi+ebx*4+3*4]
	fld	dword ptr [tempvector + vector_y]
	fmulp
	faddp

        fld	dword ptr [esi+ebx*4+6*4]
	fld	dword ptr [tempvector + vector_z]
	fmulp
	faddp

        fstp	dword ptr [edi+ebx*4]
	dec	bx
	jns	rotatepointloop

	pop	bx	
	pop	eax
;for (y=0;y<3;y++){
;  vr[y]=0;
;  for (x=0;x<3;x++){
;    vr[y]+=camera[x][y]*v[x];
;  }
;}	
ret



;*******************
;* cameratransform *
;*******************
cameratransform:
	fld	dword ptr es:[di + vertex_x]
	fsub	dword ptr [camerapos + 0*4]
	fstp	dword ptr [tempvector + 0*4]
	fld	dword ptr es:[di + vertex_y]
	fsub	dword ptr [camerapos + 1*4]
	fstp	dword ptr [tempvector + 1*4]
	fld	dword ptr es:[di + vertex_z]
	fsub	dword ptr [camerapos + 2*4]
	fstp	dword ptr [tempvector + 2*4]
	
	push	si
	lea	si, cameramatrix
	call	inverserotatepoint
	pop	si
ret



;****************
;* Crossproduct *
;****************
;Calculates crossproduct of [di] and [si] and stores it in [bx]
;result[0]=v1[1]*v2[2]-v1[2]*v2[1];
;result[1]=v1[2]*v2[0]-v1[0]*v2[2];
;result[2]=v1[0]*v2[1]-v1[1]*v2[0];
crossproduct:

	fld	dword ptr [di+2*4]
	fmul	dword ptr [si+1*4]
	fld	dword ptr [di+1*4]
	fmul	dword ptr [si+2*4]
	fsubp
	fstp	dword ptr [bx+0*4]		

	fld	dword ptr [di+0*4]
	fmul	dword ptr [si+2*4]
	fld	dword ptr [di+2*4]
	fmul	dword ptr [si+0*4]
	fsubp
	fstp	dword ptr [bx+1*4]		

	fld	dword ptr [di+1*4]
	fmul	dword ptr [si+0*4]
	fld	dword ptr [di+0*4]
	fmul	dword ptr [si+1*4]
	fsubp
	fstp	dword ptr [bx+2*4]		

ret



;**************
;* Dotproduct *
;**************
;Calculates dotproduct of [di] and [si] and leaves it in st(0)
dotproduct:
        fld	dword ptr [si]
        fld	dword ptr [di]
        fmulp	st(1)
        fld	dword ptr [si+1*4]
        fld	dword ptr [di+1*4]
        fmulp	st(1)
        fld	dword ptr [si+2*4]
        fld	dword ptr [di+2*4]
        fmulp	st(1)
        faddp	st(1)
        faddp	st(1)

ret



;***************
;* Scalevector *
;***************
;Scales vector in [si] by st(0) without popping
scalevector:
        fld	dword ptr [si]
        fmul	st(0), st(1)
        fstp	dword ptr [si]
        fld	dword ptr [si + 1*4]
        fmul	st(0), st(1)
        fstp	dword ptr [si + 1*4]
        fld	dword ptr [si + 2*4]
        fmul	st(0), st(1)
        fstp	dword ptr [si + 2*4]

ret



;*************
;* Normalize *
;*************
;Normalizes vector in [si]
normalize:
        push	di
        mov	di,si
        call	dotproduct
        pop	di

        fsqrt
        fld1
        fdivrp
        call	scalevector

ret
normalizep:
	call	normalize
        fstp	tempreal
ret



;*************
;* Dircamera *
;*************
;Target point is in bx
dircamera:
        pusha

        fld	dword ptr [bx + 0*4]
        fsub	dword ptr [camerapos + 0*4]
        fstp	dword ptr [cameramatrix + 0*4 + 24]
        fld	dword ptr [bx + 1*4]
        fsub	dword ptr [camerapos + 1*4]
        fstp	dword ptr [cameramatrix + 1*4 + 24]
        fld	dword ptr [bx + 2*4]
        fsub	dword ptr [camerapos + 2*4]
        fstp	dword ptr [cameramatrix + 2*4 + 24]

        lea	si, [cameramatrix + 24]
        call	normalizep

        call	cameranormalize

        popa
ret



;*******************
;* Cameranormalize *
;*******************
cameranormalize:
        pusha

        
        fldz
        fst	[cameramatrix + 0*4 + 12]
        fld1
        fstp	[cameramatrix + 1*4 + 12]
        fstp	[cameramatrix + 2*4 + 12]

	lea	bx, [cameramatrix]
	lea	si, [cameramatrix + 12]
	lea	di, [cameramatrix + 24]
	call	crossproduct
	lea	si, [cameramatrix]
	call	normalizep

	lea	bx, [cameramatrix + 12]
	lea	si, [cameramatrix + 24]
	lea	di, [cameramatrix + 0]
	call	crossproduct
	lea	si, [cameramatrix]
	call	normalizep

	popa
ret



;**********
;* Random *
;**********
random:
        pusha

        mov eax,rndseed
        add eax,1724721753
        mov ebx,rndseed2
	add ebx,239873
        mul bx
        add eax,4721753
        mov rndseed2,eax
	sub ebx,eax
	add ebx,19836137
	mul bx
	mov rndseed,eax

        popa
ret