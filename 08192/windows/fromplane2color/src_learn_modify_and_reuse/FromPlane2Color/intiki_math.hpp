#ifndef FROMPLANE2COLOR_INTIKI_MATH_HPP
#define FROMPLANE2COLOR_INTIKI_MATH_HPP

#include <tofu/math/simdvecf.hpp>
#include "packed_consts.hpp"

#ifndef MF_PI
#	define MF_PI	3.1415926535897932384f
#endif

namespace tofu
{

__forceinline vec4	itk_abs(const vec4& x)
{
	return
		movf
		(
			_mm_srli_epi32
			(
				_mm_slli_epi32(movi(x), 1),
				1
			)
		);
}

#if 0
__forceinline float	itk_abs(const float x)
{
	return itk_abs(vec4(x)).x;
}
#endif

__forceinline vec4	itk_floor(const vec4& x)
{
	return _mm_cvtepi32_ps(_mm_cvttps_epi32(x));
}

__forceinline vec4	itk_fract(const vec4& x)
{
	return x - itk_floor(x);
}

__forceinline vec4	itk_nsin3(const vec4& x)
{
	vec4 nx = itk_fract(itk_abs(x+cps1d4));
	vec4 negnx = vec4(cps1) - nx;
	nx = select(nx > vec4f(cps1d2), negnx, nx)-cps1d4;

	return -32.0f*nx*nx*nx + 6.0f*nx;
}

__forceinline vec4	itk_ncos3(const vec4& x)
{
	return itk_nsin3(x+cps1d4);
}

//x must be x>=0
__forceinline vec4 itk_natan1(const vec4& x)
{
	return -MF_PI/8.0f/(x+MF_PI/2.0f)+cps1d4;
}

//This is intiki atan2(y,x)*(1/(PI*2)).
//If x==0.0 or y==0.0, NaN might be generated.
//return 0 < x < 1
//
//      1/4
//       ^y
//       |    x
//1/2____|____>0
//       |
//       |
//      3/4
//Have fun!
__forceinline vec4 itk_natan2_1(const vec4& y, const vec4& x)
{
	const vec4 y_x = y/x;
	const vec4 x_y = x/y;

	const vec4 cond_y_x_gt_zero = y_x > vec4::zero();
	const vec4 t = select(cond_y_x_gt_zero, y_x, x_y);

	const vec4 cond_x_gt_zero = x > vec4::zero();
	const vec4 offset =
		select
		(
			cond_y_x_gt_zero,
			select
			(
				cond_x_gt_zero, vec4::zero(), cps1d2
			),
			select
			(
				cond_x_gt_zero, 3.0f/4.0f, cps1d4
			)
		);

	return itk_natan1(itk_abs(t))+offset;
//	return itk_natan1(itk_abs(x/y));
}

}

#endif
