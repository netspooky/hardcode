;-----------------------------------------------;
;"In the mist of web" (windowsXP sp1 version)   ;
;Intro written by Tyler Durden in 2005          ;
;Compiled with FasmW v.1.58 (flatassembler.net) ;
;-----------------------------------------------;
;website: http://www.tylerdurden.net.ru/        ;
;email: webmist@tylerdurden.net.ru              ;
;-----------------------------------------------;
ofs_delta equ esi
ofs_zDelta equ esi+4
ofs_xMul equ esi+8
ofs_randomSeed equ esi+12+openglDll_length
ofs_theta equ esi+16+openglDll_length
screenWidth=1024
screenHeight=768
screenWidthDouble equ 1024.0f
screenHeightDouble equ 768.0f
format pe gui 4.0
entry start
include '%fasminc%\win32a.inc'
include 'include\opengl_const.inc'
include 'include\opengl_macros.inc'
include 'include\opengl_func.inc'
include 'include\xp_func.inc'
include 'include\ext.inc'
macro getProcAddresses {
local getAddress
call eax
xchg eax,esi
mov ebx,exportedFunctionCount
getAddress:
invoke GetProcAddress,esi,ebx
stosd
dec ebx
jnz getAddress
}
start:
mov ebx,[GetProcAddress]
.loadDlls:
cmp word [ebx],'MZ'
jz .loadOk
dec ebx
jmp .loadDlls
.loadOk:
mov edi,procAddr
push edi
invoke GetProcAddress,ebx,_LoadLibraryA
push eax
push eax
push openglDll
getProcAddresses
pop eax
push esi
add esi,user32Offset
push esi
getProcAddresses
pop esi
pop eax
add esi,gdi32Offset
push esi
getProcAddresses
pop edi
mov esi,delta
memcall _ShowCursor,ebx
mov [dmScreenSettings.dmSize],dmScreenSettings_size
mov [dmScreenSettings.dmPelsWidth],screenWidth
mov [dmScreenSettings.dmPelsHeight],screenHeight
mov [dmScreenSettings.dmFields],DM_PELSWIDTH+DM_PELSHEIGHT
memcall _ChangeDisplaySettingsA,dmScreenSettings,ebx
memcall _CreateWindowExA,WS_EX_TOPMOST,szClass,ebx,WS_VISIBLE+WS_POPUP,ebx,ebx,screenWidth,screenHeight,ebx,ebx,ebx,ebx
screenHeight=468
screenHeightDouble equ 468.0f
memcall _GetDC,eax
xchg ebp,eax
memcall _wglChoosePixelFormat,ebp,esp,sizeof.PIXELFORMATDESCRIPTOR+10000h,PFD_DRAW_TO_WINDOW+PFD_SUPPORT_OPENGL+PFD_DOUBLEBUFFER,PFD_TYPE_RGBA+2000h,ebx,ebx,ebx,PFD_MAIN_PLANE shl 16,ebx,ebx,ebx
memcall _SetPixelFormat,ebp,eax,esp
add esp,sizeof.PIXELFORMATDESCRIPTOR
memcall _wglCreateContext,ebp
memcall _wglMakeCurrent,ebp,eax
memcall _glTexImage2D,GL_TEXTURE_2D,ebx,1,[esp],textureBlurSize,ebx,GL_LUMINANCE_ALPHA,GL_UNSIGNED_BYTE,textureBlur
memcall _glTexParameteri,GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR
memcall _glEnable,GL_LINE_SMOOTH
memcall _glEnable,GL_BLEND
memcall _glHint,GL_PERSPECTIVE_CORRECTION_HINT,GL_NICEST
memcall _glHint,GL_LINE_SMOOTH_HINT,GL_NICEST
memcall _glMatrixMode,GL_PROJECTION
glcall _glFrustum,-0.104f,0.104f,-0.058f,0.058f,0.1f,100.0f
memcall _glMatrixMode,GL_MODELVIEW
memcall _glInterleavedArrays,GL_C3F_V3F,ebx,stars
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
memcall _glClear,GL_COLOR_BUFFER_BIT
memcall _glLoadIdentity
memcall _glTranslatef,ebx,ebx,-4.0
memcall _glRotatef,[ofs_theta],ebx,ebx,1.0
memcall _glViewport,ebx,ebx,[esp],textureBlurSize
call renderMotionBlur
memcall _glDrawArrays,GL_LINES,ebx,starsCount
memcall _glViewport,ebx,150,screenWidth,screenHeight
memcall _glCopyTexImage2D,GL_TEXTURE_2D,ebx,GL_RGB,ebx,ebx,[esp],textureBlurSize,ebx
memcall _glClear,GL_COLOR_BUFFER_BIT
call renderMotionBlur
memcall _glLoadIdentity
memcall _glEnable,GL_TEXTURE_2D
memcall _glBlendFunc,GL_ONE,GL_DST_COLOR
memcall _glTranslatef,2.055,-1.67,-3.0
memcall _glBegin,GL_QUADS
memcall _glTexCoord2f,ebx,1.0
memcall _glVertex2f,ebx,ebx
memcall _glTexCoord2f,ebx,ebx
memcall _glVertex2f,ebx,0.9
memcall _glTexCoord2f,1.0,ebx
memcall _glVertex2f,1.0,0.9
memcall _glTexCoord2f,[esp],1.0
memcall _glVertex2f,1.0,ebx
memcall _glEnd
memcall _glDisable,GL_TEXTURE_2D
memcall _glColor4f,[esp],[esp],1.0,0.2
memcall _glBlendFunc,GL_SRC_ALPHA,GL_ONE
memcall _glBegin,GL_LINES
memcall _glVertex2f,ebx,ebx
memcall _glVertex2f,ebx,0.9
memcall _glVertex2f,ebx,0.9
memcall _glVertex2f,1.0,0.9
memcall _glVertex2f,1.0,0.9
memcall _glVertex2f,1.0,ebx
memcall _glVertex2f,1.0,ebx
memcall _glVertex2f,ebx,ebx
memcall _glEnd
memcall _wglSwapBuffers,ebp
mov ecx,starsCount
mov edx,stars
.starsMove:
fld dword [edx+4*3+4+4]
fadd dword [ofs_zDelta]
fst dword [edx+4*3+4+4]
cmp dword [edx+4*3+4+4],4.0
jl .notZOverflow
mov dword [edx+4*3+4+4],-1.0
.notZOverflow:
fmul dword [ofs_zDelta]
fst dword [edx]
fst dword [edx+4]
fstp dword [edx+4+4]
add edx,6*4
loop .starsMove
fld dword [ofs_theta]
fadd dword [ofs_delta]
fstp dword [theta]
memcall _GetAsyncKeyState,VK_ESCAPE
test eax,eax
jz .draw
memcall _ChangeDisplaySettingsA,ebx,ebx
retn
renderMotionBlur:
memcall _glPushMatrix
memcall _glEnable,GL_TEXTURE_2D
memcall _glMatrixMode,GL_PROJECTION
memcall _glPushMatrix
memcall _glLoadIdentity
glcall _glOrtho,0.0,screenWidthDouble,screenHeightDouble,0.0,-1.0,1.0
memcall _glMatrixMode,GL_MODELVIEW
memcall _glLoadIdentity
memcall _glColor4f,[esp],[esp],1.0,0.86
memcall _glBegin,GL_QUADS
memcall _glTexCoord2f,ebx,1.0
memcall _glVertex2i,ebx,ebx
memcall _glTexCoord2f,ebx,ebx
memcall _glVertex2i,ebx,screenHeight
memcall _glTexCoord2f,1.0,ebx
memcall _glVertex2i,screenWidth,screenHeight
memcall _glTexCoord2f,[esp],1.0
memcall _glVertex2i,screenWidth,ebx
memcall _glEnd
memcall _glMatrixMode,GL_PROJECTION
memcall _glPopMatrix
memcall _glMatrixMode,GL_MODELVIEW
memcall _glPopMatrix
memcall _glDisable,GL_TEXTURE_2D
retn
random:
mov eax,[ofs_randomSeed]
add eax,ecx
xor al,ah
bswap eax
mov [ofs_randomSeed],eax
fild dword [ofs_randomSeed]
fmul dword [ofs_xMul]
retn
textureBlurSize=512
starsCount=2300
data import
include 'include\imports_xp.inc'
end data
szClass db 'edit',0
delta dd 0.3
zDelta dd 0.02
xMul dd 0.000000001
openglDll db 'opengl32',?
openglDll_length=$-openglDll
randomSeed dd ?
theta dd ?
dmScreenSettings DEVMODE
dmScreenSettings_size=$-dmScreenSettings
pfd PIXELFORMATDESCRIPTOR
align 32
stars rd 6*starsCount
align 32
textureBlur rd textureBlurSize*textureBlurSize
align 32
procAddr rd bytesForExport