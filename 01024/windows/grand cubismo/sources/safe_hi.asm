screenWidth=640
screenHeight=480
screenWidthDouble equ 640.0f
screenHeightDouble equ 480.0f
textureSize equ 16
format PE GUI 4.0
entry start
include '%fasminc%\win32a.inc'
include 'include\opengl_const.inc'
include 'include\opengl_macros.inc'
include 'include\ext.inc'
start:
xor ebx,ebx
mov edi,textureCell
mov eax,0ff0046ffh
mov ecx,textureSize*textureSize*4
rep stosd
mov eax,0ffffffffh
mov edi,textureCell
mov ecx,textureSize*2
rep stosd
mov edi,textureCell
mov ecx,textureSize
.drawCell:
stosd
add edi,(textureSize-1)*4
loop .drawCell
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
mov [pfd.dwFlags],PFD_DRAW_TO_WINDOW+PFD_SUPPORT_OPENGL+PFD_DOUBLEBUFFER
mov [pfd.iPixelType],PFD_TYPE_RGBA
mov [pfd.cColorBits],32
mov [pfd.dwLayerMask],PFD_MAIN_PLANE
invoke ChoosePixelFormat,ebp,pfd
invoke SetPixelFormat,ebp,eax,pfd
invoke wglCreateContext,ebp
invoke wglMakeCurrent,ebp,eax
invoke glBlendFunc,GL_SRC_ALPHA,GL_ONE
invoke glEnable,GL_BLEND
invoke glEnable,GL_TEXTURE_2D
invoke glEnable,GL_LINE_SMOOTH
invoke CreateFont,-10,ebx,ebx,ebx,ebx,ebx,ebx,ebx,ebx,ebx,ebx,ebx,ebx,fontName
invoke SelectObject,ebp,eax
invoke wglUseFontBitmapsA,ebp,ebx,256,ebx
invoke glTexImage2D,GL_TEXTURE_2D,ebx,4,textureSize,textureSize,ebx,GL_RGBA,GL_UNSIGNED_BYTE,textureCell
invoke glTexParameteri,GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR
invoke glHint,GL_LINE_SMOOTH_HINT,GL_NICEST
invoke glInterleavedArrays,GL_T2F_V3F,ebx,mdlCrystal
invoke glViewport,ebx,77,screenWidth,screenHeight
mov ecx,10
.fill:
fld [theta]
fadd [delta2]
fst [theta]
fstp [theta+ecx*4-4]
loop .fill
.draw:
invoke GetTickCount
cmp eax,[msec]
jz .draw
mov [msec],eax
invoke glClear,GL_COLOR_BUFFER_BIT+GL_DEPTH_BUFFER_BIT
invoke glMatrixMode,GL_PROJECTION
invoke glLoadIdentity
glcall glFrustum,-0.114f,0.114f,-0.058f,0.058f,0.1f,100.0f
invoke glMatrixMode,GL_MODELVIEW
invoke glTranslatef,ebx,0.0,-1.0
invoke glRotatef,[theta],1.0,-1.0,1.0
call drawCubes
invoke glLoadIdentity
invoke glTranslatef,ebx,0.0,-7.0
invoke glRotatef,[theta],1.0,1.0,1.0
call drawCubes
invoke glMatrixMode,GL_PROJECTION
invoke glLoadIdentity
glcall glOrtho,0.0,screenWidthDouble,screenHeightDouble,0.0,-1.0,1.0
invoke glMatrixMode,GL_MODELVIEW
invoke glLoadIdentity
invoke glPolygonMode,GL_FRONT,GL_FILL
invoke glColor4f,[esp],[esp],1.0,0.15
invoke glBegin,GL_QUADS
invoke glTexCoord2i,ebx,200
invoke glVertex2i,ebx,ebx
invoke glTexCoord2i,ebx,ebx
invoke glVertex2i,ebx,screenHeight
invoke glTexCoord2i,400,ebx
invoke glVertex2i,screenWidth,screenHeight
invoke glTexCoord2i,400,200
invoke glVertex2i,screenWidth,ebx
invoke glEnd
invoke glColor4f,[esp],[esp],1.0,0.5
invoke glRasterPos2i,395,315
invoke glCallLists,title.size,GL_UNSIGNED_BYTE,title
invoke SwapBuffers,ebp
invoke GetAsyncKeyState,VK_ESCAPE
test eax,eax
jz .draw
invoke ChangeDisplaySettings,ebx,ebx
invoke ExitProcess,ebx
drawCubes:
mov esi,10
.loop:
invoke glRotatef,[theta+esi*4-4],1.0,-1.0,1.0
invoke glTranslatef,ebx,1.0,ebx
fld [theta+esi*4-4]
fadd [delta]
fstp [theta+esi*4-4]
invoke glPolygonMode,GL_BACK,GL_FILL
invoke glColor4f,1.0,0.9,ebx,0.15
invoke glDrawArrays,GL_QUADS,ebx,mdlCrystal.vertexes
invoke glPolygonMode,GL_FRONT_AND_BACK,GL_LINE
invoke glColor4f,[esp],[esp],1.0,0.2
invoke glDrawArrays,GL_QUADS,ebx,mdlCrystal.vertexes
invoke glTranslatef,ebx,-1.0,ebx
dec esi
jnz .loop
retn
title db 'grand cubismo - 1k intro by tyler durden'
.size=$-title
fontName db 'verdana',0
delta dd 0.136
delta2 dd 123.1415
szClass db 'edit',0
mdlCrystal dd 1.0,0.0,-1.0,-3.0,1.0,0.0,0.0,1.0,-3.0,1.0,0.0,1.0,1.0,1.0,1.0,1.0,1.0,-1.0,1.0,1.0,0.0,0.0,-1.0,-3.0,-1.0,0.0,1.0,-1.0,1.0,-1.0,1.0,1.0,1.0,1.0,-1.0,1.0,0.0,1.0,-3.0,-1.0,1.0,0.5,-1.0,1.0,-1.0,1.0,0.0,-1.0,1.0,1.0,0.0,0.0,1.0,1.0,1.0,0.0,0.5,1.0,1.0,-1.0,0.0,0.5,-1.0,-3.0,-1.0,1.0,0.5,1.0,-3.0,-1.0,1.0,0.0,1.0,-3.0,1.0,0.0,0.0,-1.0,-3.0,1.0,0.0,0.0,1.0,-3.0,-1.0,0.0,1.0,1.0,1.0,-1.0,1.0,1.0,1.0,1.0,1.0,1.0,0.0,1.0,-3.0,1.0,1.0,0.0,-1.0,-3.0,-1.0,0.0,0.0,-1.0,-3.0,1.0,0.0,1.0,-1.0,1.0,1.0,1.0,1.0,-1.0,1.0,-1.0
.vertexes=24
data import
include 'include\imports_safe.inc'
end data
msec dd ?
ratio dq ?
pfd PIXELFORMATDESCRIPTOR
dmScreenSettings DEVMODE
dmScreenSettings_size=$-dmScreenSettings
theta rd 10
textureCell rd 4*textureSize*textureSize