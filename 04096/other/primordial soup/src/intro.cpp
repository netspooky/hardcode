//######################################
// Include #############################
//######################################

#include "dnload.h"
#include "synth.h"

#if defined(USE_LD)
#include "glsl_program.hpp"
#include "image_png.hpp"
#include <cstdio>
#include <iomanip>
#include <iostream>
#include <sstream>
#include <boost/exception/diagnostic_information.hpp>
#include <boost/filesystem.hpp>
#include <boost/program_options.hpp>
#include <boost/scoped_array.hpp>
#include <boost/tuple/tuple.hpp>
namespace fs = boost::filesystem;
namespace po = boost::program_options;
#endif

//######################################
// Define ##############################
//######################################

#if !defined(DISPLAY_MODE)
/// Screen mode.
///
/// Negative values windowed.
/// Positive values fullscreen.
#define DISPLAY_MODE -720
#endif

/// \cond
#if (0 > (DISPLAY_MODE))
#define SCREEN_F 0
#define SCREEN_H (-(DISPLAY_MODE))
#elif (0 < (DISPLAY_MODE))
#define SCREEN_F 1
#define SCREEN_H (DISPLAY_MODE)
#else
#error "invalid display mode (pre)"
#endif
#if ((800 == SCREEN_H) || (1200 == SCREEN_H))
#define SCREEN_W ((SCREEN_H / 10) * 16)
#else
#define SCREEN_W (((SCREEN_H * 16) / 9) - (((SCREEN_H * 16) / 9) % 4))
#endif
/// \endcond

/// Size of one sample in bytes.
#define AUDIO_SAMPLE_SIZE 4

/// \cond
#if (4 == AUDIO_SAMPLE_SIZE)
#define AUDIO_SAMPLE_TYPE_SDL AUDIO_F32SYS
typedef float sample_t;
#elif (2 == AUDIO_SAMPLE_SIZE)
#define AUDIO_SAMPLE_TYPE_SDL AUDIO_S16SYS
typedef int16_t sample_t;
#elif (1 == AUDIO_SAMPLE_SIZE)
#define AUDIO_SAMPLE_TYPE_SDL AUDIO_U8
typedef uint8_t sample_t;
#else
#error "invalid audio sample size"
#endif
/// \endcond

/// Audio channels.
#define AUDIO_CHANNELS 2

/// Audio samplerate.
#define AUDIO_SAMPLERATE 44100

/// Audio byterate.
#define AUDIO_BYTERATE (AUDIO_CHANNELS * AUDIO_SAMPLERATE * AUDIO_SAMPLE_SIZE)

/// Intro length (in bytes of audio).
#define INTRO_LENGTH (106 * AUDIO_BYTERATE)

/// Intro start position (in seconds).
#define INTRO_START (0 * AUDIO_BYTERATE)

/// Spherical entity count.
#define KIDNEY_COUNT 256

/// Plant entity count.
#define PLANT_COUNT 1024

/// Singular worm length.
#define WORM_LENGTH 32

/// Number of worms.
#define WORM_COUNT 48

/// Mote (dirt) count.
#define MOTE_COUNT 24000

/// Noise axis.
#define NOISE_AXIS 64

/// Fractal debug mode on/off.
#undef FRACTAL_DEBUG

/// SDLK_RALT seems to not function always.
#define SDLK_RALT_EXTRA 1073741824

#if defined(USE_LD)
/// Precalculated file to load as opposed to trying to run synth.
#define SYNTH_TEST_INPUT_FILE "primordial_soup.wav"
#else
/// Output file to write for synth test.
#define SYNTH_TEST_OUTPUT_FILE "primordial_soup.wav"
#undef SYNTH_TEST_OUTPUT_FILE // Comment out this line to enable test.
#endif

//######################################
// Global data #########################
//######################################

/// Current audio position.
static int g_audio_position = 0;

/// Audio buffer.
static uint8_t g_audio_buffer[((INTRO_LENGTH / 4) * 9 / 8) * 4];

#if defined(USE_LD)

/// Floating point aspect ratio.
#define SCREEN_ASPECT (static_cast<float>(SCREEN_W) / static_cast<float>(SCREEN_H))

/// \cond
static float g_pos_x = 0.0f;
static float g_pos_y = 0.0f;
static float g_pos_z = 0.0f;
static float g_fw_x = 0.0f;
static float g_fw_y = 0.0f;
static float g_fw_z = 1.0f;
static float g_up_x = 0.0f;
static float g_up_y = 1.0f;
static float g_up_z = 0.0f;
static float g_dof = 0.0f;
/// \endcond

/// Developer mode global toggle.
static bool g_flag_developer = false;

/// Follow direction global toggle.
static bool g_direction_lock = true;

/// Usage string.
static const char *usage = ""
"Usage: primordial_soup <options>\n"
"For Revision 2017 4k intro compo.\n"
"Release version does not pertain to any size limitations.\n";

/// Fractal debug mode X offset.
static float g_fractal_offset_x = 0.0f;

/// Fractal debug mode Y offset.
static float g_fractal_offset_y = -1.0f;

/// Fractal debug mode coordinate axis scale.
static float g_fractal_zoom = 1.0f;

/// Fractal debug mode constant X.
static float g_fractal_constant_x = 0.0f;

/// Fractal debug mode constant Y.
static float g_fractal_constant_y = 0.0f;

/// Fractal debug mode position multiplier.
static float g_fractal_constant_mul = 1.0f;

#else

/// Developer mode disabled.
#define g_flag_developer 0

#endif

//######################################
// Random ##############################
//######################################

/// Random seed value (8-bit).
///
/// \param Random seed value.
static void srand8(int8_t op)
{
  void (*srand_func)(int) = reinterpret_cast<void(*)(int)>(dnload_srand);
  srand_func(op);
}

/// Random int16_t value.
///
/// \return Random signed 16-bit integer value.
static int16_t i16rand()
{
  return static_cast<int16_t>(dnload_rand() & 0xFFFF);
}

#if defined(USE_LD)

/// Random float value.
///
/// \param op Given maximum value.
/// \return Random value between 0 and given value.
static float frand(float op)
{
  return static_cast<float>(dnload_rand() & 0xFFFF) * ((1.0f / 65535.0f) * op);
}

/// Round to integer.
///
/// \param op Floating-point value.
/// \return Rounded integer value.
static GLint iround(float op)
{
  return static_cast<GLint>(std::lround(op));
}

/// Liner mix of two values.
///
/// \param pa Param A.
/// \param pb Param B.
/// \param mixer Mixer value.
float mix(int pa, int pb, float mixer)
{
  return static_cast<float>(pb - pa) * mixer + static_cast<float>(pa);
}

#endif

//######################################
// Music ###############################
//######################################

/// Update audio stream.
///
/// \param userdata Not used.
/// \param stream Target stream.
/// \param len Number of bytes to write.
static void audio_callback(void *userdata, Uint8 *stream, int len)
{
  (void)userdata;

  for(int ii = 0; (ii < len); ++ii)
  {
    stream[ii] = g_audio_buffer[g_audio_position + ii];
  }
  g_audio_position += len;
}

