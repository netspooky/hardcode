#ifndef VERBATIM_BOUNDING_VOLUME
#define VERBATIM_BOUNDING_VOLUME

#include "verbatim_realloc.hpp"

// Forward declaration.
class CompiledMesh;
class Matrix4;

/** \brief Bounding volume class.
 *
 * To be absolutely specific, more the limits of an object's extent.
 */
class BoundingVolume
{
  private:
    /** Minimum x value. */
    float m_x_min;

    /** Maximum x value. */
    float m_x_max;

    /** Minimum y value. */
    float m_y_min;

    /** Maximum y value. */
    float m_y_max;

    /** Minimum z value. */
    float m_z_min;

    /** Maximum z value. */
    float m_z_max;

  public:
    /** \brief Accessor.
     *
     * \return Maximum X value.
     */
    float getMaxX() const
    {
      return m_x_max;
    }

    /** \brief Accessor.
     *
     * \return Maximum Z value.
     */
    float getMaxZ() const
    {
      return m_z_max;
    }

    /** \brief Accessor.
     *
     * \return Minimum X value.
     */
    float getMinX() const
    {
      return m_x_min;
    }

    /** \brief Accessor.
     *
     * \return Minimum Y value.
     */
    float getMinY() const
    {
      return m_y_min;
    }

    /** \brief Accessor.
     *
     * \return Minimum X value.
     */
    float getMinZ() const
    {
      return m_z_min;
    }

  public:
    /** \brief Constructor.
     *
     * \param msh Mesh to construct from.
     * \param transform Transform to use.
     */
    BoundingVolume(const CompiledMesh *msh, const Matrix4 &transform);

  public:
    /** \brief Tell if this bounding volume conflicts with another.
     *
     * Does not check conflicts on Y space.
     *
     * \param op Other bounding volume.
     */
    bool conflicts(const BoundingVolume &op) const;
};

#endif
