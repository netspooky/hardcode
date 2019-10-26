;
; Demo visuals
;
; Author:
;	s_tec
;

%include "nasmgl.inc"
%include "nasmglu.inc"
%include "win32n.inc"
%include "math.inc"

;-----------------------------------------------------------------------------
; Import and export:
;-----------------------------------------------------------------------------

		global	_demo_init
		global	_demo_render
		extern	s_main_t
		extern	s_main_dt

		;opengl32.dll:
		import	glBegin,		__imp__glBegin@4
		import	glBindTexture,		__imp__glBindTexture@8
		import	glBlendFunc,		__imp__glBlendFunc@8
		import	glClear,		__imp__glClear@4
		import	glDisable,		__imp__glDisable@4
		import	glEnable,		__imp__glEnable@4
		import	glEnd,			__imp__glEnd@0
		import	glCallLists,		__imp__glCallLists@12
		import	glColor4ubv,		__imp__glColor4ubv@4
		import	glLineWidth,		__imp__glLineWidth@4
		import	glListBase,		__imp__glListBase@4
		import	glLoadIdentity,		__imp__glLoadIdentity@0
		import	glRotatef,		__imp__glRotatef@16
		import	glScalef,		__imp__glScalef@12
		import	glTexCoord2f,		__imp__glTexCoord2f@8
		import	glTexParameteri,	__imp__glTexParameteri@12
		import	glTranslatef,		__imp__glTranslatef@12
		import	glVertex2f,		__imp__glVertex2f@8
		import	glVertex3fv,		__imp__glVertex3fv@4
		import	glViewport,		__imp__glViewport@16
		import	wglUseFontOutlines,	__imp__wglUseFontOutlinesA@32

		;glu32.dll:
		import	gluPerspective,		__imp__gluPerspective@32
		import	gluBuild2DMipmaps,	__imp__gluBuild2DMipmaps@28

		;gdi32.dll
		import	CreateFont,		__imp__CreateFontA@56
		import	SelectObject,		__imp__SelectObject@8

		;Should be in win32n.h:
%define ANTIALIASED_QUALITY     4
%define WGL_FONT_LINES		0
%define WGL_FONT_POLYGONS	1

;-----------------------------------------------------------------------------
; Constants:
;-----------------------------------------------------------------------------

		;Timing:
k_note		equ	2*1111*16
k_fire_start	equ	k_note*(4*16+2)
k_flow_start	equ	k_fire_start + k_note*(4*8-1)
k_demo_end	equ	k_flow_start + k_note*(4*16)

		;Counts:
k_dot_size	equ	4*8
k_open_cols	equ	6			;Number of drop effects
k_open_dots	equ	40			;Particles per drop
k_splash_segs	equ	40
k_fire_dots	equ	200
k_flow_lines	equ	200
k_flow_segs	equ	100

struc dot	;Common particle structure:
.x:		resd	1
.y:		resd	1
.z:		resd	1
.s:		resd	1
.i:		resd	1
endstruc

struc dotom	;Opening particle:
		resb	dot_size
.r:		resd	1			;Next flicker value
.t:		resd	1			;Next flicker time
endstruc

struc dotos	;Child particle:
		resb	dot_size
.r:		resd	1			;Orbit radius
.t:		resd	1			;Current time counter
.tmax:		resd	1			;Maximum time
endstruc

struc dotf	;Fire particle
		resb	dot_size
.phi:		resd	1			;Angle from horizontal
.theta:		resd	1			;Angle around y
.rho:		resd	1			;Radius
endstruc

struc line	;Flow lines
.t:		resd	1			;Starting time
.dt:		resd	1			;Time increase
.len:		resd	1			;Total length
.i:		resd	1			;Luminosity
.r:		resd	1			;Width
endstruc

;-----------------------------------------------------------------------------
; Unitialized data:
;-----------------------------------------------------------------------------
		section .bss

		alignb	4
s_tex_mono:	resb	256*256 + 4
s_tex_color:	resd	256*256
s_flow_tex:	resd	256+4

s_open_dots:	resb	k_open_cols*k_open_dots*k_dot_size
s_open_clones:	resb	k_open_cols*k_open_dots*k_dot_size
s_open_right:	resd	3

s_fire_dots:	resb	k_fire_dots*k_dot_size
s_flow_lines:	resb	k_flow_lines*line_size

s_demo_zero:	resd	3

;-----------------------------------------------------------------------------
; Initialized data:
;-----------------------------------------------------------------------------
		section	.data

		;Colors 0xaabbggrr:
s_demo_white:	dd	0xffffffff
s_demo_black:	dd	0x00000000
s_open_border:	dd	0x80603c30
s_open_floor1:	dd	0xff502010
s_open_floor2:	dd	0xff000000
s_open_floor3:	dd	0xff140804
s_fire_back1:	dd	0xff000080
s_fire_back2:	dd	0xff2020e0
s_fire_arrow:	dd	0x30000000
s_flow_back1:	dd	0xff806000
s_flow_back2:	dd	0xff483000
s_text_black:	dd	0xff000000

		;Opening particle locations:
s_open_cols:	dd	24.0, 34.13, 8.0
		dd	-12.0, 42.66, 0.0
		dd	0.0, 51.19, -10.0
		dd	-5.0, 59.73, 15.0
		dd	20.0, 63.99, 0.0
		dd	-10.0, 68.26, -5.0
