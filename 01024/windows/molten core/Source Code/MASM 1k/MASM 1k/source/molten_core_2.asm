; ---------------
; Molten Core 1k
; By Drift 2014
; http://www.pouet.net/prod.php?which=64235
; ---------------

; --------------- Assembler directives
			.686P
			.XMM
			.model flat, stdcall
			OPTION CASEMAP:NONE

; --------------- Constants
XRES				equ	1280
YRES				equ	720
VK_ESCAPE           equ 1Bh
WS_POPUP            equ 80000000h
WS_VISIBLE          equ 10000000h
WS_MAXIMIZE         equ 1000000h
PM_REMOVE           equ 1h
PFD_DOUBLEBUFFER	equ	1
PFD_SUPPORT_OPENGL	equ	020h
GL_FRAGMENT_SHADER	equ	08B30h	

; --------------- Main Code
PUBLIC	main
PUBLIC	_ShaderPointer
PUBLIC	_PFD_MIDI
PUBLIC	_Notes
PUBLIC	_screenSettings
PUBLIC	_fragmentShader
PUBLIC	_API_glUseProgram
PUBLIC	_API_glCreateShaderProgramv

EXTERN	_imp__ExitProcess@4:PROC
EXTERN	_imp__ChoosePixelFormat@8:PROC
EXTERN	_imp__SetPixelFormat@12:PROC
EXTERN	_imp__wglCreateContext@4:PROC
EXTERN	_imp__wglGetProcAddress@4:PROC
EXTERN	_imp__wglMakeCurrent@8:PROC
EXTERN	_imp__SwapBuffers@4:PROC
EXTERN	_imp__PeekMessageA@20:PROC
EXTERN	_imp__CreateWindowExA@48:PROC
EXTERN	_imp__GetAsyncKeyState@4:PROC
EXTERN	_imp__GetDC@4:PROC
EXTERN	_imp__ShowCursor@4:PROC
EXTERN	_imp__ChangeDisplaySettingsA@8:PROC
EXTERN	_imp__midiOutOpen@20:PROC
EXTERN	_imp__midiOutShortMsg@8:PROC
EXTERN	_imp__timeGetTime@0:PROC
EXTERN	_imp__glRects@16:PROC
EXTERN	_imp__glColor3us@12:PROC


_TEXT	SEGMENT

