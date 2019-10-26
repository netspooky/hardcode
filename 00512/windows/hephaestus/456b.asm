
 format binary as 'exe'

 ;this includes the header  and  boot strapper only use this;
 ;include  file  as  a  basis if you want to try you hand at;
 ;altering the  function  calls.  It only bootstraps without;
 ;any gdi32 framework, But the data in the PE header remains;
 ;in place.                                                 ;
 ;include 'tiny.inc'

 ;Define a few constants required for the PE/Optional header;
 SizeOfHdr  = 148
 SizeOpHdr  = SizeOfHdr - Op_Hdr

 ;Any value greater than or equal to 64kb  (aligned to 64kb);
 ImageBase  = 0x00400000

 ;This is the size of both code  and  data (both initialized;
 ;and unitialized). You are free to expand this as necessary;
 ;Think of this feild as your malloc of choice.              ;
 SizeOfCode = 0x00080000

 ;This  macro  replaces  invoke with a version that uses ebx;
 ;which is pointing at the table of function pointers and an;
 ;offset to the desired  function. This reduces invokes from;
 ;five bytes to just three. The penalty paid is that ebx now;
 ;needs to be preserved on the stack before it can be used. ;
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

 ;I can't find any better use for these bytes then to simply;
 ;execute the 'MZ' sig  :D  This is also where ebx points to;
 ;the function pointer table.  Later when init has completed;
 ;we use this offset for our  MSG  structure, PeekMessage is;
 ;only  called  after  these function pointers can be safely;
 ;discarded. Try to keep your uninitialized variables within;
 ;a range of 128 bytes from here, so they can be accessed by;
 ;[ebx + offset]                                            ;
 use32
 root:           dec ebp  ; 4D 'M' ; .e_magic
                 pop edx  ; 5A 'Z' ;
                 jmp jump ; EB 4A  ; .e_cblp
 NT_Hdr:         dd 'PE'           ; .Signature
                 dw 0x014C         ; .Machine
                 dw 0x0000         ; .NumberOfSections
 LoadLibrary     dd 0xE9826FC6     ; .TimeDateStamp
 GetWindowRect   dd 0xF9AC1F38     ; .PointerToSymbolTable
 ShowCursor      dd 0x19A434A8     ; .NumberOfSymbols
                 dw SizeOpHdr      ; .SizeOfOptionalHeader
                 dw 0x010F         ; .Characteristics (no relocations, executable, 32 bit)
 Op_Hdr:         dw 0x010B         ; .Magic
                 db 0x00           ; .MajorLinkerVersion
                 db 0x00           ; .MinorLinkerVersion
 PeekMessage     dd 0xEA1682FE     ; .SizeOfCode
 StretchDIBits   dd 0x4ED54D5C     ; .SizeOfInitializedData
 ExitProcess     dd 0x38A66AE8     ; .SizeOfUninitializedData
                 dd root           ; .AddressOfEntryPoint
 CreateWindowEx  dd 0xF8820ECC     ; .BaseOfCode
                 dd 'edit'         ; .BaseOfData
                 dd ImageBase      ; .ImageBase
                 dd 0x00000004     ; .SectionAlignment
                 dd 0x00000004     ; .FileAlignment
 GetDC           dd 0xA4D450D1     ; .MajorOperatingSystemVersion
                 dd 0              ; .MinorOperatingSystemVersion .MajorImageVersion
                 dw 0x0004         ; .MajorSubsystemVersion
 jump:           push 0x30 ; 6A 30 ; .MinorSubsystemVersion  ; (needed during bootstrap to access PEB)
                 pop  ecx  ; 59    ; .Win32VersionValue      ; (keep 0x30 is ecx)
                 push edx  ;       ;
                 jmp  kern ;       ;
                 dd SizeOfCode     ; .SizeOfImage
                 dd SizeOfHdr      ; .SizeOfHeaders
 libname:        dd 'gdi3'         ; .CheckSum               ; needed for LoadLibraryA (gets converted to 'user32' at runtime)
                 dw 0x0002         ; .Subsystem              ; we or this with 0x30 to convert 0x0002 into '2\0'
                 dw 0x0000         ; .DllCharacteristics     ; this must be zero for compatibility

 ;Too much bloat if we go pushing  immediates onto the stack;
 ;as and when we need them.  Instead we decompress our stack;
 ;in advance  and we take care to repoint esp correctly when;
 ;we are in the main loop.  Then we only need to push things;
 ;which either don't compress well with this method  or need;
 ;to be found out at runtime. Here is the method:           ;
 ;[1] Zero out enough space on the stack in advance.        ;
 ;[2] Decompress our packed stack using esp as base pointer ;
 ;[3] Load the offset from esp to the bytes destination     ;
 ;[4] Load the value to store at that destination           ;
 ;[5] Store the byte.                                       ;
 ;Notice that we define  BITMAPINFO on the stack, Most of it;
 ;is made of zero bytes. Same for PIXELFORMATDESCRIPTOR  (if;
 ;we needed to define one)  they compress well. Pixel buffer;
 ;is located at 0x00410000, which has only one non zero byte;
 ;Our window style in CreateWindowEx is 0x91000000, also has;
 ;only one non zero byte.  ResX and ResY fit into a non zero;
 ;byte. Can you see a pattern emerging here?                ;
 ;SRCCOPY requires two bytes but notice they are not located;
 ;together in the packed stack. The reason is that these are;
 ;also feilds belonging to the PE Header & must remain valid;
 ;You must be careful how you lay out this data. But there's;
 ;some room for playing around.                             ;
 ;But there is a penalty with this approach. We need to keep;
 ;preserving and restoring our stack frame.                 ;
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

 ; These local variables will exist on the unpacked stack as
 ; arguments to StretchDIBits and they are also used to load
 ; 32 bit immediates into registers, only 3 bytes per access
 ResX  equ esp + 0x1C ; local int
 ResY  equ esp + 0x20 ; local int
 Size  equ esp + 0x1F ; local int size = ResX<<8 (This is ResY offset by one byte as RESX==0x100)
 Pixel equ esp + 0x24 ; local int*
