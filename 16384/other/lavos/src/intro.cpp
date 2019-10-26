/** \file
 * For details, please see README.
 */

//######################################
// Define ##############################
//######################################

/** Audio channels. */
#define AUDIO_CHANNELS 2

/** Audio frequency. */
#define AUDIO_FREQUENCY 44100

/** Audio byterate. */
#define AUDIO_BYTERATE (AUDIO_CHANNELS * AUDIO_FREQUENCY * sizeof(int16_t))

/** Intro length (in samples). */
#define INTRO_LENGTH (152 * AUDIO_BYTERATE)

/** Desired framerate (fps). */
#define DESIRED_FRAMERATE 60

/** Intro start position (in seconds). */
#define INTRO_START 0

/** Intro FOV. */
#define FOV 45.0f

/** Size of strength texture. */
#define TEXTURE_STRENGTH_SIDE 2048

/** Size of strength volume. */
#define VOLUME_STRENGTH_SIDE 256

/** Size of normal volume. */
#define VOLUME_NORMAL_SIDE 128

/** Size of mölli heightmap. */
#define TEXTURE_MOELLI_SIDE 256

/** Size of mölli volume. */
#define VOLUME_MOELLI_SIDE 256

/** Number of random spikes in mölli. */
#define MOELLI_SPIKE_NUM 317

/** Number of positive spikes in mölli. */
#define MOELLI_CUSTOM_POS_SPIKES 9

/** Number of negative spikes in mölli. */
#define MOELLI_CUSTOM_NEG_SPIKES 8

/** Variance in the height of spikes in mölli, spike height scale. */
#define MOELLI_ANGULAR_SCALE_VARIANCE 0.2f

/** Angular size of the average spike in mölli, in radians. */
#define MOELLI_ANGULAR_SCALE static_cast<float>(M_PI / 20.0)

/** Height of the average spike in mölli. */
#define MOELLI_SPIKE_HEIGHT (0.5f / MOELLI_ANGULAR_SCALE)

/** Height of the maximum spike in mölli, determines useful resolution. */
#define MOELLI_SPIKE_LENGTH_SCALE 2.0f

//######################################
// Include #############################
//######################################

#include "dnload.h"
#include "common.hpp"
#include "intro.hpp"

#if defined(USE_LD)
#include "synth.hpp"
#include "image_png.hpp"
#include <iostream>
#include <sstream>
#include <boost/scoped_array.hpp>
#endif

#if defined(USE_LD)
#define EXTERNALLY_VISBILE
#else
#define EXTERNALLY_VISIBLE __attribute__((externally_visible))
#endif

//######################################
// Global data #########################
//######################################

/** \brief Audio buffer for output.
 *
 * Size is double of what is needed since our musician seems to happily write long past it.
 */
static int16_t g_audio_buffer[INTRO_LENGTH / sizeof(int16_t) * 9 / 8];

/** Current audio position. */
static int16_t *g_audio_position = (int16_t*)&g_audio_buffer[INTRO_START * AUDIO_CHANNELS * AUDIO_FREQUENCY];

/** Random data. */
static int8_t g_data_random[VOLUME_STRENGTH_SIDE * VOLUME_STRENGTH_SIDE * VOLUME_STRENGTH_SIDE];

/** Mölli heightmap data. */
static uint16_t g_data_moelli_texture[TEXTURE_MOELLI_SIDE * TEXTURE_MOELLI_SIDE];

/** Mölli precalc spikes C. */
float g_moelli_spike_c[3 * MOELLI_SPIKE_NUM];

/** Mölli precalc spikes LL. */
float g_moelli_spike_ll[3 * MOELLI_SPIKE_NUM];

#if defined(USE_LD)
/** Screen width. */
static GLsizei g_screen_w;
#else
/** Screen width. */
#define g_screen_w 1280
#endif

#if defined(USE_LD)
/** Screen height. */
static GLsizei g_screen_h;
#else
/** Screen height. */
#define g_screen_h 720
#endif

/** \brief Generic uniforms.
 *
 * All generic uniforms in same common array for ease of use (and for size).
 *
 * 0: Time.
 * 1: Screen aspect ratio multiplier x / FBO width.
 * 2: Screen aspect ratio multiplier y / FBO height.
 * 3: Distance from view plane (fov).
 */
static float g_uniform_array[4];

/** \brief Raycast data.
 *
 * Arranged as:
 * 0-2: Position.
 * 3-5: Forward.
 * 6-8: Up.
 */
static float g_raycast[9];

/** Rotation matrix. */
static float g_rotation_matrix[9];

#if defined(USE_LD)

/** Noise strengths. */
static float g_noise_scale[4];

/** Noise scales. */
static float g_noise_strength[4];

/** Noise substract. */
static float g_noise_substract;

/** Effect. */
static unsigned g_effect = 0;

/** Last effect. */
static unsigned g_last_effect = 0xFFFFFFFF;

/** Lookat variable. */
static double g_position_x = 0.0;

/** Lookat variable. */
static double g_position_y = 0.0;

/** Lookat variable. */
static double g_position_z = 0.0;

/** Lookat variable. */
static double g_fw_x = 0.0;

/** Lookat variable. */
static double g_fw_y = 0.0;

/** Lookat variable. */
static double g_fw_z = -1.0;

/** Lookat variable. */
static double g_up_x = 0.0;

/** Lookat variable. */
static double g_up_y = 1.0;

/** Lookat variable. */
static double g_up_z = 0.0;

/** Developer mode global toggle. */
static uint8_t g_flag_developer = 0;

#endif

//######################################
// Common ##############################
//######################################

/** \brief Linear interpolation over pi.
 *
 * If shorter route is through the pi boundary, it is taken.
 *
 * @param start Starting position.
 * @param end Ending position.
 * @param interpolator Intepolator.
 * @return Interpolated value.
 */
static float pilerp(float start, float end, float interpolator)
{
  float diff = end - start;

  if(static_cast<float>(M_PI) < diff)
  {
    diff -= static_cast<float>(M_PI * 2.0);
  }
  else if(static_cast<float>(-M_PI) > diff)
  {
    diff += static_cast<float>(M_PI * 2.0);
  }

  return diff * interpolator + start;
}

/** \brief Normalize directional vector.
 *
 * @param op Floating-point triplet.
 */
static void normalize(float *op)
{
  float len = sqrtf(op[0] * op[0] + op[1] * op[1] + op[2] * op[2]);

  op[0] /= len;
  op[1] /= len;
  op[2] /= len;
}

#if defined(USE_LD)

/** \brief Prints an indent.
 *
 * @param lhs Stream to output to.
 * @param indent Number of characters to draw.
 */
static void print_indent(std::ostream &lhs, unsigned indent)
{
  for(unsigned ii = 0; (ii < indent); ++ii)
  {
    lhs << ' ';
  }
}

/** \brief Perform a set regex on a string.
 *
 * @return True if matches, false if not.
 */
static bool regex_space_plus_alpha_plus_semicolon(const char *op)
{
  for(;;)
  {
    if(' ' != *op)
    {
      for(;;)
      {
        if(!isalpha(*op))
        {
          for(;;)
          {
            char cc = *op;

            if(' ' != cc)
            {
              return (';' == cc);
            }

            ++op;
          }
        }

        ++op;
      }
    }

    ++op;
  }
}

/** \brief Terminate the program cleanly.
 *
 * @param op Error code to return.
 */
static void terminate(int op = 1)
{
  SDL_Quit();
  exit(op);
}

#endif

//######################################
// Shader ##############################
//######################################

/** Maximum number of distinct elements in a shader. */
#define MAX_SHADER_PARTS 6

/** \brief Shader class. */
class Shader
{
  private:
    /** Shader part list. */
    const GLchar *m_parts[MAX_SHADER_PARTS];

    /** Number of parts in a shader. */
    GLsizei m_num_parts;

  public:
    /** \brief Fake constructor.
     *
     * @param op First (and potentially only) shader part.
     */
    void init(const GLchar *op);

  public:
    /** \brief Add part.
     *
     * @param op Shader part.
     */
    void addPart(const GLchar *op);

    /** \brief Compile the shader.
     *
     * @param op Shader type.
     */
    GLuint compile(GLenum op);

#if defined(USE_LD)
  private:
    /** \brief Get shader info log.
     *
     * @return Info log string.
     */
    static std::string get_info_log(GLuint shader_object);

    /** \cond */
    friend std::ostream& operator<<(std::ostream &lhs, const Shader &rhs);
    /** \endcond */
#endif
};

#if defined(USE_LD)

/** \brief Print shader into a stream.
 *
 * @param op Stream to print to.
 */
std::ostream& operator<<(std::ostream &lhs, const Shader &rhs)
{
  int current_part = 0;
  unsigned indent = 0;

  while(current_part < rhs.m_num_parts)
  {
    const GLchar *iter = rhs.m_parts[current_part];

    for(;;)
    {
      char cc = *iter;

      if(0 == cc)
      {
        break;
      }

      switch(cc)
      {
        case ';':
          lhs << ";\n";
          print_indent(lhs, indent);
          break;

        case '{':
          lhs << std::endl;
          print_indent(lhs, indent);
          lhs << "{\n";
          indent += 2;
          print_indent(lhs, indent);
          break;

        case '}':
          lhs << '\r';
          indent -= 2;
          print_indent(lhs, indent);
          lhs << "}";
          if(!regex_space_plus_alpha_plus_semicolon(iter + 1))
          {
            lhs << std::endl;
            print_indent(lhs, indent);
          }
          break;

        default:
          lhs << cc;
          break;
      }

      ++iter;
    }

    ++current_part;
  }

  return lhs;
}

#endif

void Shader::init(const GLchar *op)
{
  m_parts[0] = "#version 150\n#define P 3.14159265\n";
  m_parts[1] = op;
  m_num_parts = 2;
}

void Shader::addPart(const GLchar *op)
{
#if defined(USE_LD)
  if(MAX_SHADER_PARTS <= m_num_parts)
  {
    std::cerr << "trying to add more than " << MAX_SHADER_PARTS << " parts into a shader" << std::endl;
    terminate(1);
  }
#endif

  m_parts[m_num_parts] = op;
  ++m_num_parts;
}

unsigned Shader::compile(GLenum op)
{
  GLuint ret = g_sym.glCreateShader(op);

#if defined(USE_LD)
  std::string combined_source;
  const char *combined_parts;
  {
    std::ostringstream sstr;
    sstr << * this;
    combined_source = sstr.str();
    combined_parts = combined_source.c_str();
  }
  g_sym.glShaderSource(ret, 1, &combined_parts, NULL);
#else
  g_sym.glShaderSource(ret, m_num_parts, m_parts, NULL);
#endif

  g_sym.glCompileShader(ret);
#if defined(USE_LD)
  {
    std::string info_log = get_info_log(ret);
    GLint compile_status;
      
    if(0 < info_log.length())
    {
      std::cout << *this << std::endl << info_log;
    }

    glGetShaderiv(ret, GL_COMPILE_STATUS, &compile_status);
    if(GL_TRUE != compile_status)
    {
      terminate(1);
    }
  }
#endif
  return ret;
}

#if defined(USE_LD)

std::string Shader::get_info_log(GLuint shader_object)
{
  GLint info_log_len;

  glGetShaderiv(shader_object, GL_INFO_LOG_LENGTH, &info_log_len);

  if(0 < info_log_len)
  {
    boost::scoped_array<char> info_log(new char[info_log_len]);
    GLsizei lenght_acquired;

    glGetShaderInfoLog(shader_object, info_log_len, &lenght_acquired, info_log.get());

    if(static_cast<GLsizei>(info_log_len) != lenght_acquired + 1)
    {
      std::cerr << "WARNING: reported compiler info log length " << info_log_len << " did not match acquired: " <<
        lenght_acquired << std::endl;
    }

    return std::string(info_log.get());
  }

  return std::string();
}

#endif

//######################################
// Program #############################
//######################################

/** \brief Shader program.
 */
class Program
{
  private:
    /** Attributes. */
    GLuint m_attributes[128];

    /** Uniforms. */
    GLint m_uniforms[128];

    /** Compiled program. */
    GLuint m_program;

  public:
    /** \brief Fake constructor.
     *
     * @param vshader Vertex shader.
     * @param fshader Fragment shader.
     */
    void init(Shader &vshader, Shader &fshader);

  public:
    /** \brief Enable a vertex attribute array.
     *
     * @param name Name of array to enable.
     */
    void enableVertexAttribArray(char name);

    /** \brief Uniform function.
     *
     * @param name Name.
     * @param value Value.
     */
    void uniform1i(char name, GLint value);

    /** \brief Uniform function.
     *
     * @param name Name.
     * @param value Value.
     */
    void uniform1f(char name, GLfloat value);

    /** \brief Uniform function.
     *
     * @param name Name.
     * @param data Data.
     */
    void uniform3fv(char name, const GLfloat *data);

    /** \brief Uniform function.
     *
     * @param name Name.
     * @param data Data.
     */
    void uniform4fv(char name, const GLfloat *data);

    /** \brief Uniform function.
     *
     * @param name Name.
     * @param data Data.
     */
    void uniformMatrix3fv(char name, const GLfloat *data);

    /** \brief Use this program.
     *
     * @param 
     */
    void use();

    /** \brief Bind vertex attribute pointer.
     *
     * @param name Name.
     * @param data Vertex data.
     */
    void vertexAttribPointer2f(char name, const void *data);

  public:
    /** \brief Get attribute identifier.
     *
     * Uniform and attribute identifiers are one character long for brevity.
     *
     * @param op Attribute identifier.
     */
    inline GLuint getAttribute(GLchar op) const
    {
      int idx = static_cast<int>(op);

#if defined(USE_LD)
      if(0xFFFFFFFF == m_attributes[idx])
      {
        std::cerr << "program does not contain attribute named '" << op << "'\n";
        terminate(1);
      }
#endif
      return m_attributes[idx];
    }

    /** \brief Get uniform identifier.
     *
     * Uniform and attribute identifiers are one character long for brevity.
     *
     * @param op Attribute identifier.
     */
    inline GLint getUniform(GLchar op) const
    {
      int idx = static_cast<int>(op);

#if defined(USE_LD)
      if(-1 == m_uniforms[idx])
      {
        std::cerr << "program does not contain uniform named '" << op << "'\n";
        terminate(1);
      }
#endif
      return m_uniforms[idx];
    }

#if defined(USE_LD)
  private:
    /** \brief Get shader info log.
     *
     * @return Info log string.
     */
    std::string getInfoLog() const;
#endif
};

void Program::init(Shader &vshader, Shader &fshader)
{
  m_program = g_sym.glCreateProgram();
  g_sym.glAttachShader(m_program, vshader.compile(GL_VERTEX_SHADER));
  g_sym.glAttachShader(m_program, fshader.compile(GL_FRAGMENT_SHADER));
  g_sym.glLinkProgram(m_program);
#if defined(USE_LD)
  {
    std::string info_log = this->getInfoLog();
    if(0 < info_log.length())
    {
      std::cerr << info_log;
    }

    {
      GLint link_status;
      glGetProgramiv(m_program, GL_LINK_STATUS, &link_status);
      if(GL_TRUE != link_status)
      {
        terminate(1);
      }
    }
  }
#endif

  for(unsigned ii = 0; (ii < 128); ++ii)
  {
    GLchar identifier[2] = { static_cast<GLchar>(ii), 0 };

    m_attributes[ii] = static_cast<GLuint>(g_sym.glGetAttribLocation(m_program, identifier));
    m_uniforms[ii] = g_sym.glGetUniformLocation(m_program, identifier);
  }
}

