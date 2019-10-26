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



SPL_MUL		= 5

SG_END		= 0
SG_CYLINDER	= 1
SG_CONE		= 2
SG_PIVOT	= 3
SG_DISC		= 4
SG_TRANSLATEX	= 5
SG_TRANSLATEY	= 6
SG_TRANSLATEZ	= 7
SG_LINK		= 8
SG_SWAPZY	= 9
SG_SWAPYX	= 10
SG_NEWOBJECT	= 11
;SG_SPLINE	= 12
SG_LINEAR	= 12
SG_COLOR	= 13
SG_COPY		= 14



sgEnd		macro
	db	SG_END
endm

sgCylinder	macro radius,height,subdiv
	db	SG_CYLINDER+((subdiv) shl 4)
	db	radius
	db	height
	;db	subdiv
endm

sgCone		macro radius1,radius2,height,subdiv
	db	SG_CONE+((subdiv) shl 4)
	db	radius1
	db	radius2
	db	height
	;db	subdiv
endm

sgPivot		macro px,py,pz
	db	SG_PIVOT
	db	px
	db	py
	;db	pz
endm

sgDisc		macro radius,subdiv
	db	SG_DISC+((subdiv) shl 4)
	db	radius
	;db	subdiv
endm

sgTranslateX	macro deltax
	db	SG_TRANSLATEX
	db	deltax
endm

sgTranslateY	macro deltay
	db	SG_TRANSLATEY
	db	deltay
endm

sgTranslateZ	macro deltaz
	db	SG_TRANSLATEZ
	db	deltaz
endm

sgSwapZY	macro vcnt
	db	SG_SWAPZY
	db	vcnt
endm

sgSwapYX	macro vcnt
	db	SG_SWAPYX
	db	vcnt
endm

sgNewObject	macro
	db	SG_NEWOBJECT
endm

;sgSpline	macro ftoffsets,spoints,sdimension
;	db	SG_SPLINE
;	db	ftoffsets
;	db	spoints
;	db	sdimension
;endm

sgLinear	macro ftoffsetl,ldimension,lpoints
	db	SG_LINEAR
	db	ftoffsetl
	;db	ldimension
	db	lpoints+((ldimension) shl 5)
endm

sgCPoint	macro cpoint:vararg
	db	cpoint
endm

sgColor		macro color
	db	SG_COLOR
;	dd	color
	dw	color
endm

sgLink		macro objrel
	db	SG_LINK
	db	objrel
endm

sgCopyObject	macro objrel,count
	db	SG_COPY+((count) shl 4)
	db	objrel
	;db	count
endm


	.data

comment #+
sgJumpData	dd sgJumpTable
		dd sgGenEnd
		db sgGenCylinder-sgGenEnd
		db sgGenCone-sgGenCylinder
		db sgGenPivot-sgGenCone
		db sgGenDisc-sgGenPivot
		db sgGenTranslate-sgGenDisc
		db sgGenTranslate-sgGenTranslate
		db sgGenTranslate-sgGenTranslate
		db sgGenLink-sgGenTranslate
		db sgGenSwapZY-sgGenLink
		db sgGenSwapYX-sgGenSwapZY
		db sgGenNewObject-sgGenSwapYX
		;db sgGenSpline-sgGenNewObject
		;db sgGenLinear-sgGenSpline
		db sgGenLinear-sgGenNewObject
		db sgGenColor-sgGenLinear
		db sgGenCopy-sgGenColor
		db -1
+#
;comment #+
sgJumpTable	dd sgGenEnd
		dd sgGenCylinder
		dd sgGenCone
		dd sgGenPivot
		dd sgGenDisc
		;dd sgGenTranslateX
		;dd sgGenTranslateY
		;dd sgGenTranslateZ
		dd sgGenTranslate
		dd sgGenTranslate
		dd sgGenTranslate
		dd sgGenLink
		dd sgGenSwapZY
		dd sgGenSwapYX
		dd sgGenNewObject
		;dd sgGenSpline
		dd sgGenLinear
		dd sgGenColor
		dd sgGenCopy
;+#

oneO16		dd 0.0625		; 1/16
;oneO4		dd 0.25			; 1/4


include script\sceneScript.ash


	.data?