;msg   equ ebx        ; By the time we call PeekMessage we no longer need the function pointers it trashes
 msg   equ edi        ; By the time we call PeekMessage we no longer need the function pointers it trashes
;Seed  equ ebx + 0x64 ;
 Seed  equ ebp + 0x30 ;

 ; The size of our pixel buffer was choosen carefully. A width
 ; of 256 pixels allows for using one register as loop counter
 ; for both x and y simultaeniously. 192 is the height to make
 ; square pixels. Now loop setup is halved.
 RESX  equ 256        ; const int
 RESY  equ 192        ; const int

 ; Here we search the PEB for kernel32s base address
 ; This is done using an adaption that is compatible
 ; with Windows 7 NT Loader
 ;     edx = return to ntldr
 ;     ecx = 0x00000030
 kern: mov     eax, [fs : ecx]              ; 64 8B 01
       mov     eax, [eax + 0x0C]            ; 8B 40 0C
       mov     eax, [eax + 0x1C]            ; 8B 40 1C
 base: mov     edx, [eax + 0x20]            ; 8B 50 20
       mov     ebp, [eax + 0x08]            ; 8B 68 08
       cmp     [edx + 0x18], ch             ; 38 6A 18
       mov     eax, [eax]                   ; 8B 00
       jnz     base                         ; 75 F3
       mov     esi, ImageBase + libname     ;
       jmp     imports                      ;

 ; Here we take our hashed function & we scan our newly
 ; loaded dll for the desired function.
 ;     ebp = imagebase of dll
 ;     eax = imagebase + &NT_Hdr
 ;     edx = imagebase + &DataDirectory
 ;     esi = &libname
 ;     edi = &hashed function name
 hash: mov     ecx, [edx + 0x18]            ; 8B 4A 18       ; ecx = Num Exports
 redo: jecxz   done                         ; E3 2E          ; ecx = 0 No More Exports
       dec     ecx                          ; 49             ; ecx = Num Exports Decreased
       mov     esi, [edx + 0x20]            ; 8B 72 20       ; edi = RVA Exports Asciiz
       add     esi, ebp                     ; 01 EE          ; edi = RVA -> VA
       mov     esi, [esi + ecx * 0x04]      ; 8B 34 8E       ; esi = RVA Export Asciiz Index
       add     esi, ebp                     ; 01 EE          ; esi = RVA -> VA
       mov     ebx, 0x00000000              ; BB 00 00 00 00 ; .PointerToLinenumbers
 calc: lodsb                                ; AC             ; al  = Char Export Asciiz
       rol     ebx, 0x06                    ; C1 C3 06       ; ebx = Hash Preparation
       xor     bl, al                       ; 30 C3          ; ebx = Hash Complete
       test    al, al                       ; 84 C0          ; al  = 0 Only For End of Asciiz
       jnz     calc                         ; 75 F6          ; If Not Zero Keep Hashing
       cmp     ebx, [edi]                   ; 3B 1F          ; Check Hash Against Input
       jnz     redo                         ; 75 E3          ; If Not Equal Hash Next Function
       mov     ebx, [edx + 0x24]            ; 8B 5A 24       ; edi = RVA Function Ordinal
       add     ebx, ebp                     ; 01 EB          ; edi = RVA -> VA
       movzx   ecx, word [ebx + ecx * 0x02] ; 0F B7 0C 4B    ;
       mov     ebx, [edx + 0x1C]            ; 8B 5A 1C       ; edi = Function RVAS List
       add     ebx, ebp                     ; 01 EB          ; edi = RVA -> VA
       add     ebp, [ebx + ecx * 0x04]      ; 03 2C 8B       ; eax = Function RVA
       mov     [edi], ebp                   ; 89 2F
       jmp     done

 ; Here we import our needed functions by hash and
 ; Load any necessary dll's. I'd imagine that this
 ; can be crunched down even further but I haven't
 ; been able to get this part crunched yet.
 ;     esi = &libname
 ;     ecx = 0x00000030
 ;     eax = imagebase kernel32.dll
 imports:
       or       byte [esi+4], cl
       mov      ebx, esi
       mov      bl, ch
 scan: push     0x13                                       ;
       pop      ecx                                        ; LoadLibrary trashes ecx
 func: pusha
       lea      edi, [ebx + ecx * 0x04]
       mov      eax, [ebp + 0x3C]            ; 8B 45 3C       ; eax = RVA NT Header
       mov      edx, [ebp + eax + 0x78]      ; 8B 54 05 78    ; edx = RVA Data Directory
       add      edx, ebp                     ; 01 EA          ; edx = RVA -> VA
       jmp      hash
 done: popa                                  ; 61             ; Restore Registers
       loop     func                         ; E2 EB
 libs: push     esi                          ; 56
       tinycall LoadLibrary ;, esi           ; FF 53 0C
       dec      esi                          ; 4E
       mov      dword [esi], 'user'          ; C7 06 75 73 65 72
       xchg     ebp, eax                     ; 95
       or       ebp, ebp                     ; 09 ED
       jnz      scan                         ; 75 DE









 ; Bootstrapping is now complete we have all our
 ; functions loaded as necessary. Execution will
 ; through to mainCRTStartup
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

        ;eax = hdc
        ;ebx = imagebase == &msg
 Pallet:mov      esi, [Pixel]       ; esi = &pixel[0] (is on the stack as an argument to StretchDIBits)
        mov      ecx, [ResX]        ; ecx = NumColors = ResX = 256
        mov      edi, [Size]        ; edi = ResX*ResY
        lea      edi, [esi + edi*8] ; edi = &pallet[0]
        xor      edx, edx           ; used for conditional move during the
        dec      edx                ; saturated add clamping colour to 0xFF
 Colr:  ;Cold = 0x00 ... Hot = 0xFF
        mov      al, cl             ; al = colour
        rol      eax, 0x01          ; eax = colour*2
        test     ah, 0x01           ; clamp(colour*2, 255)
        cmovnz   eax, edx           ; conditional move clamped value
        mov      ah, al             ; red = clamp(colour*2, 255)
        mov      al, cl             ; grn = colour
        shl      eax, 0x08          ; blu = 0
        mov      [edi + ecx*4], eax ; store colour in clut
        loop     Colr               ; Colour 0 is already black

        ;ebx = imagebase == &msg
        ;esi = &Pallet[0]
        ;edi = &Pixel[0]
        ;ecx = 0x00000000
 main:
        mov      edi, [Pixel]       ; edi = &pixel[0] (is on the stack as an argument to StretchDIBits)
        mov      ecx, [Size]        ; ecx = RESX*RESY (RESY is on the stack we offset it by 1 byte as RESX == 256)
        mov      ebp, [ResX]

       ;Here we gather heat from the pixels below
        pusha
       ;add      ch, 0x02 ; bottom 2 rows look glitchy this is the fix
 Heat:  xor      eax, eax
        xor      edx, edx
        mov      al, byte [edi + ebp*4 + 0 + 1] ; green only
        mov      dl, byte [edi + ebp*4 + 4 + 1] ; green only
        add      eax, edx
        mov      dl, byte [edi + ebp*4 - 4 + 1] ; green only
        add      eax, edx
        mov      dl, byte [edi + ebp*8 + 0 + 1] ; green only
        add      eax, edx
        stosd
        loop     Heat
        popa

