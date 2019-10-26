/* TODO: check if inlining is worth it when intro is more ready */
/** zalloc allocates and zeroes memory and also multiplies the amount by 4 */
STDCALL REGPARM ALLOC static inline void *zalloc(unsigned int n) {
  return calloc(n, 4);
}
