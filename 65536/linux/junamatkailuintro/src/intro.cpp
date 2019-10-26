/** \file
 * Main intro source file.
 */

//######################################
// Define ##############################
//######################################

#if defined(DNLOAD_GLESV2)
/** Screen height. */
#define SCREEN_H 648
#else
/** Screen height. */
#define SCREEN_H 720
#endif

/** Screen width in 16:9. */
#define SCREEN_W (SCREEN_H * 16 / 9)

/** Audio channels. */
#define AUDIO_CHANNELS 2

/** Audio samplerate. */
#define AUDIO_SAMPLERATE 44100

/** Audio byterate. */
#define AUDIO_BYTERATE (AUDIO_CHANNELS * AUDIO_SAMPLERATE * sizeof(int16_t))

/** Milliseconds per frame. */
#define FRAME_MILLISECONDS 20

/** Intro length (seconds). */
#define INTRO_LENGTH 125

/** Intro length (frames). */
#define INTRO_LENGTH_FRAMES (INTRO_LENGTH * 1000 / FRAME_MILLISECONDS)

/** Intro length (in bytes of audio). */
#define INTRO_LENGTH_AUDIO (INTRO_LENGTH * AUDIO_BYTERATE)

/** Intro start position (in seconds). */
#define INTRO_START (0 * AUDIO_BYTERATE)

/** Intro length (in bytes of audio). */
#define AUDIO_BUFFER_SIZE (INTRO_LENGTH_AUDIO * 9 / 8)

/** Field of view. */
#define CAMERA_FOV 94.0f

/** Field of view (radians). */
#define CAMERA_FOV_RADIANS (CAMERA_FOV * static_cast<float>(M_PI / 180.0))

/** Camera near plane. */
#define CAMERA_NEAR 0.29f

/** Camera near plane constant. */
#define CAMERA_NEAR_CONSTANT (CAMERA_NEAR * 2.0f)

/** Camera far plane. */
#define CAMERA_FAR 279.0f

/** \cond */
#define STARTING_POS_X -200.0f
#define STARTING_POS_Y 0.0f
#define STARTING_POS_Z 0.0f
#define STARTING_ROT_X -0.032f
#define STARTING_ROT_Y 0.048f
#define STARTING_ROT_Z 0.0f
/** \endcond */

//######################################
// Include #############################
//######################################

#include "dnload.h"
#include "intro.hpp"

#if defined(DNLOAD_GLESV2)
#include "dnload_videocore.h"
#include "dnload_egl.h"
#endif

#if defined(WIN32)
/** Use MT random since windows rand/srand seem to be scheisse. */
#define USE_MT_RAND
#endif

#if defined(USE_MT_RAND)
#include <boost/random/mersenne_twister.hpp>
#include <boost/random/uniform_int.hpp>
#include <boost/random/uniform_real.hpp>
#include <boost/random/variate_generator.hpp>
#endif

#if defined(USE_LD)
#include <iostream>
#else
#include "bsd_rand.c"
#endif

//######################################
// Platform-dependent global data ######
//######################################

#if defined(DNLOAD_GLESV2)

/** Native display. */
EGL_DISPMANX_WINDOW_T g_native_window;

/** EGL display. */
EGLDisplay g_egl_display;

/** EGL surface. */
EGLSurface g_egl_surface;

#endif

#if defined(USE_LD)

/** Debug flag. */
static bool g_debug = false;

/** Developer mode global toggle. */
static bool g_flag_developer = false;

#else

/** Globally disable developer mode. */
#define g_flag_developer 0

#endif

//######################################
// Generic (before verbatim source) ####
//######################################

/** Declare random number function. */
#define bsd_rand bsd_rand_actual

/** Declare random number function. */
#define bsd_srand bsd_srand_actual

/** Declare which color space to use. */
#define COLOR_SPACE_THEFLASH 0

/** \brief Random float value.
 *
 * \param op Given maximum value.
 * \return Random value between 0 and given value.
 */
static float frand(float op)
{
  return static_cast<float>(bsd_rand() & 0xFFFF) * ((1.0f / 65535.0f) * op);
}

/** \brief Random float value.
 *
 * \param minimum Given minimum value.
 * \param maximum Given maximum value.
 * \return Random value between minimum and maximum value.
 */
static float frand(float minimum, float maximum)
{
  return frand(maximum - minimum) + minimum;
}

#if defined(USE_MT_RAND)

/** Mersenne random number generator. */
static boost::mt19937 g_mt_rand;

#endif

/** \brief Random float value from non-deterministic source.
 *
 * \param op Given maximum value.
 * \return Random value between 0 and given value.
 */
static float frandom(float op)
{
#if defined(USE_MT_RAND)
  boost::uniform_real<> distribution(0.0, static_cast<double>(op));
  boost::variate_generator<boost::mt19937&, boost::uniform_real<> > randomize(g_mt_rand, distribution);
  return static_cast<float>(randomize());
#else
  return static_cast<float>(dnload_random() & 0xFFFF) * ((1.0f / 65535.0f) * op);
#endif
}

/** \brief Random float value from non-deterministic source.
 *
 * \param minimum Given minimum value.
 * \param maximum Given maximum value.
 * \return Random value between minimum and maximum value.
 */
static float frandom(float minimum, float maximum)
{
#if defined(USE_MT_RAND)
  boost::uniform_real<> distribution(static_cast<double>(minimum), static_cast<double>(maximum));
  boost::variate_generator<boost::mt19937&, boost::uniform_real<> > randomize(g_mt_rand, distribution);
  return static_cast<float>(randomize());
#else
  return frandom(maximum - minimum) + minimum;
#endif
}

/** \brief Mix two floats.
 *
 * \param lhs Left-hand-side operand.
 * \param rhs Right-hand-side operand.
 * \param ratio Mixing ratio.
 */
static float mix(float lhs, float rhs, float ratio)
{
  return (rhs - lhs) * ratio + lhs;
}

#if defined(USE_LD)

unsigned get_default_resolution()
{
  return SCREEN_H;
}

void set_mode_developer(bool flag_developer)
{
  g_flag_developer = flag_developer;
}

/** \brief Terminate program in a (relatively) safe manner.
 *
 * \param return_code Return code to exit with, defaults to error.
 */
static void terminate_program(int return_code = 1)
{
#if defined(DNLOAD_GLESV2)
  egl_quit(g_egl_display);
#endif
  dnload_SDL_Quit();
  exit(return_code);
}

#endif

//######################################
// Verbatim source #####################
//######################################

#include "verbatim_bounding_volume.cpp"
#include "verbatim_face.cpp"
#include "verbatim_height_map.cpp"
#include "verbatim_image_rgb.cpp"
#include "verbatim_matrix.cpp"
#include "verbatim_mesh.cpp"
#include "verbatim_object.cpp"
#include "verbatim_program.cpp"
#include "verbatim_shader.cpp"
#include "verbatim_state.cpp"
#include "verbatim_state_queue.cpp"
#include "verbatim_synth.hpp"
#include "verbatim_terrain.cpp"
#include "verbatim_vertex.cpp"
#include "verbatim_vertex_buffer.cpp"
#include "verbatim_texture.cpp"
#include "verbatim_frame_buffer.cpp"
#include "verbatim_font.cpp"
#include "verbatim_mesh_handler.cpp"

#include "model_auto.h"
#include "model_lentsikka.h"

//######################################
// Global data #########################
//######################################

/** Audio buffer for output. */
static int16_t g_audio_buffer[AUDIO_BUFFER_SIZE / sizeof(int16_t)];

/** Current audio position. */
static uint8_t *g_audio_position = reinterpret_cast<uint8_t*>(&g_audio_buffer[INTRO_START]);

#if defined(USE_LD)

/** \cond */
static Vector3 g_pos(STARTING_POS_X, STARTING_POS_Y, STARTING_POS_Z);
static float g_rot_x = STARTING_ROT_X;
static float g_rot_y = STARTING_ROT_Y;
static float g_rot_z = STARTING_ROT_Z;
/** \endcond */

/** Current frame. */
static int g_current_frame = 0;

/** Train position for moving front and back in time. */
static Vector3 g_train_positions[INTRO_LENGTH_FRAMES];

/** Position offset. */
static Vector3 g_position_offset(0.0f, 0.0f, 0.0f);

/** Print position debug flag. */
static bool g_print_position = false;

#endif

//######################################
// Music ###############################
//######################################

/** \brief Update audio stream.
 *
 * \param userdata Not used.
 * \param stream Target stream.
 * \param len Number of bytes to write.
 */
static void audio_callback(void *userdata, Uint8 *stream, int len)
{
  (void)userdata;

  while(len--)
  {
    *stream = *g_audio_position;
    ++stream;
    ++g_audio_position;
  }
}

/** SDL audio specification struct. */
static SDL_AudioSpec audio_spec =
{
  AUDIO_SAMPLERATE,
  AUDIO_S16,
  AUDIO_CHANNELS,
  0,
  4096, // Not syncing to audio, can safely use high value.
  0,
  0,
  audio_callback,
  NULL
};

//######################################
// Shaders #############################
//######################################

/** Default (scene) vertex shader. */
static const char *g_shader_vertex_default = ""
"attribute vec3 P;"
"attribute vec4 N;"
"attribute vec2 C;"
"uniform highp mat4 M;"
"uniform highp mat3 W;"
"varying mediump vec3 n;"
"varying lowp vec3 c;"
"precision mediump float;"
"void main()"
"{"
"gl_Position=M*vec4(P,1.);"
"n=W*N.xyz;"
//"c=vec3(C,(2.*.29)/(279.+.29-(gl_Position.z/gl_Position.w*(279.-.29)));" // Linearized z (0.29 ; 279.0)
"c=vec3(C,N.w/(279.29-278.71*gl_Position.z/gl_Position.w));"
"}";

/** Default (scene) fragment shader. */
static const char *g_shader_fragment_default = ""
"uniform mediump vec3 L;"
"varying mediump vec3 n;"
"varying lowp vec3 c;"
"precision lowp float;"
"void main()"
"{"
"gl_FragColor=vec4(c,dot(n,L));"
"}";

/** "Loader" vertex shader. */
static const char *g_shader_vertex_loader = ""
"attribute vec2 P;"
"uniform mediump vec2 S;"
"precision mediump float;"
"varying mediump vec2 t;"
"void main()"
"{"
"gl_Position=vec4(P,0.,1.);"
"t=(P*.5+.5)*S/256.;"
"}";

/** "Loader" fragment shader. */
static const char *g_shader_fragment_loader = ""
"uniform sampler2D T;"
"uniform mediump float F;"
"varying mediump vec2 t;"
"precision lowp float;"
"void main()"
"{"
"vec4 c=texture2D(T,t);"
"vec4 i=1.-c;"
"i=vec4((i.r+i.g+i.b)*.33);"
"float m=mod((t.x-t.y)*.2-F,1.);"
"m=(m-smoothstep(.85,1.,m))*1.2;"
"gl_FragColor=mix(i,c,m);"
"}";

/** Post-process vertex shader. */
static const char *g_shader_vertex_post = ""
"attribute vec2 P;"
"uniform mediump vec2 S;"
"varying mediump vec2 t;"
"varying mediump vec2 t1;"
"varying mediump vec2 t2;"
"varying mediump vec2 t3;"
"precision mediump float;"
"void main()"
"{"
"t=P*.5+.5;"
"vec2 s=1./S;"
"t1=t+s*vec2(-1.5,-.5);"
"t2=t+s*vec2(1.5,-.5);"
"t3=t+s*vec2(0.,1.5);"
"gl_Position=vec4(P,0.,1.);"
"}";

/** Post-process fragment shader. */
static const char *g_shader_fragment_post = ""
"uniform sampler2D T;"
"varying mediump vec2 t;"
"varying mediump vec2 t1;"
"varying mediump vec2 t2;"
"varying mediump vec2 t3;"
#if defined(COLOR_SPACE_THEFLASH) && COLOR_SPACE_THEFLASH
"vec3 C(vec2 hs)"
"{"
"  if(hs.x<(1./255.)) return hs.yyy;"
"  vec3 xt = vec3("
"    6. * (hs.x - (2./3.)),"
"    0.0,"
"    6. * (1.0 - hs.x)"
"    );"

"  if (hs.x < (2./3.))"
"  {"
"    xt.r = 0.0;"
"    xt.g = 6. * ((2./3.) - hs.x);"
"    xt.b = 6. * (hs.x - (1./3.));"
"  }"

"  if (hs.x < (1./3.))"
"  {"
"    xt.r = 6. * ((1./3.) - hs.x);"
"    xt.g = 6. * hs.x;"
"    xt.b = 0.0;"
"  }"

"  xt = min( xt, 1.0 );"
"  return ((hs.y*xt)+(1.-hs.y)/2.)*1.5;"
"}"
#else
"vec3 C(vec2 c)"
"{"
"c=c*9.-4.5;"
"vec3 r=vec3(1.402*c.g,-.344136*c.r-0.714136*c.g,1.772*c.r)+1.;"
"return r/max(max(r.r,r.g),r.b);"
"}"
#endif
"void main()"
"{"
"vec4 s=texture2D(T,t);"
"vec3 r=abs(vec3(texture2D(T,t1).z,texture2D(T,t2).z,texture2D(T,t3).z)-s.z);"
"gl_FragColor=vec4(mix(C(s.rg)*s.w,vec3(s.w),s.w),1.)*smoothstep(.965,.99,1.-max(r.x,max(r.y,r.z)));"
//"gl_FragColor=vec4(vec3(step(.8,m)),1.);"
"}";

/** Blueprint vertex shader. */
static const char *g_shader_vertex_blueprint = ""
"attribute vec2 P;"
"uniform mediump vec2 S;"
"uniform mediump vec2 A;"
"uniform mediump vec2 B;"
"uniform mediump vec2 M;"
"varying mediump vec2 t;"
"varying mediump vec2 t1;"
"varying mediump vec2 t2;"
"varying mediump vec2 n;"
"precision mediump float;"
"void main()"
"{"
"t=P*.5+.5;"
"n=t*S/256.+M;"
"vec2 s=1./S;"
"t1=t+s*A;"
"t2=t+s*B;"
"gl_Position=vec4(P,0.,1.);"
"}";

/** Post-process fragment shader. */
static const char *g_shader_fragment_blueprint = ""
"uniform sampler2D N;"
"uniform sampler2D T;"
"varying mediump vec2 t;"
"varying mediump vec2 t1;"
"varying mediump vec2 t2;"
"varying mediump vec2 n;"
"void main()"
"{"
"vec4 s=texture2D(T,t);"
"vec2 r=abs(vec2(texture2D(T,t1).z,texture2D(T,t2).z)-s.z);"
"gl_FragColor=vec4(mix(texture2D(N,n).rgb*s.w,vec3(s.w),s.w),1.)*smoothstep(.965,.99,1.-max(r.x,r.y));"
//"gl_FragColor=vec4(vec3(step(.8,m)),1.);"
"}";

//######################################
// Generation ##########################
//######################################

/** Train incremental acceleration. */
static const float TRAIN_ACCELERATION_NEG = 0.0009f;

/** Train incremental acceleration. */
static const float TRAIN_ACCELERATION_POS = 0.0011f;

/** Train incremental acceleration. */
static const float TRAIN_MAX_SPEED = 0.92f;

/** Train incremental acceleration. */
static const float TRAIN_CRUISING_SPEED = 0.68f;

/** Train incremental acceleration. */
static const float TRAIN_END_SPEED = 0.15f;

/** Train falloff acceleration. */
static const float TRAIN_FALLOFF = 0.008f;

/** Train falloff speed. */
static const float TRAIN_FALL_SPEED = 0.038f;

/** Terrain starting point (away from viewer). */
static const float TERRAIN_AWAY = -4.0f;

/** Length of land terrain segment. */
static const float LAND_LENGTH = 2100;

/** Terrain overlap. */
static const float TERRAIN_OVERLAP = 30.0f;

/** \brief Tolppa distance.
 *
 * Intentionally same as terrain overlap.
 */
static const float TOLPPA_GAP = TERRAIN_OVERLAP;

/** Length of water terrain segment. */
static const float WATER_LENGTH = 870.0f;

/** Length of city terrain segment. */
static const float CITY_LENGTH = 750.0f;

/** Length of pier terrain segment. */
static const float PIER_LENGTH = 300.0f;

/** Land start position. */
static const float LAND_START = 0.0f;

/** Land end position. */
static const float LAND_END = LAND_START - LAND_LENGTH;

/** Water level. */
static const float WATER_LEVEL = -12.0f;

/** Water start position. */
static const float WATER_START = LAND_END + TERRAIN_OVERLAP;

/** Bridge start position. */
static const float BRIDGE_START = WATER_START - TOLPPA_GAP * 11.0f;

/** City start position. */
static const float CITY_START = WATER_START - WATER_LENGTH + TERRAIN_OVERLAP;

/** Pier start position. */
static const float PIER_START = CITY_START - CITY_LENGTH + TERRAIN_OVERLAP;

/** Pier end position. */
static const float PIER_END = PIER_START - PIER_LENGTH;

/** Tunnel start. */
static const float TUNNEL_START = CITY_START + TOLPPA_GAP * 2.0f;

/** Tunnel start. */
static const float TUNNEL_END = TUNNEL_START - TOLPPA_GAP * 6.0f;

/** \brief Skyway downward sloping in the end.
 *
 * Number depends on slope speed and needs adjustment if sloping speed changes.
 */
static const float SKYWAY_SLOPE = -1.65f;

/** Horizon distance. */
static const float HORIZON = -228.0f;

/** Windmill riser. */
static const float WINDMILL_UP = 25.0f;

/** \brief Generate konseptipaperi texture.
 *
 * Fixed size.
 *
 * \param seed Random seed.
 * \return Texture.
 */
static Texture* generate_texture_konseptipaperi(unsigned seed)
{
  const unsigned KONSEPTIPAPERI_WIDTH = 256;

  ImageRGB image(KONSEPTIPAPERI_WIDTH, KONSEPTIPAPERI_WIDTH);

  bsd_srand(seed);

  for(unsigned ii = 0; (ii < KONSEPTIPAPERI_WIDTH); ++ii)
  {
    for(unsigned jj = 0; (jj < KONSEPTIPAPERI_WIDTH); ++jj)
    {
      float fr = frand(0.6f, 1.0f);
      float fg = frand(0.6f, 1.0f);
      float fb = frand(0.6f, 1.0f);

      if((((ii + 15) % 32) <= 2) || (((jj + 15) % 32) <= 1))
      {
        float sub = frand(0.4f, 0.7f);

        fr -= sub;
        fg -= sub;
      }

      image.setPixel(ii, jj, fr, fg, fb);
    }
  }

  image.filterLowpass(1);
  return image.createTexture();
}

/** \brief Terrain color function.
 *
 * \param op Height.
 * \return Color at given height.
 */
static Color land_height_color_func(float op)
{
  return mix(Color(139, 189, 55, 255), Color(85, 102, 85, 255), (op + 4.0f) / 16.0f);
}

/** \brief Terrain face color function.
 *
 * \param op Face to evaluate.
 * \return Color for face.
 */
static Color land_face_color_func(const Face& op)
{
  float mixer = dot_product(op.getNormal(), Vector3(0.0f, 1.0f, 0.0f));

  return mix(Color(151, 120, 105, 255), Color(255, 255, 255, 255), mixer * mixer);
}

/** \brief Water color function.
 *
 * \param op Height.
 * \return Color at given height.
 */
static Color water_height_color_func(float op)
{
#if 1
  return mix(Color(22, 49, 255, 255), Color(141, 180, 255, 255), (op - WATER_LEVEL) / 1.4f);
#else
  (void)op;
  return Color(255, 255, 255, 255);
#endif
}

/** \brief Water face color func.
 *
 * \param op Face to evaluate.
 * \return Color for face.
 */
static Color water_face_color_func(const Face &op)
{
#if 1
  return land_face_color_func(op);
#else
  (void)op;
  return Color(255, 255, 255, 255);
#endif
}

/** \brief Water color function.
 *
 * \param op Height.
 * \return Color at given height.
 */
static Color city_height_color_func(float op)
{
  (void)op;
  return mix(Color(150, 154, 157, 255), Color(110, 114, 117, 255), frand(1.0f));
}

/** \brief Water face color func.
 *
 * \param op Face to evaluate.
 * \return Color for face.
 */
static Color city_face_color_func(const Face &op)
{
#if 1
  return land_face_color_func(op);
#else
  (void)op;
  return Color(255, 255, 255, 255);
#endif
}

/** \brief Generate terrain.
 *
 * \param vertex_buffer Vertex buffer to insert into.
 * \param terrain Height map to use.
 * \return Terrain generated.
 */
static Terrain* generate_terrain_land(VertexBuffer *vertex_buffer, HeightMap *terrain)
{
  const float TERRAIN_NODE = 6.0f;
  const unsigned DETAIL_X = static_cast<unsigned>(LAND_LENGTH / TERRAIN_NODE);
  const unsigned DETAIL_Y = 24;

  //bsd_srand(13);
  bsd_srand(18);

  terrain->clear(DETAIL_X * 2, DETAIL_Y * 2);
  terrain->randomize(-0.125f, 0.125f, 1);
  terrain->randomize(-0.5f, 0.5f, 2);
  terrain->randomize(-1.0f, 1.0f, 4);
  terrain->randomize(-2.0f, 2.0f, 6);
  terrain->randomize(-4.0f, 4.0f, 8);
  terrain->randomize(-8.0f, 8.0f, 12);
  terrain->randomize(-16.0f, 16.0f, 24);

  terrain->filterLowpass(2);
  terrain->mapHeight(-48.0f, 18.0f);
  terrain->cutDepth(-4.0f);
  terrain->slopeFront(-2.1f, 4);
  terrain->slopeLeft(-17.1f, 5);

  return terrain->createMeshTriangle(vertex_buffer, LAND_START, LAND_START - LAND_LENGTH, TERRAIN_AWAY, HORIZON,
      DETAIL_X, DETAIL_Y, land_height_color_func, land_face_color_func);
}

/** \brief Generate terrain.
 *
 * \param vertex_buffer Vertex buffer to insert into.
 * \param terrain Height map to use.
 * \return Terrain generated.
 */
static Terrain* generate_terrain_water(VertexBuffer *vertex_buffer, HeightMap *terrain)
{
  const float TERRAIN_NODE = 6.0f;
  const unsigned DETAIL_X = static_cast<unsigned>(WATER_LENGTH / TERRAIN_NODE);
  const unsigned DETAIL_Y = 24;

  bsd_srand(20);

  terrain->clear(DETAIL_X * 2, DETAIL_Y * 2);
  terrain->randomize(-0.125f, 0.125f, 1);
  terrain->randomize(-0.5f, 0.5f, 2);
  terrain->randomize(-1.0f, 1.0f, 4);
  terrain->randomize(-2.0f, 2.0f, 6);
  terrain->randomize(-4.0f, 4.0f, 8);
  terrain->randomize(-8.0f, 8.0f, 12);

  terrain->filterLowpass(3);
  terrain->mapHeight(WATER_LEVEL, WATER_LEVEL + 0.8f);

  return terrain->createMeshTriangle(vertex_buffer, WATER_START, WATER_START - WATER_LENGTH, TERRAIN_AWAY,
      HORIZON, DETAIL_X, DETAIL_Y, water_height_color_func, water_face_color_func);
}

/** \brief Generate terrain.
 *
 * \param vertex_buffer Vertex buffer to insert into.
 * \param terrain Height map to use.
 * \return Terrain generated.
 */
static Terrain* generate_terrain_city(VertexBuffer *vertex_buffer, HeightMap *terrain)
{
  const float TERRAIN_NODE = 6.0f;
  const unsigned DETAIL_X = static_cast<unsigned>(CITY_LENGTH / TERRAIN_NODE);
  const unsigned DETAIL_Y = 24;

  bsd_srand(3);

  terrain->clear(DETAIL_X * 2, DETAIL_Y * 2);
  terrain->randomize(-0.125f, 0.125f, 1);
  terrain->randomize(-0.25f, 0.25f, 2);
  terrain->randomize(-0.5f, 0.5f, 4);
  terrain->randomize(-1.0f, 1.0f, 8);

  terrain->filterLowpass(2);
  terrain->mapHeight(-26.2f, -24.3f);
  terrain->slopeBack(6 * 2, 14 * 2, (DETAIL_X * 2) / 3, 22.0f, (DETAIL_X * 2) - 1, -23.0f);

  return terrain->createMeshTriangle(vertex_buffer, CITY_START, CITY_START - CITY_LENGTH, TERRAIN_AWAY,
      HORIZON, DETAIL_X, DETAIL_Y, city_height_color_func, city_face_color_func);
}

/** \brief Generate tolppa.
 *
 * \param vertex_buffer Vertex buffer to insert into.
 * \return Mesh generated.
 */
