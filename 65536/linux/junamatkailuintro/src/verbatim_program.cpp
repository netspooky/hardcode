#include "verbatim_program.hpp"

#include "verbatim_vertex_buffer.hpp"

#if defined(USE_LD)
#include "glsl_shader_source.hpp"
#endif

const Program *Program::g_current_program = NULL;

Program::Program(const char *vertex_source, const char *fragment_source) :
  m_id(dnload_glCreateProgram()),
  m_vertex_shader(new Shader(GL_VERTEX_SHADER, vertex_source)),
  m_fragment_shader(new Shader(GL_FRAGMENT_SHADER, fragment_source))
{
  this->link();
}

void Program::link()
{
  dnload_glAttachShader(m_id, m_vertex_shader->getId());
  dnload_glAttachShader(m_id, m_fragment_shader->getId());

  dnload_glLinkProgram(m_id);

#if defined(USE_LD)
  std::string log = GlslShaderSource::get_program_info_log(m_id);

  if(0 < log.length())
  {
    std::cout << log << std::endl;
  }

  if(!GlslShaderSource::get_program_link_status(m_id))
  {
    terminate_program();
  }

  std::cout << "|program(" << m_id << ")\n";
#endif

  for(int ii = 0; (ii < PROGRAM_MAX_IDENTIFIERS); ++ii)
  {
    char identifier_string[] = { static_cast<char>(ii), 0 };
    m_attributes[ii] = dnload_glGetAttribLocation(m_id, identifier_string);
    m_uniforms[ii] = dnload_glGetUniformLocation(m_id, identifier_string);
#if defined(USE_LD)
    if(m_attributes[ii] >= 0)
    {
      std::cout << "|attribute '" << identifier_string << "': " << m_attributes[ii] << std::endl;
    }
    if(m_uniforms[ii] >= 0)
    {
      std::cout << "|uniform '" << identifier_string << "': " << m_uniforms[ii] << std::endl;
    }
#endif
  }
}

void Program::use() const
{
  if(g_current_program == this)
  {
    return;
  }

  dnload_glUseProgram(m_id);

  g_current_program = this;

  VertexBuffer::reset_programmed_vertex_buffer();
}

