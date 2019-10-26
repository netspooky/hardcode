; Corrente Continua - 1k intro
; by Zerothehero of Topopiccione
; 28/06/2012 - Milan
;
; Thanks to Mic for Monjori source and Hitchhikr
; for 1k framework and 1kpack packing software
;
; Tested on PentiumD 3.0GHz / WinXP / GTS450
; Assembled with nasmw.exe - linked with 1kpack.exe
; Only few values of variable "a" (line 255) are meaningful!
;
; WebGL version at http://topopiccione.altervista.org/01_tan.html
; Shader code from that page should work in Shadertoy and/or
; GLSL Sandbox (not tested yet).
;
;
; Original thanks follow
;
; ------------------------------------------------------
; 1kPack v0.6 - Framework
; Written by Franck "hitchhikr" Charlet / Neural
; ------------------------------------------------------
; Thanks to rbraz for the trianglelist trick.
; ------------------------------------------------------
; buildblock RELEASE
; CAPT "[SOURCEDIR]nasmw.exe" -f bin "%2" -o "%1.bin" -s -O9
; CAPT "[SOURCEDIR]1kpack.exe" "depackers\dx_depacker.bin" "%1.bin"
; buildblockend

; ------------------------------------------------------
; Header
                            bits    32

; ------------------------------------------------------
; Includes
                            %include "d3d9_nasm.inc"

; ------------------------------------------------------
; Constants
;%define GRAB_SCREENSHOT
;%define DEBUG
WS_EX_TOPMOST               equ     0x8
VK_ESCAPE                   equ     0x1b

SCREENX                     equ     1024
SCREENY                     equ     768
SCREENDEPTH                 equ     D3DFMT_A8R8G8B8     ; 32 bits

D3DFVF_XYZRHW_SIZE          equ     (4 * 4)

BASE                        equ     0x420000

; Those are located inside the depacker
POS_fnc_exit                equ     0x410090
POS_fnc_D3DXCompileShader   equ     0x410094
POS_fnc_LoadLibrary         equ     0x4100b4
POS_fnc_GetProcAddress      equ     0x4100b8
POS_fnc_QueryPerformanceCounter equ 0x4100bc

; !!! Only valid for d3dx9_30.dll !!!
D3DX_D3DXCompileShader      equ     0xda6de
D3DX_D3DXCreateTextureFromFileInMemoryEx equ    (D3DX_D3DXCompileShader - 0xc1341)
D3DX_D3DXCreateTexture      equ     (D3DX_D3DXCompileShader - 0xbe4a2)

; ------------------------------------------------------
; Structures

; ------------------------------------------------------
; Vars datas
Device                      equ     0
OldTime                     equ     Device + 4
CurrTime			    	equ     OldTime + 8
Delta			            equ	    CurrTime + 8
HTimerFreq                  equ     Delta + 4 
PixelShader                 equ     HTimerFreq + 8

                            .code

; ---------------------------------------------------------
; Program entry point
; base address = 0x420000
; edi contains D3DXCompileShader
EntryPoint:                 ;sub     edi, D3DX_D3DXCreateTextureFromFileInMemoryEx
                            ;; stack contains D3DXCreateTextureFromFileInMemoryEx
                            ;push    edi

                            ; Import the functions we need
                            mov     edi, table_dlls + BASE
                            push    3                               ; Amount of functions in the 1st DLL
                            pop     ebx
load_dlls:                  push    edi
                            call    dword [POS_fnc_LoadLibrary]
                            repne   scasb                           ; go to end of string
                            push    ebx
