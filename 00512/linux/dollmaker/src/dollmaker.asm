[bits 32]

%define fcnoff           16

%define SDL_SetVideoMode [ebp + fcnoff + 0]
%define SDL_Flip         [ebp + fcnoff + 4]
%define SDL_Delay        [ebp + fcnoff + 8]
%define SDL_PollEvent    [ebp + fcnoff + 12]
%define SDL_Quit         [ebp + fcnoff + 16]

%define Dollmaker        [ebp + fcnoff + 20]

%define Width  512 
%define Height 256 

db '#include<dlfcn.h>',10
db 'S(x,y,t){float v=cos(t/128.),l=sin(t/128.),g=v*3,h=l*3;int m=(x*g+y*h)/5.+x/3.+512,u=(y*g-x*h)/5.+y/3.+512;float i=((m^-(m%256>=128)|u^-(u%256>=128))+t)&255,p=(u%1280)/1280.;return (int)(p*i>=255?255:p*i)|(int)((1-p)*i>255?255:(1-p)*i)<<16;}'

db 'char a[]="'   ; Wrap our code up in a character array
    push ebp
    mov  ebp, esp

    ; Translate function name strings into addresses  (24 bytes)

        ; 1. Loop breaks on failure
        ; 2. Trashes pointer to SDL lib
        ; 3. Assumes edi is zero

    mov  esi, [ebp + 12] ; pointer to libSDL 
    func_lookup:
        mov  [ebp + edi * 4 + fcnoff - 4], eax
        inc  edi
        push dword [ebp + edi * 4 + fcnoff - 4]
        push esi
        call [ebp + 8] 
        pop  esi
        pop  ecx
        test eax, eax
        jnz  func_lookup

    ; Initialize screen
    push dword 0x80000000 ; SDL_FULLSCREEN | SDL_SWSURFACE
    push byte 32 
    push Height 
    mov  esi, Width 
    push esi
    call SDL_SetVideoMode
    push eax

    main_loop:

        ; Render a frame
        inc  edi
        pop  ebx
        push ebx
        mov  ebx, [ebx + 0x14]
        mov  ecx, Height * Width - 1
        render_loop:
            mov  eax, ecx
            cdq
            div  esi
            ; Call the dollmaker 
            push ecx
            push edi
            push eax
            push edx

; We could pass the current color too, but we
; don't need it for this effect
;            push dword [ebx + ecx * 4]

            call Dollmaker
            pop  ecx
            pop  ecx
            pop  ecx
            pop  ecx
            mov  [ebx + ecx * 4], eax
            loop render_loop
        call SDL_Flip

        ; Limit to 50 FPS (6 bytes)
        push 20 
        call SDL_Delay
        pop  eax 

        ; Escape support (13 bytes)
        sub  esp, eax
        push esp
        call SDL_PollEvent
        pop  eax 
        pop  eax
        pop  ecx
        pop  ecx
        pop  ecx
        pop  ecx
;        add  esp, 16 
        cmp  al, byte 2
        jne  main_loop

    call SDL_Quit 
    leave
    ret

db '";',10

; Load up the stack with everything we need 

db 'main()'
db '{'
db '((int(*)())a)('
    db 'dlsym,'
    db 'dlopen("libSDL-1.2.so.0",2),'  ; better compatibility than libSDL.so
    db '"SDL_SetVideoMode",'           ; ebp + 16 
    db '"SDL_Flip",'                   ; ebp + 20
    db '"SDL_Delay",'                  ; ebp + 24
    db '"SDL_PollEvent",'              ; ebp + 28
    db '"SDL_Quit",'                   ; ebp + 32
    db 'S'
    db ');'
db '}'


