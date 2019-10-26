#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include "main.h"

#include "tune.h"
#define sth (*((struct Sth *)&tune_sth))

struct _Env {
  int len;
  float inc;
};

struct Sth {
struct _Env envs[8][2][6];
float freq[8];
float cutoff[8];
float mod[8];
float reso[8];
float frqmod[8];
float vol[8], vol2[8];
float phase[8];
int env_len[8][2];
unsigned char mode[8];
float lfoinit[8];
float lforate[8];
float lfomod[8];
unsigned char orders[8][64];
unsigned char _patterns[256][16];
unsigned int counter;
struct _Env *env_ptr[8][2];
float env_out[8][2];
float lpf[8], bpf[8];
unsigned char *pattern[8];
};

unsigned char **order[8];
unsigned char *orders[8][64];
const int samples_per_note = 5088, samples_per_pattern = 16*5088;

#define clamp(x, a, b) ((x) < (a) ? (a) : (x) > (b) ? (b) : (x))

void
synth_init()
{
  int k = 7;
  do {
    int i = 63;
    do {
      orders[k][i] = sth._patterns[sth.orders[k][i]];
    } while (i--);
    order[k] = orders[k];
  } while (k--);
}

void
synth_render(short *buf, int len) 
{
  int note, k, x, j;
  float y, cf;
  do {
    k = 7;
    x = 0;
    do {
      if (sth.counter % samples_per_note == 0) {
        if (sth.counter % samples_per_pattern == 0) sth.pattern[k] = *order[k]++;
        if (sth.pattern[k]) note = *sth.pattern[k]++;
        if (note & 127) {
          j = 1;
          do {
          sth.env_out[k][j] = 0.0;
          sth.env_len[k][j] = sth.envs[k][j][0].len;
          sth.env_ptr[k][j] = sth.envs[k][j];
          } while (j--);
          sth.vol2[k] = 0.5 * (2 - (note >> 7));// ? 0.2f : 1.0f;
//          sth.vol2[k] = (note >> 7) ? 0.2f : 1.0f;
          sth.freq[k] = pow(2.0f, ((note & 127) - 69) / 12.0f) * (440.0f / 44100.0f);
        }
      }
      j = 1;
      do {
        if (sth.env_ptr[k][j]) {
          if (!sth.env_len[k][j]) {
            sth.env_ptr[k][j]++;
            sth.env_len[k][j] = sth.env_ptr[k][j]->len;
            if (!sth.env_len[k][j]) {
              sth.env_ptr[k][j] = 0;
              goto noEnv;
            }
          }
          sth.env_len[k][j]--;
          sth.env_out[k][j] += sth.env_ptr[k][j]->inc;
        }
      noEnv:
        ;
      } while (j--);
      sth.phase[k] = fmod(sth.phase[k] + sth.freq[k] + sth.frqmod[k] * sth.env_out[k][1], 1.0f);
      switch (sth.mode[k]) {
      case 0:
        y = 2.0f * sth.phase[k] - 1.0f;
        break;
      case 1:
        y = sth.phase[k] < 0.5f ? -1.0f : 1.0f;
        break;
      case 3:
        y = ((rand() & 1023) - 511) / 511.0f;
        break;
      }
      cf = sth.cutoff[k] + sth.mod[k] * sth.env_out[k][1] + sth.lfomod[k] * sinf(sth.lfoinit[k]+sth.counter*sth.lforate[k]);
      cf = clamp(cf, 0.001f, 1.0f);
      sth.bpf[k] += cf * (y - sth.lpf[k] - sth.reso[k] * sth.bpf[k]);
      sth.lpf[k] += cf * sth.bpf[k];
      x += (int)(sth.env_out[k][0] * sth.vol[k] * sth.lpf[k] *sth.vol2[k]);
    } while (k--);
    sth.counter++;
    *buf++ = clamp(x, -32767, 32767);
  } while (--len);
}
