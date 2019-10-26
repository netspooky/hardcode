; ..\LIB\USER32.LIB PROTOTYPES
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~

ActivateKeyboardLayout PROTO :DWORD,:DWORD
AdjustWindowRect PROTO :DWORD,:DWORD,:DWORD
AdjustWindowRectEx PROTO :DWORD,:DWORD,:DWORD,:DWORD
AnimateWindow PROTO :DWORD,:DWORD,:DWORD
AnyPopup PROTO
AppendMenuA PROTO :DWORD,:DWORD,:DWORD,:DWORD
AppendMenu equ <AppendMenuA>

ArrangeIconicWindows PROTO :DWORD
AttachThreadInput PROTO :DWORD,:DWORD,:DWORD
BeginDeferWindowPos PROTO :DWORD
BeginPaint PROTO :DWORD,:DWORD
BlockInput PROTO :DWORD
BringWindowToTop PROTO :DWORD
BroadcastSystemMessageA PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
BroadcastSystemMessage equ <BroadcastSystemMessageA>

CallMsgFilterA PROTO :DWORD,:DWORD
CallMsgFilter equ <CallMsgFilterA>

CallNextHookEx PROTO :DWORD,:DWORD,:DWORD,:DWORD
CallWindowProcA PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
CallWindowProc equ <CallWindowProcA>

CascadeChildWindows PROTO :DWORD,:DWORD
CascadeWindows PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
ChangeClipboardChain PROTO :DWORD,:DWORD
ChangeDisplaySettingsA PROTO :DWORD,:DWORD
ChangeDisplaySettings equ <ChangeDisplaySettingsA>

ChangeDisplaySettingsExA PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
ChangeDisplaySettingsEx equ <ChangeDisplaySettingsExA>

ChangeMenuA PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
ChangeMenu equ <ChangeMenuA>

CharLowerA PROTO :DWORD
CharLower equ <CharLowerA>

CharLowerBuffA PROTO :DWORD,:DWORD
CharLowerBuff equ <CharLowerBuffA>

CharNextA PROTO :DWORD
CharNext equ <CharNextA>

CharNextExA PROTO :DWORD,:DWORD,:DWORD
CharNextEx equ <CharNextExA>

CharPrevA PROTO :DWORD,:DWORD
CharPrev equ <CharPrevA>

CharPrevExA PROTO :DWORD,:DWORD,:DWORD,:DWORD
CharPrevEx equ <CharPrevExA>

CharToOemA PROTO :DWORD,:DWORD
CharToOem equ <CharToOemA>

CharToOemBuffA PROTO :DWORD,:DWORD,:DWORD
CharToOemBuff equ <CharToOemBuffA>

CharUpperA PROTO :DWORD
CharUpper equ <CharUpperA>

CharUpperBuffA PROTO :DWORD,:DWORD
CharUpperBuff equ <CharUpperBuffA>

CheckDlgButton PROTO :DWORD,:DWORD,:DWORD
CheckMenuItem PROTO :DWORD,:DWORD,:DWORD
CheckMenuRadioItem PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
CheckRadioButton PROTO :DWORD,:DWORD,:DWORD,:DWORD
ChildWindowFromPoint PROTO :DWORD,:DWORD,:DWORD
ChildWindowFromPointEx PROTO :DWORD,:DWORD,:DWORD,:DWORD
ClientToScreen PROTO :DWORD,:DWORD
ClipCursor PROTO :DWORD
CloseClipboard PROTO
CloseDesktop PROTO :DWORD
CloseWindow PROTO :DWORD
CloseWindowStation PROTO :DWORD
CopyAcceleratorTableA PROTO :DWORD,:DWORD,:DWORD
CopyAcceleratorTable equ <CopyAcceleratorTableA>

CopyIcon PROTO :DWORD
CopyImage PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
CopyRect PROTO :DWORD,:DWORD
CountClipboardFormats PROTO
CreateAcceleratorTableA PROTO :DWORD,:DWORD
CreateAcceleratorTable equ <CreateAcceleratorTableA>

CreateCaret PROTO :DWORD,:DWORD,:DWORD,:DWORD
CreateCursor PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
CreateDesktopA PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
CreateDesktop equ <CreateDesktopA>

CreateDialogIndirectParamA PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
CreateDialogIndirectParam equ <CreateDialogIndirectParamA>

