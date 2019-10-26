#include "verbatim_terrain.hpp"

/** \brief Comparator for terrain stripes.
 *
 * \param lhs Left-hand-side operand.
 * \param rhs Right-hand-side operand.
 */
static int terrain_stripe_comparator(const void *lhs, const void *rhs)
{
  const TerrainStripe *left = static_cast<const TerrainStripe*>(lhs);
  const TerrainStripe *right = static_cast<const TerrainStripe*>(rhs);

  if(*left < *right)
  {
    return -1;
  }
  if(*right < *left)
  {
    return 1;
  }
  return 0;
}

TerrainStripe::TerrainStripe(const Terrain *terrain, size_t index_begin, size_t index_count) :
  m_min_value(FLT_MAX),
  m_max_value(-FLT_MAX),
  m_min_index(index_begin),
  m_max_index(index_begin + index_count - 1)
{
  const CompiledMesh *msh = terrain->getMesh();

  for(size_t ii = m_min_index, ee = m_max_index; (ii <= ee); ++ii)
  {
    const Vertex &vv = msh->getVertex(ii);

    m_min_value = dnload_fminf(m_min_value, vv.getPosition()[0]);
    m_max_value = dnload_fmaxf(m_max_value, vv.getPosition()[0]);
  }

  //std::cout << "indices: " << m_min_index << " to " << m_max_index << " [ " << m_min_value << " ; " <<
  //  m_max_value << " ]\n";
}

Terrain::Terrain(const CompiledMesh *msh, unsigned detail) :
  m_mesh(msh)
{
  size_t stripe_size = detail * 6;
  size_t stripes = msh->getVertexCount() / stripe_size;

#if defined(USE_LD)
  if(msh->getVertexCount() % detail)
  {
    std::cerr << "vertex count of terrain mesh (" << msh->getVertexCount() <<
      ") is not divisible by stated detail (" << detail << ')' << std::endl;
    terminate_program();
  }
#endif

  for(size_t ii = 0; (ii < stripes); ++ii)
  {
    m_stripes.add(TerrainStripe(this, ii * stripe_size, stripe_size));
  }

  dnload_qsort(m_stripes.getData(), m_stripes.getSize(), sizeof(TerrainStripe), terrain_stripe_comparator);
}

void Terrain::draw(const Program *program, size_t index_start, size_t index_count) const
{
  m_mesh->use(program);

  program->uniform('W', Matrix3::identity());

  dnload_glDrawArrays(GL_TRIANGLES, static_cast<GLint>(index_start), static_cast<GLsizei>(index_count));
}

TerrainReference::TerrainReference(const Terrain *terrain, const Program *program, const Matrix4& transform,
    float v1, float v2) :
  m_terrain(terrain),
  m_program(program),
  m_transform(transform),
  m_index(0),
  m_count(0)
{
  const TerrainStripe *lower_limit = this->bisectAboveEqual(dnload_fminf(v1, v2));
  const TerrainStripe *upper_limit = this->bisectBelowEqual(dnload_fmaxf(v1, v2));

  if(lower_limit && upper_limit)
  {
    size_t index_min = lower_limit->getMinimumIndex();
    size_t index_max = lower_limit->getMaximumIndex();

    if(upper_limit->getMinimumIndex() < index_min)
    {
      index_min = upper_limit->getMinimumIndex();
    }
    if(upper_limit->getMaximumIndex() > index_max)
    {
      index_max = upper_limit->getMaximumIndex();
    }

    m_index = index_min;
    m_count = index_max - index_min + 1;
  }
}

const TerrainStripe* TerrainReference::bisectAboveEqual(float op)
{
  size_t bb = 0;
  size_t ee = m_terrain->getStripeCount() - 1;

  for(;;)
  {
    if(bb + 1 >= ee)
    {
      const TerrainStripe &vv1 = m_terrain->getStripe(bb);
      const TerrainStripe &vv2 = m_terrain->getStripe(ee);

      if(vv1.isAboveEqual(op))
      {
        return &vv1;
      }
      if(vv2.isAboveEqual(op))
      {
        return &vv2;
      }
      return NULL;
    }

    size_t ii = (bb + ee) / 2;
    const TerrainStripe &vv = m_terrain->getStripe(ii);

    if(vv.isAboveEqual(op))
    {
      ee = ii;
    }
    else
    {
      bb = ii;
    }
  }
}

const TerrainStripe* TerrainReference::bisectBelowEqual(float op)
{
  size_t bb = 0;
  size_t ee = m_terrain->getStripeCount() - 1;

  for(;;)
  {
    if(bb + 1 >= ee)
    {
      const TerrainStripe &vv1 = m_terrain->getStripe(bb);
      const TerrainStripe &vv2 = m_terrain->getStripe(ee);

      if(vv2.isBelowEqual(op))
      {
        return &vv2;
      }
      if(vv1.isBelowEqual(op))
      {
        return &vv1;
      }
      return NULL;
    }

    size_t ii = (bb + ee) / 2;
    const TerrainStripe &vv = m_terrain->getStripe(ii);

    if(vv.isBelowEqual(op))
    {
      bb = ii;
    }
    else
    {
      ee = ii;
    }
  }
}

void TerrainReference::draw() const
{
  m_program->use();
  
  m_program->uniform('M', m_transform);
  m_program->uniform('L', normalize(Vector3(1.0f, 1.0f, 1.0f)));

  m_terrain->draw(m_program, m_index, m_count);
}

