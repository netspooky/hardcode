#ifndef STDAFX_H
#define STDAFX_H

#pragma warning(push, 1)
#define WIN32_LEAN_AND_MEAN
#define WIN32_EXTRA_LEAN
#define NOMINMAX
#include <windows.h>
#include <Mmsystem.h>
#include <tmmintrin.h>	//for ssse3
#pragma warning(pop)

#ifndef DEMO_MODE
#	include <iostream>
#	include <fstream>
#else
//Avoid including cmath
//#define _CMATH_
#	include "notstd/math.hpp"
namespace std
{
//	using notstd::sqrt;
}
//using namespace notstd;
#endif

#include <cassert>
#include <boost/mpl/begin_end.hpp>
#include <boost/mpl/copy.hpp>
#include <boost/mpl/fold.hpp>
#include <boost/mpl/placeholders.hpp>
#include <boost/mpl/size.hpp>
#include <boost/mpl/vector.hpp>
#include <boost/type.hpp>

#include <tofu/math/simdvecf.hpp>
#include <tofu/math/simdmatrix.hpp>
#include <tofu/math/simdivec.hpp>

#endif
