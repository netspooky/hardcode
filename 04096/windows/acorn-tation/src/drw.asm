; #########################################################################

      .386
      .model flat, stdcall
      option casemap :none   ; case sensitive

; #########################################################################

      include \masm32\include\windows.inc
      include \masm32\include\user32.inc
      include \masm32\include\kernel32.inc
      include \masm32\include\gdi32.inc
      include \masm32\include\opengl32.inc
      include \masm32\include\glu32.inc

      includelib \masm32\lib\gdi32.lib
      includelib \masm32\lib\user32.lib
      includelib \masm32\lib\kernel32.lib
      
      includelib opengl32.lib
      includelib glu32.lib

GLint		TYPEDEF		DWORD
GLuint		TYPEDEF		DWORD
GLdouble	TYPEDEF		REAL8

;	include .\OpenGL\def\gl.def
;	include .\OpenGL\def\glu.def
	include .\OpenGL\def\winextra.def
	include .\OpenGL\def\include.def
	includelib .\OpenGL\opengl32.lib
	includelib .\OpenGL\glu32.lib

	CreateGLWindow 			PROTO :DWORD
; #########################################################################

      ;=============
      ; Local macros
      ;=============

      szText MACRO Name, Text:VARARG
        LOCAL lbl
          jmp lbl
            Name db Text,0
          lbl:
        ENDM

      m2m MACRO M1, M2
        push M2
        pop  M1
      ENDM

      return MACRO arg
        mov eax, arg
        ret
      ENDM

        ;=================
        ; Local prototypes
        ;=================
        WinMain PROTO :DWORD,:DWORD,:DWORD,:DWORD
        WndProc PROTO :DWORD,:DWORD,:DWORD,:DWORD
        TopXY PROTO   :DWORD,:DWORD

    .data
        szDisplayName db "Acorn-tation",0
        hWnd          dd 0
        hInstance     dd 0
        szClassName   db "Template_Class",0

word_4030A0	dw 137Fh
word_4030A2	dw 1F7Fh

dbl_406048	dq 100.0
dbl_406050	dq 0.1
dbl_406058	dq 1.333333333333333
dbl_406060	dq 45.0

	D1 dd 0.0
	D2 dd 100.0
	D3 dd 0.1
	D4 dd 45.0
	D5 dd 1431655765;1.0;33333

;D1 dd 0,1079574528
;D2 dd -1717986918,1069128089
;D3 dd 1431655765,1073042773
;D4 dd 0,1078362112

;	hDC dd 0

 tmp dd 0
 
c100 dd 100.0
c3 dd 3.0
c06 dd 0.6
c6 dd 6.0
c24 dd 24.0
v_a dd 500
v_b dd 500*500
v_c dd 300

v_ys dd 1
v_ittr dd 8.0
v_delta dd -0.005

v_x dd 1
v_s dd 1
v_p dd 1
v_t dd 1
v_i dd 1
v_r dd 1
v_q dd 1
v_y dd 1
v_m dd 1
v_n dd 1

;	fovy						REAL8		45.0d
;	zNear					REAL8		0.1d
;	zFar						REAL8		100.0d
;	f1_0						REAL4		1.0f
	d1_0					REAL8		1.0d

	hRC						dd 0;HGLRC		
	hDC						dd 0;HDC			 
;	hInstance					dd 0;HINSTANCE	
;	hWND					dd 0;HWND		

    .code

start:
        push NULL
        call GetModuleHandle
        mov hInstance, eax

        push SW_SHOWDEFAULT
        push NULL;CommandLine
        push NULL
        push hInstance
        call WinMain

        push eax
        call ExitProcess

; #########################################################################

WinMain proc hInst     :DWORD,
             hPrevInst :DWORD,
             CmdLine   :DWORD,
             CmdShow   :DWORD

        ;====================
        ; Put LOCALs on stack
        ;====================

        LOCAL wc   :WNDCLASSEX
        LOCAL msg  :MSG

        LOCAL Wwd  :DWORD
        LOCAL Wht  :DWORD
        LOCAL Wtx  :DWORD
        LOCAL Wty  :DWORD

		LOCAL pfd: PIXELFORMATDESCRIPTOR
        ;==================================================
        ; Fill WNDCLASSEX structure with required variables
        ;==================================================

        mov wc.cbSize,         sizeof WNDCLASSEX
        mov wc.style,          CS_HREDRAW or CS_VREDRAW \
                               or CS_BYTEALIGNWINDOW
        mov wc.lpfnWndProc,    offset WndProc
        mov wc.cbClsExtra,     NULL
        mov wc.cbWndExtra,     NULL
        m2m wc.hInstance,      hInst
        mov wc.hbrBackground,  COLOR_BTNFACE+1
        mov wc.lpszMenuName,   NULL
        mov wc.lpszClassName,  offset szClassName

