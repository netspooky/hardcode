#ifndef TOFU_MATH_SIMDMATRIX_HPP
#define TOFU_MATH_SIMDMATRIX_HPP

#include <cmath>
#include "simdvecf.hpp"

namespace tofu
{
//Row major 3x4 matrix.
struct matrix3x4f
{
	matrix3x4f(const vec3f& col0, const vec3f& col1, const vec3f& col2, const vec3f& col3)
	{
		this->elems[0] = vec4f(col0[0], col1[0], col2[0], col3[0]);
		this->elems[1] = vec4f(col0[1], col1[1], col2[1], col3[1]);
		this->elems[2] = vec4f(col0[2], col1[2], col2[2], col3[2]);
	}

	vec3f operator*(const vec4f& v) const
	{
		return
			vec3f
			(
				dot(this->elems[0], v),
				dot(this->elems[1], v),
				dot(this->elems[2], v)
			);
	}

	void clear()
	{
		for(size_t i=0; i<3; ++i)
		{
			this->elems[i] = vec4f(0);
		}
	}

	vec4f	elems[3];
};

//Row major 4x4 matrix.
struct matrix4x4f
{
	matrix4x4f()
	{
	}

	matrix4x4f(const vec3f& col0, const vec3f& col1, const vec3f& col2, const vec3f& col3)
	{
		this->elems[0] = vec4f(col0[0], col1[0], col2[0], col3[0]);
		this->elems[1] = vec4f(col0[1], col1[1], col2[1], col3[1]);
		this->elems[2] = vec4f(col0[2], col1[2], col2[2], col3[2]);
		this->elems[3] = vec4f(0, 0, 0, 1);
	}

	matrix4x4f(const vec4f& col0, const vec4f& col1, const vec4f& col2, const vec4f& col3)
	{
		this->elems[0] = vec4f(col0[0], col1[0], col2[0], col3[0]);
		this->elems[1] = vec4f(col0[1], col1[1], col2[1], col3[1]);
		this->elems[2] = vec4f(col0[2], col1[2], col2[2], col3[2]);
		this->elems[3] = vec4f(col0[3], col1[3], col2[3], col3[3]);
	}

	const vec4f operator*(const vec4f& v) const
	{
		return
			vec4f
			(
				dot(this->elems[0], v),
				dot(this->elems[1], v),
				dot(this->elems[2], v),
				dot(this->elems[3], v)
			);
	}

	const matrix4x4f operator*(const matrix4x4f& m) const
	{
		return
			matrix4x4f
			(
				*this*m.get_column<0>(),
				*this*m.get_column<1>(),
				*this*m.get_column<2>(),
				*this*m.get_column<3>()
			);
	}

#if 0
	vec4f operator*(const vec4f& v)
	{
		vec4f ret = this->elems[0]*v[0];
		ret += this->elems[1]*v[1];
		ret += this->elems[2]*v[2];
		ret += this->elems[3]*v[3];

		return ret;
	}
#endif

	template<size_t id>
	void set_row(const vec4f& vec)
	{
		this->elems[id] = vec;
	}

	template<size_t id>
	void set_column(const vec4f& vec)
	{
		this->elems[0][id] = vec[0];
		this->elems[1][id] = vec[1];
		this->elems[2][id] = vec[2];
		this->elems[3][id] = vec[3];
	}

	template<size_t id>
	const vec4f get_column() const
	{
		return
			vec4f
			(
				this->elems[0][id],
				this->elems[1][id],
				this->elems[2][id],
				this->elems[3][id]
			);
	}

	void clear()
	{
		for(size_t i=0; i<4; ++i)
		{
			this->elems[i] = vec4f(0);
		}
	}

	vec4f	elems[4];
};

inline void perspective
(
	matrix4x4f& omat,
	const vec4f& setting	//fovy, aspect, zNear, zFar
)
{
	float f = 1.0f/tan(setting[0] * 0.5f);	

	omat.set_row<0>(vec4f(f / setting[1], 0.0f, 0.0f, 0.0f));
	omat.set_row<1>(vec4f(0.0f, f, 0.0f, 0.0f));
	omat.set_row<2>(vec4f(0.0f, 0.0f, (setting[3]+setting[2]) / (setting[2]-setting[3]), (2.0f*setting[3]*setting[2]) / (setting[2]-setting[3])));
	omat.set_row<3>(vec4f(0.0f, 0.0f, -1.0f, 0.0f));
}

inline void scaling(matrix4x4f& omat, float s)
{
	omat.set_row<0>(vec4f(s, 0, 0, 0));
	omat.set_row<1>(vec4f(0, s, 0, 0));
	omat.set_row<2>(vec4f(0, 0, s, 0));
	omat.set_row<3>(vec4f(0, 0, 0, 1));
}

}

#endif
