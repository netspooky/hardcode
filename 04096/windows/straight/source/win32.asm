; Yah this demo is so crap, I'm giving you the code, so ...
;
; Compile with the supplied Makefile
;
; 2001 Sharky- / Virtual Neurality

.386
locals
jumps
.model flat,STDCALL

include win32.inc
include glut.inc

IDEAL

include "texture.inc"

MACRO   pushd arg
        db 68h
        dd arg
ENDM

SEGMENT _DATA

wc              WNDCLASS        <?>
msg             MSGSTRUCT       <?>
ps              PAINTSTRUCT     <?>
pfd             PIXELFORMATDESCRIPTOR <size PIXELFORMATDESCRIPTOR,1,PFD_DRAW_TO_WINDOW + PFD_SUPPORT_OPENGL + PFD_DOUBLEBUFFER,PFD_TYPE_RGBA,32,0,0,0,0,0,0,0,0,0,0,0,0,0,24,0,0,PFD_MAIN_PLANE,0,0,0,0>
devm            DEVMODE <'',0,0,size DEVMODE,0,DM_PELSWIDTH + DM_PELSHEIGHT + DM_BITSPERPEL,0,0,0,0,0,0,0,0,0,0,0,0,24,640,480,0,0,0,0,0,0,0,0,0,0>

timetoquit      dd      0
msgcounter      dd      -20

greeting        db      'Yep I guess this demo pretty much sucks'
greeting2       db      'How do you make tunnels go around corners anyway ???',0

a1              dq      480.0
a2              dq      0.0
a3              dq      640.0
a4              dq      0.0

; LIGHT0
frame           dd              0
ambient         dd              1.0,0.1,0.1,1.0
diffuse         dd              160.0,160.0,160.0,1.0
position:
        lposx   dd              -0.05
        lposy   dd              0.05
        lposz   dd              2.0
        lposa   dd              1.0

fogcolor        dd              0.0,0.0,0.0,1.0

rotr            dd              0.08

; Projection
perspfar	dq		10.0
perspnear	dq		0.01
perspangle	dq		45.0
perspaspect	dq		1.33

depthf          dq              1.6
depthn		dq		0.2

pos             dd              0.0
rotpos          dd              0.0
rotdelta        dd              0.025
step            dd              0.01
lposzdelta       dd             -0.05
rotatefactor    dd              0.9
result          dd              ?

win             dd              ?
hInst           dd              ?
DC              dd              ?
RC              dd              ?
alpha		dd		0.5

repeat		dd		GL_REPEAT
nearest		dd		GL_NEAREST

texdiff dd      ?

xcoor	dd	?
ycoor	dd	?
zcoor	dd	?
a	dd	?
afactor dd      8.0
zcoorfactor dd  0.3

normalx dd      ?
normaly dd      ?

tunnelList	dd	?

ENDS

SEGMENT _TEXT

szClassName     db      'GL32',0
szTitleName     db      '',0

PROC    start

;	Initialize Window and GL env.

	finit

        mov     [texdiff],0


	call	InitWin
	call	InitGL
        call    InitLists2

;	Enter main message loop

mainLoop:
        push    0
        push    0
        push    0
        push    offset msg
        call    GetMessage
        or      eax,eax
        jz      exitMainLoop

        call    DrawFrame        

        inc     [frame]
        cmp     [timetoquit],1
        je      exitMainLoop

        push    [DC]
        call    SwapBuffers

        push    offset msg
        call    TranslateMessage
        push    offset msg
        call    DispatchMessage
        jmp     mainLoop
exitMainLoop:

        push    0
        push    0
        call    ChangeDisplaySettings

        xor     eax,eax
        ret

ENDP    start

; Inits win32 environment and main window

PROC	InitWin

        push    0
        call    GetModuleHandle         
        mov     [hInst], eax           

        push    CDS_FULLSCREEN
        push    offset devm
        call    ChangeDisplaySettings

	or	eax,eax
	jz	DisplayOK
	
	; 	Try 32 bit depth if 24 doesn't work
	mov	[devm.dmBitsPerPel],32
        mov     [pfd.cColorBits],32
	push	CDS_FULLSCREEN
	push	offset devm
	call	ChangeDisplaySettings
	
	;	Still no fullscreen? Hard luck then.
	