;        push 500
;        push hInst
;        call LoadIcon
;        mov wc.hIcon, eax
        
;        push IDC_ARROW
;        push NULL
;        call LoadCursor
        xor eax,eax
        mov wc.hCursor, eax
        mov wc.hIconSm, eax ; 0
        mov wc.hIcon, eax

        lea eax, wc
        push eax
        call RegisterClassEx

        ;================================
        ; Centre window at following size
        ;================================

        mov Wwd, 600;-10
        mov Wht, 600;-10
;
;        push SM_CXSCREEN
;        call GetSystemMetrics
;
;        push eax
;        push Wwd
;        call TopXY
;        mov Wtx, eax
;
;        push SM_CYSCREEN
;        call GetSystemMetrics
;
;        push eax
;        push Wht
;        call TopXY
;        mov Wty, eax

        push NULL
        push hInst
        push NULL
        push NULL
        push 600
        push 600
        push 10
        push 10
        push WS_OVERLAPPEDWINDOW
        push offset szDisplayName
        push offset szClassName
        push WS_EX_OVERLAPPEDWINDOW
        call CreateWindowEx

        mov   hWnd,eax

        push SW_SHOWNORMAL
        push hWnd
        call ShowWindow

        push hWnd
        call UpdateWindow
;--------------------------------------------------------------------
;		push hWnd
;;		pop hWND
;		invoke GetCurrentProcess
;		invoke SetPriorityClass,eax,128
		invoke CreateGLWindow,hWnd

;--------------------------------------------------------------------
; Repeat
_Repeat1:
GL_DEPTH_BUFFER_BIT               = 00000100h
GL_COLOR_BUFFER_BIT               = 00004000h