SG_GEN_DATA	struc
	sgTranslateXVal	dd ?
	sgTranslateYVal	dd ?
	sgTranslateZVal	dd ?
	sgColorRVal	dd ?
	sgColorGVal	dd ?
	sgColorBVal	dd ?
	sgColorAVal	dd ?
	sgCPointMul	dd ?
SG_GEN_DATA	ends

sgGenData	SG_GEN_DATA <?>

;sgJumpTable	dd 20 dup (?)


	.code

sgRotaWork	proc near
	fld	st1
	fimul	dword ptr [ebp-12]	; counter
	fadd	st0,st3
	fsincos
	fmul	st0,st2
	fxch	st1
	fmul	st0,st2
	neg	dword ptr [ebp-8]	; invert height
	fild	dword ptr [ebp-8]
	fxch	st1
	call	store_vec
	fstp	st0			; remove radius
	mov	esi,edx
	xchg	eax,esi
	call	sub_vec
	xchg	eax,esi
	ret
sgRotaWork	endp

sgMakeRotaO	proc near  settings:dword, subdiv:dword, height:dword, radius2:dword, radius1:dword
	push	esi

	fldpi
	fidiv	dword ptr [subdiv]
	fld	st0
	fadd	st0,st0

	mov	ecx,[subdiv]
rotaloop:
	mov	eax,[settings]
	push	[height]
	push	ecx

	lea	edx,[ebx+1*(sizeof tVertex)+tVertex.point.x]
	fild	dword ptr [radius1]
	call	sgRotaWork
;	neg	dword ptr [ebp-8]

	;lea	edx,[ebx+0*(sizeof tVertex)+tVertex.point.x]
	sub	edx,1*(sizeof tVertex)
	fild	dword ptr [radius2]
	call	sgRotaWork
;	neg	dword ptr [ebp-8]

	inc	dword ptr [esp]

;	lea	edx,[ebx+2*(sizeof tVertex)+tVertex.point.x]
	add	edx,2*(sizeof tVertex)
	fild	dword ptr [radius1]
	call	sgRotaWork
;	neg	dword ptr [ebp-8]

;	lea	edx,[ebx+3*(sizeof tVertex)+tVertex.point.x]
	add	edx,1*(sizeof tVertex)
	fild	dword ptr [radius2]
	call	sgRotaWork
;	neg	dword ptr [ebp-8]

	add	esp,8		; do not pop, stack was modified

	; set color
	add	eax,offset SG_GEN_DATA.sgColorRVal
	call	load_vec
	;lea	edx,[ebx+3*(sizeof tVertex)+tVertex.color.r]
	add	edx,tVertex.color.r-tVertex.point.x
	call	store_vec

	; calc normals
	;lea	eax,[ebx+3*(sizeof tVertex)+tVertex.point.x]
	;lea	esi,[ebx+1*(sizeof tVertex)+tVertex.point.x]
	;lea	edx,[ebx+3*(sizeof tVertex)+tVertex.normal.x]
	
	;add	edx,tVertex.point.x-tVertex.color.r
	;mov	eax,edx
	lea	eax,[edx+tVertex.point.x-tVertex.color.r]
	;mov	esi,eax
	;sub	esi,2*(sizeof tVertex)
	lea	esi,[eax-2*(sizeof tVertex)]
	;add	edx,tVertex.normal.x-tVertex.point.x
	add	edx,tVertex.normal.x-tVertex.color.r
	call	sub_vec

	;lea	eax,[ebx+0*(sizeof tVertex)+tVertex.point.x]
	;lea	esi,[ebx+2*(sizeof tVertex)+tVertex.point.x]
	;lea	edx,[ebx+2*(sizeof tVertex)+tVertex.normal.x]
	
	;mov	eax,esi
	;sub	eax,1*(sizeof tVertex)
	lea	eax,[esi-1*(sizeof tVertex)]
	add	esi,1*(sizeof tVertex)
	sub	edx,1*(sizeof tVertex)
	call	sub_vec

	;lea	eax,[ebx+2*(sizeof tVertex)+tVertex.normal.x]
	;lea	esi,[ebx+3*(sizeof tVertex)+tVertex.normal.x]
	;lea	edx,[ebx+3*(sizeof tVertex)+tVertex.normal.x]
	mov	eax,edx
	add	edx,1*(sizeof tVertex)
	mov	esi,edx
	;call	cross_product
	cross_product

