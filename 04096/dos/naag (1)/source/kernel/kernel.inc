global _main:proc
global code32_base:dword

dpmi_regs struc
	_edi	dd ?
	_esi	dd ?
	_ebp	dd ?
	_none1	dd ?
	_ebx	dd ?
	_edx	dd ?
	_ecx	dd ?
	_eax	dd ?
	_flags	dw ?
	_es	dw ?
	_ds	dw ?
	_fs	dw ?
	_gs	dw ?
	_none2	dw ?
	_none3	dw ?
	_sp	dw ?
	_ss	dw ?
ends