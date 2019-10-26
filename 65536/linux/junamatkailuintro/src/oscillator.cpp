#include "oscillator.hpp"
#include "MIDI2Freq.h"
#include "parameters.h"
#include <limits>

Oscillator::Oscillator(void)
{
#ifdef VSTI
  m_samplerate = 44100.0f;
#endif
  m_tempo = 120.0f;

  m_sync = true;

  m_waveform = k_sine;

  m_startphase = 0.0;
  m_phase=m_startphase;
  m_pitch = 440.0f;
  m_detune = 0.0f;
  m_semi = 0.0f;
  m_pw = 0.0f;
  m_pwm = 0.0f;
  m_pw_mod = 0.0f;
  m_pitch_mod = 0.0f;

  //noise generation
  m_gaussian_noise_constant_a = 0x67452301;
  m_gaussian_noise_constant_c = static_cast<int>(0xefcdab89);
  m_sampleandhold_period=1;
  m_sampleandhold_counter=0;
  m_sample = 0.0f;
  m_fintmax = static_cast<float>(std::numeric_limits<int>::max());

  isActive=false;

  setOscMode(k_oscmode_oscillator);
  setDetune(0.5f);
  setSemi(0.5f);
  setVolume(1.0f);
  setPW(0.5f);
  setPWM(0.0f);
  setPitch(440.0f);

  /* populate bpm denominators
     4 full notes				= BPM / 960 => speed 0
     Dotted 2 full notes			= BPM / 720
     Triplets for 4 full notes	= BPM / 640
     2 full notes				= BPM / 480
     Dotted full note			= BPM / 360
     Triplets for 2 full notes	= BPM / 320
     Full note					= BPM / 240
     Dotted-half note			= BPM / 180
     Triplet-full note			= BPM / 160
     Half note					= BPM / 120
     Dotted-quarter note			= BPM / 90
     Triplet-half note			= BPM / 80
     Quarter note				= BPM / 60
     Dotted-eighth note			= BPM / 45
     Triplet-quarter note		= BPM / 40
     Eighth note					= BPM / 30
     Dotted-sixteenth note		= BPM / 22.5
     Triplet-eighth note			= BPM / 20
     Sixteenth note				= BPM / 15
     Dotted-32th note			= BPM / 11.25
     Triplet-sixteenth note		= BPM / 10
     32th note					= BPM / 7.5
     Dotted-64th note			= BPM / 5.5125
     Triplet-32th note			= BPM / 5
     64th note					= BPM / 3.75
     Dotted-128th note			= BPM / 2.75625
     Triplet-64th note			= BPM / 2.5
     128th note					= BPM / 1.875
     Triplet-128th note			= BPM / 1.25 => speed g_num_bpm_synced_lfo_speeds-1
     */
//TODO: less hardcoding
  m_bpm_denominators[0]=960.0f;
  m_bpm_denominators[1]=720.0f;
  m_bpm_denominators[2]=640.0f;
  m_bpm_denominators[3]=480.0f;
  m_bpm_denominators[4]=360.0f;
  m_bpm_denominators[5]=320.0f;
  m_bpm_denominators[6]=240.0f;
  m_bpm_denominators[7]=180.0f;
  m_bpm_denominators[8]=160.0f;
  m_bpm_denominators[9]=120.0f;
  m_bpm_denominators[10]=90.0f;
  m_bpm_denominators[11]=80.0f;
  m_bpm_denominators[12]=60.0f;
  m_bpm_denominators[13]=45.0f;
  m_bpm_denominators[14]=40.0f;
  m_bpm_denominators[15]=30.0f;
  m_bpm_denominators[16]=22.5f;
  m_bpm_denominators[17]=20.0f;
  m_bpm_denominators[18]=15.0f;
  m_bpm_denominators[19]=11.25f;
  m_bpm_denominators[20]=10.0f;
  m_bpm_denominators[21]=7.5f;
  m_bpm_denominators[22]=5.5125f;
  m_bpm_denominators[23]=5.0f;
  m_bpm_denominators[24]=3.750f;
  m_bpm_denominators[25]=2.75625f;
  m_bpm_denominators[26]=2.5f;
  m_bpm_denominators[27]=1.875f;
  m_bpm_denominators[28]=1.25f;
}

// Used Martin Finke's modified version from http://martin-finke.de/blog/articles/audio-plugins-018-polyblep-oscillator/
// which is based on Tale's polyblep implementation at http://www.kvraudio.com/forum/viewtopic.php?t=375517
float Oscillator::getPolyBLEP(float phase)
{
  float phase_cycle = m_phase_increment / TAU;

  // 0 <= t < 1
  if (phase < phase_cycle) {
    phase /= phase_cycle;
    return static_cast<float>(phase + phase - phase*phase - 1.0f);
  }	
  // -1 < t < 0
  else if (phase > 1.0f - phase_cycle) {
    phase = (phase - 1.0f) / phase_cycle;
    return static_cast<float>(phase*phase + phase + phase + 1.0f);
  }
  // 0 otherwise
  else return 0.0f;
}


