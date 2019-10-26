; Kod napisany przez Piotra Tarsê
format PE GUI 4.0
entry start
include 'e:\fasm\include\win32a.inc'
include 'ddraw.inc'
section '.data' data readable writeable
  _title db 'ddraw_app',0
  _class db 'QPKA',0
  _error db 'Error',0
  _ddraw_error db 'Direct Draw initialization failed.',0
section '.bss' readable writeable
  hinstance dd ?
  hwnd dd ?
  wc WNDCLASS
  msg MSG
  ddsd DDSURFACEDESC
  ddscaps DDSCAPS
  DDraw DirectDraw
  DDSPrimary DirectDrawSurface
  DDSBack DirectDrawSurface
  DDSPicture DirectDrawSurface
  DDPalette DirectDrawPalette
  frame db ?
  active db ?
  paleta rb 1024
  rect RECT
section '.code' code readable executable
start:
     invoke  GetModuleHandle,NULL
     mov     [hinstance],eax
     invoke  LoadIcon,NULL,IDI_APPLICATION
     mov     [wc.hIcon],eax
     invoke  LoadCursor,NULL,IDC_ARROW
     mov     [wc.hCursor],eax
     mov     [wc.style],0
     mov     [wc.lpfnWndProc],WindowProc
     mov     [wc.cbClsExtra],0
     mov     [wc.cbWndExtra],0
     mov     eax,[hinstance]
     mov     [wc.hInstance],eax
     mov     [wc.hbrBackground],COLOR_BTNSHADOW
     mov     dword [wc.lpszMenuName],NULL
     mov     dword [wc.lpszClassName],_class
     invoke  RegisterClass,wc
     invoke  CreateWindowEx,\
             0,_class,_title,WS_POPUP+WS_VISIBLE,0,0,0,0,NULL,NULL,[hinstance],NULL
     mov     [hwnd],eax
     invoke  DirectDrawCreate,NULL,DDraw,NULL
     or      eax,eax
     jnz     ddraw_error
     comcall DDraw,SetCooperativeLevel,\
             [hwnd],DDSCL_EXCLUSIVE+DDSCL_FULLSCREEN
     or      eax,eax
     jnz     ddraw_error
     comcall DDraw,SetDisplayMode,\
             800,600,8
     or      eax,eax
     jnz     ddraw_error
     mov     [ddsd.dwSize],sizeof.DDSURFACEDESC
     mov     [ddsd.dwFlags],DDSD_CAPS+DDSD_BACKBUFFERCOUNT
     mov     [ddsd.ddsCaps.dwCaps],DDSCAPS_PRIMARYSURFACE+DDSCAPS_FLIP+DDSCAPS_COMPLEX
     mov     [ddsd.dwBackBufferCount],1
     comcall DDraw,CreateSurface,\
             ddsd,DDSPrimary,NULL
     or      eax,eax
     jnz     ddraw_error
     mov     [ddsd.dwSize],sizeof.DDSURFACEDESC
     mov     [ddsd.dwFlags],DDSD_CAPS+DDSD_WIDTH+DDSD_HEIGHT
     mov     [ddsd.ddsCaps.dwCaps],DDSCAPS_SYSTEMMEMORY
     mov     [ddsd.dwWidth],800
     mov     [ddsd.dwHeight],600
     comcall DDraw,CreateSurface,\
             ddsd,DDSPicture,0
     or      eax,eax
     jnz     ddraw_error
     mov    edi,paleta
     mov    ecx,64
     xor    ax,ax
n_kolor1:
     mov    al,ah
     stosb
     xor    al,al
     stosb
     stosb
     add    ah,4
     xor    al,al
     stosb
     loop   n_kolor1
     mov    ecx,64
     xor    ax,ax
n_kolor2:
     mov    al,255
     stosb
     mov    al,ah
     stosb
     xor    al,al
     stosb
     add    ah,4
     xor    al,al
     stosb
     loop   n_kolor2
     mov    ecx,64
     xor    ax,ax
n_kolor3:
     mov    al,255
     stosb
     stosb
     mov    al,ah
     stosb
     add    ah,4
     xor    al,al
     stosb
     loop   n_kolor3
     mov    ecx,64
     mov    ah,255
