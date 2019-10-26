
 ;A  light weight  set  of  equates  lifted  from  win32.inc;
 VK_ESCAPE    = (0x0000001B)
 SRCCOPY      = (0x00CC0020)
 WS_POPUP     = (0x80000000)
 WS_VISIBLE   = (0x10000000)
 WS_MAXIMIZE  = (0x01000000)
 PM_REMOVE    = (0x00000001)
 WM_KEYDOWN   = (0x00000100)
 WM_KEYUP     = (0x00000101)
 SM_CXSCREEN  = (0x00000000)
 SM_CYSCREEN  = (0x00000001)

 ;      eax = imagebase of user32.dll
 ;      ebx = imagebase
 ;      esi = 0040006A
 ;      edi = 0040004C
 ;      ebp = 00000000
 mainCRTStartup:
        ;memset(stack,0,sizeof(arguments));
        push     SizeStackClear ; 0x24
        pop      ecx
        push     ebp
        loop     $-1

        ;decompress(stack, &PackedStack);
        lea      esi, [esi + PtrStack]
        mov      cl, NumStackValues
        lodsw
        movzx    edx, al
        mov      [esp + edx], ah
        loop     $-8

        ;StretchDIBits->lpBitMapInfo = &BitMapInfo
        ;Must be calculated at runtime
        lea      ebp, [esp + BitMapInfo]
        mov      [esp + 0x58], ebp
        neg      dword [ebp + 0x08] ; uncomment to blit pixels upside down instead

        ;create the window...
        tinycall ShowCursor ;(FALSE);
        tinycall CreateWindowEx ;(0,"edit",0,WS_POPUP|WS_MAXIMIZE|WS_VISIBLE,0,0,0,0,0,0,0,0);
        mov      edx, esp ; our RECT struct doubles as StretchDIBits arguments
        tinycall GetWindowRect, eax, edx, eax ; the last eax is hWnd for GetDC
        tinycall GetDC ;(hwnd);
        push     eax ; StretchDIBits(hdc...

 ; Execution is allowed to fall through to demo
