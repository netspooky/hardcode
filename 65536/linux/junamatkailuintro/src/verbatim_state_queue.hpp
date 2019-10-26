#ifndef VERBATIM_STATE_QUEUE
#define VERBATIM_STATE_QUEUE

#include "verbatim_threading.hpp"
#include "verbatim_state.hpp"

/** \brief State queue.
 *
 * Static data only.
 */
class StateQueue
{
  private:
    /** Number of states to store. */
    static const size_t NUM_STATES = 3;

  private:
    /** Mutex. */
    Mutex m_mutex;

    /** Cond. */
    Cond m_cond;

    /** State array. */
    State m_states[NUM_STATES];

    /** Last inserted state. */
    const State *m_last_state;

    /** Current ready state extraction point. */
    unsigned m_extract;

    /** Current number of ready states. */
    unsigned m_num_states;

    /** Terminate flag. */
    bool m_terminated;
    
  public:
    /** \brief Get last state added.
     *
     * \return Last state added to the queue.
     */
    const State* getLastState() const
    {
      return m_last_state;
    }

  public:
    /** \brief Constructor.
     */
    StateQueue() :
      m_extract(0),
      m_num_states(0),
      m_terminated(false) { }

  public:
    /** \brief Acquire one empty state from array.
     *
     * \return State or NULL if array is full.
     */
    State* acquireEmpty();

    /** \brief Acquire one ready state from array.
     *
     * \return State or NULL if no ready states in array.
     */
    State* acquireReady();

    /** \brief Finish an empty state, making it ready.
     *
     * The state must be a previously acquired empty state.
     *
     * \param op State to finish.
     */
    void finishEmpty(const State *op);

    /** \brief Finish the last acquired ready state, making it empty.
     */
    void finishReady();

  private:
    /** \brief Acquire state queue mutex.
     */
    void acquire()
    {
      m_mutex.acquire();
    }

    /** \brief Signal state queue cond.
     */
    void signal()
    {
      m_cond.signal();
    }

    /** \brief Release state queue mutex.
     */
    void release()
    {
      m_mutex.release();
    }

    /** \brief Wait on this queue.
     */
    void wait()
    {
      m_cond.wait(m_mutex);
    }

  public:

    /** \brief Terminate execution.
     */
    void terminate()
    {
      this->acquire();
      m_terminated = true;
      this->signal();
      this->release();
    }
};

#endif