n_kolor4:
     mov    al,ah
     stosb
     stosb
     stosb
     xor        al,al
     stosb
     dec        ah
     loop   n_kolor4
      comcall DDraw,CreatePalette,\
             DDPCAPS_8BIT+DDPCAPS_ALLOW256,paleta,DDPalette,0
             or      eax,eax
     comcall DDSPrimary,SetPalette,[DDPalette]
     jmp     paint
main_loop:
     invoke  PeekMessage,msg,NULL,0,0,PM_NOREMOVE
     or      eax,eax
     jz      no_message
     invoke  GetMessage,msg,NULL,0,0
     or      eax,eax
     jz      end_loop
     invoke  TranslateMessage,msg
     invoke  DispatchMessage,msg
     jmp     main_loop
    no_message:
     cmp     [active],0
     je      sleep
paint:
     mov     [rect.top],0
     mov     [rect.bottom],600
     mov     [rect.left],0
     mov     [rect.right],800
     inc     [frame]
     comcall DDSPicture,LockSurface,\
             0,ddsd,DDLOCK_WAIT,0
     mov     edi,[ddsd.lpSurface]
        mov     ecx,800*598
        add     edi,800
qnik:   xor     eax,eax
        xor     ebx,ebx
        mov     al,[edi-800]
        mov     bl,[edi-1]
        add     ax,bx
        mov     bl,[edi+1]
        add     ax,bx
        mov     bl,[edi+800]
        add     ax,bx
        shr     ax,2
        sub     al,5
        mov     [edi],al
        inc     edi
        dec     ecx
        jnz     qnik
     comcall DDSPicture,UnlockSurface,0
     comcall DDSPrimary,BltFast,\
             0,0,[DDSPicture],rect,DDBLTFAST_NOCOLORKEY+DDBLTFAST_WAIT
     jmp     main_loop
sleep:
     invoke  WaitMessage
     jmp     main_loop
ddraw_error:
     invoke  MessageBox,[hwnd],_ddraw_error,_error,MB_OK
     invoke  DestroyWindow,[hwnd]
     invoke  PostQuitMessage,1
     jmp     main_loop
end_loop:
     invoke  ExitProcess,[msg.wParam]
proc WindowProc, hwnd,wmsg,wparam,lparam
     push    ebx esi edi
     mov     eax,[wmsg]
     cmp     eax,WM_CREATE
     je      wmcreate
     cmp     eax,WM_DESTROY
     je      wmdestroy
     cmp     eax,WM_ACTIVATE
     je      wmactivate
     cmp     eax,WM_SETCURSOR
     je      wmsetcursor
     cmp     eax,WM_KEYDOWN
     je      wmkeydown
    defwindowproc:
     invoke  DefWindowProc,[hwnd],[wmsg],[wparam],[lparam]
     jmp     finish
    wmcreate:
     xor     eax,eax
     jmp     finish
    wmkeydown:
     cmp     [wparam],VK_ESCAPE
     jne     finish
    wmdestroy:
     comcall DDraw,RestoreDisplayMode
     comcall DDraw,Release
     invoke  PostQuitMessage,0
     xor     eax,eax
     jmp     finish
    wmactivate:
     mov     eax,[wparam]
     mov     [active],al
     jmp     finish
    wmsetcursor:
     invoke  SetCursor,0
     xor     eax,eax
    finish:
     pop     edi esi ebx
     return
endp

section '.idata' import data readable

library kernel,'KERNEL32.DLL',\
        user,'USER32.DLL',\
        ddraw,'DDRAW.DLL'

import kernel,\
       GetModuleHandle,'GetModuleHandleA',\
       CreateFile,'CreateFileA',\
       ReadFile,'ReadFile',\
       CloseHandle,'CloseHandle',\
       GetTickCount,'GetTickCount',\
       ExitProcess,'ExitProcess'

import user,\
       RegisterClass,'RegisterClassA',\
       CreateWindowEx,'CreateWindowExA',\
       DestroyWindow,'DestroyWindow',\
       DefWindowProc,'DefWindowProcA',\
       GetMessage,'GetMessageA',\
       PeekMessage,'PeekMessageA',\
       TranslateMessage,'TranslateMessage',\
       DispatchMessage,'DispatchMessageA',\
       LoadCursor,'LoadCursorA',\
       LoadIcon,'LoadIconA',\
       SetCursor,'SetCursor',\
       MessageBox,'MessageBoxA',\
       PostQuitMessage,'PostQuitMessage',\
       WaitMessage,'WaitMessage'

import ddraw,\
       DirectDrawCreate,'DirectDrawCreate'