void Program::enableVertexAttribArray(char name)
{
  g_sym.glEnableVertexAttribArray(this->getAttribute(name));
}

void Program::uniform1i(char name, GLint value)
{
  g_sym.glUniform1i(this->getUniform(name), value);
}

void Program::uniform1f(char name, GLfloat value)
{
  g_sym.glUniform1f(this->getUniform(name), value);
}

void Program::uniform3fv(char name, const GLfloat *data)
{
  g_sym.glUniform3fv(this->getUniform(name), 1, data);
}

void Program::uniform4fv(char name, const GLfloat *data)
{
  g_sym.glUniform4fv(this->getUniform(name), 1, data);
}

void Program::uniformMatrix3fv(char name, const GLfloat *data)
{
  g_sym.glUniformMatrix3fv(this->getUniform(name), 1, GL_FALSE, data);
}

void Program::vertexAttribPointer2f(char name, const void *data)
{
  this->enableVertexAttribArray(name);
  g_sym.glVertexAttribPointer(this->getAttribute(name), 2, GL_FLOAT, GL_FALSE, 0, data);
}

void Program::use()
{
#if defined(USE_LD)
  if(0 == m_program)
  {
    std::cerr << "program not compiled, aborting";
    terminate(1);
  }
#endif
  g_sym.glUseProgram(m_program);
}

#if defined(USE_LD)
std::string Program::getInfoLog() const
{
  GLint info_log_len;

  glGetProgramiv(m_program, GL_INFO_LOG_LENGTH, &info_log_len);

  if(0 < info_log_len)
  {
    boost::scoped_array<char> info_log(new char[info_log_len]);
    GLsizei lenght_acquired;

    glGetProgramInfoLog(m_program, info_log_len, &lenght_acquired, info_log.get());

    if(static_cast<GLsizei>(info_log_len) != lenght_acquired + 1)
    {
      std::cerr << "WARNING: reported linker info log length " << info_log_len << " did not match acquired: " <<
        lenght_acquired << std::endl;
    }

    return std::string(info_log.get());
  }

  return std::string();
}
#endif

//######################################
// Shaders #############################
//######################################

/** Quad vertex shader. */
static const char g_shader_code_vertex_quad[] = ""
"in vec2 a;"
"uniform vec4 r;"
"uniform vec3 f;"
"uniform vec3 u;"
"out D"
"{"
"vec4 d;"
"}o;"
"void main()"
"{"
"vec3 g=normalize(f)*r.w;"
"vec3 v=normalize(u);"
"vec3 s=normalize(cross(g,v));"
"v=cross(s,g);"
"if(r.y>r.z)s*=r.y/r.z;"
"else v*=r.z/r.y;"
"o.d=vec4(a.x*s+a.y*v+g,sin(r.x*.000009)*.0047);"
"gl_Position=vec4(a,0,1);"
"}";

/** Input to quad fragment shaders. */
static const char g_shader_code_fragment_quad_input[] = ""
"in D"
"{"
"vec4 d;"
"}i;";

/** Gradient function. */
static const char g_shader_code_fragment_quad_g[] = ""
"vec3 g(vec3 n,float N)"
"{"
"vec3 d=vec3(.02,0,0);"
"return normalize(vec3(f(n+d.xyy),f(n+d.yxy),f(n+d.yyx))-N);"
"}";

/** Force function for desert. */
static const char g_shader_code_fragment_desert_f[] = ""
"uniform sampler2D t;"
"uniform mat3 M;"
#if defined(USE_LD)
"uniform vec4 S;"
"uniform vec4 R;"
"uniform float C;"
#endif
"float f(vec3 n)"
"{"
"vec3 c=vec3(n.x,0,n.z);"
#if defined(USE_LD)
"c=transpose(M)*c*S.x+M*c*S.x;"
"float l=R.x*texture(t,c.xz).r;"
"c=M*c*S.y;"
"l+=R.y*texture(t,c.xz).r;"
"c=M*c*S.z;"
"l+=R.z*texture(t,c.xz).r;"
"l=pow(3.33,l);"
"return l+n.y-C;"
#else
"c=transpose(M)*c*.0027+M*c*.0027;"
"float l=texture(t,c.xz).r*.079;"
"c=M*c*1.57;"
"l+=texture(t,c.xz).r*.041;"
"c=M*c*1.83;"
"l+=texture(t,c.xz).r*.037;"
"l=pow(3.33,l);"
"return l+n.y-.18;"
#endif
"}"
"const vec4 Q=vec4(.003,.33,3,.0079);";

/** Force function for lava. */
static const char g_shader_code_fragment_lava_f[] = ""
"uniform sampler3D v;"
"uniform mat3 M;"
#if defined(USE_LD)
"uniform vec4 S;"
"uniform vec4 R;"
"uniform float C;"
#endif
"float f(vec3 n)"
"{"
#if defined(USE_LD)
"vec3 c=transpose(M)*n*S.x+M*n*S.x;"
"float l=R.x*texture(v,c).r;"
"c=M*c*S.y;"
"l+=R.y*texture(v,c).r;"
"c=M*c*S.z;"
"l+=R.z*texture(v,c).r;"
"c=M*c*S.w;"
"l+=R.w*texture(v,c).r;"
"return l-C;"
#else
"vec3 c=transpose(M)*n*.011+M*n*.011;"
"float l=texture(v,c).r*2.09;"
"c=M*c*2.01;"
"l+=texture(v,c).r*.78;"
"c=M*c*2.03;"
"l+=texture(v,c).r*.045;"
"c=M*c*2.07;"
"l-=texture(v,c).r*.16;"
"return l-.18;"
#endif
"}"
"const vec4 Q=vec4(.0025,.1,1.5,.01);";

/** \brief Force function for moelli.
 * 
 * l2 (now "d") is a bit complicated, as what we are trying to do is to have
 * the map affect stuff directly downward (-z). For this purpose, we find that
 * h is the height level of the ball surface above the pixel and then the
 * latitude is recalculated assuming the point is projected at the ball
 * surface. This distance is added to the texture sampling step and then 0.5,
 * which is the zero-level surface distance derived from the texture for l1, is
 * deducted from the result.
 */
static const char g_shader_code_fragment_moelli_f[] = ""
"uniform sampler2D t;"
"uniform sampler3D v;"
"uniform mat3 M;"
#if defined(USE_LD)
"uniform vec4 S;"
"uniform vec4 R;"
#endif
"uniform float C;"
"float f(vec3 n)"
"{"
"float D=dot(n,n);"
"float E=dot(n.xz,n.xz);"
"if((D<.4)&&(E<.15))"
"{"
"D=sqrt(D);"
"E=sqrt(E);"
"float R=.25;" // assumed radius of the texture zero-level on the ball itself
"float o=(atan(n.z-i.d.w,n.x+i.d.w)+P/2)/P/2;"
"float a=acos(n.y/D)/P;"
"float h=R*sin(P/2-asin(clamp(E,0,R)/R));"
"float b=acos(h*4)/P;" // assumed radius of the texture zero-level on the ball itself = 4
"float c=D-(texture(t,vec2(a,o)).r-.5)*.5-R;" // We deduct the zero-level (0.5) from the texture sampling result to be able to control ball radius and surface scale independently
"float d=-n.y-h-(texture(t,vec2(b,o)).r-.5)*clamp(pow(1-E,4),0,1)*2;"
"d=mix(D-R,d,clamp(100*(R-E),0,1));"
"float N=texture(v,n*.34).r*.013+texture(v,M*n*.69).r*.006;"
"float l=mix(c,d,clamp(-20*n.y,0,1));"
"return l+N*(1+clamp(-3*n.y,0,3));"
"}"
#if defined(USE_LD)
"vec3 c=transpose(M)*(n+vec3(C,C,-C))*S.x+M*(n+vec3(-C,C,C))*S.x;"
"float l=R.x*texture(v,c).r;"
"c=M*c*S.y;"
"l+=R.y*texture(v,c).r;"
"c=M*c*S.z;"
"l+=R.z*texture(v,c).r;"
#else
"vec3 c=transpose(M)*(n+vec3(C,C,-C))*.047+M*(n+vec3(-C,C,C))*.047;"
"float l=texture(v,c).r*.66;"
"c=M*c*2.01;"
"l+=texture(v,c).r*.69;"
"c=M*c*2.69;"
"l+=texture(v,c).r*.29;"
#endif
"l=l*l*l;"
"return l+n.y*.5+.33;"
"}"
"const vec4 Q=vec4(.0021,.043,2,.009);";

/** Force function for lava. */
static const char g_shader_code_fragment_mountains_f[] = ""
"uniform sampler3D v;"
"uniform mat3 M;"
#if defined(USE_LD)
"uniform vec4 S;"
"uniform vec4 R;"
"uniform float C;"
#endif
"float f(vec3 n)"
"{"
#if defined(USE_LD)
"vec3 c=transpose(M)*vec3(n.x,n.y*.5,n.z)*S.x+M*vec3(n.x,n.y*.5,n.z)*S.x;"
"float l=R.x*texture(v,c).r;"
"l=pow(l+.21,1.67);"
"c=M*c*S.y;"
"l+=R.y*texture(v,c).r;"
"c=M*c*S.z;"
"l+=R.z*texture(v,c).r;"
"c=M*c*S.w;"
"l+=R.w*texture(v,c).r;"
"return l+n.y-C;"
#else
"vec3 c=transpose(M)*vec3(n.x,n.y*.5,n.z)*.0027+M*vec3(n.x,n.y*.5,n.z)*.0027;"
"float l=texture(v,c).r*3.47;"
"l=pow(l+.21,1.67);"
"c=M*c*2.07;"
"l+=texture(v,c).r*.66;"
"c=M*c*2.91;"
"l-=texture(v,c).r*.235;"
"c=M*c*2.73;"
"l+=texture(v,c).r*.19;"
"return l+n.y-.18;"
#endif
"}"
"const vec4 Q=vec4(.005,.14,2.5,.0118);";

/** Force function for volcanic. */
static const char g_shader_code_fragment_volcanic_f[] = ""
"uniform sampler3D v;"
"uniform vec4 r;"
"uniform mat3 M;"
#if defined(USE_LD)
"uniform vec4 S;"
"uniform vec4 R;"
"uniform float C;"
#endif
"float f(vec3 n)"
"{"
"vec3 D=vec3(n.x,n.y*.25,n.z);"
"float E=dot(D,D);"
"float s=r.x*.0000055;"
"float u=r.x*.0000117;"
"if(E<s)return E-s;"
"float F=smoothstep(s,u,E);"
"E=(1-F*F*F)*r.x*.0000045;"
#if defined(USE_LD)
"vec3 c=transpose(M)*n*S.x+M*n*S.x;"
"float l=R.x*texture(v,vec3(c.x,(n.y-E)*.0011,c.z)).r;"
"c=M*c*S.y;"
"l+=R.y*texture(v,vec3(c.x,(n.y-E)*.011,c.y)).r;"
"c=M*c*S.z;"
"l+=R.z*texture(v,vec3(c.x,(n.y-E)*.11,c.z)).r;"
#else
"vec3 c=transpose(M)*n*.0099+M*n*.0099;"
"float l=texture(v,vec3(c.x,(n.y-E)*.0011,c.z)).r*2.33;"
"c=M*c*2.01;"
"l+=texture(v,vec3(c.x,(n.y-E)*.011,c.y)).r*.617;"
"c=M*c*2.03;"
"l-=texture(v,vec3(c.x,(n.y-E)*.11,c.z)).r*.213;"
#endif
"l=l*l*l;"
#if defined(USE_LD)
"return l+n.y*F-C;"
#else
"return l+n.y*F-.18;"
#endif
"}"
"const vec4 Q=vec4(.003,.11,1.5,.01);";

/** Surface function for lava. */
static const char g_shader_code_fragment_desert_s[] = ""
"uniform sampler3D v;"
"vec3 s(vec3 p,vec3 n,float N, float i)"
"{"
"const vec3 L=normalize(vec3(0.75,.2,-1.2));"
"vec3 G=g(n,N);"
"vec3 c=M*n*2.17;"
"float H=texture(v,c).r;"
"c=M*c*2.01;"
"H+=texture(v,c).r*.75;"
"vec3 D=mix(vec3(.6,.3,.07),vec3(.9,.61,.11), H);"
"c=M*(p*.37+n)*.037;"
"float O=texture(v,c).r*.67;"
"c=M*c*2.01;"
"O+=texture(v,c).r*.31;"
"c=M*c*2.03;"
"O+=texture(v,c).r*.15;"
"vec3 l=normalize(G+H);"
"vec3 k=mix(vec3(.9,.9,.77),vec3(.2,.2,.28),n.y*.016);"
"return mix(k,D*(dot(L,l)*.5+.5),i+O*.21);"
"}";

/** Surface function for lava. */
static const char g_shader_code_fragment_lava_s[] = ""
"uniform sampler3D w;"
"vec3 s(vec3 p,vec3 n,float N,float i)"
"{"
"const vec3 L=normalize(vec3(.5,1.7,-.7));"
"vec3 G=g(n,N);"
"vec3 c=M*n*.5;"
"vec3 H=texture(w,c).rgb*.58;"
"c=M*c*2.01;"
"H+=texture(w,c).rgb*.29;"
"c=M*c*2.03;"
"H+=texture(w,c).rgb*.13;"
"vec3 l=normalize(G+H);"
"c=M*p*.003;"
"float D=abs(texture(w,c).r)*1.8;"
"c=M*c*3.01;"
"D+=abs(texture(w,c).r);"
"c=M*c*2.03;"
"D+=abs(texture(w,c).r);"
"vec3 k=vec3(.7,.2,.1)*(D+abs(H.r)+abs(H.g)+abs(H.b));"
"return mix(k,vec3(.18,.11,.09)*(dot(L,l)*.5+.5),i);"
"}";

/** Surface function for moelli. */
static const char g_shader_code_fragment_moelli_s[] = ""
"uniform sampler3D w;"
"vec3 s(vec3 p, vec3 n, float N, float i)"
"{"
"const vec3 L=normalize(vec3(.5,1.7,-.7));"
"vec3 c=M*(p+n)*.005;"
"float K=abs(texture(w,c).r)*.58;"
"c=M*c*3.01;"
"K+=abs(texture(w,c).r)*.29;"
"c=M*c*3.03;"
"K+=abs(texture(w,c).r)*.13;"
"c=M*(p+n)*.0023;"
"float Q=abs(texture(w,c).r)*.58;"
"c=M*c*3.01;"
"Q+=abs(texture(w,c).r)*.29;"
"c=M*c*3.03;"
"Q+=abs(texture(w,c).r)*.13;"
"vec3 H=vec3(.07,.03,.008)*Q*n.y;"
"vec3 k=mix(H,vec3(.2,.05,.04),K*clamp(-(n.y-1.4)*.47,0,1));"
"vec3 G=g(n,N);"
"float D=dot(n,n);"
"float E=dot(n.xz,n.xz);"
"if((D<.4)&&(E<.15))"
"{"
"c=M*n*1.59;"
"H=texture(w,c).rgb*.58;"
"c=M*c*2.01;"
"H+=texture(w,c).rgb*.29;"
"c=M*c*2.03;"
"H+=texture(w,c).rgb*.13;"
"vec3 l=normalize(G+H);"
"vec3 h=normalize(p-n);"
"float m=1-abs(dot(h,G));"
"float s=(dot(h,normalize(L+l))*.5+.5);"
"c=mix(vec3(.17,.12,.08),vec3(.4,.13,.09),(D+E)*(D+E)*35);"
"c=mix(vec3(60,60,80),c,clamp((D+E+abs(n.y-.017))*9.5,0,1));"
"return mix(k,c*(dot(L,l)*.5+.5)+vec3(.18,.13,.07)*s*s+vec3(.19,.19,.24)*pow(m,4),i);"
"}"
"c=M*n*.91;"
"H=texture(w,c).rgb*.49;"
"c=M*c*2.01;"
"H+=texture(w,c).rgb*.32;"
"c=M*c*2.03;"
"H+=texture(w,c).rgb*.19;"
"vec3 l=normalize(G+H);"
"vec3 F=mix(vec3(6,3.5,1.2),vec3(.3,.1,.06),clamp((n.y+.97)*3.33,0,1));"
"return mix(k,F*(dot(L,l)*.5+.5),1-pow(1-i,2));"
"}";