/// SDL audio specification struct.
static SDL_AudioSpec audio_spec =
{
  AUDIO_SAMPLERATE,
  AUDIO_SAMPLE_TYPE_SDL,
  AUDIO_CHANNELS,
  0,
#if defined(USE_LD)
  4096,
#else
  256, // ~172.3Hz, lower values seem to cause underruns
#endif
  0,
  0,
  audio_callback,
  NULL
};

/// Synth wrapper.
/// \param outbuf Output buffer.
/// \param samples Number of bytes to write.
inline void synth(uint8_t *outbuf, unsigned bytes)
{
#if defined(USE_LD)
  std::cerr << "WARNING: synth not available, filling audio with 0" << std::endl;
  while(bytes > 0)
  {
    outbuf[bytes - 1] = 0;
    --bytes;
  }
#else
  synth(reinterpret_cast<float*>(outbuf), bytes / sizeof(sample_t) * SYNTH_OVERSAMPLING);
#endif
}

//######################################
// Shaders #############################
//######################################

#include "header.glsl.hpp" // g_shader_header
#include "default.vert.glsl.hpp" // g_shader_vert_default
#include "default.geom.glsl.hpp" // g_shader_geom_default
#include "default.frag.glsl.hpp" // g_shader_frag_default
#include "worm.geom.glsl.hpp" // g_shader_geom_worm
#include "quad.vert.glsl.hpp" // g_shader_vert_quad
#include "quad.frag.glsl.hpp" // g_shader_frag_quad

/// Fixed uniform location.
static const GLint g_uniform_u = 0;

/// Fixed uniform location.
static const GLint g_uniform_t = 6;

/// Fixed uniform location.
static const GLint g_uniform_s = 7;

/// Fixed uniform location.
static const GLint g_uniform_v = 8;

#if defined(USE_LD)

/// Fixed uniform location.
static const GLint g_uniform_m = 9;

#endif

#if !defined(USE_LD)

/// \cond
static void program_create(GLuint&, const char*, const char*, const char*) __attribute__((regparm(2)));
/// \endcond
/// Create program.
///
/// \param vertex Vertex shader.
/// \param geometry Geometry shader, may be NULL.
/// \param fragment Fragment shader.
/// \return Program ID.
static void program_create(GLuint &program, const char *vertex, const char *fragment, const char* geometry)
{
  program = dnload_glCreateProgram();

  const GLchar* g_shader_source_array[] = { g_shader_header, NULL };

  GLuint shader_vert = dnload_glCreateShader(GL_VERTEX_SHADER);
  g_shader_source_array[1] = vertex;
  dnload_glShaderSource(shader_vert, 2, g_shader_source_array, NULL);
  dnload_glCompileShader(shader_vert);
  dnload_glAttachShader(program, shader_vert);

  GLuint shader_frag = dnload_glCreateShader(GL_FRAGMENT_SHADER);
  g_shader_source_array[1] = fragment;
  dnload_glShaderSource(shader_frag, 2, g_shader_source_array, NULL);
  dnload_glCompileShader(shader_frag);
  dnload_glAttachShader(program, shader_frag);

  if(geometry)
  {
    GLuint shader_geom = dnload_glCreateShader(GL_GEOMETRY_SHADER);
    g_shader_source_array[1] = geometry;
    dnload_glShaderSource(shader_geom, 2, g_shader_source_array, NULL);
    dnload_glCompileShader(shader_geom);
    dnload_glAttachShader(program, shader_geom);
  }

  dnload_glLinkProgram(program);
}

#endif

// Shader compilation.
static GLuint g_program_default;
static GLuint g_program_worm;
static GLuint g_program_quad;

//######################################
// Draw data ###########################
//######################################

/// Framebuffer.
static GLuint g_fbo;

/// All textures.
static GLuint g_textures[3];

/// Texture index.
#define TEXTURE_COLOR_INDEX 0
/// Texture index.
#define TEXTURE_DEPTH_INDEX 1
/// Texture index.
#define TEXTURE_NOISE_INDEX 2

/// Typedef for entities fed to GPU.
///
/// 0-2: Position.
/// 3: Type-specific identifier.
/// 4-7: Type-specific data.
typedef int16_t Entity[8];

/// Uniform temporary array.
///
/// Used for temporary scratchboard.
///
/// During program execution, used for uniform data.
/// 0-5: Position 1 & 2.
/// 6-8: Forward.
/// 9-11: Up.
/// 12-13: DoF 1 & 2.
/// 14-16: Time, scene time, global time.
#define UNIFORM_ARRAY_SIZE (sizeof(GLuint) * 6 * 3)

/// Total count of entities.
#define ENTITY_COUNT (PLANT_COUNT + KIDNEY_COUNT + MOTE_COUNT + (WORM_LENGTH * WORM_COUNT))

/// Plant start.
#define PLANT_START 0

/// Kidney start.
#define KIDNEY_START (PLANT_START + PLANT_COUNT)

/// Mote start.
#define MOTE_START (KIDNEY_START + KIDNEY_COUNT)

/// Worm start.
#define WORM_START (MOTE_START + MOTE_COUNT)

/// Common buffer for data.
/// This buffer needs to be large enough for any of the following at a time:
/// - Noise texture
/// - Uniform buffer and vertex buffers
/// - Synth scratchpad (determines buffer size).
static uint8_t g_buffer[SYNTH_WORK_SIZE];

/// Spherical kidney-style protozoa vertex buffer.
static Entity* g_entity_array = reinterpret_cast<Entity*>(g_buffer + UNIFORM_ARRAY_SIZE);

/// Uniform array.
static GLint *g_uniform_array = reinterpret_cast<GLint*>(g_buffer);

/// Noise array.
static uint8_t* g_noise_array = g_buffer;

/// Macro to convert u8 to i8 (time).
#define TIME8I(op) static_cast<int8_t>((op >= 128) ? (-128 + (op - 128)) : op)

/// Direction data.
///
/// 0-5 Position 1 & 2.
/// 6: Seed for forward.
/// 7: Seed for up.
/// 8-9: DoF 1 & 2.
/// 10: Scene length.
int8_t g_direction[] =
{
  // Starting pan looking at sun.
  9, 15, -17,
  9, 11, -15,
  23, 35,
  35, 35,
  TIME8I(90),

  // Focus onto kidney.
  18, 1, -25,
  18, 0, -24,
  -45, -125,
  18, 2,
  TIME8I(160),

  // Focus onto plant.
  22, 17, -12,
  25, 19, -8,
  -109, -54,
  3, 3,
  TIME8I(104),

  // Darkening & descent
  14, 22, -19,
  7, -27, 23,
  -48, -54,
  4, 3,
  TIME8I(191),

  // Dark kidney shot.
  -5, -30, -21,
  -4, -32, -20,
  -56, 112,
  4, 3,
  TIME8I(60),

  // First worm.
  -11, -72, 7,
  -5, -67, 1,
  114, 51,
  3, 3,
  TIME8I(100),

  // Lots of worms.
  -28, -80, -10,
  -21, -70, -16,
  -105, 16,
  17, 16,
  TIME8I(178),

  // Single worm shot.
  10, -61, -9,
  10, -60, -11,
  42, -91,
  13, 14,
  TIME8I(125),

  // Fadeout.
  0, -60, -5,
  -2, -55, 8,
  -8, 40,
  22, 7,
  TIME8I(134),
};

