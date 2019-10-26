
 format binary as 'exe'

 macro tinycall proc,[arg]
 {
    common
    if ~ arg eq
        reverse
        pushd arg
        common
    end if
    call dword [ebx + proc]
 }

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

 RESX equ 256
 RESY equ 192

 ImageBase  = 0x00400000
 SizeOfHdr  = 0x0088     ; 0x94
 SizeOfCode = 0x00600080 ; 0x00040004 ; 0x00010000 + 196608 ; (196608 = 4*(RESX)*(RESY))

;GetSystemMetrics dd 0xB9DAA600
 use32
 root:  dec      ebp
        pop      edx
        jmp      jump
                 dd 'PE'       ; .Signature
                 dw 0x014C     ; .Machine
                 dw 0x0000     ; .NumberOfSections
 LoadLibrary     dd 0xE9826FC6 ; .TimeDateStamp       
 GetWindowRect   dd 0xF9AC1F38 ; .PointerToSymbolTable
 ShowCursor      dd 0x19A434A8 ; .NumberOfSymbols     
                 dw 0x0010     ; .SizeOfOptionalHeader
                 dw 0x010F     ; .Characteristics (no relocations, executable, 32 bit)
 Op_Hdr:
                 dd 0x0000010B ; .Magic .MajorLinkerVersion .MinorLinkerVersion          
 PeekMessage     dd 0xEA1682FE ; .SizeOfCode              
 StretchDIBits   dd 0x4ED54D5C ; .SizeOfInitializedData
 ExitProcess     dd 0x38A66AE8 ; .SizeOfUninitializedData
                 dd root       ; .AddressOfEntryPoint
 CreateWindowEx  dd 0xF8820ECC ; .BaseOfCode
                 dd 'edit'     ; .BaseOfData
                 dd ImageBase  ; .ImageBase
                 dd 0x00000004 ; .SectionAlignment                            
                 dd 0x00000004 ; .FileAlignment                             
 GetDC           dd 0xA4D450D1 ; .MajorOperatingSystemVersion 
 wave            dd 0x3DC90FDB ; .MinorOperatingSystemVersion .MajorImageVersion
                 dw 0x0004     ; .MajorSubsystemVersion
 jump:  push     0x30
        pop      ecx
        push     edx
        jmp      kern
                 dd SizeOfCode ; .SizeOfImage
                 dd SizeOfHdr  ; .SizeOfHeaders
 libname:        dd 'gdi3'     ; .CheckSum
                 dw 0x0002     ; .Subsystem
                 dw 0x0000     ; .DllCharacteristics
        SizeStackClear = 0x24
        NumStackValues = 0x0F
        BitMapInfo     = 0x68
        PtrStack       = (PackedStack-libname)+3
 PackedStack:
        db 0x08, 0x34 ; <- &edit
        db 0x0A, 0x40 ; <- &edit+ImageBase
        db 0x13, 0x91 ; <- window style WS_POPUP|WS_MAXIMIZE|WS_VISIBLE
        db 0x60, 0x20 ; <- LOWORD(SRCCOPY);
        db 0x4D, 0x01 ; <- StretchDIBits->nSrcWidth = RESX
        db 0x68, 0x28 ; <- bmi.bmiHeader.biSize = sizeof(BITMAPINFOHEADER);
        db 0x56, 0x41 ; <- 41 here is compressed 00410000 == &pixel[0]
        db 0x50, 0xC0 ; <- StretchDIBits->nSrcHeight = RESY
        db 0x62, 0xCC ; <- HIWORD(SRCCOPY);
        db 0x6D, 0x01 ; <- bmi.bmiHeader.biWidth = RESX;
        dd 0x00000000 ; .NumberOfRvaAndSizes
        db 0x76, 0x20 ; <- bmi.bmiHeader.biBitCount = 32;
        db 0x70, 0xC0 ; <- bmi.bmiHeader.biHeight = RESY;
        db 0x74, 0x01 ; <- bmi.bmiHeader.biPlanes = 1;

 kern:  mov      eax, [fs : ecx]          ; 64 8B 01
        mov      eax, [eax+0x0C]          ; 8B 40 0C
        mov      eax, [eax+0x1C]          ; 8B 40 1C
 base:  mov      edx, [eax+0x20]          ; 8B 50 20
        mov      ebp, [eax+0x08]          ; 8B 68 08
        cmp      [edx+0x18], ch           ; 38 6A 18
        mov      eax, [eax]               ; 8B 00
        jnz      base                     ; 75 F3
        mov      esi, ImageBase+libname   ; BE 5C 00 40 00
        jmp      libs                     ;
 hash:  mov      ecx, [edx+0x18]          ; 8B 4A 18       ; ecx = Num Exports
 redo:  jecxz    done                     ; E3 2E          ; ecx = 0 No More Exports
        dec      ecx                      ; 49             ; ecx = Num Exports Decreased
        mov      esi, [edx+0x20]          ; 8B 72 20       ; edi = RVA Exports Asciiz
        add      esi, ebp                 ; 01 EE          ; edi = RVA -> VA
        mov      esi, [esi+ecx*0x04]      ; 8B 34 8E       ; esi = RVA Export Asciiz Index
        add      esi, ebp                 ; 01 EE          ; esi = RVA -> VA
        mov      ebx, 0x00000000          ; BB 00 00 00 00 ; .PointerToLinenumbers
 calc:  lodsb                             ; AC             ; al  = Char Export Asciiz
        rol      ebx, 0x06                ; C1 C3 06       ; ebx = Hash Preparation
        xor      bl, al                   ; 30 C3          ; ebx = Hash Complete
        test     al, al                   ; 84 C0          ; al  = 0 Only For End of Asciiz
        jnz      calc                     ; 75 F6          ; If Not Zero Keep Hashing
        cmp      ebx, [edi]               ; 3B 1F          ; Check Hash Against Input
        jnz      redo                     ; 75 E3          ; If Not Equal Hash Next Function
        mov      ebx, [edx+0x24]          ; 8B 5A 24       ; edi = RVA Function Ordinal
        add      ebx, ebp                 ; 01 EB          ; edi = RVA -> VA
        movzx    ecx, word [ebx+ecx*0x02] ; 0F B7 0C 4B    ;
        mov      ebx, [edx+0x1C]          ; 8B 5A 1C       ; edi = Function RVAS List
        add      ebx, ebp                 ; 01 EB          ; edi = RVA -> VA
        add      ebp, [ebx+ecx*0x04]      ; 03 2C 8B       ; eax = Function RVA
        mov      [edi], ebp               ; 89 2F
        jmp      done

 libs:  or       byte [esi+0x04], cl
        mov      ebx, esi
        mov      bl, ch
 scan:  push     0x13                                       ;
        pop      ecx                                        ; LoadLibrary trashes ecx
 func:  pusha
        lea      edi, [ebx+ecx*0x04]
        mov      eax, [ebp+0x3C]          ; 8B 45 3C       ; eax = RVA NT Header
        mov      edx, [ebp+eax+0x78]      ; 8B 54 05 78    ; edx = RVA Data Directory
        add      edx, ebp                 ; 01 EA          ; edx = RVA -> VA
        jmp      hash
 done:  popa                              ; 61             ; Restore Registers
        loop     func                     ; E2 EB
        push     esi                      ; 56
        tinycall LoadLibrary ;, esi       ; FF 53 0C
        dec      esi                      ; 4E
        mov      dword [esi], 'user'      ; C7 06 75 73 65 72
        xchg     ebp, eax                 ; 95
        or       ebp, ebp                 ; 09 ED
        jnz      scan                     ; 75 DE

 start: push     SizeStackClear ; 0x24
        pop      ecx
        push     ebp
        loop     $-1
        lea      esi, [esi + PtrStack]
        mov      cl, NumStackValues
        lodsw
        movzx    edx, al
        mov      [esp+edx], ah
        loop     $-8
        lea      ebp, [esp+BitMapInfo]
        mov      [esp+0x58], ebp
        tinycall ShowCursor
        tinycall CreateWindowEx
        mov      edx, esp
        tinycall GetWindowRect, eax, edx, eax
        tinycall GetDC
        push     eax

        RESX  equ 256
        RESY  equ 192
        ResX  equ ebp+0x1C
        ResY  equ ebp+0x20
        Size  equ ebp+0x1F
        Pixel equ ebp+0x24
        msg   equ edi
        
 pump:  ;xor      ecx, ecx
        mov      ebp, esp
        tinycall PeekMessage, msg, ecx, ecx, ecx, PM_REMOVE
        tinycall StretchDIBits
        mov      esp, ebp

        mov      eax, [ResX]
        cmp      eax, [msg + 4]
        jnz      main
        tinycall ExitProcess

        x         = 0x0A
        y         = 0x0A
        HalfResX  = 0x54
        HalfResY  = 0x56
        time      = 0x78
        SixtyFour = 0x3A
        Sixteen   = 0x18
        NinetySix = 0x56