/** Surface function for mountains. */
static const char g_shader_code_fragment_mountains_s[] = ""
"uniform sampler3D w;"
"vec3 s(vec3 p,vec3 n,float N,float i)"
"{"
"const vec3 L=normalize(vec3(.5,.7,-1.2));"
"vec3 G=g(n,N);"
"vec3 c=M*n*0.47;"
"vec3 H=texture(w,c).rgb*.58;"
"c=transpose(M)*c*3.33;"
"H-=texture(w,c).rgb*.35;"
"c=M*c*2.03;"
"H+=texture(w,c).rgb*.2;"
"H=normalize(H);"
"vec3 D=mix(vec3(.18,.11,.09),mix(vec3(.11,.19,.09),vec3(.9,.9,.9),(n.y+1.1)*.93),dot(G,H)*.33+.67);"
"D=mix(D,vec3(.4,.4,.9),clamp(n.y,0,1));"
"vec3 l=normalize(G+H*.21);"
"float O=texture(v,p*.037).r*.67+texture(v,p*.096).r*.31+texture(v,p*.13).r*.15;"
"vec3 E=mix(vec3(.6,.6,.71),vec3(.5,.56,.61),O);"
"vec3 k=mix(E,vec3(.5,.5,.8),n.y*.11);"
"return mix(k,D*(dot(L,l)*.5+.5),1-pow(1-i,5));"
"}";

/** Surface function for volcanic. */
static const char g_shader_code_fragment_volcanic_s[] = ""
"uniform sampler3D w;"
"vec3 s(vec3 p,vec3 n,float N,float i)"
"{"
"vec3 D=vec3(n.x,n.y*.25,n.z);"
"float E=dot(D,D);"
"float s=r.x*.0000055;"
"float u=r.x*.0000117;"
"E=1-smoothstep(s,u,E);"
"E=E*E*E*E;"
"const vec3 L=normalize(vec3(.5,1.7,-.7));"
"vec3 G=g(n,N);"
"vec3 c=M*n*.5;"
"vec3 H=texture(w,c).rgb*.5;"
"c=M*c*2.01;"
"H+=texture(w,c).rgb*.25;"
"c=M*c*2.03;"
"H+=texture(w,c).rgb*.125;"
"vec3 l=normalize(G+H);"
"p*=4;"
"vec3 k=vec3(.05,.01,.01)*(abs(texture(w,(p+n)*.003).r)*1.5+abs(texture(w,(p+n)*.009).r)*.75+abs(texture(w,(p+n)*.019).r)*.45);"
"c=vec3(.18,.11,.09)*(dot(L,l)*.5+.5);"
"c=mix(c,vec3(.5,.1,.1),clamp(-(n.y+E)*.75,0,1));"
"c-=(n.y+E)*.3*vec3(.7,.5,.3);"
"return mix(k,mix(c,vec3(.96,.87,.79),E),i);"
"}";

/** Quad fragment shader. */
static const char g_shader_code_fragment_quad_main[] = ""
"uniform vec3 p;"
"out vec4 o;"
"void main()"
"{"
"vec3 c=p;"
"vec3 d=normalize(i.d.xyz);"
"float D=.005;"
"vec3 n;"
"float N;"
"float i;"
"for(i=1;i>0;i-=Q.w)"
"{"
"n=c+d*D;"
"N=f(n);"
"if(N<0)"
"{"
"for(int j=0;(j<5);++j)"
"{"
"vec3 h=(n+c)*.5;"
"float H=f(h);"
"if(H<0)"
"{"
"n=h;"
"N=H;"
"}"
"else "
"c=h;"
"}"
"break;"
"}"
"c=n;"
"D=mix(Q.x,Q.y,clamp(N,.0,Q.z));" 
"}"
"o=vec4(s(p+d,n,N,i),1);"
"}";

/** Text vertex shader. */
static const char g_shader_code_vertex_text[] = ""
"in vec2 a;"
"uniform vec4 r;"
"uniform vec4 R;"
"uniform vec4 S;"
"void main()"
"{"
"float s=1;"
"float v=1;"
"if(r.y>r.z)s=r.z/r.y;"
"else v=r.y/r.z;"
"float c=S.z*S.w;"
"vec2 D=(R.zw-R.xy)*.5*S.z;"
"vec2 h=S.xy+D+R.xy*S.z;"
"h-=D*S.w+R.xy*c;"
"gl_Position=vec4((a*c+h)*vec2(s,v),0,1);"
"}";

/** Text fragment shader. */
static const char g_shader_code_fragment_text[] = ""
"uniform vec4 C;"
"out vec4 o;"
"void main()"
"{"
"o=C;"
"}";

/** Framebuffer-to-screen vertex shader. */
static const char g_shader_code_vertex_fbo[] = ""
"in vec2 a;"
"void main()"
"{"
"gl_Position=vec4(a,0,1);"
"}";

/** Framebuffer-to-screen fragment shader. */
static const char g_shader_code_fragment_fbo[] = ""
"uniform vec4 r;"
"uniform sampler2DMS t;"
"uniform sampler2DMS T;"
"out vec4 o;"
"void main()"
"{"
"vec4 c=texelFetch(t,ivec2(gl_FragCoord.xy*r.yz),0);"
"vec4 C=texelFetch(T,ivec2(gl_FragCoord.xy),0);"
"o=vec4(mix(c.rgb,C.rgb,C.a),1);"
"}";

/** Shader object for generic quad vertices. */
static Shader g_shader_vertex_quad;

/** Shader object for desert. */
static Shader g_shader_fragment_desert;

/** Shader object for lava. */
static Shader g_shader_fragment_lava;

/** Shader object for mölli. */
static Shader g_shader_fragment_moelli;

/** Shader object for mountains. */
static Shader g_shader_fragment_mountains;

/** Shader object for volcanic landscape. */
static Shader g_shader_fragment_volcanic;

/** Shader object for text render. */
static Shader g_shader_vertex_text;

/** Shader object for text render. */
static Shader g_shader_fragment_text;

/** Shader object for FBO vertices. */
static Shader g_shader_vertex_fbo;

/** Shader object for FBO blit. */
static Shader g_shader_fragment_fbo;

/** GPU program for desert. */
static Program g_program_desert;

/** GPU program for lava. */
static Program g_program_lava;

/** GPU program for mölli. */
static Program g_program_moelli;

/** GPU program for mountains. */
static Program g_program_mountains;

/** GPU program for volcanic landscape. */
static Program g_program_volcanic;

/** GPU program for FBO blit. */
static Program g_program_fbo;

/** GPU program for text render. */
static Program g_program_text;

//######################################
// FBO #################################
//######################################

class Framebuffer
{
  private:
    /** Framebuffer object. */
    GLuint m_fbo_object;

    /** Texture object. */
    GLuint m_texture_object;

  public:
    /** \brief Fake constructor.
     *
     * @param width Framebuffer width.
     * @param height Framebuffer height.
     * @param samples Multisample level.
     */
    void init(GLsizei width, GLsizei height, GLsizei samples);

    /** \brief Fake constructor.
     *
     * Create in full screen size.
     *
     * @param samples Multisample level.
     */
    void init(GLsizei samples);

  public:
    /** \brief Apply framebuffer.
     *
     * @param width Width of viewport to use.
     * @param height Height of viewport to use.
     */
    void bind(GLsizei width, GLsizei height);

    /** \brief Apply framebuffer.
     *
     * Bind in full screen size. */
    void bind();

    /** \brief Bind the texture in this framebuffer for use.
     *
     * @param program Program to send to.
     * @param name Uniform name.
     * @param unit Texture unit to take.
     */
    void bindTexture(Program &program, char name, GLenum unit);

    /** Unbind framebuffer. */
    void unbind();
};

void Framebuffer::init(GLsizei width, GLsizei height, GLsizei samples)
{
  g_sym.glGenTextures(1, &m_texture_object);

  g_sym.glBindTexture(GL_TEXTURE_2D_MULTISAMPLE, m_texture_object);
  g_sym.glTexImage2DMultisample(GL_TEXTURE_2D_MULTISAMPLE, samples, GL_RGBA, width, height, GL_FALSE);

  g_sym.glGenFramebuffers(1, &m_fbo_object);
  g_sym.glBindFramebuffer(GL_FRAMEBUFFER, m_fbo_object);
  g_sym.glFramebufferTexture2D(GL_FRAMEBUFFER_EXT, GL_COLOR_ATTACHMENT0_EXT, GL_TEXTURE_2D_MULTISAMPLE,
      m_texture_object, 0);
}

void Framebuffer::init(GLsizei samples)
{
  this->init(g_screen_w, g_screen_h, samples);
}

void Framebuffer::bind(GLsizei width, GLsizei height)
{
  g_sym.glBindFramebuffer(GL_FRAMEBUFFER, m_fbo_object);
  g_sym.glViewport(0, 0, width, height);
}

void Framebuffer::bind()
{
  this->bind(g_screen_w, g_screen_h);
}

void Framebuffer::bindTexture(Program &program, char name, GLenum unit)
{
  g_sym.glActiveTexture(unit);
  g_sym.glBindTexture(GL_TEXTURE_2D_MULTISAMPLE, m_texture_object);
  program.uniform1i(name, static_cast<GLint>(unit - GL_TEXTURE0));
}

void Framebuffer::unbind()
{
  g_sym.glBindFramebuffer(GL_FRAMEBUFFER, 0);
  g_sym.glViewport(0, 0, g_screen_w, g_screen_h);
}

/** Framebuffer object to render quad to. */
Framebuffer g_fbo_quad;

/** Framebuffer object to render text to. */
Framebuffer g_fbo_text;

//######################################
// Texture #############################
//######################################

/** \brief Texture class. */
class Texture
{
  private:
    /** Texture object. */
    GLuint m_texture_object;

  public:
    /** Fake constructor.
     *
     * @param internal internal format.
     * @param side Length of one texture side.
     * @param format Format.
     * @param data Texture data.
     */
    void init(GLint internal, GLsizei side, GLenum format, GLenum type, const void *data);

  public:
    /** \brief Send t exture to GPU.
     *
     * @param program Program to send to.
     * @param name Uniform name.
     * @param unit Texture unit to take.
     */
    void bind(Program &program, char name, GLenum unit);
};

void Texture::init(GLint internal, GLsizei side, GLenum format, GLenum type, const void *data)
{
  g_sym.glBindTexture(GL_TEXTURE_2D, 0);
  g_sym.glGenTextures(1, &m_texture_object);
  g_sym.glBindTexture(GL_TEXTURE_2D, m_texture_object);

  g_sym.glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
  g_sym.glTexImage2D(GL_TEXTURE_2D, 0, internal, side, side, 0, format, type, data);
}

void Texture::bind(Program &program, char name, GLenum unit)
{
  g_sym.glActiveTexture(unit);
  g_sym.glBindTexture(GL_TEXTURE_2D, m_texture_object);
  program.uniform1i(name, static_cast<GLint>(unit - GL_TEXTURE0));
}

/** Molli heightmap. */
Texture g_texture_moelli;

/** Strength texture (noise). */
Texture g_texture_strength;

//######################################
// Volume ##############################
//######################################

/** \brief Volumetric texture class. */
class Volume
{
  private:
    /** Texture object. */
    GLuint m_texture_object;

  public:
    /** \brief Fake constructor.
     *
     * @param internal Internal format.
     * @param side Length of one texture side.
     * @param format Format.
     * @param data Texture data.
     */
    void init(GLint internal, GLsizei side, GLenum format, GLenum type, const void *data);

  public:
    /** \brief Send texture to GPU.
     *
     * @param program Program to send to.
     * @param name Uniform name.
     * @param unit Texture unit to take.
     */
    void bind(Program &program, char name, GLenum unit);
};

void Volume::init(GLint internal, GLsizei side, GLenum format, GLenum type, const void *data)
{
  g_sym.glGenTextures(1, &m_texture_object);
  g_sym.glBindTexture(GL_TEXTURE_3D, m_texture_object);

  g_sym.glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
  g_sym.glTexImage3D(GL_TEXTURE_3D, 0, internal, side, side, side, 0, format, type, data);
}

void Volume::bind(Program &program, char name, GLenum unit)
{
  g_sym.glActiveTexture(unit);
  g_sym.glBindTexture(GL_TEXTURE_3D, m_texture_object);
  program.uniform1i(name, static_cast<GLint>(unit - GL_TEXTURE0));
}

/** Normal volume (noise). */
Volume g_volume_normal;

/** Strength volume (noise). */
Volume g_volume_strength;

//######################################
// Spline ##############################
//######################################

/** Maximum number of distinct spline parts. */
#define MAX_SPLINE_PARTS 6

/** \brief Spline point class. */
class SplinePoint
{
  private:
    /** \brief data.
     *
     * 0-2: Position.
     * 3-5: Forward.
     * 6-8: Up.
     */
    float m_data[9];

    /** Time. */
    float m_time;

  public:
    /** \brief Accessor.
     *
     * @return Data pointer.
     */
    const float* getData() const
    {
      return m_data;
    }

    /** \brief Accessor.
     *
     * @return Time.
     */
    float getTime() const
    {
      return m_time;
    }

  public:
    /** \brief Fake constructor.
     *
     * @param px X position.
     * @param py Y position.
     * @param pz Z position.
     * @param fx X forward.
     * @param fy Y forward.
     * @param fz Z forward.
     * @param ux X up.
     * @param uy Y up.
     * @param uz Z up.
     * @param time Time.
     */
    void init(int16_t px, int16_t py, int16_t pz, int8_t fx, int8_t fy, int8_t fz, int8_t ux, int8_t uy,
        int8_t uz, int8_t time);

  public:
    /** Evaluate position at a given point.
     *
     * @param rhs Next point.
     * @param time Point in time.
     * @param velocity Velocity.
     * @param out_data Result.
     */
    void evaluatePosition(const SplinePoint &rhs, float time, const float *velocity, float *out_data) const;

    /** \brief Resolve velocity at next point.
     *
     * @param rhs Next spline point.
     * @param out_velocity Next velocity.
     */
    void evaluateVelocity(const SplinePoint &rhs, float *out_velocity) const;

  private:
    /** \brief Evaluate acceleration required to reach next position.
     *
     * @param rhs Next spline point.
     * @param velocity Velocity.
     * @param out_acceleration Calculated acceleration.
     */
    void evaluateAcceleration(const SplinePoint &rhs, const float *velocity, float *out_acceleration) const;

#if defined(USE_LD)
  public:
    void print(FILE *fd) const;
#endif
};