CreateDialogParamA PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
CreateDialogParam equ <CreateDialogParamA>

CreateIcon PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
CreateIconFromResource PROTO :DWORD,:DWORD,:DWORD,:DWORD
CreateIconFromResourceEx PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
CreateIconIndirect PROTO :DWORD
CreateMDIWindowA PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
CreateMDIWindow equ <CreateMDIWindowA>

CreateMenu PROTO
CreatePopupMenu PROTO
CreateWindowExA PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
CreateWindowEx equ <CreateWindowExA>

CreateWindowStationA PROTO :DWORD,:DWORD,:DWORD,:DWORD
CreateWindowStation equ <CreateWindowStationA>

DdeAbandonTransaction PROTO :DWORD,:DWORD,:DWORD
DdeAccessData PROTO :DWORD,:DWORD
DdeAddData PROTO :DWORD,:DWORD,:DWORD,:DWORD
DdeClientTransaction PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
DdeCmpStringHandles PROTO :DWORD,:DWORD
DdeConnect PROTO :DWORD,:DWORD,:DWORD,:DWORD
DdeConnectList PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
DdeCreateDataHandle PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
DdeCreateStringHandleA PROTO :DWORD,:DWORD,:DWORD
DdeCreateStringHandle equ <DdeCreateStringHandleA>

DdeDisconnect PROTO :DWORD
DdeDisconnectList PROTO :DWORD
DdeEnableCallback PROTO :DWORD,:DWORD,:DWORD
DdeFreeDataHandle PROTO :DWORD
DdeFreeStringHandle PROTO :DWORD,:DWORD
DdeGetData PROTO :DWORD,:DWORD,:DWORD,:DWORD
DdeGetLastError PROTO :DWORD
DdeGetQualityOfService PROTO :DWORD,:DWORD,:DWORD
DdeImpersonateClient PROTO :DWORD
DdeInitializeA PROTO :DWORD,:DWORD,:DWORD,:DWORD
DdeInitialize equ <DdeInitializeA>

DdeKeepStringHandle PROTO :DWORD,:DWORD
DdeNameService PROTO :DWORD,:DWORD,:DWORD,:DWORD
DdePostAdvise PROTO :DWORD,:DWORD,:DWORD
DdeQueryConvInfo PROTO :DWORD,:DWORD,:DWORD
DdeQueryNextServer PROTO :DWORD,:DWORD
DdeQueryStringA PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
DdeQueryString equ <DdeQueryStringA>

DdeReconnect PROTO :DWORD
DdeSetQualityOfService PROTO :DWORD,:DWORD,:DWORD
DdeSetUserHandle PROTO :DWORD,:DWORD,:DWORD
DdeUnaccessData PROTO :DWORD
DdeUninitialize PROTO :DWORD
DefDlgProcA PROTO :DWORD,:DWORD,:DWORD,:DWORD
DefDlgProc equ <DefDlgProcA>

DefFrameProcA PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
DefFrameProc equ <DefFrameProcA>

DefMDIChildProcA PROTO :DWORD,:DWORD,:DWORD,:DWORD
DefMDIChildProc equ <DefMDIChildProcA>

DefWindowProcA PROTO :DWORD,:DWORD,:DWORD,:DWORD
DefWindowProc equ <DefWindowProcA>

DeferWindowPos PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
DeleteMenu PROTO :DWORD,:DWORD,:DWORD
DestroyAcceleratorTable PROTO :DWORD
DestroyCaret PROTO
DestroyCursor PROTO :DWORD
DestroyIcon PROTO :DWORD
DestroyMenu PROTO :DWORD
DestroyWindow PROTO :DWORD
DialogBoxIndirectParamA PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
DialogBoxIndirectParam equ <DialogBoxIndirectParamA>

DialogBoxParamA PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
DialogBoxParam equ <DialogBoxParamA>

DispatchMessageA PROTO :DWORD
DispatchMessage equ <DispatchMessageA>

DlgDirListA PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
DlgDirList equ <DlgDirListA>

DlgDirListComboBoxA PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
DlgDirListComboBox equ <DlgDirListComboBoxA>

DlgDirSelectComboBoxExA PROTO :DWORD,:DWORD,:DWORD,:DWORD
DlgDirSelectComboBoxEx equ <DlgDirSelectComboBoxExA>

