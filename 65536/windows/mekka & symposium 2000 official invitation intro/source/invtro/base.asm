; ms2k invitation
;
; base

; -------------------------------------------- includes and definitions -----

bits          32

%include      "win32.inc"
%include      "ddraw.inc"

%define       COMOBJCOUNT 16           ; maximum number of COM objects

; ---------------------------------------------------- initialized data -----

section       .data

classname     db 'scala.family',0

; just for the taste of it:

posermsg:
  db 'copyright (c) 2000 SCALA productions',0

WINDOWCLASS:
  .style          dd 0
  .lpfnWndProc    dd myWinProc
  .cbClsExtra     dd 0
  .cbWndExtra     dd 0
  .hInstance      dd 0
  .hIcon          dd 0
  .hCursor        dd 0
  .hbrBackground  dd 0
  .lpszMenuName   dd 0
  .lpszClassName  dd classname

IID_IDirectDraw4:
  dd 0x9c59509a
  dw 0x39bd,0x11d1
  db 0x8c,0x4a,0x00,0xc0,0x4f,0xd9,0x30,0xc5

MODE:
  .xres           dd 640
  .yres           dd 480
  .bpp            dd 32

; error messages

Errors:
  .mmx            db "CPU with MMX support required",0
  .win            db "Can't create window",0
  .winerr         db "Windows error",0
  .createDDraw    db "Can't create DirectDraw Object (needs DX 7.0)",0
  .DDrawSetup     db "Error during DirectDraw setup",0
  .DDraw          db "DirectDraw error",0

  decompress      db "please wait while decompressing...",0

; writer strings

%define           MSGCOUNT             16

Writer:
  .amable         db "Amable",0
  .avena          db "Avena",0
  .ctl            db "CTL",0
  .codered        db "Code Red",0
  .cubic          db "Cubic & $een",0
  .destiny        db "Destiny",0
  .elitegroup     db "Elitegroup",0
  .feb            db "FEB",0
  .lego           db "Lego",0
  .padua          db "Padua",0
  .pandemonium    db "Pandemonium",0
  .phantasm       db "Phantasm",0
  .polka          db "Polka Brothers",0
  .smash          db "Smash Designs",0
  .arevery        db "are very proud",0
  .present        db "to present",0
  .seq            dd .amable,.avena,.ctl,.codered,.cubic,.destiny,.elitegroup
                  dd .feb,.lego,.padua,.pandemonium,.phantasm,.polka,.smash,
                  dd .arevery,.present

  .ms2k           db "Mekka & Symposium 2000",0
  .expect         db "- expect nothing -",0

textfade      dd 127

; psphere

extern        flashtime

; data

extern        _pal
extern        _cursor
extern        _topaz8

; mxmfile:

mxmfile       incbin "data\elite.mxm"

; -------------------------------------------------- uninitialized data -----

section       .bss

global        font
global        vScreen
global        vPitch

initStack     resd 1
errorPtr      resd 1
hWnd          resd 1
retAddr       resd 1
mBackbuffer   resd 1
threadId      resd 1
threadHandle  resd 1
timeStart     resd 1
font          resd 1
mainthread    resd 1

exit          resd 1
work          resd 1
tempobj       resd 1

struc WAVEFORMATEX
  .wFormatTag      resw 1       ; format type
  .nChannels       resw 1       ; number of channels (i.e. mono, stereo...)
  .nSamplesPerSec  resd 1       ; sample rate
  .nAvgBytesPerSec resd 1       ; for buffer estimation
  .nBlockAlign     resw 1       ; block size of data
  .wBitsPerSample  resw 1       ; number of bits per sample of mono data
  .cbSize          resw 1       ; the count in bytes of the size of extra bytes
  .size
endstruc

struc dsdata
  .sbuf      resd 1             ; ptr to the secondary IDirectSoundBuffer
  .pbuf      resd 1             ; ptr to the primary   IDirectSoundBuffer
  .dssd      resd 1             ; ptr to the IDirectSound instance
  .exitreq   resd 1             ; exit request flag for sound thread
  .thndl     resd 1             ; handle of sound thread
  .buf1      resd 1             ; 1st locked buffer address for streaming
  .len1      resd 1             ; length of 1st buffer
  .buf2      resd 1             ; 2nd locked buffer address for streaming
  .len2      resd 1             ; length of 2nd buffer
  .towrite   resd 1             ; bytes to write
  .curpos    resd 1             ; current read position on buffer
  .lastpos   resd 1             ; last write position in buffer
  .dummy     resd 1             ; dummy dword for thread ID
  .tempwfx   resb WAVEFORMATEX.size
  .mxmheap   resb 10000h        ; resource memory for MXMPlay
  .mixbuffer resd 40000h        ; 32bit stereo mixing buffer
  .wholepos  resd 1             ; current playing pos high
  .size
endstruc

