; at least its an xor texture 
; orbitaldecay 2012

[bits 32]

%define XResolution       800
%define YResolution       600

extern SDL_SetVideoMode
extern SDL_Flip
extern SDL_Delay
extern SDL_PollEvent

global _start

section .data
event:
section .text
_start:
    push 0x80000000                 ; SDL_FULLSCREEN | SDL_SWSURFACE
    push 8 
    push YResolution
    mov  ebx, XResolution
    push ebx 
    call SDL_SetVideoMode
    mov  edi, eax
    main_loop:
        inc  ebp 
        mov  ecx, XResolution * YResolution - 1
        push edi
        mov  edi, [edi + 0x14]      ; Grab pointer to pixel buffer
        render_loop:
            mov eax, ecx
            cdq                     ; Clears edx
            div  ebx                ; Divide by width of screen
            xor  eax, edx           ; FOSFOR effect 
            add  eax, ebp           ; Add frame counter
            mov  [edi + ecx], ax 
            loop render_loop
        pop  edi
        push edi
        call SDL_Flip
        push byte 16
        call SDL_Delay
        push event
        call SDL_PollEvent
        cmp  byte [event], 2
        jne  short main_loop
    mov al, 1
    int 0x80