#if !defined(SDL12)
/// Window.
SDL_Window *g_window;
#endif

//######################################
// Uniform data ########################
//######################################

#if defined(USE_LD)

/// Find random seed most closely resembling given direction.
///
/// \param px X component.
/// \param py Y component.
/// \param pz Z component.
/// \return Random number most closely representing given number.
int8_t find_rand_dir(float px, float py, float pz)
{
  float dlen = sqrtf((px * px) + (py * py) + (pz * pz));
  px /= dlen;
  py /= dlen;
  pz /= dlen;

  float best_difference = std::numeric_limits<float>::max();
  int8_t ret = 0;

  for(int ii = -128; (ii < 128); ++ii)
  {
    int8_t seed = static_cast<int8_t>(ii);
    srand8(seed);

    float cx = static_cast<float>(i16rand());
    float cy = static_cast<float>(i16rand());
    float cz = static_cast<float>(i16rand());

    float clen = sqrtf((cx * cx) + (cy * cy) + (cz * cz));
    cx /= clen;
    cy /= clen;
    cz /= clen;

    float xdiff = cx - px;
    float ydiff = cy - py;
    float zdiff = cz - pz;
    float sqrdiff = (xdiff * xdiff) + (ydiff * ydiff) + (zdiff * zdiff);

    if(sqrdiff < best_difference)
    {
      best_difference = sqrdiff;
      ret = seed;
    }
  }

  return ret;
}

/// Generate a ZXY rotation matrix.
///
/// \param rx Rotation x.
/// \param ry Rotation y.
/// \param rz Rotation z.
/// \param out_matrix Matrix to write into.
static void generate_rotation_matrix_zxy(float rx, float ry, float rz, float *out_matrix)
{
  float sx = sinf(rx);
  float sy = sinf(ry);
  float sz = sinf(rz);
  float cx = cosf(rx);
  float cy = cosf(ry);
  float cz = cosf(rz);

  out_matrix[0] = sx * sy * sz + cy * cz;
  out_matrix[1] = sz * cx;
  out_matrix[2] = sx * sz * cy - sy * cz;
  out_matrix[3] = sx * sy * cz - sz * cy;
  out_matrix[4] = cx * cz;
  out_matrix[5] = sx * cy * cz + sy * sz;
  out_matrix[6] = sy * cx;
  out_matrix[7] = -sx;
  out_matrix[8] = cx * cy;
}

/// Matrix uniform array.
///
/// One 3x3 matrix.
static float g_uniform_matrix[9] =
{
  -0.99f, -0.16f, 0.02f,
  0.14f, -0.77f, 0.63f,
  -0.08f, 0.62f, 0.78f
};

#endif

/// Activate program for drawing.
///
/// \param prg Program to activate.
static void activate_program(unsigned prg)
{
  dnload_glUseProgram(prg);

#if defined(USE_LD)
  glUniformMatrix3fv(g_uniform_m, 1, GL_FALSE, g_uniform_matrix);
#endif
  dnload_glUniform3iv(g_uniform_u, 6, g_uniform_array);
  dnload_glUniform1i(g_uniform_v, TEXTURE_NOISE_INDEX);

  const int16_t* buf = reinterpret_cast<const int16_t*>(g_entity_array);

  dnload_glVertexAttribIPointer(0, 4, GL_SHORT, sizeof(Entity), buf + 0);
  dnload_glVertexAttribIPointer(1, 4, GL_SHORT, sizeof(Entity), buf + 4);
}

