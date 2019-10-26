;*************************************************************************
;
;       WIN32.INC - Win32 assembly language structures & constants
;
;
;*************************************************************************
;
; NOTE: this file only implements the structures and constants that
;       wap32.asm uses.  You may extend it for your own applications.
;
;*************************************************************************
;
;
;       C/C++ Run Time Library - Version 6.0
;
;       Copyright (c) 1985, 1993 by Borland International
;       All Rights Reserved.
;

UCHAR   EQU <db>
USHORT  EQU <dw>  ; used only if we really need 16 bits
UINT    EQU <dd>  ; 32 bits for WIN32
ULONG   EQU <dd>

;*******************************************************************
;
;       Rectangle
;
;*******************************************************************

RECT    struc
        rcLeft          UINT ?
        rcTop           UINT ?
        rcRight         UINT ?
        rcBottom        UINT ?
RECT    ends

;*******************************************************************
;
;  Window Class structure
;
;*******************************************************************

WNDCLASS struc
        clsStyle          UINT     ?   ; class style
        clsLpfnWndProc    ULONG    ?
        clsCbClsExtra     UINT     ?
        clsCbWndExtra     UINT     ?
        clsHInstance      UINT     ?   ; instance handle
        clsHIcon          UINT     ?   ; class icon handle
        clsHCursor        UINT     ?   ; class cursor handle
        clsHbrBackground  UINT     ?   ; class background brush
        clsLpszMenuName   ULONG    ?   ; menu name
        clsLpszClassName  ULONG    ?   ; far ptr to class name
WNDCLASS ends

PAINTSTRUCT STRUC
    PShdc         UINT             ?
    PSfErase      UINT             ?
    PSrcPaint     UCHAR            size RECT dup(?)
    PSfRestore    UINT             ?
    PSfIncUpdate  UINT             ?
    PSrgbReserved UCHAR            16 dup(?)
PAINTSTRUCT ENDS

MSGSTRUCT struc
    msHWND          UINT    ?
    msMESSAGE       UINT    ?
    msWPARAM        UINT    ?
    msLPARAM        ULONG   ?
    msTIME          ULONG   ?
    msPT            ULONG   ?
MSGSTRUCT ends

MINMAXINFO struc
  res_x               dd ?
  res_y               dd ?
  maxsize_x           dd ?
  maxsize_y           dd ?
  maxposition_x       dd ?
  maxposition_y       dd ?
  mintrackposition_x  dd ?
  mintrackposition_y  dd ?
  maxtrackposition_x  dd ?
  maxtrackposition_y  dd ?
MINMAXINFO ends


PIXELFORMATDESCRIPTOR struc
  nSize               dw ?
  nVersion            dw ?
  dwFlags             dd ?
  iPixelType          db ?
  cColorBits          db ?
  cRedBits            db ?
  cRedShift           db ?
  cGreenBits          db ?
  cGreenShift         db ?
  cBlueBits           db ?
  cBlueShift          db ?
  cAlphaBits          db ?
  cAlphaShift         db ?
  cAccumBits          db ?
  cAccumRedBits       db ?
  cAccumGreenBits     db ?
  cAccumBlueBits      db ?
  cAccumAlphaits      db ?
  cDepthBits          db ?
  cStencilBits        db ?
  cAuxBuffers         db ?
  iLayerType          db ?
  bReserverd          db ?
  dwLayerMask         dd ?
  dwVisibleMask       dd ?
  dwDamageMask        dd ?
PIXELFORMATDESCRIPTOR ends

POINTL              STRUC   
x                   DD      ?
y                   DD      ?

POINTL              ENDS

DEVMODE             STRUC   
dmDeviceName        DB      32 DUP ( ? )
dmSpecVersion       DW      ?
dmDriverVersion     DW      ?
dmSize              DW      ?
dmDriverExtra       DW      ?
dmFields            DD      ?
dmPosition          POINTL  <>
dmScale             DW      ?
dmCopies            DW      ?
dmDefaultSource     DW      ?
dmPrintQuality      DW      ?
dmColor             DW      ?
dmDuplex            DW      ?
dmYResolution       DW      ?
dmTTOption          DW      ?
dmCollate           DW      ?
dmFormName          DB      32 DUP ( ? )
dmLogPixels         DW      ?
dmBitsPerPel        DD      ?
dmPelsWidth         DD      ?
dmPelsHeight        DD      ?
dmDisplayFlags      DD      ?
dmDisplayFrequency  DD      ?
dmICMMethod         DD      ?
dmICMIntent         DD      ?
dmMediaType         DD      ?
dmDitherType        DD      ?
dmReserved1         DD      ?
dmReserved2         DD      ?
dmPanningWidth      DD      ?
dmPanningHeight     DD      ?

