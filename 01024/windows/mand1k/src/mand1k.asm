; ------------------------------------------------------
; mand1k by titan
; released on nordlicht 2012
; ------------------------------------------------------
; idea,visuals:    neoman
; audio:           neoman+jix
; modified 1kpack: jix
; ------------------------------------------------------
; yes, with sound. run debug.bat to compile the intro
; as windowed version and release.bat to compile and 
; pack the intro with our modified 1kpack, which uses
; kzip + deflopt to reach better results. probably
; you have to execute it several times to reach 1024 =P
; ------------------------------------------------------
; http://www.pouet.net/prod.php?which=59557
; ------------------------------------------------------
; ~based on~° 1kpack d3d framework  - thanks for that <3
; ------------------------------------------------------
; Header
                                bits    32

; ------------------------------------------------------
; Includes
                                %include "d3d9_nasm.inc"

; ------------------------------------------------------
; Pre-processor constants
;%define DEBUG

; ------------------------------------------------------
; User constants
SCREENX                         equ     1024
SCREENY                         equ     768
WAVERATE                        equ     44100
WAVELEN                         equ     63*((2972*2*WAVERATE)/1000) ; 2.972 secs for one tone * 63 tones = 187.236 secs
TONECOUNT                       equ     8 - 1

; ------------------------------------------------------
; Constants
WS_EX_TOPMOST                   equ     0x8
VK_ESCAPE                       equ     0x1b
WS_CAPTION                      equ     0xc00000
WS_POPUP                        equ     0x80000000
WS_BORDER                       equ     0x800000
WS_SYSMENU                      equ     0x80000
WS_VISIBLE                      equ     0x10000000
WS_THICKFRAME                   equ     0x40000
WS_POPUPWINDOW                  equ     WS_BORDER | WS_SYSMENU | WS_CAPTION | WS_VISIBLE | WS_THICKFRAME
SW_SHOWNORMAL                   equ     1

PM_REMOVE                       equ     0x1

SCREENDEPTH                     equ     D3DFMT_A8R8G8B8     ; 32 bits

D3DFVF_XYZRHW_SIZE              equ     (4 * 4)

BASE                            equ     0x420000

; Those are located inside the depacker
POS_fnc_exit                    equ     0x410090
POS_fnc_D3DXCompileShader       equ     0x410094
POS_fnc_LoadLibrary             equ     0x4100b4
POS_fnc_GetProcAddress          equ     0x4100b8
POS_fnc_GetTickCount            equ     0x4100bc
;POS_fnc_QueryPerformanceCounter equ     0x4100bc

; !!! Only valid for d3dx9_30.dll !!!
D3DX_D3DXCompileShader          equ     0xda6de
D3DX_D3DXCreateTextureFromFileInMemoryEx equ    (D3DX_D3DXCompileShader - 0xc1341)
D3DX_D3DXCreateTexture          equ     (D3DX_D3DXCompileShader - 0xbe4a2)

; ------------------------------------------------------
; Structures

; ------------------------------------------------------
; Vars datas
Device                          equ     0
OldTime                         equ     Device + 4
PixelShader                     equ     OldTime + 4
FTime                           equ     PixelShader + 4
SinTemp                         equ     FTime + 4

; ---------------------------------------------------------
; Program entry point
; edi contains D3DXCompileShader address
                                org     BASE

EntryPoint:                     ;sub     edi, D3DX_D3DXCreateTextureFromFileInMemoryEx
                                ;; stack contains D3DXCreateTextureFromFileInMemoryEx
                                ;push    edi

                                ; Import the functions we need
                                mov     edi, table_dlls
load_dlls:                      push    edi
                                call    dword [POS_fnc_LoadLibrary]
                                test    eax, eax
                                jz      done_dlls
                                push    -1                              ; Fix a problem with windows 7
                                pop     ecx
                                repne   scasb                           ; Go to end of string
load_functions:                 xchg    ebx, eax                        ; DLL handle
                                push    edi
                                push    ebx
                                call    dword [POS_fnc_GetProcAddress]
                                test    eax, eax
                                jz      load_dlls
                                stosd
                                xchg    ebx, eax
                                repne   scasb                           ; Go to end of string
                                jmp     load_functions
