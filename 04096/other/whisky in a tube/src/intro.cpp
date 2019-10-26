/** \file
 *
 * Self-contained intro source.
 */

//######################################
// Define ##############################
//######################################

/** \brief Screen mode.
 *
 * Negative values windowed.
 * Positive values fullscreen.
 *
 * Only has effect in release mode.
 */
#define DISPLAY_MODE 1080

/** \cond */
#if !defined(USE_LD)
#if (0 > (DISPLAY_MODE))
#define SCREEN_F 0
#define SCREEN_H (-(DISPLAY_MODE))
#elif (0 < (DISPLAY_MODE))
#define SCREEN_F 1
#define SCREEN_H (DISPLAY_MODE)
#else
#error "invalid display mode (pre)"
#endif
#if ((720 == SCREEN_H) || (800 == SCREEN_H))
#define SCREEN_W 1280
#elif ((1080 == SCREEN_H) || (1200 == SCREEN_H))
#define SCREEN_W 1920
#else
#error "invalid display mode (post)"
#endif
#endif
/** \endcond */

/** Audio channels. */
#define AUDIO_CHANNELS 2

/** Audio samplerate. */
#define AUDIO_SAMPLERATE 44100

/** Audio update rate. */
#define AUDIO_RATE (AUDIO_CHANNELS * AUDIO_SAMPLERATE)

#if defined(WIN32)
/* Audio tick rate, ~86.1Hz, maximum on Windows. */
#define AUDIO_TICK 512
#else
/* Audio tick rate, ~172.3Hz, lower values seem to cause underruns. */
#define AUDIO_TICK 256
#endif

/** Intro length (in bytes of audio). */
#define INTRO_LENGTH (71 * AUDIO_RATE)

/** Intro start position (in seconds). */
#define INTRO_START (0 * AUDIO_RATE)

/** Ticks per frame. */
#define TICKS_PER_FRAME (AUDIO_RATE / 60)

/** Ellipsoid height. */
#define ELLIPSOID_HEIGHT 256

/** Ellipsoid width. */
#define ELLIPSOID_WIDTH 1024

/** One side of whisky texture. */
#define WHISKY_SIDE 52

/** Whisky texture height. */
#define WHISKY_HEIGHT 130

/** Whisky ratio. */
#define WHISKY_RATIO_ABSOLUTE (static_cast<float>(WHISKY_HEIGHT) / static_cast<float>(WHISKY_SIDE))

/** \brief Stylistic whisky ratio.
 *
 * Slightly smaller than actual ratio for visual purposes. */
#define WHISKY_RATIO_STYLISTIC (static_cast<float>(WHISKY_HEIGHT - 16) / static_cast<float>(WHISKY_SIDE))

/** Integer stylistic whisky ratio squared. */
#define WHISKY_RATIO_ISQR static_cast<int>(WHISKY_RATIO_STYLISTIC * WHISKY_RATIO_STYLISTIC + 0.5f)

/** Number of movers. */
#define MOVER_COUNT 512

/** \cond */
#define STARTING_POS_X 0.0f
#define STARTING_POS_Y 0.0f
#define STARTING_POS_Z 2.0f
#define STARTING_FW_X 0.0f
#define STARTING_FW_Y 0.0f
#define STARTING_FW_Z -1.0f
#define STARTING_UP_X 0.0f
#define STARTING_UP_Y 1.0f
#define STARTING_UP_Z 0.0f
/** \endcond */

//######################################
// Include #############################
//######################################

#include "dnload.h"
#include "intro.hpp"

#include <algorithm>
#include <cfloat>

#if defined(USE_LD)
#include "glsl_shader_source.hpp"
#include <iostream>
#endif

//######################################
// Global data #########################
//######################################

/** Current audio position. */
#if defined(USE_LD)
static unsigned int g_audio_position = INTRO_START;
#else
static unsigned int g_audio_position;
#endif

/** Audio buffer for output (in record mode only). */
#if defined(USE_LD)
static int16_t g_audio_buffer[INTRO_LENGTH * 9 / 8];
#endif

/** Ellipsoid texture. */
static uint8_t g_texture_ellipsoid_data[ELLIPSOID_HEIGHT * ELLIPSOID_WIDTH];

/** Whisky texture. */
static uint8_t g_texture_whisky_data[WHISKY_SIDE * WHISKY_SIDE * WHISKY_HEIGHT];

/** Current control mode. */
static uint8_t g_mode_control;

/** Mover height. */
float g_mover_height;

/** Mover queue, number of movers to create next iteration. */
unsigned g_mover_queue;

/** Mover movement strength. */
float g_mover_strength;

#if defined(USE_LD)

/** \cond */
static float g_pos_x = STARTING_POS_X;
static float g_pos_y = STARTING_POS_Y;
static float g_pos_z = STARTING_POS_Z;
static float g_fw_x = STARTING_FW_X;
static float g_fw_y = STARTING_FW_Y;
static float g_fw_z = STARTING_FW_Z;
static float g_up_x = STARTING_UP_X;
static float g_up_y = STARTING_UP_Y;
static float g_up_z = STARTING_UP_Z;
/** \endcond */

/** Developer mode global toggle. */
static uint8_t g_flag_developer = 0;

#endif

//######################################
// rand() ##############################
//######################################

/** \brief Random number -op to op.
 *
 * \param op Limit.
 * \return Random number [-op, op[
 */
static float frand(float op)
{
  uint16_t ret = static_cast<uint16_t>(dnload_rand() & 0xFFFF);
  return static_cast<float>(*(reinterpret_cast<int16_t*>(&ret))) / 32768.0f * op;
}

#if defined(USE_LD)
/** \brief Open audio device and check for errors.
 *
 * \param requested Requested audio spec.
 * \return True on success, false on failure.
 */
