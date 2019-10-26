;##########################################################################
; Flares 4kb Intro
; For ASM Compo #6
; Coded by comrade <comrade2k@hotmail.com>
; Web: http://comrade.deviance.dk/
;      http://comrade.ownz.com/
;      http://comrade.win32asm.com/
;      http://comrade.hpacv.dk/
;      http://comrade64.cjb.net/
;      http://www.comrade64.com/
; IRC: #asm, #coders, #win32asm on EFnet
; Read readme.txt for more information.
;##########################################################################
.386
.model flat, stdcall
option casemap:none
title Flares
;##########################################################################
include C:\masm32\include\windows.inc
include lib\kernel32.inc
include lib\user32.inc
include lib\ddraw.inc
include lib\cddraw.inc
includelib C:\masm32\lib\kernel32.lib
includelib C:\masm32\lib\user32.lib
includelib C:\masm32\lib\ddraw.lib
;##########################################################################
szText MACRO Name, Text:VARARG
LOCAL lbl
	jmp	lbl
	Name	db	Text, 0
lbl:
ENDM
m2m MACRO dest, src
	push	src
	pop	dest
ENDM
m2mx MACRO dest, src
	mov	eax, src
	mov	dest, eax
ENDM
return MACRO RETVALUE
	mov	eax, RETVALUE
	ret
ENDM
iif MACRO condition, if_true, if_false, return
	.if condition
		mov	return, if_true
	.else
		mov	return, if_false
	.endif
ENDM
iifs MACRO condition, if_true, if_false, return
	mov	return, if_false
	.if condition
		mov	return, if_true
	.endif
ENDM
;##########################################################################
POINT3D struct
	x	dd	?
	y	dd	?
	z	dd	?
POINT3D ends
;##########################################################################
	resWidth		equ			640
	resHeight		equ			480
	resBits			equ			16
	resSize			equ			resWidth * resHeight * 2
	scanline		equ			resWidth * 2

	dotWidth		equ			32
	dotHeight		equ			32
	dotLine			equ			dotWidth * 2
	dotSize			equ			dotWidth * dotHeight * 2
	dotCount		equ			64

	clrBack			equ			0
	clrText			equ			0000FF00h

	hStyle			equ			WS_POPUP
	hExStyle		equ			WS_EX_TOPMOST

	CurDate			TEXTEQU			<">, @Date, <">
	CurTime			TEXTEQU			<">, @Time, <">
	CurFileName		TEXTEQU			<">, @FileCur, <">
;##########################################################################
WndProc		PROTO:DWORD,:DWORD,:DWORD,:DWORD
init		PROTO
makeFlare	PROTO
nextFrame	PROTO
initCube	PROTO
initCircle	PROTO
morph		PROTO
rotate		PROTO
drawFlares	PROTO
drawFlare	PROTO
;##########################################################################
.const
	szAppTitle		db			"[Flares] 4kb Intro by comrade", 0
	szMsgAbout		db			"Flares 4kb Intro", 13, 10
				db			"Built on ", CurDate, " ", CurTime, 13, 10
				db			"Version 1.1", 13, 10
				db			"Coded by comrade <comrade2k@hotmail.com>", 13, 10
				db			"For ASM compo #6...", 13, 10
				db			"Web: http://comrade.ownz.com/", 13, 10
				db			"http://comrade.win32asm.com/", 13, 10
				db			"http://comrade.hpacv.dk/", 13, 10
				db			"http://comrade.deviance.dk/", 13, 10
				db			"http://comrade64.cjb.net/", 13, 10
				db			"http://www.comrade64.com/", 13, 10
				db			"IRC: #asm, #coders, #win32asm on EFnet", 13, 10, 13, 10
				db			"Greetings to: Advant, Allman, DooD, f0dder, gnp, hex86, Kalms, kawfee, matja, mcarp, NtSC, X-Calibre", 0
	lens			real4			256.0
	dpi			real4			6.283185307179586476925286766559
	fixedpoint		real4			65536.0
	c_div			real4			32.0
	c_radius		real4			100.0
	include res\flareq.inc
