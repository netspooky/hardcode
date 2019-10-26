#ifndef VERBATIM_VECTOR_HPP
#define VERBATIM_VECTOR_HPP

#include "verbatim_realloc.hpp"

/** Vector class.
 */
class Vector3
{
  private:
    /** Vector data. */
    float m_data[3];

  public:
    /** \brief Accessor.
     *
     * \return Data.
     */
    const float* getData() const
    {
      return m_data;
    }

    /** \brief Access operator.
     *
     * \return Value.
     */
    float& operator[](size_t idx)
    {
      return m_data[idx];
    }

    /** \brief Const access operator.
     *
     * \return Value.
     */
    const float& operator[](size_t idx) const
    {
      return m_data[idx];
    }

    /** \brief Assignment operator.
     *
     * \param rhs Right-hand-side operand.
     * \return This vector.
     */
    Vector3& operator=(const Vector3 &rhs)
    {
      m_data[0] = rhs[0];
      m_data[1] = rhs[1];
      m_data[2] = rhs[2];
      return *this;
    }

    /** \brief Unary minus operator.
     *
     * \return Result vector.
     */
    Vector3 operator-() const
    {
      return Vector3(-m_data[0], -m_data[1], -m_data[2]);
    }

    /** \brief Substraction operator.
     *
     * \param rhs Right-hand-side operand.
     * \return Result vector.
     */
    Vector3 operator-(const Vector3 &rhs) const
    {
      return Vector3(m_data[0] - rhs[0], m_data[1] - rhs[1], m_data[2] - rhs[2]);
    }

    /** \brief Addition operator.
     *
     * \param rhs Right-hand-side operand.
     */
    Vector3 operator+(const Vector3 &rhs) const
    {
      return Vector3(m_data[0] + rhs[0], m_data[1] + rhs[1], m_data[2] + rhs[2]);
    }

    /** \brief Addition into operator.
     *
     * \param rhs Right-hand-side operand.
     */
    Vector3& operator+=(const Vector3 &rhs)
    {
      m_data[0] += rhs[0];
      m_data[1] += rhs[1];
      m_data[2] += rhs[2];
      return *this;
    }

    /** \brief Multiplication operator.
     *
     * \param rhs Right-hand-side operand.
     * \return Result vector.
     */
    Vector3 operator*(float rhs) const
    {
      return Vector3(m_data[0] * rhs, m_data[1] * rhs, m_data[2] * rhs);
    }

    /** \brief Multiplication into operator.
     *
     * \param rhs Right-hand-side operand.
     */
    Vector3& operator*=(float rhs)
    {
      m_data[0] *= rhs;
      m_data[1] *= rhs;
      m_data[2] *= rhs;
      return *this;
    }

    /** \brief Division operator.
     *
     * \param rhs Right-hand-side operand.
     * \return Result vector.
     */
    Vector3 operator/(float rhs) const
    {
      return (*this) * (1.0f / rhs);
    }

  public:
    /** \brief Empty constructor.
     */
    Vector3() { }

    /** \brief Constructor.
     *
     * \param px X component.
     * \param py Y component.
     * \param pz Z component.
     */
    Vector3(float px, float py, float pz)
    {
      m_data[0] = px;
      m_data[1] = py;
      m_data[2] = pz;
    }

  public:
    /** \brief Cross product.
     *
     * \param lhs Left-hand-side operand.
     * \param rhs Right-hand-side operand.
     * \return Result vector.
     */
    friend Vector3 cross_product(const Vector3 &lhs, const Vector3 &rhs)
    {
      return Vector3(lhs[1] * rhs[2] - lhs[2] * rhs[1],
          lhs[2] * rhs[0] - lhs[0] * rhs[2],
          lhs[0] * rhs[1] - lhs[1] * rhs[0]);
    }

    /** \brief Dot product.
     *
     * \param lhs Left-hand-side operand.
     * \param rhs Right-hand-side operand.
     * \return Result value.
     */
    friend float dot_product(const Vector3 &lhs, const Vector3 &rhs)
    {
      return lhs[0] * rhs[0] + lhs[1] * rhs[1] + lhs[2] * rhs[2];
    }

    /** \brief Calculate vector length.
     *
     * \param op Vector to calculate length on.
     * \return Length of given vector.
     */
    friend float length(const Vector3 &op)
    {
      return dnload_sqrtf(dot_product(op, op));
    }

    /** \brief Mix two vectors.
     *
     * \param lhs Left-hand-side operand.
     * \param rhs Right-hand-side operand.
     * \param ratio Mixing ratio.
     */
    friend Vector3 mix(const Vector3 &lhs, const Vector3 &rhs, float ratio)
    {
      return lhs * (1.0f - ratio) + rhs * ratio;
    }

    /** \brief Normalize a vector.
     *
     * \param op Vector to normalize.
     * \return Result vector.
     */
    friend Vector3 normalize(const Vector3 &op)
    {
      return op / length(op);
    }

    /** \brief Multiplication operator.
     *
     * \param lhs Left-hand-side operand.
     * \param rhs Right-hand-side operand.
     * \return Result vector.
     */
    friend Vector3 operator*(float lhs, const Vector3 &rhs)
    {
      return rhs * lhs;
    }

#if defined(USE_LD)
    /** \brief Print operator.
     *
     * \param lhs Left-hand-side operand.
     * \param rhs Right-hand-side operand.
     * \return Output stream.
     */
    friend std::ostream& operator<<(std::ostream &lhs, const Vector3 &rhs)
    {
      return lhs << "[ " << rhs[0] << " ; " << rhs[1] << " ; " << rhs[2] << " ]";
    }
#endif
};

#endif
