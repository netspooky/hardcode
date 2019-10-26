; description - matrix class
; * when calling a function, si must be
;   pointing to a object.
;
; functions:
;    matrix_load
;    matrix_mul
;    matrix_rotate
;    matrix_transformVector
;    matrix_translate
;    matrix_scale
;-----------------------------------------
;matrix         struc
;               m00       dd   0
;               m01       dd   0
;               m02       dd   0
;               m03       dd   0
;               m10       dd   0
;               m11       dd   0
;               m12       dd   0
;               m13       dd   0
;               m20       dd   0
;               m21       dd   0
;               m22       dd   0
;               m23       dd   0
;               m30       dd   0
;               m31       dd   0
;               m32       dd   0
;               m33       dd   0
;matrix         ends
;
;-----------------------------------------
; si = this matrix
; di = matrix to load
;
matrix_load    proc
               push si
               push di
               xchg si,di
			mov	cx,16
			rep	movsd
               pop  di
               pop  si
			ret
matrix_load    endp
;-----------------------------------------
;
; si = this matrix
; di = multiplication matrix
; this matrix is multipied by the multiplication matrix
;
matrix_mul     proc
               push      si
               mov       bx,offset matrix_multemp
			mov		dx,4					;dx=i
matrix_mul1:   push      di
			mov		cx,4					;cx=j
matrix_mul2:   fld       ds:[si].m00
               fmul      ds:[di].m00
               fld       ds:[si].m01
               fmul      ds:[di].m10
               fld       ds:[si].m02
               fmul      ds:[di].m20
               fld       ds:[si].m03
               fmul      ds:[di].m30
			faddp	st(1)
			faddp	st(1)
			faddp	st(1)
               fstp      ds:dptr[bx]
               add       bx,4
			add		di,4
               loop      short matrix_mul2
               pop       di
			add		si,16
			dec		dx
               jnz       short matrix_mul1
               pop       si
               mov       di,offset matrix_multemp
               call      matrix_load
			ret
matrix_mul     endp
;-----------------------------------------
;	public void rotate(double x, double y, double z)
;	{
;		double sx,cx, sy,cy, sz,cz;
;		sx = Math.sin(x); cx = Math.cos(x);
;		sy = Math.sin(y); cy = Math.cos(y);
;		sz = Math.sin(z); cz = Math.cos(z);
;		Matrix xmatrix = new Matrix();                                 // Rotation matrix
;		Matrix ymatrix = new Matrix();                                 // Rotation matrix
;		Matrix zmatrix = new Matrix();                                 // Rotation matrix
;		xmatrix.m[1*4+1] = cx;  xmatrix.m[1*4+2] = sx;
;		xmatrix.m[2*4+1] = -sx; xmatrix.m[2*4+2] = cx;    					// x
;		ymatrix.m[0*4+0] = cy;  ymatrix.m[0*4+2] = -sy;
;		ymatrix.m[2*4+0] = sy;  ymatrix.m[2*4+2] = cy;    					// y
;		zmatrix.m[0*4+0] = cz;  zmatrix.m[0*4+1] = sz;
;		zmatrix.m[1*4+0] = -sz; zmatrix.m[1*4+1] = cz;    					// z
;		this.matmult(xmatrix);                          					// rotate about z
;		this.matmult(ymatrix);                         						// rotate about x
;		this.matmult(zmatrix);                          					// rotate about y
;	}
;
; si = this matrix
; di = pointer to angle point3 structure
;
matrix_rotate  proc
               push      si
               push      di
               mov       si,offset matrix_x
               mov       di,offset identity
               call      matrix_load
               mov       si,offset matrix_y
               call      matrix_load
               mov       si,offset matrix_z
               call      matrix_load
               pop       di
               pop       si
			
               fld       ds:[di].point3_x
			fsincos						;sin = st(1) cos = st(0)
               fst       ds:[matrix_x].m11
               fstp      ds:[matrix_x].m22
               fst       ds:[matrix_x].m12
			fchs
               fstp      ds:[matrix_x].m21

               fld       ds:[di].point3_y
			fsincos						;sin = st(1) cos = st(0)
               fst       ds:[matrix_y].m00
               fstp      ds:[matrix_y].m22
               fst       ds:[matrix_y].m20
			fchs
               fstp      ds:[matrix_y].m02

               fld       ds:[di].point3_z
			fsincos						;sin = st(1) cos = st(0)
               fst       ds:[matrix_z].m00
               fstp      ds:[matrix_z].m11
               fst       ds:[matrix_z].m01
			fchs
               fstp      ds:[matrix_z].m10

               mov       di,offset matrix_x
               call      matrix_mul
               mov       di,offset matrix_y
               call      matrix_mul
               mov       di,offset matrix_z
               call      matrix_mul
			
			ret
