#ifndef VERBATIM_HEIGHT_MAP
#define VERBATIM_HEIGHT_MAP

#include "verbatim_mapping.hpp"
#include "verbatim_mesh.hpp"

// Forward declaration.
class Object;
class Terrain;
class VertexBuffer;

/** \brief Height map class.
 *
 * Expresses landscape.
 */
class HeightMap
{
  public:
    /** Color determination function type. */
    typedef Color (*HeightColorFunction)(float);

  private:
    /** Height data. */
    float *m_data;

    /** "Real-world" coordinate mapping. */
    Mapping m_mapping;

    /** Width. */
    unsigned m_width;

    /** Height. */
    unsigned m_height;

  public:
    /** \brief Empty constructor.
     */
    HeightMap() :
      m_data(NULL),
      m_width(0),
      m_height(0) { }

    /** \brief Empty destructor.
     */
    ~HeightMap();

  private:
    /** \brief Get maximum value in the map.
     *
     * \return Largest value found.
     */
    float getMaximumValue() const;

    /** \brief Get maximum value for a bounding volume.
     *
     * \param op Bounding volume.
     * \return Maxmimum area within volume corners.
     */
    float getMaximumValueForArea(const BoundingVolume &op) const;

    /** \brief Get minimum value in the map.
     *
     * \return Smallest value found.
     */
    float getMinimumValue() const;

    /** \brief Get minimum value for a bounding volume.
     *
     * \param op Bounding volume.
     * \return Minimum area within volume corners.
     */
    float getMinimumValueForArea(const BoundingVolume &op) const;

  public:
    /** \brief Calculate floor factor for a bounding volume.
     *
     * \param op Bounding volume.
     * \return Y difference factor to bring the volume to the 'floor'.
     */
    float calculateFloorFactor(const BoundingVolume &op) const;

    /** \brief Initialize the whole map into a value.
     *
     * \param width Width to set the terrain to.
     * \param height Height to set the terrain to.
     * \param op Value to clear to.
     */
    void clear(unsigned width, unsigned height, float op = 0.0f);

    /** \brief Tell if given volume can be added from the height map's perspective.
     *
     * \param volume Volume to check.
     * \param max_slope Maximum height difference to accept.
     * \return True if the object fits, false if not.
     */
    bool conflicts(const BoundingVolume &volume, float max_slope) const;

    /** \brief Export a triangle-style mesh.
     *
     * Do note that both X and Z are expanded into negativity. Y extends upwards.
     *
     * \param vertex_buffer Vertex buffer to insert to.
     * \param x0 X coordinate at origo.
     * \param x1 X coordinate at end.
     * \param z0 Z coordinate at origo.
     * \param z1 Z coordinate at end.
     * \param x_detail X axis detail.
     * \param z_detail Z axis detail.
     * \param func Color determination function.
     * \return Object generated.
     */
    Terrain* createMeshTriangle(VertexBuffer* vertex_buffer, float x0, float x1, float z0, float z1,
        unsigned x_detail, unsigned z_detail, HeightColorFunction height_func,
        Mesh::FaceColorFunction face_func = NULL);

    /** \brief Cut depth off height map.
     *
     * \param op Cut start value.
     */
    void cutDepth(float op);

    /** \brief Apply a naive low-pass filter over the terrain.
     *
     * \param op Kernel size.
     */
    void filterLowpass(int op);

    /** \brief Map the height scale of the height map.
     *
     * \param y0 Y coordinate at minimum value.
     * \param y1 Y coordinate at maximum value.
     */
    void mapHeight(float y0, float y1);

    /** \brief Get height at given relative position.
     *
     * Coordinates outside the area will be clamped.
     *
     * \param px Relative X coordinate.
     * \param pz Relative Z coordinate.
     * \return Height at given position.
     */
    float getHeight(float px, float pz) const;

    /** \brief Get height at given "real-world" position.
     *
     * Coordinates outside the area will be clamped.
     *
     * \param px Relative X coordinate.
     * \param pz Relative Z coordinate.
     * \return Height at given position.
     */
    float getMappedHeight(float px, float pz) const;

    /** \brief Insert random noise into height map.
     *
     * \param minimum Minimum noise value.
     * \param maximum Maximum noise value.
     * \param span Block size.
     */
    void randomize(float minimum, float maximum, int span);

    /** \brief Slope the back of height map to given value.
     *
     * \param slope_begin Index away to start sloping.
     * \param slope_end Index away to end sloping.
     * \param begin_idx Index where to begin decreasing height.
     * \param begin_heigh Height for the first part.
     * \param end_idx Index where to stop decreasing height.
     * \param end_heigh Height for the first part.
     */
    void slopeBack(unsigned slope_begin, unsigned slope_end, unsigned begin_idx, float begin_height,
        unsigned end_idx, float end_height);

    /** \brief Slope front of height map to given value.
     *
     * \param level Level to slope to.
     * \param steps Steps to take to negate slope.
     */
    void slopeFront(float level, unsigned steps);

    /** \brief Slope left side of height map to given value.
     *
     * \param level Level to slope to.
     * \param steps Steps to take to negate slope.
     */
    void slopeLeft(float level, unsigned steps);
};

#endif
