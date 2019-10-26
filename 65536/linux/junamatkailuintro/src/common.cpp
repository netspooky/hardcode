#include "common.hpp"

#if !defined(INLINE_CLAMP)
float common::cclampf(float op, float min, float max)
{
#if defined(WIN32)
  return common::cfmaxf(common::cfminf(op, max), min);
#else
  return dnload_fmaxf(dnload_fminf(op, max), min);
#endif
}

float common::cclamp1f(float op)
{
  return cclampf(op, -1.0f, 1.0f);
}
#endif

// denormalization killing with dc as presented by Laurent de Soras in
// http://ldesoras.free.fr/doc/articles/denormal-en.pdf
void common::add_dc(float& val)
{
//    static const float antidenormal_dc = 1e-20;
  static const float antidenormal_dc = 0.000000000000000001f;
  val += antidenormal_dc;
}