void SplinePoint::init(int16_t px, int16_t py, int16_t pz, int8_t fx, int8_t fy, int8_t fz, int8_t ux,
    int8_t uy, int8_t uz, int8_t time)
{
  static const float COORD_MUL = 1.0f / 255.0f;
  static const float DIR_MUL = 1.0f / 127.0f;

  m_data[0] = (float)px * COORD_MUL;
  m_data[1] = (float)py * COORD_MUL;
  m_data[2] = (float)pz * COORD_MUL;
  m_data[3] = (float)fx * DIR_MUL;
  m_data[4] = (float)fy * DIR_MUL;
  m_data[5] = (float)fz * DIR_MUL;
  m_data[6] = (float)ux * DIR_MUL;
  m_data[7] = (float)uy * DIR_MUL;
  m_data[8] = (float)uz * DIR_MUL;
  m_time = (float)time * static_cast<float>(AUDIO_BYTERATE);

  // Normalize directions, otherwise weighting may be off.
  normalize(m_data + 3);
  normalize(m_data + 6);
}

void SplinePoint::evaluateAcceleration(const SplinePoint &rhs, const float *velocity,
    float *out_acceleration) const
{
  // Must reach next spline point, only acceleration may change in linear fashion.
  // Becomes p0 + 0.5 * a * dt^2 + v0 * dt = p1
  // => a = p1 - v0 * dt - p0 / (0.5 * dt^2)
  float dt = rhs.getTime() - m_time;
  float div = 0.5f * dt * dt;

  for(unsigned ii = 0; (ii < 9); ++ii)
  {
    out_acceleration[ii] = (rhs.getData()[ii] - velocity[ii] * dt - m_data[ii]) / div;
  }
}

void SplinePoint::evaluateVelocity(const SplinePoint &rhs, float *out_velocity) const
{
  // Find acceleration with earlier function.
  // => v1 = v0 + a * dt
  float dt = rhs.getTime() - m_time;
  float acceleration[9];

  this->evaluateAcceleration(rhs, out_velocity, acceleration);

  for(unsigned ii = 0; (ii < 9); ++ii)
  {
    out_velocity[ii] += acceleration[ii] * dt;
  }
}

void SplinePoint::evaluatePosition(const SplinePoint &rhs, float time, const float *velocity,
    float *out_data) const
{
  // Acceleration can be found out. Calculate position at given time.
  // p1 = p0 + 0.5 * a * dt^2 + v0 * dt
  float dt = time - m_time;
  float acceleration[9];

  this->evaluateAcceleration(rhs, velocity, acceleration);

  //printf("acceleration: [%1.2f ; %1.2f ; %1.2f]\n", acceleration_position[0], acceleration_position[1],
  //    acceleration_position[2]);

  for(unsigned ii = 0; (ii < 9); ++ii)
  {
    out_data[ii] = m_data[ii] + 0.5f * acceleration[ii] * dt * dt + velocity[ii] * dt;
  }

  // Weighting may be off again, normalize after calculation.
  normalize(out_data + 3);
  normalize(out_data + 6);
}

#if defined(USE_LD)
void SplinePoint::print(FILE *fd) const
{
  fprintf(fd, "pos: [ %1.2f ; %1.2f ; %1.2f ] fw: [ %1.2f ; %1.2f ; %1.2f ] up: [ %1.2f ; %1.2f ; %1.2f ]\n",
      m_data[0], m_data[1], m_data[2], m_data[3], m_data[4], m_data[5], m_data[6], m_data[7], m_data[8]);
}
#endif

/** \brief Spline class. */
class Spline
{
  private:
    /** Spline data. */
    SplinePoint m_points[MAX_SPLINE_PARTS];

    /** Number of current spline points. */
    unsigned m_num_points;

  public:
    /** \brief Fake constructor. */
    void init();

  public:
    /** \brief Add one point.
     *
     * @param px X position.
     * @param py Y position.
     * @param pz Z position.
     * @param fx X forward.
     * @param fy Y forward.
     * @param fz Z forward.
     * @param ux X up.
     * @param uy Y up.
     * @param uz Z up.
     * @param time Time.
     */
    void addPoint(int16_t px, int16_t py, int16_t pz, int8_t fx, int8_t fy, int8_t fz, int8_t ux, int8_t uy,
        int8_t uz, int8_t time);

    /** \brief Resolve position in time.
     *
     * @param time Time to resolve to.
     * @param out_data Destination data.
     */
    void resolve(float time, float *out_data) const;

    /** \brief Resolve position in time.
     *
     * Writes directly to the global variables.
     *
     * @param time Time to resolve to.
     */
    void resolve(float time) const;

#if defined(USE_LD)
  public:
    /** \param Print a point into a stream.
     *
     * @param fs Stream to print to.
     * @param idx Point index.
     */
    void printPoint(FILE *fd, unsigned idx) const;
#endif
};

void Spline::init()
{
  m_num_points = 0;
}

void Spline::addPoint(int16_t px, int16_t py, int16_t pz, int8_t fx, int8_t fy, int8_t fz, int8_t ux,
    int8_t uy, int8_t uz, int8_t time)
{
  m_points[m_num_points].init(px, py, pz, fx, fy, fz, ux, uy, uz, time);
  ++m_num_points;
}

void Spline::resolve(float time, float *out_data) const
{
  float velocity[9] = { 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f };
  unsigned ii;

  for(ii = 1; (ii < m_num_points); ++ii)
  {
    const SplinePoint &prev = m_points[ii - 1];
    const SplinePoint &next = m_points[ii];

    if((prev.getTime() <= time) && (next.getTime() >= time))
    {
      prev.evaluatePosition(next, time, velocity, out_data);
      return;
    }
    prev.evaluateVelocity(next, velocity);
  }
#if defined(USE_LD)
  std::cerr << "WARNING: spline does not extend to time " << time << std::endl;
#endif
}

void Spline::resolve(float time) const
{
  this->resolve(time, g_raycast);
}

#if defined(USE_LD)
void Spline::printPoint(FILE *fd, unsigned idx) const
{
  m_points[idx].print(fd);
}
#endif

/** Desert movement spline. */
Spline g_spline_desert;

/** Lava movement spline 1. */
Spline g_spline_lava;

/** Moelli movement spline 1. */
Spline g_spline_moelli_1;

/** Moelli movement spline 2. */
Spline g_spline_moelli_2;

/** Moelli movement spline 3. */
Spline g_spline_moelli_3;

/** Moelli movement spline 4. */
Spline g_spline_moelli_4;

/** Mountain movement spline. */
Spline g_spline_mountains;

/** Volcanic movement spline. */
Spline g_spline_volcanic;

//######################################
// Text ################################
//######################################

/** Maximum number of points per character. */
#define MAX_ARRAY_POINTS 768

/** Roundness fidelity. */
#define CHARACTER_FIDELITY 16

/** Character line width. */
#define CHARACTER_LINE_WIDTH 12.0f

/** \brief Character.
 *
 * Represents one renderable character as a line strip. Constructed in code.
 *
 * Character coordinate system is represented by the pen position being at
 * origo. Input coordinates are scaled so that int8_t [-100, 100] maps into
 * [2, 2].
 */
class Character
{
  private:
    /** Points. */
    float m_points[MAX_ARRAY_POINTS * 2];

    /** Point count. */
    unsigned m_num_points;

    /** \brief Character limits.
     *
     * 0: X minimum.
     * 1: Y minimum.
     * 2: X maximum.
     * 3: Y maximum.
     */
    float m_limits[4];

  public:
    /** \brief Accessor.
     *
     * @param Maximum X bound.
     */
    inline float getMaxX() const
    {
      return m_limits[2];
    }

    /** \brief Accessor.
     *
     * @param Maximum X bound.
     */
    inline float getMaxY() const
    {
      return m_limits[3];
    }

    /** \brief Accessor.
     *
     * @param Minimum X bound.
     */
    inline float getMinX() const
    {
      return m_limits[0];
    }

    /** \brief Accessor.
     *
     * @param Minimum Y bound.
     */
    inline float getMinY() const
    {
      return m_limits[1];
    }

  public:
    /** \brief Fake constructor. */
    void init();

  public:
    /** \brief Add a half-arc.
     *
     * The point is the center of the arc.
     *
     * @param px Starting point.
     * @param py Starting point.
     * @param rx Point at the radius of the arc, in the middle.
     * @param ry Point at the radius of the arc, in the middle.
     */
    void addArc(int8_t px, int8_t py, int8_t rx, int8_t ry);

    /** \brief Add a line.
     *
     * @param x1 First X coordinate.
     * @param y1 First Y coordinate.
     * @param x2 Second X coordinate.
     * @param y2 Second Y coordinate.
     */
    void addLine(int8_t x1, int8_t y1, int8_t x2, int8_t y2);

    /** \brief Feed a character into the GPU.
     *
     * @param prg Program to feed to.
     * @param params Parameters: x, y, scale, individual scale.
     */
    void feed(Program &prg, const float *params) const;

  private:
    /** \brief Add a fan.
     *
     * @param px Fan center X.
     * @param py Fan center Y.
     * @param dx Fan arc direction X.
     * @param dy Fan arc direction X.
     */
    void addFan(float px, float py, float dx, float dy);

    /** \brief Continue a point sequence.
     *
     * @param px X coordinate.
     * @param py Y coordinate.
     */
    void continueSequence(float px, float py);
};

void Character::init()
{
  m_num_points = 0;
  m_limits[0] = 0.0f;
  m_limits[1] = 0.0f;
  m_limits[2] = 0.0f;
  m_limits[3] = 0.0f;
}

void Character::addArc(int8_t px, int8_t py, int8_t rx, int8_t ry)
{
  float fx = static_cast<float>(px);
  float fy = static_cast<float>(py);
  float frx = static_cast<float>(rx) - fx;
  float fry = static_cast<float>(ry) - fy;
  float rlen = sqrtf(frx * frx + fry * fry);
  float dx = fry;
  float dy = -frx;

  this->addFan(fx + dx, fy + dy, -frx, -fry);
  this->addFan(fx - dx, fy - dy, -frx, -fry);

  frx /= rlen;
  fry /= rlen;
  dx /= rlen;
  dy /= rlen;

  {
    static const float ARC_MUL = static_cast<float>(M_PI) / static_cast<float>(CHARACTER_FIDELITY);
    unsigned ii;

    for(ii = 0; (ii < CHARACTER_FIDELITY); ++ii)
    {
      float angle1 = static_cast<float>(ii + 0) * ARC_MUL;
      float angle2 = static_cast<float>(ii + 1) * ARC_MUL;
      float c1 = cosf(angle1);
      float s1 = sinf(angle1);
      float c2 = cosf(angle2);
      float s2 = sinf(angle2);

      this->continueSequence(fx + (c1 * dx + s1 * frx) * (rlen - CHARACTER_LINE_WIDTH),
          fy + (c1 * dy + s1 * fry) * (rlen - CHARACTER_LINE_WIDTH));
      this->continueSequence(fx + (c1 * dx + s1 * frx) * (rlen + CHARACTER_LINE_WIDTH),
          fy + (c1 * dy + s1 * fry) * (rlen + CHARACTER_LINE_WIDTH));
      this->continueSequence(fx + (c2 * dx + s2 * frx) * (rlen - CHARACTER_LINE_WIDTH),
          fy + (c2 * dy + s2 * fry) * (rlen - CHARACTER_LINE_WIDTH));
      this->continueSequence(fx + (c2 * dx + s2 * frx) * (rlen - CHARACTER_LINE_WIDTH),
          fy + (c2 * dy + s2 * fry) * (rlen - CHARACTER_LINE_WIDTH));
      this->continueSequence(fx + (c1 * dx + s1 * frx) * (rlen + CHARACTER_LINE_WIDTH),
          fy + (c1 * dy + s1 * fry) * (rlen + CHARACTER_LINE_WIDTH));
      this->continueSequence(fx + (c2 * dx + s2 * frx) * (rlen + CHARACTER_LINE_WIDTH),
          fy + (c2 * dy + s2 * fry) * (rlen + CHARACTER_LINE_WIDTH));
    }
  }
}

void Character::addLine(int8_t x1, int8_t y1, int8_t x2, int8_t y2)
{
  float fx1 = static_cast<float>(x1);
  float fy1 = static_cast<float>(y1);
  float fx2 = static_cast<float>(x2);
  float fy2 = static_cast<float>(y2);
  float dx = fx2 - fx1;
  float dy = fy2 - fy1;
  float dlen = sqrtf(dx * dx + dy * dy);
  float rx;
  float ry;

  dx /= dlen;
  dy /= dlen;
  rx = dy * CHARACTER_LINE_WIDTH;
  ry = -dx * CHARACTER_LINE_WIDTH;

  this->addFan(fx1, fy1, -dx, -dy);
  this->addFan(fx2, fy2, dx, dy);

  this->continueSequence(fx1 - rx, fy1 - ry);
  this->continueSequence(fx1 + rx, fy1 + ry);
  this->continueSequence(fx2 - rx, fy2 - ry);
  this->continueSequence(fx2 - rx, fy2 - ry);
  this->continueSequence(fx1 + rx, fy1 + ry);
  this->continueSequence(fx2 + rx, fy2 + ry);
}

void Character::feed(Program &prg, const float *params) const
{
  prg.uniform4fv('R', m_limits); 
  prg.uniform4fv('S', params);
  prg.vertexAttribPointer2f('a', m_points);
  g_sym.glDrawArrays(GL_TRIANGLES, 0, static_cast<GLsizei>(m_num_points));
}

void Character::addFan(float px, float py, float dx, float dy)
{
  float dlen = sqrtf(dx * dx + dy * dy);
  float rx;
  float ry;

  dx = dx / dlen * CHARACTER_LINE_WIDTH;
  dy = dy / dlen * CHARACTER_LINE_WIDTH;

  rx = dy;
  ry = -dx;

  {
    static const float ARC_MUL = static_cast<float>(M_PI) / static_cast<float>(CHARACTER_FIDELITY);
    unsigned ii;
    
    for(ii = 0; (ii < CHARACTER_FIDELITY); ++ii)
    {
      float angle1 = static_cast<float>(ii + 0) * ARC_MUL;
      float angle2 = static_cast<float>(ii + 1) * ARC_MUL;
      float c1 = cosf(angle1);
      float s1 = sinf(angle1);
      float c2 = cosf(angle2);
      float s2 = sinf(angle2);

      this->continueSequence(px, py);
      this->continueSequence(px + c1 * rx + s1 * dx, py + c1 * ry + s1 * dy);
      this->continueSequence(px + c2 * rx + s2 * dx, py + c2 * ry + s2 * dy);
    }
  }
}

void Character::continueSequence(float px, float py)
{
#if defined(USE_LD)
  if(MAX_ARRAY_POINTS > m_num_points)
#endif
  {
    m_points[m_num_points * 2 + 0] = px;
    m_points[m_num_points * 2 + 1] = py;
    m_limits[0] = common::cfminf(px, m_limits[0]);
    m_limits[1] = common::cfminf(py, m_limits[1]);
    m_limits[2] = common::cfmaxf(px, m_limits[2]);
    m_limits[3] = common::cfmaxf(py, m_limits[3]);
    ++m_num_points;
  }
#if defined(USE_LD)
  else
  {
    std::cout << "WARNING: trying to add point index " << m_num_points << " into a point array" << std::endl;
  }
#endif
}

/** \brief Font class.
 */
class Font
{
  private:
    /** ASCII7 characters. */
    Character m_characters[128];

  public:
    /** \brief Fake constructor.
     */
    void init();

  public:
    /** \brief Get length of string.
     *
     * @param str String.
     */
    float calculateStringLength(const char *str) const;

