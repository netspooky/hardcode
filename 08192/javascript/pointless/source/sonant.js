//------------------------------------------------------------------------------
// -*- mode: javascript; tab-width: 4; indent-tabs-mode: nil; -*-
//------------------------------------------------------------------------------
// Sonant for JavaScript, v1.0
//   A sound synth system targeted for tiny demos.
//
// This is a port of the Sonant player routine, originally written in C by
// Jake Taylor (Ferris / Youth Uprising).
//------------------------------------------------------------------------------
// Copyright (c) 2008-2009 Jake Taylor
// Copyright (c) 2011 Marcus Geelnard
//
// This software is provided 'as-is', without any express or implied
// warranty. In no event will the authors be held liable for any damages
// arising from the use of this software.
//
// Permission is granted to anyone to use this software for any purpose,
// including commercial applications, and to alter it and redistribute it
// freely, subject to the following restrictions:
//
// 1. The origin of this software must not be misrepresented; you must not
//    claim that you wrote the original software. If you use this software
//    in a product, an acknowledgment in the product documentation would be
//    appreciated but is not required.
//
// 2. Altered source versions must be plainly marked as such, and must not be
//    misrepresented as being the original software.
//
// 3. This notice may not be removed or altered from any source
//    distribution.
//------------------------------------------------------------------------------
//
// Example usage:
//
//   var songGen = new sonant();
//   for (var t = 0; t < 8; t++)
//       songGen.generate(t);
//   var audio = songGen.createAudio();
//   audio.loop = true;
//   audio.play();
//
//------------------------------------------------------------------------------

