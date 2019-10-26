; ..\LIB\KERNEL32.LIB PROTOTYPES
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

AddAtomA PROTO :DWORD
AddAtom equ <AddAtomA>

AddConsoleAliasA PROTO :DWORD,:DWORD,:DWORD
AddConsoleAlias equ <AddConsoleAliasA>

AllocConsole PROTO
AreFileApisANSI PROTO
AssignProcessToJobObject PROTO :DWORD,:DWORD
BackupRead PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
BackupSeek PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
BackupWrite PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
BaseAttachCompleteThunk PROTO
Beep PROTO :DWORD,:DWORD
BeginUpdateResourceA PROTO :DWORD,:DWORD
BeginUpdateResource equ <BeginUpdateResourceA>

BuildCommDCBA PROTO :DWORD,:DWORD
BuildCommDCB equ <BuildCommDCBA>

BuildCommDCBAndTimeoutsA PROTO :DWORD,:DWORD,:DWORD
BuildCommDCBAndTimeouts equ <BuildCommDCBAndTimeoutsA>

CallNamedPipeA PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
CallNamedPipe equ <CallNamedPipeA>

CancelIo PROTO :DWORD
CancelWaitableTimer PROTO :DWORD
ClearCommBreak PROTO :DWORD
ClearCommError PROTO :DWORD,:DWORD,:DWORD
CloseConsoleHandle PROTO :DWORD
CloseHandle PROTO :DWORD
CloseProfileUserMapping PROTO
CmdBatNotification PROTO :DWORD
CommConfigDialogA PROTO :DWORD,:DWORD,:DWORD
CommConfigDialog equ <CommConfigDialogA>

CompareFileTime PROTO :DWORD,:DWORD
CompareStringA PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
CompareString equ <CompareStringA>

ConnectNamedPipe PROTO :DWORD,:DWORD
ConsoleMenuControl PROTO :DWORD,:DWORD,:DWORD
ContinueDebugEvent PROTO :DWORD,:DWORD,:DWORD
ConvertDefaultLocale PROTO :DWORD
ConvertThreadToFiber PROTO :DWORD
CopyFileA PROTO :DWORD,:DWORD,:DWORD
CopyFile equ <CopyFileA>

CopyFileExA PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
CopyFileEx equ <CopyFileExA>

CreateConsoleScreenBuffer PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
CreateDirectoryA PROTO :DWORD,:DWORD
CreateDirectory equ <CreateDirectoryA>

CreateDirectoryExA PROTO :DWORD,:DWORD,:DWORD
CreateDirectoryEx equ <CreateDirectoryExA>

CreateEventA PROTO :DWORD,:DWORD,:DWORD,:DWORD
CreateEvent equ <CreateEventA>

CreateFiber PROTO :DWORD,:DWORD,:DWORD
CreateFileA PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
CreateFile equ <CreateFileA>

CreateFileMappingA PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
CreateFileMapping equ <CreateFileMappingA>

CreateHardLinkA PROTO :DWORD,:DWORD,:DWORD
CreateHardLink equ <CreateHardLinkA>

CreateIoCompletionPort PROTO :DWORD,:DWORD,:DWORD,:DWORD
CreateJobObjectA PROTO :DWORD,:DWORD
CreateJobObject equ <CreateJobObjectA>

CreateMailslotA PROTO :DWORD,:DWORD,:DWORD,:DWORD
CreateMailslot equ <CreateMailslotA>

CreateMutexA PROTO :DWORD,:DWORD,:DWORD
CreateMutex equ <CreateMutexA>

CreateNamedPipeA PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
CreateNamedPipe equ <CreateNamedPipeA>

CreatePipe PROTO :DWORD,:DWORD,:DWORD,:DWORD
CreateProcessA PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
CreateProcess equ <CreateProcessA>

CreateRemoteThread PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
CreateSemaphoreA PROTO :DWORD,:DWORD,:DWORD,:DWORD
CreateSemaphore equ <CreateSemaphoreA>

CreateTapePartition PROTO :DWORD,:DWORD,:DWORD,:DWORD
CreateThread PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
CreateToolhelp32Snapshot PROTO :DWORD,:DWORD
CreateVirtualBuffer PROTO :DWORD,:DWORD,:DWORD
CreateWaitableTimerA PROTO :DWORD,:DWORD,:DWORD
CreateWaitableTimer equ <CreateWaitableTimerA>

DebugActiveProcess PROTO :DWORD
DebugBreak PROTO
DefineDosDeviceA PROTO :DWORD,:DWORD,:DWORD
DefineDosDevice equ <DefineDosDeviceA>

DeleteAtom PROTO :DWORD
DeleteCriticalSection PROTO :DWORD
DeleteFiber PROTO :DWORD
DeleteFileA PROTO :DWORD
DeleteFile equ <DeleteFileA>

DeviceIoControl PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
DisableThreadLibraryCalls PROTO :DWORD
DisconnectNamedPipe PROTO :DWORD
DosDateTimeToFileTime PROTO :DWORD,:DWORD,:DWORD
DuplicateConsoleHandle PROTO :DWORD,:DWORD,:DWORD,:DWORD
DuplicateHandle PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
EndUpdateResourceA PROTO :DWORD,:DWORD
EndUpdateResource equ <EndUpdateResourceA>