struc mxmheader
  .MXMSig             resd 1
  .NOrders            resd 1
  .OrdLoopStart       resd 1
  .NChannels          resd 1
  .NPatterns          resd 1
  .NInstruments       resd 1
  .IniTempo           resb 1
  .IniBPM             resb 1
  .Options            resw 1
  .SampTable          resd 1
  .SampMem8           resd 1
  .SampMem16          resd 1
  .PitchMin           resd 1
  .PitchMax           resd 1
  .PanPos             resb 32
  .OrderTable         resb 256
  .InstrTable         resd 128
  .PatternTable       resd 256
  .size
endstruc

struc instrument
  .NSamples          resd 1
  .Samples           resb 96
  .VolFade           resw 1
  .VibType           resb 1
  .VibSweep          resb 1
  .VibDepth          resb 1
  .VibRate           resb 1
  .VNum              resb 1
  .VSustain          resb 1
  .VLoopS            resb 1
  .VLoopE            resb 1
  .VEnv              resw 24
  .PNum              resb 1
  .PSustain          resb 1
  .PLoopS            resb 1
  .PLoopE            resb 1
  .PEnv              resw 24
  .reserved          resb 46
  .size:
endstruc

struc sample
  .LoopStart         resd 1
  .End               resd 1
  .MixMode           resb 1
  .DefVol            resb 1
  .DefPan            resb 1
  .NormNote          resw 1
  .Index             resw 1
  .reserved          resb 1
endstruc
alignb        4

globdat:     resb dsdata.size

DDSURFACEDESC2:
  .dwSize             resd 1
  .dwFlags            resd 1
  .dwHeight           resd 1
  .dwWidth            resd 1
  .lPitch             resd 1
  .dwBackBufferCount  resd 1
  .dwRefreshRate      resd 1
  .dwAlphaBitDepth    resd 1
  .dwReserved         resd 1
  .lpSurface          resd 1
  .dwEmptyFaceColor   resd 1
  .dummy              resd 1
  .ddckCKDestBltLow   resd 1
  .ddckCKDestBltHigh  resd 1
  .ddckCKSrcOvrLow    resd 1
  .ddckCKSrcOvrHigh   resd 1
  .ddckCKSrcBltLow    resd 1
  .ddckCKSrcBltHigh   resd 1

DDPIXELFORMAT:
  .dwSize             resd 1
  .dwFlags            resd 1
  .dwFourCC           resd 1
  .dwRGBBitCount      resd 1
  .dwRBitMask         resd 1
  .dwGBitMask         resd 1
  .dwBBitMask         resd 1
  .dwABitMask         resd 1
  .size:

DDSCAPS2:
  .dwCaps             resd 1
  .dwCaps2            resd 1
  .dwCaps3            resd 1
  .dwCaps4            resd 1

DDSD2_TEXTURESTAGE    resd 1
DDSD2_SIZE:

MSG:
  .hwnd               resd 1
  .message            resd 1
  .wParam             resd 1
  .lParam             resd 1
  .time               resd 1
  .x                  resd 1
  .y                  resd 1

comObjects    resd COMOBJCOUNT

; com object indices

%define       mDDraw    ((COMOBJCOUNT-1)*4)
%define       mSurface  ((COMOBJCOUNT-2)*4)
%define       mPalette  ((COMOBJCOUNT-3)*4)
%define       mDSound   ((COMOBJCOUNT-4)*4)

vScreen       resd 1
vPitch        resd 1

; sound stuff

%define       SAMPLECOUNT 32

smptable      resd SAMPLECOUNT
smpmem        resb 3072000

; -------------------------------------------- code section starts here -----

section       .code

; kernel32

extern        _GetModuleHandleA@4
extern        _Sleep@4
extern        _CreateThread@24
extern        _WaitForSingleObject@8
extern        _GetTickCount@0
extern        _LocalFree@4
extern        _GetCurrentThread@0
extern        _SetThreadPriority@8

; user32

extern        _RegisterClassA@4
extern        _CreateWindowExA@48
extern        _ShowWindow@8
extern        _ShowCursor@4
extern        _UpdateWindow@4
extern        _DefWindowProcA@16
extern        _GetSystemMetrics@4
extern        _MessageBoxA@16
extern        _PostQuitMessage@4
extern        _GetMessageA@16
extern        _PostMessageA@16
extern        _PeekMessageA@20
extern        _TranslateMessage@4
extern        _DispatchMessageA@4
extern        _GetForegroundWindow@0
extern        _Sleep@4

; ddraw

extern        _DirectDrawCreate@12

; dsound

extern        _DirectSoundCreate@12

; psphere

extern        psphereInit
extern        psphereRender

; font

extern        fontCreate
extern        fontDestroy

; mxmplay/w

extern        xmpInit
extern        xmpRender
extern        xmpPlay

; synth

extern        _syRender@12

; workbench

extern        initWorkbench
extern        quitWorkbench
extern        workbenchFrame

extern        workbenchMouseHandler
extern        workbenchKeyHandler

; exports

global        lockScreen
global        updateScreen
global        getTime
global        _dd_setpal@4

; ------------------------------------------------------ win32 gespacke -----

