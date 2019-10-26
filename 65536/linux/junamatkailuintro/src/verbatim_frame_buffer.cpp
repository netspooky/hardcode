#include "verbatim_frame_buffer.hpp"

FrameBuffer const * FrameBuffer::g_current_render_target = NULL;

FrameBuffer::FrameBuffer(unsigned width, unsigned height) :
  m_fbo(0),
  m_depth_buffer(0),
  m_render_target(width, height, 4, NULL, true)
{
  dnload_glGenFramebuffers(1, &m_fbo);
  dnload_glBindFramebuffer(GL_FRAMEBUFFER, m_fbo);
  dnload_glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, m_render_target.m_id, 0);

  dnload_glGenRenderbuffers(1, &m_depth_buffer);
  dnload_glBindRenderbuffer(GL_RENDERBUFFER, m_depth_buffer);
  dnload_glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, width, height);
  dnload_glBindRenderbuffer(GL_RENDERBUFFER, 0);
  dnload_glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, m_depth_buffer);

#ifdef USE_LD
  GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
  std::cout<<"FBO("<<this<<"): "<<status<<
    (status == GL_FRAMEBUFFER_COMPLETE ? " complete" : " error") << std::endl;
#endif

  dnload_glBindFramebuffer(GL_FRAMEBUFFER,
    g_current_render_target ? g_current_render_target->m_fbo : 0);
}

void FrameBuffer::bind() const
{
  if(g_current_render_target != this)
  {
    dnload_glBindFramebuffer(GL_FRAMEBUFFER, m_fbo);
    dnload_glViewport(0, 0, static_cast<GLsizei>(m_render_target.getWidth()),
        static_cast<GLsizei>(m_render_target.getHeight()));
    g_current_render_target = this;
  }
}

void FrameBuffer::bindDefaultBuffer(unsigned screen_width, unsigned screen_height)
{
  if(g_current_render_target)
  {
    dnload_glBindFramebuffer(GL_FRAMEBUFFER, 0);
    dnload_glViewport(0, 0, static_cast<GLsizei>(screen_width), static_cast<GLsizei>(screen_height));
    g_current_render_target = NULL;
  }
}