    /** \brief Export text.
     *
     * @param prg Program.
     * @param str String to print.
     * @param scale General font scale.
     * @param individual_scale Individual scale of characters.
     * @param px Pen start position X.
     * @param py Pen start position Y.
     */
    void text(Program &prg, const char *str, float scale, float individual_scale, float px, float py) const;
};

void Font::init()
{
  static const int8_t font_data_lines[] =
  {
    ':', 0, 20, 0, 21,
    ':', 0, 80, 0, 79,
    '-', 0, 50, 30, 50,
    '1', 0, 80, 20, 100,
    '1', 20, 0, 20, 100,
    '2', 40, 80, 0, 0,
    '2', 40, 0, 0, 0,
    '3', 20, 50, 40, 20,
    '3', 20, 50, 40, 80,
    '4', 0, 30, 30, 100,
    '4', 30, 0, 30, 100,
    '4', 40, 30, 0, 30,
    '6', 0, 25, 0, 75,
    '6', 35, 100, 0, 75,
    'A', 0, 0, 30, 100,
    'A', 60, 0, 30, 100,
    'A', 10, 20, 50, 20,
    'B', 0, 0, 0, 100,
    'C', 0, 20, 0, 80,
    'D', 37, 0, 37, 100,
    'E', 0, 0, 0, 100,
    'E', 0, 0, 35, 0,
    'E', 0, 50, 35, 50,
    'E', 0, 100, 35, 100,
    'F', 0, 0, 0, 100,
    'F', 40, 100, 0, 100,
    'F', 35, 60, 0, 60,
    'G', 0, 20, 0, 80,
    'G', 40, 20, 40, 40,
    'G', 30, 40, 40, 40,
    'H', 0, 0, 0, 100,
    'H', 40, 0, 40, 100,
    'H', 0, 50, 40, 50,
    'I', 0, 0, 0, 65,
    'I', 0, 100, 0, 99,
    'L', 0, 0, 0, 100,
    'L', 0, 0, 35, 0,
    'K', 0, 0, 0, 100,
    'K', 0, 46, 50, 94,
    'K', 0, 50, 50, 0,
    'M', 0, 0, 0, 100,
    'M', 60, 0, 60, 100,
    'M', 0, 100, 30, 65,
    'M', 60, 100, 30, 65,
    'N', 0, 0, 0, 100,
    'N', 40, 0, 0, 100,
    'N', 40, 0, 40, 100,
    'O', 0, 25, 0, 75,
    'O', 50, 25, 50, 75,
    'P', 0, 0, 0, 100,
    'R', 0, 0, 0, 100,
    'R', 0, 35, 35, 0,
    'S', 0, 80, 40, 20,
    'T', 0, 100, 50, 100,
    'T', 25, 100, 25, 0,
    'U', 0, 25, 0, 100,
    'U', 50, 25, 50, 100,
    'V', 0, 100, 20, 0,
    'V', 40, 100, 20, 0,
    'W', 0, 100, 10, 0,
    'W', 10, 0, 25, 50,
    'W', 40, 0, 25, 50,
    'W', 40, 0, 50, 100,
    'X', 0, 100, 40, 0,
    'X', 0, 0, 40, 100,
    'Y', 0, 100, 20, 65,
    'Y', 40, 100, 20, 65,
    'Y', 20, 65, 20, 0
  };
  static const int8_t font_data_arcs[] =
  {
    '2', 20, 80, 20, 100,
    '3', 20, 80, 20, 100,
    '3', 20, 20, 20, 0,
    '6', 25, 25, 25, 0,
    '6', 25, 25, 25, 50,
    'B', 0, 37, 37, 37,
    'C', 20, 80, 20, 100,
    'C', 20, 20, 20, 0,
    'D', 37, 37, 0, 37,
    'G', 20, 80, 20, 100,
    'G', 20, 20, 20, 0,
    'O', 25, 25, 25, 0,
    'O', 25, 75, 25, 100,
    'P', 0, 63, 37, 63,
    'R', 0, 63, 37, 63,
    'S', 20, 80, 20, 100,
    'S', 20, 20, 20, 0,
    'U', 25, 25, 25, 0
  };

  for(unsigned ii = 0; (ii < 128); ++ii)
  {
    m_characters[ii].init();
  }
  for(unsigned ii = 0; (sizeof(font_data_lines) > ii); ii += 5)
  {
    m_characters[font_data_lines[ii + 0]].addLine(font_data_lines[ii + 1], font_data_lines[ii + 2],
        font_data_lines[ii + 3], font_data_lines[ii + 4]);
  }
  for(unsigned ii = 0; (sizeof(font_data_arcs) > ii); ii += 5)
  {
    m_characters[font_data_arcs[ii + 0]].addArc(font_data_arcs[ii + 1], font_data_arcs[ii + 2],
        font_data_arcs[ii + 3], font_data_arcs[ii + 4]);
  }
}

float Font::calculateStringLength(const char *str) const
{
  float ret = 0.0f;
  const char *it = str;

  for(;;)
  {
    char cc = *it;

    if(0 == cc)
    {
      break;
    }

    const Character &chr = m_characters[static_cast<int>(cc)];

    ret += chr.getMaxX() + CHARACTER_LINE_WIDTH * 3.0f;
    ++it;
  }

  return ret;
}

/** \brief Draw a string of text.
 *
 * @param prg Program.
 * @param str String.
 * @param scale Scale of the text.
 * @param px X position to start from.
 * @param py Y position to start from.
 */
void Font::text(Program &prg, const char *str, float scale, float individual_scale, float px, float py) const
{
  const char *it = str;

  for(;;)
  {
    char cc = *it;

    if(0 == cc)
    {
      break;
    }

    const Character &chr = m_characters[static_cast<int>(cc)];
    float params[4] = { px, py, scale, individual_scale };
#if 0
    float character_scale = scale * individual_scale;
    float cw_2 = (chr.getMaxX() - chr.getMinX()) * 0.5f * scale;
    float ch_2 = (chr.getMaxY() - chr.getMinY()) * 0.5f * scale;
    float cx = px + cw_2 + chr.getMinX() * scale;
    float cy = py + ch_2 + chr.getMinY() * scale;
    float rx = cx - cw_2 * individual_scale - chr.getMinX() * character_scale;
    float ry = cy - ch_2 * individual_scale - chr.getMinY() * character_scale;

    printf("px = %1.3f ; cw_2 = %1.3f ; cx = %1.3f ; rx = %1.3f\n", rx, cw_2, cx, rx);
    printf("limits: [ %1.3f ; %1.3f ; %1.3f ; %1.3f ]\n", chr.getMinX(), chr.getMinY(), chr.getMaxX(), chr.getMaxY());
    printf("params: [ %1.3f ; %1.3f ; %1.3f ; %1.3f ]\n", params[0], params[1], params[2], params[3]);
#endif

    // No check for valid char. Only draw what you have.
    chr.feed(prg, params);

    px += chr.getMaxX() * scale + CHARACTER_LINE_WIDTH * 3.0f * scale;

    ++it;
  }
}

/** Global font. */
Font g_font;

//######################################
// rand() ##############################
//######################################

/** Random number -op to op.
 *
 * @param op Limit.
 * @return Random number [-op, op[
 */
static float frand(float op)
{
  uint16_t ret = (uint16_t)(g_sym.rand() & 0xFFFF);
  return (float)*((int16_t*)&ret) / 32768.0f * op;
}

//######################################
// Music ###############################
//######################################

#if !defined(USE_LD)
#include "synth_verbatim.hpp"
#endif

/** \brief Update audio stream.
 *
 * This function cannot have extra attributes due to needing to comply with
 * the system ABI.
 *
 * @param userdata Not used.
 * @param stream Target stream.
 * @param len Number of bytes to write.
 */
static void audio_callback(void *userdata, Uint8 *stream, int len)
{
  (void)userdata;

  do {
	*(reinterpret_cast<int16_t*>(stream)) = *g_audio_position;
	stream += 2;
	++g_audio_position;
  } while(len -= 2);
}

/** SDL audio specification struct. */
static SDL_AudioSpec audio_spec =
{
  AUDIO_FREQUENCY,
  AUDIO_S16,
  AUDIO_CHANNELS,
  0,
#if defined(USE_LD)
  4096,
#else
  512, // Relatively low, but safe.
#endif
  0,
  0,
  audio_callback,
  NULL
};

//######################################
// Draw helpers ########################
//######################################

/** Maximum number of additional effects. */
#define MAX_ADDITIONAL_EFFECTS 3

/** \brief Shake & other crap -effect.
 *
 * Effects themselves determine what to do with this.
 */
struct AdditionalEffect
{
  /** \brief Effect data.
   *
   * Paired as start-end. Intensity will follow sinus curve along the difference.
   */
  uint8_t m_effect[MAX_ADDITIONAL_EFFECTS * 2];

  public:
    /** \brief Resolve effect intensity and count.
     *
     * Count, if written, will tell the number of effects before this one.
     *
     * @param time Input time.
     * @param out_count If non-null, write the number of effects parsed here.
     * @return Current intensity of effect.
     */
    float resolve(float ticks, float *out_count = NULL) const;
};

float AdditionalEffect::resolve(float ticks, float *out_count) const
{
  float count = 0.0f;
  unsigned ii;
  float intensity = 0.0f;

  for(ii = 0; (MAX_ADDITIONAL_EFFECTS * 2 > ii); ii += 2)
  {
    float prev = static_cast<float>(m_effect[ii + 0] * AUDIO_BYTERATE);
    float next = static_cast<float>(m_effect[ii + 1] * AUDIO_BYTERATE);

    //std::cout << "prev: " << prev << " next: " << next << " ticks: " << ticks << std::endl;

    if(ticks > prev)
    {
      if(ticks < next)
      {
        float sin_param = (ticks - prev) / (next - prev);

        intensity = sinf(sin_param * static_cast<float>(M_PI));

        count += sin_param;
        break;
      }
      count += 1.0f;
    }
  }

  if(NULL != out_count)
  {
    *out_count = count;
  }
  return intensity;
}

/** \brief Draw a full-screen rectangle.
 *
 * @param Program Program to use.
 * @param name Name to bind to.
 */
static void full_screen_rect(Program &program)
{
  program.enableVertexAttribArray('a');
  g_sym.glRects(-1, -1, 1, 1);
}

/** \brief Clear screen.
 *
 * @param alpha Alpha value to store.
 */
static void clear_screen(float alpha)
{
  g_sym.glClearColor(0.0f, 0.0f, 0.0f, alpha);
  g_sym.glClear(GL_COLOR_BUFFER_BIT);
}

/** \brief Generate a ZXY rotation matrix.
 *
 * @param rx Rotation x.
 * @param ry Rotation y.
 * @param rz Rotation z.
 * @param out_matrix Matrix to write into.
 * */
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

/** Desert effects. */
static const struct AdditionalEffect g_effect_desert =
{
  {
    15, 21,
    0xFF, 0xFF,
    0xFF, 0xFF
  }
};

/** \brief Apply desert program.
 *
 * @return Program object.
 */
static Program* use_program_desert(float ticks)
{
  Program *ret = &g_program_desert;

  ret->use();

#if defined(USE_LD)
  if(!g_flag_developer || (1 != g_last_effect))
#endif
  {
    float effect = g_effect_desert.resolve(ticks) * 0.017f;

    g_raycast[0] += frand(effect);
    g_raycast[1] += frand(effect);
    g_raycast[2] += frand(effect);

    generate_rotation_matrix_zxy(1.29f, -1.48f, -2.44f, g_rotation_matrix);
#if defined(USE_LD)
    g_noise_strength[0] = 0.079f;
    g_noise_strength[1] = 0.041f;
    g_noise_strength[2] = 0.037f;
    g_noise_scale[0] = 0.0027f;
    g_noise_scale[1] = 1.57f;
    g_noise_scale[2] = 1.83f;
    g_noise_substract = 0.18f;
#endif
  }

  ret->uniformMatrix3fv('M', g_rotation_matrix);
#if defined(USE_LD)
  ret->uniform4fv('S', g_noise_scale);
  ret->uniform4fv('R', g_noise_strength);
  ret->uniform1f('C', g_noise_substract);
#endif

  g_texture_strength.bind(*ret, 't', GL_TEXTURE0);
  g_volume_strength.bind(*ret, 'v', GL_TEXTURE1);

  return ret;
}

/** Lava effects. */
static const struct AdditionalEffect g_effect_lava =
{
  {
    19, 25,
    29, 33,
    33, 38
  }
};

/** \brief Apply lava program.
 *
 * @return Program object.
 */
static Program* use_program_lava(float ticks)
{
  Program *ret = &g_program_lava;

  ret->use();

#if defined(USE_LD)
  if(!g_flag_developer || (0 != g_last_effect))
#endif
  {
    float count;
    float effect = g_effect_lava.resolve(ticks, &count) * 0.009f;

    count = (count + (1.0f - cosf(static_cast<float>(M_PI) * effect)) * 0.5f) * (1.0f / 3.0f);

    g_raycast[0] += frand(effect);
    g_raycast[1] += frand(effect);
    g_raycast[2] += frand(effect);

    generate_rotation_matrix_zxy(pilerp(0.17f, 1.06f, count), pilerp(0.83f, 5.74f, count),
        pilerp(6.06f, 0.64f, count), g_rotation_matrix);
#if defined(USE_LD)
    g_noise_strength[0] = 2.09f;
    g_noise_strength[1] = 0.78f;
    g_noise_strength[2] = 0.045f;
    g_noise_strength[3] = -0.16f;
    g_noise_scale[0] = 0.011f;
    g_noise_scale[1] = 2.01f;
    g_noise_scale[2] = 2.03f;
    g_noise_scale[3] = 2.07f;
    g_noise_substract = 0.18f;
#endif
  }

  ret->uniformMatrix3fv('M', g_rotation_matrix);
#if defined(USE_LD)
  ret->uniform4fv('S', g_noise_scale);
  ret->uniform4fv('R', g_noise_strength);
  ret->uniform1f('C', g_noise_substract);
#endif

  g_volume_strength.bind(*ret, 'v', GL_TEXTURE0);
  g_volume_normal.bind(*ret, 'w', GL_TEXTURE1);

  return ret;
}

/** \brief Apply moelli program.
 *
 * @return Program object.
 */
static Program* use_program_moelli(float ticks)
{
  Program *ret = &g_program_moelli;

  ret->use();

#if defined(USE_LD)
  if(!g_flag_developer || (4 != g_last_effect))
#endif
  {
    generate_rotation_matrix_zxy(1.45f, 1.9f, 0.65f, g_rotation_matrix);
#if defined(USE_LD)
    g_noise_strength[0] = 0.66f;
    g_noise_strength[1] = 0.69f;
    g_noise_strength[2] = 0.29f;
    g_noise_scale[0] = 0.047f;
    g_noise_scale[1] = 2.01f;
    g_noise_scale[2] = 2.69f;
#endif
  }

  g_uniform_array[0] = ticks;

  ret->uniformMatrix3fv('M', g_rotation_matrix);
#if defined(USE_LD)
  ret->uniform4fv('S', g_noise_scale);
  ret->uniform4fv('R', g_noise_strength);
#endif
  ret->uniform1f('C', ticks * 0.00000071f);

  g_texture_moelli.bind(*ret, 't', GL_TEXTURE0);
  g_volume_strength.bind(*ret, 'v', GL_TEXTURE1);
  g_volume_normal.bind(*ret, 'w', GL_TEXTURE2);

  return ret;
}

