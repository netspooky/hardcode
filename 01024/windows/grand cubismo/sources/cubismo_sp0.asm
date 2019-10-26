ofs_delta equ esi
ofs_delta2 equ esi+4
ofs_ratio equ esi+8
ofs_theta equ esi+12
screenWidth=640
screenHeight=480
screenWidthDouble equ 640.0f
screenHeightDouble equ 480.0f
textureSize equ 16
format PE GUI 4.0
entry start
include '%fasminc%\win32a.inc'
include 'include\opengl_macros.inc'
include 'include\opengl_const.inc'
include 'include\opengl_func.inc'
include 'include\xp_sp0_func.inc'
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
xor ebx,ebx
mov edi,textureCell
mov eax,0ff0046ffh
mov ecx,textureSize*textureSize*4
rep stosd
xor eax,eax
dec eax
mov edi,textureCell
mov ecx,textureSize*2
rep stosd
mov edi,textureCell
mov ecx,textureSize
.drawCell:
stosd
add edi,(textureSize-1)*4
loop .drawCell
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
screenHeight=325
screenHeightDouble equ 325.0f
memcall _GetDC,eax
xchg ebp,eax
memcall _SetPixelFormat,ebp,10,ebx
memcall _wglCreateContext,ebp
memcall _wglMakeCurrent,ebp,eax
memcall _glBlendFunc,GL_SRC_ALPHA,GL_ONE
memcall _glEnable,GL_BLEND
memcall _glEnable,GL_TEXTURE_2D
memcall _glEnable,GL_LINE_SMOOTH
memcall _CreateFontA,-10,ebx,ebx,ebx,ebx,ebx,ebx,ebx,ebx,ebx,ebx,ebx,ebx,fontName
memcall _SelectObjectA,ebp,eax
memcall _wglUseFontBitmapsA,ebp,ebx,256,ebx
memcall _glTexImage2D,GL_TEXTURE_2D,ebx,4,textureSize,textureSize,ebx,GL_RGBA,GL_UNSIGNED_BYTE,textureCell
memcall _glTexParameteri,GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR
memcall _glInterleavedArrays,GL_T2F_V3F,ebx,mdlCrystal
memcall _glViewport,ebx,77,screenWidth,screenHeight
mov ecx,10
.fill:
fld dword [ofs_theta]
fadd dword [ofs_delta2]
fst dword [ofs_theta]
fstp dword [ofs_theta+ecx*4-4]
loop .fill
.draw:
memcall _glClear,GL_COLOR_BUFFER_BIT
memcall _glMatrixMode,GL_PROJECTION
memcall _glLoadIdentity
glcall _glFrustum,-0.114f,0.114f,-0.058f,0.058f,0.1f,100.0f
memcall _glMatrixMode,GL_MODELVIEW
memcall _glTranslatef,ebx,0.0,-1.8
memcall _glRotatef,dword [ofs_theta],1.0,-1.0,1.0
call drawCubes
memcall _glLoadIdentity
memcall _glTranslatef,ebx,0.0,-7.0
memcall _glRotatef,dword [ofs_theta],1.0,1.0,1.0
call drawCubes
memcall _glMatrixMode,GL_PROJECTION
memcall _glLoadIdentity
glcall _glOrtho,0.0,screenWidthDouble,screenHeightDouble,0.0,-1.0,1.0
memcall _glMatrixMode,GL_MODELVIEW
memcall _glLoadIdentity
memcall _glPolygonMode,GL_FRONT,GL_FILL
memcall _glColor4f,[esp],[esp],1.0,0.15
memcall _glBegin,GL_QUADS
memcall _glTexCoord2i,ebx,200
memcall _glVertex2i,ebx,ebx
memcall _glTexCoord2i,ebx,ebx
memcall _glVertex2i,ebx,screenHeight
memcall _glTexCoord2i,400,ebx
memcall _glVertex2i,screenWidth,screenHeight
memcall _glTexCoord2i,400,200
memcall _glVertex2i,screenWidth,ebx
memcall _glEnd
memcall _glColor4f,[esp],[esp],1.0,0.5
memcall _glRasterPos2i,395,315
memcall _glCallLists,title.size,GL_UNSIGNED_BYTE,title
memcall _wglSwapBuffers,ebp
memcall _GetAsyncKeyState,VK_ESCAPE
test eax,eax
jz .draw
memcall _ChangeDisplaySettingsA,ebx,ebx
retn
drawCubes:
push ebp
mov ebp,10
.loop:
memcall _glRotatef,dword [ofs_theta+ebp*4-4],1.0,-1.0,1.0
memcall _glTranslatef,ebx,1.0,ebx
fld dword [ofs_theta+ebp*4-4]
fadd dword [ofs_delta]
fstp dword [ofs_theta+ebp*4-4]
memcall _glPolygonMode,GL_FRONT,GL_FILL
memcall _glColor4f,1.0,0.9,ebx,0.15
memcall _glDrawArrays,GL_QUADS,ebx,mdlCrystal.vertexes
memcall _glPolygonMode,GL_FRONT_AND_BACK,GL_LINE
memcall _glColor4f,[esp],[esp],1.0,0.2
memcall _glDrawArrays,GL_QUADS,ebx,mdlCrystal.vertexes
memcall _glTranslatef,ebx,-1.0,ebx
dec ebp
jnz .loop
pop ebp
retn
title db 'grand cubismo - 1k intro by tyler durden'
.size=$-title
szClass db 'edit',0
fontName db 'verdana',0
mdlCrystal dd 1.0,0.0,-1.0,-3.0,1.0,0.0,0.0,1.0,-3.0,1.0,0.0,1.0,1.0,1.0,1.0,1.0,1.0,-1.0,1.0,1.0,0.0,0.0,-1.0,-3.0,-1.0,0.0,1.0,-1.0,1.0,-1.0,1.0,1.0,1.0,1.0,-1.0,1.0,0.0,1.0,-3.0,-1.0,1.0,0.5,-1.0,1.0,-1.0,1.0,0.0,-1.0,1.0,1.0,0.0,0.0,1.0,1.0,1.0,0.0,0.5,1.0,1.0,-1.0,0.0,0.5,-1.0,-3.0,-1.0,1.0,0.5,1.0,-3.0,-1.0,1.0,0.0,1.0,-3.0,1.0,0.0,0.0,-1.0,-3.0,1.0,0.0,0.0,1.0,-3.0,-1.0,0.0,1.0,1.0,1.0,-1.0,1.0,1.0,1.0,1.0,1.0,1.0,0.0,1.0,-3.0,1.0,1.0,0.0,-1.0,-3.0,-1.0,0.0,0.0,-1.0,-3.0,1.0,0.0,1.0,-1.0,1.0,1.0,1.0,1.0,-1.0,1.0,-1.0
.vertexes=24
data import
include 'include\imports_xp.inc'
end data
openglDll db 'opengl32',0
openglDll_length=$-openglDll
delta dd 0.136
delta2 dd 123.1415
ratio dq ?
theta rd 10
textureCell rd 4*textureSize*textureSize
procAddr rd bytesForExport
dmScreenSettings DEVMODE
dmScreenSettings_size=$-dmScreenSettings