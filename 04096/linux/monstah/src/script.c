enum {
  S_BEGIN,
  S_END,
  S_SCENE,
  S_NEXT_SCENE,
  S_SCENE_END,
  S_TEXT,
  S_FOG,
  S_MESHGEN,
  S_CATMULL_CLARK,
  S_M_PUSH,
  S_M_POP,
  S_LIGHT,
  S_CLEAR,
  S_MATRIX_MODE,
  S_PERSP,
  S_LOOKAT,
  S_ENABLE,
  S_DISABLE,
  S_NUM_SMALL,
  S_NUM_SMALL_2,
  S_COLOR,
  S_SCALE,
//  S_ROTATE,
  S_TRANSLATE,
/*  S_TORUS, */
  S_MESH,
  S_NUM_3B,
  S_TIME,
  S_MUL,
  S_KEYFRAME,
  S_LAST,
};

typedef int some_assert[(S_LAST<32)*2-1];

#define S_ARG(a) ((a) << 5)
#define S_ARG_2(a) (a) & 255, (a) >> 8

/* Extrude, see intro.h and Mesh_gen() */
#define S_EXTR(a, b, s) ((s << 6) | (b << 3) | (a))
#define S_BRANCH(a, b, c, d, e) (a) | ((b)<<1) | ((c)<<2) | ((d)<<3) | ((e)<<4)
#define S_AMOUNT(a) (a << 6)
#define S_ANIM (1 << 5)

static Mesh meshes[256];

#if 0
static char box_quads[6][4] = {
 { 0,1,3,2 }, { 5,4,6,7 }, { 1,5,7,3 },
 { 4,0,2,6 }, { 2,3,7,6 }, { 0,4,5,1 } };
#endif

static const unsigned char intro_script[];

static float script_stack[1024];

#define TICKS() (SDL_GetTicks()*1+0*1000)

