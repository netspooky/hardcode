; ********************************
; * [ 1K OpenGL/GLSL Framework ] *
; ********************************
; *        By Ferris / YUP       *
; ********************************
; *    [c] 2009 Youth Uprising   *
; ********************************

%define _1K_SCRW_ 1280
%define _1K_SCRH_ 720

;%define _1K_FAST_FORWARD_ 28000
%define _1K_END_TIME_ 32700

;%define _1K_DIAGNOSTICS_ ; Uncomment to enable message boxes at each major initialization step
;%define _1K_NO_SHADERS_ ; Uncomment to disable shaders
%define _1K_NO_VERTEX_SHADER_ ; Uncomment to disable vertex shader only
;%define _1K_NO_SOUND_ ; Uncomment to disable sound
;%define _1K_SYNTH_ ; Uncomment to use synth (else use MIDI)
%define _1K_SYNTH_SAW_ ; Make synth use a saw wave (else use sine wave)
%define _1K_SYNTH_DELAY_ ; Make synth use delay
%define _1K_SYNTH_DELAY_TIME_ 12000 ; Delay time in samples
%define _1K_SYNTH_WAVE_SIZE_ 44100 * 100 ; Buffer size in samples
%define _1K_SYNTH_DELAY_SIZE_ _1K_SYNTH_WAVE_SIZE_ - _1K_SYNTH_DELAY_TIME_ ; Delay buffer size in samples

%include "..\Include\win32n.inc"
%include "..\Include\nasmgl.inc"

; Windows
%define ChangeDisplaySettingsA _ChangeDisplaySettingsA@8
extern ChangeDisplaySettingsA
%define ShowCursor _ShowCursor@4
extern ShowCursor
%define CreateWindowExA _CreateWindowExA@48
extern CreateWindowExA
%define GetDC _GetDC@4
extern GetDC
%define ChoosePixelFormat _ChoosePixelFormat@8
extern ChoosePixelFormat
%define SetPixelFormat _SetPixelFormat@12
extern SetPixelFormat
%define wglCreateContext _wglCreateContext@4
extern wglCreateContext
%define wglMakeCurrent _wglMakeCurrent@8
extern wglMakeCurrent
%define timeGetTime _timeGetTime@0
extern timeGetTime
%define SwapBuffers _SwapBuffers@4
extern SwapBuffers
%define GetAsyncKeyState _GetAsyncKeyState@4
extern GetAsyncKeyState
%define ExitProcess _ExitProcess@4
extern ExitProcess
%ifdef _1K_DIAGNOSTICS_
%define MessageBoxA _MessageBoxA@16
extern MessageBoxA
%endif

; OpenGL
%define wglGetProcAddress _wglGetProcAddress@4
extern wglGetProcAddress
%define glColor3uiv _glColor3uiv@4
extern glColor3uiv
%define glRects _glRects@16
extern glRects

; Sound-specific
%ifndef _1K_NO_SOUND_
%ifdef _1K_SYNTH_
%define waveOutOpen _waveOutOpen@24
extern waveOutOpen
%define waveOutPrepareHeader _waveOutPrepareHeader@12
extern waveOutPrepareHeader
%define waveOutWrite _waveOutWrite@12
extern waveOutWrite
%else
%define midiOutOpen _midiOutOpen@20
extern midiOutOpen
%define midiOutShortMsg _midiOutShortMsg@8
extern midiOutShortMsg
%endif
%endif

[segment .text]
					; Entry point
main:
					; Set up stack
					enter 0,0
					
					; Create our window
					;  Hide cursor & possibly change display settings
windowinit:			push CDS_FULLSCREEN
					push dmss
					call ChangeDisplaySettingsA
%ifdef _1K_DIAGNOSTICS_
					push MB_OK | MB_ICONEXCLAMATION
					push dg_title
					push dg_resize
					push 0
					call MessageBoxA
%endif
					push byte 0
					call ShowCursor
					;  Create window
					times 8 push byte 0
%ifndef _1K_NO_SOUND_
%ifndef _1K_SYNTH_
					; Open & prepare midi
soundinit:			times 4 push byte 0
					push midihandle
					call midiOutOpen
