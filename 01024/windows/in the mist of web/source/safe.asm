;-----------------------------------------------;
;"In the mist of web" (safe version)            ;
;Intro written by Tyler Durden in 2005          ;
;Compiled with FasmW v.1.58 (flatassembler.net) ;
;-----------------------------------------------;
;website: http://www.tylerdurden.net.ru/        ;
;email: webmist@tylerdurden.net.ru              ;
;-----------------------------------------------;
screenWidth=1024
screenHeight=768
screenWidthDouble equ 1024.0f
screenHeightDouble equ 768.0f
format pe gui 4.0
entry start
include '%fasminc%\win32a.inc'
include 'include\opengl_const.inc'
include 'include\opengl_macros.inc'
include 'include\ext.inc'
start:
xor ebx,ebx
invoke ShowCursor,ebx
mov [dmScreenSettings.dmSize],dmScreenSettings_size
mov [dmScreenSettings.dmPelsWidth],screenWidth
mov [dmScreenSettings.dmPelsHeight],screenHeight
mov [dmScreenSettings.dmFields],DM_PELSWIDTH+DM_PELSHEIGHT
invoke ChangeDisplaySettings,dmScreenSettings,ebx
invoke CreateWindowEx,WS_EX_TOPMOST,szClass,ebx,WS_VISIBLE+WS_POPUP,ebx,ebx,screenWidth,screenHeight,ebx,ebx,ebx,ebx
screenHeight=468
screenHeightDouble equ 468.0f
invoke GetDC,eax
xchg ebp,eax
invoke wglChoosePixelFormat,ebp,esp,sizeof.PIXELFORMATDESCRIPTOR+10000h,PFD_DRAW_TO_WINDOW+PFD_SUPPORT_OPENGL+PFD_DOUBLEBUFFER,PFD_TYPE_RGBA+2000h,ebx,ebx,ebx,PFD_MAIN_PLANE shl 16,ebx,ebx,ebx
invoke SetPixelFormat,ebp,eax,esp
add esp,sizeof.PIXELFORMATDESCRIPTOR
invoke wglCreateContext,ebp
invoke wglMakeCurrent,ebp,eax
invoke glEnable,GL_BLEND
invoke glHint,GL_PERSPECTIVE_CORRECTION_HINT,GL_NICEST
invoke glTexImage2D,GL_TEXTURE_2D,ebx,1,[esp],textureBlurSize,ebx,GL_LUMINANCE_ALPHA,GL_UNSIGNED_BYTE,textureBlur
invoke glTexParameteri,GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR
invoke glEnable,GL_LINE_SMOOTH
invoke glHint,GL_LINE_SMOOTH_HINT,GL_NICEST
invoke glInterleavedArrays,GL_C3F_V3F,ebx,stars
invoke glMatrixMode,GL_PROJECTION
glcall glFrustum,-0.104f,0.104f,-0.058f,0.058f,0.1f,100.0f
invoke glMatrixMode,GL_MODELVIEW
mov ecx,starsCount
mov edx,stars
.starsGenerate:
call random
fstp dword [edx+4*3]
call random
fstp dword [edx+4*3+4]
call random
fstp dword [edx+4*3+4+4]
add edx,4*6
loop .starsGenerate
.draw:
invoke GetTickCount
cmp eax,[msec]
jz .draw
mov [msec],eax
invoke glClear,GL_COLOR_BUFFER_BIT
invoke glLoadIdentity
invoke glTranslatef,ebx,ebx,-4.0
invoke glRotatef,[theta],ebx,ebx,1.0
invoke glViewport,ebx,ebx,[esp],textureBlurSize
call renderMotionBlur
invoke glDrawArrays,GL_LINES,ebx,starsCount
invoke glViewport,ebx,150,screenWidth,screenHeight
invoke glCopyTexImage2D,GL_TEXTURE_2D,ebx,GL_RGB,ebx,ebx,[esp],textureBlurSize,ebx
invoke glClear,GL_COLOR_BUFFER_BIT
call renderMotionBlur
invoke glLoadIdentity
invoke glEnable,GL_TEXTURE_2D
invoke glBlendFunc,GL_ONE,GL_DST_COLOR
invoke glTranslatef,2.055,-1.67,-3.0
invoke glBegin,GL_QUADS
invoke glTexCoord2f,ebx,1.0
invoke glVertex2f,ebx,ebx
invoke glTexCoord2f,ebx,ebx
invoke glVertex2f,ebx,0.9
invoke glTexCoord2f,1.0,ebx
invoke glVertex2f,1.0,0.9
invoke glTexCoord2f,[esp],1.0
invoke glVertex2f,1.0,ebx
invoke glEnd
invoke glDisable,GL_TEXTURE_2D
invoke glBlendFunc,GL_SRC_ALPHA,GL_ONE
invoke glColor4f,[esp],[esp],1.0,0.2
invoke glBegin,GL_LINES
invoke glVertex2f,ebx,ebx
invoke glVertex2f,ebx,0.9
invoke glVertex2f,ebx,0.9
invoke glVertex2f,1.0,0.9
invoke glVertex2f,1.0,0.9
invoke glVertex2f,1.0,ebx
invoke glVertex2f,1.0,ebx
invoke glVertex2f,ebx,ebx
invoke glEnd
invoke SwapBuffers,ebp
mov ecx,starsCount
mov edx,stars
.starsMove:
fld dword [edx+4*3+4+4]
fadd dword [zDelta]
fst dword [edx+4*3+4+4]
cmp dword [edx+4*3+4+4],4.0
jl .notZOverflow
mov dword [edx+4*3+4+4],-1.0
.notZOverflow:
fmul [colorMul]
fst dword [edx]
fst dword [edx+4]
fstp dword [edx+4+4]
add edx,6*4
loop .starsMove
fld [theta]
fadd [delta]
fstp [theta]
invoke GetAsyncKeyState,VK_ESCAPE
test eax,eax
jz .draw
invoke ChangeDisplaySettings,ebx,ebx
invoke ExitProcess,ebx
renderMotionBlur:
invoke glPushMatrix
invoke glEnable,GL_TEXTURE_2D
invoke glMatrixMode,GL_PROJECTION
invoke glPushMatrix
invoke glLoadIdentity
glcall glOrtho,0.0,screenWidthDouble,screenHeightDouble,0.0,-1.0,1.0
invoke glMatrixMode,GL_MODELVIEW
invoke glLoadIdentity
invoke glColor4f,[esp],[esp],1.0,0.86
invoke glBegin,GL_QUADS
invoke glTexCoord2f,ebx,1.0
invoke glVertex2i,ebx,ebx
invoke glTexCoord2f,ebx,ebx
invoke glVertex2i,ebx,screenHeight
invoke glTexCoord2f,1.0,ebx
invoke glVertex2i,screenWidth,screenHeight
invoke glTexCoord2f,[esp],1.0
invoke glVertex2i,screenWidth,ebx
invoke glEnd
invoke glMatrixMode,GL_PROJECTION
invoke glPopMatrix
invoke glMatrixMode,GL_MODELVIEW
invoke glPopMatrix
invoke glDisable,GL_TEXTURE_2D
retn
random:
mov eax,[randomSeed]
add eax,ecx
xor al,ah
bswap eax
mov [randomSeed],eax
fild [randomSeed]
fmul [xMul]
retn
textureBlurSize=512
starsCount=2300
delta dd 0.3
zDelta dd 0.02
colorMul dd 0.02
xMul dd 0.000000001
szClass db 'edit',0
data import
include 'include\imports_safe.inc'
end data
randomSeed dd ?
msec dd ?
theta dd ?
dmScreenSettings DEVMODE
dmScreenSettings_size=$-dmScreenSettings
pfd PIXELFORMATDESCRIPTOR
align 32
stars rd 6*starsCount
align 32
textureBlur rd textureBlurSize*textureBlurSize