s_open_k1:	dd	0.00003			;Falling speed
s_open_k2:	dd	176400			;Flicker speed
s_open_k3:	dd	0.1			;Flicker decay
s_open_k4:	dd	0.15			;Reflection amount
s_open_k5:	dd	80000.0			;Sub-particle max time
s_open_k6:	dd	12.0			;Particle flow height
s_open_k7:	dd	4.0			;Main particle size
s_open_k8:	dd	5.0			;Orbit factor
s_splash_k1:	dd	0.5			;Splash speed
s_splash_k2:	dd	0.161107		;Ring increment
s_splash_k3:	dd	20.0			;Splash radius
s_open_env:	dd	3.1416,	k_note*(4*8)
		dd	3.1416,	k_note*(4*8)
		dd	0

		;Fireball parameters:
s_fire_k1:	dd	0.00001472		;Rotation speed
s_fire_k2:	dd	0.000044183065		;Pulse speed
s_fire_env:	dd	0.0,	k_fire_start
		dd	0.0,	k_note*3
		dd	0.75,	k_note*(4 + 2*8)
		dd	0.75,	k_note*(8)
		dd	1.25
s_fire_center:	dd	0.0, 0.0, 0.0, 1.0, 1.0

		;Flow texture ramp:
s_flow_path:	dd	0.0,	128
		dd	24.0,	128
		dd	0.0
		
		;Flow parameters:
s_flow_k1:	dd	0.00001			;Max line speed
s_flow_k2:	dd	0.03			;Max line length
s_flow_k3:	dd	0.007			;1/k_flow_segs
s_flow_k4:	dd	6.0			;Radius
s_flow_k5:	dd	4.0			;Torus factor
s_flow_k6:	dd	3.0			;Torus factor
s_flow_k7:	dd	0.0001			;Camera speed

		;Right-facing vector for particle alignment:
s_demo_right:	dd	1.0, 0.0, 0.0

s_text_font:	db	'arial', 0
s_text_text:	db	'{kandy', 0
		align	4, db 0

		;Flow texture ramp:
s_text_path:	dd	0.0,	k_flow_start + k_note*4*8
		dd	0.0,	k_note*8
		dd	255.0,	k_note*3*8
		dd	255.0

;-----------------------------------------------------------------------------
; _demo_init
;
; Initializes demo resources, such as fonts and textures
;
; Parameters:
;	esi	Device context
; Preserves:
;	esi
;-----------------------------------------------------------------------------
		section	.text
_demo_init:
		push	esi
		cld

		;Create the font:
		push	s_text_font		;lpszFace
		push	FF_DONTCARE|DEFAULT_PITCH;fdwPitchAndFamily	
		push	ANTIALIASED_QUALITY	;fdwQuality
		push	CLIP_DEFAULT_PRECIS	;fdwClipPrecision
		push	OUT_TT_PRECIS		;fdwOutputPrecision
		push	OEM_CHARSET		;fdwCharSet
		push	FALSE			;fdwStrikeOut
		push	FALSE			;fdwUnderline
		push	FALSE			;fdwItalic
		push	FW_THIN			;fnWeight
		push	0			;nOrientation
		push	0			;nEscapement
		push	0			;nWidth
		push	10			;nHeight
		call	CreateFont

		;Select the font:
		push	eax			;hgdiobj
		push	esi			;hdc
		call	SelectObject

		;Create the solid font display lists:
		push	0			;lpgmf 
		push	WGL_FONT_LINES		;format
		push	0x00000000		;extrusion
		push	0x00000000		;deviation
		push	'a'			;listBase
		push	26			;count
		push	'a'			;first
		push	esi			;hdc
		call	wglUseFontOutlines
		push	0			;lpgmf 
		push	WGL_FONT_LINES		;format
		push	0x00000000		;extrusion
		push	0x00000000		;deviation
		push	'{'			;listBase
		push	1			;count
		push	230			;first
		push	esi			;hdc
		call	wglUseFontOutlines

		;Set up our designish viewport:
		push	410;320			;height
		push	1024;800			;width
		push	179;140			;y
		push	0			;x
		call	glViewport

		;Turn on the nice settings:
		push	GL_BLEND		;cap
		call	glEnable
		push	GL_LINE_SMOOTH		;cap
		call	glEnable

		;Write the basic texture in index form:
		mov	edi, s_tex_mono
		mov	edx, 256
		fld	dword[s_f255]		;y
.repeaty:	mov	ecx, 256
		fld	dword[s_f255]		;x,y
.repeatx:	fld	st1			;y,x,y
		fmul	st0, st0		;y^2,x,y
		fld	st1			;x,y^2,x,y
		fmul	st0, st0		;x^2,y^2,x,y
		faddp	st1, st0		;x^2+y^2,x,y
		fsqrt				;sqrt(x^2+y^2),x,y
		fistp	dword[edi]		;x,y
		cmp	byte[edi+1], 0
		jz	.skip
		mov	byte[edi], 255
.skip:		fsub	dword[s_f2]		;x-=2,y
		add	edi, 1
		loop	.repeatx, ecx
		fstp	st0			;y
		fsub	dword[s_f2]		;y-=2
		loop	.repeaty, edx
		fstp	st0			;

;-----------------------------------------------------------------------------
; _open_tex
;
; Builds the opening particle texture.
;-----------------------------------------------------------------------------
_open_tex:
		;Build an RGBA texture with an alpha ramp:
		mov	esi, s_tex_mono
		mov	edi, s_tex_color
		mov	ecx, 256*256
.repeat:	dec	dword[edi]		;edi = 0xffffffff
		lodsb
		mov	dl, al
		shr	al, 1			;al = 0.5*al
		test	al, 0xc0
		jnz	.skip			;al >= 64
		add	al, dl			;al = 1.5*al
		sub	al, 0x80
