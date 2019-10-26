
 format  binary as 'exe'
 include 'BootStrap.inc'
 include 'FrameWork.inc'

 ;Define a few constants required for the PE/Optional header;
 ImageBase  = 0x00400000 ;Any value greater than or equal to 64kb  (aligned to 64kb);
 SizeOfCode = 0x00100000 ;Size of code and data (use this as your malloc)

 ; These local variables will exist on the unpacked stack as
 ; arguments to StretchDIBits and they are also used to load
 ; 32 bit immediates into registers, only 3 bytes per access
 ResX  equ ebp + 0x1C ; local int
 ResY  equ ebp + 0x20 ; local int
 Size  equ ebp + 0x1F ; local int size = ResX<<8 (This is ResY offset by one byte as RESX==0x100)
 Pixel equ ebp + 0x24 ; local int*
 msg   equ ebx        ; By the time we call PeekMessage we no longer need the function pointers it trashes
 Seed  equ ebp + 0x34 ;

 ; The size of our pixel buffer was choosen carefully. A width
 ; of 256 pixels allows for using one register as loop counter
 ; for both x and y simultaeniously. 192 is the height to make
 ; square pixels. Now loop setup is halved.
 RESX     equ 256        ; const int
 RESY     equ 192        ; const int
 HeatSize = 1
 DrawSize = 4


        ;eax = hdc
        ;ebx = imagebase == &msg
 Init:  mov      ebp, esp ; preserve this stackframe

 ; Step 1 - Generate The CLUT
 ;          Blue is set to black
 ;          Green is double colour index saturated to 255
 ;          Red is quadruple colour index saturated to 255
 Pallet:
        mov      esi, [Pixel]       ; esi = &pixel[0] (is on the stack as an argument to StretchDIBits)
        mov      ecx, [ResX]        ; ecx = NumColors = ResX = 256
        mov      edi, [Size]        ; edi = ResX*ResY
        lea      edi, [esi + edi*8] ; edi = &pallet[0]
        xor      edx, edx           ; used for conditional move during the
        dec      edx                ; saturated add clamping colour to 0xFF
 Colr:  ;Cold = 0x00 ... Hot = 0xFF
        mov      eax, ecx
        add      al, al
        add      al, al
        cmovc    eax, edx
        mov      ah, al
        mov      al, cl
        add      al, cl
        cmovc    eax, edx
        shl      eax, 0x08          ; blu = 0
        mov      [edi + ecx*4], eax ; store colour in clut
        loop     Colr               ; Colour 0 is already black

 Main:

 Render:

 ; Step 2 - Combine the HeatMap and the CoolMap to calculate the pixels temperature
 ;          Don't let pixel temperature drop below zero
 ;          Then convert temperature to colour using the clut
        push     ebp                       ; heat map
        push     ebx                       ; cool map
        mov      edi, [Pixel]              ; edi = &Pixel[0]
        mov      ecx, [Size]               ; ecx = ResX*ResY
        lea      esi, [edi + ecx*DrawSize] ; esi = &HeatMap
        lea      ebx, [esi + ecx*HeatSize] ; ebx = &CoolMap
        lea      ebp, [edi + ecx*8]        ; ebp = pallet
 Draw:  xor      eax, eax
        xor      edx, edx
        lodsb
        mov      dl, [ebx]
        cmp      al, dl
        cmovb    eax, edx
        sub      eax, edx
        inc      ebx
        mov      eax, [ebp + eax*4]
        stosd
        loop     Draw
        pop      ebx
        pop      ebp

 ; Step 3 - Update the HeatMap
 ;          Take the temperature of the pixel directly below
 ;          On the scanline directly below add the pixels to the left and right
 ;          Add the temperature of the pixel 2 scanlines below
 ;          This is a forward pass as the pixels you depend apon
 ;          must not be updated prior to being read from.
 ;          we do not update the bottom most scan line as it has
 ;          been randomized already
 ;       +-----+
 ;       |     | <- you are here
 ;       |     |
 ; +-----+-----+-----+
 ; | XXX | XXX | XXX | <----+--- Add these pixels
 ; | XXX | XXX | XXX |      |    temperatures together
 ; +-----+-----+-----+      |
 ;       | XXX | <----------+
 ;       | XXX |
 ;       +-----+

 ;          Don't let pixel temperature drop below zero
 ;          Then convert temperature to colour using the clut
       ;mov      edi, [Pixel]      ; edi = &Pixel[0]
        mov      esi, [ResX]       ; esi = ResX
        call     Calc

 ; Step 4 - Randomly generate fire points along the bottom scanline
 ;          This step actually combines generating Heat sources and
 ;          Cold sources.
 ;
       ;create random fire sources along the bottom scan line of the heat map
       ;create random cold sources along the top scan line of the cool map
        lea      ecx, [esi*HeatSize*2]
 Burn:  sbb      eax, [Seed + 2]
        adc      [Seed + 1], edi
        stosb
        loop     Burn

 ; Step 5 - Update the CoolMap
 ;          Take the temperature of the pixel directly above
 ;          On the scanline directly above add the pixels to the left and right
 ;          Add the temperature of the pixel 2 scanlines above
 ;          This is a reverse pass (you start at the end of the buffer and retreate)
 ;          as the pixels you depend apon must not be updated prior to being read from.
 ;          we do not update the top most scan line as it has been randomized already
 ;       +-----+
 ;       | XXX | <----------+
 ;       | XXX |            |
 ; +-----+-----+-----+      |
 ; | XXX | XXX | XXX | <----+--- Add these pixels
 ; | XXX | XXX | XXX |           temperatures together
 ; +-----+-----+-----+
 ;       |     |
 ;       |     | <- you are here
 ;       +-----+
        neg      esi
        mov      ecx, [Size]
        lea      edi, [edi + ecx*HeatSize]
        add      edi, esi
        std
        scasd
        call     Calc
        cld
        dec      dword [msg+0x1C] ; count down for things to get working properly
        jns      Main             ; skips blit for early glitchy frames

 Pump:  ;We need to push these args ever iteration of the main loop
        ;as the call to StretchDIBits will trash the red zone. Just
        ;ensure that some register (ecx in this case) is zero here.
        tinycall PeekMessage, msg, ecx, ecx, ecx, PM_REMOVE

 Blit:  ;finally we get to blit our pixel buffer to the screen! All
        ;that hard work just so we can make this one call.
        tinycall StretchDIBits ;(hdc,rc.left,rc.top,rc.right,rc.bottom,0,0,ResX,ResY,pixel,0,SRCCOPY);
        mov      esp, ebp ; repair the stack frame (preserves StretchDIBits arguments)

        ;Now we test for any keydown and escape if necessary
 Quit:  mov      eax, [ResX]    ; if ((eax = 0x00000100) == WM_KEYDOWN == msg.message) ExitProcess(0);
        cmp      eax, [msg + 4] ;
        jnz      Main           ;
        tinycall ExitProcess    ;0

 Calc: ;gather some heat from the pixels below the current pixel in the heat map
        push     ebp
        mov      ecx, [Size]       ; ecx = ResX*ResY
        sub      ecx, [ResX]
        mov      ebp, 0x00040200   ; fixed point 4.0078125
 Heat:  xor      edx, edx
        xor      eax, eax
        mov      dl, [edi + esi*HeatSize           ] ; pixel+ResX
        add      eax, edx                            ;
        mov      dl, [edi + esi*HeatSize - HeatSize] ; pixel-ResX
        add      eax, edx                            ;
        mov      dl, [edi + esi*HeatSize + HeatSize] ; pixel+0x01
        add      eax, edx                            ;
        mov      dl, [edi + esi*HeatSize*2         ] ; pixel-0x01
        add      eax, edx              ;
        shl      eax, 0x10
        cdq
        div      ebp
        stosb
        loop     Heat
        pop      ebp
        ret
 db 'rs'