static CompiledMesh* generate_tolppa(VertexBuffer *vertex_buffer)
{
  const float TOLPPA_X = 0.0f;
  const float TOLPPA_DEPTH = -1.0f;
  const float TOLPPA_BASE_DEPTH = -2.0f;
  const float TOLPPA_UP = 3.0f;
  const float TOLPPA_SECONDARY_UP = TOLPPA_UP - 0.8f;
  const float TOLPPA_AWAY = 0.0f;
  const float TOLPPA_FORWARD = TOLPPA_AWAY + 1.8f;
  const float TOLPPA_SECONDARY_FORWARD = TOLPPA_AWAY + 1.6f;
  const float TOLPPA_WIDTH = 0.11f;
  const float TOLPPA_BASE_WIDTH = TOLPPA_WIDTH + 0.06f;
  const float TOLPPA_BASE_SECONDARY_WIDTH = TOLPPA_BASE_WIDTH + 0.08f;
  const float TOLPPA_SECONDARY_WIDTH = TOLPPA_WIDTH - 0.03f;
  const float TOLPPA_TERTIARY_WIDTH = TOLPPA_SECONDARY_WIDTH - 0.03f;
  const float TOLPPA_INDENT = 0.25f;
  const Color TOLPPA_COLOR(220, 210, 200, 255);
  const Color TOLPPA_BASE_COLOR(193, 161, 102, 255);
  Mesh msh;

  msh.addAngle(Vector3(TOLPPA_X, TOLPPA_DEPTH, TOLPPA_AWAY), Vector3(TOLPPA_X, TOLPPA_UP, TOLPPA_AWAY),
      Vector3(TOLPPA_X, TOLPPA_UP, TOLPPA_FORWARD), TOLPPA_WIDTH, 4, TOLPPA_COLOR, Mesh::SIDE_NO_BOTTOM);
  
  msh.addCylinder(Vector3(TOLPPA_X, TOLPPA_BASE_DEPTH, TOLPPA_AWAY),
      Vector3(TOLPPA_X, TOLPPA_DEPTH, TOLPPA_AWAY), TOLPPA_BASE_SECONDARY_WIDTH, TOLPPA_BASE_WIDTH,
      6, TOLPPA_BASE_COLOR, Vector3(0.0f, 0.0f, 1.0f), Mesh::SIDE_NO_FRONT);

  msh.addCylinder(Vector3(TOLPPA_X, TOLPPA_SECONDARY_UP, TOLPPA_SECONDARY_FORWARD),
      Vector3(TOLPPA_X, TOLPPA_SECONDARY_UP, TOLPPA_AWAY), TOLPPA_SECONDARY_WIDTH, TOLPPA_SECONDARY_WIDTH,
      4, TOLPPA_COLOR, Vector3(0.0f, 1.0f, 0.0f), Mesh::SIDE_NO_BACK);

  msh.addCylinder(Vector3(TOLPPA_X, TOLPPA_SECONDARY_UP, TOLPPA_SECONDARY_FORWARD - TOLPPA_INDENT),
      Vector3(TOLPPA_X, TOLPPA_UP, TOLPPA_FORWARD - TOLPPA_INDENT), TOLPPA_TERTIARY_WIDTH,
      TOLPPA_TERTIARY_WIDTH, 4, TOLPPA_COLOR, Vector3(0.0f, 1.0f, 1.0f), 0);

  msh.addCylinder(Vector3(TOLPPA_X, TOLPPA_SECONDARY_UP, TOLPPA_SECONDARY_FORWARD - TOLPPA_INDENT),
      Vector3(TOLPPA_X, TOLPPA_UP, TOLPPA_AWAY + TOLPPA_INDENT), TOLPPA_TERTIARY_WIDTH, TOLPPA_TERTIARY_WIDTH,
      4, TOLPPA_COLOR, Vector3(0.0f, 1.0f, 1.0f), 0);

  return msh.insert(vertex_buffer);
}

/** \brief Generate the 'base' under tolppa extending up to the next one.
 *
 * \param vertex_buffer Vertex buffer to insert into.
 * \param water_segment True for water-side block.
 * \return Mesh generated.
 */
static CompiledMesh* generate_base_land(VertexBuffer *vertex_buffer, bool water_segment = false)
{
  const float SLOPE_BACK = -0.5f;
  const float SLOPE_START = -1.8f;
  const float SLOPE_END = -4.6f;
  const float SLOPE_UP = -1.4f;
  const float SLOPE_DOWN = -2.2f;
  const Color SLOPE_COLOR(205, 183, 160, 255);
  Mesh msh;

  msh.addSlope(Vector3(-TOLPPA_GAP * 0.5f, SLOPE_UP, SLOPE_BACK),
      Vector3(-TOLPPA_GAP * 0.5f, SLOPE_UP, SLOPE_START), Vector3(-TOLPPA_GAP * 0.5f, SLOPE_DOWN, SLOPE_END),
      TOLPPA_GAP * 0.5f, 4, SLOPE_COLOR);

  if(water_segment)
  {
    const float SLOPE_SECONDARY_UP = -1.8f;
    const float SLOPE_SECONDARY_DOWN = -2.8f;
    const float SLOPE_SECONDARY_START = -2.4f;
    const float SLOPE_SECONDARY_END = -7.1f;
    const Color SLOPE_SECONDARY_COLOR/*(192, 172, 157, 255)*/(151, 120, 105, 255);

    msh.addSlope(Vector3(-TOLPPA_GAP * 0.5f, SLOPE_SECONDARY_UP, SLOPE_START),
        Vector3(-TOLPPA_GAP * 0.5f, SLOPE_SECONDARY_UP, SLOPE_SECONDARY_START),
        Vector3(-TOLPPA_GAP * 0.5f, SLOPE_SECONDARY_DOWN, SLOPE_SECONDARY_END),
        TOLPPA_GAP * 0.5f, 5, SLOPE_SECONDARY_COLOR);
  }

  return msh.insert(vertex_buffer);
}

/** \brief Generate one block of bridge.
 *
 * \param vertex_buffer Vertex buffer to insert into.
 * \param segment Segment to create.
 * \return Mesh generated.
 */
static CompiledMesh* generate_bridge(VertexBuffer *vertex_buffer, unsigned segment)
{
  const float BRIDGE_BACK = -0.5f;
  const float BRIDGE_FLOOR = -1.4f;
  const float BRIDGE_UP = 5.5f;
  const float BRIDGE_AWAY = -3.2f;
  const float BRIDGE_INDENT = 0.06f;
  const float BRIDGE_START_INDENT = 1.1f;
  const float BRIDGE_THICKNESS1 = 0.55f;
  const float BRIDGE_THICKNESS2 = (BRIDGE_THICKNESS1 - BRIDGE_INDENT) * 0.5f;
  const float BRIDGE_THICKNESS3 = BRIDGE_THICKNESS2 - 0.08f;
  const float BRIDGE_THICKNESS4 = BRIDGE_THICKNESS3 - 0.05f;
  const float BRIDGE_AWAY_MIDDLE = BRIDGE_AWAY + BRIDGE_THICKNESS1 * 0.5f + BRIDGE_INDENT;
  const Color BRIDGE_FLOOR_COLOR(192, 152, 132, 255);
  const Color BRIDGE_RAIL_COLOR(205, 97, 65, 255);
  const Color BRIDGE_EDGE_COLOR = mix(BRIDGE_FLOOR_COLOR, BRIDGE_RAIL_COLOR, 0.5f);
  float start_coord = (segment == 0) ? -BRIDGE_START_INDENT : 0.0f;
  uint8_t front_side = (segment == 0) ? Mesh::SIDE_RIGHT : 0;

  Mesh msh;

  msh.addBox(Vector3(-TOLPPA_GAP, BRIDGE_FLOOR - BRIDGE_THICKNESS1, BRIDGE_BACK),
      Vector3(0.0f, BRIDGE_FLOOR, BRIDGE_AWAY), BRIDGE_FLOOR_COLOR, Vector3(0.0f, 0.0f, -1.0f),
      Vector3(0.0f, 1.0f, 0.0f), Mesh::SIDE_TOP | front_side);
  msh.addBox(Vector3(-TOLPPA_GAP, BRIDGE_FLOOR, BRIDGE_AWAY + BRIDGE_THICKNESS1 + BRIDGE_INDENT),
      Vector3(start_coord, BRIDGE_FLOOR + BRIDGE_THICKNESS1, BRIDGE_AWAY + BRIDGE_INDENT),
      BRIDGE_EDGE_COLOR, Vector3(0.0f, 0.0f, -1.0f), Vector3(0.0f, 1.0f, 0.0f),
      Mesh::SIDE_FRONT | Mesh::SIDE_TOP | front_side);
  msh.addCylinder(Vector3(-TOLPPA_GAP, BRIDGE_FLOOR + BRIDGE_THICKNESS1, BRIDGE_AWAY_MIDDLE),
      Vector3(-TOLPPA_GAP, BRIDGE_UP, BRIDGE_AWAY_MIDDLE), BRIDGE_THICKNESS2,
      BRIDGE_THICKNESS2, 7, BRIDGE_EDGE_COLOR, Vector3(0.0f, 0.0f, 1.0f), Mesh::SIDE_NO_BACK_NO_FRONT);

  switch(segment)
  {
    case 2:
      msh.addCylinder(Vector3(-TOLPPA_GAP, BRIDGE_FLOOR, BRIDGE_AWAY_MIDDLE),
          Vector3(0.0f, BRIDGE_UP * 1.5f, BRIDGE_AWAY_MIDDLE), BRIDGE_THICKNESS3, BRIDGE_THICKNESS3,
          8, BRIDGE_RAIL_COLOR, Vector3(0.0f, 1.0f, 0.0f), Mesh::SIDE_NO_BACK_NO_FRONT);
      break;

    case 1:
      msh.addCylinder(Vector3(0.0f, BRIDGE_FLOOR, BRIDGE_AWAY_MIDDLE),
          Vector3(-TOLPPA_GAP, BRIDGE_UP * 1.5f, BRIDGE_AWAY_MIDDLE), BRIDGE_THICKNESS3, BRIDGE_THICKNESS3,
          8, BRIDGE_RAIL_COLOR, Vector3(0.0f, 1.0f, 0.0f), Mesh::SIDE_NO_BACK_NO_FRONT);
      break;

    case 0:
    default:
      msh.addCylinder(Vector3(start_coord, BRIDGE_FLOOR, BRIDGE_AWAY_MIDDLE),
          Vector3(-TOLPPA_GAP, BRIDGE_UP, BRIDGE_AWAY_MIDDLE), BRIDGE_THICKNESS3, BRIDGE_THICKNESS3,
          8, BRIDGE_RAIL_COLOR, Vector3(0.0f, 1.0f, 0.0f), Mesh::SIDE_NO_BACK_NO_FRONT);
      msh.addCylinder(Vector3(-TOLPPA_GAP * 0.5f - BRIDGE_INDENT, BRIDGE_FLOOR, BRIDGE_AWAY_MIDDLE),
          Vector3(-TOLPPA_GAP, BRIDGE_UP * 0.5f, BRIDGE_AWAY_MIDDLE), BRIDGE_THICKNESS4, BRIDGE_THICKNESS4,
          8, BRIDGE_RAIL_COLOR, Vector3(0.0f, 1.0f, 0.0f), Mesh::SIDE_NO_BACK_NO_FRONT);
      break;
  }

  return msh.insert(vertex_buffer);
}

/** \brief Generate skyway.
 *
 * \param vertex_buffer Vertex buffer to insert into.
 * \param sloped Is this a sloped part?
 * \return Mesh generated.
 */
static CompiledMesh* generate_skyway(VertexBuffer *vertex_buffer, bool sloped)
{
  const float SKYWAY_AWAY1 = -2.5f;
  const float SKYWAY_AWAY2 = -4.1f;
  const float SKYWAY_FLOOR1 = -1.4f;
  const float SKYWAY_FLOOR2 = -1.9f;
  const float SKYWAY_THICKNESS1 = 0.45f;
  const float SKYWAY_THICKNESS2 = 0.094f;
  const float SKYWAY_RAIL1 = -1.5f;
  const float SKYWAY_RAIL2 = -0.7f;
  const float SKYWAY_UP = 6.0f;
  const float SKYWAY_ATAN = dnload_atanf(SKYWAY_SLOPE / TOLPPA_GAP);
  const Vector3 SKYWAY_UNIT_UP(dnload_sinf(SKYWAY_ATAN), dnload_cosf(SKYWAY_ATAN), 0.0f);
  const Color BRIDGE_FLOOR_COLOR(152, 142, 132, 255);
  const Color BRIDGE_RAIL_COLOR(227, 187, 175, 255);
  const Color TUNNEL_COLOR(63, 58, 65, 255);
  const Color TUNNEL_COLOR2(73, 67, 79, 255);
  Vector3 unit_up = sloped ? SKYWAY_UNIT_UP : Vector3(0.0f, 1.0f, 0.0f);
  float end_down = sloped ? SKYWAY_SLOPE : 0.0f;
  Mesh msh;

  msh.addBox(Vector3(-TOLPPA_GAP, SKYWAY_FLOOR1 + end_down - 0.01f, 0.0f),
      Vector3(0.0f, SKYWAY_FLOOR1, SKYWAY_AWAY1), BRIDGE_FLOOR_COLOR, Vector3(0.0f, 0.0f, -1.0f),
      unit_up, Mesh::SIDE_TOP);
  msh.addBox(Vector3(-TOLPPA_GAP, SKYWAY_FLOOR2 + end_down - 0.01f, SKYWAY_AWAY1),
      Vector3(0.0f, SKYWAY_FLOOR2, SKYWAY_AWAY2), TUNNEL_COLOR2, Vector3(0.0f, 0.0f, -1.0f),
      unit_up, Mesh::SIDE_TOP);

  msh.addCylinder(
      Vector3(-TOLPPA_GAP, SKYWAY_FLOOR2 + end_down - SKYWAY_THICKNESS1, SKYWAY_AWAY2 + SKYWAY_THICKNESS1),
      Vector3(-TOLPPA_GAP, SKYWAY_FLOOR2 + end_down + SKYWAY_UP, SKYWAY_AWAY2 + SKYWAY_THICKNESS1),
      SKYWAY_THICKNESS1, SKYWAY_THICKNESS1, 4, BRIDGE_RAIL_COLOR, Vector3(0.0f, 0.0f, -1.0f),
      Mesh::SIDE_NO_BACK_NO_FRONT);

  msh.addCylinder(
      Vector3(-TOLPPA_GAP, SKYWAY_RAIL1 + end_down, SKYWAY_AWAY2 + SKYWAY_THICKNESS1),
      Vector3(0.0f, SKYWAY_RAIL1, SKYWAY_AWAY2 + SKYWAY_THICKNESS1),
      SKYWAY_THICKNESS2, SKYWAY_THICKNESS2, 7, BRIDGE_RAIL_COLOR, Vector3(0.0f, 0.0f, -1.0f),
      Mesh::SIDE_NO_BACK_NO_FRONT);
  msh.addCylinder(
      Vector3(-TOLPPA_GAP, SKYWAY_RAIL2 + end_down, SKYWAY_AWAY2 + SKYWAY_THICKNESS1),
      Vector3(0.0f, SKYWAY_RAIL2, SKYWAY_AWAY2 + SKYWAY_THICKNESS1),
      SKYWAY_THICKNESS2, SKYWAY_THICKNESS2, 7, BRIDGE_RAIL_COLOR, Vector3(0.0f, 0.0f, -1.0f),
      Mesh::SIDE_NO_BACK_NO_FRONT);
   
  return msh.insert(vertex_buffer);
}

/** \brief Generate highway.
 *
 * \param vertex_buffer Vertex buffer to insert into.
 * \return Mesh generated.
 */
static CompiledMesh* generate_highway(VertexBuffer *vertex_buffer, float height, bool optimized)
{
  const float HIGHWAY_WIDTH1 = 2.0f;
  const float HIGHWAY_WIDTH2 = 3.0f;
  const float HIGHWAY_WIDTH3 = 5.0f;
  const float HIGHWAY_WIDTH4 = 3.8f;
  const float HIGHWAY_EDGE = 0.5f;
  const float HIGHWAY_RADIUS1 = HIGHWAY_EDGE * 2.2f;
  const float HIGHWAY_RADIUS2 = HIGHWAY_EDGE * 0.8f;
  const Color HIGHWAY_COLOR(93, 90, 107, 255);
  const Color HIGHWAY_RAIL_COLOR(227, 147, 122, 255);
  const Color HIGHWAY_FLOOR_COLOR(63, 59, 76, 255);
  float highway_height1 = height + 0.5f;
  float highway_height2 = height + 1.6f;
  float highway_height3 = height + 2.6f;
  float highway_height4 = height + 4.6f;
  float highway_height5 = height + 8.7f;
  uint8_t side_back = optimized ? 0 : Mesh::SIDE_BACK;
  uint8_t side_front = optimized ? 0 : Mesh::SIDE_FRONT;
  Mesh msh;

  msh.addCylinder(Vector3(-TOLPPA_GAP, 0.0f, 0.0f), Vector3(-TOLPPA_GAP, height, 0.0f),
      HIGHWAY_WIDTH1 - 0.5f, HIGHWAY_WIDTH1 - 0.5f, 8, HIGHWAY_COLOR, Vector3(0.0f, 0.0f, -1.0f),
      Mesh::SIDE_NO_BACK_NO_FRONT);

  msh.addCylinder(Vector3(-TOLPPA_GAP * 0.5f, 0.0f, -HIGHWAY_WIDTH3 - HIGHWAY_EDGE),
      Vector3(-TOLPPA_GAP * 0.5f, highway_height2, -HIGHWAY_WIDTH3 - HIGHWAY_EDGE),
      HIGHWAY_RADIUS1, HIGHWAY_RADIUS1, 4, HIGHWAY_COLOR, Vector3(0.0f, 0.0f, -1.0f),
      Mesh::SIDE_NO_BACK_NO_FRONT);
  msh.addCylinder(Vector3(-TOLPPA_GAP * 0.5f, highway_height2, -HIGHWAY_WIDTH3 - HIGHWAY_EDGE),
      Vector3(-TOLPPA_GAP * 0.5f, highway_height4, -HIGHWAY_WIDTH3 - HIGHWAY_EDGE),
      HIGHWAY_RADIUS1, HIGHWAY_RADIUS2, 4, HIGHWAY_COLOR, Vector3(0.0f, 0.0f, -1.0f),
      Mesh::SIDE_NO_BACK_NO_FRONT);
  msh.addAngle(Vector3(-TOLPPA_GAP * 0.5f, highway_height4, -HIGHWAY_WIDTH3 - HIGHWAY_EDGE),
      Vector3(-TOLPPA_GAP * 0.5f, highway_height5, -HIGHWAY_WIDTH3 - HIGHWAY_EDGE),
      Vector3(-TOLPPA_GAP * 0.5f, highway_height5, -HIGHWAY_WIDTH4),
      HIGHWAY_RADIUS2, 4, HIGHWAY_COLOR, Mesh::SIDE_NO_BOTTOM);

  msh.addBox(Vector3(-TOLPPA_GAP, height, -HIGHWAY_WIDTH1),
      Vector3(0.0f, highway_height1, HIGHWAY_WIDTH1), HIGHWAY_COLOR, Vector3(0.0f, 0.0f, -1.0f),
      Vector3(0.0f, 1.0f, 0.0f), Mesh::SIDE_BOTTOM | Mesh::SIDE_FRONT | Mesh::SIDE_BACK);

  msh.addBox(Vector3(-TOLPPA_GAP, highway_height1, -HIGHWAY_WIDTH1 + 0.5f),
      Vector3(0.0f, highway_height2, -HIGHWAY_WIDTH2), HIGHWAY_COLOR, Vector3(0.0f, 0.0f, -1.0f),
      Vector3(0.0f, 1.0f, 0.0f), Mesh::SIDE_BOTTOM | Mesh::SIDE_FRONT | side_back);
  msh.addBox(Vector3(-TOLPPA_GAP, highway_height1, HIGHWAY_WIDTH1 - 0.5f),
      Vector3(0.0f, highway_height2, HIGHWAY_WIDTH2), HIGHWAY_COLOR, Vector3(0.0f, 0.0f, -1.0f),
      Vector3(0.0f, 1.0f, 0.0f), Mesh::SIDE_BOTTOM | Mesh::SIDE_BACK | side_front);

  msh.addBox(Vector3(-TOLPPA_GAP, highway_height2, -HIGHWAY_WIDTH2 + 0.5f),
      Vector3(0.0f, highway_height3, -HIGHWAY_WIDTH3), HIGHWAY_COLOR, Vector3(0.0f, 0.0f, -1.0f),
      Vector3(0.0f, 1.0f, 0.0f), Mesh::SIDE_BOTTOM | Mesh::SIDE_FRONT | side_back);
  msh.addBox(Vector3(-TOLPPA_GAP, highway_height2, HIGHWAY_WIDTH2 - 0.5f),
      Vector3(0.0f, highway_height3, HIGHWAY_WIDTH3), HIGHWAY_COLOR, Vector3(0.0f, 0.0f, -1.0f),
      Vector3(0.0f, 1.0f, 0.0f), Mesh::SIDE_BOTTOM | Mesh::SIDE_BACK | side_front);

  msh.addBox(Vector3(-TOLPPA_GAP, highway_height3, -HIGHWAY_WIDTH3),
      Vector3(0.0f, highway_height3 + HIGHWAY_EDGE, -HIGHWAY_WIDTH3 + HIGHWAY_EDGE), HIGHWAY_RAIL_COLOR,
      Vector3(0.0f, 0.0f, -1.0f), Vector3(0.0f, 1.0f, 0.0f),
      Mesh::SIDE_TOP | (optimized ? Mesh::SIDE_BACK : (Mesh::SIDE_BACK | Mesh::SIDE_FRONT)));
  msh.addBox(Vector3(-TOLPPA_GAP, highway_height3, HIGHWAY_WIDTH3),
      Vector3(0.0f, highway_height3 + HIGHWAY_EDGE, HIGHWAY_WIDTH3 - HIGHWAY_EDGE), HIGHWAY_RAIL_COLOR,
      Vector3(0.0f, 0.0f, -1.0f), Vector3(0.0f, 1.0f, 0.0f),
      Mesh::SIDE_TOP | (optimized ? Mesh::SIDE_FRONT : (Mesh::SIDE_BACK | Mesh::SIDE_FRONT)));

  msh.addBox(Vector3(-TOLPPA_GAP, highway_height3, -HIGHWAY_WIDTH3 + HIGHWAY_EDGE),
      Vector3(0.0f, highway_height3 + 0.05f, HIGHWAY_WIDTH3 - HIGHWAY_EDGE), HIGHWAY_FLOOR_COLOR,
      Vector3(0.0f, 0.0f, -1.0f), Vector3(0.0f, 1.0f, 0.0f),
      Mesh::SIDE_TOP);

  return msh.insert(vertex_buffer);
}

/** \brief Add pier block into a mesh.
 *
 * \param mesh Mesh to add to.
 */
static void generate_pier_block(Mesh *msh, const Vector3 &p1, const Vector3 &p2)
{
  const float PIER_RADIUS1 = 0.8f;
  const float PIER_RADIUS2 = 0.65f;
  const float PIER_HEIGHT1 = -0.3f;
  const float PIER_HEIGHT2 = 0.6f;
  const float PIER_HEIGHT3 = 5.0f;
  const float PIER_HEIGHT4 = 5.9f;
  const float PIER_HEIGHT5 = 6.8f;
  const Color PIER_BLOCK_COLOR(73, 67, 79, 255);
  float height1 = PIER_HEIGHT1 - p1[1];
  Vector3 up1 = Vector3(0.0f, 1.0f, 0.0f) * height1;
  Vector3 up2 = Vector3(0.0f, 1.0f, 0.0f) * (PIER_HEIGHT2 - p1[1]);
  Vector3 up3 = Vector3(0.0f, 1.0f, 0.0f) * (PIER_HEIGHT3 - p1[1]);
  Vector3 up4 = Vector3(0.0f, 1.0f, 0.0f) * (PIER_HEIGHT4 - p1[1]);

  msh->addElongatedCylinder(p1, p2,
      PIER_RADIUS1, PIER_RADIUS1, height1, 4, PIER_BLOCK_COLOR,
      Vector3(0.0f, 1.0f, 0.0f), Mesh::SIDE_NO_BACK_NO_FRONT);
  msh->addElongatedCylinder(p1 + up1, p2 + up1,
      PIER_RADIUS1, PIER_RADIUS2, PIER_HEIGHT2 - PIER_HEIGHT1, 4, PIER_BLOCK_COLOR,
      Vector3(0.0f, 1.0f, 0.0f), Mesh::SIDE_NO_BACK_NO_FRONT);
  msh->addElongatedCylinder(p1 + up2, p2 + up2,
      PIER_RADIUS2, PIER_RADIUS2, PIER_HEIGHT3 - PIER_HEIGHT2, 4, PIER_BLOCK_COLOR,
      Vector3(0.0f, 1.0f, 0.0f), Mesh::SIDE_NO_BACK_NO_FRONT);
  msh->addElongatedCylinder(p1 + up3, p2 + up3,
      PIER_RADIUS2, PIER_RADIUS1, PIER_HEIGHT4 - PIER_HEIGHT3, 4, PIER_BLOCK_COLOR,
      Vector3(0.0f, 1.0f, 0.0f), Mesh::SIDE_NO_BACK_NO_FRONT);
  msh->addElongatedCylinder(p1 + up4, p2 + up4,
      PIER_RADIUS1, PIER_RADIUS1, PIER_HEIGHT5 - PIER_HEIGHT4, 4, PIER_BLOCK_COLOR,
      Vector3(0.0f, 1.0f, 0.0f), Mesh::SIDE_NO_BACK_NO_FRONT);
}

/** \brief Generate pier start.
 *
 * Generates pier starting block, this is a very specific element, the rest of the pier repeats itself.
 *
 * \param vertex_buffer Vertex buffer to insert into.
 * \param block Index of pier block, 0 = start, 1 = first block, 2 = all the rest.
 * \return Mesh generated.
 */
