// Voice class, handles generation for a single voice
// Idea and parts of code lifted from Niall Moody's Polyphonic Synth Tutorial at http://www.niallmoody.com/ndcplugs/programming.htm

#include "voice.hpp"
#include "common.hpp"
#include "MIDI2Freq.h"

//----------------------------------------------------------------------------
Voice::Voice():
#ifdef VSTI
  m_samplerate(SAMPLERATE),
#endif
  m_frequency(440.0f),
  m_note(-1),
  m_velocity(0.0f),
  m_pitch_bend(0.5f),
  isActive(false),
  m_filter1_env_mod(0.75f),
  m_filter1_vel_mod(0.75f),
  m_filter2_env_mod(0.75f),
  m_filter2_vel_mod(0.75f),
  m_filter1_keytrack(0.75f),
  m_filter2_keytrack(0.75f),
  m_filter_keytrack_offset_freq(0.0f),
  m_pitch_env_mod(0.0f),
  m_pitchmod_min(0.0f),
  m_pitchmod_max(0.0f),
  m_lfo1_keytrack(0.0f),
  m_lfo2_keytrack(0.0f),
  m_lfo3_keytrack(0.0f),
  m_lfo_keytrack_offset(0.0f),
  m_lfo1_mod_dest(0),
  m_lfo2_mod_dest(0),
  m_lfo3_mod_dest(0),
  m_lfo1_mod_amount(0.0f),
  m_lfo2_mod_amount(0.0f),
  m_lfo3_mod_amount(0.0f),
  m_filter_routing(k_filter_route_serial)
{
  m_lfo1.setOscMode(k_oscmode_lfo);
  m_lfo2.setOscMode(k_oscmode_lfo);
  m_lfo3.setOscMode(k_oscmode_lfo);
  m_lfo1.setWaveform(k_sine);
  m_lfo2.setWaveform(k_sine);
  m_lfo3.setWaveform(k_sine);
  m_lfo1.trigger(0.1f);
  m_lfo2.trigger(0.2f);
  m_lfo3.trigger(0.3f);
}

Voice::~Voice()
{
  noteOff();
}

//----------------------------------------------------------------------------
void Voice::noteOn(int note, float velocity)
{
  if(!isActive)
  {
    m_frequency = MIDI2Freq[note];
    m_filter_keytrack_offset_freq = m_frequency - MIDI2Freq[64];
    m_note = note;
    setPitchModMinMax();

    m_osc1.trigger(m_frequency);
    m_osc2.trigger(m_frequency);
    m_osc3.trigger(m_frequency);
    m_lfo1.setPitchMod(m_lfo1_keytrack*(static_cast<float>(note-64)/64.0f));
    m_lfo2.setPitchMod(m_lfo2_keytrack*(static_cast<float>(note-64)/64.0f));
    m_lfo3.setPitchMod(m_lfo3_keytrack*(static_cast<float>(note-64)/64.0f));
    m_lfo1.trigger();
    m_lfo2.trigger();
    m_lfo3.trigger();
    m_pitch_env.trigger();
    m_amp_env.trigger();
    m_filter_env.trigger();
    isActive = true;
    m_velocity = velocity;
  }
  else
  {
    //retrigger, need to do what we can to avoid pops
    m_frequency = MIDI2Freq[note];
    m_filter_keytrack_offset_freq = m_frequency - MIDI2Freq[64];
    m_note = note;
    setPitchModMinMax();

    m_osc1.trigger(m_frequency);
    m_osc2.trigger(m_frequency);
    m_osc3.trigger(m_frequency);
    m_lfo1.setPitchMod(m_lfo1_keytrack*(static_cast<float>(note-64)/64.0f));
    m_lfo2.setPitchMod(m_lfo2_keytrack*(static_cast<float>(note-64)/64.0f));
    m_lfo3.setPitchMod(m_lfo3_keytrack*(static_cast<float>(note-64)/64.0f));
    m_lfo1.trigger();
    m_lfo2.trigger();
    m_lfo3.trigger();
    m_pitch_env.trigger();
    m_amp_env.trigger();
    m_filter_env.trigger();
    isActive = true;
    m_velocity = velocity;
  }
}

//----------------------------------------------------------------------------
void Voice::noteOff()
{
  m_pitch_env.stop();
  m_amp_env.stop();
  m_filter_env.stop();
}

