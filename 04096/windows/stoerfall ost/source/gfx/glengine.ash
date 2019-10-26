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



tTexture	struct
	texname		dd ?
	texwidth	dd ?
	texheight	dd ?
	texdata		dd ?
tTexture	ends


tTexCoord2f	struct
	u		dd ?
	v		dd ?
tTexCoord2f	ends


tVector3f	struct
	x		dd ?
	y		dd ?
	z		dd ?
tVector3f	ends


tVector4f	struct
	x		dd ?
	y		dd ?
	z		dd ?
	w		dd ?
tVector4f	ends


tColor4f	struct
	r		dd ?
	g		dd ?
	b		dd ?
	a		dd ?
tColor4f	ends


tVertex		struct
	texcoord	tTexCoord2f <?,?>
	color		tColor4f <?,?,?,?>
	normal		tVector3f <?,?,?>
	point		tVector3f <?,?,?>
tVertex		ends


tFace		struct
	normal		tVector3f <?,?,?>
	flags		dd ?
tFace		ends


tEdge		struct
	p1		dd ?
	p2		dd ?
	f1		dd ?
	f2		dd ?
tEdge		ends


OBJ_BLENDED	equ 00001h
OBJ_TEXTURED	equ 00002h
OBJ_ENVMAPPED	equ 00004h
OBJ_MIRROR	equ 00008h
OBJ_CASTSHADOW	equ 00010h


tObject		struct
;	objname		dd ?

;	flags		dd ?

	visible		dd ?
	
	objpos		tVector3f <?>
	objangle	tVector3f <?>

;	objtexture	dd ?

	vcnt		dd ?
	vertexptr	dd ?

;	 ecnt		 dd ?
;	 edgeptr	 dd ?

;	fcnt		dd ?
;	faceptr		dd ?

	ocnt		dd ?
	subobjptr	dd ?
tObject		ends


tCamera		struct
	fov		dd ?
	aspect		dd ?
	znear		dd ?
	zfar		dd ?
	campos		tVector3f <?>
	camlookat	tVector3f <?>
	camup		tVector3f <?>
tCamera		ends


VL_END		= 0
VL_POS		= 1
VL_POSX		= 2
VL_POSY		= 3
VL_POSZ		= 4
VL_ANGX		= 5
VL_ANGY		= 6
VL_ANGZ		= 7
VL_CAM		= 8
;VL_TGT		= 9
VL_VIS		= 9

gleValLink	macro what,index,obj
	dw	what+((index) shl 4)
	db	obj
endm


	.data

value_jmptbl	label dword
	dd	val_end
	dd	val_pos
	dd	val_posx
	dd	val_posy
	dd	val_posz
	dd	val_angx
	dd	val_angy
	dd	val_angz
	dd	val_cam
	;dd	val_tgt
	dd	val_vis

include script\linkScript.ash


;eins		dd 1.0
;minuseins	dd -10.0

;brems		dd 0.0002
;camradius	dw 1000
;camheight	dw 300

cam		tCamera	< 60.0,1.33333333,10.0,2000.0, \
			  <0.0, 0.0, 0.0>, \
			  <0.0, 0.0, 0.0>, \
			  <0.0, 1.0, 0.0> >
			
if ENABLE_FOG  
fog_mode	dd GL_EXP
fog_density	dd 0.001
fog_color	dd 0.3,0.3,0.3,0.3
endif


	.data?

gleObjectTable	db 128*(sizeof tObject) dup (?)
gleVertexTable	db 128*1024*(sizeof tVertex) dup(?)
scenetexdat	dd 256*256 dup (?)
;cam		tCamera <?>

	.code

gleGetValues	macro
;gleGetValues	proc near
	pusha
	mov	ebx,offset value_links
