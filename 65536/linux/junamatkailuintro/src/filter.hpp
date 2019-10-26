#ifndef FILTER_HPP
#define FILTER_HPP

/** \file
 * 
 * trying Robin's ZDF-SVF implementation from
 * http://www.kvraudio.com/forum/viewtopic.php?f=33&t=350246&start=105
 */

/* \brief Filter class.
 *
 * This is an implementation of a state variable filter using topology-preserving transform (TPT) and
 * zero-delay feedback (ZDF) technology.
 * 
 * You can either use 3 outputs (lowpass, bandpass, highpass) from the SVF core by calling getOutputs() or let
 * the filter itself form a linear combination of the these 3 to obtain a desired filter mode (in addition to
 * the 3 modes above, there are also shelvers, a bell, etc.).
 */
class Filter
{
  public:
    Filter(void);
    ~Filter(void) {};

#ifdef VSTI
    void setSamplerate(float samplerate);
#endif
    void setMode(float value);
    void setMode(int mode) { m_mode = mode; };
    void setCutoff(float cutoff);
    void setMod(float amount, float modifier);
    void setStaticMod(float amount);
    void setResonance(float resonance);
    void setDrive(float drive) { m_drive = drive; };
    void setOutputLevel(float output_level) { m_output_level = output_level; };

    void setBandwidth(float newBandwidth);

    // When you use getOutputs() directly to obtain the lowpass, bandpass and highpass signals
    // of the core SVF, this function returns the value by which the bandpass signal has to be scaled
    // in order to achieve lowpass + scaler*bandpass + highpass == original input.
    inline float getBandpassScaler() const { return m_r2; }

    // Returns the 3 outputs (lowpass, bandpass, highpass) of the core SVF.
    void getOutputs(float in, float &yL, float &yB, float &yH);

    float process(float in);

    // Resets the internal state buffers to zero.
    void reset();

  private:
#ifdef VSTI
    float m_samplerate;
#endif
    // Computes damping coefficient R from desired bandwidth and the prewarped radian center
    // frequency (for bandpass with constant peak gain, bandreject and allpass).
    float bandwidthToR(float bandwidth);

    void calculateCoefficients();

    int m_mode;
    float m_cutoff; // the real internal cutoff freq, composed from base freq and mod
    float m_resonance; //gain
    float m_mod; // for env mod
    float m_staticmod; // for vel mod & keytrack
    float m_base_freq;
    float m_drive;
    float m_output_level;

    float m_bandwidth; //in octaves

    // states
    float m_state1, m_state2;

    //coefficients (robin)
    float m_g;	// embedded integrator gain
    float m_r2;	// twice the damping coefficient (R2 == 2*R == 1/Q)
    float m_h;	// factor for feedback (== 1/(1+2*R*g+g*g))
    float m_c_low, m_c_band, m_c_high;	// coefficients for low-, band-, and highpass signals

    bool m_calc_coefficients; //flag to trigger coefficient calculation during process
    int m_calc_interval; //
};

#endif
