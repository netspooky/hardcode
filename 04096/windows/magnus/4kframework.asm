; Magnus

; Made by Ferris and Decipher in two days as a quick prod for The Gathering 2010.
;  Basically an excuse to use this song that I've had on my hard drive since the
;  Summer, and something to contribute to the party. Oh yeah, and...we won :D .

; Assembles with NASM.

; [c] 2010 Youth Uprising

%define _4K_SCRW_ 1280
%define _4K_SCRH_ 720

;%define _4K_FAST_FORWARD_ 110000
%define _4K_END_TIME_ 132000

;%define _4K_DIAGNOSTICS_ ; Uncomment to enable message boxes at each major initialization step
%define _4K_RESIZE_WINDOW_ ; Uncomment to resize window to _4K_SCRW_ x _4K_SCRH_
;%define _4K_NO_SHADERS_ ; Uncomment to disable shaders
;%define _4K_NO_TIMER_ ; Meh.
%define _4K_NO_SOUND_ ; Uncomment to disable sound

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
%ifdef _4K_DIAGNOSTICS_
%define MessageBoxA _MessageBoxA@16
extern MessageBoxA
%endif

; OpenGL
%define wglGetProcAddress _wglGetProcAddress@4
extern wglGetProcAddress
%define glClear _glClear@4
extern glClear
%define glEnable _glEnable@4
extern glEnable
%define glBlendFunc _glBlendFunc@8
extern glBlendFunc
%define glColor3uiv _glColor3uiv@4
extern glColor3uiv
%define glRects _glRects@16
extern glRects

; Sonant
%ifndef _4K_NO_SOUND_
extern _sonant2_init
%endif

[segment .text]
					; Entry point
main:
					; Set up stack
					enter 0,0
					
					; Create our window
					;  Hide cursor & possibly change display settings
%ifdef _4K_RESIZE_WINDOW_
					push CDS_FULLSCREEN
					push dmss
					call ChangeDisplaySettingsA
%ifdef _4K_DIAGNOSTICS_
					push MB_OK | MB_ICONEXCLAMATION
					push dg_title
					push dg_resize
					push 0
					call MessageBoxA
%endif
%else
					push byte 0
%endif
					call ShowCursor
					;  Create window
					times 8 push byte 0
					push WS_POPUP | WS_VISIBLE | WS_MAXIMIZE
					push byte 0
					push classname
					push byte 0
					call CreateWindowExA
					;  Get device context
					push eax
					call GetDC
					mov ebx,eax
					;  Set pixel format
					push pfd
					push ebx
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
%ifdef _4K_DIAGNOSTICS_
					push MB_OK | MB_ICONEXCLAMATION
					push dg_title
					push dg_wcreate
					push 0
					call MessageBoxA
%endif
					
					; Shader init
%ifndef _4K_NO_SHADERS_
					xor ecx,ecx
shaderloop:				pusha
						shl ecx,byte 4
						xchg ecx,esi
						;  Create program
						push sn_glCreateProgram
						call wglGetProcAddress
						call eax
						mov [p],eax
%ifdef _4K_DIAGNOSTICS_
						push MB_OK | MB_ICONEXCLAMATION
						push dg_title
						push dg_spcreate
						push 0
						call MessageBoxA
%endif
						;  Vertex shader
						push sn_glCreateShader
						call wglGetProcAddress
						push 8b31h ; GL_VERTEX_SHADER
						call eax
						mov [pfd],eax
						push sn_glShaderSource
						call wglGetProcAddress
						xchg eax,ecx
						push byte 0
						mov eax,[timeline + esi + 4]
						mov [stringtab_vertex + 8],eax
						push stringtab_vertex
						push byte 4
						push dword [pfd]
						call ecx
						push sn_glCompileShader
						call wglGetProcAddress
						push dword [pfd]
						call eax
						push sn_glAttachShader
						call wglGetProcAddress
						push dword [pfd]
						push dword [p]
						call eax
%ifdef _4K_DIAGNOSTICS_
						push sn_glGetShaderInfoLog
						call wglGetProcAddress
						push ebuffer
						push edi
						push dword 256
						push dword [pfd]
						call eax
						push MB_OK | MB_ICONEXCLAMATION
						push dg_title
						push ebuffer
						push 0
						call MessageBoxA
