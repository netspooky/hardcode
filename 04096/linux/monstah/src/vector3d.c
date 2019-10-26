REGPARM static void vec_sub(
    const float * restrict a, const float * restrict b, float * restrict r) {
#if 0
  r[0] = a[0] - b[0];
  r[1] = a[1] - b[1];
  r[2] = a[2] - b[2];
#else
#if 1
  for(int i=0; i<3; i++)
    r[i] = a[i] - b[i];
#else
  *r++ = *a++ - *b++;
  *r++ = *a++ - *b++;
  *r++ = *a++ - *b++;
#endif
#endif
}

REGPARM static void vec_add(const float *b, float *r) {
#if 0
  r[0] += b[0];
  r[1] += b[1];
  r[2] += b[2];
#else
#if 1
#if 1
  for(int i=0; i<3; i++)
    r[i] += b[i];
#else
  /* Couldn't make gcc use loop instruction. :( */
  register char i = 3;
  do {
    r[i] += b[i];
  } while(i--);
#endif
#else
  *r++ += *b++;
  *r++ += *b++;
  *r++ += *b++;
#endif
#endif
}

static inline void vec_cross(
    const float * restrict a, const float * restrict b, float * restrict r) {
#if 0
  r[0] = a[1]*b[2] - b[1]*a[2];
  r[1] = a[2]*b[0] - b[2]*a[0];
  r[2] = a[0]*b[1] - b[0]*a[1];
#else
  static unsigned char tab[] = { 2, 0, 1 };
  for(unsigned int i=0; i<3; i++) {
    unsigned int j = tab[i];
    unsigned int k = tab[j];
    r[i] = a[j]*b[k] - b[j]*a[k];
  }
#endif
}

REGPARM static float vec_dot(float * restrict a, float * restrict b) {
#if 0
  return a[0] * b[0] + a[1] * b[1] + a[2] * b[2];
#else
  float res = 0;
  for(int i=0; i<3; i++)
    res += a[i] * b[i];
  return res;
#endif
}

REGPARM static void vec_scale(float * restrict r, float s) {
#if 1
  r[0] = r[0] * s;
  r[1] = r[1] * s;
  r[2] = r[2] * s;
#else
  for(int i=0; i<3; i++)
    r[i] *= s;
#endif
}

static inline void vec_normalize(float * restrict r) {
  vec_scale(r, 1.0f / sqrtf(vec_dot(r, r)));
}

REGPARM static inline void vec_spherical(float a, float b, float *d) {
  /* x = cos a * cos b
   * y = sin b
   * z = sin a * cos b */

#if 1
  /* Seems to be little smaller */
  float ca, sa, cb, sb;

  asm ("fsincos" : "=t"(ca), "=u"(sa) : "0" (a));
  asm ("fsincos" : "=t"(cb), "=u"(sb) : "0" (b));

  d[0] = ca * cb;
  d[1] = sb;
  d[2] = sa * cb;
#else
  d[1] = sin(b);
  float cb = cosf(b);
  d[0] = cos(a) * cb;
  d[2] = sin(a) * cb;
#endif
}

#if 0
static void vec_avg_4(const float *a, const float *b, const float *c,
    const float *d, float *r) {
#if 1
  r[0] = (a[0] + b[0] + c[0] + d[0]) / 4.0;
  r[1] = (a[1] + b[1] + c[1] + d[1]) / 4.0;
  r[2] = (a[2] + b[2] + c[2] + d[2]) / 4.0;
#else
  r[0] = r[1] = r[2] = r[3] = 0;
  vec_add(a, r);
  vec_add(b, r);
  vec_add(c, r);
  vec_add(d, r);
  vec_scale(r, 1 / 4.0f);
#endif
}
#endif
