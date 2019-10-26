;
; Macros and constants for simplified NASM coding under Win32
;
; Author:
;	William Swanson
;
; Index:
; import	Similar to NASM's "extern" command, but for DLL library functions.
; library	Instructs the linker to use the specified library.
;
; fmax		Selects the maximum of two values.
; fmin		Selects the minimum of two values.
; frange	Clamps st0 to be between the given values
; frsq		Calculates a reciprocal square root.
; fsearch	Performs a fast binary search for a particular value.
; invoke	Calls a function in a COM interface.
; loop		Faster version of the assembly-language loop command.
; random	Generates a random number within [-1.0, 1.0].
;
; v3add		Adds two three-component vectors.
; v3sub		Subtracts two three-component vectors.
; v3cross	Takes the cross product of two three-component vectors.
; v3dot		Takes the dot product of two three-component vectors.
; v3m3		Multiplies a three-component vector by a 3x3 matrix.
; v3v3		Multiplies two three-component vectors element-by-element.
; v3normal	Normalizes a three-component vector.
; v3scale	Multiplies a three-component vector by a scalar.
;
; m3align	Creates a rotation matrix for aligning geometry along an arbitrary axis.
; m3euler	Creates an Euler rotation matrix.
; m4look	Creates a look-at matrix.
;
; s2		Performs a linear interpolation.
; s2knot	Prepares control points for a linear interpolation.
; s2smooth	Performs smooth interpolation between two control points.
; s3bezier	Performs a quadratic Bezier-spline interpolation.
; s3b		Performs a quadratic B-spline interpolation.
; s4b		Performs a cubic B-spline interpolation.
; s4bezier	Performs a cubic Bezier-spline interpolation.
; s4bezier_dt	Calculates the derivative of a cubic Bezier spline.
; s4card	Performs a cubic cardinal-spline interpolation:
; s4card_dt	Finds the derivative of a cubic cardinal-spline interpolation.
; s4cardinal	Finds a point along a cardinal spline using the Bezier formula.
;

%ifndef math_inc_included
%define math_inc_included

;-----------------------------------------------------------------------------
; Import and export:
;-----------------------------------------------------------------------------
%ifndef math_asm
		extern	s_temp
		extern	_path
%endif

%ifndef const
%define const(name, value) extern s_ %+ name
%endif

const	(second,	0.000011338)		;Counts per second
const	(fn1,		-1.0)			;open
const	(f0p5,		0.5)			;open,flow
const	(f2,		2.0)			;texture, music
const	(f8,		8.0)			;fire
const	(f180,		180.0)			;rotation
const	(f255,		255.0)			;texture
const	(f32767,	32767.0)		;wave
const	(random_seed,	463675464)		;Seed
const	(random_div,	0x30000000)		;2^-31

;-------------------------------------------------------------------------------
; import
;
; Similar to NASM's "extern" command, but for DLL library functions.
;
; Parameters:
;	%1	Common function name
;	%2	Decorated function name
;-------------------------------------------------------------------------------
%imacro import 2
		extern	%2
%define %1 [%2]
%endmacro

;-------------------------------------------------------------------------------
; library
;
; Instructs the linker to use the specified library. May only be used after
; the following section directive:
;
;	section	.drectve info
;
; Parameters:
;	%1	Quoted library file name
;-------------------------------------------------------------------------------
%imacro library 1
		db	"-defaultlib:", %1, " "
%endmacro

;-------------------------------------------------------------------------------
; fmax
;
; Selects the maximum of two values.
;
; Parameters:
;	st0	First value to compare
;	%1	Second value to compare
; Returns:
;	st0	Maximum value
;-------------------------------------------------------------------------------
%imacro fmax 1
		fld	%1			;op,f
		fcomip	st0, st1		;f
		jc	%%skip			;Jump if st0 < st1
		fld	%1			;op,f
		fstp	st1			;op
%%skip:
%endmacro

;-------------------------------------------------------------------------------
; fmin
;
; Selects the minimum of two values.
;
; Parameters:
;	st0	First value to compare
;	%1	Second value to compare
; Returns:
;	st0	Minimum value
;-------------------------------------------------------------------------------
%imacro fmin 1
		fld	%1			;op,f
		fcomip	st0, st1		;f
		jnbe	%%skip			;Jump if st0 > st1
		fld	%1			;op,f
		fstp	st1			;op
%%skip:
%endmacro

;-------------------------------------------------------------------------------
; frsq
;
; Calculates a reciprocal square root.
;
; Parameters:
;	st0	Input scalar
; Returns:
;	st0	Output scalar
;-------------------------------------------------------------------------------
%macro frsq 0
		fsqrt				;sqrt(f)
		fld1				;1,sqrt(f)
		fdivrp	st1, st0		;1/sqrt(f)
%endmacro