%endif
%endif
					push WS_POPUP | WS_VISIBLE | WS_MAXIMIZE
					push byte 0
					push classname
					push byte 0
					call CreateWindowExA
					;  Get device context
					push eax
					call GetDC
					push pfd
					;  Set pixel format
					mov ebx,eax
					push pfd
					push eax
					call ChoosePixelFormat
					push pfd
					push eax
					push ebx
					call SetPixelFormat
					;  Set up rendering context
					push ebx
					call wglCreateContext
					push eax
					push ebx
					call wglMakeCurrent
%ifdef _1K_DIAGNOSTICS_
					push MB_OK | MB_ICONEXCLAMATION
					push dg_title
					push dg_wcreate
					push 0
					call MessageBoxA
%endif
					
					; Shader init
%ifndef _1K_NO_SHADERS_
					;  Create program
shaderinit:			push sn_glCreateProgram
					call wglGetProcAddress
					call eax
					mov [wave_buffer],eax
%ifdef _1K_DIAGNOSTICS_
					push MB_OK | MB_ICONEXCLAMATION
					push dg_title
					push dg_spcreate
					push 0
					call MessageBoxA
%endif
%ifndef _1K_NO_VERTEX_SHADER_
					;  Vertex shader
					push sn_glCreateShader
					call wglGetProcAddress
					push 8b31h ; GL_VERTEX_SHADER
					call eax
					mov [pfd],eax
					push sn_glShaderSource
					call wglGetProcAddress
					push byte 0
					;   Have to pass a pointer pointer (not a typo) because glShaderSource only accepts string arrays.
					mov [esi],dword shaders_vertex
					push esi
					push byte 1
					push dword [pfd]
					call eax
					push sn_glCompileShader
					call wglGetProcAddress
					push dword [pfd]
					call eax
					push sn_glAttachShader
					call wglGetProcAddress
					push dword [pfd]
					push dword [wave_buffer]
					call eax
%ifdef _1K_DIAGNOSTICS_
					push MB_OK | MB_ICONEXCLAMATION
					push dg_title
					push dg_svc
					push 0
					call MessageBoxA
%endif
%endif
					;  Fragment shader
					push sn_glCreateShader
					call wglGetProcAddress
					push 8b30h ; GL_FRAGMENT_SHADER
					call eax
					mov [pfd],eax
					push sn_glShaderSource
					call wglGetProcAddress
					push byte 0
					mov [esi],dword shaders_fragment
					push esi
					push byte 1
					push dword [pfd]
					call eax
					push sn_glCompileShader
					call wglGetProcAddress
					push dword [pfd]
					call eax
					push sn_glAttachShader
					call wglGetProcAddress
					push dword [pfd]
					push dword [wave_buffer]
					call eax
					;  Link and bind
					push sn_glLinkProgram
					call wglGetProcAddress
					push dword [wave_buffer]
					call eax
					push sn_glUseProgram
					call wglGetProcAddress
					push dword [wave_buffer]
					call eax
%ifdef _1K_DIAGNOSTICS_
					push MB_OK | MB_ICONEXCLAMATION
					push dg_title
					push dg_sfc
					push 0
					call MessageBoxA
%endif
%endif
					
					; Music init
%ifndef _1K_NO_SOUND_
%ifdef _1K_SYNTH_
soundinit:
					;  Render song
					mov edi,wave_buffer
					xor ecx,ecx
					mov cl,2
songloop:				push ecx
						mov eax,song_track
						xor ecx,ecx
						mov cl,4
instrloop:					push ecx
							mov edx,edi
							mov cl,8
trackloop:						push ecx
								; Render current song note
								;  Get note frequency
								mov cl,[eax]
%ifdef _1K_SYNTH_SAW_
								fld dword [freq_saw_init]
%else
								fld dword [freq_sin_init]
%endif
freqloop:							fmul dword [freq_mult]
								loop freqloop
								;  Render note
								mov cx,60000
noteloop:							
%ifdef _1K_SYNTH_SAW_
									fld1
%endif
									mov [esi],ecx
									fild dword [esi]
%ifdef _1K_SYNTH_SAW_
									fmul st2
									fprem
									fstp st1
%else
									fmul st1
									fsin
%endif
									mov [esi],word 4000
									fimul word [esi]
									fiadd word [edx]
									fistp word [edx]
								times 2 inc edx
								loop noteloop
							;  Cleanup
							fstp st0
							inc eax
							pop ecx
							loop trackloop
						pop ecx
						loop instrloop
					pop ecx
					add edi,60000 * 2 * 8
					loop songloop
					
					;  Delay