/// Perform drawing.
///
/// \param ticks current ticks.
static void draw(int ticks)
{
#if defined(USE_LD)
  if(g_flag_developer && !g_direction_lock)
  {
    g_uniform_array[0] = iround(g_pos_x);
    g_uniform_array[1] = iround(g_pos_y);
    g_uniform_array[2] = iround(g_pos_z);
    g_uniform_array[3] = g_uniform_array[0];
    g_uniform_array[4] = g_uniform_array[1];
    g_uniform_array[5] = g_uniform_array[2];
    g_uniform_array[6] = iround(g_fw_x * 1000.0f);
    g_uniform_array[7] = iround(g_fw_y * 1000.0f);
    g_uniform_array[8] = iround(g_fw_z * 1000.0f);
    g_uniform_array[9] = iround(g_up_x * 1000.0f);
    g_uniform_array[10] = iround(g_up_y * 1000.0f);
    g_uniform_array[11] = iround(g_up_z * 1000.0f);
    g_uniform_array[12] = iround(g_dof);
    g_uniform_array[13] = g_uniform_array[12];
    g_uniform_array[14] = 0;
    g_uniform_array[15] = ticks;
    g_uniform_array[16] = ticks;
    g_uniform_array[17] = ticks;
    //std::cout << g_fw_x << " ; " << g_fw_y << " ; " << g_fw_z << std::endl;
    //std::cout << g_pos_x << " ; " << g_pos_y << " ; " << g_pos_z << std::endl;
    if(ticks == 0)
    {
      g_uniform_array[16] = 1;
    }
  }
  else
#endif
  {
    int tick_iter = ticks;
    int8_t* direction = g_direction;

    for(;;)
    {
      int scene_length = static_cast<int>(reinterpret_cast<uint8_t*>(direction)[10]) << 15;

      if(scene_length > tick_iter)
      {
        g_uniform_array[0] = static_cast<int>(direction[0]) << 8;
        g_uniform_array[1] = static_cast<int>(direction[1]) << 8;
        g_uniform_array[2] = static_cast<int>(direction[2]) << 8;
        g_uniform_array[3] = static_cast<int>(direction[3]) << 8;
        g_uniform_array[4] = static_cast<int>(direction[4]) << 8;
        g_uniform_array[5] = static_cast<int>(direction[5]) << 8;
        srand8(direction[6]);
        g_uniform_array[6] = i16rand();
        g_uniform_array[7] = i16rand();
        g_uniform_array[8] = i16rand();
        srand8(direction[7]);
        g_uniform_array[9] = i16rand();
        g_uniform_array[10] = i16rand();
        g_uniform_array[11] = i16rand();
        g_uniform_array[12] = static_cast<int>(direction[8]) << 8;
        g_uniform_array[13] = static_cast<int>(direction[9]) << 8;
        g_uniform_array[14] = 0;
        g_uniform_array[15] = tick_iter;
        g_uniform_array[16] = scene_length;
        g_uniform_array[17] = ticks;

#if defined(USE_LD)
        if(g_flag_developer)
        {
          g_fw_x = static_cast<float>(g_uniform_array[6]);
          g_fw_y = static_cast<float>(g_uniform_array[7]);
          g_fw_z = static_cast<float>(g_uniform_array[8]);
          float fwlen = sqrtf((g_fw_x * g_fw_x) * (g_fw_y * g_fw_y) * (g_fw_z * g_fw_z));
          g_fw_x /= fwlen;
          g_fw_y /= fwlen;
          g_fw_z /= fwlen;

          g_up_x = static_cast<float>(g_uniform_array[9]);
          g_up_y = static_cast<float>(g_uniform_array[10]);
          g_up_z = static_cast<float>(g_uniform_array[11]);
          float uplen = sqrtf((g_up_x * g_up_x) * (g_up_y * g_up_y) * (g_up_z * g_up_z));
          g_up_x /= uplen;
          g_up_y /= uplen;
          g_up_z /= uplen;

          g_uniform_array[0] += iround(g_pos_x);
          g_uniform_array[1] += iround(g_pos_y);
          g_uniform_array[2] += iround(g_pos_z);
          g_uniform_array[3] += iround(g_pos_x);
          g_uniform_array[4] += iround(g_pos_y);
          g_uniform_array[5] += iround(g_pos_z);

          g_uniform_array[12] += static_cast<int>(g_dof);
          g_uniform_array[13] += static_cast<int>(g_dof);
        }
#endif

        break;
      }

      tick_iter -= scene_length;
      direction += 11;
    }
  }

  dnload_glEnable(GL_BLEND);
  dnload_glEnable(GL_DEPTH_TEST);
  dnload_glEnableVertexAttribArray(0);
  dnload_glEnableVertexAttribArray(1);
  dnload_glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);

  // Off-screen.
  {
    dnload_glBindFramebuffer(GL_FRAMEBUFFER, g_fbo);
    dnload_glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    // Worms.
    activate_program(g_program_worm);

    for(GLint ii = WORM_START; (ii < (WORM_START + (WORM_LENGTH * WORM_COUNT))); ii += WORM_LENGTH)
    {
      dnload_glDrawArrays(GL_LINE_STRIP_ADJACENCY, ii, WORM_LENGTH);
    }

    // Everything else.
    activate_program(g_program_default);

    // Plant entities, kidneys and motes.
    dnload_glDrawArrays(GL_POINTS, PLANT_START, (WORM_START - PLANT_START));
  }

  // On-screen.
  {
    activate_program(g_program_quad);

    dnload_glBindFramebuffer(GL_FRAMEBUFFER, 0);

    dnload_glGenerateTextureMipmap(g_textures[TEXTURE_COLOR_INDEX]);
    dnload_glGenerateTextureMipmap(g_textures[TEXTURE_DEPTH_INDEX]);

    dnload_glUniform1i(g_uniform_t, TEXTURE_COLOR_INDEX);
    dnload_glUniform1i(g_uniform_s, TEXTURE_DEPTH_INDEX);

#if defined(FRACTAL_DEBUG)
    glUniform3f(20, g_fractal_offset_x, g_fractal_offset_y, g_fractal_zoom);
    glUniform3f(21, g_fractal_constant_x, g_fractal_constant_y, g_fractal_constant_mul);
#endif

    dnload_glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    dnload_glRects(-1, -1, 1, 1);
  }
}

/// Swap buffers.
static void swap_buffers()
{
#if defined(SDL12)
  dnload_SDL_GL_SwapBuffers();
#else
  dnload_SDL_GL_SwapWindow(g_window);
#endif
}

//######################################
// Utility #############################
//######################################

#if defined(USE_LD)

/// Parse resolution from string input.
///
/// \param op Resolution string.
/// \return Tuple of width and height.
boost::tuple<unsigned, unsigned> parse_resolution(const std::string &op)
{
  size_t cx = op.find("x");
  
  if(std::string::npos == cx)
  {
    cx = op.rfind("p");

    if((std::string::npos == cx) || (0 >= cx))
    {
      std::ostringstream sstr;
      sstr << "invalid resolution string '" << op << '\'';
      BOOST_THROW_EXCEPTION(std::runtime_error(sstr.str()));
    }

    std::string sh = op.substr(0, cx);

    unsigned rh = boost::lexical_cast<unsigned>(sh);
    unsigned rw = (rh * 16) / 9;
    unsigned rem4 = rw % 4;

    return boost::make_tuple(rw - rem4, rh);
  }

  std::string sw = op.substr(0, cx);
  std::string sh = op.substr(cx + 1);

  return boost::make_tuple(boost::lexical_cast<int>(sw), boost::lexical_cast<int>(sh));
}

/// Image writing callback.
///
/// \param screen_w Screen width.
/// \param screen_h Screen height.
/// \param idx Frame index to write.
void write_frame(unsigned screen_w, unsigned screen_h, unsigned idx)
{
  boost::scoped_array<uint8_t> image(new uint8_t[screen_w * screen_h * 3]);
  std::ostringstream sstr;

  glReadPixels(0, 0, static_cast<GLsizei>(screen_w), static_cast<GLsizei>(screen_h), GL_RGB, GL_UNSIGNED_BYTE,
      image.get());

  sstr << "primordial_soup_" << std::setfill('0') << std::setw(4) << idx << ".png";

  gfx::image_png_save(sstr.str(), screen_w, screen_h, 24, image.get());
  return;
}

#endif

//######################################
// intro & _start ######################
//######################################

