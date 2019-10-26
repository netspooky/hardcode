#ifndef VERBATIM_SHADER_HPP
#define VERBATIM_SHADER_HPP

#include "verbatim_realloc.hpp"

/** \brief Shader class.
 */
class Shader
{
  private:
    /** Max amount of parts in a shader. */
    static const unsigned SHADER_MAX_PARTS = 1;

  private:
    /** GL identifier. */
    const GLuint m_id;

    /** Shader parts. */
    const GLchar *m_parts[SHADER_MAX_PARTS];

    /** Number of parts in shader. */
    const unsigned m_num_parts;

  public:
   /** \brief Accessor.
    *
    * \return OpenGL id.
    */
   GLuint getId()
   {
     return m_id;
   }

  public:
   /** \brief Constructor.
    *
    * \param type GL_VERTEX_SHADER or GL_FRAGMENT_SHADER.
    * \param part1 Shader part.
    */
   Shader(GLenum type, const char *part1);

#if defined(USE_LD)
   /** \brief Get a string representation of the shader.
    *
    * \return String representation in (more) human-readable form.
    */
   std::string str() const;
#endif

  private:
   /** \brief Compile this shader.
    *
    * Will terminate program on failure.
    */
   void compile() const;
};

#endif
