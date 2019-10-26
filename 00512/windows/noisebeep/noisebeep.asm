%define VK_ESCAPE 1Bh
%define SRCCOPY 00cc0020h
%define DIB_RGB_COLORS 0
%define	BI_RGB 0
%define WIDTH 1024
%define HEIGHT 768

extern __imp__GetAsyncKeyState@4, __imp__Beep@8
extern __imp__GetDC@4, __imp__StretchDIBits@52
extern __imp__GetSystemMetrics@4

section .text code align=1
global main
main:
	push 0
	call [__imp__GetSystemMetrics@4]
	mov esi, eax

	push 1
	call [__imp__GetSystemMetrics@4]
	mov edi, eax
	
	push 0
	call [__imp__GetDC@4]
	mov ebp, eax

@loop:
	;plot some random shit
	mov edx, pixel
	mov ecx, WIDTH*HEIGHT
	@l1:
		add eax, ebx	;pseudo
		rol eax, 5
		add eax, ecx
		add word [edx], ax
		add edx, 2
	loop @l1
	inc ebx

	;make some sound
	push 1
	push dword [pixel]	;freq
	call [__imp__Beep@8]

	push SRCCOPY
	push DIB_RGB_COLORS
	push bmi
	push pixel
	push HEIGHT
	push WIDTH
	push 0
	push 0
	push edi
	push esi
	push 0
	push 0
	push ebp
	call [__imp__StretchDIBits@52]
	
	push VK_ESCAPE
	call [__imp__GetAsyncKeyState@4]
	test eax, eax
je @loop

section .pixel bss align=1
pixel:
	resw WIDTH*HEIGHT
	
section .bmi data align=1
bmi:
	dd  032h
	dd  WIDTH
	dd  -HEIGHT
	dw  1
	dw  16