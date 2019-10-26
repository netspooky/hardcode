; Thinner - Win32/GLSL version
; Mic, 2008

; Compile with masm32:
;  ml /c /coff thinnerw.asm
;  link /SUBSYSTEM:WINDOWS thinnerw.obj

.686p
.model flat,stdcall
option casemap:none


include \masm32\include\windows.inc
include \masm32\include\kernel32.inc
include \masm32\include\user32.inc
include \masm32\include\gdi32.inc
include \masm32\include\opengl32.inc

includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\user32.lib
includelib \masm32\lib\gdi32.lib
includelib \masm32\lib\opengl32.lib

GL_FRAGMENT_SHADER 	equ 8B30h
DEBUG_SHADER		equ 0

LARGE_INT STRUCT
	UNION
		STRUCT
			LowPart dd ?
			HighPart dd ?
		ENDS
		QuadPart dq ?
	ENDS
LARGE_INT ENDS

.data

szEdit db 'edit',0

szFragShader label byte
db 'uniform float a,b,c;'
db 'const float g=0.0245436926;'
db 'unsigned int m;'
db 'void main() {'
db 'float d,e,f,h,i;'
db 'e=320*(gl_FragCoord.x/1024);'
db 'f=200*(gl_FragCoord.y/768);'
db 'float p=sqrt(((160-e)*(160-e))+((100-f)*(100-f)));'
db 'd=sin((e-1)*g)*208.0+sin((e-1)*g*2)*124.0;'
db 'd+=f+a-e+p/8;'
db 'h=(((f-(c+c-d))+e)-b)*g;'
db 'i=sin(h+p/9)*208.0+sin(h+h)*124.0;'
db 'h=((b+f)-((e+c)*2))*g;'
db 'i+=sin(h)*208.0+sin(h+h)*124.0;'
db 'h=sin(e*g)*208.0+sin(e*g*2)*124.0;'
db 'h=(h+f+a-e+i/8)*g;'
db 'i+=sin(h)*208.0+sin(h+h)*124.0;'
db 'm=floor(i);m/=8;m=mod(float(m),256.0);i=float(m);'
db 'if (i<128.0)'
db ' gl_FragColor=vec4(clamp(i/64,0.0,1.0),i/128,clamp((i/64)-1.0,0.0,1.0),1.0);'
db 'else{'
db 'i=256-i;'
db 'gl_FragColor=vec4(clamp((i/64)-1.0,0.0,1.0),i/128,clamp(i/64,0.0,1.0),1.0);'
db '}}',0

szShaderCode dd offset szFragShader,0

szCreateProgram	db 'glCreateProgram',0
szCreateShader 	db 'glCreateShader',0
szDeleteProgram	db 'glDeleteProgram',0
szDeleteShader 	db 'glDeleteShader',0
szShaderSource	db 'glShaderSource',0
szCompileShader db 'glCompileShader',0
szAttachShader 	db 'glAttachShader',0
szLinkProgram 	db 'glLinkProgram',0
szUseProgram 	db 'glUseProgram',0
szGetUniformLoc db 'glGetUniformLocation',0
szUniform1f 	db 'glUniform1f',0
IF DEBUG_SHADER EQ 1
szGetInfoLog	db 'glGetShaderInfoLog',0
ENDIF
szA		db 'a',0
szB		db 'b',0
szC		db 'c',0
deltaMul	dw 30		; This variable control movement speed

quadCoords	REAL4 -1.0,-1.0, 1.0,-1.0, 1.0,1.0, -1.0,1.0
		
.data?


pfd PIXELFORMATDESCRIPTOR <>
dmScreenSettings DEVMODE <>
msg		MSG <>
perfCnt1	LARGE_INT <>
perfCnt2	LARGE_INT <>
perfFreq	LARGE_INT <>
hdc 		HDC ?
program 	dd ?
shader 		dd ?
glGetUniformLocation dd ?
glUniform1f 	dd ?
delta1 		dd ?
delta2 		dd ?
delta3 		dd ?
unfD1		dd ?
unfD2		dd ?
unfD3		dd ?

IF DEBUG_SHADER EQ 1
stdout 		dd ?
dummy 		dd ?
szBuffer 	db 512 dup (?)
ENDIF


.code


WinMainCRTStartup:

mov edi,offset pfd
mov ecx,sizeof PIXELFORMATDESCRIPTOR
xor eax,eax
rep stosb
mov pfd.nVersion,1
mov pfd.dwFlags,PFD_SUPPORT_OPENGL OR PFD_DOUBLEBUFFER OR PFD_DRAW_TO_WINDOW
mov pfd.cColorBits,32
mov pfd.cDepthBits,32
mov pfd.dwLayerMask,PFD_MAIN_PLANE
mov pfd.iPixelType,PFD_TYPE_RGBA
 