#if defined(USE_LD)
/// Intro body function.
///
/// \param screen_w Screen width.
/// \param screen_h Screen height.
/// \param flag_fullscreen Fullscreen toggle.
/// \param flag_record Record toggle.
static void intro(unsigned screen_w, unsigned screen_h, bool flag_fullscreen, bool flag_record)
#else
#define screen_w static_cast<unsigned>(SCREEN_W)
#define screen_h static_cast<unsigned>(SCREEN_H)
#define flag_fullscreen static_cast<bool>(SCREEN_F)
void _start()
#endif
{
  dnload();
  dnload_SDL_Init(SDL_INIT_VIDEO | SDL_INIT_AUDIO);
#if defined(SDL12)
  dnload_SDL_SetVideoMode(static_cast<int>(screen_w), static_cast<int>(screen_h), 0,
      SDL_OPENGL | (flag_fullscreen ? SDL_FULLSCREEN : 0));
#else
  g_window = dnload_SDL_CreateWindow(NULL, SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED,
      static_cast<int>(screen_w), static_cast<int>(screen_h),
      SDL_WINDOW_OPENGL | (flag_fullscreen ? SDL_WINDOW_FULLSCREEN : 0));
  dnload_SDL_GL_CreateContext(g_window);
#endif
  dnload_SDL_ShowCursor(g_flag_developer);

#if defined(USE_LD)
  {
    GLenum err = glewInit();
    if(GLEW_OK != err)
    {
      std::ostringstream sstr;
      sstr << "glewInit(): " << glewGetErrorString(err) << std::endl;
      BOOST_THROW_EXCEPTION(std::runtime_error(sstr.str()));
    }
  }
#endif

#if defined(SYNTH_TEST_INPUT_FILE)
  {
    const fs::path REL_PATH("rel");
    const fs::path SYNTH_TEST_INPUT_FILE_PATH(SYNTH_TEST_INPUT_FILE);
    SDL_AudioSpec wav_spec;
    SDL_AudioSpec* wav_found;
    Uint32 wav_length;
    Uint8 *wav_buffer;

    wav_found = SDL_LoadWAV(SYNTH_TEST_INPUT_FILE_PATH.string().c_str(), &wav_spec, &wav_buffer, &wav_length);
    if(!wav_found)
    {
      fs::path fname = REL_PATH / SYNTH_TEST_INPUT_FILE_PATH;
      wav_found = SDL_LoadWAV(fname.string().c_str(), &wav_spec, &wav_buffer, &wav_length);
    }
    if(!wav_found)
    {
      fs::path fname = fs::path("..") / REL_PATH / SYNTH_TEST_INPUT_FILE_PATH;
      wav_found = SDL_LoadWAV(fname.string().c_str(), &wav_spec, &wav_buffer, &wav_length);
    }
    // If successful, read floating-point data from file.
    if(wav_found)
    {
      memcpy(g_audio_buffer, wav_buffer, wav_length);
      SDL_FreeWAV(wav_buffer);
    }
    // Fall back to calling synth, this may or may not do anything.
    else
    {
      synth(g_audio_buffer, INTRO_LENGTH);
    }
  }
#else
  // Generate audio first, when all scratch memory still remains 0.
  synth(g_audio_buffer, INTRO_LENGTH);
#endif

  // Write raw .wav file.
#if defined(SYNTH_TEST_OUTPUT_FILE)
  {
    SF_INFO info;
    info.samplerate = AUDIO_SAMPLERATE;
    info.channels = AUDIO_CHANNELS;
    info.format = SF_FORMAT_WAV | SF_FORMAT_FLOAT;

    SNDFILE *outfile = dnload_sf_open(SYNTH_TEST_OUTPUT_FILE, SFM_WRITE, &info);
    sf_count_t write_count = INTRO_LENGTH / AUDIO_CHANNELS / AUDIO_SAMPLE_SIZE;
    dnload_sf_writef_float(outfile, reinterpret_cast<float*>(g_audio_buffer), write_count);
    dnload_sf_close(outfile);
  }
#endif

#if defined(USE_LD)
  GlslProgram program_default;
  program_default.addShader(GL_VERTEX_SHADER, g_shader_header, g_shader_vert_default);
  program_default.addShader(GL_FRAGMENT_SHADER, g_shader_header, g_shader_frag_default);
  program_default.addShader(GL_GEOMETRY_SHADER, g_shader_header, g_shader_geom_default);
  program_default.link();
  if(!program_default.link())
  {
    BOOST_THROW_EXCEPTION(std::runtime_error("program creation failure (default)"));
  }
  g_program_default = program_default.getId();
  GlslProgram program_worm;
  program_worm.addShader(GL_VERTEX_SHADER, g_shader_header, g_shader_vert_default);
  program_worm.addShader(GL_FRAGMENT_SHADER, g_shader_header, g_shader_frag_default);
  program_worm.addShader(GL_GEOMETRY_SHADER, g_shader_header, g_shader_geom_worm);
  if(!program_worm.link())
  {
    BOOST_THROW_EXCEPTION(std::runtime_error("program creation failure (worm)"));
  }
  g_program_worm = program_worm.getId();
  GlslProgram program_quad;
  program_quad.addShader(GL_VERTEX_SHADER, g_shader_header, g_shader_vert_quad);
  program_quad.addShader(GL_FRAGMENT_SHADER, g_shader_header, g_shader_frag_quad);
  program_quad.link();
  if(!program_quad.link())
  {
    BOOST_THROW_EXCEPTION(std::runtime_error("program creation failure (quad)"));
  }
  g_program_quad = program_quad.getId();
#else
  program_create(g_program_default, g_shader_vert_default, g_shader_frag_default, g_shader_geom_default);
  program_create(g_program_worm, g_shader_vert_default, g_shader_frag_default, g_shader_geom_worm);
  program_create(g_program_quad, g_shader_vert_quad, g_shader_frag_quad, NULL);
#endif

  // Generate textures.
  dnload_glGenTextures(3, g_textures);

  // Noise texture preparation.
  {
    dnload_srand(0);

    for(unsigned ii = 0; (ii < NOISE_AXIS * NOISE_AXIS * NOISE_AXIS); ++ii)
    {
      g_noise_array[ii] = static_cast<uint8_t>(dnload_rand());
    }

    dnload_glActiveTexture(GL_TEXTURE0 + TEXTURE_NOISE_INDEX);
    dnload_glBindTexture(GL_TEXTURE_3D, g_textures[TEXTURE_NOISE_INDEX]);
    dnload_glTexImage3D(GL_TEXTURE_3D, 0, GL_RED, NOISE_AXIS, NOISE_AXIS, NOISE_AXIS, 0, GL_RED,
        GL_UNSIGNED_BYTE, g_noise_array);
    dnload_glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    dnload_glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    dnload_glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
#if defined(USE_LD)
    dnload_glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
#endif
  }

  // Color texture preparation.
  dnload_glActiveTexture(GL_TEXTURE0 + TEXTURE_COLOR_INDEX);
  dnload_glBindTexture(GL_TEXTURE_2D, g_textures[TEXTURE_COLOR_INDEX]);
  dnload_glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, static_cast<GLsizei>(screen_w),
      static_cast<GLsizei>(screen_h), 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);
  dnload_glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
  dnload_glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
  dnload_glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
#if defined(USE_LD)
  dnload_glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
#endif

  // Depth texture preparation.
  dnload_glActiveTexture(GL_TEXTURE0 + TEXTURE_DEPTH_INDEX);
  dnload_glBindTexture(GL_TEXTURE_2D, g_textures[TEXTURE_DEPTH_INDEX]);
  dnload_glTexImage2D(GL_TEXTURE_2D, 0, GL_DEPTH_COMPONENT, static_cast<GLsizei>(screen_w),
      static_cast<GLsizei>(screen_h), 0, GL_DEPTH_COMPONENT, GL_FLOAT, NULL);
  dnload_glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
  dnload_glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
  dnload_glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
#if defined(USE_LD)
  dnload_glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
#endif

  // FBO preparation.
  dnload_glCreateFramebuffers(1, &g_fbo);
  dnload_glNamedFramebufferTexture(g_fbo, GL_COLOR_ATTACHMENT0, g_textures[TEXTURE_COLOR_INDEX], 0);
  dnload_glNamedFramebufferTexture(g_fbo, GL_DEPTH_ATTACHMENT, g_textures[TEXTURE_DEPTH_INDEX], 0);