; --------------- Program start
main	PROC
			
			; -----	Set fullscreen settings
			push	4
			push	OFFSET _screenSettings
			call	DWORD PTR _imp__ChangeDisplaySettingsA@8
			
			; -----	Some pre-pushes
			push	0										; for exit process
			push	0										; for midiOutOpen
			push	0										; for midiOutOpen
			push	0										; for midiOutOpen
			push	0										; for midiOutOpen
			push	0										; for hide cursor

			; -----	CreateWindow
			push	0										; lpParam
			push	0										; hInstance
			push	0										; hMenu
			push	0										; hWndParent
			push	0										; nHeight
			push	0										; nWidth
			push	0										; y
			push	0										; x
			push	WS_POPUP or WS_VISIBLE or WS_MAXIMIZE	; dwStyle
			push	0										; lpWindowName
			push	0000c018H								; lpClassName
			push	0										; dwExStyle
			call	DWORD PTR _imp__CreateWindowExA@48		; create opengl window
			
			; -----	GetDC
			push	eax										; push window from eax
			call	DWORD PTR _imp__GetDC@4					; Get HDC
			xchg    eax, ebp								; move HDC to ebp

			; -----	ChoosePixelFormat
			push	offset _PFD_MIDI						; push pixelformatdescriptor data address
			push	offset _PFD_MIDI						; push pixelformatdescriptor data address
			push	ebp										; push HDC from ebp
			call	DWORD PTR _imp__ChoosePixelFormat@8		; returns pixelformat to eax

			; ----- SetPixelFormat
			push	eax										; push pixelformat from eax
			push	ebp										; push HDC from ebp
			call	DWORD PTR _imp__SetPixelFormat@12		; set pixel format

			; ----- CreateContext
			push	ebp										; push HDC from ebp
			call	DWORD PTR _imp__wglCreateContext@4		; returns context to eax

			; ----- MakeCurrent
			push	eax										; push context from eax
			push	ebp										; push HDC from ebp
			call	DWORD PTR _imp__wglMakeCurrent@8

			; ----- Hide Cursor
			call	DWORD PTR _imp__ShowCursor@4			; hide cursor

			; ----- Open MIDI channel
			push	offset _PFD_MIDI						; push MIDI Out address
			call	DWORD PTR _imp__midiOutOpen@20			; call midiOutOpen

			; ----- Set MIDI instrument
			push	31c0H									; push midi instrument selection
			push	_PFD_MIDI								; push MIDIout
			call	DWORD PTR _imp__midiOutShortMsg@8		; call midiOutShortMsg
			push	5fc1H									; push midi instrument selection
			push	_PFD_MIDI								; push MIDIout
			call	DWORD PTR _imp__midiOutShortMsg@8		; call midiOutShortMsg

			; -----	Create Shader Program
			push	offset _ShaderPointer					; push shader source code address
			push	1										; push number of source code strings (1)	
			push	GL_FRAGMENT_SHADER						; push shader type GL_FRAGMENT_SHADER
			push	offset _API_glCreateShaderProgramv		; push address of name for opengl process
			call	DWORD PTR _imp__wglGetProcAddress@4		; return actual address of opengl process to eax
			call	eax										; call glCreateShaderProgramv returns shader program ID to eax

			; -----	Use Shader Program
			push	eax										; push shader program ID from ebx
			push	offset _API_glUseProgram				; push address of name for opengl process
			call	DWORD PTR _imp__wglGetProcAddress@4		; return actual address of opengl process to eax
			call	eax										; call glUseProgram

			; ----- Get starting time
			call	DWORD PTR _imp__timeGetTime@0			; get starting time
			xchg	ebx, eax								; store starting time in ebx
			xor		edi, edi								; set edi to zero
						
MainLoop:
			; -----	Get current time
			call	DWORD PTR _imp__timeGetTime@0			; get current time
			sub		eax, ebx								; subtract starting time
			
			; -----	Exit timer
			push	eax										; push time to gl_color.z
			push	eax										; push time to gl_color.y
			push	eax										; push time to gl_color.x
			cmp		eax, 10000H								; compare time
			jge		Exit									; jump to exit
					
			; ----- Send time to shader
			xchg	esi, eax								; move time to esi			
			call	DWORD PTR _imp__glColor3us@12			; send time to gl_color

			; ----- Music player
			shr		esi, 11									; divide time for music tempo
			inc		esi										; +1 to time
			cmp		esi, edi								; compare time to edi
			je		SHORT NoPlay							; jump no play
	
			xor		esi, esi								; set esi to zero
			inc		edi										; +1 to edi

MoreNotes:
			lea		eax, [esi+7B0090H]						; load midi note on + (esi = channel number)
			add		ah,	_Notes[2*edi+esi]					; add note data + (edi = sequence step position) + (esi = channel number)
			jz		SHORT NoPlayA							; if note data is zero then skip
			push	eax										; push note
			push	_PFD_MIDI								; push MIDIout
			sub		ah, 0CH									; subtract 12 from note (1 octave lower)
			push	eax										; push note
			push	_PFD_MIDI								; push MIDIout
			lea		eax, [esi+7BB0H]						; load midi note off + (esi = channel number)
			push	eax										; push note off
			push	_PFD_MIDI								; push MIDIout
			call	DWORD PTR _imp__midiOutShortMsg@8		; play midi note
			call	DWORD PTR _imp__midiOutShortMsg@8		; play midi note
			call	DWORD PTR _imp__midiOutShortMsg@8		; play midi note
NoPlayA:
			inc		esi										; +1 to channel number
			cmp		esi, 2									; compare channel to 2
			jne		SHORT MoreNotes							; play next channel