;	lea	eax,[ebx+3*(sizeof tVertex)+tVertex.normal.x]

;	lea	edx,[ebx+0*(sizeof tVertex)+tVertex.normal.x]
;	call	load_vec
;	call	store_vec

;	lea	edx,[ebx+1*(sizeof tVertex)+tVertex.normal.x]
;	call	load_vec
;	call	store_vec

;	lea	edx,[ebx+2*(sizeof tVertex)+tVertex.normal.x]
;	call	load_vec
;	call	store_vec

	add	ebx,4*(sizeof tVertex)

	dec	ecx
	jnz	rotaloop

	;loop	rotaloop

	mov	eax,[subdiv]
	shl	eax,2
	add	[edi+tObject.vcnt],eax
	
	fstp	st0
	fstp	st0

	pop	esi
	ret
sgMakeRotaO	endp


sgMakeRota	proc near  settings:dword, subdiv:dword, height:dword, radius2:dword, radius1:dword
	push	esi
	mov	esi,[settings]
	push	[esi+SG_GEN_DATA.sgTranslateYVal]

	push	[radius1]
	push	[radius2]
	push	[height]
	push	[subdiv]
	push	[settings]
	call	sgMakeRotaO
	
	fld	dword ptr [esp]	; pushed sgTranslateYVal
	fiadd	[height]
	fstp	[esi+SG_GEN_DATA.sgTranslateYVal]
	push	0
	push	[radius1]
	push	0
	push	[subdiv]
	push	[settings]
	call	sgMakeRotaO
	
	fld	dword ptr [esp]	; pushed sgTranslateYVal
	fisub	[height]
	fstp	[esi+SG_GEN_DATA.sgTranslateYVal]
	push	[radius2]
	push	0
	push	0
	push	[subdiv]
	push	[settings]
	call	sgMakeRotaO

	pop	[esi+SG_GEN_DATA.sgTranslateYVal]
	pop	esi
	ret
sgMakeRota	endp


sgGenEnd	proc near
	pop	eax	; kill return adress
	popa
	ret
sgGenEnd	endp


sgGenCylinder	proc near
	xor	eax,eax
	lodsb		; radius
	push	eax
	push	eax
	lodsb		; height
	push	eax
sgGenCylinder	endp


sgGenRota	proc near
	;lodsb		; subdivisions
	;push	eax
	push	1
	pop	eax
	shl	eax,cl
	push	eax
	push	ebp	; pointer to scenegen settings
	call	sgMakeRota
	ret
sgGenRota	endp


sgGenCone	proc near
	xor	eax,eax
	lodsb		; radius1
	push	eax
	lodsb		; radius2
	push	eax
	lodsb		; height
	push	eax
	jmp	sgGenRota
sgGenCone	endp


sgGenDisc	proc near
	xor	eax,eax
	lodsb		; outer radius
	push	eax
	push	eax
	push	1	; height
	jmp	sgGenRota
sgGenDisc	endp


sgGenPivot	proc near
	push	edi
	push	2	; z is never used
	pop	ecx
	;mov	ecx,3
	add	edi,tObject.objpos.x
pivotloop:
	movsx	eax,byte ptr [esi]
	inc	esi
	push	eax
	fild	dword ptr [esp]
	fstp	dword ptr [esp]
	pop	eax
	stosd
	loop	pivotloop
	pop	edi
	ret
sgGenPivot	endp

comment #+
sgGenTranslateX	proc near
	movsx	eax,byte ptr [esi]	; xcoord
	inc	esi
	push	eax
	fild	dword ptr [esp]
	pop	eax
	fstp	[ebp+SG_GEN_DATA.sgTranslateXVal]
	ret
sgGenTranslateX	endp


sgGenTranslateY	proc near
	movsx	eax,byte ptr [esi]	; ycoord
	inc	esi
	push	eax
	fild	dword ptr [esp]
	pop	eax
	fstp	[ebp+SG_GEN_DATA.sgTranslateYVal]
	ret
sgGenTranslateY	endp


sgGenTranslateZ	proc near
	movsx	eax,byte ptr [esi]	; zcoord
	inc	esi
	push	eax
	fild	dword ptr [esp]
	pop	eax
	fstp	[ebp+SG_GEN_DATA.sgTranslateZVal]
	ret
