#ifndef OSCILLATOR_HPP
#define OSCILLATOR_HPP

#include "common.hpp"
#include "MIDI2Freq.h"

class Oscillator
{
  public:
    Oscillator(void);
    ~Oscillator(void) {};

#ifdef VSTI
    void setSamplerate(float samplerate) { m_samplerate = samplerate; };
#endif
    void setOscMode(int oscmode) { m_oscillator_mode = oscmode; };
    void setPitch(float pitch);
    void setWaveform(int waveform) { m_waveform = waveform; };
    void setWaveform(float value);
    void setVolume(float volume) { m_volume = volume; common::add_dc(m_volume); };
    void setDetune(float detune);
    void setSemi(float semi);
    void setPW(float pw);
    void setPWM(float pwm);
    void setPWMod(float value);
    void setStartphase(float startphase);
    void setPitchMod(float value);
    void setTempo(float tempo) { m_tempo = tempo; };

    float getSample();
    float getPolyBLEP(float phase);

    void trigger();
    void trigger(float pitch);
    void trigger(float pitch, float startphase);

    void stop();

    void reset();

  private:
#ifdef VSTI
    float m_samplerate;
#endif
    //oscillator mode (enum oscillator_modes)
    int m_oscillator_mode;

    //oscillator waveform (enum oscillator_waveforms)
    int m_waveform;

    //oscillator phase in radians [0-2PI]
    float m_phase;
    //step to increment phase in each call
    float m_phase_increment;
    //oscillator pitch in Hz
    float m_pitch;
    float m_volume;
    float m_detune; //fine tune (+/- 1 semi)
    float m_semi; //tune in semitones (+/- 60)
    float m_pw; //pulsewidth
    float m_pwm; //pulsewidth modulation strength
    float m_pw_mod; //pulsewidth modulator value
    float m_startphase;
    float m_pitch_mod; // pitch modulation for lfos, [-1,1]
    float m_tempo;
    float m_bpm_denominators[29]; // table of values to divide tempo with to get tempo synced lfo frequencies

    int m_gaussian_noise_constant_a;
    int m_gaussian_noise_constant_c;
    float m_sample; // sample for sample and hold
    int m_sampleandhold_period;
    int m_sampleandhold_counter;
    float m_fintmax;
    bool isActive;
    bool m_sync;
};

#endif
