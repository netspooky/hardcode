gdi32Offset=02FFh
glu32Offset=0309h
user32Offset=031Dh
exportedFunctionCount=732
openglOffset=0
openglExportedFunctionCount=732
gdiExportedFunctionCount=732
userExportedFunctionCount=732
userOffset=openglOffset+openglExportedFunctionCount*4
gdiOffset=userOffset+userExportedFunctionCount*4
bytesForExport=(userExportedFunctionCount+openglExportedFunctionCount+gdiExportedFunctionCount)*4
_ChangeDisplaySettingsA equ edi+userOffset+(userExportedFunctionCount-33)*4
_CreateWindowExA equ edi+userOffset+(userExportedFunctionCount-97)*4
_GetAsyncKeyState equ edi+userOffset+(userExportedFunctionCount-243)*4
_GetDC equ edi+userOffset+(userExportedFunctionCount-269)*4
_GetSystemMetrics equ edi+userOffset+(userExportedFunctionCount-350)*4
_ShowCursor equ edi+userOffset+(userExportedFunctionCount-655)*4
_CreateFontA equ edi+gdiOffset+(gdiExportedFunctionCount-58)*4
_SelectObjectA equ edi+gdiOffset+(gdiExportedFunctionCount-527)*4
_SetPixelFormat equ edi+gdiOffset+(gdiExportedFunctionCount-563)*4
_GlobalAlloc equ 472
_LoadLibraryA equ 559