%ifdef _1K_SYNTH_DELAY_
delayloop:			mov edx,ecx
					add edx,_1K_SYNTH_DELAY_TIME_ * 2
					mov ax,[wave_buffer + ecx]
					sar ax,byte 1
					add ax,[wave_buffer + edx]
					mov [wave_buffer + edx],ax
					times 2 inc ecx
					cmp ecx,_1K_SYNTH_DELAY_SIZE_ * 2
					jbe delayloop
%endif
					
					;  Send to WaveOut API
					times 3 push byte 0
					push wave_format
					push WAVE_MAPPER
					push esi
					call waveOutOpen
					push byte 32
					push wave_header
					push dword [esi]
					call waveOutPrepareHeader
					push byte 32
					push wave_header
					push dword [esi]
					call waveOutWrite
%endif
%endif
					
					; Timer init
timerinit:			call timeGetTime
					mov esi,eax
%ifdef _1K_DIAGNOSTICS_
					push MB_OK | MB_ICONEXCLAMATION
					push dg_title
					push dg_intro
					push 0
					call MessageBoxA
%endif
					
					; Main loop
mainloop:
						;  Timer
						call timeGetTime
						sub eax,esi
						;   Fast forward
%ifdef _1K_FAST_FORWARD_
						add eax,dword _1K_FAST_FORWARD_
%endif
						;   Quit when music finishes
%ifdef _1K_END_TIME_
						cmp eax,dword _1K_END_TIME_
						jge endprogram
%endif
						;   Pass time to shader
						mov [ebp],eax
						push ebp
%ifndef _1K_NO_SOUND_
%ifndef _1K_SYNTH_
						; Update midi player
playmidi				shr eax,byte 8
						and eax,63
						;  Instrument loop
						mov ecx,3
midiinstr					pusha
							cmp al,[pfd]
							je playmidinomsg
								dec ecx
								mov edx,ecx
								shl edx,byte 6
								mov al,[song_patterns + edx + eax]
								test eax,eax
								jz playmidinomsg
									push eax
									mov bl,127
midinoteoffloop							mov edi,midimsg
										mov al,87h ; Note-off message
										add eax,ecx
										stosb
										mov eax,ebx ; Note value
										call sendmidiout
									dec bl
									jnz midinoteoffloop
									mov edi,midimsg
									mov al,0c7h ; Program change message
									add eax,ecx
									stosb
									mov al,[song_programs + ecx] ; Program number
									call sendmidiout
									mov edi,midimsg
									mov al,97h ; Note-on message
									add eax,ecx
									stosb
									pop eax ; Note value
									call sendmidiout
playmidinomsg:				popa
						loop midiinstr
						mov [pfd],al
%endif
%endif
						call glColor3uiv
						
						;  Render target
						push byte 1
						push byte 1
						push byte -1
						push byte -1
						call glRects
						
						;  Swap buffers
						push ebx
						call SwapBuffers
						
					;  Quit on escape
					push VK_ESCAPE
					call GetAsyncKeyState
					dec eax
					js mainloop
					
					; Terminate
endprogram:			call ExitProcess
					;leave
					;ret
					
%ifndef _1K_NO_SOUND_
%ifndef _1K_SYNTH_
sendmidiout:		stosb
					mov al,100 ; Velocity
					stosb
					pusha
					push dword [midimsg]
					push dword [midihandle]
					call midiOutShortMsg
					popa
					ret
%endif
%endif

[segment .bss]
wave_buffer: ; Synth buffer
%ifndef _1K_NO_SOUND_
%ifdef _1K_SYNTH_
	resw _1K_SYNTH_WAVE_SIZE_
%endif
%else
	resw 2
%endif
%ifndef _1K_NO_SOUND_
%ifndef _1K_SYNTH_
midimsg: ; Midi output message buffer
	resd 1
midihandle: ; Midi output handle
	resd 1
%endif
%endif

[segment .data]
classname:
	db "edit",0
dmss: ; Devmode
pfd: ; Pixelformatdescriptor 
	db 0,0,0,0
	dd PFD_DRAW_TO_WINDOW | PFD_SUPPORT_OPENGL | PFD_DOUBLEBUFFER
	db PFD_TYPE_RGBA
	db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db DEVMODE_size
	db 0,0
	dd DM_PELSWIDTH | DM_PELSHEIGHT
