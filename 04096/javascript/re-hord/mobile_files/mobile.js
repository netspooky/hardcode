/* -*- mode: javascript; tab-width: 4; indent-tabs-mode: nil; -*-
 ******************************************************************************
 * This is "rechord", a 4k JavaScript demo with music and 3D gfx
 * Copyright (c) 2013 m / Bits'n'Bites
 ******************************************************************************/

/******************************************************************************
 * Possible optimizations:
 *  - Remove gl_PointSize in star shader
 *  - Optimize common constants & expressions in shaders
 *  - Simplify audio.currentTime (ignore poor precision)
 *  - Simplify progress bar
 *  - Simplify music
 *  - Hard-code mNumScrollVertices
 ******************************************************************************/

(function ()
{
    // Macros/shorthands
    var rnd = Math.random;

    //--------------------------------------------------------------------------
    // Private members
    //--------------------------------------------------------------------------

    //**************************************************************************
    // Music
    //**************************************************************************

    // Song data
    var mSong = {
      songData: [
        { // Instrument 0
          i: [
          2, // OSC1_WAVEFORM
          254, // OSC1_VOL
          128, // OSC1_SEMI
          0, // OSC1_XENV
          2, // OSC2_WAVEFORM
          255, // OSC2_VOL
          128, // OSC2_SEMI
          20, // OSC2_DETUNE
          0, // OSC2_XENV
          0, // NOISE_VOL
          5, // ENV_ATTACK
          45, // ENV_SUSTAIN
          28, // ENV_RELEASE
          0, // LFO_WAVEFORM
          0, // LFO_AMT
          0, // LFO_FREQ
          0, // LFO_FX_FREQ
          2, // FX_FILTER
          12, // FX_FREQ
          0, // FX_RESONANCE
          12, // FX_DIST
          91, // FX_DRIVE
          57, // FX_PAN_AMT
          1, // FX_PAN_FREQ
          69, // FX_DELAY_AMT
          2 // FX_DELAY_TIME
          ],
          // Patterns
          p: [1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,3,4,3,4,3,4,1,2,1,2,3,4],
          // Columns
          c: [
            {n: [120,,,,,,,,,,120,,,120,,,123,,,,,,123,,,,123],
             fx: []},
            {n: [118,,,,,,,,,,118,,,118,,,113,,,,,,115],
             fx: []},
            {n: [120,,108,,120,,108,,120,,108,,120,,108,123,,,111,,123,,111,,123,,111,,123,,111,118],
             fx: [,,,,,,,,,,,,,,12,12,,,,,,,,,,,,,,,12,12,,,,,,,,,,,,,,,17,45,,,,,,,,,,,,,,,17,45]},
            {n: [,,106,,118,,106,,118,,106,,118,,106,113,,,101,,113,,101,,115,,103,,115,,103],
             fx: [,,,,,,,,,,,,,,12,12,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,17,45]}
          ]
        },
        { // Instrument 1
          i: [
          3, // OSC1_WAVEFORM
          194, // OSC1_VOL
          128, // OSC1_SEMI
          0, // OSC1_XENV
          2, // OSC2_WAVEFORM
          192, // OSC2_VOL
          128, // OSC2_SEMI
          3, // OSC2_DETUNE
          0, // OSC2_XENV
          0, // NOISE_VOL
          12, // ENV_ATTACK
          32, // ENV_SUSTAIN
          43, // ENV_RELEASE
          0, // LFO_WAVEFORM
          84, // LFO_AMT
          7, // LFO_FREQ
          1, // LFO_FX_FREQ
          3, // FX_FILTER
          21, // FX_FREQ
          63, // FX_RESONANCE
          1, // FX_DIST
          32, // FX_DRIVE
          48, // FX_PAN_AMT
          3, // FX_PAN_FREQ
          44, // FX_DELAY_AMT
          4 // FX_DELAY_TIME
          ],
          // Patterns
          p: [1,2,1,2,1,2,1,2,1,2,1,2,,,,,3,4,5,4,,,1,2,,,,,1,2],
          // Columns
          c: [
            {n: [,,,,139,,,,,,,,139,,,,,,,,139,,,,,,,,139,,,,,,,,144,,,,,,,,144,,,,,,,,142,,,,,,,,142,,,,,,,,147,,,,,,,,147,,,,,,,,147,,,,,,,,147],
             fx: [12,3,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,32,128]},
            {n: [,,,,137,,,,,,,,137,,,,,,,,137,,,,,,,,139,,,,,,,,142,,,,,,,,142,,,,,,,,140,,,,,,,,143,,,,,,,,146,,,,,,,,146,,,,,,,,144,,,,,,,,146],
             fx: []},
            {n: [139,144,147,144,139,144,147,144,139,144,147,144,139,144,147,144,139,142,147,142,139,142,147,142,139,142,147,142,139,142,147,142],
             fx: [12]},
            {n: [137,142,146,142,137,142,146,142,137,142,146,142,137,142,146,142,137,140,144,140,137,140,144,140,139,143,146,143,139,143,146,143],
             fx: []},
            {n: [139,144,147,144,139,144,147,144,139,144,147,144,139,144,147,144,139,142,147,142,139,142,147,142,139,142,147,142,139,142,147,142],
             fx: [3,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,140]}
          ]
        },
        { // Instrument 2
          i: [
          2, // OSC1_WAVEFORM
          192, // OSC1_VOL
          128, // OSC1_SEMI
          0, // OSC1_XENV
          2, // OSC2_WAVEFORM
          192, // OSC2_VOL
          116, // OSC2_SEMI
          1, // OSC2_DETUNE
          0, // OSC2_XENV
          0, // NOISE_VOL
          77, // ENV_ATTACK
          22, // ENV_SUSTAIN
          76, // ENV_RELEASE
          2, // LFO_WAVEFORM
          121, // LFO_AMT
          6, // LFO_FREQ
          1, // LFO_FX_FREQ
          2, // FX_FILTER
          28, // FX_FREQ
          158, // FX_RESONANCE
          36, // FX_DIST
          51, // FX_DRIVE
          127, // FX_PAN_AMT
          4, // FX_PAN_FREQ
          48, // FX_DELAY_AMT
          4 // FX_DELAY_TIME
          ],
          // Patterns
          p: [,,,,1,2,,,1,2,1,2,1,2,1,2,,,1,2,1,2,1,2,,,,,1,2],
          // Columns
          c: [
            {n: [120,,,,,,,,,,,,,,,,123],
             fx: [13,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,150]},
            {n: [118,,,,,,,,,,,,,,,,113,,,,,,,,115],
             fx: [13,,,,,,,,,,,,,,,,13,,,,,,,,,,,,,,,,150,,,,,,,,,,,,,,,,76]}
          ]
        },
        { // Instrument 3
          i: [
          2, // OSC1_WAVEFORM
          0, // OSC1_VOL
          128, // OSC1_SEMI
          1, // OSC1_XENV
          0, // OSC2_WAVEFORM
          0, // OSC2_VOL
          128, // OSC2_SEMI
          0, // OSC2_DETUNE
          0, // OSC2_XENV
          255, // NOISE_VOL
          5, // ENV_ATTACK
          0, // ENV_SUSTAIN
          25, // ENV_RELEASE
          0, // LFO_WAVEFORM
          0, // LFO_AMT
          0, // LFO_FREQ
          0, // LFO_FX_FREQ
          3, // FX_FILTER
          255, // FX_FREQ
          242, // FX_RESONANCE
          0, // FX_DIST
          29, // FX_DRIVE
          0, // FX_PAN_AMT
          0, // FX_PAN_FREQ
          0, // FX_DELAY_AMT
          0 // FX_DELAY_TIME
          ],
          // Patterns
          p: [,,,,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,,,1],
          // Columns
          c: [
            {n: [,,,,,,,,,147,147,147,,,,,,,,,,,,,,,,,147,,147],
             fx: []},
            {n: [,,,,,,,,,147,147,147,,,,,,,147,,,147,147,,,,,,147,147,147,147],
             fx: []}
          ]
        },
        { // Instrument 4
          i: [
          0, // OSC1_WAVEFORM
          255, // OSC1_VOL
          116, // OSC1_SEMI
          1, // OSC1_XENV
          0, // OSC2_WAVEFORM
          255, // OSC2_VOL
          126, // OSC2_SEMI
          0, // OSC2_DETUNE
          1, // OSC2_XENV
          0, // NOISE_VOL
          4, // ENV_ATTACK
          6, // ENV_SUSTAIN
          40, // ENV_RELEASE
          0, // LFO_WAVEFORM
          0, // LFO_AMT
          0, // LFO_FREQ
          0, // LFO_FX_FREQ
          2, // FX_FILTER
          14, // FX_FREQ
          0, // FX_RESONANCE
          2, // FX_DIST
          35, // FX_DRIVE
          37, // FX_PAN_AMT
          10, // FX_PAN_FREQ
          0, // FX_DELAY_AMT
          0 // FX_DELAY_TIME
          ],
          // Patterns
          p: [,,,,1,1,1,1,1,1,1,1,,,,2,1,1,1,1,1,1,1,1,,,,,1,1],
          // Columns
          c: [
            {n: [135,,,,135,,,,135,,,,135,,,,135,,,,135,,,,135,,,,135],
             fx: []},
            {n: [,,,,,,,,,,,,,,,,,,,,,,,,135,,,,135,,135,135],
             fx: []}
          ]
        },
        { // Instrument 5
          i: [
          2, // OSC1_WAVEFORM
          100, // OSC1_VOL
          128, // OSC1_SEMI
          0, // OSC1_XENV
          3, // OSC2_WAVEFORM
          201, // OSC2_VOL
          128, // OSC2_SEMI
          5, // OSC2_DETUNE
          0, // OSC2_XENV
          0, // NOISE_VOL
          5, // ENV_ATTACK
          6, // ENV_SUSTAIN
          58, // ENV_RELEASE
          0, // LFO_WAVEFORM
          195, // LFO_AMT
          6, // LFO_FREQ
          1, // LFO_FX_FREQ
          3, // FX_FILTER
          30, // FX_FREQ
          0, // FX_RESONANCE
          2, // FX_DIST
          44, // FX_DRIVE
          147, // FX_PAN_AMT
          6, // FX_PAN_FREQ
          121, // FX_DELAY_AMT
          6 // FX_DELAY_TIME
          ],
          // Patterns
          p: [,,1,2,1,2,,,,,1,2,,,1,2,1,2,1,2,,,,,,,1,2],
          // Columns
          c: [
            {n: [127,,135,,144,,151,,127,,135,,144,,151,,127,,135,,142,,151,,127,,135,,142,,151],
             fx: []},
            {n: [125,,134,,142,,149,,125,,134,,142,,149,,125,,132,,140,,149,,127,,134,,143,,151],
             fx: []}
          ]
        },
        { // Instrument 6
          i: [
          2, // OSC1_WAVEFORM
          146, // OSC1_VOL
          140, // OSC1_SEMI
          0, // OSC1_XENV
          1, // OSC2_WAVEFORM
          224, // OSC2_VOL
          128, // OSC2_SEMI
          3, // OSC2_DETUNE
          0, // OSC2_XENV
          0, // NOISE_VOL
          0, // ENV_ATTACK
          0, // ENV_SUSTAIN
          95, // ENV_RELEASE
          3, // LFO_WAVEFORM
          179, // LFO_AMT
          5, // LFO_FREQ
          1, // LFO_FX_FREQ
          3, // FX_FILTER
          59, // FX_FREQ
          135, // FX_RESONANCE
          4, // FX_DIST
          23, // FX_DRIVE
          150, // FX_PAN_AMT
          3, // FX_PAN_FREQ
          128, // FX_DELAY_AMT
          6 // FX_DELAY_TIME
          ],
          // Patterns
          p: [,,,,,,1,3,1,2,,,1,3,1,2,,,,,4,5,4,5,6,7,6,7,6,7],
          // Columns
          c: [
            {n: [144,,,,,,,,,,,,,,,,,,,,,,,,147,,,,142],
             fx: [11,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,91]},
            {n: [,,,,,,,,,,,,,,,,149,,147,,149,,147,,149,,151],
             fx: [,,,,,,,,,,,,,,,,11,,,,,,,,,,,,11,,,,,,,,,,,,,,,,,,,,8,,,,,,,,,,,,91]},
            {n: [,,,,,,,,,,,,,,,,149,,,,151],
             fx: []},
            {n: [144,,139,,144,,,,,,,,139,,144,,147],
             fx: [11]},
            {n: [137,,142,,146,,,,,,,,,,,,149,,144,,140,,144,,151,,146,,143,,146],
             fx: []},
            {n: [132,,,,132,,,,,,,,,,123,,127,,,,,,,,,,,,,,,,,,,,135,,,,,,,,,,,,130,,,,,,,,,,,,,,,,,,,,139,,,,,,,,,,,,135],
             fx: []},
            {n: [130,,,,125,,,,,,,,,,125,,128,,,,,,,,131,,,,,,,,,,,,130,,,,,,,,,,,,132,,,,,,,,134,,,,,,,,,,,,134,,,,,,,,,,,,137,,,,,,,,139],
             fx: []}
          ]
        },
        { // Instrument 7
          i: [
          1, // OSC1_WAVEFORM
          192, // OSC1_VOL
          104, // OSC1_SEMI
          1, // OSC1_XENV
          0, // OSC2_WAVEFORM
          80, // OSC2_VOL
          99, // OSC2_SEMI
          0, // OSC2_DETUNE
          1, // OSC2_XENV
          72, // NOISE_VOL
          4, // ENV_ATTACK
          0, // ENV_SUSTAIN
          167, // ENV_RELEASE
          3, // LFO_WAVEFORM
          0, // LFO_AMT
          0, // LFO_FREQ
          0, // LFO_FX_FREQ
          2, // FX_FILTER
          6, // FX_FREQ
          1, // FX_RESONANCE
          6, // FX_DIST
          51, // FX_DRIVE
          125, // FX_PAN_AMT
          11, // FX_PAN_FREQ
          0, // FX_DELAY_AMT
          0 // FX_DELAY_TIME
          ],
          // Patterns
          p: [,,,,,,1,,,,,,1,,,,,,,,,,1,,1,,,,,,1],
          // Columns
          c: [
            {n: [147],
             fx: []}
          ]
        }
      ],
      rowLen: 5513,   // In sample lengths
      endPattern: 32  // End pattern
    };

    //**************************************************************************
    // End of Music
    //**************************************************************************

    //--------------------------------------------------------------------------
    // Private methods
    //--------------------------------------------------------------------------

    // Oscillators
    var osc_sin = function (value) {
        return Math.sin(value * 6.283);
    };

    var osc_saw = function (value) {
        return 2 * (value % 1) - 1;
    };

    var osc_square = function (value) {
        return (value % 1) < 0.5 ? 1 : -1;
    };

    var osc_tri = function (value) {
        var v2 = (value % 1) * 4;
        if(v2 < 2) return v2 - 1;
        return 3 - v2;
    };

    // Array of oscillator functions
    var mOscillators = [
        osc_sin,
        osc_square,
        osc_saw,
        osc_tri
    ];

    var getnotefreq = function (n) {
        // 174.61.. / 44100 = 0.003959503758 (F)
        return 0.00396 * Math.pow(2, (n-256)/12);
    };


    //--------------------------------------------------------------------------
    // Public methods
    //--------------------------------------------------------------------------

    // Initialize buffers etc.
    var mNumSamples = mSong.rowLen * 32 * (mSong.endPattern - 1),
        mNumWords = mNumSamples * 2,
        mChnBufWork = new Int32Array(mNumWords),
        mMixBufWork = new Int32Array(mNumWords);

    // Generate audio data for a single track
    var generateMusic = function (track) {
        // Local variables
        var i, j, b, p, row, col, n, cp,
            k, t, lfor, e, x, rsample, rowStartSample, f, da;

        // Put performance critical items in local variables
        var chnBuf = mChnBufWork,
            mixBuf = mMixBufWork,
            waveSamples = mNumSamples,
            waveWords = mNumWords,
            instr = mSong.songData[track],
            rowLen = mSong.rowLen;

        // Clear channel buffer
        for (b = 0; b < waveWords; b ++)
            chnBuf[b] = 0;

        // Clear effect state
        var low = 0, band = 0, high;
        var lsample, filterActive = false;

        for (p = 0; p < (mSong.endPattern - 1); ++p) // Patterns
        {
            cp = instr.p[p];
            for (row = 0; row < 32; ++row) // Pattern rows
            {
                // Execute effect command.
                var cmdNo = cp ? instr.c[cp - 1].fx[row] : 0;
                if (cmdNo)
                    instr.i[cmdNo-1] = instr.c[cp - 1].fx[row+32] || 0;

                // Put performance critical instrument properties in local variables
                var osc1 = mOscillators[instr.i[0]],
                    o1vol = instr.i[1],
                    o1xenv = instr.i[3],
                    osc2 = mOscillators[instr.i[4]],
                    o2vol = instr.i[5],
                    o2xenv = instr.i[8],
                    noiseVol = instr.i[9],
                    attack = instr.i[10] * instr.i[10] * 4,
                    sustain = instr.i[11] * instr.i[11] * 4,
                    release = instr.i[12] * instr.i[12] * 4,
                    oscLFO = mOscillators[instr.i[13]],
                    lfoAmt = instr.i[14] / 512,
                    lfoFreq = Math.pow(2, instr.i[15] - 9) / rowLen,
                    fxLFO = instr.i[16],
                    fxFilter = instr.i[17],
                    fxFreq = instr.i[18] * 0.0031, // 43.23529 * 3.141592 / 44100,
                    q = 1 - instr.i[19] / 255,
                    dist = instr.i[20] * 1e-5,
                    drive = instr.i[21] / 32,
                    panAmt = instr.i[22] / 512,
                    panFreq = 6.283 * Math.pow(2, instr.i[23] - 9) / rowLen,
                    dlyAmt = instr.i[24] / 255,
                    dly = instr.i[25] * rowLen;

                // Calculate start sample number for this row in the pattern
                rowStartSample = (p * 32 + row) * rowLen;

                // Generate notes for this pattern row
                for (col = 0; col < 4; ++col) {
                    n = cp ? instr.c[cp - 1].n[row+col*32] : 0;
                    if (n) {
                        // Calculate note frequencies for the oscillators
                        var o1t = getnotefreq(n + instr.i[2]);
                        var o2t = getnotefreq(n + instr.i[6]) * (1 + .0008 * instr.i[7]);

                        // Re-trig oscillators
                        var c1 = 0, c2 = 0;

                        // Generate one note (attack + sustain + release)
                        for (j = 0; j < attack + sustain + release; j++) {
                            // Envelope
                            e = 1;
                            if (j < attack)
                                e = j / attack;
                            else if (j >= attack + sustain)
                                e -= (j - attack - sustain) / release;

                            // Oscillator 1
                            t = o1t;
                            if (o1xenv)
                                t *= e * e;
                            c1 += t;
                            rsample = osc1(c1) * o1vol;

                            // Oscillator 2
                            t = o2t;
                            if (o2xenv)
                                t *= e * e;
                            c2 += t;
                            rsample += osc2(c2) * o2vol;

                            // Noise oscillator
                            if (noiseVol)
                                rsample += (2 * rnd() - 1) * noiseVol;

                            // Add to (mono) channel buffer
                            chnBuf[(rowStartSample + j) * 2] += 80 * rsample * e;
                        }
                    }
                }

                // Perform effects for this pattern row
                for (j = 0; j < rowLen; j++) {
                    // Dry mono-sample
                    k = (rowStartSample + j) * 2;
                    rsample = chnBuf[k];

                    // We only do effects if we have some sound input
                    if (rsample || filterActive) {
                        // State variable filter
                        f = fxFreq;
                        if (fxLFO)
                            f *= oscLFO(lfoFreq * k) * lfoAmt + 0.5;
                        f = 1.5 * Math.sin(f);
                        low += f * band;
                        high = q * (rsample - band) - low;
                        band += f * high;
                        rsample = fxFilter == 3 ? band : fxFilter == 1 ? high : low;

                        // Distortion
                        if (dist) {
                            rsample *= dist;
                            rsample = rsample < 1 ? rsample > -1 ? osc_sin(rsample*.25) : -1 : 1;
                            rsample /= dist;
                        }

                        // Drive
                        rsample *= drive;

                        // Is the filter active (i.e. still audiable)?
                        filterActive = rsample * rsample > 1e-5;

                        // Panning
                        t = Math.sin(panFreq * k) * panAmt + 0.5;
                        lsample = rsample * (1 - t);
                        rsample *= t;
                    } else
                        lsample = 0;

                    // Delay is always done, since it does not need sound input
                    if (k >= dly) {
                        // Left channel = left + right[-p] * t
                        lsample += chnBuf[k-dly+1] * dlyAmt;

                        // Right channel = right + left[-p] * t
                        rsample += chnBuf[k-dly] * dlyAmt;
                    }

                    // Store in stereo channel buffer (needed for the delay effect)
                    chnBuf[k] = lsample;
                    chnBuf[k+1] = rsample;

                    // ...and add to stereo mix buffer
                    mixBuf[k] += lsample;
                    mixBuf[k+1] += rsample;
                }
            }
        }
    };

    // Create a WAVE formatted sting from the generated audio data
    var createAudio = function () {
        // Local variables
        var b, k, x, wave, l1, l2, s, y;

        // Turn critical object properties into local variables (performance)
        var mixBuf = mMixBufWork,
            waveWords = mNumWords;

        // We no longer need the channel working buffer
//        mChnBufWork = null;

        // Convert to a WAVE file (in a binary string)
        l1 = waveWords * 2 - 8;
        l2 = l1 - 36;
        wave = String.fromCharCode(82,73,70,70,
                                   l1 & 255,(l1 >> 8) & 255,(l1 >> 16) & 255,(l1 >> 24) & 255,
                                   87,65,86,69,102,109,116,32,16,0,0,0,1,0,2,0,
                                   68,172,0,0,16,177,2,0,4,0,16,0,100,97,116,97,
                                   l2 & 255,(l2 >> 8) & 255,(l2 >> 16) & 255,(l2 >> 24) & 255);
/*
        for (b = 0; b < waveWords;) {
            // This is a GC & speed trick: don't add one char at a time - batch up
            // larger partial strings
            x = "";
            for (k = 0; k < 256 && b < waveWords; ++k, b++)
            {
                // Note: We clamp here
                y = mixBuf[b];
                y = y < -32767 ? -32767 : (y > 32767 ? 32767 : y);
                x += String.fromCharCode(y & 255, (y >> 8) & 255);
            }
            wave += x;
        }
*/
        for (b = 0; b < waveWords;) {
            // Note: We clamp here
            y = mixBuf[b++];
            y = y < -32767 ? -32767 : (y > 32767 ? 32767 : y);
            wave += String.fromCharCode(y & 255, (y >> 8) & 255);
        }

        // Return the wave formatted string
        return new Audio("data:audio/wav;base64," + btoa(wave));
    };


// 5x7 font

    var mFont = [
// ' ' (space) - 32
// .....
// .....
// .....
// .....
// .....
// .....
// .....
,,,,,,,

// ! - 33
// .....  0
// .#...  8
// .#...  8
// .#...  8
// .#...  8
// .....  0
// .#...  8
,8,8,8,8,,8,

// 0 - 48
// .....  0
// .....  0
// ##### 31
// #...# 17
// #.#.# 21
// #...# 17
// ##### 31
,,31,17,21,17,31,

// 1
// .....  0
// .....  0
// .##.. 12
// ..#..  4
// ..#..  4
// ..#..  4
// ..#..  4
,,12,4,4,4,4,

// 2
// .....  0
// .....  0
// ##### 31
// ....#  1
// ##### 31
// #.... 16
// ##### 31
,,31,1,31,16,31,

// 3
// .....  0
// .....  0
// ##### 31
// ....#  1
// .#### 15
// ....#  1
// ##### 31
,,31,1,15,1,31,

// 4
// .....  0
// .....  0
// #...# 17
// #...# 17
// ##### 31
// ....#  1
// ....#  1
,,17,17,31,1,1,

// 5
// .....  0
// .....  0
// ##### 31
// #.... 16
// ##### 31
// ....#  1
// ##### 31
,,,,,,, // unused

// 6
// .....  0
// .....  0
// ##### 31
// #.... 16
// ##### 31
// #...# 17
// ##### 31
,,,,,,, // unused

// 7
// .....  0
// .....  0
// ##### 31
// ....#  1
// ....#  1
// ....#  1
// ....#  1
,,31,1,1,1,1,

// 8
// .....  0
// .....  0
// ##### 31
// #...# 17
// ##### 31
// #...# 17
// ##### 31
,,,,,,, // unused

// 9 - 57
// .....  0
// .....  0
// ##### 31
// #...# 17
// ##### 31
// ....#  1
// ##### 31
,,,,,,, // unused

// @ - 64
// .###. 14
// #...# 17
// #.### 23
// #.#.# 21
// #.### 23
// #.... 16
// .###. 14
14,17,23,21,23,16,14,

// a - 97
// .....  0
// .....  0
// ##### 31
// ....#  1
// ##### 31
// #...# 17
// ##### 31
,,31,1,31,17,31,

// b
// #.... 16
// #.... 16
// ##### 31
// #...# 17
// #...# 17
// #...# 17
// ##### 31
16,16,31,17,17,17,31,

// c
// .....  0
// .....  0
// ##### 31
// #.... 16
// #.... 16
// #.... 16
// ##### 31
,,31,16,16,16,31,

// d
// ....#  1
// ....#  1
// ##### 31
// #...# 17
// #...# 17
// #...# 17
// ##### 31
1,1,31,17,17,17,31,

// e
// .....  0
// .....  0
// ##### 31
// #...# 17
// ##### 31
// #.... 16
// ##### 31
,,31,17,31,16,31,

// f
// ..###  7
// ..#..  4
// .###. 14
// ..#..  4
// ..#..  4
// ..#..  4
// ..#..  4
7,4,14,4,4,4,4,

// g
// .....  0
// .....  0
// ##### 31
// #...# 17
// ##### 31
// ....#  1
// ##### 31
,,31,17,31,1,31,

// h
// #.... 16
// #.... 16
// ##### 31
// #...# 17
// #...# 17
// #...# 17
// #...# 17
16,16,31,17,17,17,17,

// i
// ..#..  4
// .....  0
// ..#..  4
// ..#..  4
// ..#..  4
// ..#..  4
// ..#..  4
4,,4,4,4,4,4,

// j
// ..#..  4
// .....  0
// ..#..  4
// ..#..  4
// ..#..  4
// ..#..  4
// ###.. 28
,,,,,,, // unused

// k
// #.... 16
// #.... 16
// #...# 17
// #..#. 18
// ###.. 28
// #..#. 18
// #...# 17
16,16,17,18,28,18,17,

// l
// ..#..  4
// ..#..  4
// ..#..  4
// ..#..  4
// ..#..  4
// ..#..  4
// ..###  7
4,4,4,4,4,4,7,

// m
// .....  0
// .....  0
// ##### 31
// #.#.# 21
// #.#.# 21
// #.#.# 21
// #.#.# 21
,,31,21,21,21,21,

// n
// .....  0
// .....  0
// ##### 31
// #...# 17
// #...# 17
// #...# 17
// #...# 17
,,31,17,17,17,17,

// o
// .....  0
// .....  0
// ##### 31
// #...# 17
// #...# 17
// #...# 17
// ##### 31
,,31,17,17,17,31,

// p
// .....  0
// .....  0
// ##### 31
// #...# 17
// #...# 17
// ##### 31
// #.... 16
,,31,17,17,31,16,

// q
// .....  0
// .....  0
// ##### 31
// #...# 17
// #...# 17
// ##### 31
// ....#  1
,,,,,,, // unused

// r
// .....  0
// .....  0
// ##### 31
// #.... 16
// #.... 16
// #.... 16
// #.... 16
,,31,16,16,16,16,

// r
// .....  0
// .....  0
// ##### 31
// #.... 16
// ##### 31
// ....#  1
// ##### 31
,,31,16,31,1,31,

// t
// #.... 16
// #.... 16
// ###.. 28
// #.... 16
// #.... 16
// #.... 16
// ##### 31
16,16,28,16,16,16,31,

// u
// .....  0
// .....  0
// #...# 17
// #...# 17
// #...# 17
// #...# 17
// ##### 31
,,17,17,17,17,31,

// v
// .....  0
// .....  0
// #...# 17
// #...# 17
// #...# 17
// .#.#. 10
// ..#..  4
,,17,17,17,10,4,

// w
// .....  0
// .....  0
// #...# 17
// #.#.# 21
// #.#.# 21
// #.#.# 21
// ##### 31
,,17,21,21,21,31,

// x
// .....  0
// .....  0
// #...# 17
// .#.#. 10
// ..#..  4
// .#.#. 10
// #...# 17
,,17,10,4,10,17,

// y
// .....  0
// .....  0
// #...# 17
// #...# 17
// ##### 31
// ....#  1
// ##### 31
,,17,17,31,1,31,

// z
// .....  0
// .....  0
// ##### 31
// ...#.  2
// ..#..  4
// .#...  8
// ##### 31
,,,,,,, // unused

// .
// .....  0
// .....  0
// .....  0
// .....  0
// .....  0
// .....  0
// .#...  8
,,,,,,8,

// ,
// .....  0
// .....  0
// .....  0
// .....  0
// .....  0
// .#...  8
// #.... 16
,,,,,8,16

],

    // Vertex shader
    mVertexSrcs = [
// 0: Standard
"attribute vec2 p;"+
"void main(){"+
  "gl_Position=vec4(p,0,1);"+
"}"
,

// 1: Scrolltext
"uniform float t;"+
"attribute vec4 p;"+
"varying vec2 b;"+
"void main(){"+
  "gl_Position=vec4(3.*p.x-t*.6,5.*p.y+.2*cos(p.x-t),0,1);"+
  "b=p.zw;"+
"}"
,

// 2: Stars (3D)
"uniform float t;"+
"attribute vec3 p;"+
"void main(){"+
  "vec3 q=p;"+
  "if(t<64.)"+
    "q.x=fract(q.x+t/8.);"+
  "else "+
    "q.z=fract(q.z-t/4.);"+
  "gl_PointSize=5.-5.*q.z;"+
  "gl_Position=vec4(2.*q.xy-1.,q.z,q.z);"+
"}"
,

// 3: Mesh (2D -> 3D)
"uniform float t;"+
"attribute vec2 p;"+
"varying vec3 n,b;"+

"vec2 r(vec2 q,float a){"+
  "float c=cos(a),s=sin(a);"+
  "return vec2(q.x*c-q.y*s,q.x*s+q.y*c);"+
"}"+

"vec3 f(vec2 q){"+

  // Blend between two different shapes
  "q*=3.1415;"+
  "vec3 s=mix("+

    // Waves
    ".4*vec3("+
      "q.x,"+
      "q.y,"+
      "(cos(2.*t+2.*q.x)+cos(2.*t+2.*q.y))"+
    "),"+

    // Torus
    "vec3("+
      "(1.+.3*cos(q.x))*cos(q.y),"+
      "(1.+.3*cos(q.x))*sin(q.y),"+
      ".3*sin(q.x)"+
    "),"+

    "clamp(.5+cos(.04*t),0.,1.)"+
  ");"+

  // Rotate
  "s.xz=r(s.xz,t);"+
  "s.yz=r(s.yz,.3*t);"+

  "return s*clamp(t-16.,0.,1.);"+
"}"+

"void main(){"+
  "n=normalize(cross(f(p+vec2(.0,.01))-f(p),f(p+vec2(.01,.0))-f(p)));"+
  "b=vec3(.7,1,1)*f(p)+vec3(0,0,2);"+

  "gl_Position=vec4(b,b.z+1.);"+
"}"

],

    // Fragment shader
    mFragmentSrcs = [

// 0: Progress bar
"precision highp float;" +
"uniform float t;"+
"uniform vec2 r;"+

"void main(){"+
  "vec2 p=gl_FragCoord.xy/r.xy;"+
  "float x=0.,y,z=1.9;"+
  "if(p.x<t){"+
    "x=p.x;"+
    "z=2.;"+
  "}"+
  "y=2.*max(0.,z-20.*abs(p.y-.5));"+
  "gl_FragColor=vec4(y*x,y*.3,y-y*x,1);"+
"}"
,

// 1: Background & raster bars
"precision highp float;" +
"uniform float t;"+
"uniform vec2 r;"+

"void main(){"+
    "vec2 p=gl_FragCoord.xy/r.xy-.5;"+

    // Background rays
    "float s=length(p),"+
          "a=atan(p.y,p.x),"+
          "c=cos(19.*a+8.3*t)+"+
            "cos(7.*a-.7*t)+"+
            "cos(3.*a-3.3*t);"+
    "vec3 col=vec3(1,.8,.6)*min(3.,t)*max(0.,c)*s*s*s;"+

    // Raster bars during 8 s - 40 s
    "if(t>8.&&t<40.)"+
        "for(float k=0.;k<10.;k++){"+
            "float l=k*.1,"+
                  "d=1.-(35.+20.*cos(.3*t+16.))*abs(p.y-.3*cos(3.*l+1.4*t+cos(t)*p.x));"+
            "if(d>0.)"+
                "col=vec3(l*d,(1.-l)*d,(.5+.5*cos(l+t))*d);"+
        "}"+

    // Fade-out after ~120 s
    "gl_FragColor=vec4(col*min(1.,.2*(120.-t)),1);"+
"}"
,

// 2: Scrolltext
"precision highp float;" +
"varying vec2 b;"+

"void main(){"+
    "float s=max(0.,1.-length(b));"+
    "gl_FragColor=vec4(.5,1,.5,1)*min(1.,s*s+s+s);"+
"}"
,

// 3: Stars
"precision highp float;" +
"uniform float t;"+

"void main(){"+
    "gl_FragColor=vec4(1,1,1,max(0.,min(t-40.,124.-t)));"+
"}"
,

// 4: Mesh
"precision highp float;" +
"varying vec3 n,b;"+

"void main(void){"+
/*
    "vec3 v=normalize(-b),"+
         "l=normalize(vec3(1,1,0)-b);"+
    "float d=.3+max(0.,.7*dot(l,n)),"+
          "s=max(0.,.8*pow(dot(normalize(2.*dot(l,n)*n-l),v),10.));"+
    "gl_FragColor=vec4(vec3(d+s),1);"+
*/
    "vec3 v=normalize(-b);"+
    "gl_FragColor=vec4(vec3(.3+.6*abs(dot(v,n))+.8*max(0.,pow(dot(normalize(2.*dot(v,n)*n-v),v),10.))),1);"+
"}"

],

    // Programs
    mProgramSrcs = [
        [0, 0],     // Progress bar
        [0, 1],     // Raster & background
        [1, 2],     // Scrolltext
        [2, 3],     // Stars
        [3, 4]      // Mesh
    ],


    // "Scroll" text
    mScrollText =
    "music|  " +
    "scroller|  " +
    "raster bars|  " +
    "sx7 font|  " +
    "3d torus{{{   " +
    "yes| welcome to a 4k intro from m@bitsnbites!     " +
    "3d star field{{{ go!      " +
    "sorry for the simple design{ " +
    "this time i wanted to toy around with vertex shaders| and this is the result{        " +
    "all in all| this demo uses about 3s3s0 vertices and plays 124 seconds of music{      " +
    "happy 2013| everybody!!!       " +
    "and keep coding{{{"
    ,

    // Misc global variables
    gl, mAudio, mInitState = -2, mCanvas, mWidth, mHeight, mVertBuf1, mVertBuf2,
    mVertBuf3, mVertBuf4, mNumScrollVertices, mNumStarVertices, mNumMeshVertices,
    mPrograms = [];

    // Some constants - optimized away by closure compiler
    // These are usually shorter than using the gl.NAME variants, since they
    // will be replaced by numeric constants rather than propery long names.
    var VERTEX_SHADER = 0x8B31,
        FRAGMENT_SHADER = 0x8B30,
        ARRAY_BUFFER = 0x8892,
        STATIC_DRAW = 0x88E4,
        COLOR_BUFFER_BIT = 0x4000,
        POINTS = 0,
        TRIANGLES = 4,
        TRIANGLE_STRIP = 5,
        FLOAT = 0x1406,
        TEXTURE_2D = 0x0DE1,
        TEXTURE0 = 0x84C0,
        TEXTURE1 = 0x84C1,
        TEXTURE2 = 0x84C2,
        TEXTURE_MAG_FILTER = 0x2800,
        TEXTURE_MIN_FILTER = 0x2801,
        NEAREST = 0x2600,
        LINEAR = 0x2601,
        TEXTURE_WRAP_S = 0x2802,
        TEXTURE_WRAP_T = 0x2803,
        CLAMP_TO_EDGE = 0x812F,
        RGB = 0x1907,
        RGBA = 0x1908,
        SCISSOR_TEST = 0x0C11,
        UNSIGNED_BYTE = 0x1401,
        BLEND = 0x0BE2,
        SRC_ALPHA = 0x0302,
        ONE_MINUS_SRC_ALPHA = 0x0303,
        DEPTH_TEST = 0x0B71,
        DEPTH_BUFFER_BIT = 0x00000100;

    var getUniformLocation = function(prog, id) {
        return gl.getUniformLocation(prog, id);
    }

    var mStartT = 0;

    var getCurrentTime = function () {
        // Calculate current time according to Date()
        var t = (new Date()).getTime() * 0.001;

        // Get current time according to the audio element
        var audioCurrentTime = mAudio ? mAudio.currentTime : 0;

        // Use audio time during first second, then use Date()
        if (audioCurrentTime < 1) {
          mStartT = t - audioCurrentTime;
        }
        return t - mStartT;
    };

    var getCurrentTimeNoAudio = function () {
        var t = (new Date()).getTime() * 0.001;
        if (mStartT < 1)
            mStartT = t;
        var currentTime = t - mStartT;

        return currentTime;
    };

    var main = function() {
//        try {
            var win = window;

            // Animation
            var anim = win.webkitRequestAnimationFrame || win.mozRequestAnimationFrame;
            if (anim)
                anim(main);
            else
                setTimeout(main, 16);

            // Update canvas size
            var w = win.innerWidth,
                h = win.innerHeight;
            if (w != mWidth || h != mHeight) {
                mCanvas.width = w;
                mCanvas.height = h;
                gl.viewport(0, 0, w, h);
                mWidth = w;
                mHeight = h;
            }

            var enableAudio = false;

		    // Get the current tick.See this bug for a reference as to why we
		    // work around Audio.currentTime:
            // https://bugzilla.mozilla.org/show_bug.cgi?id=587465
            var t = enableAudio ? getCurrentTime() : getCurrentTimeNoAudio();

            // Select shader program
            var prog;

            // Update initialization
            mInitState++;
            if (mInitState < 0)
                return;
            if (mInitState < 9) {
                // This is our "progress bar"
                prog = mPrograms[0];
                t = mInitState/8;

                if (enableAudio) {
                    if (mInitState == 8) {
                        // Get & start playing the audio element!
                        mAudio = createAudio();
                        mAudio.play();
                    }
                    else {
                        // Generate music!
                        if (mInitState >= 0) generateMusic(mInitState);
                    }
                }
            }
            else {
                // Select program
                prog = mPrograms[1];
            }

            // Clear depth buffer
            gl.clear(DEPTH_BUFFER_BIT);

            // Draw background screen
            gl.useProgram(prog);
            gl.uniform1f(getUniformLocation(prog,"t"), t);
            gl.uniform2f(getUniformLocation(prog,"r"), w, h);
            gl.enableVertexAttribArray(0);

            gl.bindBuffer(ARRAY_BUFFER, mVertBuf1);
            gl.vertexAttribPointer(0, 2, FLOAT, false, 0, 0); // position
            gl.drawArrays(TRIANGLE_STRIP, 0, 4);

            if (mInitState >= 9) {
                // Draw stars
                gl.useProgram(mPrograms[3]);
                gl.uniform1f(getUniformLocation(mPrograms[3],"t"), t);

                gl.bindBuffer(ARRAY_BUFFER, mVertBuf3);
                gl.vertexAttribPointer(0, 3, FLOAT, false, 0, 0); // 3D position
                gl.drawArrays(POINTS, 0, 5000); // mNumStarVertices);

                // Draw 3D mesh object
                gl.enable(DEPTH_TEST);
                gl.useProgram(mPrograms[4]);
                gl.uniform1f(getUniformLocation(mPrograms[4],"t"), t);

                gl.bindBuffer(ARRAY_BUFFER, mVertBuf4);
                gl.vertexAttribPointer(0, 2, FLOAT, false, 0, 0); // 2D position
                gl.drawArrays(TRIANGLE_STRIP, 0, 7564); // mNumMeshVertices);
                gl.disable(DEPTH_TEST);

                // Draw scrolltext
                gl.useProgram(mPrograms[2]);
                gl.uniform1f(getUniformLocation(mPrograms[2],"t"), t);

                gl.bindBuffer(ARRAY_BUFFER, mVertBuf2);
                gl.vertexAttribPointer(0, 4, FLOAT, false, 0, 0); // position + "uv coord"
                gl.drawArrays(TRIANGLES, 0, mNumScrollVertices);
            }
//        }
//        catch (err) {
//            alert("Error: " + err.message);
//        }
    };

    // App startup
    (function () {
//        try {
            // Hide the JSEXE-generated canvas element ("V")
            V.width = 1;

            // Init WebGL context
            mCanvas = document.createElement("canvas");
            document.body.appendChild(mCanvas);
            var s = mCanvas.style;
            s.position = "fixed";
            s.left = s.top = 0;
            gl = mCanvas.getContext('experimental-webgl');
//            gl = mCanvas.getContext('webgl') || mCanvas.getContext('experimental-webgl');
//            if (!gl) {
//                alert("This demo requires WebGL");
//                return;
//            }

            // Init shaders
            for (var k = 0; k < 5; ++k) {
                var prg = gl.createProgram();

                var j = gl.createShader(VERTEX_SHADER);
                gl.shaderSource(j, mVertexSrcs[mProgramSrcs[k][0]]);
                gl.compileShader(j);
//                if (!gl.getShaderParameter(j, gl.COMPILE_STATUS)) alert("Vertex shader: "+ gl.getShaderInfoLog(j));
                gl.attachShader(prg, j);

                j = gl.createShader(FRAGMENT_SHADER);
                gl.shaderSource(j, mFragmentSrcs[mProgramSrcs[k][1]]);
                gl.compileShader(j);
//                if (!gl.getShaderParameter(j, gl.COMPILE_STATUS)) alert("Fragment shader: "+ gl.getShaderInfoLog(j));
                gl.attachShader(prg, j);

                gl.linkProgram(prg);
//                if (!gl.getProgramParameter(prg, gl.LINK_STATUS)) alert("Link program: "+ gl.getProgramInfoLog(p[i]));

                mPrograms[k] = prg;
            }

            // Init vertex buffer for a regular screen-sized quad
            var vertices = [-1,-1, -1,1, 1,-1, 1,1];
            mVertBuf1 = gl.createBuffer();
            gl.bindBuffer(ARRAY_BUFFER, mVertBuf1);
            gl.bufferData(ARRAY_BUFFER, new Float32Array(vertices), STATIC_DRAW);

            // Init vertex buffer for the scroll text
            vertices = [];
            var x0 = 0.5;
            for (k = 0; k < mScrollText.length; ++k) {
                var idx = mScrollText.charCodeAt(k);
                idx -= idx < 48 ? 32 : (idx < 64 ? 46 : (idx < 97 ? 52 : 84));
                idx *= 7;
                var y = 0.03;
                for (var l = 0; l < 7; ++l) {
                    var bits = mFont[idx];
                    var x = x0 + 0.1;
                    while (bits) {
                        if (bits & 1) {
                            vertices.push(
                                x,y,-1,-1,
                                x,y+0.01,-1,1,
                                x+0.01,y+0.01,1,1,
                                x,y,-1,-1,
                                x+0.01,y+0.01,1,1,
                                x+0.01,y,1,-1
                            );
                        }
                        bits >>= 1;
                        x -= 0.01;
                    }
                    idx++;
                    y -= 0.01;
                }
                x0 += 0.06;
            }
            mNumScrollVertices = vertices.length / 4;
            mVertBuf2 = gl.createBuffer();
            gl.bindBuffer(ARRAY_BUFFER, mVertBuf2);
            gl.bufferData(ARRAY_BUFFER, new Float32Array(vertices), STATIC_DRAW);

            // Init vertex buffer for the 3D star field
            vertices = [];
            for (k = 0; k < 5000*3; ++k)
                vertices.push(rnd());
//            mNumStarVertices = 5000;
            mVertBuf3 = gl.createBuffer();
            gl.bindBuffer(ARRAY_BUFFER, mVertBuf3);
            gl.bufferData(ARRAY_BUFFER, new Float32Array(vertices), STATIC_DRAW);

            // Init vertex buffer for the 3D morph object
            vertices = [];
            s = 30;
            for (l = -s; l <= s; ++l) {
                for (k = -s; k <= s; ++k) {
                    vertices.push(k/s, l/s, k/s, (l+1)/s);
                }
                // Degenerate triangles -> break between two strips
                vertices.push(1, (l+1)/s, -1, (l+1)/s);
            }
//            mNumMeshVertices = vertices.length / 2;
            mVertBuf4 = gl.createBuffer();
            gl.bindBuffer(ARRAY_BUFFER, mVertBuf4);
            gl.bufferData(ARRAY_BUFFER, new Float32Array(vertices), STATIC_DRAW);

            // Enable blending
            gl.enable(BLEND);
            gl.blendFunc(SRC_ALPHA, ONE_MINUS_SRC_ALPHA);

            // Start the main loop
            main();
//        }
//        catch (err) {
//            alert("Error initializing: " + err.message);
//        }
    })();
})();

