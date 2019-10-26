; intro.asm
; A demonstration of the sort of sizecode that can be written and executed
; on the blink kernel.

%include 'settings.def'

bits 32

; -----------------------------------------------------------------------------
; This code runs in userspace (ring 3)
; At this point ESI contains a pointer to init.start (which could be loaded
; anywhere) and EDI contains a pointer to our linear frame buffer (LFB)
;------------------------------------------------------------------------------

init.start:

; Blank ebx and load ecx with the video width
    xor ebx, ebx
    mov cx, VID_WIDTH

; Draw a frame
init.isr20h_fillscreen:
    mov eax, ebx
    cdq
    div ecx
    or eax, edx
    shr eax, 1
    add eax, ebp
    mov byte [edi + ebx * 4], al
    inc ebx
    cmp ebx, VID_WIDTH * VID_HEIGHT
    jnz init.isr20h_fillscreen

; Increment frame counter and draw again
    inc ebp
    jmp init.start

