#ifndef VERBATIM_STATE_HPP
#define VERBATIM_STATE_HPP

#include "verbatim_array.hpp"
#include "verbatim_object.hpp"
#include "verbatim_terrain.hpp"

/** \brief State object.
 *
 * State contains information of all objects to render. It can be generated in parallel while actual rendering
 * is being done by the main thread.
 */
class State
{
  private:
    /** Terrain references. */
    Array<TerrainReference> m_terrains;

    /** Object references. */
    Array<ObjectReference> m_objects;

    /** Projection. */
    Matrix4 m_projection;

    /** Camera transform (viewified). */
    Matrix4 m_camera;

    /** Current position (viewified camera does not provide this). */
    Vector3 m_position;

    /** Current speed. */
    Vector3 m_speed;

    /** Camera jitter (x). */
    float m_camera_jitter_x;

    /** Camera jitter (y). */
    float m_camera_jitter_y;

    /** Current frame. */
    unsigned m_frame;

  public:
    /** \brief Accessor.
     *
     * \return Camera jitter X component.
     */
    float getCameraJitterX() const
    {
      return m_camera_jitter_x;
    }

    /** \brief Accessor.
     *
     * \return Camera jitter Y component.
     */
    float getCameraJitterY() const
    {
      return m_camera_jitter_y;
    }

    /** \brief Accessor.
     *
     * \return Camera matrix.
     */
    const Matrix4& getCameraMatrix() const
    {
      return m_camera;
    }

    /** \brief Accessor.
     *
     * \return Frame number.
     */
    unsigned getFrame() const
    {
      return m_frame;
    }
    /** \brief Setter.
     *
     * \param op New frame number.
     */
    void setFrame(unsigned op)
    {
      m_frame = op;
    }

    /** \brief Accessor.
     *
     * \return Current position.
     */
    const Vector3& getPosition() const
    {
      return m_position;
    }
    /** \brief Setter.
     *
     * \return New position.
     */
    void setPosition(const Vector3& op)
    {
      m_position = op;
    }

    /** \brief Accessor.
     *
     * \return Projection matrix.
     */
    const Matrix4& getProjectionMatrix() const
    {
      return m_projection;
    }

    /** \brief Accessor.
     *
     * \return Current speed.
     */
    const Vector3& getSpeed() const
    {
      return m_speed;
    }
    /** \brief Setter.
     *
     * \param op New speed.
     */
    void setSpeed(const Vector3 &op)
    {
      m_speed = op;
    }

  public:
    /** \brief Add a reference to render terrain.
     *
     * \param terrain Terrain information.
     * \param program Program to use.
     * \param transform Transformation matrix to use.
     * \param v1 Control value 1.
     * \param v2 Control value 2.
     */
    void addTerrain(const Terrain *terrain, const Program *program, const Matrix4 &transform, float v1,
        float v2);

    /** \brief Add a reference to render an object.
     *
     * \param object Object to queue for rendering.
     * \param program Program to use for rendering.
     * \param transform Object transformation.
     */
    void addObject(const Object *object, const Program *program, const Matrix4 &transform);

    /** \brief Add everything from an object database.
     *
     * \param db Database.
     * \param program Program to use.
     * \param pos Position to render from.
     */
    void addObjectDatabase(const ObjectDatabase *db, const Program *program, float pos);

    /** \brief Draw this state.
     */
    void draw();

    /** \brief Initialize state for generation.
     *
     * \param projection Projection matrix.
     * \param camera Camera transformation.
     */
    void initialize(const Matrix4 &projection, const Matrix4 &camera);

    /** \brief Set camera jitter.
     *
     * \param prev Previous values.
     * \param amplitude Jitter amplitude.
     */
    void setCameraJitter(const State *prev, float amplitude);

  public:
    /** \brief Add a reference to render an object (wrapper).
     *
     * \param object Object to queue for rendering.
     * \param program Program to use for rendering.
     */
    void addObject(const Object *object, const Program *program)
    {
      this->addObject(object, program, object->unpackTransform(m_frame));
    }
};

#endif
