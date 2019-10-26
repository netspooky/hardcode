;----------------------------------------------;
;"God put a smile upon your face" Safe version ;
;Intro written by Tyler Durden in 2004         ;
;Compiled with FasmW v.1.52 (flatassembler.net);
;----------------------------------------------;
;website: http://www.tylerdurden.net.ru/       ;
;email: smile@tylerdurden.net.ru               ;
;----------------------------------------------;
screenWidth=640
screenHeight=480
screenWidthDouble equ 640.0f
screenHeightDouble equ 480.0f
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
screenHeight=325
screenHeightDouble equ 325.0f
invoke GetDC,eax
xchg ebp,eax
invoke wglChoosePixelFormat,ebp,esp,sizeof.PIXELFORMATDESCRIPTOR+10000h,PFD_DRAW_TO_WINDOW+PFD_SUPPORT_OPENGL+PFD_DOUBLEBUFFER,PFD_TYPE_RGBA+2000h,ebx,ebx,ebx,PFD_MAIN_PLANE shl 16,ebx,ebx,ebx
invoke SetPixelFormat,ebp,eax,esp
add esp,sizeof.PIXELFORMATDESCRIPTOR
invoke wglCreateContext,ebp
invoke wglMakeCurrent,ebp,eax
invoke glEnable,GL_LIGHT0
invoke glBlendFunc,GL_SRC_ALPHA,GL_ONE
invoke glEnable,GL_BLEND
invoke glEnable,GL_COLOR_MATERIAL
invoke glBindTexture,GL_TEXTURE_2D,1
invoke glTexImage2D,GL_TEXTURE_2D,ebx,3,blurSize,blurSize,ebx,GL_RGB,GL_UNSIGNED_BYTE,textureBlank
invoke glTexParameteri,GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR
invoke glBindTexture,GL_TEXTURE_2D,2
invoke glTexImage2D,GL_TEXTURE_2D,ebx,3,32,16,ebx,GL_RGB,GL_UNSIGNED_BYTE,start
invoke glTexParameteri,GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR
invoke glTexGeni,GL_S,GL_TEXTURE_GEN_MODE,GL_SPHERE_MAP
invoke glTexGeni,GL_T,GL_TEXTURE_GEN_MODE,GL_SPHERE_MAP
invoke glEnable,GL_TEXTURE_2D
invoke CreateFont,ebx,ebx,ebx,ebx,ebx,ebx,ebx,ebx,SYMBOL_CHARSET,ebx,ebx,ebx,ebx,fontName
invoke SelectObject,ebp,eax
invoke wglUseFontOutlinesA,ebp,4ah,1,ebp,0.02f,0.2f,1,ebx
invoke glHint,GL_PERSPECTIVE_CORRECTION_HINT,GL_NICEST
invoke glMatrixMode,GL_PROJECTION
glcall glFrustum,-0.114f,0.114f,-0.058f,0.058f,0.1f,100.0f
.draw:
invoke GetTickCount
cmp eax,[msec]
jz .draw
mov [msec],eax
invoke glClear,GL_COLOR_BUFFER_BIT
invoke glMatrixMode,GL_MODELVIEW
invoke glLoadIdentity
invoke glColor4f,0.8f,0.4f,ebx,1.0f
invoke glTranslatef,ebx,ebx,-0.7f
invoke glRotatef,[theta],1.0f,ebx,ebx
invoke glRotatef,[theta],ebx,[esp],1.0f
invoke glRotatef,[theta],ebx,ebx,1.0f
invoke glTranslatef,-0.37f,-0.32f,0.1f
invoke glViewport,ebx,ebx,[esp],blurSize
invoke glBindTexture,GL_TEXTURE_2D,2
invoke glCallList,ebp
invoke glBindTexture,GL_TEXTURE_2D,1
invoke glCopyTexImage2D,GL_TEXTURE_2D,ebx,GL_RGB,ebx,ebx,[esp],blurSize,ebx
invoke glClear,GL_COLOR_BUFFER_BIT
invoke glViewport,ebx,77,screenWidth,screenHeight
invoke glBindTexture,GL_TEXTURE_2D,2
invoke glDisable,GL_LIGHTING
invoke glDisable,GL_TEXTURE_GEN_S
invoke glDisable,GL_TEXTURE_GEN_T
invoke glMatrixMode,GL_PROJECTION
invoke glPushMatrix
invoke glLoadIdentity
glcall glOrtho,0.0f,screenWidthDouble,screenHeightDouble,0.0f,-1.0f,1.0f
invoke glMatrixMode,GL_MODELVIEW
call dword [glLoadIdentity]
invoke glBindTexture,GL_TEXTURE_2D,1
mov ecx,blurCount
mov dword [blurInc],ebx
mov dword [blurDec],1.0f
mov dword [blurAlpha],0.35f
.renderMotionBlur:
push ecx
fld dword [blurDelta]
fld st0
fadd dword [blurInc]
fstp dword [blurInc]
fsubr dword [blurDec]
fstp dword [blurDec]
fld dword [blurAlpha]
fsub dword [alphaDelta]
fstp dword [blurAlpha]
invoke glColor4f,[esp],[esp],1.0f,[blurAlpha]
invoke glBegin,GL_QUADS
invoke glTexCoord2f,[blurInc],[blurDec]
invoke glVertex2i,ebx,ebx
invoke glTexCoord2f,[esp],[blurInc]
invoke glVertex2i,ebx,screenHeight
invoke glTexCoord2f,[blurDec],[blurInc]
invoke glVertex2i,screenWidth,screenHeight
invoke glTexCoord2f,[esp],[blurDec]
invoke glVertex2i,screenWidth,ebx
invoke glEnd
pop ecx
dec ecx
jnz .renderMotionBlur
invoke glMatrixMode,GL_PROJECTION
invoke glPopMatrix
invoke glEnable,GL_TEXTURE_GEN_S
invoke glEnable,GL_TEXTURE_GEN_T
invoke glEnable,GL_LIGHTING
invoke wglSwapBuffers,ebp
fld dword [theta]
fadd dword [delta]
fstp dword [theta]
invoke GetAsyncKeyState,VK_ESCAPE
test eax,eax
jz .draw
invoke ChangeDisplaySettings,ebx,ebx
invoke ExitProcess,ebx
blurCount=25
blurSize=256
fontName db 'wingdings',0
szClass db 'edit',0
data import
include 'include\imports_safe.inc'
end data
blurDelta dd 0.01f
alphaDelta dd 0.013f
delta dd 1.0f
blurInc dd ?
blurDec dd ?
blurAlpha dd ?
msec dd ?
theta dd ?
dmScreenSettings DEVMODE
dmScreenSettings_size=$-dmScreenSettings
textureBlank rd blurSize*blurSize