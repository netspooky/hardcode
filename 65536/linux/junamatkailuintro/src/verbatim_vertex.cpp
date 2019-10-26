#include "verbatim_vertex.hpp"

void LogicalVertex::collapse()
{
  const float FACE_CORPOREAL_WEIGHT = 1.0f;
  const float FACE_INCORPOREAL_WEIGHT = 0.05f;
  Vector3 normal(0.0f, 0.0f, 0.0f);

  for(unsigned ii = 0; (ii < m_face_count); ++ii)
  {
    Face* face = m_face_references[ii];

    normal += face->getNormal() * (face->isReal() ? FACE_CORPOREAL_WEIGHT : FACE_INCORPOREAL_WEIGHT);
  }
  m_normal = normalize(normal);
}