DlgDirSelectExA PROTO :DWORD,:DWORD,:DWORD,:DWORD
DlgDirSelectEx equ <DlgDirSelectExA>

DragDetect PROTO :DWORD,:DWORD,:DWORD
DragObject PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
DrawAnimatedRects PROTO :DWORD,:DWORD,:DWORD,:DWORD
DrawCaption PROTO :DWORD,:DWORD,:DWORD,:DWORD
DrawEdge PROTO :DWORD,:DWORD,:DWORD,:DWORD
DrawFocusRect PROTO :DWORD,:DWORD
DrawFrame PROTO :DWORD,:DWORD,:DWORD,:DWORD
DrawFrameControl PROTO :DWORD,:DWORD,:DWORD,:DWORD
DrawIcon PROTO :DWORD,:DWORD,:DWORD,:DWORD
DrawIconEx PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
DrawMenuBar PROTO :DWORD
DrawStateA PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
DrawState equ <DrawStateA>

DrawTextA PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
DrawText equ <DrawTextA>

DrawTextExA PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
DrawTextEx equ <DrawTextExA>

EditWndProc PROTO :DWORD,:DWORD,:DWORD,:DWORD
EmptyClipboard PROTO
EnableMenuItem PROTO :DWORD,:DWORD,:DWORD
EnableScrollBar PROTO :DWORD,:DWORD,:DWORD
EnableWindow PROTO :DWORD,:DWORD
EndDeferWindowPos PROTO :DWORD
EndDialog PROTO :DWORD,:DWORD
EndMenu PROTO
EndPaint PROTO :DWORD,:DWORD
EnumChildWindows PROTO :DWORD,:DWORD,:DWORD
EnumClipboardFormats PROTO :DWORD
EnumDesktopWindows PROTO :DWORD,:DWORD,:DWORD
EnumDesktopsA PROTO :DWORD,:DWORD,:DWORD
EnumDesktops equ <EnumDesktopsA>

EnumDisplayMonitors PROTO :DWORD,:DWORD,:DWORD,:DWORD
EnumDisplaySettingsA PROTO :DWORD,:DWORD,:DWORD
EnumDisplaySettings equ <EnumDisplaySettingsA>

EnumDisplaySettingsExA PROTO :DWORD,:DWORD,:DWORD,:DWORD
EnumDisplaySettingsEx equ <EnumDisplaySettingsExA>

EnumPropsA PROTO :DWORD,:DWORD
EnumProps equ <EnumPropsA>

EnumPropsExA PROTO :DWORD,:DWORD,:DWORD
EnumPropsEx equ <EnumPropsExA>

EnumThreadWindows PROTO :DWORD,:DWORD,:DWORD
EnumWindowStationsA PROTO :DWORD,:DWORD
EnumWindowStations equ <EnumWindowStationsA>

EnumWindows PROTO :DWORD,:DWORD
EqualRect PROTO :DWORD,:DWORD
ExcludeUpdateRgn PROTO :DWORD,:DWORD
ExitWindowsEx PROTO :DWORD,:DWORD
FillRect PROTO :DWORD,:DWORD,:DWORD
FindWindowA PROTO :DWORD,:DWORD
FindWindow equ <FindWindowA>

FindWindowExA PROTO :DWORD,:DWORD,:DWORD,:DWORD
FindWindowEx equ <FindWindowExA>

FlashWindow PROTO :DWORD,:DWORD
FrameRect PROTO :DWORD,:DWORD,:DWORD
FreeDDElParam PROTO :DWORD,:DWORD
GetActiveWindow PROTO
GetAltTabInfoA PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
GetAltTabInfo equ <GetAltTabInfoA>

GetAncestor PROTO :DWORD,:DWORD
GetAsyncKeyState PROTO :DWORD
GetCapture PROTO
GetCaretBlinkTime PROTO
GetCaretPos PROTO :DWORD
GetClassInfoA PROTO :DWORD,:DWORD,:DWORD
GetClassInfo equ <GetClassInfoA>

GetClassInfoExA PROTO :DWORD,:DWORD,:DWORD
GetClassInfoEx equ <GetClassInfoExA>

GetClassLongA PROTO :DWORD,:DWORD
GetClassLong equ <GetClassLongA>

GetClassNameA PROTO :DWORD,:DWORD,:DWORD
GetClassName equ <GetClassNameA>

