#ifndef __FILTER_H_
#define __FILTER_H_

#ifndef PI
#define PI 3.141592653589793238
#endif

#include <stdio.h>

class CRfilter {
public:
  void SetParams ();
  void Init();
  float Work(float psamples);
public:
  // Filter stuff
  float param_cutoff, param_resonance;
  float filtCoefTab[5];
  float x1, x2, y1, y2; // Left sample history
  int   SampleRate;
  float in, out,  temp_y;
};

#define LOWPASS 2
#define HIGHPASS 4
#define BENDPASS 8

class PassFilter {
public:
  void SetParams ();
  void Init();
  short Work(short c);
  PassFilter();
  ~PassFilter();
public:
  int type;
  // Filter stuff
  short *e_buff;
  int   low_frq, high_frq;
  int   e_head;                   /* голова кольцевого буфеpа */
  int   buff_size;
  int   SampleRate;

  long hi_acc;                  /* накопители сpеднего значения */
  long lo_acc;                  /* для фвч и фнч */
};

#endif