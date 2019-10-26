#ifndef DNLOAD_HASH_H
#define DNLOAD_HASH_H

#include <stdint.h>

/** \brief SDBM hash function.
 *
 * Hash function from public domain ndbm library.
 * http://www.cse.yorku.ca/~oz/hash.html
 *
 * @param op String to hash.
 * @return Full hash.
 */
static uint32_t sdbm_hash(const uint8_t *op)
{
  uint32_t ret = 0;

  for(;;)
  {
    uint32_t cc = *op++;

    if(!cc)
    {
      return ret;
    }

    ret = ret * 65599 + cc;
  }
}

#endif