EnterCriticalSection PROTO :DWORD
EnumCalendarInfoA PROTO :DWORD,:DWORD,:DWORD,:DWORD
EnumCalendarInfo equ <EnumCalendarInfoA>

EnumCalendarInfoExA PROTO :DWORD,:DWORD,:DWORD,:DWORD
EnumCalendarInfoEx equ <EnumCalendarInfoExA>

EnumDateFormatsA PROTO :DWORD,:DWORD,:DWORD
EnumDateFormats equ <EnumDateFormatsA>

EnumDateFormatsExA PROTO :DWORD,:DWORD,:DWORD
EnumDateFormatsEx equ <EnumDateFormatsExA>

EnumResourceLanguagesA PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
EnumResourceLanguages equ <EnumResourceLanguagesA>

EnumResourceNamesA PROTO :DWORD,:DWORD,:DWORD,:DWORD
EnumResourceNames equ <EnumResourceNamesA>

EnumResourceTypesA PROTO :DWORD,:DWORD,:DWORD
EnumResourceTypes equ <EnumResourceTypesA>

EnumSystemCodePagesA PROTO :DWORD,:DWORD
EnumSystemCodePages equ <EnumSystemCodePagesA>

EnumSystemLocalesA PROTO :DWORD,:DWORD
EnumSystemLocales equ <EnumSystemLocalesA>

EnumTimeFormatsA PROTO :DWORD,:DWORD,:DWORD
EnumTimeFormats equ <EnumTimeFormatsA>

EraseTape PROTO :DWORD,:DWORD,:DWORD
EscapeCommFunction PROTO :DWORD,:DWORD
ExitProcess PROTO :DWORD
ExitThread PROTO :DWORD
ExitVDM PROTO :DWORD,:DWORD
ExpandEnvironmentStringsA PROTO :DWORD,:DWORD,:DWORD
ExpandEnvironmentStrings equ <ExpandEnvironmentStringsA>

ExpungeConsoleCommandHistoryA PROTO :DWORD
ExpungeConsoleCommandHistory equ <ExpungeConsoleCommandHistoryA>

ExtendVirtualBuffer PROTO :DWORD,:DWORD
FatalAppExitA PROTO :DWORD,:DWORD
FatalAppExit equ <FatalAppExitA>

FatalExit PROTO :DWORD
FileTimeToDosDateTime PROTO :DWORD,:DWORD,:DWORD
FileTimeToLocalFileTime PROTO :DWORD,:DWORD
FileTimeToSystemTime PROTO :DWORD,:DWORD
FillConsoleOutputAttribute PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
FillConsoleOutputCharacterA PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
FillConsoleOutputCharacter equ <FillConsoleOutputCharacterA>

FindAtomA PROTO :DWORD
FindAtom equ <FindAtomA>

FindClose PROTO :DWORD
FindCloseChangeNotification PROTO :DWORD
FindFirstChangeNotificationA PROTO :DWORD,:DWORD,:DWORD
FindFirstChangeNotification equ <FindFirstChangeNotificationA>

FindFirstFileA PROTO :DWORD,:DWORD
FindFirstFile equ <FindFirstFileA>

FindFirstFileExA PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
FindFirstFileEx equ <FindFirstFileExA>

FindNextChangeNotification PROTO :DWORD
FindNextFileA PROTO :DWORD,:DWORD
FindNextFile equ <FindNextFileA>

FindResourceA PROTO :DWORD,:DWORD,:DWORD
FindResource equ <FindResourceA>

FindResourceExA PROTO :DWORD,:DWORD,:DWORD,:DWORD
FindResourceEx equ <FindResourceExA>

FlushConsoleInputBuffer PROTO :DWORD
FlushFileBuffers PROTO :DWORD
FlushInstructionCache PROTO :DWORD,:DWORD,:DWORD
FlushViewOfFile PROTO :DWORD,:DWORD
FoldStringA PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
FoldString equ <FoldStringA>

FormatMessageA PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
FormatMessage equ <FormatMessageA>

FreeConsole PROTO
FreeEnvironmentStringsA PROTO :DWORD
FreeEnvironmentStrings equ <FreeEnvironmentStringsA>

FreeLibrary PROTO :DWORD
FreeLibraryAndExitThread PROTO :DWORD,:DWORD
FreeResource PROTO :DWORD
FreeVirtualBuffer PROTO :DWORD
GenerateConsoleCtrlEvent PROTO :DWORD,:DWORD
GetACP PROTO
GetAtomNameA PROTO :DWORD,:DWORD,:DWORD
GetAtomName equ <GetAtomNameA>

GetBinaryTypeA PROTO :DWORD,:DWORD
GetBinaryType equ <GetBinaryTypeA>

GetCPInfo PROTO :DWORD,:DWORD
GetCPInfoExA PROTO :DWORD,:DWORD,:DWORD
GetCPInfoEx equ <GetCPInfoExA>