bool open_audio(SDL_AudioSpec* requested)
{
  SDL_AudioSpec acquired;
  std::ostringstream sstr;

  SDL_OpenAudio(requested, &acquired);

  if(requested->freq != acquired.freq)
  {
    sstr << "requested audio frequency " << requested->freq << ", got " << acquired.freq << std::endl;
  }
  if(requested->format != acquired.format)
  {
    sstr << "requested audio format " << requested->format << ", got " << acquired.format << std::endl;
  }
  if(requested->channels != acquired.channels)
  {
    sstr << "requested " << requested->channels << "-channel audio, got " << acquired.channels << "-channel\n";
  }
  if(requested->samples != acquired.samples)
  {
    sstr << "requested audio buffer of " << requested->samples << " samples, got " << acquired.samples <<
      std::endl;
  }
  if(requested->callback != acquired.callback)
  {
    sstr << "requested audio callback " << requested->callback << ", got " << acquired.callback << std::endl;
  }
  if(requested->userdata != acquired.userdata)
  {
    sstr << "requested callback user data " << requested->userdata << ", got " << acquired.userdata <<
      std::endl;
  }

  std::string err = sstr.str();
  if(0 < err.length())
  {
    std::cerr << err;
    return false;
  }
  return true;
}
#endif

//######################################
// Shaders #############################
//######################################

/** Quad vertex shader. */
static const char g_shader_vertex_quad[] = ""
"attribute vec2 a;"
"uniform vec3 u[5];"
"varying vec3 b;"
"varying vec3 p;"
"void main()"
"{"
"vec3 g=normalize(u[3]);"
"vec3 r=normalize(cross(g,u[4]));"
"vec3 v=normalize(cross(r,g));"
#if defined(USE_LD)
"if(u[1].z != .0)"
"{"
"vec2 m=a;"
"if(1. < u[1].y)"
"{"
"m.x *= u[1].y;"
"}"
"else"
"{"
"m.y /= u[1].y;"
"}"
"b = m.x * r + m.y * v + g;"
"p = u[2];"
"}"
"else"
"{"
#endif
"vec3 s=u[2]/21.;"
"p=vec3(cos(s.x)*s.z,s.y-4.,sin(s.x)*s.z);"
"b=a.x*"
#if defined(USE_LD)
"u[1].y"
#elif defined(SCREEN_H) && ((720 == SCREEN_H) || (1080 == SCREEN_H))
"1.67"
#elif defined(SCREEN_H) && ((800 == SCREEN_H) || (1200 == SCREEN_H))
"1.6"
#else
#error "invalid screen height definition"
#endif
"*r+a.y*v+g;"
#if defined(USE_LD)
"}"
#endif
"gl_Position=vec4(a,0,1);"
"}";

/** Quad fragment shader. */
static const char g_shader_fragment_quad[] = "#define P 3.14159265\n"
"uniform sampler2D T;"
"uniform sampler3D W;"
"uniform vec3 u[5];"
"varying vec3 b;"
"varying vec3 p;"
"vec4 D=vec4(.01,-.01,.0,.022);"
"float f(vec3 p)"
"{"
"vec3 s=vec3(p.x,.0,p.z),d=p.xzy*vec3(.5,.5,.2)+.5;"
"return(texture3D(W,d).r*3.+texture3D(W,d+D.xxx).r+texture3D(W,d+D.xxy).r+texture3D(W,d+D.xyx).r+texture3D(W, d+D.yxx).r+texture3D(W,d+D.yyx).r+texture3D(W,d+D.yxy).r+texture3D(W,d+D.xyy).r+texture3D(W,d+D.yyy).r)/11.-.5+max(.0,mix(.0,9.,dot(s,s)-.8));"
"}"
"vec3 g(vec3 n,float N)"
"{"
"return normalize(vec3(f(n+D.wzz),f(n+D.zwz),f(n+D.zzw))-N);"
"}"
"bool S(vec3 s, vec3 p, vec3 d, out vec3 o)"
"{"
"float b=s.y*s.y-4.*s.x*s.z;"
"if(.0>b)"
#if defined(USE_LD)
"return false;"
#else
"return 0;"
#endif
"vec2 a=vec2(-s.y-sqrt(b),-s.y+sqrt(b))/(2.*s.x);"
"b=.0>a.x?(.0>a.y?.0:a.y):(.0>a.y?a.x:min(a.x,a.y));"
"if(.0>=b)"
#if defined(USE_LD)
"return false;"
#else
"return 0;"
#endif
"o=p+b*d;"
#if defined(USE_LD)
"return true;"
#else
"return 1;"
#endif
"}"
"vec3 U(vec3 p,vec3 d)"
"{"
"return vec3(dot(d.xz,d.xz),dot(p.xz,d.xz)*2.,dot(p.xz,p.xz)-1.);"
"}"
"vec3 E(vec3 p,vec3 d,float r)"
"{"
"vec3 h=vec3(1.,.5,1.);"
"return vec3(dot(d*h,d*h),dot(p*h,d*h)*2.,dot(p*h,p*h)-r*r);"
"}"
"void main()"
"{"
"vec3 L=normalize(vec3(1)),d=b,c=p,o,r;"
"vec4 l,w;"
"float N;"
#if defined(USE_LD)
"l=vec4(0);"
"o=vec3(0);"
"w=vec4(0);"
#endif
"if(S(U(c,d),c,d,r))"
"{"
"vec3 s=normalize(vec3(r.x,.0,r.z));"
"N=dot(-normalize(vec3(d.x,.0,d.z)),s);"
"d=normalize(mix(-s,d,sin((N*.22+.28)*P)));"
"c=r;"
"l=vec4(vec3(1)*dot(s,L)*.3+.7,.8*(1.-N));"
"for(int i=0;i<222;++i)"
"{"
"vec3 n=c+d*.02;"
"s=vec3(n.x,.0,n.z);"
"N=dot(s,s);"
"if(1.<N)break;"
"N=f(n);"
"if(.0>N)"
"{"
"s=g(n,N);"
"N=dot(-s,d);"
"float a=dot(normalize(L-2.*s*dot(s,L)),d)*.4+.4;"
"w=vec4(mix(mix(vec3(mix(vec2(.7,.2),vec2(1.,.6),N),.1),vec3(1.,.1,.0)*N,u[1].x),vec3(1),a*a*a),mix(1.,.85,N));"
"break;"
"}"
"c=n;"
"}"
"}"
"for(float i=.0;i<11.;++i)"
"{"
"if(S(E(c,d,11.+i*.1),c,d,r))"
"{"
"N=u[0].x*.00000004*(i+1.);"
"float b=atan(r.z,r.x)/P/2.+(mod(i,2.)!=.0?N:-N);"
"if(step(.88,texture2D(T,vec2(i+b,(r.y+i)*.02)).r)>.0)"
"{"
"o=mix(vec3(.3,.2,.9),vec3(.0,.2,.2),u[1].x)/(i*.5+1.)*(dot(normalize(-r),L)*.2+.8);"
"break;"
"}"
"}"
"}"
"o=mix(mix(o*(1.+u[0].z),w.rgb*(1.-u[0].z*.3),w.a),l.rgb,l.a);"
"N=(o.r+o.g+o.b)/3.;"
"gl_FragColor=vec4(mix(o,vec3(N),u[0].y),1);"
"}";