%endif
						;  Fragment shader
						push sn_glCreateShader
						call wglGetProcAddress
						push 8b30h ; GL_FRAGMENT_SHADER
						call eax
						mov [pfd],eax
						push sn_glShaderSource
						call wglGetProcAddress
						xchg eax,ecx
						push byte 0
						mov eax,[timeline + esi + 8]
						mov [stringtab_fragment + 8],eax
						push stringtab_fragment
						push byte 4
						push dword [pfd]
						call ecx
						push sn_glCompileShader
						call wglGetProcAddress
						push dword [pfd]
						call eax
						push sn_glAttachShader
						call wglGetProcAddress
						push dword [pfd]
						push dword [p]
						call eax
						;  Link
						push sn_glLinkProgram
						call wglGetProcAddress
						push dword [p]
						call eax
						mov eax,[timeline + esi]
						shr esi,byte 1
						mov [shadertimetable + esi],eax
						mov eax,[p]
						mov [shadertimetable + esi + 4],eax
						; Stupid ATI.
						;push sn_glUseProgram
						;call wglGetProcAddress
						;push dword [p]
						;call eax
						;times 4 push byte 0
						;call glRects
%ifdef _4K_DIAGNOSTICS_
						push sn_glGetShaderInfoLog
						call wglGetProcAddress
						push ebuffer
						push edi
						push dword 256
						push dword [pfd]
						call eax
						push MB_OK | MB_ICONEXCLAMATION
						push dg_title
						push ebuffer
						push 0
						call MessageBoxA
%endif
					popa
					inc ecx
					cmp cl,byte TIMELINENUM
					jne shaderloop
%endif
					
					; Music
%ifndef _4K_NO_SOUND_
					call _sonant2_init
%endif
					
					; Timer init
%ifndef _4K_NO_TIMER_
					call timeGetTime
					xchg eax,esi
%endif
%ifdef _4K_DIAGNOSTICS_
					push MB_OK | MB_ICONEXCLAMATION
					push dg_title
					push dg_intro
					push 0
					call MessageBoxA
%endif
					
					; Main loop
mainloop:
						push GL_COLOR_BUFFER_BIT
						call glClear
						push GL_ONE_MINUS_SRC_ALPHA
						push GL_SRC_ALPHA
						call glBlendFunc
						push GL_BLEND
						call glEnable
						
						;  Timer
%ifndef _4K_NO_TIMER_
						call timeGetTime
						sub eax,esi
						;   Fast forward
%ifdef _4K_FAST_FORWARD_
						add eax,dword _4K_FAST_FORWARD_
%endif
						;   Quit when music finishes
%ifdef _4K_END_TIME_
						cmp eax,dword _4K_END_TIME_
						jge endprogram
%endif
%endif
%ifndef _4K_NO_SHADERS_
						xor ecx,ecx
timeloop:					pusha
							shl ecx,byte 3
							xchg ecx,esi
							cmp eax,dword [shadertimetable + esi]
							jb timeloop_nope
								push sn_glUseProgram
								call wglGetProcAddress
								push dword [shadertimetable + esi + 4]
								call eax
timeloop_nope:				popa
						inc ecx
						cmp cl,byte TIMELINENUM
						jne timeloop
						
						mov ecx,4
							;   Pass time to shader
blurloop:					mov [pfd],eax
							add eax,byte 8
							pusha
							push pfd
							call glColor3uiv
							
							;  Render target
							push byte 1
							push byte 1
							push byte -1
							push byte -1
							call glRects
							popa
						loop blurloop
%endif
						
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

[segment .bss]
p: ; Program id
	resd 1
shadertimetable:
	resd TIMELINENUM * 2
%ifdef _4K_DIAGNOSTICS_
ebuffer: ; Shader error log buffer
	resb 256
%endif

[segment .data]
classname:
	db "edit",0
%ifdef _4K_RESIZE_WINDOW_
pfd: ; Pixelformatdescriptor
dmss: ; Devmode
	dw 0,0
	dd PFD_DRAW_TO_WINDOW | PFD_SUPPORT_OPENGL | PFD_DOUBLEBUFFER
	db PFD_TYPE_RGBA
	db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dw 0,0
	dw DEVMODE_size
	dw 0
	dd DM_PELSWIDTH | DM_PELSHEIGHT
	dw 0,0,0,0,0,0,0,0,0,0,0,0,0
	db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dw 0
	dd 0
	dd _4K_SCRW_
	dd _4K_SCRH_
	; Risky :)
