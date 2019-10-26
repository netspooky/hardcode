// (c) 1995-1997 Niklas Beisert / pascal
// lasse reinboeng source
// this header must stay on top of this file
// free for non-commercial use of any kind as long as proper credits are given.

#ifndef __FMATH_H
#define __FMATH_H

#define M_PI        3.14159265358979323846

void finit();
long double fsin(long double);
long double fcos(long double);
long double fsqr(long double);
long double fpatan(long double, long double);
long double fsqrt(long double);
long double fprem(long double, long double);
long double ffabs(long double);
long double flog2(long double);
long double flog(long double);
long double flog10(long double);
long double fexp2(long double);
long double fexp(long double);
long double fexp10(long double);
long double fpow(long double, long double);

#pragma aux finit modify [8087] = "finit"
#pragma aux fsin parm [8087] value [8087] modify [8087] = "fsin"
#pragma aux fcos parm [8087] value [8087] modify [8087] = "fcos"
#pragma aux fpatan parm [8087] [8087] value [8087] modify [8087] = "fpatan"
#pragma aux fsqr parm [8087] value [8087] modify [8087] = "fmul st,st"
#pragma aux fsqrt parm [8087] value [8087] modify [8087] = "fsqrt"
#pragma aux fprem parm [8087] [8087] value [8087] modify [8087] = "fprem" "fxch st(1)" "fstp st(0)"
#pragma aux ffabs parm [8087] value [8087] modify [8087] = "fabs"
#pragma aux flog2 parm [8087] value [8087] modify [8087] = "fld1" "fxch st(1)" "fyl2x"
#pragma aux flog parm [8087] value [8087] modify [8087] = "fldln2" "fxch st(1)" "fyl2x"
#pragma aux flog10 parm [8087] value [8087] modify [8087] = "fldlg2" "fxch st(1)" "fyl2x"
#pragma aux fexp2 parm [8087] value [8087] modify [8087] = "fld1" "fld st(1)" "fprem" "f2xm1" "faddp st(1),st" "fscale" "fxch st(1)" "fstp st(0)"
#pragma aux fexp parm [8087] value [8087] modify [8087] = "fldl2e" "fmulp st(1),st" "fld1" "fld st(1)" "fprem" "f2xm1" "faddp st(1),st" "fscale" "fxch st(1)" "fstp st(0)"
#pragma aux fexp10 parm [8087] value [8087] modify [8087] = "fldl2t" "fmulp st(1),st" "fld1" "fld st(1)" "fprem" "f2xm1" "faddp st(1),st" "fscale" "fxch st(1)" "fstp st(0)"
#pragma aux fpow parm [8087] [8087] value [8087] modify [8087] = "fyl2x" "fld1" "fld st(1)" "fprem" "f2xm1" "faddp st(1),st" "fscale" "fxch st(1)" "fstp st(0)"

#endif
