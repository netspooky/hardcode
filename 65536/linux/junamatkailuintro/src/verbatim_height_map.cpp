#include "verbatim_height_map.hpp"

#include "verbatim_mesh.hpp"
#include "verbatim_terrain.hpp"
#include "verbatim_vertex_buffer.hpp"

#include <cfloat>

HeightMap::~HeightMap()
{
  array_delete(m_data);
}

float HeightMap::calculateFloorFactor(const BoundingVolume &op) const
{
  float min_height = getMinimumValueForArea(op);
 
  return min_height - op.getMinY();
}

void HeightMap::clear(unsigned width, unsigned height, float op)
{
  m_width = width;
  m_height = height;
  m_data = array_new(m_data, width * height);

  for(unsigned ii = 0, ee = width * height; (ii < ee); ++ii)
  {
    m_data[ii] = op;
  }
}

bool HeightMap::conflicts(const BoundingVolume &volume, float max_slope) const
{
  float min_height = getMinimumValueForArea(volume);
  float max_height = getMaximumValueForArea(volume);

  //std::cout << "max: " << max_height << " ; min: " << min_height << " ; slope: " << max_slope << std::endl;

  return (max_height - min_height > max_slope);
}

Terrain* HeightMap::createMeshTriangle(VertexBuffer* vertex_buffer, float x0, float x1, float z0, float z1,
    unsigned x_detail, unsigned z_detail, HeightColorFunction height_func, Mesh::FaceColorFunction face_func)
{
  Mesh msh;

  m_mapping = Mapping(x0, x1, z0, z1);

  float x_detail_float = static_cast<float>(x_detail - 1);
  float z_detail_float = static_cast<float>(z_detail - 1);

  for(unsigned ii = 0; (ii < x_detail); ++ii)
  {
    float proportional_x = static_cast<float>(ii) / x_detail_float;

    for(unsigned jj = 0; (jj < z_detail); ++jj)
    {
      float proportional_z = static_cast<float>(jj) / z_detail_float;
      float corrected_x = proportional_x;
      bool odd_triangle = (jj % 2 != 0);

      if(odd_triangle)
      {
        corrected_x += 1.0f / static_cast<float>(x_detail);
      }

      float height = this->getHeight(corrected_x, proportional_z);

      msh.addVertex(m_mapping.getX(corrected_x), height, m_mapping.getZ(proportional_z), height_func(height));

      if((0 < ii) && (z_detail - 1 > jj))
      {
        unsigned prev = (ii - 1) * z_detail + jj;
        unsigned next = ii * z_detail + jj;

        if(odd_triangle)
        {
          msh.addFace(next, prev, next + 1);
          msh.addFace(next + 1, prev, prev + 1);
        }
        else
        {
          msh.addFace(next, prev, prev + 1);
          msh.addFace(next + 1, next, prev + 1);
        }
      }
    }
  }

  return new Terrain(msh.insert(vertex_buffer, face_func), z_detail - 1);
}

void HeightMap::cutDepth(float op)
{
  for(unsigned ii = 0, ee = m_width * m_height; (ii < ee); ++ii)
  {
    if(m_data[ii] < op)
    {
      m_data[ii] = op - dnload_sqrtf(op - m_data[ii]);
    }
  }
}

float HeightMap::getHeight(float px, float pz) const
{
  px = dnload_fmaxf(0.0f, dnload_fminf(1.0f, px));
  pz = dnload_fmaxf(0.0f, dnload_fminf(1.0f, pz));

  unsigned ux = static_cast<unsigned>(px * static_cast<float>(m_width - 1) + 0.5f);
  unsigned uz = static_cast<unsigned>(pz * static_cast<float>(m_height - 1) + 0.5f);

  return m_data[uz * m_width + ux];
}

float HeightMap::getMappedHeight(float px, float pz) const
{
  return this->getHeight(m_mapping.getRelativeX(px), m_mapping.getRelativeZ(pz));
}

float HeightMap::getMaximumValue() const
{
  float ret = -FLT_MAX;

  for(unsigned ii = 0, ee = m_width * m_height; (ii < ee); ++ii)
  {
    ret = dnload_fmaxf(ret, m_data[ii]);
  }

  return ret;
}

float HeightMap::getMaximumValueForArea(const BoundingVolume &op) const
{
  return dnload_fmaxf(this->getMappedHeight(op.getMinX(), op.getMinZ()),
      dnload_fmaxf(this->getMappedHeight(op.getMaxX(), op.getMinZ()),
        dnload_fmaxf(this->getMappedHeight(op.getMinX(), op.getMaxZ()),
          this->getMappedHeight(op.getMaxX(), op.getMaxZ()))));
}

float HeightMap::getMinimumValue() const
{
  float ret = FLT_MAX;

  for(unsigned ii = 0, ee = m_width * m_height; (ii < ee); ++ii)
  {
    ret = dnload_fminf(ret, m_data[ii]);
  }

  return ret;
}