float Oscillator::getSample()
{
  if(!isActive)
  {
    return 0.0f;
  }

  float ret_val;

  switch(m_waveform)
  {
    case k_sine:
#if defined(APPROXIMATE_SIN)
      ret_val = common::fast_sin(m_phase);
#else
#if defined(WIN32)
      ret_val = sinf(m_phase);
#else
      ret_val = dnload_sinf(m_phase);
#endif
#endif
      break;

    case k_blepsaw:
      ret_val = (m_phase/PII) - 1.0f;
      ret_val -= getPolyBLEP(m_phase/(TAU));
      break;

    case k_rawtriangle:
      ret_val = -1.0f + (m_phase / PII);
      ret_val = 2.0f * (fabsf(ret_val) - 0.5f);
      break;

    case k_bleppulse:
      ret_val = (m_phase / PII) - 1.0f;
      ret_val -= getPolyBLEP(m_phase / (TAU));
#if defined(ALTERNATIVE_FMODF)
      ret_val += ((TAU - common::mfmodf(m_phase + m_pw + m_pw_mod, TAU)) / PII) - 1.0f;
#else
#if defined(WIN32)
      ret_val += ((TAU - fmodf(m_phase + m_pw + m_pw_mod, TAU)) / PII) - 1.0f;
#else
      ret_val += ((TAU - dnload_fmodf(m_phase + m_pw + m_pw_mod, TAU)) / PII) - 1.0f;
#endif
#endif
      //TODO: figure out the other edge. probably need to modify the blep function
      break;

    case k_blepsquare:
      if (m_phase<PII)
        ret_val = 1.0f;
      else
        ret_val = -1.0f;
      ret_val += getPolyBLEP(m_phase/(TAU));
#if defined(ALTERNATIVE_FMODF)
      ret_val -= getPolyBLEP(common::mfmodf((m_phase/(TAU)) + 0.5f, 1.0f));
#else
#if defined(WIN32)
      ret_val -= getPolyBLEP(fmodf((m_phase / (TAU)) + 0.5f, 1.0f));
#else
      ret_val -= getPolyBLEP(dnload_fmodf((m_phase / (TAU)) + 0.5f, 1.0f));
#endif
#endif
      break;

    case k_noise:
      //lifted from http://www.musicdsp.org/showArchiveComment.php?ArchiveID=216
      m_gaussian_noise_constant_a ^= m_gaussian_noise_constant_c;
      ret_val = static_cast<float>(m_gaussian_noise_constant_c)/m_fintmax;
      m_gaussian_noise_constant_c += m_gaussian_noise_constant_a;
      break;

    case k_sampleandhold:
      m_gaussian_noise_constant_a ^= m_gaussian_noise_constant_c;
      ret_val = static_cast<float>(m_gaussian_noise_constant_c)/m_fintmax;
      m_gaussian_noise_constant_c += m_gaussian_noise_constant_a;

      if(m_sampleandhold_counter<0)
      {
        m_sample = ret_val;
        m_sampleandhold_counter = m_sampleandhold_period;
      }
      else
      {
        ret_val = m_sample;
      }
      m_sampleandhold_counter--;
      break;

    case k_rawsaw:
      ret_val = (m_phase/PII) - 1.0f;
      break;

    case k_rawsquare:
      if (m_phase<PII)
        ret_val = 1.0f;
      else
        ret_val = -1.0f;
      break;

    case k_rawpulse:
      ret_val = (m_phase/PII) - 1.0f;
#if defined(ALTERNATIVE_FMODF)
      ret_val += ((TAU-common::mfmodf(m_phase+m_pw+m_pw_mod,TAU))/PII) - 1.0f;
#else
#if defined(WIN32)
      ret_val += ((TAU - fmodf(m_phase + m_pw + m_pw_mod, TAU)) / PII) - 1.0f;
#else
      ret_val += ((TAU - dnload_fmodf(m_phase + m_pw + m_pw_mod, TAU)) / PII) - 1.0f;
#endif
#endif
      break;

    default:
      ret_val = 0.0f;
      break;
  }


  if(m_oscillator_mode==k_oscmode_lfo)
    m_phase += m_phase_increment*(1+m_pitch_mod);
  else
    m_phase += m_phase_increment;

  //This wraps our phase round, so it's always in the 0->2PI range.
  if(m_phase > (TAU))
#if defined(ALTERNATIVE_FMODF)
    m_phase = common::mfmodf(m_phase, TAU);
#else
#if defined(WIN32)
    m_phase = fmodf(m_phase, TAU);
#else
    m_phase = dnload_fmodf(m_phase, TAU);
#endif
#endif

  common::add_dc(ret_val);
  return ret_val * m_volume;
}

void Oscillator::trigger()
{
  if(m_sync==true)
  {
    m_phase=m_startphase;
  }
  if (m_oscillator_mode == k_oscmode_oscillator)
  {
    setPitch(m_pitch);
  }

  isActive=true;
}

void Oscillator::trigger(float pitch)
{
  if(m_sync==true)
  {
    m_phase=m_startphase;
  }
  setPitch(pitch);
  isActive = true;
}

void Oscillator::trigger(float pitch, float startphase)
{
  if(m_sync==true)
  {
    m_phase = startphase;
  }
  setPitch(pitch);
  isActive = true;
}

void Oscillator::stop()
{
  isActive=false;
}

void Oscillator::setDetune(float detune)
{
  //horrible implementation, there's gotta be a smart and accurate way to do this. works for now.
  //TODO: make pretty
  if(detune >= 0.5f)
  {
    detune *= 2.0f;
    detune -= 1.0f;
    detune *= 0.05946309436f;
    detune += 1.0f;
    m_detune=detune;
  }
  else if(detune < 0.5f)
  {
    detune *= 2.0f;
    detune *= 0.05946309436f;
    detune += 0.94387431268f;
    m_detune=detune;
  }
  setPitch(m_pitch);
}

void Oscillator::setSemi(float semi)
{
  if(semi >= 0.5f)
  {
    semi -= 0.5f;
    semi *= 2.0f;
    semi *= g_osc_semi_range;
    //tempsemi should now have the amount of semitones away from center pitch
#if defined(WIN32)
    m_semi = powf(1.05946309436f, common::croundf(semi));
#else
    m_semi = dnload_powf(1.05946309436f, dnload_roundf(semi));
#endif
  }
  else if(semi < 0.5f)
  {
    semi = 0.5f-semi;
    semi *= 2.0f;
    semi *= g_osc_semi_range;
    //tempsemi should now have the amount of semitones away from center pitch
#if defined(WIN32)
    m_semi = powf(0.94387431268f, common::croundf(semi));
#else
    m_semi = dnload_powf(0.94387431268f, dnload_roundf(semi));
#endif
  }
  setPitch(m_pitch);
}

void Oscillator::setPW(float pw)
{
  m_pw=TAU*pw;
}

void Oscillator::setPWM(float pwm)
{
  m_pwm=pwm;
}

void Oscillator::setPWMod(float value)
{
  m_pw_mod=TAU*m_pwm*value;
  if(m_pw_mod>TAU)
    m_pw_mod-=TAU;
  if(m_pw_mod<0.0f)
    m_pw_mod+=TAU;
}

void Oscillator::setStartphase(float startphase)
{
  if(m_oscillator_mode==k_oscmode_lfo)
  {
    //0-0.5 == synced to trigger, 0.5-1.0 == freerunning
    if(startphase<0.5f)
    {
      m_sync=true;
      m_startphase = TAU*2.0f*startphase;
    }
    else
    {
      m_sync=false;
      m_startphase = TAU*2.0f*(startphase-0.5f);
    }
  }
  else
    m_startphase = TAU*startphase;
}

void Oscillator::setPitch(float pitch)
{
  m_pitch = pitch;
  switch(m_oscillator_mode)
  {
    case k_oscmode_oscillator:
      //limiting to arbitrary audible frequencies
#if !defined(ASSUME_SAFE_RANGES)
      m_pitch=common::cclampf(m_pitch,20.0f,19500.0f);
#endif
      m_sampleandhold_period = static_cast<int>(19500.0f/(m_pitch+0.1f));
#ifdef VSTI
      m_phase_increment = m_pitch*(1.0f + m_pitch_mod) * m_detune * m_semi * (TAU / m_samplerate);
#else
      m_phase_increment = m_pitch*(1.0f + m_pitch_mod) * m_detune * m_semi * (TAU / SAMPLERATE);
#endif
      break;

    case k_oscmode_lfo:
      if(m_pitch>=0.5f)
      {
        m_pitch = (m_pitch*2.0f) - 1.0f;
#if !defined(ASSUME_SAFE_RANGES)
        m_pitch = g_lfo_max_frequency * common::cclampf(m_pitch, 0.0f, 1.0f);
#else
        m_pitch = g_lfo_max_frequency * m_pitch;
#endif
      }
      else
      {
        m_pitch *= 2.0f*static_cast<float>(g_num_bpm_synced_lfo_speeds - 1);
#if !defined(ASSUME_SAFE_RANGES)
        m_pitch = common::cclampf(m_pitch, 0.0f, static_cast<float>(g_num_bpm_synced_lfo_speeds - 1));
#endif
        m_pitch = m_tempo / m_bpm_denominators[common::clrintf(m_pitch)];
      }

      m_sampleandhold_period = static_cast<int>(g_lfo_max_frequency/(m_pitch+1.0f));
#ifdef VSTI
      m_phase_increment = m_pitch * (TAU / m_samplerate);
#else
      m_phase_increment = m_pitch * (TAU / SAMPLERATE);
#endif
      break;

    default:
      m_pitch=common::cclampf(m_pitch,20.0f,19500.0f);
      break;
  }

  if(m_phase_increment<0.0f)
    m_phase_increment=0.0f;
}

void Oscillator::setPitchMod (float value)
{
#if !defined(ASSUME_SAFE_RANGES)
  m_pitch_mod = common::cclamp1f(value);
#else
  m_pitch_mod = value;
#endif
}

void Oscillator::setWaveform (float value)
{
  value *= k_num_waveforms;
  int waveform = common::clrintf(value);
  m_waveform=waveform;
  m_sample=0.0f;
}

