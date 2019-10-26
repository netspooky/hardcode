#ifndef VERBATIM_FRAME_BUFFER_HPP
#define VERBATIM_FRAME_BUFFER_HPP

#include "verbatim_texture.hpp"

class FrameBuffer
{
  public:
    FrameBuffer(unsigned width, unsigned height);

    void bind() const;

    /** \brief Bind default framebuffer.
     *
     * \param screen_width Width of default framebuffer.
     * \param screen_height Height of default framebuffer.
     */
    static void bindDefaultBuffer(unsigned screen_width, unsigned screen_height);

    inline Texture const & getTexture() const
    {
      return m_render_target;
    }

    /** \brief Accessor.
     *
     * \return Render target width.
     */
    inline unsigned getWidth() const
    {
      return m_render_target.getWidth();
    }

    /** \brief Accessor.
     *
     * \return Render target height.
     */
    inline unsigned getHeight() const
    {
      return m_render_target.getHeight();
    }

  private:
    GLuint m_fbo;
    GLuint m_depth_buffer;
    Texture m_render_target;

    static FrameBuffer const * g_current_render_target;
};

#endif /* VERBATIM_FRAME_BUFFER_HPP */