myWinProc:                             ; window proc
  push     ebp
  mov      ebp, esp

  mov      eax, [ebp+12]
  cmp      eax, WM_CLOSE
  je       .close
  cmp      eax, WM_KEYDOWN
  je       .keydown
  cmp      eax, WM_LBUTTONDOWN
  je       .ldown
  cmp      eax, WM_LBUTTONDBLCLK
  je       .ldouble
  cmp      eax, WM_LBUTTONUP
  je       .lup
  cmp      eax, WM_MOUSEMOVE
  je       .move
  cmp      eax, WM_RBUTTONDOWN
  je       .rdown
  cmp      eax, WM_RBUTTONUP
  je       .rup

.default:
  push     dword [ebp+20]
  push     dword [ebp+16]
  push     dword [ebp+12]
  push     dword [ebp+8]
  call     _DefWindowProcA@16
  jmp      short .end

.close:
  pushad
  inc      dword [exit]
  call     deinit
  popad

  jmp      short .default

.keydown:
  mov      eax, [ebp+16]
  cmp      eax, 0x1b                   ; VK_ESCAPE
  jne      .keyproc

  xor      eax, eax
  push     eax
  call     _PostQuitMessage@4

  jmp      short .close

.keyproc:
  pushad
  call     workbenchKeyHandler
  popad
  jmp      short .default

.ldown:
  pushad
  xor      eax, eax
  jmp      short .mousecaller

.ldouble:
  pushad
  movzx    ebx, word [ebp+20]
  movzx    ecx, word [ebp+22]
  xor      eax, eax
  call     workbenchMouseHandler
  xor      eax, eax
  inc      eax
  jmp      short .mousecaller

.lup:
  pushad
  xor      eax, eax
  inc      eax
  jmp      short .mousecaller

.move:
  pushad
  xor      eax, eax
  mov      al, 2
  jmp      short .mousecaller

.rdown:
  pushad
  xor      eax, eax
  mov      al, 3
  jmp      short .mousecaller

.rup:
  pushad
  xor      eax, eax
  mov      al, 4

.mousecaller:
  movzx    ebx, word [ebp+20]
  movzx    ecx, word [ebp+22]
  call     workbenchMouseHandler
  popad

.end:
  pop      ebp
  ret      16

winInit:                               ; window initialization
  xor      eax, eax
  push     eax
  call     _GetModuleHandleA@4
 
  push     eax
  mov      [WINDOWCLASS.hInstance], eax

  push     dword WINDOWCLASS
  call     _RegisterClassA@4

  pop      ebx
  xor      eax, eax
  push     eax
  push     ebx
  push     eax
  push     eax
  inc      eax
  push     eax
  push     eax
  dec      eax
  push     eax
  push     eax
  push     dword WS_POPUP
  mov      ebx, classname
  push     ebx
  push     ebx
  push     eax
  call     _CreateWindowExA@48

  mov      dword [errorPtr], Errors.win
  call     errorIfZero

  mov      [hWnd], eax

  push     dword SW_SHOW
  push     eax
  push     eax
  call     _UpdateWindow@4
  call     _ShowWindow@8

; directdraw stuff

  xor      eax, eax
  push     eax
  push     dword tempobj
  push     eax
  call     _DirectDrawCreate@12

  mov      dword [errorPtr], Errors.createDDraw
  call     errorIfNotZero

  mov      esi, [tempobj]
  mov      edi, [esi]

  push     dword comObjects+mDDraw
  push     dword IID_IDirectDraw4
  push     esi
  call     [edi+DirectDraw.QueryInterface]

  push     esi
  call     [edi+DirectDraw.Release]

reSetMode:
  mov      esi, [comObjects+mDDraw]
  mov      edi, [esi]

  push     dword DDSCL_EXCLUSIVE|DDSCL_FULLSCREEN|DDSCL_ALLOWREBOOT
  push     dword [hWnd]
  push     esi
  call     [edi+DirectDraw4.SetCooperativeLevel]

  mov      dword [errorPtr], Errors.DDrawSetup
  call     errorIfNotZero

  mov      ebx, MODE
  xor      eax, eax
  push     eax
  push     eax
  push     dword [ebx-MODE+MODE.bpp]
  push     dword [ebx-MODE+MODE.yres]
  push     dword [ebx-MODE+MODE.xres]
  push     esi
  call     [edi+DirectDraw4.SetDisplayMode]

  call     errorIfNotZero

  mov      dword [DDSURFACEDESC2.dwSize], (DDSD2_SIZE-DDSURFACEDESC2)
  mov      dword [DDSURFACEDESC2.dwFlags], DDSD_CAPS|DDSD_BACKBUFFERCOUNT
  mov      dword [DDSURFACEDESC2.dwBackBufferCount], 2
  mov      dword [DDSCAPS2.dwCaps], DDSCAPS_PRIMARYSURFACE|DDSCAPS_FLIP|DDSCAPS_COMPLEX

  xor      eax, eax
  push     eax
  push     dword comObjects+mSurface
  push     dword DDSURFACEDESC2
  push     esi
  call     [edi+DirectDraw4.CreateSurface]

  call     errorIfNotZero

  mov      esi, [comObjects+mSurface]
  mov      edi, [esi]

  mov      dword [DDSCAPS2.dwCaps], DDSCAPS_BACKBUFFER

  push     dword mBackbuffer
  push     dword DDSCAPS2
  push     esi
  call     [edi+DirectDrawSurface7.GetAttachedSurface]

  call     errorIfNotZero

  mov      dword [DDPIXELFORMAT.dwSize], (DDPIXELFORMAT.size-DDPIXELFORMAT)
  push     dword DDPIXELFORMAT
  push     esi
  call     [edi+DirectDrawSurface7.GetPixelFormat]

  call     errorIfNotZero

  mov      eax, [DDPIXELFORMAT.dwFlags]
  and      eax, DDPF_RGB

  call     errorIfZero

  xor      eax, eax
  push     eax
  call     _ShowCursor@4

  ret