;	dd 0,0,0
%endif
%ifndef _4K_NO_SHADERS_
timeline:
	dd 0		,shaders_vertex0	,shaders_fragment0	,0
	dd 8300		,shaders_vertex1	,shaders_fragment0	,0
	dd 12350	,shaders_vertex2	,shaders_fragment1	,0
	dd 14400	,shaders_vertex2	,shaders_fragment2	,0
	dd 15450	,shaders_vertex2	,shaders_fragment3	,0
	dd 16500	,shaders_vertex2	,shaders_fragment4	,0
	dd 20800	,shaders_vertex3	,shaders_fragment4	,0
	dd 25100	,shaders_vertex4	,shaders_fragment4	,0
	dd 28900	,shaders_vertex4	,shaders_fragment5	,0
	dd 33500	,shaders_vertex3	,shaders_fragment5	,0
	dd 41700	,shaders_vertex4	,shaders_fragment5	,0
	dd 50000	,shaders_vertex5	,shaders_fragment6	,0
	dd 67500	,shaders_vertex1	,shaders_fragment6	,0
	dd 84000	,shaders_vertex3	,shaders_fragment6	,0
	dd 100700	,shaders_vertex4	,shaders_fragment6	,0
	dd 117500	,shaders_vertex3	,shaders_fragment6	,0
TIMELINENUM equ ($ - timeline) / 16
stringtab_vertex:
	dd shaders_commonstart,shaders_vertexstart,0,shaders_vertexend
stringtab_fragment:
	dd shaders_commonstart,shaders_fragmentstart,0,shaders_fragmentend
shaders_commonstart:
	db "varying float t,a1,a2,a3,a,b;"
	db "varying vec3 e;"
	db "float n1(vec3 p){"
	db  "p.x+=p.y*50.+p.z*20.;"
	db  "return cos(p.x*sin(p.x));"
	db "}"
	db "float n2(vec3 p){"
	db  "vec3 a=floor(p),b=p-a;"
	db  "return mix(mix(mix(n1(a),n1(a+vec3(1,0,0)),b.x),mix(n1(a+vec3(0,1,0)),n1(a+vec3(1,1,0)),b.x),b.y),mix(mix(n1(a+vec3(0,0,1)),n1(a+vec3(1,0,1)),b.x),mix(n1(a+vec3(0,1,1)),n1(a+1.),b.x),b.y),b.z)*.5+.5;"
	db "}",0
;	db "float pn(vec3 p){"
;	db  "return n2(p*.06125)*.5+n2(p*.125)*.25+n2(p*.25)*.125;"
;	db "}",0
shaders_vertexstart:
	db "void main(){"
	db  "t=gl_Color.x*4294967.295;"
	db  "float er;"
	db  "e=vec3(",0
shaders_vertexend:
	db  ";e-=vec3(sin(a2)*er,0,cos(a2)*er)-n2(vec3(t*(8.+b*60.)))*(.13+b);"
	db  "gl_Position=ftransform();"
	db "}",0
shaders_fragmentstart:
	db "float f(vec3 p){"
	db  "float q,s;",0
shaders_fragmentend:
	db ";}"
	db "void main(){"
	; Eye ray
;	db  "vec3 v=normalize(vec3((gl_FragCoord.xy-vec2(960,540))/1080.*1.4,1));" ; Eye ray (1080p)
;	db  "vec3 v=normalize(vec3((gl_FragCoord.xy-vec2(720,450))/900.*1.4,1));" ; Eye ray (1440x900)
	db  "vec3 v=normalize(vec3((gl_FragCoord.xy-vec2(640,360))/720.*1.4,1));" ; Eye ray (720p)