/** \cond */
GLuint g_program_quad;
GLuint g_textures[2];
/** \endcond */

/** \brief Create a shader.
 *
 * \param sh Shader content.
 * \param st Shader type.
 * \return Compiled shader.
 */
static GLuint shader_create(const char *source, GLenum st)
{
  GLuint ret = dnload_glCreateShader(st);
#if defined(USE_LD)
  GlslShaderSource glsl_source(source);
  const GLchar *pretty_source = static_cast<const GLchar*>(glsl_source.c_str());
  dnload_glShaderSource(ret, 1, &pretty_source, NULL);
#else
  dnload_glShaderSource(ret, 1, static_cast<const GLchar**>(&source), NULL);
#endif
  dnload_glCompileShader(ret);
#if defined(USE_LD)
  {
    std::string log(GlslShaderSource::get_shader_info_log(ret));
    GLint status;

    std::cout << pretty_source << std::endl;
    if(0 < log.length())
    {
      std::cout << log << std::endl;
    }

    glGetShaderiv(ret, GL_COMPILE_STATUS, &status);
    if(status != GL_TRUE)
    {
      SDL_Quit();
      exit(1);
    }
  }
#endif
  return ret;
}

/** \brief Create a program.
 *
 * Create a shader program using one vertex shader and one fragment shader.
 *
 * \param vs Vertex shader.
 * \param fs Fragement shader.
 * \return The compiled and linked program.
 */
static GLuint program_create(const char *vertex, const char* fragment)
{
  GLuint ret = dnload_glCreateProgram();

  dnload_glAttachShader(ret, shader_create(vertex, GL_VERTEX_SHADER));
  dnload_glAttachShader(ret, shader_create(fragment, GL_FRAGMENT_SHADER));
  dnload_glLinkProgram(ret);
#if defined(USE_LD)
  {
    std::string log(GlslShaderSource::get_program_info_log(ret));
    GLint status;

    if(0 < log.length())
    {
      std::cout << log << std::endl;
    }

    glGetProgramiv(ret, GL_LINK_STATUS, &status);
    if(status != GL_TRUE)
    {
      SDL_Quit();
      exit(1);
    }
    std::cout << "GLSL program compiles to: " << ret << std::endl;
  }
#endif
  return ret;
}

//######################################
// Draw ################################
//######################################

/** \brief Debug uniforms.
 *
 * Common legend:
 * 0: Time.
 * 1: Grayscale factor.
 * 2: Inverse color flash factor.
 * 3: Whisky / blood switch.
 * 4: Screen aspect ratio x/y (disabled in release mode).
 * 5: Developer mode toggle (disabled in release mode).
 * ...
 * 7: Y position.
 * ...
 * 9: X forward.
 * 10: Y forward.
 * 11: Z forward.
 * 12: X up.
 * 14: Y up.
 * 15: Z up.
 *
 * And in developer mode, additionally:
 * 6: X position.
 * ...
 * 8: Z position.
 *
 * Otherwise:
 * 6: Angular position.
 * ...
 * 8: Radial position.
 */
#if defined(USE_LD)
static float g_uniform_array[3 * 5] =
{
  0.0f, 0.0f, 0.0f,
  0.0f, 0.0f, 0.0f,
  STARTING_POS_X, STARTING_POS_Y, STARTING_POS_Z,
  STARTING_FW_X, STARTING_FW_Y, STARTING_FW_Z,
  STARTING_UP_X, STARTING_UP_Y, STARTING_UP_Z,
};
#else
static float g_uniform_array[3 * 5];
#endif

/** \brief Camera data.
 *
 * Composed of 11 values for each scene. For each 'scene':
 * 0: Camera angular position 1.
 * 1: Camera Y position 1.
 * 2: Camera radius 1.
 * 3: Forward random seed 1.
 * 4: Up random seed 1.
 * 5: Camera angular position 1.
 * 6: Camera Y position 1.
 * 7: Camera radius 1.
 * 8: Forward random seed 1.
 * 9: Up random seed 1.
 * 10: Time (in ~1/4 of a second).
 */
static const uint8_t g_camera_data[] =
{
  50, 158, 220, 203, 101, 59, 84, 72, 55, 101, 53,
  121, 86, 52, 220, 88, 88, 88, 72, 164, 18, 161,
  50, 27, 12, 218, 38, 36, 49, 2, 218, 38, 54,
  35, 106, 65, 194, 239, 54, 89, 73, 203, 209, 108,
  123, 116, 45, 220, 50, 99, 120, 48, 81, 94, 107,
  22, 89, 9, 25, 103, 22, 89, 8, 25, 103, 75,
  28, 86, 55, 225, 48, 29, 86, 126, 225, 251, 81,
};