getvalloop:
	movzx	eax,word ptr [ebx]		; load script opcode
	;add	ebx,2
	inc	ebx
	inc	ebx
	mov	esi,eax
	shr	esi,4
	lea	esi,[script_dword+esi*4]	; decode index into floattab
	and	eax,15				; decode opcode

	movzx	edx,byte ptr [ebx]		; load object number
	;add	ebx,1
	inc	ebx
	imul	edx,sizeof tObject
	lea	edi,[gleObjectTable+tObject.objpos+edx]	; get offset to object
	push	1
	pop	ecx
	;mov	ecx,1
	jmp	[value_jmptbl+eax*4]		; execute opcode
val_cam::
	mov	edi,(offset cam)+tCamera.campos
	add	ecx,3
	;jmp	val_do_copy
;val_tgt::
;	mov	edi,(offset cam)+tCamera.camlookat
;	jmp	val_pos
val_pos::
	add	ecx,2
	jmp	val_do_copy
val_posz::
	add	edi,4
val_posy::
	add	edi,4
val_posx::
	jmp	val_do_copy
val_angz::
	add	edi,4
val_angy::
	add	edi,4
val_angx::
	add	edi,tObject.objangle-tObject.objpos
	jmp	val_do_copy
val_vis::
	sub	edi,4
val_do_copy:
	rep	movsd				; apply the link
	jmp	getvalloop
val_end::
	popa
	;ret
;gleGetValues	endp
endm

if TEXTURES
gleMakeTexture	proc near
	lea	eax,[esi+tTexture.texname]
	push	eax
	push	1
	call	dword ptr [ebx+impglGenTextures]

	push	[esi+tTexture.texname]
	push	GL_TEXTURE_2D
	call	dword ptr [ebx+impglBindTexture]

;	push	GL_MODULATE
;	push	GL_TEXTURE_ENV_MODE
;	push	GL_TEXTURE_ENV
;	call	dword ptr [ebx+impglTexEnvf]

	push	GL_LINEAR
	push	GL_TEXTURE_MIN_FILTER
	push	GL_TEXTURE_2D
	call	dword ptr [ebx+impglTexParameteri]

;	push	GL_LINEAR
;	push	GL_TEXTURE_MAG_FILTER
;	push	GL_TEXTURE_2D
;	call	dword ptr [ebx+impglTexParameteri]

;	 invoke	 glTexEnvf, GL_TEXTURE_ENV,GL_TEXTURE_ENV_MODE,GL_MODULATE
;	 invoke	 glTexParameteri, GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR
;	 invoke	 glTexParameteri, GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR
;	 invoke	 glTexParameteri, GL_TEXTURE_2D,GL_TEXTURE_WRAP_S,GL_REPEAT
;	 invoke	 glTexParameteri, GL_TEXTURE_2D,GL_TEXTURE_WRAP_T,GL_REPEAT

	push	[esi+tTexture.texdata]
	push	GL_UNSIGNED_BYTE
	push	GL_RGBA
	push	0
	push	[esi+tTexture.texheight]
	push	[esi+tTexture.texwidth]
	push	4
	push	0
	push	GL_TEXTURE_2D
	call	dword ptr [ebx+impglTexImage2D]
;	 invoke	 glTexImage2D, GL_TEXTURE_2D,0,4,[esi+tTexture.texwidth],[esi+tTexture.texheight],0,GL_RGBA,GL_UNSIGNED_BYTE,[esi+tTexture.texdata]
	ret
gleMakeTexture	endp
endif

