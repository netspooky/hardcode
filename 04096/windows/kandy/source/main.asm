;
; Startup and OpenGL setup code.
;
; Author:
;	s_tec
;

;%define fullscreen
;%define start 2*1111*16*(4*16+4*8)

%include "win32n.inc"
%include "dsound.inc"
%include "nasmgl.inc"
%include "math.inc"

;-----------------------------------------------------------------------------
; Import and export:
;-----------------------------------------------------------------------------

		global	_main
		global	s_main_t
		global	s_main_dt
		extern	_demo_init
		extern	_demo_render
		extern	_synth_init
		extern	_synth_write

		;dsound.lib:
		import	DirectSoundCreate8,	__imp__DirectSoundCreate8@12

		;gdi32.dll:
		import	ChoosePixelFormat,	__imp__ChoosePixelFormat@8
		import	SetPixelFormat,		__imp__SetPixelFormat@12
		import	SwapBuffers,		__imp__SwapBuffers@4

		;kernel32.dll:
		import	ExitProcess,		__imp__ExitProcess@4

		;opengl32.dll:
		import	wglCreateContext,	__imp__wglCreateContext@4
		import	wglMakeCurrent,		__imp__wglMakeCurrent@8

		;user32.dll:
		import	ChangeDisplaySettings,	__imp__ChangeDisplaySettingsA@8
		import	CreateWindowEx,		__imp__CreateWindowExA@48
		import	GetAsyncKeyState,	__imp__GetAsyncKeyState@4
		import	GetDC,			__imp__GetDC@4
		import	ShowCursor,		__imp__ShowCursor@4
%ifdef debug
		import	PeekMessage,		__imp__PeekMessageA@20
		import	DispatchMessage,	__imp__DispatchMessageA@4
%endif

;-----------------------------------------------------------------------------
; Constants:
;-----------------------------------------------------------------------------

		;Demo constants:
k_main_x	equ	1024			;Demo width
k_main_y	equ	768			;Demo height

		;Audio constants:
k_wave_chan	equ	1			;Channels
k_wave_align	equ	2			;Bytes per block
k_wave_bits	equ	16			;Bits per sample
k_wave_sps	equ	44100			;Samples per second
k_wave_bps	equ	k_wave_align*k_wave_sps	;Bytes per second
k_wave_size	equ	k_wave_align*32768	;Bytes per buffer

;-----------------------------------------------------------------------------
; Unitialized data:
;-----------------------------------------------------------------------------
		section .bss
%ifdef debug
s_main_msg:	resb	MSG_size
%endif
		;Demo timing:
s_main_t:	resd	1
s_main_dt:	resd	1

		;Audio buffers:
s_wave_buffer:	resd	1
s_wave_cursor:	resd	1
;s_wave_effect:	resd	1
s_wave_p1:	resd	1
s_wave_b1:	resd	1
s_wave_p2:	resd	1
s_wave_b2:	resd	1
		
;-----------------------------------------------------------------------------
; Initialized data:
;-----------------------------------------------------------------------------
		section	.data

%ifdef fullscreen
s_main_mode:		;Display mode:
.dmDeviceName		times	CCHDEVICENAME db 0
.dmSpecVersion		dw	0
.dmDriverVersion	dw	0
.dmSize			dw	DEVMODE_size
.dmDriverExtra		dw	0
.dmFields		dd	DM_PELSWIDTH|DM_PELSHEIGHT
.dmOrientation		dw	0
.dmPaperSize		dw	0
.dmPaperiLength		dw	0
.dmPaperWidth		dw	0
.dmScale		dw	0
.dmCopies		dw	0
.dmDefaultSource	dw	0
.dmPrintQuality		dw	0
.dmColor		dw	0
.dmDuplex		dw	0
.dmYResolution		dw	0
.dmTTOption		dw	0
.dmCollate		dw	0
.dmFormName		times	32 db 0
.dmLogPixels		dw	0
.dmBitsPerPel		dd	0
.dmPelsWidth		dd	k_main_x
.dmPelsHeight		dd	k_main_y
.dmDisplayFlags		dd	0
.dmDisplayFrequency	dd	0
.dmDisplayOrientation	dd	0
%endif
			;The main window's class:
s_main_class:		db	'static', 0
			align	4, db 0

