#ifndef VERBATIM_MUTEX_HPP
#define VERBATIM_MUTEX_HPP

#include "verbatim_realloc.hpp"

/** \brief Mutex class.
 */
class Mutex
{
  private:
    /** Actual mutex. */
    SDL_mutex *m_mutex;

  public:
    /** \brief Accessor.
     *
     * \return Inner mutex.
     */
    SDL_mutex* getInnerMutex()
    {
      return m_mutex;
    }

  public:
    /** \brief Constructor.
     */
    Mutex() :
      m_mutex(dnload_SDL_CreateMutex()) { }

    /** \brief Destructor.
     */
    ~Mutex()
    {
      dnload_SDL_DestroyMutex(m_mutex);
    }

  public:
    /** \brief Lock.
     */
    void acquire()
    {
      dnload_SDL_mutexP(m_mutex);
    }

    /** \brief Unlock.
     */
    void release()
    {
      dnload_SDL_mutexV(m_mutex);
    }
};

/** \brief Cond.
 */
class Cond
{
  private:
    /** Actual cond. */
    SDL_cond *m_cond;

  public:
    /** \brief Constructor.
     */
    Cond()
      : m_cond(dnload_SDL_CreateCond()) { }

    /** \brief Destructor.
     */
    ~Cond()
    {
      dnload_SDL_DestroyCond(m_cond);
    }

  public:
    /** \brief Signal the cond.
     */
    void signal()
    {
      dnload_SDL_CondSignal(m_cond);
    }

    /** \brief Wait on cond.
     *
     * \param mutex Mutex (already locked).
     */
    void wait(Mutex *mutex)
    {
      dnload_SDL_CondWait(m_cond, mutex->getInnerMutex());
    }

    /** \brief Wait on cond wrapper.
     *
     * \param mutex Mutex (already locked).
     */
    void wait(Mutex &mutex)
    {
      this->wait(&mutex);
    }
};

/** \brief Scoped lock.
 */
class ScopedLock
{
  private:
    /** Mutex that was locked. */
    Mutex *m_mutex;

  public:
    /** \brief Constructor.
     *
     * Implicitly locks the mutex.
     *
     * \param op Mutex to lock.
     */
    ScopedLock(Mutex *op)
      : m_mutex(op)
    {
      op->acquire();
    }

    /** \brief Destructor.
     *
     * Implicitly unlocks the mutex.
     */
    ~ScopedLock()
    {
      m_mutex->release();
    }
};

/** \brief Thread class.
 */
class Thread
{
  private:
    /** Thread pointer. */
    SDL_Thread* m_thread;

  public:
    /** \brief Constructor.
     *
     * \param func Function to start.
     * \param data Data to pass to the thread.
     */
    Thread(int (*func)(void*), void *data)
      : m_thread(dnload_SDL_CreateThread(func, data)) { }

    /** \brief Destructor.
     *
     * Will implicitly join the thread.
     */
    ~Thread()
    {
      this->join();
    }

  private:
    /** \brief Join the thread.
     */
    void join()
    {
      dnload_SDL_WaitThread(m_thread, NULL);
    }
};

#endif