mov edi,offset dmScreenSettings
mov ecx,sizeof DEVMODE
xor eax,eax
rep stosb
mov dmScreenSettings.dmSize, sizeof DEVMODE
mov dmScreenSettings.dmFields,DM_PELSWIDTH OR DM_PELSHEIGHT
mov dmScreenSettings.dmPelsWidth,1024
mov dmScreenSettings.dmPelsHeight,768

;invoke ChangeDisplaySettings,ADDR dmScreenSettings,CDS_FULLSCREEN
invoke CreateWindowEx,0,ADDR szEdit,0,WS_POPUP OR WS_VISIBLE OR WS_MAXIMIZE,0,0,1024,768,0,0,0,0
invoke GetDC,eax
mov hdc,eax
invoke ChoosePixelFormat,hdc,ADDR pfd
invoke SetPixelFormat,hdc,eax,ADDR pfd
invoke wglCreateContext,hdc
invoke wglMakeCurrent,hdc,eax
invoke ShowCursor,0

IF DEBUG_SHADER EQ 1
invoke AllocConsole
invoke GetStdHandle,STD_OUTPUT_HANDLE
mov stdout,eax
ENDIF

invoke wglGetProcAddress,ADDR szCreateProgram
call eax
mov program,eax

invoke wglGetProcAddress,ADDR szCreateShader
mov ebx,GL_FRAGMENT_SHADER
push ebx
call eax
mov shader,eax

invoke wglGetProcAddress,ADDR szShaderSource
xor ebx,ebx
push ebx
push offset szShaderCode
inc ebx
push ebx
push shader
call eax

invoke wglGetProcAddress,ADDR szCompileShader
push shader
call eax

IF DEBUG_SHADER EQ 1
invoke wglGetProcAddress,ADDR szGetInfoLog
push offset szBuffer
xor ebx,ebx
push ebx
mov ebx,512
push ebx
push shader
call eax
invoke lstrlen,ADDR szBuffer
invoke WriteConsole,stdout,ADDR szBuffer,eax,ADDR dummy,NULL
ENDIF

invoke wglGetProcAddress,ADDR szAttachShader
push shader
push program
call eax

invoke wglGetProcAddress,ADDR szLinkProgram
push program
call eax

invoke wglGetProcAddress,ADDR szGetUniformLoc
mov glGetUniformLocation,eax
push offset szA
push program
call eax
mov unfD1,eax

mov eax,glGetUniformLocation
push offset szB
push program
call eax
mov unfD1,eax

mov eax,glGetUniformLocation
push offset szC
push program
call eax
mov unfD3,eax

invoke wglGetProcAddress,ADDR szUniform1f
mov glUniform1f,eax

; Get starting time and frequency
invoke QueryPerformanceCounter,ADDR perfCnt1
invoke QueryPerformanceFrequency,ADDR perfFreq

invoke wglGetProcAddress,ADDR szUseProgram
push program
call eax

@@forever:

	invoke glBegin,GL_QUADS
	
	invoke glVertex2fv,ADDR quadCoords
	invoke glVertex2fv,ADDR quadCoords+8
	invoke glVertex2fv,ADDR quadCoords+16
	invoke glVertex2fv,ADDR quadCoords+24
	
	invoke glEnd
	
	; Update the plasma movement deltas
	invoke QueryPerformanceCounter,ADDR perfCnt2
	fild qword ptr perfCnt2.QuadPart
	fild qword ptr perfCnt1.QuadPart
	fsubp st(1),st(0)
	fild qword ptr perfFreq.QuadPart
	fdivp st(1),st(0)
	fimul word ptr deltaMul
	fld st(0)
	fld dword ptr delta1
	faddp st(1),st(0)
	fstp dword ptr delta1
	fchs
	fld st(0)
	fld dword ptr delta2
	faddp st(1),st(0)
	fstp dword ptr delta2
	fld dword ptr delta3
	faddp st(1),st(0)
	fstp dword ptr delta3
	push perfCnt2.LowPart
	pop perfCnt1.LowPart
	push perfCnt2.HighPart
	pop perfCnt1.HighPart

	push delta1
	push unfD1
	mov ebx,glUniform1f
	call ebx

	push delta2
	push unfD2
	mov ebx,glUniform1f
	call ebx

	push delta3
	push unfD3
	mov ebx,glUniform1f
	call ebx
	
	invoke SwapBuffers,hdc
	invoke GetAsyncKeyState,VK_ESCAPE
	test eax,eax
	jz @@forever


invoke wglGetProcAddress,ADDR szDeleteShader
push shader
call eax

invoke wglGetProcAddress,ADDR szDeleteProgram
push program
call eax

invoke ExitProcess,0

END WinMainCRTStartup