DEVMODE             ENDS

;
;  Stock Logical Objects
;
WHITE_BRUSH         =  0
LTGRAY_BRUSH        =  1
GRAY_BRUSH          =  2
DKGRAY_BRUSH        =  3
BLACK_BRUSH         =  4
NULL_BRUSH          =  5
HOLLOW_BRUSH        =  5
WHITE_PEN           =  6
BLACK_PEN           =  7
NULL_PEN            =  8
DOT_MARKER          =  9
OEM_FIXED_FONT      = 10
ANSI_FIXED_FONT     = 11
ANSI_VAR_FONT       = 12
SYSTEM_FONT         = 13
DEVICE_DEFAULT_FONT = 14
DEFAULT_PALETTE     = 15
SYSTEM_FIXED_FONT   = 16

;
; Brush Styles
;
BS_SOLID        =   0
BS_NULL         =   1
BS_HOLLOW       =   BS_NULL
BS_HATCHED      =   2
BS_PATTERN      =   3
BS_INDEXED      =   4
BS_DIBPATTERN   =   5
;
; Hatch Styles
;
HS_HORIZONTAL   =   0       ; -----
HS_VERTICAL     =   1       ; |||||
HS_FDIAGONAL    =   2       ; \\\\\
HS_BDIAGONAL    =   3       ; /////
HS_CROSS        =   4       ; +++++
HS_DIAGCROSS    =   5       ; xxxxx
;
; Pen Styles
;
PS_SOLID        =   0
PS_DASH         =   1       ; -------
PS_DOT          =   2       ; .......
PS_DASHDOT      =   3       ; _._._._
PS_DASHDOTDOT   =   4       ; _.._.._
PS_NULL         =   5
PS_INSIDEFRAME  =   6

;
;  Window State Messages
;
IFNDEF  NOWM
WM_STATE            = 0000H

WM_NULL             = 0000h
WM_CREATE           = 0001h
WM_DESTROY          = 0002h
WM_MOVE             = 0003h
WM_SIZE             = 0005h
WM_ACTIVATE         = 0006h
WM_SETFOCUS         = 0007h
WM_KILLFOCUS        = 0008h
WM_ENABLE           = 000Ah
WM_SETREDRAW        = 000Bh
WM_SETTEXT          = 000Ch
WM_GETTEXT          = 000Dh
WM_GETTEXTLENGTH    = 000Eh
WM_PAINT            = 000Fh
WM_CLOSE            = 0010h
WM_QUERYENDSESSION  = 0011h
WM_QUIT             = 0012h
WM_QUERYOPEN        = 0013h
WM_ERASEBKGND       = 0014h
WM_SYSCOLORCHANGE   = 0015h
WM_ENDSESSION       = 0016h
WM_SYSTEMERROR      = 0017h
WM_SHOWWINDOW       = 0018h
WM_CTLCOLOR         = 0019h
WM_WININICHANGE     = 001Ah
WM_DEVMODECHANGE    = 001Bh
WM_ACTIVATEAPP      = 001Ch
WM_FONTCHANGE       = 001Dh
WM_TIMECHANGE       = 001Eh
WM_CANCELMODE       = 001Fh
WM_SETCURSOR        = 0020h
WM_MOUSEACTIVATE    = 0021h
WM_CHILDACTIVATE    = 0022h
WM_QUEUESYNC        = 0023h
WM_GETMINMAXINFO    = 0024h
WM_PAINTICON        = 0026h
WM_ICONERASEBKGND   = 0027h
WM_NEXTDLGCTL       = 0028h
WM_SPOOLERSTATUS    = 002Ah
WM_DRAWITEM         = 002Bh
WM_MEASUREITEM      = 002Ch
WM_DELETEITEM       = 002Dh
WM_VKEYTOITEM       = 002Eh
WM_CHARTOITEM       = 002Fh
WM_SETFONT          = 0030h
WM_GETFONT          = 0031h
WM_QUERYDRAGICON    = 0037h
WM_COMPAREITEM      = 0039h
WM_COMPACTING       = 0041h
WM_COMMNOTIFY       = 0044h
WM_WINDOWPOSCHANGING= 0046h
WM_WINDOWPOSCHANGED = 0047h
WM_POWER            = 0048h

WM_NCCREATE         = 0081h
WM_NCDESTROY        = 0082h
WM_NCCALCSIZE       = 0083h
WM_NCHITTEST        = 0084h
WM_NCPAINT          = 0085h
WM_NCACTIVATE       = 0086h
WM_GETDLGCODE       = 0087h
WM_NCMOUSEMOVE      = 00A0h
WM_NCLBUTTONDOWN    = 00A1h
WM_NCLBUTTONUP      = 00A2h
WM_NCLBUTTONDBLCLK  = 00A3h
WM_NCRBUTTONDOWN    = 00A4h
WM_NCRBUTTONUP      = 00A5h
WM_NCRBUTTONDBLCLK  = 00A6h
WM_NCMBUTTONDOWN    = 00A7h
WM_NCMBUTTONUP      = 00A8h
WM_NCMBUTTONDBLCLK  = 00A9h

WM_KEYFIRST         = 0100h
WM_KEYDOWN          = 0100h
WM_KEYUP            = 0101h
WM_CHAR             = 0102h
WM_DEADCHAR         = 0103h
WM_SYSKEYDOWN       = 0104h
WM_SYSKEYUP         = 0105h
WM_SYSCHAR          = 0106h
WM_SYSDEADCHAR      = 0107h
WM_KEYLAST          = 0108h

WM_INITDIALOG       = 0110h
WM_COMMAND          = 0111h
WM_SYSCOMMAND       = 0112h
WM_TIMER            = 0113h
WM_HSCROLL          = 0114h
WM_VSCROLL          = 0115h
WM_INITMENU         = 0116h
WM_INITMENUPOPUP    = 0117h
WM_MENUSELECT       = 011Fh
WM_MENUCHAR         = 0120h
WM_ENTERIDLE        = 0121h


WM_MOUSEFIRST       = 0200h
WM_MOUSEMOVE        = 0200h
WM_LBUTTONDOWN      = 0201h
WM_LBUTTONUP        = 0202h
WM_LBUTTONDBLCLK    = 0203h
WM_RBUTTONDOWN      = 0204h
WM_RBUTTONUP        = 0205h
WM_RBUTTONDBLCLK    = 0206h
WM_MBUTTONDOWN      = 0207h
WM_MBUTTONUP        = 0208h
WM_MBUTTONDBLCLK    = 0209h
WM_MOUSELAST        = 0209h

WM_PARENTNOTIFY     = 0210h
WM_MDICREATE        = 0220h
WM_MDIDESTROY       = 0221h
WM_MDIACTIVATE      = 0222h
WM_MDIRESTORE       = 0223h
WM_MDINEXT          = 0224h
WM_MDIMAXIMIZE      = 0225h
WM_MDITILE          = 0226h
WM_MDICASCADE       = 0227h
WM_MDIICONARRANGE   = 0228h
WM_MDIGETACTIVE     = 0229h
WM_MDISETMENU       = 0230h
WM_DROPFILES        = 0233h


WM_CUT              = 0300h
WM_COPY             = 0301h
WM_PASTE            = 0302h
WM_CLEAR            = 0303h
WM_UNDO             = 0304h
WM_RENDERFORMAT     = 0305h
WM_RENDERALLFORMATS = 0306h
WM_DESTROYCLIPBOARD = 0307h
WM_DRAWCLIPBOARD    = 0308h
WM_PAINTCLIPBOARD   = 0309h
WM_VSCROLLCLIPBOARD = 030Ah
WM_SIZECLIPBOARD    = 030Bh
WM_ASKCBFORMATNAME  = 030Ch
WM_CHANGECBCHAIN    = 030Dh
WM_HSCROLLCLIPBOARD = 030Eh
WM_QUERYNEWPALETTE  = 030Fh
WM_PALETTEISCHANGING = 0310h
WM_PALETTECHANGED   = 0311h

WM_PENWINFIRST      equ 0380h
WM_PENWINLAST       equ 038Fh

