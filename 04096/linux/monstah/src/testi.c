#include <stdio.h>

void foobar(unsigned int P, unsigned int N) {
  unsigned int i;
      unsigned int data =
#define D(a, b, c, d) ((c) | ((d)<<2) | ((a)<<4) | ((b)<<6))
        /* P0, P1, N1, N0 */
        D(0, 1, 1, 0) |
        /* P1, P2, N2, N1 */
        (D(1, 2, 2, 1) << 8) |
        /* P2, P3, N3, N2 */
        (D(2, 3, 3, 2) << 16) |
        /* P3, P0, N0, N3 */
        (D(3, 0, 0, 3) << 24);
#undef D

      for(i=0; i<4; i++) {
#if 0
        /* This is broken anyway, ANDs are missing */
        *sp++ =
          (P >> ((data & (3<<0))*8)) |
          (P >> ((data & (3<<2))*2) << 8) |
          (N >> ((data & (3<<4))/2) << 16) |
          (N >> ((data & (3<<6))/8) << 24);
        data >>= 8;
#else
        unsigned int q;

        q = ( (N >> ((data &      3) * 8)) & 0xFF) |
            (((N >> ((data & (3<<2)) * 2))) << 8);
        data >>= 4;

        q = (q << 16) |
            ( (P >> ((data &      3) * 8)) & 0xFF) |
            (((P >> ((data & (3<<2)) * 2)) & 0xFF) << 8);
        data >>= 4;

        printf("%08X\n", q);
#endif
      }
}

int main(int argc, char *argv[]) {
  foobar(strtoll(argv[1], 0, 0),
         strtoll(argv[2], 0, 0));
  return 0;
}
