#ifndef VERBATIM_MATRIX_HPP
#define VERBATIM_MATRIX_HPP

#include "verbatim_vector.hpp"

class Matrix3
{
  private:
    /** Matrix data. */
    float m_data[9];

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

    /** \brief Multiply vector.
     *
     * \param rhs Right-hand-side operand.
     * \return Result vector.
     */
    Vector3 operator*(const Vector3 &rhs) const
    {
      return Vector3(m_data[0] * rhs[0] + m_data[3] * rhs[1] + m_data[6] * rhs[2],
          m_data[1] * rhs[0] + m_data[4] * rhs[1] + m_data[7] * rhs[2],
          m_data[2] * rhs[0] + m_data[5] * rhs[1] + m_data[8] * rhs[2]);
    }

  public:
    /** Empty constructor.
     */
    Matrix3() { }

    /** \brief Full constructor.
     *
     * \param op1 First element.
     * \param op2 Second element.
     * \param op3 Third element.
     * \param op4 Fourth element.
     * \param op5 Fifth element.
     * \param op6 Sixth element.
     * \param op7 Seventh element.
     * \param op8 Eight element.
     * \param op9 Ninth element.
     */
    Matrix3(float op1, float op2, float op3, float op4, float op5, float op6, float op7, float op8, float op9)
    {
      m_data[0] = op1;
      m_data[1] = op2;
      m_data[2] = op3;
      m_data[3] = op4;
      m_data[4] = op5;
      m_data[5] = op6;
      m_data[6] = op7;
      m_data[7] = op8;
      m_data[8] = op9;
    }

    /** \brief Matrix constructor from a base.
     *
     * \param x_vec X base vector.
     * \param y_vec Y base vector.
     * \param z_vec Z base vector.
     */
    Matrix3(const Vector3 &x_base, const Vector3 &y_base, const Vector3 &z_base)
    {
      m_data[0] = x_base[0];
      m_data[1] = y_base[0];
      m_data[2] = z_base[0];
      m_data[3] = x_base[1];
      m_data[4] = y_base[1];
      m_data[5] = z_base[1];
      m_data[6] = x_base[2];
      m_data[7] = y_base[2];
      m_data[8] = z_base[2];
    }

  public:
    /** Create zxy rotation matrix in this.
     *
     * @param rx Rotation X.
     * @param ry Rotation Y.
     * @param rz Rotation Z.
     */
    static Matrix3 rotation_zxy(float rx, float ry, float rz);

  public:
    /** \brief Create an identity matrix.
     *
     * \return Result matrix.
     */
    static Matrix3 identity()
    {
      return Matrix3(1.0f, 0.0f, 0.0f,
          0.0f, 1.0f, 0.0f,
          0.0f, 0.0f, 1.0f);
    }

    /** \brief Transpose a matrix.
     *
     * \param op Input matrix.
     * \return Transposed matrix.
     */
    friend Matrix3 transpose(const Matrix3 &op)
    {
      return Matrix3(op[0], op[3], op[6],
          op[1], op[4], op[7],
          op[2], op[5], op[8]);
    }
};

class Matrix4
{
  private:
    /** Matrix data. */
    float m_data[16];

  public:
    /** \brief Accessor.
     *
     * \return Data.
     */
    const float* getData() const
    {
      return m_data;
    }

    /** \brief Get rotation matrix part as 3x3 matrix.
     *
     * \return Rotation matrix part.
     */
    Matrix3 getRotation() const
    {
      return Matrix3(m_data[0], m_data[1], m_data[2],
          m_data[4], m_data[5], m_data[6],
          m_data[8], m_data[9], m_data[10]);
    }

    /** \brief Get translation vector.
     *
     * \return Translation vector part.
     */
    Vector3 getTranslation() const
    {
      return Vector3(m_data[12], m_data[13], m_data[14]);
    }

    /** \brief Access operator.
     *
     * \return Value.
     */
    float& operator[](const int idx)
    {
      return m_data[idx];
    }