var sonant = function()
{
    //--------------------------------------------------------------------------
    // Private members
    //--------------------------------------------------------------------------

    //**************************************************************************
    // Music
    //**************************************************************************

    // *** INSERT MUSIC HERE ***
    // var song = ???;
    var song = {
      // Song length in seconds (how much data to generate)
      songLen: 137,  // Tune this to fit your needs!

      songData: [
        { // Instrument 0
          // Oscillator 1
          osc1_oct: 6,
          osc1_det: 0,
          osc1_detune: 0,
          osc1_xenv: 1,
          osc1_vol: 255,
          osc1_waveform: 0,
          // Oscillator 2
          osc2_oct: 6,
          osc2_det: 0,
          osc2_detune: 0,
          osc2_xenv: 1,
          osc2_vol: 255,
          osc2_waveform: 0,
          // Noise oscillator
          noise_fader: 14,
          // Envelope
          env_attack: 50,
          env_sustain: 150,
          env_release: 8181,
          env_master: 61,
          // Effects
          fx_filter: 2,
          fx_freq: 5900,
          fx_resonance: 240,
          fx_delay_time: 1,
          fx_delay_amt: 4,
          fx_pan_freq: 0,
          fx_pan_amt: 0,
          // LFO
          lfo_osc1_freq: 0,
          lfo_fx_freq: 0,
          lfo_freq: 0,
          lfo_amt: 0,
          lfo_waveform: 0,
          // Patterns
          p: [0,0,0,0,1,1,1,2,1,1,1,2,3,3,3,4,1,2,1,2,1,1,2,2,1,2,1,2,3,4,3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
          // Columns
          c: [
            {n: [156,0,156,0,0,0,156,156,0,156,156,0,0,0,0,0,156,0,156,0,0,0,156,156,0,156,156,0,0,0,0,156]},
            {n: [156,0,156,0,0,0,156,156,0,156,156,0,0,0,0,0,156,0,156,0,0,0,156,156,0,156,156,0,156,0,156,156]},
            {n: [156,0,0,0,0,0,0,0,0,156,156,0,0,0,0,0,156,0,0,0,0,0,0,0,0,156,156,0,156,0,0,0]},
            {n: [156,0,0,0,156,0,0,0,0,156,156,0,0,0,0,0,156,0,0,0,0,156,156,0,0,156,156,0,156,0,156,156]},
            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]}
          ]
        },
        { // Instrument 1
          // Oscillator 1
          osc1_oct: 4,
          osc1_det: 0,
          osc1_detune: 0,
          osc1_xenv: 1,
          osc1_vol: 221,
          osc1_waveform: 3,
          // Oscillator 2
          osc2_oct: 4,
          osc2_det: 0,
          osc2_detune: 0,
          osc2_xenv: 1,
          osc2_vol: 210,
          osc2_waveform: 0,
          // Noise oscillator
          noise_fader: 16,
          // Envelope
          env_attack: 1234,
          env_sustain: 49,
          env_release: 5970,
          env_master: 255,
          // Effects
          fx_filter: 3,
          fx_freq: 11024,
          fx_resonance: 240,
          fx_delay_time: 6,
          fx_delay_amt: 24,
          fx_pan_freq: 0,
          fx_pan_amt: 20,
          // LFO
          lfo_osc1_freq: 0,
          lfo_fx_freq: 0,
          lfo_freq: 7,
          lfo_amt: 64,
          lfo_waveform: 0,
          // Patterns
          p: [0,0,1,2,1,1,1,2,1,1,1,2,3,1,3,2,1,1,2,2,1,2,1,2,1,1,2,2,1,1,3,3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
          // Columns
          c: [
            {n: [0,0,0,0,132,0,0,0,0,0,0,0,132,0,0,0,0,0,0,0,132,0,0,0,0,0,0,0,132,0,0,0]},
            {n: [0,0,0,0,132,0,0,0,0,0,0,0,132,0,0,0,0,0,0,0,132,0,0,0,132,0,0,0,132,0,132,0]},
            {n: [0,0,0,0,0,0,0,0,0,0,0,0,156,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,156,0,0,0]},
            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]}
          ]
        },
        { // Instrument 2
          // Oscillator 1
          osc1_oct: 7,
          osc1_det: 0,
          osc1_detune: 0,
          osc1_xenv: 0,
          osc1_vol: 192,
          osc1_waveform: 2,
          // Oscillator 2
          osc2_oct: 7,
          osc2_det: 0,
          osc2_detune: 0,
          osc2_xenv: 0,
          osc2_vol: 201,
          osc2_waveform: 3,
          // Noise oscillator
          noise_fader: 0,
          // Envelope
          env_attack: 100,
          env_sustain: 150,
          env_release: 13636,
          env_master: 191,
          // Effects
          fx_filter: 2,
          fx_freq: 5839,
          fx_resonance: 254,
          fx_delay_time: 6,
          fx_delay_amt: 121,
          fx_pan_freq: 6,
          fx_pan_amt: 147,
          // LFO
          lfo_osc1_freq: 0,
          lfo_fx_freq: 1,
          lfo_freq: 6,
          lfo_amt: 195,
          lfo_waveform: 0,
          // Patterns
          p: [1,2,1,3,1,2,1,3,1,2,1,3,4,5,4,6,7,8,7,9,1,2,7,9,1,3,7,8,4,5,4,6,10,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
          // Columns
          c: [
            {n: [144,0,0,0,0,0,0,0,0,0,0,0,151,0,0,0,147,0,0,0,0,0,0,0,0,0,0,0,149,0,0,0]},
            {n: [142,0,0,0,0,0,0,0,0,0,0,0,146,0,0,0,149,0,0,0,0,0,0,0,0,0,0,0,147,0,0,0]},
            {n: [142,0,0,0,0,0,0,0,0,0,0,0,146,0,0,0,151,0,0,0,0,0,0,0,0,0,0,0,146,0,146,0]},
            {n: [144,0,0,0,0,0,0,0,0,0,0,132,135,139,0,132,147,0,0,0,0,0,0,0,0,0,0,132,135,134,0,130]},
            {n: [142,0,0,0,0,0,0,0,0,0,0,130,132,134,0,130,149,0,0,0,0,0,0,0,0,0,0,139,137,135,0,134]},
            {n: [142,0,0,0,0,0,0,0,0,0,0,130,132,134,0,130,151,0,0,0,0,0,130,0,134,0,139,0,146,0,146,0]},
            {n: [144,0,0,0,0,0,0,0,0,0,0,0,142,0,144,0,146,0,0,0,0,0,0,0,0,0,0,0,149,0,147,0]},
            {n: [151,0,0,0,0,0,0,0,0,0,0,0,149,0,151,0,152,0,0,0,0,0,0,0,0,0,0,0,147,0,146,0]},
            {n: [146,0,0,0,0,0,0,0,0,0,0,0,147,0,149,0,147,0,0,0,0,0,0,0,142,0,146,0,149,0,142,0]},
            {n: [144,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]}
          ]
        },
        { // Instrument 3
          // Oscillator 1
          osc1_oct: 7,
          osc1_det: 0,
          osc1_detune: 0,
          osc1_xenv: 0,
          osc1_vol: 255,
          osc1_waveform: 2,
          // Oscillator 2
          osc2_oct: 8,
          osc2_det: 0,
          osc2_detune: 18,
          osc2_xenv: 0,
          osc2_vol: 255,
          osc2_waveform: 2,
          // Noise oscillator
          noise_fader: 0,
          // Envelope
          env_attack: 27636,
          env_sustain: 2900,
          env_release: 41496,
          env_master: 247,
          // Effects
          fx_filter: 2,
          fx_freq: 200,
          fx_resonance: 254,
          fx_delay_time: 8,
          fx_delay_amt: 24,
          fx_pan_freq: 0,
          fx_pan_amt: 0,
          // LFO
          lfo_osc1_freq: 0,
          lfo_fx_freq: 0,
          lfo_freq: 0,
          lfo_amt: 0,
          lfo_waveform: 0,
          // Patterns
          p: [0,0,0,0,1,2,1,3,1,2,1,3,0,0,0,0,4,5,4,2,1,2,4,2,1,3,4,5,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
          // Columns
          c: [
            {n: [144,147,151,0,0,0,0,0,0,0,0,0,0,0,0,0,144,147,151,0,0,0,0,0,0,0,0,0,0,0,0,0]},
            {n: [142,146,149,0,0,0,0,0,0,0,0,0,0,0,0,0,142,146,149,0,0,0,0,0,0,0,0,0,0,0,0,0]},
            {n: [142,146,151,0,0,0,0,0,0,0,0,0,0,0,0,0,142,146,151,0,0,0,0,0,0,0,0,0,139,0,0,0]},
            {n: [144,147,151,0,0,0,0,0,0,0,0,0,0,0,0,0,142,146,149,0,0,0,0,0,0,0,0,0,0,0,0,0]},
            {n: [142,146,151,0,0,0,0,0,0,0,0,0,0,0,0,0,140,144,149,0,0,0,0,0,0,0,0,0,0,0,0,0]},
            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]}
          ]
        },
        { // Instrument 4
          // Oscillator 1
          osc1_oct: 7,
          osc1_det: 0,
          osc1_detune: 0,
          osc1_xenv: 0,
          osc1_vol: 192,
          osc1_waveform: 2,
          // Oscillator 2
          osc2_oct: 7,
          osc2_det: 0,
          osc2_detune: 8,
          osc2_xenv: 0,
          osc2_vol: 130,
          osc2_waveform: 3,
          // Noise oscillator
          noise_fader: 0,
          // Envelope
          env_attack: 100,
          env_sustain: 150,
          env_release: 13636,
          env_master: 63,
          // Effects
          fx_filter: 3,
          fx_freq: 1655,
          fx_resonance: 254,
          fx_delay_time: 0,
          fx_delay_amt: 0,
          fx_pan_freq: 4,
          fx_pan_amt: 255,
          // LFO
          lfo_osc1_freq: 0,
          lfo_fx_freq: 1,
          lfo_freq: 6,
          lfo_amt: 13,
          lfo_waveform: 0,
          // Patterns
          p: [0,0,0,0,0,0,0,0,1,2,1,3,0,0,0,0,4,5,4,6,1,2,4,6,1,3,4,5,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
          // Columns
          c: [
            {n: [144,151,144,0,144,142,144,0,144,147,142,0,151,149,147,0,147,142,144,0,144,142,144,0,144,147,146,0,142,146,147,0]},
            {n: [142,146,142,0,137,139,137,0,139,142,147,0,149,147,146,0,146,144,146,0,144,142,144,0,146,147,149,0,147,146,144,0]},
            {n: [146,144,142,0,139,142,147,0,146,142,139,0,137,139,142,0,144,146,144,0,146,147,146,0,147,149,151,0,151,147,146,147]},
            {n: [144,151,147,0,147,149,152,0,151,149,147,0,146,142,144,0,146,142,146,0,149,151,149,0,147,142,146,0,149,151,147,149]},
            {n: [151,154,156,0,151,135,146,0,142,144,146,0,142,144,146,135,149,147,152,0,151,147,149,0,144,147,144,0,147,149,146,147]},
            {n: [146,149,147,0,151,154,149,0,146,147,146,0,147,151,149,0,151,149,151,0,144,146,147,0,146,144,142,139,144,140,142,147]},
            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]}
          ]
        },
        { // Instrument 5
          // Oscillator 1
          osc1_oct: 4,
          osc1_det: 0,
          osc1_detune: 0,
          osc1_xenv: 0,
          osc1_vol: 255,
          osc1_waveform: 3,
          // Oscillator 2
          osc2_oct: 5,
          osc2_det: 0,
          osc2_detune: 0,
          osc2_xenv: 0,
          osc2_vol: 255,
          osc2_waveform: 0,
          // Noise oscillator
          noise_fader: 127,
          // Envelope
          env_attack: 22,
          env_sustain: 22,
          env_release: 2193,
          env_master: 162,
          // Effects
          fx_filter: 4,
          fx_freq: 4067,
          fx_resonance: 176,
          fx_delay_time: 4,
          fx_delay_amt: 12,
          fx_pan_freq: 2,
          fx_pan_amt: 29,
          // LFO
          lfo_osc1_freq: 0,
          lfo_fx_freq: 1,
          lfo_freq: 3,
          lfo_amt: 96,
          lfo_waveform: 0,
          // Patterns
          p: [0,0,0,0,0,0,0,0,1,1,1,1,3,3,3,3,1,1,1,2,1,1,1,2,1,2,1,2,3,3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
          // Columns
          c: [
            {n: [144,0,0,0,0,0,0,0,0,0,0,0,0,0,0,144,144,0,0,0,0,0,0,0,0,0,0,0,0,0,0,144]},
            {n: [144,0,0,0,0,0,0,132,132,0,0,0,0,0,0,144,144,0,0,0,0,0,0,132,132,0,0,0,0,0,0,144]},
            {n: [144,0,0,0,0,0,0,0,144,0,0,0,0,0,0,0,144,0,0,0,0,0,0,0,144,0,0,0,0,0,0,0]},
            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]}
          ]
        },
        { // Instrument 6
          // Oscillator 1
          osc1_oct: 7,
          osc1_det: 0,
          osc1_detune: 0,
          osc1_xenv: 0,
          osc1_vol: 192,
          osc1_waveform: 0,
          // Oscillator 2
          osc2_oct: 7,
          osc2_det: 0,
          osc2_detune: 0,
          osc2_xenv: 0,
          osc2_vol: 192,
          osc2_waveform: 0,
          // Noise oscillator
          noise_fader: 0,
          // Envelope
          env_attack: 200,
          env_sustain: 2000,
          env_release: 20000,
          env_master: 192,
          // Effects
          fx_filter: 0,
          fx_freq: 11025,
          fx_resonance: 255,
          fx_delay_time: 0,
          fx_delay_amt: 0,
          fx_pan_freq: 0,
          fx_pan_amt: 0,
          // LFO
          lfo_osc1_freq: 0,
          lfo_fx_freq: 0,
          lfo_freq: 0,
          lfo_amt: 0,
          lfo_waveform: 0,
          // Patterns
          p: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
          // Columns
          c: [
            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]}
          ]
        },
        { // Instrument 7
          // Oscillator 1
          osc1_oct: 7,
          osc1_det: 0,
          osc1_detune: 0,
          osc1_xenv: 0,
          osc1_vol: 192,
          osc1_waveform: 0,
          // Oscillator 2
          osc2_oct: 7,
          osc2_det: 0,
          osc2_detune: 0,
          osc2_xenv: 0,
          osc2_vol: 192,
          osc2_waveform: 0,
          // Noise oscillator
          noise_fader: 0,
          // Envelope
          env_attack: 200,
          env_sustain: 2000,
          env_release: 20000,
          env_master: 192,
          // Effects
          fx_filter: 0,
          fx_freq: 11025,
          fx_resonance: 255,
          fx_delay_time: 0,
          fx_delay_amt: 0,
          fx_pan_freq: 0,
          fx_pan_amt: 0,
          // LFO
          lfo_osc1_freq: 0,
          lfo_fx_freq: 0,
          lfo_freq: 0,
          lfo_amt: 0,
          lfo_waveform: 0,
          // Patterns
          p: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
          // Columns
          c: [
            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]}
          ]
        }
      ],
      rowLen: 5513,   // In sample lengths
      endPattern: 34  // End pattern
    };

    //**************************************************************************
    // End of Music
    //**************************************************************************

    // Wave data configuration
    var WAVE_SPS = 44100;                    // Samples per second
    var WAVE_CHAN = 2;                       // Channels
    var WAVE_SIZE = WAVE_SPS * song.songLen; // Total song size (in samples)
 
    // Work buffers
    var chnBufWork, mixBufWork;


    //--------------------------------------------------------------------------
    // Private methods
    //--------------------------------------------------------------------------

    // Initialize buffers etc. (constructor)
    (function ()
    {
        // Note 1: We use a CanvasPixelArray instead of a traditional ECMAScript
        // array of numbers, since that gives us a typed byte array (much more
        // compact, and quite fast).
        //
        // Note 2: We would LIKE to create an (N x 1) bitmap buffer, but some
        // browsers (hrrr-o-mme...) have an upper bitmap size limit of
        // 32767 x 32767, so we create a square bitmap buffer (with some
        // trailing bytes that we don't care too much about)
        var size = Math.ceil(Math.sqrt(WAVE_SIZE * WAVE_CHAN / 2));

        var ctx = document.createElement('canvas').getContext('2d');

        // Create the channel work buffer
        chnBufWork = ctx.createImageData(size, size).data;

        // Create & clear the channel mix buffer
        var b, mixBuf = ctx.createImageData(size, size).data;
        for(b = size * size * 4 - 2; b >= 0 ; b -= 2)
        {
            mixBuf[b] = 0;
            mixBuf[b + 1] = 128;
        }
        mixBufWork = mixBuf;
    })();

    // Oscillators
    function osc_sin(value)
    {
        return Math.sin(value * 6.283184);
    }

    function osc_square(value)
    {
        if(osc_sin(value) < 0) return -1;
        return 1;
    }

    function osc_saw(value)
    {
        return (value % 1) - 0.5;
    }

    function osc_tri(value)
    {
        var v2 = (value % 1) * 4;
        if(v2 < 2) return v2 - 1;
        return 3 - v2;
    }

    function getnotefreq(n)
    {
        return 0.00390625 * Math.pow(1.059463094, n - 128);
    }


    //--------------------------------------------------------------------------
    // Public members
    //--------------------------------------------------------------------------

    // Number of lines per second (song speed)
    this.lps = WAVE_SPS / song.rowLen;


    //--------------------------------------------------------------------------
    // Public methods
    //--------------------------------------------------------------------------

    // Generate audio data for a single track
    this.generate = function (track)
    {
        // Array of oscillator functions
        var oscillators =
        [
            osc_sin,
            osc_square,
            osc_saw,
            osc_tri
        ];

        // Local variables
        var i, j, k, b, p, row, n, currentpos, cp,
            c1, c2, q, low, band, high, t, lfor, e, x,
            rsample, f, da, o1t, o2t;

        // Preload/precalc some properties/expressions (for improved performance)
        var chnBuf = chnBufWork,
            mixBuf = mixBufWork,
            waveSamples = WAVE_SIZE,
            waveBytes = WAVE_SIZE * WAVE_CHAN * 2,
            instr = song.songData[track],
            rowLen = song.rowLen,
            osc_lfo = oscillators[instr.lfo_waveform],
            osc1 = oscillators[instr.osc1_waveform],
            osc2 = oscillators[instr.osc2_waveform],
            attack = instr.env_attack,
            sustain = instr.env_sustain,
            release = instr.env_release,
            panFreq = Math.pow(2, instr.fx_pan_freq - 8) / rowLen,
            lfoFreq = Math.pow(2, instr.lfo_freq - 8) / rowLen;

        // Clear buffer
        for(b = 0; b < waveBytes; b += 2)
        {
            chnBuf[b] = 0;
            chnBuf[b+1] = 128;
        }

        currentpos = 0;
        for(p = 0; p < song.endPattern - 1; ++p) // Patterns
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
                        o1t = getnotefreq(n + (instr.osc1_oct - 8) * 12 + instr.osc1_det) * (1 + 0.0008 * instr.osc1_detune);
                        o2t = getnotefreq(n + (instr.osc2_oct - 8) * 12 + instr.osc2_det) * (1 + 0.0008 * instr.osc2_detune);

                        // State variable init
                        q = instr.fx_resonance / 255;
                        low = band = 0;
                        for (j = attack + sustain + release - 1; j >= 0; --j)
                        {
                            k = j + currentpos;

                            // LFO
                            lfor = osc_lfo(k * lfoFreq) * instr.lfo_amt / 512 + 0.5;

                            // Envelope
                            e = 1;
                            if(j < attack)
                                e = j / attack;
                            else if(j >= attack + sustain)
                                e -= (j - attack - sustain) / release;

                            // Oscillator 1
                            t = o1t;
                            if(instr.lfo_osc1_freq) t += lfor;
                            if(instr.osc1_xenv) t *= e * e;
                            c1 += t;
                            rsample = osc1(c1) * instr.osc1_vol;

                            // Oscillator 2
                            t = o2t;
                            if(instr.osc2_xenv) t *= e * e;
                            c2 += t;
                            rsample += osc2(c2) * instr.osc2_vol;

                            // Noise oscillator
                            if(instr.noise_fader) rsample += (2*Math.random()-1) * instr.noise_fader * e;

                            rsample *= e / 255;

                            // State variable filter
                            f = instr.fx_freq;
                            if(instr.lfo_fx_freq) f *= lfor;
                            f = 1.5 * Math.sin(f * 3.141592 / WAVE_SPS);
                            low += f * band;
                            high = q * (rsample - band) - low;
                            band += f * high;
                            switch(instr.fx_filter)
                            {
                                case 1: // Hipass
                                    rsample = high;
                                    break;
                                case 2: // Lopass
                                    rsample = low;
                                    break;
                                case 3: // Bandpass
                                    rsample = band;
                                    break;
                                case 4: // Notch
                                    rsample = low + high;
                                default:
                            }

                            // Panning & master volume
                            t = osc_sin(k * panFreq) * instr.fx_pan_amt / 512 + 0.5;
                            rsample *= 39 * instr.env_master;

                            // Add to 16-bit channel buffer
                            k <<= 2;
                            x = chnBuf[k] + (chnBuf[k+1] << 8) + rsample * (1 - t);
                            chnBuf[k] = x & 255;
                            chnBuf[k+1] = (x >> 8) & 255;
                            x = chnBuf[k+2] + (chnBuf[k+3] << 8) + rsample * t;
                            chnBuf[k+2] = x & 255;
                            chnBuf[k+3] = (x >> 8) & 255;
                        }
                    }
                }
                currentpos += rowLen;
            }
        }

        // Delay
        p = (instr.fx_delay_time * rowLen) >> 1;
        t = instr.fx_delay_amt / 255;

        for(n = 0; n < waveSamples - p; ++n)
        {
            b = 4 * n;
            k = 4 * (n + p);

            // Left channel = left + right[-p] * t
            x = chnBuf[k] + (chnBuf[k+1] << 8) +
                (chnBuf[b+2] + (chnBuf[b+3] << 8) - 32768) * t;
            chnBuf[k] = x & 255;
            chnBuf[k+1] = (x >> 8) & 255;

            // Right channel = right + left[-p] * t
            x = chnBuf[k+2] + (chnBuf[k+3] << 8) +
                (chnBuf[b] + (chnBuf[b+1] << 8) - 32768) * t;
            chnBuf[k+2] = x & 255;
            chnBuf[k+3] = (x >> 8) & 255;
        }

        // Add to mix buffer
        for(b = 0; b < waveBytes; b += 2)
        {
            x = mixBuf[b] + (mixBuf[b+1] << 8) + chnBuf[b] + (chnBuf[b+1] << 8) - 32768;
            mixBuf[b] = x & 255;
            mixBuf[b+1] = (x >> 8) & 255;
        }
    };

    // Create an HTML audio element from the generated audio data
    this.createAudio = function()
    {
        // Local variables
        var b, k, x, wave, l1, l2, s, y;

        // Turn critical object properties into local variables (performance)
        var mixBuf = mixBufWork,
            waveBytes = WAVE_SIZE * WAVE_CHAN * 2;

        // We no longer need the channel working buffer
        chnBufWork = null;

        // Convert to a WAVE file (in a binary string)
        l1 = waveBytes - 8;
        l2 = l1 - 36;
        wave = String.fromCharCode(82,73,70,70,
                                   l1 & 255,(l1 >> 8) & 255,(l1 >> 16) & 255,(l1 >> 24) & 255,
                                   87,65,86,69,102,109,116,32,16,0,0,0,1,0,2,0,
                                   68,172,0,0,16,177,2,0,4,0,16,0,100,97,116,97,
                                   l2 & 255,(l2 >> 8) & 255,(l2 >> 16) & 255,(l2 >> 24) & 255);
        for (b = 0; b < waveBytes;)
        {
            // This is a GC & speed trick: don't add one char at a time - batch up
            // larger partial strings
            x = "";
            for (k = 0; k < 256 && b < waveBytes; ++k, b += 2)
            {
                // Note: We amplify and clamp here
                y = 4 * (mixBuf[b] + (mixBuf[b+1] << 8) - 32768);
                y = y < -32768 ? -32768 : (y > 32767 ? 32767 : y);
                x += String.fromCharCode(y & 255, (y >> 8) & 255);
            }
            wave += x;
        }

        // Convert the string buffer to a base64 data uri
        s = "data:audio/wav;base64," + btoa(wave);
        wave = null;

        // Return the music as an audio element
        return new Audio(s);
    };

    // Get n samples of wave data at time t [s]. Wave data in range [0,1].
    this.getData = function(t, n)
    {
        for (var i = Math.floor(t * WAVE_SPS), j = 0, d = [], b = mixBufWork; j < 2*n; j += 2)
        {
            var k = 4 * (i + j) + 1;
            d.push(t > 0 && k < b.length ? (b[k] + b[k-1]/256) / 256 : 0.5);
        }
        return d;
    };
};