done_dlls:
                                ; ----------------------------------------------------

                                mov     esi, API_CreateWindowEx
                                mov     edi, POS_fnc_GetTickCount
                                mov     ebp, Vars                       ; MUST BE ALIGNED !!

                                lea     eax, [ebp + PixelShader]

                                push    ebp                             ; CreateDevice
                                push    Present_Buffer
                                push    D3DCREATE_SOFTWARE_VERTEXPROCESSING

                                push    D3D_SDK_VERSION                 ; Direct3DCreate9

                                push    0                               ; D3DXCompileShader
                                push    0
                                push    eax
                                push    0
                                push    PShaderProfileName
                                push    ProcedureName
                                push    0
                                push    0
                                push    (fPShader - PShader)
                                push    PShader

                                %ifndef DEBUG
                                push    0                               ; SetCursor
                                %endif

                                push    0                               ; CreateWindowEx
                                push    0
                                push    0
                                push    0
                                %ifdef DEBUG
                                push    SCREENY
                                push    SCREENX
                                %else
                                push    0
                                push    0
                                %endif
                                push    0
                                push    0
                                %ifdef DEBUG
                                push    WS_POPUPWINDOW
                                %else
                                push    0
                                %endif
                                push    0
                                push    ClassName
                                %ifdef DEBUG
                                push    0
                                %else
                                push    WS_EX_TOPMOST
                                %endif
                                call    dword [esi]                     ; + (API_CreateWindowEx - API_CreateWindowEx)]
                                mov     ebx, eax
                                %ifdef DEBUG
                                push    SW_SHOWNORMAL
                                push    eax
                                call    dword [esi + (API_ShowWindow - API_CreateWindowEx)]
                                %else
                                call    dword [esi + (API_SetCursor - API_CreateWindowEx)]
                                %endif

                                call    dword [edi + (POS_fnc_D3DXCompileShader - POS_fnc_GetTickCount)]

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

;                               pop     ebx                             ; ebx = D3DXCreateTextureFromFileInMemoryEx

; ------------------------------------------------------
; Initialize sound
                                ;finit

                                ; Allocate memory for sound (+ delay)
                                mov     ecx, (WAVELEN + (WaveData - WaveHeader)) * 4
                                push    ecx
                                push    0
                                call    dword [esi + (API_GlobalAlloc - API_CreateWindowEx)]

                                ; Push address to wave
                                push    eax

                                ; Prepare generation
                                push    edi
                                mov     edx, WaveHeader
                                mov     edi, eax
                                mov     ecx, (WAVELEN + (WaveData - WaveHeader)) / 2


                                ; Check if we're in header or synth
SoundGen:                       cmp     ecx, WAVELEN / 2
                                jge     SoundHeader

                                ; ----------------------------------------------------------------------------
                                ; white noise
SoundNext:                      push    ecx
                                neg     ecx
                                add     ecx, WAVELEN / 2

                                ; ----------------------------------------------------------------------------
                                ; yep, we're using the .exe itself as "noise source"
                                push    ecx
                                mov     ebx, ecx
                                shr     ecx, 6
                                and     ecx, 0x2ff
                                mov     dx, word [EntryPoint + ecx]
                                pop     ecx
                                sub     dx, 0x7fff
                                sar     dx, 3

                                ; ----------------------------------------------------------------------------
                                ; add sine
                                shr     ebx, 14
                                and     ebx, TONECOUNT
                                push    ecx
                                fild    dword [esp]
                                fidiv   word [Tones + ebx * 2]
                                pop     ecx
                                fsin
                                fimul   word [SinVolume]
                                fistp   dword [ebp + SinTemp]
                                add     dx, word [ebp + SinTemp]

                                ; ----------------------------------------------------------------------------
                                ; lowpass (last sample * 7 / 8 + current sample * 1 / 8)
                                movsx   eax, word [edi - 2]
                                imul    eax, 7
                                sar     eax, 3
                                sar     dx, 3
                                add     ax, dx

                                ; ----------------------------------------------------------------------------
                                ; finished sample is in ax, continue!

