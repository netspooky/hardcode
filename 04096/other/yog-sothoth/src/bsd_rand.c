#include "bsd_rand.h"

#include <stdio.h>
#include <stdlib.h>

#define BSD_RAND_MAX 0x7FFFFFFF

/** BSD random var. */
static bsd_u_long bsd_rand_next = 1;

int bsd_rand(void)
{
  /*
   * Compute x = (7^5 * x) mod (2^31 - 1)
   * wihout overflowing 31 bits:
   *      (2^31 - 1) = 127773 * (7^5) + 2836
   * From "Random number generators: good ones are hard to find",
   * Park and Miller, Communications of the ACM, vol. 31, no. 10,
   * October 1988, p. 1195.
   */
  long hi, lo, x;

  /* Can't be initialized with 0, so use another value. */
  if(bsd_rand_next == 0)
  {
    bsd_rand_next = 123459876;
  }
  hi = bsd_rand_next / 127773;
  lo = bsd_rand_next % 127773;
  x = 16807 * lo - 2836 * hi;
  if (x < 0)
    x += 0x7fffffff;
  return ((bsd_rand_next = x) % ((bsd_u_long)BSD_RAND_MAX + 1));
}

void bsd_srand(bsd_u_int seed)
{
  bsd_rand_next = seed;
}

int bsd_rand_wrapper(void)
{
  static bsd_u_long cidx = 0;
  int ret = bsd_rand();
  int cmp = rand();

  if(ret != cmp)
  {
    printf("ERROR: rand() inconsistency %i (system) vs %i (custom) at call number %u\n", cmp, ret, cidx);
  }

  ++cidx;
  return ret;
}

void bsd_srand_wrapper(bsd_u_int seed)
{
  bsd_srand(seed);
  srand(seed);
}

