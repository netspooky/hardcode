#ifndef _attrs_h_
#define _attrs_h_

#include <stdint.h>

#ifdef __GNUC__

/* function doesn't return */
# define NORETURN __attribute__((noreturn))
/* for pure function stuff like foo()+foo() -> 2*foo() can be done */
# define PURE     __attribute__((pure))
/* arg indices that shouldn't be null (first is 1) */
# define NONNULL(varargs...) __attribute__((nonnull(varargs)))
/* function's result is pointer that cannot alias anything */
# define ALLOC __attribute__((malloc))
/* function's two first arguments are registers */
# define REGPARM __attribute__((regparm(3)))
/* no register arguments */
# define NOREGS __attribute__((regparm(0)))
/* stdcall may save an instruction when calling */
# define STDCALL __attribute__((stdcall))
/* always inline */
# define AINLINE __attribute__((always_inline))

#else /* not GNU C */

# define NORETURN
# define PURE
# define NONNULL(varargs...)
# define ALLOC
# define REGPARM
# define NOREGS
# define STDCALL
# define AINLINE

#endif

/* breaks strict-aliasing rules but seemed to be faster than
 * signbit(a) == signbit(b) */
#define TEST_FLOAT_SIGNS(a, b) \
  (!(((*(long *)&(a)) ^ (*(long *)&(b))) & 0x80000000))

#ifdef LEAKY
#define NO_LEAK(a)
#else
#define NO_LEAK(a) a
#endif

/* debug */

#ifdef DEBUG
#  include <stdio.h>
#  define DEB(a, varargs...) \
     ::fprintf(stderr, __FILE__ ": %d: " a "\n", __LINE__, ##varargs)
#  define FEB(a, varargs...) \
     ::fprintf(stderr, __FILE__ ": %s(): %d: " a "\n", __func__, __LINE__, ##varargs)
#else
#  define DEB(a, varargs...)
#  define FEB(a, varargs...)
#endif

#  define EB(a, varargs...)

#endif
