#include "verbatim_mesh.hpp"

#include "verbatim_program.hpp"
#include "verbatim_vertex_buffer.hpp"

void Mesh::addAngle(const Vector3 &p1, const Vector3 &p2, const Vector3 &p3, float radius, unsigned detail,
    const Color &color, uint8_t existence)
{
  const Color FACE_COLOR(255, 255, 255, 255);
  float fdetail = static_cast<float>(detail);
  Vector3 unit_first = normalize(p1 - p2);
  Vector3 unit_second = normalize(p3 - p2);
  Vector3 right = normalize(cross_product(unit_first, unit_second));
  Vector3 t1_forward = normalize(cross_product(right, unit_first));
  Vector3 t2_forward = normalize(cross_product(unit_second, right));
  Vector3 half = normalize(unit_first + unit_second);
  bool bottom_existence = ((existence & SIDE_BOTTOM) != 0);
  bool top_existence = ((existence & SIDE_TOP) != 0);

  half *= 1.0f / dot_product(t1_forward, half) * radius;
  right *= radius;
  t1_forward *= radius;
  t2_forward *= radius;

  unsigned index_base = static_cast<unsigned>(m_vertices.getSize());

  this->addVertex(p1, color);
  this->addVertex(p3, color);

  for(unsigned ii = 0; (ii < detail); ++ii)
  {
    unsigned prev = ((ii == 0) ? ((detail - 1) * 3) : ((ii - 1) * 3)) + index_base + 2;
    unsigned next = (ii * 3) + index_base + 2;
    float angle = static_cast<float>(ii) / fdetail * static_cast<float>(M_PI * 2.0) +
      static_cast<float>(M_PI) / fdetail;
    float ca = dnload_cosf(angle);
    float sa = dnload_sinf(angle);

    this->addVertex(p1 + ca * right + sa * t1_forward, color);
    this->addVertex(p2 + ca * right + sa * half, color);
    this->addVertex(p3 + ca * right + sa * t2_forward, color);

    this->addFace(prev, next, next + 1, prev + 1);
    this->addFace(prev + 1, next + 1, next + 2, prev + 2);

    this->addFace(index_base + 0, next, prev, FACE_COLOR, bottom_existence);
    this->addFace(index_base + 1, prev + 2, next + 2, FACE_COLOR, top_existence);
  }
}