; ----------------------------------------------------------- soundkram -----

clamp:
  pushad
  shr      ecx, 2
  jz       .clampend
  mov      ebx, 32700    
  mov      edx, ebx
  neg      edx

.ClampLoop:
  lodsd
  cmp      eax, ebx
  jng      .NoClampHigh1
  mov      eax, ebx

.NoClampHigh1:
  cmp      eax, edx
  jnl      .NextSample1
  mov      eax, edx
.NextSample1:
  stosw

  lodsd
  cmp      eax, ebx
  jng      .NoClampHigh2
  mov      eax, ebx

.NoClampHigh2:
  cmp      eax, edx
  jnl      .NextSample2
  mov      eax, edx
.NextSample2:
  stosw

  add      esi,8
  loop     .ClampLoop

.clampend
  popad
  ret

sndInit:
  pushad
  mov      ebx, globdat

  ; clear global data
  mov      ecx, dsdata.size
  mov      edi, ebx
  xor      eax, eax
  rep      stosb

  ; init MXM player
  lea      edi, [ebx+dsdata.mxmheap]
  mov      esi, [esp+40]               ; first parm (mxmheap)
  call     xmpInit

  ; create IDirectSound instance
  push     eax
  lea      ecx, [ebx+dsdata.dssd]
  push     ecx
  push     eax
  call     _DirectSoundCreate@12

  or       eax, eax
  jnz      .initfailgate

  ; set DSound cooperative level
  mov      al, 3                       ; exclusive mode
  push     eax
  push     dword [esp+40]              ; second parm (hwnd)
  mov      esi, [ebx+dsdata.dssd]
  push     esi
  mov      edi, [esi]                  ; edx = vtbl
  call     [edi+18h]                   ; IDirectSound::SetCooperativeLevel

  or       eax, eax
  jnz      .initfailgate

  ; obtain primary buffer
  push     eax
  lea      ebp, [ebx+dsdata.pbuf]
  push     ebp
  push     dword primdesc
  push     esi
  call     [edi+0ch]                   ; IDirectSound::CreateSoundBuffer

  or       eax, eax
.initfailgate:
  jnz      .gate2

  ; obtain secondary buffer
  push     eax
  lea      edx, [ebx+dsdata.sbuf]
  push     edx
  push     dword streamdesc
  push     esi
  call     [edi+0ch] ; IDirectSound::CreateSoundBuffer

  or       eax, eax
.gate2
  jnz      near .InitFailed

  ; set primary buffer format

  lea      edi, [ebx+dsdata.tempwfx]
  push     edi

  lea      esi, [wfxprimary]
  lea      ecx, [eax+WAVEFORMATEX.size]
  rep      movsb

  mov      esi, [ebp]
  push     esi
  mov      edi, [esi]  ; edx = vtbl
  call     [edi+38h] ; IDirectSoundBuffer::SetFormat

  ; lock, clear and unlock secondary buffer
  xor      esi,esi
  push     dword 2                   ; DSBLOCK_ENTIREBUFFER
  lea      edx, [ebx+dsdata.len2]
  push     edx
  lea      edx, [ebx+dsdata.buf2]
  push     edx
  lea      edx, [ebx+dsdata.len1]
  push     edx
  lea      edx, [ebx+dsdata.buf1]
  push     edx
  push     esi
  push     esi
  mov      ebp, [ebx+dsdata.sbuf]
  mov      esi, [ebp]                  ; vtbl
  push     ebp
  call     [esi+2ch]                   ; IDirectSoundBuffer::Lock
  or       eax, eax
  jnz      .InitFailed
  mov      ecx, [ebx+dsdata.len1]
  mov      edi, [ebx+dsdata.buf1]
  rep      stosb
  mov      ecx, [ebx+dsdata.len2]
  mov      edi, [ebx+dsdata.buf2]
  rep      stosb
  push     dword [ebx+dsdata.len2]
  push     dword [ebx+dsdata.buf2]
  push     dword [ebx+dsdata.len1]
  push     dword [ebx+dsdata.buf1]
  push     ebp
  call     [esi+4ch]                   ; IDirectSoundBuffer::Unlock
  or       eax, eax
  jnz      .InitFailed

  ; activate the streaming buffer
  xor      eax,eax
  inc      al
  push     eax                         ; for later
  push     eax                         ; DSPLAY_LOOPING
  dec      al
  push     eax
  push     eax
  push     ebp
  call     [esi+30h]                   ; IDirectSoundBuffer::Play

  or       eax, eax
  jnz      .InitFailed

  ; start sound thread
  lea      edx, [ebx+dsdata.dummy]
  push     edx
  push     eax
  push     eax
  push     dword threadfunc
  push     eax
  push     eax
  call     _CreateThread@24

  mov      [ebx+dsdata.thndl], eax

  inc      dword [esp]
  push     eax
  call     _SetThreadPriority@8

  ; ok, everything's done
  popad
  stc
  jmp      short .initends

