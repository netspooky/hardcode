#ifndef VERBATIM_PROGRAM_HPP
#define VERBATIM_PROGRAM_HPP

#include "verbatim_matrix.hpp"
#include "verbatim_shader.hpp"
#include "verbatim_vertex_buffer.hpp"

/** \brief Shader program class.
 */
class Program
{
  private:
    /** Max amount of identifiers in a program (ASCII7). */
    static const int PROGRAM_MAX_IDENTIFIERS = 128;

  private:
    /** Currently bound program. */
    static const Program* g_current_program;

  private:
    /** OpenGL id. */
    GLuint m_id;

    /** Vertex shader. */
    Shader *m_vertex_shader;

    /** Vertex shader. */
    Shader *m_fragment_shader;

    /** Attributes. */
    GLint m_attributes[PROGRAM_MAX_IDENTIFIERS];

    /** Uniforms. */
    GLint m_uniforms[PROGRAM_MAX_IDENTIFIERS];

  public:
    /** \brief Bind attribute.
     *
     * \param name Identifier name.
     * \param GLint size Number of components.
     * \param type Component type.
     * \param normalized Should fixed-point values be normalized?
     * \param pointer Pointer to first component.
     */
    void attribPointer(int name, GLint size, GLenum type, bool normalized, GLsizei stride,
        const GLvoid* pointer) const
    {
      GLint attribute_name = m_attributes[name];
      if(0 <= attribute_name)
      {
        dnload_glVertexAttribPointer(attribute_name, size, type, static_cast<GLboolean>(normalized), stride,
            pointer);
        dnload_glEnableVertexAttribArray(attribute_name);
      }
    }

    /** \brief Send uniform.
     *
     * \param name Identifier name.
     * \param value Uniform value.
     */
    void uniform(int name, GLint value) const
    {
      dnload_glUniform1i(m_uniforms[name], value);
    }

    /** \brief Send uniform.
     *
     * \param name Identifier name.
     * \param value Uniform value.
     */
    void uniform(int name, GLfloat value) const
    {
      dnload_glUniform1f(m_uniforms[name], value);
    }

    /** \brief Send uniform.
     *
     * \param name Identifier name.
     * \param value1 Uniform value.
     * \param value2 Uniform value.
     */
    void uniform(int name, float value1, float value2) const
    {
      dnload_glUniform2f(m_uniforms[name], value1, value2);
    }

    /** \brief Send uniform.
     *
     * \param name Identifier name.
     * \param value Uniform value.
     */
    void uniform(int name, const Vector3 &value) const
    {
      dnload_glUniform3fv(m_uniforms[name], 1, value.getData());
    }

    /** \brief Send uniform.
     *
     * \param name Identifier name.
     * \param value Uniform value.
     */
    void uniform(int name, const Matrix3 &value) const
    {
      dnload_glUniformMatrix3fv(m_uniforms[name], 1, static_cast<GLboolean>(false), value.getData());
    }

    /** \brief Send uniform.
     *
     * \param name Identifier name.
     * \param value Uniform value.
     */
    void uniform(int name, const Matrix4 &value) const
    {
      dnload_glUniformMatrix4fv(m_uniforms[name], 1, static_cast<GLboolean>(false), value.getData());
    }

  public:
    /** Constructor.
     *
     * \param vertex_source Vertex shader source.
     * \param fragment_source Fragment shader source.
     */
    Program(const char *vertex_source, const char *fragment_source);

  private:
    /** \brief Link this program.
    *
    * Will terminate program on failure.
     */
    void link();

  public:
    /** \brief Use this program.
     */
    void use() const;
};

#endif