GetCommConfig PROTO :DWORD,:DWORD,:DWORD
GetCommMask PROTO :DWORD,:DWORD
GetCommModemStatus PROTO :DWORD,:DWORD
GetCommProperties PROTO :DWORD,:DWORD
GetCommState PROTO :DWORD,:DWORD
GetCommTimeouts PROTO :DWORD,:DWORD
GetCommandLineA PROTO
GetCommandLine equ <GetCommandLineA>

GetCompressedFileSizeA PROTO :DWORD,:DWORD
GetCompressedFileSize equ <GetCompressedFileSizeA>

GetComputerNameA PROTO :DWORD,:DWORD
GetComputerName equ <GetComputerNameA>

GetConsoleAliasA PROTO :DWORD,:DWORD,:DWORD,:DWORD
GetConsoleAlias equ <GetConsoleAliasA>

GetConsoleAliasExesA PROTO :DWORD,:DWORD
GetConsoleAliasExes equ <GetConsoleAliasExesA>

GetConsoleAliasExesLengthA PROTO
GetConsoleAliasExesLength equ <GetConsoleAliasExesLengthA>

GetConsoleAliasesA PROTO :DWORD,:DWORD,:DWORD
GetConsoleAliases equ <GetConsoleAliasesA>

GetConsoleAliasesLengthA PROTO :DWORD
GetConsoleAliasesLength equ <GetConsoleAliasesLengthA>

GetConsoleCP PROTO
GetConsoleCommandHistoryA PROTO :DWORD,:DWORD,:DWORD
GetConsoleCommandHistory equ <GetConsoleCommandHistoryA>

GetConsoleCommandHistoryLengthA PROTO :DWORD
GetConsoleCommandHistoryLength equ <GetConsoleCommandHistoryLengthA>

GetConsoleCursorInfo PROTO :DWORD,:DWORD
GetConsoleDisplayMode PROTO :DWORD
GetConsoleFontInfo PROTO :DWORD,:DWORD,:DWORD,:DWORD
GetConsoleFontSize PROTO :DWORD,:DWORD
GetConsoleHardwareState PROTO :DWORD,:DWORD,:DWORD
GetConsoleInputExeNameA PROTO :DWORD,:DWORD
GetConsoleInputExeName equ <GetConsoleInputExeNameA>

GetConsoleInputWaitHandle PROTO
GetConsoleKeyboardLayoutNameA PROTO :DWORD
GetConsoleKeyboardLayoutName equ <GetConsoleKeyboardLayoutNameA>

GetConsoleMode PROTO :DWORD,:DWORD
GetConsoleOutputCP PROTO
GetConsoleScreenBufferInfo PROTO :DWORD,:DWORD
GetConsoleTitleA PROTO :DWORD,:DWORD
GetConsoleTitle equ <GetConsoleTitleA>

GetConsoleWindow PROTO
GetCurrencyFormatA PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
GetCurrencyFormat equ <GetCurrencyFormatA>

GetCurrentConsoleFont PROTO :DWORD,:DWORD,:DWORD
GetCurrentDirectoryA PROTO :DWORD,:DWORD
GetCurrentDirectory equ <GetCurrentDirectoryA>

GetCurrentProcess PROTO
GetCurrentProcessId PROTO
GetCurrentThread PROTO
GetCurrentThreadId PROTO
GetDateFormatA PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
GetDateFormat equ <GetDateFormatA>

GetDefaultCommConfigA PROTO :DWORD,:DWORD,:DWORD
GetDefaultCommConfig equ <GetDefaultCommConfigA>

GetDevicePowerState PROTO :DWORD
GetDiskFreeSpaceA PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
GetDiskFreeSpace equ <GetDiskFreeSpaceA>

GetDiskFreeSpaceExA PROTO :DWORD,:DWORD,:DWORD,:DWORD
GetDiskFreeSpaceEx equ <GetDiskFreeSpaceExA>

GetDriveTypeA PROTO :DWORD
GetDriveType equ <GetDriveTypeA>

GetEnvironmentStringsA PROTO
GetEnvironmentStrings equ <GetEnvironmentStringsA>

GetEnvironmentVariableA PROTO :DWORD,:DWORD,:DWORD
GetEnvironmentVariable equ <GetEnvironmentVariableA>

GetExitCodeProcess PROTO :DWORD,:DWORD
GetExitCodeThread PROTO :DWORD,:DWORD
GetFileAttributesA PROTO :DWORD
GetFileAttributes equ <GetFileAttributesA>

GetFileAttributesExA PROTO :DWORD,:DWORD,:DWORD
GetFileAttributesEx equ <GetFileAttributesExA>

GetFileInformationByHandle PROTO :DWORD,:DWORD
GetFileSize PROTO :DWORD,:DWORD
GetFileTime PROTO :DWORD,:DWORD,:DWORD,:DWORD
GetFileType PROTO :DWORD
GetFullPathNameA PROTO :DWORD,:DWORD,:DWORD,:DWORD
GetFullPathName equ <GetFullPathNameA>

GetHandleInformation PROTO :DWORD,:DWORD
GetLargestConsoleWindowSize PROTO :DWORD
GetLastError PROTO
GetLocalTime PROTO :DWORD
GetLocaleInfoA PROTO :DWORD,:DWORD,:DWORD,:DWORD
GetLocaleInfo equ <GetLocaleInfoA>