static CompiledMesh* generate_pier(VertexBuffer *vertex_buffer, unsigned block)
{
  const float BLOCK_DISTANCE = 12.0f;
  const float BLOCK_WIDTH1 = 2.4f;
  const float BLOCK_WIDTH2 = 4.2f;
  const float BLOCK_UP = 12.0f;
  const float BLOCK_AWAY = -5.5f;
  const float BLOCK_LEFT1 = -9.0f;
  const float BLOCK_LEFT2 = -12.0f;
  const float SKYWAY_AWAY1 = -2.5f;
  const float SKYWAY_AWAY2 = -4.1f;
  const float PIER_AWAY2 = SKYWAY_AWAY2 - 3.5f;
  const float PIER_AWAY3 = PIER_AWAY2 - 14.0f;
  const float PIER_AWAY4 = PIER_AWAY3 - 14.0f;
  const float PIER_RADIUS1 = 0.08f;
  const float PIER_RADIUS2 = 0.12f;
  const float PIER_HEIGHT4 = 5.6f;
  const float PIER_HEIGHT5 = 6.8f;
  const float SKYWAY_FLOOR1 = -1.4f;
  const float SKYWAY_FLOOR2 = -1.9f;
  const float PIER_FLOOR = -1.2f;
  const Color PIER_FLAT_COLOR(93, 90, 107, 255);
  const Color PIER_BLOCK_COLOR(73, 67, 79, 255);
  const Color BRIDGE_FLOOR_COLOR(152, 142, 132, 255);
  const Color TUNNEL_COLOR2(73, 67, 79, 255);
  const Color PIER_RAIL_COLOR(227, 187, 175, 255);
  bool start = (block == 0);
  float right1 = start ? -BLOCK_WIDTH1 : 0.0f;
  float right2 = start ? (-BLOCK_WIDTH1 * 3.0f) : 0.0f;
  Mesh msh;

  msh.addBox(Vector3(-TOLPPA_GAP, SKYWAY_FLOOR1 - 0.01f, 0.0f),
      Vector3(0.0f, SKYWAY_FLOOR1, SKYWAY_AWAY1), BRIDGE_FLOOR_COLOR, Vector3(0.0f, 0.0f, -1.0f),
      Vector3(0.0f, 1.0f, 0.0f), Mesh::SIDE_TOP);
  msh.addBox(Vector3(-TOLPPA_GAP, SKYWAY_FLOOR2 - 0.01f, SKYWAY_AWAY1),
      Vector3(0.0f, SKYWAY_FLOOR2, SKYWAY_AWAY2), TUNNEL_COLOR2, Vector3(0.0f, 0.0f, -1.0f),
      Vector3(0.0f, 1.0f, 0.0f), Mesh::SIDE_TOP);

  switch(block)
  {
    case 2:
      generate_pier_block(&msh, Vector3(-TOLPPA_GAP * 0.3f, PIER_FLOOR, PIER_AWAY4),
          Vector3(-TOLPPA_GAP * 0.7f, PIER_FLOOR, PIER_AWAY4));
      // Intentional fallthrough.

    case 1:
      generate_pier_block(&msh, Vector3(-TOLPPA_GAP, PIER_FLOOR, PIER_AWAY2),
          Vector3(-TOLPPA_GAP * 0.6f, PIER_FLOOR, PIER_AWAY2));
      generate_pier_block(&msh, Vector3(-TOLPPA_GAP * 0.4f, PIER_FLOOR, PIER_AWAY3),
          Vector3(0.0f, PIER_FLOOR, PIER_AWAY3));
      break;

    case 0:
    default:
      generate_pier_block(&msh, Vector3(-TOLPPA_GAP, PIER_FLOOR, PIER_AWAY2),
          Vector3(-TOLPPA_GAP * 0.65f, PIER_FLOOR, PIER_AWAY2));
      generate_pier_block(&msh, Vector3(-TOLPPA_GAP * 0.55f, PIER_FLOOR, PIER_AWAY3),
          Vector3(-TOLPPA_GAP * 0.25f, PIER_FLOOR, PIER_AWAY3));
      generate_pier_block(&msh, Vector3(-TOLPPA_GAP * 1.7f, PIER_FLOOR, PIER_AWAY4 + 0.2f),
          Vector3(-TOLPPA_GAP * 0.5f, PIER_FLOOR, PIER_AWAY4 + 0.2f));
      break;
  }

  if(start)
  {
    for(float ii = BLOCK_AWAY; (ii > -82.0f); ii -= BLOCK_DISTANCE)
    {
      msh.addCylinder(Vector3(0.0f, -BLOCK_WIDTH1 * 2.0f, ii), Vector3(BLOCK_LEFT1, BLOCK_UP, ii),
          BLOCK_WIDTH1, BLOCK_WIDTH1, 4, PIER_BLOCK_COLOR, Vector3(0.0f, 0.0f, -1.0f),
          Mesh::SIDE_NO_BACK_NO_FRONT);

      msh.addCylinder(Vector3(0.0f, -BLOCK_WIDTH2 * 2.0f, ii - BLOCK_DISTANCE * 0.5f),
          Vector3(BLOCK_LEFT2, BLOCK_UP, ii - BLOCK_DISTANCE * 0.5f),
          BLOCK_WIDTH2, BLOCK_WIDTH2, 4, PIER_FLAT_COLOR, Vector3(0.0f, 0.0f, -1.0f),
          Mesh::SIDE_NO_BACK_NO_FRONT);
    }
  }

  for(float ii = SKYWAY_AWAY2; (ii > -40.0f); ii -= 14.0f)
  {
    msh.addCylinder(Vector3(-TOLPPA_GAP, PIER_HEIGHT4, ii - 9.0f),
        Vector3(right2, PIER_HEIGHT4, ii - 9.0f), PIER_RADIUS2, PIER_RADIUS2, 6, PIER_RAIL_COLOR,
        Vector3(0.0f, 0.0f, -1.0f), Mesh::SIDE_NO_BACK_NO_FRONT);
    msh.addCylinder(Vector3(-TOLPPA_GAP, PIER_HEIGHT4, ii - 11.0f),
        Vector3(right2, PIER_HEIGHT4, ii - 11.0f), PIER_RADIUS2, PIER_RADIUS2, 6, PIER_RAIL_COLOR,
        Vector3(0.0f, 0.0f, -1.0f), Mesh::SIDE_NO_BACK_NO_FRONT);
    msh.addCylinder(Vector3(-TOLPPA_GAP, PIER_HEIGHT4, ii - 9.0f),
        Vector3(-TOLPPA_GAP, PIER_HEIGHT5, ii - 9.0f), PIER_RADIUS1, PIER_RADIUS1, 6, PIER_RAIL_COLOR,
        Vector3(0.0f, 0.0f, -1.0f), Mesh::SIDE_NO_BACK_NO_FRONT);
    msh.addCylinder(Vector3(-TOLPPA_GAP * 0.5f, PIER_HEIGHT4, ii - 9.0f),
        Vector3(-TOLPPA_GAP * 0.5f, PIER_HEIGHT5, ii - 9.0f), PIER_RADIUS1, PIER_RADIUS1, 6, PIER_RAIL_COLOR,
        Vector3(0.0f, 0.0f, -1.0f), Mesh::SIDE_NO_BACK_NO_FRONT);
    msh.addCylinder(Vector3(-TOLPPA_GAP * 0.25f, PIER_HEIGHT4, ii - 11.0f),
        Vector3(-TOLPPA_GAP * 0.25f, PIER_HEIGHT5, ii - 11.0f), PIER_RADIUS1, PIER_RADIUS1, 6, PIER_RAIL_COLOR,
        Vector3(0.0f, 0.0f, -1.0f), Mesh::SIDE_NO_BACK_NO_FRONT);
    msh.addCylinder(Vector3(-TOLPPA_GAP * 0.75f, PIER_HEIGHT4, ii - 11.0f),
        Vector3(-TOLPPA_GAP * 0.75f, PIER_HEIGHT5, ii - 11.0f), PIER_RADIUS1, PIER_RADIUS1, 6, PIER_RAIL_COLOR,
        Vector3(0.0f, 0.0f, -1.0f), Mesh::SIDE_NO_BACK_NO_FRONT);

    msh.addBox(Vector3(-TOLPPA_GAP, SKYWAY_FLOOR2, ii),
        Vector3(right1, PIER_FLOOR, ii - 7.0f), PIER_FLAT_COLOR, Vector3(0.0f, 0.0f, -1.0f),
        Vector3(0.0f, 1.0f, 0.0f), Mesh::SIDE_FRONT | Mesh::SIDE_TOP);
  }

  msh.addBox(Vector3(-TOLPPA_GAP, PIER_HEIGHT5, 0.0f), Vector3(right2, PIER_HEIGHT5 + 0.01f, -40.0f),
      PIER_FLAT_COLOR, Vector3(0.0f, 0.0f, -1.0f), Vector3(0.0f, 1.0f, 0.0f), Mesh::SIDE_BOTTOM);

  return msh.insert(vertex_buffer);
}

/** \brief Generate city wall.
 *
 * \param vertex_buffer Vertex buffer to insert into.
 * \return Mesh generated.
 */
static CompiledMesh* generate_city_wall(VertexBuffer *vertex_buffer)
{
  const float WALL_BOTTOM = WATER_LEVEL;
  const float WALL_HEIGHT1 = 18.0f;
  const float WALL_HEIGHT2 = 13.0f;
  const float WALL_THICKNESS1 = 3.0f;
  const float WALL_THICKNESS2 = 2.0f;
  const float WALL_START = -6.0f;
  const float WALL_SEGMENT_HORIZONTAL = 18.0f;
  const float WALL_SEGMENT_HORIZONTAL_JITTER = 6.0f;
  const float WALL_SEGMENT_VERTICAL = 28.0f;
  const float WALL_SEGMENT_VERTICAL_JITTER = 8.0f;
  const Color WALL_COLOR1(63, 58, 65, 255);
  const Color WALL_COLOR2(93, 90, 107, 255);
  bool left = false;
  Mesh msh;

  for(float x1 = 0.0f, z1 = WALL_START;;)
  {
    float z2 = z1 - WALL_SEGMENT_VERTICAL;
    float x2 = x1 + (left ? -WALL_SEGMENT_HORIZONTAL : WALL_SEGMENT_HORIZONTAL);
    
    z2 += frand(-WALL_SEGMENT_VERTICAL_JITTER, WALL_SEGMENT_VERTICAL_JITTER);
    x2 += frand(-WALL_SEGMENT_HORIZONTAL_JITTER * 1.5f, WALL_SEGMENT_HORIZONTAL_JITTER * 0.5f);

    msh.addBox(Vector3(x1 - WALL_THICKNESS2, WALL_BOTTOM, z1),
        Vector3(x1 + WALL_THICKNESS2, WALL_HEIGHT2, z2 + WALL_THICKNESS1), WALL_COLOR2,
        Vector3(0.0f, 0.0f, -1.0f), Vector3(0.0f, 1.0f, 0.0f), Mesh::SIDE_RIGHT);

    msh.addBox(Vector3(x1 - WALL_THICKNESS1, WALL_BOTTOM, z2 + WALL_THICKNESS1),
        Vector3(x1 + WALL_THICKNESS1, WALL_HEIGHT1, z2 - WALL_THICKNESS1), WALL_COLOR1,
        Vector3(0.0f, 0.0f, -1.0f), Vector3(0.0f, 1.0f, 0.0f), Mesh::SIDE_RIGHT | Mesh::SIDE_FRONT);

    if(HORIZON >= z2)
    {
      break;
    }

    msh.addBox(Vector3(x2 - WALL_THICKNESS1, WALL_BOTTOM, z2 + WALL_THICKNESS1),
        Vector3(x2 + WALL_THICKNESS1, WALL_HEIGHT1, z2 - WALL_THICKNESS1), WALL_COLOR1,
        Vector3(0.0f, 0.0f, -1.0f), Vector3(0.0f, 1.0f, 0.0f), Mesh::SIDE_RIGHT | Mesh::SIDE_FRONT);

    if(left)
    {
      msh.addBox(Vector3(x2 + WALL_THICKNESS1, WALL_BOTTOM, z2 + WALL_THICKNESS2),
          Vector3(x1 - WALL_THICKNESS1, WALL_HEIGHT2, z2 - WALL_THICKNESS2), WALL_COLOR2,
          Vector3(0.0f, 0.0f, -1.0f), Vector3(0.0f, 1.0f, 0.0f), Mesh::SIDE_FRONT);
    }
    else
    {
      msh.addBox(Vector3(x1 + WALL_THICKNESS1, WALL_BOTTOM, z2 + WALL_THICKNESS2),
          Vector3(x2 - WALL_THICKNESS1, WALL_HEIGHT2, z2 - WALL_THICKNESS2), WALL_COLOR2,
          Vector3(0.0f, 0.0f, -1.0f), Vector3(0.0f, 1.0f, 0.0f), Mesh::SIDE_FRONT);
    }

    x1 = x2;
    z1 = z2;
    left = !left;
  }

  return msh.insert(vertex_buffer);
};

/** \brief Generate tunnel segment.
 *
 * \param vertex_buffer Vertex buffer to insert into.
 * \param firdt Is this the last tunnel segment?
 * \return Mesh generated.
 */
static CompiledMesh* generate_tunnel_segment(VertexBuffer* vertex_buffer, bool first)
{
  const float TUNNEL_NEAR = -0.5f;
  const float TUNNEL_AWAY1 = -2.0f;
  const float TUNNEL_AWAY2 = -4.2f;
  const float TUNNEL_AWAY3 = -3.2f;
  const float TUNNEL_AWAY4 = -3.7f;
  const float TUNNEL_UP1 = 3.0f;
  const float TUNNEL_UP2 = 4.0f;
  const float TUNNEL_DOWN1 = -1.4f;
  const float TUNNEL_DOWN2 = -1.9f;
  const float SEGMENT_WIDTH = TOLPPA_GAP * 0.031f;
  const Color TUNNEL_COLOR(63, 58, 65, 255);
  const Color TUNNEL_COLOR2(72, 66, 92, 255);
  Mesh msh;

  msh.addBox(Vector3(-TOLPPA_GAP, TUNNEL_DOWN2, TUNNEL_NEAR),
      Vector3(0.0f, TUNNEL_DOWN1, TUNNEL_AWAY1), TUNNEL_COLOR,
      Vector3(0.0f, 0.0f, -1.0f), Vector3(0.0f, 1.0f, 0.0f), Mesh::SIDE_TOP);
  msh.addBox(Vector3(-TOLPPA_GAP, TUNNEL_DOWN2 - 1.0f, TUNNEL_AWAY1),
      Vector3(0.0f, TUNNEL_DOWN2, TUNNEL_AWAY2), TUNNEL_COLOR2,
      Vector3(0.0f, 0.0f, -1.0f), Vector3(0.0f, 1.0f, 0.0f), Mesh::SIDE_TOP);

  for(unsigned ii = 0; (ii < 4); ++ii)
  {
    float x1 = static_cast<float>(ii) * (-TOLPPA_GAP / 4.0f);
    float x4 = static_cast<float>(ii + 1) * (-TOLPPA_GAP / 4.0f);
    float x2 = x1 - SEGMENT_WIDTH * 1.2f;
    float x3 = x4 + SEGMENT_WIDTH * 1.2f;
    float y1 = TUNNEL_DOWN2;
    float y2 = TUNNEL_UP1;
    float y3 = TUNNEL_UP2;
    float z1 = TUNNEL_AWAY2;
    float z2 = z1 + SEGMENT_WIDTH * 0.45f;
    float z3 = TUNNEL_NEAR;
    float z4 = z3 + SEGMENT_WIDTH * 0.45f;

    unsigned index_base = static_cast<unsigned>(msh.getLogicalVertexCount());

    msh.addVertex(x1, y1, z1);
    msh.addVertex(x1, y2, z1);
    msh.addVertex(x1, y3, z3);

    msh.addVertex(x2, y1, z1);
    msh.addVertex(x2, y2, z1);
    msh.addVertex(x2, y3, z3);

    msh.addVertex(x2, y1, z2);
    msh.addVertex(x2, y2, z2);
    msh.addVertex(x2, y3, z4);

    msh.addVertex(x3, y1, z2);
    msh.addVertex(x3, y2, z2);
    msh.addVertex(x3, y3, z4);

    msh.addVertex(x3, y1, z1);
    msh.addVertex(x3, y2, z1);
    msh.addVertex(x3, y3, z3);

    msh.addVertex(x4, y1, z1);
    msh.addVertex(x4, y2, z1);
    msh.addVertex(x4, y3, z3);

    msh.addFace(index_base + 0, index_base + 1, index_base + 4, index_base + 3, TUNNEL_COLOR2);
    msh.addFace(index_base + 1, index_base + 2, index_base + 5, index_base + 4, TUNNEL_COLOR2);
    msh.addFace(index_base + 3, index_base + 4, index_base + 7, index_base + 6, TUNNEL_COLOR2);
    msh.addFace(index_base + 4, index_base + 5, index_base + 8, index_base + 7, TUNNEL_COLOR2);
    msh.addFace(index_base + 6, index_base + 7, index_base + 10, index_base + 9, TUNNEL_COLOR2);
    msh.addFace(index_base + 7, index_base + 8, index_base + 11, index_base + 10, TUNNEL_COLOR2);
    msh.addFace(index_base + 9, index_base + 10, index_base + 13, index_base + 12, TUNNEL_COLOR2);
    msh.addFace(index_base + 10, index_base + 11, index_base + 14, index_base + 13, TUNNEL_COLOR2);
    msh.addFace(index_base + 12, index_base + 13, index_base + 16, index_base + 15, TUNNEL_COLOR2);
    msh.addFace(index_base + 13, index_base + 14, index_base + 17, index_base + 16, TUNNEL_COLOR2);

    if((ii == 0) && first)
    {
      msh.addAngle(Vector3(x1, y1, TUNNEL_AWAY3), Vector3(x1, y2, TUNNEL_AWAY3), Vector3(x1, y3, z3),
          SEGMENT_WIDTH, 4, TUNNEL_COLOR, Mesh::SIDE_NO_BOTTOM_NO_TOP);
    }
    msh.addAngle(Vector3(x4, y1, TUNNEL_AWAY4), Vector3(x4, y2, TUNNEL_AWAY4), Vector3(x4, y3, z3),
        SEGMENT_WIDTH * 0.7f, 4, TUNNEL_COLOR, Mesh::SIDE_NO_BOTTOM_NO_TOP);
  }
  
  return msh.insert(vertex_buffer);
}

/** \brief Generate window.
 *
 * Generates the 'window' through which the world is observed. This is actually one of the more complex
 * objects since it isn't a 'sum' of other objects.
 *
 * \param vertex_buffer Vertex buffer to insert into.
 * \return Object generated.
 */
static Object* generate_window(VertexBuffer *vertex_buffer)
{
  const float FRAME_WIDTH = 0.04f;
  const float FRAME_ELEVATION = 0.005f;
  const float EXTENT = 1.0f;
  const float WINDOW_LEFT = -0.7f;
  const float WINDOW_RIGHT = 0.5f;
  const float WINDOW_BOTTOM = -0.3f;
  const float WINDOW_BEAM = 0.205f;
  const Color FRAME_COLOR(64, 54, 45, 255);
  const Color WINDOW_COLOR(164, 117, 71, 255);
  Mesh msh;

  // Window extents, vertices 0-7.
  msh.addVertex(-EXTENT, EXTENT, 0.0f);
  msh.addVertex(-EXTENT, -EXTENT, 0.0f);
  msh.addVertex(EXTENT, -EXTENT, 0.0f);
  msh.addVertex(EXTENT, EXTENT, 0.0f);
  msh.addVertex(WINDOW_RIGHT, EXTENT, 0.0f);
  msh.addVertex(WINDOW_RIGHT, WINDOW_BOTTOM, 0.0f);
  msh.addVertex(WINDOW_LEFT, WINDOW_BOTTOM, 0.0f);
  msh.addVertex(WINDOW_LEFT, EXTENT, 0.0f);

  // Window frame front, vertices 8-19.
  msh.addVertex(WINDOW_LEFT, EXTENT, FRAME_ELEVATION);
  msh.addVertex(WINDOW_LEFT, WINDOW_BOTTOM, FRAME_ELEVATION);
  msh.addVertex(WINDOW_RIGHT, WINDOW_BOTTOM, FRAME_ELEVATION);
  msh.addVertex(WINDOW_RIGHT, EXTENT, FRAME_ELEVATION);
  msh.addVertex(WINDOW_RIGHT - FRAME_WIDTH, EXTENT, FRAME_ELEVATION);
  msh.addVertex(WINDOW_RIGHT - FRAME_WIDTH, WINDOW_BEAM, FRAME_ELEVATION);
  msh.addVertex(WINDOW_RIGHT - FRAME_WIDTH, WINDOW_BEAM - FRAME_WIDTH, FRAME_ELEVATION);
  msh.addVertex(WINDOW_RIGHT - FRAME_WIDTH, WINDOW_BOTTOM + FRAME_WIDTH, FRAME_ELEVATION);
  msh.addVertex(WINDOW_LEFT + FRAME_WIDTH, WINDOW_BOTTOM + FRAME_WIDTH, FRAME_ELEVATION);
  msh.addVertex(WINDOW_LEFT + FRAME_WIDTH, WINDOW_BEAM - FRAME_WIDTH, FRAME_ELEVATION);
  msh.addVertex(WINDOW_LEFT + FRAME_WIDTH, WINDOW_BEAM, FRAME_ELEVATION);
  msh.addVertex(WINDOW_LEFT + FRAME_WIDTH, EXTENT, FRAME_ELEVATION);

  // Window frame back, vertices 20-27.
  msh.addVertex(WINDOW_LEFT + FRAME_WIDTH, EXTENT, -FRAME_ELEVATION);
  msh.addVertex(WINDOW_LEFT + FRAME_WIDTH, WINDOW_BEAM, -FRAME_ELEVATION);
  msh.addVertex(WINDOW_LEFT + FRAME_WIDTH, WINDOW_BEAM - FRAME_WIDTH, -FRAME_ELEVATION);
  msh.addVertex(WINDOW_LEFT + FRAME_WIDTH, WINDOW_BOTTOM + FRAME_WIDTH, -FRAME_ELEVATION);
  msh.addVertex(WINDOW_RIGHT - FRAME_WIDTH, WINDOW_BOTTOM + FRAME_WIDTH, -FRAME_ELEVATION);
  msh.addVertex(WINDOW_RIGHT - FRAME_WIDTH, WINDOW_BEAM - FRAME_WIDTH, -FRAME_ELEVATION);
  msh.addVertex(WINDOW_RIGHT - FRAME_WIDTH, WINDOW_BEAM, -FRAME_ELEVATION);
  msh.addVertex(WINDOW_RIGHT - FRAME_WIDTH, EXTENT, -FRAME_ELEVATION);

  // Window base.
  msh.addFace(0, 1, 6, 7, WINDOW_COLOR);
  msh.addFace(1, 2, 5, 6, WINDOW_COLOR);
  msh.addFace(2, 3, 4, 5, WINDOW_COLOR);

  // Window frame outer bevel.
  msh.addFace(4, 11, 10, 5, FRAME_COLOR, false);
  msh.addFace(5, 10, 9, 6, FRAME_COLOR, false);
  msh.addFace(6, 9, 8, 7, FRAME_COLOR, false);

  // Window frame face.
  msh.addFace(8, 9, 18, 19, FRAME_COLOR);
  msh.addFace(9, 10, 15, 16, FRAME_COLOR);
  msh.addFace(9, 17, 18, FRAME_COLOR);
  msh.addFace(9, 16, 17, FRAME_COLOR);
  msh.addFace(10, 11, 12, 13, FRAME_COLOR);
  msh.addFace(10, 13, 14, FRAME_COLOR);
  msh.addFace(10, 14, 15, FRAME_COLOR);
  msh.addFace(13, 18, 17, 14, FRAME_COLOR);

  // Window frame inner bevel.
  msh.addFace(12, 27, 26, 13, FRAME_COLOR);
  msh.addFace(13, 26, 21, 18, FRAME_COLOR);
  msh.addFace(14, 17, 22, 25, FRAME_COLOR);
  msh.addFace(14, 25, 24, 15, FRAME_COLOR);
  msh.addFace(15, 24, 23, 16, FRAME_COLOR);
  msh.addFace(16, 23, 22, 17, FRAME_COLOR);
  msh.addFace(18, 21, 20, 19, FRAME_COLOR);

  return new Object(msh.insert(vertex_buffer));
}

/** \brief Generate a horizon object.
 *
 * \param vertex_buffer Vertex buffer to insert into.
 * \param sky Which sky to generate, 0 for land, 1 for city, 2 for pier.
 * \return Object generated.
 */
static Object* generate_horizon(VertexBuffer *vertex_buffer, unsigned sky)
{
  const float SKY_LEFT = -280.0f;
  const float SKY_RIGHT = 240.0f;
  const Color SKY_BASE_COLOR(255, 255, 255, 255);
  float back;
  float down;
  float up;
  Color color_up;
  Color color_down;
  Mesh msh;

  switch(sky)
  {
    case 2:
      back = -40.0f;
      down = -4.0f;
      up = 8.0f;
      color_up = Color(160, 255, 255, 255);
      color_down = Color(220, 255, 255, 255);
      break;

    case 1:
      back = HORIZON - 8.0f;
      down = -8.0f;
      up = 255.0f;
      color_up = Color(255, 255, 0, 255);
      color_down = Color(255, 0, 0, 255);
      break;

    case 0:
    default:
      back = HORIZON - 8.0f;
      down = WATER_LEVEL - 4.0f;
      up = 255.0f;
      color_up = Color(51, 32, 255, 255);
      color_down = Color(110, 130, 255, 255);
      break;
  }

  msh.addVertex(SKY_LEFT, down, back, color_down);
  msh.addVertex(SKY_RIGHT, down, back, color_down);
  msh.addVertex(SKY_RIGHT, up, back, color_up);
  msh.addVertex(SKY_LEFT, up, back, color_up);

  msh.addFace(0, 1, 2, 3);

  return new Object(msh.insert(vertex_buffer));
}

/** \brief Generate apartment block color.
 *
 * \return Color for an apartment block.
 */
static Color generate_apartment_block_color()
{
  return mix(Color(198, 194, 191, 255), Color(208, 172, 136, 255), frand(1.0f));
}

/** \brief Generate apartment block color.
 *
 * \return Color for an apartment block.
 */
static Color generate_apartment_frame_color()
{
  return mix(Color(134, 105, 89, 255), Color(133, 141, 152, 255), frand(1.0f));
}

/** \brief Generate apartment block color.
 *
 * \return Color for an apartment block.
 */
static Color generate_skyscraper_base_color()
{
  return mix(Color(198, 194, 191, 255), Color(208, 172, 136, 255), frand(1.0f));
}

/** \brief Generate apartment block color.
 *
 * \return Color for an apartment block.
 */
