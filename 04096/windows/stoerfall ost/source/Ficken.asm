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



	.586p
	.model flat,stdcall

option casemap:none
option noemulator

	.nolist

;-------------------------------------------------------------------------

PARTY = 0

if PARTY
	GFX		= 1
	FAKEWINDOW	= 1
	FULLSCREEN	= 0
	FAKEFSCREEN	= 1
	TEXTURES	= 0
	DEBUG		= 0
	LOW_SOUND	= 0
	SAFE_CODE	= 0
	ESC_BREAK	= 0
	ENABLE_FOG	= 0
	MESSAGE		= 0
	DSOUND		= 0
	SE_MASTER_HACK	= 1
else
	GFX		= 1
	FAKEWINDOW	= 1
	FULLSCREEN	= 0
	FAKEFSCREEN	= 0
	TEXTURES	= 0
	DEBUG		= 0
	LOW_SOUND	= 0
	SAFE_CODE	= 1
	ESC_BREAK	= 1
	ENABLE_FOG	= 0
	MESSAGE		= 1
	DSOUND		= 1
	SE_MASTER_HACK	= 0
endif

;-------------------------------------------------------------------------

include	windows.inc
include	kernel32.inc
if DEBUG
include	gdi32.inc
endif

include	gl.def

;-------------------------------------------------------------------------
	.list

if DEBUG
	include misc\debug.ash
else
	atsc macro
	endm
	etsc macro
	endm
	asize macro
	endm
	esize macro
	endm
	debugout macro
	endm
endif
;-------------------------------------------------------------------------

	.data?

zerostart	label byte

;-------------------------------------------------------------------------

include misc\help.ash
include misc\import.ash

;-------------------------------------------------------------------------

if TEXTURES
	include gfx\texgen.ash
endif
include misc\math.ash
include	sfx\se.ash
if DSOUND
	include	sfx\directsound.ash
else
	include	sfx\waveout.ash
endif
include	script\script.ash
include	gfx\glengine.ash
include	gfx\scenegen.ash

;-------------------------------------------------------------------------

	.data

if PARTY
else
MBText		db "freestyle regiert",0
endif

if FAKEWINDOW
ClassName	db "STATIC",0
endif

createwindat	label dword
if FULLSCREEN or FAKEFSCREEN
		dd WS_EX_TOPMOST
else
		dd 0
endif
		dd offset ClassName, 0 ;offset ClassName
if FAKEFSCREEN
		dd WS_POPUP or WS_VISIBLE or WS_MAXIMIZE, 0, 0, 0, 0, 0, 0
		;dd WS_POPUP or WS_VISIBLE or WS_MAXIMIZE, 0, 0, 0, 0, 0, 0
else
		dd WS_POPUP or WS_VISIBLE, 0, 0, 640, 480, 0, 0
endif
hInstance	dd ?, 0


;		    ...xRCPC..PUOZDI
cwTrunc		dw (0000111100111010b)

;-------------------------------------------------------------------------

	.data?

pfd		PIXELFORMATDESCRIPTOR <?>
	align 16
secode		db seCodeSize dup (?)

;-------------------------------------------------------------------------

	.code

WinMainCRTStartup proc
	LOCAL	hdc:HDC
	LOCAL	hwnd:HWND

if FULLSCREEN
	LOCAL	dm:DEVMODE
endif

	LOCAL	msg:MSG

	lea	edi,[zerostart]
	mov	ecx,(offset zeroend)-(offset zerostart)
	xor	eax,eax
	rep	stosb

	call	impDoImports
if SAFE_CODE
	jz	exitproggy
endif

	mov	ebx,offset wincalltbl

;	push	NULL
;	call	GetModuleHandleA
;	mov	[esi+(offset hInstance - offset createwindat)],eax

	mov	esi,offset createwindat
	push	48
	pop	ecx
	sub	esp,ecx
	mov	edi,esp
	rep	movsb
	call	dword ptr [ebx+impCreateWindowExA]
	
	mov	[hwnd],eax

