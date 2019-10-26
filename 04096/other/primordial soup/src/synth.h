#ifndef _SYNTH_H_
#define _SYNTH_H_

/// Oversampling amount.
#define SYNTH_OVERSAMPLING 1

// Data required for synth working area.
#define SYNTH_WORK_SIZE (40 * 1024 * 1024)

#if !defined(USE_LD)
#if defined(__cplusplus)
extern "C"
{
#endif

/// External synth.
/// Args passed in eax, edx
/// \param outbuf Output buffer.
/// \param samples Number of samples to generate.
void synth(float *outbuf, int samples) __attribute__((regparm(2)));

#if defined(__cplusplus)
}
#endif
#endif

#endif // _SYNTH_H_