static Color generate_skyscraper_detail_color()
{
  return mix(Color(134, 105, 89, 255), Color(133, 141, 152, 255), frand(1.0f));
}

/** \brief Decorate apartment block.
 *
 * \param msh Mesh to decorate into.
 * \param pos Center position.
 * \param width Width to go (at maximum).
 * \param depth Depth to go (at maximum).
 * \param height Base height (don't go near this even).
 * \param unit_rt Right direction.
 * \param unit_fw Forward direction.
 */
void decorate_apartment_block(Mesh *msh, const Vector3 &pos, float width, float depth, float height,
    const Vector3 &unit_rt, const Vector3 &unit_fw, const Color &color)
{
  const Vector3 UNIT_UP(0.0f, 1.0f, 0.0f);
  float rt = frand(-width * 0.8f, width * 0.8f);
  float fw = frand(-depth * 0.8f, depth * 0.8f);
  float avg = (width + depth) * 0.5f;
  Vector3 actual_pos = pos + rt * unit_rt + fw * unit_fw;

  if(bsd_rand() % 2)
  {
    float radius = frand(avg * 0.15f, avg * 0.2f);
    float ht = frand(height * 0.1f, height * 0.2f);

    msh->addCylinder(actual_pos, actual_pos + UNIT_UP * ht, radius, radius * 0.9f, 4, color, unit_fw,
        Mesh::SIDE_NO_BOTTOM);
  }
  else
  {
    float radius = frand(avg * 0.1f, avg * 0.15f);
    float ht = frand(height * 0.3f, height * 0.4f);

    msh->addCylinder(actual_pos, actual_pos + UNIT_UP * ht, radius, radius, 8, color, unit_fw,
        Mesh::SIDE_NO_BOTTOM);
  }
}

/** \brief Extend apartment block.
 *
 * \param msh Mesh to write into.
 *
 * \param pos Center pos of wall to extend from.
 * \param dir Direction to extend to.
 * \param width Extent of this wall (left and right).
 * \param depth Extend at most this amount.
 * \param height Height of wall.
 */
static void extend_apartment_block(Mesh *msh, const Vector3 &pos, const Vector3 &dir, float width,
    float depth, float height, const Color &base_color, const Color &frame_color,
    const Color &decoration_color, unsigned extensions_left = 2)
{
  const Vector3 UNIT_UP(0.0f, 1.0f, 0.0f);
  const float ROOF_EXTENT = 0.3f;
  const float ROOF_HEIGHT = 0.4f;
  Vector3 unit_fw = normalize(dir);
  Vector3 unit_rt = normalize(cross_product(dir, UNIT_UP));
  float actual_height = frand(height * 0.6f, height * 0.95f);
  float left = frand(-width * 1.25f, width * 1.25f);
  float right = frand(-width * 1.25f , width * 1.25f);
  float actual_depth = frand(depth * 0.3f, depth * 0.7f);
  float actual_lt = dnload_fminf(left, right);
  float actual_rt = dnload_fmaxf(left, right);
  Vector3 lt = Vector3(pos + unit_rt * actual_lt);
  Vector3 rt = Vector3(pos + unit_rt * actual_rt + unit_fw * actual_depth + actual_height * UNIT_UP);
  float actual_width = actual_rt - actual_lt;

  if((width * 0.1f > actual_width) || (1.0f > actual_width))
  {
    //std::cout << width << " vs. " << actual_width << std::endl;
    return;
  }

  msh->addBox(lt, rt, base_color, unit_fw, UNIT_UP, Mesh::SIDE_NO_BOTTOM);
  msh->addBox(lt - unit_rt * ROOF_EXTENT + UNIT_UP * actual_height,
      rt + (unit_rt + unit_fw) * ROOF_EXTENT + UNIT_UP * ROOF_HEIGHT, frame_color, unit_fw, UNIT_UP);

  if(0 >= extensions_left)
  {
    return;
  }

  int extensions = bsd_rand() % 3;
  for(int ii = 0; (ii < extensions); ++ii)
  {
    int direction = bsd_rand() % 3;

    switch(direction)
    {
      case 2:
        extend_apartment_block(msh, pos + unit_rt * (actual_rt + actual_lt) * 0.5f + unit_fw * actual_depth,
            unit_fw, actual_width * 0.5f, (actual_width + actual_depth) * 0.5f, actual_height, base_color,
            frame_color, decoration_color, extensions_left - 1);
        break;

      case 1:
        extend_apartment_block(msh, pos + unit_rt * actual_rt + unit_fw * actual_depth * 0.5f,
            unit_rt, actual_depth * 0.5f, (actual_width + actual_depth) * 0.5f, actual_height, base_color,
            frame_color, decoration_color, extensions_left - 1);
        break;

      case 0:
      default:
        extend_apartment_block(msh, pos + unit_rt * actual_lt + unit_fw * actual_depth * 0.5f,
            -unit_rt, actual_depth * 0.5f, (actual_width + actual_depth) * 0.5f, actual_height, base_color,
            frame_color, decoration_color, extensions_left - 1);
        break;
    }
  }

  extensions = bsd_rand() % 2 + bsd_rand() % 2;
  for(int ii = 0; (ii < extensions); ++ii)
  {
    decorate_apartment_block(msh,
        Vector3(pos + (unit_rt * (actual_lt + actual_rt) * 0.5f) + unit_fw * actual_depth * 0.5f +
          UNIT_UP * (actual_height + ROOF_HEIGHT)),
        actual_width * 0.5f, actual_depth * 0.5f, actual_height, unit_rt, unit_fw, decoration_color);
  }
}

/** \brief Generate an apartment house.
 *
 * Generation of apartment houses is randomized. It is probably a bad idea to use the same house twice.
 *
 * \param vertex_buffer Vertex buffer to insert into.
 * \param seed Seed to use for generation.
 * \param height Desired height of house (altered by randomness).
 * \param width Desired width of house side (altered by randomness).
 * \return Mesh generated.
 */
CompiledMesh* generate_apartment_block(VertexBuffer *vertex_buffer, unsigned seed, float height, float width,
    float depth = 0.0f)
{
  const float ROOF_EXTENT = 0.3f;
  const float ROOF_HEIGHT = 0.4f;

  bsd_srand(seed);

  if(depth <= 0.0f)
  {
    depth = width;
  }

  float actual_height = frand(height * 0.75f, height * 1.25f);
  float actual_width = frand(width * 0.75f, width * 1.25f);
  float actual_depth = frand(depth * 0.75f, depth * 1.25f);
  Color base_color = generate_apartment_block_color();
  Color frame_color = generate_apartment_frame_color();
  Color decoration_color = generate_apartment_block_color();
  Mesh msh;

  int extensions = bsd_rand() % 6;
  for(int ii = 0; (ii < extensions); ++ii)
  {
    int direction = bsd_rand() % 4;

    switch(direction)
    {
      case 3:
        extend_apartment_block(&msh, Vector3(actual_width * 0.5f, 0.0f, actual_depth),
            Vector3(0.0f, 0.0f, 1.0f), actual_width * 0.5f, (actual_width + actual_depth) * 0.5f,
            actual_height, base_color, frame_color, decoration_color);
        break;

      case 2:
        extend_apartment_block(&msh, Vector3(actual_width * 0.5f, 0.0f, 0.0f),
            Vector3(0.0f, 0.0f, -1.0f), actual_width * 0.5f, (actual_width + actual_depth) * 0.5f,
            actual_height, base_color, frame_color, decoration_color);
        break;

      case 1:
        extend_apartment_block(&msh, Vector3(actual_width, 0.0f, actual_depth * 0.5f),
            Vector3(1.0f, 0.0f, 0.0f), actual_depth * 0.5f, (actual_width + actual_depth) * 0.5f,
            actual_height, base_color, frame_color, decoration_color);
        break;

      case 0:
      default:
        extend_apartment_block(&msh, Vector3(0.0f, 0.0f, actual_depth * 0.5f),
            Vector3(-1.0f, 0.0f, 0.0f), actual_depth * 0.5f, (actual_width + actual_depth) * 0.5f,
            actual_height, base_color, frame_color, decoration_color);
        break;
    }
  }

  extensions = bsd_rand() % 3 + bsd_rand() % 3;
  for(int ii = 0; (ii < extensions); ++ii)
  {
    decorate_apartment_block(&msh,
        Vector3(actual_width * 0.5f, actual_height + ROOF_HEIGHT, actual_depth * 0.5f),
        actual_width *  0.5f, actual_depth * 0.5f, actual_height, Vector3(1.0f, 0.0f, 0.0f),
        Vector3(0.0f, 0.0f, 1.0f), decoration_color);
  }

  // Add innermost thingy last since it's likely to be masked by extents, reducing overdraw.
  msh.addBox(Vector3(0.0f, 0.0f, 0.0f), Vector3(actual_width, actual_height, actual_depth), base_color,
      Vector3(0.0f, 0.0f, -1.0f), Vector3(0.0f, 1.0f, 0.0f), Mesh::SIDE_NO_BOTTOM);
  msh.addBox(Vector3(-ROOF_EXTENT, actual_height, -ROOF_EXTENT),
      Vector3(actual_width + ROOF_EXTENT, actual_height + ROOF_HEIGHT, actual_depth + ROOF_EXTENT),
      frame_color);

  return msh.insert(vertex_buffer);
}

/** \brief Generate station.
 *
 * Generates 'bönde' train station.
 *
 * \param vertex_buffer Vertex buffer to insert into.
 * \params seed Random seed for station.
 * \return Mesh generated.
 */
static CompiledMesh* generate_station(VertexBuffer *vertex_buffer, unsigned seed)
{
  const float FRONT_LEFT = -18.0f;
  const float FRONT_RIGHT = 0.0f;
  const float BACK_LEFT = -26.0f;
  const float BACK_RIGHT = 8.0f;
  const float MID_LEFT = (FRONT_LEFT + BACK_LEFT) * 0.5f;
  const float MID_RIGHT = (FRONT_RIGHT + BACK_RIGHT) * 0.5f;
  const float BASE_AWAY1 = -1.8f;
  const float BASE_AWAY2 = -5.0f;
  const float MID_AWAY = (BASE_AWAY2 + BASE_AWAY1) * 0.5f;
  const float BASE_AWAY3 = -7.5f;
  const float BASE_AWAY4 = -17.0f;
  const float BASE_UP1 = -1.2f;
  const float BASE_UP2 = -1.35f;
  const float BASE_UP3 = -1.5f;
  const float BASE_DOWN1 = -2.8f;
  const float BASE_DOWN2 = -6.5f;
  const float BASE_INDENT = 2.0f;
  const float ROOF_INDENT = 0.5f;
  const float PILLAR_RADIUS = 0.22f;
  const float PERUSTUS_INDENT = 1.2f;
  const float PERUSTUS_RADIUS = 0.8f;
  const float NEG_INDENT = BASE_INDENT - ROOF_INDENT;
  const float ROOF_HEIGHT = 0.4f;
  const float ROOF_UP = 4.0f;
  const Color BASE_COLOR(178, 152, 119, 255);

  bsd_srand(seed);

  float base_x1 = frand(BACK_LEFT + BASE_INDENT, BACK_RIGHT - BASE_INDENT);
  float base_x2 = frand(BACK_LEFT + BASE_INDENT, BACK_RIGHT - BASE_INDENT);
  float roof = frand(ROOF_UP * 0.75f, ROOF_UP * 1.25f) + BASE_UP3;
  float house_left = dnload_fminf(base_x1, base_x2);
  float house_right = dnload_fmaxf(base_x1, base_x2);
  float house_width = house_right - house_left;
  float house_mid = (house_left + house_right) * 0.5f;
  float house_away = frand(BASE_AWAY3 * 1.25f, BASE_AWAY3 * 0.75f);
  float house_depth = house_away - (BASE_AWAY4 + NEG_INDENT);
  float house_mid_away = (house_away + (BASE_AWAY4 + NEG_INDENT)) * 0.5f;
  Color pillar_color = generate_apartment_frame_color();
  Color frame_color = generate_apartment_frame_color();
  Mesh msh;

  for(unsigned ii = 0; (ii <= 3); ++ii)
  {
    float fi = static_cast<float>(ii) / 3.0f;
    float pos = FRONT_LEFT + ROOF_INDENT + (FRONT_RIGHT - ROOF_INDENT - (FRONT_LEFT + ROOF_INDENT)) * fi;

    msh.addAngle(Vector3(pos, BASE_UP1, BASE_AWAY1 - ROOF_INDENT),
        Vector3(pos, ROOF_UP * 0.2f, BASE_AWAY1 - ROOF_INDENT),
        Vector3(pos, ROOF_UP, 0.0f), PILLAR_RADIUS, 4, frame_color, Mesh::SIDE_NO_BOTTOM_NO_TOP);
  }

  msh.addBox(Vector3(FRONT_LEFT, BASE_DOWN1, BASE_AWAY1), Vector3(FRONT_RIGHT, BASE_UP1, MID_AWAY),
      BASE_COLOR, Vector3(0.0f, 0.0f, -1.0f), Vector3(0.0f, 1.0f, 0.0f), Mesh::SIDE_NO_BACK_NO_BOTTOM);
  msh.addBox(Vector3(MID_LEFT, BASE_DOWN1, MID_AWAY), Vector3(MID_RIGHT, BASE_UP2, BASE_AWAY2),
      BASE_COLOR, Vector3(0.0f, 0.0f, -1.0f), Vector3(0.0f, 1.0f, 0.0f), Mesh::SIDE_NO_BACK_NO_BOTTOM);
  msh.addBox(Vector3(BACK_LEFT, BASE_DOWN1, BASE_AWAY2), Vector3(BACK_RIGHT, BASE_UP3, BASE_AWAY4),
      BASE_COLOR, Vector3(0.0f, 0.0f, -1.0f), Vector3(0.0f, 1.0f, 0.0f), Mesh::SIDE_NO_BACK_NO_BOTTOM);

  int extensions = bsd_rand() % 3;
  for(int ii = 0; (ii < extensions); ++ii)
  {
    extend_apartment_block(&msh, Vector3(house_mid, BASE_UP3, house_away),
        Vector3(0.0f, 0.0f, 1.0f), house_width * 0.5f, house_depth * 0.5f, roof, BASE_COLOR,
        frame_color, pillar_color);
  }

  msh.addBox(Vector3(house_left, BASE_UP3, house_away), Vector3(house_right, roof, BASE_AWAY4 + BASE_INDENT),
      generate_apartment_block_color(), Vector3(0.0f, 0.0f, -1.0f), Vector3(0.0f, 1.0f, 0.0f),
      Mesh::SIDE_NO_BACK_NO_BOTTOM_NO_TOP);
  msh.addBox(Vector3(BACK_LEFT + NEG_INDENT, roof, house_away + ROOF_INDENT),
      Vector3(BACK_RIGHT - NEG_INDENT, roof + ROOF_HEIGHT, BASE_AWAY4 + NEG_INDENT),
      frame_color, Vector3(0.0f, 0.0f, -1.0f), Vector3(0.0f, 1.0f, 0.0f), Mesh::SIDE_NO_BACK_NO_TOP);

  extensions = bsd_rand() % 3 + bsd_rand() % 3;
  for(int ii = 0; (ii < extensions); ++ii)
  {
    decorate_apartment_block(&msh,
        Vector3(house_mid, roof + ROOF_HEIGHT, house_mid_away), house_width * 0.5f, house_depth * 0.5f,
        roof * 3.0f, Vector3(1.0f, 0.0f, 0.0f), Vector3(0.0f, 0.0f, -1.0f), pillar_color);
  }

  extensions = bsd_rand() % 3;
  for(int ii = 0; (ii < extensions); ++ii)
  {
    extend_apartment_block(&msh, Vector3(house_right, BASE_UP3, house_mid_away),
        Vector3(1.0f, 0.0f, 0.0f), house_depth * 0.5f, house_width * 0.5f, roof, BASE_COLOR, 
        frame_color, pillar_color);
  }
  extensions = bsd_rand() % 3;
  for(int ii = 0; (ii < extensions); ++ii)
  {
    extend_apartment_block(&msh, Vector3(house_left, BASE_UP3, house_mid_away),
        Vector3(-1.0f, 0.0f, 0.0f), house_depth * 0.5f, house_width * 0.5f, roof, BASE_COLOR,
        frame_color, pillar_color);
  }

  msh.addCylinder(Vector3(BACK_LEFT + NEG_INDENT + ROOF_INDENT, BASE_UP3, house_away - ROOF_INDENT),
      Vector3(BACK_LEFT + NEG_INDENT + ROOF_INDENT, roof, house_away - ROOF_INDENT),
      PILLAR_RADIUS, PILLAR_RADIUS, 7, pillar_color, Vector3(0.0f, 0.0f, -1.0f), Mesh::SIDE_NO_BACK_NO_FRONT);
  msh.addCylinder(Vector3(BACK_LEFT + NEG_INDENT + ROOF_INDENT, BASE_UP3, BASE_AWAY4 + NEG_INDENT + ROOF_INDENT),
      Vector3(BACK_LEFT + NEG_INDENT + ROOF_INDENT, roof, BASE_AWAY4 + NEG_INDENT + ROOF_INDENT),
      PILLAR_RADIUS, PILLAR_RADIUS, 7, pillar_color, Vector3(0.0f, 0.0f, -1.0f), Mesh::SIDE_NO_BACK_NO_FRONT);
  msh.addCylinder(Vector3(BACK_RIGHT - NEG_INDENT - ROOF_INDENT, BASE_UP3, house_away - ROOF_INDENT),
      Vector3(BACK_RIGHT - NEG_INDENT - ROOF_INDENT, roof, house_away - ROOF_INDENT),
      PILLAR_RADIUS, PILLAR_RADIUS, 7, pillar_color, Vector3(0.0f, 0.0f, -1.0f), Mesh::SIDE_NO_BACK_NO_FRONT);
  msh.addCylinder(Vector3(BACK_RIGHT - NEG_INDENT - ROOF_INDENT, BASE_UP3, BASE_AWAY4 + NEG_INDENT + ROOF_INDENT),
      Vector3(BACK_RIGHT - NEG_INDENT - ROOF_INDENT, roof, BASE_AWAY4 + NEG_INDENT + ROOF_INDENT),
      PILLAR_RADIUS, PILLAR_RADIUS, 7, pillar_color, Vector3(0.0f, 0.0f, -1.0f), Mesh::SIDE_NO_BACK_NO_FRONT);

  msh.addCylinder(Vector3(BACK_LEFT + PERUSTUS_INDENT, BASE_DOWN1, BASE_AWAY4 + ROOF_INDENT),
      Vector3(BACK_LEFT + PERUSTUS_INDENT, BASE_DOWN2, BASE_AWAY4 + ROOF_INDENT),
      PERUSTUS_RADIUS, PERUSTUS_RADIUS, 6, pillar_color, Vector3(0.0f, 0.0f, -1.0f),
      Mesh::SIDE_NO_BACK_NO_FRONT);
  msh.addCylinder(Vector3(BACK_LEFT + PERUSTUS_INDENT, BASE_DOWN1, BASE_AWAY3 - PERUSTUS_INDENT),
      Vector3(BACK_LEFT + PERUSTUS_INDENT, BASE_DOWN2, BASE_AWAY3 - PERUSTUS_INDENT),
      PERUSTUS_RADIUS, PERUSTUS_RADIUS, 6, pillar_color, Vector3(0.0f, 0.0f, -1.0f),
      Mesh::SIDE_NO_BACK_NO_FRONT);
  msh.addCylinder(Vector3(BACK_RIGHT - PERUSTUS_INDENT, BASE_DOWN1, BASE_AWAY3 - PERUSTUS_INDENT),
      Vector3(BACK_RIGHT - PERUSTUS_INDENT, BASE_DOWN2, BASE_AWAY3 - PERUSTUS_INDENT),
      PERUSTUS_RADIUS, PERUSTUS_RADIUS, 6, pillar_color, Vector3(0.0f, 0.0f, -1.0f),
      Mesh::SIDE_NO_BACK_NO_FRONT);
  msh.addCylinder(Vector3(BACK_RIGHT - PERUSTUS_INDENT, BASE_DOWN1, BASE_AWAY4 + ROOF_INDENT),
      Vector3(BACK_RIGHT - PERUSTUS_INDENT, BASE_DOWN2, BASE_AWAY4 + ROOF_INDENT),
      PERUSTUS_RADIUS, PERUSTUS_RADIUS, 6, pillar_color, Vector3(0.0f, 0.0f, -1.0f),
      Mesh::SIDE_NO_BACK_NO_FRONT);

  return msh.insert(vertex_buffer);
}

/** \brief Generate skyscraper detail.
 *
 * \param msh Mesh to insert to.
 * \param base_pos Base position to move from.
 * \param height Height (to rise up).
 * \param current_width Current width (distance to randomize in).
 * \param difference Difference to move away (in axises)
 * \param sub_width Sub-width of detail
 * \param detail_color Color of detail.
 */
void generate_skyscraper_detail(Mesh *msh, Vector3 base_pos, float height, float current_width,
    float difference, float sub_width, const Color &detail_color, unsigned range_iterator, unsigned range)
{
  const Vector3 UNIT_FW(0.0f, 0.0f, 1.0f);
  const Vector3 UNIT_UP(0.0f, 1.0f, 0.0f);
  float offset = frand(-current_width, current_width);
  float roof = frand(height * 0.3f, height * 0.9f);
  Vector3 pos = base_pos;

  unsigned side = (static_cast<unsigned>(bsd_rand()) + range_iterator) % range;

  switch(side)
  {
    case 3:
      pos += Vector3(offset, 0.0f, -difference);
      break;

    case 2:
      pos += Vector3(offset, 0.0f, difference);
      break;

    case 1:
      pos += Vector3(-difference, 0.0f, offset);
      break;

    case 0:
    default:
      pos += Vector3(difference, 0.0f, offset);
      break;
  }

  msh->addCylinder(pos, pos + UNIT_UP * roof, sub_width, sub_width, 4, detail_color, UNIT_FW,
      Mesh::SIDE_NO_BACK_NO_FRONT);
  msh->addCylinder(pos + UNIT_UP * roof, pos + UNIT_UP * (roof + sub_width), sub_width,
      sub_width * 0.6f, 4, detail_color, UNIT_FW, Mesh::SIDE_NO_FRONT);
}

/** \brief Generate a skyscraper
 *
 * \param vertex_buffer Vertex buffer to insert into.
 * \param height Height of one block.
 * \param width Maximum width.
 * \return Mesh generated.
 */
static CompiledMesh* generate_skyscraper(VertexBuffer *vertex_buffer, unsigned seed, float height, float width)
{
  const Vector3 UNIT_FW(0.0f, 0.0f, 1.0f);
  const Vector3 UNIT_UP(0.0f, 1.0f, 0.0f);

  bsd_srand(seed);

  Vector3 pos(0.0f, 0.0f, 0.0f);
  float current_height = 0.0f;
  float next_height = frand(height * 0.75f, height * 1.25f);
  float current_width = frand(width * 0.75f, width * 1.25f);
  float depth = frand(width, width * 2.0f);
  float sub_width = frand(current_width * 0.15f, current_width * 0.25f);
  unsigned blocks = bsd_rand() % 2 + 2;
  bool style = (bsd_rand() % 2 == 0);
  Color base_color = generate_skyscraper_base_color();
  Color detail_color = generate_skyscraper_detail_color();
  Mesh msh;

  for(unsigned ii = 0; (ii < blocks); ++ii)
  {
    bool last = (blocks - 1 <= ii);

    // Square-style 'empire state' skyscraper.
    if(style)
    {
      if(ii == 0)
      {
        msh.addCylinder(Vector3(0.0f, current_height, 0.0f), Vector3(0.0f, next_height, 0.0f), current_width,
            current_width, 4, base_color, UNIT_FW, Mesh::SIDE_NO_BACK_NO_FRONT);
      }
      else
      {
        float elevation = frand(height * 0.1f, height * 0.2f);

        msh.addCylinder(Vector3(0.0f, current_height, 0.0f), Vector3(0.0f, current_height + elevation, 0.0f),
            current_width + sub_width * 1.4142f, current_width, 4, detail_color, UNIT_FW,
            Mesh::SIDE_NO_BACK_NO_FRONT);
        msh.addCylinder(Vector3(0.0f, current_height + elevation, 0.0f), Vector3(0.0f, next_height, 0.0f),
            current_width, current_width, 4, base_color, UNIT_FW,
            Mesh::SIDE_NO_BACK_NO_FRONT);
      }

      if(last)
      {
        float elevation = frand(height * 0.1f, height * 0.2f);

        msh.addCylinder(Vector3(0.0f, next_height, 0.0f), Vector3(0.0f, next_height + elevation, 0.0f),
            current_width, current_width - sub_width * 1.4142f, 4, detail_color, UNIT_FW,
            Mesh::SIDE_NO_FRONT);
      }

      unsigned detail_count = bsd_rand() % 6 + 3;
      for(unsigned jj = 0; (jj < detail_count); ++jj)
      {
        float diff = frand(sub_width * 0.1f);

        generate_skyscraper_detail(&msh, Vector3(0.0f, current_height, 0.0f), next_height - current_height,
            current_width * 0.7071f, current_width * 0.7071f + (sub_width - diff) * (0.7071f * 0.7071f),
            sub_width * 0.7071f, detail_color, jj, 4);
      }
    }
    // Elongated 'brutalist' (?) skyscraper.
    else
    {
      if(ii == 0)
      {
        msh.addElongatedCylinder(pos, pos + UNIT_FW * depth, current_width, current_width,
            next_height - current_height, 4, base_color, UNIT_UP, Mesh::SIDE_NO_BACK_NO_FRONT);
      }
      else
      {
        float elevation = frand(height * 0.1f, height * 0.2f);

        msh.addElongatedCylinder(pos, pos + UNIT_FW * depth, current_width + sub_width * 1.4142f,
            current_width, elevation, 4, detail_color, UNIT_UP, Mesh::SIDE_NO_BACK_NO_FRONT);
        msh.addElongatedCylinder(pos + UNIT_UP * elevation, pos + UNIT_FW * depth + UNIT_UP * elevation,
            current_width, current_width, next_height - elevation - current_height, 4, base_color,
            UNIT_UP, Mesh::SIDE_NO_BACK_NO_FRONT);
      }

      if(last)
      {
        Vector3 last_pos = pos + UNIT_UP * (next_height - current_height);
        float elevation = frand(height * 0.1f, height * 0.2f);

        msh.addElongatedCylinder(last_pos, last_pos + UNIT_FW * depth, current_width,
            current_width - sub_width * 1.4142f, elevation, 4, detail_color, UNIT_UP, Mesh::SIDE_NO_FRONT);
      }

      unsigned detail_count = bsd_rand() % 6 + 1;
      for(unsigned jj = 0; (jj < detail_count); ++jj)
      {
        float diff = frand(sub_width * 0.1f);

        generate_skyscraper_detail(&msh, pos + UNIT_FW * (depth * 0.5f), next_height - current_height,
            depth * 0.7071f - sub_width * 1.4142f, current_width + (sub_width - diff) * 0.7071f, sub_width,
            detail_color, jj, 2);
      }
    }

    float height_diff = next_height - current_height;

    pos += UNIT_UP * (next_height - current_height);
    current_height = next_height;
    next_height = current_height + frand(height_diff * 0.8f, height_diff * 1.3f);
    sub_width = frand(current_width * 0.15f, current_width * 0.25f);
    current_width -= sub_width * 1.4142f;
  }

  return msh.insert(vertex_buffer);
}