;	db  "vec3 v=normalize(vec3((gl_FragCoord.xy-vec2(512,384))/768.*1.4,1));" ; Eye ray (1024x768)
;	db  "vec3 v=normalize(vec3((gl_FragCoord.xy-vec2(400,300))/600.*1.4,1));" ; Eye ray (800x600)
;	db  "vec3 v=normalize(vec3((gl_FragCoord.xy-vec2(320,240))/480.*1.4,1));" ; Eye ray (480p)
;	db  "vec3 v=normalize(vec3((gl_FragCoord.xy-vec2(160,120))/240.*1.4,1));" ; Eye ray (320x240)
	db  "v=vec3(v.x,v.y*cos(a1)+v.z*sin(a1),v.z*cos(a1)-v.y*sin(a1));"
	db  "v=vec3(v.x*cos(a3)+v.y*sin(a3),v.y*cos(a3)-v.x*sin(a3),v.z);"
	db  "v=vec3(v.x*cos(a2)+v.z*sin(a2),v.y,v.z*cos(a2)-v.x*sin(a2));"
	db  "vec3 p=e,c=vec3(pow(v.y*.5+.5,2.))-(1.-pow(max(max(abs(v.x),.4-v.y),abs(v.z))-.4,2.))*.2;";+pow(max(v.y,0.),77.);"
	; Stupid NVidia.
	db  "float g=0.;"
	db  "while(g<32.){"
	db   "g=length(p-e);"
	db   "float d=f(p),c2=0.,i;"
	db   "if(d<=0.){"
	db    "vec3 n=normalize(vec3(f(p+vec3(.01,0,0))-d,f(p+vec3(0,.01,0))-d,f(p+vec3(0,0,.01))-d)),r=2.*n*dot(n,-v)+v;"
	db    "for(i=1.;i<5.;i++)c2+=(i*.2-f(p+n*i*.2))/pow(2.,i);"
	db    "c=vec3(r.y*.5+.5)*vec3(.9,1,.8)*.86-c2;"
	db    "if(r.y>0.&&abs(r.x)<.504&&abs(r.z)<.504){"
	db     "r=fract(r*8.)*.125-.0625;"
	db     "c+=.2-pow(length(r.xz*16.),2.)*.2;"
	db    "}else{"
	db     "c-=(1.-pow(max(max(abs(r.x),.4-r.y),abs(r.z))-.4,2.))*.2;"
	db    "}"
	db    "break;"
	db   "}"
	db   "if(d<.001)d=.001;"
	db   "p+=v*d;"
	db  "}"
	db  "gl_FragColor=vec4(c+b,.33)*a;"
	db "}",0