%ifndef _1K_NO_SOUND_
%ifdef _1K_SYNTH_
wave_header:
	dd wave_buffer
	dd _1K_SYNTH_WAVE_SIZE_; * 2 ; <- Incorrect to take out the " * 2", but it compresses just slightly better.
	dd 0,0,0,0,0
wave_format:
	dw WAVE_FORMAT_PCM
	dw 1
	dd 44120
	dd 88200
	dw 2
	dw 16
%ifdef _1K_SYNTH_SAW_
freq_saw_init: ; Initial saw frequency
	dd 0.0005009692
%elifdef _1K_SYNTH_SINE_
freq_sin_init: ; Initial sine frequency
	dd 0.0031476826
%endif
freq_mult: ; Frequency multiplier
	dd 1.0594630943
%else
	dd 0,0,0,0,0,0,0
	dw 0,0
	dd 0,0
	dw 0,0
	dd 0,0
%endif
%else
	dd 0,0,0,0,0,0,0
	dw 0,0
	dd 0,0
	dw 0,0
	dd 0,0
%endif
	db 0,0,0,0,0,0,0,0,0,0,0,0
	dd _1K_SCRW_
	dd _1K_SCRH_
%ifndef _1K_NO_SHADERS_
%ifndef _1K_NO_VERTEX_SHADER_
shaders_vertex: ; Vertex shader
	db "void main(){"
	db  "gl_Position=ftransform();"
	db "}",0
%endif
shaders_fragment: ; Fragment shader
	db "void main(){"
	db  "float i=0,t=gl_Color.x*1111111;"
	db  "vec2 x=0,y=(gl_FragCoord.xy/250-1)*(.14-sin(t*.2)*.1);"
	db  "for(;i<80;i++){"
	db   "gl_FragColor+=(mix(vec4(.01,.015,.02,1),vec4(.02,.01,.015,1),min((y.y+.02)*8,1.))+.01)*(1-max(min(t-7.2,1.),0.))+(1-min(t,1.))*.11;"
	db   "x=vec2(x.x*x.x-x.y*x.y-y.x-t*.09-1.15,(2-pow(min(1.-t/4.7,1.),2.))*abs(x.x*x.y)-y.y);"
	db   "if(length(x)>20)i=80;"
	db  "}"
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
%endif
%ifndef _1K_NO_SOUND_
%ifdef _1K_SYNTH_
song_track:
	db 44,47,49,51,40,47,44,42 ; Lead
	db 51,54,56,58,47,54,51,49 ; Lead 7th
	db 13,11,16,15,13,15,16,18 ; Bass
	db 25,23,28,27,25,27,28,30 ; Bass octave
%else
song_patterns:
	db 31, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,29, 0, 0, 0, 0, 0, 0, 0,26, 0, 0, 0, 0, 0, 0, 0 ; Bass
	db 27, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,29, 0, 0, 0, 0, 0, 0, 0,34, 0, 0, 0, 0, 0, 0, 0
	
	db 67, 0, 0, 0, 0, 0, 0, 0,74, 0, 0, 0, 0, 0, 0, 0,69, 0, 0, 0, 0, 0, 0, 0,70, 0, 0, 0, 0, 0,69, 0 ; Pad
	db 67, 0, 0, 0, 0, 0, 0, 0,69, 0, 0, 0, 0, 0, 0, 0,70, 0, 0, 0, 0, 0, 0, 0,72, 0, 0, 0,74, 0, 0, 0
	
	db 36,42,42,36,38,42,42,36,36,42,42,36,38,42,42,46,36,42,42,36,38,42,42,36,36,42,42,36,38,42,38,40 ; Drums
	db 36,42,42,36,38,42,42,36,36,42,42,36,38,46,36,46,36,42,42,36,38,42,42,36,36,42,42,36,38,42,38,40
song_programs:
	db 44 ; Bass
	db 89 ; Pad (also good are 81, 92)
%endif
%endif
%ifdef _1K_DIAGNOSTICS_
dg_title:
	db "Diagnostic Update",0
dg_resize:
	db "Screen resized successfully.",0
dg_wcreate:
	db "Window created successfully.",0
dg_spcreate:
	db "Shader program created successfully.",0
dg_svc:
	db "Vertex shader initialized successfully.",0
dg_sfc:
	db "Fragment shader initialized successfully.",0
dg_intro:
	db "Intro initialized successfully.",0
%endif