/** \brief Generate apartment block color.
 *
 * \return Color for an apartment block.
 */
static Color generate_factory_base_color()
{
  return mix(Color(255, 142, 121, 255), Color(240, 142, 121, 255), frand(1.0f));
}

/** \brief Generate apartment block color.
 *
 * \return Color for an apartment block.
 */
static Color generate_factory_frame_color()
{
  return mix(Color(240, 240, 255, 255), Color(140, 140, 255, 255), frand(1.0f));
}

/** \brief Generate apartment block color.
 *
 * \return Color for an apartment block.
 */
static Color generate_factory_silo_color()
{
  return mix(Color(162, 255, 255, 255), Color(220, 255, 255, 255), frand(1.0f));
}

/** \brief Generate factory building complex thingy.
 *
 * \param vertex_buffer Vertex buffer to insert into.
 * \param seed Random seed.
 * \param height Height directive.
 * \param width Width directive.
 * \return Mesh generated.
 */
static CompiledMesh* generate_factory_building(VertexBuffer *vertex_buffer, unsigned seed, float height,
    float width)
{
  const Vector3 UNIT_FW(0.0f, 0.0f, 1.0f);
  const Vector3 UNIT_UP(0.0f, 1.0f, 0.0f);

  bsd_srand(seed);

  float actual_width = frand(width * 0.75f, width * 1.25f);
  float actual_depth = frand(width * 3.0f, width * 5.0f);
  float actual_height = frand(height * 0.75f, height * 1.25f);
  Color color_base = generate_factory_base_color();
  Color color_frame = generate_factory_frame_color();
  Vector3 p1(0.0f, 0.0f, 0.0f);
  Vector3 p2(actual_depth, 0.0f, 0.0f);
  Mesh msh;

  msh.addElongatedCylinder(p1, p2, actual_width, actual_width, actual_height, 4, color_base, UNIT_UP,
      Mesh::SIDE_NO_BACK_NO_FRONT);
  p1 += UNIT_UP * actual_height;
  p2 += UNIT_UP * actual_height;
  msh.addElongatedCylinder(p1, p2, actual_width, actual_width * 0.8f, actual_height * 0.2f, 4, color_frame,
      UNIT_UP, Mesh::SIDE_NO_BACK_NO_FRONT);
  p1 += UNIT_UP * (actual_height * 0.2f);
  p2 += UNIT_UP * (actual_height * 0.2f);
  msh.addElongatedCylinder(p1, p2, actual_width * 0.8f, actual_width * 0.8f, actual_height, 4,
      color_base, UNIT_UP, Mesh::SIDE_NO_BACK_NO_FRONT);
  p1 += UNIT_UP * actual_height;
  p2 += UNIT_UP * actual_height;
  msh.addElongatedCylinder(p1, p2, actual_width * 0.8f, actual_width * 0.6f, actual_height * 0.2f, 4,
      color_frame, UNIT_UP, Mesh::SIDE_NO_FRONT);
  p1 += UNIT_UP * (actual_height * 0.2f);
  p2 += UNIT_UP * (actual_height * 0.2f);

  int extensions = bsd_rand() % 4 + 1;
  for(int ii = 0; (ii < extensions); ++ii)
  {
    Vector3 pos = mix(p1, p2, frand(1.0f));

    msh.addCylinder(pos, pos + UNIT_UP * frand(height * 0.3f, height * 0.8f), width * 0.1f, width * 0.1f, 6,
        color_frame, UNIT_FW, Mesh::SIDE_NO_FRONT);
  }

  return msh.insert(vertex_buffer);
}

/** \brief Generate factory fence.
 *
 * \param vertex_buffer Vertex buffer to insert into.
 * \param away Away distance.
 * \param p1 First X coordinate.
 * \param p2 Second X coordinate.
 * \param detail Number of posts.
 * \return Mesh generated.
 */
static CompiledMesh* generate_factory_fence(VertexBuffer* vertex_buffer, const HeightMap *hmap,
    const Color &color, const Vector3 &p1, const Vector3 &p2, unsigned detail)
{
  const Vector3 UNIT_FW(0.0f, 0.0f, 1.0f);
  const Vector3 UNIT_UP(0.0f, 1.0f, 0.0f);
  const float FENCE_UP1 = -1.8f;
  const float FENCE_UP2 = -2.8f;
  const float FENCE_UP3 = -4.1f;
  const float FENCE_UP4 = -5.4f;
  const float FENCE_RADIUS1 = 0.4f;
  const float FENCE_RADIUS2 = 0.2f;
  Vector3 dir = p2 - p1;
  Mesh msh;

  for(unsigned ii = 0; (ii <= detail); ++ii)
  {
    float fi = static_cast<float>(ii) / static_cast<float>(detail);
    Vector3 pos = p1 + (dir * fi);
    float ht = hmap->getMappedHeight(pos[0], pos[2]) - 0.5f;

    msh.addCylinder(pos + UNIT_UP * ht, pos + UNIT_UP * FENCE_UP1, FENCE_RADIUS1, FENCE_RADIUS1, 6, color,
        UNIT_FW, Mesh::SIDE_NO_FRONT);
  }

  msh.addCylinder(p1 + FENCE_UP2 * UNIT_UP, p2 + FENCE_UP2 * UNIT_UP, FENCE_RADIUS2, FENCE_RADIUS2, 6, color,
      UNIT_UP, Mesh::SIDE_NO_BACK_NO_FRONT);
  msh.addCylinder(p1 + FENCE_UP3 * UNIT_UP, p2 + FENCE_UP3 * UNIT_UP, FENCE_RADIUS2, FENCE_RADIUS2, 6, color,
      UNIT_UP, Mesh::SIDE_NO_BACK_NO_FRONT);
  msh.addCylinder(p1 + FENCE_UP4 * UNIT_UP, p2 + FENCE_UP4 * UNIT_UP, FENCE_RADIUS2, FENCE_RADIUS2, 6, color,
      UNIT_UP, Mesh::SIDE_NO_BACK_NO_FRONT);

  return msh.insert(vertex_buffer);
}

/** \brief Generate factory silo thingy.
 *
 * \param vertex_buffer Vertex buffer to insert into.
 * \param height Height directive.
 * \param width Width directive.
 * \return Mesh generated.
 */
static CompiledMesh* generate_factory_silo(VertexBuffer *vertex_buffer, unsigned seed, float height,
    float width)
{
  const Vector3 UNIT_FW(0.0f, 0.0f, 1.0f);
  const Vector3 UNIT_UP(0.0f, 1.0f, 0.0f);

  bsd_srand(seed);

  float actual_width = frand(width * 0.75f, width * 1.25f);
  float actual_height = frand(height * 0.75f, height * 1.25f);
  Color color_base = generate_factory_silo_color();
  Color color_frame = generate_factory_frame_color();
  Vector3 pos(0.0f, 0.0f, 0.0f);
  Mesh msh;

  msh.addCylinder(pos, pos + UNIT_UP * actual_height, actual_width, actual_width, 9, color_base, UNIT_FW,
      Mesh::SIDE_NO_BACK_NO_FRONT);
  pos += UNIT_UP * actual_height;
  msh.addCylinder(pos, pos + UNIT_UP * actual_height * 0.15f, actual_width, actual_width * 0.7f, 9,
      color_base, UNIT_FW, Mesh::SIDE_NO_BACK_NO_FRONT);
  pos += UNIT_UP * actual_height * 0.15f;
  msh.addCylinder(pos, pos + UNIT_UP * actual_height * 0.08f, actual_width * 0.7f, actual_width * 0.4f, 9,
      color_base, UNIT_FW, Mesh::SIDE_NO_FRONT);

  int extensions = (bsd_rand() % 4) + 3;
  for(int ii = 0; (ii < extensions); ++ii)
  {
    float rot = frand(static_cast<float>(M_PI * 2.0));
    float cr = dnload_cosf(rot);
    float sr = dnload_sinf(rot);

    pos = Vector3(cr, 0.0f, sr) * (actual_width * 1.05f);
    msh.addCylinder(pos, pos + UNIT_UP * (actual_height * 1.1f), actual_width * 0.1f, actual_width * 0.1f, 5,
        color_frame, UNIT_FW, Mesh::SIDE_NO_BACK_NO_FRONT);
    pos += UNIT_UP * (actual_height * 1.1f);
    msh.addCylinder(pos, pos + UNIT_UP * actual_height * 0.05f, actual_width * 0.1f, actual_width * 0.03f, 5,
        color_frame, UNIT_FW, Mesh::SIDE_NO_FRONT);
  }

  return msh.insert(vertex_buffer);
}

/** \brief Generate windmill base.
 *
 * \param vertexBuffer Vertex buffer to insert into.
 * \return Mesh generated.
 */
static CompiledMesh* generate_windmill_base(VertexBuffer *vertex_buffer)
{
  const Vector3 UNIT_FW(0.0f, 0.0f, 1.0f);
  const Vector3 UNIT_UP(0.0f, 1.0f, 0.0f);
  const float WINDMILL_RADIUS1 = 1.4f;
  const float WINDMILL_RADIUS2 = 0.7f;
  const float WINDMILL_RADIUS3 = 1.6f;
  const float WINDMILL_RADIUS4 = 0.7f;
  const float WINDMILL_FRONT = 2.0f;
  const float WINDMILL_BACK = -5.5f;
  const Color WINDMILL_COLOR(220, 230, 222, 255);
  Mesh msh;

  msh.addCylinder(Vector3(0.0f, WINDMILL_UP, WINDMILL_FRONT), Vector3(0.0f, WINDMILL_UP - 0.2f, WINDMILL_BACK),
      WINDMILL_RADIUS3, WINDMILL_RADIUS4, 7, WINDMILL_COLOR, UNIT_UP);
  msh.addCylinder(Vector3(0.0f, 0.0f, 0.0f), Vector3(0.0f, WINDMILL_UP, 0.0f), WINDMILL_RADIUS1,
      WINDMILL_RADIUS2, 7, WINDMILL_COLOR, UNIT_FW, Mesh::SIDE_NO_FRONT);

  return msh.insert(vertex_buffer);
}

/** \brief Generate windmill blades.
 *
 * \param vertexBuffer Vertex buffer to insert into.
 * \return Mesh generated.
 */
static CompiledMesh* generate_windmill_blades(VertexBuffer *vertex_buffer)
{
  const Vector3 UNIT_UP(0.0f, 1.0f, 0.0f);
  const float WINDMILL_FRONT1 = 2.0f;
  const float WINDMILL_FRONT2 = 3.4f;
  const float WINDMILL_RADIUS1 = 1.4f;
  const float WINDMILL_RADIUS2 = 0.4f;
  const float WINDMILL_LENGTH = 10.5f;
  const Color WINDMILL_COLOR(220, 230, 222, 255);
  Mesh msh;

  msh.addCylinder(Vector3(0.0f, 0.0f, WINDMILL_FRONT1), Vector3(0.0f, 0.0f, WINDMILL_FRONT2),
      WINDMILL_RADIUS1, WINDMILL_RADIUS2, 8, WINDMILL_COLOR, UNIT_UP, Mesh::SIDE_NO_FRONT);

  for(unsigned ii = 0; (ii < 3); ++ii)
  {
    float fi1 = static_cast<float>(ii) * static_cast<float>(M_PI * 2.0 / 3.0);
    float fi2 = static_cast<float>(ii) * static_cast<float>(M_PI * 2.0 / 3.0) + 0.44f;
    float fi3 = (fi1 + fi2) * 0.5f;
    float c1 = dnload_cosf(fi1) * (WINDMILL_RADIUS1 - 0.4f);
    float c2 = dnload_cosf(fi2) * (WINDMILL_RADIUS2 - 0.1f);
    float c3 = dnload_cosf(fi3);
    float s1 = dnload_sinf(fi1) * (WINDMILL_RADIUS1 - 0.4f);
    float s2 = dnload_sinf(fi2) * (WINDMILL_RADIUS2 - 0.1f);
    float s3 = dnload_sinf(fi3);
    Vector3 p1(c1, s1, WINDMILL_FRONT1 + 0.2f);
    Vector3 p2(c2, s2, WINDMILL_FRONT2 - 0.2f);
    Vector3 dir(c3, s3, 0.0f);

    msh.addElongatedCylinder(p1, p2, 0.2f, 0.1f, WINDMILL_LENGTH, 3, WINDMILL_COLOR, dir, Mesh::SIDE_NO_FRONT);
  }

  return msh.insert(vertex_buffer);
}

/** \brief Generate apartment block color.
 *
 * \return Color for an apartment block.
 */
static Color generate_tree_trunk_color()
{
  return mix(Color(47, 37, 28, 255), Color(47, 39, 30, 255), frand(1.0f));
}

/** \brief Generate apartment block color.
 *
 * \return Color for an apartment block.
 */
static Color generate_tree_leaf_color()
{
  return mix(Color(8, 47, 0, 255), Color(46, 86, 19, 255), frand(1.0f));
}

/** \brief Generate tree.
 *
 * Since I'm lazy, this is a kind of spruce or something.
 *
 * \param vertexBuffer Vertex buffer to insert into.
 * \param seed Random seed.
 * \return Mesh generated.
 */
static CompiledMesh* generate_tree(VertexBuffer *vertex_buffer, unsigned seed)
{
  const float TREE_HEIGHT = 14.0f;
  const float TREE_WIDTH = 0.4f;

  bsd_srand(seed);

  float height = frand(TREE_HEIGHT * 0.75f, TREE_HEIGHT);
  float width = frand(TREE_WIDTH * 0.9f, TREE_WIDTH * 1.1f);
  unsigned leaves = (bsd_rand() % 3) + 6;
  Color leaf_color = generate_tree_leaf_color();
  Color trunk_color = generate_tree_trunk_color();
  Mesh msh;

  for(unsigned ii = 0; (ii <= leaves); ++ii)
  {
    float fi = 1.0f - static_cast<float>(ii) / static_cast<float>(leaves) * 0.48f;
    float rot = frand(static_cast<float>(M_PI * 2.0));
    float rl = rot - static_cast<float>(M_PI * 0.45);
    float rr = rot + static_cast<float>(M_PI * 0.45);
    float ci = dnload_cosf(rot);
    float cl = dnload_cosf(rl);
    float cr = dnload_cosf(rr);
    float si = dnload_sinf(rot);
    float sl = dnload_sinf(rl);
    float sr = dnload_sinf(rr);
    float h1 = fi - 0.35f;
    float h2 = fi - 0.48f;
    float h3 = fi - 0.12f;
    float w0 = (1.0f - fi) * width;
    float w1 = (1.0f - h1) * width * 3.4f;
    float w2 = dnload_fmaxf((1.0f - h2) * width * 7.2f, TREE_WIDTH * 2.0f);
    float w3 = dnload_fmaxf((1.0f - h3) * width * 6.4f, TREE_WIDTH * 2.0f);
    unsigned index_base = static_cast<unsigned>(msh.getLogicalVertexCount());

    msh.addVertex(Vector3(ci * w0, fi * height, si * w0));
    msh.addVertex(Vector3(cl * w1, h1 * height, sl * w1));
    msh.addVertex(Vector3(ci * w2, h2 * height, si * w2));
    msh.addVertex(Vector3(cr * w1, h1 * height, sr * w1));
    msh.addVertex(Vector3(ci * w3, h3 * height, si * w3));

    msh.addFace(index_base + 0, index_base + 1, index_base + 2, index_base + 3, leaf_color);
    msh.addFace(index_base + 0, index_base + 3, index_base + 4, leaf_color);
    msh.addFace(index_base + 0, index_base + 4, index_base + 1, leaf_color);
    msh.addFace(index_base + 1, index_base + 4, index_base + 2, leaf_color);
    msh.addFace(index_base + 2, index_base + 4, index_base + 3, leaf_color);
  }

  msh.addCylinder(Vector3(0.0f, 0.0f, 0.0f), Vector3(0.0f, height, 0.0f), width, 0.01f, 6, trunk_color,
      Vector3(0.0f, 0.0f, 1.0f), Mesh::SIDE_NO_BACK_NO_FRONT);

  return msh.insert(vertex_buffer);
}

/** \brief Add a 'forest' to a location.
 *
 * \param tree_array Tree array.
 * \param tree_count Number of trees.
 * \param db Object database.
 * \param hmap Height map to use.
 * \param base_pos Base position.
 * \param xr X range.
 * \param zr Z range.
 * \param count Tree count.
 */
static void generate_forest(const CompiledMesh* tree_array[], unsigned tree_count, ObjectDatabase *db,
    HeightMap *hmap, unsigned seed, const Vector3 &base_pos, float xr, float zr, unsigned count)
{
  bsd_srand(seed);

  for(unsigned ii = 0; (ii < count);)
  {
    float xpos = frand(-xr, xr);
    float zpos = frand(-zr, zr);
    Vector3 pos = base_pos + Vector3(xpos, 0.0f, zpos);

    if(db->tryAddObject(tree_array[static_cast<unsigned>(bsd_rand()) % tree_count],
          Matrix4::rotation_zxy(0.0f, frand(static_cast<float>(M_PI * 2.0)), 0.0f, pos), hmap, 0.05f))
    {
      ++ii;
    }
  }
}

/** \brief Generate a bird.
 *
 * Birds have 'frames' since I'm not going to do bone animation.
 *
 * \param vertexBuffer Vertex buffer to insert into.
 * \param angle Wing angle to generate with.
 * \return Object generated.
 */
static Object* generate_bird(VertexBuffer *vertex_buffer, float angle)
{
  const Vector3 UNIT_UP(0.0f, 1.0f, 0.0f);
  const float BIRD_WIDTH1 = 0.01f;
  const float BIRD_WIDTH2 = 0.10f;
  const float BIRD_WIDTH3 = 0.08f;
  const float BIRD_WIDTH4 = 0.12f;
  const float BIRD_WIDTH5 = 0.04f;
  const float BIRD_Z1 = -0.48f;
  const float BIRD_Z2 = -0.18f;
  const float BIRD_Z3 = -0.02f;
  const float BIRD_Z4 = 0.12f;
  const float BIRD_Z5 = 0.32f;
  const float BIRD_UP1 = -0.01f;
  const float BIRD_UP2 = 0.01f;
  const float BIRD_UP3 = 0.0f;
  const float BIRD_UP4 = 0.0f;
  const float BIRD_UP5 = -0.01f;
  const float BIRD_WING_LENGTH = 0.9f;
  const Color BIRD_COLOR(255, 225, 220, 255);
  float rot = 0.0f + dnload_sinf(angle * static_cast<float>(M_PI * 2.0)) * 0.5f;
  float sa = dnload_sinf(rot);
  float ca = dnload_cosf(rot);
  Mesh msh;

  msh.addVertex(0.0f, BIRD_UP1, BIRD_Z1);

  msh.addVertex(BIRD_WIDTH2, BIRD_UP2 + BIRD_WIDTH2, BIRD_Z2);
  msh.addVertex(BIRD_WIDTH2, BIRD_UP2 - BIRD_WIDTH2, BIRD_Z2);
  msh.addVertex(-BIRD_WIDTH2, BIRD_UP2 + BIRD_WIDTH2, BIRD_Z2);
  msh.addVertex(-BIRD_WIDTH2, BIRD_UP2 - BIRD_WIDTH2, BIRD_Z2);

  msh.addVertex(BIRD_WIDTH3, BIRD_UP3 + BIRD_WIDTH3, BIRD_Z3);
  msh.addVertex(BIRD_WIDTH3, BIRD_UP3 - BIRD_WIDTH3, BIRD_Z3);
  msh.addVertex(-BIRD_WIDTH3, BIRD_UP3 + BIRD_WIDTH3, BIRD_Z3);
  msh.addVertex(-BIRD_WIDTH3, BIRD_UP3 - BIRD_WIDTH3, BIRD_Z3);

  msh.addVertex(BIRD_WIDTH4, BIRD_UP4 + BIRD_WIDTH4, BIRD_Z4);
  msh.addVertex(BIRD_WIDTH4, BIRD_UP4 - BIRD_WIDTH4, BIRD_Z4);
  msh.addVertex(-BIRD_WIDTH4, BIRD_UP4 + BIRD_WIDTH4, BIRD_Z4);
  msh.addVertex(-BIRD_WIDTH4, BIRD_UP4 - BIRD_WIDTH4, BIRD_Z4);

  msh.addVertex(BIRD_WIDTH5, BIRD_UP5 + BIRD_WIDTH5, BIRD_Z5);
  msh.addVertex(BIRD_WIDTH5, BIRD_UP5 - BIRD_WIDTH5, BIRD_Z5);
  msh.addVertex(-BIRD_WIDTH5, BIRD_UP5 + BIRD_WIDTH5, BIRD_Z5);
  msh.addVertex(-BIRD_WIDTH5, BIRD_UP5 - BIRD_WIDTH5, BIRD_Z5);

  msh.addFace(0, 3, 1, BIRD_COLOR);
  msh.addFace(0, 1, 2, BIRD_COLOR);
  msh.addFace(0, 2, 4, BIRD_COLOR);
  msh.addFace(0, 4, 3, BIRD_COLOR);

  msh.addFace(1, 3, 7, 5, BIRD_COLOR);
  msh.addFace(1, 5, 6, 2, BIRD_COLOR);
  msh.addFace(2, 6, 8, 4, BIRD_COLOR);
  msh.addFace(3, 4, 8, 7, BIRD_COLOR);

  msh.addFace(5, 7, 11, 9, BIRD_COLOR);
  msh.addFace(5, 9, 10, 6, BIRD_COLOR);
  msh.addFace(6, 10, 12, 8, BIRD_COLOR);
  msh.addFace(7, 8, 12, 11, BIRD_COLOR);

  msh.addFace(9, 11, 15, 13, BIRD_COLOR);
  msh.addFace(9, 13, 14, 10, BIRD_COLOR);
  msh.addFace(10, 14, 16, 12, BIRD_COLOR);
  msh.addFace(11, 12, 16, 15, BIRD_COLOR);

  msh.addFace(13, 15, 16, 14, BIRD_COLOR);

  msh.addElongatedCylinder(Vector3(BIRD_WIDTH3 * 0.75f, BIRD_UP3, BIRD_Z3 - BIRD_WIDTH3 * 0.25f), 
      Vector3(BIRD_WIDTH4 * 0.75f, BIRD_UP4, BIRD_Z4 + BIRD_WIDTH4 * 0.25f), BIRD_WIDTH2 * 0.75f,
      BIRD_WIDTH1, BIRD_WING_LENGTH, 3, BIRD_COLOR, Vector3(ca, sa, 0.0f), Mesh::SIDE_NO_FRONT);
  msh.addElongatedCylinder(Vector3(-BIRD_WIDTH3 * 0.75f, BIRD_UP3, BIRD_Z3 - BIRD_WIDTH3 * 0.25f), 
      Vector3(-BIRD_WIDTH4 * 0.75f, BIRD_UP4, BIRD_Z4 + BIRD_WIDTH4 * 0.25f), BIRD_WIDTH2 * 0.75f,
      BIRD_WIDTH1, BIRD_WING_LENGTH, 3, BIRD_COLOR, Vector3(-ca, sa, 0.0f), Mesh::SIDE_NO_FRONT);

  return new Object(msh.insert(vertex_buffer));
}

/** \brief Generate solar panel.
 *
 * \param vertexBuffer Vertex buffer to insert into.
 * \return Mesh generated.
 */