gleRenderObject	proc near
	pusha

	cmp	byte ptr [esi+tObject.visible],0
	jne	no_render

	call	dword ptr [ebx+impglPushMatrix]

	push	[esi+tObject.objpos.z]
	push	[esi+tObject.objpos.y]
	push	[esi+tObject.objpos.x]
	call	dword ptr [ebx+impglTranslatef]
	;invoke	 glTranslatef, [esi+tObject.objpos.x],[esi+tObject.objpos.y],[esi+tObject.objpos.z]

	xor	ebp,ebp			; ebp = 0.0f
	mov	edi,03F800000h		; edi = 1.0f

	push	ebp	;0.0f
	push	edi	;1.0f
	push	ebp	;0.0f
	push	[esi+tObject.objangle.y]
	call	dword ptr [ebx+impglRotatef]
	;invoke	 glRotatef, [esi+tObject.objangle.y], 0,eins,0

	push	ebp	;0.0f
	push	ebp	;0.0f
	push	edi	;1.0f
	push	[esi+tObject.objangle.x]
	call	dword ptr [ebx+impglRotatef]
	;invoke	 glRotatef, [esi+tObject.objangle.x], eins,0,0

	push	edi	;1.0f
	push	ebp	;0.0f
	push	ebp	;0.0f
	push	[esi+tObject.objangle.z]
	call	dword ptr [ebx+impglRotatef]
	;invoke	 glRotatef, [esi+tObject.objangle.z], 0,0,eins

	push	[esi+tObject.vertexptr]
	push	ebp	;0
	push	GL_T2F_C4F_N3F_V3F
	call	dword ptr [ebx+impglInterleavedArrays]

;	lea	edi,[esi+tObject.flags]

if TEXTURES
	test	byte ptr [edi],OBJ_TEXTURED
	jz	obj_no_texture
		push	GL_TEXTURE_2D
		call	dword ptr [ebx+impglEnable]

		mov	ecx,[esi+tObject.objtexture]
		push	[ecx+tTexture.texname]
		push	GL_TEXTURE_2D
		call	dword ptr [ebx+impglBindTexture]
		;invoke	 glBindTexture,	GL_TEXTURE_2D,[ebx+tTexture.texname]
	obj_no_texture:
endif

comment #+
	test	byte ptr [edi],OBJ_BLENDED
	jz	obj_no_blend
		push	GL_BLEND
		call	dword ptr [ebx+impglEnable]
		push	GL_ONE
		push	GL_SRC_ALPHA
		call	dword ptr [ebx+impglBlendFunc]
		;invoke	 glBlendFunc, GL_SRC_ALPHA,GL_ONE
	obj_no_blend:
+#

comment #+
	mov	eax,[esi+tObject.fcnt]
	imul	eax,3

	push	[esi+tObject.faceptr]
	push	GL_UNSIGNED_INT
	push	eax
	push	GL_TRIANGLES
	call	dword ptr [ebx+impglDrawElements]
	;invoke	 glDrawElements,  GL_TRIANGLES,eax,GL_UNSIGNED_INT,[esi+tObject.faceptr]
+#
	push	[esi+tObject.vcnt]
	push	ebp
	push	GL_QUADS
	call	dword ptr [ebx+impglDrawArrays]
;	push	GL_BLEND
;	call	dword ptr [ebx+impglDisable]

if TEXTURES
	push	GL_TEXTURE_2D
	call	dword ptr [ebx+impglDisable]
endif

	mov	ecx,[esi+tObject.ocnt]
	render_obj_loop:
		dec	ecx
		js	render_obj_done
		mov	eax,[esi+tObject.subobjptr]
		mov	eax,[eax+ecx*4]
		xchg	eax,esi
		call	gleRenderObject
		xchg	eax,esi
		jmp	render_obj_loop
	render_obj_done:

	call	dword ptr [ebx+impglPopMatrix]
	
no_render:
	popa
	ret
gleRenderObject	endp


; in	edi = timeindex
gleRenderScene	proc near
;	call	gleGetValues
	gleGetValues
comment #+	
	push	edi

	fild	dword ptr [esp]
	fmul	[brems]
	fsincos
	fimul	[camradius]
	fadd	[script_dword+(220*16-3)*4]
	fstp	[cam.campos.x]
	fimul	[camradius]
	fld	st0
	fadd	[script_dword+(220*16-1)*4]
	fstp	[cam.campos.z]
	fadd	[script_dword+(220*16-2)*4]
	fstp	[cam.campos.y]

	pop	edi
