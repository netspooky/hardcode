#ifndef __GENERATE_H_
#define __GENERATE_H_

#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include "filter.h"

#define G_TRI   1
#define G_SQU   2
#define G_SAW   3
#define G_NOISE 4
#define G_SIN   5
#define G_SINH  6
#define G_COS   7
#define G_COSH  8
#define G_TAN   9
#define G_TANH  10
#define G_ACOS  11
#define G_ASIN  12
#define G_ATAN  13
#define G_LOG   14
#define G_LOG10 15

struct SampleInfo {
  float              frequency;
  float              phy;
  float              amplitude;
  float              pitch_env;
  unsigned short int rate;
  unsigned short int gen_type;
  unsigned int       attack;
  unsigned int       sustain;
  unsigned int       release;
  //Cutoff/resonance filter
  float              cutoff;
  float              resonance;
  float              cut_env;
  float              res_env;
  //Pass filter 
  int                low_freq;
  int                high_freq;
  float              low_env;
  float              high_env;

  short int          filter;
};

double tri(double x);
double squ(double x);
double saw(double x);
double noise(double x);

double g_func(double x, int f_number);
void GenerateSample8(void *buffer,SampleInfo *si);
void GenerateSample16(void *buffer,SampleInfo *si);
#endif