GetLogicalDriveStringsA PROTO :DWORD,:DWORD
GetLogicalDriveStrings equ <GetLogicalDriveStringsA>

GetLogicalDrives PROTO
GetLongPathNameA PROTO :DWORD,:DWORD,:DWORD
GetLongPathName equ <GetLongPathNameA>

GetMailslotInfo PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
GetModuleFileNameA PROTO :DWORD,:DWORD,:DWORD
GetModuleFileName equ <GetModuleFileNameA>

GetModuleHandleA PROTO :DWORD
GetModuleHandle equ <GetModuleHandleA>

GetNamedPipeHandleStateA PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
GetNamedPipeHandleState equ <GetNamedPipeHandleStateA>

GetNamedPipeInfo PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
GetNextVDMCommand PROTO :DWORD
GetNumberFormatA PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
GetNumberFormat equ <GetNumberFormatA>

GetNumberOfConsoleFonts PROTO
GetNumberOfConsoleInputEvents PROTO :DWORD,:DWORD
GetNumberOfConsoleMouseButtons PROTO :DWORD
GetOEMCP PROTO
GetOverlappedResult PROTO :DWORD,:DWORD,:DWORD,:DWORD
GetPriorityClass PROTO :DWORD
GetPrivateProfileIntA PROTO :DWORD,:DWORD,:DWORD,:DWORD
GetPrivateProfileInt equ <GetPrivateProfileIntA>

GetPrivateProfileSectionA PROTO :DWORD,:DWORD,:DWORD,:DWORD
GetPrivateProfileSection equ <GetPrivateProfileSectionA>

GetPrivateProfileSectionNamesA PROTO :DWORD,:DWORD,:DWORD
GetPrivateProfileSectionNames equ <GetPrivateProfileSectionNamesA>

GetPrivateProfileStringA PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
GetPrivateProfileString equ <GetPrivateProfileStringA>

GetPrivateProfileStructA PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
GetPrivateProfileStruct equ <GetPrivateProfileStructA>

GetProcAddress PROTO :DWORD,:DWORD
GetProcessAffinityMask PROTO :DWORD,:DWORD,:DWORD
GetProcessHeap PROTO
GetProcessHeaps PROTO :DWORD,:DWORD
GetProcessPriorityBoost PROTO :DWORD,:DWORD
GetProcessShutdownParameters PROTO :DWORD,:DWORD
GetProcessTimes PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
GetProcessVersion PROTO :DWORD
GetProcessWorkingSetSize PROTO :DWORD,:DWORD,:DWORD
GetProfileIntA PROTO :DWORD,:DWORD,:DWORD
GetProfileInt equ <GetProfileIntA>

GetProfileSectionA PROTO :DWORD,:DWORD,:DWORD
GetProfileSection equ <GetProfileSectionA>

GetProfileStringA PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
GetProfileString equ <GetProfileStringA>

GetQueuedCompletionStatus PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
GetShortPathNameA PROTO :DWORD,:DWORD,:DWORD
GetShortPathName equ <GetShortPathNameA>

GetStartupInfoA PROTO :DWORD
GetStartupInfo equ <GetStartupInfoA>

GetStdHandle PROTO :DWORD
GetStringTypeA PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
GetStringType equ <GetStringTypeA>

GetStringTypeExA PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
GetStringTypeEx equ <GetStringTypeExA>

GetSystemDefaultLCID PROTO
GetSystemDefaultLangID PROTO
GetSystemDirectoryA PROTO :DWORD,:DWORD
GetSystemDirectory equ <GetSystemDirectoryA>

GetSystemInfo PROTO :DWORD
GetSystemPowerStatus PROTO :DWORD
GetSystemTime PROTO :DWORD
GetSystemTimeAdjustment PROTO :DWORD,:DWORD,:DWORD
GetSystemTimeAsFileTime PROTO :DWORD
GetTapeParameters PROTO :DWORD,:DWORD,:DWORD,:DWORD
GetTapePosition PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
GetTapeStatus PROTO :DWORD
GetTempFileNameA PROTO :DWORD,:DWORD,:DWORD,:DWORD
GetTempFileName equ <GetTempFileNameA>

GetTempPathA PROTO :DWORD,:DWORD
GetTempPath equ <GetTempPathA>

GetThreadContext PROTO :DWORD,:DWORD
GetThreadLocale PROTO
GetThreadPriority PROTO :DWORD
GetThreadPriorityBoost PROTO :DWORD,:DWORD
GetThreadSelectorEntry PROTO :DWORD,:DWORD,:DWORD
GetThreadTimes PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
GetTickCount PROTO
GetTimeFormatA PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
GetTimeFormat equ <GetTimeFormatA>

GetTimeZoneInformation PROTO :DWORD
GetUserDefaultLCID PROTO
GetUserDefaultLangID PROTO
GetVDMCurrentDirectories PROTO :DWORD,:DWORD
GetVersion PROTO
GetVersionExA PROTO :DWORD
GetVersionEx equ <GetVersionExA>

GetVolumeInformationA PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
GetVolumeInformation equ <GetVolumeInformationA>

GetWindowsDirectoryA PROTO :DWORD,:DWORD
GetWindowsDirectory equ <GetWindowsDirectoryA>