.InitFailed                            ; oh no, we've encountered an error!
  call     sndClose
  popad
  clc

.initends
  sbb      eax, eax
  ret      8

sndClose:
  pushad
  mov     ebx, globdat

  ; set exit request..
  inc     dword [ebx+dsdata.exitreq]
  mov     eax, [ebx+dsdata.thndl]
  or      eax, eax
  jz      .NoThread

  ; give the thread a chance to finish

  push    dword 1000
  push    eax
  call    _WaitForSingleObject@8

.NoThread:
  ; remove allocated instances
  mov     edi, .ReleaseComObj
  xchg    esi, ebx
  lodsd
  call    edi
  lodsd
  call    edi
  lodsd

  db  0b1h                             ; 31337 untergrund trick!

.ReleaseComObj:
  pushad
  or      eax, eax
  jz      .endRelease
  mov     edx, [eax]
  push    eax
  call    [edx+08h]                    ; IUnknown::Release

.endRelease
  popad
  ret

threadfunc:
  pushad
  mov     ebx, globdat

.looping:
  ; check for exit request
  cmp     byte [ebx+dsdata.exitreq], 0
  je      .loopok

  popad
  xor     eax, eax
  ret     4

.loopok:
  ; sleep 25 msecs
  xor     ebp,ebp
  lea     edx, [ebp+2]
  push    edx
  call    _Sleep@4

  mov     [ebx+dsdata.buf1], ebp
  mov     [ebx+dsdata.buf2], ebp

.lockLoop:
  ; fetch current buffer position
  xor     eax, eax
  push    eax

  lea     eax, [ebx+dsdata.curpos]
  push    eax             

  mov     ebp, [ebx+dsdata.sbuf]
  push    ebp
  mov     edx, [ebp]                   ; vtbl
  call    [edx+10h]                    ; IDirectSoundBuffer::GetCurrentPosition
  cmp     eax, 88780096h               ; DSERR_BUFFERLOST
  je      .tryRestore

  ; find out how many bytes to write
  mov     eax, [ebx+dsdata.curpos]
  and     eax, ~1fh
  mov     word [ebx+dsdata.wholepos], ax
  mov     ecx, eax
  sub     eax, [ebx+dsdata.lastpos]
  jns     .ja
  add     eax, 10000h
  inc     word [ebx+dsdata.wholepos+2]

.ja:
  mov     edi, eax

  ; try to lock the buffer
  xor     esi, esi
  push    esi
  lea     edx, [ebx+dsdata.len2]
  push    edx
  lea     edx, [ebx+dsdata.buf2]
  push    edx
  lea     edx, [ebx+dsdata.len1]
  push    edx
  lea     edx, [ebx+dsdata.buf1]
  push    edx

  push    eax
  push    dword [ebx+dsdata.lastpos]
  mov     [ebx+dsdata.lastpos],ecx

  mov     edx, [ebp]                   ; vtbl
  push    ebp
  call    [edx+2ch]                    ; IDirectSoundBuffer::Lock
  cmp     eax, 88780096h               ; DSERR_BUFFERLOST
  jne     .lockOK

.tryRestore:
  mov     edx, [ebp]                   ; vtbl
  push    ebp
  call    [edx+50h]                    ; IDirectSoundBuffer::Restore
  jmp     short .lockLoop

.lockOK:
  mov     eax, edi
  shr     eax, 2
  lea     edi, [ebx+dsdata.mixbuffer]
  call    xmpRender

  mov     esi, edi

  push    ebp
  mov     ebp, clamp

  ; check buffer one
  mov     edi, [ebx+dsdata.buf1]
  or      edi, edi
  jz      .nobuf1
  mov     ecx, [ebx+dsdata.len1]
  call    ebp
  shl     ecx, 2
  add     esi, ecx

.nobuf1:
  ; check buffer two
  mov     edi, [ebx+dsdata.buf2]
  or      edi, edi
  jz      .nobuf2
  mov     ecx, [ebx+dsdata.len2]
  call    ebp

.nobuf2:
  pop     ebp
  push    dword [ebx+dsdata.len2]
  push    dword [ebx+dsdata.buf2]
  push    dword [ebx+dsdata.len1]
  push    dword [ebx+dsdata.buf1]
  push    ebp
  mov     esi, [ebp]                   ; vtbl
  call    [esi+4ch]                    ; IDirectSoundBuffer::Unlock

  jmp     .looping

wfxprimary:
  db 0x01, 0x00, 0x02, 0x00, 0x44, 0xac, 0x00, 0x00, 0x10, 0xb1, 0x02
  db 0x00, 0x04, 0x00, 0x10, 0x00, 0x00, 0x00, 0x00