;ebx image pointer
;ebp frame pointer
;esi const pointer
;edx temp pointer
;edi pixel pointer
;ecx loop counter
 main:  fld      dword [ebx+time]
        fadd     dword [ebx+wave]
        fstp     dword [ebx+time]
        
        mov      edi, [Pixel]
        mov      ecx, [Size]
 draw:  dec      ecx
        jz       pump
        finit
        push     0x0A
        pop      dword [edi]

        lea      esi, [ebx+0x18] ;0x0010
        lea      edx, [ebx+0x2C] ;0x00000000
        ;float dirx = (float)(x+x-ResX);
        ;float diry = fabs((float)(y+y-ResY));
        ;float dirz = (float)ResX;
        mov      byte  [edx], cl  ;
        fild     word  [edx]      ;
        fisub    word  [ebx+0x54] ; ResX/2
        mov      byte  [edx], ch  ;
        fild     word  [edx]      ;
        fisub    word  [ebx+0x56] ; ResY/2
        fabs                      ;
        fild     word [ResX]      ;
        
        ;float norm = 1.0f/sqrt(dirx*dirx + diry*diry + dirz*dirz);
        fld      st2
        fmul     st0, st0
        fld      st2
        fmul     st0, st0
        fld      st2
        fmul     st0, st0
        faddp    st1, st0
        faddp    st1, st0
        fsqrt
        fld1
        fdivrp   st1, st0
        
        ;dirx *= norm;
        ;diry *= norm;
        ;dirz *= norm;
        fmul     st3, st0
        fmul     st2, st0
        fmulp    st1, st0
        
        ;float posx = sin(time*wave)*0x40;
        ;float posy = cos(time*wave)*0x10-0x20;
        ;float posz = 0x60;
        fld      dword [ebx+time]
        fsincos
        fimul    word  [ebx+0x3A] ; 0x0040
        fxch
        fimul    word [esi]
        fisub    word [esi]
        fisub    word [esi]

        fild     word [ResX] ; 0x0080

 cast:  ;do {
        ;dist = fabs(posy + 0x10*sin(posx*wave)*sin(posz*wave));
        fld      st0
        fmul     dword [ebx+wave]
        fsin
        fld      st3
        fmul     dword [ebx+wave]
        fsin
        fmulp    st1, st0
        fimul    dword [edi]
        fadd     st0, st2
        fabs
        fist     dword [ebx]


        ;posx += dist*dirx;
        ;posy += dist*diry;
        ;posz += dist*dirz;
        fld      st6
        fmul     st0, st1
        faddp    st4, st0
        fld      st5
        fmul     st0, st1
        faddp    st3, st0
        fld      st4
        fmulp    st1, st0
        faddp    st1, st0

        ;} while ((int)posz < 0x0200 && (int)dist>1);
        cmp      dword [ebx], 0x00000004
        jbe      colr
        fist     dword [ebx]
        cmp      dword [ebx], 0x00000800
        jb       cast

 colr:
        ;int b = (int)fabs(posy*0x100/posz)<<2;
        ;int r = ((int)posx^(int)posz)&0x10;
        ;r = (int)(r*0x100/posz);
        fild      dword [ResX]
        fdivrp    st1, st0
        fmulp     st1, st0
        fimul     dword [edi]
        fabs

        fistp    dword [edi]
        mov      eax, [edi]
        stosb
        stosb
        stosb
        scasb
        jmp      draw
        db 0