GlobalAddAtomA PROTO :DWORD
GlobalAddAtom equ <GlobalAddAtomA>

GlobalAlloc PROTO :DWORD,:DWORD
GlobalCompact PROTO :DWORD
GlobalDeleteAtom PROTO :DWORD
GlobalFindAtomA PROTO :DWORD
GlobalFindAtom equ <GlobalFindAtomA>

GlobalFix PROTO :DWORD
GlobalFlags PROTO :DWORD
GlobalFree PROTO :DWORD
GlobalGetAtomNameA PROTO :DWORD,:DWORD,:DWORD
GlobalGetAtomName equ <GlobalGetAtomNameA>

GlobalHandle PROTO :DWORD
GlobalLock PROTO :DWORD
GlobalMemoryStatus PROTO :DWORD
GlobalMemoryStatusVlm PROTO :DWORD
GlobalReAlloc PROTO :DWORD,:DWORD,:DWORD
GlobalSize PROTO :DWORD
GlobalUnWire PROTO :DWORD
GlobalUnfix PROTO :DWORD
GlobalUnlock PROTO :DWORD
GlobalWire PROTO :DWORD
Heap32First PROTO :DWORD,:DWORD,:DWORD
Heap32ListFirst PROTO :DWORD,:DWORD
Heap32ListNext PROTO :DWORD,:DWORD
Heap32Next PROTO :DWORD
HeapAlloc PROTO :DWORD,:DWORD,:DWORD
HeapCompact PROTO :DWORD,:DWORD
HeapCreate PROTO :DWORD,:DWORD,:DWORD
HeapDestroy PROTO :DWORD
HeapExtend PROTO :DWORD,:DWORD,:DWORD,:DWORD
HeapFree PROTO :DWORD,:DWORD,:DWORD
HeapLock PROTO :DWORD
HeapReAlloc PROTO :DWORD,:DWORD,:DWORD,:DWORD
HeapSize PROTO :DWORD,:DWORD,:DWORD
HeapSummary PROTO :DWORD,:DWORD,:DWORD
HeapUnlock PROTO :DWORD
HeapUsage PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
HeapValidate PROTO :DWORD,:DWORD,:DWORD
HeapWalk PROTO :DWORD,:DWORD
InitAtomTable PROTO :DWORD
InitializeCriticalSection PROTO :DWORD
InitializeCriticalSectionAndSpinCount PROTO :DWORD,:DWORD
InterlockedCompareExchange PROTO :DWORD,:DWORD,:DWORD
InterlockedDecrement PROTO :DWORD
InterlockedExchange PROTO :DWORD,:DWORD
InterlockedExchangeAdd PROTO :DWORD,:DWORD
InterlockedIncrement PROTO :DWORD
InvalidateConsoleDIBits PROTO :DWORD,:DWORD
IsBadCodePtr PROTO :DWORD
IsBadHugeReadPtr PROTO :DWORD,:DWORD
IsBadHugeWritePtr PROTO :DWORD,:DWORD
IsBadReadPtr PROTO :DWORD,:DWORD
IsBadStringPtrA PROTO :DWORD,:DWORD
IsBadStringPtr equ <IsBadStringPtrA>

IsBadWritePtr PROTO :DWORD,:DWORD
IsDBCSLeadByte PROTO :DWORD
IsDBCSLeadByteEx PROTO :DWORD,:DWORD
IsDebuggerPresent PROTO
IsProcessorFeaturePresent PROTO :DWORD
IsValidCodePage PROTO :DWORD
IsValidLocale PROTO :DWORD,:DWORD
LCMapStringA PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
LCMapString equ <LCMapStringA>

LeaveCriticalSection PROTO :DWORD
LoadLibraryA PROTO :DWORD
LoadLibrary equ <LoadLibraryA>

LoadLibraryExA PROTO :DWORD,:DWORD,:DWORD
LoadLibraryEx equ <LoadLibraryExA>

LoadModule PROTO :DWORD,:DWORD
LoadResource PROTO :DWORD,:DWORD
LocalAlloc PROTO :DWORD,:DWORD
LocalCompact PROTO :DWORD
LocalFileTimeToFileTime PROTO :DWORD,:DWORD
LocalFlags PROTO :DWORD
LocalFree PROTO :DWORD
LocalHandle PROTO :DWORD
LocalLock PROTO :DWORD
LocalReAlloc PROTO :DWORD,:DWORD,:DWORD
LocalShrink PROTO :DWORD,:DWORD
LocalSize PROTO :DWORD
LocalUnlock PROTO :DWORD
LockFile PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
LockFileEx PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
LockResource PROTO :DWORD
MapViewOfFile PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
MapViewOfFileEx PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
MapViewOfFileVlm PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
Module32First PROTO :DWORD,:DWORD
Module32Next PROTO :DWORD,:DWORD
MoveFileA PROTO :DWORD,:DWORD
MoveFile equ <MoveFileA>

MoveFileExA PROTO :DWORD,:DWORD,:DWORD
MoveFileEx equ <MoveFileExA>

MoveFileWithProgressA PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
MoveFileWithProgress equ <MoveFileWithProgressA>