s_main_format:		;Pixel format (40 bytes):
.nSize:			dw	0
.nVersion:		dw	0
.dwFlags:		dd	PFD_DRAW_TO_WINDOW|PFD_SUPPORT_OPENGL|PFD_DOUBLEBUFFER
.iPixelType:		db	0
.cColorBits:		db	0
.cRedBits:		db	0
.cRedShift:		db	0
.cGreenBits:		db	0
.cGreenShift:		db	0
.cBlueBits:		db	0
.cBlueShift:		db	0
.cAlphaBits:		db	0
.cAlphaShift:		db	0
.cAccumBits:		db	0
.cAccumRedBits:		db	0
.cAccumGreenBits:	db	0
.cAccumBlueBits:	db	0
.cAccumAlphaBits:	db	0
.cDepthBits:		db	16
.cStencilBits:		db	0
.cAuxBuffers:		db	0
.iLayerType:		db	0
.bReserved:		db	0
.dwLayerMask:		dd	0
.dwVisibleMask:		dd	0
.dwDamageMask:		dd	0

s_wave_desc:		;Describes the primary buffer:
.dwSize			dd	DSBUFFERDESC_size
.dwFlags		dd	DSBCAPS_GLOBALFOCUS|DSBCAPS_GETCURRENTPOSITION2|DSBCAPS_CTRLFX
.dwBufferBytes		dd	k_wave_size
.dwReserved		dd	0
.lpwfxFormat		dd	s_wave_format
.guid3DAlgorithm	db	GUID_NULL

s_wave_format:		;Audio format (16 bytes):
.wFormatTag:		dw	WAVE_FORMAT_PCM
.nChannels:		dw	k_wave_chan
.nSamplesPerSec:	dd	k_wave_sps
.nAvgBytesPerSec:	dd	k_wave_bps
.nBlockAlign:		dw	k_wave_align
.wBitsPerSample:	dw	k_wave_bits
.cbSize			dw	0

;-----------------------------------------------------------------------------
; _main
; Program entry point
;-----------------------------------------------------------------------------
		section	.text
_main:
%ifdef fullscreen
		;Go to fullscreen mode:
		push	CDS_FULLSCREEN		;dwflags
		push	s_main_mode		;lpDevMode
		call	ChangeDisplaySettings

		;Create the window:
		push	0			;lpParam
		push	0			;hInstance
		push	0			;hMenu
		push	0			;hWndParent
		push	0			;nHeight
		push	0			;nWidth
		push	0			;y
		push	0			;x
		push	WS_POPUP|WS_VISIBLE|WS_CLIPSIBLINGS|WS_MAXIMIZE ;dwStyle
		push	0			;lpWindowName
		push	s_main_class		;lpClassName
		push	0			;dwExStyle
		call	CreateWindowEx
		mov	esi, eax
%else
		;Create the window:
		push	0			;lpParam
		push	0			;hInstance
		push	0			;hMenu
		push	0			;hWndParent
		push	k_main_y		;nHeight
		push	k_main_x		;nWidth
		push	0			;y
		push	100			;x
		push	WS_POPUP|WS_VISIBLE|WS_CLIPSIBLINGS ;dwStyle
		push	0			;lpWindowName
		push	s_main_class		;lpClassName
		push	0			;dwExStyle
		call	CreateWindowEx
		mov	esi, eax
%endif
;-----------------------------------------------------------------------------
; DirectSound setup
;-----------------------------------------------------------------------------

		;Create the DirectSound object:
		push	0			;pUnkOuter
		push	s_wave_buffer		;ppDS8
		push	0			;lpcGuidDevice
		call	DirectSoundCreate8

		;Set the cooperative level:
		push	DSSCL_NORMAL		;dwLevel
		push	esi			;hwnd
		invoke	s_wave_buffer, IDirectSound8_SetCooperativeLevel

		;Create the sound buffer:
		push	0			;pUnkOuter 
		push	s_wave_buffer		;ppDSBuffer (pointer recycling)
		push	s_wave_desc		;pcDSBufferDesc
		invoke	s_wave_buffer, IDirectSound8_CreateSoundBuffer
%if 0
		;Set the reverb effect:
		push	0			;pdwResultCodes
		push	s_wave_reverb		;pDSFXDesc
		push	1			;dwEffectsCount
		invoke	s_wave_buffer, IDirectSoundBuffer8_SetFX

		;Obtain a pointer to the reverb effect:
		push	s_wave_effect		;ppObject
		push	s_wave_iid_reverb	;rguidInterface
		push	0			;dwIndex
		push	s_wave_reverb.guidDSFXClass	;rguidObject
		invoke	s_wave_buffer, IDirectSoundBuffer8_GetObjectInPath

		;Set the parameters:
		push	s_wave_reverb		;pcDsFXWavesReverb
		invoke	s_wave_effect, IDirectSoundFXWavesReverb_SetAllParameters
%endif
		;Prepare the music system:
		call	_synth_init