streamdesc:
  db 0x14, 0x00, 0x00, 0x00, 0x00, 0x80, 0x01, 0x00, 0x00, 0x00, 0x01
  db 0x00, 0x00, 0x00, 0x00, 0x00
  dd wfxprimary

primdesc:
  db 0x14, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
  db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00

; ----------------------------- checken ob surfaces lost sind und so... -----

fixSurfaces:
  mov      esi, [comObjects+mSurface]
  mov      edi, [esi]
  mov      dword [errorPtr], Errors.DDraw

  push     esi
  call     [edi+DirectDrawSurface.IsLost]
  or       eax, eax
  jz       .primaryOk

  push     esi
  call     [edi+DirectDrawSurface.Restore]

  call     errorIfNotZero

.primaryOk:
  mov      esi, [mBackbuffer]
  mov      edi, [esi]

  push     esi
  call     [edi+DirectDrawSurface.IsLost]
  or       eax, eax
  jz       .backbufferOk

  push     esi
  call     [edi+DirectDrawSurface.Restore]
  call     errorIfNotZero

.backbufferOk:
  ret

; ------------------------------------------------------- screen locken -----

lockScreen:
  call     fixSurfaces
  mov      ebx, DDSURFACEDESC2
  mov      dword [ebx-DDSURFACEDESC2+DDSURFACEDESC2.dwSize], DDSD2_SIZE-DDSURFACEDESC2
  
.lockloop:
  xor      eax, eax
  push     eax
  push     dword DDLOCK_WAIT
  push     ebx
  push     eax
  push     esi
  call     [edi+DirectDrawSurface.Lock]

  cmp      eax, DDERR_WASSTILLDRAWING
  je       .llp

  call     errorIfNotZero
  jmp      short .locked

.llp:
  jmp      short .lockloop

.locked:
  mov      edi, vScreen

  mov      eax, [ebx-DDSURFACEDESC2+DDSURFACEDESC2.lpSurface]
  stosd
  mov      eax, [ebx-DDSURFACEDESC2+DDSURFACEDESC2.lPitch]
  stosd

  ret

; ------------------------------------------------------ screen updaten -----

updateScreen:
  call     fixSurfaces

  xor      eax, eax
  push     eax
  push     esi
  call     [edi+DirectDrawSurface.Unlock]

  call     errorIfNotZero

  mov      esi, [comObjects+mSurface]
  mov      edi, [esi]

.fliploop:
  xor      eax, eax
  push     dword DDFLIP_WAIT
  push     eax
  push     esi
  call     [edi+DirectDrawSurface.Flip]

  or       eax, eax
  jz       .flipOk

  cmp      eax, DDERR_SURFACELOST
  jne      .notLost

  push     esi
  call     [edi+DirectDrawSurface.Restore]
  call     errorIfNotZero

  jmp      short .fliploop

.notLost:
  cmp      eax, DDERR_WASSTILLDRAWING
  je       .fliploop

.flipOk:
  ret

; --------------------------------------------------------- timer-stuff -----

tmrget:
  push     ebx
  push     edx
  push     ebp

  mov      eax, [globdat+dsdata.wholepos]
  shl      eax, 2

  xor      edx, edx
  mov      ebx, 706
  idiv     ebx

  pop      ebp
  pop      edx
  pop      ebx
  ret

resetTimer:
  call     tmrget
  mov      [timeStart], eax
  ret

getTime:
  call     tmrget
  sub      eax, [timeStart]
  ret

; ------------------------------------- deinitialization/error handling -----

deinit:
  push     dword 1000
  push     dword [threadHandle]
  call     _WaitForSingleObject@8

  call     fontDestroy
  call     quitWorkbench

releaseAllComObjects:
  call     sndClose

  xor      ecx, ecx
  mov      cl, COMOBJCOUNT
  mov      esi, comObjects

.relLp:
  lodsd
  or       eax, eax
  jz       .next
  mov      edx, [eax]
  pushad
  push     eax
  call     [edx+8]
  popad

.next:
  xor      eax, eax
  mov      [esi-4], eax

  loop     .relLp

  ret

errorIfZero:
  or       eax, eax
  jz       errorExit
  ret

errorIfNotZero:
  or       eax, eax
  jz       errorExit.end

errorExit:
  call     deinit

  push     dword MB_ICONERROR+MB_OK
  push     dword classname
  push     dword [errorPtr]
  push     dword [hWnd]
  call     _MessageBoxA@16

  mov      esp, [initStack]

.end:
  ret

; ------------------------------------------------------------ "writer" -----

centerWrite:
  push    esi
  push    eax
  push    ebx
  push    edx

  xor     ebx, ebx

.lp:
  lodsb
  or      al, al
  jz      .end

  movzx   eax, al
  shl     eax, 2
  lea     edx, [eax*2+eax+262144]
  add     edx, [font]

  shl     ebx, 2
  add     ebx, [edx]
  add     ebx, [edx+4]
  add     ebx, [edx+8]
  lea     ebx, [ebx+3]
  shr     ebx, 2

  jmp     short .lp