MulDiv PROTO :DWORD,:DWORD,:DWORD
MultiByteToWideChar PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
OpenEventA PROTO :DWORD,:DWORD,:DWORD
OpenEvent equ <OpenEventA>

OpenFile PROTO :DWORD,:DWORD,:DWORD
OpenFileMappingA PROTO :DWORD,:DWORD,:DWORD
OpenFileMapping equ <OpenFileMappingA>

OpenJobObjectA PROTO :DWORD,:DWORD,:DWORD
OpenJobObject equ <OpenJobObjectA>

OpenMutexA PROTO :DWORD,:DWORD,:DWORD
OpenMutex equ <OpenMutexA>

OpenProcess PROTO :DWORD,:DWORD,:DWORD
OpenProfileUserMapping PROTO
OpenSemaphoreA PROTO :DWORD,:DWORD,:DWORD
OpenSemaphore equ <OpenSemaphoreA>

OpenWaitableTimerA PROTO :DWORD,:DWORD,:DWORD
OpenWaitableTimer equ <OpenWaitableTimerA>

OutputDebugStringA PROTO :DWORD
OutputDebugString equ <OutputDebugStringA>

PeekConsoleInputA PROTO :DWORD,:DWORD,:DWORD,:DWORD
PeekConsoleInput equ <PeekConsoleInputA>

PeekNamedPipe PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
PostQueuedCompletionStatus PROTO :DWORD,:DWORD,:DWORD,:DWORD
PrepareTape PROTO :DWORD,:DWORD,:DWORD
Process32First PROTO :DWORD,:DWORD
Process32Next PROTO :DWORD,:DWORD
PulseEvent PROTO :DWORD
PurgeComm PROTO :DWORD,:DWORD
QueryDosDeviceA PROTO :DWORD,:DWORD,:DWORD
QueryDosDevice equ <QueryDosDeviceA>

QueryInformationJobObject PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
QueryPerformanceCounter PROTO :DWORD
QueryPerformanceFrequency PROTO :DWORD
QueryWin31IniFilesMappedToRegistry PROTO :DWORD,:DWORD,:DWORD,:DWORD
QueueUserAPC PROTO :DWORD,:DWORD,:DWORD
RaiseException PROTO :DWORD,:DWORD,:DWORD,:DWORD
ReadConsoleA PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
ReadConsole equ <ReadConsoleA>

ReadConsoleInputA PROTO :DWORD,:DWORD,:DWORD,:DWORD
ReadConsoleInput equ <ReadConsoleInputA>

ReadConsoleInputExA PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
ReadConsoleInputEx equ <ReadConsoleInputExA>

ReadConsoleOutputA PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
ReadConsoleOutput equ <ReadConsoleOutputA>

ReadConsoleOutputAttribute PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
ReadConsoleOutputCharacterA PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
ReadConsoleOutputCharacter equ <ReadConsoleOutputCharacterA>

ReadFile PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
ReadFileEx PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
ReadFileScatter PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
ReadFileVlm PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
ReadProcessMemory PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
ReadProcessMemoryVlm PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
RegisterConsoleVDM PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
RegisterWaitForInputIdle PROTO :DWORD
RegisterWowBaseHandlers PROTO :DWORD
RegisterWowExec PROTO :DWORD
ReleaseMutex PROTO :DWORD
ReleaseSemaphore PROTO :DWORD,:DWORD,:DWORD
RemoveDirectoryA PROTO :DWORD
RemoveDirectory equ <RemoveDirectoryA>

RequestWakeupLatency PROTO :DWORD
ResetEvent PROTO :DWORD
ResumeThread PROTO :DWORD
RtlFillMemory PROTO :DWORD,:DWORD,:DWORD
RtlMoveMemory PROTO :DWORD,:DWORD,:DWORD
RtlUnwind PROTO :DWORD,:DWORD,:DWORD,:DWORD
RtlZeroMemory PROTO :DWORD,:DWORD
ScrollConsoleScreenBufferA PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
ScrollConsoleScreenBuffer equ <ScrollConsoleScreenBufferA>

SearchPathA PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
SearchPath equ <SearchPathA>

SetCommBreak PROTO :DWORD
SetCommConfig PROTO :DWORD,:DWORD,:DWORD
SetCommMask PROTO :DWORD,:DWORD
SetCommState PROTO :DWORD,:DWORD
SetCommTimeouts PROTO :DWORD,:DWORD
SetComputerNameA PROTO :DWORD
SetComputerName equ <SetComputerNameA>

SetConsoleActiveScreenBuffer PROTO :DWORD
SetConsoleCP PROTO :DWORD
SetConsoleCommandHistoryMode PROTO :DWORD
SetConsoleCtrlHandler PROTO :DWORD,:DWORD
SetConsoleCursor PROTO :DWORD,:DWORD
SetConsoleCursorInfo PROTO :DWORD,:DWORD
SetConsoleCursorPosition PROTO :DWORD,:DWORD
SetConsoleDisplayMode PROTO :DWORD,:DWORD,:DWORD
SetConsoleFont PROTO :DWORD,:DWORD
SetConsoleHardwareState PROTO :DWORD,:DWORD,:DWORD
SetConsoleIcon PROTO :DWORD
SetConsoleInputExeNameA PROTO :DWORD
SetConsoleInputExeName equ <SetConsoleInputExeNameA>