DisplayOK:

        mov     [wc.clsStyle], CS_HREDRAW + CS_VREDRAW + CS_GLOBALCLASS
        mov     [wc.clsLpfnWndProc], offset WndProc
        mov     [wc.clsCbClsExtra], 0
        mov     [wc.clsCbWndExtra], 0
        mov     eax, [hInst]
        mov     [wc.clsHInstance], eax
        mov     [wc.clsHIcon],0
        mov     [wc.clsHCursor], 0
        mov     [wc.clsHbrBackground], COLOR_WINDOW
        mov     [wc.clsLpszMenuName], 0
        mov     [wc.clsLpszClassName], offset szClassName

        push    offset wc
        call    RegisterClass

        push    0
        push    [hInst]
        push    0
        push    0
        push    480
        push    640
        push    0
        push    0
        push    WS_POPUP + WS_CLIPSIBLINGS + WS_CLIPCHILDREN
        push    offset szTitleName
        push    offset szClassName
        push    WS_EX_TOPMOST
        call    CreateWindowEx

        mov     [win],eax
        
        push    SW_SHOWNORMAL
        push    eax
        call    ShowWindow

        push    [win]
        call    UpdateWindow

        push    [win]
        call    GetDC
        mov     [DC],eax

        push    offset pfd
        push    [DC]
        call    ChoosePixelFormat

        push    offset pfd
        push    eax
        push    [DC]
        call    SetPixelFormat

        push    [DC]
        call    wglCreateContext
        mov     [RC],eax

        push    eax
        push    [DC]
        call    wglMakeCurrent
        
        ret

ENDP	InitWin

;	Init GL state & textures

PROC	InitGL

        pushd   1.0
        pushd   0.0
        pushd   0.0
        pushd   0.0
        call    glClearColor

;        push    GL_POLYGON_SMOOTH
;        call    glEnable

        pushd   GL_ONE_MINUS_SRC_ALPHA
        pushd   GL_SRC_ALPHA
        call    glBlendFunc
	
        pushd   GL_BLEND
        call    glEnable

        push	GL_PROJECTION
        call	glMatrixMode
;        call	glLoadIdentity
        
;        pushd	4.0
;        pushd	5.33
;        pushd	4.0
;        call	glScalef
 
	push	[perspfar]
	push	[perspnear]
	push	[perspaspect]
	push	[perspangle]
	call	gluPerspective
        
        push	GL_MODELVIEW
        call	glMatrixMode

        push	GL_DEPTH_TEST
        call	glEnable
        
        push    GL_LESS
        call    glDepthFunc
        
        push	GL_LIGHTING
        call	glEnable
        
;       push    offset lmodel_ambient
;       push    GL_LIGHT_MODEL_AMBIENT
;       call    glLightModelfv
	
        push   offset ambient
        push   GL_AMBIENT
        push   GL_LIGHT0
        call   glLightfv
        
        push	offset diffuse
        push	GL_DIFFUSE
        push	GL_LIGHT0
        call	glLightfv
        
        push	GL_LIGHT0
        call	glEnable
        
        push	GL_TRUE
        push	GL_LIGHT_MODEL_TWO_SIDE
        call	glLightModeli
 
 	push	offset repeat
 	push	GL_TEXTURE_WRAP_S
 	push	GL_TEXTURE_2D
 	call	glTexParameterfv
 
 	push	offset repeat
 	push	GL_TEXTURE_WRAP_T
 	push	GL_TEXTURE_2D
 	call	glTexParameterfv

 	push	offset nearest
 	push	GL_TEXTURE_MAG_FILTER
 	push	GL_TEXTURE_2D
 	call	glTexParameterfv

 	push	offset nearest
 	push	GL_TEXTURE_MIN_FILTER
 	push	GL_TEXTURE_2D
 	call	glTexParameterfv
 
        push	GL_TEXTURE_2D
        call	glEnable
        
        push    GL_SMOOTH
        call    glShadeModel

;        push    GL_AUTO_NORMAL
;        call    glEnable

;        push    GL_POLYGON_SMOOTH
;        call    glEnable

        push    GL_FOG
        call    glEnable
	
	pushd	0.1
	push	GL_FOG_START
	call	glFogf
	
	pushd	1.0
	push	GL_FOG_END
	call	glFogf
	
	push	offset fogcolor
	push	GL_FOG_COLOR
	call	glFogfv
	ret

