comment #+

    This is the source-release of "Stoerfall Ost", our winning 4kb
    multimedia presentation that was first shown at Dialogos 2000.
    If you have any questions concerning the sourcecode drop us a
    line at freestyle@freestylas.org. Feel free to visit our
    webpage at http://www.freestylas.org.
    Copyright (C) 2001 freestyle
    
    This program is free software; you can redistribute it and/or
    modify it under the terms of the GNU General Public License
    as published by the Free Software Foundation; either version 2
    of the License, or (at your option) any later version.
    
    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.
    
    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
    
+#



	.data

randseed	dq 0.5
randmul		dq 12054.67293087436
randadd		dq 0.3183287916948132
;randomize	dd 0DEADBEEFh



	.data?

;splinebuf	dd 128 dup (?)

	.code

comment #+
randomf		proc near
  pushad
 
 
  xor		edx,edx
  dec		edx
  
  push		edx
  fild		word ptr [esp]
  
  imul 		eax,[randomize],69069
  mov 		[randomize],eax
  shr 		eax,16
  mul 		dx
  ;movzx eax,dx
  
  push	edx
  fild		dword ptr [esp]
  fdivrp	st(1),st(0)
  pop	  	eax
  pop		eax
  
  
  popad
ret
randomf	endp
+#

comment #+
; out	st0 - random number  0<=x<1
; uses  eax
randomf		proc near
	mov	eax,offset randseed
	fld	qword ptr [eax]
	fmul	qword ptr [eax+8]
	fadd	qword ptr [eax+16]
	fld	st0
	frndint
	fsubp	st1,st0
	fst	qword ptr [eax]
	ret
randomf		endp
+#


comment #+
; in	eax - range
; out	eax - random int, 0..range-1
randomi		proc near
	push	eax
	call	randomf
	fimul	dword ptr [esp]
	fistp	dword ptr [esp]
	pop	eax
	ret
randomi		endp
+#

; ---- vector math ----------------------------------------

; in	eax - adress of vector to load
; out	st0 - x component of vector
;	st1 - y
;	st2 - z
load_vec	proc near
	fld	dword ptr [eax+8]	; z
	fld	dword ptr [eax+4]	; y
	fld	dword ptr [eax]		; x
	ret
load_vec	endp

; in	eax - vector 1
;	esi - vector 2
;	edx - result
; out	[edx]=[eax]-[esi]
sub_vec		proc near
	xchg	eax,esi
	call	load_vec
	xchg	eax,esi
	call	load_vec
	fsubp	st3,st0			; x
	fsubp	st3,st0			; y
	fsubp	st3,st0			; z
;	jmp	store_vec
sub_vec		endp

; in	edx - adress to store vector at
;	st0 - x component of vector
;	st1 - y
;	st2 - z
; out	vector in [edx]
;	fpu stack cleared from vector
store_vec	proc near
	fstp	dword ptr [edx]		; x
	fstp	dword ptr [edx+4]	; y
	fstp	dword ptr [edx+8]	; z
	ret
store_vec	endp

comment #+
; in	eax - vector 1
;	esi - vector 2
;	edx - result
; out	[edx]=[eax]+[esi]
add_vec		proc near
	call	load_vec
	xchg	eax,esi
	call	load_vec
	xchg	eax,esi
	faddp	st3,st0			; x
	faddp	st3,st0			; y
	faddp	st3,st0			; z
	jmp	store_vec
add_vec		endp
+#

comment #+
; in	st0 - factor
;	eax - vector
;	edx - result
; out	result at [edx]
;	factor removed from fpu stack
scale_vec	proc near
	call	load_vec
	fld	st3
	ffree	st4
	fmul	st1,st
	fmul	st2,st
	fmulp	st3,st
	jmp	store_vec
scale_vec	endp

; in	eax - vector1
;	esi - vector2
; out	st0 - result
dot_product	proc near
	fld	dword ptr [eax]
	fmul	dword ptr [esi]
	fld	dword ptr [eax+4]
	fmul	dword ptr [esi+4]
	faddp	st1,st0
	fld	dword ptr [eax+8]
	fmul	dword ptr [esi+8]
	faddp	st1,st0
	ret
dot_product	endp
+#
; in	eax - vector1
;	esi - vector2
;	edx - result
; out	result at [edx]
;cross_product	proc near
cross_product	macro
	fld	dword ptr [eax]		; z
	fmul	dword ptr [esi+4]
	fld	dword ptr [eax+4]
	fmul	dword ptr [esi]
	fsubp	st1,st0

	fld	dword ptr [eax+8]	; y
	fmul	dword ptr [esi]
	fld	dword ptr [eax]
	fmul	dword ptr [esi+8]
	fsubp	st1,st0

	fld	dword ptr [eax+4]	; x
	fmul	dword ptr [esi+8]
	fld	dword ptr [eax+8]
	fmul	dword ptr [esi+4]
	fsubp	st1,st0
comment #+
	pusha
	push	3
	pop	ecx
	xor	edx,edx
	lea	ebx,[ecx+1]
	lea	edi,[ebx*2]
crossloop:
	fld	dword ptr [eax+edx]		; z
	fmul	dword ptr [esi+ebx]
	fld	dword ptr [eax+ebx]
	fmul	dword ptr [esi+edx]
	fsubp	st1,st0
	xchg	edx,edi
	xchg	ebx,edi
	loop	crossloop
	popa
+#
	call	store_vec
;	jmp	store_vec
;cross_product	endp
endm


; ---- splinecode -----------------------------------------

; in	esi - controlpoints
;	eax - controlpointcount
;	edx - controlpointstride
;	edi - result
;	st0 - position 0<=x<1
; out	result at [edi]
getlinearf	macro
;getlinearf	proc near
	pusha
	push	eax
	fild	dword ptr [esp]
	fmul	st0,st1
	fld	st0
	frndint				; trunc
	fist	dword ptr [esp]		; number of active section
	fsubp	st1,st0			; position within this section

	; ----- supergenialer splinefake -----
		fldpi			; splineparam = (cos(splineparam*pi)-1)/(-2)
		fmulp	st1,st0
		fcos
		fld1
		fchs
		fadd	st1,st0
		fadd	st0,st0
		fdivp	st1,st0

	pop	eax
	imul	eax,edx
	fld	dword ptr [esi+eax]
	add	eax,edx
	fld	dword ptr [esi+eax]
	fsub	st0,st1
	fxch	st2
	fmulp	st2,st0
	faddp	st1,st0
	fstp	dword ptr [edi]
	popa
;	ret
;getlinearf	endp
endm

; in	st0 - postion in tween
;	ebx - position of data in script_dword
;	edx - number of points
;	edi - dimension of points
getlinearv	macro
;getlinearv	proc near
;	pusha

	mov	ecx,edi
	mov	eax,edx
	;lea	edx,[edi*4]
	mov	edx,edi
	shl	edx,2
	lea	esi,[script_dword+ebx*4]
linear_dimension_loop:
	mov	edi,esi
	sub	edi,edx
	;call	getlinearf
	getlinearf
	add	esi,4
	;add	edi,4
	loop	linear_dimension_loop

	fstp	st0

;	popa
;	ret
;getlinearv	endp
endm

comment #+
; in	eax
getsplinef	proc near
	pusha

	popa
	ret
getsplinef	endp

; in	st0 - postion in tween
;	ebx - position of data in script_dword
;	edx - number of points
;	edi - dimension of points
getsplinev	proc near
	pusha

	fstp	st0	; no need for position any longer  :)

	popa
	ret
getsplinev	endp
+#