    /** \brief Const access operator.
     *
     * \return Value.
     */
    const float& operator[](const int idx) const
    {
      return m_data[idx];
    }

    /** \brief Multiply vector.
     *
     * \param rhs Right-hand-side operand.
     * \return Result vector.
     */
    Vector3 operator*(const Vector3 &rhs) const
    {
      return Vector3(m_data[0] * rhs[0] + m_data[4] * rhs[1] + m_data[8] * rhs[2] + m_data[12],
          m_data[1] * rhs[0] + m_data[5] * rhs[1] + m_data[9] * rhs[2] + m_data[13],
          m_data[2] * rhs[0] + m_data[6] * rhs[1] + m_data[10] * rhs[2] + m_data[14]);
    }

    /** \brief Multiplication operator.
     *
     * \param rhs Right-hand-side operand.
     * \return Result matrix.
     */
    const Matrix4 operator*(const Matrix4 &rhs) const
    {
      Matrix4 ret;

      for(int ii = 0; (ii < 16); ii += 4)
      { 
        for(int jj = 0; (jj < 4); ++jj)
        {
          ret[ii + jj] = m_data[0 + jj] * rhs[ii + 0] +
            m_data[4 + jj] * rhs[ii + 1] +
            m_data[8 + jj] * rhs[ii + 2] +
            m_data[12 + jj] * rhs[ii + 3];
        }
      }

      return ret;
    }

  public:
    /** Empty constructor.
     */
    Matrix4() { }

    /** \brief Constructor.
     *
     * \param op1 First value.
     * \param op2 Second value.
     * \param op3 Third value.
     * \param op4 Fourth value.
     * \param op5 Fifth value.
     * \param op6 Sixth value.
     * \param op7 Seventh value.
     * \param op8 Eighth value.
     * \param op9 Ninth value.
     * \param op10 Tenth value.
     * \param op11 Eleventh value.
     * \param op12 Twelwth value.
     * \param op13 Thirteenth value.
     * \param op14 Foiurteenth value.
     * \param op15 Fifteenth value.
     * \param op16 Sixteenth value.
     */
    Matrix4(float op1, float op2, float op3, float op4, float op5, float op6, float op7, float op8, float op9,
        float op10, float op11, float op12, float op13, float op14, float op15, float op16)
    {
      m_data[0] = op1;
      m_data[1] = op2;
      m_data[2] = op3;
      m_data[3] = op4;
      m_data[4] = op5;
      m_data[5] = op6;
      m_data[6] = op7;
      m_data[7] = op8;
      m_data[8] = op9;
      m_data[9] = op10;
      m_data[10] = op11;
      m_data[11] = op12;
      m_data[12] = op13;
      m_data[13] = op14;
      m_data[14] = op15;
      m_data[15] = op16;
    }

    /** \brief Expansion from 3x3 matrix.
     *
     * \param mat 3x3 Matrix.
     * \param vec Vector part.
     */
    Matrix4(const Matrix3 &mat, const Vector3 &vec)
    {
      m_data[0] = mat[0];
      m_data[1] = mat[1];
      m_data[2] = mat[2];
      m_data[3] = 0.0f;
      m_data[4] = mat[3];
      m_data[5] = mat[4];
      m_data[6] = mat[5];
      m_data[7] = 0.0f;
      m_data[8] = mat[6];
      m_data[9] = mat[7];
      m_data[10] = mat[8];
      m_data[11] = 0.0f;
      m_data[12] = vec[0];
      m_data[13] = vec[1];
      m_data[14] = vec[2];
      m_data[15] = 1.0f;
    }

    /** Empty destructor.
     */
    ~Matrix4() { }

  public:
    /** \brief Create a projection matrix.
     *
     * \param xfov Horizontal field of view in radians.
     * \param width Viewport width.
     * \param height Viewport height.
     * \param znear Near clip plane.
     * \param zfar Near clip plane.
     * \return Result matrix.
     */
    static Matrix4 projection(float xfov, unsigned width, unsigned height, float znear, float zfar);

    /** \brief Create zxy rotation matrix.
     *
     * \param rx Rotation X.
     * \param ry Rotation Y.
     * \param rz Rotation Z.
     * \param translation Translation vector.
     * \return Result matrix.
     */
    static Matrix4 rotation_zxy(float rx, float ry, float rz,
        const Vector3 &translation = Vector3(0.0f, 0.0f, 0.0f));;

    /** \brief Convert to camera matrix.
     *
     * \param op Input matrix.
     * \return View matrix from the given input.
     */
    static Matrix4 viewify(const Matrix4 &op);

  public:
    /** \brief Create an identity matrix.
     *
     * \return Result matrix.
     */
    static Matrix4 identity()
    {
      return Matrix4(1.0f, 0.0f, 0.0f, 0.0f,
          0.0f, 1.0f, 0.0f, 0.0f,
          0.0f, 0.0f, 1.0f, 0.0f,
          0.0f, 0.0f, 0.0f, 1.0f);
    }

    /** \brief Create an animated RT (no scale) storage matrix.
     *
     * \param rx Rotation X.
     * \param ry Rotation Y.
     * \param rz Rotation Z.
     * \param drx Rotation diff X (per frame).
     * \param dry Rotation diff Y (per frame).
     * \param drz Rotation diff Z (per frame).
     * \param pos Position.
     * \return Result matrix.
     */
    static Matrix4 pack_rta(float rx, float ry, float rz, float drx, float dry, float drz, const Vector3 &pos)
    {
      return Matrix4(rx, ry, rz, drx,
          dry, drz, 0.0f, 0.0f,
          0.0f, 0.0f, 0.0f, 0.0f,
          pos[0], pos[1], pos[2], 0.0f);
    }

    /** \brief Unpack an animated RT (storage matrix).
     *
     * Will modify the matrix being unpacked to advance animation.
     *
     * \param transform Matrix storage.
     * \param frame Frame count.
     * \return Normal transformation matrix.
     */
    static Matrix4 unpack_rta(const Matrix4 &transform, unsigned frame)
    {
      if(transform[15] != 0.0f)
      {
        return transform;
      }
      float fidx = static_cast<float>(frame);
      float rx = transform[0] + transform[3] * fidx;
      float ry = transform[1] + transform[4] * fidx;
      float rz = transform[2] + transform[5] * fidx;
      return rotation_zxy(rx, ry, rz, Vector3(transform[12], transform[13], transform[14]));
    }

    /** \brief Create a translation matrix.
     *
     * \param tx X translation.
     * \param ty Y translation.
     * \param tz Z translation.
     * \return Translation matrix
     */
    static Matrix4 translation(float tx, float ty, float tz)
    {
      return Matrix4(1.0f, 0.0f, 0.0f, 0.0f,
          0.0f, 1.0f, 0.0f, 0.0f,
          0.0f, 0.0f, 1.0f, 0.0f,
          tx, ty, tz, 1.0f);
    }
     /** \brief Create a translation matrix.
     *
     * \param pos Position vector.
     * \return Translation matrix
     */
    static Matrix4 translation(const Vector3 &pos)
    {
      return translation(pos[0], pos[1], pos[2]);
    }
    
#if defined(USE_LD)
    /** \brief Print operator.
     *
     * \param lhs Left-hand-side operand.
     * \param rhs Right-hand-side operand.
     * \return Output stream.
     */
    friend std::ostream& operator<<(std::ostream &lhs, const Matrix4 &rhs)
    {
      return lhs << "[ " << rhs[0] << " ;  " << rhs[4] << " ; " << rhs[8] << " ; " << rhs[12] << "\n  " <<
        rhs[1] << " ; " << rhs[5] << " ; " << rhs[9] << " ; " << rhs[13] << "\n  " <<
        rhs[2] << " ; " << rhs[6] << " ; " << rhs[10] << " ; " << rhs[14] << "\n  " <<
        rhs[3] << " ; " << rhs[7] << " ; " << rhs[11] << " ; " << rhs[15] << " ]";
    }
#endif
};

#endif
