#ifndef VERBATIM_REALLOC_HPP
#define VERBATIM_REALLOC_HPP

// Use C++11 exception specification if possible
#if __cplusplus >= 201103L
#define NOEXCEPT noexcept
#else
#define NOEXCEPT throw()
#endif

/** \brief A global new operator using realloc.
 *
 * \param sz Size to allocate.
 * \return Allocated pointer.
 */
void* operator new(size_t sz)
{
  return dnload_realloc(NULL, sz);
}

/** \brief A global delete operator using realloc.
 *
 * \param ptr Pointer to free.
 */
void operator delete(void *ptr) NOEXCEPT
{
  void* ret = dnload_realloc(ptr, 0);
  (void)ret;
}

/** \brief Array new.
 *
 * Replacement for new[].
 *
 * \param ptr Existing ptr (may be NULL).
 * \param count Number of elements to allocate.
 * \return Reallocated ptr.
 */
template <typename T> static inline T* array_new(T* ptr, size_t count)
{
  return static_cast<T*>(dnload_realloc(ptr, sizeof(T) * count));
}

/** \brief Array delete.
 *
 * Replacement for delete[].
 *
 * \param ptr Pointer to free.
 */
static inline void array_delete(void *ptr)
{
  void* ret = dnload_realloc(ptr, 0);
  (void)ret;
}

#endif