void Mesh::addBox(const Vector3 &p1, const Vector3 &p2, const Color &color, const Vector3 &forward,
    const Vector3 &up, uint8_t existence)
{
  const Color FACE_COLOR(255, 255, 255, 255);
  Vector3 diagonal = p2 - p1;
  Vector3 unit_forward = normalize(forward);
  Vector3 unit_diagonal = normalize(diagonal);
  Vector3 unit_up = normalize(up);
  bool existence_front = ((existence & SIDE_FRONT) != 0);
  bool existence_back = ((existence & SIDE_BACK) != 0);
  bool existence_bottom = ((existence & SIDE_BOTTOM) != 0);
  bool existence_top = ((existence & SIDE_TOP) != 0);
  bool existence_left = ((existence & SIDE_LEFT) != 0);
  bool existence_right = ((existence & SIDE_RIGHT) != 0);
  bool inverse_order = false;

  if(dot_product(unit_diagonal, unit_up) < 0.0f)
  {
    unit_up = -unit_up;
    inverse_order = !inverse_order;
  }
  if(dot_product(unit_diagonal, unit_forward) < 0.0f)
  {
    unit_forward = -unit_forward;
    inverse_order = !inverse_order;
  }

  Vector3 unit_right = normalize(cross_product(unit_forward, unit_up));
  unit_up = normalize(cross_product(unit_right, unit_forward));

  Matrix3 base(unit_right, unit_up, unit_forward);
  Vector3 transformed_p1 = base * p1;
  Vector3 transformed_p2 = base * p2;

#if defined(USE_LD)
  if(g_debug)
  {
    std::cout << "p1: " << transformed_p1 << "\np2: " << transformed_p2 << std::endl;
  }
#endif

  float width = transformed_p2[0] - transformed_p1[0];
  float height = transformed_p2[1] - transformed_p1[1];

#if defined(USE_LD)
  if(g_debug)
  {
    std::cout << "up" << unit_up << "\nright: " << unit_right << "\nforward: " << unit_forward << std::endl;
    std::cout << "width: " << width << " height: " << height << std::endl;
  }
#endif

  unsigned index_base = static_cast<unsigned>(m_vertices.getSize());

  this->addVertex(p1, color);
  this->addVertex(p1 + width * unit_right, color);
  this->addVertex(p1 + width * unit_right + height * unit_up, color);
  this->addVertex(p1 + height * unit_up, color);
  this->addVertex(p2 - width * unit_right - height * unit_up, color);
  this->addVertex(p2 - height * unit_up, color);
  this->addVertex(p2, color);
  this->addVertex(p2 - width * unit_right, color);

  if(inverse_order)
  {
    this->addFace(Face(index_base + 0, index_base + 3, index_base + 2, index_base + 1, FACE_COLOR,
          existence_front));
    this->addFace(Face(index_base + 4, index_base + 5, index_base + 6, index_base + 7, FACE_COLOR,
          existence_back));
    this->addFace(Face(index_base + 0, index_base + 1, index_base + 5, index_base + 4, FACE_COLOR,
          existence_bottom));
    this->addFace(Face(index_base + 2, index_base + 3, index_base + 7, index_base + 6, FACE_COLOR,
          existence_top));
    this->addFace(Face(index_base + 0, index_base + 4, index_base + 7, index_base + 3, FACE_COLOR,
          existence_left));
    this->addFace(Face(index_base + 1, index_base + 2, index_base + 6, index_base + 5, FACE_COLOR,
          existence_right));
  }
  else
  {
    this->addFace(Face(index_base + 0, index_base + 1, index_base + 2, index_base + 3, FACE_COLOR,
          existence_front));
    this->addFace(Face(index_base + 4, index_base + 7, index_base + 6, index_base + 5, FACE_COLOR,
          existence_back));
    this->addFace(Face(index_base + 0, index_base + 4, index_base + 5, index_base + 1, FACE_COLOR,
          existence_bottom));
    this->addFace(Face(index_base + 2, index_base + 6, index_base + 7, index_base + 3, FACE_COLOR,
          existence_top));
    this->addFace(Face(index_base + 0, index_base + 3, index_base + 7, index_base + 4, FACE_COLOR,
          existence_left));
    this->addFace(Face(index_base + 1, index_base + 5, index_base + 6, index_base + 2, FACE_COLOR,
          existence_right));
  }
}

void Mesh::addCylinder(const Vector3 &p1, const Vector3 &p2, float radius1, float radius2, unsigned detail,
    const Color &color, const Vector3 &up, uint8_t existence)
{
  const Color FACE_COLOR(255, 255, 255, 255);
  float fdetail = static_cast<float>(detail);
  Vector3 unit_forward = normalize(p2 - p1);
  Vector3 unit_up = normalize(up);

  // Might easily degenerate, prevent it.
  if(dnload_fabsf(dot_product(unit_up, unit_forward)) > 0.999f)
  {
    unit_up = Vector3(0.0f, 0.0f, 1.0f);
  }

  Vector3 unit_right = normalize(cross_product(unit_forward, unit_up));
  unit_up = normalize(cross_product(unit_right, unit_forward));

  //std::cout << unit_right << " ; " << unit_up << std::endl;

  unsigned index_base = static_cast<unsigned>(m_vertices.getSize());

  this->addVertex(p1, color);
  this->addVertex(p2, color);

  for(unsigned ii = 0; (ii < detail); ++ii)
  {
    unsigned prev = ((ii == 0) ? ((detail - 1) * 2) : ((ii - 1) * 2)) + index_base + 2;
    unsigned next = (ii * 2) + index_base + 2;
    float angle = static_cast<float>(ii) / fdetail * static_cast<float>(M_PI * 2.0) +
      static_cast<float>(M_PI) / fdetail;
    float ca = dnload_cosf(angle);
    float sa = dnload_sinf(angle);

    this->addVertex(p1 + ca * unit_right * radius1 + sa * unit_up * radius1, color);
    this->addVertex(p2 + ca * unit_right * radius2 + sa * unit_up * radius2, color);

    this->addFace(next, prev, prev + 1, next + 1);

    this->addFace(index_base + 0, prev, next, FACE_COLOR, ((existence & SIDE_FRONT) != 0));
    this->addFace(index_base + 1, next + 1, prev + 1, FACE_COLOR, ((existence & SIDE_BACK) != 0));
  }
}