load_functions:             push    eax
                            push    edi
                            push    eax
                            call    dword [POS_fnc_GetProcAddress]
                            stosd
                            pop     eax
                            repne   scasb                           ; go to end of string
                            dec     ebx
                            jnz     load_functions
                            pop     ebx
                            dec     ebx
                            jnz     load_dlls
                            ; ----------------------------------------------------

                            mov     esi, API_CreateWindowEx + BASE
                            mov     edi, POS_fnc_QueryPerformanceCounter
                            mov     ebp, Vars + 128 + BASE          ; MUST BE ALIGNED !!

                            lea     eax, [ebp + PixelShader]

                            push    ebp                             ; CreateDevice
                            push    Present_Buffer + BASE
                            push    D3DCREATE_SOFTWARE_VERTEXPROCESSING

                            push    D3D_SDK_VERSION                 ; Direct3DCreate9

                            push    0                               ; D3DXCompileShader
                            push    0
                            push    eax
                            push    0
                            push    PShaderProfileName + BASE
                            push    ProcedureName + BASE
                            push    0
                            push    0
                            push    (fPShader - PShader)
                            push    PShader + BASE

                            push    0                               ; SetCursor

                            push    0                               ; CreateWindowEx
                            push    0
                            push    0
                            push    0
                            push    0
                            push    0
                            push    0
                            push    0
                            push    0
                            push    0
                            push    ClassName + BASE
                            push    WS_EX_TOPMOST
                            call    dword [esi]                     ; + (API_CreateWindowEx - API_CreateWindowEx)]
                            mov     ebx, eax
                            call    dword [esi + (API_SetCursor - API_CreateWindowEx)]

                            call    dword [edi + (POS_fnc_D3DXCompileShader - POS_fnc_QueryPerformanceCounter)]

                            ; ------------------------------------------------------
                            call    dword [esi + (API_Direct3DCreate9 - API_CreateWindowEx)]

                            push    ebx
                            push    D3DDEVTYPE_HAL
                            push    D3DADAPTER_DEFAULT              ; (0)
                            push    eax
                            mov     ebx, [eax]
                            call    [ebx + IDirect3D9.CreateDevice]

                            lea     eax, [ebp + PixelShader]
                            push    eax
                            mov     eax, [eax]
                            push    eax
                            mov     ebx, [eax]
                            call    [ebx + ID3DXConstantTable.GetBufferPointer]
                            push    eax
                            mov     eax, [ebp]
                            push    eax
                            mov     ebx, [eax]
                            call    [ebx + IDirect3DDevice9.CreatePixelShader]

;                            pop     ebx                             ; ebx = D3DXCreateTextureFromFileInMemoryEx

                            lea     eax, [ebp + OldTime]
                            push    eax
                            call    dword [edi + (POS_fnc_QueryPerformanceCounter - POS_fnc_QueryPerformanceCounter)]

; ------------------------------------------------------
; Program loop
MainLoop:
                            ; ------------------------------------------------------
                            ; Obtain the frames timer
                            fild    qword [ebp + OldTime]
                            lea     eax, [ebp + CurrTime]
                            push    eax
                            call    dword [edi + (POS_fnc_QueryPerformanceCounter - POS_fnc_QueryPerformanceCounter)]
                            fild    qword [ebp + CurrTime]
                            fsubp   st1, st0
                            lea     eax, [ebp + HTimerFreq]
                            push    eax
                            call    dword [esi + (API_QueryPerformanceFrequency - API_CreateWindowEx)]
                            fild    qword [ebp + HTimerFreq]
                            fdivp   st1, st0

                            push    VK_ESCAPE                       ; GetAsyncKeyState
                            ; ------------------------------------------------------
                            ; Animate
                            push    dword 1			    ; SetPixelShaderConstantF
                            lea     ebx,[ebp + Delta]
                            fstp    dword [ebx]
                            push    ebx
                            push    dword 0

                            ; ------------------------------------------------------
                            ; Display a rectangle

                            mov     eax, [ebp]
                            push    eax
                            mov     ebx, [eax]
                            push    0                               ; Present
                            push    0
                            push    0
                            push    0
			    push    eax

                            push    eax                             ; EndScene

                            push    D3DFVF_XYZRHW_SIZE              ; DrawPrimitiveUP
                            push    BigTriangle + BASE
                            push    1
                            push    D3DPT_TRIANGLELIST
                            push    eax

                            push    D3DFVF_XYZRHW                   ; SetFVF
                            push    eax

                            push    dword [ebp + PixelShader]       ; SetPixelShader
                            push    eax

                            push    eax
                            call    [ebx + IDirect3DDevice9.BeginScene]
                            call    [ebx + IDirect3DDevice9.SetPixelShader]
                            call    [ebx + IDirect3DDevice9.SetFVF]
                            call    [ebx + IDirect3DDevice9.DrawPrimitiveUP]
                            call    [ebx + IDirect3DDevice9.EndScene]
                            call    [ebx + IDirect3DDevice9.Present]
                            call    [ebx + IDirect3DDevice9.SetPixelShaderConstantF]
                            call    dword [esi + (API_GetAsyncKeyState - API_CreateWindowEx)]
                            sahf
                            jns     MainLoop
                            call    dword [edi + (POS_fnc_exit - POS_fnc_QueryPerformanceCounter)]