.skip:		not	al			;al = 0xff-al
		sub	al, 0x80
		mov	[edi+3], al
		add	edi, 4
		loop	.repeat

		;Bind to texture 1:
		push	1			;texture
		push	GL_TEXTURE_2D		;target
		call	glBindTexture

		;Load the texture:
		push	s_tex_color		;data
		push	GL_UNSIGNED_BYTE	;type
		push	GL_RGBA			;format
		push	256			;height
		push	256			;width
		push	4			;components
		push	GL_TEXTURE_2D		;target
		call	gluBuild2DMipmaps

		;Pretty mipmapping:
		push	GL_LINEAR_MIPMAP_LINEAR	;param
		push	GL_TEXTURE_MIN_FILTER	;pname
		push	GL_TEXTURE_2D		;target
		call	glTexParameteri

;-----------------------------------------------------------------------------
; _fire_tex
;
; Builds the fireball particle texture.
;-----------------------------------------------------------------------------
_fire_tex:
		;Reduce the blue component to make the texture yellow:
		mov	esi, s_tex_mono
		mov	edi, s_tex_color
		mov	ecx, 256*256
.repeat:	lodsb
		add	al, al			;al = 2*al
		jnc	.skip			;Clamp to 0xff
		mov	al, 0xff
.skip:		not	al			;al = 0xff-al
		mov	[edi+2], al
		add	edi, 4
		loop	.repeat

		;Bind to texture 2:
		push	2			;texture
		push	GL_TEXTURE_2D		;target
		call	glBindTexture

		;Load the texture:
		push	s_tex_color		;data
		push	GL_UNSIGNED_BYTE	;type
		push	GL_RGBA			;format
		push	256			;height
		push	256			;width
		push	4			;components
		push	GL_TEXTURE_2D		;target
		call	gluBuild2DMipmaps

		;Pretty mipmapping:
		push	GL_LINEAR_MIPMAP_LINEAR	;param
		push	GL_TEXTURE_MIN_FILTER	;pname
		push	GL_TEXTURE_2D		;target
		call	glTexParameteri

;-----------------------------------------------------------------------------
; _flow_tex
;
; Builds the flow background texture.
;-----------------------------------------------------------------------------
_flow_tex:
		;Render the texture:
		mov	edi, s_flow_tex
		mov	ecx, 256
.repeat:	mov	eax, ecx
		mov	esi, s_flow_path
		call	_path			;k
		random				;r,k
		fmul	st0, st1		;r*k,k
		faddp	st1, st0		;k+r*k
		fistp	dword[edi]
		add	edi, 1
		loop	.repeat

		;Bind to texture 3
		push	3			;texture
		push	GL_TEXTURE_2D		;target
		call	glBindTexture

		;Load the texture:
		push	s_flow_tex		;data
		push	GL_UNSIGNED_BYTE	;type
		push	GL_LUMINANCE		;format
		push	1			;height
		push	256			;width
		push	1			;components
		push	GL_TEXTURE_2D		;target
		call	gluBuild2DMipmaps

;-----------------------------------------------------------------------------
; _open_dot_init
;
; Builds the array of opening particles.
;-----------------------------------------------------------------------------
_open_dot_init:
		mov	esi, s_open_cols
		mov	ebp, s_open_dots
		mov	edx, k_open_cols

.repeat1:	mov	edi, ebp
		v3mov
		inc	dword[ebp+dotom.t]

		;Prepare for the child particle loop:
		add	ebp, k_dot_size
		mov	ecx, k_open_dots-1
.repeat2:	random				;r
		fstp	dword[ebp+dot.s]	;
		random				;r
		fmul	dword[s_open_k8]	;r*k8
		fstp	dword[ebp+dotos.r]	;
		random				;r
		fabs				;|r|
		fmul	dword[s_open_k5]	;|r|*k5
		fadd	dword[s_open_k5]	;|r|*2k5
		fist	dword[ebp+dotos.tmax]	;|r|*k5
		random				;r,|r|*k5
		fabs				;|r|,|r|*k5
		fmulp	st1, st0		;|r|*|r|*k5
		fistp	dword[ebp+dotos.t]	;
		add	ebp, k_dot_size
		loop	.repeat2

		add	esi, 12
		loop	.repeat1, edx

;-----------------------------------------------------------------------------
; _fire_dot_init
;
; Builds the array of fire particles.
;-----------------------------------------------------------------------------
_fire_dot_init:
		mov	ebp, s_fire_dots
		mov	ecx, k_fire_dots
		fld1				;1

.repeat:	fst	dword[ebp+dot.i]	;1
		random				;r,1
		fld	st0			;r,r,1
		fmul	st0, st0		;r*r,r,1
		fsubr	st0, st2		;1-r*r,r,1
		fpatan				;asin(r),1
		fstp	dword[ebp+dotf.phi]	;1
		random				;r,1
		fldpi				;pi,r,1
		fmulp	st1, st0		;pi*r,1
		fstp	dword[ebp+dotf.theta]	;1
		random				;r,1
		fadd	st0, st1		;r+1,1
		fsqrt				;sqrt(r+1),1
		fmul	dword[s_f8]		;8*sqrt(r+1),1
		fstp	dword[ebp+dotf.rho]	;1

		add	ebp, k_dot_size	
		loop	.repeat
		fstp	st0

;-----------------------------------------------------------------------------
; _flow_lines_init
;
; Builds the array of lines.
;-----------------------------------------------------------------------------
_flow_lines_init:
		mov	ebp, s_flow_lines
		mov	ecx, k_flow_lines

.repeat:	random				;r
		fldpi				;pi,r
		fmulp	st1, st0		;r*pi
		fstp	dword[ebp+line.t]	;
		random				;r
		fabs				;|r|
		fmul	dword[s_flow_k1]	;|r|*k1
		fstp	dword[ebp+line.dt]	;
		random				;r
		fabs				;|r|
		fmul	dword[s_flow_k2]	;|r|*k2
		fstp	dword[ebp+line.len]	;
		random				;r
		fabs				;|r|
		fstp	dword[ebp+line.i]	;
		random				;r
		fstp	dword[ebp+line.r]	;

		add	ebp, line_size	
		loop	.repeat

		pop	esi
		ret