static CompiledMesh* generate_panel(VertexBuffer *vertex_buffer)
{
  const Vector3 UNIT_RT(1.0f, 0.0f, 0.0f);
  const float PANEL_WIDTH = 5.8f;
  const float PANEL_WIDTH2 = 5.6f;
  const float PANEL_DOWN = -4.5f;
  const float PANEL_DOWN2 = -4.3f;
  const float PANEL_UP = 2.0f;
  const float PANEL_UP2 = 1.8f;
  const float PANEL_DEPTH = 0.25f;
  const float PANEL_DEPTH2 = 0.45f;
  const float PANEL_FOOT_WIDTH1 = 1.1f;
  const float PANEL_FOOT_WIDTH2 = 0.4f;
  const float PANEL_FOOT_UP1 = 2.1f;
  const float PANEL_FOOT_UP2 = 7.2f;
  const float PANEL_ANGLE = 0.55f;
  const Vector3 PANEL_BASE(0.0f, PANEL_FOOT_UP2, 0.0f);
  float ca = dnload_cosf(PANEL_ANGLE);
  float sa = dnload_sinf(PANEL_ANGLE);
  Vector3 panel_fw(0.0f, sa, ca);
  Vector3 panel_up(0.0f, ca, -sa);
  Color PANEL_COLOR(220, 220, 255, 255);
  Color PANEL_FRONT_COLOR(255, 140, 255, 255);
  Mesh msh;

  msh.addBox(Vector3(PANEL_BASE - panel_fw * PANEL_DEPTH + UNIT_RT * PANEL_WIDTH + panel_up * PANEL_DOWN),
      Vector3(PANEL_BASE + panel_fw * PANEL_DEPTH - UNIT_RT * PANEL_WIDTH + panel_up * PANEL_UP),
      PANEL_COLOR, panel_fw, panel_up);
  msh.addBox(Vector3(PANEL_BASE + panel_fw * PANEL_DEPTH + UNIT_RT * PANEL_WIDTH2 + panel_up * PANEL_DOWN2),
      Vector3(PANEL_BASE + panel_fw * PANEL_DEPTH2 - UNIT_RT * PANEL_WIDTH2 + panel_up * PANEL_UP2),
      PANEL_FRONT_COLOR, panel_fw, panel_up);
  msh.addCylinder(Vector3(0.0f, 0.0f, 0.0f), Vector3(0.0f, PANEL_FOOT_UP1, 0.0f), PANEL_FOOT_WIDTH1,
      PANEL_FOOT_WIDTH1, 6, PANEL_COLOR, UNIT_RT, Mesh::SIDE_NO_BACK_NO_FRONT);
  msh.addCylinder(Vector3(0.0f, PANEL_FOOT_UP1, 0.0f), Vector3(0.0f, PANEL_FOOT_UP2, 0.0f), PANEL_FOOT_WIDTH1,
      PANEL_FOOT_WIDTH2, 6, PANEL_COLOR, UNIT_RT, Mesh::SIDE_NO_BACK_NO_FRONT);

  return msh.insert(vertex_buffer);
}

/** \brief Generate a solar tower.
 *
 * \param vertexBuffer Vertex buffer to insert into.
 * \param mid Is this the rotating mid-section?
 * \return Mesh generated.
 */
static CompiledMesh* generate_tower(VertexBuffer *vertex_buffer, bool mid)
{
  const Vector3 UNIT_FW(0.0f, 0.0f, 1.0f);
  const Vector3 UNIT_UP(0.0f, 1.0f, 0.0f);
  const float TOWER_WIDTH0 = 0.8f;
  const float TOWER_WIDTH1 = 15.0f;
  const float TOWER_WIDTH2 = 13.8f;
  const float TOWER_WIDTH3 = 11.6f;
  const float TOWER_UP1 = 9.5f;
  const float TOWER_UP2 = 10.5f;
  const float TOWER_UP3 = 15.5f;
  const float TOWER_UP4 = 27.5f;
  const float TOWER_UP5 = 32.5f;
  const float TOWER_UP6 = 33.5f;
  const float TOWER_UP7 = 64.0f;
  const Color TOWER_COLOR(255, 235, 220, 255);
  const Color TOWER_DETAIL_COLOR(255, 240, 160, 255);
  Mesh msh;

  if(mid)
  {
    for(unsigned ii = 0; (ii < 7); ++ii)
    {
      const float TOWER_OUT = TOWER_WIDTH2 - TOWER_WIDTH0 * 4.4f;
      float rot = static_cast<float>(ii) * static_cast<float>(M_PI * 2.0 / 7.0);
      float ca = dnload_cosf(rot);
      float sa = dnload_sinf(rot);
      Vector3 pos1(ca * TOWER_OUT, TOWER_UP3, sa * TOWER_OUT);
      Vector3 pos2(-ca * TOWER_OUT, TOWER_UP3, -sa * TOWER_OUT);

      msh.addElongatedCylinder(pos1, pos2, TOWER_WIDTH0, TOWER_WIDTH0, TOWER_UP4 - TOWER_UP3, 3,
          TOWER_DETAIL_COLOR, UNIT_UP, Mesh::SIDE_NO_BACK_NO_FRONT);
    }
  }
  else
  {
    msh.addCylinder(Vector3(0.0f, 0.0f, 0.0f), Vector3(0.0f, TOWER_UP1, 0.0f), TOWER_WIDTH1,
        TOWER_WIDTH1, 9, TOWER_COLOR, UNIT_FW, Mesh::SIDE_NO_BACK_NO_FRONT);
    msh.addCylinder(Vector3(0.0f, TOWER_UP1, 0.0f), Vector3(0.0f, TOWER_UP2, 0.0f), TOWER_WIDTH1,
        TOWER_WIDTH2, 9, TOWER_DETAIL_COLOR, UNIT_FW, Mesh::SIDE_NO_BACK_NO_FRONT);
    msh.addCylinder(Vector3(0.0f, TOWER_UP2, 0.0f), Vector3(0.0f, TOWER_UP3, 0.0f), TOWER_WIDTH2,
        TOWER_WIDTH2, 9, TOWER_COLOR, UNIT_FW, Mesh::SIDE_NO_FRONT);

    for(unsigned ii = 0; (ii < 5); ++ii)
    {
      const float TOWER_OUT = TOWER_WIDTH2 - TOWER_WIDTH0 * 2.2f;
      float rot = static_cast<float>(ii) * static_cast<float>(M_PI * 2.0 / 5.0);
      float ca = dnload_cosf(rot);
      float sa = dnload_sinf(rot);
      Vector3 pos1(ca * TOWER_OUT, TOWER_UP3, sa * TOWER_OUT);
      Vector3 pos2 = pos1 + (TOWER_UP4 - TOWER_UP3) * UNIT_UP;

      msh.addCylinder(pos1, pos2, TOWER_WIDTH0, TOWER_WIDTH0, 5, TOWER_COLOR, UNIT_FW,
          Mesh::SIDE_NO_BACK_NO_FRONT);
    }

    msh.addCylinder(Vector3(0.0f, TOWER_UP4, 0.0f), Vector3(0.0f, TOWER_UP5, 0.0f), TOWER_WIDTH2,
        TOWER_WIDTH2, 9, TOWER_COLOR, UNIT_FW, Mesh::SIDE_NO_BACK);
    msh.addCylinder(Vector3(0.0f, TOWER_UP5, 0.0f), Vector3(0.0f, TOWER_UP6, 0.0f), TOWER_WIDTH2,
        TOWER_WIDTH3, 9, TOWER_DETAIL_COLOR, UNIT_FW, Mesh::SIDE_NO_BACK_NO_FRONT);
    msh.addCylinder(Vector3(0.0f, TOWER_UP6, 0.0f), Vector3(0.0f, TOWER_UP7, 0.0f), TOWER_WIDTH3,
        TOWER_WIDTH3, 9, TOWER_COLOR, UNIT_FW, Mesh::SIDE_NO_BACK_NO_FRONT);

  }

  return msh.insert(vertex_buffer);
}

/** \brief Generate container color.
 *
 * \return Random container color.
 */
static Color generate_container_color()
{
  return mix(Color(120, 255, 255, 255), Color(0, 255, 120, 255), frand(1.0f));
}

/** \brief Generate ship.
 *
 * \param vertexBuffer Vertex buffer to insert into.
 * \return Mesh generated.
 */
static CompiledMesh* generate_ship(VertexBuffer *vertex_buffer)
{
  const Vector3 UNIT_RT(1.0f, 0.0f, 0.0f);
  const Vector3 UNIT_FW(0.0f, 0.0f, -1.0f);
  const Vector3 UNIT_UP(0.0f, 1.0f, 0.0f);
  const float SHIP_WIDTH1 = 10.0f;
  const float SHIP_WIDTH2 = 8.9f;
  const float SHIP_WIDTH3 = 7.6f;
  const float SHIP_LENGTH = 52.0f;
  const float CONTAINER_WIDTH = 3.0f;
  const float CONTAINER_HEIGHT = 3.5f;
  const float CONTAINER_LENGTH = 5.0f;
  const float SHIP_ELEVATION1 = -6.0f;
  const float SHIP_ELEVATION2 = -4.8f;
  const float SHIP_ELEVATION3 = -0.8f;
  const float SHIP_ELEVATION4 = -0.2f;
  Color color = generate_factory_base_color();
  Color color_frame = generate_factory_frame_color();
  Mesh msh;

  bsd_srand(7);

  msh.addBox(Vector3(-SHIP_WIDTH3, SHIP_ELEVATION2, 4.1f),
      Vector3(SHIP_WIDTH3, SHIP_ELEVATION3, -SHIP_WIDTH3), color_frame, UNIT_FW, UNIT_UP,
      Mesh::SIDE_NO_BOTTOM_NO_TOP);
  msh.addBox(Vector3(-SHIP_WIDTH3 - 0.4f, SHIP_ELEVATION3, 4.5f),
      Vector3(SHIP_WIDTH3 + 0.4f, SHIP_ELEVATION4, -SHIP_WIDTH3 - 0.4f), color, UNIT_FW, UNIT_UP);

  extend_apartment_block(&msh, Vector3(0.0f, SHIP_ELEVATION2, -SHIP_WIDTH3), UNIT_FW,
      SHIP_WIDTH3, SHIP_WIDTH3, SHIP_ELEVATION3 - SHIP_ELEVATION2, color_frame,
      color, color);

  for(int ii = 0; (ii < 5); ++ii)
  {
    decorate_apartment_block(&msh, Vector3(0.0f, SHIP_ELEVATION4, (2.0f - SHIP_WIDTH3) * 0.5f),
        SHIP_WIDTH3, (2.0f - SHIP_WIDTH3) * 0.5f, 8.5f, UNIT_RT, UNIT_FW, color);
  }

  for(unsigned ii = 0; (ii <= 4); ++ii)
  {
    float fi = static_cast<float>(ii) / 4.0f;
    Vector3 pos1(SHIP_WIDTH3, SHIP_ELEVATION2, fi * (SHIP_WIDTH3 * 1.5f - SHIP_LENGTH) - SHIP_WIDTH3 * 1.6f);
    Vector3 pos2 = pos1 + UNIT_UP * (SHIP_ELEVATION3 - SHIP_ELEVATION2);
    Vector3 pos3 = pos2 + UNIT_UP * (SHIP_ELEVATION4 - SHIP_ELEVATION3) - UNIT_RT * SHIP_WIDTH1 * 0.35f;

    msh.addAngle(pos1, pos2, pos3, 0.5f, 4, color_frame, Mesh::SIDE_NO_BOTTOM_NO_TOP);

    pos1[0] *= -1.0f;
    pos2[0] *= -1.0f;
    Vector3 pos4(-pos3[0], pos3[1], pos3[2]);

    msh.addAngle(pos1, pos2, pos4, 0.5f, 4, color_frame, Mesh::SIDE_NO_BOTTOM_NO_TOP);
    msh.addCylinder(pos3 + UNIT_RT * 0.07f, pos4 - UNIT_RT * 0.07f, 0.5f, 0.5f, 4, color_frame, UNIT_UP,
        Mesh::SIDE_NO_BACK_NO_FRONT);
  }

  {
    Vector3 pos1(SHIP_WIDTH3 * 0.4f, SHIP_ELEVATION2, -SHIP_LENGTH - SHIP_WIDTH3);
    Vector3 pos2 = pos1 + UNIT_UP * (SHIP_ELEVATION3 - SHIP_ELEVATION2);
    Vector3 pos3 = pos2 + UNIT_UP * (SHIP_ELEVATION4 - SHIP_ELEVATION3) - UNIT_FW * SHIP_WIDTH1 * 0.35f;
    Vector3 pos4 = pos3 - UNIT_FW * (SHIP_LENGTH - SHIP_WIDTH3 * 1.1f);

    msh.addAngle(pos1, pos2, pos3, 0.38f, 4, color_frame, Mesh::SIDE_NO_BOTTOM_NO_TOP);
    msh.addCylinder(pos3 + UNIT_FW * 0.07f, pos4, 0.38f, 0.38f, 4, color_frame, UNIT_UP,
        Mesh::SIDE_NO_BACK_NO_FRONT);

    pos1[0] *= -1.0f;
    pos2[0] *= -1.0f;
    pos3[0] *= -1.0f;
    pos4[0] *= -1.0f;

    msh.addAngle(pos1, pos2, pos3, 0.38f, 4, color_frame, Mesh::SIDE_NO_BOTTOM_NO_TOP);
    msh.addCylinder(pos3 + UNIT_FW * 0.07f, pos4, 0.38f, 0.38f, 4, color_frame, UNIT_UP,
        Mesh::SIDE_NO_BACK_NO_FRONT);
  }

  //bsd_srand(19);
  bsd_srand(20);

  for(unsigned ii = 0; (ii < 12); ++ii)
  {
    Color container_color = generate_container_color();
    float width = frand(CONTAINER_WIDTH * 0.75f, CONTAINER_WIDTH * 1.25f);
    float height = frand(CONTAINER_HEIGHT * 0.75f, CONTAINER_HEIGHT * 1.25f);
    float length = frand(CONTAINER_LENGTH * 0.75f, CONTAINER_LENGTH * 1.25f);
    float container_x = frand(-SHIP_WIDTH2 * 0.8f, SHIP_WIDTH2 - width);
    float container_z = frand(-SHIP_LENGTH * 1.1f, -SHIP_WIDTH3 * 3.0f);
    Vector3 pos1(container_x, SHIP_ELEVATION2, container_z);
    Vector3 pos2 = pos1 + Vector3(width, height, length);

    msh.addBox(pos1, pos2, container_color, UNIT_FW, UNIT_UP, Mesh::SIDE_NO_BOTTOM);   
  }

  msh.addElongatedCylinder(Vector3(0.0f, SHIP_ELEVATION1, 0.0f), Vector3(0.0f, SHIP_ELEVATION1, -SHIP_LENGTH),
      SHIP_WIDTH1, SHIP_WIDTH2, SHIP_ELEVATION1 - WATER_LEVEL, 5, color, Vector3(0.0f, -1.0f, 0.05f),
      Mesh::SIDE_NO_BACK_NO_FRONT);
  msh.addElongatedCylinder(Vector3(0.0f, SHIP_ELEVATION1, 0.0f), Vector3(0.0f, SHIP_ELEVATION1, -SHIP_LENGTH),
      SHIP_WIDTH1, SHIP_WIDTH1, SHIP_ELEVATION2 - SHIP_ELEVATION1, 5, color,
      UNIT_UP, Mesh::SIDE_NO_FRONT);

  return msh.insert(vertex_buffer);
}

//######################################
// Paraller generation #################
//######################################

/** Global container.
 */
class GlobalContainer
{
  public:
    /** Bird mesh count. */
    static const unsigned BIRD_COUNT = 23;

  private:
    /** Global shader program. */
    Program m_program_blueprint;

    /** Global shader program. */
    Program m_program_default;

    /** Global shader program. */
    Program m_program_loader;

    /** Global shader program. */
    Program m_program_post;

    /** Global render target. */
    FrameBuffer m_render_target;

    /** Global vertex buffer. */
    VertexBuffer m_vertex_buffer_land;

    /** Global vertex buffer. */
    VertexBuffer m_vertex_buffer_water;

    /** Global vertex buffer. */
    VertexBuffer m_vertex_buffer_city;

    /** Global vertex buffer. */
    VertexBuffer m_vertex_buffer_objects;

    /** Global object database. */
    ObjectDatabase m_object_database;

    /** Global state queue. */
    StateQueue m_state_queue;

    /** Global projection matrix. */
    Matrix4 m_projection;

    /** Screen width. */
    unsigned m_screen_width;

    /** Screen height. */
    unsigned m_screen_height;

    /** Done flag. */
    bool m_done;

    /** Konseptipaperi texture. */
    Texture *m_texture_konseptipaperi;

    /** Global terrain object. */
    Terrain *m_terrain_land;

    /** Global terrain object. */
    Terrain *m_terrain_water;

    /** Global terrain object. */
    Terrain *m_terrain_city;

    /** Global object. */
    Object* m_object_horizon_land;

    /** Global object. */
    Object* m_object_horizon_city;

    /** Global object. */
    Object* m_object_horizon_pier;

    /** Global object. */
    Object* m_object_window;

    /** Bird object. */
    Object *m_birds[BIRD_COUNT];

    /** Auto object. */
    Object *m_auto;

    /** Lentsikka object. */
    Object *m_lentsikka;

    /** Font */
    CompiledMesh *m_glyphs['z'-'a'];

  public:
    /** \brief Accessor.
     *
     * \return Konseptipaperi texture.
     */
    const Texture* getTextureKonseptipaperi() const
    {
      return m_texture_konseptipaperi;
    }

    /** \brief Accessor.
     *
     * \return Blueprint program.
     */
    const Program* getProgramBlueprint() const
    {
      return &m_program_blueprint;
    }

    /** \brief Accessor.
     *
     * \return Default program.
     */
    const Program* getProgramDefault() const
    {
      return &m_program_default;
    }

    /** \brief Accessor.
     *
     * \return Loader program.
     */
    const Program* getProgramLoader() const
    {
      return &m_program_loader;
    }

    /** \brief Accessor.
     *
     * \return Post-process program.
     */
    const Program* getProgramPost() const
    {
      return &m_program_post;
    }

    /** \brief Accessor.
     *
     * \return Projection matrix.
     */
    const Matrix4& getProjection() const
    {
      return m_projection;
    }

    /** \brief Accessor.
     *
     * \return Render target.
     */
    const FrameBuffer* getFrameBuffer() const
    {
      return &m_render_target;
    }

    /** \brief Accessor.
     *
     * \return Screen height.
     */
    unsigned getScreenHeight() const
    {
      return m_screen_height;
    }

    /** \brief Accessor.
     *
     * \return Screen width.
     */
    unsigned getScreenWidth() const
    {
      return m_screen_width;
    }

    /** \brief Get state queue.
     *
     * \return State queue.
     */
    StateQueue* getStateQueue()
    {
      return &m_state_queue;
    }

    /** \brief Is calculation done?
     *
     * \return True if yes, false if no.
     */
    bool isDone() const
    {
      return m_done;
    }

  private:
    /** \brief Set the done flag.
     */
    void setDone()
    {
      m_done = true;
    }

  public:
    /** \brief Constructor.
     *
     * \param screen_w Screen width.
     * \param screen_h Screen height.
     */
    GlobalContainer(unsigned screen_w, unsigned screen_h);

  public:
    /** \brief Fill objects into a state.
     *
     * \param op State to fill into.
     */
    void fillState(State *op) const;

    /** \brief Update data to GPU.
     */
    void update();

  private:
    /** \brief Fill auto events.
     *
     * \param op State to fill into.
     * \param event_start Event start X position.
     * \param event_end Event end X position.
     * \param x1 Auto X position 1.
     * \param x2 Auto X position 2.
     * \param ypos Auto Y position.
     * \param zpos Auto Z position.
     * \param powered Turbo?
     */
    void fillAuto(State *op, float event_start, float event_end, float x1, float x2,
        float ypos, float zpos, bool powered = false) const;

    /** \brief Fill bird events.
     *
     * \param op State to fill into.
     * \param event_start Event start X position.
     * \param event_end Event end X position.
     * \param x1 Bird random X position 1.
     * \param x2 Bird random X position 2.
     * \param z1 Bird random Z position 1.
     * \param z2 Bird random Z position 2.
     * \param y1 Bird start Y position.
     * \param yspeed1 Bird Y speed random value 1.
     * \param yspeed2 Bird Y speed random value 2.
     * \param seed Bird random seed.
     * \param count Number of birds.
     */
    void fillBirds(State *op, float event_start, float event_end, float x1, float x2, float z1, float z2,
        float y1, float yspeed1, float yspeed2, unsigned seed, unsigned count) const;

    /** \brief Precalculation of audio.
     */
    void precalculateAudio();

    /** \brief Precalculation of visuals.
     */
    void precalculateVisuals();

    /** \brief Write text.
     *
     * \param str String to write.
     * \param pos Starting position.
     * \param dir Direction.
     * \param rot Rotation of text letters.
     * \param adv Advance for one letter.
     */
    void writeText(const char *str, const Vector3 &pos, const Vector3 &dir, float rot, float adv);

  private:
    /** \brief Add object.
     *
     * \param object Object.
     * \param transform Transformation.
     */
    void addObject(const CompiledMesh* msh, const Matrix4 &transform)
    {
      m_object_database.addObject(msh, transform);
    }

    /** \brief Try to add object.
     *
     * \param object Object.
     * \param transform Transformation.
     * \param height_map Height map to use for checking slope.
     * \param slope Maximum allowed slope.
     * \return True if object was successfully added.
     */
    bool tryAddObject(const CompiledMesh* object, const Matrix4 &transform, const HeightMap *height_map,
        float slope)
    {
      return m_object_database.tryAddObject(object, transform, height_map, slope);
    }

  private:
    /** \brief Generator thread function. 
     *
     * \param user_data Parameters to thread.
     * \return Trhead exit code.
     */
    static int precalc_function_audio(void *user_data);

    /** \brief Generator thread function. 
     *
     * \param user_data Parameters to thread.
     * \return Trhead exit code.
     */
    static int precalc_function_visuals(void *user_data);

  public:
    /** \brief Generator thread function. 
     *
     * \param user_data Parameters to thread.
     * \return Trhead exit code.
     */
    static int precalc_function(void *user_data);
};

GlobalContainer::GlobalContainer(unsigned screen_w, unsigned screen_h) :
  m_program_blueprint(g_shader_vertex_blueprint, g_shader_fragment_blueprint),
  m_program_default(g_shader_vertex_default, g_shader_fragment_default),
  m_program_loader(g_shader_vertex_loader, g_shader_fragment_loader),
  m_program_post(g_shader_vertex_post, g_shader_fragment_post),
  m_render_target(screen_w, screen_h),
  m_projection(Matrix4::projection(CAMERA_FOV_RADIANS, screen_w, screen_h, CAMERA_NEAR, CAMERA_FAR)),
  m_screen_width(screen_w),
  m_screen_height(screen_h),
  m_done(false),
  m_texture_konseptipaperi(generate_texture_konseptipaperi(1)) { }

void GlobalContainer::fillAuto(State *op, float event_start, float event_end, float x1, float x2,
    float ypos, float zpos, bool powered) const
{
  float camera_pos = op->getPosition()[0];

  if((event_start >= camera_pos) && (event_end <= camera_pos))
  {
    float fi = (event_start - camera_pos) / (event_start - event_end);

    if(powered)
    {
      fi *= fi;
    }

    op->addObject(m_auto, &m_program_default, Matrix4::rotation_zxy(0.0f,
          powered ? static_cast<float>(-M_PI / 2.0) : static_cast<float>(M_PI / 2.0), 0.0f,
          Vector3(mix(x1, x2, fi), ypos, zpos)));
  }
}

void GlobalContainer::fillBirds(State *op, float event_start, float event_end, float x1, float x2,
    float z1, float z2, float y1, float yspeed1, float yspeed2, unsigned seed, unsigned count) const
{
  const float BIRD_EVENT_XSPEED1 = -95.0f;
  const float BIRD_EVENT_XSPEED2 = -85.0f;
  float camera_pos = op->getPosition()[0];

  if((event_start >= camera_pos) && (event_end <= camera_pos))
  {
    float fi = (event_start - camera_pos) / (event_start - event_end);

    bsd_srand(seed);

    for(unsigned ii = 0; (ii < count); ++ii)
    {
      float xpos = frand(x1, x2);
      float xposadd = frand(BIRD_EVENT_XSPEED1, BIRD_EVENT_XSPEED2);
      float yposadd = frand(yspeed1, yspeed2);
      float zpos = frand(z1, z2);
      Vector3 pos(xpos + xposadd * fi, y1 + yposadd * fi, zpos);
      unsigned bird = (static_cast<unsigned>(bsd_rand()) +
          static_cast<unsigned>(fi * 5.0f * static_cast<float>(BIRD_COUNT) + 0.5f)) % BIRD_COUNT;

      op->addObject(m_birds[bird], &m_program_default,
          Matrix4::rotation_zxy(0.0f, static_cast<float>(M_PI / 2.0), 0.0f, pos));
    }
  }
}

