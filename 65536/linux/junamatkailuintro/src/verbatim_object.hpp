#ifndef VERBATIM_OBJECT_HPP
#define VERBATIM_OBJECT_HPP

#include "verbatim_array.hpp"
#include "verbatim_bounding_volume.hpp"
#include "verbatim_matrix.hpp"

// Forward declaration.
class CompiledMesh;

/** Renderable object.
 *
 * Includes a reference to a compiled mesh and a transformation.
 */
class Object
{
  private:
    /** Compiled mesh being rendered. */
    const CompiledMesh *m_mesh;

    /** Transformation. */
    Matrix4 m_transform;

    /** Bounding volume. */
    BoundingVolume m_bounding_volume;

    /** Visibility begin area. */
    float m_begin;

    /** Visibility end area. */
    float m_end;

  public:
    /** \brief Access bounding volume.
     *
     * \return Bounding volume reference.
     */
    const BoundingVolume& getBoundingVolume() const
    {
      return m_bounding_volume;
    }

    /** \brief Accessor.
     *
     * \return Compiled mesh.
     */
    const CompiledMesh* getMesh() const
    {
      return m_mesh;
    }

    /** \brief Accessor.
     * 
     * \return Search begin value.
     */
    float getSearchBegin() const
    {
      return m_begin;
    }
    /** \brief Accessor.
     * 
     * \return Search end value.
     */
    float getSearchEnd() const
    {
      return m_end;
    }

    /** \brief Get size of object.
     *
     * X value is used for this calculation.
     *
     * \return Object size in sort axis.
     */
    float getSize() const
    {
      return m_end - m_begin;
    }

    /** \brief Get transform.
     *
     * \return Current transform.
     */
    const Matrix4& getTransform() const
    {
      return m_transform;
    }
    /** \brief Set transform.
     *
     * \param op New transform.
     */
    void setTransform(const Matrix4 &op)
    {
      m_transform = op;
    }
    /** \brief Unpack transform.
     *
     * \param frame Frame index.
     * \return Unpacked SRT matrix.
     */
    Matrix4 unpackTransform(unsigned frame) const
    {
      return Matrix4::unpack_rta(m_transform, frame);
    }

    /** \brief Tell if object is visible at given range.
     *
     * \param op Location.
     */
    bool isVisible(float op) const
    {
      return (m_begin <= op) && (m_end > op);
    }

  public:
    /** \brief Constructor.
     *
     * \param mesh Mesh to attach to.
     */
    Object(const CompiledMesh *mesh, const Matrix4 &transform = Matrix4::identity());

  public:
    /** \brief Draw this object.
     *
     * \param op Program to use for drawing.
     */
    void draw(const Program *op) const;

    /** \brief Tell if this object conflicts with given bounding volume.
     *
     * \param op Volume to test against.
     * \return True if yes, false if no.
     */
    bool conflicts(const BoundingVolume &op) const;

  public:
    /** \param Less than operator.
     *
     * \param rhs Right-hand-side operand.
     * \return True if this is considered smaller than rhs.
     */
    bool operator<(const Object &rhs) const
    {
      return (m_bounding_volume.getMaxZ() > rhs.getBoundingVolume().getMaxZ());
    }
};

/** \brief Object search element.
 */
class ObjectSearchElement
{
  private:
    /** Minimum value (where any kind of change happens). */
    float m_value;

    /** Offset to object listing. */
    size_t m_offset;

    /** Number of objects in this listing. */
    size_t m_count;

  public:
    /** \brief Accessor.
     *
     * \return Count.
     */
    size_t getCount() const
    {
      return m_count;
    }
    /** \brief Setter.
     *
     * \param op New count.
     */
    void setCount(size_t op)
    {
      m_count = op;
    }

    /** \brief Accessor.
     *
     * \return Offset.
     */
    size_t getOffset() const
    {
      return m_offset;
    }
    /** \brief Setter.
     *
     * \param op New offset.
     */
    void setOffset(size_t op)
    {
      m_offset = op;
    }