;-----------------------------------------------------------------------------
; _demo_render
;
; Main drawing code.
;
; Returns:
;	eax	0 to exit the demo, 1 to continue running
; Preserves:
;	esi
;-----------------------------------------------------------------------------
		section	.text
_demo_render:
		;Pick an effect based on time:
		mov	eax, [s_main_t]
		cmp	eax, k_fire_start
		jl	near _open_render
		cmp	eax, k_flow_start
		jl	near _fire_render
		cmp	eax, k_demo_end
		jl	near _flow_render

		;Otherwise, quit:
		xor	eax, eax
		ret

;-----------------------------------------------------------------------------
; _open_render
;
; Displays the opening particle effect.
;
; Same signature as _demo_render
;-----------------------------------------------------------------------------
_open_render:
		push	esi

		;Clear the canvas:
		push	GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT
		call	glClear

		;Make vertex coordinates match screen coordinates:
		call	glLoadIdentity

		;Alpha bending mode:
		push	GL_ONE_MINUS_SRC_ALPHA	;dfactor
		push	GL_SRC_ALPHA		;sfactor
		call	glBlendFunc

		;Two-pixel lines:
		push	0x40000000		;width = 2.0f
		call	glLineWidth

		;Render the rectangle:
		push	GL_QUAD_STRIP		;mode
		call	glBegin
		push	s_open_floor1		;v
		call	glColor4ubv
		push	0xbf800000		;y = -1
		push	0xbf800000		;x = -1
		call	glVertex2f
		push	0xbf800000		;y = -1
		push	0x3f800000		;x = 1
		call	glVertex2f
		push	s_open_floor2		;v
		call	glColor4ubv
		push	0x00000000		;y = 0
		push	0xbf800000		;x = -1
		call	glVertex2f
		push	0x00000000		;y = 0
		push	0x3f800000		;x = 1
		call	glVertex2f
		push	s_open_floor3		;v
		call	glColor4ubv
		push	0x3f800000		;y = 1
		push	0xbf800000		;x = -1
		call	glVertex2f
		push	0x3f800000		;y = 1
		push	0x3f800000		;x = 1
		call	glVertex2f
		call	glEnd

		;Render the top and bottom borders:
		push	s_open_border		;v
		call	glColor4ubv
		push	GL_LINES		;mode
		call	glBegin
		push	0xbf800000		;y = -1
		push	0xbf800000		;x = -1
		call	glVertex2f
		push	0xbf800000		;y = -1
		push	0x3f800000		;x = 1
		call	glVertex2f
		push	0x3f800000		;y = 1
		push	0xbf800000		;x = -1
		call	glVertex2f
		push	0x3f800000		;y = 1
		push	0x3f800000		;x = 1
		call	glVertex2f
		call	glEnd

		;Project the geometry in 3D:
		call	glLoadIdentity
		push	0x40890000		;zFar = 800.0
		push	0x00000000
		push	0x3ff00000		;zNear = 1.0
		push	0x00000000
		push	0x40040000		;aspect = 2.5
		push	0x00000000
		push	0x40468000		;fovy = 45.0
		push	0x00000000
		call	gluPerspective

		;Additive bending mode:
		push	GL_ONE			;dfactor
		push	GL_SRC_ALPHA		;sfactor
		call	glBlendFunc

		;One-pixel lines:
		push	0x3f800000		;width = 1.0f
		call	glLineWidth

;-----------------------------------------------------------------------------
; _open_render1
; Sets up the camera for the effect.
;-----------------------------------------------------------------------------
_open_render1:
		;Calculate the sines and cosines
		mov	esi, s_open_env
		mov	eax, [s_main_t]
		call	_path			;t
		fcos				;t
		fldpi				;pi,t
		fmul	st0,st1			;pi*t,t
		fsincos				;c,s,t
		fstp	dword[s_open_right+dot.x]	;c,s,t
		fstp	dword[s_open_right+dot.z]	;s,t
		fmul	dword[s_f180]			;degrees
		fstp	dword[s_temp]			;

		;Translate backwards:
		push	0xc2000000		;z = -32
		push	0xc0800000		;y = -4
		push	0x00000000		;x
		call	glTranslatef
		
		;Rotate:
		push	0x00000000		;z
		push	0x3f800000		;y
		push	0x00000000		;x
		push	dword[s_temp]		;angle
		call	glRotatef

;-----------------------------------------------------------------------------
; _open_render2
; Prepares the particle system for rendering.
;-----------------------------------------------------------------------------
_open_render2:
		;Prepare for the master particle loop:
		mov	ebp, s_open_dots
		mov	edx, k_open_cols

		;Update the master particle:
.repeat1:	fldz				;0
		fild	dword[s_main_dt]	;dt,0
		fmul	dword[s_open_k1]	;dt*k1,0
		fsubr	dword[ebp+dot.y]	;y-dt*k1,0
		fst	dword[ebp+dot.y]	;y,0

		;Kill the particle if its past the end:
		fcomip	st1			;0
		jnbe	.skip2			;Jump if st0 > st1
		fst	dword[ebp+dotom.t]	;0
		fst	dword[ebp+dotom.r]	;0
		
		;Animate the flicker:
.skip2:		fstp	st0			;
		dec	dword[ebp+dotom.t]
		jnz	.skip1
		random				;r
		fabs				;|r|
		fmul	dword[s_open_k2]	;|r|*k2
		fistp	dword[ebp+dotom.t]	;
		inc	dword[ebp+dotom.t]
		random				;r
		fabs				;|r|
		fsqrt				;sqrt|r|
		fstp	dword[ebp+dotom.r]	;
.skip1:		fld	dword[ebp+dotom.r]	;r
		fsub	dword[ebp+dot.i]	;r-i
		fmul	dword[s_open_k3]	;(r-i)*k3
		fadd	dword[ebp+dot.i]	;i+(r-i)*k3
		fst	dword[ebp+dot.i]	;i
		fmul	dword[s_open_k7]	;i*k7
		fstp	dword[ebp+dot.s]	;

		;Prepare for the child particle loop:
		mov	esi, ebp
		add	ebp, k_dot_size
		mov	ecx, k_open_dots-1
.repeat2:	mov	eax, dword[ebp+dotos.t]
		add	eax, dword[s_main_dt]
		mov	dword[ebp+dotos.t], eax
		cmp	eax, dword[ebp+dotos.tmax]
		jl	near .skip3

		;Reset dead particles:
		random				;r
		fstp	dword[ebp+dot.s]	;
		random				;r
		fadd	st0, st0		;2r
		fstp	dword[ebp+dotos.r]	;
		random				;r
		fabs				;|r|
		fmul	dword[s_open_k5]	;|r|*k5
		fadd	dword[s_open_k5]	;|r|*2k5
		fistp	dword[ebp+dotos.tmax]	;
		mov	dword[ebp+dotos.t], 0
		cmp	dword[esi+dotom.t], 0
		jg	.skip3
		fldz				;0
		fstp	dword[ebp+dot.s]	;

		;Update the particle state:
.skip3:		fild	dword[ebp+dotos.t]	;t
		fidiv	dword[ebp+dotos.tmax]	;t/=tmax
		fld1				;1,t
		fsub	st0, st1		;1-t,t
		fstp	dword[ebp+dot.i]	;t
		fld	st0			;t,t
		fmul	dword[s_open_k6]	;t*k6,t
		fadd	dword[esi+dot.y]	;y+t*k6,t
		fst	dword[ebp+dot.y]	;t,t
		fsincos				;c,s,t
		fmul	st0, st2		;t*c,s,t
		fmul	dword[ebp+dotos.r]	;r*t*c,s,t
		fadd	dword[esi+dot.x]	;x+r*c,s,t
		fstp	dword[ebp+dot.x]	;s,t
		fmulp	st1, st0		;t*s
		fmul	dword[ebp+dotos.r]	;r*t*s,t
		fadd	dword[esi+dot.z]	;x+r*s,t
		fstp	dword[ebp+dot.z]	;

		;Advance to the next child particle:
		add	ebp, k_dot_size
		loop	.repeat2

		;Advance to the next master particle:
		add	esi, 12
		loop	.repeat1, edx

;-----------------------------------------------------------------------------
; _open_render3
; Renders the particle system splashes
;-----------------------------------------------------------------------------
_open_render3:
		;Render the splashes:
		mov	ebp, s_open_dots
		mov	esi, k_open_cols

		;Set up the particle center:
.repeat1:	push	GL_TRIANGLE_FAN		;mode
		call	glBegin
		push	s_demo_black		;v
		call	glColor4ubv
		push	ebp			;v
		call	glVertex3fv
		fldz				;0
		fmin	dword[ebp+dot.y]	;min(y,0)
		fmul	dword[s_splash_k1]	;y*=speed
		fmax	dword[s_fn1]		;max(y,-1)
		fabs				;y
		fsqrt				;y
		mov	dword[s_temp], 0xffffffff
		fld1				;1,y
		fsub	st0, st1		;1-y,y
		fmul	st0, st0		;i,y
		fmul	dword[s_f255]		;i*=255,y
		fistp	dword[s_temp+3]		;y
		push	s_temp			;v
		call	glColor4ubv
		fmul	dword[s_splash_k3]	;r
		fldz				;0,r
		mov	edi, k_splash_segs

		;Render the ring:
.repeat2:	fld	st0			;t,t,r
		fsincos				;c,s,t,r
		fmul	st0, st3		;c*r,s,t,r
		fadd	dword[ebp+dot.x]	;x+c*r,s,t,r
		fstp	dword[s_temp+dot.x]	;s,t,r
		fmul	st0, st2		;s*r,t,r
		fadd	dword[ebp+dot.z]	;z+s*r,t,r
		fstp	dword[s_temp+dot.z]	;t,r
		fldz				;0,t,r
		fstp	dword[s_temp+dot.y]	;t,r
		push	s_temp			;v
		call	glVertex3fv
		fadd	dword[s_splash_k2]	;t+=k2
		loop	.repeat2, edi

		fstp	st0			;r
		fstp	st0			;
		call	glEnd	
		add	ebp, k_open_dots*k_dot_size
		loop	.repeat1, esi

;-----------------------------------------------------------------------------
; _open_render4
; Renders the particle system and its reflection.
;-----------------------------------------------------------------------------
_open_render4:
		;Activate texture 1:
		push	1			;texture
		push	GL_TEXTURE_2D		;target
		call	glBindTexture
		push	GL_TEXTURE_2D		;cap
		call	glEnable
		push	s_demo_white		;v
		call	glColor4ubv

		;Copy the data to the clone particle array:
		mov	esi, s_open_dots
		mov	edi, s_open_clones
		mov	ecx, k_open_cols*k_open_dots*k_dot_size
		rep movsb

		;Adjust the clones:
		mov	ebp, s_open_clones
		mov	ecx, k_open_cols*k_open_dots