float HeightMap::getMinimumValueForArea(const BoundingVolume &op) const
{
  return dnload_fminf(this->getMappedHeight(op.getMinX(), op.getMinZ()),
      dnload_fminf(this->getMappedHeight(op.getMaxX(), op.getMinZ()),
        dnload_fminf(this->getMappedHeight(op.getMinX(), op.getMaxZ()),
          this->getMappedHeight(op.getMaxX(), op.getMaxZ()))));
}

void HeightMap::filterLowpass(int op)
{
  float* data_copy = array_new(static_cast<float*>(NULL), m_width * m_height);
  int iwidth = static_cast<int>(m_width);
  int iheight = static_cast<int>(m_height);

  for(int jj = 0; (jj < iheight); ++jj)
  {
    for(int ii = 0; (ii < iwidth); ++ii)
    {
      int idx = jj * iwidth + ii;

      data_copy[idx] = 0.0f;
      unsigned elements = 0;

      for(int kk = -op; (kk < op); ++kk)
      {
        for(int ll = -op; (ll < op); ++ll)
        {
          if((ii + kk >= 0) && (ii + kk < iwidth) && (jj + ll >= 0) && (jj + ll < iheight))
          {
            data_copy[idx] += m_data[(jj + ll) * iwidth + ii + kk];
            ++elements;
          }
        }
      }

      data_copy[idx] /= static_cast<float>(elements);
    }
  }

  array_delete(m_data);
  m_data = data_copy;
}

void HeightMap::mapHeight(float y0, float y1)
{
  float y_max = this->getMaximumValue();
  float y_min = this->getMinimumValue();
  float y_diff = y1 - y0;
  float height_diff = y_max - y_min;

  if((y_diff <= 0.0f) || (height_diff <= 0.0f))
  {
    return;
  }

  float y_mul = y_diff / height_diff;

  for(unsigned ii = 0, ee = m_width * m_height; (ii < ee); ++ii)
  {
    m_data[ii] = (m_data[ii] - y_min) * y_mul + y0;
  }

  //std::cout << this->getMinimumValue() << " ; " << this->getMaximumValue() << std::endl;
}

void HeightMap::randomize(float minimum, float maximum, int span)
{
  int iwidth = static_cast<int>(m_width);
  int iheight = static_cast<int>(m_height);
  int imodw = bsd_rand() % span;
  int imodh = bsd_rand() % span;

  // Particularly horrible, but it's precalc so it doesn't matter.
  for(int ii = -span + 1; (ii < iwidth); ++ii)
  {
    for(int jj = -span + 1; (jj < iheight); ++jj)
    {
      if((((ii + imodw) % span) == 0) && (((jj + imodh) % span) == 0))
      {
        float addition = frand(minimum, maximum);

        for(int kk = 0; (kk < span); ++kk)
        {
          int current_x = ii + kk;

          for(int ll = 0; (ll < span); ++ll)
          {
            int current_z = jj + ll;

            if((current_x >= 0) && (current_x < iwidth) && (current_z >= 0) && (current_z < iheight))
            {
              m_data[current_z * iwidth + current_x] += addition;
            }
          }
        }
      }
    }
  }
}

void HeightMap::slopeBack(unsigned slope_begin, unsigned slope_end, unsigned begin_idx, float begin_height,
    unsigned end_idx, float end_height)
{
  for(unsigned jj = slope_begin; (jj < m_height); ++jj)
  {
    float step = static_cast<float>(jj - slope_begin);
    float mul = dnload_fminf(step / static_cast<float>(slope_end - slope_begin), 1.0f);

    for(unsigned ii = 0; (ii < m_width); ++ii)
    {
      float ratio = (static_cast<float>(ii) - static_cast<float>(begin_idx)) /
        static_cast<float>(end_idx - begin_idx);
      float clamped_ratio = dnload_fminf(dnload_fmaxf(ratio, 0.0f), 1.0f);
      float level = begin_height + (end_height - begin_height) * clamped_ratio;
      unsigned idx = jj * m_width + ii;

      m_data[idx] += (level - m_data[idx]) * mul * mul;
    }
  }
}

void HeightMap::slopeFront(float level, unsigned steps)
{
  for(unsigned jj = 0; (jj < steps); ++jj)
  {
    float step = static_cast<float>(jj);
    float mul = step / static_cast<float>(steps);
    float inverse = 1.0f - mul;

    for(unsigned ii = 0; (ii < m_width); ++ii)
    {
      unsigned idx = jj * m_width + ii;

      m_data[idx] += (level - m_data[idx]) * inverse * inverse;
    }
  }
}

void HeightMap::slopeLeft(float level, unsigned steps)
{
  for(unsigned jj = 0; (jj < steps); ++jj)
  {
    float step = static_cast<float>(jj);
    float mul = step / static_cast<float>(steps);
    float inverse = 1.0f - mul;

    for(unsigned ii = 0; (ii < m_height); ++ii)
    {
      unsigned idx = ii * m_width + m_width - jj - 1;

      m_data[idx] += (level - m_data[idx]) * inverse * inverse;
    }
  }
}