sgGenTranslateZ	endp
+#
sgGenTranslate	proc near
	lea	edx,[eax-SG_TRANSLATEX]
	;mov	edx,eax
	;sub	edx,SG_TRANSLATEX
	movsx	eax,byte ptr [esi]	; coord
	inc	esi
	push	eax
	fild	dword ptr [esp]
	pop	eax
	fstp	dword ptr [ebp+edx*4]
	ret
sgGenTranslate	endp


sgGenLink	proc near
	movsx	eax,byte ptr [esi]	; relative index of obj
					; to link actual obj to
	inc	esi
	imul	eax,(sizeof tObject)
	mov	edx,[edi+eax+tObject.ocnt]
	inc	[edi+eax+tObject.ocnt]
	shl	edx,2
	add	edx,[edi+eax+tObject.subobjptr]
	mov	[edx],edi
	ret
sgGenLink	endp


sgDoSwapZY	proc near
	mov	edx,eax
	call	load_vec
	fxch	st1
	fxch	st2
	;call	store_vec
	;ret
	jmp	store_vec
sgDoSwapZY	endp

sgDoSwapYX	proc near
	mov	edx,eax
	call	load_vec
	fxch	st1
	;call	store_vec
	;ret
	jmp	store_vec
sgDoSwapYX	endp

sgGenSwapZY	proc near
	push	ebp
	mov	ebp,offset sgDoSwapZY
	jmp	sgDoSwap
sgGenSwapZY	endp

sgGenSwapYX	proc near
	push	ebp
	mov	ebp,offset sgDoSwapYX
;	jmp	sgDoSwap
sgGenSwapYX	endp

sgDoSwap	proc near
	xor	eax,eax
	lodsb
	;movzx	eax,byte ptr [esi]
	;inc	esi
	shl	eax,2
	mov	ecx,eax
	imul	eax,-(sizeof tVertex)
	lea	eax,[eax+ebx+tVertex.point]
swaploop:
	call	ebp
	add	eax,tVertex.normal-tVertex.point
	call	ebp
	add	eax,(sizeof tVertex)+tVertex.point-tVertex.normal
	loop	swaploop
	pop	ebp
	ret
sgDoSwap	endp

comment #+
sgGenSwapZY	proc near
	movzx	eax,byte ptr [esi]
	inc	esi
	shl	eax,2
	mov	ecx,eax
	imul	eax,-(sizeof tVertex)
	lea	eax,[eax+ebx+tVertex.point]
swapzyloop:
	mov	edx,eax
	call	load_vec
	fxch	st1
	fxch	st2
	call	store_vec
	add	eax,tVertex.normal-tVertex.point
	mov	edx,eax
	call	load_vec
	fxch	st1
	fxch	st2
	call	store_vec
	add	eax,(sizeof tVertex)+tVertex.point-tVertex.normal
	loop	swapzyloop
	ret
sgGenSwapZY	endp


sgGenSwapYX	proc near
	movzx	eax,byte ptr [esi]
	inc	esi
	shl	eax,2
	mov	ecx,eax
	imul	eax,-(sizeof tVertex)
	lea	eax,[eax+ebx+tVertex.point]
swapyxloop:
	mov	edx,eax
	call	load_vec
	fxch	st1
	call	store_vec
	add	eax,tVertex.normal-tVertex.point
	mov	edx,eax
	call	load_vec
	fxch	st1
	call	store_vec
	add	eax,(sizeof tVertex)+tVertex.point-tVertex.normal
	loop	swapyxloop
	ret
sgGenSwapYX	endp
+#

sgGenNewObject	proc near
	; reset sgGenData
	push	edi
	xor	al,al
	mov	edi,ebp
	push	4*3
	pop	ecx
	;mov	ecx,4*3
	rep	stosb
	pop	edi
	; point to next object in table
	add	edi,sizeof tObject
	mov	[edi+tObject.subobjptr],ebx
	add	ebx,4*60	; maximum 60 subobjects
	mov	[edi+tObject.vertexptr],ebx
	ret
sgGenNewObject	endp

