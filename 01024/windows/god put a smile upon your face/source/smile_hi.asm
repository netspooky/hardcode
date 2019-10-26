;-----------------------------------------------------------;
;"God put a smile upon your face"                           ;
;640x480x32 256x256 blur textures version (WindowsXP SP1)   ;
;Intro written by Tyler Durden in 2004                      ;
;Compiled with FasmW v.1.52 (flatassembler.net)             ;
;-----------------------------------------------------------;
;website: http://www.tylerdurden.net.ru/                    ;
;email: smile@tylerdurden.net.ru                            ;
;-----------------------------------------------------------;
format PE GUI 4.0
entry start
ofs_blurDelta equ esi
ofs_alphaDelta equ esi+4
ofs_delta equ esi+8
ofs_blurInc equ esi+12+openglDll_length
ofs_blurDec equ esi+16+openglDll_length
ofs_blurAlpha equ esi+20+openglDll_length
ofs_theta equ esi+24+openglDll_length
ofs_dmScreenSettings equ esi+28+openglDll_length
screenWidth=800
screenHeight=600
screenWidthDouble equ 800.0f
screenHeightDouble equ 600.0f
include '%fasminc%\win32a.inc'
include 'include\opengl_macros.inc'
include 'include\opengl_const.inc'
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
mov esi,blurDelta
memcall _ShowCursor,ebx
mov [ofs_dmScreenSettings+dmScreenSettings.dmSize-dmScreenSettings],dmScreenSettings_size
mov [ofs_dmScreenSettings+dmScreenSettings.dmPelsWidth-dmScreenSettings],screenWidth
mov [ofs_dmScreenSettings+dmScreenSettings.dmPelsHeight-dmScreenSettings],screenHeight
mov [ofs_dmScreenSettings+dmScreenSettings.dmFields-dmScreenSettings],DM_PELSWIDTH+DM_PELSHEIGHT
memcall _ChangeDisplaySettingsA,dmScreenSettings,ebx
memcall _CreateWindowExA,ebx,className,ebx,WS_VISIBLE or WS_POPUP,ebx,ebx,screenWidth,screenHeight,ebx,ebx,ebx,ebx
screenHeight=445
screenHeightDouble equ 445.0f
memcall _GetDC,eax
xchg ebp,eax
memcall _SetPixelFormat,ebp,10,ebx
memcall _wglCreateContext,ebp
memcall _wglMakeCurrent,ebp,eax
memcall _glEnable,GL_LIGHT0,GL_BLEND,GL_COLOR_MATERIAL,GL_SRC_ALPHA,GL_ONE
memcall _glEnable
memcall _glEnable
memcall _glBlendFunc
memcall _glEnable,GL_TEXTURE_2D
memcall _glBindTexture,GL_TEXTURE_2D,1
memcall _glTexImage2D,GL_TEXTURE_2D,ebx,3,[esp],blurSize,ebx,GL_RGB,GL_UNSIGNED_BYTE,textureBlank
memcall _glTexParameteri,GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR
memcall _glBindTexture,GL_TEXTURE_2D,2
memcall _glTexImage2D,GL_TEXTURE_2D,ebx,3,32,16,ebx,GL_RGB,GL_UNSIGNED_BYTE,start
memcall _glTexParameteri,GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR
memcall _glTexGeni,GL_S,GL_TEXTURE_GEN_MODE,GL_SPHERE_MAP
memcall _glTexGeni,GL_T,GL_TEXTURE_GEN_MODE,GL_SPHERE_MAP
memcall _CreateFontA,ebx,ebx,ebx,ebx,ebx,ebx,ebx,ebx,SYMBOL_CHARSET,ebx,ebx,ebx,ebx,ebx
memcall _SelectObjectA,ebp,eax
memcall _wglUseFontOutlinesA,ebp,4ah,1,ebp,0.02f,0.2f,1,ebx
memcall _glMatrixMode,GL_PROJECTION
glcall _glFrustum,-0.104f,0.104f,-0.058f,0.058f,0.1f,100.0f
.draw:
memcall _glClear,GL_COLOR_BUFFER_BIT
memcall _glMatrixMode,GL_MODELVIEW
memcall _glLoadIdentity
memcall _glColor4f,0.8f,0.4,ebx,1.0f
memcall _glTranslatef,ebx,ebx,-0.7f
memcall _glRotatef,[ofs_theta],1.0f,ebx,ebx
memcall _glRotatef,[ofs_theta],ebx,[esp],1.0f
memcall _glRotatef,[ofs_theta],ebx,ebx,1.0f
memcall _glTranslatef,-0.37f,-0.32f,0.1f
memcall _glViewport,ebx,ebx,[esp],blurSize
memcall _glBindTexture,GL_TEXTURE_2D,2
memcall _glCallList,ebp
memcall _glBindTexture,GL_TEXTURE_2D,1
memcall _glCopyTexImage2D,GL_TEXTURE_2D,ebx,GL_RGB,ebx,ebx,[esp],blurSize,ebx
memcall _glClear,GL_COLOR_BUFFER_BIT
memcall _glViewport,ebx,77,screenWidth,screenHeight
memcall _glBindTexture,GL_TEXTURE_2D,2
memcall _glDisable,GL_LIGHTING,GL_TEXTURE_GEN_S,GL_TEXTURE_GEN_T
memcall _glDisable
memcall _glDisable
memcall _glMatrixMode,GL_PROJECTION
memcall _glPushMatrix
memcall _glLoadIdentity
glcall _glOrtho,0.0f,screenWidthDouble,screenHeightDouble,0.0f,-1.0f,1.0f
memcall _glMatrixMode,GL_MODELVIEW
memcall _glLoadIdentity
memcall _glBindTexture,GL_TEXTURE_2D,1
mov ecx,blurCount
mov dword [ofs_blurInc],ebx
mov dword [ofs_blurDec],1.0f
mov dword [ofs_blurAlpha],0.35f
.renderMotionBlur:
push ecx
fld dword [ofs_blurDelta]
fld st0
fadd dword [ofs_blurInc]
fstp dword [ofs_blurInc]
fsubr dword [ofs_blurDec]
fstp dword [ofs_blurDec]
fld dword [ofs_blurAlpha]
fsub dword [ofs_alphaDelta]
fstp dword [ofs_blurAlpha]
memcall _glColor4f,[esp],[esp],1.0f,[ofs_blurAlpha]
memcall _glBegin,GL_QUADS
memcall _glTexCoord2f,[ofs_blurInc],[esp],[esp],[ofs_blurDec]
memcall _glVertex2i,ebx,ebx
memcall _glTexCoord2f,[esp],[esp],[ofs_blurInc]
memcall _glVertex2i,ebx,screenHeight
memcall _glTexCoord2f,[ofs_blurDec]
memcall _glVertex2i,screenWidth,screenHeight
memcall _glTexCoord2f
memcall _glVertex2i,screenWidth,ebx
memcall _glEnd
pop ecx
dec ecx
jnz .renderMotionBlur
memcall _glMatrixMode,GL_PROJECTION
memcall _glPopMatrix
memcall _glEnable,GL_LIGHTING,GL_TEXTURE_GEN_S,GL_TEXTURE_GEN_T
memcall _glEnable
memcall _glEnable
memcall _wglSwapBuffers,ebp
fld dword [ofs_theta]
fadd dword [ofs_delta]
fstp dword [ofs_theta]
memcall _GetAsyncKeyState,VK_ESCAPE
test eax,eax
jz .draw
.exit:
memcall _ChangeDisplaySettingsA,ebx,ebx
retn
blurCount=25
blurSize=512
data import
include 'include\imports_xp.inc'
end data
className db 'edit',0
blurDelta dd 0.01f
alphaDelta dd 0.013f
delta dd 1.0f
openglDll db 'opengl32',?
openglDll_length=$-openglDll
blurInc dd ?
blurDec dd ?
blurAlpha dd ?
theta dd ?
dmScreenSettings DEVMODE
dmScreenSettings_size=$-dmScreenSettings
textureBlank rd blurSize*blurSize
procAddr rd bytesForExport