GetClassWord PROTO :DWORD,:DWORD
GetClientRect PROTO :DWORD,:DWORD
GetClipCursor PROTO :DWORD
GetClipboardData PROTO :DWORD
GetClipboardFormatNameA PROTO :DWORD,:DWORD,:DWORD
GetClipboardFormatName equ <GetClipboardFormatNameA>

GetClipboardOwner PROTO
GetClipboardSequenceNumber PROTO
GetClipboardViewer PROTO
GetComboBoxInfo PROTO :DWORD,:DWORD
GetCursor PROTO
GetCursorInfo PROTO :DWORD
GetCursorPos PROTO :DWORD
GetDC PROTO :DWORD
GetDCEx PROTO :DWORD,:DWORD,:DWORD
GetDesktopWindow PROTO
GetDialogBaseUnits PROTO
GetDlgCtrlID PROTO :DWORD
GetDlgItem PROTO :DWORD,:DWORD
GetDlgItemInt PROTO :DWORD,:DWORD,:DWORD,:DWORD
GetDlgItemTextA PROTO :DWORD,:DWORD,:DWORD,:DWORD
GetDlgItemText equ <GetDlgItemTextA>

GetDoubleClickTime PROTO
GetFocus PROTO
GetForegroundWindow PROTO
GetGUIThreadInfo PROTO :DWORD,:DWORD
GetGuiResources PROTO :DWORD,:DWORD
GetIconInfo PROTO :DWORD,:DWORD
GetInputDesktop PROTO
GetInputState PROTO
GetKBCodePage PROTO
GetKeyNameTextA PROTO :DWORD,:DWORD,:DWORD
GetKeyNameText equ <GetKeyNameTextA>

GetKeyState PROTO :DWORD
GetKeyboardLayout PROTO :DWORD
GetKeyboardLayoutList PROTO :DWORD,:DWORD
GetKeyboardLayoutNameA PROTO :DWORD
GetKeyboardLayoutName equ <GetKeyboardLayoutNameA>

GetKeyboardState PROTO :DWORD
GetKeyboardType PROTO :DWORD
GetLastActivePopup PROTO :DWORD
GetLastInputInfo PROTO :DWORD
GetListBoxInfo PROTO :DWORD
GetMenu PROTO :DWORD
GetMenuBarInfo PROTO :DWORD,:DWORD,:DWORD,:DWORD
GetMenuCheckMarkDimensions PROTO
GetMenuContextHelpId PROTO :DWORD
GetMenuDefaultItem PROTO :DWORD,:DWORD,:DWORD
GetMenuInfo PROTO :DWORD,:DWORD
GetMenuItemCount PROTO :DWORD
GetMenuItemID PROTO :DWORD,:DWORD
GetMenuItemInfoA PROTO :DWORD,:DWORD,:DWORD,:DWORD
GetMenuItemInfo equ <GetMenuItemInfoA>

GetMenuItemRect PROTO :DWORD,:DWORD,:DWORD,:DWORD
GetMenuState PROTO :DWORD,:DWORD,:DWORD
GetMenuStringA PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
GetMenuString equ <GetMenuStringA>

GetMessageA PROTO :DWORD,:DWORD,:DWORD,:DWORD
GetMessage equ <GetMessageA>

GetMessageExtraInfo PROTO
GetMessagePos PROTO
GetMessageTime PROTO
GetMonitorInfoA PROTO :DWORD,:DWORD
GetMonitorInfo equ <GetMonitorInfoA>

GetMouseMovePoints PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
GetNextDlgGroupItem PROTO :DWORD,:DWORD,:DWORD
GetNextDlgTabItem PROTO :DWORD,:DWORD,:DWORD
GetOpenClipboardWindow PROTO
GetParent PROTO :DWORD
GetPriorityClipboardFormat PROTO :DWORD,:DWORD
GetProcessWindowStation PROTO
GetPropA PROTO :DWORD,:DWORD
GetProp equ <GetPropA>

GetQueueStatus PROTO :DWORD
GetScrollBarInfo PROTO :DWORD,:DWORD,:DWORD
GetScrollInfo PROTO :DWORD,:DWORD,:DWORD
GetScrollPos PROTO :DWORD,:DWORD
GetScrollRange PROTO :DWORD,:DWORD,:DWORD,:DWORD
GetShellWindow PROTO
GetSubMenu PROTO :DWORD,:DWORD
GetSysColor PROTO :DWORD
GetSysColorBrush PROTO :DWORD
GetSystemMenu PROTO :DWORD,:DWORD
GetSystemMetrics PROTO :DWORD
GetTabbedTextExtentA PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
GetTabbedTextExtent equ <GetTabbedTextExtentA>