NextSample:                     sar     ax, 1
                                add     word [edi], ax
                                ; "flanger-echo"
                                shr     ecx, 14
                                shl     ecx, 4
                                add     word [edi + ecx], ax 
                                pop     ecx
SoundPart2:                     add     edi, 2
                                jmp     SoundLoop

                                ; Copy header
SoundHeader:                    mov     eax, [edx]
                                add     edx, 4
                                stosd

                                ; Next word
SoundLoop:                      dec     ecx
                                jne     SoundGen

                                pop     edi

; ------------------------------------------------------
; Play sound
                                ; Pop address to sound
                                pop     eax

                                ; Play
                                push    SND_MEMORY | SND_ASYNC
                                push    0
                                push    eax
                                call    dword [esi + (API_PlaySound - API_CreateWindowEx)]

; ------------------------------------------------------
; Start timer
                                call    dword [edi + (POS_fnc_GetTickCount - POS_fnc_GetTickCount)]
                                mov     [ebp + OldTime], eax

; ------------------------------------------------------
; Program loop
MainLoop:
                                %ifdef DEBUG
                                push    PM_REMOVE
                                push    0
                                push    0
                                push    0
                                push    Msg
                                call    dword [esi + (API_PeekMessage - API_CreateWindowEx)]
                                test    eax, eax
                                jz      No_Msg
                                push    Msg
                                call    dword [esi + (API_TranslateMessage - API_CreateWindowEx)]
No_Msg:
                                %endif

                                ; ------------------------------------------------------
                                ; Obtain the frames timer
                                call    dword [edi + (POS_fnc_GetTickCount - POS_fnc_GetTickCount)]
                                sub     eax, [ebp + OldTime]
                                push    eax
                                fild    dword [esp]
                                fidiv   word [TimeDivider]
                                pop     eax

                                ; ------------------------------------------------------
                                ; Time
                                fstp    dword [ebp + FTime]
                                lea     ecx, [ebp + FTime]

                                ; ------------------------------------------------------
                                ; Display a rectangle
                                push    VK_ESCAPE                       ; GetAsyncKeyState

                                push    0                               ; Present
                                push    0
                                push    0
                                push    0
                                mov     eax, [ebp]
                                push    eax
                                mov     ebx, [eax]

                                push    eax                             ; EndScene

                                push    D3DFVF_XYZRHW_SIZE              ; DrawPrimitiveUP
%ifndef DEBUG
                                push    BigTriangle
%else
                                push    BigTriangleDebug
%endif
                                push    1
                                push    D3DPT_TRIANGLELIST
                                push    eax

                                push    D3DFVF_XYZRHW                   ; SetFVF
                                push    eax

                                push    dword [ebp + PixelShader]       ; SetPixelShader
                                push    eax

                                push    1                               ; (Nbr) SetPixelShaderConstantF
                                push    ecx
                                push    0                               ; First constant register number
                                push    eax

                                push    eax
                                call    [ebx + IDirect3DDevice9.BeginScene]
                                call    [ebx + IDirect3DDevice9.SetPixelShaderConstantF]
                                call    [ebx + IDirect3DDevice9.SetPixelShader]
                                call    [ebx + IDirect3DDevice9.SetFVF]
                                call    [ebx + IDirect3DDevice9.DrawPrimitiveUP]
                                call    [ebx + IDirect3DDevice9.EndScene]
                                call    [ebx + IDirect3DDevice9.Present]
                                call    dword [esi + (API_GetAsyncKeyState - API_CreateWindowEx)]
                                sahf
                                jns     MainLoop
                                call    dword [edi + (POS_fnc_exit - POS_fnc_GetTickCount)]

; ------------------------------------------------------
; Datas
                                %ifdef DEBUG
Msg:                            times   100 db 0
                                %endif

ClassName:                      db      "edi"
ProcedureName:                  db      "t", 0
PShaderProfileName:             db      "ps_3_0", 0

