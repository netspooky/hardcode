#include "delay.hpp"

/** Maximum number of delay buffers. */
#define MAX_DELAY_BUFFERS 20

/** \brief Delay buffers.
 *
 * The delay buffers are too large for stack. Thus, we read them from this global buffer and always take the
 * 'next' one for each delay.
 *
 * I feel bad about this, but what can you do. 
 */
static float g_delay_buffers[MAX_DELAY_BUFFERS][g_delay_buffer_size];

/** Next delay buffer to give. */
static uint8_t current_delay_buffer = 0;

/** \brief Acquire delay buffer.
 *
 * Will also clear the buffer.
 */
static float* get_delay_buffer()
{
  float *ret = g_delay_buffers[current_delay_buffer];

  {
    for(unsigned ii = 0; (ii  < g_delay_buffer_size); ++ii)
    {
      ret[ii] = 0.0f;
    }
  }

  ++current_delay_buffer;
  return ret;
}

Delay::Delay(void)
{
  m_mode=k_delay_mode_off;
  m_level=0.0f;
  m_delay_index=m_input_index=0;
  m_delay_time=1;
  m_feedback=0.0f;
  m_delay_buffer_l = get_delay_buffer();
  m_delay_buffer_r = get_delay_buffer();
  m_lowpass_filter_l.setMode(k_filter_lowpass);
  m_lowpass_filter_l.setCutoff(1.0f);
  m_highpass_filter_l.setMode(k_filter_highpass);
  m_highpass_filter_l.setCutoff(0.0f);
  m_lowpass_filter_r.setMode(k_filter_lowpass);
  m_lowpass_filter_r.setCutoff(1.0f);
  m_highpass_filter_r.setMode(k_filter_highpass);
  m_highpass_filter_r.setCutoff(0.0f);
}

void Delay::setMode(float value)
{
  value *= k_num_delay_modes;
  m_mode = common::clrintf(value);
}

void Delay::process(float input, float &output_l, float& output_r)
{
  process(input,input,output_l,output_r);
}

void Delay::process(float inputl, float inputr, float &output_l, float& output_r)
{
  float inl = m_level*inputl;
  float inr = m_level*inputr;
  //	output_l=m_delay_buffer_l[m_delay_index];
  //	output_r=m_delay_buffer_r[m_delay_index];
  output_l=m_highpass_filter_l.process(m_lowpass_filter_l.process(m_delay_buffer_l[m_delay_index]));
  output_r=m_highpass_filter_r.process(m_lowpass_filter_r.process(m_delay_buffer_r[m_delay_index]));
  switch(m_mode)
  {
    case k_delay_mode_mono:
      m_delay_buffer_l[m_delay_index] = 0.707f*(inl+inr) + output_l * m_feedback;
      m_delay_buffer_r[m_delay_index] = 0.707f*(inl+inr) + output_r * m_feedback;
      break;

//stereo delay not used
//    case k_delay_mode_stereo:
 //     m_delay_buffer_l[m_delay_index] = inl + output_l * m_feedback;
//      m_delay_buffer_r[m_delay_index] = inr + output_r * m_feedback;
//      break;

    case k_delay_mode_pingpong:
      m_delay_buffer_l[m_delay_index] = 0.707f*(inl+inr) + output_r * m_feedback;
      m_delay_buffer_r[m_delay_index] = output_l * m_feedback;
      break;

    case k_delay_mode_cross:
      m_delay_buffer_l[m_delay_index] = inl + output_r * m_feedback;
      m_delay_buffer_r[m_delay_index] = inr + output_l * m_feedback;
      break;

    default:
      m_delay_buffer_l[m_delay_index] = 0.0f;
      m_delay_buffer_r[m_delay_index] = 0.0f;
      break;
  }

  m_delay_index++;
  if (m_delay_index > m_delay_time)
    m_delay_index = 0;
}

