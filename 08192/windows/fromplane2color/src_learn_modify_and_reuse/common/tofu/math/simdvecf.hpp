#ifndef TOFU_MATH_SIMDVECF_HPP
#define TOFU_MATH_SIMDVECF_HPP

#include <xmmintrin.h>
#include <intrin.h>
#include <boost/utility/enable_if.hpp>
#include <boost/type_traits.hpp>
#include <boost/mpl/logical.hpp>

namespace tofu
{
__declspec(align(16)) struct vec3f
{
	vec3f(){}
	__forceinline vec3f(float s):
		v(_mm_set1_ps(s))
	{
	}

	__forceinline vec3f(float x, float y, float z):
		v(_mm_set_ps(0.0f, z, y, x))
	{
	}

	__forceinline vec3f(float x, float y, float z, float w):
		v(_mm_set_ps(w, z, y, x))
	{
	}

	__forceinline vec3f(const vec3f& src):
		v(src.v)
	{
	}

	__forceinline vec3f(__m128 src):
		v(src)
	{
	}

	__forceinline vec3f(const float* src):
		v(_mm_load_ps(src))
	{
	}

	__forceinline vec3f& operator+=(const vec3f& v0);
	__forceinline vec3f& operator-=(const vec3f& v0);
	__forceinline vec3f& operator*=(const vec3f& v0);
	__forceinline vec3f& operator*=(const float v0);
	__forceinline vec3f& operator/=(const vec3f& v0);
	__forceinline vec3f& operator/=(const float v0);

	__forceinline vec3f operator-() const
	{
		return _mm_sub_ps(_mm_setzero_ps(), *this);
	}

	__forceinline void setW()
	{
		v.m128_f32[3] = 1.0f;
	}

	__forceinline void clearW()
	{
		v.m128_f32[3] = 0.0f;
	}

	__forceinline vec3f& operator=(const vec3f& src)
	{
		this->v = src.v;
		return *this;
	}

	__forceinline float& operator[](size_t i)
	{
		assert(i<4);
		return this->array[i];
	}

	__forceinline const float& operator[](size_t i) const
	{
		assert(i<4);
		return this->array[i];
	}

	__forceinline void packed_load(const float* src)
	{
		this->v = _mm_load_ps(src);
	}

	__forceinline operator __m128() const
	{
		return this->v;
	}

	__forceinline static vec3f zero()
	{
		return _mm_setzero_ps();
	}

	__forceinline vec3f operator &=(const vec3f& src)
	{
		return *this = _mm_and_ps(this->v, src);
	}

	union
	{
		__m128 v;
		struct {float x, y, z, w;};
		float array[4];
	};
};

struct vec4f : public vec3f
{
	vec4f(){}
	__forceinline vec4f(float s):
		vec3f(s)
	{
	}

	__forceinline vec4f(float x, float y, float z):
		vec3f(x, y, z, 1.0f)
	{
	}

	__forceinline vec4f(float x, float y, float z, float w):
		vec3f(x, y, z, w)
	{
	}

	__forceinline vec4f(const vec3f& src):
		vec3f(src)
	{
	}

	__forceinline vec4f(const vec3f& src, float w):
		vec3f(src)
	{
		v.m128_f32[3] = w;
	}

	__forceinline vec4f(const float* src):
		vec3f(_mm_load_ps(src))
	{
	}

	template<typename T>
	vec4f
	(
		T s,
		typename
		boost::enable_if
		<
			boost::mpl::or_
			<
				boost::is_same<T, int>,
				boost::is_same<T, unsigned int>
			>
		>::type* = 0
	)
	{
		//Select SHUFPS(1) or PSHUFD(0) for better compression rate!.
#if 0
		__m128 tmp = _mm_cvtepi32_ps(_mm_cvtsi32_si128(s));
		v = _mm_shuffle_ps(tmp, tmp, 0);
#else
		v = _mm_cvtepi32_ps(_mm_set1_epi32(s));
#endif
	}

	__forceinline vec3f& swizzle_xyz()
	{
		return *this;
	}

	__forceinline const vec3f& swizzle_xyz() const
	{
		return *this;
	}

