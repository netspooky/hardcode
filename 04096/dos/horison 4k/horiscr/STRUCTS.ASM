array          struc
               array_length   dw   0
               array_ptr      dw   0
array          ends
;-----------------------------------------
point2         struc
               point2_x       dd   0
               point2_y       dd   0
point2         ends
;-----------------------------------------
point3         struc
               point3_x       dd   0
               point3_y       dd   0
               point3_z       dd   0
point3         ends
;-----------------------------------------
point4         struc
               point4_x       dd   0
               point4_y       dd   0
               point4_z       dd   0
               point4_w       dd   0
point4         ends
;-----------------------------------------
vertex         struc
               vertex_x       dd   0
               vertex_y       dd   0
               vertex_z       dd   0
               vertex_tx      dd   0
               vertex_ty      dd   0
               vertex_color   dd   0
vertex         ends
;-----------------------------------------
particle       struc
               particle_position   point3    <>
               particle_direction  point3    <>
particle       ends
;-----------------------------------------
polygon        struc
               polygon_count       dw   0
               polygon_vertex_ptr  dw   0
polygon        ends
;-----------------------------------------
face           struc
               face_vertices  dw   0
               face_ptr       dw   0         ;array of words (point3 ref array)
               face_tptr      dw   0         ;array of Point2 (point2 ref array)
               face_flags     db   0
               face_normalPtr dw   0         ;noramelPtr-face_ptr[0]=normalVector
               face_hide      equ  01000b
face           ends
;-----------------------------------------
mesh           struc
               mesh_faces     dw   0
               mesh_vertices  dw   0
               mesh_facePtr   dw   0
               mesh_vertexPtr dw   0
               mesh_flags     db   0
               mesh_invert    equ       0001b
               mesh_mirror    equ       0010b
               mesh_transparent equ     0100b
mesh           ends
;-----------------------------------------
matrix         struc
               m00       dd   0
               m01       dd   0
               m02       dd   0
               m03       dd   0
               m10       dd   0
               m11       dd   0
               m12       dd   0
               m13       dd   0
               m20       dd   0
               m21       dd   0
               m22       dd   0
               m23       dd   0
               m30       dd   0
               m31       dd   0
               m32       dd   0
               m33       dd   0
matrix         ends
;-----------------------------------------
tstruc         struc
               tstruc_t       dd   0
               tstruc_delta   dd   0
               tstruc_max     dd   0
tstruc         ends
;-----------------------------------------
; si = this tstruc
; returns test result in ax
tstruc_update  proc
               fld       ds:[si].tstruc_t
               fadd      ds:[si].tstruc_delta
               fst       ds:[si].tstruc_t
               fcomp     ds:[si].tstruc_max
			fstsw 	ax
               test      ah,1
               jnz       jmp2ret
               fldz
               fadd      ds:[si].tstruc_delta
               fstp      ds:[si].tstruc_t
               ret
tstruc_update  endp
;-----------------------------------
;     public double getLength(Point3d p)
;     {
;          double lx = p.x-x;
;          double ly = p.y-y;
;          double lz = p.z-z;
;          double length = Math.sqrt(lx*lx+ly*ly+lz*lz);
;          if (length > 0.0)
;               return length;
;          return -length;
;     }
; si = this point3
; di = other point3
; returns length in st(0)
;point3_length  proc
;               fld  [di].point3_x
;               fsub [si].point3_x
;               fmul st,st
;               fld  [di].point3_y
;               fsub [si].point3_y
;               fmul st,st
;               fld  [di].point3_z
;               fsub [si].point3_z
;               fmul st,st
;               faddp
;               faddp
;               fsqrt
;               fstp temp_dd
;               mov  eax,temp_dd
               ret
;point3_length  endp
;-----------------------------------------
; si = this point3
; di = point3 to add
;point3_add     proc
;               fld  [si].point3_x
;               fadd [di].point3_x
;               fstp [si].point3_x
;               fld  [si].point3_y
;               fadd [di].point3_y
;               fstp [si].point3_y
;               fld  [si].point3_z
;               fadd [di].point3_z
;               fstp [si].point3_z
;               ret
;point3_add     endp
;-----------------------------------------