+#
;	fmov	eax,<float>
	db	0B8h
	dd	0.3
	push	eax
	push	eax
	push	eax
	push	eax
	call	dword ptr [ebx+impglClearColor]

	push	GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT
	call	dword ptr [ebx+impglClear]
	
	;push	GL_FILL
	;push	GL_FRONT_AND_BACK
	;call	dword ptr [ebx+impglPolygonMode]

	;push	GL_LESS
	;call	dword ptr [ebx+impglDepthFunc]

	push	GL_PROJECTION
	call	dword ptr [ebx+impglMatrixMode]
	call	dword ptr [ebx+impglLoadIdentity]

comment #+
	;mov	ecx,32
	push	32
	pop	ecx
	sub	esp,ecx
	mov	esi,offset cam.fov
	mov	edi,esp
	rep	movsb
	call	dword ptr [ebx+impgluPerspective]

	mov	esi,offset (cam.campos)
	sub	esp,3*3*(sizeof qword)
	;mov	ecx,3*3-1
	push	3*3-1
	pop	ecx
camconvert:
	fld	dword ptr [esi+ecx*4]
	fstp	qword ptr [esp+ecx*8]
	dec	ecx
	jns	camconvert
	call	dword ptr [ebx+impgluLookAt]
+#

	; copy camfloats as doubles onto the stack
	mov	esi,(offset cam)
	sub	esp,(3*3+4)*(sizeof qword)
	push	(3*3+4)-1
	pop	ecx
camconvert:
	fld	dword ptr [esi+ecx*4]
	fstp	qword ptr [esp+ecx*8]
	dec	ecx
	jns	camconvert

	call	dword ptr [ebx+impgluPerspective]

if ENABLE_FOG
	push	GL_MODELVIEW
	call	dword ptr [ebx+impglMatrixMode]
	call	dword ptr [ebx+impglLoadIdentity]
	call	dword ptr [ebx+impgluLookAt]
else
	call	dword ptr [ebx+impgluLookAt]
	push	GL_MODELVIEW
	call	dword ptr [ebx+impglMatrixMode]
	call	dword ptr [ebx+impglLoadIdentity]
endif

	push	GL_FLAT
	;push	GL_SMOOTH
	call	dword ptr [ebx+impglShadeModel]

	; set lights

	push	(offset script_dword)+(200*16)*4
	push	GL_POSITION
	push	GL_LIGHT0
	call	dword ptr [ebx+impglLightfv]

if ENABLE_FOG
	mov	edi,offset fog_mode
	push	edi
	push	GL_FOG_MODE
	call	dword ptr [ebx+impglFogfv]
	
	add	edi,4
	push	edi
	push	GL_FOG_DENSITY
	call	dword ptr [ebx+impglFogfv]

	add	edi,4
	push	edi
	push	GL_FOG_COLOR
	call	dword ptr [ebx+impglFogfv]
	
	push	GL_FOG
	call	dword ptr [ebx+impglEnable]
endif

	push	GL_LIGHT0
	call	dword ptr [ebx+impglEnable]
	push	GL_DEPTH_TEST
	call	dword ptr [ebx+impglEnable]
	push	GL_NORMALIZE
	call	dword ptr [ebx+impglEnable]
	push	GL_COLOR_MATERIAL
	call	dword ptr [ebx+impglEnable]
	push	GL_LIGHTING
	call	dword ptr [ebx+impglEnable]

	mov	esi,offset gleObjectTable
	call	gleRenderObject

;	invoke	 glDisable, GL_LIGHTING
;	push	GL_COLOR_MATERIAL
;	call	dword ptr [ebx+impglDisable]

;	push	0
;	call	dword ptr [ebx+impglDepthMask]

	;call	gleRenderLight

;	push	1
;	call	dword ptr [ebx+impglDepthMask]

	call	dword ptr [ebx+impglFinish]

	ret
gleRenderScene	endp