GetThreadDesktop PROTO :DWORD
GetTitleBarInfo PROTO :DWORD,:DWORD
GetTopWindow PROTO :DWORD
GetUpdateRect PROTO :DWORD,:DWORD,:DWORD
GetUpdateRgn PROTO :DWORD,:DWORD,:DWORD
GetUserObjectInformationA PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
GetUserObjectInformation equ <GetUserObjectInformationA>

GetUserObjectSecurity PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
GetWindow PROTO :DWORD,:DWORD
GetWindowContextHelpId PROTO :DWORD
GetWindowDC PROTO :DWORD
GetWindowInfo PROTO :DWORD,:DWORD
GetWindowLongA PROTO :DWORD,:DWORD
GetWindowLong equ <GetWindowLongA>

GetWindowModuleFileNameA PROTO :DWORD,:DWORD,:DWORD
GetWindowModuleFileName equ <GetWindowModuleFileNameA>

GetWindowPlacement PROTO :DWORD,:DWORD
GetWindowRect PROTO :DWORD,:DWORD
GetWindowRgn PROTO :DWORD,:DWORD
GetWindowTextA PROTO :DWORD,:DWORD,:DWORD
GetWindowText equ <GetWindowTextA>

GetWindowTextLengthA PROTO :DWORD
GetWindowTextLength equ <GetWindowTextLengthA>

GetWindowThreadProcessId PROTO :DWORD,:DWORD
GetWindowWord PROTO :DWORD,:DWORD
GrayStringA PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
GrayString equ <GrayStringA>

HideCaret PROTO :DWORD
HiliteMenuItem PROTO :DWORD,:DWORD,:DWORD,:DWORD
IMPGetIMEA PROTO :DWORD,:DWORD
IMPGetIME equ <IMPGetIMEA>

IMPQueryIMEA PROTO :DWORD
IMPQueryIME equ <IMPQueryIMEA>

IMPSetIMEA PROTO :DWORD,:DWORD
IMPSetIME equ <IMPSetIMEA>

ImpersonateDdeClientWindow PROTO :DWORD,:DWORD
InSendMessage PROTO
InSendMessageEx PROTO :DWORD
InflateRect PROTO :DWORD,:DWORD,:DWORD
InsertMenuA PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
InsertMenu equ <InsertMenuA>

InsertMenuItemA PROTO :DWORD,:DWORD,:DWORD,:DWORD
InsertMenuItem equ <InsertMenuItemA>

IntersectRect PROTO :DWORD,:DWORD,:DWORD
InvalidateRect PROTO :DWORD,:DWORD,:DWORD
InvalidateRgn PROTO :DWORD,:DWORD,:DWORD
InvertRect PROTO :DWORD,:DWORD
IsCharAlphaA PROTO :DWORD
IsCharAlpha equ <IsCharAlphaA>

IsCharAlphaNumericA PROTO :DWORD
IsCharAlphaNumeric equ <IsCharAlphaNumericA>

IsCharLowerA PROTO :DWORD
IsCharLower equ <IsCharLowerA>

IsCharUpperA PROTO :DWORD
IsCharUpper equ <IsCharUpperA>

IsChild PROTO :DWORD,:DWORD
IsClipboardFormatAvailable PROTO :DWORD
IsDialogMessageA PROTO :DWORD,:DWORD
IsDialogMessage equ <IsDialogMessageA>

IsDlgButtonChecked PROTO :DWORD,:DWORD
IsIconic PROTO :DWORD
IsMenu PROTO :DWORD
IsRectEmpty PROTO :DWORD
IsWindow PROTO :DWORD
IsWindowEnabled PROTO :DWORD
IsWindowUnicode PROTO :DWORD
IsWindowVisible PROTO :DWORD
IsZoomed PROTO :DWORD
KillSystemTimer PROTO :DWORD,:DWORD
KillTimer PROTO :DWORD,:DWORD
LoadAcceleratorsA PROTO :DWORD,:DWORD
LoadAccelerators equ <LoadAcceleratorsA>