WM_COALESCE_FIRST  equ 0390h
WM_COALESCE_LAST   equ 039Fh

;  private window messages start here
WM_USER             = 0400H
ENDIF           ; NOWM

; WM_MOUSEACTIVATE Return Codes
MA_ACTIVATE       =  1
MA_ACTIVATEANDEAT =  2
MA_NOACTIVATE     =  3

; Size message commands
SIZENORMAL       = 0
SIZEICONIC       = 1
SIZEFULLSCREEN   = 2
SIZEZOOMSHOW     = 3
SIZEZOOMHIDE     = 4

; ShowWindow() Commands
SW_HIDE            = 0
SW_SHOWNORMAL      = 1
SW_NORMAL          = 1
SW_SHOWMINIMIZED   = 2
SW_SHOWMAXIMIZED   = 3
SW_MAXIMIZE        = 3
SW_SHOWNOACTIVATE  = 4
SW_SHOW            = 5
SW_MINIMIZE        = 6
SW_SHOWMINNOACTIVE = 7
SW_SHOWNA          = 8
SW_RESTORE         = 9

; Old ShowWindow() Commands
HIDE_WINDOW        = 0
SHOW_OPENWINDOW    = 1
SHOW_ICONWINDOW    = 2
SHOW_FULLSCREEN    = 3
SHOW_OPENNOACTIVATE= 4

;  identifiers for the WM_SHOWWINDOW message
SW_PARENTCLOSING =  1
SW_OTHERZOOM     =  2
SW_PARENTOPENING =  3
SW_OTHERUNZOOM   =  4
;
; Key state masks for mouse messages
;
MK_LBUTTON       = 0001h
MK_RBUTTON       = 0002h
MK_SHIFT         = 0004h
MK_CONTROL       = 0008h
MK_MBUTTON       = 0010h
;
; Class styles
;
CS_VREDRAW         = 0001h
CS_HREDRAW         = 0002h
CS_KEYCVTWINDOW    = 0004H
CS_DBLCLKS         = 0008h
;                    0010h reserved
CS_OWNDC           = 0020h
CS_CLASSDC         = 0040h
CS_PARENTDC        = 0080h
CS_NOKEYCVT        = 0100h
CS_SAVEBITS        = 0800h
CS_NOCLOSE         = 0200h
CS_BYTEALIGNCLIENT = 1000h
CS_BYTEALIGNWINDOW = 2000h
CS_GLOBALCLASS     = 4000h    ; Global window class

;
; Special CreateWindow position value
;
CW_USEDEFAULT   EQU    8000h

;
; Windows styles
;
WS_OVERLAPPED   = 000000000h
WS_ICONICPOPUP  = 0C0000000h
WS_POPUP        = 080000000h
WS_CHILD        = 040000000h
WS_MINIMIZE     = 020000000h
WS_VISIBLE      = 010000000h
WS_DISABLED     = 008000000h
WS_CLIPSIBLINGS = 004000000h
WS_CLIPCHILDREN = 002000000h
WS_MAXIMIZE     = 001000000h
WS_CAPTION      = 000C00000h     ; WS_BORDER | WS_DLGFRAME
WS_BORDER       = 000800000h
WS_DLGFRAME     = 000400000h
WS_VSCROLL      = 000200000h
WS_HSCROLL      = 000100000h
WS_SYSMENU      = 000080000h
WS_THICKFRAME   = 000040000h
WS_HREDRAW      = 000020000h
WS_VREDRAW      = 000010000h
WS_GROUP        = 000020000h
WS_TABSTOP      = 000010000h
WS_MINIMIZEBOX  = 000020000h
WS_MAXIMIZEBOX  = 000010000h

; Common Window Styles

WS_OVERLAPPEDWINDOW = WS_OVERLAPPED OR WS_CAPTION OR WS_SYSMENU OR WS_THICKFRAME OR WS_MINIMIZEBOX OR WS_MAXIMIZEBOX
WS_POPUPWINDOW  = WS_POPUP OR WS_BORDER OR WS_SYSMENU
WS_CHILDWINDOW  = WS_CHILD
WS_TILEDWINDOW  = WS_OVERLAPPEDWINDOW

WS_TILED        = WS_OVERLAPPED
WS_ICONIC       = WS_MINIMIZE
WS_SIZEBOX      = WS_THICKFRAME

