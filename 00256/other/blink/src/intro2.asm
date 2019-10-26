    %include 'settings.def'
    bits 32

    user.start:
    ; At this point ESI contains a pointer to USER.start (which could be loaded
    ; anywhere) and EDI contains a pointer to our linear frame buffer (LFB)

    ; Initialize segment registers and setup stack
    mov esp, USER_STACK ; USER_STACK is defined in settings.def

    ; Save pointer to LFB
    mov [USER_DATA], edi ; USER_DATA is defined in settings.def

    ; Install ISR 0x20 to draw when the timer goes off (IRQ0)
    mov eax, IDT_ADDR + 0x20 * 8 ; IDT_ADDR is defined in settings.def
    add esi, (user.isr20h - user.start)
    mov word [eax], si
    shr esi, 16
    mov word [eax + 6], si

    user.spin:
    jmp user.spin

    ; ISR for 20h
    user.isr20h:
    pushad

    ; Clear master PIC
    mov al, 0x20
    out 0x20, al

    ; Fill the screen
    mov eax, USER_DATA
    mov ebx, [eax]      ; Load LFB address
    mov edx, [eax + 4]  ; Load frame counter
    xor ecx, ecx        ; Clear the pixel counter

    user.isr20h_fillscreen:
    mov byte [ebx + ecx * 4], dl
    inc ecx
    cmp ecx, VID_WIDTH * VID_HEIGHT
    jnz user.isr20h_fillscreen

    ; Increment frame counter
    inc dword [eax + 4]

    ; Goodbye
    popad
    iretd
    user.end:
