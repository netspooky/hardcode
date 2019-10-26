#ifndef VERBATIM_TEXTURE_HPP
#define VERBATIM_TEXTURE_HPP

#include "verbatim_realloc.hpp"

// Forward declaration.
class FrameBuffer;

/** \brief Texture class.
 */
class Texture
{
  public:
    /** Constructor.
     *
     * \param width Width of the texture
     * \param height Height of the texture
     * \param channels Number of color channels in texture data
     * \param data Pointter to texture data, must be one byte per color channel per texel.
     * \param clamp True to clamp texture instead of wrapping (default: false).
     */
    Texture(unsigned width, unsigned height, unsigned channels, void *data, bool clamp = false);
    
#if defined(USE_LD)
    /** Destructor. */
    ~Texture();
#endif

    /** Accessor function to get with of the texture */
    unsigned getWidth() const
    {
      return m_width;
    }

    /** Accessor function to get height of the texture */
    unsigned getHeight() const
    {
      return m_height;
    }

    /** \brief Bind texture to given texture unit 
     *
     * \param texture_unit Texture unit [0, 8)
     * 
     */
    void bind(unsigned texture_unit) const;

    /** Number of texture units managed by this class */
    static unsigned const MAX_TEXTURE_UNITS = 2;

  private:
    /** OpenGL texture name */
    GLuint m_id;

    /** Texture width */
    unsigned m_width;

    /** Texture height */
    unsigned m_height;

    /** Currently bound textures. One for each texture unit */
    static Texture const * g_current_texture[MAX_TEXTURE_UNITS];

    /** Currently active texture unit */
    static unsigned g_active_texture_unit;

    friend class FrameBuffer;
};

#endif /* VERBATIM_TEXTURE_HPP */