; Extended Window Styles (low words)
WS_EX_DLGMODALFRAME  = 0001
WS_EX_DRAGOBJECT     = 0002
WS_EX_NOPARENTNOTIFY = 0004
WS_EX_TOPMOST        = 0008


; PeekMessage() Options
PM_NOREMOVE    = 0000h
PM_REMOVE      = 0001h
PM_NOYIELD     = 0002h

; SetWindowPos Flags
SWP_NOSIZE       =  0001h
SWP_NOMOVE       =  0002h
SWP_NOZORDER     =  0004h
SWP_NOREDRAW     =  0008h
SWP_NOACTIVATE   =  0010h
SWP_DRAWFRAME    =  0020h
SWP_SHOWWINDOW   =  0040h
SWP_HIDEWINDOW   =  0080h
SWP_NOCOPYBITS   =  0100h
SWP_NOREPOSITION =  0200h
;
;  Predefined cursor & icon IDs
;
IDC_ARROW       = 32512
IDC_IBEAM       = 32513
IDC_WAIT        = 32514
IDC_CROSS       = 32515
IDC_UPARROW     = 32516
IDC_SIZE        = 32640
IDC_ICON        = 32641
IDC_SIZENWSE    = 32642
IDC_SIZENESW    = 32643
IDC_SIZEWE      = 32644
IDC_SIZENS      = 32645

IDI_APPLICATION = 32512
IDI_HAND        = 32513
IDI_QUESTION    = 32514
IDI_EXCLAMATION = 32515
IDI_ASTERISK    = 32516

COLOR_SCROLLBAR           = 0
COLOR_BACKGROUND          = 1
COLOR_ACTIVECAPTION       = 2
COLOR_INACTIVECAPTION     = 3
COLOR_MENU                = 4
COLOR_WINDOW              = 5
COLOR_WINDOWFRAME         = 6
COLOR_MENUTEXT            = 7
COLOR_WINDOWTEXT          = 8
COLOR_CAPTIONTEXT         = 9
COLOR_ACTIVEBORDER        = 10
COLOR_INACTIVEBORDER      = 11
COLOR_APPWORKSPACE        = 12
COLOR_HIGHLIGHT           = 13
COLOR_HIGHLIGHTTEXT       = 14
COLOR_BTNFACE             = 15
COLOR_BTNSHADOW           = 16
COLOR_GRAYTEXT            = 17
COLOR_BTNTEXT             = 18

;
;  MessageBox type flags
;
MB_OK                   = 0000H
MB_OKCANCEL             = 0001H
MB_ABORTRETRYIGNORE     = 0002H
MB_YESNOCANCEL          = 0003H
MB_YESNO                = 0004H
MB_RETRYCANCEL          = 0005H

MB_ICONHAND             = 0010H
MB_ICONQUESTION         = 0020H
MB_ICONEXCLAMATION      = 0030H
MB_ICONASTERISK         = 0040H

MB_DEFBUTTON1           = 0000H
MB_DEFBUTTON2           = 0100H
MB_DEFBUTTON3           = 0200H

MB_APPLMODAL            = 0000H
MB_SYSTEMMODAL          = 1000H
MB_TASKMODAL            = 2000H

MB_NOFOCUS              = 8000H

;
;  Conventional dialog box and message box command IDs
;
IDOK     =   1
IDCANCEL =   2
IDABORT  =   3
IDRETRY  =   4
IDIGNORE =   5
IDYES    =   6
IDNO     =   7


PFD_TYPE_RGBA       =     0
PFD_TYPE_COLORINDEX =     1
PFD_MAIN_PLANE      =     0
PFD_OVERLAY_PLANE   =     1
PFD_UNDERLAY_PLANE  =     -1
PFD_DOUBLEBUFFER    =     000000001h
PFD_STEREO          =     000000002h
PFD_DRAW_TO_WINDOW  =     000000004h
PFD_DRAW_TO_BITMAP  =     000000008h
PFD_SUPPORT_GDI     =     000000010h
PFD_SUPPORT_OPENGL  =     000000020h
PFD_GENERIC_FORMAT  =     000000040h
PFD_NEED_PALETTE    =     000000080h
PFD_NEED_SYSTEM_PALETTE                 =     000000100h
PFD_SWAP_EXCHANGE   =     000000200h
PFD_SWAP_COPY       =     000000400h
PFD_SWAP_LAYER_BUFFERS                  =     000000800h
PFD_GENERIC_ACCELERATED                 =     000001000h
PFD_SUPPORT_DIRECTDRAW                  =     000002000h
PFD_DEPTH_DONTCARE  =     020000000h
PFD_DOUBLEBUFFER_DONTCARE               =     040000000h
PFD_STEREO_DONTCARE =     080000000h
                
CDS_UPDATEREGISTRY  =     000000001h
CDS_TEST            =     000000002h
CDS_FULLSCREEN      =     000000004h
CDS_GLOBAL          =     000000008h
CDS_SET_PRIMARY     =     000000010h
CDS_RESET           =     040000000h
CDS_SETRECT         =     020000000h
CDS_NORESET         =     010000000h
DISP_CHANGE_SUCCESSFUL                  =     0
DISP_CHANGE_RESTART =     1
DISP_CHANGE_FAILED  =     -1
DISP_CHANGE_BADMODE =     -2
DISP_CHANGE_NOTUPDATED                  =     -3
DISP_CHANGE_BADFLAGS          =     -4
DISP_CHANGE_BADPARAM          =     -5

DM_ORIENTATION      =     00000001h
DM_PAPERSIZE        =     00000002h
DM_PAPERLENGTH      =     00000004h
DM_PAPERWIDTH       =     00000008h
DM_SCALE            =     00000010h
DM_COPIES           =     00000100h
DM_DEFAULTSOURCE    =     00000200h
DM_PRINTQUALITY     =     00000400h
DM_COLOR            =     00000800h
DM_DUPLEX           =     00001000h
DM_YRESOLUTION      =     00002000h
DM_TTOPTION         =     00004000h
DM_COLLATE          =     00008000h
DM_FORMNAME         =     00010000h
DM_LOGPIXELS        =     00020000h
DM_BITSPERPEL       =     00040000h
DM_PELSWIDTH        =     00080000h
DM_PELSHEIGHT       =     00100000h
DM_DISPLAYFLAGS     =     00200000h
DM_DISPLAYFREQUENCY =     00400000h
DM_ICMMETHOD        =     00800000h
DM_ICMINTENT        =     01000000h
DM_MEDIATYPE        =     02000000h
DM_DITHERTYPE       =     04000000h
DM_PANNINGWIDTH     =     08000000h
DM_PANNINGHEIGHT    =     10000000h

; Win32 calls
extrn            BeginPaint:PROC
extrn            CreateWindowExA:PROC
extrn            DefWindowProcA:PROC
extrn            DispatchMessageA:PROC
extrn            EndPaint:PROC
extrn            ExitProcess:PROC

extrn            FindWindowA:PROC
extrn            GetMessageA:PROC
extrn            GetModuleHandleA:PROC
extrn            GetStockObject:PROC
extrn            InvalidateRect:PROC
extrn            LoadCursorA:PROC
extrn            LoadIconA:PROC
extrn            MessageBeep:PROC
extrn            MessageBoxA:PROC
extrn            PostQuitMessage:PROC
extrn            RegisterClassA:PROC
extrn            ShowWindow:PROC
extrn            SetWindowPos:PROC
extrn            TextOutA:PROC
extrn            TranslateMessage:PROC
extrn            UpdateWindow:PROC
extrn            GetDC:PROC
extrn            SetPixelFormat:PROC
extrn            ChoosePixelFormat:PROC
extrn            wglCreateContext:PROC
extrn            wglDeleteContext:PROC
extrn            wglMakeCurrent:PROC
extrn            ReleaseDC:PROC
extrn            ChangeDisplaySettingsA:PROC
extrn		 SwapBuffers:PROC
extrn		 SetCursor:PROC

CreateWindowEx   EQU <CreateWindowExA>
DefWindowProc    EQU <DefWindowProcA>
DispatchMessage  EQU <DispatchMessageA>
FindWindow       EQU <FindWindowA>
GetMessage       EQU <GetMessageA>
GetModuleHandle  EQU <GetModuleHandleA>
LoadCursor       EQU <LoadCursorA>
LoadIcon         EQU <LoadIconA>
MessageBox       EQU <MessageBoxA>
RegisterClass    EQU <RegisterClassA>
TextOut          EQU <TextOutA>
ChangeDisplaySettings EQU <ChangeDisplaySettingsA>

