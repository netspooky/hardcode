#ifndef VERBATIM_FACE_HPP
#define VERBATIM_FACE_HPP

#include "verbatim_color.hpp"
#include "verbatim_vector.hpp"

// Forward declaration.
class Mesh;
class VertexBuffer;

/** \brief Face class.
 *
 * Up to quads supported.
 */
class Face
{
  private:
    /** Number of corners. */
    unsigned m_num_corners;

    /** Corner points. */
    unsigned m_indices[4];

    /** Color modulation. */
    Color m_color;

    /** Average normal. */
    Vector3 m_normal;

    /** \brief Is this face real?
     *
     * If false, face will only be used for normal calculations but never drawn.
     */
    bool m_real;

  public:
    /** \brief Accessor
     *
     * \return Color.
     */
    const Color& getColor() const
    {
      return m_color;
    }
    /** \brief Assignment.
     *
     * \param op New color.
     */
    void setColor(const Color &op)
    {
      m_color = op;
    }

    /** \brief Accessor.
     *
     * \return Corner count.
     */
    unsigned getCornerCount() const
    {
      return m_num_corners;
    }

    /** \brief Accessor.
     *
     * \return Normal data.
     */
    const Vector3& getNormal() const
    {
      return m_normal;
    }

    /** \brief Tell if this face is real.
     *
     * \return True if yes, false if not.
     */
    bool isReal() const
    {
      return m_real;
    }
    /** \brief Set real flag.
     *
     * \param op New real flag.
     */
    void setReal(bool op)
    {
      m_real = op;
    }

  public:
    /** \brief Constructor.
     *
     * \param c1 First corner point.
     * \param c2 Second corner point.
     * \param c3 Third corner point.
     * \param col Color of this face.
     * \param exists Does the face exist?
     */
    Face(unsigned c1, unsigned c2, unsigned c3, const Color &col = Color(255, 255, 255, 255),
        bool exists = true) :
      m_num_corners(3),
      m_color(col),
      m_real(exists)
    {
      m_indices[0] = c1;
      m_indices[1] = c2;
      m_indices[2] = c3;
    }

    /** \brief Constructor.
     *
     * \param c1 First corner point.
     * \param c2 Second corner point.
     * \param c3 Third corner point.
     * \param c4 Fourth corner point.
     * \param col Color of this face.
     * \param exists Does the face exist?
     */
    Face(unsigned c1, unsigned c2, unsigned c3, unsigned c4, const Color &col = Color(255, 255, 255, 255),
        bool exists = true) :
      m_num_corners(4),
      m_color(col),
      m_real(exists)
    {
      m_indices[0] = c1;
      m_indices[1] = c2;
      m_indices[2] = c3;
      m_indices[3] = c4;
    }

  public:
    /** \brief Append to vertex buffer.
     *
     * Does not append index data, only the vertex data.
     *
     * \param buffer Vertex buffer to append to.
     * \param mesh Mesh to get vertex data from.
     * \param near_value Near factor for vertices.
     * \return How many indices were appended?
     */
    unsigned append(VertexBuffer *buffer, const Mesh *mesh, float near_value) const;

    /** \brief Append to vertex buffer.
     *
     * Append both vertex and index data.
     *
     * \param buffer Vertex buffer to append to.
     * \param mesh Mesh to get vertex data from.
     * \param near_value Near factor for vertices.
     * \param index_base Base to add to every index.
     * \return How many indices were appended?
     */
    unsigned append(VertexBuffer *buffer, const Mesh *mesh, float near_value, uint16_t index_base) const;

    /** \brief Calculate normal (from object vertices).
     *
     * \param op Mesh to calculate from.
     */
    void calculateNormal(Mesh *op);

  public:
#if defined(USE_LD)
    /** \brief Print operator.
     *
     * \param lhs Left-hand-side operand.
     * \param rhs Right-hand-side operand.
     * \return Output stream.
     */
    friend std::ostream& operator<<(std::ostream &lhs, const Face &rhs)
    {
      lhs << "[ " << rhs.m_indices[0] << " ; " << rhs.m_indices[1] << " ; " << rhs.m_indices[2];

      if(3 < rhs.m_num_corners)
      {
        lhs << " ; " << rhs.m_indices[3];
      }

      return lhs << " ] | " << rhs.m_normal << " | " << rhs.m_color;
    }
#endif
};

#endif