;##########################################################################
.data?
	hMainWnd		dd			?

	hBackImageMemory	dd			?
	dwBackImage		dd			?
	dwTime			dd			?
	dwStack			dd			?
	x			dd			?
	y			dd			?
	z			dd			?
	angle			dd			?
	sin_rot			dd			?
	cos_rot			dd			?
	flare			db			dotSize dup (?)
	sin			dd			256 dup (?)
	cos			dd			256 dup (?)
	cube			POINT3D			dotCount dup (<>)
	circle			POINT3D			dotCount dup (<>)
	morphed			POINT3D			dotCount dup (<>)
	morph_pos		dd			?	; 0
	morph_step		dd			?	; 1
	morph_wait		dd			?	; 128

	ddMain			LPDIRECTDRAW		?
	ddsPrimary		LPDIRECTDRAWSURFACE	?
	ddsd			DDSURFACEDESC		<>

	msg			MSG			<>
	wc			WNDCLASSEX		<>
;##########################################################################
;##########################################################################
.code
start:	invoke	GetModuleHandle, 0
	mov	[wc.hInstance], eax
	xor	ecx, ecx
	or	[wc.cbSize], sizeof wc
	or	[wc.lpfnWndProc], OFFSET WndProc
	push	ecx
	push	eax
	push	ecx
	push	ecx
	push	ecx ;resHeight
	push	ecx ;resWidth
	push	ecx
	push	ecx
	push	hStyle
	mov	edx, OFFSET szAppTitle
	push	edx
	push	edx
	mov	[wc.lpszClassName], edx
	push	hExStyle
	invoke	ShowCursor, ecx
	invoke	RegisterClassEx, ADDR wc

	call	CreateWindowEx
	;invoke	CreateWindowEx, hExStyle, ADDR szClassName, ADDR szAppTitle, hStyle, 0, 0, resWidth, resHeight, 0, 0, [wc.hInstance], 0
	mov	[hMainWnd], eax
	push	eax
	invoke	ShowWindow, eax, SW_SHOWNORMAL
	call	UpdateWindow

	call	GetTickCount
	mov	[dwTime], eax

@@mlp:	xor	eax, eax
	invoke	PeekMessage, ADDR msg, eax, eax, eax, PM_NOREMOVE
	test	eax, eax
	.if !zero?
		xor	eax, eax
		invoke	GetMessage, ADDR msg, eax, eax, eax
		test	eax, eax
		jz	@@mend
		mov	eax, OFFSET msg
		push	eax
		invoke	TranslateMessage, eax
		call	DispatchMessage
	.else
		call	GetFocus
		.if eax==[hMainWnd]
		@@lksf:	mov	[ddsd.dwSize], sizeof DDSURFACEDESC
			mov	[ddsd.dwFlags], DDSD_PITCH
			ddsinvk	mLock, [ddsPrimary], 0, ADDR ddsd, DDLOCK_WAIT, 0
			cmp	eax, DDERR_SURFACELOST
			jne	@@nors
			ddsinvk	Restore, [ddsPrimary]
			jmp	@@lksf
		@@nors:	push	esi
			push	edi
			push	ebx
			push	ebp
		@@noud:	call	nextFrame
			ddinvk	WaitForVerticalBlank, [ddMain], DDWAITVB_BLOCKBEGIN, 0
			mov	esi, [dwBackImage]
			mov	edx, [ddsd.lpSurface]
			mov	ebx, resHeight
		@@blt:	mov	edi, edx
			mov	ecx, scanline shr 2
			rep	movsd
			add	edx, [ddsd.lPitch]
			dec	ebx
			jnz	@@blt
			pop	ebp
			pop	ebx
			pop	edi
			pop	esi
			ddsinvk	Unlock, [ddsPrimary], [ddsd.lpSurface]
		.else
			call	WaitMessage
		.endif
	.endif
	jmp	@@mlp