void Mesh::addCappedCylinder(const Vector3 &p1, const Vector3 &p2, float radius1, float radius2,
    unsigned detail1, unsigned detail2, const Color &color, const Vector3 &up, uint8_t existence)
{
  float fdetail1 = static_cast<float>(detail1);
  float fdetail2 = static_cast<float>(detail2);
  Vector3 unit_forward = normalize(p2 - p1);
  Vector3 unit_up = normalize(up);

  // Might easily degenerate, prevent it.
  if(dnload_fabsf(dot_product(unit_up, unit_forward)) > 0.999f)
  {
    unit_up = Vector3(0.0f, 0.0f, 1.0f);
  }

  Vector3 unit_right = normalize(cross_product(unit_forward, unit_up));
  unit_up = normalize(cross_product(unit_right, unit_forward));

  //std::cout << unit_right << " ; " << unit_up << std::endl;

  unsigned index_base = static_cast<unsigned>(m_vertices.getSize());

  Vector3 tip1 = p1 - (radius1 * unit_forward);
  Vector3 tip2 = p2 + (radius2 * unit_forward);

  if(existence & SIDE_FRONT)
  {
    addVertex(tip1, color);

    // Create vertices for first cap
    for(unsigned jj = 0; jj < detail2; ++jj)
    {
      float t = static_cast<float>(jj+1)/fdetail2;
      float r = dnload_sinf(t * static_cast<float>(M_PI / 2.0)) * radius1;
      Vector3 c = tip1 + (t * t * unit_forward);

      for(unsigned ii = 0; ii < detail1; ++ii)
      {
        float angle = static_cast<float>(ii) / fdetail1 * static_cast<float>(M_PI * 2.0) +
          static_cast<float>(M_PI) / fdetail1;
        float ca = dnload_cosf(angle);
        float sa = dnload_sinf(angle);

        addVertex(c + ca * unit_right * r + sa * unit_up * r, color);
      }
    }

    // Create tip of the cap.
    for(unsigned ii = 0; ii < detail1; ++ii)
    {
      unsigned ii_next = (ii+1) % detail1;
      addFace(index_base, ii+index_base+1, ii_next+index_base+1);
    }

    // The rest of the cap...
    for(unsigned jj = 0; jj < detail2-1; ++jj)
    {
      unsigned local_base = (jj*detail1) + 1 + index_base;
      for(unsigned ii = 0; ii < detail1; ++ii)
      {
        unsigned next1 = (ii+1) % detail1;
        unsigned next2 = next1 + detail1;
        addFace(next2+local_base, next1+local_base, ii+local_base, ii+detail1+local_base);
      }
    }
  }
  else
  {
    for(unsigned ii = 0; ii < detail1; ++ii)
    {
      float angle = static_cast<float>(ii) / fdetail1 * static_cast<float>(M_PI * 2.0) +
        static_cast<float>(M_PI) / fdetail1;
      float ca = dnload_cosf(angle);
      float sa = dnload_sinf(angle);

      addVertex(p1 + ca * unit_right * radius1 + sa * unit_up * radius1, color);
    }
  }

  index_base = static_cast<unsigned>(m_vertices.getSize());

  if(existence & SIDE_BACK)
  {
    // Create vertices for second cap
    for(unsigned jj = 0; jj < detail2; ++jj)
    {
      float t = static_cast<float>(jj)/fdetail2;
      float r = dnload_sinf((1.0f-t) * static_cast<float>(M_PI / 2.0)) * radius2;
      Vector3 c = p2 + (t * unit_forward);

      for(unsigned ii = 0; ii < detail1; ++ii)
      {
        float angle = static_cast<float>(ii) / fdetail1 * static_cast<float>(M_PI * 2.0) +
          static_cast<float>(M_PI) / fdetail1;
        float ca = dnload_cosf(angle);
        float sa = dnload_sinf(angle);

        addVertex(c + ca * unit_right * r + sa * unit_up * r, color);
      }
    }

    addVertex(tip2, color);
  }
  else
  {
    for(unsigned ii = 0; (ii < detail1); ++ii)
    {
      float angle = static_cast<float>(ii) / fdetail1 * static_cast<float>(M_PI * 2.0) +
        static_cast<float>(M_PI) / fdetail1;
      float ca = dnload_cosf(angle);
      float sa = dnload_sinf(angle);

      addVertex(p2 + ca * unit_right * radius2 + sa * unit_up * radius1, color);
    }
  }

  // Mid-part
  for(unsigned ii = 0; ii < detail1; ++ii)
  {
    unsigned index_base2 = index_base - detail1;
    unsigned next = (ii+1) % detail1;
    addFace(index_base2+ii, index_base+ii, index_base+next, index_base2+next);
  }

  if(existence & SIDE_BACK)
  {
    // Faces for the second cap
    for(unsigned jj = 0; jj < detail2-1; ++jj)
    {
      unsigned local_base = (jj*detail1) + index_base;
      for(unsigned ii = 0; ii < detail1; ++ii)
      {
        unsigned next1 = (ii+1) % detail1;
        unsigned next2 = next1 + detail1;
        addFace(next2+local_base, next1+local_base, ii+local_base, ii+detail1+local_base);
      }
    }

    index_base = static_cast<unsigned>(m_vertices.getSize()) - 1;
    unsigned index_base2 = index_base - detail1 - 1;

    // Create tip of the cap.
    for(unsigned ii = 0; ii < detail1; ++ii)
    {
      unsigned next = (ii+1) % detail1;
      addFace(index_base, index_base2+next, index_base2+ii);
    }
  }
}