; glClear_(#GL_DEPTH_BUFFER_BIT | #GL_COLOR_BUFFER_BIT)
  PUSH   GL_DEPTH_BUFFER_BIT+GL_COLOR_BUFFER_BIT
  CALL  glClear

; glLoadIdentity_() 
  CALL  glLoadIdentity

; glTranslatef_(0,0,-1)
  PUSH   -1082130432
  PUSH   0
  PUSH   0
  CALL  glTranslatef

; glScalef_(0.0007,0.0007,1)
  PUSH   1065353216
  PUSH   981668463
  PUSH   981668463
  call  glScalef

; glPointSize_(1.0)
  PUSH   1065353216
  CALL  glPointSize
; 
; glBegin_(#GL_POINTS)
  PUSH  0
  CALL  glBegin

;;  mov eax,100
;;  push eax
;;  push eax
;;  CALL  glVertex2i

; ys=ittr
  FLD    v_ittr
  FSTP   v_ys
; 
; For x = -500 To 500
  MOV    v_x,-500
_For2:
  MOV    eax,500
  CMP    eax,v_x
  JL    _Next3
; s = x * x
  MOV    ebx,v_x
  IMUL   ebx,v_x
  MOV    v_s,ebx
; p.f = Sqr(b - s)
  FILD   v_b
  FISUB  v_s
  FSQRT
  FST   v_p
; t.f = -p
;  FLD    v_p
  FCHS
  FST   v_t
; i.f=t
;;  FLD    v_t
  FSTP   v_i
; 
; While i<=p
_While4:
  FLD    v_i
  FLD    v_p
  FCOMPP
  FNSTSW ax
  TEST   ah,1h
  JNE   _Wend4

; r.f = Sqr(s + i * i)/a
;  FILD   v_s
  FLD    v_i
  FMUL   v_i
  FIADD v_s
 ; FADDP  st(1),st(0)
  FSQRT
  FIDIV  v_a
  FSTP   v_r

; q.f = (r - 1) * Sin(24 * r)
  fld1
  fchs
  fadd v_r
;  FLD    v_r
  FLD    v_r
  FMUL   c24;dword [F3]
  FSIN

;  FMUL v_r
  FMULP  st(1),st(0)
  FSTP   v_q

;;;;;        y = (int)(i/3 + q*c);
;;;;		fld	c3
;;;;		fdivr	v_i;обратное деление
;;;;		fst	tmp;[ebp+var_18]
;;;;		fstp	st(1)
;;;;
;;;;		fild	v_c
;;;;		fmul	v_q;q*c
;;;;		fadd	tmp;[ebp+var_18];+i/3
;;;;
;;;;		fldcw	word_4030A2
;;;;;		sub	esp, 4
;;;;		fistp	v_y;;;[esp+24h+var_24]
;;;;		fldcw	word_4030A0

; y = Int(i/3 + q*c)
  FLD    v_i
  FDIV   c3
  FLD    v_q
  FIMUL  v_c
  FADDP  st(1),st(0)
  FISTP v_y
;  SUB    esp,8
;  FSTP   [esp]
;  CALL  PB_Int
;  MOV    v_y,eax

; If i = t:m = y:n = y:EndIf
  FLD    v_i
  FLD    v_t
  FCOMPP
  FNSTSW ax
  TEST   ah,40h
  JE    _EndIf6
  MOV    eax,v_y
  MOV    v_m,eax
  MOV    v_n,eax
_EndIf6:

; If y > m:m = y:EndIf
  MOV    ebx,v_y
  CMP    ebx,v_m
  JLE   _EndIf8
  MOV    v_m,ebx
_EndIf8:

; If y < n:n = y:EndIf
  MOV    ebx,v_y
  CMP    ebx,v_n
  JGE   _EndIf10
  MOV    v_n,ebx
_EndIf10:

; If ( m = y )Or ( n = y)
  MOV    ebx,v_m
  CMP    ebx,v_y
  JE     Ok0
  MOV    ebx,v_n
  CMP    ebx,v_y
  JE     Ok0
  JMP    No0
Ok0:
  MOV    eax,1
  JMP    End0
No0:
  XOR    eax,eax
End0:
  AND    eax,eax
  JE    _EndIf12

; glColor3f_(1.0,1.0,1.0)
;  fild v_r
;  fidiv v_q
;  fstp tmp
  PUSH   1065353216
  PUSH   v_r;1065353216
  PUSH   v_q;1065353216
  CALL  glColor3f

; glVertex2i_(x-200,y)
  PUSH   v_y
  MOV    ebx,v_x
;  ADD    ebx,-200
  PUSH   ebx

;  PUSH   v_x
;  PUSH   v_x

  CALL  glVertex2i
; EndIf
_EndIf12:
; i=i+6*ys
  FLD    v_i
  FLD    v_ys
  FMUL   c6;dword [F4]
  FADDP  st(1),st(0)
  FSTP   v_i
; Wend
  JMP   _While4
_Wend4:
; Next x
_NextContinue3:
  INC    v_x
  JNO   _For2
_Next3:
; 
; ittr = ittr + delta
  FLD    v_ittr
  FADD   v_delta
  FSTP   v_ittr

; If(ittr < 0.6):delta =-delta:EndIf
  FLD    v_ittr
  FCOMP  c06;dword [F5]
  FNSTSW ax
  TEST   ah,1h
  JE    _EndIf14
  FLD    v_delta
  FCHS
  FSTP   v_delta
_EndIf14:

; If(ittr > 100):delta =-delta:EndIf
  FLD    v_ittr
  FCOMP  c100
  FNSTSW ax
  TEST   ah,41h
  JNE   _EndIf16
  FLD    v_delta
  FCHS
  FSTP   v_delta
_EndIf16:
; 
; glEnd_()
  CALL  glEnd
; glFinish_()
  CALL  glFinish
; SwapBuffers_ ( hDC )
  PUSH  hDC
  CALL  SwapBuffers
;; Until ( GetAsyncKeyState_ (#VK_ESCAPE) )
;  PUSH   dword 27
;  CALL  _GetAsyncKeyState@4
;  AND    eax,eax
;  JE    _Repeat1
;_Until1:

;--------------------------------------------------------------------

      ;===================================
      ; Loop until PostQuitMessage is sent
      ;===================================
VK_ESCAPE=01Bh

 invoke GetAsyncKeyState,VK_ESCAPE
 or eax,eax
 jne exitp
 jmp _Repeat1
exitp:
 ret 
 
    StartLoop:
      push 0
      push 0
      push NULL
      lea eax, msg
      push eax
      call GetMessage

      cmp eax, 0
      je ExitLoop

      lea eax, msg
      push eax
      call TranslateMessage

      lea eax, msg
      push eax
      call DispatchMessage

      jmp StartLoop
    ExitLoop:

      mov eax, msg.wParam
      ret

WinMain endp
;
;PB_Int proc
; fld     [esp+arg_0]
; call    sub_4049F0
; retn    8
;
;PB_Int endp
; #########################################################################

WndProc proc hWin   :DWORD,
             uMsg   :DWORD,
             wParam :DWORD,
             lParam :DWORD

;LOCAL hdc:DWORD
    cmp uMsg, WM_PAINT
    jne nxt1

nxt1:
    cmp uMsg, WM_CLOSE
    je nxt4 ; jne nxt2
    nxt2:
    cmp uMsg, WM_DESTROY
    jne nxt3
nxt4:
      push NULL
      call PostQuitMessage
      xor eax, eax                  ; put zero in eax
      ret                           ; exit the proc

    nxt3:
      push lParam
      push wParam
      push uMsg
      push hWin
      call DefWindowProc

    ret

WndProc endp

CreateGLWindow proc h_Wnd:HWND
	LOCAL PixelFormat:GLuint, pfd:PIXELFORMATDESCRIPTOR, ratio:GLdouble
	LOCAL WindowRect:RECT
	LOCAL WindowWidth:DWORD
	LOCAL WindowHeight:DWORD

	ZeroMemory &pfd,sizeof(PIXELFORMATDESCRIPTOR)
	mov pfd.nSize,sizeof(PIXELFORMATDESCRIPTOR)
	mov pfd.nVersion,1
	mov pfd.dwFlags,PFD_DRAW_TO_WINDOW or PFD_SUPPORT_OPENGL or PFD_DOUBLEBUFFER 
	mov pfd.iPixelType,PFD_TYPE_RGBA
	mov pfd.cColorBits,16
	mov pfd.cDepthBits,16
	mov pfd.dwLayerMask,PFD_MAIN_PLANE
	
	invoke GetDC,h_Wnd
	mov hDC,eax
	invoke ChoosePixelFormat,hDC,addr pfd
	mov PixelFormat,eax
	invoke SetPixelFormat,hDC,PixelFormat,addr pfd
	invoke wglCreateContext,hDC
	mov hRC,eax
	invoke wglMakeCurrent,hDC,hRC

	invoke GetWindowRect,h_Wnd,addr WindowRect
	mov eax,WindowRect.right
	sub eax,WindowRect.left
	mov WindowWidth,eax
	mov eax,WindowRect.bottom
	sub eax,WindowRect.top
	mov WindowHeight,eax

	invoke glViewport, 0, 0, WindowWidth,WindowHeight
	invoke glMatrixMode, GL_PROJECTION
	invoke glLoadIdentity  
;	fild WindowWidth
;	fild WindowHeight
;	fdivp st(1),st(0)
;	fstp ratio
;	fwait


var_20		= qword	ptr -20h
var_18		= qword	ptr -18h
var_10		= qword	ptr -10h
var_8		= qword	ptr -8

; gluPerspective(45.0,#width/#height,0.1,100.0) 
		fld	dbl_406048;100.0
		sub	esp, 8
		fstp	[esp+8+var_8]
		fld	dbl_406050;0.1
		sub	esp, 8
		fstp	[esp+10h+var_10]
		fld	dbl_406058;1.33
		sub	esp, 8
		fstp	[esp+18h+var_18]
		fld	dbl_406060;45
		sub	esp, 8
		fstp	[esp+20h+var_20]
		call gluPerspective

;	invoke gluPerspective,dword ptr fovy,dword ptr fovy+4,dword ptr dbl_406058,dword ptr dbl_406058+4, \
;					dword ptr zNear,dword ptr zNear+4,dword ptr zFar,dword ptr zFar+4 ; 45.0d, ratio, 0.1d, 100.0d
	invoke glMatrixMode, GL_MODELVIEW
	invoke glLoadIdentity
	
;	invoke InitGL
	invoke glBlendFunc,GL_SRC_ALPHA,GL_ONE		; Set The Blending Function For Translucency
	xor eax,eax
	invoke glClearColor,eax,eax,eax,eax						; This Will Clear The Background Color To Black
;	invoke glClearColor,0,0,0,0						; This Will Clear The Background Color To Black

	ret
CreateGLWindow endp

end start