if FULLSCREEN

	DM_BITSPERPEL	= 000040000h
	DM_PELSWIDTH	= 000080000h
	DM_PELSHEIGHT   = 000100000h
	CDS_FULLSCREEN  = 000000004h

	sub	esi,24		; esi auf die auflösung des fensters zeigen lassen
	lea	edi,[dm]	; ein glück, dass width und height genauso wie in der
	push	edi		; winstruc hintereinanderliegen  ;D   *froi*
	add	edi,DEVMODE.dmPelsWidth
	movsd
	movsd
	pop	edi
	mov	[edi+DEVMODE.dmFields],DM_PELSWIDTH or DM_PELSHEIGHT
	mov	[edi+DEVMODE.dmSize],sizeof DEVMODE

	push	CDS_FULLSCREEN
	push	edi
	call	dword ptr [ebx+impChangeDisplaySettingsA]

	push	[hwnd]

else

	push	eax

endif

	call	dword ptr [ebx+impGetDC]
	mov	[hdc],eax

	push	eax	; [hdc] sichern

	mov	edi,offset pfd
	mov	[seCodePtr],edi
	mov	byte ptr [edi+PIXELFORMATDESCRIPTOR.nSize],SIZEOF PIXELFORMATDESCRIPTOR
	mov	byte ptr [edi+PIXELFORMATDESCRIPTOR.nVersion],1
	mov	byte ptr [edi+PIXELFORMATDESCRIPTOR.dwFlags],025h
	; 25h =	PFD_DRAW_TO_WINDOW or PFD_SUPPORT_OPENGL or PFD_DOUBLEBUFFER
if FULLSCREEN
	mov	byte ptr [edi+PIXELFORMATDESCRIPTOR.cColorBits],32
	mov	byte ptr [edi+PIXELFORMATDESCRIPTOR.cDepthBits],32
endif
	;mov	byte ptr [edi+PIXELFORMATDESCRIPTOR.cStencilBits],8

	pop	esi	; push eax, siehe oben, eigentlich [hdc]

	push	edi	;offset pfd
	push	esi	;[hdc]
	call	dword ptr [ebx+impChoosePixelFormat]

	push	edi	;offset pfd
	push	eax
	push	esi	;[hdc]
	call	dword ptr [ebx+impSetPixelFormat]

	push	esi	;[hdc]
	call	dword ptr [ebx+impwglCreateContext]

	push	eax	;[hrc]
	push	esi	;[hdc]
	call	dword ptr [ebx+impwglMakeCurrent]

if FULLSCREEN or FAKEFSCREEN
	push	0
	call	dword ptr [ebx+impShowCursor]
endif

;---- introinit ---------------------------------------------------------

if SAFE_CODE
	finit
endif
	fldcw	[cwTrunc]

if TEXTURES
	call	texMakeTextures

	mov	esi,offset scenetexture
	call	gleMakeTexture
endif

	call	sgGenerate

	seInit

	if DSOUND
		mov	esi,[hwnd]	; not needed for waveout
	endif
	dsndInit

;-------------------------------------------------------------------------

	main_loop:
if SAFE_CODE
		push	PM_REMOVE
		push	0
		push	0
		push	[hwnd]
		lea	eax,[msg]
		push	eax
		call	dword ptr [ebx+impPeekMessageA]
endif

		call	scptRun

if GFX
		;mov	edi,[dsndData.samples]
		;shr	edi,6-44100/SAMPLERATE
		call	gleRenderScene
		
		push	[hdc]
		call	dword ptr [ebx+impSwapBuffers]
endif

		debugout

if ESC_BREAK
		push	VK_ESCAPE
		call	dword ptr [ebx+impGetAsyncKeyState]
if SAFE_CODE
		and	al,1
endif
		or	al,byte ptr [script_dword]
	jz	main_loop
else
		xor	al,byte ptr [script_dword]	; swapbuffers returns 1 on success  ;>
	jnz	main_loop
endif
	
;---- introdeinit --------------------------------------------------------

if SAFE_CODE
	call	dsndDeinit
endif

;-------------------------------------------------------------------------

if FULLSCREEN
	xor	eax,eax
	push	eax
	push	eax
	call	dword ptr [ebx+impChangeDisplaySettingsA]
endif

if PARTY
else
	push	[hwnd]
	call	dword ptr [ebx+impDestroyWindow]
	
	push 	MB_TASKMODAL+MB_TOPMOST
	push	offset MBText
	push	0
	push	0
	call	dword ptr [ebx+impMessageBoxA]
endif

exitproggy::
	push	eax
	call	ExitProcess
WinMainCRTStartup endp

;-------------------------------------------------------------------------

;include	memory.ash

;-------------------------------------------------------------------------

	.data?

	align 16
zeroend		label byte

;-------------------------------------------------------------------------

end WinMainCRTStartup
