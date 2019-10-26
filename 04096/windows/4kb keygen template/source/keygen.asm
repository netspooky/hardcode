;##########################################################################
; 4kb Keygen Template for contests.anticrack.de
; Coded by comrade <comrade2k@hotmail.com>
; http://comrade64.cjb.net/
; IRC: #asm, #coders, #win32asm on EFnet
;##########################################################################
.386
.model flat, stdcall
option casemap:none
title Template
;##########################################################################
include C:\masm32\include\windows.inc
include C:\masm32\include\kernel32.inc
include C:\masm32\include\user32.inc
include C:\masm32\include\gdi32.inc
includelib C:\masm32\lib\kernel32.lib
includelib C:\masm32\lib\user32.lib
includelib C:\masm32\lib\gdi32.lib
;##########################################################################
m2m MACRO M1, M2
	push	M2
	pop	M1
ENDM
;##########################################################################
;##########################################################################
	bmpWidth	equ	304
	bmpHeight	equ	080
	bmpSize		equ	bmpWidth * bmpHeight * 3
	scanline	equ	304*3

	CurDate		TEXTEQU	<">, @Date, <">
	CurTime		TEXTEQU	<">, @Time, <">
	CurFileName	TEXTEQU	<">, @FileCur, <">
;##########################################################################
DlgProc		PROTO	:DWORD,:DWORD,:DWORD,:DWORD
nextFrame	PROTO
blur		PROTO
blend		PROTO
;##########################################################################
.data
	szAppTitle	db	"4kb Keygen Template by comrade", 0
	szMsgAbout	db	"4kb Keygen Template for contests.anticrack.de", 13, 10
			db	"Coded by comrade <comrade2k@hotmail.com>", 13, 10
			db	"http://comrade64.cjb.net/", 0
	tat		real4	-1.0
	xcenter		real4	152.0
	ycenter		real4	040.0
	angle		real4	00.00
	scale		real4	01.00
	angle_inc	real4	00.02
	scale_inc	real4	00.05
	rcDraw		RECT	<0, 114, bmpWidth, 114+bmpHeight>
	include res\shakira.inc
;##########################################################################
.data?
	szName		db	256 dup (?)
	szSerial	db	012 dup (?)
	hBackDC		dd	?
	hBackBmp	dd	?
	dwBackBmp	dd	?
	sin		real4	?
	cos		real4	?
	x		dd	?
	y		dd	?
	u		dd	?
	v		dd	?
	count		dd	?
	dwStack		dd	?
	ps		PAINTSTRUCT	<>
	bmi		BITMAPINFO	<>
	back		db		bmpSize dup (?)
	prev		db		bmpSize dup (?)
;##########################################################################
.code
start:	invoke	GetModuleHandle, eax
	invoke	DialogBoxParam, eax, 100, 0, ADDR DlgProc, eax
	invoke	ExitProcess, eax
;#########################################################################
DlgProc proc hWnd:DWORD, uMsg:DWORD, wParam:DWORD, lParam:DWORD
	.if [uMsg]==WM_INITDIALOG
		or	[bmi.bmiHeader.biSize], sizeof bmi.bmiHeader
		or	[bmi.bmiHeader.biWidth], bmpWidth
		or	[bmi.bmiHeader.biHeight], -bmpHeight
		inc	[bmi.bmiHeader.biPlanes]
		or	[bmi.bmiHeader.biBitCount], 24
		invoke	GetDC, [hWnd]
		push	eax	; for ReleaseDC()
		invoke	CreateCompatibleDC, eax
		mov	[hBackDC], eax
		invoke	CreateDIBSection, [esp+14h], ADDR bmi, DIB_RGB_COLORS, ADDR dwBackBmp, 0, 0
		mov	[hBackBmp], eax
		invoke	SelectObject, [hBackDC], eax
		push	[hWnd]
		call	ReleaseDC
		invoke	SetTimer, [hWnd], 1, 75, 0
		invoke	SetDlgItemText, [hWnd], 100, ADDR szMsgAbout
		invoke	SetWindowText, [hWnd], ADDR szAppTitle
	.elseif [uMsg]==WM_TIMER
		push	esi
		push	edi
		push	ebx
		mov	esi, OFFSET bmp
		mov	edi, OFFSET back
		mov	ebx, OFFSET palette
		call	nextFrame
		mov	esi, OFFSET back
		mov	edi, [dwBackBmp]
		mov	ecx, bmpSize-scanline
		call	blur
		mov	esi, OFFSET prev
		mov	edi, [dwBackBmp]
		mov	ecx, bmpSize
		call	blend
		mov	esi, [dwBackBmp]
		mov	edi, OFFSET prev
		mov	ecx, bmpSize shr 2
		rep	movsd
		pop	ebx
		pop	edi
		pop	esi
		invoke	RedrawWindow, [hWnd], ADDR rcDraw, 0, RDW_INVALIDATE
	.elseif [uMsg]==WM_COMMAND && [wParam]==(EN_CHANGE shl 16 + 102)
		push	ebx
		mov	eax, OFFSET szName
		push	eax
		invoke	GetDlgItemText, [hWnd], 102, eax, sizeof szName
		pop	edx
		test	eax, eax
		jz	@@key
		dec	edx
		xor	ebx, ebx
	@@sum:	movzx	ecx, byte ptr [edx+eax]
		cmp	ecx, "a"
		jb	@@noch
		cmp	ecx, "z"
		ja	@@noch
		sub	ecx, "a"-"A"
	@@noch:	add	ebx, ecx
		dec	eax
		jnz	@@sum
		mov	eax, ebx
		mov	ecx, 25
		add	eax, 324h
		mul	ecx
	@@key:	mov	edx, OFFSET szSerial+7
		mov	ecx, 8
	@@hex:	mov	ebx, eax
		and	ebx, 0Fh
		cmp	ebx, 0Ah
		jb	@@uten
		add	ebx, "A"-"0"-0Ah
	@@uten:	add	ebx, "0"
		mov	byte ptr [edx], bl
		shr	eax, 4
		jz	@@hexd
		dec	edx
		loop	@@hex
	@@hexd:	invoke	SetDlgItemText, [hWnd], 103, edx
		pop	ebx
	.elseif [uMsg]==WM_TIMER
		invoke	RedrawWindow, [hWnd], 0, 0, RDW_INVALIDATE
	.elseif [uMsg]==WM_PAINT
		mov	eax, [hWnd]
		mov	ecx, OFFSET ps
		push	ecx	; for EndPaint()
		push	eax
		invoke	BeginPaint, eax, ecx
		invoke	BitBlt, eax, 0, 114, bmpWidth, bmpHeight, [hBackDC], 0, 0, SRCCOPY
		call	EndPaint
	.elseif [uMsg]==WM_CTLCOLORDLG || [uMsg]==WM_CTLCOLORSTATIC || [uMsg]==WM_CTLCOLOREDIT
		mov	eax, [wParam]
		push	00FFFFFFh
		push	eax
		invoke	SetBkColor, eax, 00000000h
		call	SetTextColor
		invoke	GetStockObject, BLACK_BRUSH
		ret
	.elseif [uMsg]==WM_LBUTTONDOWN
		call	ReleaseCapture
		invoke	SendMessage, [hWnd], WM_NCLBUTTONDOWN, HTCAPTION, 0
		;invoke	SendMessage, [hWnd], WM_SYSCOMMAND, SC_MOVE+2, 0
	.elseif [uMsg]==WM_CLOSE
		invoke	EndDialog, [hWnd], 0
	.endif