/** \brief Movers.
 *
 * Divided into elements of 6 floats.
 *
 * 0-2: Speed.
 * 3-5: Position.
 */
static float g_mover_array[6 * MOVER_COUNT];

/** Number of movers. */
static unsigned g_mover_count = 0;

/** \brief Remove a mover.
 *
 * @param idx Mover index.
 */
static void remove_mover(unsigned idx)
{
  if(idx + 6 < g_mover_count)
  {
    for(unsigned ii = 0; (ii < 6); ++ii)
    {
      g_mover_array[idx + ii] = g_mover_array[g_mover_count - 6 + ii];
    }
  }
  g_mover_count -= 6;
}

/** \brief Random direction.
 *
 * @param seed Random seed.
 * @param dst Destination array.
 */
static void random_coordinate(unsigned seed, float *dst)
{
  dnload_srand(seed);

  dst[0] = frand(1.0f);
  dst[1] = frand(1.0f);
  dst[2] = frand(1.0f);
}

/** \brief Write to whisky texture.
 *
 * @param px X coordinate.
 * @param py Y coordinate.
 * @param diff Difference.
 */
static void whisky_write(int pz, int pxy, int diff)
{
  int idx = pz * WHISKY_SIDE * WHISKY_SIDE + pxy;
  int val = static_cast<int>(g_texture_whisky_data[idx]) - diff;

  g_texture_whisky_data[idx] = static_cast<uint8_t>(std::max(std::min(255, val), 0));
}

/** \brief Calculate next frame.
 *
 * \param ticks Current tick count.
 */
static void calc(unsigned ticks)
{
  dnload_srand(ticks);
  {
    float cz = g_mover_height;

    if(g_mode_control == 0)
    {
      cz = 0.06f * WHISKY_HEIGHT;
    }
    if(g_mode_control == 1)
    {
      cz = 0.92f * WHISKY_HEIGHT;
    }

    while(0 < g_mover_queue)
    {
      if(6 * MOVER_COUNT > g_mover_count)
      {
        float cx;
        float cy;

        g_mover_array[g_mover_count + 0] = frand(g_mover_strength);
        g_mover_array[g_mover_count + 1] = frand(g_mover_strength);
        g_mover_array[g_mover_count + 2] = frand(g_mover_strength) * WHISKY_RATIO_ABSOLUTE;

        if(g_mode_control < 2)
        {
          cx = frand(0.4f * WHISKY_SIDE);
          cy = frand(0.4f * WHISKY_SIDE);
        }
        else
        {
          cx = frand(0.08f * WHISKY_SIDE);
          cy = frand(0.08f * WHISKY_SIDE);
        }

        g_mover_array[g_mover_count + 3] = cx;
        g_mover_array[g_mover_count + 4] = cy;
        g_mover_array[g_mover_count + 5] = cz;

        g_mover_count += 6;
      }

      --g_mover_queue;
    }
  }

  for(unsigned ii = 0; (ii < g_mover_count);)
  {
    float dx = g_mover_array[ii + 0];
    float dy = g_mover_array[ii + 1];
    float dz = g_mover_array[ii + 2];
    float px = g_mover_array[ii + 3] + dx;
    float py = g_mover_array[ii + 4] + dy;
    float pz = g_mover_array[ii + 5] + dz;
    float rad = px * px + py * py;

    //printf("[ %1.2f ; %1.2f ; %1.2f ] || [ %1.2f ; %1.2f ; %1.2f ]\n", px, py, pz, dx, dy, dz);

    if((0.4f * 0.4f * WHISKY_SIDE * WHISKY_SIDE) < rad)
    {
      px *= 0.99f;
      py *= 0.99f;
      dx -= px * 0.001f;
      dy -= py * 0.001f;
    }

    if(g_mode_control < 2)
    {
      dx *= 0.99f;
      dy *= 0.99f;
      dz -= 0.00017f * WHISKY_HEIGHT;

      if((0.04f * WHISKY_HEIGHT) > pz)
      {
        remove_mover(ii);
        continue;
      }
    }
    else
    {
      dx -= px * 0.001f;
      dy -= py * 0.001f;
      px *= 0.99f;
      py *= 0.99f;

      if((0.05f * 0.05f * WHISKY_SIDE * WHISKY_SIDE) > rad)
      {
        remove_mover(ii);
        continue;
      }
    }

    pz = std::max(pz, 0.04f * WHISKY_HEIGHT);
    pz = std::min(pz, 0.94f * WHISKY_HEIGHT);

    g_mover_array[ii + 0] = dx;
    g_mover_array[ii + 1] = dy;
    g_mover_array[ii + 2] = dz;
    g_mover_array[ii + 3] = px;
    g_mover_array[ii + 4] = py;
    g_mover_array[ii + 5] = pz;

    static const int WHISKY_HEIGHT_ITER = WHISKY_HEIGHT / 26;
    static const int WHISKY_SIDE_ITER = WHISKY_SIDE / 26;
    int ix = static_cast<int>(px + WHISKY_SIDE * 0.5f);
    int iy = static_cast<int>(py + WHISKY_SIDE * 0.5f);
    int iz = static_cast<int>(pz);

    for(int jj = -WHISKY_HEIGHT_ITER; (jj <= WHISKY_HEIGHT_ITER); ++jj)
    {
      for(int kk = -WHISKY_SIDE_ITER; (kk <= WHISKY_SIDE_ITER); ++kk)
      {
        for(int ll = -WHISKY_SIDE_ITER; (ll <= WHISKY_SIDE_ITER); ++ll)
        {
          int diff = std::max(96 - ((ll * ll + kk * kk + (jj * jj >> 2)) << 4), 0);

          whisky_write(jj + iz, ((kk + iy) * WHISKY_SIDE) + (ll + ix), diff);
        }
      }
    }

    ii += 6;
  }

  for(int ii = 0; (ii < WHISKY_HEIGHT); ++ii)
  {
    for(int jj = 0; (jj < WHISKY_SIDE * WHISKY_SIDE); ++jj)
    {
      int ht = (WHISKY_HEIGHT - 14) - ii;
      int lt = ii - 6;
      int diff = 1 - (lt * 2);

      if(0 < g_mode_control)
      {
        diff = std::max(diff, 1 - (ht * 2));
      }

      whisky_write(ii, jj, std::max(diff, -6));
    }
  }

  g_uniform_array[0] = static_cast<float>(ticks);
  g_uniform_array[1] *= 0.98f;
  g_uniform_array[2] *= 0.98f;

#if defined(USE_LD)
  if(!g_flag_developer)
#endif
  {
    const uint8_t *iter = g_camera_data;

    for(;;)
    {
      unsigned ctime = iter[10] * (AUDIO_RATE / 9);

      if(ctime > ticks)
      {
        float relative = static_cast<float>(ticks) / static_cast<float>(ctime);
        float lerp_a[9];
        float lerp_b[9];

        for(unsigned ii = 0; (ii < 3); ++ii)
        {
          lerp_a[ii] = static_cast<float>(iter[ii + 0]);
          lerp_b[ii] = static_cast<float>(iter[ii + 5]);
        }
        random_coordinate(iter[3], lerp_a + 3);
        random_coordinate(iter[4], lerp_a + 6);
        random_coordinate(iter[8], lerp_b + 3);
        random_coordinate(iter[9], lerp_b + 6);

        for(unsigned ii = 0; (ii < 9); ++ii)
        {
          g_uniform_array[ii + 6] = (lerp_b[ii] - lerp_a[ii]) * relative + lerp_a[ii];
        }
        break;
      }

      ticks -= ctime;
      iter += 11;
    }
  }
}

