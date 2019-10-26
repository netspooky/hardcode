/* -*- mode: javascript; tab-width: 4; indent-tabs-mode: nil; -*-
 ******************************************************************************
 * This is "Frank", a 4k JavaScript demo with music and 3D gfx
 * Copyright (c) 2011 m / Bits'n'Bites
 *
 * Thanks to Ferris / Youth Uprising for the original Sonant synth!
 ******************************************************************************/

(function ()
{
    //--------------------------------------------------------------------------
    // Private members
    //--------------------------------------------------------------------------

    //**************************************************************************
    // Music
    //**************************************************************************

    // Song data
    var mSong = {
      // Song length in seconds (how much data to generate)
      songLen: 158,  // Tune this to fit your needs!

      songData: [
        { // Instrument 0
          // Oscillator 1
          osc1_oct: 7,
//          osc1_det: 0,
//          osc1_detune: 0,
          osc1_xenv: 0,
          osc1_vol: 192,
          osc1_waveform: 2,
          // Oscillator 2
          osc2_oct: 7,
//          osc2_det: 0,
          osc2_detune: 9,
//          osc2_xenv: 0,
          osc2_vol: 192,
          osc2_waveform: 2,
          // Noise oscillator
          noise_fader: 39,
          // Envelope
          env_attack: 88,
          env_sustain: 1584,
          env_release: 1075,
          env_master: 15, // 235
          // Effects
          fx_filter: 3,
          fx_freq: 1610,
          fx_resonance: 156,
          fx_delay_time: 3,
          fx_delay_amt: 16,
          fx_pan_freq: 4,
          fx_pan_amt: 131,
          // LFO
//          lfo_osc1_freq: 0,
          lfo_fx_freq: 1,
          lfo_freq: 4,
          lfo_amt: 111,
          lfo_waveform: 1,
          // Patterns
          p: [0,0,1,2,1,2,1,2,1,2,1,2,0,0,5,6,3,4,1,2,1,2,1,2,3,4,3,4,3,4,3,4,3,4,3,4,0,0,0,0,7,0], // ,0,0,0,0,0,0],
          // Columns
          c: [
            {n: [135,135,135,135,135,135,135,135,135,135,135,135,135,135,135,135,135,135,135,135,135,135,135,135,135,135,135,135,135,135,135,135]},
            {n: [138,138,138,138,138,138,138,138,138,138,138,138,138,138,138,138,138,138,138,138,138,138,138,138,138,138,138,138,138,138,138,138]},
            {n: [0,0,135,135,0,0,135,135,0,0,135,135,0,0,135,135,0,0,135,135,0,0,135,135,0,0,135,135,0,0,135,135]},
            {n: [0,0,138,138,0,0,138,138,0,0,138,138,0,0,138,138,0,0,138,138,0,0,138,138,0,0,138,138,0,0,138,138]},
            {n: [0,0,135,135,0,0,135,135,0,0,0,0,0,0,0,0,0,0,135,135,0,0,135,135,0,0,0,0,0,0,0,0]},
            {n: [0,0,138,138,0,0,138,138,0,0,0,0,0,0,0,0,0,0,138,138,0,0,138,138,0,0,0,0,0,0,0,0]},
            {n: [171,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]}
//            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
//            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
//            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]}
          ]
        },
        { // Instrument 1
          // Oscillator 1
          osc1_oct: 7,
//          osc1_det: 0,
//          osc1_detune: 0,
          osc1_xenv: 1,
          osc1_vol: 255,
          osc1_waveform: 0,
          // Oscillator 2
          osc2_oct: 7,
//          osc2_det: 0,
          osc2_detune: 0,
//          osc2_xenv: 1,
          osc2_vol: 255,
          osc2_waveform: 0,
          // Noise oscillator
          noise_fader: 0,
          // Envelope
          env_attack: 49,
          env_sustain: 150,
          env_release: 10614,
          env_master: 13, // 200,
          // Effects
          fx_filter: 2,
          fx_freq: 600,
          fx_resonance: 254,
          fx_delay_time: 2,
          fx_delay_amt: 24,
          fx_pan_freq: 0,
          fx_pan_amt: 0,
          // LFO
//          lfo_osc1_freq: 0,
          lfo_fx_freq: 0,
          lfo_freq: 0,
          lfo_amt: 0,
          lfo_waveform: 0,
          // Patterns
          p: [0,2,1,4,1,5,1,6,1,1,1,7,3,8,0,0,1,5,1,6,0,0,0,2,1,5,1,6,1,4,1,6,0,2,0,2,0,0,0,0,0,0], // ,0,0,0,0,0,0],
          // Columns
          c: [
            {n: [147,0,0,0,147,0,0,0,147,0,0,0,147,0,0,0,147,0,0,0,147,0,0,0,147,0,0,0,147,0,0,0]},
            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,147,0,0,0,147,147,0,0]},
            {n: [147,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
            {n: [147,0,0,0,147,0,0,0,147,0,0,0,147,0,0,0,147,0,0,0,147,0,0,0,147,0,0,147,147,0,147,0]},
            {n: [147,0,0,0,147,0,0,0,147,0,0,0,147,0,0,0,147,0,0,0,147,0,0,0,147,0,147,0,147,0,147,0]},
            {n: [147,0,0,0,147,0,0,0,147,0,0,0,147,0,0,0,147,0,0,0,147,0,0,0,0,147,147,0,147,0,147,147]},
            {n: [147,0,0,0,147,0,0,0,147,0,0,0,147,0,0,0,147,0,0,0,0,0,0,0,0,0,0,0,0,0,147,0]},
            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,147,0,0,0]}
//            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
//            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]}
          ]
        },
        { // Instrument 2
          // Oscillator 1
          osc1_oct: 7,
//          osc1_det: 0,
//          osc1_detune: 0,
          osc1_xenv: 1,
          osc1_vol: 255,
          osc1_waveform: 1,
          // Oscillator 2
          osc2_oct: 8,
//          osc2_det: 0,
          osc2_detune: 0,
//          osc2_xenv: 1,
          osc2_vol: 208,
          osc2_waveform: 0,
          // Noise oscillator
          noise_fader: 255,
          // Envelope
          env_attack: 50,
          env_sustain: 150,
          env_release: 12631,
          env_master: 14, // 229,
          // Effects
          fx_filter: 1,
          fx_freq: 7931,
          fx_resonance: 143,
          fx_delay_time: 4,
          fx_delay_amt: 24,
          fx_pan_freq: 0,
          fx_pan_amt: 20,
          // LFO
//          lfo_osc1_freq: 0,
          lfo_fx_freq: 1,
          lfo_freq: 5,
          lfo_amt: 64,
          lfo_waveform: 0,
          // Patterns
          p: [0,0,0,4,1,2,1,3,0,0,0,0,0,5,0,0,1,2,1,3,0,0,0,4,1,2,1,3,0,4,1,3,0,0,0,0,0,0,0,0,0,0], // ,0,0,0,0,0,0],
          // Columns
          c: [
            {n: [0,0,0,0,147,0,0,0,0,0,0,0,147,0,0,0,0,0,0,0,147,0,0,0,0,0,0,0,147,0,0,0]},
            {n: [0,0,0,0,147,0,0,0,0,0,0,0,147,0,0,0,0,0,0,0,147,0,0,0,0,0,147,0,147,0,147,0]},
            {n: [0,0,0,0,147,0,0,0,0,0,0,0,147,0,0,0,0,0,0,0,147,0,0,0,0,135,147,0,147,0,147,147]},
            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,147,0,0,147,147,0,147,0]},
            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,147,0,0,0]}
