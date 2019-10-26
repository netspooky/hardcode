#include "verbatim_face.hpp"

#include "verbatim_mesh.hpp"
#include "verbatim_vertex_buffer.hpp"

/** How much gouraud shading do we want? */
static const float GOURAUD_FACTOR = 0.5f;

/** How much flat shading do we want? */
static const float FLAT_FACTOR = 1.0f - GOURAUD_FACTOR;

unsigned Face::append(VertexBuffer *buffer, const Mesh *mesh, float near_value) const
{
  const LogicalVertex &v1 = mesh->getLogicalVertex(m_indices[0]);
  const LogicalVertex &v2 = mesh->getLogicalVertex(m_indices[1]);
  const LogicalVertex &v3 = mesh->getLogicalVertex(m_indices[2]);
  Vector3 n1 = normalize(v1.getNormal() * GOURAUD_FACTOR + m_normal * FLAT_FACTOR);
  Vector3 n2 = normalize(v2.getNormal() * GOURAUD_FACTOR + m_normal * FLAT_FACTOR);
  Vector3 n3 = normalize(v3.getNormal() * GOURAUD_FACTOR + m_normal * FLAT_FACTOR);

  buffer->addVertex(Vertex(v1.getPosition(), n1, near_value, modulate(v1.getColor(), m_color)));
  buffer->addVertex(Vertex(v2.getPosition(), n2, near_value, modulate(v2.getColor(), m_color)));
  buffer->addVertex(Vertex(v3.getPosition(), n3, near_value, modulate(v3.getColor(), m_color)));

  if(4 <= m_num_corners)
  {
    const LogicalVertex &v4 = mesh->getLogicalVertex(m_indices[3]);
    Vector3 n4 = normalize(v4.getNormal() * GOURAUD_FACTOR + m_normal * FLAT_FACTOR);

    buffer->addVertex(Vertex(v4.getPosition(), n4, near_value, modulate(v4.getColor(), m_color)));

    return 6;
  }

  return 3;
}

unsigned Face::append(VertexBuffer *buffer, const Mesh *mesh, float near_value, uint16_t index_base) const
{
  unsigned ret = this->append(buffer, mesh, near_value);

  buffer->addIndex(static_cast<uint16_t>(index_base + 0));
  buffer->addIndex(static_cast<uint16_t>(index_base + 1));
  buffer->addIndex(static_cast<uint16_t>(index_base + 2));

  if(3 < ret)
  {
    buffer->addIndex(static_cast<uint16_t>(index_base + 2));
    buffer->addIndex(static_cast<uint16_t>(index_base + 3));
    buffer->addIndex(static_cast<uint16_t>(index_base + 0));
  }

  return ret;
}

void Face::calculateNormal(Mesh *op)
{
  LogicalVertex &v1 = op->getLogicalVertex(m_indices[0]);
  LogicalVertex &v2 = op->getLogicalVertex(m_indices[1]);
  LogicalVertex &v3 = op->getLogicalVertex(m_indices[2]);
  const Vector3 &c1 = v1.getPosition();
  const Vector3 &c2 = v2.getPosition();
  const Vector3 &c3 = v3.getPosition();

#if defined(USE_LD)
  if(g_debug)
  {
    std::cout << "corner 1: " << c1 << std::endl;
    std::cout << "corner 2: " << c2 << std::endl;
    std::cout << "corner 3: " << c3 << std::endl;
  }
#endif

  if(4 <= m_num_corners)
  {
    LogicalVertex &v4 = op->getLogicalVertex(m_indices[3]);
    const Vector3 &c4 = v4.getPosition();

#if defined(USE_LD)
    if(g_debug)
    {
      std::cout << "corner 4: " << c4 << std::endl;
    }
#endif

    Vector3 n1 = normalize(cross_product(c2 - c1, c4 - c1));
    Vector3 n2 = normalize(cross_product(c3 - c2, c1 - c2));
    Vector3 n3 = normalize(cross_product(c4 - c3, c2 - c3));
    Vector3 n4 = normalize(cross_product(c1 - c4, c3 - c4));

    m_normal = normalize(n1 + n2 + n3 + n4);

    v4.addFaceReference(this);
  }
  else
  {
    m_normal = normalize(cross_product(c3 - c2, c1 - c2));
  }

  v1.addFaceReference(this);
  v2.addFaceReference(this);
  v3.addFaceReference(this);
}