.end:
  shr     ebx, 1
  neg     ebx
  mov     edi, 224
  imul    edi, [vPitch]
  lea     edi, [edi+ebx*4+320*4]

  pop     edx
  pop     ebx
  pop     eax
  pop     esi

writeString:                           ; esi=string edi=dest
  push    ebp
  add     edi, [vScreen]

.wrloop:
  lodsb
  or      al, al
  jnz     .ok
  jmp     .end

.ok:
  push    esi
  push    edi
  movzx   eax, al
  shl     eax, 2
  mov     esi, [font]
  lea     ebp, [eax+262144+eax*2]
  shr     eax, 2
  add     ebp, esi
  mov     ebx, eax
  and     bl, 0fh
  shl     ebx, 5
  add     esi, ebx
  mov     ebx, eax
  shr     ebx, 4
  shl     ebx, 14
  add     esi, ebx
  mov     eax, [ds:ebp]
  add     eax, [ds:ebp+4]
  add     eax, [ds:ebp+8]
  dec     eax
  shr     eax, 2
  xchg    eax, ebx

  pxor         mm4, mm4
  movd         mm4, [textfade]
  pslld        mm4, 8
  punpcklwd    mm4, mm4

.mm4ok:
  pxor         mm5, mm5

  xor     edx, edx
  mov     dl, 32

.yloop:
  mov     ecx, ebx
  shr     ecx, 1

.xloop:
  movd         mm0, [esi+ecx*2]
  punpcklbw    mm0, mm5
  movq         mm1, [edi+ecx*8]
  pmulhw       mm0, mm4
  psllw        mm0, 1
  dec          ecx
  packuswb     mm0, mm5
  punpcklbw    mm0, mm0
  punpcklbw    mm0, mm0
  paddusb      mm0, mm1
  movq         [edi+ecx*8+8], mm0
  jns          .xloop

  add     esi, 512
  add     edi, [vPitch]
  dec     edx
  jnz     .yloop

  pop     edi
  pop     esi
  lea     edi, [edi+ebx*4+4]
  jmp     .wrloop

.end:
  pop     ebp

  emms
  ret

; --------------------------------------------------- samples berechnen -----

calcSamples:
  mov     esi, smptable
  mov     ebp, mxmfile
  mov     [ebp+mxmheader.SampTable], esi

  mov     edi, smpmem
  xor     ebx, ebx                     ; overall sample counter
  xor     ecx, ecx                     ; instrument counter

.instlp:
  mov     eax, [ebp+mxmheader.InstrTable+ecx*4]
  add     eax, ebp

  push    ecx
  xor     ecx, ecx                     ; smp counter

.calcsmp:
  mov     [esi+ebx*4], edi

  mov     edx, ecx
  shl     edx, 4
  mov     edx, [eax+edx+instrument.size+sample.End]

  pushad
  push    edx
  push    edi
  push    ebx
  call    _syRender@12
  popad

  inc     ebx
  lea     edi, [edi+edx*2]

  inc     ecx
  cmp     ecx, [eax+instrument.NSamples]
  jne     .calcsmp

  pop     ecx

  inc     ecx
  cmp     ecx, [ebp+mxmheader.NInstruments]
  jne     .instlp

  ret

; --------------------------------------------------------- demo thread -----

demothread:
  pushad

  xor      eax, eax
  call     xmpPlay
  call     resetTimer

.introlp:
  call     lockScreen

  call     getTime
  push     eax

  sub      eax, 4520
  js       .notext

  xor      edx, edx
  mov      ebx, 1000
  idiv     ebx

  cmp      al, MSGCOUNT
  jnb      .part2

  mov      ecx, eax

  shr      edx, 1
  mov      dword [flashtime], edx

  pop      eax
  push     ecx

  call     psphereRender

  pop      ecx

  mov      esi, [Writer.seq+ecx*4]
  call     centerWrite

.normal:
  call     updateScreen

  cmp      byte [exit], 0
  je       .introlp
  jmp      .end

.notext:
  pop      eax

  call     getTime
  call     psphereRender
  jmp      short .normal

.part2:
  pop      eax

  call     getTime
  call     psphereRender
  call     updateScreen

.p2lp:
  call     lockScreen

  call     getTime

  push     eax

  sub      eax, 20520
  jnb      .p2ck2
  jmp      .p2ck

.p2ck2:
  cmp      eax, 16000
  jb       .p2supabla
  jmp      .part3

.p2supabla:
  xor      edx, edx
  mov      ebx, eax
  cmp      eax, 4000
  jb       .p2nfk
  sub      ebx, 4000
  inc      edx

.p2nfk:
  shr      ebx, 3
  mov      [flashtime], ebx

  mov      ebx, eax
  pop      eax
  push     ebx
  push     edx
  call     psphereRender
  pop      edx
  pop      eax

  xor      ecx, ecx
  mov      cl, 127
  mov      ebx, 15000
  sub      ebx, eax
  jns      .tfns
  xor      ebx, ebx

.tfns:
  shr      ebx, 5
  cmp      ebx, ecx
  jb       .tfadeok
  mov      ebx, ecx

