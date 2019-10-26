#include "verbatim_bounding_volume.hpp"

#include "verbatim_matrix.hpp"
#include "verbatim_mesh.hpp"

#include <cfloat>

BoundingVolume::BoundingVolume(const CompiledMesh *msh, const Matrix4 &transform) :
  m_x_min(FLT_MAX),
  m_x_max(-FLT_MAX),
  m_y_min(FLT_MAX),
  m_y_max(-FLT_MAX),
  m_z_min(FLT_MAX),
  m_z_max(-FLT_MAX)
{
  Matrix4 unpacked = Matrix4::unpack_rta(transform, 0);

  for(size_t ii = 0, ee = msh->getVertexCount(); (ii != ee); ++ii)
  {
    Vector3 transformed_vertex = unpacked * msh->getVertex(ii).getPosition();

    m_x_min = dnload_fminf(m_x_min, transformed_vertex[0]);
    m_x_max = dnload_fmaxf(m_x_max, transformed_vertex[0]);
    m_y_min = dnload_fminf(m_y_min, transformed_vertex[1]);
    m_y_max = dnload_fmaxf(m_y_max, transformed_vertex[1]);
    m_z_min = dnload_fminf(m_z_min, transformed_vertex[2]);
    m_z_max = dnload_fmaxf(m_z_max, transformed_vertex[2]);
  }
}

bool BoundingVolume::conflicts(const BoundingVolume &op) const
{
  return !((op.getMinX() > m_x_max) ||
      (op.getMaxX() < m_x_min) ||
      (op.getMinZ() > m_z_max) ||
      (op.getMaxZ() < m_z_min));
}