.repeat2:	fld	dword[ebp+dot.y]
		fchs
		fstp	dword[ebp+dot.y]
		fld	dword[ebp+dot.i]
		fmul	dword[s_open_k4]
		fstp	dword[ebp+dot.i]
		add	ebp, k_dot_size
		loop	.repeat2

		;Render the reflection array:
		push	s_open_right		;aDirection
		push	k_open_cols*k_open_dots	;aParticleN
		push	s_open_clones		;aParticles
		call	_dot_render

		;Render the particle array:
		push	s_open_right		;aDirection
		push	k_open_cols*k_open_dots	;aParticleN
		push	s_open_dots		;aParticles
		call	_dot_render

		;Texturing off:
		push	GL_TEXTURE_2D		;cap
		call	glDisable

		mov	eax, 1
		pop	esi
		ret

;-----------------------------------------------------------------------------
; _fire_render
;
; Displays the spinning fire ball effect.
;
; Same signature as _demo_render
;-----------------------------------------------------------------------------
_fire_render:
		push	esi

		;Clear the canvas:
		push	GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT
		call	glClear

		;Make vertex coordinates match screen coordinates:
		call	glLoadIdentity

		;Alpha bending mode:
		push	GL_ONE_MINUS_SRC_ALPHA	;dfactor
		push	GL_SRC_ALPHA		;sfactor
		call	glBlendFunc

		;Render the rectangle:
		push	GL_QUAD_STRIP		;mode
		call	glBegin
		push	s_fire_back1		;v
		call	glColor4ubv
		push	0xbf800000		;y = -1
		push	0xbf800000		;x = -1
		call	glVertex2f
		push	0xbf800000		;y = -1
		push	0x3f800000		;x = 1
		call	glVertex2f
		push	s_fire_back2		;v
		call	glColor4ubv
		push	0x3f800000		;y = 1
		push	0xbf800000		;x = -1
		call	glVertex2f
		push	0x3f800000		;y = 1
		push	0x3f800000		;x = 1
		call	glVertex2f
		call	glEnd

		;Render the arrows:
		push	s_fire_arrow		;v
		call	glColor4ubv
		mov	ecx, 3

		;Render one arrow:
.repeat:	push	ecx
		push	GL_QUAD_STRIP		;mode
		call	glBegin
		push	0xbf800000		;y = -1
		push	0xbf000000		;x = -0.5 = 200/400-1
		call	glVertex2f
		push	0xbf800000		;y = -1
		push	0xbe999999		;x = -0.3 = 280/400-1
		call	glVertex2f
		push	0x00000000		;y = -1
		push	0xbdcccccc		;x = -0.1 = 360/400-1
		call	glVertex2f
		push	0x00000000		;y = -1
		push	0x3dcccccc		;x = 0.1 = 440/400-1
		call	glVertex2f
		push	0x3f800000		;y = 1
		push	0xbf000000		;x = -0.5 = 200/400-1
		call	glVertex2f
		push	0x3f800000		;y = 1
		push	0xbe999999		;x = -0.3 = 280/400-1
		call	glVertex2f
		call	glEnd

		;Translate backwards:
		push	0x00000000		;z
		push	0x00000000		;y
		push	0xbecccccc		;x = -0.4 = -160/400
		call	glTranslatef
		pop	ecx
		loop	.repeat

		;Project the geometry in 3D:
		call	glLoadIdentity
		push	0x40890000		;zFar = 800.0
		push	0x00000000
		push	0x3ff00000		;zNear = 1.0
		push	0x00000000
		push	0x40040000		;aspect = 2.5
		push	0x00000000
		push	0x40468000		;fovy = 45.0
		push	0x00000000
		call	gluPerspective

		;One-pixel lines:
		push	0x3f800000		;width = 1.0f
		call	glLineWidth

		;Activate texture 2:
		push	2			;texture
		push	GL_TEXTURE_2D		;target
		call	glBindTexture
		push	GL_TEXTURE_2D		;cap
		call	glEnable
		push	s_demo_white		;v
		call	glColor4ubv

		;Translate backwards:
		push	0xc1e00000		;z = -28
		push	0x00000000		;y
		push	0x41800000		;x = 16
		call	glTranslatef

		;Render the center particle:
		push	s_demo_right		;aDirection
		push	1			;aParticleN
		push	s_fire_center		;aParticles
		call	_dot_render
		
;-----------------------------------------------------------------------------
; _fire_render2
; Animates the fire particle system using the following formulas:
;
; s = cos(phi+t)+sin(2theta+t)
; x = r*cos(theta+t)*cos(phi)
; z = r*sin(theta+t)*cos(phi)
; y = r*sin(phi)
;-----------------------------------------------------------------------------
_fire_render2:
		;Prepare the particles:
		mov	ebp, s_fire_dots
		mov	ecx, k_fire_dots
		mov	esi, s_fire_env
		mov	eax, [s_main_t]
		call	_path			;b
		fild	dword[s_main_t]		;t2,b
		fmul	dword[s_fire_k2]
		fild	dword[s_main_t]		;t1,t2,b
		fmul	dword[s_fire_k1]