PShader:                        db      "float4 f;"
                                db      "float4 t(float2 x:vpos):color"
                                db      "{"
                                ; start (t=time,a,b=rot,c=pos,d=tmp)
                                db          "float4 t=max(18.7236-f.x,0.),a,b,c=float4(x.x/512.,x.y/384.,t.x*10.,1.)-1.,d=c;"
                                ; 2d rotation + spiral modulation
                                db            "sincos(min(t.x,1.)*sin(length(c.xy)+t.x)*4.,a,b);"
                                db            "d.x=c.x*b-c.y*a;" ; rot x
                                db            "d.y=c.y*b+c.x*a;" ; rot y
                                ; iterate slice of 3d mandelbox (min/max method)
                                db          "for(int i=0;i<20;i++)"
                                db                "d=clamp(d,-1.,1.)*3.-d,"
                                db                "d*=3.*sin(t.x)/dot(d,d),"
                                db                "d-=abs(d)*i*.01;"
                                ; color mods
                                db            "d*=d*=1.-dot(d,d);"
                                ; greyscale with some red and blue oil =p
                                db            "d*=.2;d.gb=dot(d,float3(.3,.6,.1));"
                                ; fade in, fade out + return ready color
                                db          "return min(t.x,1.)*min(f.x*.5,1.)*d;"
                                db      "}"
fPShader:

                                ; -------------------------------
table_dlls:                     db      "user32", 0
API_CreateWindowEx:             db      "CreateWindowExA", 0
                                %ifdef DEBUG
API_ShowWindow:                 db      "ShowWindow", 0
                                %else
API_SetCursor:                  db      "SetCursor", 0
                                %endif
API_GetAsyncKeyState:           db      "GetAsyncKeyState", 0
                                %ifdef DEBUG
API_PeekMessage:                db      "PeekMessageA", 0
API_TranslateMessage:           db      "TranslateMessage", 0
                                %endif
                                db        "kernel32", 0
API_GlobalAlloc:                db        "GlobalAlloc",0
                                db      "d3d9", 0
API_Direct3DCreate9:            db      "Direct3DCreate9", 0
                                db        "winmm", 0
API_PlaySound:                    db        "PlaySound",0

Present_Buffer:                 dd      SCREENX                     ; dpBackBufferWidth
                                dd      SCREENY                     ; dpBackBufferHeight
                                dd      SCREENDEPTH                 ; dpBackBufferFormat
                                dd      0                           ; dpBackBufferCount
                                dd      0                           ; dpMultiSampleType
                                dd      0                           ; dpMultiSampleQuality
BigTriangle:                    dd      D3DSWAPEFFECT_DISCARD       ; dpSwapEffect
                                dd      0                           ; dphDeviceWindow
                                ; dpWindowed / Windowed = 1 / Fullscreen = 0
                                %ifdef DEBUG
                                dd      1
                                %else
                                dd      0
                                %endif
                                dd      0                           ; dpEnableAutoDepthStencil
                                dd      2048.0                      ; dpAutoDepthStencilFormat (D3DFMT_D16)
                                dd      0                           ; dpFlags
                                dd      0                           ; dpFullScreen_RefreshRateInHz
                                dd      0                           ; dpFullScreen_PresentationInterval
                                dd      0
                                dd      2048.0

%ifdef DEBUG
BigTriangleDebug:               dd      0.0
                                dd      0.0
                                dd      0.0
                                dd      1.0

                                dd      2048.0
                                dd      0.0
                                dd      0.0
                                dd      1.0

                                dd      0.0
                                dd      2048.0
                                dd      0.0
                                dd      1.0
%endif

SinVolume:                      dw      4096
Tones:                          dw      11, 10, 9, 7, 10, 13, 14, 17
TimeDivider:                    dw      10000
WaveHeader:                     db      "RIFF"
                                dd      4 + 24 + 8 + WAVELEN
                                db      "WAVE"
                                db      "fmt "
                                dd      16
                                dw      1 ; PCM
                                dw      1
                                dd      WAVERATE
                                dd      WAVERATE*2
                                dw      2
                                dw      16
                                db      "data"
                                dd      WAVELEN
WaveData:                       dd      0
                                ; Note: the packer strips any 0 located
                                ; at the end of the file (including the flt above)
                                align   8
Vars:
; ------------------------------------------------------
