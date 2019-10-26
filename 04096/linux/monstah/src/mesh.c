#include <stdlib.h>
#include <string.h>

#define MAX_VERTICES 8192

/* Mesh stuff. Mesh is always closed and consists of quads (it's easier to
 * to model with quads than triangles when doing low-poly modelling). This
 * means that
 *   qn >= 6      (box is the simplest and it has 6 quads)
 *   vn = qn + 2
 *
 * Also, maybe
 *   qn = 2 + 4n   =>   vn = 4(n+1)
 */

struct MeshVertex {
  float p[3];
  float n[3];
  int dummy[2];
};

struct MeshQuad {
  unsigned int v[4];
//  float n[3];
};

typedef struct {
  unsigned int qn;
  struct MeshQuad *q;
  unsigned int vn;
  struct MeshVertex *v;
} Mesh;

REGPARM static void Mesh_create(Mesh * restrict m, unsigned int qn) {
  m->qn = qn;
  free(m->q);
  m->q = zalloc(qn * sizeof(struct MeshQuad) / 4);
  m->vn = qn+2;
  free(m->v);
  m->v = zalloc(m->vn * sizeof(struct MeshVertex) / 4);
}

#if 0
REGPARM static void Mesh_destroy(Mesh *m) {
}
#endif

#if 0
REGPARM static inline void Mesh_calculate_normals(Mesh *m) {
#if 0
  unsigned int i, j;

  for(i=0; i < m->vn; i++)
    memset(m->v[i].n, 0, sizeof(float)*3);

  for(i=0; i < m->qn; i++) {
    const struct MeshQuad *q = &m->q[i];
    float v1[3];
    float v2[3];
    float *n = q->n;

    vec_sub(m->v[q->v[0]].p, m->v[q->v[1]].p, v1);
    vec_sub(m->v[q->v[0]].p, m->v[q->v[2]].p, v2);

    vec_cross(v2, v1, n);

    vec_normalize(n);

    for(j=0; j<4; j++) {
      vec_add(n, m->v[q->v[j]].n);
    }
  }

  /* Normalize vertex normals */

  for(i=0; i < m->vn; i++)
    vec_normalize(m->v[i].n);
#endif
}
#endif

REGPARM static void Mesh_render(const Mesh *m) {
#if 1
  glVertexPointer(3, GL_FLOAT, sizeof(struct MeshVertex), m->v[0].p);
  glNormalPointer(GL_FLOAT, sizeof(struct MeshVertex), m->v[0].n);
  glEnableClientState(GL_VERTEX_ARRAY);
  glEnableClientState(GL_NORMAL_ARRAY);
  glDrawElements(GL_QUADS, m->qn*4, GL_UNSIGNED_INT, m->q);
#else
  unsigned int i, j;

  for(i = 0; i < m->qn; i++) {
    glBegin(GL_QUADS);
    for(j=0; j<4; j++) {
#if 1
      const unsigned int *v = m->q[i].v;
      glNormal3fv(m->v[v[j]].n);
      glVertex3fv(m->v[v[j]].p);
#else
      /* Weird that this is larger ~15 bytes */
      const struct MeshVertex *v = &m->v[m->q[i].v[j]];
      glNormal3fv(v->n);
      glVertex3fv(v->p);
#endif
    }
    glEnd();
  }
#endif
}

static int facepoints_n[MAX_VERTICES];