ENDP	InitGL

testz   dd      0.05

PROC	DrawFrame

        push    ecx
        push    GL_COLOR_BUFFER_BIT + GL_DEPTH_BUFFER_BIT
        call    glClear

        fld     [step]
        fld     [pos]
        fadd    st(0),st(1)
        fst     [pos]
        fsin
        fld     [rotatefactor]
        fmul    st(0),st(1)
        fstp    [result]
        fstp    st(0)
        fstp    st(0)

        fld     [rotr]
        fld     [rotdelta]
        fld     [rotpos]
        fadd    st(0),st(1)
        fst     [rotpos]
        fsincos
        fmul    st(0),st(3)
        fstp    [lposx]
        fmul    st(0),st(2)
        fstp    [lposy]
        fstp    st(0)
        fstp    st(0)

        fld     [lposzdelta]
        fld     [lposz]
        faddp   st(1),st(0)
        fstp    [lposz]

        push	offset position
        push	GL_POSITION
        push	GL_LIGHT0
        call	glLightfv

        pushd   0.05
        pushd   0.0
        pushd   0.0
        call    glTranslatef

        pushd    1.0
 	pushd	0.0
 	pushd	0.0
        push   [result]
 	call	glRotatef

        add     [texdiff],10
        call    InitTexture
	push	[tunnelList]
	call	glCallList

        push    GL_PROJECTION
        call    glMatrixMode
        call    glPushMatrix
        call    glLoadIdentity

        push    [a1]
        push    [a2]
        push    [a3]
        push    [a4]
        call    gluOrtho2D

        push    GL_MODELVIEW
        call    glMatrixMode
        call    glPushMatrix
        call    glLoadIdentity

        pushd   1.0
        pushd   1.0
        pushd   1.0
        call    glColor3f

        push    7
        call    glIndexi

        push    GL_DEPTH_TEST
        call    glDisable

        push    GL_LIGHTING
        call    glDisable

        pushd   240
        pushd   200
        call    glRasterPos2i

        push    esi
        mov     esi,offset greeting
        mov     ecx,[msgcounter]
        or      ecx,ecx
        js      BC03
        shr     ecx,2
        jcxz    BC02
BC01:
        cmp     esi,offset greeting2
        jne     BCNE

        push    ecx
        pushd   200
        pushd   150
        call    glRasterPos2i
        pop     ecx

BCNE:
        xor     eax,eax
        mov     al,[esi]
        or      al,al
        jz      BC02
        inc     esi
        push    ecx
        push    eax
        push    4
        call    glutBitmapCharacter
        pop     ecx
        loop BC01
BC02:
        cmp     ecx,60
        jb      BC03
        inc     [timetoquit]
BC03:
        pop     esi


        inc     [msgcounter]

        push    GL_LIGHTING
        call    glEnable

        push    GL_DEPTH_TEST
        call    glEnable

        push    GL_PROJECTION
        call    glMatrixMode
        call    glPopMatrix

        push    GL_MODELVIEW
        call    glMatrixMode
        call    glPopMatrix

        pop ecx
	ret
	
ENDP	DrawFrame

PROC    WndProc uses ebx edi esi, hwnd:DWORD, wmsg:DWORD, wparam:DWORD, lparam:DWORD

	cmp	[wmsg], WM_CREATE
	je	wmcreate
        cmp     [wmsg], WM_DESTROY
        je      wmdestroy
        cmp	[wmsg], WM_KEYDOWN
        je	wmdestroy
        cmp     [wmsg], WM_PAINT
        je      wmpaint
        cmp	[wmsg], WM_SETCURSOR
        push	0
        call	SetCursor
        jmp 	finish

        jmp     defwndproc

wmpaint:
        mov     eax, 0
        jmp     finish

defwndproc:
        push    [lparam]
        push    [wparam]
        push    [wmsg]
        push    [hwnd]
        call    DefWindowProc
        jmp     finish

wmdestroy:
        push    0
        push    0
        call    wglMakeCurrent
        push    [RC]
        call    wglDeleteContext
        push    [DC]
        push    [hwnd]
        call    ReleaseDC

        push    0
        push    0
        call    ChangeDisplaySettings

        push    0
        call    PostQuitMessage
        mov     eax, 0
        jmp     finish