.repeat1:	;Pulse effect:
		fld	dword[ebp+dotf.phi]	;phi,t1,t2
		fadd	st0, st2		;phi+t,t1,t2
		fcos				;s,t1,t2
		fld	dword[ebp+dotf.theta]	;theta,s,t1,t2
		fadd	st0, st0		;2theta,s,t1,t2
		fadd	st0, st3		;2theta+t,s,t1,t2
		fsin				;s,s,t1,t2
		faddp	st1, st0		;s,t1,t2,b
		fmul	st0, st3		;s*b,t1,t2,b
		fstp	dword[ebp+dot.s]

		;Particle position:
		fld	dword[ebp+dotf.phi]	;phi,t1,t2
		fsincos				;c,s,t1,t2
		fmul	dword[ebp+dotf.rho]	;c*r,s,t1,t2
		fld	dword[ebp+dotf.theta]	;theta,c*r,s,t1,t2
		fsub	st0, st3		;theta+t,c*r,s,t1,t2
		fsincos				;c,s,c*r,s,t1,t2
		fmul	st0, st2		;c*c*r,s,c*r,s,t1,t2
		fstp	dword[ebp+dot.x]	;s,c*r,s,t1,t2
		fmulp	st1, st0		;s*c*r,s,t1,t2
		fstp	dword[ebp+dot.z]	;s,t1,t2
		fmul	dword[ebp+dotf.rho]	;s*r,t1,t2
		fstp	dword[ebp+dot.y]	;t1,t2

		add	ebp, k_dot_size
		loop	.repeat1
		fstp	st0			;t2,b
		fstp	st0			;b
		fstp	st0			;

;-----------------------------------------------------------------------------
; _fire_render3
; Renders the fire particle sytem
;-----------------------------------------------------------------------------
_fire_render3:
		;Render the lines:
		push	GL_LINES		;mode
		call	glBegin
		mov	esi, s_fire_dots
		mov	ecx, k_fire_dots
.repeat2:	push	ecx
		push	0x3f000000		;t = 0.5
		push	0x3f800000		;s = 1.0
		call	glTexCoord2f
		push	s_demo_zero
		call	glVertex3fv		
		push	0x3f000000		;t = 0.5
		push	0x3f000000		;s = 0.5
		call	glTexCoord2f
		push	esi
		call	glVertex3fv
		add	esi, k_dot_size
		pop	ecx	
		loop	.repeat2
		call	glEnd

		;Render the particles:
		push	s_demo_right		;aDirection
		push	k_fire_dots		;aParticleN
		push	s_fire_dots		;aParticles
		call	_dot_render

		;Texturing off:
		push	GL_TEXTURE_2D		;cap
		call	glDisable

		mov	eax, 1
		pop	esi
		ret

;-----------------------------------------------------------------------------
; _flow_render
;
; Displays the ribbon torus effect.
;
; Same signature as _demo_render
;-----------------------------------------------------------------------------
_flow_render:
		push	esi

		;Clear the canvas:
		push	GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT
		call	glClear

		;Make vertex coordinates match screen coordinates:
		call	glLoadIdentity

		;Additive bending mode:
		push	GL_ONE			;dfactor
		push	GL_SRC_ALPHA		;sfactor
		call	glBlendFunc

		;Render the rectangle:
		push	GL_QUAD_STRIP		;mode
		call	glBegin
		push	s_flow_back1		;v
		call	glColor4ubv
		push	0xbf800000		;y = -1
		push	0xbf800000		;x = -1
		call	glVertex2f
		push	0xbf800000		;y = -1
		push	0x3f800000		;x = 1
		call	glVertex2f
		push	s_flow_back2		;v
		call	glColor4ubv
		push	0x3f800000		;y = 1
		push	0xbf800000		;x = -1
		call	glVertex2f
		push	0x3f800000		;y = 1
		push	0x3f800000		;x = 1
		call	glVertex2f
		call	glEnd

		;Activate texture 3:
		push	3			;texture
		push	GL_TEXTURE_2D		;target
		call	glBindTexture
		push	GL_TEXTURE_2D		;cap
		call	glEnable
		push	s_demo_white		;v
		call	glColor4ubv

		;Render the stripe effect (rendered clockwise):
		push	GL_QUAD_STRIP		;mode
		call	glBegin
		push	0x00000000		;t = 0
		push	0x00000000		;s = 0
		call	glTexCoord2f
		push	0xbf800000		;y = -1
		push	0x3f800000		;x = 1
		call	glVertex2f
		push	0x3f800000		;y = 1
		push	0x3f800000		;x = 1
		call	glVertex2f
		push	0x00000000		;t = 0
		push	0x3f800000		;s = 1
		call	glTexCoord2f
		push	0xbf800000		;y = -1
		push	0x3eaaaaaa		;x = 1/3
		call	glVertex2f
		push	0x3f800000		;y = 1
		push	0x3eaaaaaa		;x = 1/3
		call	glVertex2f
		call	glEnd

		;Texturing off:
		push	GL_TEXTURE_2D		;cap
		call	glDisable

		;Color setup:
		mov	esi, s_text_path
		mov	eax, [s_main_t]
		call	_path			;i
		mov	dword[s_temp], 0xffffffff
		fistp	dword[s_temp+3]		;
		push	s_temp
		call	glColor4ubv

		push	0x00000000		;z
		push	0xbf400000		;y
		push	0x3ec00000		;x
		call	glTranslatef

		push	0x3e400000		;z
		push	0x3e400000		;y
		push	0x3e400000		;x
		call	glScalef

		;Render the text:
		push	s_text_text		;lists
		push	GL_UNSIGNED_BYTE	;type
		push	6			;n
		call	glCallLists

		;Project the geometry in 3D:
		call	glLoadIdentity
		push	0x40890000		;zFar = 800.0
		push	0x00000000
		push	0x3ff00000		;zNear = 1.0
		push	0x00000000
		push	0x40040000		;aspect = 2.5
		push	0x00000000
		push	0x40468000		;fovy = 45.0
		push	0x00000000
		call	gluPerspective