.tfadeok:
  mov      [textfade], ebx

  mov      ebx, [vPitch]
  shl      ebx, 4
  sub      [vScreen], ebx

  push     edx
  push     ebx

  mov      esi, Writer.ms2k
  call     centerWrite

  pop      ebx
  pop      eax
  push     ebx

  shl      ebx, 1
  add      [vScreen], ebx

  or       eax, eax
  jz       .noexpect

  mov      esi, Writer.expect
  call     centerWrite

.noexpect:
  pop      ebx

  sub      [vScreen], ebx
  push     eax

.p2ck:
  pop      eax
  call     updateScreen

  cmp      byte [exit], 0
  jne      near .end
  jmp      .p2lp

.part3:
  pop      eax
  call     updateScreen

.part3fromstart:
; wb init.
  mov      esi, [comObjects+mSurface]
  mov      edi, [esi]
  push     esi
  call     [edi+DirectDrawSurface7.Release]

  mov      edi, MODE
  mov      eax, 640
  stosd
  mov      eax, 480
  stosd
  xor      eax, eax
  mov      al, 8
  stosd

  call     reSetMode

  mov      esi, [comObjects+mDDraw]
  mov      edi, [esi]

  mov      ebx, comObjects+mPalette
  xor      eax, eax
  push     eax
  push     ebx
  push     dword _pal
  mov      al, DDPCAPS_8BIT
  push     eax
  push     esi
  call     [edi+DirectDraw4.CreatePalette]

  mov      esi, [comObjects+mSurface]
  mov      edi, [esi]

  push     dword [ebx]
  push     esi
  call     [edi+DirectDrawSurface7.SetPalette]

  call     initWorkbench

; end wb init

  push     dword 0
  push     dword 0
  push     dword WM_UNDO
  push     dword [hWnd]
  call     _PostMessageA@16
  inc      dword [work]


.end:
  popad
  xor      eax, eax
  ret      4

wbframe:
  call     lockScreen

  mov      eax, [vScreen]
  mov      ebx, [vPitch]
  call     workbenchFrame

  call     updateScreen
  ret

_dd_setpal@4:
  mov      ecx, [esp+4]
  add      ecx, 64*4

  mov      eax, [comObjects+mPalette]
  mov      edx, [eax]

  push     ecx
  push     dword 64
  xor      ecx, ecx
  push     dword 64
  push     ecx
  push     eax
  call     [edx+DirectDrawPalette.SetEntries]

  ret

; -------------------------------------------------------- startup code -----

global entrypnt

entrypnt:                              ; program entry point
  ; init

  xor      eax, eax
  mov      edi, exit
  mov      [edi], eax
  mov      [edi+4], eax
  mov      [initStack], esp

  finit
  push     word 1F7Fh
  fldcw    word [esp]
  add      esp, 2

  mov      dword [errorPtr], Errors.mmx
  xor      eax, eax
  inc      eax
  cpuid
  xchg     edx, eax
  and      eax, (1<<23)
  call     errorIfZero

  call     winInit
  call     fontCreate
  mov      [font], eax

  ; decompress-screen

  call     lockScreen

  mov      edi, [vScreen]
  mov      ecx, [MODE.yres]
  imul     ecx, [vPitch]
  lea      ecx, [ecx+3]
  shr      ecx, 2
  xor      eax, eax
  rep      stosd

  mov      esi, decompress
  call     centerWrite
  call     updateScreen

  ; precalcs...

  call     psphereInit
  call     calcSamples

  push     dword mxmfile
  call     _GetForegroundWindow@0
  push     eax
  call     sndInit

  ; und los

  xor      eax, eax
  push     dword threadId
  push     eax
  push     eax
  push     dword demothread
  push     dword 49152
  push     eax
  call     _CreateThread@24
  mov      [threadHandle], eax

.msgloop:
  mov      edi, MSG
  xor      eax, eax

  push     eax
  push     eax
  push     eax
  push     edi
  call     _GetMessageA@16

  mov      dword [errorPtr], Errors.winerr
  dec      eax
  call     errorIfNotZero

  push     edi
  push     edi
  call     _TranslateMessage@4
  call     _DispatchMessageA@4

  cmp      byte [work], 0
  jne      .wbtiming

  cmp      byte [exit], 0
  je       short .msgloop
  jmp      .end

.wbtiming:
  call     getTime
  cmp      eax, 36520
  jb       .wbtiming

  jmp      .frame

.workloop:
  xor      eax, eax
  mov      edi, MSG

.wmsgloop:
  push     eax
  push     eax
  push     eax
  push     eax
  push     edi
  call     _PeekMessageA@20

  or       eax, eax
  jz       .frame

  xor      eax, eax

  push     eax
  push     eax
  push     eax
  push     edi
  call     _GetMessageA@16

  or       eax, eax
  jz       .end

  push     edi
  push     edi
  call     _TranslateMessage@4
  call     _DispatchMessageA@4

  jmp      short .wmsgloop

.frame:
  call     wbframe

  cmp      byte [exit], 0
  je       short .workloop

.end:
  ret
