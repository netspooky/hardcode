bits 32

%define VK_ESCAPE 1Bh

global _main
extern __imp__ExitProcess@4, __imp__GetDC@4, __imp__GetAsyncKeyState@4, __imp__StretchDIBits@52

section .text

_main:
push    0
push    0
call    [__imp__GetDC@4]
mov     ebx, eax
xor     ebp, ebp
mainloop:
mov     edi, buf
cld
mov     ecx, 720
yloop:
mov     esi, 1280
xloop:
mov     eax, ecx
add     eax, ebp
and     eax, esi
jz     short .skip
mov     eax, 0xffffffff
.skip:
stosd
dec     esi
jnz     short xloop
loop    yloop
inc     ebp

push    13369376
push    0
push    bmi
push    buf
push    720
push    1280
push    0
push    0
push    720
push    1280
push    0
push    0
push    ebx
call    [__imp__StretchDIBits@52]
push    VK_ESCAPE
call    [__imp__GetAsyncKeyState@4]
sahf
jns     short mainloop
call    [__imp__ExitProcess@4]

section .bss
buf resd 1280*720

section .data
bmi:
    dd  40
    dd  1280
    dd  -720
    dw  1
    dw  32
    