void Mesh::addElongatedCylinder(const Vector3 &p1, const Vector3 &p2, float radius1, float radius2,
    float length, unsigned detail, const Color &color, const Vector3 &up, uint8_t existence)
{
  Vector3 unit_fw = normalize(p2 - p1);
  Vector3 unit_up = normalize(up);
  Vector3 unit_rt = normalize(cross_product(unit_fw, unit_up));
  bool exists_back =((existence & Mesh::SIDE_BACK) != 0);
  bool exists_front = ((existence & Mesh::SIDE_FRONT) != 0);

  //std::cout << exists_back << " ; " << exists_front << std::endl;

  unsigned index_base = static_cast<unsigned>(m_vertices.getSize());

  this->addVertex(p1, color);
  this->addVertex(p1 + length * unit_up, color);
  this->addVertex(p2, color);
  this->addVertex(p2 + length * unit_up, color);

  for(unsigned ii = 0; (ii <= detail); ++ii)
  {
    float rad = static_cast<float>(ii) / static_cast<float>(detail) * static_cast<float>(M_PI);
    float cr = dnload_cosf(rad);
    float sr = dnload_sinf(rad);
    Vector3 rp1 = cr * unit_rt - sr * unit_fw;
    Vector3 rp2 = cr * unit_rt + sr * unit_fw;

    this->addVertex(p1 + rp1 * radius1, color);
    this->addVertex(p1 + rp1 * radius2 + unit_up * length, color);
    this->addVertex(p2 + rp2 * radius1, color);
    this->addVertex(p2 + rp2 * radius2 + unit_up * length, color);

    if(0 < ii)
    {
      unsigned prev1 = ii * 4 + index_base;
      unsigned curr1 = (ii + 1) * 4 + index_base;
      unsigned prev2 = ii * 4 + index_base + 2;
      unsigned curr2 = (ii + 1) * 4 + index_base + 2;

      this->addFace(prev1, prev1 + 1, curr1 + 1, curr1);
      this->addFace(prev2, curr2, curr2 + 1, prev2 + 1);

      this->addFace(prev1, curr1, index_base, Color(255, 255, 255, 255), exists_front);
      this->addFace(prev1 + 1, index_base + 1, curr1 + 1, Color(255, 255, 255, 255), exists_back);

      this->addFace(prev2, index_base + 2, curr2, Color(255, 255, 255, 255), exists_front);
      this->addFace(prev2 + 1, curr2 + 1, index_base + 3, Color(255, 255, 255, 255), exists_back);
    }
  }

  {
    unsigned base = detail * 4 + 4 + index_base;
    this->addFace(index_base + 4, index_base + 4 + 2, index_base + 4 + 3, index_base + 4 + 1);
    this->addFace(base, base + 1, base + 3, base + 2);

    this->addFace(index_base + 0, base + 0, base  + 2, index_base + 2, Color(255, 255, 255, 255), exists_front);
    this->addFace(index_base + 0, index_base + 2, index_base + 4 + 2, index_base + 4 + 0,
        Color(255, 255, 255, 255), exists_front);

    this->addFace(index_base + 1, index_base + 3, base + 3, base + 1, Color(255, 255, 255, 255), exists_back);
    this->addFace(index_base + 1, index_base + 4 + 1, index_base + 4 + 3, index_base + 3,
        Color(255, 255, 255, 255), exists_back);
  }
}

