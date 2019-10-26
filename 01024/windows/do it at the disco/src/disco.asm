; ------------------------------------------------------
; 1kPack v0.7 - Framework
; Written by Franck "hitchhikr" Charlet / Neural
; ------------------------------------------------------
; Thanks to rbraz for the trianglelist trick.
; ------------------------------------------------------
; buildblock RELEASE
; CAPT "[SOURCEDIR]nasmw.exe" -f bin "%2" -o "%1.bin" -s -O9
; CAPT "[SOURCEDIR]1kpack.exe" "%1.bin"
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
WS_EX_TOPMOST                           equ     0x8
VK_ESCAPE                               equ     0x1b

SCREENX                                 equ     640
SCREENY                                 equ     480
SCREENDEPTH                             equ     D3DFMT_A8R8G8B8     ; 32 bits

D3DFVF_XYZRHW_SIZE          equ     (4 * 4)

BASE                                    equ     0x420000

; Those are located inside the depacker
POS_fnc_exit                            equ     0x410090
POS_fnc_D3DXCompileShader               equ     0x410094
POS_fnc_LoadLibrary                     equ     0x4100b4
POS_fnc_GetProcAddress                  equ     0x4100b8
POS_fnc_QueryPerformanceCounter         equ     0x4100bc

; !!! Only valid for d3dx9_30.dll !!!
D3DX_D3DXCompileShader      equ     0xda6de
D3DX_D3DXCreateTextureFromFileInMemoryEx equ    (D3DX_D3DXCompileShader - 0xc1341)
D3DX_D3DXCreateTexture      equ     (D3DX_D3DXCompileShader - 0xbe4a2)

; ------------------------------------------------------
; Structures

; ------------------------------------------------------
; Vars datas
Device                              equ     0
;OldTime                             equ     Device + 4
;HTimerFreq                          equ     OldTime + 8
PixelShader                         equ     Device + 4
TimeElapsed                         equ     PixelShader + 4
OldTimeElapsed		            equ     TimeElapsed + 4


                                    .code

; ---------------------------------------------------------
; Program entry point
; base address = 0x420000
; edi contains D3DXCompileShader
EntryPoint:                         ;sub     edi, D3DX_D3DXCreateTextureFromFileInMemoryEx
                            ;; stack contains D3DXCreateTextureFromFileInMemoryEx
                                    ;push    edi

                            ; Import the functions we need
                                    mov     edi, table_dlls + BASE
                                    push    3                                           ; Amount of functions in the 1st DLL
                                    pop     ebx
load_dlls:                          push    edi
                                    call    dword [POS_fnc_LoadLibrary]
                                    repne   scasb                                       ; go to end of string
                                    push    ebx
load_functions:                     push    eax
                                    push    edi
                                    push    eax
                                    call    dword [POS_fnc_GetProcAddress]
                                    stosd
                                    pop     eax
                                    repne   scasb                                       ; go to end of string
                                    dec     ebx
                                    jnz     load_functions
                                    pop     ebx
                                    dec     ebx
                                    jnz     load_dlls
                                    ; ----------------------------------------------------

                                    mov     esi, API_CreateWindowEx + BASE
                                    mov     edi, POS_fnc_QueryPerformanceCounter
                                    mov     ebp, Vars + 128 + BASE                      ; MUST BE ALIGNED !!

                                    lea     eax, [ebp + PixelShader]                    

                                    push    ebp                                         ; CreateDevice
                                    push    Present_Buffer + BASE
                                    push    D3DCREATE_SOFTWARE_VERTEXPROCESSING

                                    push    D3D_SDK_VERSION                             ; Direct3DCreate9

                                    push    0                                           ; D3DXCompileShader
                                    push    0
                                    push    eax
                                    push    0
                                    push    PShaderProfileName + BASE
                                    push    ProcedureName + BASE
                                    push    0
                                    push    0
                                    push    (fPShader - PShader)
                                    push    PShader + BASE

                                    push    0                                           ; SetCursor

                                    push    0                                           ; CreateWindowEx
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
                                    push    D3DADAPTER_DEFAULT                          ; (0)
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

;                                   pop     ebx                ; ebx = D3DXCreateTextureFromFileInMemoryEx


                                    ;lea     eax, [ebp + OldTime]
                                    ;push    eax
                                    ;call    dword [edi + (POS_fnc_QueryPerformanceCounter - POS_fnc_QueryPerformanceCounter)]  ;OldTime = QueryPerformanceCounter

call    dword [esi + (API_timeGetTime - API_CreateWindowEx)]
mov     dword [ebp + OldTimeElapsed], eax

; ------------------------------------------------------
; Program loop
MainLoop:
                                    ; ------------------------------------------------------
                                    ; Obtain the frames timer

				    ;fild    qword [ebp + OldTime] ;Save oldtime
				    ;lea     eax, [ebp + OldTime]
                                    ;push    eax
                                    ;call    dword [edi + (POS_fnc_QueryPerformanceCounter - POS_fnc_QueryPerformanceCounter)] ;OldTime = QueryPerformanceCounter


				    ;fild    qword [ebp + TimeElapsed]
                                    ;fsubp   st1, st0              ;ST0 = ST1 - OldTime
                                    
				    ;lea     eax, [ebp + HTimerFreq]
                                    ;push    eax
                                    ;call    dword [esi + (API_QueryPerformanceFrequency - API_CreateWindowEx)] ; HTimerFreq = QueryPerformanceFrequency

                                    ;fild    qword [ebp + HTimerFreq]
				    ;fdivp   st1, st0   ;ST0 = DeltaTime / HTimerFreq