//----------------------------------------------------------------------------
void Voice::setPitchBend(float val)
{
  if(val>1.0f)
    val=1.0f;
  else if(val<0.0f)
    val=0.0f;
  //Scale pitch bend to +/- 2 semitones.
  if(val >= 0.5f)
  {
    val -= 0.5f;
    val *= 2.0f;
    m_pitch_bend = (MIDI2Freq[m_note+2]-m_frequency) * val;
  }
  else if(val < 0.5f)
  {
    val -= 0.5f;
    val *= 2.0f;
    m_pitch_bend = (m_frequency-MIDI2Freq[m_note-2]) * val;
  }
}

//----------------------------------------------------------------------------
void Voice::setPitchEnvMod(float val)
{
  //Scale pitch mod to +/- the amount of semitones set in parameters.h -> g_pitch_env_range.
  if(val >= 0.5f)
  {
    val -= 0.5f;
    val *= 2.0f;
#if defined(WIN32)
    m_pitch_env_mod = val*(MIDI2Freq[m_note]*powf(1.05946309436f,static_cast<float>(g_pitch_env_range)));
#else
    m_pitch_env_mod = val*(MIDI2Freq[m_note]*dnload_powf(1.05946309436f,static_cast<float>(g_pitch_env_range)));
#endif
  }
  else if(val < 0.5f)
  {
    val -= 0.5f;
    val *= 2.0f;
#if defined(WIN32)
    m_pitch_env_mod = val*(MIDI2Freq[m_note]*powf(0.94387431268f,static_cast<float>(g_pitch_env_range))+MIDI2Freq[m_note]);
#else
    m_pitch_env_mod = val*(MIDI2Freq[m_note]*dnload_powf(0.94387431268f,static_cast<float>(g_pitch_env_range))+MIDI2Freq[m_note]);
#endif
  }
}

//----------------------------------------------------------------------------
void Voice::setPitchModMinMax()
{
#if defined(WIN32)
  m_pitchmod_max = MIDI2Freq[m_note]*powf(1.05946309436f,static_cast<float>(g_pitch_env_range))-MIDI2Freq[m_note];
  m_pitchmod_min = -1.0f*(MIDI2Freq[m_note]*powf(0.94387431268f,static_cast<float>(g_pitch_env_range))-MIDI2Freq[m_note]);
#else
  m_pitchmod_max = MIDI2Freq[m_note]*dnload_powf(1.05946309436f,static_cast<float>(g_pitch_env_range))-MIDI2Freq[m_note];
  m_pitchmod_min = -1.0f*(MIDI2Freq[m_note]*dnload_powf(0.94387431268f,static_cast<float>(g_pitch_env_range))-MIDI2Freq[m_note]);
#endif
}

//----------------------------------------------------------------------------
void Voice::setFilterRouting(float val)
{
  int mode = common::clrintf(val*(k_num_filter_routing_modes-1));
  m_filter_routing = mode;
}

