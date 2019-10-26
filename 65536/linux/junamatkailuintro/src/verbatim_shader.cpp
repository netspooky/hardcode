#include "verbatim_shader.hpp"

#if defined(USE_LD)
#include "glsl_shader_source.hpp"
#endif

Shader::Shader(GLenum type, const char* part1) :
  m_id(dnload_glCreateShader(type)),
  m_num_parts(1)
{
  m_parts[0] = part1;

  this->compile();
}

void Shader::compile() const
{
#if defined(USE_LD)
  std::string pretty_source = this->str();
  const GLchar *pretty_source_c_str = pretty_source.c_str();
  dnload_glShaderSource(m_id, 1, &pretty_source_c_str, NULL);
#else
  dnload_glShaderSource(m_id, m_num_parts, const_cast<const GLchar**>(m_parts), NULL);
#endif

  dnload_glCompileShader(m_id);

#if defined(USE_LD)
  std::string log = GlslShaderSource::get_shader_info_log(m_id);

  std::cout << pretty_source << std::endl;
  if(0 < log.length())
  {
    std::cout << log << std::endl;
  }

  if(!GlslShaderSource::get_shader_compile_status(m_id))
  {
    terminate_program();
  }
#endif
}

#if defined(USE_LD)

std::string Shader::str() const
{
  GlslShaderSource glsl_source;

  for(unsigned ii = 0; (ii < m_num_parts); ++ii)
  {
    glsl_source.add(std::string(m_parts[ii]));
  }

#if defined(DNLOAD_GLESV2)
  return glsl_source.str();
#else
  return GlslShaderSource::convert_glesv2_gl(glsl_source.str());
#endif
}

#endif