wmcreate:
        
        mov	eax,0
	jmp 	finish

finish:
        ret

ENDP    WndProc

PI	EQU	3.14159265
z	EQU	1000
n       EQU     101
r	dd	0.1
zdelta	dd	-0.1
adelta  dd      0.0628318530                ;2 * PI / (n-1)
bmpfactor dd    0.025

PROC	InitLists2

	push	esi
	
	mov	esi, offset texture
	
	push	1
	call	glGenLists
	mov	[tunnelList],eax

	push	GL_COMPILE
	push	eax
	call	glNewList

	fld	[zdelta]	; st(1) = zdelta
	fldz			; st(0) = z
	mov	ecx,z

zloop:
	push 	ecx

        push    GL_QUAD_STRIP
	call	glBegin
	
	mov	ecx,n

	fldz
	fstp	[a]
nloop:
	push	ecx

	fst	[zcoor]		; z = st(0)

        call    GetRadius

        pushd   0.0
        push    [normaly]
        push    [normalx]
        call    glNormal3f

	push	[zcoor]
	push	[a]
	call	glTexCoord2f
	
	push	[zcoor]
	push	[ycoor]
	push	[xcoor]
	call	glVertex3f
	
	fld	st(0)		; copy current z
	fadd	st(0),st(2)	; add zdelta
	fstp	[zcoor]

        call    GetRadius

        pushd   0.0
        push    [normaly]
        push    [normalx]
        call    glNormal3f

	push	[zcoor]
	push	[a]
	call	glTexCoord2f
	
	push	[zcoor]
	push	[ycoor]
	push	[xcoor]
	call	glVertex3f

	fld	[a]
	fadd	[adelta]
	fstp	[a]
	
	inc 	esi
	cmp	esi,offset texture + 128*128
	jne	L01
	mov	esi,offset texture
L01:
	
	pop	ecx
	loop	nloop

	fadd	st(0),st(1)

	call	glEnd

	pop	ecx
	loop	zloop

	fstp	st(0)
	fstp	st(0)
	
	call	glEndList
	pop	esi
	
	ret

ENDP	InitLists2

PROC    GetRadius

        fld     [a]             ; push a
        fld     [zcoor]
        fld     [zcoorfactor]
        fmulp   st(1),st(0)
        faddp   st(1),st(0)
        fld     [afactor]       ; push afactor
        fmulp   st(1),st(0)     ; st(0)=a*afactor
        fsin                    ; st(0)=sin(a)
        fmul    [bmpfactor]     ; st(0)=sin(a) * bmpfactor
        fld     [r]             ; st(0)=r, st(1)=sin(a) * bmpfactor
        fadd    st(0),st(1)     ; st(0)=r + sin(1) * bmpfactor
        fld     [a]             ; st(0) = a, st(1)=r
        fsincos                 ; st(0) = sin(a); st(1) = cos(a), st(2)=r
        fmul    st(0),st(2)     ; st(0) = r * sin(a)
        fst     [ycoor]         ; y = r * cos(a)
        fchs
        fadd    st(0),st(3)
        fstp    [normaly]
        fmul    st(0),st(1)     ; st(0) = r * cos(a)
        fst     [xcoor]         ; x = r * sin(a)
        fchs
        fadd    st(0),st(2)
        fstp    [normalx]
        fstp    st(0)
        fstp    st(0)           ; pop r
        ret

ENDP

PROC    InitTexture

        push ecx
        push edi
        push eax
        mov ecx,128*128
        mov edi,offset texture
        mov ebx,0
IT01:
        mov eax,[texdiff]
        shr eax,8
        stosb
        mov ah,0ffh
        sub ah,al
        xchg ah,al
        stosb
        inc ebx
        mov eax,ebx
        shr eax,5
;        mov al,0ffh
        stosb
;        stosb
;        stosb
        loop IT01

        pop eax
        pop edi
        pop ecx

 	push	offset texture
 	push	GL_UNSIGNED_BYTE
 	push	GL_RGB
 	push	0
 	push	128
 	push	128
 	push	3
 	push	0
 	push	GL_TEXTURE_2D
        call	glTexImage2D

        ret
ENDP



ENDS    _TEXT

END     start