/** \brief Draw the world.
 */
static void draw()
{
#if defined(USE_LD)
  glDisable(GL_DEPTH_TEST);
  glDisable(GL_BLEND);
#endif

  dnload_glUseProgram(g_program_quad);

#if defined(USE_LD)
  if(g_flag_developer)
  {
    g_uniform_array[6] = g_pos_x;
    g_uniform_array[7] = g_pos_y;
    g_uniform_array[8] = g_pos_z;
    g_uniform_array[9] = g_fw_x;
    g_uniform_array[10] = g_fw_y;
    g_uniform_array[11] = g_fw_z;
    g_uniform_array[12] = g_up_x;
    g_uniform_array[13] = g_up_y;
    g_uniform_array[14] = g_up_z;
  }
#endif
  dnload_glUniform3fv(dnload_glGetUniformLocation(g_program_quad, "u"), 5, g_uniform_array);

#if defined(USE_LD) // uniform value guaranteed 0 if never written
  dnload_glUniform1i(dnload_glGetUniformLocation(g_program_quad, "T"), 0);
#endif
  dnload_glTexSubImage3D(GL_TEXTURE_3D, 0, 0, 0, 0, WHISKY_SIDE, WHISKY_SIDE, WHISKY_HEIGHT, GL_RED,
      GL_UNSIGNED_BYTE, g_texture_whisky_data);
  dnload_glUniform1i(dnload_glGetUniformLocation(g_program_quad, "W"), 1);

#if defined(USE_LD)
  glEnableVertexAttribArray(glGetAttribLocation(g_program_quad, "a"));
#endif
  dnload_glRects(-1, -1, 1, 1);
}

//######################################
// Music ###############################
//######################################

extern "C"
{
#include "chip.c"
}

/** \brief Update audio stream.
 *
 * \param userdata Not used.
 * \param stream Target stream.
 * \param len Number of bytes to write.
 */
static void audio_callback(void *userdata, Uint8 *stream, int len)
{
  (void)userdata;
  render(reinterpret_cast<sample_t*>(stream), static_cast<unsigned>(len)/sizeof(sample_t));
}

/** SDL audio specification struct. */
static SDL_AudioSpec audio_spec =
{
  AUDIO_SAMPLERATE,
  AUDIO_S16,
  AUDIO_CHANNELS,
  0,
  AUDIO_TICK,
  0,
  0,
  audio_callback,
  NULL
};

//######################################
// Main ################################
//######################################