void GlobalContainer::fillState(State *op) const
{
  Vector3 camera_pos = op->getPosition();

  // Terrain.
  {
    const float VISION_RIGHT = 230.0f;
    const float VISION_LEFT = 270.0f;
    float x_pos_start = camera_pos[0] + VISION_RIGHT;
    float x_pos_end = camera_pos[0] - VISION_LEFT;
    Matrix4 transform = op->getProjectionMatrix() * op->getCameraMatrix();

    op->addTerrain(m_terrain_land, &m_program_default, transform, x_pos_start, x_pos_end);
    op->addTerrain(m_terrain_water, &m_program_default, transform, x_pos_start, x_pos_end);
    op->addTerrain(m_terrain_city, &m_program_default, transform, x_pos_start, x_pos_end);
  }

#ifdef USE_LD
  /*if(g_flag_developer)
  {
      // Test
      for(unsigned i = 0; i < 13; ++i)
      {
          op->addObject(m_glyphs[i], &m_program_default,
                        Matrix4::translation(camera_pos + Vector3(-13.0f + i*2.0f, 2.0f, -15.0f)));
          op->addObject(m_glyphs[13+i], &m_program_default,
                        Matrix4::translation(camera_pos + Vector3(-13.0f + i*2.0f, -2.0f, -15.0f)));
      }
  }*/
#endif

  // Window.
  op->addObject(m_object_window, &m_program_default,
      Matrix4::translation(camera_pos + Vector3(0.0f, 0.0f, -0.4f)));

  // Objects.
  op->addObjectDatabase(&m_object_database, &m_program_default, op->getPosition()[0]);

  // Birds.
  this->fillBirds(op, -1023.0f, -1247.0f, -1105.0f, -1092.0f, -85.0f, -35.0f, 6.0f, 25.0f, 35.0f, 2, 9);
  this->fillBirds(op, -2435.0f, -2771.0f, -2739.0f, -2460.0f, -24, -8, 2.0f, 0.1f, 0.2f, 3, 19);

  // Autos.
  this->fillAuto(op, -3000.0f, -3120.0f, -3020.0f, -3148.0f, -6.5f, -16.6f, true);
  this->fillAuto(op, -3195.0f, -3230.0f, -3230.0f, -3195.0f, -6.5f, -11.1f);
  this->fillAuto(op, -3275.0f, -3310.0f, -3310.0f, -3275.0f, -6.5f, -11.1f);

  // Lentsikka.
  {
    const float LENTSIKKA_START = -2700.0f;
    const float LENTSIKKA_END = -2804.0f;
    const Vector3 LENTSIKKA_POS1(-2480.0f, -1.0f, HORIZON);
    const Vector3 LENTSIKKA_POS2(-2825.0f, 6.9f, 0.0f);
    const float LENTSIKKA_ROT1 = static_cast<float>(M_PI * 3.0 / 4.0);
    const float LENTSIKKA_ROT2 = static_cast<float>(M_PI * 2.0 / 3.0);

    if((LENTSIKKA_START >= camera_pos[0]) && (LENTSIKKA_END <= camera_pos[0]))
    {
      float fi = (LENTSIKKA_START - camera_pos[0]) / (LENTSIKKA_START - LENTSIKKA_END);
      float lentsikka_zrot = mix(LENTSIKKA_ROT1, LENTSIKKA_ROT2, fi);
      Vector3 lentsikka_pos = mix(LENTSIKKA_POS1, LENTSIKKA_POS2, fi);

#if defined(USE_LD)
      std::cout << "camera pos: " << camera_pos << " || fi: " << fi << " || lentsikka zrot: " <<
        lentsikka_zrot << " || lentsikka pos: " << lentsikka_pos << std::endl;
#endif

      op->addObject(m_lentsikka, &m_program_default, Matrix4::rotation_zxy(-0.1f, -1.1f, lentsikka_zrot,
            lentsikka_pos));
    }
  }

  // Horizon.
  {
    Matrix4 transform = Matrix4::translation(camera_pos);

    if(TUNNEL_START - TOLPPA_GAP < camera_pos[0])
    {
      op->addObject(m_object_horizon_land, &m_program_default, transform);
    }
    else if(PIER_START - 5.5f < camera_pos[0])
    {
      op->addObject(m_object_horizon_city, &m_program_default, transform);
    }
    else
    {
      op->addObject(m_object_horizon_pier, &m_program_default, transform);
    }
  }
}

void GlobalContainer::precalculateAudio()
{
#if defined(USE_LD)
  uint32_t precalc_start = dnload_SDL_GetTicks();
#endif

  dnload_memset(g_audio_buffer, 0, AUDIO_BUFFER_SIZE);
  if(!g_flag_developer)
  {
    generate_audio(g_audio_buffer, AUDIO_BUFFER_SIZE);

#if defined(USE_LD)
    uint32_t precalc_end = dnload_SDL_GetTicks();
    std::cout << "|precalc(audio): " << (static_cast<float>(precalc_end - precalc_start) * .001f) << std::endl;
#endif
  }
}

void GlobalContainer::precalculateVisuals()
{
#if defined(USE_LD)
  uint32_t precalc_start = dnload_SDL_GetTicks();
#endif

  HeightMap height_map_land;
  HeightMap height_map_water;
  HeightMap height_map_city;

  m_terrain_land = generate_terrain_land(&m_vertex_buffer_land, &height_map_land);
  m_terrain_water = generate_terrain_water(&m_vertex_buffer_water, &height_map_water);
  m_terrain_city = generate_terrain_city(&m_vertex_buffer_city, &height_map_city);

  m_object_window = generate_window(&m_vertex_buffer_objects);
  m_object_horizon_land = generate_horizon(&m_vertex_buffer_objects, 0);
  m_object_horizon_city = generate_horizon(&m_vertex_buffer_objects, 1);
  m_object_horizon_pier = generate_horizon(&m_vertex_buffer_objects, 2);

  {
    CompiledMesh *tolppa = generate_tolppa(&m_vertex_buffer_objects);
    CompiledMesh *land_base = generate_base_land(&m_vertex_buffer_objects);
    CompiledMesh *water_base = generate_base_land(&m_vertex_buffer_objects, true);
    CompiledMesh *bridge_start = generate_bridge(&m_vertex_buffer_objects, 0);
    CompiledMesh *bridge_continuation_1 = generate_bridge(&m_vertex_buffer_objects, 1);
    CompiledMesh *bridge_continuation_2 = generate_bridge(&m_vertex_buffer_objects, 2);
    CompiledMesh *city_wall = generate_city_wall(&m_vertex_buffer_objects);
    CompiledMesh *tunnel_start = generate_tunnel_segment(&m_vertex_buffer_objects, true);
    CompiledMesh *tunnel_continuation = generate_tunnel_segment(&m_vertex_buffer_objects, false);
    CompiledMesh *skyway_flat = generate_skyway(&m_vertex_buffer_objects, false);
    CompiledMesh *skyway_sloped = generate_skyway(&m_vertex_buffer_objects, true);
    CompiledMesh *highway_1 = generate_highway(&m_vertex_buffer_objects, 16.5f, true);
    CompiledMesh *highway_2 = generate_highway(&m_vertex_buffer_objects, 13.0f, false);
    CompiledMesh *pier_start = generate_pier(&m_vertex_buffer_objects, 0);
    CompiledMesh *pier_continuation = generate_pier(&m_vertex_buffer_objects, 1);
    CompiledMesh *pier_end = generate_pier(&m_vertex_buffer_objects, 2);
    bool jj = false;
    float kk = 0.0f;

    for(float ii = LAND_START; (ii > WATER_START + TOLPPA_GAP); ii -= TOLPPA_GAP)
    {
      this->addObject(land_base, Matrix4::translation(Vector3(ii, 0.0f, 0.0f)));

      // Block tolppa elements around stations.
      if(!(((-209.0f >= ii) && (-211.0f <= ii)) || ((-1940.0f >= ii) && (-1955.0f <= ii))))
      {
        this->addObject(tolppa, Matrix4::translation(ii, 0.0f, TERRAIN_AWAY + 0.4f));
      }
    }

    {
      const float ROT = -0.4f;
      float cr = dnload_cosf(static_cast<float>(-M_PI + ROT));
      float sr = dnload_sinf(static_cast<float>(-M_PI + ROT));
      Vector3 unit_fw = normalize(Vector3(sr, 0.0f, cr));
      Vector3 unit_rt = normalize(cross_product(unit_fw, Vector3(0.0f, 1.0f, 0.0f)));
      Vector3 pos(-1120.0f, -9.0f, 0.0f);

      //std::cout << unit_fw << std::endl;

      while(pos[2] > HORIZON)
      {
        Vector3 pos1 = pos + unit_rt * 5.5f;
        Vector3 pos2 = pos - unit_rt * 5.5f + unit_fw * (TOLPPA_GAP * 0.75f);
        Matrix4 t1 = Matrix4::rotation_zxy(0.0f, static_cast<float>(M_PI / -2.0 + ROT), 0.0f, pos1);
        Matrix4 t2 = Matrix4::rotation_zxy(0.0f, static_cast<float>(M_PI / 2.0 + ROT), 0.0f, pos2);

        this->addObject(highway_2, t1);
        this->addObject(highway_2, t2);

        pos += unit_fw * TOLPPA_GAP;
      }
    }
    for(float ii = WATER_START + TOLPPA_GAP; (ii > BRIDGE_START); ii -= TOLPPA_GAP)
    {
      this->addObject(tolppa, Matrix4::translation(ii, 0.0f, TERRAIN_AWAY + 0.4f));
      this->addObject(water_base, Matrix4::translation(Vector3(ii, 0.0f, 0.0f)));
    }
    
    this->addObject(bridge_start, Matrix4::translation(BRIDGE_START, 0.0f, 0.0f));
    for(float ii = BRIDGE_START - TOLPPA_GAP; (ii > TUNNEL_START); ii -= TOLPPA_GAP)
    {
      this->addObject(jj ? bridge_continuation_1 : bridge_continuation_2,
          Matrix4::translation(ii, 0.0f, 0.0f));
      jj = !jj;
    }

    this->addObject(city_wall, Matrix4::translation(TUNNEL_START - TOLPPA_GAP * 0.5f, 0.0f, 0.0f));

    this->addObject(tunnel_start, Matrix4::translation(TUNNEL_START, 0.0f, 0.0f));
    for(float ii = TUNNEL_START - TOLPPA_GAP; (ii > TUNNEL_END); ii -= TOLPPA_GAP)
    {
      this->addObject(tunnel_continuation, Matrix4::translation(ii, 0.0f, 0.0f));
    }

    for(float ii = TUNNEL_END; (ii > PIER_START); ii -= TOLPPA_GAP)
    {
      if((CITY_START - 250.0f) < ii)
      {
        this->addObject(skyway_flat, Matrix4::translation(ii, 0.0f, 0.0f));
      }
      else if((PIER_START + TOLPPA_GAP * 2.0f) < ii)
      {
        this->addObject(skyway_sloped, Matrix4::translation(ii, kk, 0.0f));
        kk += SKYWAY_SLOPE;
      }
      else
      {
        this->addObject(skyway_flat, Matrix4::translation(ii, kk, 0.0f));
      }
    }

    for(float ii = TUNNEL_END + 18.0f; (ii > PIER_START + TOLPPA_GAP); ii -= TOLPPA_GAP)
    {
      this->addObject(highway_1, Matrix4::translation(ii, -26.0f, -14.0f));
    }

    this->addObject(pier_start, Matrix4::translation(PIER_START, kk, 0.0f));
    for(float ii = PIER_START - TOLPPA_GAP; (ii > PIER_END - TOLPPA_GAP); ii -= TOLPPA_GAP)
    {
      this->addObject((ii == PIER_START) ? pier_continuation : pier_end, Matrix4::translation(ii, kk, 0.0f));
    }
  }

  {
    CompiledMesh *apartments[11] =
    {
      generate_apartment_block(&m_vertex_buffer_objects, 7, 4.0f, 8.0f),
      generate_apartment_block(&m_vertex_buffer_objects, 8, 4.0f, 8.0f),
      generate_apartment_block(&m_vertex_buffer_objects, 16, 4.0f, 8.0f),
      generate_apartment_block(&m_vertex_buffer_objects, 20, 4.0f, 8.0f),
      generate_apartment_block(&m_vertex_buffer_objects, 29, 4.0f, 8.0f),
      generate_apartment_block(&m_vertex_buffer_objects, 45, 4.0f, 8.0f),
      generate_apartment_block(&m_vertex_buffer_objects, 51, 4.0f, 8.0f),
      generate_apartment_block(&m_vertex_buffer_objects, 58, 4.0f, 8.0f),
      generate_apartment_block(&m_vertex_buffer_objects, 79, 4.0f, 8.0f),
      generate_apartment_block(&m_vertex_buffer_objects, 100, 4.0f, 8.0f),
      generate_apartment_block(&m_vertex_buffer_objects, 116, 4.0f, 8.0f)
    };
    const unsigned SKYSCRAPER_COUNT = 9;
    CompiledMesh *skyscrapers[SKYSCRAPER_COUNT] = 
    {
      generate_skyscraper(&m_vertex_buffer_objects, 8, 22.0f, 16.0f),
      generate_skyscraper(&m_vertex_buffer_objects, 18, 18.0f, 9.0f),
      generate_skyscraper(&m_vertex_buffer_objects, 19, 22.0f, 8.5f),
      generate_skyscraper(&m_vertex_buffer_objects, 22, 18.0f, 17.0f),
      generate_skyscraper(&m_vertex_buffer_objects, 27, 23.0f, 8.0f),
      generate_skyscraper(&m_vertex_buffer_objects, 33, 18.5f, 11.5f),
      generate_skyscraper(&m_vertex_buffer_objects, 41, 17.0f, 12.0f),
      generate_skyscraper(&m_vertex_buffer_objects, 42, 21.0f, 12.0f),
      generate_skyscraper(&m_vertex_buffer_objects, 44, 28.0f, 10.0f)
    };
    
    bsd_srand(1);

    // Starting apartment area.
    for(unsigned ii = 0; (ii < 45);)
    {
      float xpos = frand(-520.0f, 160.0f);
      float zpos = frand(HORIZON * 0.4f, -20.0f);
      Vector3 pos(-200.0f + xpos, 0.0f, zpos);
      Matrix4 transform = Matrix4::rotation_zxy(0.0f, frand(static_cast<float>(M_PI * 2.0)), 0.0f, pos);

      if(this->tryAddObject(apartments[bsd_rand() % 11], transform, &height_map_land, 0.3f))
      {
        ++ii;
      }
    }

    bsd_srand(37);

    for(unsigned ii = 0; (ii < 30);)
    {
      float xpos = frand(PIER_START + TOLPPA_GAP * 2.0f, TUNNEL_END + TOLPPA_GAP);
      float zpos = frand(HORIZON * 0.5f, 0.0f);
      Vector3 pos(xpos, 0.0f, zpos);
      Matrix4 transform = Matrix4::rotation_zxy(0.0f, frand(static_cast<float>(M_PI * 2.0)), 0.0f, pos);

      if(this->tryAddObject(skyscrapers[static_cast<unsigned>(bsd_rand()) % SKYSCRAPER_COUNT],
            transform, &height_map_city, 1.0f))
      {
        ++ii;
      }
    }
  }

  {
    CompiledMesh *station_1 = generate_station(&m_vertex_buffer_objects, 102);
    CompiledMesh *station_2 = generate_station(&m_vertex_buffer_objects, 44);

    this->addObject(station_1, Matrix4::translation(-200.0f, 0.0f, 0.0f));
    this->addObject(station_2, Matrix4::translation(-1945.0f, 0.0f, 0.0f));
  }

  {
    const unsigned FACTORY_BUILDING_COUNT = 6;
    CompiledMesh *factory_buildings[FACTORY_BUILDING_COUNT] =
    {
      generate_factory_building(&m_vertex_buffer_objects, 1, 6.0f, 6.0f),
      generate_factory_building(&m_vertex_buffer_objects, 2, 6.0f, 6.0f),
      generate_factory_building(&m_vertex_buffer_objects, 3, 6.0f, 6.0f),
      generate_factory_building(&m_vertex_buffer_objects, 4, 6.0f, 6.0f),
      generate_factory_building(&m_vertex_buffer_objects, 5, 6.0f, 6.0f),
      generate_factory_building(&m_vertex_buffer_objects, 6, 6.0f, 6.0f)
    };
    const unsigned FACTORY_SILO_COUNT = 5;
    CompiledMesh *factory_silos[FACTORY_SILO_COUNT] =
    {
      generate_factory_silo(&m_vertex_buffer_objects, 7, 8.0f, 7.0f),
      generate_factory_silo(&m_vertex_buffer_objects, 8, 8.0f, 7.0f),
      generate_factory_silo(&m_vertex_buffer_objects, 9, 8.0f, 7.0f),
      generate_factory_silo(&m_vertex_buffer_objects, 10, 8.0f, 7.0f),
      generate_factory_silo(&m_vertex_buffer_objects, 11, 8.0f, 7.0f)
    };
    const float FACTORY_RANGE = 35.0f;
    const float SILO_RANGE = 70.0f;

    bsd_srand(15);

    Vector3 base_pos(frand(-1681.0f - FACTORY_RANGE * 0.5f, -1681.0f + FACTORY_RANGE * 0.5f), 0.0f,
        HORIZON * 0.58f);
    Vector3 silo_base = base_pos - Vector3(0.0f, 0.0f, HORIZON * 0.28f);
    const float base_rot = frand(static_cast<float>(M_PI * 2.0));
  
    for(unsigned ii = 0; (ii < 6);)
    {
      float xdiff = frand(-FACTORY_RANGE, FACTORY_RANGE);
      float zdiff = frand(-FACTORY_RANGE, FACTORY_RANGE);
      float rot = base_rot + (((bsd_rand() % 2) == 0) ? 0.0f : static_cast<float>(M_PI * 0.5));
      Matrix4 transform = Matrix4::rotation_zxy(0.0f, rot, 0.0f, base_pos + Vector3(xdiff, 0.0f, zdiff));
      //std::cout << base_rot << " ; " << rot << std::endl;

      if(this->tryAddObject(factory_buildings[ii], transform, &height_map_land, 5.0f))
      {
        ++ii;
      }
    }

    Color fence_color = generate_factory_frame_color();
    CompiledMesh* fence1 = generate_factory_fence(&m_vertex_buffer_objects, &height_map_land, fence_color,
        Vector3(-1843.0f, 0.0f, -68.0f), Vector3(-1841.0f, 0.0f, -17.0f), 4);
    CompiledMesh* fence2 = generate_factory_fence(&m_vertex_buffer_objects, &height_map_land, fence_color,
        Vector3(-1605.0f, 0.0f, -15.0f), Vector3(-1839.0f, 0.0f, -15.0f), 9);

    this->addObject(fence1, Matrix4::identity());
    this->addObject(fence2, Matrix4::identity());

    bsd_srand(3);

    for(unsigned ii = 0; (ii < 16);)
    {
      float xdiff = frand(-SILO_RANGE * 2.0f, SILO_RANGE * 2.0f);
      float zdiff = frand(-SILO_RANGE, SILO_RANGE);
      float rot = frand(static_cast<float>(M_PI * 2.0));
      Matrix4 transform = Matrix4::rotation_zxy(0.0f, rot, 0.0f, silo_base + Vector3(xdiff, 0.0f, zdiff));
      //std::cout << base_rot << " ; " << rot << std::endl;

      if(this->tryAddObject(factory_silos[static_cast<unsigned>(bsd_rand()) % FACTORY_SILO_COUNT],
            transform, &height_map_land, 2.0f))
      {
        ++ii;
      }
    }
  }

  {
    CompiledMesh *windmill_base = generate_windmill_base(&m_vertex_buffer_objects);
    CompiledMesh *windmill_blades = generate_windmill_blades(&m_vertex_buffer_objects);

    bsd_srand(19);

    for(unsigned ii = 0; (ii < 16);)
    {
      float xpos = frand(WATER_START - TOLPPA_GAP * 9.0f, LAND_END + TOLPPA_GAP * 3.0f);
      float zpos = frand(-8.0f, HORIZON + 8.0f);
      Vector3 pos(xpos, 0.0f, zpos);
      const HeightMap* hmap = (LAND_END > pos[0]) ? &height_map_land : &height_map_water;
      float dir = frand(-0.9f, -0.7f);

      if(m_object_database.tryAddObject(windmill_base, Matrix4::rotation_zxy(0.0f, dir, 0.0f, pos),
            hmap, 0.2f))
      {
        float starting_rot = frand(static_cast<float>(M_PI * 2.0));
        float rot_speed = frand(0.03f, 0.045f);

        m_object_database.addObject(windmill_blades, Matrix4::pack_rta(0.0f, dir, starting_rot, 0.0f, 0.0f, rot_speed,
              pos + Vector3(0.0f, 1.0f, 0.0f) * (m_object_database.getLatestTranslationY() + WINDMILL_UP)));
        ++ii;
      }
    }
  }

  {
    const unsigned TREE_COUNT = 22;
    CompiledMesh *trees[TREE_COUNT] =
    {
      generate_tree(&m_vertex_buffer_objects, 4),
      generate_tree(&m_vertex_buffer_objects, 5),
      generate_tree(&m_vertex_buffer_objects, 6),
      generate_tree(&m_vertex_buffer_objects, 7),
      generate_tree(&m_vertex_buffer_objects, 8),
      generate_tree(&m_vertex_buffer_objects, 9),
      generate_tree(&m_vertex_buffer_objects, 10),
      generate_tree(&m_vertex_buffer_objects, 11),
      generate_tree(&m_vertex_buffer_objects, 12),
      generate_tree(&m_vertex_buffer_objects, 13),
      generate_tree(&m_vertex_buffer_objects, 14),
      generate_tree(&m_vertex_buffer_objects, 15),
      generate_tree(&m_vertex_buffer_objects, 16),
      generate_tree(&m_vertex_buffer_objects, 17),
      generate_tree(&m_vertex_buffer_objects, 18),
      generate_tree(&m_vertex_buffer_objects, 19),
      generate_tree(&m_vertex_buffer_objects, 20),
      generate_tree(&m_vertex_buffer_objects, 21),
      generate_tree(&m_vertex_buffer_objects, 22),
      generate_tree(&m_vertex_buffer_objects, 23),
      generate_tree(&m_vertex_buffer_objects, 24),
      generate_tree(&m_vertex_buffer_objects, 25)
    };

    generate_forest(const_cast<const CompiledMesh**>(static_cast<CompiledMesh**>(trees)), TREE_COUNT,
        &m_object_database, &height_map_land, 1, Vector3(-786.0f, 0.0f, -140.0f), 70.0f, 40.0f, 18);
    generate_forest(const_cast<const CompiledMesh**>(static_cast<CompiledMesh**>(trees)), TREE_COUNT,
        &m_object_database, &height_map_land, 2, Vector3(-923.0f, 0.0f, -90.0f), 30.0f, 70.0f, 14);

    generate_forest(const_cast<const CompiledMesh**>(static_cast<CompiledMesh**>(trees)), TREE_COUNT,
        &m_object_database, &height_map_land, 3, Vector3(-1506.0f, 0.0f, -110.0f), 30.0f, 86.0f, 12);

    generate_forest(const_cast<const CompiledMesh**>(static_cast<CompiledMesh**>(trees)), TREE_COUNT,
        &m_object_database, &height_map_land, 5, Vector3(-1930.0f, 0.0f, -120.0f), 40.0f, 60.0f, 11);

    //CompiledMesh *tree = generate_tree(&m_vertex_buffer_objects, 6);
    //m_object_database.addObject(tree, Matrix4::translation(-300.0f, 0.0f, -10.0f));
  }

  for(unsigned ii = 0; (ii < BIRD_COUNT); ++ii)
  {
    float fi = static_cast<float>(ii) / static_cast<float>(BIRD_COUNT);

    m_birds[ii] = generate_bird(&m_vertex_buffer_objects, fi);
  }
  //m_object_database.addObject(m_birds[5], Matrix4::translation(-300.0f, 0.0f, -10.0f));
  
  {
    CompiledMesh *panel = generate_panel(&m_vertex_buffer_objects);
    CompiledMesh *tower_outer = generate_tower(&m_vertex_buffer_objects, false);
    CompiledMesh *tower_mid = generate_tower(&m_vertex_buffer_objects, true);
    const Vector3 TOWER_POS(-1260.0f, 0.0f, -96.0f);
    const float MIN_RADIUS = 22.0f;
    const float MAX_RADIUS = 115.0f;
    const float Z_AWAY = -44.0f;
    const float Z_NEAR = 44.0f;
    const float MIN_ANGLE = 0.1f;
    const float MAX_ANGLE = 0.8f;

    this->tryAddObject(tower_outer, Matrix4::rotation_zxy(0.0f, 0.0f, 0.0f, TOWER_POS),
        &height_map_land, 2.4f);
    this->addObject(tower_mid, Matrix4::pack_rta(0.0f, 0.0f, 0.0f, 0.0f, 0.018f, 0.0f, TOWER_POS +
          Vector3(0.0f, 1.0f, 0.0f) * (m_object_database.getLatestTranslationY())));

    bsd_srand(25);

    for(unsigned ii = 0; (ii < 15);)
    {
      bool left = ((bsd_rand() % 2) != 0);
      float lmul = left ? -1.0f : 1.0f;
      float away = frand(1.0f);
      float right = frand(1.0f);
      Vector3 pos((right * (MAX_RADIUS - MIN_RADIUS) + MIN_RADIUS) * lmul + TOWER_POS[0], 0.0f,
          away * (Z_NEAR - Z_AWAY) + Z_AWAY + TOWER_POS[2]);
      float zrot = ((away + right) * (MAX_ANGLE - MIN_ANGLE) + MIN_ANGLE) * lmul * -1.0f;

      if(this->tryAddObject(panel, Matrix4::rotation_zxy(0.0f, zrot, 0.0f, pos), &height_map_land, 2.4f))
      {
        ++ii;
      }
    }
  }

  {
    CompiledMesh *ship = generate_ship(&m_vertex_buffer_objects);
    this->addObject(ship, Matrix4::rotation_zxy(0.0f, 2.3f, 0.0f, Vector3(-2590.0f, 0.0f, -74.0f)));
  }

  {
    unsigned const v_count = sizeof(g_v_mdl_auto)/sizeof(float)/3;
    unsigned const i_count = sizeof(g_i_mdl_auto)/sizeof(unsigned)/6;

    m_auto = new Object(compile_blender_model(&m_vertex_buffer_objects,
          v_count, g_v_mdl_auto, i_count, g_i_mdl_auto, 1.24f));
  }

  {
    unsigned const v_count = sizeof(g_v_mdl_lentsikka)/sizeof(float)/3;
    unsigned const i_count = sizeof(g_i_mdl_lentsikka)/sizeof(unsigned)/6;

    m_lentsikka = new Object(compile_blender_model(&m_vertex_buffer_objects,
          v_count, g_v_mdl_lentsikka, i_count, g_i_mdl_lentsikka, 0.64f));
  }
   
  unsigned const count_glyphs =
      (sizeof(font_data::glyph_records)/sizeof(font_data::glyph_record));

#if defined(USE_LD) && 0
  std::cout<<count_glyphs<<" glyphs in the font"<<std::endl;
#endif
  for(unsigned i=0; i<count_glyphs; ++i)
  {
    m_glyphs[i] = generate_glyph(&m_vertex_buffer_objects, i);
  }

  this->writeText("zugdorf hbf", Vector3(-210.85f, 1.7f, -5.9f), Vector3(1.0f, 0.0f, 0.0), 0.0f, 0.78f);

  this->writeText("greets", Vector3(-3725.8f, -17.3f, -20.7f), Vector3(1.0f, -0.2f, 0.0), -0.3f, 0.78f);

  this->writeText("adf", Vector3(-3728.2f, -18.1f, -20.7f), Vector3(1.0f, -0.25f, 0.0), -0.4f, 0.78f);
  this->writeText("blobtrox", Vector3(-3730.5f, -19.5f, -20.7f), Vector3(1.0f, -0.1f, 0.0), -0.1f, 0.78f);

  this->writeText("fit", Vector3(-3754.0f, -17.4f, -20.7f), Vector3(1.0f, -0.2f, 0.0), -0.4f, 0.78f);
  this->writeText("g incorporated", Vector3(-3761.0f, -17.4f, -20.7f), Vector3(1.0f, -0.23f, 0.0), -0.3f, 0.78f);
  this->writeText("hedelmae", Vector3(-3761.0f, -19.5f, -20.7f), Vector3(1.0f, -0.1f, 0.0), -0.12f, 0.78f);
  
  this->writeText("forsaken", Vector3(-3790.9f, -18.0f, -20.7f), Vector3(1.0f, 0.15f, 0.0), 0.24f, 0.78f);
  this->writeText("lonely coders", Vector3(-3790.8f, -19.9f, -20.7f), Vector3(1.0f, 0.22f, 0.0), 0.3f, 0.78f);
  this->writeText("peisik", Vector3(-3785.2f, -20.1f, -20.7f), Vector3(1.0f, 0.05f, 0.0), 0.04f, 0.78f);

  this->writeText("tekotuotanto", Vector3(-3820.8f, -17.4f, -20.7f), Vector3(1.0f, -0.05f, 0.0), -0.06f, 0.78f);
  this->writeText("tda", Vector3(-3820.6f, -19.1f, -20.7f), Vector3(1.0f, -0.11f, 0.0), -0.15f, 0.78f);
  this->writeText("traction", Vector3(-3816.5f, -19.6f, -20.7f), Vector3(1.0f, -0.03f, 0.0), -0.07f, 0.78f);

  this->writeText("raspberry pi", Vector3(-3838.4f, -20.2f, -6.6f), Vector3(1.0f, 0.0f, 0.0), 0.0f, 0.78f);

  this->writeText("battletech", Vector3(-3829.8f, -17.4f, -34.7f), Vector3(1.0f, 0.05f, 0.0), 0.07f, 0.78f);
  this->writeText("aquila", Vector3(-3829.9f, -18.9f, -34.7f), Vector3(1.0f, 0.1f, 0.0), 0.12f, 0.78f);
  this->writeText("model", Vector3(-3824.9f, -18.6f, -34.7f), Vector3(1.0f, 0.11f, 0.0), 0.1f, 0.78f);
  this->writeText("by", Vector3(-3828.2f, -20.1f, -34.7f), Vector3(1.0f, 0.04f, 0.0), 0.03f, 0.78f);
  this->writeText("warma", Vector3(-3826.1f, -19.9f, -34.7f), Vector3(1.0f, 0.05f, 0.0), 0.02f, 0.78f);

  this->writeText("code", Vector3(-3850.8f, -17.7f, -20.7f), Vector3(1.0f, 0.1f, 0.0), 0.11f, 0.78f);
  this->writeText("theflash", Vector3(-3848.7f, -18.9f, -20.7f), Vector3(1.0f, 0.15f, 0.0), 0.12f, 0.78f);
  this->writeText("trilkk", Vector3(-3845.4f, -20.0f, -20.7f), Vector3(1.0f, 0.13f, 0.0), 0.1f, 0.78f);

  this->writeText("lix kilobytes", Vector3(-3868.5f, -20.2f, -6.6f), Vector3(1.0f, 0.0f, 0.0), 0.0f, 0.74f);

  this->writeText("synth", Vector3(-3879.4f, -18.2f, -20.7f), Vector3(1.0f, 0.2f, 0.0), 0.3f, 0.78f);
  this->writeText("collateralburger", Vector3(-3881.4f, -20.1f, -20.7f), Vector3(1.0f, 0.2f, 0.0), 0.3f, 0.73f);

  this->writeText("faemiyah mmxv", Vector3(-3898.8f, -20.2f, -6.6f), Vector3(1.0f, 0.0f, 0.0), 0.0f, 0.78f);

  m_object_database.sort();

#if defined(USE_LD)
  uint32_t precalc_end = dnload_SDL_GetTicks();
  std::cout << "|precalc(visuals): " << (static_cast<float>(precalc_end - precalc_start) * .001f) << std::endl;
#endif
}