LoadBitmapA PROTO :DWORD,:DWORD
LoadBitmap equ <LoadBitmapA>

LoadCursorA PROTO :DWORD,:DWORD
LoadCursor equ <LoadCursorA>

LoadCursorFromFileA PROTO :DWORD
LoadCursorFromFile equ <LoadCursorFromFileA>

LoadIconA PROTO :DWORD,:DWORD
LoadIcon equ <LoadIconA>

LoadImageA PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
LoadImage equ <LoadImageA>

LoadKeyboardLayoutA PROTO :DWORD,:DWORD
LoadKeyboardLayout equ <LoadKeyboardLayoutA>

LoadMenuA PROTO :DWORD,:DWORD
LoadMenu equ <LoadMenuA>

LoadMenuIndirectA PROTO :DWORD
LoadMenuIndirect equ <LoadMenuIndirectA>

LoadStringA PROTO :DWORD,:DWORD,:DWORD,:DWORD
LoadString equ <LoadStringA>

LockWindowUpdate PROTO :DWORD
LockWorkStation PROTO
LookupIconIdFromDirectory PROTO :DWORD,:DWORD
LookupIconIdFromDirectoryEx PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
MapDialogRect PROTO :DWORD,:DWORD
MapVirtualKeyA PROTO :DWORD,:DWORD
MapVirtualKey equ <MapVirtualKeyA>

MapVirtualKeyExA PROTO :DWORD,:DWORD,:DWORD
MapVirtualKeyEx equ <MapVirtualKeyExA>

MapWindowPoints PROTO :DWORD,:DWORD,:DWORD,:DWORD
MenuItemFromPoint PROTO :DWORD,:DWORD,:DWORD,:DWORD
MessageBeep PROTO :DWORD
MessageBoxA PROTO :DWORD,:DWORD,:DWORD,:DWORD
MessageBox equ <MessageBoxA>

MessageBoxExA PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
MessageBoxEx equ <MessageBoxExA>

MessageBoxIndirectA PROTO :DWORD
MessageBoxIndirect equ <MessageBoxIndirectA>

ModifyMenuA PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
ModifyMenu equ <ModifyMenuA>

MonitorFromPoint PROTO :DWORD,:DWORD,:DWORD
MonitorFromRect PROTO :DWORD,:DWORD
MonitorFromWindow PROTO :DWORD,:DWORD
MoveWindow PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
MsgWaitForMultipleObjects PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
MsgWaitForMultipleObjectsEx PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
NotifyWinEvent PROTO :DWORD,:DWORD,:DWORD,:DWORD
OemKeyScan PROTO :DWORD
OemToCharA PROTO :DWORD,:DWORD
OemToChar equ <OemToCharA>

OemToCharBuffA PROTO :DWORD,:DWORD,:DWORD
OemToCharBuff equ <OemToCharBuffA>

OffsetRect PROTO :DWORD,:DWORD,:DWORD
OpenClipboard PROTO :DWORD
OpenDesktopA PROTO :DWORD,:DWORD,:DWORD,:DWORD
OpenDesktop equ <OpenDesktopA>

OpenIcon PROTO :DWORD
OpenInputDesktop PROTO :DWORD,:DWORD,:DWORD
OpenWindowStationA PROTO :DWORD,:DWORD,:DWORD
OpenWindowStation equ <OpenWindowStationA>

PackDDElParam PROTO :DWORD,:DWORD,:DWORD
PaintDesktop PROTO :DWORD
PeekMessageA PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
PeekMessage equ <PeekMessageA>

PostMessageA PROTO :DWORD,:DWORD,:DWORD,:DWORD
PostMessage equ <PostMessageA>

PostQuitMessage PROTO :DWORD
PostThreadMessageA PROTO :DWORD,:DWORD,:DWORD,:DWORD
PostThreadMessage equ <PostThreadMessageA>

PtInRect PROTO :DWORD,:DWORD,:DWORD
RealChildWindowFromPoint PROTO :DWORD,:DWORD,:DWORD
RealGetWindowClassA PROTO :DWORD,:DWORD,:DWORD
RealGetWindowClass equ <RealGetWindowClassA>

RedrawWindow PROTO :DWORD,:DWORD,:DWORD,:DWORD
RegisterClassA PROTO :DWORD
RegisterClass equ <RegisterClassA>

