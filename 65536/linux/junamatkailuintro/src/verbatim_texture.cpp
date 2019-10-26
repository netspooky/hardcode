#include "verbatim_texture.hpp"
#include "verbatim_realloc.hpp"

Texture const * Texture::g_current_texture[Texture::MAX_TEXTURE_UNITS] =
{
  0, 0
};
unsigned Texture::g_active_texture_unit = 0;

Texture::Texture(unsigned width, unsigned height, unsigned channels, void * data, bool clamp) :
  m_id(0),
  m_width(width),
  m_height(height)
{
  dnload_glGenTextures(1, &m_id);

#if defined(USE_LD)
  const Texture* prev_texture = g_current_texture[g_active_texture_unit];
  this->bind(g_active_texture_unit);
#endif

  static GLenum const formats[] =
  {
    0,
    GL_LUMINANCE,
    GL_LUMINANCE_ALPHA,
    GL_RGB,
    GL_RGBA
  };
  GLenum const format = formats[channels];
  GLint const wrap_mode = clamp ? GL_CLAMP_TO_EDGE : GL_REPEAT;

  dnload_glBindTexture(GL_TEXTURE_2D, m_id); 
  dnload_glTexImage2D(GL_TEXTURE_2D, 0, static_cast<GLint>(format), static_cast<GLsizei>(width),
      static_cast<GLsizei>(height), 0, format, GL_UNSIGNED_BYTE, data);

  dnload_glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
  dnload_glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
  dnload_glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, wrap_mode);
  dnload_glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, wrap_mode);

#if defined(USE_LD)
  glGenerateMipmap(GL_TEXTURE_2D);

  if(prev_texture)
  {
    prev_texture->bind(g_active_texture_unit);
  }
#endif
}

#ifdef USE_LD
Texture::~Texture()
{
  for(unsigned i = 0; i < MAX_TEXTURE_UNITS; ++i)
  {
    if(g_current_texture[i] && g_current_texture[i]->m_id == m_id)
    {
      dnload_glActiveTexture(GL_TEXTURE0 + i);
      dnload_glBindTexture(GL_TEXTURE_2D, 0);
      g_current_texture[i] = NULL;
    }
  }

  dnload_glActiveTexture(GL_TEXTURE0 + g_active_texture_unit);

  if(m_id)
  {
    glDeleteTextures(1, &m_id);
  }
}
#endif

void Texture::bind(unsigned texture_unit) const
{
  if(g_current_texture[texture_unit] != this)
  {
    dnload_glActiveTexture(GL_TEXTURE0 + texture_unit);
    dnload_glBindTexture(GL_TEXTURE_2D, m_id);
    g_active_texture_unit = texture_unit;
    g_current_texture[texture_unit] = this;
  }
}

