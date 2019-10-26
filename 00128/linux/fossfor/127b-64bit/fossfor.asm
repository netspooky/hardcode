[bits 64]

; Fedora 16 x86-64 libs happen to be loaded to the same address every time :D

%define SDL_SetVideoMode 0x3b35631b00
%define SDL_Flip         0x3b35630570

; If you're on a different x86-64 Linux OS that uses position dependent libs,
; you can look up the addresses of these functions and substitute them here.

%define XResolution       320 
%define YResolution       240

db 'char main[]="' ; Wrap our code up in a character array

    ; segfaults without this ... ? 
    push rax 

    ; Initialize window (ecx is presumed to be zero)
    mov  bl, YResolution
    push rbx
    pop  rsi
    mov  bp, XResolution                          ; Save XResolution in ebp for later
    mov  edi, ebp

    push 8                                        ; 2 bytes shorter than mov edx, 8 
    pop  rdx
    mov  rbx, SDL_SetVideoMode
    call rbx 

    ; Prepare for main loop
    push rax                                      ; Surface pointer on the stack
    mov  r14, [rax + 32]                          ; Pointer to pixel buffer in r14
    add  bx, SDL_Flip - SDL_SetVideoMode          ; Pointer to SDL_Flip in rbx
 
   MainLoop:
        mov  ecx, XResolution * YResolution       ; ecx = size of pixel buffer
        inc  r15
        DrawLoop:
            mov  eax, ecx           ; Pixel index
            cdq                     ; Sideffect of clearing edx (smaller than xor edx, edx)
            div  ebp                ; Divide by width of screen (eax = x, edx = y) 
            xor  eax, edx           ; Our nifty effect
            add  rax, r15           ; Use edi as psuedo-random number
            mov  [rcx + r14], ax 
            loop DrawLoop
        pop  rdi                    ; Grab surface pointer from stack,
        push rdi                    ; then put it back.
        call rbx                    ; SDL_Flip (refresh screen)
        jmp  short MainLoop

  ; Don't bother cleaning up.  We'll never quit :P

db '";'

