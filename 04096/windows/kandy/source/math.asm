;
; Implements common constants and functions
;
; Author:
;	William Swanson
;

%define math_asm

;-----------------------------------------------------------------------------
; Import and export:
;-----------------------------------------------------------------------------

		global	s_temp
		global	_path

;-----------------------------------------------------------------------------
; Unitialized data:
;-----------------------------------------------------------------------------
		section .bss

s_temp:		resd	8

;-----------------------------------------------------------------------------
; Initialized data:
;-----------------------------------------------------------------------------
		section	.data

%macro make_const 2
		global	s_%1
s_%1:		dd	%2
%endmacro

%define const(name, value) make_const name, value
%include "math.inc"

;-----------------------------------------------------------------------------
; _path
;
; Finds an arbitrary point along a path.
;
; Parameters:
;	esi	Path address
;	eax	Position	
; Returns:
;	st0	Interpolated point
;-----------------------------------------------------------------------------
_path:
		;Find the current point:
		cmp	eax, [esi+4]
		jb	.skip
		sub	eax, [esi+4]
		add	esi, 8
		jmp	_path

		;Interpolate:
.skip:		mov	[s_temp], eax
		fld	dword[esi+8]		;k1
		fsub	dword[esi]		;k1-k0
		fimul	dword[s_temp]		;t*(k1-k0)
		fidiv	dword[esi+4]		;t*(k1-k0)/t0
		fadd	dword[esi]		;k0+t*(k1-k0)/t0
		ret

;-----------------------------------------------------------------------------
; _path_next
;
; This function returns the next point along a path each time it is called.
;
; Parameters:
;	esi	Current key address
;	ebp	State storage address
; Returns:
;	st0	Interpolated point
;	esi	Incremented key address
;-----------------------------------------------------------------------------
%if 0
_path_next:
		;Interpolate:
		fld	dword[esi+8]		;k1
		fsub	dword[esi]		;k1-k0
		fimul	dword[ebp]		;t*(k1-k0)
		fidiv	dword[esi+4]		;t*(k1-k0)/t0
		fadd	dword[esi]		;k0+t*(k1-k0)/t0

		;Advance to the next point:
		mov	eax, dword[ebp]
		inc	eax
		cmp	eax, dword[esi+4]
		jl	.skip
		add	esi, 8
		xor	eax, eax
.skip:		mov	dword[ebp], eax
		ret
%endif