@@quit:	xor	eax, eax
	ret
DlgProc endp
;##########################################################################
nextFrame proc
	fld	[angle]
	fsincos
	fstp	[cos]
	fstp	[sin]
	and	[y], 0
@@y:	and	[x], 0
	@@x:	fild	[x]
		fsub	[xcenter]
		fmul	[cos]
		fild	[y]
		fsub	[ycenter]
		fmul	[sin]
		fsub
		fdiv	[scale]
		fistp	[u]

		fild	[x]
		fsub	[xcenter]
		fmul	[sin]
		fild	[y]
		fsub	[ycenter]
		fmul	[cos]
		fadd
		fdiv	[scale]
		fistp	[v]

		mov	eax, [u]
		mov	ecx, [v]
		sub	eax, 16
		sub	ecx, 16
		and	eax, 0000001Fh
		and	ecx, 0000001Fh
		shr	eax, 1
		shl	ecx, 4
		add	eax, ecx
		movzx	eax, byte ptr [esi+eax]
		test	[u], 1
		jnz	@@odd
		shr	eax, 4
	@@odd:	and	eax, 0000000Fh
		mov	eax, [ebx+eax*4]
		mov	[edi], eax
		add	edi, 3
		inc	[x]
		cmp	[x], bmpWidth
		jne	@@x
	inc	[y]
	cmp	[y], bmpHeight
	jne	@@y
	fld	[angle]
	fadd	[angle_inc]
	fstp	[angle]
	fld	[scale]
	fadd	[scale_inc]
	fstp	[scale]
	inc	[count]
	cmp	[count], 96
	jb	@@quit
	mov	[count], 0BF800000h
	fld	[scale_inc]
	fmul	real4 ptr [count]
	fstp	[scale_inc]
	and	[count], 0
@@quit:	ret
nextFrame endp
;##########################################################################
blur proc
	push	ebp
	mov	[dwStack], esp
	add	edi, ecx
	add	esi, ecx
@@blur:	mov	eax, [esi-scanline]	; + top
	mov	edx, [esi+3]		; + right
	mov	ebx, [esi-3]		; + left
	mov	ebp, [esi+scanline]	; + bottom
	mov	esp, [esi]		; + center
	and	edx, 11111000111110001111100011111000b
	shr	eax, 3
	and	esp, 11111110111111101111111011111110b
	shr	edx, 3
	and	ebp, 11111000111110001111100011111000b
	shr	ebx, 3
	and	eax, 00011111000111110001111100011111b
	shr	ebp, 3
	and	ebx, 00011111000111110001111100011111b
	shr	esp, 1

	add	edx, ebp
	add	ebx, esp
	add	eax, edx
	mov	ebp, 3
	add	eax, ebx

	mov	[edi], eax
	sub	esi, ebp
	sub	edi, ebp
	sub	ecx, ebp
	jnz	@@blur
	mov	esp, [dwStack]
	pop	ebp
	ret
blur endp
;##########################################################################
blend proc
@@redo:	mov	eax, [esi]
	mov	edx, [edi]
	shr	eax, 1
	shr	edx, 1
	and	eax, 07F7F7F7Fh
	and	edx, 07F7F7F7Fh

	add	eax, edx
	mov	[edi], eax
	add	esi, 3
	add	edi, 3
	sub	ecx, 3
	jnz	@@redo
	ret
blend endp
;##########################################################################
;##########################################################################
;##########################################################################
end start