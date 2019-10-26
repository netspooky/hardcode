#ifndef PARAMETERS_H
#define PARAMETERS_H

#define g_lfo_max_frequency 250.0f //Hz

enum EParams
{
  kVolume = 0,
  kVelocity,
  kNumParams
};

enum global_vst_defs
{
  // Global VST defines
  g_num_programs = 128,
  g_num_outputs = 2,
  g_pitch_env_range = 24, //pitch envelope range in semitones
  g_osc_semi_range = 60, //oscillator tuning range in semitones [-g_osc_semi_range,g_osc_semi_range]
  g_env_length_stage_max = 10, //maximum length for an envelope stage in seconds
  g_num_bpm_synced_lfo_speeds = 29, //number of available bpm synced lfo speeds
  g_delay_buffer_size = 2*44100 //delay buffer size in seconds * samplerate
};

namespace FX
{
  enum global_fx_params
  {
    // Parameters Tags
    // Reverb params
    k_reverb_mix = 0,
    k_reverb_predelay,
    k_reverb_bandwidth, //lpf1 / input filtering after predelay (diffusion) (0.0-1.0, 0.9995)
    k_reverb_damping, //lpf2&lpf3 (0.0 - 1.0, 0.0005)
    k_reverb_decay, //g5 (0.0-1.0, 0.5)
    k_reverb_roomsize,

    // Delay/echo params
    k_delay_mode = 0, 
    k_delay_mix,
    k_delay_time,
    k_delay_feedback,
    k_delay_lowpass_cutoff,
    k_delay_highpass_cutoff,

    k_num_fx_params, // number of "real" fx params (all params minus gui junk)

    // additional gui params
    k_fx_icaptioncontrol,
    k_fx_fileopen,
    k_fx_filesave,

    // end of parameter tags, k_num_params sets the number of available controls for the host UI
    k_num_params,

    // invisible parameters
    k_fx_samplerate,
  };
}

enum global_params
{
  // Parameters Tags
  k_osc1_waveform = 0,
  k_osc1_semi,
  k_osc1_detune,
  k_osc1_volume,
  k_osc1_pw, //pulsewidth
  k_osc1_pwm, //pulsewidth modulation

  k_osc2_waveform,
  k_osc2_semi,
  k_osc2_detune,
  k_osc2_volume,
  k_osc2_pw,
  k_osc2_pwm,

  k_osc3_waveform,
  k_osc3_semi,
  k_osc3_detune,
  k_osc3_volume,
  k_osc3_pw,
  k_osc3_pwm,

  k_lfo1_waveform,
  k_lfo1_speed,
  k_lfo1_startphase,
  k_lfo1_keytrack,
  k_lfo1_mod_dest,
  k_lfo1_mod_amount,

  k_lfo2_waveform,
  k_lfo2_speed,
  k_lfo2_startphase,
  k_lfo2_keytrack,
  k_lfo2_mod_dest,
  k_lfo2_mod_amount,

  k_lfo3_waveform,
  k_lfo3_speed,
  k_lfo3_startphase,
  k_lfo3_keytrack,
  k_lfo3_mod_dest,
  k_lfo3_mod_amount,

  k_pitch_env_mod,
  k_pitch_attack,
  k_pitch_decay,
  k_pitch_sustain,
  k_pitch_release,

  k_filter1_mode,
  k_filter1_cutoff,
  k_filter1_resonance,
  k_filter1_drive,

  k_filter1_keytrack,
  k_filter1_vel_mod, //modulate by velocity
  k_filter1_env_mod, //modulate by envelope

  k_filter2_mode,
  k_filter2_cutoff,
  k_filter2_resonance,
  k_filter2_drive,

  k_filter2_keytrack,
  k_filter2_vel_mod,
  k_filter2_env_mod,

  k_filter_attack,
  k_filter_decay,
  k_filter_sustain,
  k_filter_release,

  k_volume,

  k_env_length, //envelope length (up to 10 seconds)
  k_filter_routing, //filter routing: serial or parallel
  k_polymode, //polyphony mode
  k_glide, //glide,portamento etc.
  k_gliderate,

  k_amp_attack,
  k_amp_decay,
  k_amp_sustain,
  k_amp_release,

  k_tempo,
  k_pan,

  k_out1_level, 
  k_out2_level,
  k_out3_level,
  k_out4_level,

  k_filter1_output_level,
  k_filter2_output_level,
  /*
  //maybe add these eventually, would be an 8 slot mod matrix
  k_mod1_src,
  k_mod1_trg,
  k_mod1_amt,
  k_mod1_op,

  k_mod2_src,
  k_mod2_trg,
  k_mod2_amt,
  k_mod2_op,

  k_mod3_src,
  k_mod3_trg,
  k_mod3_amt,
  k_mod3_op,

  k_mod4_src,
  k_mod4_trg,
  k_mod4_amt,
  k_mod4_op,

  k_mod5_src,
  k_mod5_trg,
  k_mod5_amt,
  k_mod5_op,

  k_mod6_src,
  k_mod6_trg,
  k_mod6_amt,
  k_mod6_op,

  k_mod7_src,
  k_mod7_trg,
  k_mod7_amt,
  k_mod7_op,

  k_mod8_src,
  k_mod8_trg,
  k_mod8_amt,
  k_mod8_op,
  */
  k_num_synth_params, // number of "real" synth params (all params minus gui junk)

  // additional gui params
  k_icaptioncontrol,
  k_fileopen,
  k_filesave,

  // end of parameter tags, k_num_params sets the number of available controls for the host UI
  k_num_params,

  // invisible parameters
  k_samplerate,
  k_pitchbend
};

enum oscillator_waveforms
{
  k_sine, k_blepsaw, k_blepsquare, k_bleppulse, k_noise, k_sampleandhold, k_rawsaw, k_rawsquare, k_rawpulse, k_rawtriangle,
  k_num_waveforms
};

enum oscillator_modes
{
  k_oscmode_oscillator, k_oscmode_lfo
};

enum filter_modes
{
  //lowpass, highpass, bandpass/skirt (constant skirt gain), bandpass/peak (constant peak gain), bandreject, bypass,
  k_filter_lowpass, k_filter_highpass, k_filter_bandpass_skirt, k_filter_bandpass_peak, k_filter_bandreject, k_filter_off
    //TODO: maybe add the following?
    //k_filter_bell, k_filter_lowshelf, k_filter_highshelf, k_filter_allpass
};

enum filter_routing
{
  k_filter_route_serial, k_filter_route_parallel,
  k_num_filter_routing_modes
};

enum mod_dests
{
  k_mod_dst_pitch, k_mod_dst_pitch_osc1, k_mod_dst_pitch_osc2, k_mod_dst_pitch_osc3, k_mod_dst_amp, k_mod_dst_filter1_cutoff, k_mod_dst_filter2_cutoff, k_mod_dst_pwm,
  k_num_mod_dests
};

enum delay_modes
{
  //no use for cross delay now but saving for future stereo use, for now pingpong==cross
  k_delay_mode_mono, k_delay_mode_stereo, k_delay_mode_pingpong, k_delay_mode_cross, k_delay_mode_off,
  k_num_delay_modes,
  k_delay_mode_apf
};

enum event_nums
{
//numeric event codes, not all of them used at the moment
  k_event_num_standard_note_on = 0,
  k_event_num_standard_note_off = 1,
  k_event_num_standard_pitch_bend = 2,
  k_event_num_standard_control_code = 3,
  k_event_num_custom_nrpn = 4,
  k_event_num_global_division = 5,
  k_event_num_global_tempo = 6
};

#endif
