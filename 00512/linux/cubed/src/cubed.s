;
;                                                                      ####:    
;                                                                      #;;##    
;                                                                         ##    
;                                                                       ###     
;                             ###                                 ###    i##    
;                             ###                                 ###     ##    
;                             ###                                 ###  #####    
;      #####K    ###     ###  ###:#####t       #####       E#####,###  ####     
;     ########   ###     ###  ##########t    ########K    W##########           
;    ####:t####  ###     ###  ####W  W###   ####L f###E  j###G  #####           
;   ###     ###. ###     ###  ###.    .###  ###     ###  ###     ,###           
;   ###          ###     ###  ###      ###  ##       ##  ##W      ###           
;   ##.          ###     ###  ###      ### L###########  ##       ###           
;   ##L          ###:    ###  ###      ### j###########  ##E      ###           
;   ###          D##W    ###  ###      ###  ###          ###      ###           
;   W###   f###   ###   ####  ####    ###i  ####   W###  ####   :####           
;    #########;   ##########  ###########    #########    ###########           
;     #######i     #########  ##E#######      #######      #######E##           
;       ,WD          WE            f#L          f#E          f#j                
;                                                                               
;                                                            prod: cubed
;                                                        platform: linux i386
;                                                            size: 512b
;                                                          author: orbitaldecay
;                                                            date: 02/11/2012
;
; A few notes on the source: Don't trust the labels on the components
; (i.e. what is labled as X might really be Y, etc.).  Otherwise, I've tried
; to keep things generally tidy and reasonably well documented.  The 512b
; version was compiled using Nasm 2.09.08 (some older versions produce code
; that is slightly larger).

[bits 32]

; Use Python to load the SDL library, open a SDL window, mmap us into memory,
; then start the intro.

;db '#!/bin/sh', 10
db `python -c"from ctypes import *;S=CDLL('libSDL-1.2.so.0');`
db `CFUNCTYPE(int)(S.mmap(0,1,7,2,S.open('$0',2),0)+190)`
db `(S.SDL_SetVideoMode(640,480,32,1<<31),S.SDL_PollEvent,S.SDL_Flip);`
db `S.SDL_Quit()" #` 

; Global constants

%define XRES          640        ; X resolution of screen
%define YRES          480        ; Y resolution of screen
%define VOXEL_SIZE    4          ; Size of a voxel (2^VOXEL_SIZE)
%define MAXITS        32         ; Maximum number of iterations when marching
%define ROT_SPEED     120        ; Speed of rotation (larger = slower)

; Pseudonyms for stack addresses within main()

%define SURFACE       ebp + 08 ; Pointer to an SDL_Surface
%define SDL_POLLEVENT ebp + 12 ; Pointer to SDL_Pollevent() function
%define SDL_FLIP      ebp + 16 ; Pointer to SDL_Flip() function

main:
    push ebp
    mov  ebp, esp
    push byte ROT_SPEED
    sub  esp, 32

    main_loop:
        inc  ebx                        ; Increment frame counter 
        push ebx

        ; Prepare FP unit with cos(t/ROT_SPEED) and sin(t/ROT_SPEED) for
        ; rotation about Z-axis.
        ;                         ST0         ST1

        fninit
        fild  dword [esp]       ; t
        fidiv dword [esp + 36]  ; t/s
        fsincos                 ; cos(t/s)    sin(t/s)

        push dword [SURFACE]
        call [SDL_FLIP]
        mov  ecx, XRES * YRES - 1
        render_loop:
            mov  eax, ecx
            cdq 
            mov  esi, XRES
            div  esi
            shr  esi, 1                 ; Displace coordinates 
            sub  edx, esi
            sub  eax, (YRES / 2)
            push ecx
            push edx                    ; X component of ray
            push esi                    ; Z component of ray
            push eax                    ; Y component of ray
            call cast_ray
            add  esp, byte 12
            pop  ecx
            pop  edi
            push edi
            mov  edi, [edi + 0x14]      ; Grab pointer to pixel buffer
            mov  [edi + ecx * 4], eax   ; Set pixel color
            loop render_loop
        pop  edi
        pop  ebx 
        push esp                        ; Process events 
        call [SDL_POLLEVENT]
        pop  edi
    	cmp  byte [edi], 2              ; Continue until keypress
        jne short main_loop
    leave
    ret

; Psuedonyms for stack addresses within cast_ray()

%define ORIGIN_X  ebp - 0x14
%define ORIGIN_Y  ebp - 0x18
%define ORIGIN_Z  ebp - 0x10
%define ORIGIN    ebp - 0x18 ; Vector (3 x 1)
%define VOXEL_X   ebp - 0x28
%define VOXEL_Y   ebp - 0x2c
%define VOXEL_Z   ebp - 0x30
%define VOXEL     ebp - 0x30 ; Vector (3 x 1)
%define RAY_X     ebp + 0x08
%define RAY_Y     ebp + 0x10
%define RAY_Z     ebp + 0x0c
%define RAY       ebp + 0x08 ; Vector (3 x 1)
%define TIME      ebp + 0x1c ; Scalar (was 0x18)
%define DIR       ebp - 0x24 ; Vector (3 x 1)
%define STEP      ebp - 0x3c ; Vector (3 x 1)
%define AREA      ebp - 0x6c ; Matrix (3 x 3)

