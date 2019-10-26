#include "filter.hpp"
#include "common.hpp"
#include "parameters.h"

Filter::Filter(void)
{
  m_resonance = static_cast<float>(ONE_OVER_SQRT2);
  m_r2 = 1/m_resonance;
  m_h = 0.5f;
  m_c_low=m_c_band=m_c_high=0.0f;
  setMode(0.0f);
  setCutoff(0.5f);
  setMod(0.0f,0.0f);
  setBandwidth(2.0f);
  setDrive(0.0f);
  m_staticmod = 0.0f;
  setOutputLevel(1.0f);
  m_cutoff = 0.0f;
  calculateCoefficients();
  reset(); 
}

void Filter::setMod(float amount, float modifier)
{
  // amount (envmod) range is from -100% to 100% [-1.0,1.0]
  // modifier (envelope) range is [0.0,1.0] where 0.0 should be base freq

  //clamp
  amount = common::cclamp1f(amount);

  m_mod = amount * modifier;
  calculateCoefficients();
}

void Filter::setStaticMod(float amount)
{
  //clamp
  amount = common::cclamp1f(amount);

  m_staticmod = amount;
  calculateCoefficients();
}

// Sets the characteristic frequency (which is the cutoff-frequency for lowpass and highpass,
// the center-frequency for bandpass, bandreject and bell, and the halfgain-frequency for
// shelvers).

void Filter::setCutoff(float cutoff)
{
  //not sure if this is needed here, should probably profile at some point
  m_base_freq = cutoff * cutoff;
  calculateCoefficients();
}

// Sets the resonance gain (as linear gain factor) for low-, high- and (constant skirt gain)
// bandpass filters or the boost/cut gain for bell- and shelving filters.

void Filter::setResonance(float resonance)
{
  m_resonance = ONE_OVER_SQRT2 + 99.0f * (resonance*resonance*resonance);
  setBandwidth(40.0f * (resonance * resonance) + 0.001f);
  calculateCoefficients();
}

// Sets the bandwidth (in octaves) for (constant peak gain) bandpass filters and bell filters.
// In the case of shelving filters, this also determines the slope at the halfgain point.
// At B = (2*asinh(1/sqrt(2)))/log(2) = 1.899968626952992, the slope is as steep as it can be
// without overshooting.

void Filter::setBandwidth(float bandwidth)
{
  m_bandwidth = bandwidth;
}


float Filter::process(float in)
{
  //TODO: add a flag to calculate coefficients here instead of calculating them at every param change

  //"clamping" with tanh
  in = ctanhf(in);
  //	in = common::clampFloat2Unit(in);

  //svf process implementation
  float yL, yB, yH;
  getOutputs(in, yL, yB, yH);
  return m_output_level * ctanhf((m_c_low * yL + m_c_band * yB + m_c_high * yH)*(1.0f+(3.0f*m_drive)));
}

//svf implementation
void Filter::calculateCoefficients()
{
#if defined(USE_OVERSAMPLING)
  m_cutoff = 0.5f * SAMPLERATE * 0.25f * (m_base_freq + m_mod + m_staticmod);
#else
  m_cutoff = 0.5f * SAMPLERATE * (m_base_freq + m_mod + m_staticmod);
#endif

  // avoiding going near nyquist as the filter will blow
  m_cutoff = common::cclampf(m_cutoff, 20.0f, SAMPLERATE * 0.495f);
  m_g = static_cast<float>(tanf(PII / SAMPLERATE * m_cutoff));// embedded integrator gain (Fig 3.11)

  switch(m_mode)
  {
    case k_filter_off:
      m_r2 = 1.0f / m_resonance;// can we use an arbitrary value here, for example R2 = 1?
      m_c_low = 1.0f;
      m_c_band = getBandpassScaler();
      m_c_high = 1.0f;
      break;

    case k_filter_lowpass:
      m_r2 = 1.0f / m_resonance;
      m_c_low = 1.0f; m_c_band = 0.0f; m_c_high = 0.0f;
      break;

    case k_filter_highpass:
      m_r2 = 1.0f / m_resonance;
      m_c_low = 0.0f; m_c_band = 0.0f; m_c_high = 1.0f;
      break;

      //		case BANDPASS_SKIRT:
    case k_filter_bandpass_skirt:
      m_r2 = 1.0f / (1.00001f + m_bandwidth);
      m_c_low = 0.0f;
      m_c_band = 1.0f;
      m_c_high = 0.0f;
      break;

      //		case BANDPASS_PEAK:
    case k_filter_bandpass_peak:
      m_r2 = 2.0f * bandwidthToR(40.001f - 0.9654f * m_bandwidth);
      m_c_low = 0.0f;
      m_c_band = m_r2;
      m_c_high = 0.0f;
      break;

    case k_filter_bandreject:
      m_r2 = 2.0f * bandwidthToR(m_bandwidth);
      m_c_low = 1.0f;
      m_c_band = 0.0f;
      m_c_high = 1.0f;
      break;

      /*
         case BELL:
         {
         double fl = fc*pow(2, -B/2); // lower bandedge frequency (in Hz)
         double wl = tan(PII*fl/fs); // warped radian lower bandedge frequency /(2*fs)
         double r= g/wl; r *= r;// warped frequency ratio wu/wl == (wc/wl)^2 where wu is the
      // warped upper bandedge, wc the center
      m_r2 = 2*sqrt(((r*r+1)/r-2)/(4*m_resonance));
      cL = 1; cB = m_r2*m_resonance; cH = 1;
      }
      break;
      case LOWSHELF:
      {
      double A = sqrt(m_resonance);
      g /= sqrt(A); // scale SVF-cutoff frequency for shelvers
      m_r2 = 2*sinh(B*log(2.0)/2);
      cL = m_resonance; cB = m_r2*A; cH = 1;
      }
      break;
      case HIGHSHELF:
      {
      double A = sqrt(m_resonance);
      g *= sqrt(A); // scale SVF-cutoff frequency for shelvers
      m_r2 = 2*sinh(B*log(2.0)/2);
      cL = 1; cB = m_r2*A; cH = m_resonance;
      }
      break;
      case ALLPASS:
      {
      m_r2 = 2*bandwidthToR(B);
      cL = 1; cB = -m_r2; cH = 1;
      }
      break;
      */
  }
  m_h = 1.0f / (1.0f + m_r2 * m_g + m_g * m_g);// factor for feedback precomputation
}

void Filter::setMode (float value)
{
  value *= k_filter_off; //also acts as the number of filter modes
  m_mode = common::clrintf(value);
}

void Filter::getOutputs(float in, float &yL, float &yB, float &yH)
{
  // compute highpass output via Eq. 5.1:
  yH = (in - m_r2 * m_state1 - m_g * m_state1 - m_state2) * m_h;

  // compute bandpass output by applying 1st integrator to highpass output:
  yB = m_g * yH + m_state1;
  m_state1 = m_g * yH + yB; // state update in 1st integrator

  // compute lowpass output by applying 2nd integrator to bandpass output:
  yL = m_g * yB + m_state2;
  m_state2 = m_g * yB + yL; // state update in 2nd integrator

  // Remark: we have used two TDF2 integrators (Fig. 3.11) where one of them would be in code:
  // y = g*x + s; // output computation
  // s = g*x + y; // state update

  // as a cheap trick to introduce nonlinear behavior, we apply a nonlinearity to the states of
  // the integrators (uncomment, if you want that):
  //s1 = tanh(s1);
  //s2 = tanh(s2);
}

float Filter::bandwidthToR(float bandwidth)
{
  float fl = m_cutoff * cpowf(2.0f, bandwidth * - 0.5f);	// lower bandedge frequency (in Hz)
#if defined(USE_OVERSAMPLING)
  float gl = tanf(PII * fl / (SAMPLERATE * 0.25f));	// warped radian lower bandedge frequency /(2*fs)
#else
  float gl = tanf(PII * fl / SAMPLERATE);
#endif
  //	float fl = (m_cutoff*(0.5f*44100.0f)) * pow(2, -bandwidth/2.0f);	// lower bandedge frequency (in Hz)
  //	float gl = static_cast<float>(tan(PII * fl/44100.0f));	// warped radian lower bandedge frequency /(2*fs)
  float r  = gl / m_g;			// ratio between warped lower bandedge- and center-frequencies
  // unwarped: r = pow(2, -bandwidth/2) -> approximation for low
  // center-frequencies
  return sqrtf((1.0f-r*r)*(1.0f-r*r)/(4.0f*r*r));
}

void Filter::reset()
{
  m_state1 = m_state2 = 0.0f;
}

