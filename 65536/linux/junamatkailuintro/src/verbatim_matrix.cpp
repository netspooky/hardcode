#include "verbatim_matrix.hpp"

Matrix3 Matrix3::rotation_zxy(float rx, float ry, float rz)
{
  float sx = dnload_sinf(rx);
  float sy = dnload_sinf(ry);
  float sz = dnload_sinf(rz);
  float cx = dnload_cosf(rx);
  float cy = dnload_cosf(ry);
  float cz = dnload_cosf(rz);

  return Matrix3(sx * sy * sz + cy * cz,
      sz * cx,
      sx * sz * cy - sy * cz,
      sx * sy * cz - sz * cy,
      cx * cz,
      sx * cy * cz + sy * sz,
      sy * cx,
      -sx,
      cx * cy);
}

Matrix4 Matrix4::projection(float xfov, unsigned width, unsigned height, float znear, float zfar)
{
  float ff = dnload_tanf(static_cast<float>(M_PI * 0.5) - xfov * 0.5f);
  float n_f = 1.0f / (znear - zfar);

  return Matrix4(ff, 0.0f, 0.0f, 0.0f,
      0.0f, ff * (static_cast<float>(width) / static_cast<float>(height)), 0.0f, 0.0f,
      0.0f, 0.0f, (znear + zfar) * n_f, -1.0f,
      0.0f, 0.0f, 2.0f * znear * zfar * n_f, 0.0f);
}

Matrix4 Matrix4::rotation_zxy(float rx, float ry, float rz, const Vector3 &translation)
{
  return Matrix4(Matrix3::rotation_zxy(rx, ry, rz), translation);
}

Matrix4 Matrix4::viewify(const Matrix4 &op)
{
  Matrix3 rotation = transpose(op.getRotation());
  Vector3 translation = rotation * (-op.getTranslation());
  return Matrix4(rotation, translation);
}