@@mend:	invoke	ExitProcess, eax
;##########################################################################
WndProc	proc hWnd:DWORD, uMsg:DWORD, wParam:DWORD, lParam:DWORD
	.if [uMsg]==WM_CREATE
		invoke	GlobalAlloc, GMEM_MOVEABLE OR GMEM_ZEROINIT, resSize
		mov	[hBackImageMemory], eax
		invoke	GlobalLock, eax
		mov	[dwBackImage], eax
		call	init

		invoke	DirectDrawCreate, 0, ADDR ddMain, 0
		ddinvk	SetCooperativeLevel, [ddMain], [hWnd], DDSCL_EXCLUSIVE OR DDSCL_FULLSCREEN OR DDSCL_ALLOWREBOOT
		ddinvk	SetDisplayMode, [ddMain], resWidth, resHeight, resBits
		mov	[ddsd.dwSize], sizeof ddsd
		mov	[ddsd.dwFlags], DDSD_CAPS
		mov	[ddsd.ddsCaps.dwCaps], DDSCAPS_PRIMARYSURFACE
		ddinvk	CreateSurface, [ddMain], ADDR ddsd, ADDR ddsPrimary, 0
	.elseif [uMsg]==WM_KEYDOWN && [wParam]==VK_ESCAPE
		invoke	SendMessage, [hWnd], WM_CLOSE, 0, 0
	.elseif [uMsg]==WM_CLOSE
		mov	eax, [hBackImageMemory]
		push	eax
		invoke	GlobalUnlock, eax
		call	GlobalFree
		invoke	ShowCursor, eax
		ddinvk	RestoreDisplayMode, [ddMain]
		ddsinvk	Release, [ddsPrimary]
		ddinvk	Release, [ddMain]
		invoke	MessageBox, [hWnd], ADDR szMsgAbout, ADDR szAppTitle, MB_OK OR MB_ICONASTERISK OR MB_APPLMODAL
	.elseif [uMsg]==WM_DESTROY
		invoke	PostQuitMessage, 0
		xor	eax, eax
		ret
	.endif
@@quit:	pop	ebp
	jmp	DefWindowProc
WndProc endp
;##########################################################################
init proc
	push	ebx
	push	edi
	push	esi
	push	ebp
	call	makeFlare
	; sine/cosine table generation
	mov	[y], ecx
	mov	eax, OFFSET sin
	mov	edx, OFFSET cos
	mov	ecx, 256
@@trig:	fild	[y]
	fmul	real4 ptr [dpi]
	fdiv	real4 ptr [lens]
	fsincos
	fmul	real4 ptr [fixedpoint]
	fistp	dword ptr [edx]
	fmul	real4 ptr [fixedpoint]
	fistp	dword ptr [eax]
	add	eax, 4
	add	edx, 4
	inc	[y]
	loopd	@@trig
	invoke	ShowCursor, ecx
	call	initCube
	call	initCircle
	inc	[morph_step]
	mov	[morph_wait], 256
	pop	ebp
	pop	esi
	pop	edi
	pop	ebx
	ret
init endp
;##########################################################################
makeFlare proc
	; convert the flare into a 16-bit bitmap
	xor	eax, eax
	mov	esi, OFFSET flareq
	mov	edi, OFFSET flare
	mov	ebp, OFFSET flare+62
	mov	[y], 16
@@fcvy:	mov	[x], 16
	@@fcvx:	lodsb
		mov	ebx, eax
		mov	edx, eax
		shr	eax, 3
		and	ebx, 11111100b
		shl	edx, 8
		and	edx, 11111000b shl 8
		shl	ebx, 3

		; blue * 0.5
		shr	eax, 1
		and	eax, 00007BEFh
		; green * 0.75
		lea	ebx, [ebx*2+ebx]
		shr	ebx, 2
		and	ebx, 000007E0h

		or	eax, edx	; +red
		or	eax, ebx	; +green
		stosw
		mov	[ebp], ax
		xor	eax, eax
		sub	ebp, 2
		dec	[x]
		jnz	@@fcvx
	add	ebp, dotLine+32
	add	edi, 32
	dec	[y]
	jnz	@@fcvy
	add	eax, 16
	lea	esi, [edi-dotLine]
@@flmr:	mov	ecx, dotLine shr 2
	rep	movsd
	sub	esi, dotLine*2
	dec	eax
	jnz	@@flmr
	ret
