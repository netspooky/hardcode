#ifndef _SYNTH_H_
#define _SYNTH_H_

// Args passed in eax, edx
__attribute__((regparm(2))) void synth(float *outbuf, int samples);

#endif // _SYNTH_H_
