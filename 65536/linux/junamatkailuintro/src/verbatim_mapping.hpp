#ifndef VERBATIM_MAPPING_HPP
#define VERBATIM_MAPPING_HPP

#include "verbatim_realloc.hpp"

/** Mapping class.
 *
 * Intended to transform coordinates between heightfields and "real-world" coordinates.
 */
class Mapping
{
  private:
    /** X start. */
    float m_x0;

    /** X end. */
    float m_x1;

    /** Z start. */
    float m_z0;

    /** Z end. */
    float m_z1;

  public:
    /** \brief Empty constructor.
     */
    Mapping() { }

    /** \brief Constructor.
     *
     * \param x0 X start.
     * \param x1 X end.
     * \param z0 Z start.
     * \param z1 Z end.
     */
    Mapping(float x0, float x1, float z0, float z1) :
      m_x0(x0),
      m_x1(x1),
      m_z0(z0),
      m_z1(z1) { }

  public:
    /** \brief Get relative X coordinate.
     *
     * \param op "Real-world" coordinate.
     * \return Relative X coordinate.
     */
    float getRelativeX(float op) const
    {
      return (op - m_x0) / (m_x1 - m_x0);
    }

    /** \brief Get relative Z coordinate.
     *
     * \param op "Real-world" coordinate.
     * \return Relative Z coordinate.
     */
    float getRelativeZ(float op) const
    {
      return (op - m_z0) / (m_z1 - m_z0);
    }

    /** \brief Get "real-world" X coordinate.
     *
     * \param op Relative coordinate.
     */
    float getX(float op)
    {
      return m_x0 + (m_x1 - m_x0) * op;
    }

    /** \brief Get "real-world" Z coordinate.
     *
     * \param op Relative coordinate.
     */
    float getZ(float op)
    {
      return m_z0 + (m_z1 - m_z0) * op;
    }
};

#endif
