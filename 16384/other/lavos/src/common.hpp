#ifndef COMMON_HPP
#define COMMON_HPP

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
#include <cmath>
#include <stdint.h>

/** Floating-point samplerate. */
#define SAMPLERATE 44100.0f

/** Single-precision M_SQRT1_2. */
#define ONE_OVER_SQRT2 static_cast<float>(M_SQRT1_2)

/** Single-precision M_PI. */
#define PII static_cast<float>(M_PI)

/** Single-precision two times pi. */
#define TAU static_cast<float>(M_PI * 2.0)

namespace common
{
  /** \brief Clamp function.
   *
   * As in GLSL.
   *
   * @param op Input operand.
   * @param min Minimum value.
   * @param max Maximum value.
   * @retuen Clamped input value.
   */
  float cclampf(float op, float min, float max);

  /** \brief Clamp value to unit size.
   *
   * @param op Input operand.
   * @retuen Input clamped to unit size.
   */
  float cclamp1f(float op);

  /** \brief Max function
   *
   * Windows sucks so goddamn much.
   *
   * @param lhs Left-hand-side operand.
   * @param rhs Right-hand-side operand.
   * @return Maximum value.
   */
  static inline float cfmaxf(float lhs, float rhs)
  {
#if defined(WIN32)
    return (lhs >= rhs) ? lhs : rhs;
#else
    return fmaxf(lhs, rhs);
#endif
  }

  /** \brief Min function
   *
   * @param lhs Left-hand-side operand.
   * @param rhs Right-hand-side operand.
   * @return Minimum value.
   */
  static inline float cfminf(float lhs, float rhs)
  {
#if defined(WIN32)
    return (lhs <= rhs) ? lhs : rhs;
#else
    return fminf(lhs, rhs);
#endif
  }

  /** \brief Float round to int.
   *
   * @param op Floating point input.
   * @return Integer output.
   */
  static inline int clrintf(float op)
  {
#if defined(USE_LD) && defined(WIN32)
    return static_cast<int>(op + 0.5f);
#else
    return static_cast<int>(lrintf(op));
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
    return static_cast<float>(lrintf(op));
#endif
  }
}

/** \cond */
#if defined(USE_LD)
#define cpowf powf
#define ctanhf tanhf
#else
#define cpowf g_sym.powf
#define ctanhf g_sym.tanhf
#endif
/** \endcond */

#endif
