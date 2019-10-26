#include "verbatim_object.hpp"

#include "verbatim_mesh.hpp"

/** \brief Comparator for objects.
 *
 * \param lhs Left-hand-side operand.
 * \param rhs Right-hand-side operand.
 * \return -1 if (lhs < rhs), 1 if (rhs < lhs), 0 if equal.
 */
static int object_comparator(const void *lhs, const void *rhs)
{
  const Object* left = *static_cast<const Object*const*>(lhs);
  const Object* right = *static_cast<const Object*const*>(rhs);

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

/** \brief Comparator for object search elements.
 *
 * \param lhs Left-hand-side operand.
 * \param rhs Right-hand-side operand.
 * \return -1 if (lhs < rhs), 1 if (rhs < lhs), 0 if equal.
 */
static int object_search_comparator(const void *lhs, const void *rhs)
{
  const ObjectSearchElement *left = static_cast<const ObjectSearchElement*>(lhs);
  const ObjectSearchElement *right = static_cast<const ObjectSearchElement*>(rhs);

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

Object::Object(const CompiledMesh *mesh, const Matrix4 &transform) :
  m_mesh(mesh),
  m_transform(transform),
  m_bounding_volume(mesh, transform)
{
  const float VISION_TOLERANCE = 0.5f;
  const float VISION_BIAS_RIGHT = 0.98f;
  const float VISION_BIAS_LEFT = 1.16f;
  float depth_factor = dnload_fabsf(m_bounding_volume.getMinZ());
  float min_x = m_bounding_volume.getMinX();
  float max_x = m_bounding_volume.getMaxX();

  // The object showing values are too strict, work around problems with planar objects.
  if(m_bounding_volume.getMaxZ() - m_bounding_volume.getMinZ() < VISION_TOLERANCE)
  {
    min_x -= VISION_TOLERANCE;
    max_x += VISION_TOLERANCE;
  }

  m_begin = min_x - (depth_factor * VISION_BIAS_RIGHT);
  m_end = max_x + (depth_factor * VISION_BIAS_LEFT);

  //std::cout << "begin: " << m_begin << " ; end: " << m_end << std::endl;
}

bool Object::conflicts(const BoundingVolume &op) const
{
  return m_bounding_volume.conflicts(op);
}

void Object::draw(const Program *op) const
{
  m_mesh->use(op);

  m_mesh->drawElements();
}

void ObjectDatabase::addObject(const CompiledMesh* msh, const Matrix4 &transform)
{
  m_objects.add(Object(msh, transform));

  m_list.clear();
  m_search.clear();
}

bool ObjectDatabase::conflicts(const BoundingVolume &volume) const
{
  for(size_t ii = 0; (ii < m_objects.getSize()); ++ii)
  {
    if(m_objects[ii].conflicts(volume))
    {
      return true;
    }
  }
  return false;
}

const ObjectSearchElement* ObjectDatabase::findListing(float op) const
{
  size_t bb = 0;
  size_t ee = m_search.getSize() - 1;

  for(;;)
  {
    if(bb + 1 >= ee)
    {
      const ObjectSearchElement& vv1 = m_search[bb];
      const ObjectSearchElement& vv2 = m_search[ee];

      if((vv1.getValue() <= op) && (vv2.getValue() > op))
      {
        return &vv1;
      }
      if(vv2.getValue() <= op)
      {
        return &vv2;
      }
      return NULL;
    }

    size_t ii = (bb + ee) / 2;
    const ObjectSearchElement &vv = m_search[ii];

    if(vv.getValue() <= op)
    {
      bb = ii;
    }
    else
    {
      ee = ii;
    }
  }
}

bool ObjectDatabase::tryAddObject(const CompiledMesh* msh, const Matrix4 &transform, const HeightMap *terrain,
    float max_slope)
{
  BoundingVolume volume(msh, transform);

  if(!this->conflicts(volume) && !terrain->conflicts(volume, max_slope))
  {
    float y_difference = terrain->calculateFloorFactor(volume);
    Matrix4 adjusted = transform;

    adjusted[13] += y_difference;

    this->addObject(msh, adjusted);
    return true;
  }
  return false;
}

void ObjectDatabase::sort()
{
  if(0 >= m_search.getSize())
  {
    for(size_t ii = 0; (ii < m_objects.getSize()); ++ii)
    {
      Object &obj = m_objects[ii];

      m_search.add(ObjectSearchElement(obj.getSearchBegin()));
      m_search.add(ObjectSearchElement(obj.getSearchEnd()));
    }

    dnload_qsort(m_search.getData(), m_search.getSize(), sizeof(ObjectSearchElement),
        object_search_comparator);

    for(size_t ii = 0; (ii < m_search.getSize()); ++ii)
    {
      ObjectSearchElement &element = m_search[ii];
      size_t idx = m_list.getSize();
      size_t count = 0;

      for(size_t jj = 0; (jj < m_objects.getSize()); ++jj)
      {
        Object &obj = m_objects[jj];

        if(obj.isVisible(element.getValue()))
        {
          //std::cout << "adding object " << &obj << " ; " << obj.getTransform().getTranslation() << " to block at " << element.getValue() << std::endl;
          m_list.add(&obj);
          ++count;
        }
      }

      //std::cout << "value " << element.getValue() << ": offset " << idx << " ; count: " << count << std::endl;
      element.setOffset(idx);
      element.setCount(count);

      dnload_qsort(m_list.getData() + idx, count, sizeof(Object*), object_comparator);
    }
  }
}

void ObjectReference::draw() const
{
  m_program->use();

  m_program->uniform('W', m_world);
  m_program->uniform('M', m_transform);

  m_object->draw(m_program);
}

