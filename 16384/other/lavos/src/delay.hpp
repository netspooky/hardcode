#ifndef DELAY_HPP
#define DELAY_HPP

#include "common.hpp"
#include "filter.hpp"
#include "parameters.h"

class Delay
{
  public:
    Delay(void);

    void process(float input, float& output_l, float& output_r);
    void process(float inputl, float inputr, float& output_l, float& output_r);
    void setMode(float value);
    void setLevel(float level) { m_level=level; };
    void setFeedback(float feedback) { m_feedback = feedback; };
    void setDelayTime(float delay_time) { m_delay_time = 1+static_cast<int>(g_delay_buffer_size * delay_time); };
    void setLowpassCutoff(float lowpass_cutoff) { m_lowpass_filter_l.setCutoff(lowpass_cutoff); m_lowpass_filter_r.setCutoff(lowpass_cutoff); };
    void setHighpassCutoff(float highpass_cutoff) { m_highpass_filter_l.setCutoff(highpass_cutoff); m_highpass_filter_r.setCutoff(highpass_cutoff); };

  private:
    int m_mode;
    int m_input_index;
    int m_delay_index;
    //	Filter m_lowpass_filter;
    //	Filter m_highpass_filter;
    Filter m_lowpass_filter_l;
    Filter m_highpass_filter_l;
    Filter m_lowpass_filter_r;
    Filter m_highpass_filter_r;
    float m_feedback;
    float m_level;
    int m_delay_time;
    float *m_delay_buffer_l;
    float *m_delay_buffer_r;
};

#endif