#if defined(USE_LD)
int intro(unsigned screen_w, unsigned screen_h, uint8_t flag_developer, uint8_t flag_fullscreen,
    uint8_t flag_record)
{
  g_flag_developer = flag_developer;
#else
/** \cond */
#define screen_h SCREEN_H
#define screen_w SCREEN_W
#define flag_fullscreen SCREEN_F
#define flag_developer 0
/** \endcond */
void _start()
{
#endif
  dnload();
  dnload_SDL_Init(SDL_INIT_VIDEO | SDL_INIT_AUDIO);
  dnload_SDL_SetVideoMode(static_cast<int>(screen_w), static_cast<int>(screen_h), 0,
      SDL_OPENGL | (flag_fullscreen ? SDL_FULLSCREEN : 0));
  dnload_SDL_ShowCursor(flag_developer);
#if defined(USE_LD)
  {
    GLenum err = glewInit();
    if(GLEW_OK != err)
    {
      SDL_Quit();
      std::cerr << "glewInit(): " << glewGetErrorString(err) << std::endl;
      return 1;
    }
  }
#endif

  g_program_quad = program_create(g_shader_vertex_quad, g_shader_fragment_quad);
#if defined(USE_LD)
  std::cout << "Quad program: " << g_program_quad << "\nAttributes:\na: " <<
    glGetAttribLocation(g_program_quad, "a") << "\nu: " << glGetUniformLocation(g_program_quad, "u") <<
    std::endl;
#endif

#if defined(USE_LD)
  g_uniform_array[4] = static_cast<float>(screen_w) / static_cast<float>(screen_h);
  g_uniform_array[5] = static_cast<float>(flag_developer);
#endif

  {
    unsigned ii;

    for(ii = 0; (ii < ELLIPSOID_HEIGHT); ++ii)
    {
      unsigned offset = dnload_rand() % ELLIPSOID_WIDTH / 2;
      unsigned kk = dnload_rand() % ELLIPSOID_WIDTH / 4;
      unsigned jj;
      uint8_t write = 0xFF;

      for(jj = 0; (jj < ELLIPSOID_WIDTH); ++jj)
      {
        g_texture_ellipsoid_data[ii * ELLIPSOID_WIDTH + (jj + offset) % ELLIPSOID_WIDTH] = write;

        if(!(kk--))
        {
          write = static_cast<uint8_t>(~write);
          kk = dnload_rand() % ELLIPSOID_WIDTH / 4;
        }
      }
    }

    for(ii = 0; (ii < WHISKY_SIDE * WHISKY_SIDE * WHISKY_HEIGHT); ++ii)
    {
      g_texture_whisky_data[ii] = 128;
    }
  }

  dnload_glGenTextures(2, g_textures);
  dnload_glActiveTexture(GL_TEXTURE0);
  dnload_glBindTexture(GL_TEXTURE_2D, g_textures[0]);
#if defined(USE_LD)
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
#endif
  dnload_glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
  dnload_glTexImage2D(GL_TEXTURE_2D, 0, GL_RED, ELLIPSOID_WIDTH, ELLIPSOID_HEIGHT, 0, GL_RED, GL_UNSIGNED_BYTE,
      g_texture_ellipsoid_data);
  dnload_glActiveTexture(GL_TEXTURE1);
  dnload_glBindTexture(GL_TEXTURE_3D, g_textures[1]);
#if defined(USE_LD)
  glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
  glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
  glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
#endif
  dnload_glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
  dnload_glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_WRAP_R, GL_CLAMP_TO_EDGE);
  dnload_glTexImage3D(GL_TEXTURE_3D, 0, GL_RED, WHISKY_SIDE, WHISKY_SIDE, WHISKY_HEIGHT, 0, GL_RED,
      GL_UNSIGNED_BYTE, g_texture_whisky_data);

  unsigned cumulative = INTRO_START;

#if defined(USE_LD)
  if(flag_record)
  {
    sample_t *stream = reinterpret_cast<sample_t*>(g_audio_buffer);
    SDL_Event event;
    unsigned frame_idx = 0;

    // combined audio / video
    for(;;)
    {
      if(SDL_PollEvent(&event) && (event.type == SDL_KEYDOWN) && (event.key.keysym.sym == SDLK_ESCAPE))
      {
        break;
      }

      render(stream, AUDIO_TICK);

      unsigned currtick = g_audio_position - cumulative;

      while(TICKS_PER_FRAME <= currtick)
      {
        currtick -= TICKS_PER_FRAME;
        cumulative += TICKS_PER_FRAME;
        calc(cumulative);
        draw();
        SDL_GL_SwapBuffers();
        write_frame_callback(screen_w, screen_h, frame_idx);
        ++frame_idx;
      }
      
      if(cumulative >= INTRO_LENGTH)
      {
        break;
      }
      stream += AUDIO_TICK;
    }

    write_audio_callback(g_audio_buffer, static_cast<unsigned>(INTRO_LENGTH * sizeof(uint16_t)));

    SDL_Quit();
    return 0;
  }

  if(!flag_developer)
  {
    if(!open_audio(&audio_spec))
    {
      SDL_Quit();
      return 1;
    }
    SDL_PauseAudio(0);
  }
#else
  dnload_SDL_OpenAudio(&audio_spec, NULL);
  dnload_SDL_PauseAudio(0);
#endif

#if defined(USE_LD)
  unsigned starttick = SDL_GetTicks();	
#endif

  for(;;)
  {
#if defined(USE_LD)
    static float move_speed = 1.0f / 60.0f;
    static float strength = -1.0f;
    static float saved_pos_x = 0.0f;
    static float saved_pos_y = 0.0f;
    static float saved_pos_z = 0.0f;
    static float saved_fw_x = 0.0f;
    static float saved_fw_y = 0.0f;
    static float saved_fw_z = 0.0f;
    static float saved_up_x = 0.0f;
    static float saved_up_y = 0.0f;
    static float saved_up_z = 0.0f;
    static uint8_t mouse_look = 0;
    static int8_t move_backward = 0;
    static int8_t move_down = 0;
    static int8_t move_forward = 0;
    static int8_t move_left = 0;
    static int8_t move_right = 0;
    static int8_t move_up = 0;
    int mouse_look_x = 0;
    int mouse_look_y = 0;
    static bool insert = false;
    static bool quit = false;
#endif
    SDL_Event event;
    unsigned currtick;

#if defined(USE_LD)
    if(flag_developer)
    {
      currtick = static_cast<unsigned>(static_cast<float>(SDL_GetTicks() - starttick) / 1000.0f *
          static_cast<float>(AUDIO_RATE)) + INTRO_START - cumulative;
    }
    else
    {
      currtick = g_audio_position - cumulative;
    }

    if(((cumulative >= INTRO_LENGTH) && !flag_developer) || quit)
    {
      break;
    }

    if(TICKS_PER_FRAME > currtick)
    {
      SDL_Delay(0);
      continue;
    }

    while(SDL_PollEvent(&event))
    {
      if(SDL_QUIT == event.type)
      {
        quit = true;
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

          case SDLK_1:
            g_mode_control = 0;
            break;

          case SDLK_2:
            g_mode_control = 1;
            break;

          case SDLK_3:
            g_mode_control = 2;
            break;

          case SDLK_HOME:
            g_uniform_array[1] = 1.0f;
            break;

          case SDLK_END:
            g_uniform_array[2] = 1.0f;
            break;

          case SDLK_PAGEUP:
            g_uniform_array[1] = 2.0f;
            break;

          case SDLK_PAGEDOWN:
            g_uniform_array[2] = -8.0f;
            break;

          case SDLK_INSERT:
            insert = true;
            break;

          case SDLK_KP0:
            strength = 0.1f;
            break;

          case SDLK_KP1:
            strength = 0.2f;
            break;

          case SDLK_KP2:
            strength = 0.3f;
            break;

          case SDLK_KP3:
            strength = 0.4f;
            break;

          case SDLK_KP4:
            strength = 0.5f;
            break;

          case SDLK_KP5:
            strength = 0.6f;
            break;

          case SDLK_KP6:
            strength = 0.7f;
            break;

          case SDLK_KP7:
            strength = 0.8f;
            break;

          case SDLK_KP8:
            strength = 0.9f;
            break;

          case SDLK_KP9:
            strength = 1.0f;
            break;

          case SDLK_KP_MINUS:
            g_uniform_array[3] = std::max(g_uniform_array[3] - 0.1f, -1.0f);
            break;

          case SDLK_KP_PLUS:
            g_uniform_array[3] = std::min(g_uniform_array[3] + 0.1f, 2.0f);
            break;

          case SDLK_LSHIFT:
          case SDLK_RSHIFT:
            move_speed = 1.0f / 5.0f;
            break;            

          case SDLK_SPACE:
            {
              int ipos_x;
              int ipos_y;
              int ipos_z;
              saved_pos_x = g_pos_x;
              saved_pos_y = g_pos_y;
              saved_pos_z = g_pos_z;
              saved_fw_x = g_fw_x;
              saved_fw_y = g_fw_y;
              saved_fw_z = g_fw_z;
              saved_up_x = g_up_x;
              saved_up_y = g_up_y;
              saved_up_z = g_up_z;
              {
                float angle = atan2f(g_pos_z, g_pos_x);

                if(angle < 0.0f)
                {
                  angle += 2.0f * static_cast<float>(M_PI);
                }

                ipos_x = static_cast<int>(angle * 21.0f + 0.5f);
              }
              {
                float radius = sqrtf(g_pos_x * g_pos_x + g_pos_z * g_pos_z);

                printf("radius: %f\n", radius);

                ipos_z = static_cast<int>(radius * 21.0f + 0.5f);
              }
              ipos_y = static_cast<int>((g_pos_y + 4.0f) * 21.0f + 0.5f);
              {
                float min_diff_fw = FLT_MAX;
                float min_diff_up = FLT_MAX;
                unsigned srand_fw = 0;
                unsigned srand_up = 0;

                for(unsigned ii = 0; (ii < 256); ++ii)
                {
                  dnload_srand(ii);

                  float ax = frand(1.0f);
                  float ay = frand(1.0f);
                  float az = frand(1.0f);
                  float fx = ax - g_fw_x;
                  float fy = ay - g_fw_y;
                  float fz = az - g_fw_z;
                  float ux = ax - g_up_x;
                  float uy = ay - g_up_y;
                  float uz = az - g_up_z;
                  float fw_diff = sqrtf(fx * fx + fy * fy + fz * fz);
                  float up_diff = sqrtf(ux * ux + uy * uy + uz * uz);

                  if(fw_diff < min_diff_fw)
                  {
                    min_diff_fw = fw_diff;
                    srand_fw = ii;
                  }
                  if(up_diff  < min_diff_up)
                  {
                    min_diff_up = up_diff;
                    srand_up = ii;
                  }
                }
                g_pos_x = static_cast<float>(ipos_x);
                g_pos_y = static_cast<float>(ipos_y);
                g_pos_z = static_cast<float>(ipos_z);
                dnload_srand(srand_fw);
                g_fw_x = frand(1.0f);
                g_fw_y = frand(1.0f);
                g_fw_z = frand(1.0f);
                dnload_srand(srand_up);
                g_up_x = frand(1.0f);
                g_up_y = frand(1.0f);
                g_up_z = frand(1.0f);

                std::cout << "pos: [ " << ipos_x << ", " << ipos_y << ", " << ipos_z << " ] ; fw: " <<
                  srand_fw << " ; up: " << srand_up << std::endl;
              }
              g_uniform_array[5] = 0.0f;
            }
            break;

          case SDLK_MODE:
          case SDLK_RALT:
            {
              uint8_t camera_array[5] = { 89, 124, 219, 48, 89 };

              g_pos_x = static_cast<float>(camera_array[0]);
              g_pos_y = static_cast<float>(camera_array[1]);
              g_pos_z = static_cast<float>(camera_array[2]);
              dnload_srand(camera_array[3]);
              g_fw_x = frand(1.0f);
              g_fw_y = frand(1.0f);
              g_fw_z = frand(1.0f);
              dnload_srand(camera_array[4]);
              g_up_x = frand(1.0f);
              g_up_y = frand(1.0f);
              g_up_z = frand(1.0f);

              {
                float angle = g_pos_x / 21.0f;
                float radius = g_pos_z / 21.0f;

                saved_pos_x = cosf(angle) * radius;
                saved_pos_y = -4.0f + g_pos_y / 21.0f;
                saved_pos_z = sinf(angle) * radius;
              }

              g_uniform_array[5] = 0.0f;
            }
            break;

          case SDLK_ESCAPE:
            quit = true;
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

          case SDLK_INSERT:
            insert = false;
            break;

          case SDLK_LSHIFT:
          case SDLK_RSHIFT:
            move_speed = 1.0f / 60.0f;
            break;            

          case SDLK_MODE:
          case SDLK_RALT:
            g_pos_x = saved_pos_x;
            g_pos_y = saved_pos_y;
            g_pos_z = saved_pos_z;
            g_uniform_array[5] = 1.0f;
            break;

          case SDLK_SPACE:
            g_pos_x = saved_pos_x;
            g_pos_y = saved_pos_y;
            g_pos_z = saved_pos_z;
            g_fw_x = saved_fw_x;
            g_fw_y = saved_fw_y;
            g_fw_z = saved_fw_z;
            g_up_x = saved_up_x;
            g_up_y = saved_up_y;
            g_up_z = saved_up_z;
            g_uniform_array[5] = 1.0f;
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

    if(flag_developer)
    {
      float uplen = sqrtf(g_up_x * g_up_x + g_up_y * g_up_y + g_up_z * g_up_z);
      float fwlen = sqrtf(g_fw_x * g_fw_x + g_fw_y * g_fw_y + g_fw_z * g_fw_z);
      float rt_x;
      float rt_y;
      float rt_z;
      float movement_rt = static_cast<float>(move_right - move_left) * move_speed;
      float movement_up = static_cast<float>(move_up - move_down) * move_speed;
      float movement_fw = static_cast<float>(move_forward - move_backward) * move_speed;

      g_up_x /= uplen;
      g_up_y /= uplen;
      g_up_z /= uplen;

      g_fw_x /= fwlen;
      g_fw_y /= fwlen;
      g_fw_z /= fwlen;

      rt_x = g_fw_y * g_up_z - g_fw_z * g_up_y;
      rt_y = g_fw_z * g_up_x - g_fw_x * g_up_z;
      rt_z = g_fw_x * g_up_y - g_fw_y * g_up_x;

      if(0 != mouse_look_x)
      {
        float angle = static_cast<float>(mouse_look_x) / static_cast<float>(screen_h / 4) * 0.25f;
        float ca = cosf(angle);
        float sa = sinf(angle);
        float new_rt_x = ca * rt_x + sa * g_fw_x;
        float new_rt_y = ca * rt_y + sa * g_fw_y;
        float new_rt_z = ca * rt_z + sa * g_fw_z;
        float new_fw_x = ca * g_fw_x - sa * rt_x;
        float new_fw_y = ca * g_fw_y - sa * rt_y;
        float new_fw_z = ca * g_fw_z - sa * rt_z;

        rt_x = new_rt_x;          
        rt_y = new_rt_y;
        rt_z = new_rt_z;
        g_fw_x = new_fw_x;
        g_fw_y = new_fw_y;
        g_fw_z = new_fw_z;
      }
      if(0 != mouse_look_y)
      {
        float angle = static_cast<float>(mouse_look_y) / static_cast<float>(screen_h / 4) * 0.25f;
        float ca = cosf(angle);
        float sa = sinf(angle);
        float new_fw_x = ca * g_fw_x + sa * g_up_x;
        float new_fw_y = ca * g_fw_y + sa * g_up_y;
        float new_fw_z = ca * g_fw_z + sa * g_up_z;
        float new_up_x = ca * g_up_x - sa * g_fw_x;
        float new_up_y = ca * g_up_y - sa * g_fw_y;
        float new_up_z = ca * g_up_z - sa * g_fw_z;

        g_fw_x = new_fw_x;
        g_fw_y = new_fw_y;
        g_fw_z = new_fw_z;
        g_up_x = new_up_x;
        g_up_y = new_up_y;
        g_up_z = new_up_z;
      }

      g_pos_x += movement_rt * rt_x + movement_up * g_up_x + movement_fw * g_fw_x;
      g_pos_y += movement_rt * rt_y + movement_up * g_up_y + movement_fw * g_fw_y;
      g_pos_z += movement_rt * rt_z + movement_up * g_up_z + movement_fw * g_fw_z;

      if(insert)
      {
        g_mover_queue += MOVER_COUNT;
        g_mover_strength = (frand(0.5f) + 0.5f) * 0.02f * static_cast<float>(WHISKY_SIDE);
        g_mover_height = (frand(0.5f) + 0.5f) * static_cast<float>(WHISKY_HEIGHT);
      }
      else if(0.0f <= strength)
      {
        g_mover_queue += MOVER_COUNT;
        g_mover_height = strength * static_cast<float>(WHISKY_HEIGHT);
        g_mover_strength = ((g_mode_control == 2) ? 1.0f : strength) * 0.02f * static_cast<float>(WHISKY_SIDE);
        strength = -1.0f;
      }
    }
#else
    currtick = g_audio_position - cumulative;

    if((cumulative >= INTRO_LENGTH) || (dnload_SDL_PollEvent(&event) && (event.type == SDL_KEYDOWN)))
    {
      break;
    }
#endif

    if(TICKS_PER_FRAME <= currtick)
    {
#if defined(DISPLAY_FRAMESKIP) && DISPLAY_FRAMESKIP
      unsigned calcs = 0;
#endif

      while(TICKS_PER_FRAME <= currtick)
      {
        calc(cumulative);
        currtick -= TICKS_PER_FRAME;
        cumulative += TICKS_PER_FRAME;
#if defined(DISPLAY_FRAMESKIP) && DISPLAY_FRAMESKIP
        ++calcs;
#endif
      }

#if defined(DISPLAY_FRAMESKIP) && DISPLAY_FRAMESKIP
      if(1 < calcs)
      {
        static char frameskip[] = "frameskip0";
        frameskip[9] += 1;
        if('9' < frameskip[9])
        {
          frameskip[9] = '0';
        }
        dnload_puts(frameskip);
      }
#endif

      draw();
      dnload_SDL_GL_SwapBuffers();
    }
  }

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