;-------------------------------------------------------------------------------
; fsearch
;
; Performs a fast binary search for a particular value, t, in an array of
; values k[n]. The starting assumptions are that k[0] < t and that t < k[n].
; The function searches until it locates an element in the array, k[i], such
; that k[i] <= t < k[i+1]. The function returns the address of k[i].
;
; Parameters:
;	st0	t
;	esi	Array k address
;	ecx	Number of elements in array k
; Returns:
;	st0	t
;	esi	Element k[i] address
;	ecx	0
;-------------------------------------------------------------------------------
%macro fsearch 0
		dec	ecx
%%repeat1:	mov	eax, ecx
		shr	ecx, 1
		jz	%%done
%%repeat2:	fld	dword[esi+4*ecx]	;k[i],t
		fcomip	st1			;t
		jnbe	%%repeat1		;Jump if k[i] > t
		lea	esi, [esi+4*ecx]
		sub	eax, ecx
		mov	ecx, eax
		shr	ecx, 1
		jnz	%%repeat2	
%%done:
%endmacro

;-------------------------------------------------------------------------------
; invoke
;
; Calls a function in a COM interface.
;
; Parameters:
;	%1	Interface pointer label
;	%2	Function name
;-------------------------------------------------------------------------------
%imacro invoke 2
		mov	eax, [%1]
		push	eax
		mov	eax, [eax]
		call	[eax+%2]
%endmacro

;-------------------------------------------------------------------------------
; loop
;
; Smaller and faster version of the loop instruction.
;
; Parameters:
;	%1	Label to loop to
;	%2	Register to loop by (optional)
;-------------------------------------------------------------------------------
%imacro loop 1-2 ecx
		dec	%2
		jnz	%1
%endmacro

;-----------------------------------------------------------------------------
; random
;
; Generates a random number within [-1.0, 1.0]. Uses the algorithm described
; at http://en.wikipedia.org/wiki/Linear_congruential_generator.
;
; Return:
;	st0	Floating-point random number between -1.0 and 1.0.
;	eax	Random bit pattern. The low-order bits are worthless for
;		randomness, so always use the higher bits first.
;-----------------------------------------------------------------------------
%macro random 0
		imul	eax, [s_random_seed], 1664525
		add	eax, 1013904223
		mov	[s_random_seed], eax
		fild	dword[s_random_seed]	;Load random signed integer
		fmul	dword[s_random_div]	;random *= 2^-31
%endmacro

;-------------------------------------------------------------------------------
; v3add
;
; Adds two three-component vectors.
;
; Parameters:
;	esi	Input vector A address
;	ebx	Input vector B address
;	edi	Output vector C address
;-------------------------------------------------------------------------------
%macro v3add 0
		fld	dword[esi]
		fadd	dword[ebx]
		fstp	dword[edi]
		fld	dword[esi+4]
		fadd	dword[ebx+4]
		fstp	dword[edi+4]		
		fld	dword[esi+8]
		fadd	dword[ebx+8]
		fstp	dword[edi+8]
%endmacro

;-------------------------------------------------------------------------------
; v3sub
;
; Subtracts two three-component vectors.
;
; Parameters:
;	esi	Input vector A address
;	ebx	Input vector B address
;	edi	Output vector C address (C=A-B)
;-------------------------------------------------------------------------------
%macro v3sub 0
		fld	dword[esi]
		fsub	dword[ebx]
		fstp	dword[edi]
		fld	dword[esi+4]
		fsub	dword[ebx+4]
		fstp	dword[edi+4]
		fld	dword[esi+8]
		fsub	dword[ebx+8]
		fstp	dword[edi+8]
%endmacro

;-------------------------------------------------------------------------------
; v3mov
;
; Copies a vector from one location to another.
;
; Parameters:
;	esi	Input vector address
;	edi	Output vector address
;-------------------------------------------------------------------------------
%macro v3mov 0
		fld	dword[esi]
		fstp	dword[edi]
		fld	dword[esi+4]
		fstp	dword[edi+4]
		fld	dword[esi+8]
		fstp	dword[edi+8]
%endmacro

;-------------------------------------------------------------------------------
; v3cross
;
; Takes the cross product of two three-component vectors.
;
; Parameters:
;	esi	Input vector A address
;	ebx	Input vector B address
;	edi	Output vector address
;-------------------------------------------------------------------------------
%macro v3cross 0
		fld	dword[esi+4]
		fmul	dword[ebx+8]
		fld	dword[esi+8]
		fmul	dword[ebx+4]
		fsubp	st1, st0
		fstp	dword[edi]

		fld	dword[esi+8]
		fmul	dword[ebx+0]
		fld	dword[esi+0]
		fmul	dword[ebx+8]
		fsubp	st1, st0
		fstp	dword[edi+4]

		fld	dword[esi+0]
		fmul	dword[ebx+4]
		fld	dword[esi+4]
		fmul	dword[ebx+0]
		fsubp	st1, st0
		fstp	dword[edi+8]
%endmacro