;-----------------------------------------------------------------------------
; _flow_render1
; Sets up the torus camera.
;-----------------------------------------------------------------------------
_flow_render1:
		;Translate backwards:
		push	0xc1800000		;z = -16
		push	0x3f800000		;y = 1
		push	0xc0800000		;x = -4
		call	glTranslatef

		fild	dword[s_main_t]		;t
		fmul	dword[s_flow_k7]	;t*k7
		fstp	dword[s_temp]		;

		;Rotate:
		push	0x00000000		;z = 0.0
		push	0x3f800000		;y = 1.0
		push	0x3e800000		;x = 0.25
		push	dword[s_temp]		;angle
		call	glRotatef

;-----------------------------------------------------------------------------
; _flow_render2
; Renders the torus knot.
;-----------------------------------------------------------------------------
_flow_render2:
		mov	ebp, s_flow_lines
		mov	esi, k_flow_lines

		;Get the time for the line:
.repeat1:	fldz				;0
		fild	dword[s_main_dt]	;dt,0
		fmul	dword[ebp+line.dt]	;dt*dt,0
		fadd	dword[ebp+line.t]	;t+dt*dt,0
		fst	dword[ebp+line.t]	;t,0
		push	GL_LINE_STRIP		;mode
		call	glBegin
		mov	edi, k_flow_segs

		;Setup line color:
.repeat2:	mov	dword[s_temp], 0xffffffff
		fld	st1			;i,t,i
		fadd	dword[s_flow_k3]	;i+k3,t,i
		fst	st2			;i+k3,t,i
		fmul	dword[ebp+line.i]	;i*i,t,i
		fmul	dword[s_f255]		;i*i*255,t,i
		fistp	dword[s_temp+3]		;t,i
		push	s_temp
		call	glColor4ubv

		;Render line geometry:
		fadd	dword[ebp+line.len]	;t+=len
		fld	st0			;t,t
		fmul	dword[s_flow_k5]	;t*k5,t
		fsincos				;c,s,t
		fmul	dword[s_f0p5]		;0.5c,s,t
		fld1				;1,0.5c,s,t
		faddp	st1, st0		;1+0.5c,s,t
		fld	dword[s_flow_k4]	;k4,r,s,t
		fadd	dword[ebp+line.r]	;k4+r,r,s,t
		fmulp	st1, st0		;r,s,t
		fld	st2			;t,r,s,t
		fmul	dword[s_flow_k6]	;t*k6,r,s,t
		fsincos				;c,s,r,s,t
		fmul	st0, st2		;r*c,s,r,s,t
		fstp	dword[s_temp+dot.x]	;s,r,s,t
		fmul	st0, st1		;r*s,r,s,t
		fstp	dword[s_temp+dot.z]	;r,s,t
		fstp	st0			;s,t
		fld	dword[s_flow_k4]	;k4,s,t
		fadd	dword[ebp+line.r]	;k4+r,s,t
		fmulp	st1, st0		;s,t
		fstp	dword[s_temp+dot.y]	;t
		push	s_temp			;v
		call	glVertex3fv

		;Go to the next line segment:
		loop	.repeat2, edi

		;Go to the next line:
		fstp	st0			;i
		fstp	st0			;
		call	glEnd
		add	ebp, line_size
		loop	.repeat1, esi

		mov	eax, 1
		pop	esi
		ret

;-----------------------------------------------------------------------------
; _dot_render
;
; Renders a particle system.
;
; Parameters:
;	dot_render(aParticles, aParticleN, aDirection)
;	aParticles	Particle array
;	aParticleN	Particle count
;	aDirection	Direction vector address
; Stack:
;	[epb+8]  aParticles
;	[epb+12] aParticleN
;	[epb+16] aDirection
;-----------------------------------------------------------------------------
_dot_render:
		push	ebp
		mov	ebp, esp

		;Foreach particle:
		push	GL_QUADS		;mode
		call	glBegin

		;Store the color:
.repeat:	mov	ebx, [ebp+8]
		mov	dword[s_temp], 0xffffffff
		fld	dword[ebx+dot.i]	;i
		fmul	dword[s_f255]		;i*=255
		fistp	dword[s_temp+3]		;
		push	s_temp
		call	glColor4ubv

		;Scale the direction vector:		
		fld	dword[ebx+dot.s]	;s
		mov	esi, [ebp+16]
		mov	edi, s_temp+16
		v3scale

		;Draw the particle:
		mov	esi, ebx
		mov	ebx, edi
		mov	edi, s_temp

		;Bottom left:
		v3sub
		fld	dword[edi+4]		;y,s
		fsub	st0, st1		;y-=s
		fstp	dword[edi+4]		;s
		push	0x00000000		;t = 0
		push	0x00000000		;s = 0
		call	glTexCoord2f
		push	s_temp			;v
		call	glVertex3fv

		;Bottom right:
		v3add
		fld	dword[edi+4]		;y,s
		fsub	st0, st1		;y-=s
		fstp	dword[edi+4]		;s
		push	0x00000000		;t = 0
		push	0x3f800000		;s = 1
		call	glTexCoord2f
		push	s_temp			;v
		call	glVertex3fv

		;Top right:
		v3add
		fld	dword[edi+4]		;y,s
		fadd	st0, st1		;y+=s
		fstp	dword[edi+4]		;s
		push	0x3f800000		;t = 1
		push	0x3f800000		;s = 1
		call	glTexCoord2f
		push	s_temp			;v
		call	glVertex3fv

		;Top left:
		v3sub
		fld	dword[edi+4]		;y,s
		fadd	st0, st1		;y+=s
		fstp	dword[edi+4]		;s
		push	0x3f800000		;t = 1
		push	0x00000000		;s = 0
		call	glTexCoord2f
		push	s_temp			;v
		call	glVertex3fv

		fstp	st0			;
		add	dword[ebp+8], k_dot_size
		loop	.repeat, dword[ebp+12]
		call	glEnd

		pop	ebp
		ret	12