void GlobalContainer::writeText(const char *str, const Vector3 &pos, const Vector3 &dir, float rot, float adv)
{
  Vector3 unit_dir = normalize(dir);
  unsigned ii = 0;

  for(;;)
  {
    char cc = str[ii];

    if(!cc)
    {
      break;
    }
    if(' ' != cc)
    {
      float fi = static_cast<float>(ii);
      Matrix4 transform = Matrix4::rotation_zxy(0.0f, 0.0f, rot, pos + unit_dir * (fi * adv));

      this->addObject(m_glyphs[cc - 'a'], transform);
    }

    ++ii;
  }
}

void GlobalContainer::update()
{
  m_vertex_buffer_land.update(false);
  m_vertex_buffer_water.update(false);
  m_vertex_buffer_city.update(false);
  m_vertex_buffer_objects.update();
}

int GlobalContainer::precalc_function(void *user_data)
{
  GlobalContainer *globals = static_cast<GlobalContainer*>(user_data);

  {
    Thread thread_audio(precalc_function_audio, globals);
    Thread thread_visuals(precalc_function_visuals, globals);
  }

  globals->setDone();

  return 0;
}

int GlobalContainer::precalc_function_audio(void *user_data)
{
  GlobalContainer *globals = static_cast<GlobalContainer*>(user_data);

  globals->precalculateAudio();

  return 0;
}

int GlobalContainer::precalc_function_visuals(void *user_data)
{
  GlobalContainer *globals = static_cast<GlobalContainer*>(user_data);

  globals->precalculateVisuals();

  return 0;
}

//######################################
// Draw process ########################
//######################################

/** \brief Generate initial state.
 *
 * \param queue State queue to generate in.
 * \param globals Global storage.
 */
static State* generate_initial_state(StateQueue *queue, const GlobalContainer *globals)
{
  State *state = queue->acquireEmpty();

  state->setCameraJitter(NULL, 0.0f);
  state->setPosition(Vector3(STARTING_POS_X, STARTING_POS_Y, STARTING_POS_Z));
  state->setSpeed(Vector3(0.0f, 0.0f, 0.0f));
  state->setFrame(0);

  Matrix4 camera = Matrix4::rotation_zxy(STARTING_ROT_X, STARTING_ROT_Y, STARTING_ROT_Z,
      state->getPosition());
  state->initialize(globals->getProjection(), camera);

  globals->fillState(state);
 
  queue->finishEmpty(state);

  return state;
}

/** \brief Generate next camera position.
 *
 * \param prev Previous state.
 * \param next Next state.
 * \return Next camera matrix.
 */
static Matrix4 generate_camera_position(const State *prev, State *next)
{
#if defined(USE_LD)
  if(g_flag_developer && (prev != next))
  {
    if(g_print_position)
    {
      std::cout << g_train_positions[g_current_frame] << std::endl;
      g_print_position = false;
    }

    next->setPosition(g_train_positions[g_current_frame]);
    next->setSpeed(prev->getSpeed());

    return Matrix4::rotation_zxy(g_rot_x, g_rot_y, g_rot_z,
        next->getPosition() + g_position_offset);
  }
#endif
  Vector3 position = prev->getPosition();
  Vector3 speed = prev->getSpeed();
  float acceleration_x;
  float acceleration_y;

  position += speed;

  // Acceleration left/right.
  if((WATER_START + 500.0f) < position[0])
  {
    acceleration_x = dnload_fmaxf(speed[0] - TRAIN_ACCELERATION_NEG, -TRAIN_MAX_SPEED) - speed[0];
    speed[0] += acceleration_x;
  }
  else if((PIER_START + TOLPPA_GAP * 1.5f) < position[0])
  {
    acceleration_x = dnload_fminf(speed[0] + TRAIN_ACCELERATION_POS, -TRAIN_CRUISING_SPEED) - speed[0];
    speed[0] += acceleration_x;
  }
  else if((PIER_END + TOLPPA_GAP * 1.5f) < position[0])
  {
    acceleration_x = dnload_fminf(speed[0] + TRAIN_ACCELERATION_POS, -TRAIN_END_SPEED) - speed[0];
    speed[0] += acceleration_x;
  }
  else
  {
    acceleration_x = dnload_fminf(speed[0] + TRAIN_ACCELERATION_POS, 0.0f) - speed[0];
    speed[0] += acceleration_x;
  }

  // Acceleration up/down.
  if(((CITY_START - 270.0f) > position[0]) && (PIER_START + TOLPPA_GAP * 2.0f < position[0]))
  {
    acceleration_y = dnload_fmaxf(speed[1] - TRAIN_FALLOFF, -TRAIN_FALL_SPEED) - speed[1];
    speed[1] += acceleration_y;
  }
  else
  {
    acceleration_y = dnload_fminf(speed[1] + TRAIN_FALLOFF, 0.0f) - speed[1];
    speed[1] += acceleration_y;
  }

  next->setCameraJitter(prev, dnload_fabsf(acceleration_x) + dnload_fabsf(acceleration_y));
  next->setPosition(position);
  next->setSpeed(speed);

  return Matrix4::rotation_zxy(STARTING_ROT_X + next->getCameraJitterX(),
      STARTING_ROT_Y + next->getCameraJitterY(), STARTING_ROT_Z, position);
}

/** Generate next state from a state.
 *
 * \param prev Previous state.
 * \param next Next state.
 * \param globals Global storage.
 */
static void generate_state(const State *prev, State *next, const GlobalContainer *globals)
{
  next->initialize(globals->getProjection(), generate_camera_position(prev, next));
  next->setFrame(prev->getFrame() + 1);

  globals->fillState(next);
}

/** \brief Generates next state.
 *
 * May fail if state array is full.
 *
 * \param queue State queue to generate in.
 * \param globals Global storage.
 * \return True on success, false on failure.
 */
static bool generate_next_state(StateQueue *op, const GlobalContainer *globals)
{
  State *state = op->acquireEmpty();
  if(!state)
  {
    return false;
  }

  generate_state(op->getLastState(), state, globals);

  op->finishEmpty(state);
  return true;
}

/** \brief State generator thread function.
 *
 * \param data Data (actually state queue.
 * \return Return value (always 0).
 */
int state_thread_function(void *data)
{
  GlobalContainer *globals = static_cast<GlobalContainer*>(data);
  StateQueue *queue = globals->getStateQueue();
  unsigned frames_generated = 0;

  for(;;)
  {
    if(!generate_next_state(queue, globals))
    {
      break;
    }

    if(
#if defined(USE_LD)
        !g_flag_developer && (INTRO_LENGTH_FRAMES < ++frames_generated)
#else
        INTRO_LENGTH_FRAMES < ++frames_generated
#endif
      )
    {
      queue->terminate();
    }
  }

  return 0;
}

/** Unit quad data. */
static const int8_t UNIT_QUAD[] =
{
  1, -1,
  1, 1,
  -1, -1,
  -1, 1
};

/** \brief Bind a program with unit quad.
 *
 * \param program Program to use.
 * \param globals Global storage.
 */
static void bind_unit_quad(const Program *prg, const GlobalContainer *globals)
{
  float fw = static_cast<float>(globals->getScreenWidth());
  float fh = static_cast<float>(globals->getScreenHeight());

  prg->use();

  VertexBuffer::unbind();
  prg->attribPointer('P', 2, GL_BYTE, false, 0, UNIT_QUAD);

  prg->uniform('S', fw, fh);
}

/** \brief Draw the world.
 *
 * \param ticks Tick count.
 * \param globals Global storage.
 * \param state State to render.
 */
static void draw(unsigned ticks, const GlobalContainer *globals, State *state)
{
#if !defined(USE_MT_RAND)
  dnload_srandom(ticks);
#endif

  // Don't know if it's wise to interpolate light with partial random value but what gives.
  float pos = state->getPosition()[0] - frandom(64.0f);

  {
    const Program *prg = globals->getProgramDefault();
    const FrameBuffer *fbo = globals->getFrameBuffer();
    float rad = static_cast<float>(M_PI / 2.0 - M_PI / 3.0) +
      (PIER_END - pos) * (static_cast<float>(M_PI / 3.0) / PIER_END);

    fbo->bind();
    dnload_glEnable(GL_DEPTH_TEST);
    dnload_glClear(GL_DEPTH_BUFFER_BIT);
    
    prg->use();
    prg->uniform('L', normalize(Vector3(dnload_cosf(rad), dnload_sinf(rad), static_cast<float>(M_PI / 5.0))));
    state->draw();

    FrameBuffer::bindDefaultBuffer(globals->getScreenWidth(), globals->getScreenHeight());
    dnload_glDisable(GL_DEPTH_TEST);
  }

  if((-1666.0f >= pos) && (-2060.0f <= pos))
  {
    const float DIST = 1.5811f;
    const Program *prg = globals->getProgramBlueprint();

    float radians1 = frandom(static_cast<float>(M_PI / 2.0) - 0.5f, static_cast<float>(M_PI / 2.0) + 0.5f);
    float radians2 = radians1 + static_cast<float>(M_PI);

    bind_unit_quad(prg, globals);

    prg->uniform('A', dnload_cosf(radians1) * DIST, dnload_sinf(radians1) * DIST);
    prg->uniform('B', dnload_cosf(radians2) * DIST, dnload_sinf(radians2) * DIST); 
    prg->uniform('M', static_cast<float>(ticks) * -0.0012f, frand(0.0012f)); 

    dnload_glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
  }
  else
  {
    const Program *prg = globals->getProgramPost();

    bind_unit_quad(prg, globals);

    dnload_glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
  }
}

#if defined(USE_LD)

/** \brief Get OpenGL extensions.
 *
 * \return Extension string.
 */
std::string get_opengl_info()
{
  std::ostringstream sstr;

  sstr << reinterpret_cast<const char*>(glGetString(GL_VERSION)) << " || " <<
    reinterpret_cast<const char*>(glGetString(GL_SHADING_LANGUAGE_VERSION)) << " || " <<
    reinterpret_cast<const char*>(glGetString(GL_EXTENSIONS));

  return sstr.str();
}

#endif

/** \brief Swap buffers.
 *
 * Uses global context data.
 */
static void swap_buffers()
{
#if defined(DNLOAD_GLESV2)
  dnload_eglSwapBuffers(g_egl_display, g_egl_surface);
#else
  dnload_SDL_GL_SwapBuffers();
#endif
}

//######################################
// Main ################################
//######################################

#if defined(USE_LD)

/** \brief Record the intro to disk.
 *
 * \param queue State queue.
 * \param globals Global storage.
 */
static void perform_record(StateQueue *queue, const GlobalContainer *globals)
{
  // audio
  write_audio_callback(g_audio_buffer, AUDIO_BUFFER_SIZE);

  // video
  for(unsigned frame_idx = 0; (INTRO_LENGTH_FRAMES > frame_idx); ++frame_idx)
  {
    SDL_Event event;
    if(SDL_PollEvent(&event) && (event.type == SDL_KEYDOWN) && (event.key.keysym.sym == SDLK_ESCAPE))
    {
      break;
    }

    State *state = queue->acquireReady();
    if(!state)
    {
      break;
    }

    draw(frame_idx * FRAME_MILLISECONDS, globals, state);
    queue->finishReady();
    generate_next_state(queue, globals);

    write_frame_callback(globals->getScreenWidth(), globals->getScreenHeight(), frame_idx);
    swap_buffers();
  }
}

#endif

//######################################
// Main ################################
//######################################

#if defined(USE_LD)
int intro(unsigned screen_w, unsigned screen_h, bool flag_fullscreen, bool flag_record)
{
#else
/** \cond */
#define screen_w SCREEN_W
#define screen_h SCREEN_H
#define flag_fullscreen 0
/** \endcond */
void _start()
{
#endif
  dnload();
#if defined(DNLOAD_GLESV2)
  dnload_SDL_Init(SDL_INIT_AUDIO);
  videocore_create_native_window(screen_w, screen_h, &g_native_window);
  bool egl_result = egl_init(reinterpret_cast<NativeWindowType>(&g_native_window), &g_egl_display,
      &g_egl_surface);
#if defined(USE_LD)
  if(!egl_result)
  {
    terminate_program();
  }
  // Also init video purely for input.
  dnload_SDL_Init(SDL_INIT_VIDEO);
  SDL_SetVideoMode(160, screen_h * 160 / screen_w, 0, (flag_fullscreen ? SDL_FULLSCREEN : 0));
  SDL_ShowCursor(g_flag_developer);
#else
  (void)egl_result;
#endif
#else
  dnload_SDL_Init(SDL_INIT_VIDEO | SDL_INIT_AUDIO);
  dnload_SDL_SetVideoMode(static_cast<int>(screen_w), static_cast<int>(screen_h), 0,
      SDL_OPENGL | (flag_fullscreen ? SDL_FULLSCREEN : 0));
  dnload_SDL_ShowCursor(g_flag_developer);
#if defined(USE_LD)
  {
    GLenum err = glewInit();
    if(GLEW_OK != err)
    {
      std::cerr  << "glewInit(): " << glewGetErrorString(err) << std::endl;
      terminate_program();
    }
  }
#endif
#endif

  //dnload_glCullFace(GL_BACK);
  //dnload_glDepthFunc(GL_LESS);
  //dnload_glDepthMask(GL_TRUE);
  dnload_glDisable(GL_BLEND);
  dnload_glDisable(GL_DEPTH_TEST);
  dnload_glEnable(GL_CULL_FACE);

#if defined(USE_LD)
  uint32_t precalc_start = dnload_SDL_GetTicks();
#endif

  GlobalContainer globals(screen_w, screen_h);

  // Bind textures and their uniforms, they won't change.
  {
    const Texture *tex = globals.getTextureKonseptipaperi();
    const FrameBuffer *fbo = globals.getFrameBuffer();
    
    tex->bind(0);
    fbo->getTexture().bind(1);
  }
  {
    const Program *prg = globals.getProgramLoader();
    prg->use();
    prg->uniform('T', 0);
  }
  {
    const Program *prg = globals.getProgramPost();
    prg->use();
    prg->uniform('T', 1);
  }
  {
    const Program *prg = globals.getProgramBlueprint();
    prg->use();
    prg->uniform('N', 0);
    prg->uniform('T', 1);
  }

#if defined(USE_LD)
  uint32_t precalc_init = dnload_SDL_GetTicks();
  std::cout << get_opengl_info() << "\n|precalc(initial): " <<
    (static_cast<float>(precalc_init - precalc_start) * .001f) << std::endl;
#endif

  // Parallel loading phase.
  {
    Thread precalc_thread(GlobalContainer::precalc_function, &globals);
    const Program *prg = globals.getProgramLoader();
    uint32_t start_ticks = dnload_SDL_GetTicks();

    bind_unit_quad(prg, &globals);
    dnload_glViewport(0, 0, static_cast<GLsizei>(globals.getScreenWidth()),
        static_cast<GLsizei>(globals.getScreenHeight()));

    while(!globals.isDone())
    {
      uint32_t curr_ticks = dnload_SDL_GetTicks();

      prg->uniform('F', static_cast<float>(curr_ticks - start_ticks) * 0.00011f);

      dnload_glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

      swap_buffers();
    }
  }

  // Upload to GPU when ready.
  globals.update();
  StateQueue *queue = globals.getStateQueue();

#if defined(USE_LD)
  // Generate train positions to go forward and backward in time.
  if(g_flag_developer)
  {
    State *state = generate_initial_state(queue, &globals);
    State next;

    g_train_positions[0] = state->getPosition();

    for(unsigned ii = 1; (INTRO_LENGTH_FRAMES > ii); ++ii)
    {
      generate_camera_position((1 >= ii) ? state : &next, &next);

      g_train_positions[ii] = next.getPosition();
    }
  }
  else
#endif
  {
    generate_initial_state(queue, &globals);
  }

#if defined(USE_LD)
  if(flag_record)
  {
    perform_record(queue, &globals);
    terminate_program(0);
  }

  if(!g_flag_developer)
#endif
  {
    dnload_SDL_OpenAudio(&audio_spec, NULL);
    dnload_SDL_PauseAudio(0);
  }

  // Scope will ensure destruction of threading.
  {
    Thread state_thread(state_thread_function, &globals);
    uint32_t prev_ticks = dnload_SDL_GetTicks();
#if defined(USE_LD)
    unsigned successful_frames = 0;
    float move_speed = 0.1f;
    uint8_t mouse_look = 0;
    int8_t move_backward = 0;
    int8_t move_down = 0;
    int8_t move_forward = 0;
    int8_t move_left = 0;
    int8_t move_right = 0;
    int8_t move_up = 0;
    int8_t time_delta = 0;
#endif

    for(;;)
    {
#if defined(USE_LD)
      int mouse_look_x = 0;
      int mouse_look_y = 0;
#endif
      SDL_Event event;

#if defined(USE_LD)
      while(SDL_PollEvent(&event))
      {
        if(SDL_QUIT == event.type)
        {
          queue->terminate();
        }
        else if(SDL_KEYDOWN == event.type)
        {
          switch(event.key.keysym.sym)
          {
            case SDLK_a:
              move_left = 1;
              break;

            case SDLK_d:
              move_right = 1;
              break;

            case SDLK_e:
              move_up = 1;
              break;

            case SDLK_q:
              move_down = 1;
              break;

            case SDLK_s:
              move_backward = 1;
              break;

            case SDLK_w:
              move_forward = 1;
              break;

            case SDLK_LSHIFT:
            case SDLK_RSHIFT:
              move_speed = 2.0f;
              break;            

            case SDLK_LALT:
              time_delta = -1;
              break;

            case SDLK_MODE:
            case SDLK_RALT:
              time_delta = 1;
              break;

            case SDLK_SPACE:
              g_print_position = true;
              break;

            case SDLK_ESCAPE:
              queue->terminate();
              break;

            default:
              break;
          }
        }
        else if(SDL_KEYUP == event.type)
        {
          switch(event.key.keysym.sym)
          {
            case SDLK_a:
              move_left = 0;
              break;

            case SDLK_d:
              move_right = 0;
              break;

            case SDLK_e:
              move_up = 0;
              break;

            case SDLK_q:
              move_down = 0;
              break;

            case SDLK_s:
              move_backward = 0;
              break;

            case SDLK_w:
              move_forward = 0;
              break;

            case SDLK_LSHIFT:
            case SDLK_RSHIFT:
              move_speed = 1.0f / 10.0f;
              break;            

            case SDLK_MODE:
            case SDLK_LALT:
            case SDLK_RALT:
              time_delta = 0;
              break;

            default:
              break;
          }
        }
        else if(SDL_MOUSEBUTTONDOWN == event.type)
        {
          if(1 == event.button.button)
          {
            mouse_look = 1;
          }
        }
        else if(SDL_MOUSEBUTTONUP == event.type)
        {
          if(1 == event.button.button)
          {
            mouse_look = 0;
          }
        }
        else if(SDL_MOUSEMOTION == event.type)
        {
          if(0 != mouse_look)
          {
            mouse_look_x += event.motion.xrel;
            mouse_look_y += event.motion.yrel;
          }
        }
      }

      if(g_flag_developer)
      {
        float rt_x = cosf(g_rot_y);
        float rt_z = -sinf(g_rot_y);
        float fw_x = rt_z;
        float fw_z = -rt_x;
        float movement_rt = static_cast<float>(move_right - move_left) * move_speed;
        float movement_up = static_cast<float>(move_up - move_down) * move_speed;
        float movement_fw = static_cast<float>(move_forward - move_backward) * move_speed;

        if(0 != mouse_look_x)
        {
          float angle = static_cast<float>(mouse_look_x) / static_cast<float>(screen_h / 4) * 0.25f;

          g_rot_y += angle;
        }
        if(0 != mouse_look_y)
        {
          float angle = static_cast<float>(mouse_look_y) / static_cast<float>(screen_h / 4) * 0.25f;

          g_rot_x += angle;
        }

        g_position_offset += Vector3(movement_rt * rt_x + movement_fw * fw_x, movement_up,
            movement_rt * rt_z + movement_fw * fw_z);

        g_current_frame += time_delta * static_cast<int>(move_speed * 10.0f);
        if(0 > g_current_frame)
        {
          g_current_frame = 0;
        }
        else if(INTRO_LENGTH_FRAMES <= g_current_frame)
        {
          g_current_frame = INTRO_LENGTH_FRAMES - 1;
        }
      }
#else
      dnload_SDL_PollEvent(&event);
      if(event.type == SDL_KEYDOWN)
      {
        break;
      }
#endif

      State *state = queue->acquireReady();
      if(!state)
      {
        break;
      }

      // First check, discard frame if we're too far (2 frames) behind.
      {
        unsigned tick_diff = dnload_SDL_GetTicks() - prev_ticks;
        if(FRAME_MILLISECONDS * 3 < tick_diff)
        {
          prev_ticks += FRAME_MILLISECONDS;
#if defined(USE_LD)
          std::cout << "frameskip(" << successful_frames << "): " << tick_diff - FRAME_MILLISECONDS * 3 <<
            std::endl;
          successful_frames = 0;
#endif
          continue;
        }
#if defined(USE_LD)
        else
        {
          ++successful_frames;
        }
#endif
      }

      draw(prev_ticks, &globals, state);
      queue->finishReady();
      swap_buffers();

      // Second check, wait until we can proceed (less than one frame left).
      for(;;)
      {
        unsigned tick_diff = dnload_SDL_GetTicks() - prev_ticks;
        if(FRAME_MILLISECONDS <= tick_diff)
        {
          break;
        }
        dnload_SDL_Delay(0);
      }
      prev_ticks += FRAME_MILLISECONDS;
    }

    queue->terminate();
  }

#if defined(DNLOAD_GLESV2)
  egl_quit(g_egl_display);
#endif
  dnload_SDL_Quit();

#if defined(USE_LD)
  return 0;
#else
  asm_exit();
#endif
}

//######################################
// End #################################
//######################################