;-------------------------------------------------------------------------------
; v3dot
;
; Takes the dot product of two three-component vectors.
;
; Parameters:
;	esi	Input vector A address
;	ebx	Input vector B address
; Returns:
;	st0	Scalar output
;-------------------------------------------------------------------------------
%macro v3dot 0
		fld	dword[esi]
		fmul	dword[ebx]
		fld	dword[esi+4]
		fmul	dword[ebx+4]
		fld	dword[esi+8]
		fmul	dword[ebx+8]
		faddp	st1, st0
		faddp	st1, st0
%endmacro

;-------------------------------------------------------------------------------
; v3m3
;
; Multiplies a three-component vector by a 3x3 matrix.
;
; Parameters:
;	esi	Input vector address
;	ebx	Input matrix address
;	edi	Output vector address
;-------------------------------------------------------------------------------
%macro v3m3 0
		v3dot
		fstp	dword[edi]
		add	ebx, byte 12
		v3dot
		fstp	dword[edi+4]
		add	ebx, byte 12
		v3dot
		fstp	dword[edi+8]
		add	ebx, byte -24
%endmacro

;-------------------------------------------------------------------------------
; v3v3
;
; Multiplies two three-component vectors element-by-element.
;
; Parameters:
;	esi	Input vector A address
;	ebx	Input vector B address
;	edi	Output vector C address
;-------------------------------------------------------------------------------
%macro v3v3 0
		fld	dword[esi]
		fmul	dword[ebx]
		fstp	dword[edi]
		fld	dword[esi+4]
		fmul	dword[ebx+4]
		fstp	dword[edi+4]		
		fld	dword[esi+8]
		fmul	dword[ebx+8]
		fstp	dword[edi+8]
%endmacro

;-------------------------------------------------------------------------------
; v3normal
;
; Normalizes a three-component vector.
; NOTE: Assumes ebx = esi
;
; Parameters:
;	esi&ebx	Input vector
;	edi	Output vector
;-------------------------------------------------------------------------------
%macro v3normal 0
		v3dot
		frsq
		v3scale
		fstp	st0
%endmacro

;-------------------------------------------------------------------------------
; v3scale
;
; Multiplies a three-component vector by a scalar.
;
; Parameters:
;	esi	Input vector address
;	st0	Scalar input
;	edi	Output vector address
; Returns:
;	st0	Scalar input (unmodified)
;-------------------------------------------------------------------------------
%macro v3scale 0
		fld	dword[esi]
		fmul	st0, st1
		fstp	dword[edi]
		fld	dword[esi+4]
		fmul	st0, st1
		fstp	dword[edi+4]		
		fld	dword[esi+8]
		fmul	st0, st1
		fstp	dword[edi+8]
%endmacro

;-------------------------------------------------------------------------------
; m3align
;
; Creates a rotation matrix for aligning geometry along an arbitrary axis. The
; matrix has the folowing formula:
; 
;	| 1-yx*yx/(1+yy)  yx  -yz*yx/(1+yy)  |
;	| -yx		  yy  -yz            |
;	| -yx*yz/(1+yy)   yz  1-yz*yz/(1+yy) |
;
; This matrix's center column is the input vector normalized, and the outer
; two columns are computed based on the center column.
;
; WARNING!!! Derived with an incorrect understanding of rotation matrixes!!!
; The whole thing ought to be transposed to be compatible with v3m3!!!
;
; Parameters:
;	esi&ebx	Input vector address
;	edi	Output matrix address
;-------------------------------------------------------------------------------
%macro m3align 0
		;Normalize and copy the input vector:
		add	edi, byte 12
		normal3
		add	edi, byte -12

		;Build the left column:
		fld	dword[edi+12]			;yx
		fchs					;-yx
		fld1					;1,-yx
		fadd	dword[edi+16]			;1+yy,-yx
		fdivr	st0, st1			;-yx/1+yy,-yx
		fld	st0				;-yx/1+yy,-yx/1+yy,-yx
		fmul	dword[edi+20]			;-yx*yz/1+yy,-yx/1+yy,-yx
		fstp	dword[edi+8]			;-yx/1+yy,-yx
		fmul	st1				;yx*yx/1+yy,-yx
		fld1					;1,-yx*yx/1+yy,-yx
		fsubrp	st1, st0			;1-yx*yx/1+yy,-yx
		fstp	dword[edi+0]			;-yx
		fstp	dword[edi+4]			;

		;Build the right column:
		fld	dword[edi+20]			;yz
		fchs					;-yz
		fld1					;1,-yz
		fadd	dword[edi+16]			;1+yy,-yz
		fdivr	st0, st1			;-yz/1+yy,-yz
		fld	st0				;-yz/1+yy,-yz/1+yy,-yz
		fmul	dword[edi+12]			;-yz*yx/1+yy,-yz/1+yy,-yz
		fstp	dword[edi+24]			;-yz/1+yy,-yz
		fmul	st1				;yz*yz/1+yy,-yz
		fld1					;1,yz*yz/1+yy,-yz
		fsubrp	st1, st0			;1-yz*yz/1+yy,-yz
		fstp	dword[edi+32]			;-yz
		fstp	dword[edi+28]			;
