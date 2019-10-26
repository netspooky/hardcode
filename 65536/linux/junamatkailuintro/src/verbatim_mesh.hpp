#ifndef VERBATIM_MESH_HPP
#define VERBATIM_MESH_HPP

#include "verbatim_face.hpp"
#include "verbatim_vertex_buffer.hpp"

// Forward declaration.
class CompiledMesh;

/** Renderable object.
 */
class Mesh
{
  public:
    /** Color determination function type. */
    typedef Color (*FaceColorFunction)(const Face&);

  public:
    /** Side existence flag. */
    static const uint8_t SIDE_FRONT = (1 << 0);

    /** Side existence flag. */
    static const uint8_t SIDE_BACK = (1 << 1);

    /** Side existence flag. */
    static const uint8_t SIDE_BOTTOM = (1 << 2);

    /** Side existence flag. */
    static const uint8_t SIDE_TOP = (1 << 3);

    /** Side existence flag. */
    static const uint8_t SIDE_LEFT = (1 << 4);

    /** Side existence flag. */
    static const uint8_t SIDE_RIGHT = (1 << 5);

    /** Combinatoric side existence flag. */
    static const uint8_t SIDE_ALL = 0xFF;

    /** Combinatoric side existence flag. */
    static const uint8_t SIDE_NO_BACK = 0xFF & (~SIDE_BACK);

    /** Combinatoric side existence flag. */
    static const uint8_t SIDE_NO_BACK_NO_BOTTOM = 0xFF & (~SIDE_BACK) & (~SIDE_BOTTOM);

    /** Combinatoric side existence flag. */
    static const uint8_t SIDE_NO_BACK_NO_BOTTOM_NO_TOP = 0xFF & (~SIDE_BACK) & (~SIDE_BOTTOM) & (~SIDE_TOP);

    /** Combinatoric side existence flag. */
    static const uint8_t SIDE_NO_BACK_NO_TOP = 0xFF & (~SIDE_BACK) & (~SIDE_TOP);

    /** Combinatoric side existence flag. */
    static const uint8_t SIDE_NO_BACK_NO_FRONT = 0xFF & (~SIDE_FRONT) & (~SIDE_BACK);

    /** Combinatoric side existence flag. */
    static const uint8_t SIDE_NO_BOTTOM = 0xFF & (~SIDE_BOTTOM);

    /** Combinatoric side existence flag. */
    static const uint8_t SIDE_NO_BOTTOM_NO_TOP = 0xFF & (~SIDE_BOTTOM) & (~SIDE_TOP);

    /** Combinatoric side existence flag. */
    static const uint8_t SIDE_NO_FRONT = 0xFF & (~SIDE_FRONT);

    /** Combinatoric side existence flag. */
    static const uint8_t SIDE_NO_TOP = 0xFF & (~SIDE_TOP);

  private:
    /** \brief Mesh vertex data.
     *
     * Freed upon bake.
     */
    Array<LogicalVertex> m_vertices;

    /** \brief Mesh face data.
     *
     * Freed upon bake.
     */
    Array<Face> m_faces;

  public:
    /** \brief Accessor.
     *
     * \param idx Index.
     * \return Vertex (not logical) at index.
     */
    LogicalVertex& getLogicalVertex(size_t idx)
    {
      return m_vertices[idx];
    }

    /** \brief Accessor.
     *
     * \param idx Index.
     * \return Vertex (not logical) at index.
     */
    const LogicalVertex& getLogicalVertex(size_t idx) const
    {
      return m_vertices[idx];
    }

    /** \brief Accessor.
     *
     * \return Logical vertex count.
     */
    size_t getLogicalVertexCount() const
    {
      return m_vertices.getSize();
    }

  private:
    /** \brief Get amount of vertices needed after precalculating.
     * 
     * This function is not constant-time.
     *
     * \return Number of vertices this object is going to add into a vertex buffer.
     */
    unsigned getPrecalculatedVertexCount() const;

    /** \brief Precalculate an object.
     *
     * After precalculation, object is ready for adding into a vertex buffer.
     *
     * \param func Func to use for replacing face color (if specified).
     */
    void precalculate(FaceColorFunction func = NULL);

