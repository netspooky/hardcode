#ifndef VERBATIM_ARRAY_HPP
#define VERBATIM_ARRAY_HPP

#include "verbatim_realloc.hpp"

/** Array template.
 *
 * Think of std::vector, this replacement uses realloc memory management.
 *
 * The array never decreases in size.
 */
template<typename T> class Array
{
  private:
    /** Array data. */
    T *m_data;

    /** Array size. */
    size_t m_size;

    /** Array capacity. */
    size_t m_capacity;

  public:
    /** \brief Accessor.
     *
     * \return Pointer to data.
     */
    T* getData()
    {
      return m_data;
    }

    /** \brief Accessor.
     *
     * \return Pointer to data.
     */
    const T* getData() const
    {
      return m_data;
    }

    /** \brief Get array size.
     *
     * \return Current size.
     */
    size_t getSize() const
    {
      return m_size;
    }

    /** \brief Get byte size.
     *
     * \return Current size in bytes.
     */
    size_t getSizeBytes() const
    {
      return m_size * sizeof(T);
    }

    /** \brief Get last element.
     *
     * \return Last element reference.
     */
    T& getLast()
    {
      return m_data[m_size - 1];
    }

    /** \brief Get last element (const version).
     *
     * \return Last element reference.
     */
    const T& getLast() const
    {
      return m_data[m_size - 1];
    }

    /** \brief Access operator.
     *
     * \return Element reference.
     */
    T& operator[](size_t idx)
    {
      return m_data[idx];
    }

    /** \brief Const access operator.
     *
     * \return Element reference.
     */
    const T& operator[](size_t idx) const
    {
      return m_data[idx];
    }

  public:
    /** \brief Constructor.
     */
    Array() :
      m_data(array_new(static_cast<T*>(NULL), 2)),
      m_size(0),
      m_capacity(2) { }

    /** \brief Destructor.
     */
    ~Array()
    {
      array_delete(m_data);
    }

  public:
    /** \brief Add an element into array.
     *
     * \param op Element to add.
     */
    void add(const T &op)
    {
      if(m_size >= m_capacity)
      {
        m_capacity *= 2;
        m_data = array_new(m_data, m_capacity);
      }
      m_data[m_size] = op;
      ++m_size;
    }

    /** \brief Clear the array.
     *
     * Will NOT resize the array, the capacity will remain.
     */
    void clear()
    {
      m_size = 0;
    }
};

#endif