#if defined(USE_LD)
  {
    GLenum status = glCheckNamedFramebufferStatus(g_fbo, GL_FRAMEBUFFER);
    if(status != GL_FRAMEBUFFER_COMPLETE)
    {
      std::ostringstream sstr;
      sstr << "framebuffer status " << status;
      BOOST_THROW_EXCEPTION(std::runtime_error(sstr.str()));
    }
  }
#endif

  {
    dnload_srand(0);

    for(unsigned ii = 0; (ii < ENTITY_COUNT); ++ii)
    {
      Entity& ent = g_entity_array[ii];

      ent[0] = static_cast<int16_t>(i16rand() >> 2);
      ent[1] = static_cast<int16_t>(i16rand() >> 2);
      ent[2] = static_cast<int16_t>(i16rand() >> 2);
      ent[3] = i16rand();
      ent[4] = 32;
      ent[5] = 144;
      ent[6] = i16rand();
      ent[7] = i16rand();

      if(ii >= KIDNEY_START)
      {
        ent[3] = 0;
        ent[4] = 244;
        ent[5] = 244;
      }
      if(ii >= MOTE_START)
      {
        ent[1] = static_cast<int16_t>(-8192 + (ent[1] << 1));
        ent[3] = 1;
        ent[4] = 48;
        ent[5] = 48;
      }
      if(ii >= WORM_START)
      {
        ent[1] = static_cast<int16_t>(-16384 + (ent[1] >> 1));
        ent[3] = 0;
        ent[4] = 48;
        ent[5] = 48;

        for(unsigned jj = 1; (jj < WORM_LENGTH); ++jj)
        {
          Entity& prev = (&ent)[jj - 1];
          Entity& curr = (&ent)[jj];

          curr[0] = static_cast<int16_t>(prev[0] + (i16rand() >> 6));
          curr[1] = static_cast<int16_t>(prev[1] + (i16rand() >> 6));
          curr[2] = static_cast<int16_t>(prev[2] + (i16rand() >> 6));
          curr[3] = static_cast<int16_t>(jj);
          curr[4] = prev[4];
          curr[5] = prev[5];
          curr[6] = prev[6];
          curr[7] = prev[7];
        }

        ii += WORM_LENGTH - 1;
      }
#if defined(USE_LD)
      if((ii < PLANT_COUNT) && ((0 <= ent[3]) && (2 >= ent[3])))
      {
        std::ostringstream sstr;
        sstr << "type of plant was '" << ent[3] << "', use a different seed";
        BOOST_THROW_EXCEPTION(std::runtime_error(sstr.str()));
      }
#endif
    }
  }

#if defined(USE_LD)
  if(!g_flag_developer)
  {
    if(flag_record)
    {
      SDL_Event event;
      unsigned frame_idx = 0;

      // video
      for(;;)
      {
        int ticks = static_cast<int>(static_cast<float>(frame_idx) / 60.0f * static_cast<float>(AUDIO_BYTERATE));

        if(INTRO_LENGTH <= ticks)
        {
          break;
        }

        if(SDL_PollEvent(&event) && (event.type == SDL_KEYDOWN) && (event.key.keysym.sym == SDLK_ESCAPE))
        {
          break;
        }

        draw(ticks);
        write_frame(screen_w, screen_h, frame_idx);
        swap_buffers();
        ++frame_idx;
      }

      SDL_Quit();
      return;
    }
    else
    {
      SDL_OpenAudio(&audio_spec, NULL);
      SDL_PauseAudio(0);
    }
  }
#else
  dnload_SDL_OpenAudio(&audio_spec, NULL);
  dnload_SDL_PauseAudio(0);
#endif

#if defined(USE_LD)
  const float MOVE_SPEED_FAST = 2048.0f / 60.0f;
  const float MOVE_SPEED_SLOW = 256.0f / 60.0f;
  const float FRACTAL_ZOOM_FACTOR = 0.1f;
  int start_ticks = static_cast<int>(SDL_GetTicks());
  unsigned frame_idx = 0;
  float move_speed = MOVE_SPEED_SLOW;
  float current_time = 0.0f;
  float stored_orientation[9] = { 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f};
  uint8_t fractal_look = 0;
  uint8_t mouse_look = 0;
  int8_t move_backward = 0;
  int8_t move_down = 0;
  int8_t move_forward = 0;
  int8_t move_left = 0;
  int8_t move_right = 0;
  int8_t move_up = 0;
  int8_t time_delta = 0;
  int8_t dof_pos = 0;
  int8_t dof_neg = 0;
  bool stored_orientation_active = false;