SetConsoleKeyShortcuts PROTO :DWORD,:DWORD,:DWORD,:DWORD
SetConsoleMaximumWindowSize PROTO :DWORD,:DWORD
SetConsoleMenuClose PROTO :DWORD
SetConsoleMode PROTO :DWORD,:DWORD
SetConsoleNumberOfCommandsA PROTO :DWORD,:DWORD
SetConsoleNumberOfCommands equ <SetConsoleNumberOfCommandsA>

SetConsoleOutputCP PROTO :DWORD
SetConsolePalette PROTO :DWORD,:DWORD,:DWORD
SetConsoleScreenBufferSize PROTO :DWORD,:DWORD
SetConsoleTextAttribute PROTO :DWORD,:DWORD
SetConsoleTitleA PROTO :DWORD
SetConsoleTitle equ <SetConsoleTitleA>

SetConsoleWindowInfo PROTO :DWORD,:DWORD,:DWORD
SetCriticalSectionSpinCount PROTO :DWORD,:DWORD
SetCurrentDirectoryA PROTO :DWORD
SetCurrentDirectory equ <SetCurrentDirectoryA>

SetDefaultCommConfigA PROTO :DWORD,:DWORD,:DWORD
SetDefaultCommConfig equ <SetDefaultCommConfigA>

SetEndOfFile PROTO :DWORD
SetEnvironmentVariableA PROTO :DWORD,:DWORD
SetEnvironmentVariable equ <SetEnvironmentVariableA>

SetErrorMode PROTO :DWORD
SetEvent PROTO :DWORD
SetFileApisToANSI PROTO
SetFileApisToOEM PROTO
SetFileAttributesA PROTO :DWORD,:DWORD
SetFileAttributes equ <SetFileAttributesA>

SetFilePointer PROTO :DWORD,:DWORD,:DWORD,:DWORD
SetFileTime PROTO :DWORD,:DWORD,:DWORD,:DWORD
SetHandleCount PROTO :DWORD
SetHandleInformation PROTO :DWORD,:DWORD,:DWORD
SetInformationJobObject PROTO :DWORD,:DWORD,:DWORD,:DWORD
SetLastConsoleEventActive PROTO
SetLastError PROTO :DWORD
SetLocalTime PROTO :DWORD
SetLocaleInfoA PROTO :DWORD,:DWORD,:DWORD
SetLocaleInfo equ <SetLocaleInfoA>

SetMailslotInfo PROTO :DWORD,:DWORD
SetNamedPipeHandleState PROTO :DWORD,:DWORD,:DWORD,:DWORD
SetPriorityClass PROTO :DWORD,:DWORD
SetProcessAffinityMask PROTO :DWORD,:DWORD
SetProcessPriorityBoost PROTO :DWORD,:DWORD
SetProcessShutdownParameters PROTO :DWORD,:DWORD
SetProcessWorkingSetSize PROTO :DWORD,:DWORD,:DWORD
SetStdHandle PROTO :DWORD,:DWORD
SetSystemPowerState PROTO :DWORD,:DWORD
SetSystemTime PROTO :DWORD
SetSystemTimeAdjustment PROTO :DWORD,:DWORD
SetTapeParameters PROTO :DWORD,:DWORD,:DWORD
SetTapePosition PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
SetThreadAffinityMask PROTO :DWORD,:DWORD
SetThreadContext PROTO :DWORD,:DWORD
SetThreadExecutionState PROTO :DWORD
SetThreadIdealProcessor PROTO :DWORD,:DWORD
SetThreadLocale PROTO :DWORD
SetThreadPriority PROTO :DWORD,:DWORD
SetThreadPriorityBoost PROTO :DWORD,:DWORD
SetTimeZoneInformation PROTO :DWORD
SetUnhandledExceptionFilter PROTO :DWORD
SetVDMCurrentDirectories PROTO :DWORD,:DWORD
SetVolumeLabelA PROTO :DWORD,:DWORD
SetVolumeLabel equ <SetVolumeLabelA>

SetWaitableTimer PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
SetupComm PROTO :DWORD,:DWORD,:DWORD
ShowConsoleCursor PROTO :DWORD,:DWORD
SignalObjectAndWait PROTO :DWORD,:DWORD,:DWORD,:DWORD
SizeofResource PROTO :DWORD,:DWORD
Sleep PROTO :DWORD
SleepEx PROTO :DWORD,:DWORD
SuspendThread PROTO :DWORD
SwitchToFiber PROTO :DWORD
SwitchToThread PROTO
SystemTimeToFileTime PROTO :DWORD,:DWORD
SystemTimeToTzSpecificLocalTime PROTO :DWORD,:DWORD,:DWORD
TerminateJobObject PROTO :DWORD,:DWORD
TerminateProcess PROTO :DWORD,:DWORD
TerminateThread PROTO :DWORD,:DWORD
Thread32First PROTO :DWORD,:DWORD
Thread32Next PROTO :DWORD,:DWORD
TlsAlloc PROTO
TlsFree PROTO :DWORD
TlsGetValue PROTO :DWORD
TlsSetValue PROTO :DWORD,:DWORD
Toolhelp32ReadProcessMemory PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
TransactNamedPipe PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
TransmitCommChar PROTO :DWORD,:DWORD
TrimVirtualBuffer PROTO :DWORD
TryEnterCriticalSection PROTO :DWORD
UnhandledExceptionFilter PROTO :DWORD
UnlockFile PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
UnlockFileEx PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
UnmapViewOfFile PROTO :DWORD
UnmapViewOfFileVlm PROTO :DWORD
UpdateResourceA PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
UpdateResource equ <UpdateResourceA>

