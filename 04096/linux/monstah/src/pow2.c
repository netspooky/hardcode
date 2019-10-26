AINLINE static inline float pow2(float x) {
  int j;
  float b = 1;
  float res = 1;

  for(j=1; j<12; j++) {
    b *= logf(2) * x / j;
    res += b;
  }

  return res;
}