#endif

  for(;;)
  {
#if defined(USE_LD)
    int mouse_look_x = 0;
    int mouse_look_y = 0;
    int fractal_look_x = 0;
    int fractal_look_y = 0;
    int fractal_constant_x = 0;
    int fractal_constant_y = 0;
    int time_skip = 0;
    bool fractal_constant_set = false;
    bool quit = false;
#endif
    int curr_ticks;
    SDL_Event event;

#if defined(USE_LD)
    while(SDL_PollEvent(&event))
    {
      if(SDL_QUIT == event.type)
      {
        quit = true;
      }
      else if((SDL_KEYDOWN == event.type) && !event.key.repeat)
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

          case SDLK_z:
            dof_neg = 1;
            break;

          case SDLK_x:
            dof_pos = 1;
            break;

          case SDLK_LEFT:
            time_skip = 5000;
            break;

          case SDLK_DOWN:
            time_skip = 30000;
            break;

          case SDLK_RIGHT:
            time_skip = -5000;
            break;

          case SDLK_UP:
            time_skip = -30000;
            break;

          case SDLK_INSERT:
            {
              float rx = frand(static_cast<float>(M_PI * 2.0));
              float ry = frand(static_cast<float>(M_PI * 2.0));
              float rz = frand(static_cast<float>(M_PI * 2.0));

              generate_rotation_matrix_zxy(rx, ry, rz, g_uniform_matrix);

              printf("[ %1.2f ; %1.2f ; %1.2f ] =>\n[ %+1.2f ; %+1.2f ; %+1.2f\n"
                  "  %+1.2f ; %+1.2f ; %+1.2f\n  %+1.2f ; %+1.2f ; %+1.2f ]\n",
                  rx, ry, rz,
                  g_uniform_matrix[0], g_uniform_matrix[3], g_uniform_matrix[6],
                  g_uniform_matrix[1], g_uniform_matrix[4], g_uniform_matrix[7],
                  g_uniform_matrix[2], g_uniform_matrix[5], g_uniform_matrix[8]);
            }
            break;

          case SDLK_RETURN:
            g_pos_x = 0.0f;
            g_pos_y = 0.0f;
            g_pos_z = 0.0f;
            g_direction_lock = true;
            break;

          case SDLK_LSHIFT:
          case SDLK_RSHIFT:
            move_speed = MOVE_SPEED_FAST;
            break;            

          case SDLK_LALT:
            time_delta = -1;
            break;

          case SDLK_MODE:
          case SDLK_RALT:
          case SDLK_RALT_EXTRA:
            time_delta = 1;
            break;

          case SDLK_SPACE:
            {
#if defined(FRACTAL_DEBUG)
              int mouse_x;
              int mouse_y;
              SDL_GetMouseState(&mouse_x, &mouse_y);
              float offset_x = (static_cast<float>(mouse_x) / static_cast<float>(screen_w) - 0.5f) *
                2.0f * SCREEN_ASPECT * g_fractal_zoom + g_fractal_offset_x;
              float offset_y = g_fractal_offset_y - 2.0f * g_fractal_zoom *
                (static_cast<float>(mouse_y) / static_cast<float>(screen_h) - 0.5f);
              std::cout << "[ " << offset_x << " ; " << offset_y << " ] / " << g_fractal_zoom << " @ ";
              if(g_fractal_constant_mul != 0.0f)
              {
                std::cout << "DISABLED";
              }
              else
              {
                std::cout << "[ " << g_fractal_constant_x << " ; " << g_fractal_constant_y << "]";
              }
              std::cout << std::endl;
#else
              if(!stored_orientation_active)
              {
                if(g_direction_lock)
                {
                  float mixer = static_cast<float>(g_uniform_array[15]) / static_cast<float>(g_uniform_array[16]);
                  float mixed_x = mix(g_uniform_array[0], g_uniform_array[3], mixer);
                  float mixed_y = mix(g_uniform_array[1], g_uniform_array[4], mixer);
                  float mixed_z = mix(g_uniform_array[2], g_uniform_array[5], mixer);
                  float mixed_dof = mix(g_uniform_array[12], g_uniform_array[13], mixer);

                  std::cout << "[ " << iround(mixed_x / 256.0f) << ", " << iround(mixed_y / 256.0f) << ", " <<
                    iround(mixed_z / 256.0f) << " ] " << " ; " << iround(mixed_dof / 256.0f) << " ; " <<
                    g_uniform_array[17] << std::endl;
                }
                else
                {
                  // Store current.
                  stored_orientation[0] = g_pos_x;
                  stored_orientation[1] = g_pos_y;
                  stored_orientation[2] = g_pos_z;
                  stored_orientation[3] = g_fw_x;
                  stored_orientation[4] = g_fw_y;
                  stored_orientation[5] = g_fw_z;
                  stored_orientation[6] = g_up_x;
                  stored_orientation[7] = g_up_y;
                  stored_orientation[8] = g_up_z;
                  // Find closest.
                  int8_t fw_rand = find_rand_dir(g_fw_x, g_fw_y, g_fw_z);
                  int8_t up_rand = find_rand_dir(g_up_x, g_up_y, g_up_z);
                  // Replace with randomized.
                  g_pos_x = static_cast<float>(iround(g_pos_x / 256.0f)) * 256.0f;
                  g_pos_y = static_cast<float>(iround(g_pos_y / 256.0f)) * 256.0f;
                  g_pos_z = static_cast<float>(iround(g_pos_z / 256.0f)) * 256.0f;
                  dnload_srand(static_cast<unsigned>(fw_rand));
                  g_fw_x = static_cast<float>(i16rand());
                  g_fw_y = static_cast<float>(i16rand());
                  g_fw_z = static_cast<float>(i16rand());
                  dnload_srand(static_cast<unsigned>(up_rand));
                  g_up_x = static_cast<float>(i16rand());
                  g_up_y = static_cast<float>(i16rand());
                  g_up_z = static_cast<float>(i16rand());
                  // Inform.
                  std::cout << "[ " << iround(g_pos_x / 256.0f) << ", " << iround(g_pos_y / 256.0f) << ", " <<
                    iround(g_pos_z / 256.0f) << " ] ; " << static_cast<int>(fw_rand) << " ; " <<
                    static_cast<int>(up_rand) << std::endl;
                  // Mark as active.
                  stored_orientation_active = true;
                }
              }
#endif
            }
            break;

          case SDLK_F5:
            if(!program_default.link())
            {
              BOOST_THROW_EXCEPTION(std::runtime_error("program compilation failure (default)"));
            }
            g_program_default = program_default.getId();
            if(!program_worm.link())
            {
              BOOST_THROW_EXCEPTION(std::runtime_error("pipeline recreation failure (worm)"));
            }
            g_program_worm = program_worm.getId();
            if(!program_quad.link())
            {
              BOOST_THROW_EXCEPTION(std::runtime_error("pipeline recreation failure (quad)"));
            }
            g_program_quad = program_quad.getId();
            break;

          case SDLK_ESCAPE:
            quit = true;
            break;

          default:
            //std::cout << event.key.keysym.sym << std::endl;
            break;
        }
      }
      else if((SDL_KEYUP == event.type) && !event.key.repeat)
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

          case SDLK_z:
            dof_neg = 0;
            break;

          case SDLK_x:
            dof_pos = 0;
            break;

          case SDLK_LSHIFT:
          case SDLK_RSHIFT:
            move_speed = MOVE_SPEED_SLOW;
            break;            

          case SDLK_MODE:
          case SDLK_LALT:
          case SDLK_RALT:
          case SDLK_RALT_EXTRA:
            time_delta = 0;
            break;

          case SDLK_SPACE:
#if !defined(FRACTAL_DEBUG)
            if(stored_orientation_active)
            {
              g_pos_x = stored_orientation[0];
              g_pos_y = stored_orientation[1];
              g_pos_z = stored_orientation[2];
              g_fw_x = stored_orientation[3];
              g_fw_y = stored_orientation[4];
              g_fw_z = stored_orientation[5];
              g_up_x = stored_orientation[6];
              g_up_y = stored_orientation[7];
              g_up_z = stored_orientation[8];
              stored_orientation_active = false;
            }