matrix_rotate  endp
;-----------------------------------------
;public void transformVektor(Point3d dest, Point3d source)
;	dest.x = (source.x*m[0*4+0] + source.y*m[0*4+1] + source.z*m[0*4+2] + m[0*4+3]);
;	dest.y = (source.x*m[1*4+0] + source.y*m[1*4+1] + source.z*m[1*4+2] + m[1*4+3]);
;	dest.z = (source.x*m[2*4+0] + source.y*m[2*4+1] + source.z*m[2*4+2] + m[2*4+3]);
;
; si = this matrix
; bx = source vector to transform
; di = destination vector
;
; source vector is transformed by this matrix and stored in the destination
;
matrix_transformVector   proc
               push      si
               push      di
               push      cx
               mov       cx,3
matrix_transVector:
               fld       ds:[bx].point3_x
               fmul      ds:[si].m00
               fld       ds:[bx].point3_y
               fmul      ds:[si].m01
               fld       ds:[bx].point3_z
               fmul      ds:[si].m02
               fld       ds:[si].m03
			faddp	st(1)
			faddp	st(1)
			faddp	st(1)
               fstp      ds:dptr[di]
			add		di,4
               add       si,4*4
               loop      matrix_transVector
               pop       cx
               pop       di
               pop       si
			ret
matrix_transformVector   endp
;-----------------------------------------------------------------------------
;public void translate(double dx, double dy, double dz)
;{
;	Matrix tmatrix = new Matrix();                  // Translation matrix
;	tmatrix.m[0*4+3] = dx;
;	tmatrix.m[1*4+3] = dy;
;	tmatrix.m[2*4+3] = dz;
; 	this.matmult(tmatrix);
;}
;
; si - this matrix
; di - pointer to point3 (dx,dy,dz)
;
matrix_translate    proc
               push si
               push di
               mov  si,offset matrix_trnstmp
               mov  di,offset identity
               call matrix_load              ;load identety into temp matrix
               pop  di
               pop  si
               mov  eax,ds:[di].point3_x
               mov  ds:[matrix_trnstmp].m03,eax
               mov  eax,ds:[di].point3_y
               mov  ds:[matrix_trnstmp].m13,eax
               mov  eax,ds:[di].point3_z
               mov  ds:[matrix_trnstmp].m23,eax
               mov  di,offset matrix_trnstmp
               call matrix_mul               ;multiply this with the translation matrix
               ret
matrix_translate    endp
;-----------------------------------------
; si - this matrix
; di - pointer to scaling vector (point3)
;
;matrix_scaleTmp matrix <>
;
;matrix_scale   proc
;               push si
;               push di
;               mov  si,offset matrix_scaleTmp
;               mov  di,offset identity
;               call matrix_load              ;load identety into temp matrix
;               pop  di
;               pop  si
;               mov  eax,[di].point3_x
;               mov  [matrix_scaleTmp].m00,eax
;               mov  eax,[di].point3_y
;               mov  [matrix_scaleTmp].m11,eax
;               mov  eax,[di].point3_z
;               mov  [matrix_scaleTmp].m22,eax
;               mov  di,offset matrix_transTemp
;               call matrix_mul               ;multiply this with the scaling matrix
;               ret
;matrix_scale   endp
;-----------------------------------------