;fldz       ; try uncomment this !!!
;fmulp st1  ;
;fld1       ;

;push eax
call    dword [esi + (API_timeGetTime - API_CreateWindowEx)]
sub eax, dword [ebp + OldTimeElapsed]
mov     dword [ebp + TimeElapsed], eax
fild    dword [ebp + TimeElapsed]
fstp	dword [ebp + TimeElapsed]

;pop eax


                                    ; ------------------------------------------------------
                                    ; Animate			    
				    ;fadd	dword [ebp + TimeElapsed]
				    ;fstp	dword [ebp + TimeElapsed]
				    lea	ecx,    [ebp + TimeElapsed]



                                    ; ------------------------------------------------------
                                    ; Display a rectangle
                                    push    VK_ESCAPE                           ; GetAsyncKeyState

                                    push    0                                   ; Present
                                    push    0
                                    push    0
                                    push    0
                                    mov     eax, [ebp]
                                    push    eax
                                    mov     ebx, [eax]


                                    push    eax                                 ; EndScene



			            push    D3DFVF_XYZRHW_SIZE                  ; DrawPrimitiveUP
                                    push    BigTriangle + BASE
                                    push    1
                                    push    D3DPT_TRIANGLELIST
                                    push    eax




                                    push    D3DFVF_XYZRHW                       ; SetFVF
                                    push    eax




                                    push    dword [ebp + PixelShader]           ; SetPixelShader
                                    push    eax

    
				    push    1					; (Nbr) SetPixelShaderConstantF
				    push    ecx
				    push    0					; First constant register number
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
                                    call    dword [edi + (POS_fnc_exit - POS_fnc_QueryPerformanceCounter)]

; ------------------------------------------------------
; Datas

ClassName:                          db      "edi"
ProcedureName:                      db      "t", 0
PShaderProfileName:                 db      "ps_3_0", 0




PShader:                          db	"float f,x,y,u,v,k,q,c,l,i;"
db	"float4 s(float2 p,float z):COLOR"
db	"{"
db		"l=3.1415;"
db		"k=f*sign(z)*.0005;"
db		"x=(p.x-320)*(.0065)*z;"
db		"y=(p.y-240)*(.006)*z;"
;db "if (z<.9) return 0; else{"
db		"c=sqrt(x*x+y*y);"
db		"if(c>1) return 0;"
db		"else{u=-.4*sign(z)+sin(k*.05);"
db		"v=sqrt(1-x*x-y*y);q=y*sin(u)-v*cos(u);"
db		"y=y*cos(u)+v*sin(u);"
db		"v=acos(y);"
db		"u=acos(x/sin(v))/(2*l)*120*sign(q)-k;"
db		"v=v*60/l;"
db		"q=cos((float)int(v/l));"
db		"c=pow(abs(cos(u)*sin(v)),.2)*.1/(q+sin(int((u+l/2)/l)+k*.6+cos(q*25)))*pow(1-c,.9);"

;db		"if(c<0)"
;db		" return float4(-c/2*abs(cos(t*.1)),0,-c*2*abs(sin(t*.12)),1);"
;db		"else"
;db		" return float4(c,c*2,c*2,1);}"

db		"return c<0?float4(-c/2*abs(cos(k*.1)),0,-c*2*abs(sin(k*.04)),1):float4(c,c*2,c*2,1);}"
;db		"return c<0?float4(-c/2,0,-c*2,1):float4(c,c*2,c*2,1);}"


db 	"}";
db	"float4 t(float2 p:VPOS):COLOR"
db	"{"
;db 		"float b;b=1+max((sin(f)*32),0);p.x=int(p.x/b)*b;p.y=int(p.y/b)*b;"
db		"float4 c,d;"
db		"for(i=80;i>0;i--)"
;db		"{"
db			"c+=s(p,1-i/80.0)*(.008-i*.00005);"
;db		"}"
db		"d=s(p,1);"
;db		"return s(p,-.2)*(1-d.a)*.02+(d*d.a)+sqrt(c);"
;db		"return lerp(s(p,-.2)*.02,d,d.a)+sqrt(c);"
db		"return (d.a==0?s(p,-.2)*.02:d)+sqrt(c);"
db	"}"

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
;                                    db      "kernel32", 0
;API_QueryPerformanceFrequency:  
;                            db      "QueryPerformanceFrequency", 0


                                    ; 1 function
                                    db      "winmm", 0
API_timeGetTime             db      "timeGetTime", 0









Present_Buffer:                     dd      SCREENX                 ;dpBackBufferWidth
                                    dd      SCREENY                 ;dpBackBufferHeight
                                    dd      SCREENDEPTH             ;dpBackBufferFormat
                                    dd      0                       ;dpBackBufferCount
                                    dd      0                       ;dpMultiSampleType
                                    dd      0                       ;dpMultiSampleQuality
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
align 8

Vars:
; ------------------------------------------------------