	__forceinline vec4f& operator=(const vec4f& src)
	{
		this->v = src.v;
		return *this;
	}
};

typedef vec4f	vec4;
typedef vec3f	vec3;

__forceinline vec3f set_vec3f(float x, float y, float z)
{
	return vec3f(x, y, z);
}

__forceinline vec3f operator+(const vec3f& v0, const vec3f& v1)
{
	return _mm_add_ps(v0.v, v1.v);
}

__forceinline vec3f operator-(const vec3f& v0, const vec3f& v1)
{
	return _mm_sub_ps(v0.v, v1.v);
}

__forceinline vec3f operator*(const vec3f& v0, const vec3f& v1)
{
	return _mm_mul_ps(v0.v, v1.v);
}

__forceinline vec3f operator/(const vec3f& v0, const vec3f& v1)
{
	return _mm_div_ps(v0.v, v1.v);
}

__forceinline vec3f operator*(const vec3f& v0, float s)
{
	return _mm_mul_ps(v0.v, _mm_set1_ps(s));
}

__forceinline vec3f operator*(float s, const vec3f& v0)
{
	return v0.v*s;
}

__forceinline vec3f operator/(const vec3f& v0, float s)
{
	return _mm_div_ps(v0.v, _mm_set1_ps(s));
}

__forceinline vec3f operator>(const vec3f& v0, const vec3f& v1)
{
	return _mm_cmpgt_ps(v0, v1);
}

__forceinline vec3f operator<(const vec3f& v0, const vec3f& v1)
{
	return _mm_cmplt_ps(v0, v1);
}

__forceinline vec3f& vec3f::operator+=(const vec3f& v0)
{
	*this = *this + v0;

	return *this;
}

__forceinline vec3f& vec3f::operator-=(const vec3f& v0)
{
	*this = *this - v0;

	return *this;
}

__forceinline vec3f& vec3f::operator*=(const vec3f& v0)
{
	*this = *this * v0;

	return *this;
}

__forceinline vec3f& vec3f::operator*=(const float v0)
{
	*this = *this * v0;

	return *this;
}

__forceinline vec3f& vec3f::operator/=(const vec3f& v0)
{
	*this = *this / v0;

	return *this;
}

__forceinline vec3f& vec3f::operator/=(const float v0)
{
	*this = *this / v0;

	return *this;
}

__forceinline __m128 dot_ps(const vec3f& v0, const vec3f& v1)
{
#if 1
	return
		_mm_hadd_ps
		(
			_mm_hadd_ps
			(
				(v0*v1).v,
				_mm_setzero_ps()
			),
			_mm_setzero_ps()
		);
#else
	__m128 x0 = (v0*v1).v;
	x0 = _mm_hadd_ps(x0, x0);
	return _mm_hadd_ps(x0, x0);
#endif
}

__forceinline __m128 dot_ps(const vec3f& v0)
{
	return dot_ps(v0, v0);
}

__forceinline float dot(const vec3f& v0, const vec3f& v1)
{
	return dot_ps(v0, v1).m128_f32[0];
}

__forceinline float dot(const vec3f& v0)
{
	return dot(v0, v0);
}

__forceinline vec3f cross(const vec3f& v0, const vec3f& v1)
{
	__m128 tmpv0 = v0.v;
	__m128 tmpv1 = v1.v;
	__m128 tmpv2 = v0.v;
	__m128 tmpv3 = v1.v;

	tmpv0 = _mm_shuffle_ps(tmpv0, tmpv0, _MM_SHUFFLE(0, 0, 2, 1));
	tmpv1 = _mm_shuffle_ps(tmpv1, tmpv1, _MM_SHUFFLE(0, 1, 0, 2));
	tmpv0 = _mm_mul_ps(tmpv0, tmpv1);

	tmpv3 = _mm_shuffle_ps(tmpv3, tmpv3, _MM_SHUFFLE(0, 0, 2, 1));
	tmpv2 = _mm_shuffle_ps(tmpv2, tmpv2, _MM_SHUFFLE(0, 1, 0, 2));
	tmpv2 = _mm_mul_ps(tmpv2, tmpv3);
	tmpv0 = _mm_sub_ps(tmpv0, tmpv2);

	return tmpv0;
}

__forceinline float length2(const vec3f& v0)
{
	return dot(v0);
}

__forceinline float length(const vec3f& v0)
{
//	return sqrt(length2(v0));
	return _mm_sqrt_ps(dot_ps(v0)).m128_f32[0];
}

__forceinline vec3 sqrt(const vec3& v0)
{
	return _mm_sqrt_ps(v0);
}

__forceinline float distance2(const vec3f& v0, const vec3f& v1)
{
	return length2(v1-v0);
}

__forceinline float distance(const vec3f& v0, const vec3f& v1)
{
//	return sqrt(distance2(v0, v1));
	return _mm_sqrt_ps(dot_ps(v1-v0)).m128_f32[0];
}

__forceinline float rlength(const vec3f& v0)
{
	return _mm_rsqrt_ps(dot_ps(v0)).m128_f32[0];
}

__forceinline const vec3f normalize(const vec3f& v0)
{
//	return v0/length(v0);
	return v0*rlength(v0);
}

__forceinline const vec3f min(const vec3& v0, const vec3& v1)
{
	return _mm_min_ps(v0, v1);
}

__forceinline const vec3f max(const vec3& v0, const vec3& v1)
{
	return _mm_max_ps(v0, v1);
}

__forceinline const vec3f clamp(const vec3f& src, const vec3f& min, const vec3f& max)
{
	return _mm_min_ps(_mm_max_ps(src, min), max);
}

__forceinline __m128i movi(const __m128 s)
{
		return _mm_castps_si128(s);
}

__forceinline vec3f operator&(const vec3f& v0, const vec3f& v1)
{
	return _mm_and_ps(v0, v1);
}

__forceinline vec3f operator|(const vec3f& v0, const vec3f& v1)
{
	return _mm_or_ps(v0, v1);
}

__forceinline vec3f select(const vec3f& c, const vec3f& t, const vec3f& f)
{
	return (t&c) | _mm_andnot_ps(c, f);
}

__forceinline int movemask(const vec3f& src)
{
	return _mm_movemask_ps(src);
}

__forceinline vec3f rsqrt(const vec3f& src)
{
	return _mm_rsqrt_ps(src);
}

}

#endif
