; ********************************
; * [ 1K OpenGL/GLSL Framework ] *
; ********************************
; *        By Ferris / YUP       *
; ********************************
; * (C) 2009-2011 Youth Uprising *
; ********************************

%define _1K_SCRW_ 1280
%define _1K_SCRH_ 720

%define _1K_END_TIME_ 104000

%include "..\Include\win32n.inc"
%include "..\Include\nasmgl.inc"

extern _sonant2_init

; Windows
%define ChangeDisplaySettingsA __imp__ChangeDisplaySettingsA@8
extern ChangeDisplaySettingsA
%define ShowCursor __imp__ShowCursor@4
extern ShowCursor
%define CreateWindowExA __imp__CreateWindowExA@48
extern CreateWindowExA
%define GetDC __imp__GetDC@4
extern GetDC
%define ChoosePixelFormat __imp__ChoosePixelFormat@8
extern ChoosePixelFormat
%define SetPixelFormat __imp__SetPixelFormat@12
extern SetPixelFormat
%define wglCreateContext __imp__wglCreateContext@4
extern wglCreateContext
%define wglMakeCurrent __imp__wglMakeCurrent@8
extern wglMakeCurrent
%define timeGetTime __imp__timeGetTime@0
extern timeGetTime
%define SwapBuffers __imp__SwapBuffers@4
extern SwapBuffers
%define GetAsyncKeyState __imp__GetAsyncKeyState@4
extern GetAsyncKeyState
%define ExitProcess __imp__ExitProcess@4
extern ExitProcess
%define midiOutOpen __imp__midiOutOpen@20
extern midiOutOpen

; OpenGL
%define wglGetProcAddress __imp__wglGetProcAddress@4
extern wglGetProcAddress
%define glColor3uiv __imp__glColor3uiv@4
extern glColor3uiv
%define glRects __imp__glRects@16
extern glRects

[segment .text]
					; Entry point
main:
					; Create window
					;  Hide cursor & possibly change display settings
windowinit:			push CDS_FULLSCREEN
					push dmss
					call [ChangeDisplaySettingsA]
					times 13 push byte 0
					call [ShowCursor]
					;  Midi init
					push midi_handle
					call [midiOutOpen]
					;  Create window
					push WS_POPUP | WS_VISIBLE | WS_MAXIMIZE
					push byte 0
					push classname
					push byte 0
					call [CreateWindowExA]
					;  Get device context
					push eax
					call [GetDC]
					push pfd
					;  Set pixel format
					xchg eax,ebx
					push pfd
					push ebx
					call [ChoosePixelFormat]
					push pfd
					push eax
					push ebx
					call [SetPixelFormat]
					;  Set up rendering context
					push ebx
					call [wglCreateContext]
					push eax
					push ebx
					call [wglMakeCurrent]
					
					; Shader init
					;  Create program
shaderinit:			push sn_glCreateProgram
					call [wglGetProcAddress]
					call eax
					mov [program],eax
					;  Fragment shader
					push 8b30h ; GL_FRAGMENT_SHADER
					push sn_glCreateShader
					call [wglGetProcAddress]
					call eax
					mov [pfd],eax
					push byte 0
					mov [edi],dword shaders_fragment
					push edi
					push byte 1
					push dword [pfd]
					push sn_glShaderSource
					call [wglGetProcAddress]
					call eax
					push dword [pfd]
					push sn_glCompileShader
					call [wglGetProcAddress]
					call eax
					push dword [pfd]
					push dword [program]
					push sn_glAttachShader
					call [wglGetProcAddress]
					call eax
					;  Link and bind
					push dword [program]
					push sn_glLinkProgram
					call [wglGetProcAddress]
					call eax
					push dword [program]
					push sn_glUseProgram
					call [wglGetProcAddress]
					call eax
					
					call _sonant2_init
					
					; Timer init
timerinit:			call [timeGetTime]
					mov esi,eax
					
					; Main loop
mainloop:
						;  Timer
						call [timeGetTime]
						sub eax,esi
						;   Quit when music finishes
