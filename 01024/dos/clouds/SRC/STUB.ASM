extern _demo_start
global _flip

SEGMENT _TEXT CLASS=CODE
    
    resb 100h

; Entry point
..start:
    
; DOS .com files are allocated the largest contiguous block of memory
; when they start. We'll check that it's at least 128kb. This is easier
; then dynamically allocating memory via int 21h calls.
    
; Check if we have at least 128kb of memory allocated to us
; Quit if we don't

;    mov cx, word [0x02]
;    mov bx, ds
;    sub cx, bx
;    cmp cx, 0x2000
;    ja mem_check
;    ret

mem_check:
; Get the address of the next segment
    mov bx, ds
    add bx, 0x1000
    mov [buffer_segment], bx
    mov es, bx
; Clear the next segment
    xor ax, ax
    xor di, di
    xor cx, cx
    dec cx
    rep stosb
; Put next segment on the stack    
    push bx

; Initiailize mode 13h graphics and FP unit
    mov ax, 13h
    int 10h
    call _demo_start
    
; Remove parameter from stack    
    pop bx    

; Return to text mode
    mov ax, 3h
    int 10h
    ret

_flip:
    pusha
    push ds
    mov ds, [buffer_segment]
    push 0xA000
    pop es
    cld
    xor si, si
    xor di, di
    xor cx, cx
    dec cx
    rep movsb
    pop ds
    popa
    ret


SEGMENT _DATA CLASS=DATA
buffer_segment: resw 1

SEGMENT _BSS CLASS=BSS
SEGMENT _BSSEND CLASS=BSSEND
GROUP DGROUP _TEXT _DATA _BSS _BSSEND