//----------------------------------------------------------------------------
void Voice::setParameter(int parameter, float value)
{
//pass parameters to components affected
//TODO: refactor
  switch(parameter)
  {
    case k_pitchbend:
      setPitchBend(value);
      break;

    case k_filter_routing:
      setFilterRouting(value);
      break;

      //osc1
    case k_osc1_waveform:
      m_osc1.setWaveform(value);
      break;

    case k_osc1_detune:
      m_osc1.setDetune(value);
      break;

    case k_osc1_semi:
      m_osc1.setSemi(value);		
      break;

    case k_osc1_volume:
      m_osc1.setVolume(value);		
      break;

    case k_osc1_pw:
      m_osc1.setPW(value);		
      break;

    case k_osc1_pwm:
      m_osc1.setPWM(value);		
      break;

      //osc2
    case k_osc2_waveform:
      m_osc2.setWaveform(value);
      break;

    case k_osc2_detune:
      m_osc2.setDetune(value);		
      break;

    case k_osc2_semi:
      m_osc2.setSemi(value);		
      break;

    case k_osc2_volume:
      m_osc2.setVolume(value);				
      break;

    case k_osc2_pw:
      m_osc2.setPW(value);		
      break;

    case k_osc2_pwm:
      m_osc2.setPWM(value);		
      break;

      //osc3
    case k_osc3_waveform:
      m_osc3.setWaveform(value);
      break;

    case k_osc3_detune:
      m_osc3.setDetune(value);		
      break;

    case k_osc3_semi:
      m_osc3.setSemi(value);		
      break;

    case k_osc3_volume:
      m_osc3.setVolume(value);				
      break;

    case k_osc3_pw:
      m_osc3.setPW(value);		
      break;

    case k_osc3_pwm:
      m_osc3.setPWM(value);		
      break;

      //all lfos
    case k_tempo:
      m_lfo1.setTempo(value);
      m_lfo2.setTempo(value);
      m_lfo3.setTempo(value);
      break;

      //lfo1
    case k_lfo1_waveform:
      m_lfo1.setWaveform(value);
      break;

    case k_lfo1_speed:
      m_lfo1.setPitch(value);
      break;

    case k_lfo1_startphase:
      m_lfo1.setStartphase(value);
      break;

    case k_lfo1_keytrack:
      m_lfo1_keytrack = (value-0.5f)*2.0f;
      break;

    case k_lfo1_mod_dest:
      m_lfo1_mod_dest = common::clrintf(value*k_num_mod_dests);
      break;

    case k_lfo1_mod_amount:
      m_lfo1_mod_amount = value;
      break;

      //lfo2
    case k_lfo2_waveform:
      m_lfo2.setWaveform(value);
      break;

    case k_lfo2_speed:
      m_lfo2.setPitch(value);
      break;

    case k_lfo2_startphase:
      m_lfo2.setStartphase(value);
      break;

    case k_lfo2_keytrack:
      m_lfo2_keytrack = (value-0.5f)*2.0f;
      break;

    case k_lfo2_mod_dest:
      m_lfo2_mod_dest = common::clrintf(value*k_num_mod_dests);
      break;

    case k_lfo2_mod_amount:
      m_lfo2_mod_amount = value;
      break;

      //lfo3
    case k_lfo3_waveform:
      m_lfo3.setWaveform(value);
      break;

    case k_lfo3_speed:
      m_lfo3.setPitch(value);
      break;

    case k_lfo3_startphase:
      m_lfo3.setStartphase(value);
      break;

    case k_lfo3_keytrack:
      m_lfo3_keytrack = (value-0.5f)*2.0f;
      break;

    case k_lfo3_mod_dest:
      m_lfo3_mod_dest = common::clrintf(value*k_num_mod_dests);
      break;

    case k_lfo3_mod_amount:
      m_lfo3_mod_amount = value;
      break;

      //pitch env
    case k_pitch_env_mod:
      setPitchEnvMod(value);
      break;

    case k_pitch_attack:
      m_pitch_env.setAttack(value);
      break;

    case k_pitch_decay:
      m_pitch_env.setDecay(value);
      break;

    case k_pitch_sustain:
      m_pitch_env.setSustain(value);
      break;

    case k_pitch_release:
      m_pitch_env.setRelease(value);
      break;


      //amp env
    case k_amp_attack:
      m_amp_env.setAttack(value);
      break;

    case k_amp_decay:
      m_amp_env.setDecay(value);
      break;

    case k_amp_sustain:
      m_amp_env.setSustain(value);
      break;

    case k_amp_release:
      m_amp_env.setRelease(value);
      break;

    case k_env_length:
      m_pitch_env.setLength(value);
      m_amp_env.setLength(value);
      m_filter_env.setLength(value);
      break;

      //filter 1
    case k_filter1_mode:
      m_filter1.setMode(value);
      break;

    case k_filter1_cutoff:
      m_filter1.setCutoff(value);
      break;

    case k_filter1_resonance:
      m_filter1.setResonance(value);
      break;

    case k_filter1_keytrack:
      m_filter1_keytrack = (value-0.5f)*2.0f;
      break;

    case k_filter1_env_mod:
      m_filter1_env_mod = (value-0.5f)*2.0f;
      break;

    case k_filter1_vel_mod:
      m_filter1_vel_mod = (value-0.5f)*2.0f;
      break;

    case k_filter1_drive:
      m_filter1.setDrive(value);
      break;

    case k_filter1_output_level:
      m_filter1.setOutputLevel(value);
      break;

      //filter 2
    case k_filter2_mode:
      m_filter2.setMode(value);
      break;

    case k_filter2_cutoff:
      m_filter2.setCutoff(value);
      break;

    case k_filter2_resonance:
      m_filter2.setResonance(value);
      break;

    case k_filter2_keytrack:
      m_filter2_keytrack = (value-0.5f)*2.0f;
      break;

    case k_filter2_env_mod:
      m_filter2_env_mod = (value-0.5f)*2.0f;
      break;

    case k_filter2_vel_mod:
      m_filter2_vel_mod = (value-0.5f)*2.0f;
      break;

    case k_filter2_drive:
      m_filter2.setDrive(value);
      break;

    case k_filter2_output_level:
      m_filter2.setOutputLevel(value);
      break;

      //filter envelope
    case k_filter_attack:
      m_filter_env.setAttack(value);
      break;

    case k_filter_decay:
      m_filter_env.setDecay(value);
      break;

    case k_filter_sustain:
      m_filter_env.setSustain(value);
      break;

    case k_filter_release:
      m_filter_env.setRelease(value);
      break;

    default:
      break;
  }
}