RegisterClassExA PROTO :DWORD
RegisterClassEx equ <RegisterClassExA>

RegisterClipboardFormatA PROTO :DWORD
RegisterClipboardFormat equ <RegisterClipboardFormatA>

RegisterDeviceNotificationA PROTO :DWORD,:DWORD,:DWORD
RegisterDeviceNotification equ <RegisterDeviceNotificationA>

RegisterHotKey PROTO :DWORD,:DWORD,:DWORD,:DWORD
RegisterWindowMessageA PROTO :DWORD
RegisterWindowMessage equ <RegisterWindowMessageA>

ReleaseCapture PROTO
ReleaseDC PROTO :DWORD,:DWORD
RemoveMenu PROTO :DWORD,:DWORD,:DWORD
RemovePropA PROTO :DWORD,:DWORD
RemoveProp equ <RemovePropA>

ReplyMessage PROTO :DWORD
ReuseDDElParam PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
ScreenToClient PROTO :DWORD,:DWORD
ScrollChildren PROTO :DWORD,:DWORD,:DWORD
ScrollDC PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
ScrollWindow PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
ScrollWindowEx PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
SendDlgItemMessageA PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
SendDlgItemMessage equ <SendDlgItemMessageA>

SendIMEMessageExA PROTO :DWORD,:DWORD
SendIMEMessageEx equ <SendIMEMessageExA>

SendInput PROTO :DWORD,:DWORD,:DWORD
SendMessageA PROTO :DWORD,:DWORD,:DWORD,:DWORD
SendMessage equ <SendMessageA>

SendMessageCallbackA PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
SendMessageCallback equ <SendMessageCallbackA>

SendMessageTimeoutA PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
SendMessageTimeout equ <SendMessageTimeoutA>

SendNotifyMessageA PROTO :DWORD,:DWORD,:DWORD,:DWORD
SendNotifyMessage equ <SendNotifyMessageA>

SetActiveWindow PROTO :DWORD
SetCapture PROTO :DWORD
SetCaretBlinkTime PROTO :DWORD
SetCaretPos PROTO :DWORD,:DWORD
SetClassLongA PROTO :DWORD,:DWORD,:DWORD
SetClassLong equ <SetClassLongA>

SetClassWord PROTO :DWORD,:DWORD,:DWORD
SetClipboardData PROTO :DWORD,:DWORD
SetClipboardViewer PROTO :DWORD
SetCursor PROTO :DWORD
SetCursorPos PROTO :DWORD,:DWORD
SetDebugErrorLevel PROTO :DWORD
SetDeskWallpaper PROTO :DWORD
SetDlgItemInt PROTO :DWORD,:DWORD,:DWORD,:DWORD
SetDlgItemTextA PROTO :DWORD,:DWORD,:DWORD
SetDlgItemText equ <SetDlgItemTextA>

SetDoubleClickTime PROTO :DWORD
SetFocus PROTO :DWORD
SetForegroundWindow PROTO :DWORD
SetKeyboardState PROTO :DWORD
SetLastErrorEx PROTO :DWORD,:DWORD
SetMenu PROTO :DWORD,:DWORD
SetMenuContextHelpId PROTO :DWORD,:DWORD
SetMenuDefaultItem PROTO :DWORD,:DWORD,:DWORD
SetMenuInfo PROTO :DWORD,:DWORD
SetMenuItemBitmaps PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
SetMenuItemInfoA PROTO :DWORD,:DWORD,:DWORD,:DWORD
SetMenuItemInfo equ <SetMenuItemInfoA>

SetMessageExtraInfo PROTO :DWORD
SetMessageQueue PROTO :DWORD
SetParent PROTO :DWORD,:DWORD
SetProcessWindowStation PROTO :DWORD
SetPropA PROTO :DWORD,:DWORD,:DWORD
SetProp equ <SetPropA>

SetRect PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
SetRectEmpty PROTO :DWORD
SetScrollInfo PROTO :DWORD,:DWORD,:DWORD,:DWORD
SetScrollPos PROTO :DWORD,:DWORD,:DWORD,:DWORD
SetScrollRange PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
SetShellWindow PROTO :DWORD
SetSysColors PROTO :DWORD,:DWORD,:DWORD
SetSystemCursor PROTO :DWORD,:DWORD
SetSystemMenu PROTO :DWORD,:DWORD
SetSystemTimer PROTO :DWORD,:DWORD,:DWORD,:DWORD
SetThreadDesktop PROTO :DWORD
SetTimer PROTO :DWORD,:DWORD,:DWORD,:DWORD
SetUserObjectInformationA PROTO :DWORD,:DWORD,:DWORD,:DWORD
SetUserObjectInformation equ <SetUserObjectInformationA>