%ifdef _1K_END_TIME_
						cmp eax,dword _1K_END_TIME_
						jge endprogram
%endif
						;   Pass time to shader
						mov [edi],eax
						push edi
						
						;  Music update
musicupdate:			pusha
						
						popa
						
						call [glColor3uiv]
						
						;  Render target
						push byte 1
						push byte 1
						push byte -1
						push byte -1
						call [glRects]
						
						;  Swap buffers
						push ebx
						call [SwapBuffers]
						
					;  Quit on escape
					push VK_ESCAPE
					call [GetAsyncKeyState]
					dec eax
					js mainloop
					
					; Terminate
endprogram:			push byte 0
					call [ExitProcess]

[segment .bss]

[segment .data]
classname:
	db "edit",0
dmss: ; Devmode
pfd: ; Pixelformatdescriptor 
	db 0,0,0,0
program: ; Program storage space
	dd PFD_DRAW_TO_WINDOW | PFD_SUPPORT_OPENGL | PFD_DOUBLEBUFFER
midi_handle: ; Handle for midi interface
	db PFD_TYPE_RGBA
	db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db DEVMODE_size
	db 0,0
	dd DM_PELSWIDTH | DM_PELSHEIGHT
	dd 0,0,0,0,0,0,0
	dw 0,0
	dd 0,0
	dw 0,0
	dd 0,0
	db 0,0,0,0,0,0,0,0,0,0,0,0
	dd _1K_SCRW_
	dd _1K_SCRH_
shaders_fragment: ; Fragment shader
	db "float t2;"
	db "float t,d,c,pl,pl2,fart;"
	db "vec3 r(vec3 x,float t){"
		db "for(float v=0.;v<3;v++)t*=.8,x=vec3(cos(t)*x.x+sin(t)*x.z,cos(t)*x.z-sin(t)*x.x,x.y);"
		db "return x;"
	db "}"
	db "void main(){"
		db "t2=gl_Color.x*2222222.+14.;"
		db "t=(t2-fract(t2*.1))*.9-3.0;c=cos(max(t-16,0.)*.08)*5;pl=sin(t*.8)*.7;pl2=cos(t*.6)*.3;fart=t*.4;"
		db "vec2 lol=(gl_FragCoord.xy-vec2(600,380))/480.;"
		db "vec3 x,a,z=vec3(0),y=r(normalize(vec3(lol,1)),c);"
		db "for(float v=0.;v<3;v+=.06){"
			db "x=abs(a=r(abs(z-r("
					db "vec3(sin(t*.22),0,3.5+sin(t*.6)+t*.04)"
				db ",c))"
					db "-vec3(1.5)"
				db ","
					db "max(t-15,0.)*.3"
				db "));"
			db "d=min(max(max(x.x,x.y),x.z)-1,8.-length(x));"
			db "for(float v=0.;v<3;v++){"
				db "x=r(r(abs(fract(a*pow(3.,v))-.5)+.01,pl),pl2);"
				db "d=max(d,mix("
					db ".17-min(min(max(x.x,x.y),max(x.x,x.z)),max(x.y,x.z)),"
					db "length(x+sin(fart)*.14)-.6,"
					db ".5-cos(t*.09)*.5"
				db "));"
			db "}"
			db "gl_FragColor=(vec4(1)-mix(vec4(.6,.8,1.2,1),vec4(1.2,1,1.1,1),y.y+.5)*v*.3)*min(t2*.4-6.,1.)*min(1.0-(t2*.4-25.4),1.0)-length(lol)*.4;"
			db "if(d<=0)break;"
			db "z+=y*max(d,.001);"
		db "}"
	db "}",0
sn_glCreateProgram:
	db "glCreateProgram",0
sn_glCreateShader:
	db "glCreateShader",0
sn_glShaderSource:
    db "glShaderSource",0
sn_glCompileShader:
    db "glCompileShader",0
sn_glAttachShader:
    db "glAttachShader",0
sn_glLinkProgram:
    db "glLinkProgram",0
sn_glUseProgram:
    db "glUseProgram",0