;-----------------------------------------------------------------------------
; OpenGL setup
;-----------------------------------------------------------------------------

		;Get the device context:
		push	esi
		call	GetDC
		mov	esi, eax

		;Hide the mouse:
		push	0
		call	ShowCursor

		;Set up the pixel format:
		push	s_main_format		;ppfd
		push	esi			;hdc
		call	ChoosePixelFormat
		push	s_main_format		;ppfd
		push	eax			;iPixelFormat
		push	esi			;hdc
		call	SetPixelFormat

		;Set up the rendering context:
		push	esi			;hdc
		call	wglCreateContext
		push	eax			;hglrc
		push	esi			;hdc
		call	wglMakeCurrent

		;Prepare the graphics system:
		call	_demo_init

;-----------------------------------------------------------------------------
; Music playback
;-----------------------------------------------------------------------------

		;Lock the audio buffer:
		push	DSBLOCK_ENTIREBUFFER	;dwFlags	
		push	s_wave_b2		;pdwAudioBytes2
		push	s_wave_p2		;ppvAudioPtr2
		push	s_wave_b1		;pdwAudioBytes1
		push	s_wave_p1		;ppvAudioPtr1
		push	0			;dwBytes
		push	0			;dwOffset
		invoke	s_wave_buffer, IDirectSoundBuffer8_Lock

		;Render the audio:
		mov	edi, [s_wave_p1]
		mov	ecx, [s_wave_b1]
		call	_synth_write

		;Unlock the buffer:
		push	dword[s_wave_b2]		;dwAudioBytes2
		push	dword[s_wave_p2]		;pvAudioPtr2
		push	dword[s_wave_b1]		;dwAudioBytes1
		push	dword[s_wave_p1]		;pvAudioPtr1
		invoke	s_wave_buffer, IDirectSoundBuffer8_Unlock

		;Start the playback:
		push	DSBPLAY_LOOPING			;dwFlags
		push	0				;dwPriority
		push	0				;dwReserved1
		invoke	s_wave_buffer, IDirectSoundBuffer8_Play
%ifdef start
		add	dword[s_main_t], start
%endif

;-----------------------------------------------------------------------------
; _main_loop
; Demo rendering & music streaming loop
;-----------------------------------------------------------------------------
_main_loop:
		;Load the last play cursor:
		mov	edi, [s_wave_cursor]

		;Find the new play cursor cursor:
		push	0			;pdwCurrentWriteCursor
		push	s_wave_cursor		;pdwCurrentPlayCursor
		invoke	s_wave_buffer, IDirectSoundBuffer8_GetCurrentPosition

		;Find the time difference:
		mov	eax, [s_wave_cursor]
		sub	eax, edi
		jns	.skip
		add	eax, k_wave_size
.skip:		add	[s_main_t], eax
		mov	[s_main_dt], eax

		;Lock the audio buffer:
		push	0			;dwFlags	
		push	s_wave_b2		;pdwAudioBytes2
		push	s_wave_p2		;ppvAudioPtr2
		push	s_wave_b1		;pdwAudioBytes1
		push	s_wave_p1		;ppvAudioPtr1
		push	eax			;dwBytes
		push	edi			;dwOffset
		invoke	s_wave_buffer, IDirectSoundBuffer8_Lock

		;Render the audio:
		mov	edi, [s_wave_p1]
		mov	ecx, [s_wave_b1]
		call	_synth_write
		mov	edi, [s_wave_p2]
		mov	ecx, [s_wave_b2]
		call	_synth_write

		;Unlock the buffer:
		push	dword[s_wave_b2]		;dwAudioBytes2
		push	dword[s_wave_p2]		;pvAudioPtr2
		push	dword[s_wave_b1]		;dwAudioBytes1
		push	dword[s_wave_p1]		;pvAudioPtr1
		invoke	s_wave_buffer, IDirectSoundBuffer8_Unlock
		
		;Render the demo:
		call	_demo_render
		test	eax, eax
		jz	.quit

		;Copy to the display:
		push	esi			;hdc
		call	SwapBuffers

%ifdef debug	;Process messages in debug mode:
		push	PM_REMOVE		;wRemoveMsg
		push	0			;wMsgFilterMax
		push	0			;wMsgFilterMin
		push	0			;hWnd
		push	s_main_msg		;lpMsg
		call	PeekMessage
		test	eax, eax
		jz	_main_loop
		push	s_main_msg		;lpmsg
		call	DispatchMessage
%endif
		;while (!GetAsyncKeyState(VK_ESCAPE)):
		push	VK_ESCAPE
		call	GetAsyncKeyState
		test	eax, eax
		jz	_main_loop

		;Clean up and exit:
.quit:		push	0			;uExitCode 
		call	ExitProcess
