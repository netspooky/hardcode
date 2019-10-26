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
XRES				equ	1024
YRES				equ	768
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
PUBLIC	_PFD
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
			push	offset _PFD								; push pixelformatdescriptor data address
			push	offset _PFD								; push pixelformatdescriptor data address
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

			; -----	Create Shader Program
			push	offset _ShaderPointer					; push shader source code address
			push	1										; push number of source code strings (1)	
			push	GL_FRAGMENT_SHADER						; push shader type GL_FRAGMENT_SHADER
			push	offset _API_glCreateShaderProgramv		; push address of name for opengl process
			call	DWORD PTR _imp__wglGetProcAddress@4		; return actual address of opengl process to eax
			call	eax										; call glCreateShaderProgramv returns shader program ID to eax

			; -----	Use Shader Program
			push	eax										; push shader program ID from eax
			push	offset _API_glUseProgram				; push address of name for opengl process
			call	DWORD PTR _imp__wglGetProcAddress@4		; return actual address of opengl process to eax
			call	eax										; call glUseProgram

			; ----- Get starting time
			call	DWORD PTR _imp__timeGetTime@0			; get starting time
			xchg	ebx, eax								; store starting time in ebx
						
MainLoop:
			; -----	Get current time
			call	DWORD PTR _imp__timeGetTime@0			; get current time
			sub		eax, ebx								; subtract starting time
			
			; -----	Exit timer
			push	eax										; push time to gl_color.z
			push	eax										; push time to gl_color.y
			push	eax										; push time to gl_color.x
			cmp		eax, 6000H								; compare time
			jge		SHORT Exit								; jump to exit
					
			; ----- Send time to shader
			call	DWORD PTR _imp__glColor3us@12			; send time to gl_color

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
            jns     SHORT MainLoop							; jump to main loop if flag not set

Exit:
			; -----	ExitProcess
			call	DWORD PTR _imp__ExitProcess@4

; --------------- Program end
main	ENDP
_TEXT	ENDS


; --------------- Data Section
CONST	SEGMENT
_fragmentShader		db "float x=gl_Color.x*8,y=sin(x)-1,v,g,m;"
					db "void main(){vec4 r=gl_FragCoord*.003-1;"
					db "v=r.x*x;"
					db "for(m=0;m<7;m++)g=r.x+x*y,r.x=g*g-r.y*r.y+v,r.y=y*3*g*r.y+r.y;"
					db "gl_FragColor=vec4(mix(vec4(-x,-y,x,y),vec4(g),max(g,r.x)));}", 0

CONST	ENDS

CONST	SEGMENT
_PFD				dd	0										; nSize / nVersion
					dd	PFD_SUPPORT_OPENGL or PFD_DOUBLEBUFFER	; dwFlags
CONST	ENDS

CONST	SEGMENT
_API_glCreateShaderProgramv	db	"glCreateShaderProgramv", 0
CONST	ENDS

CONST	SEGMENT
_API_glUseProgram			db	"glUseProgram"
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