makeFlare endp
;##########################################################################
nextFrame proc
	call	GetTickCount
	sub	eax, [dwTime]
	cmp	eax, 10
	jl	@@quit
	add	[dwTime], eax
	mov	eax, [angle]
	inc	eax
@@chka:	cmp	eax, 255
	jbe	@@a_ok
	sub	eax, 256
	jmp	@@chka
@@a_ok:	dec	[morph_wait]
	jnz	@@m_ok
	inc	[morph_wait]
	mov	ecx, [morph_step]
	add	[morph_pos], ecx
	cmp	[morph_pos], 0
	jle	@@chms
	cmp	[morph_pos], 256
	jle	@@m_ok
@@chms:	neg	[morph_step]
	mov	[morph_wait], 256
@@m_ok:	mov	[angle], eax
	mov	ecx, [sin][eax*4]
	mov	edx, [cos][eax*4]
	mov	[sin_rot], ecx
	mov	[cos_rot], edx
	mov	esi, OFFSET circle
	mov	ebp, OFFSET cube
	mov	edi, OFFSET morphed
	push	edi		; save morphed
	call	morph
	mov	edi, [esp]	; get morphed
	call	rotate
	xor	eax, eax
	mov	edi, [dwBackImage]
	mov	ecx, resSize shr 2
	rep	stosd
	pop	esi		; restore morphed
	call	drawFlares
@@quit:	ret
nextFrame endp
;##########################################################################
initCube proc
	xor	ecx, ecx
	mov	edi, OFFSET cube
@@cube:	mov	eax, ecx
	mov	ebx, ecx
	mov	edx, ecx
	and	eax, 00000003h
	and	ebx, 0000000Ch
	and	edx, 00000030h
	shr	ebx, 2
	shr	edx, 4

	shl	eax, 5
	shl	ebx, 5
	shl	edx, 5
		
	sub	eax, 48
	sub	ebx, 48
	sub	edx, 48

	mov	[edi][POINT3D.x], eax
	mov	[edi][POINT3D.y], ebx
	mov	[edi][POINT3D.z], edx

	inc	ecx
	add	edi, sizeof POINT3D
	cmp	ecx, dotCount
	jne	@@cube
	ret
initCube endp
;##########################################################################
initCircle proc
	push	0
	mov	edi, OFFSET circle
	mov	ecx, dotCount
@@circ:	fild	dword ptr [esp]
	fmul	[dpi]
	fdiv	[c_div]
	fsincos
	fmul	[c_radius]
	fistp	[y]
	fmul	[c_radius]
	fistp	[x]

	mov	eax, [x]
	mov	ebx, [y]
	xor	edx, edx
	mov	[edi][POINT3D.x], eax
	mov	[edi][POINT3D.y], ebx
	mov	[edi][POINT3D.z], edx
	mov	[edi+sizeof POINT3D][POINT3D.x], eax
	mov	[edi+sizeof POINT3D][POINT3D.y], ebx
	mov	[edi+sizeof POINT3D][POINT3D.z], edx
	add	edi, sizeof POINT3D*2

	inc	dword ptr [esp]
	loopd	@@circ
	pop	eax
	ret
initCircle endp
;##########################################################################
morph proc
	mov	ecx, dotCount
@@mrph:	; x
	mov	eax, [esi][POINT3D.x]
	sub	eax, [ebp][POINT3D.x]
	imul	[morph_pos]
	sar	eax, 8
	add	eax, [ebp][POINT3D.x]
	mov	[edi][POINT3D.x], eax
	; y
	mov	eax, [esi][POINT3D.y]
	sub	eax, [ebp][POINT3D.y]
	imul	[morph_pos]
	sar	eax, 8
	add	eax, [ebp][POINT3D.y]
	mov	[edi][POINT3D.y], eax
	; z
	mov	eax, [esi][POINT3D.z]
	sub	eax, [ebp][POINT3D.z]
	imul	[morph_pos]
	sar	eax, 8
	add	eax, [ebp][POINT3D.z]
	mov	[edi][POINT3D.z], eax

	add	esi, sizeof POINT3D
	add	ebp, sizeof POINT3D
	add	edi, sizeof POINT3D
	loopd	@@mrph
	ret
