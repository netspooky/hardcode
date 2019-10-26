#ifndef TOFU_MATH_SIMDIVEC_HPP
#define	TOFU_MATH_SIMDIVEC_HPP

#include <emmintrin.h>
#include "simdvecf.hpp"

namespace tofu
{
//GLSL style name!
#if 0
__declspec(align(16)) struct ivec4
{
	union
	{
		__m128i	v;
		struct	{int x, y, z, w;};
		int		array[4];
	};
};
#endif

__declspec(align(16)) struct uvec4
{
	typedef unsigned int uint;

	uvec4(){}

	__forceinline uvec4(__m128i s):
		v(s)
	{
	}

	__forceinline uvec4(const vec4& s):
		v(_mm_cvttps_epi32(s))
	{
	}

	__forceinline uvec4(const unsigned int s):
		v(_mm_set1_epi32(s))
	{
	}

	union
	{
		__m128i	v;
		struct	{uint x, y, z, w;};
		uint array[4];
	};

	__forceinline operator __m128i() const
	{
		return this->v;
	}

	__forceinline operator vec4() const
	{
		return _mm_cvtepi32_ps(this->v);
	}
};

__forceinline __m128 movf(const __m128i s)
{
	return _mm_castsi128_ps(s);
}

__forceinline uvec4 operator|(const uvec4& v0, const uvec4& v1)
{
	return
		movi
		(
			_mm_or_ps(movf(v0), movf(v1))
		);
}

}

#endif