comment #+
sgGenSpline	proc near
	push	edi
	push	ebx

	xor	eax,eax
	lodsb		; offset into floattab (div 16)
	shl	eax,4
	mov	edx,eax
	xor	eax,eax
	lodsb		; controlpointcount
	mov	ecx,eax
	lodsb		; dimension
	mov	edi,eax

genlinearloop:
	mov	ebx,edi
	dimensionloop:
		movsx	eax,byte ptr [esi]
		imul	eax,SPL_MUL
		inc	esi
		push	eax
		fild	dword ptr [esp]
		pop	eax
		fstp	dword ptr [script_dword+edx*4]
		inc	edx
		dec	ebx
		jnz	dimensionloop
	loop	genlinearloop

	pop	ebx
	pop	edi

	ret
sgGenSpline	endp
+#

sgGenLinear	proc near
	push	edi
	push	ebx

	xor	eax,eax
	lodsb		; offset into floattab (div 16)
	shl	eax,4
	mov	edx,eax
	xor	eax,eax
	lodsb		; controlpointcount
	;mov	ecx,eax
	;lodsb		; dimension
	;mov	edi,eax
	db	0D4h,20h
	movzx	ecx,al
	movzx	edi,ah

genlinearloop:
	mov	ebx,edi
	dimensionloop:
		movsx	eax,byte ptr [esi]
		imul	eax,SPL_MUL
		inc	esi
		push	eax
		fild	dword ptr [esp]
		pop	eax
		fstp	dword ptr [script_dword+edx*4]
		inc	edx
		dec	ebx
		jnz	dimensionloop
	loop	genlinearloop

	pop	ebx
	pop	edi
	ret
sgGenLinear	endp


sgGenColor	proc near
	push	edi
	lea	edi,[ebp+SG_GEN_DATA.sgColorRVal]
	push	4
	pop	ecx
	mov	edx,dword ptr [esi]		; fake! dont care about the high word...
	inc	esi
	inc	esi
	componentloop:
		mov	eax,edx
		and	eax,0Fh
		shr	edx,4
		push	eax
		fild	dword ptr [esp]
		fmul	dword ptr [oneO16]
		fstp	dword ptr [esp]
		pop	eax
		stosd
	loop	componentloop
	pop	edi
	ret
sgGenColor	endp


sgGenCopy	proc near
	mov	eax,offset gleObjectTable	; automatically register with scene (object 0)
	mov	edx,[eax+tObject.ocnt]
	inc	[eax+tObject.ocnt]
	shl	edx,2
	add	edx,[eax+tObject.subobjptr]
	;lea	edx,[edx*4+eax+tObject.subobjptr]
	;mov	eax,edi
	;add	eax,sizeof tObject
	lea	eax,[edi+sizeof tObject]
	mov	[edx],eax

	movsx	edx,byte ptr [esi]	; relative index of obj to copy
	inc	esi
	imul	edx,(sizeof tObject)	; how many bytes is the relative index worth?  :)

copyobjloop:
	add	edi,sizeof tObject	; new obj

	pusha

	; copy da main object
	mov	esi,edi
	add	esi,edx			; get pointer of source
	push	esi			; save pointer to source
	;mov	ecx,sizeof tObject
	push	sizeof tObject
	pop	ecx
	rep	movsb			; copy it!

	pop	eax			; restore pointer to source

	; now go for the subobjects
	or	ecx,[eax+tObject.ocnt]	; ecx is zero, see da rep movsb  ;)
	jz	donesub
	mov	esi,[eax+tObject.subobjptr]
	mov	edi,ebx
subobjloop:
	lodsd
	sub	eax,edx			; update offset
	stosd
	loop	subobjloop
donesub:

	popa

	mov	[edi+tObject.subobjptr],ebx
	add	ebx,4*60

	;dec	byte ptr [esi]		; destroys the script!!!
	;jnz	copyobjloop
	loop	copyobjloop

	;inc	esi

	ret
sgGenCopy	endp


sgGenerate	proc near
	pusha
	mov	ebp,offset sgGenData
	mov	esi,offset sgSceneScript
	mov	edi,(offset gleObjectTable)-(sizeof tObject)
	mov	ebx,offset gleVertexTable
sgGenLoop:
	lodsb
	db	0D4h,10h
	movzx	ecx,ah
	movzx	eax,al
	call	dword ptr [sgJumpTable+eax*4]
	jmp	sgGenLoop
sgGenerate	endp
