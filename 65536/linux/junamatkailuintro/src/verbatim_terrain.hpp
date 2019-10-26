#ifndef VERBATIM_TERRAIN_HPP
#define VERBATIM_TERRAIN_HPP

#include "verbatim_array.hpp"
#include "verbatim_matrix.hpp"

// Forward declaration.
class Terrain;

/** \brief Terrain indexing class.
 */
class TerrainStripe
{
  private:
    /** Minimum value. */
    float m_min_value;

    /** Maximum value. */
    float m_max_value;

    /** Minimum index. */
    size_t m_min_index;

    /** Maximum index. */
    size_t m_max_index;

  public:
    /** \brief Accessor.
     *
     * \return Maximum index.
     */
    size_t getMaximumIndex() const
    {
      return m_max_index;
    }

    /** \brief Accessor.
     *
     * \return Minimum index.
     */
    size_t getMinimumIndex() const
    {
      return m_min_index;
    }

    /** \brief Accessor.
     *
     * \return Minimum value.
     */
    float getMinimumValue() const
    {
      return m_min_value;
    }

    /** \brief Tell if this stripe is above (or equal to) given limit.
     *
     * \param op Limit.
     * \return True if yes, false if no.
     */
    bool isAboveEqual(float op) const
    {
      return (m_min_value >= op);
    }

    /** \brief Tell if this stripe is below (or equal to) given limit.
     *
     * \param op Limit.
     * \return True if yes, false if no.
     */
    bool isBelowEqual(float op) const
    {
      return (m_max_value <= op);
    }

    /** \brief Less than operator.
     *
     * \param rhs Right-hand-side operand.
     * \return True if this is smaller than rhs.
     */
    bool operator<(const TerrainStripe &rhs) const
    {
      return (m_min_value < rhs.getMinimumValue());
    }

  public:
    /** \brief Constructor.
     *
     * \param terrain Terrain mesh to acquire values from.
     * \param index_begin Where to start calculating.
     * \param index_count How many vertices to read.
     */
    TerrainStripe(const Terrain *terrain, size_t index_begin, size_t index_count);
};

/** \brief Terrain class.
 *
 * Handles terrain objects that are basically glorified vertex buffers.
 */
class Terrain
{
  private:
    /** Terrain index block locations. */
    Array<TerrainStripe> m_stripes;

    /** Compiled mesh referenced. */
    const CompiledMesh *m_mesh;

  public:
    /** \brief Accessor.
     *
     * \return Mesh contained within.
     */
    const CompiledMesh* getMesh() const
    {
      return m_mesh;
    }

    /** \brief Accessor.
     *
     * \param idx Index of stripe to access.
     */
    const TerrainStripe& getStripe(size_t idx) const
    {
      return m_stripes[idx];
    }

    /** \brief Accessor.
     *
     * \return Stripe count.
     */
    size_t getStripeCount() const
    {
      return m_stripes.getSize();
    }

  public:
    /** \brief Constructor.
     *
     * \param msh Compiled mesh.
     * \param detail Detail in one stripe.
     */
    Terrain(const CompiledMesh *msh, unsigned detail);

  public:
    /** \brief Draw selected indices of this terrain.
     *
     * \param program Program to use.
     * \param index_start Index start.
     * \param index_count Index count.
     */
    void draw(const Program *program, size_t index_start, size_t index_count) const;
};

/** \brief Terrain reference.
 */
class TerrainReference
{
  private:
    /** Reference to terrain. */
    const Terrain *m_terrain;

    /** Program. */
    const Program *m_program;

    /** Transformation. */
    Matrix4 m_transform;

    /** Index to render from. */
    size_t m_index;

    /** Number of indices to render. */
    size_t m_count;

  public:
    /** \brief Constructor.
     *
     * The order of values specified does not really matter.
     *
     * \param terrain Terrain to refer.
     * \param transform Transform to use for rendering.
     * \param v1 Value range other end.
     * \param v2 Value range other end.
     */
    TerrainReference(const Terrain *terrain, const Program *program, const Matrix4& transform, float min_value,
        float max_value);

  private:
    /** \brief Bisect first stripe that is above or equal.
     *
     * \param op Value to compare to.
     * \return Stripe found or NULL.
     */
    const TerrainStripe* bisectAboveEqual(float op);

    /** \brief Bisect last stripe that is below or equal.
     *
     * \param op Value to compare to.
     * \return Stripe found or NULL.
     */
    const TerrainStripe* bisectBelowEqual(float op);

  public:
    /** \brief Draw this terrain.
     */
    void draw() const;
};

#endif