/** Mountains effects. */
static const struct AdditionalEffect g_effect_mountains =
{
  {
    25, 34,
    0xFF, 0xFF,
    0xFF, 0xFF
  }
};

/** \brief Apply mountains program.
 *
 * @return Program object.
 */
static Program* use_program_mountains(float ticks)
{
  Program *ret = &g_program_mountains;

  ret->use();

#if defined(USE_LD)
  if(!g_flag_developer || (2 != g_last_effect))
#endif
  {
    float effect = g_effect_mountains.resolve(ticks) * 0.02f;

    g_raycast[0] += frand(effect);
    g_raycast[1] += frand(effect);
    g_raycast[2] += frand(effect);

    generate_rotation_matrix_zxy(1.0f, -1.0f, 1.5f, g_rotation_matrix);
#if defined(USE_LD)
    g_noise_strength[0] = 3.47f;
    g_noise_strength[1] = 0.66f;
    g_noise_strength[2] = -0.235f;
    g_noise_strength[3] = 0.19f;
    g_noise_scale[0] = 0.0027f;
    g_noise_scale[1] = 2.07f;
    g_noise_scale[2] = 2.91f;
    g_noise_scale[3] = 2.73f;
    g_noise_substract = 0.18f;
#endif
  }

  ret->uniformMatrix3fv('M', g_rotation_matrix);
#if defined(USE_LD)
  ret->uniform4fv('S', g_noise_scale);
  ret->uniform4fv('R', g_noise_strength);
  ret->uniform1f('C', g_noise_substract);
#endif

  g_volume_strength.bind(*ret, 'v', GL_TEXTURE0);
  g_volume_normal.bind(*ret, 'w', GL_TEXTURE1);

  return ret;
}

/** Volcanic effects. */
static const struct AdditionalEffect g_effect_volcanic =
{
  {
    13, 21,
    22, 28,
    0xFF, 0xFF
  }
};

/** \brief Apply volcanic program.
 *
 * @return Program object.
 */
static Program* use_program_volcanic(float ticks)
{
  Program *ret = &g_program_volcanic;

  ret->use();

#if defined(USE_LD)
  if(!g_flag_developer || (3 != g_last_effect))
#endif
  {
    float effect = g_effect_volcanic.resolve(ticks) * 0.02f;

    g_raycast[0] += frand(effect);
    g_raycast[1] += frand(effect);
    g_raycast[2] += frand(effect);

    g_uniform_array[0] = common::cfmaxf(ticks - static_cast<float>(AUDIO_BYTERATE * 22), 0.0f);
    generate_rotation_matrix_zxy(0.37f, -0.88f, -2.99f, g_rotation_matrix);
#if defined(USE_LD)
    g_noise_strength[0] = 2.33f;
    g_noise_strength[1] = 0.617f;
    g_noise_strength[2] = -0.213f;
    g_noise_scale[0] = 0.0099f;
    g_noise_scale[1] = 2.01f;
    g_noise_scale[2] = 2.03f;
    g_noise_substract = 0.18f;
#endif
  }

  ret->uniformMatrix3fv('M', g_rotation_matrix);
#if defined(USE_LD)
  ret->uniform4fv('S', g_noise_scale);
  ret->uniform4fv('R', g_noise_strength);
  ret->uniform1f('C', g_noise_substract);
#endif

  g_volume_strength.bind(*ret, 'v', GL_TEXTURE0);
  g_volume_normal.bind(*ret, 'w', GL_TEXTURE1);

  return ret;
}

/** \brief Render fading pop-up text.
 *
 * @param ftime Current time.
 * @param str String to render.
 * @param px Render location X.
 * @param py Render location Y.
 * @param duration Text duration.
 * @param fade Fade time.
 * @param scale text scale.
 * @param enlarge Text enlargment in/out.
 * @param color Color.
 */
static void render_fade_text(float ftime, const char *str, float px, float py, float duration, float fade,
    float scale, float enlarge, GLfloat *color)
{
  if((ftime > duration) || (0.0f > ftime))
  {
    return;
  }

  float alpha_mul = 1.0f;

  if(ftime <= fade)
  {
    alpha_mul = 1.0f - (fade - ftime) / fade;
    enlarge = 1.0f + enlarge * (1.0f - alpha_mul);
  }
  else if(duration - fade <= ftime)
  {
    alpha_mul = (duration - ftime) / fade;
    enlarge = 1.0f - enlarge * (1.0f - alpha_mul);
  }
  else
  {
    enlarge = 1.0f;
  }

  //printf("text: '%s' ; scale: %1.3f ; enlarge: %1.3f ; alpha_mul: %1.3f ; [ %1.3f ; %1.3f ]\n",
  //    str, scale, enlarge, alpha_mul, px, py);

  color[3] *= alpha_mul;

  g_program_text.uniform4fv('C', color);
  g_font.text(g_program_text, str, scale, enlarge, px, py);
}

/** \brief Render credits text.
 *
 * @param ftime Floating point time.
 */
static void render_text_credits(float ftime)
{
  static const char *credits[] =
  {
    "CODE: TRILKK",
    "SYNTH: COLLATERALBURGER",
    "ADDITIONAL CODE: WARMA",
    NULL
  };

  clear_screen(0.0f);
  {
    static const float DURATION = 2.5f * static_cast<float>(AUDIO_BYTERATE);
    float itime = ftime - static_cast<float>(AUDIO_BYTERATE * 18);
    const char **current_credit = credits;

    do {
      GLfloat color[] = { 0.0f, 0.0f, 0.0f, 0.67f };
      float slen = g_font.calculateStringLength(*current_credit) * 0.0014f;

      render_fade_text(itime, *current_credit, 1.67f - itime * 0.00000027f - slen, 0.24f, DURATION,
          0.75f * static_cast<float>(AUDIO_BYTERATE), 0.0014f, 0.3f, color);

      itime -= DURATION;
    } while(*(++current_credit));
  }
}

/** \brief Render greets text.
 *
 * @param ftime Floating point time.
 */
static void render_text_greets(float ftime)
{
  static const char *greets[] =
  {
    "GREETS:",
    "ADF",
    "BLOBTROX",
    "FIT",
    "HEDELMAE",
    "LONELY CODERS",
    "TDA",
    "TEKOTUOTANTO",
    "TRACTION",
    NULL
  };

  clear_screen(0.0f);
  {
    static const float DURATION = 1.6f * static_cast<float>(AUDIO_BYTERATE);
    float itime = ftime - static_cast<float>(AUDIO_BYTERATE * 8);
    const char **current_greet = greets;

    do {
      GLfloat color[] = { 0.0f, 0.0f, 0.0f, 0.67f };
      float slen = g_font.calculateStringLength(*current_greet) * 0.0017f;

      render_fade_text(itime, *current_greet, 1.67f - itime * 0.00000039f - slen, 0.18f, DURATION,
          0.5f * static_cast<float>(AUDIO_BYTERATE), 0.0017f, 0.2f, color);

      itime -= DURATION;
    } while(*(++current_greet));
  }
}

/** \brief Render info text.
 *
 * @param ftime Floating point time.
 */
static void render_text_info(float ftime)
{
  static const char *info[] =
  {
    "LAVOS: A FREEBSD-IA32 16K INTRO",
    "LARGER ON OTHER PLATFORMS",
    "FAEMIYAH 2O14-O3",
    NULL
  };

  ftime = (ftime - static_cast<float>(AUDIO_BYTERATE * 2)) / (static_cast<float>(AUDIO_BYTERATE * 8));
  clear_screen(ftime * ftime);
  ftime -= 0.2f;
  {
    float py = 0.75f;
    const char **current_info = info;

    do {
      GLfloat color[] = { 1.0f, 1.0f, 1.0f, 0.33f };

      render_fade_text(ftime, *current_info, -1.6f, py, 0.8f, 0.08f, 0.0008f, 0.3f, color);

      py -= 0.18f;
      ftime -= 0.02f;
    } while(*(++current_info));
  }
}

//######################################
// Main draw ###########################
//######################################

/** Program function type. */
typedef Program* (*ProgramFunc)(float);

/** \brief Direction struct.
 *
 * This struct only controls scene and path selection and fades.
 * Further effects are in the specific programs.
 */
struct Direction
{
  /** Scene callback to use. */
  ProgramFunc m_program;

  /** Spline to use. */
  Spline* m_spline;

  /** Fade time in. */
  unsigned m_fade_time_in;

  /** Fade time out. */
  unsigned m_fade_time_out;

  /** Effect start time (to offset spline traversal). */
  uint8_t m_start_time;

  /** Effect time. */
  uint8_t m_time;

  public:
    /** \brief Accessor.
     *
     * @return Fade time.
     */
    inline unsigned getFadeTimeIn() const
    {
      return m_fade_time_in;
    }

    /** \brief Accessor.
     *
     * @return Fade time.
     */
    inline unsigned getFadeTimeOut() const
    {
      return m_fade_time_out;
    }

    /** \brief Accessor.
     *
     * @return Program.
     */
    inline ProgramFunc getProgram() const
    {
      return m_program;
    }

    /** \brief Accessor.
     *
     * @return Spline.
     */
    inline Spline* getSpline() const
    {
      return m_spline;
    }

    /** \brief Accessor.
     *
     * @return Start time.
     */
    inline unsigned getStartTime() const
    {
      return static_cast<unsigned>(m_start_time) * AUDIO_BYTERATE;
    }

    /** \brief Accessor.
     *
     * @return Duration time.
     */
    inline unsigned getTime() const
    {
      return static_cast<unsigned>(m_time) * AUDIO_BYTERATE;
    }
};

/** Complete direction. */
static const struct Direction g_regie[] =
{
  {
    use_program_lava,
    &g_spline_lava,
    0,
    AUDIO_BYTERATE / 4,
    0,
    17
  },
  {
    use_program_desert,
    &g_spline_desert,
    AUDIO_BYTERATE * 2,
    AUDIO_BYTERATE * 3,
    5,
    25
  },
  {
    use_program_lava,
    &g_spline_lava,
    AUDIO_BYTERATE,
    AUDIO_BYTERATE * 2,
    17,
    16
  },
  {
    use_program_mountains,
    &g_spline_mountains,
    AUDIO_BYTERATE / 2,
    AUDIO_BYTERATE / 2,
    4,
    25
  },
  {
    use_program_lava,
    &g_spline_lava,
    AUDIO_BYTERATE,
    AUDIO_BYTERATE * 2,
    17 + 16,
    16
  },
  {
    use_program_volcanic,
    &g_spline_volcanic,
    AUDIO_BYTERATE * 3 / 2,
    AUDIO_BYTERATE,
    8,
    20
  },
  {
    use_program_moelli,
    &g_spline_moelli_1,
    AUDIO_BYTERATE * 2 / 5,
    AUDIO_BYTERATE * 2 / 5,
    3,
    6
  },
  {
    use_program_moelli,
    &g_spline_moelli_2,
    AUDIO_BYTERATE * 2 / 5,
    AUDIO_BYTERATE * 2 / 5,
    3,
    12
  },
  {
    use_program_moelli,
    &g_spline_moelli_3,
    AUDIO_BYTERATE * 2 / 5,
    AUDIO_BYTERATE * 2 / 5,
    1,
    6
  },
  {
    use_program_moelli,
    &g_spline_moelli_4,
    AUDIO_BYTERATE * 2 / 5,
    0,
    2,
    255, // Forever?
  }
};

/** \brief Draw the world.
 *
 * @param ms Milliseconds.
 */
static void draw(unsigned ticks)
{
  Program *program;
  Spline *spline;
  GLint current_fbo_width;
  GLint current_fbo_height;
  float ftime;

#if 0
  printf("ticks: %u || diff: %u || cap: %u || FBO: %i ; %i\n", g_uniform_array[0], ticks - last_ticks,
      (AUDIO_BYTERATE / DESIRED_FRAMERATE), fbo_use_width, fbo_use_height);
#endif

#if 0 // Adaptive size turned off for now.
  static GLsizei fbo_use_width = g_screen_w;
  static GLsizei fbo_use_height = g_screen_h;
  static Uint32 last_ticks = ticks;
  if((ticks - last_ticks) > (AUDIO_BYTERATE / DESIRED_FRAMERATE * 9 / 8))
  {
    GLsizei new_width = fbo_use_width - 8;
    fbo_use_width = (new_width < 320) ? 320 : new_width;
  }
  else
  {
    GLsizei new_width = fbo_use_width + 8;
    fbo_use_width = (new_width > g_screen_w) ? g_screen_w : new_width;
  }
  fbo_use_height = (fbo_use_width * g_screen_h) / g_screen_w;
  last_ticks = ticks;
#endif

  // Raycast phase.
  {
    float fbo_multiplier = 1.0f;

#if defined(USE_LD)
    if(g_flag_developer)
    {
      switch(g_effect)
      {
        case 4:
          program = use_program_moelli(g_uniform_array[0]);
          break;

        case 3:
          program = use_program_volcanic(g_uniform_array[0]);
          break;

        case 2:
          program = use_program_mountains(g_uniform_array[0]);
          break;

        case 1:
          program = use_program_desert(g_uniform_array[0]);
          break;

        case 0:
        default:
          program = use_program_lava(g_uniform_array[0]);
          break;
      }
      g_last_effect = g_effect;
      ftime = g_uniform_array[0];
      spline = NULL;
    }
    else
#endif
    {
      const Direction *regie = g_regie;
      ProgramFunc prg_func;
      unsigned current_scene_time;

      for(;;)
      {
        current_scene_time = regie->getTime();

        if(ticks <= current_scene_time)
        {
          break;
        }

        ticks -= current_scene_time;
        ++regie;
      }

      ftime = static_cast<float>(ticks + regie->getStartTime());
      spline = regie->getSpline();

      spline->resolve(ftime);
      prg_func = regie->getProgram();
      program = prg_func(ftime);

      // Fade in and out.
      if(regie->getFadeTimeIn() > ticks)
      {
        fbo_multiplier = static_cast<float>(ticks) / static_cast<float>(regie->getFadeTimeIn());
      }
      else
      {
        unsigned out_time = current_scene_time - ticks;

        if(regie->getFadeTimeOut() > out_time)
        {
          fbo_multiplier = static_cast<float>(out_time) / static_cast<float>(regie->getFadeTimeOut());
        }
      }
    }
 
    current_fbo_width = common::clrintf(static_cast<float>(g_screen_w) * fbo_multiplier);
    current_fbo_height = common::clrintf(static_cast<float>(g_screen_h) * fbo_multiplier);

    g_fbo_quad.bind(current_fbo_width, current_fbo_height);

    // Time has already been written if necessary.
    g_uniform_array[1] = static_cast<float>(current_fbo_width);
    g_uniform_array[2] = static_cast<float>(current_fbo_height);
    g_uniform_array[3] = 1.0f;

#if 0
    printf("r: %i, p: %i, f: %i, u: %i\n",
        prg->getUniform('r'), prg->getUniform('p'), prg->getUniform('f'), prg->getUniform('u'));

    printf("r: %1.1f, %1.1f, %1.1f, %1.1f\n", g_uniform_array[0], g_uniform_array[1], g_uniform_array[2],
        g_uniform_array[3]);

    printf("p: [%1.1f ; %1.1f ; %1.1f], f: [%1.1f ; %1.1f ; %1.1f], u: [%1.1f ; %1.1f ; %1.1f]\n",
        g_position[0], g_position[1], g_position[2],
        g_forward[0], g_forward[1], g_forward[2],
        g_up[0], g_up[1], g_up[2]);
#endif

    program->uniform4fv('r', g_uniform_array);
    program->uniform3fv('p', g_raycast + 0);
    program->uniform3fv('f', g_raycast + 3);
    program->uniform3fv('u', g_raycast + 6);

    full_screen_rect(*program);

    g_fbo_quad.unbind();
  }

  // Text phase (if applicable).
  {
    g_program_text.use();
    g_program_text.uniform4fv('r', g_uniform_array);
    g_fbo_text.bind();

    if(&g_program_desert == program)
    {
      render_text_greets(ftime);
    }
    else if(&g_program_mountains == program)
    {
      render_text_credits(ftime);
    }
    else if((&g_program_moelli == program) && (&g_spline_moelli_4 == spline))
    {
      render_text_info(ftime);
    }
    else
    {
      clear_screen(0.0f);
    }

    /*g_sym.glVertexAttribPointer(static_cast<GLuint>(g_program_text.getAttribute('a')), 2, GL_FLOAT, GL_FALSE,
        0, data);
    g_sym.glUniform2fv(g_program_text.getUniform('r'), 1, g_uniform_array + 1);

    g_sym.glDrawArrays(GL_LINES, 0, 2);*/

    g_fbo_text.unbind();
  }

  // FBO blit phase.
  {
    g_program_fbo.use();

    g_uniform_array[1] /= static_cast<float>(g_screen_w);
    g_uniform_array[2] /= static_cast<float>(g_screen_h);

    g_program_fbo.uniform4fv('r', g_uniform_array);

    g_fbo_quad.bindTexture(g_program_fbo, 't', GL_TEXTURE0);
    g_fbo_text.bindTexture(g_program_fbo, 'T', GL_TEXTURE1);

    full_screen_rect(g_program_fbo);
  }
}