//            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
//            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
//            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
//            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
//            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]}
          ]
        },
        { // Instrument 3
          // Oscillator 1
          osc1_oct: 7,
//          osc1_det: 0,
//          osc1_detune: 0,
          osc1_xenv: 0,
          osc1_vol: 192,
          osc1_waveform: 2,
          // Oscillator 2
          osc2_oct: 7,
//          osc2_det: 0,
          osc2_detune: 0,
//          osc2_xenv: 0,
          osc2_vol: 201,
          osc2_waveform: 3,
          // Noise oscillator
          noise_fader: 0,
          // Envelope
          env_attack: 100,
          env_sustain: 150,
          env_release: 13636,
          env_master: 12, // 191,
          // Effects
          fx_filter: 2,
          fx_freq: 5839,
          fx_resonance: 191,
          fx_delay_time: 6,
          fx_delay_amt: 121,
          fx_pan_freq: 6,
          fx_pan_amt: 147,
          // LFO
//          lfo_osc1_freq: 0,
          lfo_fx_freq: 1,
          lfo_freq: 4,
          lfo_amt: 123,
          lfo_waveform: 1,
          // Patterns
          p: [1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,0,0,0,0,3,4,3,4,3,4,3,4,3,4,3,4,3,4,1,5,6,0], // ,0,0,0,0,0,0],
          // Columns
          c: [
            {n: [123,0,0,0,0,0,0,0,135,0,0,0,0,0,0,0,123,0,0,0,0,0,0,0,135,0,0,0,0,0,0,0]},
            {n: [126,0,0,0,0,0,0,0,138,0,0,0,0,0,0,0,126,0,0,0,0,0,0,0,138,0,0,0,0,0,0,0]},
            {n: [123,0,0,0,135,0,0,0,0,123,123,0,135,0,0,0,123,0,0,0,135,0,0,0,0,123,123,0,135,0,123,0]},
            {n: [126,0,0,0,138,0,0,0,0,126,126,0,138,0,0,0,126,0,0,0,138,0,0,0,0,126,126,0,138,0,126,0]},
            {n: [123,123,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,123,130,135,142,147,154,159,166]},
            {n: [171,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]}
//            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
//            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
//            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
//            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]}
          ]
        },
        { // Instrument 4
          // Oscillator 1
          osc1_oct: 7,
//          osc1_det: 0,
//          osc1_detune: 0,
          osc1_xenv: 0,
          osc1_vol: 255,
          osc1_waveform: 2,
          // Oscillator 2
          osc2_oct: 8,
//          osc2_det: 0,
          osc2_detune: 18,
//          osc2_xenv: 0,
          osc2_vol: 255,
          osc2_waveform: 3,
          // Noise oscillator
          noise_fader: 0,
          // Envelope
          env_attack: 21074,
          env_sustain: 56363,
          env_release: 100000,
          env_master: 12, // 199,
          // Effects
          fx_filter: 2,
          fx_freq: 948,
          fx_resonance: 92,
          fx_delay_time: 7,
          fx_delay_amt: 60,
          fx_pan_freq: 3,
          fx_pan_amt: 100,
          // LFO
//          lfo_osc1_freq: 0,
          lfo_fx_freq: 1,
          lfo_freq: 7,
          lfo_amt: 138,
          lfo_waveform: 3,
          // Patterns
          p: [1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,3,4,3,5,0,0,0,0,1,2,1,2,6,7,6,8,0,0,0,0,9,0], // ,0,0,0,0,0,0],
          // Columns
          c: [
            {n: [123,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
            {n: [114,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
            {n: [123,166,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
            {n: [126,169,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
            {n: [126,162,0,0,0,0,0,0,166,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
            {n: [111,123,135,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
            {n: [114,126,133,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
            {n: [126,138,133,0,0,0,0,0,0,0,0,0,145,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
            {n: [99,111,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]}
//            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]}
          ]
        },
        { // Instrument 5
          // Oscillator 1
          osc1_oct: 8,
//          osc1_det: 0,
//          osc1_detune: 0,
          osc1_xenv: 0,
          osc1_vol: 0,
          osc1_waveform: 0,
          // Oscillator 2
          osc2_oct: 8,
//          osc2_det: 0,
          osc2_detune: 0,
//          osc2_xenv: 0,
          osc2_vol: 0,
          osc2_waveform: 0,
          // Noise oscillator
          noise_fader: 60,
          // Envelope
          env_attack: 50,
          env_sustain: 419,
          env_release: 4607,
          env_master: 11, // 182,
          // Effects
          fx_filter: 1,
          fx_freq: 10332,
          fx_resonance: 120,
          fx_delay_time: 4,
          fx_delay_amt: 16,
          fx_pan_freq: 5,
          fx_pan_amt: 108,
          // LFO
//          lfo_osc1_freq: 0,
          lfo_fx_freq: 0,
          lfo_freq: 5,
          lfo_amt: 187,
          lfo_waveform: 0,
          // Patterns
          p: [0,0,0,2,1,1,1,1,0,0,0,4,3,5,3,3,3,3,3,3,6,6,6,6,3,3,6,6,6,6,6,6,6,6,6,6,0,0,0,0,0,0], // ,0,0,0,0,0,0],
          // Columns
          c: [
            {n: [159,159,159,159,159,159,159,159,159,159,159,159,159,159,159,159,159,159,159,159,159,159,159,159,159,159,159,159,159,159,159,159]},
            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,159,159,159,0,159,159,159,0]},
            {n: [0,0,0,0,159,0,0,0,0,0,0,0,159,0,0,0,0,0,0,0,159,0,0,0,0,0,159,0,0,0,159,0]},
            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,147,0,0,0]},
            {n: [0,0,0,0,159,0,0,0,0,0,0,0,159,0,0,0,0,0,0,0,159,0,0,0,159,159,159,159,0,159,159,159]},
            {n: [0,159,159,0,159,0,159,159,0,159,159,0,159,0,159,0,0,159,159,0,159,0,159,159,0,159,159,0,159,0,0,159]}
//            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
//            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
//            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
//            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]}
          ]
        },
        { // Instrument 6
          // Oscillator 1
          osc1_oct: 7,
//          osc1_det: 0,
//          osc1_detune: 0,
          osc1_xenv: 0,
          osc1_vol: 255,
          osc1_waveform: 2,
          // Oscillator 2
          osc2_oct: 8,
//          osc2_det: 0,
          osc2_detune: 5,
//          osc2_xenv: 0,
          osc2_vol: 255,
          osc2_waveform: 2,
          // Noise oscillator
          noise_fader: 48,
          // Envelope
          env_attack: 5970,
          env_sustain: 88,
          env_release: 18442,
          env_master: 16, // 255,
          // Effects
          fx_filter: 2,
          fx_freq: 3657,
          fx_resonance: 95,
          fx_delay_time: 6,
          fx_delay_amt: 147,
          fx_pan_freq: 1,
          fx_pan_amt: 81,
          // LFO
//          lfo_osc1_freq: 0,
          lfo_fx_freq: 1,
          lfo_freq: 3,
          lfo_amt: 195,
          lfo_waveform: 0,
          // Patterns
          p: [0,0,0,0,0,0,0,0,1,1,1,1,2,3,2,3,2,3,2,3,0,0,0,0,0,0,0,0,2,3,2,3,0,0,0,0,0,0,0,0,0,0], // ,0,0,0,0,0,0],
          // Columns
          c: [
            {n: [147,0,154,0,0,0,0,0,150,0,157,0,0,0,0,0,152,0,159,0,0,0,0,0,0,0,0,0,150,0,149,0]},
            {n: [147,0,154,0,111,0,0,0,150,0,157,0,111,0,0,0,152,0,159,0,111,0,0,0,0,0,119,0,150,0,149,0]},
            {n: [147,0,154,0,114,0,0,0,150,0,157,0,114,0,0,0,152,0,159,0,114,0,0,0,0,0,121,0,150,0,149,0]}
//            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
//            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
//            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
//            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
//            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
//            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
//            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]}
          ]
        },
        { // Instrument 7
          // Oscillator 1
          osc1_oct: 7,
//          osc1_det: 0,
//          osc1_detune: 0,
          osc1_xenv: 0,
          osc1_vol: 255,
          osc1_waveform: 3,
          // Oscillator 2
          osc2_oct: 8,
//          osc2_det: 0,
          osc2_detune: 0,
//          osc2_xenv: 0,
          osc2_vol: 255,
          osc2_waveform: 0,
          // Noise oscillator
          noise_fader: 127,
          // Envelope
          env_attack: 22,
          env_sustain: 22,
          env_release: 2193,
          env_master: 16, // 255,
          // Effects
          fx_filter: 3,
          fx_freq: 4067,
          fx_resonance: 176,
          fx_delay_time: 4,
          fx_delay_amt: 144,
          fx_pan_freq: 2,
          fx_pan_amt: 84,
          // LFO
//          lfo_osc1_freq: 0,
          lfo_fx_freq: 1,
          lfo_freq: 3,
          lfo_amt: 96,
          lfo_waveform: 0,
          // Patterns
          p: [0,0,0,0,0,0,0,0,0,0,0,0,1,2,1,3,1,2,1,3,1,2,1,3,0,0,1,3,1,2,1,3,1,2,1,3,0,0,0,0,0,0], // ,0,0,0,0,0,0],
          // Columns
          c: [
            {n: [147,0,0,0,159,0,166,0,162,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
            {n: [145,0,0,0,159,0,171,0,169,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
            {n: [145,0,0,0,159,0,169,0,166,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,162,0,164,0,161,0,162,0]}
//            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
//            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
//            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
//            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
//            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
//            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
//            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]}
          ]
        }
      ],
      rowLen: 5168   // In sample lengths
    };

    //**************************************************************************
    // End of Music
    //**************************************************************************

    // Wave data configuration
    var mWaveSPS = 44100,           // Samples per second
        mWaveWords = mWaveSPS * 2 * mSong.songLen; // Total song size (in words)
 
    // Work buffers
    var mChnBufWork = new Int32Array(mWaveWords),
        mMixBufWork = new Int32Array(mWaveWords);


    //--------------------------------------------------------------------------
    // Private methods
    //--------------------------------------------------------------------------

    // Oscillators
    function osc_sin(value)
    {
        return Math.sin(value * 6.28318);
    }

    function osc_square(value)
    {
        if(osc_sin(value) < 0) return -1;
        return 1;
    }

    function osc_saw(value)
    {
        return (value % 1) - .5;
    }

    function osc_tri(value)
    {
        var v2 = (value % 1) * 4;
        if(v2 < 2) return v2 - 1;
        return 3 - v2;
    }

    function getnotefreq(n)
    {
        return Math.pow(1.05946, n - 128) / 256;
    }

    // Array of oscillator functions
    var mOscillators = [
        osc_sin,
        osc_square,
        osc_saw,
        osc_tri
    ];


    //--------------------------------------------------------------------------
    // Public methods
    //--------------------------------------------------------------------------

    // Generate audio data for a single track
    function generateMusic(track)
    {
        // Local variables
        var i, j, k, b, p, row, n, currentpos, cp,
            c1, c2, q, low, band, high, t, lfor, e, x,
            rsample, f, da, o1t, o2t;

        // Preload/precalc some properties/expressions (for improved performance)
        var chnBuf = mChnBufWork,
            mixBuf = mMixBufWork,
            waveWords = mWaveWords,
            instr = mSong.songData[track],
            rowLen = mSong.rowLen,
            osc_lfo = mOscillators[instr.lfo_waveform],
            osc1 = mOscillators[instr.osc1_waveform],
            osc2 = mOscillators[instr.osc2_waveform],
            attack = instr.env_attack,
            sustain = instr.env_sustain,
            release = instr.env_release,
            masterVolume = instr.env_master * 8,
            panFreq = 1 / (rowLen << (8 - instr.fx_pan_freq)),
            lfoFreq = 1 / (rowLen << (8 - instr.lfo_freq));

        // Clear buffer
        for(b = 0; b < waveWords; b++) chnBuf[b] = 0;

        currentpos = 0;
        for(p = 0; p < 41; ++p) // Patterns
        {
            cp = instr.p[p];
            for(row = 0;row < 32; ++row) // Rows
            {
                if(cp)
                {
                    n = instr.c[cp - 1].n[row];
                    if(n)
                    {
                        c1 = c2 = 0;

                        // Precalculate frequencues
/*
                        o1t = getnotefreq(n + (instr.osc1_oct - 8) * 12 + instr.osc1_det) * (1 + .0008 * instr.osc1_detune);
                        o2t = getnotefreq(n + (instr.osc2_oct - 8) * 12 + instr.osc2_det) * (1 + .0008 * instr.osc2_detune);
*/
                        o1t = getnotefreq(n + (instr.osc1_oct - 8) * 12);
                        o2t = getnotefreq(n + (instr.osc2_oct - 8) * 12) * (1 + .0008 * instr.osc2_detune);

                        // State variable init
                        q = instr.fx_resonance / 255;
                        low = band = 0;
                        for (j = attack + sustain + release - 1; j >= 0; --j)
                        {
                            k = j + currentpos;

                            // LFO
                            lfor = osc_lfo(k * lfoFreq) * instr.lfo_amt / 512 + .5;

                            // Envelope
                            e = 1;
                            if(j < attack)
                                e = j / attack;
                            else if(j >= attack + sustain)
                                e -= (j - attack - sustain) / release;

                            // Oscillator 1
                            t = o1t;
//                            if(instr.lfo_osc1_freq) t += lfor;
                            if(instr.osc1_xenv) t *= e * e;
                            c1 += t;
                            rsample = osc1(c1) * instr.osc1_vol;

                            // Oscillator 2
                            t = o2t;
//                            if(instr.osc2_xenv) t *= e * e;
                            if(instr.osc1_xenv) t *= e * e;
                            c2 += t;
                            rsample += osc2(c2) * instr.osc2_vol;

                            // Noise oscillator
                            if(instr.noise_fader) rsample += (2*Math.random()-1) * instr.noise_fader * e;

                            // Apply envelope and master volume
//                            rsample *= e * instr.env_master * 8;
                            rsample *= e * masterVolume;

                            // State variable filter
                            f = instr.fx_freq;
                            if(instr.lfo_fx_freq) f *= lfor;
                            f = 1.5 * Math.sin(f / 14037); // * 3.141592 / mWaveSPS);
                            low += f * band;
                            high = q * (rsample - band) - low;
                            band += f * high;
//                            rsample = instr.fx_filter == 1 ? high : instr.fx_filter == 2 ? low : instr.fx_filter == 3 ? band : notch;
                            rsample = instr.fx_filter == 1 ? high : instr.fx_filter == 2 ? low : band;

                            // Panning
                            t = osc_sin(k * panFreq) * instr.fx_pan_amt / 512 + .5;

                            // Add to channel buffer
                            chnBuf[k*2] += rsample * (1 - t);
                            chnBuf[k*2+1] += rsample * t;
                        }
                    }
                }
                currentpos += rowLen;
            }
        }

        // Delay
        p = ((instr.fx_delay_time * rowLen) >> 1) * 2; // Must be even
        t = instr.fx_delay_amt / 255;
        for(b = 0; b < waveWords - p; b += 2)
        {
            k = b + p;

            // Left channel = left + right[-p] * t
            chnBuf[k] += chnBuf[b+1] * t;

            // Right channel = right + left[-p] * t
            chnBuf[k+1] += chnBuf[b] * t;
        }

        // Add to mix buffer
        for(b = 0; b < waveWords; b++) mixBuf[b] += chnBuf[b];
    };

    // Create an HTML audio element from the generated audio data
    function createAudio()
    {
        // Local variables
        var b, wave, l1, l2, y;

        // Turn critical object properties into local variables (performance)
        var mixBuf = mMixBufWork,
            waveWords = mWaveWords;

        // We no longer need the channel working buffer
//        mChnBufWork = null;

        // Convert to a WAVE file (in a binary string)
/*
        l1 = waveWords * 2  - 8;
        l2 = l1 - 36;
        wave = String.fromCharCode(82,73,70,70,
                                   l1 & 255,(l1 >> 8) & 255,(l1 >> 16) & 255,l1 >> 24,
                                   87,65,86,69,102,109,116,32,16,0,0,0,1,0,2,0,
                                   68,172,0,0,16,177,2,0,4,0,16,0,100,97,116,97,
                                   l2 & 255,(l2 >> 8) & 255,(l2 >> 16) & 255,l2 >> 24);
*/
        // If songLen is 158, this can be used instead
        wave = atob("UklGRthHqQFXQVZFZm10IBAAAAABAAIARKwAABCxAgAEABAAZGF0YbRHqQE=");
        for (b = 0; b < waveWords; b++)
        {
            // Note: We clamp here
            y = mixBuf[b];
            y = y < -32767 ? -32767 : (y > 32767 ? 32767 : y);
            wave += String.fromCharCode(y & 255, (y >> 8) & 255);
        }

        // Return the music as an audio element
        return new Audio("data:audio/wav;base64," + btoa(wave));
    };

    // Audio & initialization state
    var mAudio,
        mInitState = -2,

    // Programs array
    p = [],

    // Vertex shader
    v = "attribute vec2 p;void main(){gl_Position=vec4(p,0,1);}",

    // Fragment shaders
    f=[
       //******************* PART 1 A (0)**********************
"precision highp float;"+
"uniform float ut;"+
"uniform vec2 ur;"+
"float gc=fract(ut*3.2/3.),"+
      "gb=fract(gc*2.),"+
      "PI=3.14159;"+
"float fc(vec2 v)"+
"{"+
    "return sin(7.*length(v)+.2*ut);"+
"}"+
"vec3 ff(vec2 p)"+
"{"+
    "return (1.+sin("+
                   "fc(3.*sin(ut*vec2(.3,.2))-p)+"+
                   "fc(3.*sin(ut*vec2(.2,.1))-p)+"+
                   "fc(3.*sin(ut*vec2(.1,.4))-p)+"+
                   "vec3(0,.1,.2)))*max(1.-.1*length(p),0.);"+
"}"+
"vec3 ft(vec3 o,vec3 d)"+
"{"+
    "float e=.5*sin(gc*PI)-1.,"+
          "t=(e-o.z)/d.z,"+
          "r=1.5-(1.+sin(.3*ut))*gb,"+
          "a=dot(o,d)/dot(d,d),"+
          "b=dot(o,o)-r*r;"+
    "vec3 c=vec3(0),"+
         "p=o+t*d,"+
         "n,f;"+
    "if(t>0.)"+
      "c=ff(p.xy);"+
    "if(ut<7.5)"+
      "return c;"+
    "t=-a-sqrt(a*a-b);"+
    "p=o+t*d;"+
    "n=normalize(p);"+
    "f=reflect(d,n);"+
    "t=(e-p.z)/f.z;"+
    "if(a*a>b)"+
      "c=.2*ff((p+t*f).xy)+(1.-gb)*vec3(n+.5);"+
    "return c;"+
"}"+
"void main()"+
"{"+
    "vec2 p=(2.*gl_FragCoord.xy-ur)/ur.y,"+
         "q=2.*gl_FragCoord.xy/ur-1.;"+
//    "vec3 cp=vec3(6.*cos(gc*PI+.9),7.*sin(ut*3.2),2.);"+
    "vec3 cp=vec3(4.*cos(ut*.3+1.),3.*sin(ut*.2),2.),"+
         "ct=vec3(.0,.8*cos(ut),0.),"+
         "cd=normalize(ct-cp),"+
         "cr=normalize(cross(cd,vec3(.3*cos(.3*ut),0.,1.))),"+
         "cu=cross(cr,cd),"+
//         "rd=normalize(2.*cd+cr*p.x*p.x+cu*p.y),"+
         "rd=normalize(2.*cd+cr*p.x+cu*p.y),"+
         "c=ft(cp,rd)*"+
           "min(min(1.,.03*ut*ut),1.8-dot(q,q))*"+
           "(.9+.1*sin(3.*sin(gc)*gl_FragCoord.y));"+
//           "(.6+.7*sin(3.*sin(gc)*gl_FragCoord.y));"+
    "gl_FragColor=vec4(c,1);"+
//    "gl_FragColor=vec4(vec3(.5,.45,.4)*(c.r+c.g+c.b),1);"+
"}",

       //******************* PART 1 B (1)**********************
"precision highp float;"+
"uniform float ut;"+
"uniform vec2 ur;"+
"float gc=fract(ut*3.2/3.),"+
      "gb=fract(gc*2.),"+
      "PI=3.14159;"+
"float fc(vec2 v)"+
"{"+
    "return sin(7.*length(v)+.2*ut);"+
"}"+
"vec3 ff(vec2 p)"+
"{"+
    "return (1.+sin("+
                   "fc(3.*sin(ut*vec2(.3,.2))-p)+"+
                   "fc(3.*sin(ut*vec2(.2,.1))-p)+"+
                   "fc(3.*sin(ut*vec2(.1,.4))-p)+"+
                   "vec3(0,.1,.2)))*max(1.-.1*length(p),0.);"+
"}"+
"vec3 ft(vec3 o,vec3 d)"+
"{"+
    "float e=.5*sin(gc*PI)-1.,"+
          "t=(e-o.z)/d.z,"+
          "r=1.5-(1.+sin(.3*ut))*gb,"+
          "a=dot(o,d)/dot(d,d),"+
          "b=dot(o,o)-r*r;"+
    "vec3 c=vec3(0),"+
         "p=o+t*d,"+
         "n,f;"+
    "if(t>0.)"+
      "c=ff(p.xy);"+
    "t=-a-sqrt(a*a-b);"+
    "p=o+t*d;"+
    "n=normalize(p);"+
    "f=reflect(d,n);"+
    "t=(e-p.z)/f.z;"+
    "if(a*a>b)"+
      "c=.2*ff((p+t*f).xy)+(1.-gb)*vec3(n+.5);"+
    "return c;"+
"}"+
"void main()"+
"{"+
    "vec2 p=(2.*gl_FragCoord.xy-ur)/ur.y,"+
         "q=2.*gl_FragCoord.xy/ur-1.;"+
    "vec3 cp=vec3(6.*cos(gc*PI+.9),7.*sin(ut*3.2),2.),"+
//    "vec3 cp=vec3(4.*cos(ut*.3+1.),3.*sin(ut*.2),2.),"+
         "ct=vec3(.0,.8*cos(ut),0.),"+
         "cd=normalize(ct-cp),"+
         "cr=normalize(cross(cd,vec3(.3*cos(.3*ut),0.,1.))),"+
         "cu=cross(cr,cd),"+
//         "rd=normalize(2.*cd+cr*p.x*p.x+cu*p.y),"+
         "rd=normalize(2.*cd+cr*p.x+cu*p.y),"+
         "c=ft(cp,rd)*"+
           "min(1.,1.8-dot(q,q))*"+
//           "(.9+.1*sin(3.*sin(gc)*gl_FragCoord.y));"+
           "(.7+.4*sin(5.*sin(gc)*gl_FragCoord.y));"+
    "gl_FragColor=vec4(c,1);"+
//    "gl_FragColor=vec4(vec3(.5,.45,.4)*(c.r+c.g+c.b),1);"+
"}",

       //******************* PART 1 C (2)**********************
"precision highp float;"+
"uniform float ut;"+
"uniform vec2 ur;"+
"float gc=fract(ut*3.2/3.),"+
      "gb=fract(gc*2.),"+
      "PI=3.14159;"+
"float fc(vec2 v)"+
"{"+
    "return sin(7.*length(v)+.2*ut);"+
"}"+
"vec3 ff(vec2 p)"+
"{"+
    "return (1.+sin("+
                   "fc(3.*sin(ut*vec2(.3,.2))-p)+"+
                   "fc(3.*sin(ut*vec2(.2,.1))-p)+"+
                   "fc(3.*sin(ut*vec2(.1,.4))-p)+"+
                   "vec3(0,.1,.2)))*max(1.-.1*length(p),0.);"+
"}"+
"vec3 ft(vec3 o,vec3 d)"+
"{"+
    "float e=.5*sin(gc*PI)-1.,"+
          "t=(e-o.z)/d.z,"+
          "r=1.5-(1.+sin(.3*ut))*gb,"+
          "a=dot(o,d)/dot(d,d),"+
          "b=dot(o,o)-r*r;"+
    "vec3 c=vec3(0),"+
         "p=o+t*d,"+
         "n,f;"+
    "if(t>0.)"+
      "c=ff(p.xy);"+
    "t=-a-sqrt(a*a-b);"+
    "p=o+t*d;"+
    "n=normalize(p);"+
    "f=reflect(d,n);"+
    "t=(e-p.z)/f.z;"+
    "if(a*a>b)"+
      "c=.2*ff((p+t*f).xy)+(1.-gb)*vec3(n+.5);"+
    "return c;"+
"}"+
"void main()"+
"{"+
    "vec2 p=(2.*gl_FragCoord.xy-ur)/ur.y,"+
         "q=2.*gl_FragCoord.xy/ur-1.;"+
//    "vec3 cp=vec3(4.*cos(ut*.3+1.),3.*sin(ut*.2),2.),"+
    "vec3 cp=vec3(1.*cos(ut*.3+2.),2.*sin(ut*.2),.4),"+
//         "ct=vec3(.0,.8*cos(ut),0.),"+
         "ct=vec3(.0,1.3*cos(ut),0.),"+
         "cd=normalize(ct-cp),"+
         "cr=normalize(cross(cd,vec3(.3*cos(.3*ut),0.,1.))),"+
         "cu=cross(cr,cd),"+
         "rd=normalize(2.*cd+cr*p.x*p.x+cu*p.y),"+
//         "rd=normalize(2.*cd+cr*p.x+cu*p.y),"+
         "c=ft(cp,rd)*"+
           "min(1.,1.8-dot(q,q))*"+
           "(.9+.1*sin(3.*sin(gc)*gl_FragCoord.y));"+
//         "(.6+.7*sin(3.*sin(gc)*gl_FragCoord.y));"+
    "gl_FragColor=vec4(c,1);"+
//    "gl_FragColor=vec4(vec3(.5,.45,.4)*(c.r+c.g+c.b),1);"+
"}",

       //******************* PART 1 D (3)**********************
"precision highp float;"+
"uniform float ut;"+
"uniform vec2 ur;"+
"float gc=fract(ut*3.2/3.),"+
      "gb=fract(gc*2.),"+
      "PI=3.14159;"+
"float fc(vec2 v)"+
"{"+
    "return sin(7.*length(v)+.2*ut);"+
"}"+
"vec3 ff(vec2 p)"+
"{"+
    "return (1.+sin("+
                   "fc(3.*sin(ut*vec2(.3,.2))-p)+"+
                   "fc(3.*sin(ut*vec2(.2,.1))-p)+"+
                   "fc(3.*sin(ut*vec2(.1,.4))-p)+"+
                   "vec3(0,.1,.2)))*max(1.-.1*length(p),0.);"+
"}"+
"vec3 ft(vec3 o,vec3 d)"+
"{"+
    "float e=.5*sin(gc*PI)-1.,"+
          "t=(e-o.z)/d.z,"+
          "r=1.5-(1.+sin(.3*ut))*gb,"+
          "a=dot(o,d)/dot(d,d),"+
          "b=dot(o,o)-r*r;"+
    "vec3 c=vec3(0),"+
         "p=o+t*d,"+
         "n,f;"+
    "if(t>0.)"+
      "c=ff(p.xy);"+
    "t=-a-sqrt(a*a-b);"+
    "p=o+t*d;"+
    "n=normalize(p);"+
    "f=reflect(d,n);"+
    "t=(e-p.z)/f.z;"+
    "if(a*a>b)"+
      "c=.2*ff((p+t*f).xy)+(1.-gb)*vec3(n+.5);"+
    "return c;"+
"}"+
"void main()"+
"{"+
    "vec2 p=(2.*gl_FragCoord.xy-ur)/ur.y,"+
         "q=2.*gl_FragCoord.xy/ur-1.;"+
//    "vec3 cp=vec3(6.*cos(gc*PI+.9),7.*sin(ut*3.2),2.),"+
    "vec3 cp=vec3(4.*cos(ut*.3+1.),3.*sin(ut*.2),2.),"+
         "ct=vec3(.0,.8*cos(ut),0.),"+
         "cd=normalize(ct-cp),"+
         "cr=normalize(cross(cd,vec3(.3*cos(.3*ut),0.,1.))),"+
         "cu=cross(cr,cd),"+
//         "rd=normalize(2.*cd+cr*p.x+cu*p.y*p.y),"+
         "rd=normalize(2.*cd+cr*p.x*p.x+cu*p.y),"+
//         "rd=normalize(2.*cd+cr*p.x+cu*p.y),"+
         "c=ft(cp,rd)*"+
           "min(1.,1.8-dot(q,q))*"+
           "(.9+.1*sin(3.*sin(gc)*gl_FragCoord.y))*"+
           "min(1.,15.8-ut*.1);"+
//         "(.6+.7*sin(3.*sin(gc)*gl_FragCoord.y));"+
//    "gl_FragColor=vec4(c,1);"+
    "gl_FragColor=vec4(vec3(.5,.45,.4)*(c.r+c.g+c.b),1);"+
"}",

       //******************* PART 1 E (4)**********************
"precision highp float;"+
"uniform float ut;"+
"uniform vec2 ur;"+
"float gc=fract(ut*3.2/3.),"+
      "gb=fract(gc*2.),"+
      "PI=3.14159;"+
"float fc(vec2 v)"+
"{"+
    "return sin(7.*length(v)+.2*ut);"+
"}"+
"vec3 ff(vec2 p)"+
"{"+
    "return (1.+sin("+
                   "fc(3.*sin(ut*vec2(.3,.2))-p)+"+
                   "fc(3.*sin(ut*vec2(.2,.1))-p)+"+
                   "fc(3.*sin(ut*vec2(.1,.4))-p)+"+
                   "vec3(0,.1,.2)))*max(1.-.1*length(p),0.);"+
"}"+
"vec3 ft(vec3 o,vec3 d)"+
"{"+
    "float e=.5*sin(gc*PI)-1.,"+
          "t=(e-o.z)/d.z,"+
          "r=1.5-(1.+sin(.3*ut))*gb,"+
          "a=dot(o,d)/dot(d,d),"+
          "b=dot(o,o)-r*r;"+
    "vec3 c=vec3(0),"+
         "p=o+t*d;"+
    "if(t>0.)"+
      "c=ff(p.xy);"+
    "t=-a-sqrt(a*a-b);"+
    "p=o+t*d;"+
    "vec3 n=normalize(p),"+
         "f=reflect(d,n);"+
    "t=(e-p.z)/f.z;"+
    "if(a*a>b)"+
      "c=.2*ff((p+t*f).xy)+"+
        "(1.-gb)*vec3(n+.5);"+
    "return c;"+
"}"+
"void main()"+
"{"+
    "vec2 p=(2.*gl_FragCoord.xy-ur)/ur.y,"+
         "q=2.*gl_FragCoord.xy/ur-1.;"+
    "vec3 cp=vec3(6.*cos(gc*PI+.9),7.*sin(ut*3.2),1.),"+
//    "vec3 cp=vec3(6.*cos(gc*PI+.9),7.*sin(ut*3.2),2.),"+
//    "vec3 cp=vec3(4.*cos(ut*.3+1.),3.*sin(ut*.2),2.),"+
         "ct=vec3(.0,1.8*cos(ut),0.),"+
         "cd=normalize(ct-cp),"+
         "cr=normalize(cross(cd,vec3(.3*cos(.3*ut),0.,1.))),"+
         "cu=cross(cr,cd),"+
         "rd=normalize(2.*cd+cr*pow(p.x,2.)+cu*p.y),"+
//         "rd=normalize(2.*cd+cr*p.x+cu*p.y),"+
         "c=ft(cp,rd)*"+
           "min(1.,1.8-dot(q,q))*"+
           "(.9+.1*sin(3.*sin(gc)*gl_FragCoord.y));"+
//         "(.6+.7*sin(3.*sin(gc)*gl_FragCoord.y));"+
    "gl_FragColor=vec4(c,1);"+
//    "gl_FragColor=vec4(vec3(.5,.45,.4)*(c.r+c.g+c.b),1);"+
"}",

       //******************* PART 1 F (5)**********************
"precision highp float;"+
"uniform float ut;"+
"uniform vec2 ur;"+
"float gc=fract(ut*3.2/3.),"+
      "gb=fract(gc*2.),"+
      "PI=3.14159;"+
"float fc(vec2 v)"+
"{"+
    "return sin(7.*length(v)+.2*ut);"+
"}"+
"vec3 ff(vec2 p)"+
"{"+
    "return (1.+sin("+
                   "fc(3.*sin(ut*vec2(.3,.2))-p)+"+
                   "fc(3.*sin(ut*vec2(.2,.1))-p)+"+
                   "fc(3.*sin(ut*vec2(.1,.4))-p)+"+
                   "vec3(0,.1,.2)))*max(1.-.1*length(p),0.);"+
"}"+
"vec3 ft(vec3 o,vec3 d)"+
"{"+
    "float e=.5*sin(gc*PI)-1.,"+
          "t=(e-o.z)/d.z,"+
          "r=1.5-(1.+sin(.3*ut))*gb,"+
          "a=dot(o,d)/dot(d,d),"+
          "b=dot(o,o)-r*r;"+
    "vec3 c=vec3(0),"+
         "p=o+t*d,"+
         "n,f;"+
    "if(t>0.)"+
      "c=ff(p.xy);"+
    "t=-a-sqrt(a*a-b);"+
    "p=o+t*d;"+
    "n=normalize(p);"+
    "f=reflect(d,n);"+
    "t=(e-p.z)/f.z;"+
    "if(a*a>b)"+
      "c=.2*ff((p+t*f).xy)+(1.-gb)*vec3(n+.5);"+
    "return c;"+
"}"+
"void main()"+
"{"+
    "vec2 p=(2.*gl_FragCoord.xy-ur)/ur.y,"+
         "q=2.*gl_FragCoord.xy/ur-1.;"+
    "vec3 cp=vec3(13.*cos(gc*PI+.9),9.*sin(ut*3.2),.6),"+
//         "cp=vec3(4.*cos(ut*.3+1.),3.*sin(ut*.2),2.);"+
         "ct=vec3(.0,.8*cos(ut),-2.),"+
         "cd=normalize(ct-cp),"+
         "cr=normalize(cross(cd,vec3(.3*cos(.3*ut),0.,1.))),"+
         "cu=cross(cr,cd),"+
//         "rd=normalize(2.*cd+cr*pow(p.x,2.)+cu*p.y),"+
         "rd=normalize(2.*cd+cr*p.x+cu*p.y),"+
         "c=ft(cp,rd)*"+
           "min(1.,1.8-dot(q,q))*"+
//         "(.9+.1*sin(3.*sin(gc)*gl_FragCoord.y));"+
           "(.6+.7*sin(3.*sin(gc)*gl_FragCoord.y));"+
    "gl_FragColor=vec4(c,1);"+
//    "gl_FragColor=vec4(vec3(.5,.45,.4)*(c.r+c.g+c.b),1);"+
"}",
       //******************* PART 2 A (6)**********************
"precision highp float;"+
"uniform float ut;"+
"uniform vec2 ur;"+
"float gc=fract(ut*3.2/3.),"+
      "gb=fract(gc*2.),"+
      "PI=3.14159;"+
"vec3 ff(vec2 p)"+
"{"+
    "vec2 q=vec2(sin(.08*p.x),4.*p.y);"+
    "vec3 c=vec3(0);"+
    "for(float i=0.;i<15.;i++)"+
      "c+=(1.+sin(i*sin(ut)+vec3(0.,1.3,2.2)))*.2/length(q-vec2(sin(i),12.*sin(.3*ut+i)));"+
    "return c+vec3(mix(mod(floor(p.x*.2)+floor(p.y*2.2),2.),.2,gc));"+
"}"+
"vec3 ft(vec3 o,vec3 d)"+
"{"+
    "d.y*=.65+.1*sin(.5*ut);"+
    "float D=1./(d.y*d.y+d.z*d.z),"+
          "a=(o.y*d.y+o.z*d.z)*D,"+
          "b=(o.y*o.y+o.z*o.z-36.)*D,"+
          "t=-a-sqrt(a*a-b);"+
    "o+=t*d;"+
    "return ff(vec2(o.x,atan(o.y,o.z)))*(1.+.01*t);"+
"}"+
"void main()"+
"{"+
    "vec2 p=(2.*gl_FragCoord.xy-ur)/ur.y,"+
         "q=2.*gl_FragCoord.xy/ur-1.;"+
    "vec3 cp=vec3(-ut*20.+1.,1.6*sin(ut*1.2),2.+2.*cos(ut*.3)),"+
         "ct=cp+vec3(1.,.3*cos(ut),-.2),"+
         "cd=normalize(ct-cp),"+
         "cr=normalize(cross(cd,vec3(.5*cos(.3*ut),0.,1.))),"+
         "cu=cross(cr,cd),"+
         "rd=normalize(2.*cd+cr*p.x+cu*p.y),"+
         "c=ft(cp,rd)*"+
           "min(1.,1.8-dot(q,q))*"+
           "(.9+.1*sin(3.*sin(gc)*gl_FragCoord.y));"+
    "gl_FragColor=vec4(c,1);"+
"}",

       //******************* PART 2 B (7)**********************
"precision highp float;"+
"uniform float ut;"+
"uniform vec2 ur;"+
"float gc=fract(ut*3.2/3.),"+
      "gb=fract(gc*2.),"+
      "PI=3.14159;"+
"vec3 ff(vec2 p)"+
"{"+
    "vec2 q=vec2(sin(.08*p.x),4.*p.y);"+
    "vec3 c=vec3(0);"+
    "for(float i=0.;i<15.;i++)"+
      "c+=(1.+sin(i*sin(ut)+vec3(0.,1.3,2.2)))*.2/length(q-vec2(sin(i),12.*sin(.3*ut+i)));"+
    "return c+vec3(mix(mod(floor(p.x*.2)+floor(p.y*2.2),2.),.2,gc));"+
"}"+
"vec3 ft(vec3 o,vec3 d)"+
"{"+
    "d.y*=.65+.1*sin(.5*ut);"+
    "float D=1./(d.y*d.y+d.z*d.z),"+
          "a=(o.y*d.y+o.z*d.z)*D,"+
          "b=(o.y*o.y+o.z*o.z-36.)*D,"+
          "t=-a-sqrt(a*a-b);"+
    "o+=t*d;"+
    "return ff(vec2(o.x,atan(o.y,o.z)))*(1.-.01*t);"+
"}"+
"void main()"+
"{"+
    "vec2 p=(2.*gl_FragCoord.xy-ur)/ur.y,"+
         "q=2.*gl_FragCoord.xy/ur-1.;"+
    "vec3 cp=vec3(-ut*50.+1.,1.6*sin(ut*2.2),2.+2.*cos(ut*.3)),"+
         "ct=cp+vec3(1.,.3*cos(ut),-.2),"+
         "cd=normalize(ct-cp),"+
         "cr=normalize(cross(cd,vec3(.5*cos(.3*ut),0.,1.))),"+
         "cu=cross(cr,cd),"+
         "rd=normalize(2.*cd+cr*p.x+cu*p.y),"+
         "c=ft(cp,rd)*"+
           "min(1.,1.8-dot(q,q))*"+
           "(.9+.1*sin(3.*sin(gc)*gl_FragCoord.y));"+
    "gl_FragColor=vec4(c,1);"+
"}"
    ],


    // Timeline
    parts = [
//        [0, 0],  // Intro
        [30, 6], // Tunnel
        [45, 2], // Mirrored slow
        [60, 1], // Wild
        [75, 0], // Basic
        [90, 5], // Even wilder
        [105, 4], // Mirrored fast
        [120, 7], // Tunnel
        [135, 3], // Sepia mirrored
        [9000, 0]
    ],

    gl, mCanvas, mWidth, mHeight;

    // Some constants - optimized away by closure compiler
    // These are usually shorter than using the gl.NAME variants, since they
    // will be replaced by numeric constants rather than propery long names.
    var VERTEX_SHADER = 0x8B31,
        FRAGMENT_SHADER = 0x8B30,
        ARRAY_BUFFER = 0x8892,
        STATIC_DRAW = 0x88E4,
        COLOR_BUFFER_BIT = 0x4000,
        TRIANGLE_STRIP = 5,
        FLOAT = 0x1406;

    var main = function()
    {
        try
        {
            // Update canvas size
            var w = window.innerWidth,
                h = window.innerHeight;
            if (w != mWidth || h != mHeight) {
                mCanvas.width = w;
                mCanvas.height = h;
                gl.viewport(0, 0, w, h);
                mWidth = w;
                mHeight = h;
            }

            // Update initialization
            mInitState++;
            gl.clearColor(0,(8-mInitState)/9,0,1);
            gl.clear(COLOR_BUFFER_BIT);

            if (mInitState < 8)
            {
                // Generate music!
                if (mInitState >= 0) generateMusic(mInitState);
                return;
            }
            if (mInitState == 8)
            {
                // Get & start playing the audio element!
                mAudio = createAudio();
                mAudio.play();
            }

		    // Get the current tick
            // Note: FF 6 has low precision currentTime, so the animation will
            // appear jerky!! Hope this bug is fixed soon:
            // https://bugzilla.mozilla.org/show_bug.cgi?id=587465
            var t = mAudio.currentTime;

		    // Timeline
            var prg = p[0]; // NOTE: This is the first part
            for (var i = 0; t > parts[i][0]; i++) prg = p[parts[i][1]];
            gl.useProgram(prg);

            // Set time and screen size for the animation
            gl.uniform1f(gl.getUniformLocation(prg, "ut"), t);
            gl.uniform2f(gl.getUniformLocation(prg, "ur"), w, h);

            // Draw
            gl.drawArrays(TRIANGLE_STRIP, 0, 4);
        }
        catch (err)
        {
            alert("Error: " + err.message);
        }
    };

    // App startup
    (function ()
    {
        try
        {
            // Init WebGL context
            mCanvas = document.createElement("canvas");
            document.body.appendChild(mCanvas);
            var s = mCanvas.style;
            s.position = "fixed";
            s.left = s.top = 0;
            gl = mCanvas.getContext('experimental-webgl');
            if (!gl)
            {
                alert("This demo requires WebGL");
                return;
            }

            // Init shaders
            for (var i = 0, j; i < 8; ++i)
            {
                p[i] = gl.createProgram();

                j = gl.createShader(VERTEX_SHADER);
                gl.shaderSource(j, v);
                gl.compileShader(j);
                if (!gl.getShaderParameter(j, gl.COMPILE_STATUS)) alert("Vertex shader  "+ i + ": "+ gl.getShaderInfoLog(j));
                gl.attachShader(p[i], j);

                j = gl.createShader(FRAGMENT_SHADER);
                gl.shaderSource(j, f[i]);
                gl.compileShader(j);
                if (!gl.getShaderParameter(j, gl.COMPILE_STATUS)) alert("Fragment shader  "+ i + ": "+ gl.getShaderInfoLog(j));
                gl.attachShader(p[i], j);

                gl.linkProgram(p[i]);
                if (!gl.getProgramParameter(p[i], gl.LINK_STATUS)) alert("Link program  "+ i + ": "+ gl.getProgramInfoLog(p[i]));
            }

            // Init vertex buffer for a regular screen-sized quad
            var vertices = [-1,-1, -1,1, 1,-1, 1,1];
            gl.bindBuffer(ARRAY_BUFFER, gl.createBuffer());
            gl.bufferData(ARRAY_BUFFER, new Float32Array(vertices), STATIC_DRAW);

            // Set up position attribute
            gl.enableVertexAttribArray(0);
            gl.vertexAttribPointer(0, 2, FLOAT, false, 0, 0); // position

            // Start the main loop
            setInterval(main, 1);
        }
        catch (err)
        {
            alert("Error initializing: " + err.message);
        }
    })();
})();

