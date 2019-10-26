static const unsigned char intro_script[] = {
S_ENABLE, S_ARG_2(GL_COLOR_MATERIAL),
S_ENABLE, S_ARG_2(GL_LIGHT0),
S_ENABLE, S_ARG_2(GL_DEPTH_TEST),
S_ENABLE, S_ARG_2(GL_NORMALIZE),

#define S S_NEXT_SCENE, 0,
#undef S

/* Generate non-realtime meshes */

#define PLANT 3
#if 0
S_NUM_3B | S_ARG(1),  64,  64,  64,
S_MESHGEN,
  S_EXTR(7, 2, 1),       S_AMOUNT(1) | S_BRANCH(1, 0, 0, 0, 0),
  S_EXTR(7, 2, 1),       S_AMOUNT(1) | S_BRANCH(1, 0, 0, 0, 0),
  S_EXTR(7, 2, 3),       S_AMOUNT(1) | S_BRANCH(1, 0, 0, 0, 0),
  S_EXTR(7, 2, 3),       S_AMOUNT(1) | S_BRANCH(0, 1, 1, 1, 1),
    S_EXTR(2, 3, 1),     S_AMOUNT(1) | S_BRANCH(1, 0, 0, 0, 0),
      S_EXTR(2, 3, 3),   S_AMOUNT(2) | S_BRANCH(0, 0, 0, 0, 0),
    S_EXTR(4, 5, 3),     S_AMOUNT(1) | S_BRANCH(1, 0, 0, 0, 0),
      S_EXTR(7, 5, 3),   S_AMOUNT(2) | S_BRANCH(0, 0, 0, 0, 0),
    S_EXTR(5, 0, 1),     S_AMOUNT(2) | S_BRANCH(1, 0, 0, 0, 0),
      S_EXTR(3, 0, 1),   S_AMOUNT(3) | S_BRANCH(0, 0, 0, 0, 0),
    S_EXTR(4, 2, 3),     S_AMOUNT(2) | S_BRANCH(1, 0, 0, 0, 0),
      S_EXTR(2, 2, 2),   S_AMOUNT(2) | S_BRANCH(0, 0, 0, 0, 0),
S_CATMULL_CLARK,
S_CATMULL_CLARK,
S_CATMULL_CLARK,
#endif

#if 1
#define PLANT_2 PLANT
S_NUM_3B | S_ARG(1),  64,  64,  128,
S_MESHGEN,
  S_EXTR(7, 2, 1),       S_AMOUNT(1) | S_BRANCH(1, 0, 0, 0, 0),
  S_EXTR(7, 2, 1),       S_AMOUNT(1) | S_BRANCH(1, 0, 0, 0, 0),
  S_EXTR(7, 2, 1),       S_AMOUNT(1) | S_BRANCH(1, 0, 0, 0, 0),
  S_EXTR(7, 2, 1),       S_AMOUNT(1) | S_BRANCH(1, 0, 0, 0, 0),
  S_EXTR(7, 2, 3),       S_AMOUNT(1) | S_BRANCH(0, 1, 1, 1, 1),
    S_EXTR(5, 3, 3),     S_AMOUNT(1) | S_BRANCH(1, 0, 0, 0, 0),
      S_EXTR(5, 3, 1),   S_AMOUNT(2) | S_BRANCH(0, 0, 0, 0, 0),
    S_EXTR(5, 5, 3),     S_AMOUNT(1) | S_BRANCH(1, 0, 0, 0, 0),
      S_EXTR(7, 5, 1),   S_AMOUNT(2) | S_BRANCH(0, 0, 0, 0, 0),
    S_EXTR(6, 7, 3),     S_AMOUNT(2) | S_BRANCH(1, 0, 0, 0, 0),
      S_EXTR(6, 7, 1),   S_AMOUNT(3) | S_BRANCH(0, 0, 0, 0, 0),
    S_EXTR(4, 1, 3),     S_AMOUNT(2) | S_BRANCH(1, 0, 0, 0, 0),
      S_EXTR(2, 1, 1),   S_AMOUNT(2) | S_BRANCH(0, 0, 0, 0, 0),
S_CATMULL_CLARK,
S_CATMULL_CLARK,
S_CATMULL_CLARK,
#else
#define PLANT_2 PLANT
#endif

#define LAND PLANT_2+4
S_NUM_3B | S_ARG(1),  64,  64,  64,
S_MESHGEN,
  S_EXTR(7, 0, 3),       S_AMOUNT(3) | S_BRANCH(0, 1, 1, 1, 1),
    S_EXTR(3, 3, 1),   S_AMOUNT(3) | S_BRANCH(1, 0, 0, 0, 0),
      S_EXTR(4, 3, 1),   S_AMOUNT(3) | S_BRANCH(0, 0, 0, 0, 0),
    S_EXTR(4, 6, 1),   S_AMOUNT(3) | S_BRANCH(0, 0, 0, 0, 0),
    S_EXTR(3, 0, 1),   S_AMOUNT(3) | S_BRANCH(0, 0, 0, 0, 0),
    S_EXTR(2, 2, 1),   S_AMOUNT(3) | S_BRANCH(0, 0, 0, 1, 0),
      S_EXTR(7, 0, 1),   S_AMOUNT(1) | S_BRANCH(1, 0, 0, 0, 0),
      S_EXTR(6, 2, 1),   S_AMOUNT(1) | S_BRANCH(0, 0, 0, 0, 0),
S_CATMULL_CLARK,
S_CATMULL_CLARK,
S_CATMULL_CLARK,


S_BEGIN, /* Frame begins */

/* Real-time meshes begin from 128 */

/* Some guy, angles broken */
#define SOME_GUY 127+0
#if 0
/* Some guy removed, it was too broken and useless */
#endif

#define BIRDIE SOME_GUY + 3
S_NUM_3B | S_ARG(1),  64,  64,  64,
S_NUM_3B | S_ARG(1),   0,  64,  64,
S_NUM_3B | S_ARG(1),  64,  64,  64,

S_SCENE, 0, 3,
S_TIME, 0,
S_SCENE_END | S_ARG(7),

S_SCENE, 4, 4,
S_NUM_SMALL | S_ARG(0),
S_SCENE_END | S_ARG(7),

S_SCENE, 5, 255,
S_TIME, 0,
S_SCENE_END | S_ARG(7),

  S_NUM_SMALL_2 | S_ARG(6),
  S_MUL,
S_KEYFRAME | S_ARG(2),

S_MESHGEN,
  S_EXTR(7, 0, 2),       S_AMOUNT(3) | S_BRANCH(1, 1, 1, 1, 1),
  /* Head */
    S_EXTR(5, 4, 1),   S_AMOUNT(3) | S_BRANCH(1, 0, 0, 0, 0),
    S_EXTR(7, 4, 2),   S_AMOUNT(3) | S_BRANCH(0, 1, 0, 0, 0),
    S_EXTR(4, 4, 2),   S_AMOUNT(2) | S_BRANCH(1, 0, 0, 0, 0),
    S_EXTR(3, 4, 1),   S_AMOUNT(1) | S_BRANCH(1, 0, 0, 0, 0),
    S_EXTR(3, 4, 1),   S_AMOUNT(1) | S_BRANCH(0, 0, 0, 0, 0),
  /* Wing */
    S_EXTR(5, 6, 1),     S_AMOUNT(2) | S_BRANCH(1, 0, 0, 0, 0),
    S_EXTR(1, 6, 1),     S_AMOUNT(2) | S_BRANCH(0, 0, 0, 0, 0) | S_ANIM,
                         S_EXTR(5, 6, 0),
  /* Tail */
    S_EXTR(6, 0, 1),     S_AMOUNT(1) | S_BRANCH(1, 0, 0, 0, 0),
      S_EXTR(4, 0, 2),   S_AMOUNT(3) | S_BRANCH(0, 0, 0, 0, 0) | S_ANIM,
                         S_EXTR(3, 0, 0),
  /* Other wing */
    S_EXTR(5, 2, 1),     S_AMOUNT(2) | S_BRANCH(1, 0, 0, 0, 0),
    S_EXTR(1, 2, 1),     S_AMOUNT(2) | S_BRANCH(0, 0, 0, 0, 0) | S_ANIM,
                         S_EXTR(5, 2, 0),
  /* Upper body */
    S_EXTR(7, 0, 3),       S_AMOUNT(1) | S_BRANCH(0, 0, 0, 0, 0),
S_CATMULL_CLARK,
S_CATMULL_CLARK, /* 10 */

/* Goat */

#define GOAT BIRDIE+3
S_NUM_3B | S_ARG(1),  64,  64,  64,
S_NUM_3B | S_ARG(1),   0,  64,  64,
S_NUM_3B | S_ARG(1),  64,  64,  64,

S_TIME, 0,
  S_NUM_SMALL_2 | S_ARG(2),
  S_MUL,
S_KEYFRAME | S_ARG(2),

S_MESHGEN,
  S_EXTR(7, 0, 1),     S_AMOUNT(3) | S_BRANCH(0, 1, 1, 1, 1),
    /* Body */
    S_EXTR(3, 4, 1),   S_AMOUNT(3) | S_BRANCH(1, 1, 0, 0, 0),
      /* Fatten body (THIS LOOKS ACTUALLY QUITE STUPID) */
      S_EXTR(0, 0, 3), S_AMOUNT(1) | S_BRANCH(0, 0, 0, 0, 0),
      /* Forelegs begin in body */
      S_EXTR(3, 4, 1),   S_AMOUNT(2) | S_BRANCH(0, 0, 1, 0, 1),
      /* Hind leg */
      S_EXTR(3, 6, 1),     S_AMOUNT(1) | S_BRANCH(0, 0, 1, 0, 0),
        S_EXTR(0, 6, 1),   S_AMOUNT(2) | S_BRANCH(1, 0, 0, 0, 0) | S_ANIM,
                           S_EXTR(0, 4, 0),
        S_EXTR(0, 6, 2),   S_AMOUNT(1) | S_BRANCH(0, 0, 0, 0, 0) | S_ANIM,
                           S_EXTR(0, 4, 0),
      /* Other hind leg */
      S_EXTR(2, 2, 1),     S_AMOUNT(1) | S_BRANCH(0, 0, 0, 0, 1),
        S_EXTR(0, 4, 1),   S_AMOUNT(2) | S_BRANCH(1, 0, 0, 0, 0) | S_ANIM,
                           S_EXTR(0, 1, 0),
        S_EXTR(0, 4, 2),   S_AMOUNT(1) | S_BRANCH(0, 0, 0, 0, 0) | S_ANIM,
                           S_EXTR(0, 1, 0),
    /* Fore leg */
    S_EXTR(3, 6, 1),     S_AMOUNT(1) | S_BRANCH(0, 1, 0, 0, 0),
      S_EXTR(0, 7, 1),   S_AMOUNT(2) | S_BRANCH(1, 0, 0, 0, 0) | S_ANIM,
                         S_EXTR(0, 4, 0),
      S_EXTR(0, 7, 2),   S_AMOUNT(1) | S_BRANCH(0, 0, 0, 0, 0) | S_ANIM,
                         S_EXTR(0, 4, 0),
    /* Head */
    S_EXTR(4, 0, 1),   S_AMOUNT(1) | S_BRANCH(1, 0, 0, 0, 0) | S_ANIM,
                       S_EXTR(6, 0, 0),
      S_EXTR(6, 0, 2),   S_AMOUNT(3) | S_BRANCH(0, 1, 1, 0, 1),
    /* Horns */
      S_EXTR(5, 2, 1),     S_AMOUNT(1) | S_BRANCH(1, 0, 0, 0, 0),
        S_EXTR(5, 3, 1),     S_AMOUNT(2) | S_BRANCH(1, 0, 0, 0, 0),
        S_EXTR(6, 4, 1),     S_AMOUNT(1) | S_BRANCH(1, 0, 0, 0, 0),
        S_EXTR(6, 5, 1),     S_AMOUNT(1) | S_BRANCH(0, 0, 0, 0, 0),
      S_EXTR(5, 6, 1),     S_AMOUNT(1) | S_BRANCH(1, 0, 0, 0, 0),
        S_EXTR(5, 5, 1),     S_AMOUNT(2) | S_BRANCH(1, 0, 0, 0, 0),
        S_EXTR(6, 4, 1),     S_AMOUNT(1) | S_BRANCH(1, 0, 0, 0, 0),
        S_EXTR(6, 3, 1),     S_AMOUNT(1) | S_BRANCH(0, 0, 0, 0, 0),
      S_EXTR(4, 0, 2),   S_AMOUNT(2) | S_BRANCH(1, 0, 0, 0, 0),
      S_EXTR(4, 0, 2),   S_AMOUNT(2) | S_BRANCH(1, 0, 0, 0, 0),
      S_EXTR(4, 0, 1),   S_AMOUNT(1) | S_BRANCH(0, 0, 0, 0, 0),
    /* Other fore leg */
    S_EXTR(3, 2, 1),     S_AMOUNT(1) | S_BRANCH(0, 1, 0, 0, 0),
      S_EXTR(0, 4, 1),   S_AMOUNT(2) | S_BRANCH(1, 0, 0, 0, 0) | S_ANIM,
                         S_EXTR(0, 1, 0),
      S_EXTR(0, 4, 2),   S_AMOUNT(1) | S_BRANCH(0, 0, 0, 0, 0) | S_ANIM,
                         S_EXTR(0, 1, 0),
S_CATMULL_CLARK,
S_CATMULL_CLARK,

#define MONSTAH GOAT+3
S_NUM_3B | S_ARG(1),  64,  64,  64,
S_NUM_3B | S_ARG(1),   0,  64,  64,
S_NUM_3B | S_ARG(1),  64,  64,  64,

S_TIME, 0,
  S_NUM_SMALL_2 | S_ARG(2),
    S_NUM_SMALL_2 | S_ARG(1),
    S_MUL,
  S_MUL,
S_KEYFRAME | S_ARG(2),

S_MESHGEN,
  S_EXTR(7, 0, 3),     S_AMOUNT(3) | S_BRANCH(1, 1, 1, 1, 1),
  /* Legs */
    S_EXTR(2, 4, 1),     S_AMOUNT(2) | S_BRANCH(1, 0, 0, 0, 0),
      S_EXTR(2, 4, 1),   S_AMOUNT(2) | S_BRANCH(0, 0, 0, 0, 0) | S_ANIM,
                         S_EXTR(5, 4, 0),
    S_EXTR(2, 6, 1),     S_AMOUNT(2) | S_BRANCH(1, 0, 0, 0, 0),
      S_EXTR(2, 7, 1),   S_AMOUNT(2) | S_BRANCH(0, 0, 0, 0, 0) | S_ANIM,
                         S_EXTR(2, 5, 0),
    S_EXTR(2, 0, 1),     S_AMOUNT(2) | S_BRANCH(1, 0, 0, 0, 0),
      S_EXTR(5, 0, 1),   S_AMOUNT(2) | S_BRANCH(0, 0, 0, 0, 0) | S_ANIM,
                         S_EXTR(2, 0, 0),
    S_EXTR(2, 2, 1),     S_AMOUNT(2) | S_BRANCH(1, 0, 0, 0, 0),
      S_EXTR(2, 1, 1),   S_AMOUNT(2) | S_BRANCH(0, 0, 0, 0, 0) | S_ANIM,
                         S_EXTR(2, 3, 0),
  /* Body / head */
  S_EXTR(7, 0, 3),     S_AMOUNT(3) | S_BRANCH(1, 0, 0, 0, 0) | S_ANIM,
    S_EXTR(4, 0, 0),
    S_EXTR(6, 0, 3),     S_AMOUNT(3) | S_BRANCH(1, 0, 1, 0, 0),
      S_EXTR(3, 0, 3),     S_AMOUNT(2) | S_BRANCH(0, 0, 0, 0, 0) | S_ANIM,
          S_EXTR(1, 0, 0),
    S_EXTR(7, 0, 1),     S_AMOUNT(3) | S_BRANCH(1, 0, 1, 0, 0) | S_ANIM,
          S_EXTR(6, 0, 0),
    /* Mouth */
    S_EXTR(3, 4, 1),     S_AMOUNT(3) | S_BRANCH(0, 0, 0, 0, 0),
//    S_EXTR(3, 0, 1),     S_AMOUNT(1) | S_BRANCH(1, 0, 0, 0, 0),
//    S_EXTR(2, 0, 2),     S_AMOUNT(2) | S_BRANCH(0, 0, 0, 0, 0) | S_ANIM,
//    S_EXTR(4, 0, 0),
    /* More body / head */
    S_EXTR(7, 4, 3),     S_AMOUNT(3) | S_BRANCH(1, 0, 1, 0, 0),
      S_EXTR(3, 0, 3),     S_AMOUNT(2) | S_BRANCH(0, 0, 0, 0, 0) | S_ANIM,
          S_EXTR(4, 0, 0),
    S_EXTR(7, 0, 1),     S_AMOUNT(2) | S_BRANCH(0, 0, 0, 0, 0),
S_CATMULL_CLARK,
S_CATMULL_CLARK,


#define BLOOD MONSTAH+3
S_NUM_3B | S_ARG(1),  64,  64,  64,
S_NUM_3B | S_ARG(1),   0,  64,  64,
S_NUM_3B | S_ARG(1),  64,  64,  64,

S_TIME, 0,
  S_NUM_SMALL_2 | S_ARG(7),
  S_MUL,
S_KEYFRAME | S_ARG(2),

S_MESHGEN,
  S_EXTR(7, 0, 2),     S_AMOUNT(3) | S_BRANCH(0, 1, 1, 1, 1),
    S_EXTR(3, 4, 1),    S_AMOUNT(3) | S_BRANCH(0, 0, 0, 0, 0) | S_ANIM,
          S_EXTR(6, 4, 0),
    S_EXTR(3, 6, 1),    S_AMOUNT(3) | S_BRANCH(0, 0, 0, 0, 0) | S_ANIM,
          S_EXTR(6, 6, 0),
    S_EXTR(3, 0, 3),    S_AMOUNT(3) | S_BRANCH(0, 0, 0, 0, 0) | S_ANIM,
          S_EXTR(6, 0, 0),
    S_EXTR(3, 2, 1),    S_AMOUNT(3) | S_BRANCH(0, 0, 0, 0, 0) | S_ANIM,
          S_EXTR(6, 2, 0),
S_CATMULL_CLARK,
S_CATMULL_CLARK,


#if 0
/*** MODELLING ***/

  /* Clear */
  S_NUM_3B | S_ARG(1), 64, 32, 64,
  S_NUM_SMALL | S_ARG(0),
  S_CLEAR,

  S_MATRIX_MODE, S_ARG_2(GL_PROJECTION),
  S_PERSP,
  S_MATRIX_MODE, S_ARG_2(GL_MODELVIEW),

  S_NUM_3B | S_ARG(7), 128, 32, 128,
  S_NUM_3B | S_ARG(7), 32, 32, 128,
  S_NUM_3B | S_ARG(7), 128, 32, 128,
  S_TIME, 0,
    S_NUM_SMALL | S_ARG(1),
    S_MUL,
  S_KEYFRAME | S_ARG(2),

  S_NUM_3B | S_ARG(7),  48,  0,  48,
  S_LOOKAT,

  /* Lightning */

  S_ENABLE, S_ARG_2(GL_LIGHTING),
  S_NUM_SMALL_2 | S_ARG(1),
  S_NUM_3B | S_ARG(7), 32, 255, 128,
  S_LIGHT,

  /* Mesh */

  S_M_PUSH,
    S_NUM_3B | S_ARG(1), 0, 16, 63,
    S_COLOR,

    S_NUM_3B | S_ARG(7), 48, 0, 48,
    S_TRANSLATE,

    S_MESH, BLOOD,
  S_M_POP,


#else
/* Intro */

/* PART1 is where bird flies */
#define PART1_BEGIN 0
#define PART1_END   2
/* PART2 is where goat eats bird */
#define PART2_BEGIN (PART1_END+1)
#define PART2_END   5
/* PART3 is where monstah eats goat */
#define PART3_BEGIN (PART2_END+1)
#define PART3_END   7

  S_ENABLE, S_ARG_2(GL_FOG),

  /* Clear and set fog */
#define BG_COLOR  32, 16, 0
  S_NUM_3B | S_ARG(1), BG_COLOR,
  S_NUM_SMALL | S_ARG(0),
  S_NUM_3B | S_ARG(1), BG_COLOR,
  S_NUM_SMALL | S_ARG(0),
  S_CLEAR,

  S_FOG, S_ARG_2(GL_FOG_COLOR),

#define F  S_NUM_SMALL | S_ARG(2),
  F F F F
#undef F
  S_FOG, S_ARG_2(GL_FOG_DENSITY),

  /* Matrix stuff */

  S_MATRIX_MODE, S_ARG_2(GL_PROJECTION),
  S_PERSP,

  S_MATRIX_MODE, S_ARG_2(GL_MODELVIEW),

  /* Text */

  S_DISABLE, S_ARG_2(GL_LIGHTING),

  S_M_PUSH,
    S_NUM_3B | S_ARG(4), 12, 0, 10,
    S_NUM_3B | S_ARG(4), 10, 0, 0,
    S_LOOKAT,
#if 0
    S_NUM_SMALL | S_ARG(0),
    S_TIME,
      S_NUM_SMALL_2 | S_ARG(7),
      S_NUM_SMALL_2 | S_ARG(7),
      S_NUM_SMALL_2 | S_ARG(7),
      S_MUL,
      S_MUL,
      S_MUL,
    S_NUM_SMALL | S_ARG(0),

#endif
    S_NUM_3B | S_ARG(4), 0, 3, 0,
    S_TRANSLATE,

    S_NUM_SMALL | S_ARG(1),
      S_NUM_SMALL | S_ARG(1),
        S_NUM_SMALL | S_ARG(1),
          S_NUM_SMALL | S_ARG(2),
          S_MUL,
        S_MUL,
      S_MUL,
    S_SCALE,

    S_NUM_3B | S_ARG(1), 48, 63, 48,
    S_COLOR,

    /* Reverse order so two texts aren't rendered on same frame */

    S_SCENE, 6, 6,
      S_NEXT_SCENE, 90,
      S_TEXT, 'B','e','w','a','r','e',' ','o','f',' ',
              'm','o','n','s','t','a','h', '!','1','\0',
    S_SCENE_END | S_ARG(7),

#define PART3_TIME 70

    S_SCENE, 5, 5,
      S_NEXT_SCENE, 70,
    S_SCENE_END | S_ARG(7),

    S_SCENE, 4, 4,
      S_NEXT_SCENE, 62,
    S_SCENE_END | S_ARG(7),

    S_SCENE, 3, 3,
      S_NEXT_SCENE, 40,
      S_TEXT, 'M','e','a','t','-','e','a','t','i','n','g',' ',
              'g','o','a','t', '!','!','1','\0',
    S_SCENE_END | S_ARG(7),

#define PART2_TIME 34

    S_SCENE, 2, 2,
      S_NEXT_SCENE, PART2_TIME,
    S_SCENE_END | S_ARG(7),

    S_SCENE, 1, 1,
      S_NEXT_SCENE, 28,
      S_NUM_SMALL_2 | S_ARG(2),
        S_NUM_SMALL | S_ARG(6),
        S_MUL,
      S_SCALE,
      S_TEXT, ' ', 'M', 'o', 'n', 's', 't', 'a', 'h','h', '!','!','1', '\0',
    S_SCENE_END | S_ARG(7),

    S_SCENE, PART1_BEGIN, 0,
      S_NEXT_SCENE, 21,
    S_SCENE_END | S_ARG(7),
  S_M_POP,

  /* Other stuff */

  /* Camera keyframes */

  /* Very first scene where bird is flying */
  S_SCENE, PART1_BEGIN, PART1_END,
    S_NUM_3B | S_ARG(7),   50,   40,   32,
    S_NUM_3B | S_ARG(7),   70,   20,   48,
    S_NUM_3B | S_ARG(7),   84,   30,   70,
    S_NUM_3B | S_ARG(7),   70,   40,  100,
    S_NUM_3B | S_ARG(7),  160,  255,  192,

    S_TIME, 0,
      S_NUM_SMALL | S_ARG(4),
        S_NUM_SMALL | S_ARG(2),
        S_MUL,
      S_MUL,
    S_KEYFRAME | S_ARG(4),

    S_NUM_3B | S_ARG(7), 32, 16, 64,
    S_LOOKAT,
  S_SCENE_END | S_ARG(7),

  /* Part where goat eats bird and some more, actually the rest of intro */
  S_SCENE, PART2_BEGIN, PART3_END,
    S_NUM_3B | S_ARG(7),    92,   192,  80,
    S_NUM_3B | S_ARG(7),    50,   64,  70,
    S_NUM_3B | S_ARG(7),    100,   40,  100,
    S_NUM_3B | S_ARG(7),    50,   28,  40,

    S_TIME, PART2_TIME,
      S_NUM_SMALL | S_ARG(2),
        S_NUM_SMALL | S_ARG(1),
        S_MUL,
      S_MUL,
    S_KEYFRAME | S_ARG(3),

    S_NUM_3B | S_ARG(7), 32, 16, 64,
    S_LOOKAT,
  S_SCENE_END | S_ARG(7),

  /* Lightning */

  S_ENABLE, S_ARG_2(GL_LIGHTING),

  S_NUM_SMALL_2 | S_ARG(1),
  S_NUM_3B | S_ARG(7), 32, 255, 128,
  S_LIGHT,

  /* Some land */

  S_M_PUSH,
    S_NUM_3B | S_ARG(1), 16, 48, 0,
    S_COLOR,

    S_SCENE, PART2_BEGIN, PART2_END,
      S_NUM_3B | S_ARG(7), 16, 0, 32,
      S_TRANSLATE,
    S_SCENE_END | S_ARG(7),

    S_MESH, LAND,

    S_NUM_3B | S_ARG(7), 32, 0, 32,
    S_TRANSLATE,

    S_MESH, LAND,

#if 0
    S_NUM_SMALL_2 | S_ARG(7),
    S_NUM_3B | S_ARG(7), 4, 4, 4,
    S_ROTATE,
#endif

    S_NUM_3B | S_ARG(7), 4, 0, 16,
    S_TRANSLATE,

    S_MESH, LAND,

    S_NUM_3B | S_ARG(7), 16, 4, 16,
    S_TRANSLATE,

    S_MESH, LAND,

    /* Trees */

    S_NUM_3B | S_ARG(1), 48, 48, 32,
    S_COLOR,

    S_NUM_SMALL | S_ARG(4),
    S_SCALE,

    S_NUM_3B | S_ARG(7), 0, 10, 0,
    S_TRANSLATE,

    S_MESH, PLANT_2,

    S_SCENE, PART2_BEGIN, PART2_END,
      S_NUM_3B | S_ARG(7), 16, 8, 32,
      S_TRANSLATE,

      S_MESH, PLANT_2,
    S_SCENE_END | S_ARG(7),

    S_NUM_3B | S_ARG(7), 4, 8, 32,
    S_TRANSLATE,

    S_SCENE, PART1_BEGIN, PART1_END,
      S_MESH, PLANT,
    S_SCENE_END | S_ARG(7),
  S_M_POP,

  /* Mesh */

  S_M_PUSH,
    S_NUM_3B | S_ARG(7), 32, 17, 64,
    S_TRANSLATE,

    S_NUM_SMALL | S_ARG(2),
    S_SCALE,

    /* Animal */

    S_SCENE, PART3_BEGIN, PART3_END,
      S_NUM_3B | S_ARG(1), 60,  32,  24,
      S_COLOR,

      S_M_PUSH,
        S_NUM_3B | S_ARG(7),  40,  10,  64,
        S_NUM_3B | S_ARG(7),  40,  10,  64,
        S_NUM_3B | S_ARG(7),  40,  10,  64,
        S_NUM_3B | S_ARG(7),  40,  10,   0,
        S_TIME, PART3_TIME,
          S_NUM_SMALL | S_ARG(2),
            S_NUM_SMALL | S_ARG(1),
            S_MUL,
          S_MUL,
        S_KEYFRAME | S_ARG(3),
        S_TRANSLATE,

        S_MESH, MONSTAH,
      S_M_POP,
    S_SCENE_END | S_ARG(7),

    /* Goat */

    S_SCENE, PART2_BEGIN, PART3_END,
      S_NUM_3B | S_ARG(1), 50,  40,  10,
      S_COLOR,

      S_M_PUSH,
        S_NUM_3B | S_ARG(7),   20,  20, 120,
        S_NUM_3B | S_ARG(7),   20,  20, 120,
        S_NUM_3B | S_ARG(7),   20,  20, 120,
        S_NUM_3B | S_ARG(7),   20,  20,   0,
        S_TIME, PART2_TIME,
          S_NUM_SMALL | S_ARG(2),
            S_NUM_SMALL | S_ARG(1),
            S_MUL,
          S_MUL,
        S_KEYFRAME | S_ARG(3),
        S_TRANSLATE,

        S_MESH, GOAT,
      S_M_POP,
    S_SCENE_END | S_ARG(7),

    /* Birdie */

    S_SCENE, PART1_BEGIN, PART1_END,
      S_NUM_3B | S_ARG(7),    0,  50,   0,
      S_NUM_3B | S_ARG(7),   32,   0,  64,
      S_NUM_3B | S_ARG(7),    0,  10, 128,
      S_TIME, 5,
        S_NUM_SMALL | S_ARG(2),
          S_NUM_SMALL | S_ARG(3),
          S_MUL,
        S_MUL,
      S_KEYFRAME | S_ARG(2),
      S_TRANSLATE,
    S_SCENE_END | S_ARG(7),

    S_SCENE, PART2_BEGIN, PART2_END,
      S_NUM_3B | S_ARG(7),  148,  20, 20,
      S_TRANSLATE,
    S_SCENE_END | S_ARG(7),

    S_NUM_SMALL | S_ARG(2),
    S_SCALE,

    S_SCENE, PART1_BEGIN, PART2_END,
      S_NUM_3B | S_ARG(1), 32, 32, 48,
      S_COLOR,
      S_MESH, BIRDIE,
    S_SCENE_END | S_ARG(7),

    S_SCENE, 5, 6,
      S_NUM_3B | S_ARG(1), 32, 0, 0,
      S_COLOR,
      S_MESH, BLOOD,
    S_SCENE_END | S_ARG(7),
  S_M_POP,
#endif

S_END,
};