REGPARM static void Mesh_catmull_clark(const Mesh *m,
    Mesh * restrict dest) {
//  int facepoints_n[16384*4] = { 0 };

  /* Point organization in new mesh:
   *   0   .. qn        face points
   *   qn  .. 3qn       edge points
   *   3qn .. 4qn+2     vertex points
   */
  /* TODO: making vertex_point_begin a macro seemed to make code larger but
   * it packed better, check this later */
//  unsigned int vertex_points_begin = m->qn * 3;
#define vertex_points_begin (m->qn*3)

#if 0
  int *facepoints_n = zalloc(16384 * sizeof(int) / 4);
#else
  /* TODO: figure out which is better when intro is done, memset or 'for'
   * ('for' packs better atm) */
#if 1
  __builtin_memset(facepoints_n, 0, sizeof(facepoints_n));
#else
  for(unsigned int i=0; i<MAX_VERTICES; i++)
    facepoints_n[i] = 0;
#endif
#endif

  Mesh_create(dest, m->qn*4);

  struct MeshVertex *dv = &dest->v[0];

  /* Face points (in the center of old polygon) */

  {
  int i = m->qn;
  const struct MeshQuad *q = &m->q[0];
  do {
//  for(int i=0; i<m->qn; i++) {
//  const struct MeshQuad *q = &m->q[i];

//    vec_avg_4(m->v[q->v[0]].p, m->v[q->v[1]].p, m->v[q->v[2]].p,
//        m->v[q->v[3]].p, dv->p);
    for(int j=0; j<4; j++)
      vec_add(m->v[q->v[j]].p, dv->p);
    vec_scale(dv->p, 1 / 4.0f);

    /* Prepare vertex points: add new face points to new vertex points */
    for(int j=0; j<4; j++) {
      vec_add(dv->p, dest->v[vertex_points_begin + q->v[j]].p);
      facepoints_n[q->v[j]]++;
    }

    dv++;
    q++;
  } while(--i);
  }

  /* Edge points (average of old edge points and new face points) */

  int *edgepoints = (int *) zalloc(m->vn * m->vn * sizeof(int) / 4);
#if 0
  memset(edgepoints, -1, m->vn*m->vn*sizeof(int));
#else
//  for(int i=0; i < m->vn * m->vn; i++)
//    edgepoints[i]--;
#endif

  {
  int i = m->qn;
  const struct MeshQuad *q = &m->q[0];
  do {
//  for(int i=0; i<m->qn; i++) {
    for(int j=0; j<4; j++) {

      unsigned int e1 = q->v[j];
      unsigned int e2 = q->v[(j+1)&3];

      /* check if it isn't created already */
      if(edgepoints[e1 * m->vn + e2] > 0)
        continue;

      {
        int a = (dv - dest->v) + 1;
        edgepoints[e1 * m->vn + e2] = a;
        edgepoints[e2 * m->vn + e1] = a;
      }

      /* Add edge's vertices to edge point */
      vec_add(m->v[e1].p, dv->p);
      vec_add(m->v[e2].p, dv->p);

      /* Prepare vertex points: add old edge points to new vertex points */
      vec_add(dv->p, dest->v[vertex_points_begin + e1].p);
      vec_add(dv->p, dest->v[vertex_points_begin + e2].p);

      /* Add edge points to vertex points */
      vec_add(dest->v[m->qn - i].p, dv->p);

      /* Search other polygon connected to the edge and add face point */
      int k = m->qn;
      const struct MeshQuad *q = &m->q[0];

      do {
//      for(int k=0; k<m->qn; k++) {
        if(k == i)
//          continue;
          goto lop;

        int v1 = 3;

        for(int l=0; l<4; l++) {
          if(q->v[v1] == e2 && q->v[l] == e1) {
            vec_add(dest->v[m->qn - k].p, dv->p);
            break;
          }

          v1 = l;
        }

lop:;
        q++;
      } while(--k);

      vec_scale(dv->p, 1 / 4.0);

      dv++;
    }
    q++;
  } while(--i);
  }

  /* Finish vertex points */

  {
  int i = m->vn;
  do {
//  for(int i=0; i < m->vn; i++) {
    int n = facepoints_n[m->vn - i] - 3;
    float invm = 1.0 / facepoints_n[m->vn - i];

    for(int j=0; j<3; j++)
      dv->p[j] = (dv->p[j] * invm + m->v[m->vn - i].p[j] * n) * invm;

    dv++;
  } while(--i);
  }

  /* Create polygons */

  struct MeshQuad *dq = dest->q;

  {
  int i = m->qn;
  const struct MeshQuad *q = m->q;

  do {
//  for(int i=0; i < m->qn; i++) {
    for(int j=0; j < 4; j++) {
      unsigned int e1 = q->v[j];

      /* vertex point */
      dq->v[0] = vertex_points_begin + e1;
      /* edge point that is next to vertex point */
      dq->v[1] = edgepoints[e1 * m->vn + q->v[(j+1)&3]] - 1;
      /* edge point that is previous to vertex point */
      dq->v[3] = edgepoints[e1 * m->vn + q->v[(j+3)&3]] - 1;
      /* face point */
      dq->v[2] = m->qn - i;

      /* Calculate quad and vertex normals */
      {
        float v[2][3];

        vec_sub(dest->v[dq->v[0]].p, dest->v[dq->v[1]].p, v[0]);
        vec_sub(dest->v[dq->v[0]].p, dest->v[dq->v[2]].p, v[1]);

        float n[3];

        vec_cross(v[0], v[1], n);
//        vec_normalize(n);

        for(int k=0; k<4; k++)
          vec_add(n, dest->v[dq->v[k]].n);
      }

      dq++;
    }

    q++;
  } while(--i);
  }

  /* Normalize vertex normals */

  /* OpenGL does this (GL_NORMALIZE) */
#if 0
  for(i=0; i < dest->vn; i++)
    vec_normalize(dest->v[i].n);
#endif

  /* Clean up */

//  free(facepoints_n);
  free(edgepoints);
}