AINLINE NORETURN static inline void script_run() {
  int last = 0, scene = 0;
  const unsigned char *s;
  const unsigned char *last_ptr;
  float *sp;

  s = intro_script;
  sp = script_stack;

  glLineWidth(5.0);
#if 0
  glBlendFunc(GL_ONE, GL_ONE);
#endif

  while(1) { // && music_not_playing != 0) {
    int c = *s++;
#ifdef DEBUG
    int cmd_num = c & 31;
#endif

    ASSERT(sp >= script_stack && sp < script_stack+1024);

#if 0
#error this isn't anymore valid, it doesn't do c >>= 5
#define CASE(ca) case ca: ASSERT(cmd_num == ca);
#define BREAK break;
    switch(c & 31) {
    CASE(S_BEGIN)
#else
    {
    int casevar = c & 31;
    c >>= 5;
#define CASE(ca) if(!--casevar) { ASSERT(cmd_num == ca);
#define BREAK } else
    if(!casevar) {
#endif
      last_ptr = s-1;
      last = 128;
    BREAK

    CASE(S_END)
//      SDL_Delay(1);
      SDL_GL_SwapBuffers();
      s = last_ptr;
    BREAK

    CASE(S_SCENE)
      {
        int min = *s++;
        int max = *s++;

        if(scene < min || scene > max)
          do
            s++;
          while(*s != (S_SCENE_END | S_ARG(7)));
      }
    BREAK

    CASE(S_NEXT_SCENE)
      if(TICKS() > *s++ * (1000 * 180 / 255))
      {
        scene++;
//        printf("%d\n", scene);
      }
    BREAK

    CASE(S_SCENE_END)
    BREAK

    CASE(S_TEXT)
      do
#ifdef DEBUG
        glutStrokeCharacter(GLUT_STROKE_ROMAN, *s);
#else
        glutStrokeCharacter(glutStrokeRoman, *s);
#endif
      /* Ending zero is drawn also but that doesn't matter, I hope. :-) */
      while(*s++);
//      s++;
    BREAK

    CASE(S_FOG)
      sp -= 4;
      glFogfv(* (unsigned short *) s, sp);
      s += 2;
    BREAK

    CASE(S_MESHGEN)
      sp -= 3;
      s = Mesh_gen(&meshes[last++], s, sp[2]); /* TODO sp[2] -> sp[0] */
    BREAK

    CASE(S_CATMULL_CLARK)
      Mesh_catmull_clark(&meshes[last-1], &meshes[last]);
      last++;
    BREAK

    CASE(S_M_PUSH)
      glPushMatrix();
    BREAK

    CASE(S_M_POP)
      glPopMatrix();
    BREAK

    CASE(S_LIGHT)
      sp -= 4;
      glLightfv(GL_LIGHT0, GL_POSITION, sp);
//      float col[4] = { 1.0f, 1.0f, 1.0f, 1.0f };
//      glLightfv(GL_LIGHT0, GL_DIFFUSE, col);
    BREAK

    CASE(S_CLEAR)
      sp -= 4;
      glClearColor(sp[0], sp[1], sp[2], sp[3]);
      glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    BREAK

    CASE(S_MATRIX_MODE)
      glMatrixMode(* (unsigned short *) s);
      s += 2;
      glLoadIdentity();
    BREAK

#if 0
    CASE(S_PROJ)
      glMatrixMode(GL_PROJECTION);
      goto identity;

    CASE(S_MODEL)
      glMatrixMode(GL_MODELVIEW);
identity:
      glLoadIdentity();
    BREAK
#endif

    CASE(S_PERSP)
#if 0
      sp -= 4;
      gluPerspective(sp[0], sp[1], sp[2], sp[3]);
#else
      gluPerspective(70.0, 1.25, 1.0 / 8.0, 256.0);
#endif
    BREAK

    CASE(S_LOOKAT)
      sp -= 6;
      gluLookAt(sp[0], sp[1], sp[2],   sp[3], sp[4], sp[5],   0, 1, 0);
    BREAK

    CASE(S_ENABLE)
      glEnable(* (unsigned short *) s);
      s += 2;
    BREAK

    CASE(S_DISABLE)
      glDisable(* (unsigned short *) s);
      s += 2;
    BREAK

    CASE(S_NUM_SMALL)
      *sp++ = c / 7.0f;
    BREAK

    CASE(S_NUM_SMALL_2)
      *sp++ = c;
    BREAK

    CASE(S_COLOR)
      sp -= 3;
      glColor3fv(sp);
    BREAK

    CASE(S_SCALE)
      {
        float scale = *--sp;
        glScalef(scale, scale, scale);
      }
    BREAK

#if 0
    CASE(S_ROTATE)
      sp -= 4;
      glRotatef(sp[0], sp[1], sp[2], sp[3]);
    BREAK
#endif

    CASE(S_TRANSLATE)
      sp -= 3;
      glTranslatef(sp[0], sp[1], sp[2]);
    BREAK

#if 0
    CASE(S_TORUS)
      {
        float r2 = *--sp;
        float r1 = *--sp;

        glutSolidTorus(r1, r2, 16, 32);
      }
    BREAK
#endif

    CASE(S_MESH)
      Mesh_render(&meshes[*s++]);
    BREAK

    CASE(S_NUM_3B)
      {
        float a = c / 64.0f;
        *sp++ = *s++ * a;
        *sp++ = *s++ * a;
        *sp++ = *s++ * a;
      }
    BREAK

    CASE(S_TIME)
      *sp++ = (TICKS() - *s++ * (1000 * 180 / 255)) / 1000.0f;
    BREAK

    CASE(S_MUL)
      sp--;
      *(sp-1) *= *sp;
    BREAK

      /* Ok, this reverses order? (x,y,z) -> (z,y,x). I'm NOT fixing it,
       * deadline is tomorrow. :-) */
    CASE(S_KEYFRAME)
      {
        int keys = c;
        float t = fmodf(*--sp, (float) keys);
        float v[3];

        sp -= 3;
        int i = keys;
        do {
        //for(unsigned int i=0; i<keys; i++) {
          sp -= 3;

          if(t >= 0.0f && t <= 1.0f) {
#if 0
            v[0] = lerp(sp[3], sp[0], t);
            v[1] = lerp(sp[4], sp[1], t);
            v[2] = lerp(sp[5], sp[2], t);
#else
            for(int i=0; i<3; i++)
              v[i] = lerp(sp[3+i], sp[i], t);
#endif
          }

          t -= 1.0f;
        } while(--i);

#if 1
        *sp++ = v[2];
        *sp++ = v[1];
        *sp++ = v[0];
#else
        sp[0] = v[2];
        sp[1] = v[1];
        sp[2] = v[0];
        sp += 3;
#endif
      }
    BREAK
      ;
    }

    {
      SDL_Event ev;
      if(SDL_PollEvent(&ev))
      {
        if(ev.type == SDL_KEYDOWN || ev.type == SDL_QUIT) {
#ifdef DEBUG
          exit(0);
#else
          /* This crashes the program */
          __asm__ __volatile__ ("cli");
#endif
        }
      }
    }
    __asm__ ("nop\n");
  }
}