  public:
    /** \brief Add angle form.
     *
     * \param p1 Starting point.
     * \param p2 Corner point.
     * \param p3 End point.
     * \param radius Radius of angle 'tube'.
     * \param detail Detail of angle 'tube'.
     * \param color Color.
     * \param existence Which sides exist (default: all).
     */
    void addAngle(const Vector3 &p1, const Vector3 &p2, const Vector3 &p3, float radius, unsigned detail,
        const Color &color, uint8_t existence = SIDE_ALL);

    /** \brief Add box form.
     *
     * \param p1 First corner.
     * \param p2 Second corner.
     * \param color Color.
     * \param up Up vector.
     * \param existence Which sides exist (default: all).
     */
    void addBox(const Vector3 &p1, const Vector3 &p2, const Color &color,
        const Vector3 &forward = Vector3(0.0f, 0.0f, -1.0f), const Vector3 &up = Vector3(0.0f, 1.0f, 0.0f),
        uint8_t existence = SIDE_ALL);

    /** \brief Add capped cylinder.
     *
     * TODO: document
     */
    void addCappedCylinder(const Vector3 &p1, const Vector3 &p2, float radius1, float radius2,
        unsigned detail1, unsigned detail2, const Color &color, const Vector3 &up, uint8_t existence);

    /** \brief Add cylinder form.
     *
     * \param p1 First vertex.
     * \param p2 Second vertex.
     * \param radius1 Radius at beginning of 'tube'.
     * \param radius2 Radius at end of 'tube'.
     * \param detail Detail level of 'tube'.
     * \param color Color.
     * \param up Up vector.
     * \param existence Which sides exist (default: all).
     */
    void addCylinder(const Vector3 &p1, const Vector3 &p2, float radius1, float radius2, unsigned detail,
        const Color &color, const Vector3 &up = Vector3(0.0f, 1.0f, 0.0f), uint8_t existence = SIDE_ALL);

    /** \brief Add elongated cylinder form.
     *
     * \param p1 First vertex.
     * \param p2 Second vertex.
     * \param radius1 Radius at beginning of form.
     * \param radius2 Radius at end of form.
     * \param length Length along the up axis.
     * \param detail Detail level of one end.
     * \param color Color.
     * \param up Up vector.
     * \param existence Which sides exist (default: all).
     */
    void addElongatedCylinder(const Vector3 &p1, const Vector3 &p2, float radius1, float radius2, float length,
        unsigned detail, const Color &color, const Vector3 &up = Vector3(0.0f, 1.0f, 0.0f),
        uint8_t existence = SIDE_ALL);

    /** \brief Add slope.
     *
     * \param p1 Level begin.
     * \param p2 Slope begin.
     * \param p3 Slope end.
     * \param width Slope width.
     * \param detail Slope detail.
     * \param color Color.
     * \param up Up vector.
     */
    void addSlope(const Vector3 &p1, const Vector3 &p2, const Vector3 &p3, float width, unsigned detail,
        const Color &color, const Vector3 &up = Vector3(0.0f, 1.0f, 0.0f));

    /** \brief Insert object into a vertex buffer.
     *
     * \param vertex_buffer Vertex buffer to insert to.
     * \param near_value Near factor.
     * \param func Function to use to calculate face color.
     * \return Compiled mesh as result of insertion or NULL.
     */
    CompiledMesh* insert(VertexBuffer *vertex_buffer, float near_value = CAMERA_NEAR_CONSTANT,
        FaceColorFunction func = NULL);

  public:
    /** \brief Add individual face.
     *
     * \param op Face.
     */
    void addFace(const Face &op)
    {
      m_faces.add(op);
    }

    /** \brief Add individual vertex.
     *
     * \param pos Position.
     * \param col Color.
     */
    void addVertex(const Vector3 &pos, const Color &col = Color(255, 255, 255, 255))
    {
#if defined(USE_LD)
      if(g_debug)
      {
        std::cout << pos << " ; " << col << std::endl;
      }
#endif
      m_vertices.add(LogicalVertex(pos, col));
    }