//######################################
// Misc ################################
//######################################

/** \brief Fill the random data array. */
static void fill_random()
{
  {
    unsigned ii = VOLUME_STRENGTH_SIDE * VOLUME_STRENGTH_SIDE * VOLUME_STRENGTH_SIDE;
    int8_t *volumeiter = g_data_random;
    do {
      *volumeiter++ = (int8_t)g_sym.rand();
    } while(--ii);
  }
}

/** \brief Fill the mölli data arrays. */
static void moelli_init()
{
  unsigned ii;
  unsigned jj;
  unsigned kk;
  unsigned counter=0;
  float temp;
  float temp1;
  float temp2;
  float x;
  float y;
  float z;

  // Beginning of texture generation.
  // First create an uniform distribution of points on ball surface, algorithm from Marsaglia (1972).
  while((MOELLI_SPIKE_NUM - MOELLI_CUSTOM_POS_SPIKES - MOELLI_CUSTOM_NEG_SPIKES) > counter)
  {
    temp1 = frand(2.0f);
    temp2 = frand(2.0f);
    temp = temp1 * temp1 + temp2 * temp2;
    if(temp < 1.0f)
    {
      x = 2.0f * temp1 * sqrtf(1.0f - temp);
      y = 2.0f * temp2 * sqrtf(1.0f - temp);
      z = 1.0f - 2.0f * temp;
      g_moelli_spike_c[counter * 3 + 0] = x;
      g_moelli_spike_c[counter * 3 + 1] = y;
      g_moelli_spike_c[counter * 3 + 2] = z;
      counter++;
    }
  }

  // Map points to dots in the texture matrices, as pseudo as possible.
  for(ii=0; ii<counter; ii++)
  {
    x = g_moelli_spike_c[ii * 3 + 0];
    y = g_moelli_spike_c[ii * 3 + 1];
    z = g_moelli_spike_c[ii * 3 + 2];
    g_moelli_spike_ll[ii * 3 + 0] = g_sym.acosf(z / sqrtf(x * x + y * y + z * z));
    g_moelli_spike_ll[ii * 3 + 1] = atan2f(y, x);
    // Randomize point intensity a bit
    float mul = (frand(0.5f) + 0.5f) * MOELLI_ANGULAR_SCALE_VARIANCE *
      fabsf(common::cfminf(1.0f, common::cfmaxf(2.0f * z + 0.05f, -2.0f)));
    g_moelli_spike_ll[ii * 3 + 2] = -0.1f + mul;
  }

  static const int16_t customspikecoords[] =
  {
    157+0,  -40, -5,
    157-10, -30, -5,
    157-15, -20, -5,
    157-18, -10, -5,
    157-20, 0,   -5,
    157-18, 10,  -5,
    157-15, 20,  -5,
    157-10, 30,  -5,
    157+0,  40,  -5,
    157+0,  -15, 0, 
    157+0,  15,  0,
    157-3,  -7,  0, 
    157-3,  7,   0,
    157+4,  0,   0, 
    157-4,  0,   0,
    157+3,  -7,  0, 
    157+3,  7,   0
  };

  for(ii=0; ii<3*(MOELLI_CUSTOM_POS_SPIKES+MOELLI_CUSTOM_NEG_SPIKES); ii++)
  {
    g_moelli_spike_ll[counter*3+ii] = 0.01f*(float)(customspikecoords[ii]); // juus tis för int16_t
  }

#if 0
  for(ii = 0; (ii < MOELLI_SPIKE_NUM); ii++)
  {
    printf("Spike %i: %f %f %f\n", ii, g_moelli_spike_ll[ii * 3 + 0], g_moelli_spike_ll[ii * 3 + 1],
        g_moelli_spike_ll[ii * 3 + 2]);
  }
#endif

  // Fill the mölli texture with el data
  for(ii = 0; (ii < TEXTURE_MOELLI_SIDE); ii++)
  {
    float fii = static_cast<float>(ii);

    for(jj = 0; (jj < TEXTURE_MOELLI_SIDE); jj++)
    {
      static const float MOELLI_SIDE_F = static_cast<float>(TEXTURE_MOELLI_SIDE);
      float fjj = static_cast<float>(jj);

      // temp1 latitude, temp2 longtitude
      temp1 = static_cast<float>(M_PI) * fii / MOELLI_SIDE_F;
      temp2 = 2.0f * static_cast<float>(M_PI) * fjj / MOELLI_SIDE_F - static_cast<float>(M_PI);

      // Go through the spike matrix and calculate angular distance, start from
      // 2*PI, which is more than the maximum angular distance.
      float dist_f = 2.0f * static_cast<float>(M_PI);
      float dist_f_neg = 2.0f * static_cast<float>(M_PI);

      for(kk = 0; (kk < MOELLI_SPIKE_NUM - MOELLI_CUSTOM_NEG_SPIKES); kk++)
      {
        float x1;
        float x2;
        float y1;
        float y2;
        float z1;
        float z2;
        float alpha;
        
        x1 = sinf(temp1) * cosf(temp2);
        x2 = sinf(g_moelli_spike_ll[kk * 3 + 0]) * cosf(g_moelli_spike_ll[kk * 3 + 1]);
        y1 = sinf(temp1) * sinf(temp2);
        y2 = sinf(g_moelli_spike_ll[kk * 3 + 0]) * sinf(g_moelli_spike_ll[kk * 3 + 1]);
        z1 = cosf(temp1);
        z2 = cosf(g_moelli_spike_ll[kk * 3 + 0]);

        alpha = g_sym.acosf(x1 * x2 + y1 * y2 + z1 * z2) - g_moelli_spike_ll[kk * 3 + 2];
        if(alpha < dist_f)
        {
          dist_f = alpha;
        }
      }
      for(kk = MOELLI_SPIKE_NUM - MOELLI_CUSTOM_NEG_SPIKES; (kk < MOELLI_SPIKE_NUM); kk++)
      {
        float x1;
        float x2;
        float y1;
        float y2;
        float z1;
        float z2;
        float alpha;

        x1 = sinf(temp1) * cosf(temp2);
        x2 = sinf(g_moelli_spike_ll[kk * 3 + 0]) * cosf(g_moelli_spike_ll[kk * 3 + 1]);
        y1 = sinf(temp1) * sinf(temp2);
        y2 = sinf(g_moelli_spike_ll[kk * 3 + 0]) * sinf(g_moelli_spike_ll[kk * 3 + 1]);
        z1 = cosf(temp1);
        z2 = cosf(g_moelli_spike_ll[kk * 3 + 0]);

        alpha = g_sym.acosf(x1 * x2 + y1 * y2 + z1 * z2) - g_moelli_spike_ll[kk * 3 + 2];
        if(alpha < dist_f_neg)
        {
          dist_f_neg = alpha;
        }
      }

      // Since the texture generation is in-place for each texture pixel, we
      // can immediately make calculations for it.
      // Outward spike.
      float spike_o = MOELLI_SPIKE_HEIGHT * common::cfmaxf(MOELLI_ANGULAR_SCALE - dist_f, 0);
      // Inward spike.
      float spike_i = MOELLI_SPIKE_HEIGHT * common::cfmaxf(MOELLI_ANGULAR_SCALE - dist_f_neg, 0);

      //dist_f = (spike_o+spike_i)*MOELLI_SPIKE_HEIGHT;
      //dist_f = spike_o+spike_i;
      dist_f = spike_o - spike_i;

      // dist_f = fmaxf(MOELLI_ANGULAR_SCALE-dist_f,0);
      // normalize found distance to scale and insert it into the texture
      uint16_t dist_i = static_cast<uint16_t>(32767 + common::clrintf(65535.0f / static_cast<float>(M_PI) * dist_f));
      g_data_moelli_texture[jj * TEXTURE_MOELLI_SIDE + ii] = dist_i;
    }
  }

  // Katotaans mitä tuli
#if defined(USE_LD) && 0
  uint8_t *kuvadata = new uint8_t[TEXTURE_MOELLI_SIDE*TEXTURE_MOELLI_SIDE];
  for(ii=0; ii<TEXTURE_MOELLI_SIDE*TEXTURE_MOELLI_SIDE; ii++) {
    kuvadata[ii] = (uint8_t)(g_data_moelli_texture[ii]/256);
  }
  gfx::image_png_save("vittutekstuuri.png", TEXTURE_MOELLI_SIDE, TEXTURE_MOELLI_SIDE, 8, kuvadata);
#endif
}

//######################################
// Main ################################
//######################################

