#ifndef VOICE_HPP
#define VOICE_HPP

#include "filter.hpp"
#include "env_gen.hpp"
#include "oscillator.hpp"
#include "parameters.h"

/** \brief Voice class, handles generation for a single voice.
 * 
 * This represents a single voice of the synth - all the audio work is done here, in getSample().
 *
 * Idea and parts of code lifted from Niall Moody's Polyphonic Synth Tutorial at
 * http://www.niallmoody.com/ndcplugs/programming.htm
 *
 * See MIDI2Freq.h for the required copyright notice.
 */
class Voice
{
  public:
    ///	Constructor.
    Voice();
    ///	Destructor.
    ~Voice();

    ///	Called when the PolyHandler assigns a new note to this voice.
    /*!
      We set the voice to be active in this method, and set up various
      variables we need to start outputting sound.
      */
    void noteOn(int note, float velocity);
    ///	Called when the PolyHandler receives a noteOff() call for this
    ///	voice's note.
    /*!
      We push the envelope into it's release section here, so the voice can
      come to a halt accordingly.
      */
    void noteOff();

    ///	Used by PolyHandler to determine whether to call getSample() for
    ///	this voice.
    bool getIsActive() {return isActive;};

#ifdef VSTI
    void setSamplerate(float samplerate);
#endif

    ///	Called whenever the plugin gets a call to its setParameter() method.
    /*!
      We use this to set our attack, decay and release times, and the
      sustain level.
      */
    void setParameter(int parameter, float value);
    void setPitchBend(float val);
    void setPitchEnvMod(float val);
    void setPitchModMinMax();
    void setFilterRouting(float val);

    ///	Called for every sample in the plugin's processing loop (when the
    ///	voice is active).
    /*!
      In this method we generate the next sample to output, according to the
      envelope and the sine wave function we're using.

      The envelope should take care of itself, moving onto the next section
      when necessary, and telling the voice when it's reached the end of
      it's release section.  When this happens, the voice sets itself to be
      inactive, and the PolyHandler will not call getSample() again until a
      new note has been assigned to the voice with noteOn().
      */
    float getSample();

    float downSample(float in);

  private:
    ///	The samplerate we're running at.
#ifdef VSTI
    float m_samplerate;
#endif

    ///	The base frequency of the note generation's currently set to.
    float m_frequency;
    ///	The current (MIDI) note value for the voice.
    int m_note;

    ///	The velocity of the current note.
    float m_velocity;
    ///	The current pitch bend value.
    /*!
      We store this because it won't necessarily be 0 when a noteOn message
      is received, in which case we need to set the increment accordingly.
      */
    float m_pitch_bend;

    ///	Whether or not the voice is currently active or not.
    /*!
      This is used so that PolyHandler can tell when a voice has finished
      outputting sound, as it won't be when the noteOff() method is called
      due to the release section still having to complete.
      */
    bool isActive;

    //The envelope generators for amp, filter and pitch
    EnvGen m_amp_env;
    EnvGen m_filter_env;
    EnvGen m_pitch_env;
    float m_filter1_env_mod;
    float m_filter1_vel_mod;
    float m_filter2_env_mod;
    float m_filter2_vel_mod;
    float m_filter1_keytrack;
    float m_filter2_keytrack;
    float m_filter_keytrack_offset_freq;
    float m_pitch_env_mod;
    float m_pitchmod_min;
    float m_pitchmod_max;
    float m_lfo1_keytrack;
    float m_lfo2_keytrack;
    float m_lfo3_keytrack;
    float m_lfo_keytrack_offset;

    int m_lfo1_mod_dest;
    int m_lfo2_mod_dest;
    int m_lfo3_mod_dest;

    float m_lfo1_mod_amount;
    float m_lfo2_mod_amount;
    float m_lfo3_mod_amount;

    Oscillator m_osc1;
    Oscillator m_osc2;
    Oscillator m_osc3;
    Oscillator m_lfo1;
    Oscillator m_lfo2;
    Oscillator m_lfo3;
    Filter m_filter1;
    Filter m_filter2;
    int m_filter_routing;
};

#endif
