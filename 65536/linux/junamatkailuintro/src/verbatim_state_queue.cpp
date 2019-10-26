#include "verbatim_state_queue.hpp"

State* StateQueue::acquireEmpty()
{
  ScopedLock lock(&m_mutex);

  for(;;)
  {
    if(m_terminated)
    {
      return NULL;
    }

    if(NUM_STATES > m_num_states)
    {
      break;
    }

    this->wait();
  }

  return &(m_states[(m_extract + m_num_states) % NUM_STATES]);
}

State* StateQueue::acquireReady()
{
  ScopedLock lock(&m_mutex);

  for(;;)
  {
    if(m_terminated)
    {
      return NULL;
    }

    if(0 < m_num_states)
    {
      break;
    }

#if defined(USE_LD)
    std::cout << "WARNING: state queue empty" << std::endl;
#endif
    this->wait();
  }

  return &(m_states[m_extract]);
}

void StateQueue::finishEmpty(const State *op)
{
  ScopedLock lock(&m_mutex);

  m_last_state = op;
  ++m_num_states;

  this->signal();
}

void StateQueue::finishReady()
{
  ScopedLock lock(&m_mutex);

  m_extract = (m_extract + 1) % NUM_STATES;
  --m_num_states;

  this->signal();
}