%endmacro

;-------------------------------------------------------------------------------
; m3euler
;
; Creates an Euler rotation matrix according to this formula:
; 
;	| ac   bf-aed   -be-afd |
;	| d    ce	cf      |
;	| bc   -af-bed  ae-bfd  |
;
; a = cos ry
; b = sin ry
; c = cos rz
; d = sin rz
; e = cos rx
; f = sin rx
;
; Parameters:
;	ebx	Input vector address
;	edi	Output matrix address
;-------------------------------------------------------------------------------
%macro m3euler 0
		fldpi
		fmul	dword[ebx]			;rx
		fsincos					;e,f
		fldpi
		fmul	dword[ebx+8]			;rz,e,f
		fsincos					;c,d,e,f
		fldpi
		fmul	dword[ebx+4]			;ry,c,d,e,f
		fsincos					;a,b,c,d,e,f

		fld	st0				;a,a,b,c,d,e,f
		fmul	st3				;ac,a,b,c,d,e,f
		fstp	dword[edi]
		fld	st1				;b,a,b,c,d,e,f
		fmul	st6				;bf,a,b,c,d,e,f
		fld	st1				;a,bf,a,b,c,d,e,f
		fmul	st6				;ae,bf,a,b,c,d,e,f
		fmul	st5				;aed,bf,a,b,c,d,e,f
		fsubp	st1, st0			;bf-aed,a,b,c,d,e,f
		fstp	dword[edi+4]
		fld	st1				;b,a,b,c,d,e,f
		fmul	st5				;be,a,b,c,d,e,f
		fld	st1				;a,be,a,b,c,d,e,f
		fmul	st7				;af,be,a,b,c,d,e,f
		fmul	st5				;afd,be,a,b,c,d,e,f
		faddp	st1, st0			;be+afd,a,b,c,d,e,f
		fchs
		fstp	dword[edi+8]

		fld	st3				;d,a,b,c,d,e,f
		fstp	dword[edi+12]
		fld	st2				;c,a,b,c,d,e,f
		fmul	st5				;ce,a,b,c,d,e,f
		fstp	dword[edi+16]
		fld	st2				;c,a,b,c,d,e,f
		fmul	st6				;cf,a,b,c,d,e,f
		fstp	dword[edi+20]

		fld	st1				;b,a,b,c,d,e,f
		fmul	st3				;bc,a,b,c,d,e,f
		fstp	dword[edi+24]
		fld	st0				;a,a,b,c,d,e,f
		fmul	st6				;af,a,b,c,d,e,f
		fld	st2				;b,af,a,b,c,d,e,f
		fmul	st6				;be,af,a,b,c,d,e,f
		fmul	st5				;bed,af,a,b,c,d,e,f
		faddp	st1, st0			;af+bed,a,b,c,d,e,f
		fchs
		fstp	dword[edi+28]
		fld	st0				;a,a,b,c,d,e,f
		fmul	st5				;ae,a,b,c,d,e,f
		fld	st2				;b,ae,a,b,c,d,e,f
		fmul	st7				;bf,ae,a,b,c,d,e,f
		fmul	st5				;bfd,ae,a,b,c,d,e,f
		fsubp	st1, st0			;ae-bfd,a,b,c,d,e,f
		fstp	dword[edi+32]

		fcompp
		fcompp
		fcompp
%endmacro

;-------------------------------------------------------------------------------
; m4look
;
; Creates a look-at matrix.
; 
; Parameters:
;	esi	Look-at location vector address
;	ebx	Camera location vector address
;	edi	Output matrix address
;-------------------------------------------------------------------------------
%macro m4look 0
		;Set up the axes:
		push	ebx
		add	edi, 32
		v3sub
		mov	esi, edi
		mov	ebx, edi
		v3normal
		add	edi, -32
		fld	dword[esi]
		fchs
		fstp	dword[edi+8]
		fld	dword[esi+8]
		fstp	dword[edi]
		mov	esi, edi
		mov	ebx, edi
		v3normal
		add	esi, 32
		add	edi, 16
		v3cross
		add	edi, -16

		;Set up the translation:
		pop	ebx
		v3dot
		fchs
		fstp	dword[edi+44]
		add	esi, -16
		v3dot
		fchs
		fstp	dword[edi+28]
		add	esi, -16
		v3dot
		fchs
		fstp	dword[edi+12]
%endmacro

;-------------------------------------------------------------------------------
; s2
;
; Performs a linear interpolation.
;
; Maximum FPU stack:
;	2
; Parameters:
;	st0	t
;	esi	Control point array address
;	%1	Stride
; Returns:
;	st0	s2(t)
;-------------------------------------------------------------------------------
%macro s2 1
		;Calculate the basis functions:
		fld1				;1,t
		fsub	st1			;1-t,t

		;Multiply the control points by the basis functions:
		fld	dword[esi]
		fmulp	st1, st0
		fld	dword[esi+%1]
		fmulp	st2, st0

		;Sum the weighted control points:
		faddp	st1, st0		;a+b
%endmacro

;-------------------------------------------------------------------------------
; s2knot
;
; Prepares control points for a linear interpolation using the a knot vector
; (timing array).
;
; Parameters:
;	st0	t
;	ecx	Number of control points
;	esi	Knot vector address
;	ebx	Control point array address
; Returns:
;	ecx	0
;-------------------------------------------------------------------------------
%macro s2knot 0
		;Do a binary search for the correct knot interval:
		push	esi
		fsearch
		pop	eax
		sub	eax, esi
		sub	ebx, eax

		;Adjust t to the [0, 1) range:
		fld	dword[esi]		;t0,t
		fsub	st1, st0		;t0,t-t0
		fsubr	dword[esi+4]		;t1-t0,t-t0
		fdivp	st1, st0		;(t-t0)/(t1-t0)

		;Do the interpolation:
		xchg	esi, ebx
		s2smooth 4
		xchg	esi, ebx
%endmacro

;-------------------------------------------------------------------------------
; s2smooth
;
; Performs smooth interpolation between two control points.
;
; p[0](1-(3x^2-2x^3)) + p[1](3x^2-2x^3)
;
; Parameters:
;	st0	t
;	esi	Control point address
;	%1	pitch
;-------------------------------------------------------------------------------
%macro s2smooth 1
		;Generate the basis functions:
		fld	st0			;t,t
		fmul	st0, st0		;t^2,t
		fld	st0			;t^2,t^2,t
		fadd	st0, st0		;2t^2,t^2,t
		fadd	st1, st0		;2t^2,3t^2,t
		fmulp	st2, st0		;3t^2,2t^3
		fsubrp	st1, st0		;3t^2-2t^3
		fld1				;1,3t^2-2t^3
		fsub	st0, st1		;1-3t^2-2t^3,3t^2-2t^3
		
		;Multiply the control points by the basis functions:
		fld	dword[esi]
		fmulp	st1, st0
		fld	dword[esi+%1]
		fmulp	st2, st0

		;Sum the weighted control points:
		faddp	st1, st0		;a+b
%endmacro

;-------------------------------------------------------------------------------
; s3bezier
;
; Performs a quadratic Bezier-spline interpolation.
;
; Maximum FPU stack:
;	5
; Parameters:
;	st0	t
;	esi	Control point array address
; Returns:
;	st0	s3bezier(t)
;-------------------------------------------------------------------------------
%macro s3bezier 0
		;Calculate the basis functions:
		fld1				;1,t
		fsub	st1			;1-t,t
		fld	st1			;t,1-t,t
		fld	st1			;1-t,t,1-t,t
		fld	st1			;t,1-t,t,1-t,t
		fmulp	st4, st0		;1-t,t,1-t,t^2
		fmul	st2, st0		;1-t,t,(1-t)^2,t^2
		fmulp	st1, st0		;(1-t)*t,(1-t)^2,t^2
		fadd	st0, st0		;2(1-t)*t,(1-t)^2,t^2

		;Multiply the control points by the basis functions:
		fld	dword[esi]
		fmulp	st2, st0
		fld	dword[esi+4]
		fmulp	st1, st0
		fld	dword[esi+8]
		fmulp	st3, st0

		;Sum the weighted control points:
		faddp	st1, st0		;a+b,c
		faddp	st1, st0		;a+b+c
%endmacro

;-------------------------------------------------------------------------------
; s3b
;
; Performs a quadratic B-spline interpolation.
;
; (p[0](1-t)^2 + p[1](1+2(1-t)t) + p[2]t^2)/2
;
; Maximum FPU stack:
;	5
; Parameters:
;	st0	t
;	esi	Control point array address
;	%1	stride
; Returns:
;	st0	s3bezier(t)
;-------------------------------------------------------------------------------
%macro s3b 1
		;Calculate the basis functions:
		fld1				;1,t
		fsub	st1			;1-t,t
		fld	st1			;t,1-t,t
		fld	st1			;1-t,t,1-t,t
		fld	st1			;t,1-t,t,1-t,t
		fmulp	st4, st0		;1-t,t,1-t,t^2
		fmul	st2, st0		;1-t,t,(1-t)^2,t^2
		fmulp	st1, st0		;(1-t)*t,(1-t)^2,t^2
		fadd	st0, st0		;2(1-t)*t,(1-t)^2,t^2
		fld1				;1,2(1-t)*t,(1-t)^2,t^2
		faddp	st1, st0		;1+2(1-t)*t,(1-t)^2,t^2

		;Multiply the control points by the basis functions:
		fld	dword[esi+(%1)*0]
		fmulp	st2, st0
		fld	dword[esi+(%1)*1]
		fmulp	st1, st0
		fld	dword[esi+(%1)*2]
		fmulp	st3, st0

		;Sum the weighted control points:
		faddp	st1, st0		;a+b,c
		faddp	st1, st0		;a+b+c
		fmul	dword[f2r]
%endmacro

;-------------------------------------------------------------------------------
; s4b
;
; Performs a cubic B-spline interpolation.
;
; (p[0](1-t)^3 + p[1](4-6t^2+3t^3) + p[2](4-6(1-t)^2+3(1-t)^3) + p[3]t^3)/6
;
; Maximum FPU stack:
;	6
; Parameters:
;	st0	t
;	esi	Control point array address
;	%1	stride
; Returns:
;	st0	s4b(t)
;-------------------------------------------------------------------------------
%macro s4b 1
		;Calculate the basis functions:
		fld1				;1,t
		fsub	st0, st1		;1-t,t
		fld	st1			;t,1-t,t
		fld	st1			;1-t,t,1-t,t
		fld	st1			;t,1-t,t,1-t,t
		fld	st1			;1-t,t,1-t,t,1-t,t
		fmul	st0, st0		;(1-t)^2,t,1-t,t,1-t,t
		fmul	st4, st0		;(1-t)^2,t,1-t,t,(1-t)^3,t
		fmul	dword[f3]		;3(1-t)^2,t,1-t,t,(1-t)^3,t
		fmul	st2, st0		;3(1-t)^2,t,3(1-t)^3,t,(1-t)^3,t
		fadd	st0, st0		;6(1-t)^2,t,3(1-t)^3,t,(1-t)^3,t
		fsubp	st2, st0		;t,3(1-t)^3-6(1-t)^2,t,(1-t)^3,t
		fld	dword[f4]		;4,t,3(1-t)^3-6(1-t)^2,t,(1-t)^3,t
		faddp	st2, st0		;t,3(1-t)^3-6(1-t)^2+4,t,(1-t)^3,t
		fmul	st0, st0		;t^2,3(1-t)^3-6(1-t)^2+4,t,(1-t)^3,t
		fmul	st4, st0		;t^2,3(1-t)^3-6(1-t)^2+4,t,(1-t)^3,t^3
		fmul	dword[f3]		;3t^2,3(1-t)^3-6(1-t)^2+4,t,(1-t)^3,t^3
		fmul	st2, st0		;3t^2,3(1-t)^3-6(1-t)^2+4,3t^3,(1-t)^3,t^3
		fadd	st0, st0		;6t^2,3(1-t)^3-6(1-t)^2+4,3t^3,(1-t)^3,t^3
		fsubp	st2, st0		;3(1-t)^3-6(1-t)^2+4,3t^3-6t^2,(1-t)^3,t^3
		fld	dword[f4]		;4,3(1-t)^3-6(1-t)^2+4,3t^3-6t^2,(1-t)^3,t^3
		faddp	st2, st0		;3(1-t)^3-6(1-t)^2+4,3t^3-6t^2+4,(1-t)^3,t^3

		;Multiply the control points by the basis functions:
		fld	dword[esi+(%1)*0]
		fmulp	st3, st0
		fld	dword[esi+(%1)*1]
		fmulp	st2, st0
		fld	dword[esi+(%1)*2]
		fmulp	st1, st0
		fld	dword[esi+(%1)*3]
		fmulp	st4, st0

		;Sum the weighted control points:
		faddp	st1, st0		;a+b,c,d
		faddp	st1, st0		;a+b+c,d
		faddp	st1, st0		;a+b+c+d
		fmul	dword[f6r]
%endmacro

;-------------------------------------------------------------------------------
; s4bezier
;
; Performs a cubic Bezier-spline interpolation.
;
; Maximum FPU stack:
;	6
; Parameters:
;	st0	t
;	esi	Control point array address
;	%1	stride
; Returns:
;	st0	s4bezier(t)
;-------------------------------------------------------------------------------
%macro s4bezier 1
		;Calculate the basis functions:
		fld1				;1,t
		fsub	st0, st1		;1-t,t
		fld	st1			;t,1-t,t
		fld	st1			;1-t,t,1-t,t
		fld	st1			;t,1-t,t,1-t,t
		fld	st1			;1-t,t,1-t,t,1-t,t
		fmul	st0, st0		;(1-t)^2,t,1-t,t,1-t,t
		fmul	st4, st0		;(1-t)^2,t,1-t,t,(1-t)^3,t
		fmul	dword[f3]		;3(1-t)^2,t,1-t,t,(1-t)^3,t
		fmulp	st3, st0		;t,1-t,3t(1-t)^2,(1-t)^3,t
		fmul	st0, st0		;t^2,1-t,3t(1-t)^2,(1-t)^3,t
		fmul	st4, st0		;t^2,(1-t),3t(1-t)^2,(1-t)^3,t^3
		fmul	dword[f3]		;3t^2,(1-t),3t(1-t)^2,(1-t)^3,t^3
		fmulp	st1, st0		;3(1-t)t^2,3t(1-t)^2,(1-t)^3,t^3

		;Multiply the control points by the basis functions:
		fld	dword[esi+(%1)*0]
		fmulp	st3, st0
		fld	dword[esi+(%1)*1]
		fmulp	st2, st0
		fld	dword[esi+(%1)*2]
		fmulp	st1, st0
		fld	dword[esi+(%1)*3]
		fmulp	st4, st0

		;Sum the weighted control points:
		faddp	st1, st0		;a+b,c,d
		faddp	st1, st0		;a+b+c,d
		faddp	st1, st0		;a+b+c+d
%endmacro

;-------------------------------------------------------------------------------
; s4bezier_dt
;
; Calculates the derivative of a cubic Bezier spline.
;
; Maximum FPU stack:
;	6
; Parameters:
;	st0	t
;	esi	Control point array address
; Returns:
;	st0	d/dt s4bezier(t)
;	st1	t
;-------------------------------------------------------------------------------
%macro s4bezier_dt 0
		;Calculate the basis functions:
		fld1				;1,t
		fsub	st1			;1-t,t
		fld	st1			;t,1-t,t
		fld	st1			;1-t,t,1-t,t
		fld	st1			;t,1-t,t,1-t,t
		fld	st1			;1-t,t,1-t,t,1-t,t
		fchs				;-(1-t),t,1-t,t,1-t,t
		fmul	dword[f3]		;-3(1-t),t,1-t,t,1-t,t
		fmul	st4, st0		;-3(1-t),t,1-t,t,-3(1-t)^2,t
		fadd	st0, st0		;-6(1-t),t,1-t,t,-3(1-t)^2,t
		fmulp	st3, st0		;t,1-t,-6t(1-t),-3(1-t)^2,t
		fmul	dword[f3]		;3t,1-t,-6t(1-t),-3(1-t)^2,t
		fmul	st4, st0		;3t,1-t,-6t(1-t),-3(1-t)^2,3t^2
		fadd	st0, st0		;6t,1-t,-6t(1-t),-3(1-t)^2,3t^2
		fmulp	st1, st0		;6t(1-t),-6t(1-t),-3(1-t)^2,3t^2
		
		fsub	st0, st3		;db2,-6t(1-t),db0,db3
		fincstp				;-6t(1-t),db0,db3
		fsub	st0, st2		;db1,db0,db3
		fdecstp				;db2,db1,db0,db3

		;Multiply the control points by the basis functions:
		fld	dword[esi]
		fmulp	st3, st0
		fld	dword[esi+4]
		fmulp	st2, st0
		fld	dword[esi+8]
		fmulp	st1, st0
		fld	dword[esi+12]
		fmulp	st4, st0

		;Sum the weighted control points:
		faddp	st1, st0		;a+b,c,d
		faddp	st1, st0		;a+b+c,d
		faddp	st1, st0		;a+b+c+d
%endmacro

;-------------------------------------------------------------------------------
; s4card
;
; Performs a cubic cardinal-spline interpolation:
;
; Maximum FPU stack:
;	7
; Parameters:
;	st0	t
;	esi	Control point array address
;	%1	List pitch
;	%2	a (tension)
; Returns:
;	st0	s4cardinal[t]
;	st1	a (tension)
;-------------------------------------------------------------------------------
%macro s4card 2
		;Calculate the basis functions:
		fld1				;1,t
		fsub	st0, st1		;1-t,t
		fld	st1			;t,1-t,t
		fld	st1			;1-t,t,1-t,t
		fld	st1			;t,1-t,t,1-t,t
		fld	st1			;1-t,t,1-t,t,1-t,t
		fmul	st0, st0		;(1-t)^2,t,1-t,t,1-t,t
		fmul	st4, st0		;(1-t)^2,t,1-t,t,(1-t)^3,t
		fmul	dword[f3]		;3(1-t)^2,t,1-t,t,(1-t)^3,t
		fmulp	st3, st0		;t,1-t,3t(1-t)^2,(1-t)^3,t
		fmul	st0, st0		;t^2,1-t,3t(1-t)^2,(1-t)^3,t
		fmul	st4, st0		;t^2,(1-t),3t(1-t)^2,(1-t)^3,t^3
		fmul	dword[f3]		;3t^2,(1-t),3t(1-t)^2,(1-t)^3,t^3
		fmulp	st1, st0		;3(1-t)t^2,3t(1-t)^2,(1-t)^3,t^3

		;Notation change: b2, b1, b0, b3
		fadd	st3, st0		;b2,b1,b0,b3+b2
		fmul	dword[%2]		;a*b2,b1,b0,b3+b2
		fadd	st2, st0		;a*b2,b1,b0+a*b2,b3+b2
		fchs				;-a*b2,b1,b0+a*b2,b3+b2
		fincstp				;b1,b0+a*b2,b3+b2
		fadd	st1, st0		;b1,b0+b1+a*b2,b3+b2
		fmul	dword[%2]		;a*b1,b0+b1+a*b2,b3+b2
		fadd	st2, st0		;a*b1,b0+b1+a*b2,b3+b2+a*b1
		fchs				;-a*b1,b0+b1+a*b2,b3+b2+a*b1
		fdecstp				;-a*b2,-a*b1,b0+b1+a*b2,b3+b2+a*b1

		;Multiply the control points by the basis functions:
		fld	dword[esi+(%1)*0]
		fmulp	st2, st0
		fld	dword[esi+(%1)*1]
		fmulp	st3, st0
		fld	dword[esi+(%1)*2]
		fmulp	st4, st0
		fld	dword[esi+(%1)*3]
		fmulp	st1, st0

		;Sum the weighted control points:
		faddp	st1, st0		;a+b,c,d
		faddp	st1, st0		;a+b+c,d
		faddp	st1, st0		;a+b+c+d
%endmacro

;-------------------------------------------------------------------------------
; s4card_dt
;
; Finds the derivative of a cubic cardinal-spline interpolation.
;
; Maximum FPU stack:
;	7
; Parameters:
;	st0	t
;	st1	a (tension)
;	esi	Control point array address
; Returns:
;	st0	d/dt s4cardinal[t]
;	st1	a (tension)
;-------------------------------------------------------------------------------
%macro s4card_dt 0
		;Calculate the basis functions:
		fld1				;1,t,a
		fsub	st1			;1-t,t,a
		fxch	st0, st1		;t,1-t,a
		fld	st1			;1-t,t,1-t,a
		fld	st1			;t,1-t,t,1-t,a
		fld	st1			;1-t,t,1-t,t,1-t,a
		fld	st1			;t,1-t,t,1-t,t,1-t,a
		fmul	dword[f3]		;3t,1-t,t,1-t,t,1-t,a
		fmul	st2, st0		;3t,1-t,3t^2,1-t,t,1-t,a
		fadd	st0, st0		;6t,1-t,3t^2,1-t,t,1-t,a
		fmulp	st5, st0		;1-t,3t^2,1-t,t,6t(1-t),a
		fchs				;-(1-t),3t^2,1-t,t,6t(1-t),a
		fmul	dword[f3]		;-3(1-t),3t^2,1-t,t,6t(1-t),a
		fmul	st2, st0		;-3(1-t),3t^2,-3(1-t)^2,t,6t(1-t),a
		fadd	st0, st0		;-6(1-t),3t^2,-3(1-t)^2,t,6t(1-t),a
		fmulp	st3, st0		;3t^2,-3(1-t)^2,-6t(1-t),6t(1-t),a

		fadd	st0, st2		;3t^2-6t(1-t),-3(1-t)^2,-6t(1-t),6t(1-t),a
		fmul	st0, st4		;dc3,-3(1-t)^2,-6t(1-t),6t(1-t),a
		fsub	st2, st0		;dc3,-3(1-t)^2,dc1,6t(1-t),a
		fincstp				;-3(1-t)^2,dc1,6t(1-t),a
		fadd	st0, st2		;6t(1-t)-3(1-t)^2,dc1,6t(1-t),a
		fmul	st0, st3		;dc0,dc1,6t(1-t),a
		fsub	st2, st0		;dc0,dc1,dc2,a
		fdecstp				;dc3,dc0,dc1,dc2,a

		;Multiply the control points by the basis functions:
		fld	dword[esi]
		fmulp	st2, st0
		fld	dword[esi+4]
		fmulp	st3, st0
		fld	dword[esi+8]
		fmulp	st4, st0
		fld	dword[esi+12]
		fmulp	st1, st0

		;Sum the weighted control points:
		faddp	st1, st0		;a+b,c,d
		faddp	st1, st0		;a+b+c,d
		faddp	st1, st0		;a+b+c+d
%endmacro

;-------------------------------------------------------------------------------
; s4cardinal
;
; Finds a point along a cardinal spline using the Bezier formula.
;
; Parameters:
;	st0	Tension (a)
;	st1	t
;	esi	Control point array address
;-------------------------------------------------------------------------------
%macro b4cardinal 0
		fld	dword[esi+4]		;p1,a,t
		fld	dword[esi+8]		;p2,p1,a,t

		fld	dword[esi]		;p0,p2,p1,a,t
		fsubr	st0, st1		;p2-p0,p2,p1,a,t
		fmul	st0, st3		;a(p2-p0),p2,p1,a,t
		fadd	st0, st2		;p1+a(p2-p0),p2,p1,a,t
		fstp	dword[esi+4]		;p2,p1,a,t

		fld	dword[esi+12]		;p3,p2,p1,a,t
		fsubr	st0, st2		;p1-p3,p2,p1,a,t
		fmul	st0, st3		;a(p1-p3),p2,p1,a,t
		fadd	st0, st1		;p2+a(p1-p3),p2,p1,a,t
		fstp	dword[esi+8]		;p2,p1,a,t

		fstp	dword[esi+12]		;p1,a,t
		fstp	dword[esi]		;a,t
		fstp	st0			;t
		
		b4
%endmacro

%endif
