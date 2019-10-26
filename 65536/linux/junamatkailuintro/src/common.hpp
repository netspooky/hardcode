#ifndef COMMON_HPP
#define COMMON_HPP

//approximate tanh, sin and tan, use ghetto versions of instruments
//considerable speed-ups
#define GHETTO_AUDIO
#if defined(GHETTO_AUDIO)
#define APPROXIMATE_TANH
#define APPROXIMATE_SIN
#define APPROXIMATE_TAN
#endif

//use alternative implementations for a handful of math functions
//seems to produce a very modest execution time advantage so disabling
//#define ALTERNATIVE_FMODF
//#define INLINE_CLAMP

//ignore range checks/clamping for params that should be safe
#define ASSUME_SAFE_RANGES

//should we allocate resources for and use the reverb?
#define USE_REVERB

#if !defined(WIN32)
#include "dnload.h"
#endif

/** \file
 * Common header file with some generally useful stuff.
 *
 * May be used with or without dnload.h
 */

#if defined(WIN32) && !defined(_USE_MATH_DEFINES)
/** \cond */
#define _USE_MATH_DEFINES
/** \endcond */
#endif

#if defined(WIN32)
#include <cmath>
#include <stdint.h>
#include <cstdio>
#endif

/** Floating-point samplerate. */
#define SAMPLERATE 44100.0f

/** Interval for internal state calculations in cycles*/
#define STATE_CALC_INTERVAL 3

/** Single-precision M_SQRT1_2. */
#define ONE_OVER_SQRT2 static_cast<float>(M_SQRT1_2)

/** Single-precision M_PI. */
#define PII static_cast<float>(M_PI)

/** Single-precision two times pi. */
#define TAU static_cast<float>(M_PI * 2.0)

namespace common
{
  //
  void add_dc(float& val);

#if defined(APPROXIMATE_TANH)
  //cschueler's rational tanh approximation from http://www.musicdsp.org/showone.php?id=238
  inline float rational_tanh(float x)
  {
    if (x < -3.0f)
      return -1.0f;
    else if (x > 3.0f)
      return 1.0f;
    else
      return x * (27.0f + x * x) / (27.0f + 9.0f * x * x);
  }
#endif

#if defined(APPROXIMATE_SIN) || defined(APPROXIMATE_TAN)
#define HALF_PI     (0.5f * PII)

//based on Michael Baczynski's sine approximation at http://lab.polygonal.de/?p=205
  inline float fast_sin(float x)
  {
    //always wrap input angle to -PI..PI
    while (fabs(x) > PII)
    {
      if (x < -PII)
        x += TAU;
      else
        if (x > PII)
          x -= TAU;
    }

    //compute sine
    if (x < 0.0f)
      return (1.27323954f * x) + (0.405284735f * x * x);
    else
      return (1.27323954f * x) - (0.405284735f * x * x);
  }

  inline float fast_cos(float x)
  {
    return common::fast_sin(x + HALF_PI);
  }

  inline float fast_tan(float x)
  {
    return common::fast_sin(x) / common::fast_cos(x);
  }
#endif

#if defined(ALTERNATIVE_FMODF)
  inline float mfmodf(float x, float y) { float a; return ((a = x / y) - (int)a)*y; }
#endif

  /** \brief Max function
   *
   * Windows sucks so goddamn much.
   *
   * @param lhs Left-hand-side operand.
   * @param rhs Right-hand-side operand.
   * @return Maximum value.
   */
#if defined(WIN32) || defined(INLINE_CLAMP)
  static inline float cfmaxf(float lhs, float rhs)
  {
    return (lhs >= rhs) ? lhs : rhs;
  }
#endif

  /** \brief Min function
   *
   * @param lhs Left-hand-side operand.
   * @param rhs Right-hand-side operand.
   * @return Minimum value.
   */

#if defined(WIN32) || defined(INLINE_CLAMP)
  static inline float cfminf(float lhs, float rhs)
  {
    return (lhs <= rhs) ? lhs : rhs;
  }
#endif

  /** \brief Clamp function.
  *
  * As in GLSL.
  *
  * @param op Input operand.
  * @param min Minimum value.
  * @param max Maximum value.
  * @retuen Clamped input value.
  */
#if defined(INLINE_CLAMP)
  static inline float cclampf(float op, float min, float max) { return common::cfmaxf(common::cfminf(op, max), min); };
#else
  float cclampf(float op, float min, float max);
#endif
  /** \brief Clamp value to unit size.
  *
  * @param op Input operand.
  * @retuen Input clamped to unit size.
  */
#if defined(INLINE_CLAMP)
  static inline float cclamp1f(float op) { return common::cclampf(op, -1.0f, 1.0f); };
#else
  float cclamp1f(float op);
#endif

  /** \brief Float round to int.
   *
   * @param op Floating point input.
   * @return Integer output.
   */
  static inline int clrintf(float op)
  {
#if defined(WIN32)
    return static_cast<int>(op + 0.5f);
#else
    return static_cast<int>(dnload_lrintf(op));
#endif
  }

  /** \brief Float round.
   *
   * @param op Floating point input.
   * @return Rounded result.
   */
  static inline float croundf(float op)
  {
#if defined(WIN32) 
    return floorf(op + 0.5f);
#elif defined(USE_LD)
    return roundf(op);
#else
    return static_cast<float>(dnload_lrintf(op));
#endif
  }
}

#endif