#endif
            break;

          default:
            break;
        }
      }
      else if(SDL_MOUSEBUTTONDOWN == event.type)
      {
        if(g_direction_lock)
        {
          g_pos_x += static_cast<float>(g_uniform_array[0]);
          g_pos_y += static_cast<float>(g_uniform_array[1]);
          g_pos_z += static_cast<float>(g_uniform_array[2]);
          g_direction_lock = false;
        }

        if(1 == event.button.button)
        {
          mouse_look = 1;
        }
        if(2 == event.button.button)
        {
          fractal_constant_x = event.button.x;
          fractal_constant_y = event.button.y;
          fractal_constant_set = true;
        }
        else if(3 == event.button.button)
        {
          fractal_look = 1;
        }
      }
      else if(SDL_MOUSEBUTTONUP == event.type)
      {
        if(1 == event.button.button)
        {
          mouse_look = 0;
        }
        else if(3 == event.button.button)
        {
          fractal_look = 0;
        }
      }
      else if(SDL_MOUSEMOTION == event.type)
      {
        if(0 != mouse_look)
        {
          mouse_look_x += event.motion.xrel;
          mouse_look_y += event.motion.yrel;
        }
        if(0 != fractal_look)
        {
          fractal_look_x += event.motion.xrel;
          fractal_look_y += event.motion.yrel;
        }
      }
      else if(SDL_MOUSEWHEEL == event.type)
      {
        if(event.wheel.y > 0)
        {
          for(int ii = event.wheel.y; (ii > 0); --ii)
          {
            g_fractal_zoom *= 1.0f - FRACTAL_ZOOM_FACTOR;
          }
        }
        else
        {
          for(int ii = event.wheel.y; (ii < 0); ++ii)
          {
            g_fractal_zoom *= 1.0f + FRACTAL_ZOOM_FACTOR;
          }
        }
      }
    }

    if(g_flag_developer)
    {
      float uplen = sqrtf(g_up_x * g_up_x + g_up_y * g_up_y + g_up_z * g_up_z);
      float fwlen = sqrtf(g_fw_x * g_fw_x + g_fw_y * g_fw_y + g_fw_z * g_fw_z);
      float rt_x;
      float rt_y;
      float rt_z;
      float movement_rt = static_cast<float>(move_right - move_left) * move_speed;
      float movement_up = static_cast<float>(move_up - move_down) * move_speed;
      float movement_fw = static_cast<float>(move_backward - move_forward) * move_speed;

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
        float angle = static_cast<float>(mouse_look_x) / static_cast<float>(screen_h / 4) * -0.25f;
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
        float angle = static_cast<float>(mouse_look_y) / static_cast<float>(screen_h / 4) * -0.25f;
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

      if(0 != fractal_look_x)
      {
        float diff = static_cast<float>(fractal_look_x) / static_cast<float>(screen_w) *
          g_fractal_zoom * 2.0f * SCREEN_ASPECT;
        g_fractal_offset_x -= diff;
      }
      if(0 != fractal_look_x)
      {
        float diff = static_cast<float>(fractal_look_y) / static_cast<float>(screen_h) *
          g_fractal_zoom * 2.0f;
        g_fractal_offset_y += diff;
      }
      if(fractal_constant_set)
      {
        if(g_fractal_constant_mul != 0.0f)
        {
          g_fractal_constant_x = g_fractal_offset_x + 2.0f * g_fractal_zoom * SCREEN_ASPECT *
            (static_cast<float>(fractal_constant_x) / static_cast<float>(screen_w) - 0.5f);
          g_fractal_constant_y = g_fractal_offset_y - 2.0f * g_fractal_zoom *
            (static_cast<float>(fractal_constant_y) / static_cast<float>(screen_h) - 0.5f);
          g_fractal_constant_mul = 0.0f;
        }
        else
        {
          g_fractal_constant_x = 0.0f;
          g_fractal_constant_y = 0.0f;
          g_fractal_constant_mul = 1.0f;
        }
      }

      g_pos_x += movement_rt * rt_x + movement_up * g_up_x + movement_fw * g_fw_x;
      g_pos_y += movement_rt * rt_y + movement_up * g_up_y + movement_fw * g_fw_y;
      g_pos_z += movement_rt * rt_z + movement_up * g_up_z + movement_fw * g_fw_z;
      
      g_dof += static_cast<float>(dof_pos - dof_neg) * 16.0f;
      if(dof_pos - dof_neg)
      {
        std::cout << g_dof << " (" << iround(g_dof / 256.0f) << ")" << std::endl;
      }
    }

    if(g_flag_developer)
    {
      float dt = static_cast<float>(time_delta) * ((move_speed == MOVE_SPEED_SLOW) ? 1.0f : 8.0f);
      current_time += static_cast<float>(AUDIO_BYTERATE) / 60.0f * dt;

      // Clamp time to prevent going outside direction data.
      current_time = std::max(std::min(static_cast<float>(INTRO_LENGTH), current_time), 0.0f);

      curr_ticks = static_cast<int>(current_time);
    }
    else if(flag_record)
    {
      curr_ticks = static_cast<int>(static_cast<float>(frame_idx) / 60.0f *
          static_cast<float>(AUDIO_BYTERATE));
      ++frame_idx;
    }
    else
    {
      int actual_ticks = static_cast<int>(SDL_GetTicks());

      // Adjust start time for skip.
      if(time_skip)
      {
        start_ticks += time_skip;

        if(start_ticks > actual_ticks)
        {
          start_ticks = actual_ticks;
        }
      }

      float seconds_elapsed = static_cast<float>(actual_ticks - start_ticks) / 1000.0f;

      if(time_skip)
      {
        printf("%1.2f seconds\n", seconds_elapsed);
      }

      curr_ticks = static_cast<int>(seconds_elapsed * static_cast<float>(AUDIO_BYTERATE));

      // Adjust music copy location in a similar fashion.
      if(time_skip)
      {
        g_audio_position = curr_ticks - (curr_ticks % (AUDIO_SAMPLE_SIZE * AUDIO_CHANNELS));
      }
    }

    if((INTRO_LENGTH <= curr_ticks) || quit)
    {
      break;
    }
#else
    curr_ticks = g_audio_position;

    dnload_SDL_PollEvent(&event);
    
    if((INTRO_LENGTH <= curr_ticks) || (event.type == SDL_KEYDOWN))
    {
      break;
    }
#endif

    draw(curr_ticks);

    swap_buffers();
  }

  dnload_SDL_Quit();
#if !defined(USE_LD)
  asm_exit();
#endif
}

//######################################
// Main ################################
//######################################

#if defined(USE_LD)
/// Main function.
///
/// \param argc Argument count.
/// \param argv Arguments.
/// \return Program return code.
int DNLOAD_MAIN(int argc, char **argv)
{
  unsigned screen_w = SCREEN_W;
  unsigned screen_h = SCREEN_H;
  bool fullscreen = true;
  bool record = false;

  try
  {
    if(argc > 0)
    {
      po::options_description desc("Options");
      desc.add_options()
        ("developer,d", "Developer mode.")
        ("help,h", "Print help text.")
        ("record,R", "Do not play intro normally, instead save audio as .wav and frames as .png -files.")
        ("resolution,r", po::value<std::string>(), "Resolution to use, specify as 'WIDTHxHEIGHT' or 'HEIGHTp'.")
        ("window,w", "Start in window instead of full-screen.");

      po::variables_map vmap;
      po::store(po::command_line_parser(argc, argv).options(desc).run(), vmap);
      po::notify(vmap);

      if(vmap.count("developer"))
      {
        g_flag_developer = true;
      }
      if(vmap.count("help"))
      {
        std::cout << usage << desc << std::endl;
        return 0;
      }
      if(vmap.count("record"))
      {
        record = true;
      }
      if(vmap.count("resolution"))
      {
        boost::tie(screen_w, screen_h) = parse_resolution(vmap["resolution"].as<std::string>());
      }
      if(vmap.count("window"))
      {
        fullscreen = false;
      }
    }

    intro(screen_w, screen_h, fullscreen, record);
  }
  catch(const boost::exception &err)
  {
    std::cerr << boost::diagnostic_information(err);
    return 1;
  }
  catch(const std::exception &err)
  {
    std::cerr << err.what() << std::endl;
    return 1;
  }
  catch(...)
  {
    std::cerr << __FILE__ << ": unknown exception caught\n";
    return -1;
  }
  return 0;
}
#endif

//######################################
// End #################################
//######################################