    /** \brief Accessor.
     *
     * \return Value.
     */
    float getValue() const
    {
      return m_value;
    }

  public:
    /** \brief Constructor.
     *
     * \param op Value.
     */
    ObjectSearchElement(float op) :
      m_value(op) { }

    /** \brief Empty destructor.
     */
    ~ObjectSearchElement() { }

  public:
    /** \param Less than operator.
     *
     * \param rhs Right-hand-side operand.
     * \return True if this is considered smaller than rhs.
     */
    bool operator<(const ObjectSearchElement &rhs) const
    {
      return (m_value < rhs.getValue());
    }
};

/** \brief Object database.
 *
 * Listing of all objects in the whole intro. Arranged thus it's possible, in relatively reasonable time, to
 * decide which ones to draw and which ones not to.
 */
class ObjectDatabase
{
  private:
    /** All objects. */
    Array<Object> m_objects;

    /** Combined object listing array. */
    Array<Object*> m_list;

    /** Search array. */
    Array<ObjectSearchElement> m_search;

  public:
    /** \brief Accessor.
     *
     * \param idx Index of object to access.
     * \return Object reference.
     */
    const Object& getObject(size_t idx) const
    {
      return m_objects[idx];
    }

    /** \brief Accessor.
     *
     * \return Object count.
     */
    size_t getObjectCount() const
    {
      return m_objects.getSize();
    }

    /** \brief Get the Y translation of latest added object.
     *
     * Will not function if no objects added yet.
     *
     * \return Y translation of latest object.
     */
    float getLatestTranslationY() const
    {
      return m_objects[m_objects.getSize() - 1].getTransform()[13];
    }

    /** \brief Accessor.
     *
     * \param idx Index in object listing.
     * \return Object in listing.
     */
    const Object* getListObject(size_t idx) const
    {
      return m_list[idx];
    }

  public:
    /** \brief Empty constructor.
     */
    ObjectDatabase() { }

    /** \brief Empty destructor.
     */
    ~ObjectDatabase() { }

  private:
    /** \brief Tell if a bounding volume conflicts with existing objects.
     *
     * \param volume Volume to insert.
     * \return True if conflicts, false if not.
     */
    bool conflicts(const BoundingVolume &volume) const;

  public:
    /** \brief Add an object (referring to compiled mesh).
     *
     * \param msh Mesh to add.
     * \param transform Transform to use.
     */
    void addObject(const CompiledMesh* msh, const Matrix4 &transform);

    /** \brief Find object search listing for given value.
     *
     * \param op Value to check against.
     * \return Search element found.
     */
    const ObjectSearchElement* findListing(float op) const;

    /** \brief Try to add object with given transform.
     *
     * May fail, in which case object is not added.
     *
     * \param msh Mesh to add.
     * \param transform Transform to use.
     * \param terrain Terrain to investigate.
     * \param max_slope Maximum allowed slope for placing the object.
     * \return True if added, false if not.
     */
    bool tryAddObject(const CompiledMesh* msh, const Matrix4 &transform, const HeightMap *terrain,
        float max_slope);

    /** \brief Sort the object database (if necessary).
     */
    void sort();
};

/** \breif Object reference.
 *
 * As object, but contains both the object's own transformation and the full transformation.
 */
class ObjectReference
{
  private:
    /** The object itself verbatim. */
    const Object *m_object;

    /** Program reference. */
    const Program *m_program;

    /** Object world matrix. */
    Matrix3 m_world;

    /** Full transformation of the object. */
    Matrix4 m_transform;

  public:
    /** \brief Object reference.
     *
     * \param object Object to render.
     * \param program Program to use.
     * \param projection Projection matrix.
     * \param camera Camera matrix.
     * \param transform Object transformation matrix.
     */
    ObjectReference(const Object *object, const Program *program, const Matrix4 &projection,
        const Matrix4 &camera, const Matrix4 &transform) :
      m_object(object),
      m_program(program),
      m_world(transform.getRotation()),
      m_transform(projection * (camera * transform)) { }

  public:
    /** \brief Draw this object reference.
     */
    void draw() const;
};


#endif