/* Vertices of a quad are packed to one integer to simplify generated
 * assembler code so let's not use more than 256 vertices (~64 extrudes) when
 * modelling. :-) */

/* TODO: it might actually be smaller to just use 4 dwords for a quad */

#define PACK(a, b, c, d) (((a) << 24) | ((b) << 16) | ((c) << 8) | (d))

unsigned int g_stack[16];

REGPARM static unsigned int *add_packed_quad(unsigned int *v, unsigned int q) {
#if 0
  for(int i=0; i<4; i++) {
    *v++ = q & 255;
    q >>= 8;
  }
#else
  *v++ = q & 255;
  q >>= 8;
  *v++ = q & 255;
  q >>= 8;
  *v++ = q & 255;
  q >>= 8;
  *v++ = q;
#endif

  return v;
}

static const char *Mesh_gen(Mesh * restrict dest,
    const unsigned char * restrict s, float time) {
  Mesh_create(dest, 256);

#if 0
  float *p = dest->v[0].p;
  for(unsigned int i=0; i<4; i++) {
    *p++ = (i & 1) * 2 - 1;
    p++;
    *p++ = (i & 2) - 1;
    p += 3;
  }
#else
#if 0
  float *p = dest->v[0].p;
  *p++ = -1;
  p++;
  *p++ = -1;
  p += 3;
  *p++ = 1;
  p++;
  *p++ = -1;
  p += 3;
  *p++ = -1;
  p++;
  *p++ = 1;
  p += 3;
  *p++ = 1;
  p++;
  *p = 1;
#else
  dest->v[0].p[0] = -1;
  dest->v[0].p[2] = -1;
  dest->v[1].p[2] = -1;
  dest->v[2].p[0] = -1;
  dest->v[1].p[0] =  1;
  dest->v[2].p[2] =  1;
  dest->v[3].p[0] =  1;
  dest->v[3].p[2] =  1;
#endif
#endif

  dest->vn = 4;

  /* Processed quads */
  unsigned int *qp =
    add_packed_quad((unsigned int *) dest->q, PACK(0, 2, 3, 1));

  /* Stack ptr */
  unsigned int *sp = g_stack;

  *sp++ = PACK(0, 1, 3, 2);

  do {
    unsigned int c = *s++;

    /* Extrude */

    /* P is the quad to be extruded */
    unsigned int P = *--sp;

    int b = (c & 7) - 3;
    c >>= 3;
    int a = c & 7;
    c >>= 3;

    /* This isn't even close what I wanted but that would have cost much
     * more in size
     *
     *   p' = normalize(p - center + dirvec * scale) * amount + center
     */

    float scale = 2.0f / c;

    c = *s++;
    float amount = c >> 6;

    /* Animation */

    int to_a = a, to_b = b;

    if(c & (1 << 5)) {
      unsigned int c = *s++;
      to_b = (c & 7) - 3;
      to_a = c >> 3;
    }

    float dirvec[3];
    vec_spherical(lerp(a, to_a, time) * (2 * M_PI / 8.0f),
                  lerp(b, to_b, time) * (M_PI / 8.0f),
                  dirvec);
    vec_scale(dirvec, scale);

    {
      /* Calculate center */

      float center[3] = { 0, 0, 0 };
      unsigned int src = P;

      for(unsigned int i=0; i<4; i++) {
        vec_add(dest->v[src&255].p, center);
        src >>= 8;
      }
      vec_scale(center, 1 / 4.0f);

      /* Do the thing */

      src = P;

      for(unsigned int i=0; i<4; i++) {
        float *p = dest->v[dest->vn+3-i].p;

        vec_sub(dest->v[src&255].p, center, p);
        vec_add(dirvec, p);
        vec_normalize(p);
        vec_scale(p, amount);
        vec_add(center, p);

        src >>= 8;
      }
    }

#if 0
    vec_scale(v, -c - 1);

    {
      unsigned int src = P;

      for(unsigned int i=0; i<4; i++) {
        vec_sub(dest->v[src&255].p, v, dest->v[dest->vn+3-i].p);
        src >>= 8;
      }
    }
#endif

    /* New quad */
    unsigned int N = dest->vn * 0x01010101 + 0x00010203;
    dest->vn += 4;

    /* Branches */

    {
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

      /* NOTE: first quad is the new quad, other quads are the quads around
       * it (compination of old and new) */
      unsigned int q = N;

      for(unsigned int i=0; i<5; i++) {
        if(c & 1)
          *sp++ = q;
        else
          qp = add_packed_quad(qp, q);
        c >>= 1;

#if 0
        q =
          (((P >> ((data & (3<<0))*8)) & 0xFF)     ) |
          (((P >> ((data & (3<<2))*2)) & 0xFF) << 8) |
          (((N >> ((data & (3<<4))/2)) & 0xFF) << 16) |
          (((N >> ((data & (3<<6))/8))       ) << 24);
        data >>= 8;
#else
        /* gzip is better packing this version */

        q = ( (N >> ((data &      3) * 8)) & 0xFF) |
            (((N >> ((data & (3<<2)) * 2))) << 8);
        data >>= 4;

        q = (q << 16) |
            ( (P >> ((data &      3) * 8)) & 0xFF) |
            (((P >> ((data & (3<<2)) * 2)) & 0xFF) << 8);
        data >>= 4;
#endif
      }
    }
  } while(sp > g_stack);

  dest->qn = dest->vn - 2;

#if 0
  unsigned int *v = &dest->q[0].v[0];

  for(unsigned int *p = g_quads; p < qp; p++) {
    unsigned int q = *p;

#if 1
    *v++ = q & 255;
    q >>= 8;
    *v++ = q & 255;
    q >>= 8;
    *v++ = q & 255;
    q >>= 8;
    *v++ = q;
#else
    *v++ = q & 255;
    *v++ = (q >> 8) & 255;
    *v++ = (q >> 16) & 255;
    *v++ = q >> 24;
#endif
  }
#endif

#if 0
  fprintf(stderr, "Mesh generated vn=%d, qn=%d\n", dest->vn, dest->qn);
  for(unsigned int i=0; i<dest->vn; i++)
    fprintf(stderr, "  v %3d: %.2f %.2f %.2f\n", i,
        dest->v[i].p[0], dest->v[i].p[1], dest->v[i].p[2]);
  for(unsigned int i=0; i<dest->qn; i++)
    fprintf(stderr, "  q %3d: %3d %3d %3d %3d\n", i,
        dest->q[i].v[0], dest->q[i].v[1], dest->q[i].v[2], dest->q[i].v[3]);
#endif

  return s;
}

#undef PACK