morph endp
;##########################################################################
rotate proc
	mov	ecx, dotCount
@@rot:	mov	eax, [edi][POINT3D.x]
	mov	ebx, [edi][POINT3D.y]
	mov	edx, [edi][POINT3D.z]
	mov	[x], eax
	mov	[y], ebx
	mov	[z], edx
	; rotation around X
	mov	eax, edx
	imul	[sin_rot]
	mov	ebx, eax
	mov	eax, [y]
	imul	[cos_rot]
	sub	eax, ebx
	sar	eax, 16
	mov	[edi][POINT3D.y], eax
	mov	eax, [z]
	imul	[cos_rot]
	mov	ebx, eax
	mov	eax, [y]
	imul	[sin_rot]
	add	eax, ebx
	sar	eax, 16
	mov	[edi][POINT3D.z], eax
	mov	[z], eax
	; rotation around Y
	mov	eax, [x]
	imul	[sin_rot]
	mov	ebx, eax
	mov	eax, [z]
	imul	[cos_rot]
	sub	eax, ebx
	sar	eax, 16
	mov	esi, eax
	mov	eax, [x]
	imul	[cos_rot]
	mov	ebx, eax
	mov	eax, [z]
	imul	[sin_rot]
	add	eax, ebx
	sar	eax, 16
	mov	[edi][POINT3D.x], eax
	mov	[edi][POINT3D.z], esi
	add	edi, sizeof POINT3D
	dec	ecx
	jnz	@@rot
	ret
rotate endp
;##########################################################################
drawFlares proc
	mov	ecx, dotCount
@@drcb:	push	ecx
	xor	edx, edx
	push	esi
	mov	eax, [esi][POINT3D.y]	; eax = y
	mov	ebx, 256		; ebx = 256
	shl	eax, 8			; 256*y
	sub	ebx, [esi][POINT3D.z]	; 256 - z
	cdq				; extend to qword
	idiv	ebx			; 256y/(256-z)
	add	eax, resHeight shr 1 - dotHeight shr 1	; screen_y + height/2
	mov	ecx, scanline		; ecx = scanline
	mul	ecx			; result * scanline
	xor	edx, edx
	mov	ecx, eax		; ecx = screen_y
	mov	eax, [esi][POINT3D.x]	; eax = x
	shl	eax, 8			; 256*x
	cdq				; extended to qword
	idiv	ebx			; 256x/(256-z)
	add	eax, resWidth shr 1 - dotWidth shr 1	; x + width/2
	add	eax, eax		; x*2
	add	ecx, eax		; screen_y + screen_x

	mov	esi, [dwBackImage]
	mov	edi, [dwBackImage]
	add	esi, ecx
	add	edi, ecx
	mov	ebx, OFFSET flare
	call	drawFlare

	pop	esi
	pop	ecx
	add	esi, sizeof POINT3D
	loopd	@@drcb
	ret
drawFlares endp
;##########################################################################
drawFlare proc
	push	ebp
	mov	[dwStack], esp
	mov	[y], dotHeight
@@redo:	mov	ecx, dotWidth
	@@x:	mov	eax, [esi]
		mov	edx, [ebx]
		shr	eax, 1
		and	edx, 0F7DEF7DEh
		shr	edx, 1
		and	eax, 07BEF7BEFh

		mov	ebp, 084108410h
		add	eax, edx
		and	ebp, eax
		mov	esp, ebp
		shr	esp, 4
		sub	ebp, esp
		or	eax, ebp

		add	eax, eax
		mov	[edi], eax
		add	esi, 4
		add	edi, 4
		add	ebx, 4
		sub	ecx, 2
		jnz	@@x
	add	esi, scanline-dotLine
	add	edi, scanline-dotLine
	dec	[y]
	jnz	@@redo
	mov	esp, [dwStack]
	pop	ebp
	ret
drawFlare endp
;##########################################################################
;##########################################################################
;##########################################################################
end start