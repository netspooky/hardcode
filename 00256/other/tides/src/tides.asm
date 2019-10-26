%include 'settings.def'

%define q1    esi - 4
%define q2    esi - 8
%define q3    esi - 12
%define s3    esi - 12
%define R     esi - 16
%define Color esi - 20
%define F     esi - 64

org KERNEL_LOADADDR
bits 32

kernel.start:
; At this point EAX should contain 0x2BADB002 and EBX should point to the
; multiboot information structure

; Initialize the FPU
    fninit

kernel.draw:

; We'll be counting up to the size of screen buffer
    xor ecx, ecx

; Our double buffer will go right above our stack. Our light rotation
; velocity scalar overlaps with this instruction.
kernel.velocity:
    mov esi, KERNEL_STACK

kernel.loop:
; Calculate screen X and Y. We'll use EBX as Z as well.
    mov ebp, VID_WIDTH
    mov eax, ecx
    cdq
    div ebp

; Center our coordinates
    shr ebp, 1
    sub edx, ebp
    sub eax, VID_HEIGHT / 2


; We'll use the stack just bellow the double buffer
    mov     esp, esi

; Load non-normalized ray components into memory
    push    edx         ; q1
    push    eax         ; q2
    push    ebp         ; q3 = s3 = XRES / 2
    shr     ebp, 1
    push    ebp         ; R = XRES / 4

; Calculate position of light (normalized)
    fild    dword [F]                          ; F
    fmul    dword [kernel.velocity - 1]        ; v * F
    fsincos                                    ; l1 = cos(vF), l3 = sin(vF)

; Calculate b = q1 * l1 + q3 * l3 and l3 * s3
    fimul   dword [q1]  ; l1 * q1, l3
    fild    dword [q3]  ; q3, l1 * q1, l3
    fmul    st0, st2    ; l3 * q3, l1 * q1, l3
    fst     st2         ; l3 * q3, l1 * q1, l3 * s3
    faddp               ; b = l1 * q1 + l3 * q3, l3*s3

; Calculate the length of the non-normalized ray |q|
    fild    dword [q1]  ; q1, b, l3 * s3
    fmul    st0, st0    ; q1^2, b, l3 * s3
    fild    dword [q2]  ; q2, q1^2, b, l3 * s3
    fmul    st0, st0    ; q2^2, q1^2, b, l3 * s3
    fild    dword [q3]  ; q3, q2^2, q1^2, b, l3 * s3
    fmul    st0, st0    ; q3^2, q2^2, q1^2, b, l3 * s3
    faddp               ; q2^2 + q3^2, q1^2, b, l3 * s3
    faddp               ; q1^2 + q2^2 + q3^2, b, l3 * s3
    fsqrt               ; |q| = sqrt(q1^2 + q2^2 + q3^2), b, l3 * s3

; a = b / |q|
    fdiv    st1, st0    ; |q|, a, l3 * s3

; Compute determinant of sphere intersection
    fild    dword [q3]  ; q3, |q|, a, l3 * s3
    fmul    st0, st0    ; q3s3, |q|, a, l3 * s3
    fdiv    st0, st1    ; s3r3, |q|, a, l3 * s3
    fst     st1         ; s3r3, s3r3, a, l3 * s3
    fmul    st0, st0    ; (s3r3)^2, s3r3, a, l3 * s3
    fild    dword [R]   ; R, (s3r3)^2, s3r3, a, l3 * s3
    fmul    st0, st0    ; R^2, (s3r3)^2, s3r3, a, l3 * s3
    faddp               ; R^2 + (s3r3)^2, s3r3, a, l3 * s3
    fild    dword [s3]  ; s3, R^2 + (s3r3)^2, s3r3, a, l3 * s3
    fmul    st0, st0    ; s3^2, R^2 + (s3r3)^2, s3r3, a, l3 * s3
    fsubp               ; D = R^2 + (s3r3)^2 - s3^2, s3r3, a, l3 * s3

; If the determinant is less than zero, we missed 
    fldz                ; 0, D, s3r3, a, l3 * s3
    fcomip              ; D, s3r3, a, l3 * s3
    ja      kernel.missed
    
; Calculate the multiple of the ray at the intersection t = s3r3 - sqrt(D)
    fsqrt               ; sqrt(D), s3r3, a, l3 * s3
    fsubr   st0, st1    ; t, s3r3, a, l3 * s3

; Calculate Lambertian (L)
    fmul    st2, st0         ; t, s3r3, ta, l3 * s3
    fmul    st1, st0         ; t, ts3r3, ta, l3 * s3
    fmul    st0, st0         ; t^2, ts3r3, ta, l3 * s3
    fild    dword [s3]       ; s3, t^2, ts3r3, ta, l3 * s3
    fmul    st0, st0         ; s3^2, t^2, ts3r3, ta, l3 * s3
    faddp                    ; s3^2 + t^2, ts3r3, ta, l3 * s3
    fadd    st0, st1         ; s3^2 + ts3r3 + t^2, ts3r3, ta, l3 * s3
    faddp                    ; s3^2 + 2ts3r3 + t^2, ta, l3 * s3
    fsqrt                    ; c = sqrt(s3^2 + 2ts3r3 + t^2), ta, l3 * s3
    fdiv    st2, st0         ; c, ta, l3 * s3 / c
    fdivp   st1, st0         ; ta / c, l3 * s3 / c
    fsubrp  st1, st0         ; L = (ta - l3 * s3) / c

; Push 255 onto stack
    push    255
    jmp     kernel.plot

kernel.missed:

    fstp    st0                ; s3r3, a, l3 * s3
    fstp    st0                ; a, l3 * s3
    fstp    st1                ; L = a
    or      eax, edx
    and     eax, 255
    push    eax

kernel.plot:

; Multiply the color by the Lambertian and put it in eax
    fimul   dword [Color]    ; L * 255
    fistp   dword [Color]    ; {}
    pop     edx

; Add small random value to color
    ;imul    edi, edi, byte 127
    ;mov     eax, edi
    ;sar     eax, 30
    ;add     edx, eax


; If color is signed, set it to zero
    xor     eax, eax
    test    edx, edx
    cmovs   edx, eax

    imul    edx, edx, 0x00020201

    mov     dword [esi + ecx * 4], edx

    inc     ecx
    cmp     ecx, VID_WIDTH * VID_HEIGHT
    jl      kernel.loop
    
; Determine address of linear frame buffer for drawing
    mov     edi, [ebx + 0x4C] ; Pointer to vbe_mode_info structure
    mov     edi, [edi + 0x28] ; Pointer to linear frame buffer (LFB)

; Increment frame counter
    inc     dword [F]

; Copy from double buffer to frame buffer
    
    cld
    rep movsd

; Check for escape

    in      al, 0x60
    dec     eax 
    jnz     kernel.draw

; If user hit escape, reboot.

    dec     eax
    dec     eax
    out     0x64, al

    align 4

kernel.multiboot_hdr:

    dd MB_HDR_MAGIC                 ; magic
    dd MB_HDR_FLAGS                 ; flags
    dd MB_HDR_CHECKSUM              ; checksum
    dd kernel.multiboot_hdr         ; header_addr
    dd KERNEL_LOADADDR              ; load_addr
    dd 0                            ; load_end_addr
    dd RESERVED_SPACE               ; bss_end_addr
    dd kernel.start                 ; entry_addr
    dd VID_MODE                     ; mode_type
    dd VID_WIDTH                    ; width
    dd VID_HEIGHT                   ; height
    dd VID_DEPTH                    ; depth

    db ':)', 0

kernel.frame:
kernel.end:

