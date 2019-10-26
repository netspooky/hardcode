#ifndef VERBATIM_VERTEX_BUFFER
#define VERBATIM_VERTEX_BUFFER

#include "verbatim_array.hpp"
#include "verbatim_vertex.hpp"

// Forward declaration.
class Program;

/** Vertex buffer.
 */
class VertexBuffer
{
  private:
    /** Current vertex buffer. */
    static const VertexBuffer* g_bound_vertex_buffer;

    /** Currently programmed vertex buffer. */
    static const VertexBuffer* g_programmed_vertex_buffer;

  private:
    /** OpenGL id. */
    GLuint m_id_data[2];

    /** Vertex array. */
    Array<Vertex> m_vertices;

    /** Index array. */
    Array<uint16_t> m_indices;

  private:
    /** \brief Accessor.
     *
     * \return Vertex buffer OpenGL id.
     */
    GLuint getVertexId() const
    {
      return m_id_data[0];
    }

    /** \brief Accessor.
     *
     * \return Index buffer OpenGL id.
     */
    GLuint getIndexId() const
    {
      return m_id_data[1];
    }

  public:
    /** \brief Accessor.
     *
     * \param idx Index of vertex to access.
     * \return Vertex at given index.
     */
    const Vertex& getVertex(size_t idx) const
    {
      return m_vertices[idx];
    }

  public:
    /** \brief Constructor.
     */
    VertexBuffer();

  public:
    /** \brief Add face to this vertex buffer.
     *
     * \param op Index to add.
     */
    void addIndex(uint16_t op)
    {
#if defined(USE_LD)
      if(g_debug)
      {
        std::cout << op << std::endl;
      }
#endif
      m_indices.add(op);
    }

    /** \brief Add vertex to this vertex buffer.
     *
     * \param op Vertex to add.
     */
    void addVertex(const Vertex &op)
    {
#if defined(USE_LD)
      if(g_debug)
      {
        std::cout << op << std::endl;
      }
#endif
      m_vertices.add(op);
    }

    /** \brief Tell if amount of vertices fits in this vertex buffer.
     *
     * \param op Number of offered vertices.
     * \return True if fits, false if not.
     */
    bool fitsVertices(size_t op)
    {
      return (65536 >= (m_vertices.getSize() + op));
    }

    /** \brief Accessor.
     *
     * \return Index count.
     */
    size_t getIndexCount() const
    {
      return m_indices.getSize();
    }

    /** \brief Accessor.
     *
     * \return Vertex count.
     */
    size_t getVertexCount() const
    {
      return m_vertices.getSize();
    }

  private:
    /** \brief Bind this vertex buffer for rendering and/or modification.
     */
    void bind() const;

  public:
    /** \brief Update this vertex buffer into the GPU.
     *
     * \param indicesEnabled Set to true (default) if index buffer is relevant and should be uploaded.
     */
    void update(bool indicesEnabled = true);

    /** \brief Use this vertex buffer for rendering.
     *
     * \param op Program to use.
     */
    void use(const Program *op) const;

  public:
    /** \brief Reset programmed vertex buffer.
     *
     * Must be done when changing a program.
     */
    static void reset_programmed_vertex_buffer()
    {
      g_programmed_vertex_buffer = NULL;
    }

    /** \brief Unbind vertex buffer.
     */
    static void unbind()
    {
      dnload_glBindBuffer(GL_ARRAY_BUFFER, 0);
      dnload_glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);

      g_bound_vertex_buffer = NULL;
      reset_programmed_vertex_buffer();
    }

#if defined(USE_LD)
  public:
    /** \brief Print operator.
     *
     * \param lhs Left-hand-side operand.
     * \param rhs Right-hand-side operand.
     */
    friend std::ostream& operator<<(std::ostream &lhs, const VertexBuffer &rhs)
    {
      return lhs << "VertexBuffer(" << &rhs << ')';
    }
#endif
};

#endif