; ------------------------------------------------------
; Datas

ClassName:                  db      "edi"
ProcedureName:              db      "t", 0
PShaderProfileName:         db      "ps_3_0", 0

PShader:            db "float a:register(c0);"
                    db "float4 t(float2 x:vpos):color"
                    db "{"
					db "a=a*3.125;"
					db "x.x=-1.0+0.4*(x.x/(1024.0/5.0));"
					db "x.y=-1.0+0.4*(x.y/(768.0/5.0));"
					db "float r=sqrt(x.x*x.x+x.y*x.y);"
					db "float u=atan2(x.y,x.x);"
					db "float2 q=x*1.5,s=-q;"
					db "float v=sqrt(q.x*q.x+q.y*q.y);"
					db "float w=atan2(x.x*1.5,x.y*1.5);"
					db "float z=(atan2(x.y,q.x)+atan2(q.y,x.x))/2.0;"
					db "x.x=tan(clamp((x.x-r/2.0*cos(a/8.1)+x.y/r),-1.4,1.4));"
					db "x.y=tan(clamp((x.y-r/1.5*sin(a/9.5)+x.x/r),-1.55,1.4));"
					db "q.x=tan(-clamp((q.x-r/2.5*cos(a/30.5)+q.x/u),-1.4,1.45));"
					db "q.y=tan(clamp((-q.y-v/1.3*sin(sqrt(a/10.0)/2.4)+q.y/r),-1.4,1.4));"
					db "s.x=tan(clamp((-s.x-v/2.5*cos(a/40.1313)-q.x/w),-1.5,1.4));"
					db "s.y=tan(-clamp((s.y-r/1.3*sin(a/30.414)+s.y/z),-1.4,1.49));"
					db "float b=(3.0/(sin(q.x)-cos(q.y)))/1.5;"
					db "float g=(1.0/(sin(x.x)-cos(x.y)))/0.5;"
					db "float c=(1.5/(cos(x.x)-sin(q.y)))/1.5;"
					db "float d=(2.5/(cos(q.x)+sin(q.y)))/1.5-sqrt(c/2.7);"
					db "float f=(4.5/(cos(-s.x)+sin(-s.y)))/1.5+dot(b,g)/3.0;"
					db "return float4(sqrt(g+b+c-d+f)/30.0,sqrt(g+b+c-d+f)/30.0,sqrt(g+b+c-d+f)/18.0,1);"
                    db "}"
					
fPShader:

                            ; -------------------------------
table_dlls:
                            ; 3 functions
                            db      "user32", 0
API_CreateWindowEx:         db      "CreateWindowExA", 0
API_SetCursor:              db      "SetCursor", 0
API_GetAsyncKeyState:       db      "GetAsyncKeyState", 0

                            ; 2 functions
                            db      "d3d9", 0
API_Direct3DCreate9:        db      "Direct3DCreate9", 0
                            dd      0
                            db      0

                            ; 1 function
                            db      "kernel32", 0
API_QueryPerformanceFrequency:
                            db      "QueryPerformanceFrequency", 0

Present_Buffer:             dd      SCREENX                     ; dpBackBufferWidth
                            dd      SCREENY                     ; dpBackBufferHeight
                            dd      SCREENDEPTH                 ; dpBackBufferFormat
                            dd      0                           ; dpBackBufferCount
                            dd      0                           ; dpMultiSampleType
                            dd      0                           ; dpMultiSampleQuality
BigTriangle:                dd      D3DSWAPEFFECT_DISCARD       ; dpSwapEffect
                            dd      0                           ; dphDeviceWindow
                            %ifdef DEBUG
                            dd      1                           ; dpWindowed / Windowed = 1 / Fullscreen = 0
                            %else
                            dd      0                           ; dpWindowed / Windowed = 1 / Fullscreen = 0
                            %endif
                            dd      0                           ; dpEnableAutoDepthStencil
                            dd      2048.0                      ; dpAutoDepthStencilFormat (D3DFMT_D16)
                            dd      0                           ; dpFlags
                            dd      0                           ; dpFullScreen_RefreshRateInHz
                            dd      0                           ; dpFullScreen_PresentationInterval
                            dd      0
                            dd      2048.0

                            ; Note: the packer strips any 0 located
                            ; at the end of the file (including the flt above)
                            ; this can eventually be used as a bss section
Vars:
; ------------------------------------------------------