cast_ray:

    enter 0x68, 0

    ; Calculate where the ray came from 

;    mov  ax, 0x5548
    mov  al, 90 
    mov  [ORIGIN_Y], al 
    mov  [ORIGIN_Z], al ; ah
    imul eax, [TIME], byte 12 
    mov  [ORIGIN_X], eax

    ; Rotate the screen
    ;                      ST0         ST1         ST2         ST3         ST4
                         ; cos         sin
    fild  dword [RAY_X]  ; x           cos         sin
    fmul  st0, st1       ; x*cos       cos         sin
    fild  dword [RAY_Y]  ; y           x*cos       cos         sin
    fmul  st0, st3       ; y*sin       x*cos       cos         sin
    fsubp                ; x*cos-y*sin cos         sin

    fild  dword [RAY_X]  ; x           x*cos-y*sin cos         sin
    fmul  st0, st3       ; x*sin       x*cos-y*sin cos         sin
    fild  dword [RAY_Y]  ; y           x*sin       x*cos-y*sin cos         sin
    fmul  st0, st3       ; y*cos       x*sin       x*cos-y*sin cos         sin
    faddp                ; x*sin+y*cos x*cos-y*sin cos         sin

    fistp dword [RAY_Y]  ; x*cos-y*sin cos         sin
    fistp dword [RAY_X]  ; cos         sin

    ; The first round of precomputation determines the voxel coordinates at
    ; which the ray begins (VOXEL), a step size used for voxel traversal
    ; (STEP), and the increment to add to voxel coordinates each iteration
    ; (DIR).  They are computed in the following way:

    ; STEP[] = RAY[] * (DIR[] << VOXEL_SIZE)
    ; DIR[] = (RAY[] > 0) ? 1 : -1 
    ; VOXEL[] = ORIGIN[] >> VOXEL_SIZE

    xor  ecx, ecx
    mov  cl, 3
    precomp_loop:
        mov  edx, [ORIGIN + ecx * 4 - 4] 
        sar  edx, VOXEL_SIZE 
        mov  [VOXEL + ecx * 4 - 4], edx
        mov  eax, [RAY + ecx * 4 - 4]
        cdq
        or   dl, 1
        mov  [DIR + ecx * 4 - 4], edx
        shl  edx, VOXEL_SIZE
        imul eax, edx
        mov  [STEP + ecx * 4 - 4], eax
        loop precomp_loop

    ; The next section precomputes some areas that we use to drastically speed
    ; up voxel traversal.  It populates a 3 x 3 matrix refered to as AREA with
    ; the following values:

    ; AREA_i,j = abs(RAY[i]*(((VOXEL[j]+(RAY[j]>0))<<VOXEL_SIZE)-ORIGIN[j])

    lea esi, [AREA]
    outer_loop:
        mov  ebx, [RAY + ecx * 4]
        xor  edi, edi
        inner_loop: 
            mov  eax, [RAY + edi * 4]
            cdq
            inc  edx
            add  edx, [VOXEL + edi * 4]
            imul eax, edx, byte (1 << VOXEL_SIZE)
            sub  eax, [ORIGIN + edi * 4]
            imul eax, ebx
            cdq
            xor  eax, edx
            sub  eax, edx
            mov  [esi + edi * 4], eax    ; Store result in AREA matrix
            inc  edi
            cmp  edi, byte 3
            jnz short inner_loop
        add  esi, byte 12                ; Move to next row of AREA matrix
        inc  ecx 
        cmp  ecx, byte 3
        jnz short outer_loop

    ; March the ray until we hit something or run out of iterations

    mov cl, MAXITS ; max iterations
    march_loop:

        ; Check for collision
        mov  eax, [VOXEL_Y]
        or   al, ah
        or   eax, [VOXEL_X]
        not  eax
        xor  eax, [VOXEL_Z]
        and  eax, byte 7
        jz short collide

        ; Determine the next voxel we need to check (sorry for the mess) 
        xor  ebx, ebx
        mov  eax, [AREA + (3 * 4)] ; 0,1
        cmp  [AREA + (1 * 4)], eax ; 1,0
        jng short L4
        mov  eax, [AREA + (6 * 4)] ; 0,2
        cmp  [AREA + (2 * 4)], eax ; 2,0
        jg short L2
        L4:
        nop
        mov  eax, [AREA + (7 * 4)]  ; 1,2
        cmp  [AREA + (5 * 4)], eax ; 2,1
        setng bl
        inc  ebx
        L2:

        ; Advance to the next voxel 
        mov  eax, [DIR + ebx * 4]
        add  [VOXEL + ebx * 4], eax
        xor  edi, edi
        mov  edx, ebx
        update_loop:
            mov  eax, [STEP + edi * 4]
            add  [AREA + edx * 4], eax
            add  dl, 3
            inc  edi
            cmp  edi, 3
            jle short update_loop

    loop march_loop

    collide:

    ; Determine pixel color based on the number of iterations taken before
    ; the collision occured and the side of the voxel that was hit. 

    imul eax, ecx, 0x010101
    mov  cl, 3 
    sub  cl, bl
    shl  eax, cl

    leave
    ret