shaders_vertex0: ; Opening Sphere
	db  "0,-5.2-t*.3,0);" ; e=vec3(
	db  "a1=1.;"
	db  "a2=t*.4;"
	db  "a3=0.;"
	db  "er=6.;"
	db  "a=min(t*.2,1.);"
	db  "b=max(min((t-6.9)*.8,1.),0.)",0
shaders_vertex1: ; Show sphere opening
	db  "0,6.,0);" ; e=vec3(
	db  "a1=cos(t*.1)*.4-.9;"
	db  "a2=t*.3+sin(t*.2)*.3;"
	db  "a3=cos(t*.8)*.4;"
	db  "er=6.;"
	db  "a=1.;"
	db  "b=max(8.9-t,0.);"
	db  "if(t>=60.)b+=max(68.5-t,0.)+max(t-83.,0.)",0
shaders_vertex2: ; Slow & steady
	db  "0,4.-t*.35,0);" ; e=vec3(
	db  "a1=0.;"
	db  "a2=sin(t*.7)*2.;"
	db  "a3=cos(t*.4)*.3;"
	db  "er=34.-t*1.1;"
	db  "a=1.;"
	db  "b=pow(max(min(t-15.5,1.),0.)-max(min(t-16.5,1.),0.),2.)",0
shaders_vertex3: ; Really sick fast angle :D haha
	db  "0);" ; e=vec3(
	db  "a1=cos(t*.32)*.2;"
	db  "a2=sin(t*.7)*.3-t;"
	db  "a3=cos(t*1.1)*.4;"
	db  "er=11.+sin(t*1.3)*3.;"
	db  "a=1.-max((t-130.)*.5,0.);"
	db  "b=max(9.-t,0.)",0
shaders_vertex4: ; A bit slower but same as above :)
	db  "0,-2.,0);" ; e=vec3(
	db  "a1=cos(t*.36)*.2;"
	db  "a2=sin(t*.6)*.3+t*.4;"
	db  "a3=cos(t)*.4;"
	db  "er=11.+sin(t*1.4)*3.;"
	db  "b=max(9.-t,0.);"
	db  "if(t>=46.1)if(t<48.1){"
	db   "b=(1.-fract((t-46.1)/.4))*.5;"
	db   "if(t>=47.4)b=.3+sin((t-47.4)*5.)*.3;"
	db   "t=42.23+b*1.6;"
	db  "}"
	db  "if(t>=47.4){b+=max((49.4-t)*.5,0.)+pow(1.-max((50.-t)*.3,0.),2.)*.7;t+=1.;}"
	db  "a=1.",0
shaders_vertex5: ; Epic Awesomesauce
	db  "0);" ; e=vec3(
	db  "a1=sin(t*.08)*.2;"
	db  "a2=sin(t*.3)*.3-t*.1;"
	db  "a3=cos(t*.26)*.4;"
	db  "er=16.+sin(t*.2)*3.;"
	db  "a=1.6;"
	db  "b=pow(1.-min((t-50.)*.12,1.)+max(t-66.5,0.),3.)*.7",0
shaders_fragment0: ; Opening Sphere
	db  "return min(length(p)-4." ; Sphere
	db  ",max(length(p)-4.15,p.y+max(t-12.39,0.)*1.4-4.15+min(max(t-9.6,0.)*.9,4.15)))",0 ; Shell
shaders_fragment1: ; Opening Sphere pump
	db  "s=4.+pow(1.-fract((t-12.3)*1.9),4.);"
	db  "return min(length(p)-s" ; Sphere
	db  ",max(length(p)-(s+.15),p.y+max(t-12.38,0.)*1.4-(s+.15)+min(max(t-9.6,0.)*.9,s+.15)))",0 ; Shell
shaders_fragment2: ; Opening Sphere pump double time
	db  "s=4.+pow(1.-fract((t-12.3)*3.8),4.);"
	db  "return min(length(p)-s" ; Sphere
	db  ",max(length(p)-(s+.15),p.y+max(t-12.38,0.)*1.4-(s+.15)+min(max(t-9.6,0.)*.9,s+.15)))",0 ; Shell
shaders_fragment3: ; Opening Sphere pump quad time
	db  "s=4.+pow(1.-fract((t-12.3)*7.6),4.);"
	db  "return min(length(p)-s" ; Sphere
	db  ",max(length(p)-(s+.15),p.y+max(t-12.38,0.)*1.4-(s+.15)+min(max(t-9.6,0.)*.9,s+.15)))",0 ; Shell
shaders_fragment4: ; Cube
	db  "q=pow(min(max((25.-t)*.2,0.),1.),3.)*30.;"
	db  "float r=pow(1.-min(max((t-28.)*.5,0.),1.),2.);"
	db  "s=max(length(p.xz)-7.5,p.y+q+4.);" ; "Stage"
	db  "return mix(min(max(max(abs(p.x)-4.,max(abs(p.y)-4.,abs(p.z)-4.))," ; Cube
	db  "sin(length(p)+5.6-.7*(1.-pow(min(max((22.8-t)*.5,0.),1.),2.))*3.))," ; Cutout
	db  "s),s,pow(1.-min(max((28.-t)*.2,0.),1.),3.))",0
shaders_fragment5: ; Bouncy Ball
	db  "s=length(p.xz);"
	db  "float r=pow(1.-min(max((t-28.)*.5,0.),1.),2.),u=pow(1.-s/7.5,2.)*3.5*(1.-r)*(max(abs(cos(t*3.6)),.9)-.9)*8.;"
	db  "s=max(s-7.5,p.y+u+4.);" ; "Stage"
	db  "return min(s,length(p-vec3(0,abs(sin(t*3.6))*10.*pow(1.-r,10.)+30.*r-5.5,0))-3.)",0 ; Bouncy Ball
shaders_fragment6: ; Breakage
	db  "q=pow(1.-min((t-49.8)*1.8,1.),2.);"
	db  "s=length(p.xz);"
	db  "return mix(mix(length(vec2(length(vec2(p.xy))-4.,p.z))-2.,max(abs(p.x)-4.,max(abs(p.y)-4.,abs(p.z)-4.)),cos(t*.4)*.5+.5)+n1(vec3(int(p.x),int(p.y),int(p.z))*.75)*.2*pow(1.-fract((t-12.3)*1.9),4.)," ; ???
	db  "min(length(p-vec3(0,q*10.-sin(t*2.)*pow(1.-min((t-52.)*.4,1.),2.),0))-4.,max(s-11.,p.y)+sin(s-t)*.2*(1.-q)+3.)+n1(vec3(int(p.x),int(p.y),int(p.z))*.75)*.1*pow(1.-q,77.),min(max((82.5-t)*.08,0.),1.))",0
sn_glCreateProgram: ; Names of shader procs
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
    db "glUseProgram"
%ifdef _4K_DIAGNOSTICS_
	db 0
sn_glGetShaderInfoLog:
	db "glGetShaderInfoLog",0
%endif
%endif
%ifdef _4K_DIAGNOSTICS_
	db 0
dg_title:
	db "Diagnostic Update",0
dg_resize:
	db "Screen resized successfully.",0
dg_wcreate:
	db "Window created successfully.",0
dg_fcreate:
	db "Font created successfully.",0
dg_spcreate:
	db "Shader program created successfully.",0
dg_intro:
	db "Intro initialized successfully.",0
%endif