SetUserObjectSecurity PROTO :DWORD,:DWORD,:DWORD
SetWinEventHook PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
SetWindowContextHelpId PROTO :DWORD,:DWORD
SetWindowLongA PROTO :DWORD,:DWORD,:DWORD
SetWindowLong equ <SetWindowLongA>

SetWindowPlacement PROTO :DWORD,:DWORD
SetWindowPos PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
SetWindowRgn PROTO :DWORD,:DWORD,:DWORD
SetWindowTextA PROTO :DWORD,:DWORD
SetWindowText equ <SetWindowTextA>

SetWindowWord PROTO :DWORD,:DWORD,:DWORD
SetWindowsHookA PROTO :DWORD,:DWORD
SetWindowsHook equ <SetWindowsHookA>

SetWindowsHookExA PROTO :DWORD,:DWORD,:DWORD,:DWORD
SetWindowsHookEx equ <SetWindowsHookExA>

ShowCaret PROTO :DWORD
ShowCursor PROTO :DWORD
ShowOwnedPopups PROTO :DWORD,:DWORD
ShowScrollBar PROTO :DWORD,:DWORD,:DWORD
ShowWindow PROTO :DWORD,:DWORD
ShowWindowAsync PROTO :DWORD,:DWORD
SubtractRect PROTO :DWORD,:DWORD,:DWORD
SwapMouseButton PROTO :DWORD
SwitchDesktop PROTO :DWORD
SystemParametersInfoA PROTO :DWORD,:DWORD,:DWORD,:DWORD
SystemParametersInfo equ <SystemParametersInfoA>

TabbedTextOutA PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
TabbedTextOut equ <TabbedTextOutA>

TileChildWindows PROTO :DWORD,:DWORD
TileWindows PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
ToAscii PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
ToAsciiEx PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
ToUnicode PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
ToUnicodeEx PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
TrackMouseEvent PROTO :DWORD
TrackPopupMenu PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
TrackPopupMenuEx PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
TranslateAcceleratorA PROTO :DWORD,:DWORD,:DWORD
TranslateAccelerator equ <TranslateAcceleratorA>

TranslateMDISysAccel PROTO :DWORD,:DWORD
TranslateMessage PROTO :DWORD
UnhookWinEvent PROTO :DWORD
UnhookWindowsHook PROTO :DWORD,:DWORD
UnhookWindowsHookEx PROTO :DWORD
UnionRect PROTO :DWORD,:DWORD,:DWORD
UnloadKeyboardLayout PROTO :DWORD
UnpackDDElParam PROTO :DWORD,:DWORD,:DWORD,:DWORD
UnregisterClassA PROTO :DWORD,:DWORD
UnregisterClass equ <UnregisterClassA>

UnregisterDeviceNotification PROTO :DWORD
UnregisterHotKey PROTO :DWORD,:DWORD
UpdateWindow PROTO :DWORD
UserHandleGrantAccess PROTO :DWORD,:DWORD
ValidateRect PROTO :DWORD,:DWORD
ValidateRgn PROTO :DWORD,:DWORD
VkKeyScanA PROTO :DWORD
VkKeyScan equ <VkKeyScanA>

VkKeyScanExA PROTO :DWORD,:DWORD
VkKeyScanEx equ <VkKeyScanExA>

WINNLSEnableIME PROTO :DWORD,:DWORD
WINNLSGetEnableStatus PROTO :DWORD
WINNLSGetIMEHotkey PROTO :DWORD
WaitForInputIdle PROTO :DWORD,:DWORD
WaitMessage PROTO
WinHelpA PROTO :DWORD,:DWORD,:DWORD,:DWORD
WinHelp equ <WinHelpA>

WindowFromDC PROTO :DWORD
WindowFromPoint PROTO :DWORD,:DWORD
keybd_event PROTO :DWORD,:DWORD,:DWORD,:DWORD
mouse_event PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
wvsprintfA PROTO :DWORD,:DWORD,:DWORD
wvsprintf equ <wvsprintfA>