    /** \brief Add vertex wrapper.
     *
     * \param px X position.
     * \param py Y position.
     * \param pz Z position.
     * \param col Color.
     */
    void addVertex(float px, float py, float pz, const Color &col = Color(255, 255, 255, 255))
    {
      this->addVertex(Vector3(px, py, pz), col);
    }

    /** \brief Add face wrapper.
     *
     * \param c1 First corner.
     * \param c2 Second corner.
     * \param c3 Third corner.
     * \param col Color.
     * \param exists Face existence.
     */
    void addFace(unsigned c1, unsigned c2, unsigned c3, const Color &col = Color(255, 255, 255, 255),
        bool exists = true)
    {
      this->addFace(Face(c1, c2, c3, col, exists));
    }

    /** \brief Add face wrapper.
     *
     * \param c1 First corner.
     * \param c2 Second corner.
     * \param c3 Third corner.
     * \param c4 Fourth corner.
     * \param col Color.
     * \param exists Face existence.
     */
    void addFace(unsigned c1, unsigned c2, unsigned c3, unsigned c4,
        const Color &col = Color(255, 255, 255, 255), bool exists = true)
    {
#if defined(USE_LD)
      if(g_debug)
      {
        std::cout << c1 << " ; " << c2 << " ; " << c3 << " ; " << c4 << std::endl;
      }
#endif
      this->addFace(Face(c1, c2, c3, c4, col, exists));
    }

    /** \brief Insert object into a vertex buffer wrapper.
     *
     * \param vertex_buffer Vertex buffer to insert to.
     * \param func Function to use to calculate face color.
     * \return Compiled mesh as result of insertion or NULL.
     */
    CompiledMesh* insert(VertexBuffer *vertex_buffer, FaceColorFunction func)
    {
      return this->insert(vertex_buffer, CAMERA_NEAR_CONSTANT, func);
    }

#if defined(USE_LD)
  public:
    /** \brief Print operator.
     *
     * \param lhs Left-hand-side operand.
     * \param rhs Right-hand-side operand.
     * \return Output stream.
     */
    friend std::ostream& operator<<(std::ostream &lhs, const Mesh &rhs)
    {
      return lhs << "Mesh(" << &rhs << ')';
    }
#endif
};

/** Compiled mesh.
 *
 * Acquired when inserting a mesh into a vertex buffer, can be used for compilation.
 */
class CompiledMesh
{
  private:
    /** Vertex buffer this object has been baked into. */
    const VertexBuffer *m_vertex_buffer;

    /** Vertex base. */
    size_t m_vertex_base;

    /** Vertex count in this mesh. */
    size_t m_vertex_count;

    /** Index base to start rendering from. */
    size_t m_index_base;

    /** Indices to render. */
    GLsizei m_index_count;

  public:
    /** \brief Accessor.
     *
     * \param idx Index of vertex to access.
     * \return Vertex reference.
     */
    const Vertex& getVertex(size_t idx) const
    {
      return m_vertex_buffer->getVertex(m_vertex_base + idx);
    }

    /** \brief Accessor.
     *
     * \return Index count.
     */
    size_t getVertexCount() const
    {
      return m_vertex_count;
    }

  public:
    /** \brief Constructor.
     *
     * \param vertex_buffer Vertex buffer bound to.
     * \param vertex_base Vertex base.
     * \param vertex_count Vertex count.
     * \param index_base Index base.
     * \param index_count Index count.
     */
    CompiledMesh(const VertexBuffer *vertex_buffer, size_t vertex_base, size_t vertex_count, size_t index_base,
        unsigned index_count) :
      m_vertex_buffer(vertex_buffer),
      m_vertex_base(vertex_base),
      m_vertex_count(vertex_count),
      m_index_base(index_base),
      m_index_count(static_cast<GLsizei>(index_count)) { }

    /** \brief Empty destructor.
     */
    ~CompiledMesh() { }

  public:
    /** \brief Use this for rendering.
     *
     * \param op Program to use for drawing.
     */
    void use(const Program *op) const;

  public:
    /** \brief Issue glDrawElements call.
     */
    void drawElements() const
    {
      dnload_glDrawElements(GL_TRIANGLES, m_index_count, GL_UNSIGNED_SHORT,
          static_cast<uint16_t*>(NULL) + m_index_base);
    }
};

#endif
