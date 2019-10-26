#include "verbatim_state.hpp"

void State::addTerrain(const Terrain *terrain, const Program *program, const Matrix4 &transform, float v1,
    float v2)
{
  m_terrains.add(TerrainReference(terrain, program, transform, v1, v2));
}

void State::addObject(const Object *object, const Program *program, const Matrix4 &transform)
{
  m_objects.add(ObjectReference(object, program, m_projection, m_camera, transform));
}

void State::addObjectDatabase(const ObjectDatabase *db, const Program *program, float pos)
{
  const ObjectSearchElement *elem = db->findListing(pos);
  if(elem)
  {
    size_t ii = elem->getOffset();
    size_t ee = ii + elem->getCount();

    //std::cout << pos << " (" << elem->getValue() << "): listing from index " << ii << " to " << ee << std::endl;

    for(; (ii < ee); ++ii)
    {
      const Object *obj = db->getListObject(ii);

      //std::cout << obj->getTransform().getTranslation() << std::endl;

      this->addObject(obj, program);
    }
  }
}

void State::draw()
{
  for(size_t ii = 0; (ii < m_objects.getSize()); ++ii)
  {
    m_objects[ii].draw();
  }
  for(size_t ii = 0; (ii < m_terrains.getSize()); ++ii)
  {
    m_terrains[ii].draw();
  }
}

void State::initialize(const Matrix4 &projection, const Matrix4 &camera)
{
  m_terrains.clear();
  m_objects.clear();

  m_projection = projection;
  m_camera = Matrix4::viewify(camera);
}

void State::setCameraJitter(const State *prev, float amplitude)
{
  const float JITTER_MINIMUM = 0.0009f;
  const float JITTER_MUL = 1.8f;
  const float JITTER_PERSISTENCE = 0.96f;
  float prev_x = prev ? prev->getCameraJitterX() : 0.0f;
  float prev_y = prev ? prev->getCameraJitterY() : 0.0f;
  float amp = dnload_fmaxf(amplitude * JITTER_MUL, JITTER_MINIMUM);

  m_camera_jitter_x = JITTER_PERSISTENCE * prev_x + frand(-amp, amp);
  m_camera_jitter_y = JITTER_PERSISTENCE * prev_y + frand(-amp, amp);
}