;       ;Here we gather heat from the pixels below
;        pusha
;        lea      esi, [edi + ecx*4]
;        mov      ebx, ebp
;        neg      ebp
; Cool:  xor      eax, eax
;        xor      edx, edx
;        mov      al, byte [esi + ebp*8 + 0 + 1] ; green only
;        mov      dl, byte [esi + ebp*4 + 4 + 1] ; green only
;        add      eax, edx
;        mov      dl, byte [esi + ebp*4 - 4 + 1] ; green only
;        add      eax, edx
;        ;mov      dl, byte [esi + ebx*4 + 0 + 1] ; green only
;        ;add      eax, edx
;        shl      eax, 0x02
;        mov      [esi], eax
;        sub      [edi], eax
;        cmpsd
;        loop     Cool
;        popa

       ;Cool the heat a little
        push     ebx                ;
        lea      ebx, [edi + ecx*8] ; ebx = &pallet[0]
        ;inc      ebp                ;
        ;shl      ebp, 0x0A          ; ebp = 0x00040100

        mov      ebp, 0x00040100
        mov      esi, edi           ;
 Draw:  lodsd                       ;
        shl      eax, 0x10          ;
        cdq                         ;
        idiv     ebp                ;
        mov      eax, [ebx + eax*4] ; clut
        stosd                       ;
        loop     Draw               ;
        pop      ebx                ;

       ;Keep adding random flames below the bottom row of pixels
        mov      ch, 0x02
 Burn:  sbb      eax, [Seed + 2]
        adc      [Seed + 1], edi
        stosd
        loop     Burn

 Pump:  ;We need to push these args ever iteration of the main loop
        ;as the call to StretchDIBits will trash the red zone. Just
        ;ensure that some register (ecx in this case) is zero here.
        tinycall PeekMessage, msg, ecx, ecx, ecx, PM_REMOVE

 Blit:  ;finally we get to blit our pixel buffer to the screen! All
        ;that hard work just so we can make this one call.
        mov      ebp, esp ; preserve this stackframe
        tinycall StretchDIBits ;(hdc,rc.left,rc.top,rc.right,rc.bottom,0,0,ResX,ResY,pixel,0,SRCCOPY);
        mov      esp, ebp ; repair the stack frame (preserves StretchDIBits arguments)

        ;Now we test for any keydown and escape if necessary
 Quit:  mov      eax, [ResX]    ; if ((eax = 0x00000100) == WM_KEYDOWN == msg.message) ExitProcess(0);
        cmp      eax, [msg + 4] ;
        jnz      main           ;
        tinycall ExitProcess    ;0

;Greetz: db 'brought to you by rain_storm of http://www.dbfinteractive.com/',0,0
