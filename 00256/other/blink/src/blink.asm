; Blink
; A 256 byte Multiboot kernel

%include 'settings.def'

org KERNEL_LOADADDR
bits 32

kernel.start:
; At this point EAX should contain 0x2BADB002 and EBX should point to the
; multiboot information structure

; The first thing we need to do is setup a working GDT and fill in our
; segment registers
    lgdt [kernel.gdt_desc]
    mov ax, 0x0010
    mov ss, ax
    mov ds, ax
    jmp 0x0008:kernel.init_cs
kernel.init_cs:

; Setup the stack (we should probably reset EFLAGS, but we won't to save space)
    mov esp, KERNEL_STACK

; Now we'll create our IDT
; See http://wiki.osdev.org/Interrupt_Descriptor_Table
    mov edi, IDT_ADDR
    xor ecx, ecx
    dec cl
kernel.idt_loop:
    ; Write IDT entry pointing to ISR
    isr_addr equ (kernel.isr - kernel.start) + KERNEL_LOADADDR
    mov dword [edi + ecx * 8], (isr_addr & 0xFFFF) | (0x0008 << 16)
    mov dword [edi + ecx * 8 + 4], 0xEE00 | ((isr_addr >> 16) & 0xFFFF) << 16
    loop kernel.idt_loop

; Setup TSS
; See http://wiki.osdev.org/Task_State_Segment
    mov eax, TSS_ADDR
    mov dword [eax + 0x04], KERNEL_STACK ; Address of kernel stack
    mov word [eax + 0x08], 0x0010        ; Kernel stack segment
    mov word [eax + 0x66], 0x0068        ; Size of TSS
    mov ax, 0x0028                       ; GDT entry of TSS
    ltr ax

; Remap the PIC
; See http://wiki.osdev.org/8259_PIC
    mov al, 0x11
    out 0x20, al
    out 0xA0, al
    mov al, 0x20
    out 0x21, al
    mov al, 0x28
    out 0xA1, al
    mov al, 0x04
    out 0x21, al
    mov al, 0x02
    out 0xA1, al
    mov al, 0x05
    out 0x21, al
    mov al, 0x01
    out 0xA1, al

; Load IDT and enable interrupts
    lidt [kernel.idt_desc]
    sti

; Determine address of linear frame buffer for drawing
    mov edi, [ebx + 0x4C] ; Pointer to vbe_mode_info structure
    mov edi, [edi + 0x28] ; Pointer to linear frame buffer (LFB)

; Determine address of first multiboot module. This will contain our
; userland code.
    mov esi, [ebx + 0x18]    ; Grab mods_addr from multiboot info structure
    mov esi, [esi]           ; Grab mod_start of first module

; Jump to userland module (notice extra segment registers still need fixing)
; When we get there, EBX will contain the address of the module and ECX will
; contain the address of the LFB

    mov ax, 0x0020 | 11b
    push eax
    pop ds
    push eax        ; User mode SS
    push eax        ; Address of stack (garbage)
    pushf           ; Push EFLAGS
    push 0x18 | 11b ; User mode CS
    push esi        ; Address of userland module
kernel.isr:         ; This can double as our default ISR (it simply returns)
    iret

; GDT Descriptor =============================================================
; See http://wiki.osdev.org/Global_Descriptor_Table
kernel.gdt_desc:
    dw kernel.gdt_end - kernel.gdt - 1 ; Limit (size - 1)
    dd kernel.gdt                      ; Address of the GDT

; Multiboot Header ===========================================================
; From the Multiboot Specification 0.6.96:
; "The Multiboot header must be contained completely within the first 8192
; bytes of the OS image, and must be longword (32-bit) aligned."
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

; GDT ========================================================================
    align 8
kernel.gdt:
; Null segment
    dd 0
    dd 0
; Ring 0 linear code segment (0x08), readable, ring 0, 4kb limit units, 32b
    dw 0xFFFF            ; Limit 0:15
    dw 0x0000            ; Base 0:15
    db 0x00              ; Base 16:23
    db 10011010b         ; Access byte
    db 0x0F | 1100b << 4 ; Limit 16:19, Flags
    db 0x00              ; Base 24:31
; Ring 0 linear data segment (0x10), writable
    dw 0xFFFF            ; Limit 0:15
    dw 0x0000            ; Base 0:15
    db 0x00              ; Base 16:23
    db 10010010b         ; Access byte
    db 0x0F | 1100b << 4 ; Limit 16:19, Flags
    db 0x00              ; Base 24:31
; User code segment (0x18), readable, ring 3, 4kb limit units, 32b
    dw 0xFFFF            ; Limit 0:15
    dw 0x0000            ; Base 0:15
    db 0x00              ; Base 16:23
    db 11111010b         ; Access byte
    db 0x0F | 1100b << 4 ; Limit 16:19, Flags
    db 0x00              ; Base 24:31
; User data segment (0x20), writable
    dw 0xFFFF            ; Limit 0:15
    dw 0x0000            ; Base 0:15
    db 0x00              ; Base 16:23
    db 11110010b         ; Access byte
    db 0x0F | 1100b << 4 ; Limit 16:19, Flags
    db 0x00              ; Base 24:31
; TSS (0x28)
    dw 0x0068                       ; Limit 0:15 (Size of TSS)
    dw (TSS_ADDR) & 0xFFFF          ; Base 0:15
    db (TSS_ADDR >> 16) & 0xFF      ; Base 16:23
    db 10001001b                    ; Access byte
    db 0x00 | 0100b << 4            ; Limit 16:19, Flags
    db (TSS_ADDR >> 24) & 0xFF      ; Base 24:31
kernel.gdt_end:

; IDT Descriptor =============================================================
    align 8
kernel.idt_desc:                   ; The IDT descriptor
    dw 0x07FF                      ; Size - 1
    dd IDT_ADDR                    ; Address of the IDT

; Thanks for checking it out! ================================================

db ':)'

kernel.end:

