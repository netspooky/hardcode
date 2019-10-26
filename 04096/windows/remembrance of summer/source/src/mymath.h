#pragma once

#ifndef M_PIf
#define M_PIf	(3.1415926535f)
#endif

#define MY_MATH_INLINE	static __forceinline

//	sin
MY_MATH_INLINE double my_sinf(float x) {
	__asm {
		fld		dword ptr [x]
		fsin
	}
}

//	cos
MY_MATH_INLINE double my_cosf(float x) {
	__asm {
		fld		dword ptr [x]
		fcos
	}
}

// atan2
MY_MATH_INLINE double my_atan2f(float y, float x) {
	__asm {
		fld	dword ptr [y]
		fld	dword ptr [x]
		fpatan
	}
}

//	pow
MY_MATH_INLINE double my_powf(float x, float y) {
	__asm {
		fld	    dword ptr [y]
		fld		dword ptr [x]
		ftst
		fstsw	ax
		sahf
		jz		zero

		fyl2x
		fld1
		fld		st(1)
		fprem
		f2xm1
		faddp	st(1), st(0)
		fscale

	zero:
		fstp	st(1)
	};
}

#define	fabsf(x)	static_cast<float>(my_fabsf(x))
#define	sinf(x)		static_cast<float>(my_sinf(x))
#define	cosf(x)		static_cast<float>(my_cosf(x))
#define	tanf(x)		static_cast<float>(my_tanf(x))
#define	atanf(x)	static_cast<float>(my_atanf(x))
#define	atan2f(y,x)	static_cast<float>(my_atan2f(y,x))
#define	sqrtf(x)	static_cast<float>(my_sqrtf(x))
#define	powf(x, y)	static_cast<float>(my_powf(x, y))
