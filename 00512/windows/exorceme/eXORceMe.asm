bits	32

%define EXP 11
%define SIZE 2048

extern __imp__StretchDIBits@52
extern __imp__GetDC@4
extern __imp__GetAsyncKeyState@4
extern __imp__ExitProcess@4

section .edit data align=1
_edit: dw 'edit'

section .bmi data align=1
_bmi: 
	DD	032H
	DD	SIZE
	DD	-SIZE
	DW	01H
	DW	020H

section .pixel bss align=1
_pixel:	resd SIZE*SIZE

section	.main code align=1
global _main@0
_main@0:

	xor esi, esi
	xor ebx, ebx
	
	push esi 
	call dword [__imp__GetDC@4]  
	mov edi, eax

	loop1:
		mov ecx, SIZE*SIZE
		mov edx, _pixel

		loop2:
			mov eax, ecx
			mov ebp, ecx
			shr eax, EXP
			add eax, ebx
			and ebp, SIZE-1
			add ebp, ebx
			xor eax, ebp
			add dword [edx], eax
			add edx, 4
			dec	ecx
		jne	 loop2
		inc ebx

		push	 0x1b
		push	 0x00CC0020
		push	 esi
		push	 _bmi
		push	 _pixel
		push	 SIZE
		push	 SIZE
		push	 esi
		push	 esi
		push	 SIZE
		push	 SIZE
		push	 esi
		push	 esi
		push	 edi
		call	 DWORD [__imp__StretchDIBits@52]
		call	 DWORD [__imp__GetAsyncKeyState@4]
		test	 eax, eax
	je  loop1

	push	esi
	call	 DWORD [__imp__ExitProcess@4]
end