VDMConsoleOperation PROTO :DWORD,:DWORD
VDMOperationStarted PROTO :DWORD
VerLanguageNameA PROTO :DWORD,:DWORD,:DWORD
VerLanguageName equ <VerLanguageNameA>

VerifyConsoleIoHandle PROTO :DWORD
VirtualAlloc PROTO :DWORD,:DWORD,:DWORD,:DWORD
VirtualAllocEx PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
VirtualAllocVlm PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
VirtualBufferExceptionHandler PROTO :DWORD,:DWORD,:DWORD
VirtualFree PROTO :DWORD,:DWORD,:DWORD
VirtualFreeEx PROTO :DWORD,:DWORD,:DWORD,:DWORD
VirtualFreeVlm PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
VirtualLock PROTO :DWORD,:DWORD
VirtualProtect PROTO :DWORD,:DWORD,:DWORD,:DWORD
VirtualProtectEx PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
VirtualProtectVlm PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
VirtualQuery PROTO :DWORD,:DWORD,:DWORD
VirtualQueryEx PROTO :DWORD,:DWORD,:DWORD,:DWORD
VirtualQueryVlm PROTO :DWORD,:DWORD,:DWORD,:DWORD
VirtualUnlock PROTO :DWORD,:DWORD
WaitCommEvent PROTO :DWORD,:DWORD,:DWORD
WaitForDebugEvent PROTO :DWORD,:DWORD
WaitForMultipleObjects PROTO :DWORD,:DWORD,:DWORD,:DWORD
WaitForMultipleObjectsEx PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
WaitForSingleObject PROTO :DWORD,:DWORD
WaitForSingleObjectEx PROTO :DWORD,:DWORD,:DWORD
WaitNamedPipeA PROTO :DWORD,:DWORD
WaitNamedPipe equ <WaitNamedPipeA>

WideCharToMultiByte PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
WinExec PROTO :DWORD,:DWORD
WriteConsoleA PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
WriteConsole equ <WriteConsoleA>

WriteConsoleInputA PROTO :DWORD,:DWORD,:DWORD,:DWORD
WriteConsoleInput equ <WriteConsoleInputA>

WriteConsoleInputVDMA PROTO :DWORD,:DWORD,:DWORD,:DWORD
WriteConsoleInputVDM equ <WriteConsoleInputVDMA>

WriteConsoleOutputA PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
WriteConsoleOutput equ <WriteConsoleOutputA>

WriteConsoleOutputAttribute PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
WriteConsoleOutputCharacterA PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
WriteConsoleOutputCharacter equ <WriteConsoleOutputCharacterA>

WriteFile PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
WriteFileEx PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
WriteFileGather PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
WriteFileVlm PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
WritePrivateProfileSectionA PROTO :DWORD,:DWORD,:DWORD
WritePrivateProfileSection equ <WritePrivateProfileSectionA>

WritePrivateProfileStringA PROTO :DWORD,:DWORD,:DWORD,:DWORD
WritePrivateProfileString equ <WritePrivateProfileStringA>

WritePrivateProfileStructA PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
WritePrivateProfileStruct equ <WritePrivateProfileStructA>

WriteProcessMemory PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
WriteProcessMemoryVlm PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
WriteProfileSectionA PROTO :DWORD,:DWORD
WriteProfileSection equ <WriteProfileSectionA>

WriteProfileStringA PROTO :DWORD,:DWORD,:DWORD
WriteProfileString equ <WriteProfileStringA>

WriteTapemark PROTO :DWORD,:DWORD,:DWORD,:DWORD
_hread PROTO :DWORD,:DWORD,:DWORD
_hwrite PROTO :DWORD,:DWORD,:DWORD
_lclose PROTO :DWORD
_lcreat PROTO :DWORD,:DWORD
_llseek PROTO :DWORD,:DWORD,:DWORD
_lopen PROTO :DWORD,:DWORD
_lread PROTO :DWORD,:DWORD,:DWORD
_lwrite PROTO :DWORD,:DWORD,:DWORD
lstrcatA PROTO :DWORD,:DWORD
lstrcat equ <lstrcatA>

lstrcmpA PROTO :DWORD,:DWORD
lstrcmp equ <lstrcmpA>

lstrcmpiA PROTO :DWORD,:DWORD
lstrcmpi equ <lstrcmpiA>

lstrcpyA PROTO :DWORD,:DWORD
lstrcpy equ <lstrcpyA>

lstrcpynA PROTO :DWORD,:DWORD,:DWORD
lstrcpyn equ <lstrcpynA>

lstrlenA PROTO :DWORD
lstrlen equ <lstrlenA>