//----------------------------------------------------------------------------
float Voice::getSample()
{
  float retVal;

  float amp_mod = 0.0f;
  float lfopitch_mod = 0.0f;
  float lfopitch_mod_osc1 = 0.0f;
  float lfopitch_mod_osc2 = 0.0f;
  float lfopitch_mod_osc3 = 0.0f;
  float filter1_mod = 0.0f;
  float filter2_mod = 0.0f;
  //this is pretty terrible, probably should find a better way

  float lfo1val = m_lfo1.getSample();
  float lfo2val = m_lfo2.getSample();
  float lfo3val = m_lfo3.getSample();

  switch (m_lfo1_mod_dest)
  {
    case k_mod_dst_pitch:
      lfopitch_mod += m_lfo1_mod_amount * lfo1val;
      break;

    case k_mod_dst_pitch_osc1:
      lfopitch_mod_osc1 += m_lfo1_mod_amount * lfo1val;
      break;

    case k_mod_dst_pitch_osc2:
      lfopitch_mod_osc2 += m_lfo1_mod_amount * lfo1val;
      break;

    case k_mod_dst_pitch_osc3:
      lfopitch_mod_osc3 += m_lfo1_mod_amount * lfo1val;
      break;

    case k_mod_dst_amp:
      amp_mod += m_lfo1_mod_amount * lfo1val;
      break;

    case k_mod_dst_filter1_cutoff:
      filter1_mod += m_lfo1_mod_amount * lfo1val;
      break;

    case k_mod_dst_filter2_cutoff:
      filter2_mod += m_lfo1_mod_amount * lfo1val;
      break;

    case k_mod_dst_pwm:
      m_osc1.setPWMod(m_lfo1_mod_amount * lfo1val);
      m_osc2.setPWMod(m_lfo1_mod_amount * lfo1val);
      m_osc3.setPWMod(m_lfo1_mod_amount * lfo1val);
      break;

    default:
      break;
  }

  switch (m_lfo2_mod_dest)
  {
    case k_mod_dst_pitch:
      lfopitch_mod += m_lfo2_mod_amount * lfo2val;
      break;

    case k_mod_dst_pitch_osc1:
        lfopitch_mod_osc1 += m_lfo2_mod_amount * lfo2val;
        break;

    case k_mod_dst_pitch_osc2:
        lfopitch_mod_osc2 += m_lfo2_mod_amount * lfo2val;
        break;

    case k_mod_dst_pitch_osc3:
        lfopitch_mod_osc3 += m_lfo2_mod_amount * lfo2val;
        break;

    case k_mod_dst_amp:
      amp_mod += m_lfo2_mod_amount * lfo2val;
      break;

    case k_mod_dst_filter1_cutoff:
      filter1_mod += m_lfo2_mod_amount * lfo2val;
      break;

    case k_mod_dst_filter2_cutoff:
      filter2_mod += m_lfo2_mod_amount * lfo2val;
      break;

    case k_mod_dst_pwm:
      m_osc1.setPWMod(m_lfo2_mod_amount * lfo2val);
      m_osc2.setPWMod(m_lfo2_mod_amount * lfo2val);
      m_osc3.setPWMod(m_lfo2_mod_amount * lfo2val);
      break;

    default:
      break;
  }

  switch (m_lfo3_mod_dest)
  {
    case k_mod_dst_pitch:
      lfopitch_mod += m_lfo3_mod_amount * lfo3val;
      break;

    case k_mod_dst_pitch_osc1:
      lfopitch_mod_osc1 += m_lfo1_mod_amount * lfo3val;
      break;

    case k_mod_dst_pitch_osc2:
      lfopitch_mod_osc2 += m_lfo1_mod_amount * lfo3val;
      break;

    case k_mod_dst_pitch_osc3:
      lfopitch_mod_osc3 += m_lfo1_mod_amount * lfo3val;
      break;

    case k_mod_dst_amp:
      amp_mod += m_lfo3_mod_amount * lfo3val;
      break;

    case k_mod_dst_filter1_cutoff:
      filter1_mod += m_lfo3_mod_amount * lfo3val;
      break;

    case k_mod_dst_filter2_cutoff:
      filter2_mod += m_lfo3_mod_amount * lfo3val;
      break;

    case k_mod_dst_pwm:
      m_osc1.setPWMod(m_lfo3_mod_amount * lfo3val);
      m_osc2.setPWMod(m_lfo3_mod_amount * lfo3val);
      m_osc3.setPWMod(m_lfo3_mod_amount * lfo3val);
      break;

    default:
      break;
  }

#if !defined(ASSUME_SAFE_RANGES)
  lfopitch_mod = common::cclamp1f(lfopitch_mod);
#endif
  if (lfopitch_mod < 0.0f)
    lfopitch_mod *= m_pitchmod_min;
  else
    lfopitch_mod *= m_pitchmod_max;

#if !defined(ASSUME_SAFE_RANGES)
  lfopitch_mod_osc1 = common::cclamp1f(lfopitch_mod_osc1);
#endif
  if (lfopitch_mod_osc1 < 0.0f)
    lfopitch_mod_osc1 *= m_pitchmod_min;
  else
    lfopitch_mod_osc1 *= m_pitchmod_max;

#if !defined(ASSUME_SAFE_RANGES)
  lfopitch_mod_osc2 = common::cclamp1f(lfopitch_mod_osc2);
#endif
  if (lfopitch_mod_osc2 < 0.0f)
    lfopitch_mod_osc2 *= m_pitchmod_min;
  else
    lfopitch_mod_osc2 *= m_pitchmod_max;

#if !defined(ASSUME_SAFE_RANGES)
  lfopitch_mod_osc3 = common::cclamp1f(lfopitch_mod_osc3);
#endif
  if (lfopitch_mod_osc3 < 0.0f)
    lfopitch_mod_osc3 *= m_pitchmod_min;
  else
    lfopitch_mod_osc3 *= m_pitchmod_max;

  // when the pitch envelope is at 0.0f the pitch should be unaltered
  float pitch_mod = lfopitch_mod + m_pitch_env_mod*m_pitch_env.getSample() + m_pitch_bend;

  m_osc1.setPitch(m_frequency + pitch_mod + lfopitch_mod_osc1);
  m_osc2.setPitch(m_frequency + pitch_mod + lfopitch_mod_osc2);
  m_osc3.setPitch(m_frequency + pitch_mod + lfopitch_mod_osc3);

  retVal = 0.33f*(m_osc1.getSample() + m_osc2.getSample() + m_osc3.getSample());

#ifdef VSTI
  float filter_keytrack_mod = m_filter_keytrack_offset_freq/(0.5f*m_samplerate);
#else
  float filter_keytrack_mod = m_filter_keytrack_offset_freq/(0.5f*SAMPLERATE);
#endif

  //filter
  m_filter1.setMod(m_filter1_env_mod, m_filter_env.getSample());
  m_filter2.setMod(m_filter2_env_mod, m_filter_env.getSample());

  m_filter1.setStaticMod(m_filter1_vel_mod*(m_velocity)+filter_keytrack_mod*2.0f*m_filter1_keytrack+filter1_mod);
  m_filter2.setStaticMod(m_filter2_vel_mod*(m_velocity)+filter_keytrack_mod*2.0f*m_filter2_keytrack+filter2_mod);

  switch(m_filter_routing)
  {
    default:
    case k_filter_route_serial:
      retVal = m_filter1.process(retVal);
      retVal = m_filter2.process(retVal);
      break;

    case k_filter_route_parallel:
      //TODO: add a mixing value for filter balance?
      retVal = 0.5f * (m_filter1.process(retVal) + m_filter2.process(retVal));
      break;
  }

  //amp envelope has reached the end, setting voice inactive
  if(m_amp_env.isActive()==false)
  {
    isActive=false;
    m_osc1.stop();
    m_osc2.stop();
    m_osc3.stop();
  }

  //Scale according to velocity and return.
#if defined(WIN32)
//  return tanhf(retVal * m_velocity * m_amp_env.getSample() * (1+amp_mod));
  return retVal * m_velocity * m_amp_env.getSample() * (1 + amp_mod);
#else
//  return dnload_tanhf(retVal * m_velocity * m_amp_env.getSample() * (1+m_amp_mod));
  return retVal * m_velocity * m_amp_env.getSample() * (1 + amp_mod);
#endif
}