void Mesh::addSlope(const Vector3 &p1, const Vector3 &p2, const Vector3 &p3, float width, unsigned detail,
    const Color &color, const Vector3 &up)
{
  Vector3 unit_up = normalize(up);
  Vector3 unit_forward = normalize(p2 - p1);
  Vector3 unit_right = normalize(cross_product(unit_forward, unit_up));
  float len = length(p3 - p2);
  Vector3 unit_slope = normalize(p3 - p2);
  Vector3 unit_slope_right = normalize(cross_product(unit_slope, unit_up));

  unsigned index_base = static_cast<unsigned>(m_vertices.getSize());

  this->addVertex(p1 - unit_right * width, color);
  this->addVertex(p1 + unit_right * width, color);

  this->addFace(index_base + 0, index_base + 1, index_base + 3, index_base + 2); 

  for(unsigned ii = 0; (ii <= detail); ++ii)
  {
    float fraction = static_cast<float>(ii) / static_cast<float>(detail);

    Vector3 forward_component = mix(unit_forward * len * fraction, unit_slope * len * fraction, fraction);
    Vector3 right_component = mix(unit_right * width, unit_slope_right * width, fraction);

    this->addVertex(p2 + forward_component - right_component, color);
    this->addVertex(p2 + forward_component + right_component, color);

    unsigned base = index_base + ii * 2;

    this->addFace(base + 0, base + 1, base + 3, base + 2);
  }
}

unsigned Mesh::getPrecalculatedVertexCount() const
{
  unsigned ret = 0;

  for(size_t ii = 0; (ii < m_faces.getSize()); ++ii)
  {
    const Face &vv = m_faces[ii];

    if(vv.isReal())
    {
      ret += vv.getCornerCount();
    }
  }

  return ret;
}

CompiledMesh* Mesh::insert(VertexBuffer *vertex_buffer, float near_value, FaceColorFunction func)
{
  if(!vertex_buffer->fitsVertices(this->getPrecalculatedVertexCount()))
  {
    return NULL;
  }

  this->precalculate(func);

  size_t vertex_base = vertex_buffer->getVertexCount();
  size_t index_base = vertex_buffer->getIndexCount();
  unsigned index_count = 0;

  for(size_t ii = 0; (ii < m_faces.getSize()); ++ii)
  {
    const Face &face = m_faces[ii];

    if(face.isReal())
    {
      index_count += face.append(vertex_buffer, this, near_value,
          static_cast<uint16_t>(vertex_buffer->getVertexCount()));
    }
  }

  return new CompiledMesh(vertex_buffer, vertex_base, vertex_buffer->getVertexCount() - vertex_base,
      index_base, index_count);
}

void Mesh::precalculate(FaceColorFunction func)
{
  for(size_t ii = 0; (ii < m_vertices.getSize()); ++ii)
  {
    m_vertices[ii].clearFaceReferences();
  }

  for(size_t ii = 0; (ii < m_faces.getSize()); ++ii)
  {
    Face &face = m_faces[ii];

    face.calculateNormal(this);

    if(func)
    {
      face.setColor(func(face));
    }

#if defined(USE_LD)
    if(g_debug)
    {
      std::cout << face << std::endl;
    }
#endif
  }

  for(size_t ii = 0; (ii < m_vertices.getSize()); ++ii)
  {
    m_vertices[ii].collapse();
  }
}

void CompiledMesh::use(const Program *op) const
{
  m_vertex_buffer->use(op);
}