NoPlay:
			; ----- Draw quad
			push	1										; push quad coords
			push	1										; push quad coords
			push	-1										; push quad coords
			push	-1										; push quad coords
			call	DWORD PTR _imp__glRects@16				; draw fullscreen quad

			; ----- Swap buffers
			push	ebp										; push HDC from ebp
			call	DWORD PTR _imp__SwapBuffers@4			; swap buffers

			; ----- Remove error message
			push	PM_REMOVE								; wRemoveMsg
			push	0										; wMsgFilterMax
			push	0										; wMsgFilterMin
			push	0										; hWnd
			push	0										; lpMsg
			call	DWORD PTR _imp__PeekMessageA@20			; dispatch incoming message

			; -----	Check for escape key press
			push	VK_ESCAPE								; push escape key
			call	DWORD PTR _imp__GetAsyncKeyState@4		; check for key press
			sahf											; store result in flags
            jns     MainLoop								; jump to main loop if flag not set

Exit:
			; -----	ExitProcess
			call	DWORD PTR _imp__ExitProcess@4

; --------------- Program end
main	ENDP
_TEXT	ENDS


; --------------- Data Section
CONST	SEGMENT
_fragmentShader		db	"float v=gl_Color.x*8,y=sin(v),x,g,f,c,z,d,r;"
					db	"float n(vec3 v){"
					db	"x=1;"
					db	"for(r=0;r<9;r++)"
					db	"v=clamp(v,-1,1)*2-v,c=max((1.2-y*.3)/dot(v,v),1),x*=c,v*=c,v+=vec3(.2,.2,-.2);"
					db	"return.3*abs(v.z)/x;"
					db	"}"
					db	"void main(){"
					db	"vec3 r=gl_FragCoord*.002-1,z;"
					db	"for(d=0;d<90&&f*.001<=g;d++)"
					db	"z=vec3(v-2.8,-y-floor(v),3)+f*normalize(vec3(r.x+y,1.3+y*.6,r.y-y)),g=n(z),f+=g;"
					db	"gl_FragColor.xyz="
					db	"(pow(dot(normalize(vec3(n(z+vec2(.001,0).xyy),n(z+vec2(.001,0).yxy),n(z+vec2(.001,0).yyx))-n(z)),vec3(.6,-.6,0)),3)"
					db	"+f*d*.006*vec3(1,.3,.1))*sin(mod(v,1)*3.2)*-sin(r.y*2.2-.9);"
					db	"}", 0
CONST	ENDS

CONST	SEGMENT
_PFD_MIDI			dd	0										; nSize / nVersion
					dd	PFD_SUPPORT_OPENGL or PFD_DOUBLEBUFFER	; dwFlags
CONST	ENDS

CONST	SEGMENT
_API_glCreateShaderProgramv	db	"glCreateShaderProgramv", 0
CONST	ENDS

CONST	SEGMENT
_API_glUseProgram			db	"glUseProgram"
CONST	ENDS

CONST	SEGMENT
_Notes				db	00H, 00H
					db	31H, 40H
					db	00H, 00H
					db	2fH, 3fH
					db	00H, 3bH
					db	36H, 3dH
					db	00H, 00H
					db	39H, 40H
					db	00H, 3dH
					db	34H, 42H
					db	00H, 00H
					db	38H, 44H
					db	00H, 45H
					db	39H, 40H
					db	00H, 00H
					db	33H, 42H
					db	00H, 47H
					db	31H, 40H 
					db	00H, 00H
					db	2fH, 3fH
					db	00H, 00H
					db	36H, 3dH
					db	00H, 00H
					db	31H, 40H
					db	00H, 42H
					db	2fH, 3fH
					db	00H, 40H
					db	2eH, 3dH
					db	00H, 00H
					db	28H
					
CONST	ENDS

CONST	SEGMENT
_screenSettings		DB 00H
					ORG $+31
					DW	00H
					DW	00H
					DW	09cH
					DW	00H
					DD	0180000H
					DW	00H
					ORG $+14
					DW	00H
					DW	00H
					DW	00H
					DW	00H
					DW	00H
					DB	00H
					ORG $+31
					DW	00H
					DD	00H
					DD	XRES
					DD	YRES
CONST	ENDS

CONST	SEGMENT
_ShaderPointer		dd	_fragmentShader
CONST	ENDS


END