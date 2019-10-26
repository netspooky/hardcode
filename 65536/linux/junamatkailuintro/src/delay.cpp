#include "delay.hpp"

/** Maximum number of delay buffers. */
//atm 26 x 1 (reverb) + 2 (stereo delay) buffers
#if defined(USE_REVERB)
#define MAX_DELAY_BUFFERS 28
#else
#define MAX_DELAY_BUFFERS 2
#endif

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
  m_level=1.0f;
#ifdef VSTI
  setSamplerate(44100.0f);
#endif
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

  m_truemono = false;
}

void Delay::init(int params[], int num_params)
{
  int i;
//setting all instrument parameters as defined in the input array
  for(i = 0; i<num_params; i++)
    setParameter(i,static_cast<float>(params[i])/65535.0f);
}

void Delay::setParameter(int parameter, float value)
{
#if !defined(ASSUME_SAFE_RANGES)
  value = common::cclampf(value,0.0f,1.0f);
#endif
  switch(parameter)
  {
    case FX::k_delay_mode:
      setMode(value);
      break;

    case FX::k_delay_mix:
      //dummy
      break;

    case FX::k_delay_time:
      setDelayTime(value);
      break;

    case FX::k_delay_feedback:
      setFeedback(value);
      break;

    case FX::k_delay_lowpass_cutoff:
      setLowpassCutoff(value);
      break;

    case FX::k_delay_highpass_cutoff:
      setHighpassCutoff(value);
      break;

    default:
      break;
  }
}

void Delay::setMode(float value)
{
  value *= k_num_delay_modes;
  m_mode = common::clrintf(value);
}

#ifdef VSTI
void Delay::setSamplerate(float samplerate)
{
	m_samplerate = samplerate;
	m_lowpass_filter_l.setSamplerate(samplerate);
	m_highpass_filter_l.setSamplerate(samplerate);
	m_lowpass_filter_r.setSamplerate(samplerate);
	m_highpass_filter_r.setSamplerate(samplerate);
}
#endif

float Delay::getSampleDelayedBy(int delay)
{
  int index = (m_delay_index - delay) % m_delay_time;
  if(index<0)
    index += m_delay_time;
  common::add_dc(m_delay_buffer_l[index]);
  return m_delay_buffer_l[index];
};

//mono processing for allpass
void Delay::process(float& sample)
{
  float dummy = 0.0f;
  process(sample,dummy,sample,dummy);
}

void Delay::process(float input, float& output_l, float& output_r)
{
  process(input,input,output_l,output_r);
}

void Delay::process(float inputl, float inputr, float &output_l, float& output_r)
{
  common::add_dc(inputl);
  common::add_dc(inputr);
  if (m_truemono)
  {
    float in = inputl * m_level;
    output_l = m_lowpass_filter_l.process(m_delay_buffer_l[m_delay_index]);
    common::add_dc(output_l);
    m_delay_buffer_l[m_delay_index] = 0.707f*(in)+output_l * m_feedback;
    m_delay_index++;
    if (m_delay_index > m_delay_time)
      m_delay_index = 0;
    return;
  }

  float inl = inputl * m_level;
  float inr = inputr * m_level;

  if (m_mode == k_delay_mode_apf)
  {
    output_l = m_delay_buffer_l[m_delay_index] + (inl * -m_feedback);
    m_delay_buffer_l[m_delay_index] = inl + m_feedback * output_l;
  }
  else
  {
    output_l = m_highpass_filter_l.process(m_lowpass_filter_l.process(m_delay_buffer_l[m_delay_index]));
    output_r = m_highpass_filter_r.process(m_lowpass_filter_r.process(m_delay_buffer_r[m_delay_index]));
    common::add_dc(output_l);
    common::add_dc(output_r);

    switch(m_mode)
    {
      case k_delay_mode_mono:
        m_delay_buffer_l[m_delay_index] = 0.707f*(inl+inr) + output_l * m_feedback;
        m_delay_buffer_r[m_delay_index] = 0.707f*(inl+inr) + output_r * m_feedback;
        break;

      case k_delay_mode_stereo:
        m_delay_buffer_l[m_delay_index] = inl + output_l * m_feedback;
        m_delay_buffer_r[m_delay_index] = inr + output_r * m_feedback;
        break;

      case k_delay_mode_pingpong:
        m_delay_buffer_l[m_delay_index] = 0.707f*(inl+inr) + output_r * m_feedback;
        m_delay_buffer_r[m_delay_index] = output_l * m_feedback;
        break;

      case k_delay_mode_cross:
        m_delay_buffer_l[m_delay_index] = inr + output_r * m_feedback;
        m_delay_buffer_r[m_delay_index] = inl + output_l * m_feedback;
        break;

      default:
        m_delay_buffer_l[m_delay_index] = 0.0f;
        m_delay_buffer_r[m_delay_index] = 0.0f;
        break;
    }
  }

  common::add_dc(m_delay_buffer_l[m_delay_index]);
  common::add_dc(m_delay_buffer_r[m_delay_index]);

  m_delay_index++;
  if (m_delay_index > m_delay_time)
    m_delay_index = 0;
}