#if defined(USE_LD)
int intro(unsigned screen_w, unsigned screen_h, uint8_t flag_developer, uint8_t flag_fullscreen,
    uint8_t flag_record)
{
#else
/** Required ELF symbol. */
void *environ EXTERNALLY_VISIBLE;

/** Required ELF symbol. */
void *__progname EXTERNALLY_VISIBLE;

/** \cond */
#define flag_developer 0
#define flag_fullscreen 0
/** \endcond */

/** \brief Object file starting point. */
extern "C" void _start() EXTERNALLY_VISIBLE;
void _start()
{
#endif
#if defined(USE_LD)
  uint32_t starttick;

  g_screen_w = static_cast<GLsizei>(screen_w);
  g_screen_h = static_cast<GLsizei>(screen_h);
#endif

  init(static_cast<int>(g_screen_w), static_cast<int>(g_screen_h), flag_fullscreen);
  g_sym.SDL_ShowCursor(flag_developer);

#if defined(USE_LD)
  g_flag_developer = flag_developer;
  if(!g_flag_developer)
#endif
  {
    synth::generate_audio(g_audio_buffer, INTRO_LENGTH);
  }

  g_shader_vertex_quad.init(g_shader_code_vertex_quad);
  g_shader_fragment_desert.init(g_shader_code_fragment_quad_input);
  g_shader_fragment_lava.init(g_shader_code_fragment_quad_input);
  g_shader_fragment_moelli.init(g_shader_code_fragment_quad_input);
  g_shader_fragment_mountains.init(g_shader_code_fragment_quad_input);
  g_shader_fragment_volcanic.init(g_shader_code_fragment_quad_input);
  g_shader_vertex_text.init(g_shader_code_vertex_text);
  g_shader_fragment_text.init(g_shader_code_fragment_text);
  g_shader_vertex_fbo.init(g_shader_code_vertex_fbo);
  g_shader_fragment_fbo.init(g_shader_code_fragment_fbo);
  g_shader_fragment_desert.addPart(g_shader_code_fragment_desert_f);
  g_shader_fragment_desert.addPart(g_shader_code_fragment_quad_g);
  g_shader_fragment_desert.addPart(g_shader_code_fragment_desert_s);
  g_shader_fragment_desert.addPart(g_shader_code_fragment_quad_main);
  g_shader_fragment_lava.addPart(g_shader_code_fragment_lava_f);
  g_shader_fragment_lava.addPart(g_shader_code_fragment_quad_g);
  g_shader_fragment_lava.addPart(g_shader_code_fragment_lava_s);
  g_shader_fragment_lava.addPart(g_shader_code_fragment_quad_main);
  g_shader_fragment_moelli.addPart(g_shader_code_fragment_moelli_f);
  g_shader_fragment_moelli.addPart(g_shader_code_fragment_quad_g);
  g_shader_fragment_moelli.addPart(g_shader_code_fragment_moelli_s);
  g_shader_fragment_moelli.addPart(g_shader_code_fragment_quad_main);
  g_shader_fragment_mountains.addPart(g_shader_code_fragment_mountains_f);
  g_shader_fragment_mountains.addPart(g_shader_code_fragment_quad_g);
  g_shader_fragment_mountains.addPart(g_shader_code_fragment_mountains_s);
  g_shader_fragment_mountains.addPart(g_shader_code_fragment_quad_main);
  g_shader_fragment_volcanic.addPart(g_shader_code_fragment_volcanic_f);
  g_shader_fragment_volcanic.addPart(g_shader_code_fragment_quad_g);
  g_shader_fragment_volcanic.addPart(g_shader_code_fragment_volcanic_s);
  g_shader_fragment_volcanic.addPart(g_shader_code_fragment_quad_main);
  g_program_desert.init(g_shader_vertex_quad, g_shader_fragment_desert);
  g_program_lava.init(g_shader_vertex_quad, g_shader_fragment_lava);
  g_program_moelli.init(g_shader_vertex_quad, g_shader_fragment_moelli);
  g_program_mountains.init(g_shader_vertex_quad, g_shader_fragment_mountains);
  g_program_volcanic.init(g_shader_vertex_quad, g_shader_fragment_volcanic);
  g_program_text.init(g_shader_vertex_text, g_shader_fragment_text);
  g_program_fbo.init(g_shader_vertex_fbo, g_shader_fragment_fbo);

  g_sym.srand(29);
  fill_random();
  g_texture_strength.init(GL_R8, TEXTURE_STRENGTH_SIDE, GL_RED, GL_BYTE, g_data_random);
  fill_random();
  g_volume_strength.init(GL_R8, VOLUME_STRENGTH_SIDE, GL_RED, GL_BYTE, g_data_random);
  fill_random();
  g_volume_normal.init(GL_RGB8_SNORM, VOLUME_NORMAL_SIDE, GL_RGB, GL_BYTE, g_data_random);
  moelli_init();
  g_texture_moelli.init(GL_R16, TEXTURE_MOELLI_SIDE, GL_RED, GL_UNSIGNED_SHORT, g_data_moelli_texture);

  g_sym.glDisable(GL_DEPTH_TEST);
  g_sym.glDisable(GL_BLEND);

  g_fbo_quad.init(1);
  g_fbo_text.init(1);

  g_spline_lava.init();
  g_spline_desert.init();
  g_spline_mountains.init();
  g_spline_volcanic.init();
  g_spline_moelli_1.init();
  g_spline_moelli_2.init();
  g_spline_moelli_3.init();
  g_spline_moelli_4.init();
  g_spline_lava.addPoint(-52, 25, 22, 34, -52, -110, 6, 115, -53, 0);
  g_spline_lava.addPoint(17, -73, -211, 74, 9, -102, -22, 124, -5, 11);
  g_spline_lava.addPoint(154, -18, -362, 101, 73, 19, -68, 102, -28, 21);
  g_spline_lava.addPoint(355, 108, -478, 63, 29, 108, -34, 122, -2, 38);
  g_spline_lava.addPoint(366, 118, -489, 63, 39, 108, -34, 122, -2, 39);
  g_spline_lava.addPoint(7, 24508, 24551, 21, 74, 76, -2, 80, -46, 60);
  g_spline_desert.addPoint(442, -192, 1811, 55, 6, -114, -6, 126, 4, 0);
  g_spline_desert.addPoint(2359, -77, -929, 77, -10, -88, 8, 125, -20, 17);
  g_spline_desert.addPoint(2483, -71, -1277, 122, -11, 34, 6, 122, -32, 19);
  g_spline_desert.addPoint(4610, -81, 195, 97, 0, 81, 19, 123, 23, 30);
  g_spline_mountains.addPoint(-265, 637, 1516, 30, -60, -107, 6, 111, -60, 0);
  g_spline_mountains.addPoint(-80, 188, -385, 70, -26, -102, -2, 122, -33, 10);
  g_spline_mountains.addPoint(87, 223, -2215, -40, 0, -120, -10, 126, 3, 20);
  g_spline_mountains.addPoint(1206, 27, -5553, 49, -10, -116, -39, 117, -27, 30);
  g_spline_volcanic.addPoint(-338, 184, 577, -26, 3, -124, 0, 126, 3, 0);
  g_spline_volcanic.addPoint(-401, 67, -158, 43, 29, -115, -6, 123, 29, 20);
  g_spline_volcanic.addPoint(-381, 88, -249, 36, 16, 4, -17, 123, 14, 22);
  g_spline_volcanic.addPoint(-541, 101, -497, 36, 16, -4, -27, 123, 14, 29);
  g_spline_moelli_1.addPoint(84, -127, 38, -70, 102, -50, 42, 80, 88, 0);
  g_spline_moelli_1.addPoint(147, 27, 5, -122, 7, -29, -30, 108, 58, 12);
  g_spline_moelli_2.addPoint(-133, 38, -2, 118, -45, -4, 43, 116, -24, 0);
  g_spline_moelli_2.addPoint(-59, 21, 145, 67, -24, -104, -5, 122, -31, 16);
  g_spline_moelli_3.addPoint(53, -99, 157, -24, 76, -98, 0, 100, 78, 0);
  g_spline_moelli_3.addPoint(-51, -54, 178, 75, 46, -91, -3, 114, 55, 8);
  g_spline_moelli_4.addPoint(314, 249, -104, -90, -79, 40, -87, 65, -64, 0);
  g_spline_moelli_4.addPoint(191, 252, 195, -49, -85, -79, -83, 86, -40, 11);

  g_font.init();

#if defined(USE_LD)
  if(flag_record)
  {
    SDL_Event event;
    unsigned frame_idx = 0;

    // audio
    SDL_PauseAudio(1);

    write_audio_callback(g_audio_buffer, (unsigned)INTRO_LENGTH);

    // video
    for(;;)
    {
      unsigned ticks = static_cast<unsigned>(
          static_cast<double>(frame_idx) / 60.0 * static_cast<double>(AUDIO_BYTERATE));

      if(ticks > INTRO_LENGTH)
      {
        break;
      }

      if(SDL_PollEvent(&event) && (event.type == SDL_KEYDOWN) && (event.key.keysym.sym == SDLK_ESCAPE))
      {
        break;
      }

      draw(ticks);
      write_frame_callback(static_cast<unsigned>(g_screen_w), static_cast<unsigned>(g_screen_h), frame_idx);
      SDL_GL_SwapBuffers();
      ++frame_idx;
    }

    SDL_Quit();
    return 0;
  }
#endif

#if defined(USE_LD)
  if(!g_flag_developer)
#endif
  {
    g_sym.SDL_OpenAudio(&audio_spec, NULL);
    g_sym.SDL_PauseAudio(0);
  }
  
#if defined(USE_LD)
  starttick = SDL_GetTicks();	
#endif

  for(;;)
  {
    SDL_Event event;
    unsigned currtick;

#if defined(USE_LD)
    currtick = static_cast<unsigned>((static_cast<double>(SDL_GetTicks() - starttick) * 0.001 +
          static_cast<double>(INTRO_START)) * static_cast<double>(AUDIO_BYTERATE));
#else
    currtick = reinterpret_cast<uint8_t*>(g_audio_position) - reinterpret_cast<uint8_t*>(g_audio_buffer);
#endif

#if defined(USE_LD)
    {
      static double move_speed = 0.002;
      static float time = 0.0f;
      static float noise_param_mul = 1.0f;
      static uint8_t mouse_look = 0;
      static int8_t move_backward = 0;
      static int8_t move_down = 0;
      static int8_t move_forward = 0;
      static int8_t move_left = 0;
      static int8_t move_right = 0;
      static int8_t move_up = 0;
      static int8_t noise_params[9];
      int mouse_look_x = 0;
      int mouse_look_y = 0;
      uint8_t quit = 0;

      while(SDL_PollEvent(&event))
      {
        if(SDL_QUIT == event.type)
        {
          quit = 1;
        }
        else if(SDL_KEYDOWN == event.type)
        {
          switch(event.key.keysym.sym)
          {
            case SDLK_1:
              g_effect = 0;
              break;

            case SDLK_2:
              g_effect = 1;
              break;

            case SDLK_3:
              g_effect = 2;
              break;

            case SDLK_4:
              g_effect = 3;
              break;

            case SDLK_5:
              g_effect = 4;
              break;

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

            case SDLK_INSERT:
              {
                float rx = frand(static_cast<float>(M_PI)) + static_cast<float>(M_PI);
                float ry = frand(static_cast<float>(M_PI)) + static_cast<float>(M_PI);
                float rz = frand(static_cast<float>(M_PI)) + static_cast<float>(M_PI);

                generate_rotation_matrix_zxy(rx, ry, rz, g_rotation_matrix);
                printf("Rotation matrix (%1.2f ; %1.2f ; %1.2f):\n"
                    "[ %1.3f ; %1.3f ; %1.3f\n  %1.3f ; %1.3f ; %1.3f\n  %1.3f ; %1.3f ; %1.3f]\n",
                    rx, ry, rz, g_rotation_matrix[0], g_rotation_matrix[3], g_rotation_matrix[6],
                    g_rotation_matrix[1], g_rotation_matrix[4], g_rotation_matrix[7], g_rotation_matrix[2],
                    g_rotation_matrix[5], g_rotation_matrix[8]);
              }
              break;

            case SDLK_SPACE:
              printf("Position: [ %i ; %i ; %i ]\nForward: [ %i ; %i ; %i ]\nUp: [ %i ; %i ; %i ]\n",
                  static_cast<int>(g_position_x * 255.0f), static_cast<int>(g_position_y * 255.0f),
                  static_cast<int>(g_position_z * 255.0f), static_cast<int>(g_fw_x * 127.0f),
                  static_cast<int>(g_fw_y * 127.0f), static_cast<int>(g_fw_z * 127.0f),
                  static_cast<int>(g_up_x * 127.0f), static_cast<int>(g_up_y * 127.0f),
                  static_cast<int>(g_up_z * 127.0f));
              break;

            case SDLK_z:
              noise_params[0] = 1;
              break;

            case SDLK_x:
              noise_params[1] = 1;
              break;

            case SDLK_c:
              noise_params[2] = 1;
              break;

            case SDLK_v:
              noise_params[3] = 1;
              break;

            case SDLK_b:
              noise_params[4] = 1;
              break;

            case SDLK_n:
              noise_params[5] = 1;
              break;

            case SDLK_m:
              noise_params[6] = 1;
              break;

            case SDLK_COMMA:
              noise_params[7] = 1;
              break;
              
            case SDLK_PERIOD:
              noise_params[8] = 1;
              break;

            case SDLK_LSHIFT:
            case SDLK_RSHIFT:
              move_speed = 0.02;
              noise_param_mul = -1.0;
              break;            

            case SDLK_LALT:
              time = -static_cast<float>(AUDIO_BYTERATE / DESIRED_FRAMERATE);
              break;

            case SDLK_MODE:
            case SDLK_RALT:
              time = static_cast<float>(AUDIO_BYTERATE / DESIRED_FRAMERATE);
              break;

            case SDLK_ESCAPE:
              quit = 1;
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

            case SDLK_z:
              noise_params[0] = 0;
              break;

            case SDLK_x:
              noise_params[1] = 0;
              break;

            case SDLK_c:
              noise_params[2] = 0;
              break;

            case SDLK_v:
              noise_params[3] = 0;
              break;

            case SDLK_b:
              noise_params[4] = 0;
              break;

            case SDLK_n:
              noise_params[5] = 0;
              break;

            case SDLK_m:
              noise_params[6] = 0;
              break;

            case SDLK_COMMA:
              noise_params[7] = 0;
              break;
              
            case SDLK_PERIOD:
              noise_params[8] = 0;
              break;

            case SDLK_LSHIFT:
            case SDLK_RSHIFT:
              move_speed = 0.002;
              noise_param_mul = 1.0;
              break;            

            case SDLK_MODE:
            case SDLK_LALT:
            case SDLK_RALT:
              time = 0.0f;
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
        double fwlen = sqrt(g_fw_x * g_fw_x + g_fw_y * g_fw_y + g_fw_z * g_fw_z);
        double rtlen;
        double uplen;
        double rt_x;
        double rt_y;
        double rt_z;
        double movement_rt = (double)(move_right - move_left) * move_speed;
        double movement_up = (double)(move_up - move_down) * move_speed;
        double movement_fw = (double)(move_forward - move_backward) * move_speed;
        double new_fw_x;
        double new_fw_y;
        double new_fw_z;

        g_fw_x /= fwlen;
        g_fw_y /= fwlen;
        g_fw_z /= fwlen;

        rt_x = g_fw_y * g_up_z - g_fw_z * g_up_y;
        rt_y = g_fw_z * g_up_x - g_fw_x * g_up_z;
        rt_z = g_fw_x * g_up_y - g_fw_y * g_up_x;

        rtlen = sqrt(rt_x * rt_x + rt_y * rt_y + rt_z * rt_z);
        rt_x /= rtlen;
        rt_y /= rtlen;
        rt_z /= rtlen;

        g_up_x = rt_y * g_fw_z - rt_z * g_fw_y;
        g_up_y = rt_z * g_fw_x - rt_x * g_fw_z;
        g_up_z = rt_x * g_fw_y - rt_y * g_fw_x;
        
        uplen = sqrt(g_up_x * g_up_x + g_up_y * g_up_y + g_up_z * g_up_z);
        g_up_x /= uplen;
        g_up_y /= uplen;
        g_up_z /= uplen;

        g_position_x += movement_rt * rt_x + movement_up * g_up_x + movement_fw * g_fw_x;
        g_position_y += movement_rt * rt_y + movement_up * g_up_y + movement_fw * g_fw_y;
        g_position_z += movement_rt * rt_z + movement_up * g_up_z + movement_fw * g_fw_z;

        new_fw_x = g_fw_x;
        new_fw_y = g_fw_y;
        new_fw_z = g_fw_z;

        if(0 != mouse_look_x)
        {
          double angle = (double)mouse_look_x / (double)(screen_h / 4) * FOV / 180.0;
          double ca = cos(angle);
          double sa = sin(angle);

          new_fw_x = ca * g_fw_x - sa * rt_x;
          new_fw_y = ca * g_fw_y - sa * rt_y;
          new_fw_z = ca * g_fw_z - sa * rt_z;
        }
        if(0 != mouse_look_y)
        {
          double angle = (double)mouse_look_y / (double)(screen_h / 4) * FOV / 180.0;
          double ca = cos(angle);
          double sa = sin(angle);
          double new_fw_x2 = ca * g_fw_x + sa * g_up_x;
          double new_fw_y2 = ca * g_fw_y + sa * g_up_y;
          double new_fw_z2 = ca * g_fw_z + sa * g_up_z;
          
          g_up_x = ca * g_up_x - sa * g_fw_x;
          g_up_y = ca * g_up_y - sa * g_fw_y;
          g_up_z = ca * g_up_z - sa * g_fw_z;

          if(0 != mouse_look_x)
          {
            new_fw_x = (new_fw_x2 + new_fw_x) * 0.5f;
            new_fw_y = (new_fw_y2 + new_fw_y) * 0.5f;
            new_fw_z = (new_fw_z2 + new_fw_z) * 0.5f;
          }
          else
          {
            new_fw_x = new_fw_x2;
            new_fw_y = new_fw_y2;
            new_fw_z = new_fw_z2;
          }
        }
        g_fw_x = new_fw_x;
        g_fw_y = new_fw_y;
        g_fw_z = new_fw_z;

        g_uniform_array[0] += time;
        if(g_uniform_array[0] < 0.0)
        {
          g_uniform_array[0] = 0.0f;
        }

        g_raycast[0] = static_cast<float>(g_position_x);
        g_raycast[1] = static_cast<float>(g_position_y);
        g_raycast[2] = static_cast<float>(g_position_z);
        g_raycast[3] = static_cast<float>(g_fw_x);
        g_raycast[4] = static_cast<float>(g_fw_y);
        g_raycast[5] = static_cast<float>(g_fw_z);
        g_raycast[6] = static_cast<float>(g_up_x);
        g_raycast[7] = static_cast<float>(g_up_y);
        g_raycast[8] = static_cast<float>(g_up_z);

        // Noise scale.
        {
          bool print_noise = false;
          for(unsigned ii = 0; (ii <= 3); ++ii)
          {
            if(noise_params[ii])
            {
              g_noise_scale[ii] += ((ii == 0) ? 0.001f : 0.01f) * noise_param_mul;
              print_noise = true;
            }
          }
          if(print_noise)
          {
            printf("Noise scale: [ %1.3f ; %1.3f ; %1.3f ; %1.3f ]\n", g_noise_scale[0], g_noise_scale[1],
                g_noise_scale[2], g_noise_scale[3]);
          }
        }

        // Noise strength.
        {
          bool print_noise = false;
          for(unsigned ii = 4; (ii <= 7); ++ii)
          {
            if(noise_params[ii])
            {
              g_noise_strength[ii - 4] += 0.01f * noise_param_mul;
              print_noise = true;
            }
          }
          if(print_noise)
          {
            printf("Noise strength: [ %1.3f ; %1.3f ; %1.3f ; %1.3f ]\n", g_noise_strength[0],
                g_noise_strength[1], g_noise_strength[2], g_noise_strength[3]);
          }
        }

        // Noise substract.
        if(noise_params[8])
        {
          g_noise_substract += 0.01f * noise_param_mul;
          printf("Noise substract: %1.3f\n", g_noise_substract);
        }
      }

      if(0 != quit)
      {
        break;
      }
    }
    if(!g_flag_developer && (currtick >= INTRO_LENGTH))
    {
      break;
    }
#else
    if((currtick >= INTRO_LENGTH) || (g_sym.SDL_PollEvent(&event) && (event.type == SDL_KEYDOWN)))
    {
      break;
    }
#endif

    draw(currtick);
    g_sym.SDL_GL_SwapBuffers();
  }

  g_sym.SDL_Quit();
#if !defined(USE_LD) && defined(asm_exit)
  asm_exit();
#else
  return 0;
#endif
}

//######################################
// End #################################
//######################################
