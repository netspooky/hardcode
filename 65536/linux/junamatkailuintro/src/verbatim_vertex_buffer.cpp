#include "verbatim_vertex_buffer.hpp"

const VertexBuffer* VertexBuffer::g_bound_vertex_buffer = NULL;
const VertexBuffer* VertexBuffer::g_programmed_vertex_buffer = NULL;

VertexBuffer::VertexBuffer()
{
  dnload_glGenBuffers(2, m_id_data);
}

void VertexBuffer::bind() const
{
  if(this == g_bound_vertex_buffer)
  {
    return;
  }

  dnload_glBindBuffer(GL_ARRAY_BUFFER, getVertexId());
  dnload_glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, getIndexId());

  g_bound_vertex_buffer = this;
  reset_programmed_vertex_buffer();
}

void VertexBuffer::update(bool indicesEnabled)
{
  if(!indicesEnabled)
  {
    dnload_glDeleteBuffers(1, &(m_id_data[1]));
    m_id_data[1] = 0;
  }

  this->bind();

#if 0
  for(unsigned ii = 0; (ii < m_vertex_count); ++ii)
  {
    std::cout << m_vertex_data[ii] << std::endl;
  }

  for(unsigned ii = 0; (ii < m_index_count); ii += 3)
  {
    std::cout << m_index_data[ii] << ", " << m_index_data[ii + 1] << ", " << m_index_data[ii + 2] << std::endl;
  }
#endif

  dnload_glBufferData(GL_ARRAY_BUFFER, m_vertices.getSizeBytes(), m_vertices.getData(), GL_STATIC_DRAW);
  if(indicesEnabled)
  {
    dnload_glBufferData(GL_ELEMENT_ARRAY_BUFFER, m_indices.getSizeBytes(), m_indices.getData(), GL_STATIC_DRAW);
  }
}

void VertexBuffer::use(const Program *op) const
{
  this->bind();

  if(this == g_programmed_vertex_buffer)
  {
    return;
  }

  op->attribPointer('P', 3, GL_FLOAT, false, sizeof(Vertex),
      static_cast<const uint8_t*>(NULL) + Vertex::POSITION_OFFSET);
  op->attribPointer('N', 4, GL_BYTE, true, sizeof(Vertex),
      static_cast<const uint8_t*>(NULL) + Vertex::NORMAL_OFFSET);
  op->attribPointer('C', 2, GL_UNSIGNED_BYTE, true, sizeof(Vertex),
      static_cast<const uint8_t*>(NULL) + Vertex::COLOR_OFFSET);

  g_programmed_vertex_buffer = this;
}

